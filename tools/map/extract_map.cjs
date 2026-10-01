// Extracts map geometry from the decompiled map entity file into docs/map/map_data.json.
//
// 1. Decompile the installed map's entity file (Source2Viewer CLI, see docs/OBJECTIVE_TESTING.md):
//      Source2Viewer-CLI.exe -i "<dota>/game/dota/maps/dota.vpk" -f maps/dota/entities/default_ents.vents_c -d -o <dir>
// 2. node tools/map/extract_map.cjs <dir>/maps/dota/entities/default_ents.vents [patch label]
//
// Camp numbers and spawn boxes come from the in-game GetNeutralSpawners() dump (tests/neutral_spawners_741f.lua),
// matched to the map's spawners by position, so the map and the bots use the same camp keys.
const fs = require('fs');
const path = require('path');
const [ventsFile, patch = '7.41f'] = process.argv.slice(2);
if (!ventsFile) { console.error('usage: node tools/map/extract_map.cjs <default_ents.vents> [patch]'); process.exit(1); }
const root = path.resolve(__dirname, '..', '..');

// ---- parse entities --------------------------------------------------------------------------------------
const ents = [];
for (const block of fs.readFileSync(ventsFile, 'utf8').split(/^====\d+====\r?$/m)) {
    const e = {};
    for (const line of block.split(/\r?\n/)) {
        const m = line.match(/^(\S+)\s+(.*)$/);
        if (!m) continue;
        let v = m[2].trim();
        if (/^".*"$/.test(v)) v = v.slice(1, -1);
        else if (/^\[.*\]$/.test(v)) v = v.slice(1, -1).split(',').map(Number);
        e[m[1]] = v;
    }
    if (e.classname) ents.push(e);
}
const of = cls => ents.filter(e => e.classname === cls);
const xy = e => [Math.round(e.origin[0]), Math.round(e.origin[1])];
const name = e => String(e.targetname || '').replace(/^\[PR#\]/, '');
const vec = s => String(s).split(/\s+/).map(Number);
const teamOf = s => /goodguys|good|radiant/i.test(s) ? 'radiant' : /badguys|bad|evil|dire/i.test(s) ? 'dire' : 'neutral';

// ---- camps: merge the map spawners with the in-game dump (keys + spawn boxes) -----------------------------
const fixture = fs.readFileSync(path.join(root, 'tests', 'neutral_spawners_741f.lua'), 'utf8');
const dump = [];
const num = '(-?[\\d.]+)';
const v3 = k => new RegExp(k + ' = V\\(' + num + ', ' + num + ', ' + num + '\\)');
for (const line of fixture.split(/\r?\n/)) {
    const key = line.match(/-- key (\d+)/);
    if (!key) continue;
    const loc = line.match(v3('location')), mn = line.match(v3('min')), mx = line.match(v3('max'));
    dump.push({ key: +key[1], team: line.match(/team = (\d)/)[1] === '2' ? 'radiant' : 'dire',
        type: line.match(/type = '(\w+)'/)[1], x: +loc[1], y: +loc[2],
        box: [Math.round(+mn[1]), Math.round(+mn[2]), Math.round(+mx[1]), Math.round(+mx[2])] });
}
const camps = of('npc_dota_neutral_spawner').map(e => {
    const [x, y] = xy(e);
    const d = dump.find(c => Math.hypot(c.x - x, c.y - y) < 10);
    if (!d) throw new Error(`map spawner at ${x},${y} has no match in the GetNeutralSpawners dump: re-dump for this patch`);
    return { key: d.key, team: d.team, type: d.type, x, y, box: d.box,
        volume: String(e.volumename || '').replace(/^\[PR#\]/, ''), pullType: +e.pulltype, aggroType: +e.aggrotype };
}).sort((a, b) => a.key - b.key);
if (camps.length !== dump.length) throw new Error(`camp count mismatch: map ${camps.length}, dump ${dump.length}`);

// ---- buildings --------------------------------------------------------------------------------------------
const unit = e => ({ name: String(e.mapunitname || name(e)), team: teamOf(e.mapunitname || name(e)), x: xy(e)[0], y: xy(e)[1] });
const towers = of('npc_dota_tower').map(e => {
    const u = unit(e), m = u.name.match(/tower(\d)(?:_(top|mid|bot))?/);
    return { ...u, tier: +m[1], lane: m[2] || 'base' };
});
const barracks = of('npc_dota_barracks').map(e => {
    const u = unit(e), m = u.name.match(/(melee|range)_rax_(top|mid|bot)/);
    return { ...u, kind: m[1], lane: m[2] };
});
const ancients = of('npc_dota_fort').map(unit);
const fountains = of('ent_dota_fountain').map(e => ({ team: e.teamnumber === '2' ? 'radiant' : 'dire', x: xy(e)[0], y: xy(e)[1] }));
const shops = of('ent_dota_shop').map(e => ({ kind: e.shoptype === '0' ? 'home' : 'secret', x: xy(e)[0], y: xy(e)[1] }));

// ---- objectives -------------------------------------------------------------------------------------------
const point = (e, extra) => ({ x: xy(e)[0], y: xy(e)[1], ...extra });
const runes = [
    ...of('dota_item_rune_spawner_powerup').map(e => point(e, { kind: 'power', position: e.runeposition })),
    ...of('dota_item_rune_spawner_bounty').map(e => point(e, { kind: 'bounty', position: e.runeposition })),
    ...of('npc_dota_xp_fountain').map(e => point(e, { kind: 'wisdom' })),
];
const roshan = [
    ...of('npc_dota_roshan_spawner').map(e => point(e, { name: 'Roshan pit (bottom)' })),
    ...of('info_target').filter(e => /roshan_location/.test(name(e))).map(e => point(e, { name: 'Roshan pit (top)' })),
];
const objectives = {
    roshan,
    tormentors: [
        ...of('npc_dota_miniboss_spawner').map(e => point(e, { name: name(e) })),
        // The second Tormentor has no spawner entity; FunLib/objective_locations.lua holds its position.
        { x: 7744, y: -6208, name: 'tormentor (bottom, from objective_locations.lua)' },
    ],
    lotusPools: of('npc_dota_lotus_pool').map(e => point(e, { name: name(e).replace(/^\d+_/, '') })),
    twinGates: of('npc_dota_unit_twin_gate').map(e => point(e, { name: name(e) })),
    outposts: of('npc_dota_watch_tower').map(e => point(e, { name: name(e) })),
    watchers: of('npc_dota_lantern').map(e => point(e, {})),
};

// ---- creep lane paths: follow each path_corner chain from its head -----------------------------------------
const corners = of('path_corner').map(e => ({ name: name(e), target: String(e.target || '').replace(/^\[PR#\]/, ''), x: xy(e)[0], y: xy(e)[1] }));
const lanes = [];
for (const lane of ['top', 'mid', 'bot']) for (const side of ['goodguys', 'badguys']) {
    const group = corners.filter(c => c.name.startsWith(`lane_${lane}_pathcorner_${side}`));
    const targeted = new Set(group.filter(c => c.target !== c.name).map(c => c.target));
    let node = group.find(c => !targeted.has(c.name));
    const points = [], seen = new Set();
    while (node && !seen.has(node.name)) {
        seen.add(node.name); points.push([node.x, node.y]);
        node = group.find(c => c.name === node.target && c.name !== node.name);
    }
    lanes.push({ lane, team: side === 'goodguys' ? 'radiant' : 'dire', points, nodes: group.length });
}

// ---- trees and bounds ---------------------------------------------------------------------------------------
const trees = of('ent_dota_tree').map(xy);
const wb = of('world_bounds')[0];
const mm = of('dota_minimap_boundary').map(e => e.origin);
const data = {
    patch, source: 'maps/dota/entities/default_ents.vents_c (installed dota.vpk)',
    // Valve's minimap frame: the square the in-game minimap shows.
    minimap: { min: [Math.min(mm[0][0], mm[1][0]), Math.min(mm[0][1], mm[1][1])], max: [Math.max(mm[0][0], mm[1][0]), Math.max(mm[0][1], mm[1][1])] },
    worldBounds: { min: vec(wb.min).slice(0, 2), max: vec(wb.max).slice(0, 2) },
    camps, towers, barracks, ancients, fountains, shops, runes, objectives, lanes, trees,
};
const out = path.join(root, 'docs', 'map', 'map_data.json');
fs.mkdirSync(path.dirname(out), { recursive: true });
fs.writeFileSync(out, JSON.stringify(data));
console.log(`camps ${camps.length}, towers ${towers.length}, barracks ${barracks.length}, runes ${runes.length}, trees ${trees.length}`);
for (const l of lanes) console.log(`lane ${l.lane} ${l.team}: ${l.points.length}/${l.nodes} nodes`, JSON.stringify(l.points.slice(0, 3)), '...');
console.log('minimap', JSON.stringify(data.minimap), 'world', JSON.stringify(data.worldBounds));
console.log('pull types', camps.map(c => `${c.key}:${c.pullType}`).join(' '));
console.log(`wrote ${path.relative(root, out)} (${fs.statSync(out).size} bytes)`);
