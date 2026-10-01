package.path='./?.lua;'..package.path
LANE_TOP,LANE_MID,LANE_BOT=1,2,3
TOWER_TOP_1,TOWER_MID_1,TOWER_BOT_1,TOWER_TOP_2,TOWER_MID_2,TOWER_BOT_2,TOWER_TOP_3,TOWER_MID_3,TOWER_BOT_3=1,2,3,4,5,6,7,8,9
local now,heroes,enemies,towers,creeps,laning,visible
local V={}
function Vector(x,y)return setmetatable({x=x,y=y or 0},V)end
V.__add=function(a,b)return Vector(a.x+b.x,a.y+b.y)end
V.__sub=function(a,b)return Vector(a.x-b.x,a.y-b.y)end
V.__mul=function(a,b)return Vector(a.x*b,a.y*b)end
V.__index={Normalized=function(a)local d=math.sqrt(a.x*a.x+a.y*a.y);return Vector(a.x/d,a.y/d)end}
local function dist(a,b)return math.sqrt((a.x-b.x)^2+(a.y-b.y)^2)end
function GetScriptDirectory()return 'bots'end
function DotaTime()return now end
function GetTeam()return 2 end
function GetOpposingTeam()return 3 end
function GetTeamPlayers()return {1,2,3,4,5}end
function GetTeamMember(i)return heroes[i]end
function GetTower(team,id)return towers[team][id]end
function GetUnitToLocationDistance(h,loc)return dist(h.loc,loc)end
function GetUnitToUnitDistance(a,b)return dist(a.loc,b.loc)end
function GetLaneFrontLocation(_,lane,offset)return Vector((lane-2)*5000,offset or 0)end
function GetAncient()return {GetLocation=function()return Vector(-10000,-10000)end}end
local function unit(x,y)
    local h={loc=Vector(x,y),hp=1,alive=true,lane=LANE_BOT,pos=4}
    function h:GetLocation()return self.loc end
    function h:IsAlive()return self.alive end
    function h:IsIllusion()return false end
    function h:IsInvulnerable()return false end
    function h:GetAssignedLane()return self.lane end
    function h:GetActiveMode()return 0 end
    function h:WasRecentlyDamagedByTower()return false end
    function h:WasRecentlyDamagedByAnyHero()return self.damaged end
    function h:IsChanneling()return self.channeling end
    function h:GetCurrentActiveAbility()return self.ability end
    function h:Action_ClearActions()self.cancelled=true;self.channeling=false end
    function h:GetNearbyLaneCreeps()return creeps end
    function h:Action_MoveToLocation(loc)self.destination=loc end
    return h
end
local function near(list,loc,radius)
    local result={}
    for _,h in ipairs(list)do if h.alive and dist(h.loc,loc)<radius then table.insert(result,h)end end
    return result
end
local J={Utils={}}
J.GetDistance=dist
function J.GetHP(h)return h.hp end
function J.GetMP()return 1 end
function J.IsValidHero(h)return h~=nil end
function J.IsCore(h)return h.pos<=3 end
function J.IsInLaningPhase()return laning end
function J.IsModeTurbo()return false end
function J.GetPosition(h)return h.pos end
function J.IsSuspiciousIllusion()return false end
function J.IsRetreating()return false end
function J.CanNotUseAction(h)return h.channeling end
function J.GetAlliesNearLoc(loc,radius)return near(heroes,loc,radius)end
function J.GetEnemiesNearLoc(loc,radius)return visible and near(enemies,loc,radius)or {}end
function J.GetLastSeenEnemiesNearLoc(loc,radius)return near(enemies,loc,radius)end
function J.GetNumOfAliveHeroes()local n=0;for _,h in ipairs(heroes)do if h.alive then n=n+1 end end;return n end
function J.GetTeamFountain()return Vector(-10000,-10000)end
function J.Utils.GetOffsetLocationTowardsTargetLocation(a,b,d)return a+(b-a):Normalized()*d end
function J.GetNearbyLocationToTp(loc)return loc end
package.loaded['bots/FunLib/jmz_func']=J
local F=require('bots/FunLib/fight_response')
local R=require('bots/FunLib/lane_rotation')
local passed=0
local function reset()
    now,laning,visible=470,true,true
    heroes={unit(-5000),unit(5000),unit(5100),unit(-8000),unit(-8500)}
    heroes[1].lane=LANE_TOP
    heroes[4].lane=LANE_TOP;heroes[4].pos=3 -- A safe home core exists for the support's bounded push.
    enemies={unit(5000,500),unit(5100,500)}
    towers={[2]={[TOWER_BOT_1]=unit(5000),[TOWER_TOP_1]=unit(-5000)},[3]={}}
    creeps={}
end
local function test(name,fn)reset();fn();passed=passed+1;print('PASS '..name)end
local function arrive()
    local h=heroes[1]
    F.RecordTeleport(h,Vector(5000));assert(h.ohaLaneRotation)
    now=471;h.loc=Vector(5000);R.Get(h)
    enemies={};now=481
    return h
