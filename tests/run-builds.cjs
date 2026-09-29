// Test entry point for the D2PT build migration: `node tests/run-builds.cjs`.
// Needs the git-ignored `.test-tools/` (luaparse + fengari-node-cli); see docs/D2PT_BUILD_UPDATES.md.
const fs = require('fs');
const path = require('path');
const cp = require('child_process');
const assert = require('assert');
process.chdir(path.resolve(__dirname, '..'));
const parser = require('../.test-tools/node_modules/luaparse');

const read = file => fs.readFileSync(file, 'utf8');
const buildsDir = 'bots/BotLib/Builds';
const heroNames = fs.readdirSync(buildsDir).filter(f => f.endsWith('.lua')).map(f => f.slice(0, -4)).sort();
assert(heroNames.length > 0, 'no hero build files found in ' + buildsDir);
for (const name of heroNames) {
    assert(fs.existsSync(`bots/BotLib/hero_${name}.lua`), `${buildsDir}/${name}.lua has no bots/BotLib/hero_${name}.lua`);
}

// 1. Lua syntax: every migrated hero, its build data, and the shared infrastructure.
const lua = [
    ...heroNames.flatMap(n => [`bots/BotLib/hero_${n}.lua`, `${buildsDir}/${n}.lua`]),
    'bots/FunLib/hero_build_preferences.lua', 'bots/FunLib/alchemist_scepter.lua', 'bots/FunLib/inventory_upkeep.lua', 'bots/FunLib/aba_item.lua',
    'bots/FunLib/aba_hero_pos_weights.lua', 'bots/FretBots/BonusTimers.lua', 'bots/Buff/NeutralItems.lua',
    'bots/FretBots/NeutralItems.lua', 'bots/hero_selection.lua', 'bots/item_purchase_generic.lua',
    'bots/ability_item_usage_generic.lua',
    ...fs.readdirSync('tests').filter(f => f.endsWith('.lua')).map(f => 'tests/' + f),
];
for (const file of lua) parser.parse(read(file), {luaVersion: '5.2'});
console.log(`Lua syntax passed for ${lua.length} files`);

// 2. Position weights: the TypeScript source and generated Lua must agree for every hero.
const stripComments = text => text.replace(/--[^\n]*|\/\/[^\n]*/g, '');
const numbers = text => (stripComments(text).match(/\d+/g) || []).map(Number);
function weightTable(source, pattern) {
    const table = new Map();
    for (const [, key, body] of source.matchAll(pattern)) table.set(key, numbers(body));
    return table;
}
const tsWeights = weightTable(read('typescript/bots/FunLib/aba_hero_pos_weights.ts'), /\[HeroName\.(\w+)\]\s*:\s*\[([^\]]*)\]/g);
const luaWeights = weightTable(read('bots/FunLib/aba_hero_pos_weights.lua'), /\[HeroName\.(\w+)\]\s*=\s*\{([^}]*)\}/g);
assert(tsWeights.size > 100, 'expected the full hero weight table');
assert.deepStrictEqual([...luaWeights.keys()].sort(), [...tsWeights.keys()].sort(), 'TS and Lua weight tables list different heroes');
for (const [key, weights] of tsWeights) {
    assert.deepStrictEqual(luaWeights.get(key), weights, `weights for ${key} differ between TS and generated Lua`);
    assert(weights.length === 5 && weights.every(w => w >= 0 && w <= 100), `weights for ${key} must be five values of 0-100`);
}
const unitOf = new Map([...read('bots/ts_libs/dota/heroes.lua').matchAll(/HeroName\.(\w+)\s*=\s*"(npc_dota_hero_\w+)"/g)].map(m => [m[1], m[2]]));
console.log(`Role weights in sync for ${tsWeights.size} heroes`);

