// Exercise the real framework entry point: observed spell continuations must
// reach hero decisions before the general invulnerability guard.
const fs = require('fs');
const path = require('path');
const cp = require('child_process');
const assert = require('assert');
process.chdir(path.resolve(__dirname, '..'));
const source = fs.readFileSync('bots/ability_item_usage_generic.lua', 'utf8');
const start = source.indexOf('function AbilityUsageThink()');
const end = source.indexOf('function BuybackUsageThink()', start);
assert(start >= 0 && end > start);
fs.writeFileSync('.test-tools/hero-cast-hooks.lua',
    'return function(bot, BotBuild, GateProbe, RefreshBotHandle, J, BossCombat, HighFive)\n' +
    'local botName = "npc_dota_hero_test"\nlocal Customize = {ThinkLess=0}\n' +
    source.slice(start, end) + 'return AbilityUsageThink\nend\n');
const result = cp.spawnSync(process.execPath,
    [path.resolve('.test-tools/node_modules/fengari-node-cli/src/lua-cli.js'), 'tests/hero_cast_hooks_spec.lua'],
    {encoding: 'utf8'});
process.stdout.write(result.stdout || '');
process.stderr.write(result.stderr || '');
assert(!result.error && result.status === 0 && result.stdout.includes('Hero cast hook scenarios passed'),
    'Hero cast hook scenarios failed');
