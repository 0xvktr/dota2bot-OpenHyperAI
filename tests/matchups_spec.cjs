const assert = require('node:assert/strict');
const fs = require('node:fs');
const cp = require('node:child_process');
const path = require('node:path');
process.chdir(path.resolve(__dirname, '..'));
cp.execFileSync(process.execPath, ['node_modules/typescript/bin/tsc', '-p', 'tsconfig-node.json'], {stdio: 'inherit'});
const {parseCounterTable, importSnapshot, validateMatchups} = require('../dist/post-process/matchups.js');
const {hero_name_table: names} = require('../dist/post-process/names.js');
const heroes = Object.keys(names);
assert.equal(heroes.length, 127);

// Preserve Dotabuff's disadvantage sign and ignore empty/non-numeric cells.
assert.deepEqual(parseCounterTable(`<table class="sortable"><tr><th>Hero</th></tr>
<tr><td></td><td>Chen</td><td>5.10%</td></tr>
<tr><td></td><td>Axe</td><td>-3.79%</td></tr>
<tr><td></td><td>Abaddon</td><td></td></tr></table>`), {
    npc_dota_hero_chen: 5.1, npc_dota_hero_axe: -3.79,
});
assert.equal(parseCounterTable('<h1>Performing security verification</h1>'), null);
const snapshot = Object.fromEntries(heroes.map(hero => [names[hero].urlName,
    heroes.filter(other => other !== hero).map(other => ({
        name: names[other].visibleName, href: `/heroes/${names[other].urlName}`, disadvantage: -1.25,
    })),
]));
const complete = importSnapshot(snapshot);
validateMatchups(complete);
const broken = structuredClone(snapshot);
broken.abaddon.pop();
assert.throws(() => importSnapshot(broken), /Incomplete opponents/);
assert.throws(() => importSnapshot({}), /Missing browser table/);
broken.abaddon = [...snapshot.abaddon, snapshot.abaddon[0]];
assert.throws(() => importSnapshot(broken), /Duplicate/);
broken.abaddon = structuredClone(snapshot.abaddon);
broken.abaddon[0].disadvantage = null;
assert.throws(() => importSnapshot(broken), /Invalid disadvantage/);
broken.abaddon[0].href = '/heroes/not-the-same-hero';
assert.throws(() => importSnapshot(broken), /Unknown opponent/);

const outputPath = 'bots/FretBots/matchups_data.lua';
const before = fs.readFileSync(outputPath);
const incompletePath = '.test-tools/incomplete-matchups.json';
fs.writeFileSync(incompletePath, '{}');
const failed = cp.spawnSync(process.execPath, ['dist/post-process/matchups.js', '--snapshot', incompletePath], {encoding:'utf8'});
assert.notEqual(failed.status, 0);
assert(failed.stderr.includes('Missing browser table'));
assert.deepEqual(fs.readFileSync(outputPath), before, 'failed refresh must preserve shipped data');

// Read the actual shipped Lua data and compare migrated arrays with TypeScript.
const source = fs.readFileSync('typescript/bots/FunLib/aba_matchups.ts', 'utf8');
const migrated = ['abaddon','abyssal_underlord','alchemist','ancient_apparition','antimage','arc_warden','axe','bane','batrider'];
const checks = [];
for (const hero of migrated) {
    const block = source.match(new RegExp(`npc_dota_hero_${hero}: \\{([\\s\\S]*?)\\n    \\},`))[1];
    for (const kind of ['counter', 'synergy']) {
        const list = block.match(new RegExp(`${kind}: \\[([\\s\\S]*?)\\]`))[1];
        const ids = [...list.matchAll(/"(npc_dota_hero_\w+)"/g)].map(m => m[1]);
        assert(ids.length <= 8);
        // No Batrider synergy clears the sample/positive-score filter; do not pad it.
        if (hero === 'batrider' && kind === 'synergy') assert.equal(ids.length, 0);
        else assert(ids.length > 0);
        assert.equal(new Set(ids).size, ids.length);
        for (const id of ids) assert(names[id], `Unknown hero: ${id}`);
        checks.push(`local a=M.GetHeroMatchups('npc_dota_hero_${hero}','${kind}'); assert(#a==${ids.length})`);
        ids.forEach((id, i) => checks.push(`assert(a[${i+1}]=='${id}')`));
    }
}
const lua = `
local D=dofile('bots/FretBots/matchups_data.lua')
local count,pairsCount=0,0
for h,row in pairs(D) do
    count=count+1
    local n=0
    for other,v in pairs(row) do
        assert(other~=h and D[other] and type(v)=='number' and math.abs(v)<=100)
        n=n+1
    end
    assert(n==126)
    pairsCount=pairsCount+n
end
assert(count==127 and pairsCount==16002)
assert(D.npc_dota_hero_abaddon.npc_dota_hero_chen==5.1)
assert(D.npc_dota_hero_abaddon.npc_dota_hero_axe==-3.79)
local M=dofile('bots/FunLib/aba_matchups.lua')
${checks.join('\n')}
assert(#M.GetHeroMatchups('missing','counter')==0)
assert(not M.IsSynergy('npc_dota_hero_batrider','npc_dota_hero_pudge'))
assert(M.IsCounter('npc_dota_hero_batrider','npc_dota_hero_pudge'))
print('Matchup data and generator scenarios passed')
`;
const result=cp.spawnSync(process.execPath, ['.test-tools/node_modules/fengari-node-cli/src/lua-cli.js','-e',lua], {encoding:'utf8'});
process.stdout.write(result.stdout || '');
process.stderr.write(result.stderr || '');
assert.equal(result.status,0);
assert(result.stdout.includes('Matchup data and generator scenarios passed'));
