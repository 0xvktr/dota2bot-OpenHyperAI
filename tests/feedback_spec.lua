package.path = './?.lua;'..package.path
BOT_ACTION_DESIRE_NONE, BOT_ACTION_DESIRE_HIGH = 0, 0.8
TOWER_TOP_1,TOWER_MID_1,TOWER_BOT_1,TOWER_TOP_2,TOWER_MID_2,TOWER_BOT_2,TOWER_TOP_3,TOWER_MID_3,TOWER_BOT_3=1,2,3,4,5,6,7,8,9
local V = {}
function Vector(x,y) return setmetatable({x=x,y=y or 0},V) end
V.__add=function(a,b)return Vector(a.x+b.x,a.y+b.y)end
V.__sub=function(a,b)return Vector(a.x-b.x,a.y-b.y)end
V.__mul=function(a,b)return Vector(a.x*b,a.y*b)end
V.__index={Normalized=function(a)local d=math.sqrt(a.x*a.x+a.y*a.y);return Vector(a.x/d,a.y/d)end}
local now, allies, threat, tower, fightEnemies, landingDanger
function GetScriptDirectory()return 'bots'end
function DotaTime()return now end
function GetTeam()return 2 end
function GetItemCost(name)return name=='item_branches' and 50 or 2000 end
function GetTower(_,id)return id==1 and tower or nil end
function GetAncient()return {GetLocation=function()return Vector(-8000)end}end
function GetUnitToUnitDistance(a,b)return math.abs(a.loc.x-b.loc.x)end
local J={}
function J.GetHP(h)return h.hp/h.maxhp end
function J.GetMP(h)return h.mp/1000 end
function J.IsValidHero(h)return h~=nil end
function J.IsValid(h)return h~=nil end
function J.CanNotUseAction(h)return h.casting end
function J.GetAlliesNearLoc()return allies end
function J.GetEnemiesNearLoc(loc,radius)
    if threat then return {1} end
    if tower and loc.x==tower.loc.x then return fightEnemies end
    if tower and radius==700 and landingDanger then return {1} end
    return {}
end
function J.IsDoingRoshan(h)return h.roshan end
function J.IsRoshan(h)return h.boss end
package.loaded['bots/FunLib/jmz_func']=J
local L=require('bots/FunLib/lotus_usage')
local F=require('bots/FunLib/fight_response')
local B=require('bots/FunLib/boss_combat')
local function hero(x)
    local h={hp=1000,maxhp=1000,mp=1000,items={},loc=Vector(x or 0),abilities={}}
    function h:GetLocation()return self.loc end
    function h:GetHealth()return self.hp end
    function h:GetMaxHealth()return self.maxhp end
    function h:GetMana()return self.mp end
    function h:GetMaxMana()return 1000 end
    function h:IsAlive()return true end
    function h:IsIllusion()return false end
    function h:IsSilenced()return self.silenced end
    function h:HasModifier()return self.buff end
    function h:DistanceFromFountain()return 6000 end
    function h:WasRecentlyDamagedByAnyHero()return self.damaged end
    function h:WasRecentlyDamagedByTower()return false end
    function h:WasRecentlyDamagedByCreep()return self.creepDamage end
    function h:GetItemInSlot(i)return self.items[i]end
    function h:ActionImmediate_SwapItems(a,b)self.items[a],self.items[b]=self.items[b],self.items[a];self.swaps=(self.swaps or 0)+1 end
    function h:GetAttackTarget()return self.target end
    function h:GetAttackRange()return 600 end
    function h:GetAttackDamage()return 100 end
    function h:GetAbilityByName(n)return self.abilities[n]end
    function h:Action_UseAbilityOnEntity(a,t)self.cast=a;self.castTarget=t end
    return h
end
local function item(name)
    return {GetName=function()return name end,GetCastRange=function()return 700 end,
        IsFullyCastable=function()return true end,GetCurrentCharges=function()return 1 end}
end
local passed=0
local function test(name,fn)
    now,allies,threat,tower,fightEnemies,landingDanger=200,{},false,nil,{},false
    fn();passed=passed+1;print('PASS '..name)
