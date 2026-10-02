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
    'bots/FunLib/rubick_utility.lua', 'bots/FunLib/spell_prob_list.lua',
    ...fs.readdirSync('bots/FunLib').filter(f => f.endsWith('_abilities.lua')).map(f => 'bots/FunLib/' + f),
    ...fs.readdirSync('bots/FunLib/rubick_hero').filter(f => f.endsWith('.lua')).map(f => 'bots/FunLib/rubick_hero/' + f),
    'bots/FunLib/break_state.lua', 'bots/FunLib/minion_lib/primal_split.lua', 'bots/FunLib/minion_lib/minion_with_skill.lua', 'bots/FunLib/lone_druid_items.lua', 'bots/BotLib/hero_lone_druid_bear.lua',
    ...heroNames.flatMap(n => [`bots/BotLib/hero_${n}.lua`, `${buildsDir}/${n}.lua`]),
    'bots/FunLib/hero_build_preferences.lua', 'bots/FunLib/alchemist_scepter.lua', 'bots/FunLib/inventory_upkeep.lua', 'bots/FunLib/debug_dumps.lua', 'bots/FunLib/lane_pull.lua', 'bots/mode_roam_generic.lua', 'bots/FunLib/aba_ward_utility.lua', 'bots/mode_ward_generic.lua', 'bots/FunLib/aba_item.lua',
    'bots/FunLib/aba_hero_pos_weights.lua', 'bots/FretBots/BonusTimers.lua', 'bots/Buff/NeutralItems.lua',
    'bots/FretBots/NeutralItems.lua', 'bots/hero_selection.lua', 'bots/item_purchase_generic.lua',
    'bots/ability_item_usage_generic.lua', 'bots/FunLib/jmz_func.lua', 'bots/FunLib/power_treads.lua', 'bots/FunLib/item_cast_policy.lua',
    'bots/FunLib/early_lane_defense.lua', 'bots/FunLib/fight_response.lua', 'bots/FunLib/lane_rotation.lua',
    ...fs.readdirSync('tests').filter(f => f.endsWith('.lua')).map(f => 'tests/' + f),
];
for (const file of lua) parser.parse(read(file), {luaVersion: '5.2'});
console.log(`Lua syntax passed for ${lua.length} files`);

