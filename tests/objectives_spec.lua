-- Run with Lua 5.1+ (or fengari). Engine calls are stubbed; gameplay still needs a lobby test.
package.path = './?.lua;'..package.path
TEAM_RADIANT, TEAM_DIRE = 2, 3
LANE_TOP, LANE_MID, LANE_BOT = 1, 2, 3
TOWER_TOP_2, TOWER_MID_2, TOWER_BOT_2 = 4, 5, 6
TOWER_TOP_3, TOWER_MID_3, TOWER_BOT_3 = 7, 8, 9
local now, team, heroes, enemies, threats, neutral, roshanAlive, advantage, baseThreat
local function vector(x,y,z) return { x=x, y=y, z=z or 0 } end
Vector = vector
local function distance(a,b) return math.sqrt((a.x-b.x)^2+(a.y-b.y)^2) end
function GetScriptDirectory() return 'bots' end
function DotaTime() return now end
GameTime = DotaTime
function GetTeam() return team end
function GetOpposingTeam() return team == 2 and 3 or 2 end
function GetTeamPlayers() return {0,1,2,3,4} end
function GetTeamMember(i) return heroes[i] end
function GetUnitToLocationDistance(h,loc) return distance(h.loc,loc) end
function GetUnitToUnitDistance(a,b) return distance(a.loc,b.loc) end
function IsLocationVisible() return true end
function GetTower() return nil end
function GetAncient() return {GetLocation=function() return Vector(0,0) end} end
function GetLaneFrontLocation(_,lane,offset) return Vector(3000,lane*1000+(offset or 0)) end

local J = {}
function J.IsValidHero(h) return h ~= nil and h.hero end
function J.IsValid(h) return h ~= nil and h.alive end
function J.CanNotUseAction(h) return h.casting or false end
function J.IsMeepoClone(h) return h.clone or false end
function J.GetHP(h) return h.hp end
function J.GetPosition(h) return h.pos end
J.GetDistance = distance
function J.IsCore(h) return h.pos <= 3 end
function J.IsInTeamFight(h) return h.fighting end
function J.GetLastSeenEnemiesNearLoc(loc)
    if baseThreat and loc.x == 0 then return {1} end
    if threats then return {1,2,3,4,5} end
    return {}
end
function J.GetEnemiesNearLoc() return threats and {1} or {} end
function J.GetAlliesNearLoc(loc,radius)
    local result = {}
    for _,h in ipairs(heroes) do if h.alive and distance(h.loc,loc) <= radius then table.insert(result,h) end end
    return result
end
function J.GetNumOfAliveHeroes(enemy)
    if enemy then return enemies end
    local count = 0
    for _,h in ipairs(heroes) do if h.alive then count=count+1 end end
    return count
end
function J.IsModeTurbo() return false end
function J.GetTormentorLocation() return Vector(7744,-6208,64) end
function J.GetCurrentRoshanLocation() return Vector(3000,-2800) end
function J.IsRoshanAlive() return roshanAlive end
function J.IsRoshanCloseToChangingSides() return false end
function J.HasEnoughDPSForRoshan() return true end
function J.GetInventoryNetworth() return advantage and 70000 or 40000, 50000 end
function J.DoesTeamHaveAegis() return false end
function J.ModeAnnounce(h) h.announcements = (h.announcements or 0)+1 end
function J.IsRoshan(h) return h.kind == 'roshan' end
function J.IsTormentor(h) return h.kind == 'tormentor' end
package.loaded['bots/FunLib/jmz_func'] = J
local O = require('bots/FunLib/objectives')
local Locations = require('bots/FunLib/objective_locations')

