// Run the actual social policy, scoped hidden wrappers and generic ability Think.
const fs=require('fs'),path=require('path'),cp=require('child_process'),assert=require('assert');
process.chdir(path.resolve(__dirname,'..'));
const parser=require('../.test-tools/node_modules/luaparse');
for(const file of ['bots/FunLib/high_five.lua','bots/FunLib/aba_global_overrides.lua',
    'bots/ability_item_usage_generic.lua','bots/Customize/general.lua','tests/high_five_spec.lua']) {
    parser.parse(fs.readFileSync(file,'utf8'),{luaVersion:'5.2'});
}
function section(text,start,end) {
    const a=text.indexOf(start),b=text.indexOf(end,a);
    assert(a>=0&&b>a,`missing ${start}`);return text.slice(a,b);
}
const overrides=fs.readFileSync('bots/FunLib/aba_global_overrides.lua','utf8');
fs.writeFileSync('.test-tools/high-five-wrappers.lua',
    'return function(CDOTA_Bot_Script)\nlocal function safeTraceback()return "test" end\n'+
    section(overrides,'local function probeMayCastHidden(','-- local originalAction_AttackUnit')+
    'return CDOTA_Bot_Script\nend\n');
const generic=fs.readFileSync('bots/ability_item_usage_generic.lua','utf8');
fs.writeFileSync('.test-tools/high-five-think.lua',
    'return function(bot,J,HighFive,BotBuild,BossCombat,GateProbe,Customize)\n'+
    'local botName=bot:GetUnitName()\nlocal function RefreshBotHandle()return false end\nlocal AbilityUsageThink\n'+
    'local EmergencyReactions={InterruptTeleport=function()return false end,WakeCore=function()return false end}\n'+
    section(generic,'function AbilityUsageThink()','function BuybackUsageThink()')+
    'return AbilityUsageThink\nend\n');
const result=cp.spawnSync(process.execPath,[path.resolve('.test-tools/node_modules/fengari-node-cli/src/lua-cli.js'),
    'tests/high_five_spec.lua'],{encoding:'utf8'});
process.stdout.write(result.stdout||'');process.stderr.write(result.stderr||'');
assert(!result.error&&result.status===0&&/\d+ High Five scenarios passed/.test(result.stdout),'High Five checks failed');
