// Refreshes tests/valve/abilities.json and tests/valve/recipes.json from d2vpkr (Valve's game files
// mirrored on GitHub). Run after a patch: `node tests/valve/refresh.cjs [commit]` (default: latest
// d2vpkr master). Only the compact JSON is committed, so tests/valve_ability_check.cjs and
// tests/purchase_plan_spec.lua run offline.
const fs = require('fs');
const path = require('path');
const { parseKV } = require('./kv.cjs');

const root = path.resolve(__dirname, '../..');
const out = path.join(__dirname, 'abilities.json');
const repo = 'dotabuff/d2vpkr';

// Bot files whose unit has no hero file of its own.
const NO_HERO_FILE = new Set(['lone_druid_bear']);

async function get(url, asJson) {
    const res = await fetch(url, { headers: { 'User-Agent': 'OpenHyperAI-valve-refresh' } });
    if (!res.ok) throw new Error(`${res.status} ${url}`);
    return asJson ? res.json() : res.text();
}

function abilityInfo(def) {
    const keys = new Set();
    for (const block of ['AbilityValues', 'AbilitySpecial']) {
        const values = def[block];
        if (!values || typeof values !== 'object') continue;
        for (const [k, v] of Object.entries(values)) {
            // Legacy AbilitySpecial nests each value in a numbered block.
            if (block === 'AbilitySpecial' && typeof v === 'object') {
                for (const kk of Object.keys(v)) if (kk !== 'var_type') keys.add(kk);
            } else keys.add(k);
        }
    }
    return {
        behavior: def.AbilityBehavior || '',
        ultimate: def.AbilityType === 'ABILITY_TYPE_ULTIMATE',
        innate: def.Innate === '1',
        keys: [...keys].sort(),
    };
}

// Talents linked into another ability's values: "damage" { "value" "..", "special_bonus_unique_x" "+50" }.
function talentBonuses(defs) {
    const bonus = {};
    for (const def of Object.values(defs)) {
        const values = def && def.AbilityValues;
        if (!values || typeof values !== 'object') continue;
        for (const [key, v] of Object.entries(values)) {
            if (typeof v !== 'object') continue;
            for (const inner of Object.keys(v)) {
                if (inner.startsWith('special_bonus_')) (bonus[inner] = bonus[inner] || new Set()).add(key);
            }
        }
    }
    return Object.fromEntries(Object.entries(bonus).map(([k, s]) => [k, [...s].sort()]));
}

// items.txt recipes as GetItemComponents(item)[1] returns them: the parts, then the recipe when it
// costs gold (a free recipe is never bought). Also the gold cost of every item.
function recipes(text) {
    const items = parseKV(text).DOTAAbilities || {};
    const costs = {}, out = {};
    for (const [name, def] of Object.entries(items)) {
        if (typeof def === 'object' && def.ItemCost !== undefined) costs[name] = Number(def.ItemCost);
    }
    for (const [name, def] of Object.entries(items)) {
        if (!name.startsWith('item_recipe_') || typeof def !== 'object' || !def.ItemResult) continue;
        const first = (def.ItemRequirements || {})['01'];
        if (!first) continue;
        const parts = first.split(';').map(s => s.replace('*', '').trim()).filter(Boolean);
        if (costs[name] > 0) parts.push(name);
        out[def.ItemResult] = parts;
    }
    const sorted = o => Object.fromEntries(Object.keys(o).sort().map(k => [k, o[k]]));
    return { recipes: sorted(out), costs: sorted(costs) };
}

async function main() {
    const commit = process.argv[2]
        || (await get(`https://api.github.com/repos/${repo}/commits/master`, true)).sha;
    const heroes = fs.readdirSync(path.join(root, 'bots/BotLib'))
        .filter(f => /^hero_.+\.lua$/.test(f)).map(f => f.slice(5, -4))
        .filter(h => !NO_HERO_FILE.has(h)).sort();

    const data = { source: `https://github.com/${repo}/tree/${commit}`, commit, heroes: {} };
    for (const hero of heroes) {
        const unit = `npc_dota_hero_${hero}`;
        const text = await get(`https://raw.githubusercontent.com/${repo}/${commit}/dota/scripts/npc/heroes/${unit}.txt`);
        const header = (parseKV(text).DOTAHeroes || {})[unit];
        if (!header) throw new Error(`no ${unit} block in the hero file`);
        const defs = header.AbilityDefinitions || {};
        // Top-level AbilityN keys only; the nested AbilityDraftAbilities block reuses the same names.
        const slots = Object.entries(header)
            .filter(([k, v]) => /^Ability\d+$/.test(k) && typeof v === 'string')
            .map(([k, v]) => [Number(k.slice(7)), v]).sort((a, b) => a[0] - b[0]);
        const abilities = {};
        for (const [name, def] of Object.entries(defs)) if (typeof def === 'object') abilities[name] = abilityInfo(def);
        data.heroes[hero] = { slots, abilities, talentBonuses: talentBonuses(defs) };
        process.stdout.write('.');
    }
    fs.writeFileSync(out, JSON.stringify(data, null, 1) + '\n');
    console.log(`\nWrote ${path.relative(root, out)}: ${heroes.length} heroes at d2vpkr ${commit.slice(0, 7)}`);

    const items = recipes(await get(`https://raw.githubusercontent.com/${repo}/${commit}/dota/scripts/npc/items.txt`));
    const recipesOut = path.join(__dirname, 'recipes.json');
    fs.writeFileSync(recipesOut, JSON.stringify({ source: data.source, commit, ...items }, null, 1) + '\n');
    console.log(`Wrote ${path.relative(root, recipesOut)}: ${Object.keys(items.recipes).length} recipes`);
}

main().catch(e => { console.error(e.message); process.exit(1); });
