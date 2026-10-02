// Real TP decision and final execution, isolated from unrelated engine code.
const fs=require('fs'), path=require('path'), cp=require('child_process'), assert=require('assert');
process.chdir(path.resolve(__dirname,'..'));
const source=fs.readFileSync('bots/ability_item_usage_generic.lua','utf8');
function section(first,last,text=source) {
    const start=text.indexOf(first),end=text.indexOf(last,start);
    assert(start>=0 && end>start,`missing ${first}`);return text.slice(start,end);
}
const hooks=`return function(bot,J,FightResponse,LaneRotation,EarlyDefense,Services)
local X={ConsiderItemDesire={}}
local botName,team,nMode,botTarget=bot:GetUnitName(),GetTeam(),bot:GetActiveMode(),bot:GetTarget()
local PowerTreads,ItemCastPolicy=Services.treads,Services.items
X.GetNumHeroWithinRange=function(r)return #J.GetEnemiesNearLoc(bot:GetLocation(),r)end
X.IsInvFull=function()return false end
X.GetNumStashItem=function()return 0 end
X.IsBaseTowerDestroyed=function()return false end
X.GetLaningTPLocation=function()return nil,false end
X.GetDefendTPLocation=Services.defendLocation
X.CanJuke=function()return true end
X.IsFarmingAlways=function()return false end
`+section('X.ConsiderItemDesire["item_tpscroll"] = function','X.ConsiderItemDesire["item_urn_of_shadows"] = function')+
section('function X.SetUseItem(','function X.IsWithoutSpellShield(')+'return X\nend\n';
fs.writeFileSync('.test-tools/early-lane-defense-hooks.lua',hooks);
const prophet=fs.readFileSync('bots/BotLib/hero_furion.lua','utf8');
fs.writeFileSync('.test-tools/early-lane-prophet-hooks.lua',
    // Hero-specific landing safety is covered by furion_ability_spec; isolate lane policy here.
    'return function(bot,J,FightResponse)\nlocal X={}\nlocal FurionAbilities={SourceTeleportSafe=function()return true end,TeleportSafe=function()return true end}\n'+
    section('local Sprout, Teleportation,','function X.ConsiderSprout()',prophet)+
    section('function X.ConsiderTeleportation()','function X.ConsiderNaturesCall()',prophet)+
    `
for _,name in ipairs({'ConsiderSproutCall','ConsiderSprout','ConsiderNaturesCall','ConsiderCurseOfTheOldGrowth','ConsiderWrathOfNature'}) do
    X[name]=function()return 0 end
end
return X
end
`);
const result=cp.spawnSync(process.execPath,[path.resolve('.test-tools/node_modules/fengari-node-cli/src/lua-cli.js'),
    'tests/early_lane_defense_spec.lua'],{encoding:'utf8'});
process.stdout.write(result.stdout||'');process.stderr.write(result.stderr||'');
assert(!result.error && result.status===0 && /\d+ early lane defense scenarios passed/.test(result.stdout), 'early TP policies failed');