// 3. Validation context for tests/build_validator.lua.
const neutralTiers = {}, enhancementTiers = {};
function addTier(map, name, tier) { (map[name] ||= {})[tier] = true; }
const fretTable = read('bots/FretBots/SettingsNeutralItemTable.lua');
const buffPools = read('bots/Buff/NeutralItems.lua');
// Commented-out entries still describe real items; builds may list items a pool skips (e.g. active-use).
for (const source of [fretTable, buffPools]) {
    for (const [, name, tier] of source.matchAll(/name\s*=\s*"(item_[a-z0-9_]+)"\s*,\s*tier\s*=\s*(\d)/g)) {
        addTier(name.startsWith('item_enhancement_') ? enhancementTiers : neutralTiers, name, Number(tier));
    }
}
for (const [, tier, body] of buffPools.matchAll(/local Tier(\d)NeutralItems\s*=\s*\{([\s\S]*?)\n\}/g)) {
    for (const [, name] of body.matchAll(/"(item_[a-z0-9_]+)"/g)) addTier(neutralTiers, name, Number(tier));
}
const items = {};
for (const [name] of read('bots/FunLib/aba_item.lua').matchAll(/\bitem_[a-z0-9_]+\b/g)) items[name] = true;

const heroes = heroNames.map(name => {
    const patch = read(`${buildsDir}/${name}.lua`).match(/patch\s*=\s*['"]([^'"]+)['"]/);
    return {
        name,
        unit: 'npc_dota_hero_' + name,
        annotated: !!patch && read(`bots/BotLib/hero_${name}.lua`).includes(patch[1]),
    };
});
const weights = {};
for (const {unit} of heroes) {
    const key = [...unitOf].find(([, u]) => u === unit);
    assert(key && luaWeights.has(key[0]), `no HeroName / weight entry for ${unit}`);
    weights[unit] = luaWeights.get(key[0]);
}
const toLua = value => {
    if (Array.isArray(value)) return '{' + value.map(toLua).join(',') + '}';
    if (value && typeof value === 'object') {
        return '{' + Object.entries(value).map(([k, v]) => `[${/^\d+$/.test(k) ? k : JSON.stringify(k)}]=${toLua(v)}`).join(',') + '}';
    }
    return typeof value === 'string' ? JSON.stringify(value) : String(value);
};
fs.writeFileSync('.test-tools/build-context.lua',
    'return ' + toLua({heroes, items, neutralTiers, enhancementTiers, weights}) + '\n');

// 4. Run the Lua suites under fengari. fengari exits 0 even when a script errors, so every
// suite must print its success marker.
const fengari = path.resolve('.test-tools/node_modules/fengari-node-cli/src/lua-cli.js');
function run(args, marker) {
    const result = cp.spawnSync(process.execPath, [fengari, ...args], {encoding: 'utf8'});
    process.stdout.write(result.stdout || '');
    process.stderr.write(result.stderr || '');
    if (result.error || result.status !== 0 || !result.stdout.includes(marker)) process.exit(1);
}
run(['tests/build_validator.lua'], 'Build validation passed');
run(['tests/neutral_consumers_spec.lua'], 'Neutral consumer wiring passed');
run(['tests/alchemist_scepter_spec.lua'], 'Alchemist Scepter gift scenarios passed');
run(['tests/axe_culling_blade_spec.lua'], 'Axe Culling Blade talent scenario passed');
run(['tests/inventory_upkeep_spec.lua'], 'Inventory upkeep scenarios passed');

