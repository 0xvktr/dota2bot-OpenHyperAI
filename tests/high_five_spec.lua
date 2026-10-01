package.path='./?.lua;'..package.path
BOT_ACTION_TYPE_NONE,BOT_ACTION_TYPE_IDLE,BOT_ACTION_TYPE_MOVE_TO,BOT_ACTION_TYPE_MOVE_TO_DIRECTLY=0,1,2,3
BOT_ACTION_TYPE_ATTACK,BOT_ACTION_TYPE_ATTACKMOVE,BOT_ACTION_TYPE_USE_ABILITY,BOT_ACTION_TYPE_PICK_UP_RUNE=4,5,6,7
BOT_MODE_DEFEND_ALLY=10
local now,allies,enemies,seen,scores,roll,rolls,bot,human,settings,logs
function DotaTime()return now end
function GetHeroKills(id)return (scores[id]or {}).kills or 0 end
function GetHeroAssists(id)return (scores[id]or {}).assists or 0 end
function RandomInt()rolls=rolls+1;return roll end
local function distance(a,b)return math.sqrt((a.x-b.x)^2+(a.y-b.y)^2)end
function GetUnitToUnitDistance(a,b)return distance(a.loc,b.loc)end
local realPrint=print
print=function(...)logs[#logs+1]=table.concat({...},' ')end
local abilityMethods={
    'Action_UseAbility','Action_UseAbilityOnEntity','Action_UseAbilityOnLocation','Action_UseAbilityOnTree',
    'ActionQueue_UseAbility','ActionQueue_UseAbilityOnEntity','ActionQueue_UseAbilityOnLocation','ActionQueue_UseAbilityOnTree',
    'ActionPush_UseAbility','ActionPush_UseAbilityOnEntity','ActionPush_UseAbilityOnLocation','ActionPush_UseAbilityOnTree',
}
local api={}
for _,name in ipairs(abilityMethods)do
    api[name]=function(self,ability,target,extra)
        if self.failAction then error('engine rejected action')end
        self.actions[#self.actions+1]={method=name,ability=ability,target=target,extra=extra}
        return name
    end
end
api=dofile('.test-tools/high-five-wrappers.lua')(api)
local function hero(id,isBot,x)
    local h=setmetatable({id=id,bot=isBot,loc={x=x or 0,y=0},mods={},actions={},abilities={},alive=true,
        visible=true,hp=0.9,mode=0,action=BOT_ACTION_TYPE_IDLE,queued=0,frameProcessTime=0.1,
        lastAbilityFrameProcessTime=0}, {__index=api})
    function h:GetPlayerID()return self.id end
    function h:GetUnitName()return 'npc_dota_hero_puck'end
    function h:GetLocation()return self.loc end
    function h:GetTeam()return self.team or 2 end
    function h:IsAlive()return self.alive end
    function h:IsHero()return true end
    function h:IsBot()return self.bot end
    function h:IsIllusion()return self.illusion==true end
    function h:IsInvisible()return self.invisible==true end
    function h:IsInvulnerable()return self.invulnerable==true end
    function h:IsChanneling()return self.channel==true end
    function h:IsCastingAbility()return self.casting==true end
    function h:IsUsingAbility()return self.using==true end
    function h:IsHexed()return self.hexed==true end
    function h:IsMuted()return self.muted==true end
    function h:IsSilenced()return self.silenced==true end
    function h:IsStunned()return self.stunned==true end
    function h:GetAttackTarget()return self.attackTarget end
    function h:GetActiveMode()return self.mode end
    function h:GetCurrentActionType()return self.action end
    function h:NumQueuedActions()return self.queued end
    function h:HasModifier(name)return self.mods[name]==true end
    function h:WasRecentlyDamagedByAnyHero()return self.damaged==true end
    function h:WasRecentlyDamagedByTower()return self.towerDamage==true end
    function h:GetAbilityByName(name)return self.abilities[name]end
    return h
end
local function ability(name)
    local a={name=name or 'plus_high_five',ready=true,hidden=true,mana=0,castPoint=0}
    function a:GetName()return self.name end
    function a:IsFullyCastable()return self.ready end
    function a:IsHidden()return self.hidden end
    function a:GetManaCost()return self.mana end
    function a:GetCastPoint()return self.castPoint end
    return a
end
local J={}
function J.IsValidHero(h)return h~=nil and h.alive and h.visible and not h.invulnerable end
function J.IsSuspiciousIllusion(h)return h.suspicious==true end
function J.IsMeepoClone(h)return h.clone==true end
function J.CanNotUseAction(h)return h.locked==true end
function J.IsGoingOnSomeone(h)return h.attacking==true end
function J.IsRetreating(h)return h.retreat==true end
function J.IsDefending(h)return h.defending==true end
function J.GetHP(h)return h.hp end
function J.GetEnemiesNearLoc()return enemies end
function J.GetLastSeenEnemiesNearLoc()return seen end
function J.GetAlliesNearLoc(loc,r)
    local list={};for _,h in ipairs(allies)do if distance(h.loc,loc)<=r then list[#list+1]=h end end;return list
end
function J.IsNoAbilityIllution(h)return h.noAbilities==true end
local H=require('bots/FunLib/high_five')
local genericFactory=dofile('.test-tools/high-five-think.lua')
local function reset()
    now,roll,rolls=100,1,0;logs={};scores={};enemies={};seen={}
    settings={Enable=true,Allow_High_Fives=true}
    bot,human=hero(0,true),hero(1,false,500)
    human.mods.modifier_plus_high_five_requested=true
    bot.abilities.plus_high_five=ability()
    allies={bot,human}
end
local passed=0
local function test(name,fn)reset();fn();passed=passed+1;realPrint('PASS '..name)end
local function think()return H.Think(bot,J,settings)end
test('reply uses the instant cosmetic without targets or movement orders',function()
    bot.action=BOT_ACTION_TYPE_MOVE_TO;bot.moveTarget={x=4000,y=0}
    assert(think() and #bot.actions==1)
    assert(bot.actions[1].method=='Action_UseAbility' and not bot.actions[1].target)
    assert(bot.moveTarget.x==4000 and not bot.ohaHighFiveAbility and not bot.ohaAbilityOrderTime)
end)
test('persistent request is attempted once even with a ready ability',function()
    assert(think());now=111;assert(not think());assert(#bot.actions==1)
end)
test('request ending while on cooldown enables a later new request',function()
    assert(think());human.mods={};bot.abilities.plus_high_five.ready=false
    now=102;assert(not think());human.mods.modifier_plus_high_five_requested=true
    bot.abilities.plus_high_five.ready=true;now=111;assert(think() and #bot.actions==2)
end)
test('new requests respect the local attempt interval',function()
    assert(think());human.mods={};now=101;assert(not think())
    human.mods.modifier_plus_high_five_requested=true;now=102;assert(not think())
    now=110;assert(think())
end)
test('another bot reservation prevents simultaneous responses',function()
    local other=hero(2,true,300);other.ohaHighFiveTarget=human.id;other.ohaHighFiveUntil=101
    allies[#allies+1]=other;assert(not think());now=101;assert(think())
end)
test('no chasing, enemy-human replies, or unseen-human replies',function()
    for _,change in ipairs({function()human.loc.x=901 end,function()human.team=3 end,
        function()human.visible=false end,function()human.alive=false end})do reset();change();assert(not think())end
end)
test('illusion, clone and bot requests do not trigger friendly responses',function()
    for _,field in ipairs({'illusion','clone','suspicious','bot'})do reset();human[field]=true;assert(not think())end
end)
test('cosmetics never replace channels, spells, queue entries or disabled actions',function()
    for _,field in ipairs({'channel','casting','using','locked','hexed','muted','silenced','stunned','invisible'})do
        reset();bot[field]=true;assert(not think(),field);assert(#bot.actions==0)
    end
    reset();bot.queued=1;assert(not think())
    reset();bot.mods.modifier_teleporting=true;assert(not think())
end)
test('combat, local danger and low HP suppress social interaction',function()
    for _,field in ipairs({'attacking','retreat','defending','damaged','towerDamage'})do
        reset();bot[field]=true;assert(not think(),field)
    end
    reset();bot.hp=0.49;assert(not think())
    reset();enemies={hero(4,true)};assert(not think())
    reset();seen={4};assert(not think())
    reset();bot.attackTarget=human;assert(not think())
    reset();bot.mode=BOT_MODE_DEFEND_ALLY;assert(not think())
end)
test('attacks, attack-moves and pickups remain untouched',function()
    for _,action in ipairs({BOT_ACTION_TYPE_ATTACK,BOT_ACTION_TYPE_ATTACKMOVE,BOT_ACTION_TYPE_USE_ABILITY,
        BOT_ACTION_TYPE_PICK_UP_RUNE})do reset();bot.action=action;assert(not think())end
end)
test('illusions, duplicates and bears cannot initiate cosmetic orders',function()
    for _,field in ipairs({'illusion','clone','suspicious','isBear'})do reset();bot[field]=true;assert(not think())end
    reset();bot.mods.modifier_arc_warden_tempest_double=true;assert(not think())
end)
test('missing, cooldown, wrong-name and non-instant handles fail quietly',function()
    for _,change in ipairs({function()bot.abilities={}end,function()bot.abilities.plus_high_five.ready=false end,
        function()bot.abilities.plus_high_five.name='other' end,function()bot.abilities.plus_high_five.mana=1 end,
        function()bot.abilities.plus_high_five.castPoint=1 end})do reset();change();assert(not think());assert(#logs==0)end
end)
test('high_five handle and old request modifier are supported as fallback',function()
    bot.abilities={high_five=ability('high_five')};human.mods={modifier_high_five_requested=true};assert(think())
end)
test('own pending request prevents repeated raising of hands',function()
    bot.mods.modifier_plus_high_five_requested=true;assert(not think())
end)
test('disable setting suppresses behavior and master switch restores defaults',function()
    settings.Allow_High_Fives=false;assert(not think() and not bot.ohaHighFive)
    settings.Enable=false;assert(think())
end)
test('debug exposes handles and attempts without claiming animation success',function()
    settings.Debug_High_Fives=true;assert(think());assert(#logs==2)
    assert(logs[1]:find('hidden=true') and logs[2]:find('animation unverified'))
    now=101;think();assert(#logs==2)
end)
test('engine error clears hidden permission and bounds attempts',function()
    bot.failAction=true;assert(not think() and not bot.ohaHighFiveAbility)
    bot.failAction=false;now=111;assert(not think() and #bot.actions==0)
end)
test('initial scoreboard never celebrates historical kills',function()
    human.mods={};scores[bot.id]={kills=5,assists=10};assert(not think() and rolls==0)
end)
test('kill or assist can trigger one bounded celebration',function()
    for _,field in ipairs({'kills','assists'})do reset();human.mods={};assert(not think())
        scores[bot.id]={[field]=1};now=101;assert(think() and rolls==1)
        now=112;assert(not think() and #bot.actions==1)
    end
end)
test('celebration chance is rolled once per event, not repeatedly',function()
    human.mods={};assert(not think());roll=4;scores[bot.id]={kills=1};now=101
    assert(not think() and rolls==1);roll=1;now=102;assert(not think() and rolls==1)
end)
test('celebration waits for safety but expires instead of resurfacing later',function()
    human.mods={};think();scores[bot.id]={kills=1};bot.damaged=true;now=101;assert(not think())
    now=117;bot.damaged=false;assert(not think() and #bot.actions==0)
end)
test('celebration can happen when combat clears within its event window',function()
    human.mods={};think();scores[bot.id]={kills=1};bot.damaged=true;now=101;assert(not think())
    now=106;bot.damaged=false;assert(think())
end)
test('celebration cooldown permits replies while suppressing another offer',function()
    human.mods={};think();scores[bot.id]={kills=1};now=101;assert(think())
    scores[bot.id].kills=2;now=120;assert(not think())
    human.mods.modifier_plus_high_five_requested=true;now=121;assert(think())
end)
test('only a completed arrived rescue can trigger a celebration',function()
    human.mods={};bot.ohaLaneRotation={phase='travel'};think()
    now=101;bot.ohaLaneRotation=nil;assert(not think() and rolls==0)
    bot.ohaLaneRotation={phase='assist'};now=102;assert(not think())
    bot.ohaLaneRotation.phase='return';now=103;assert(think() and rolls==1)
end)
test('all gameplay cast shapes preserve arguments and block same-frame cosmetics',function()
    for _,method in ipairs(abilityMethods)do reset();local spell=ability('gameplay_spell');spell.hidden=false
        local target={x=42};local targeted=method:find('On')~=nil
        local result
        if targeted then result=bot[method](bot,spell,target,99) else result=bot[method](bot,spell)end
        assert(result==method)
        if targeted then assert(bot.actions[1].target==target and bot.actions[1].extra==99)end
        assert(bot.ohaAbilityOrderTime==now and not think() and #bot.actions==1,method)
    end
end)
test('hidden whitelist requires the matching scoped High Five handle',function()
    local five=bot.abilities.plus_high_five;bot:Action_UseAbility(five);assert(#bot.actions==0)
    bot.ohaHighFiveAbility=five;bot:Action_UseAbility(five);assert(#bot.actions==1)
    local other=ability('unrelated_hidden');bot.ohaHighFiveAbility=other;bot:Action_UseAbility(other);assert(#bot.actions==1)
    bot.ohaHighFiveAbility=five;bot:ActionPush_UseAbility(five);assert(#bot.actions==1)
    bot.ohaHighFiveAbility=nil
end)
test('existing scoped Twin Gate diagnostic remains available',function()
    local gate=ability('twin_gate_portal_warp');bot:Action_UseAbility(gate);assert(#bot.actions==0)
    bot.ohaGateProbe={done=false};bot:Action_UseAbility(gate);bot:ActionPush_UseAbility(gate);assert(#bot.actions==2)
    bot.ohaGateProbe.done=true;bot:Action_UseAbility(gate);assert(#bot.actions==2)
end)
local function generic(skills,boss)
    return genericFactory(bot,J,H,{SkillsComplement=skills or function()end},
        {AbilityThink=boss or function()return false end},{Active=function()return false end},{ThinkLess=1})
end
test('generic Think invokes social logic after an idle hero decision',function()
    generic()();assert(#bot.actions==1 and bot.actions[1].ability:GetName()=='plus_high_five')
end)
test('generic Think never overwrites a selected instant spell in the same frame',function()
    generic(function()local spell=ability('gameplay_spell');spell.hidden=false
        bot:Action_UseAbilityOnLocation(spell,{x=500})end)()
    assert(#bot.actions==1 and bot.actions[1].ability:GetName()=='gameplay_spell')
end)
test('generic Think honors boss priority and external customization',function()
    generic(nil,function()return true end)();assert(#bot.actions==0)
    reset();J.Customize={Enable=true,Allow_High_Fives=false};generic()();assert(#bot.actions==0);J.Customize=nil
end)
print=realPrint
print(passed..' High Five scenarios passed')
