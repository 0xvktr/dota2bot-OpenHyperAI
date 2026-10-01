// Run `node tests/power_treads_spec.cjs`. Test the real shared helpers and item
// executor without loading their unrelated engine dependencies.
const fs = require('fs');
const path = require('path');
const cp = require('child_process');
const assert = require('assert');
process.chdir(path.resolve(__dirname, '..'));
const parser = require('../.test-tools/node_modules/luaparse');
for (const file of ['bots/FunLib/power_treads.lua', 'bots/FunLib/jmz_func.lua',
    'bots/ability_item_usage_generic.lua', 'tests/power_treads_spec.lua']) {
    parser.parse(fs.readFileSync(file, 'utf8'), { luaVersion: '5.2' });
}
function section(file, first, last) {
    const source = fs.readFileSync(file, 'utf8');
    const start = source.indexOf(first), end = source.indexOf(last, start);
    assert(start >= 0 && end > start, `missing test section in ${file}`);
    return source.slice(start, end);
}
fs.writeFileSync('.test-tools/power-treads-hooks.lua',
    'return function(bot, J, PowerTreads, FightResponse, Services)\nlocal X = {}\n' +
    'local InventoryUpkeep, AlchemistScepter, LotusUsage, BossCombat = Services.inventory, Services.scepter, Services.lotus, Services.boss\n' +
    'local bDebugMode = false\nlocal aetherRange, botTarget, nMode, hNearbyEnemyHeroList, hNearbyEnemyTowerList\n' +
    "local ItemCastPolicy = require('bots/FunLib/item_cast_policy')\n" +
    section('bots/FunLib/jmz_func.lua', 'function J.SetQueueSwitchPtToINT(', 'function J.IsOtherAllysTarget(') +
    section('bots/ability_item_usage_generic.lua', 'local function ItemUsageComplement()', 'function X.SetUseItem(') +
    'X.RunItemThink = ItemUsageComplement\n' +
    section('bots/ability_item_usage_generic.lua', 'function X.SetUseItem(', 'function X.IsWithoutSpellShield(') +
    'return X\nend\n');
const result = cp.spawnSync(process.execPath,
    [path.resolve('.test-tools/node_modules/fengari-node-cli/src/lua-cli.js'), 'tests/power_treads_spec.lua'],
    { encoding: 'utf8' });
process.stdout.write(result.stdout || '');
process.stderr.write(result.stderr || '');
assert(!result.error && result.status === 0 && result.stdout.includes('Power Treads scenarios passed'),
    'Power Treads scenarios failed');