local function hero(id,pos,human)
    local h = {id=id,pos=pos,human=human,hp=1,alive=true,hero=true,loc=Vector(0,0),items={},level=15}
    function h:IsAlive() return self.alive end
    function h:IsIllusion() return self.illusion or false end
    function h:HasModifier() return false end
    function h:IsBot() return not self.human end
    function h:WasRecentlyDamagedByAnyHero() return self.damaged or false end
    function h:WasRecentlyDamagedByTower() return false end
    function h:GetLocation() return self.loc end
    function h:GetPlayerID() return self.id end
    function h:GetUnitName() return 'hero_'..self.id end
    function h:GetCurrentMovementSpeed() return 300 end
    function h:GetLevel() return self.level end
    function h:GetItemInSlot(slot) return self.items[slot] end
    function h:GetNearbyNeutralCreeps() return neutral and distance(self.loc,neutral.loc)<1600 and {neutral} or {} end
    function h:Action_MoveToLocation(loc) self.action='move';self.destination=loc end
    function h:Action_ClearActions() self.action='wait' end
    function h:Action_AttackUnit(target) self.action='attack';self.target=target;self.attackTarget=target;self.attacks=(self.attacks or 0)+1 end
    function h:GetAttackTarget() return self.attackTarget end
    function h:SetTarget(target) self.target=target end
    function h:ActionImmediate_Ping() self.pings=(self.pings or 0)+1 end
    return h
end
local function reset(time)
    now,team,enemies,threats,neutral,roshanAlive,advantage,baseThreat = time or 0,2,5,false,nil,false,false,false
    heroes={}
    for i=1,5 do heroes[i]=hero(i,i,i==1) end
end
local passed=0
local function test(name,fn)
    reset()
    fn()
    passed=passed+1
    print('PASS '..name)
end
local function equal(a,b) assert(a==b,tostring(a)..' ~= '..tostring(b)) end
local function near(h,loc,offset) h.loc=Vector(loc.x+(offset or 0),loc.y,loc.z) end
local function tick(h,seconds)
    for _=1,seconds*2 do now=now+0.5; O.CollectionDesire(h); O.CollectionThink(h) end
end
test('lotus travel starts before minute three',function()
    now=173; near(heroes[5],Locations.lotus.bot,1000)
    assert(O.CollectionDesire(heroes[5])>0)
    O.CollectionThink(heroes[5]); equal(heroes[5].action,'move')
end)
test('no premature lotus camping',function()
    now=150; near(heroes[5],Locations.lotus.bot,1000)
    equal(O.CollectionDesire(heroes[5]),0)
end)
test('only one collector per pool',function()
    now=180; near(heroes[4],Locations.lotus.bot,400); near(heroes[5],Locations.lotus.bot,600)
    assert(O.CollectionDesire(heroes[4])>0)
    equal(O.CollectionDesire(heroes[5]),0)
end)
test('empty pool times out and next spawn is retried',function()
    now=180; local h=heroes[5]; near(h,Locations.lotus.bot)
    assert(O.CollectionDesire(h)>0); O.CollectionThink(h); tick(h,4)
    equal(O.CollectionDesire(h),0)
    now=360; assert(O.CollectionDesire(h)>0)
end)
test('full inventory excludes lotus collector',function()
    now=180;local h=heroes[5];near(h,Locations.lotus.bot)
    for i=0,8 do h.items[i]={} end
    equal(O.CollectionDesire(h),0)
end)
test('wisdom prefers bot support over closer human core',function()
    now=410;near(heroes[1],Locations.wisdom[2],500);near(heroes[5],Locations.wisdom[2],3000)
    assert(O.CollectionDesire(heroes[5])>0)
    equal(heroes[5].ohaCollection.kind,'wisdom')
end)
test('Dire secures bottom wisdom',function()
    team=3;now=420;near(heroes[4],Locations.wisdom[3])
    assert(O.CollectionDesire(heroes[4])>0)
    equal(heroes[4].ohaCollection.loc,Locations.wisdom[3])
end)
test('collector death allows reassignment',function()
    now=420;near(heroes[4],Locations.wisdom[2],500);near(heroes[5],Locations.wisdom[2],1000)
    assert(O.CollectionDesire(heroes[4])>0);heroes[4].alive=false
    assert(O.CollectionDesire(heroes[5])>0)
end)
test('human physically collecting releases bot claim',function()
    now=420;near(heroes[5],Locations.wisdom[2],500)
    assert(O.CollectionDesire(heroes[5])>0)
    near(heroes[1],Locations.wisdom[2]);equal(O.CollectionDesire(heroes[5]),0)
end)
test('arrival does not immediately mark wisdom collected',function()
    now=420;local h=heroes[5];near(h,Locations.wisdom[2])
    O.CollectionDesire(h);O.CollectionThink(h);tick(h,2)
    assert(O.CollectionDesire(h)>0);tick(h,3)
    equal(O.CollectionDesire(h),0)
end)
test('interrupted collection restarts countdown',function()
    now=420;local h=heroes[5];near(h,Locations.wisdom[2])
    O.CollectionDesire(h);O.CollectionThink(h);tick(h,2)
    now=now+3;O.CollectionDesire(h);O.CollectionThink(h);tick(h,2)
    assert(O.CollectionDesire(h)>0)
end)
test('danger yields to survival',function()
    now=420;near(heroes[5],Locations.wisdom[2]);threats=true
    equal(O.CollectionDesire(heroes[5]),0)
end)
test('base threat prevents collection',function()
    now=420;near(heroes[5],Locations.wisdom[2]);baseThreat=true
    equal(O.CollectionDesire(heroes[5]),0)
end)
test('illusion never collects',function()
    now=420;near(heroes[5],Locations.wisdom[2]);heroes[5].illusion=true
    equal(O.CollectionDesire(heroes[5]),0)
end)
local function bossSetup(kind)
    now=1250;local loc=kind=='tormentor' and J.GetTormentorLocation() or J.GetCurrentRoshanLocation()
    for i=2,5 do near(heroes[i],loc,1500+i*50) end
    neutral={kind=kind,loc=loc,alive=true,GetLocation=function(self)return self.loc end,IsAlive=function(self)return self.alive end,IsNull=function()return false end}
    if kind=='roshan' then
        now=1850;roshanAlive=true
        -- Tormentor is on the other side of the map and unavailable to this group.
        heroes[2].level=10
    end
    return loc
