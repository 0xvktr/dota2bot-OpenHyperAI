package.path='./?.lua;'..package.path
TEAM_RADIANT,TEAM_DIRE=2,3
LANE_NONE,LANE_TOP,LANE_MID,LANE_BOT=0,1,2,3
TOWER_TOP_1,TOWER_MID_1,TOWER_BOT_1,TOWER_TOP_2,TOWER_MID_2,TOWER_BOT_2,TOWER_TOP_3,TOWER_MID_3,TOWER_BOT_3=1,2,3,4,5,6,7,8,9
BOT_MODE_NONE,BOT_MODE_LANING,BOT_MODE_RETREAT,BOT_MODE_DEFEND_ALLY=0,1,2,3
BOT_MODE_DEFEND_TOWER_TOP,BOT_MODE_DEFEND_TOWER_MID,BOT_MODE_DEFEND_TOWER_BOT=4,5,6
BOT_MODE_ATTACK,BOT_MODE_RUNE,BOT_MODE_ROSHAN,BOT_MODE_SIDE_SHOP,BOT_MODE_FARM=7,8,9,10,11
BOT_MODE_SECRET_SHOP=12
BOT_MODE_DESIRE_MODERATE=0.5
BOT_ACTION_DESIRE_NONE,BOT_ACTION_DESIRE_MODERATE,BOT_ACTION_DESIRE_HIGH,BOT_ACTION_DESIRE_ABSOLUTE=0,0.5,0.8,1
DAMAGE_TYPE_PHYSICAL=1
local V={};V.__index=V
function Vector(x,y)return setmetatable({x=x,y=y or 0},V)end
V.__add=function(a,b)return Vector(a.x+b.x,a.y+b.y)end
V.__sub=function(a,b)return Vector(a.x-b.x,a.y-b.y)end
V.__mul=function(a,b)return Vector(a.x*b,a.y*b)end
function V:Normalized()local d=math.sqrt(self.x*self.x+self.y*self.y);return Vector(self.x/d,self.y/d)end
local function dist(a,b)return math.sqrt((a.x-b.x)^2+(a.y-b.y)^2)end
local now,team,turbo,heroes,enemies,towers
function GetScriptDirectory()return 'bots'end
function GetTeam()return team end
function GetOpposingTeam()return team==2 and 3 or 2 end
function DotaTime()return now end
function GetTeamPlayers()return {1,2,3,4,5}end
function GetTeamMember(i)return heroes[i]end
function GetTower(_,id)return towers[id]end
function GetAncient()return {GetLocation=function()return team==2 and Vector(-10000,-10000)or Vector(10000,10000)end}end
function GetUnitToLocationDistance(h,loc)return dist(h.loc,loc)end
function GetUnitToUnitDistance(a,b)return dist(a.loc,b.loc)end
function GetLaneFrontAmount()return 0.5 end
function GetLaneFrontLocation(_,lane)return towers[lane].loc end
function GetAmountAlongLane(lane,loc)return {distance=dist(towers[lane].loc,loc),amount=0}end
function IsLocationPassable()return true end
local function hero(pos,lane,loc)
    local h={pos=pos,lane=lane,loc=loc,hp=0.9,mp=0.9,alive=true,mode=0,level=8,slots={},actions={}}
    function h:GetLocation()return self.loc end
    function h:GetAssignedLane()return self.lane end
    function h:GetActiveMode()return self.mode end
    function h:GetActiveModeDesire()return 0.8 end
    function h:GetUnitName()return self.name or 'npc_dota_hero_puck'end
    function h:GetHealth()return self.hp*1000 end
    function h:GetMaxHealth()return 1000 end
    function h:GetMana()return self.mp*1000 end
    function h:GetMaxMana()return 1000 end
    function h:GetTarget()return self.target end
    function h:GetAttackTarget()return nil end
    function h:GetTeam()return team end
    function h:IsHero()return not self.building end
    function h:IsNull()return false end
    function h:IsAlive()return self.alive end
    function h:IsIllusion()return self.illusion==true end
    function h:IsRooted()return false end
    function h:HasModifier()return false end
    function h:GetNearbyTowers()return {} end
    function h:GetLevel()return self.level end
    function h:WasRecentlyDamagedByAnyHero()return self.damaged==true end
    function h:WasRecentlyDamagedByTower()return self.towerDamage==true end
    function h:GetActualIncomingDamage(damage)return damage end
    function h:GetItemInSlot(i)return self.slots[i]end
    function h:GetAbilityByName()return self.teleportation end
    function h:DistanceFromFountain()return dist(self.loc,GetAncient():GetLocation())end
    function h:IsChanneling()return self.channeling==true end
    function h:GetCurrentActiveAbility()return self.currentAbility end
    function h:Action_ClearActions()self.cancelled=true end
    function h:Action_UseAbilityOnLocation(ability,loc)self.actions[#self.actions+1]={ability=ability,loc=loc}end
    function h:GetNetWorth()return 2000 end
    function h:GetCurrentMovementSpeed()return 300 end
    function h:GetNearbyHeroes(r,enemy)return J.GetNearbyHeroes(self,r,enemy)end
    h.ActionQueue_UseAbilityOnLocation=h.Action_UseAbilityOnLocation
    return h
end
local function near(list,loc,r)
    local out={};for _,h in ipairs(list)do if h.alive and dist(h.loc,loc)<=r then out[#out+1]=h end end;return out
end
J={Role={},Chat={GetNormName=function()return 'core'end}}
function J.IsModeTurbo()return turbo end
function J.GetPosition(h)return h.pos end
function J.IsValidHero(h)return h~=nil and h.alive and not h.building end
function J.IsSuspiciousIllusion(h)return h.illusion==true end
function J.GetHP(h)return h.hp end
function J.GetMP(h)return h.mp end
function J.IsCore(h)return h.pos<=3 end
function J.IsRetreating(h)return h.retreat==true end
function J.GetDistance(a,b)return dist(a,b)end
J.GetLocationToLocationDistance=J.GetDistance
function J.GetAlliesNearLoc(loc,r)return near(heroes,loc,r)end
function J.GetEnemiesNearLoc(loc,r)
    local out={};for _,h in ipairs(near(enemies,loc,r))do if not h.hidden then out[#out+1]=h end end;return out
end
function J.GetLastSeenEnemiesNearLoc(loc,r)
    local ids={};for i,h in ipairs(near(enemies,loc,r))do if not h.illusion and not h.stale then ids[#ids+1]=100+i end end;return ids
end
function J.GetNumOfAliveHeroes()local n=0;for _,h in ipairs(heroes)do if h.alive then n=n+1 end end;return n end
function J.IsInLaningPhase()return true end -- deliberately remains true after the hard cutoff
function J.IsDoingRoshan()return false end
function J.IsDoingTormentor()return false end
function J.CanNotUseAbility()return false end
function J.CanCastAbility(a)return a~=nil end
function J.IsAttacking()return false end
function J.IsGoingOnSomeone()return false end
function J.GetTeamFightLocation(h)return h.fightLocation end
function J.GetMostDefendLaneDesire()return LANE_BOT end
function J.GetCorrectLoc(h)return h.loc end
function J.SetQueuePtToINT()end
function J.IsStuck()return false end
function J.IsDefending(h)return h.mode>=4 and h.mode<=6 end
function J.IsPushing()return false end
function J.GetTeamFountain()return GetAncient():GetLocation()end
function J.GetProperTarget(h)return h.target end
function J.GetNearbyLocationToTp(loc)return loc end
function J.GetAllyCount(h,r)return math.max(0,#near(heroes,h.loc,r)-1)end
function J.GetNearbyHeroes(h,r,enemy)return enemy and J.GetEnemiesNearLoc(h.loc,r)or near(heroes,h.loc,r)end
function J.GetAttackProjectileDamageByRange()return 0 end
function J.IsItemAvailable()return nil end
function J.Role.CanBeSupport()return true end -- reproduce the old core-with-support-capable-hero defect
function J.Role.ShouldTpToDefend()return false end
function J.Role.ShouldTpToFarm()return false end
package.loaded['bots/FunLib/jmz_func']=J
local D=require('bots/FunLib/early_lane_defense')
local F=require('bots/FunLib/fight_response')
local factory=dofile('.test-tools/early-lane-defense-hooks.lua')
local prophetFactory=dofile('.test-tools/early-lane-prophet-hooks.lua')
local tp={GetName=function()return 'item_tpscroll'end,IsFullyCastable=function()return true end}
local function hooks(bot)
    return factory(bot,J,F,{ReturnTP=function()return nil end},D,{
        treads={ActionLocked=function(h)return h.channeling or h.queued end,PrepareItem=function()return false end},
        items={RestoreDesire=function()return 0 end},defendLocation=function(lane)return towers[lane].loc end})
end
local function reset(side)
    now,team,turbo=300,side or 2,false
    towers={ [1]=hero(0,1,Vector(-6000,5000)),[2]=hero(0,2,Vector(0,0)),[3]=hero(0,3,Vector(6000,-5000)) }
    for _,tower in pairs(towers)do tower.building=true;tower.hp=1 end
    local safe,off=team==2 and 3 or 1,team==2 and 1 or 3
    heroes={hero(1,safe,towers[safe].loc+Vector(100)),hero(2,2,Vector(100)),
        hero(3,off,towers[off].loc+Vector(100)),hero(4,off,GetAncient():GetLocation()),
        hero(5,safe,towers[safe].loc+Vector(-200))}
    heroes[1].hp=0.5;heroes[1].damaged=true
    local forward=team==2 and 1 or -1
    enemies={hero(0,safe,towers[safe].loc+Vector(1000*forward)),hero(0,safe,towers[safe].loc+Vector(1100*forward))}
end
local passed=0
local function test(name,fn)reset();fn();passed=passed+1;print('PASS '..name)end
test('pos 4 rescues pressured carry on both teams',function()
    for _,side in ipairs({2,3})do reset(side);local loc=F.TeleportLocation(heroes[4]);assert(loc)
        assert(F.CanTeleportTo(heroes[4],loc,'defense'))end
end)
test('all early cores stay in assigned lane despite support-capable names',function()
    for _,pos in ipairs({1,2,3})do local bot=heroes[pos];bot.loc=GetAncient():GetLocation()
        if pos==1 then bot.lane=LANE_MID;bot.hp=0.9 end
        assert(not F.TeleportLocation(bot))
        assert(not F.CanTeleportTo(bot,towers[heroes[1].lane==LANE_MID and LANE_BOT or heroes[1].lane].loc,'defense'))
    end
end)
test('pos 5 can rescue a solo offlaner while carry is safe',function()
    heroes[1].hp=0.9;heroes[1].damaged=false
    heroes[3].hp=0.5;heroes[3].damaged=true
    enemies={hero(0,1,towers[1].loc+Vector(1000)),hero(0,1,towers[1].loc+Vector(1100))}
    assert(F.TeleportLocation(heroes[5]))
end)
test('low home health blocks each support',function()
    heroes[3].hp=0.69;assert(not F.TeleportLocation(heroes[4]))
    assert(not D.HomeSafe(heroes[5]))
end)
test('recent home tower damage or retreat blocks departure',function()
    for _,field in ipairs({'towerDamage','retreat'})do reset();heroes[3][field]=true
        assert(not F.TeleportLocation(heroes[4]),field)end
end)
test('ordinary harass above 70 percent home HP permits rescue with low home mana',function()
    for _,hp in ipairs({0.9,0.75,0.7})do reset();heroes[3].hp=hp;heroes[3].mp=0.1;heroes[3].damaged=true
        assert(F.TeleportLocation(heroes[4]))end
    reset();heroes[1].hp=0.75;heroes[1].mp=0.1;heroes[1].damaged=true
    enemies={};assert(D.HomeSafe(heroes[5]))
end)
test('rapid home HP loss blocks rescue even above 70 percent',function()
    assert(D.HomeSafe(heroes[4]));now=now+1.5;heroes[3].hp=0.74;heroes[3].damaged=true
    assert(not F.TeleportLocation(heroes[4]))
end)
test('old HP samples cannot turn gradual attrition into rapid pressure',function()
    assert(D.HomeSafe(heroes[4]));now=now+5;heroes[3].hp=0.74;heroes[3].damaged=true
    assert(F.TeleportLocation(heroes[4]))
end)
test('home core would be outnumbered after support leaves',function()
    enemies[#enemies+1]=hero(0,1,heroes[3].loc+Vector(100))
    enemies[#enemies+1]=hero(0,1,heroes[3].loc+Vector(200))
    assert(not D.HomeSafe(heroes[4]))
end)
test('one opponent and healthy solo home core can be safe',function()
    enemies[#enemies+1]=hero(0,1,heroes[3].loc+Vector(100))
    assert(D.HomeSafe(heroes[4]))
end)
test('numeric last-seen player IDs still protect home core in fog',function()
    for _,x in ipairs({100,200})do local e=hero(0,1,heroes[3].loc+Vector(x));e.hidden=true;enemies[#enemies+1]=e end
    assert(not D.HomeSafe(heroes[4]))
    for _,e in ipairs(enemies)do if e.hidden then e.stale=true end end
    assert(D.HomeSafe(heroes[4]))
end)
test('missing or dead home partner is not a safe lane',function()
    heroes[3].alive=false;assert(not D.HomeSafe(heroes[4]))
    heroes[3]=nil;assert(not D.HomeSafe(heroes[4]))
end)
test('healthy carry taking no damage does not trigger cross-lane rescue',function()
    heroes[1].hp=0.9;heroes[1].damaged=false;assert(not F.TeleportLocation(heroes[4]))
end)
test('single harmless harass hit does not trigger a rescue',function()
    heroes[1].hp=0.9;enemies={enemies[1]};assert(not F.TeleportLocation(heroes[4]))
end)
test('carry rescue outranks a mid dive',function()
    heroes[2].hp=0.5;heroes[2].damaged=true;enemies[#enemies+1]=hero(0,2,Vector(1000))
    local loc=F.TeleportLocation(heroes[4]);assert(loc and dist(loc,towers[3].loc)<1800)
end)
test('unknown pressure or illusions do not justify a rescue',function()
    for _,e in ipairs(enemies)do e.illusion=true end;assert(not F.TeleportLocation(heroes[4]))
end)
test('carry too far from allied tower does not trigger tower rescue',function()
    heroes[1].loc=towers[3].loc+Vector(2000);assert(not F.TeleportLocation(heroes[4]))
end)
test('safe own-lane mid return remains allowed',function()
    assert(F.CanTeleportTo(heroes[2],towers[2].loc,'defense'))
end)
test('local defense desire is not suppressed by remote-role policy',function()
    heroes[2].loc=towers[3].loc+Vector(200)
    assert(F.DefendDesire(heroes[2],LANE_BOT,0.9)==0.9)
end)
test('foreign outer defense desire is suppressed for mid and offlane cores',function()
    assert(F.DefendDesire(heroes[2],LANE_BOT,0.9)==0)
    assert(F.DefendDesire(heroes[3],LANE_BOT,0.9)==0)
end)
test('base defense is available for cores',function()
    towers[9]=hero(0,3,Vector(-9000,-9000));towers[9].building=true
    assert(F.CanTeleportTo(heroes[2],towers[9].loc,'defense'))
    assert(F.CanTeleportTo(heroes[3],GetAncient():GetLocation(),'defense'))
end)
test('foreign creep landing cannot bypass defensive position gate',function()
    assert(not F.CanTeleportTo(heroes[2],Vector(3000,-3000),'defense'))
end)
test('unrelated gank and escape destinations retain existing rules',function()
    assert(F.CanTeleportTo(heroes[2],Vector(3000,-3000),'gank'))
    assert(F.CanTeleportTo(heroes[2],GetAncient():GetLocation(),'escape'))
end)
test('fight reinforcement at allied tower cannot bypass defense restriction',function()
    assert(not F.CanTeleportTo(heroes[2],towers[3].loc,'fight'))
    assert(F.CanTeleportTo(heroes[4],towers[3].loc,'fight'))
end)
test('hard normal cutoff does not inherit extended laning heuristic',function()
    now=599.99;assert(not F.CanTeleportTo(heroes[2],towers[3].loc,'defense'))
    now=600;assert(F.CanTeleportTo(heroes[2],towers[3].loc,'defense'))
end)
test('Turbo policy expires at eight minutes',function()
    turbo=true;now=479.99;assert(not F.CanTeleportTo(heroes[3],towers[3].loc,'defense'))
    now=480;assert(F.CanTeleportTo(heroes[3],towers[3].loc,'defense'))
end)
test('final item execution revalidates newly unsafe home core',function()
    local bot=heroes[4];local loc=F.TeleportLocation(bot);assert(loc)
    now=now+1;heroes[3].hp=0.74;heroes[3].damaged=true
    assert(hooks(bot).SetUseItem(tp,loc,'ground','defense')==false)
    assert(#bot.actions==0 and not bot.ohaDefenseTP)
end)
test('final item execution records purpose and preserves destination',function()
    local bot=heroes[4];local loc=F.TeleportLocation(bot);assert(loc)
    hooks(bot).SetUseItem(tp,loc,'ground','defense')
    assert(#bot.actions==1 and bot.actions[1].loc==loc and bot.ohaDefenseTP.purpose=='defense')
end)
test('changed home threat cancels an in-flight defensive TP only',function()
    local bot=heroes[4];local loc=F.TeleportLocation(bot);F.RecordTeleport(bot,loc,'defense')
    bot.channeling=true;bot.currentAbility=tp;now=now+1;heroes[3].hp=0.74;heroes[3].damaged=true
    assert(F.CancelUnsafeTeleport(bot) and bot.cancelled)
end)
test('single ordinary home poke does not cancel an in-flight rescue',function()
    local bot=heroes[4];local loc=F.TeleportLocation(bot);F.RecordTeleport(bot,loc,'defense')
    bot.channeling=true;bot.currentAbility=tp;now=now+1;heroes[3].hp=0.85;heroes[3].damaged=true
    assert(not F.CancelUnsafeTeleport(bot) and not bot.cancelled)
end)
test('lost fight and unsafe landing still prohibit support rescue',function()
    enemies[#enemies+1]=hero(0,3,towers[3].loc+Vector(1100));enemies[#enemies+1]=hero(0,3,towers[3].loc+Vector(1150))
    assert(not F.TeleportLocation(heroes[4]))
    reset();enemies[#enemies+1]=hero(0,3,towers[3].loc+Vector(-300));assert(not F.TeleportLocation(heroes[4]))
end)
test('legacy defend-ally TP is blocked for actual pos 2 and pos 3',function()
    local proactive=F.TeleportLocation;F.TeleportLocation=function()return nil end
    for _,pos in ipairs({2,3})do local bot=heroes[pos];bot.loc=GetAncient():GetLocation();bot.mode=BOT_MODE_DEFEND_ALLY;bot.target=heroes[1]
        assert(hooks(bot).ConsiderItemDesire.item_tpscroll(tp)==0)
    end
    F.TeleportLocation=proactive
end)
test('legacy ally-save path permits pos 4 with a safe offlaner',function()
    local proactive=F.TeleportLocation;F.TeleportLocation=function()return nil end
    local bot=heroes[4];bot.mode=BOT_MODE_DEFEND_ALLY;bot.target=heroes[1]
    local desire,loc,kind,_,purpose=hooks(bot).ConsiderItemDesire.item_tpscroll(tp)
    assert(desire>0 and dist(loc,heroes[1].loc)==0)
    assert(kind=='ground' and purpose=='defense')
    F.TeleportLocation=proactive
end)
test('legacy tower TP cannot override core role but own mid return works',function()
    local proactive=F.TeleportLocation;F.TeleportLocation=function()return nil end
    local bot=heroes[2];bot.loc=GetAncient():GetLocation();bot.mode=BOT_MODE_DEFEND_TOWER_BOT
    assert(hooks(bot).ConsiderItemDesire.item_tpscroll(tp)==0)
    bot.mode=BOT_MODE_DEFEND_TOWER_MID
    local desire,_,_,_,purpose=hooks(bot).ConsiderItemDesire.item_tpscroll(tp)
    assert(desire>0 and purpose=='defense')
    F.TeleportLocation=proactive
end)
test('legacy retreat TP is preserved for mid',function()
    local bot=heroes[2];bot.loc=towers[1].loc;bot.mode=BOT_MODE_RETREAT;bot.hp=0.1
    local desire,loc=hooks(bot).ConsiderItemDesire.item_tpscroll(tp)
    assert(desire>0 and dist(loc,GetAncient():GetLocation())==0)
end)
test('Prophet request carries the defensive purpose for later revalidation',function()
    local proactive=F.TeleportLocation;F.TeleportLocation=function()return nil end
    local bot=heroes[4];bot.name='npc_dota_hero_furion';bot.mode=BOT_MODE_DEFEND_ALLY;bot.target=heroes[1]
    bot.teleportation={IsTrained=function()return true end,IsFullyCastable=function()return true end}
    assert(hooks(bot).ConsiderItemDesire.item_tpscroll(tp)==0)
    assert(bot.useProphetTP and bot.ProphetTPPurpose=='defense')
    heroes[3].towerDamage=true
    assert(not F.CanTeleportTo(bot,bot.ProphetTPLocation,bot.ProphetTPPurpose))
    F.TeleportLocation=proactive
end)
local function prophet(bot)
    bot.teleportation={GetName=function()return 'furion_teleportation'end,GetCastPoint=function()return 3 end}
    return prophetFactory(bot,J,F)
end
test('actual Prophet external execution rejects newly threatened home core',function()
    local bot=heroes[4];bot.useProphetTP=true;bot.ProphetTPLocation=towers[3].loc;bot.ProphetTPPurpose='defense'
    heroes[3].towerDamage=true;prophet(bot).SkillsComplement()
    assert(#bot.actions==0 and not bot.useProphetTP and bot.ProphetTPPurpose==nil)
end)
test('actual Prophet external execution records a permitted support rescue',function()
    local bot=heroes[4];bot.useProphetTP=true;bot.ProphetTPLocation=towers[3].loc;bot.ProphetTPPurpose='defense'
    prophet(bot).SkillsComplement()
    assert(#bot.actions==1 and bot.ohaDefenseTP.purpose=='defense' and not bot.useProphetTP)
end)
test('actual Prophet native defense cannot send mid or offlane cores across lanes',function()
    for _,role in ipairs({2,3})do reset();local bot=heroes[role];bot.loc=GetAncient():GetLocation();bot.mode=BOT_MODE_DEFEND_TOWER_BOT
        prophet(bot).SkillsComplement();assert(#bot.actions==0)end
end)
test('actual Prophet native defense permits support with safe home core',function()
    local bot=heroes[4];bot.mode=BOT_MODE_DEFEND_TOWER_BOT;prophet(bot).SkillsComplement()
    assert(#bot.actions==1 and bot.ohaDefenseTP.purpose=='defense')
end)
test('actual Prophet native teamfight at own tower remains a defensive rescue',function()
    local bot=heroes[4];bot.fightLocation=towers[3].loc;prophet(bot).SkillsComplement()
    assert(#bot.actions==1 and bot.ohaDefenseTP.purpose=='defense')
    reset();bot=heroes[4];bot.fightLocation=towers[3].loc;heroes[3].towerDamage=true
    prophet(bot).SkillsComplement();assert(#bot.actions==0)
end)
print(passed..' early lane defense scenarios passed')