end
test('basic lotus can restore health during combat',function()
    local h=hero();h.hp=400;h.damaged=true;threat=true
    assert(L.Target(h,item('item_famango'))==h)
end)
test('lotus prioritizes depleted nearby human over healthy holder',function()
    local h, human=hero(),hero();human.mp=100;allies={h,human}
    assert(L.Target(h,item('item_great_famango'))==human)
end)
test('large lotus is not wasted on tiny deficits',function()
    local h=hero();h.hp=950;assert(L.Target(h,item('item_greater_famango'))==nil)
end)
test('backpack lotus replaces cheap item and restores it after use',function()
    local h=hero();h.hp=600
    for i=0,5 do h.items[i]=item('item_expensive')end
    local branch,lotus=item('item_branches'),item('item_famango');h.items[2]=branch;h.items[6]=lotus
    L.Prepare(h);assert(h.items[2]==lotus and h.items[6]==branch)
    now=205;L.Prepare(h);assert(h.swaps==1)
    h.items[2]=nil;now=208;L.Prepare(h);assert(h.items[2]==branch and h.swaps==2)
end)
test('backpack swapping does not remove stats in combat',function()
    local h=hero();h.hp=400;h.items[6]=item('item_famango');h.damaged=true
    L.Prepare(h);assert(not h.swaps)
end)
test('active lotus prevents repeated backpack swaps',function()
    local h=hero();h.hp=400;h.items[0]=item('item_famango');h.items[6]=item('item_great_famango')
    L.Prepare(h);assert(not h.swaps)
end)
local function fight()
    local h=hero(-5000);tower=hero(0);allies={hero(),hero()};allies[1].damaged=true;fightEnemies={1,2,3}
    return h
end
test('distant healthy hero reinforces a winnable tower fight',function()
    local h=fight();assert(F.TeleportLocation(h).x==-450)
end)
test('do not TP into a lost two versus five',function()
    local h=fight();fightEnemies={1,2,3,4,5};assert(not F.TeleportLocation(h))
end)
test('do not teleport from an ongoing local fight',function()
    local h=fight();h.damaged=true;assert(not F.TeleportLocation(h))
end)
test('do not land among enemies',function()
    local h=fight();landingDanger=true;assert(not F.TeleportLocation(h))
end)
test('do not reinforce a tower that will imminently fall',function()
    local h=fight();tower.hp=100;assert(not F.TeleportLocation(h))
end)
test('Satanic can sustain an ongoing Roshan attack',function()
    local h=hero();h.hp=500;h.roshan=true;h.target=hero();h.target.boss=true
    assert(B.ItemDesire(h,item('item_satanic'))>0)
    h.target=nil;assert(B.ItemDesire(h,item('item_satanic'))==0)
end)
test('Slardar applies armor reduction only to committed Roshan target',function()
    local h=hero();h.roshan=true;h.target=hero();h.target.boss=true
    local ability=item('slardar_amplify_damage');h.abilities.slardar_amplify_damage=ability
    assert(B.AbilityThink(h));assert(h.castTarget==h.target)
    h.target.buff=true;assert(not B.AbilityThink(h))
end)
test('boss spell does not interrupt another ability or ignore enemies',function()
    local h=hero();h.roshan=true;h.target=hero();h.target.boss=true
    h.abilities.slardar_amplify_damage=item('slardar_amplify_damage')
    h.casting=true;assert(not B.AbilityThink(h));h.casting=false;threat=true;assert(not B.AbilityThink(h))
end)
test('Ogre buffs a teammate attacking Roshan',function()
    local h,a=hero(),hero();h.roshan=true;h.target=hero();h.target.boss=true;a.target=h.target;allies={a}
    h.abilities.ogre_magi_bloodlust=item('ogre_magi_bloodlust')
    assert(B.AbilityThink(h));assert(h.castTarget==a)
end)
test('do not swap away defensive slots while a creep or boss is damaging us',function()
    local h=hero();h.hp=400;h.creepDamage=true;h.items[6]=item('item_famango')
    L.Prepare(h);assert(not h.swaps)
end)
test('never backpack BKB or boots to prepare a lotus',function()
    local h=hero();h.hp=400;h.items[6]=item('item_famango')
    for i=0,5 do h.items[i]=item(i==0 and 'item_black_king_bar' or 'item_phase_boots')end
    L.Prepare(h);assert(not h.swaps)
end)
test('Drums require a group actually attacking the boss',function()
    local h=hero();h.roshan=true;h.target=hero();h.target.boss=true;allies={h,hero(),hero()}
    assert(B.ItemDesire(h,item('item_ancient_janggo'))==0)
    allies[2].target=h.target;allies[3].target=h.target
    assert(B.ItemDesire(h,item('item_ancient_janggo'))>0)
end)
print(passed..' feedback scenarios passed')
