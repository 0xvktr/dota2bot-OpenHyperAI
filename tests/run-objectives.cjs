// Optional Node runner for machines without native Lua; dependencies stay local.
// npm install --prefix .test-tools --no-package-lock --ignore-scripts fengari-node-cli luaparse
const fs = require('fs');
const cp = require('child_process');
const path = require('path');
const parser = require('../.test-tools/node_modules/luaparse');
const lua = path.resolve(__dirname, '../.test-tools/node_modules/fengari-node-cli/src/lua-cli.js');
process.chdir(path.resolve(__dirname, '..'));
const files = [
    'bots/FunLib/support_last_hits.lua',
    'bots/FunLib/aba_global_overrides.lua',
    'bots/FunLib/twin_gate_probe.lua',
    'bots/FunLib/lane_rotation.lua', 'bots/FunLib/early_lane_defense.lua', 'bots/BotLib/hero_furion.lua',
    'bots/mode_defend_tower_top_generic.lua', 'bots/mode_defend_tower_mid_generic.lua', 'bots/mode_defend_tower_bot_generic.lua',
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
const earlyDefense = cp.spawnSync(process.execPath, ['tests/early_lane_defense_spec.cjs'], {stdio: 'inherit'});
if (earlyDefense.error || earlyDefense.status !== 0) process.exit(1);
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

const rotation = cp.spawnSync(process.execPath, [lua, 'tests/rotation_spec.lua'], { encoding: 'utf8' });
process.stdout.write(rotation.stdout || '');
process.stderr.write(rotation.stderr || '');
if (rotation.error || rotation.status !== 0 || !/\d+ rotation scenarios passed/.test(rotation.stdout)) process.exit(1);

// Test the actual final cast boundary: older TP decision branches must not bypass it.
const itemUsage = fs.readFileSync('bots/ability_item_usage_generic.lua', 'utf8');
const castStart = itemUsage.indexOf('function X.SetUseItem(');
const castEnd = itemUsage.indexOf('function X.IsWithoutSpellShield(', castStart);
if (castStart < 0 || castEnd < 0) throw new Error('Could not locate item cast boundary');
const castSpec = `X = {}; local allowed = false; local casts = 0; local records = 0
local ItemCastPolicy = { RestoreDesire = function() return 0 end }
local J = {}
-- Treads behavior has its own real-policy suite; isolate this TP gate check.
local PowerTreads = { ActionLocked=function() return false end, PrepareItem=function() return false end }
local FightResponse = {
 CanTeleportTo=function() return allowed end,
 RecordTeleport=function() records=records+1 end
}
local bot = { Action_UseAbilityOnLocation=function() casts=casts+1 end }
${itemUsage.slice(castStart,castEnd)}
local tp={GetName=function()return 'item_tpscroll'end}
assert(X.SetUseItem(tp,{x=1,y=2},'ground') == false)
assert(casts==0 and records==0)
allowed=true;X.SetUseItem(tp,{x=1,y=2},'ground')
assert(casts==1 and records==1)
print('TP cast boundary checks passed')`;
const cast = cp.spawnSync(process.execPath, [lua, '-e', castSpec], { encoding: 'utf8' });
process.stdout.write(cast.stdout || '');process.stderr.write(cast.stderr || '');
if (cast.error || cast.status !== 0 || !cast.stdout.includes('TP cast boundary checks passed')) process.exit(1);

const gateProbe = cp.spawnSync(process.execPath, [lua, 'tests/gate_probe_spec.lua'], { encoding: 'utf8' });
process.stdout.write(gateProbe.stdout || '');process.stderr.write(gateProbe.stderr || '');
if (gateProbe.error || gateProbe.status !== 0 || !/\d+ gate probe scenarios passed/.test(gateProbe.stdout)) process.exit(1);

// Use the actual wrappers with an engine stub and no Lua debug library.
const overrides = fs.readFileSync('bots/FunLib/aba_global_overrides.lua', 'utf8');
const traceStart = overrides.indexOf('local function safeTraceback()');
const traceEnd = overrides.indexOf('\nend',traceStart)+4;
const wrapperStart = overrides.indexOf('local function probeMayCastHidden(');
const wrapperEnd = overrides.indexOf('-- local originalAction_AttackUnit',wrapperStart);
if (traceStart<0 || wrapperStart<0 || wrapperEnd<0) throw new Error('Gate wrapper definitions missing');
const wrapperSpec = `debug=nil
local calls=0
CDOTA_Bot_Script={Action_UseAbility=function()calls=calls+1 end,ActionPush_UseAbility=function()calls=calls+1 end}
${overrides.slice(traceStart,traceEnd)}
${overrides.slice(wrapperStart,wrapperEnd)}
local bot=setmetatable({}, {__index=CDOTA_Bot_Script})
local gate={IsHidden=function()return true end,GetName=function()return 'twin_gate_portal_warp'end}
local other={IsHidden=function()return true end,GetName=function()return 'other_hidden_ability'end}
bot:Action_UseAbility(nil);bot:Action_UseAbility(gate);assert(calls==0)
bot.ohaGateProbe={done=false};bot:Action_UseAbility(gate);assert(calls==1)
bot:ActionPush_UseAbility(gate);assert(calls==2)
bot:Action_UseAbility(other);assert(calls==2)
bot.ohaGateProbe.done=true;bot:Action_UseAbility(gate);assert(calls==2)
bot:Action_UseAbility({IsHidden=function()return false end});assert(calls==3)
print('Hidden gate wrapper regression checks passed')`;
const wrappers=cp.spawnSync(process.execPath,[lua,'-e',wrapperSpec],{encoding:'utf8'});
process.stdout.write(wrappers.stdout||'');process.stderr.write(wrappers.stderr||'');
if(wrappers.error||wrappers.status!==0||!wrappers.stdout.includes('Hidden gate wrapper regression checks passed'))process.exit(1);

const support = cp.spawnSync(process.execPath, [lua, 'tests/support_last_hits_spec.lua'], { encoding: 'utf8' });
process.stdout.write(support.stdout || '');process.stderr.write(support.stderr || '');
if (support.error || support.status !== 0 || !/\d+ support last-hit scenarios passed/.test(support.stdout)) process.exit(1);

const attackStart=overrides.indexOf('local function reserveLaneCreep(');
const attackEnd=overrides.indexOf('local originalGetTarget =',attackStart);
if(attackStart<0||attackEnd<0)throw new Error('Support attack wrappers missing');
const attackSpec=`local calls=0;local reserve=true
function GetScriptDirectory()return 'bots'end
package.loaded['bots/FunLib/support_last_hits']={ReservedForCore=function()if reserve then return {} end end}
CDOTA_Bot_Script={Action_AttackUnit=function()calls=calls+1 end,ActionQueue_AttackUnit=function()calls=calls+1 end,ActionPush_AttackUnit=function()calls=calls+1 end}
${overrides.slice(attackStart,attackEnd)}
local bot=setmetatable({},{__index=CDOTA_Bot_Script})
local creep={IsNull=function()return false end,GetUnitName=function()return 'npc_dota_creep_badguys_melee'end}
for _,method in ipairs({'Action_AttackUnit','ActionQueue_AttackUnit','ActionPush_AttackUnit'})do bot[method](bot,creep,true)end
assert(calls==0)
reserve=false
for _,method in ipairs({'Action_AttackUnit','ActionQueue_AttackUnit','ActionPush_AttackUnit'})do bot[method](bot,creep,true)end
assert(calls==3)
reserve=true;bot:Action_AttackUnit({IsNull=function()return false end,GetUnitName=function()return 'npc_dota_hero_axe'end},true)
assert(calls==4)
print('Support attack wrapper checks passed')`;
const attackWrappers=cp.spawnSync(process.execPath,[lua,'-e',attackSpec],{encoding:'utf8'});
process.stdout.write(attackWrappers.stdout||'');process.stderr.write(attackWrappers.stderr||'');
if(attackWrappers.error||attackWrappers.status!==0||!attackWrappers.stdout.includes('Support attack wrapper checks passed'))process.exit(1);