for (const file of ['creep_deny_spec.cjs', 'mask_disassembly_spec.cjs', 'valve_ability_check.cjs', 'power_treads_spec.cjs', 'item_cast_policy_spec.cjs', 'hero_cast_hooks_spec.cjs']) {
    const result = cp.spawnSync(process.execPath, [path.join('tests', file)], {stdio: 'inherit'});
    assert.strictEqual(result.status, 0, `${file} failed`);
}

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
// Only active entries count: the pools comment out items that moved tier (or were removed) in 7.41, and
// a commented old-tier entry would let a retained lower-tier item through. Block-comment labels such as
// `--[[Occult Bracelet]]` in front of an active entry are stripped first.
const activeOnly = source => source.replace(/--\[\[[^\]]*\]\]/g, '').replace(/--[^\n]*/g, '');
for (const source of [activeOnly(fretTable), activeOnly(buffPools)]) {
    for (const [, name, tier] of source.matchAll(/name\s*=\s*"(item_[a-z0-9_]+)"\s*,\s*tier\s*=\s*(\d)/g)) {
        addTier(name.startsWith('item_enhancement_') ? enhancementTiers : neutralTiers, name, Number(tier));
    }
}
for (const [, tier, body] of activeOnly(buffPools).matchAll(/local Tier(\d)NeutralItems\s*=\s*\{([\s\S]*?)\n\}/g)) {
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

const druidPurchase = read('bots/item_purchase_generic.lua');
const purchaseSection = (start, end) => {
    const a = druidPurchase.indexOf(start), b = druidPurchase.indexOf(end, a);
    assert(a >= 0 && b > a, 'missing Lone Druid purchase test hook');
    return druidPurchase.slice(a, b);
};
fs.writeFileSync('.test-tools/lone-druid-purchase-hooks.lua',
    'return function(bot, BotBuild, Utils, Item, LoneDruidItems)\n' +
    purchaseSection('local function _countOwnedEverywhere(', 'local function _buildRequiredCounts(') +
    purchaseSection('local function _stillNeeds(', 'local function _popIfNoLongerNeeded(') +
    'return _stillNeeds\nend\n');

// Purchase planning (tests/purchase_plan_spec.lua): Valve recipes, every hero file, and the real
// dedupe / queue / recipe-hold functions of the purchase loop.
const valveItems = JSON.parse(read('tests/valve/recipes.json'));
const allHeroes = fs.readdirSync('bots/BotLib').map(f => f.match(/^hero_(.+)\.lua$/))
    .filter(m => m && m[1] !== 'lone_druid_bear').map(m => m[1]).sort();
fs.writeFileSync('.test-tools/purchase-plan-context.lua',
    'return ' + toLua({recipes: valveItems.recipes, costs: valveItems.costs, heroes: allHeroes}) + '\n');
fs.writeFileSync('.test-tools/purchase-plan-hooks.lua',
    'return function(bot, BotBuild, Utils, Item, LoneDruidItems, print)\n' +
    'local botName, botCourierValue, botStashValue = "npc_dota_hero_sim", 0, 0\n' +
    purchaseSection('local function _countOwnedEverywhere(', 'local function _antiSpamPurchase(') +
    purchaseSection('local function _resetCurrentTarget(', 'local function GeneralPurchase(') +
    'return {stillNeeds=_stillNeeds, pop=_popIfNoLongerNeeded, queue=_queueComponents, recipeWaits=_recipeWaitsForParts,\n' +
    '    transit=function(courier, stash) botCourierValue, botStashValue = courier, stash end}\nend\n');

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
run(['tests/ancient_apparition_combo_spec.lua'], 'Ancient Apparition combo scenarios passed');
run(['tests/dazzle_ability_spec.lua'], 'Dazzle ability scenarios passed');
run(['tests/abaddon_ability_spec.lua'], 'Abaddon ability scenarios passed');
run(['tests/underlord_ability_spec.lua'], 'Underlord ability scenarios passed');
run(['tests/alchemist_ability_spec.lua'], 'Alchemist ability scenarios passed');
run(['tests/antimage_ability_spec.lua'], 'Anti-Mage ability decisions passed');
run(['tests/arc_warden_ability_spec.lua'], 'Arc Warden ability scenarios passed');
run(['tests/axe_ability_spec.lua'], 'Axe ability scenarios passed');
run(['tests/bane_ability_spec.lua'], 'Bane ability scenarios passed');
run(['tests/batrider_ability_spec.lua'], 'Batrider ability scenarios passed');
run(['tests/beastmaster_ability_spec.lua'], 'Beastmaster ability scenarios passed');
run(['tests/brewmaster_ability_spec.lua'], 'Brewmaster ability scenarios passed');
run(['tests/bloodseeker_ability_spec.lua'], 'Bloodseeker ability scenarios passed');
run(['tests/bounty_hunter_ability_spec.lua'], 'Bounty Hunter ability scenarios passed');
run(['tests/bristleback_ability_spec.lua'], 'Bristleback ability scenarios passed');
run(['tests/broodmother_ability_spec.lua'], 'Broodmother ability scenarios passed');
run(['tests/centaur_ability_spec.lua'], 'Centaur ability scenarios passed');
run(['tests/chaos_knight_ability_spec.lua'], 'Chaos Knight ability scenarios passed');
run(['tests/chen_ability_spec.lua'], 'Chen ability scenarios passed');
run(['tests/clinkz_ability_spec.lua'], 'Clinkz ability scenarios passed');
run(['tests/crystal_maiden_ability_spec.lua'], 'Crystal Maiden ability scenarios passed');
run(['tests/dark_seer_ability_spec.lua'], 'Dark Seer ability scenarios passed');
run(['tests/dark_willow_ability_spec.lua'], 'Dark Willow ability scenarios passed');
run(['tests/dawnbreaker_ability_spec.lua'], 'Dawnbreaker ability scenarios passed');
run(['tests/death_prophet_ability_spec.lua'], 'Death Prophet ability scenarios passed');
run(['tests/disruptor_ability_spec.lua'], 'Disruptor ability scenarios passed');
run(['tests/doom_bringer_ability_spec.lua'], 'Doom ability scenarios passed');
run(['tests/dragon_knight_ability_spec.lua'], 'Dragon Knight ability scenarios passed');
run(['tests/drow_ranger_ability_spec.lua'], 'Drow Ranger ability scenarios passed');
run(['tests/earth_spirit_ability_spec.lua'], 'Earth Spirit ability scenarios passed');
run(['tests/earthshaker_ability_spec.lua'], 'Earthshaker ability scenarios passed');
run(['tests/elder_titan_ability_spec.lua'], 'Elder Titan ability scenarios passed');
run(['tests/break_state_spec.lua'], 'Break state scenarios passed');
run(['tests/brewmaster_split_spec.lua'], 'Brewmaster split scenarios passed');
run(['tests/leshrac_ability_spec.lua'], 'Leshrac ability scenarios passed');
run(['tests/naga_siren_ability_spec.lua'], 'Naga Siren ability scenarios passed');
run(['tests/ember_spirit_ability_spec.lua'], 'Ember Spirit ability scenarios passed');
run(['tests/lich_ability_spec.lua'], 'Lich ability scenarios passed');
run(['tests/necrolyte_ability_spec.lua'], 'Necrophos ability scenarios passed');
run(['tests/enchantress_ability_spec.lua'], "Enchantress ability scenarios passed");
run(['tests/life_stealer_ability_spec.lua'], "Lifestealer ability scenarios passed");
run(['tests/lina_ability_spec.lua'], "Lina ability scenarios passed");
run(['tests/nevermore_ability_spec.lua'], "Shadow Fiend ability scenarios passed");
run(['tests/night_stalker_ability_spec.lua'], "Night Stalker ability scenarios passed");
run(['tests/enigma_ability_spec.lua'], "Enigma ability scenarios passed");
run(['tests/lion_ability_spec.lua'], "Lion ability scenarios passed");
run(['tests/nyx_assassin_ability_spec.lua'], "Nyx Assassin ability scenarios passed");
run(['tests/luna_ability_spec.lua'], "Luna ability scenarios passed");
run(['tests/faceless_void_ability_spec.lua'], "Faceless Void ability scenarios passed");
run(['tests/lycan_ability_spec.lua'], "Lycan ability scenarios passed (5 groups)");
run(['tests/obsidian_destroyer_ability_spec.lua'], "Outworld Destroyer ability scenarios passed");
run(['tests/furion_ability_spec.lua'], "Nature Prophet ability scenarios passed");
run(['tests/magnataur_ability_spec.lua'], "Magnus ability scenarios passed (5 groups)");
run(['tests/ogre_magi_ability_spec.lua'], "Ogre Magi ability scenarios passed");
run(['tests/marci_ability_spec.lua'], "Marci ability scenarios passed (5 groups)");
run(['tests/mars_ability_spec.lua'], "Mars ability scenarios passed (4 groups)");
run(['tests/omniknight_ability_spec.lua'], "Omniknight ability scenarios passed");
run(['tests/grimstroke_ability_spec.lua'], "Grimstroke ability scenarios passed");
run(['tests/gyrocopter_ability_spec.lua'], "Gyrocopter ability scenarios passed");
run(['tests/legion_commander_ability_spec.lua'], "Legion Commander ability scenarios passed (6 groups)");
run(['tests/medusa_ability_spec.lua'], "Medusa ability scenarios passed (5 groups)");
run(['tests/rubick_unknown_handlers_spec.lua'], 'Rubick unknown handler preservation passed');
run(['tests/hoodwink_ability_spec.lua'], "Hoodwink ability scenarios passed");
run(['tests/oracle_ability_spec.lua'], "Oracle ability scenarios passed");
run(['tests/meepo_ability_spec.lua'], "Meepo ability scenarios passed (6 groups)");
run(['tests/huskar_ability_spec.lua'], "Huskar ability scenarios passed");
run(['tests/pangolier_ability_spec.lua'], "Pangolier ability scenarios passed");
run(['tests/mirana_ability_spec.lua'], "Mirana ability scenarios passed (5 groups)");
run(['tests/jakiro_ability_spec.lua'], "Jakiro ability scenarios passed");
run(['tests/monkey_king_ability_spec.lua'], "Monkey King ability scenarios passed (4 groups)");
run(['tests/phantom_assassin_ability_spec.lua'], "Phantom Assassin ability scenarios passed");
run(['tests/juggernaut_ability_spec.lua'], "Juggernaut ability scenarios passed");
run(['tests/keeper_of_the_light_ability_spec.lua'], "Keeper of the Light ability scenarios passed");
run(['tests/morphling_ability_spec.lua'], "morphling_ability_spec: 5 behavioral groups passed");
run(['tests/phantom_lancer_ability_spec.lua'], "Phantom Lancer ability scenarios passed");
run(['tests/muerta_ability_spec.lua'], "muerta_ability_spec: 5 behavioral groups passed");
run(['tests/phoenix_ability_spec.lua'], "Phoenix ability scenarios passed");
run(['tests/largo_ability_spec.lua'], "largo_ability_spec: 6 behavioral groups passed");
run(['tests/primal_beast_ability_spec.lua'], "Primal Beast ability scenarios passed");
run(['tests/kez_ability_spec.lua'], "Kez ability scenarios passed");
run(['tests/puck_ability_spec.lua'], "Puck ability scenarios passed");
run(['tests/kunkka_ability_spec.lua'], "Kunkka ability scenarios passed");
run(['tests/pudge_ability_spec.lua'], "Pudge ability scenarios passed");
run(['tests/pugna_ability_spec.lua'], "Pugna ability scenarios passed");
run(['tests/snapfire_ability_spec.lua'], "Snapfire ability scenarios passed");
run(['tests/tusk_ability_spec.lua'], "Tusk ability scenarios passed");
run(['tests/queenofpain_ability_spec.lua'], "Queen of Pain ability scenarios passed: ");
run(['tests/sniper_ability_spec.lua'], "Sniper ability scenarios passed");
run(['tests/undying_ability_spec.lua'], "Undying ability scenarios passed");
run(['tests/rattletrap_ability_spec.lua'], "Clockwerk ability scenarios passed: ");
run(['tests/ursa_ability_spec.lua'], "Ursa ability scenarios passed");
run(['tests/razor_ability_spec.lua'], "Razor ability scenarios passed: ");
run(['tests/spectre_ability_spec.lua'], "Spectre ability scenarios passed");
run(['tests/riki_ability_spec.lua'], "Riki ability scenarios passed: ");
run(['tests/vengefulspirit_ability_spec.lua'], "Vengeful Spirit ability scenarios passed");
run(['tests/witch_doctor_ability_spec.lua'], "Witch Doctor ability scenarios passed: ");
run(['tests/spirit_breaker_ability_spec.lua'], "Spirit Breaker ability scenarios passed");
run(['tests/ringmaster_ability_spec.lua'], "Ringmaster ability scenarios passed: ");
run(['tests/venomancer_ability_spec.lua'], "Venomancer ability scenarios passed");
run(['tests/storm_spirit_ability_spec.lua'], "Storm Spirit ability scenarios passed");
run(['tests/viper_ability_spec.lua'], "Viper ability scenarios passed");
run(['tests/sand_king_ability_spec.lua'], "Sand King ability scenarios passed: ");
run(['tests/sven_ability_spec.lua'], "Sven ability scenarios passed");
run(['tests/shadow_demon_ability_spec.lua'], "Shadow Demon ability scenarios passed: ");
run(['tests/techies_ability_spec.lua'], "Techies ability scenarios passed");
run(['tests/visage_ability_spec.lua'], "Visage ability scenarios passed");
run(['tests/zuus_ability_spec.lua'], "Zeus ability scenarios passed: ");
run(['tests/void_spirit_ability_spec.lua'], "Void Spirit ability scenarios passed");
run(['tests/shadow_shaman_ability_spec.lua'], "Shadow Shaman ability scenarios passed: ");
run(['tests/templar_assassin_ability_spec.lua'], "Templar Assassin native/copied focused scenarios passed");
run(['tests/shredder_ability_spec.lua'], "Timbersaw ability scenarios passed: ");
run(['tests/terrorblade_ability_spec.lua'], "Terrorblade native/copied focused scenarios passed");
run(['tests/warlock_ability_spec.lua'], "Warlock ability scenarios passed");
run(['tests/slardar_ability_spec.lua'], "Slardar ability scenarios passed: ");
run(['tests/slark_ability_spec.lua'], "Slark ability scenarios passed: ");
run(['tests/tidehunter_ability_spec.lua'], "Tidehunter native/copied focused scenarios passed");
run(['tests/weaver_ability_spec.lua'], "Weaver ability scenarios passed");
run(['tests/silencer_ability_spec.lua'], "Silencer ability spec passed: ");
run(['tests/tinker_ability_spec.lua'], "Tinker native/copied focused scenarios passed");
run(['tests/skeleton_king_ability_spec.lua'], "Wraith King ability spec passed: ");
run(['tests/windrunner_ability_spec.lua'], "Windranger ability scenarios passed");
run(['tests/skywrath_mage_ability_spec.lua'], "Skywrath Mage ability spec passed: ");
run(['tests/tiny_ability_spec.lua'], "Tiny native/copied focused scenarios passed");
run(['tests/winter_wyvern_ability_spec.lua'], "Winter Wyvern ability scenarios passed");
run(['tests/treant_ability_spec.lua'], "Treant native/copied focused scenarios passed");
run(['tests/wisp_ability_spec.lua'], "Io ability scenarios passed: ");
run(['tests/troll_warlord_ability_spec.lua'], "Troll Warlord ability spec passed: ");
run(['tests/rubick_handlers_spec.lua'], 'Rubick specialized handler scenarios passed');
run(['tests/rubick_stolen_spec.lua'], 'Rubick stolen dispatcher, cast shapes, target masks, radii, support intent and channel safety passed');
run(['tests/rubick_hero_spec.lua'], 'Rubick hero behavior checks passed:');
run(['tests/invoker_skill_spec.lua'], 'Invoker skill order scenarios passed');
run(['tests/invoker_meteor_spec.lua'], 'Invoker Meteor Hammer scenarios passed');
run(['tests/lone_druid_items_spec.lua'], 'Lone Druid ownership scenarios passed');
run(['tests/purchase_plan_spec.lua'], 'Purchase plan scenarios passed');
// Legacy explicit orb lists, when present, must retain eight points in each orb.
for (const [, body] of read('bots/BotLib/hero_invoker.lua').matchAll(/^\s*\{([\d,]+)\},?\s*--/gm)) {
    const n = [0, 0, 0];
    for (const d of body.split(',')) n[+d - 1]++;
    assert.deepStrictEqual(n, [8, 8, 8], 'hero_invoker build must level each orb to 8: ' + body);
}
run(['tests/inventory_upkeep_spec.lua'], 'Inventory upkeep scenarios passed');
run(['tests/ward_spawn_box_spec.lua'], 'Ward spawn box scenarios passed');
run(['tests/ping_recorder_spec.lua'], 'Ping recorder scenarios passed');
run(['tests/lane_pull_spec.lua'], 'Lane pull scenarios passed');

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

// Weak-hero cap: Customize presets are never replaced; random picks leave room for pending weak presets.
const capStart = selection.indexOf('local function CountPendingCustomWeakPicks(');
const capEnd = selection.indexOf('-- Random pick within a role pool', capStart);
assert(capStart >= 0 && capEnd > capStart);
assert(selection.includes('X.CanPickHero(team, pick, pick == preselect and X.IsInCustomizedPicks(preselect))'),
    'the final pick check must pass the Customize flag');
run(['-e', `
TEAM_RADIANT=2
local Customize={Radiant_Heros={'Random','weak_a','npc_x','npc_y','weak_b'}}
local Utils={TrimString=function(s) return s end,HasValue=function(t,v) for _,x in pairs(t) do if x==v then return true end end return false end}
local WeakHeroes={'weak_a','weak_b','weak_c'}
local WeakHeroCount={[2]=0}
local selected={}
function GetTeam() return 2 end
function GetTeamPlayers() return {0,1,2,3,4} end
function GetSelectedHeroName(id) return selected[id] or '' end
local function GetWeakCapForTeam() return 1 end
local function AlreadyPickedOnTeam() return false end
local X={IsBannedHero=function(h) return h=='banned' end}
${selection.slice(capStart, capEnd)}
assert(not X.CanPickHero(2,'weak_c'), 'random weak pick blocked: two weak presets are still pending')
assert(X.CanPickHero(2,'npc_z'), 'non-weak random picks are unaffected')
assert(X.CanPickHero(2,'weak_a',true), 'first weak preset is kept')
selected[1]='weak_a'; WeakHeroCount[2]=1
assert(X.CanPickHero(2,'weak_b',true), 'second weak preset is kept despite the cap')
assert(not X.CanPickHero(2,'banned',true), 'bans still apply to presets')
Customize.Radiant_Heros={'Random'}; WeakHeroCount[2]=0; selected={}
assert(X.CanPickHero(2,'weak_c'), 'without weak presets a random weak pick fits under the cap')
print('Weak cap custom pick scenarios passed')
`], 'Weak cap custom pick scenarios passed');

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
local Item={IsTopItem=function() return true end,GetItemCount=function() return 0 end,GetItemCountInSolt=function() return 0 end,
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