end
test('outer tower permits a viable reinforcement',function()
    assert(F.CanTeleportTo(heroes[1],Vector(5000)))
end)
test('three dead teammates block a solo TP into three attackers',function()
    heroes[2].alive=false;heroes[3].alive=false;heroes[4].alive=false
    enemies[3]=unit(4900,500)
    assert(not F.CanTeleportTo(heroes[1],Vector(5000)))
end)
test('last seen attackers still block an unsafe TP after entering fog',function()
    heroes[2].alive=false;heroes[3].alive=false;enemies[3]=unit(4900,500);visible=false
    assert(not F.CanTeleportTo(heroes[1],Vector(5000)))
end)
test('lost defense cooldown does not count a new TP as a regroup',function()
    local h=heroes[1];assert(F.CanTeleportTo(h,Vector(5000)))
    heroes[2].alive=false;heroes[3].alive=false;heroes[4].loc=Vector(5000)
    now=471;assert(not F.CanTeleportTo(h,Vector(5000)))
    now=500;assert(not F.CanTeleportTo(h,Vector(5000)))
    now=507;assert(F.CanTeleportTo(h,Vector(5000)))
end)
test('physical regroup can reopen a lost defense',function()
    F.CanTeleportTo(heroes[1],Vector(5000));heroes[2].alive=false;heroes[3].alive=false
    assert(not F.CanTeleportTo(heroes[1],Vector(5000)))
    heroes[4].loc=Vector(5000);heroes[5].loc=Vector(5100)
    assert(F.CanTeleportTo(heroes[1],Vector(5000)))
end)
test('pending arrivals prevent redundant fourth defender',function()
    F.RecordTeleport(heroes[1],Vector(5000))
    assert(not F.CanTeleportTo(heroes[4],Vector(5000)))
    now=479;assert(F.CanTeleportTo(heroes[4],Vector(5000)))
end)
test('outer tower defend desire yields when outnumbered',function()
    heroes[2].alive=false;heroes[3].alive=false
    assert(F.DefendDesire(heroes[1],LANE_BOT,0.9)==0)
end)
test('tier two has the same lost-fight protection',function()
    towers[2][TOWER_BOT_2]=towers[2][TOWER_BOT_1];towers[2][TOWER_BOT_1]=nil
    heroes[2].alive=false;heroes[3].alive=false
    assert(not F.CanTeleportTo(heroes[1],Vector(5000)))
    assert(F.DefendDesire(heroes[1],LANE_BOT,0.9)==0)
end)
test('base tower defense retains existing behavior',function()
    towers[2][TOWER_BOT_3]=towers[2][TOWER_BOT_1];towers[2][TOWER_BOT_1]=nil
    heroes[2].alive=false;heroes[3].alive=false
    assert(F.CanTeleportTo(heroes[1],Vector(5000)))
    assert(F.DefendDesire(heroes[1],LANE_BOT,0.9)==0.9)
end)
test('rescue ends with return when there is no push opportunity',function()
    local h=arrive();assert(R.Get(h).phase=='return')
    assert(R.ReturnDesire(h)>0);assert(R.ThinkReturn(h));assert(h.destination.x==-5000)
    assert(R.ReturnTP(h));assert(R.CapRoutineDesire(h,0.95)==0.45)
    assert(R.CapRoutineDesire(h,1.1)==1.1)
end)
local function wave()
    towers[3][TOWER_BOT_1]=unit(6200)
    creeps={unit(6000),unit(6100),unit(6200)}
end
test('three healthy heroes with a wave take a bounded tier one push',function()
    local h=arrive();wave();assert(R.Get(h).phase=='push')
    assert(R.PushDesire(h,LANE_BOT)>0);assert(R.PushDesire(h,LANE_TOP)==0)
    now=502;assert(R.Get(h).phase=='return')
end)
test('no wave means return instead of tower diving',function()
    local h=arrive();wave();creeps={};assert(R.Get(h).phase=='return')
end)
test('unsafe home core prevents extending rotation for a tower',function()
    local h=arrive();wave();heroes[4].lane=LANE_TOP;heroes[4].pos=1;heroes[4].hp=0.4
    assert(R.Get(h).phase=='return')
end)

test('ordinary home harassment does not prematurely end a safe bounded push',function()
    local h=arrive();wave();assert(R.Get(h).phase=='push')
    now=482;heroes[4].hp=0.95;heroes[4].damaged=true
    assert(R.Get(h).phase=='push')
end)
test('ongoing fight does not force a return order',function()
    local h=arrive();h.damaged=true;assert(not R.Get(h));assert(not R.ThinkReturn(h))
end)
test('channel is not interrupted by return movement',function()
    local h=arrive();R.Get(h);h.channeling=true;assert(not R.ThinkReturn(h));assert(not h.destination)
end)
test('arrival back home clears rotation',function()
    local h=arrive();h.loc=Vector(-5000,-600);assert(not R.Get(h));assert(not h.ohaLaneRotation)
end)
test('failed teleport does not leave a permanent rotation',function()
    local h=heroes[1];F.RecordTeleport(h,Vector(5000));now=486;R.Get(h);assert(not h.ohaLaneRotation)
end)
test('rotation does not persist past laning',function()
    local h=arrive();laning=false;assert(not R.Get(h));assert(not h.ohaLaneRotation)
end)
test('cancel an in-flight reinforcement when defenders die',function()
    local h=heroes[1];F.RecordTeleport(h,Vector(5000))
    h.channeling=true;h.ability={GetName=function()return 'item_tpscroll'end}
    heroes[2].alive=false;heroes[3].alive=false
    assert(F.CancelUnsafeTeleport(h));assert(h.cancelled);assert(not h.ohaLaneRotation)
end)
test('do not cancel an unrelated channel after teleporting',function()
    local h=heroes[1];F.RecordTeleport(h,Vector(5000))
    h.channeling=true;h.ability={GetName=function()return 'witch_doctor_death_ward'end}
    heroes[2].alive=false;heroes[3].alive=false
    assert(not F.CancelUnsafeTeleport(h));assert(not h.cancelled)
end)
print(passed..' rotation scenarios passed')