// 5. Shared logic the build migration changed, executed from the real source.
// Draft scoring with controlled positive/negative matchups.
const selection = read('bots/hero_selection.lua');
const start = selection.indexOf('local function ScoreCandidatesForTeam(');
const end = selection.indexOf('local function SelectTopWithFuzz(', start);
assert(start >= 0 && end > start);
run(['-e', `
local X={CanPickHero=function() return true end}
local Utils={HasValue=function() return false end}
local WeakHeroes={}
local function WeakPenaltyFactor() return 1 end
local allies={}
local function GetAllyHeroNames() return allies end
local HeroMatchups={IsSynergy=function() return false end,IsCounter=function() error('enemy counter queried for allies') end}
local HeroPositionMap={strong={80},weak={20}}
local matchups={strong={enemy=9},weak={enemy=9}}
${selection.slice(start, end)}
local r=ScoreCandidatesForTeam(2,{'weak','strong'},{'enemy'},1)
assert(r[1].name=='strong', 'higher role weight must help negative matchup scores')
r=ScoreCandidatesForTeam(2,{'weak','strong'},{},1)
assert(r[1].name=='strong', 'role weights must affect neutral matchup scores')
allies={'ally'}
r=ScoreCandidatesForTeam(2,{'strong'},{},1)
assert(r[1].score==4, 'enemy counters must not penalize allied pairs')
HeroMatchups.IsSynergy=function() return true end
r=ScoreCandidatesForTeam(2,{'strong'},{},1)
assert(r[1].score==5.5, 'positive synergy bonus remains')
print('Draft scoring scenarios passed')
`], 'Draft scoring scenarios passed');

// The real duplicate check and recursive component expansion used for Scepter gifts.
const itemLibrary = read('bots/FunLib/aba_item.lua');
const itemStart = itemLibrary.indexOf('function Item.IsItemInTargetHero(');
const itemEnd = itemLibrary.indexOf('-- function Item.ItemBasicItemsNotInHeroSlots', itemStart);
assert(itemStart >= 0 && itemEnd > itemStart);
run(['-e', `
local inventory={}
local gifted=false
local bot={GetUnitName=function() return 'npc_dota_hero_alchemist' end,
    HasScepter=function() return true end, FindItemSlot=function(_,n) return inventory[n] or -1 end}
function GetBot() return bot end
local tDefineItemRealName={}
local Item={IsTopItem=function() return true end,GetItemCount=function() return 0 end,
    item_ultimate_scepter={'item_point_booster','item_ogre_axe','item_blade_of_alacrity','item_staff_of_wizardry'}}
Item.IsItemInHero=function(name) return Item.IsItemInTargetHero(name,bot) end
${itemLibrary.slice(itemStart, itemEnd)}
assert(Item.IsItemInHero('item_ultimate_scepter'), 'normal personal upgrade dedupe')
bot.alchemistGiftPending=true
assert(not Item.IsItemInHero('item_ultimate_scepter'), 'a consumed personal Scepter must not suppress gifts')
assert(#Item.GetBasicItems({'item_ultimate_scepter'})==4, 'gift expands into purchasable components')
inventory.item_ultimate_scepter=6
assert(Item.IsItemInHero('item_ultimate_scepter'), 'assembled gift completes purchase in backpack')
inventory.item_ultimate_scepter=nil
bot.alchemistGiftCastTarget={IsNull=function() return false end,HasScepter=function() return gifted end}
assert(not Item.IsItemInHero('item_ultimate_scepter'), 'failed cast does not finish purchase')
gifted=true
assert(Item.IsItemInHero('item_ultimate_scepter'), 'gift cast between purchase ticks completes queue')
print('Gift purchase integration passed')
`], 'Gift purchase integration passed');

// The generic purchase and item-use loops must keep calling the Alchemist gift hooks.
const purchase = read('bots/item_purchase_generic.lua');
assert(purchase.includes('AlchemistScepter.UpdatePurchase(bot, J, BotBuild.enableScepterGifts)'));
const usage = read('bots/ability_item_usage_generic.lua');
assert(usage.includes('AlchemistScepter.Prepare(bot, J)'));
assert(usage.includes('return AlchemistScepter.Consider(bot, hItem, J)'));
assert(purchase.includes('InventoryUpkeep.SellDeadComponents(bot, currentTime)'));
assert(usage.includes('InventoryUpkeep.SwapInBackpackConsumable( bot,'));
console.log('Generic purchase/item-use gift and inventory upkeep hooks present');