end
test('four bots assemble for Tormentor without human ping',function()
    bossSetup('tormentor');local p=O.GetPlan(heroes[2])
    equal(p.kind,'tormentor');equal(p.participants[1],nil)
    O.PlanThink(heroes[2],'tormentor');equal(heroes[2].action,'move')
end)
test('Tormentor waits for group and attacks with four including two cores',function()
    local loc=bossSetup('tormentor');O.GetPlan(heroes[2]);near(heroes[2],loc)
    O.PlanThink(heroes[2],'tormentor');equal(heroes[2].action,'wait')
    for i=3,5 do near(heroes[i],loc,500) end
    O.PlanThink(heroes[2],'tormentor');equal(heroes[2].action,'attack')
end)
test('boss announcements only happen in Think and once per plan',function()
    bossSetup('tormentor');local h=heroes[2];O.GetPlan(h);equal(h.announcements,nil)
    O.PlanThink(h,'tormentor');O.PlanThink(h,'tormentor');equal(h.announcements,1)
end)
test('assembly timeout prevents endless waiting',function()
    bossSetup('tormentor');local h=heroes[2];assert(O.GetPlan(h))
    now=now+61;equal(O.GetPlan(h),nil)
end)
test('dead participant cancels unsafe boss attempt',function()
    bossSetup('tormentor');local h=heroes[2];assert(O.GetPlan(h))
    heroes[5].alive=false;now=now+1;equal(O.GetPlan(h),nil)
end)
test('Roshan has movement and attack execution',function()
    local loc=bossSetup('roshan');local h=heroes[2]
    equal(O.GetPlan(h).kind,'roshan');O.PlanThink(h,'roshan');equal(h.action,'move')
    for i=2,5 do near(heroes[i],loc,500) end
    O.PlanThink(h,'roshan');equal(h.action,'attack')
end)
test('won fight chooses shared push lane instead of boss',function()
    bossSetup('tormentor');enemies=2
    local p=O.GetPlan(heroes[2]);equal(p.kind,'push')
    equal(O.GetPlan(heroes[5]),p)
    assert(O.PlanDesire(heroes[2],'push',p.lane)>0)
    equal(O.PlanDesire(heroes[2],'push',p.lane%3+1),0)
end)
test('push assembles before handing off building micro',function()
    now=1100;enemies=2;local h=heroes[2];local p=O.GetPlan(h)
    equal(O.PlanThink(h,'push'),true);equal(h.action,'move')
    for i=2,5 do near(heroes[i],p.loc) end
    equal(O.PlanThink(h,'push'),false);equal(h.laneToPush,p.lane)
end)
test('enemy respawns end powerplay commitment',function()
    now=1100;enemies=2;local h=heroes[2];assert(O.GetPlan(h))
    now=1101;enemies=5;equal(O.GetPlan(h),nil)
end)
test('routine farming yields but emergency desire survives',function()
    now=1100;enemies=2;local h=heroes[2];assert(O.GetPlan(h))
    equal(O.CapRoutineDesire(h,0.98),0.45)
    equal(O.CapRoutineDesire(h,1.1),1.1)
    h.damaged=true;equal(O.CapRoutineDesire(h,0.98),0.98)
end)
test('base defense cancels push',function()
    now=1100;enemies=2;local h=heroes[2];assert(O.GetPlan(h))
    now=1101;baseThreat=true;equal(O.GetPlan(h),nil)
end)
test('Tormentor prefers all five before allowing four',function()
    local loc=bossSetup('tormentor');near(heroes[1],loc,1800)
    local h=heroes[2];equal(O.GetPlan(h).preferred,5)
    for i=2,5 do near(heroes[i],loc,500) end
    O.PlanThink(h,'tormentor');equal(h.action,'move')
    now=now+21;O.PlanThink(h,'tormentor');equal(h.action,'attack')
end)
test('nearby human core anchors regroup without needing a ping',function()
    now=1250
    for i=1,5 do heroes[i].loc=Vector(-6000+i*1200,1000);heroes[i].level=7 end
    local h=heroes[5];local p=O.GetPlan(h)
    equal(p.kind,'regroup');equal(p.anchor,heroes[1]);equal(O.GetPlan(heroes[1]),nil)
    O.PlanThink(h,'regroup');equal(h.action,'move')
    for i=2,5 do near(heroes[i],heroes[1].loc) end
    O.PlanThink(h,'regroup');equal(O.GetPlan(h),nil)
end)
test('late push participant rejoins teammates instead of walking alone',function()
    now=1100;enemies=2;local h=heroes[2];local p=O.GetPlan(h)
    for i=2,4 do near(heroes[i],p.loc) end
    O.PlanThink(h,'push');equal(p.phase,'execute')
    heroes[5].loc=Vector(-5000,-5000)
    equal(O.PlanThink(heroes[5],'push'),true);equal(heroes[5].action,'move')
end)
test('stalled collection lease backs off before reassigning',function()
    now=420;local h=heroes[5];near(h,Locations.wisdom[2],500)
    assert(O.CollectionDesire(h)>0);now=466
    equal(O.CollectionDesire(h),0);now=482
    assert(O.CollectionDesire(h)>0)
end)
test('contested timer never completes a wisdom visit',function()
    now=420;local h=heroes[5];near(h,Locations.wisdom[2]);O.CollectionDesire(h);O.CollectionThink(h)
    local c=h.ohaCollection
    now=422;threats=true;O.CollectionThink(h)
    equal(c.serviced,nil);equal(c.arrived,nil)
end)
test('boss death stops attacking and starts respawn backoff',function()
    local loc=bossSetup('tormentor');local h=heroes[2];O.GetPlan(h)
    for i=2,5 do near(heroes[i],loc) end
    O.PlanThink(h,'tormentor');neutral.alive=false;neutral=nil
    O.PlanThink(h,'tormentor');equal(O.GetPlan(h),nil)
    assert(heroes[1].ohaObjectives.tormentorNext>now+500)
end)
test('human mid also leaves bot supports responsible for wisdom',function()
    heroes[1].human=false;heroes[2].human=true
    now=420;near(heroes[2],Locations.wisdom[2],400);near(heroes[4],Locations.wisdom[2],1000)
    assert(O.CollectionDesire(heroes[4])>0)
    equal(heroes[4].ohaCollection.owner,heroes[4])
end)
test('regroup cancels when its human anchor dies',function()
    now=1250
    for i=1,5 do heroes[i].loc=Vector(-6000+i*1200,1000);heroes[i].level=7 end
    assert(O.GetPlan(heroes[5]))
    heroes[1].alive=false;enemies=4;now=1251
    equal(O.GetPlan(heroes[5]),nil)
end)
test('bot core is a fallback when supports cannot collect',function()
    now=420;heroes[4].alive=false;heroes[5].alive=false
    near(heroes[3],Locations.wisdom[2],1000)
    assert(O.CollectionDesire(heroes[3])>0)
end)
test('actual lotus pickup extends inspection to collect the next lotus',function()
    now=180;local h=heroes[5];near(h,Locations.lotus.bot)
    O.CollectionDesire(h);O.CollectionThink(h);tick(h,2)
    h.items[0]={GetName=function()return 'item_famango' end,GetCurrentCharges=function()return 1 end}
    tick(h,2);assert(O.CollectionDesire(h)>0)
    tick(h,2);equal(O.CollectionDesire(h),0)
end)
test('late lotus check does not cause a lane detour',function()
    now=270;near(heroes[5],Locations.lotus.bot,1000)
    equal(O.CollectionDesire(heroes[5]),0)
    near(heroes[5],Locations.lotus.bot,100)
    assert(O.CollectionDesire(heroes[5])>0)
end)
test('normal lineup does not initiate Roshan at minute 22',function()
    bossSetup('roshan');now=1320
    local p=O.GetPlan(heroes[2]);assert(not p or p.kind~='roshan')
end)
test('boss attack orders are not reissued each frame',function()
    local loc=bossSetup('roshan');local h=heroes[2];O.GetPlan(h)
    for i=2,5 do near(heroes[i],loc,500) end
    O.PlanThink(h,'roshan');O.PlanThink(h,'roshan');equal(h.attacks,1)
end)
test('committed boss group continues below starting health',function()
    local loc=bossSetup('roshan');local h=heroes[2];O.GetPlan(h)
    for i=2,5 do near(heroes[i],loc,500) end
    O.PlanThink(h,'roshan')
    for i=2,5 do heroes[i].hp=0.5 end
    now=now+1;assert(O.GetPlan(h));O.PlanThink(h,'roshan');equal(h.attacks,1)
end)
test('boss mode does not interrupt a spell',function()
    local loc=bossSetup('roshan');local h=heroes[2];O.GetPlan(h)
    for i=2,5 do near(heroes[i],loc,500) end
    h.casting=true;O.PlanThink(h,'roshan');equal(h.attacks,nil)
end)
test('chased participant prevents cached-plan announcement',function()
    bossSetup('roshan');local h=heroes[2];assert(O.GetPlan(h))
    heroes[5].damaged=true;O.PlanThink(h,'roshan');equal(h.announcements,nil)
    equal(heroes[1].ohaObjectives.plan,nil)
end)
test('early Ursa option is opt-in and requires a participating Ursa',function()
    bossSetup('roshan');now=1320
    local settings=require('bots/FunLib/objective_settings')
    settings.AllowEarlyRoshan=true
    heroes[2].GetUnitName=function() return 'npc_dota_hero_ursa' end
    equal(O.GetPlan(heroes[2]).kind,'roshan')
    settings.AllowEarlyRoshan=false
end)
print(passed..' objective scenarios passed')
