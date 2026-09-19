// Optional Node runner for machines without native Lua; dependencies stay local.
// npm install --prefix .test-tools --no-package-lock --ignore-scripts fengari-node-cli luaparse
const fs = require('fs');
const cp = require('child_process');
const path = require('path');
const parser = require('../.test-tools/node_modules/luaparse');
const lua = path.resolve(__dirname, '../.test-tools/node_modules/fengari-node-cli/src/lua-cli.js');
process.chdir(path.resolve(__dirname, '..'));
const files = [
    'bots/FunLib/boss_combat.lua',
    'bots/FunLib/lotus_usage.lua', 'bots/FunLib/fight_response.lua', 'bots/FunLib/objective_settings.lua',
    'bots/ability_item_usage_generic.lua', 'bots/item_purchase_generic.lua',
    'bots/FunLib/objectives.lua', 'bots/FunLib/objective_locations.lua',
    'bots/FunLib/jmz_func.lua', 'bots/mode_rune_generic.lua',
    'bots/mode_roshan_generic.lua', 'bots/mode_side_shop_generic.lua',
    'bots/mode_assemble_generic.lua', 'bots/mode_push_tower_top_generic.lua',
    'bots/mode_push_tower_mid_generic.lua', 'bots/mode_push_tower_bot_generic.lua',
    'bots/mode_farm_generic.lua', 'bots/mode_roam_generic.lua', 'bots/mode_team_roam_generic.lua',
];
for (const file of files) {
    const text = fs.readFileSync(file, 'utf8');
    // Existing project files use goto/labels. Keep the new modules 5.1-compatible,
    // and accept the existing dialect when checking the integration files.
    parser.parse(text, { luaVersion: file.includes('/objective') ? '5.1' : '5.2' });
}
console.log(`${files.length} Lua files passed syntax checks`);
const run = cp.spawnSync(process.execPath, [lua, 'tests/objectives_spec.lua'], { encoding: 'utf8' });
process.stdout.write(run.stdout || '');
process.stderr.write(run.stderr || '');
// Fengari CLI can exit 0 after a Lua error; require the completion marker too.
if (run.error || run.status !== 0 || !/\d+ objective scenarios passed/.test(run.stdout)) process.exit(1);

const feedback = cp.spawnSync(process.execPath, [lua, 'tests/feedback_spec.lua'], { encoding: 'utf8' });
process.stdout.write(feedback.stdout || '');
process.stderr.write(feedback.stderr || '');
if (feedback.error || feedback.status !== 0 || !/\d+ feedback scenarios passed/.test(feedback.stdout)) process.exit(1);

// Exercise the real DPS helper without loading thousands of unrelated engine
// functions. Extract its complete top-level definition, not a reimplementation.
const jmz = fs.readFileSync('bots/FunLib/jmz_func.lua', 'utf8');
const dpsStart = jmz.indexOf('function J.HasEnoughDPSForRoshan(heroes)');
const dpsEnd = jmz.indexOf('\nfunction J.IsNotSelf(', dpsStart);
if (dpsStart < 0 || dpsEnd < 0) throw new Error('Could not locate Roshan DPS helper');
const dpsSpec = `
J = { GetArmorReducers = function() return 0 end }
function DotaTime() return 0 end
${jmz.slice(dpsStart, dpsEnd)}
local h = { GetAttackDamage=function() return 150 end, GetAttackSpeed=function() return 1 end }
assert(not J.HasEnoughDPSForRoshan({}), 'empty team')
assert(not J.HasEnoughDPSForRoshan({h}), 'weak solo hero')
assert(J.HasEnoughDPSForRoshan({h,h,h,h,h}), 'combined team DPS must not be averaged')
print('Roshan DPS regression checks passed')
`;
const dps = cp.spawnSync(process.execPath, [lua, '-e', dpsSpec], { encoding: 'utf8' });
process.stdout.write(dps.stdout || '');
process.stderr.write(dps.stderr || '');
if (dps.error || dps.status !== 0 || !dps.stdout.includes('Roshan DPS regression checks passed')) process.exit(1);
