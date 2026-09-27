package.path='./?.lua;'..package.path
DAMAGE_TYPE_PHYSICAL=1
local allies,enemyCreeps,allyCreeps,laning
function GetScriptDirectory()return 'bots'end
function GetUnitToUnitDistance(a,b)return math.abs(a.x-b.x)end
function GetUnitToLocationDistance(a,b)return math.abs(a.x-b.x)end
local J={Utils={}}
function J.GetPosition(h)return h.pos end
function J.IsInLaningPhase()return laning end
function J.IsRetreating(h)return h.retreat end
function J.IsPushing(h)return h.push end
function J.IsCore(h)return h.pos<=3 end
function J.IsValidHero(h)return h and h.hero end
function J.IsValid(h)return h and h.alive end
function J.CanBeAttacked()return true end
function J.GetHP(h)return h.hp/1000 end
function J.CanNotUseAction(h)return h.channel or h.casting end
function J.GetAlliesNearLoc()return allies end
function J.GetTeamFountain()return {x=-10000}end
function J.Utils.GetOffsetLocationTowardsTargetLocation(loc,_,d)return {x=loc.x-d}end
package.loaded['bots/FunLib/jmz_func']=J
local S=require('bots/FunLib/support_last_hits')
local function unit(hero,x)
    local h={hero=hero,x=x or 0,pos=5,alive=true,hp=1000,team=hero and 2 or 3,damage=60,range=150}
    function h:IsHero()return self.hero end
    function h:IsAlive()return self.alive end
    function h:IsNull()return false end
    function h:IsIllusion()return self.illusion end
    function h:GetTeam()return self.team end
    function h:GetUnitName()return self.hero and 'npc_dota_hero_test' or (self.name or 'npc_dota_creep_badguys_melee')end
    function h:GetLocation()return {x=self.x}end
    function h:GetHealth()return self.hp end
    function h:GetAttackRange()return self.range end
    function h:GetAttackDamage()return self.damage end
    function h:IsDisarmed()return self.disarmed end
    function h:IsStunned()return self.stunned end
    function h:IsChanneling()return self.channel end
    function h:WasRecentlyDamagedByAnyHero()return self.damaged end
    function h:WasRecentlyDamagedByTower()return self.towerDamage end
    function h:GetAttackTarget()return self.target end
    function h:GetNearbyLaneCreeps(_,enemy)return enemy and enemyCreeps or allyCreeps end
    function h:GetActualIncomingDamage(damage)return damage end
    function h:SetTarget(t)self.target=t end
    function h:Action_AttackUnit(t)self.target=t;self.attacks=(self.attacks or 0)+1 end
    function h:Action_MoveToLocation(loc)self.destination=loc end
    return h
end
local bot,core,creep
local passed=0
local function test(name,fn)
    bot,core,creep=unit(true),unit(true,100),unit(false,200)
    core.pos=1;creep.hp=100;allies={bot,core};enemyCreeps={creep};allyCreeps={};laning=true
    fn();passed=passed+1;print('PASS '..name)
end
test('support reserves near-last-hit creep for core',function()assert(S.ReservedForCore(bot,creep)==core);assert(S.Window(bot)==core)end)
test('core proximity is measured from the creep',function()
    bot.range=700;core.x=1000;core.range=650;creep.x=700
    assert(S.ReservedForCore(bot,creep)==core)
end)
test('nearby support does not reserve creep unreachable by melee core',function()
    core.x=-300;assert(not S.ReservedForCore(bot,creep))
end)
test('dead or absent core permits farming',function()
    core.alive=false;assert(not S.Window(bot));allies={bot};assert(not S.Window(bot))
end)
test('disabled or retreating core permits farming',function()
    core.disarmed=true;assert(not S.Window(bot));core.disarmed=false;core.retreat=true;assert(not S.Window(bot))
end)
test('support retreat and tower aggro take priority',function()
    bot.retreat=true;assert(not S.Window(bot));bot.retreat=false;bot.towerDamage=true;assert(not S.Window(bot))
end)
test('hero combat takes priority',function()
    bot.target=unit(true,300);assert(not S.Window(bot));bot.target=nil;bot.damaged=true;assert(not S.Window(bot))
end)
test('casting is not interrupted',function()bot.casting=true;assert(not S.Think(bot));assert(not bot.destination)end)
test('healthy creep does not trigger intervention',function()creep.hp=800;assert(not S.Window(bot))end)
test('denies and neutral creeps are never reserved',function()
    creep.team=2;assert(not S.ReservedForCore(bot,creep));creep.team=3;creep.name='npc_dota_neutral_centaur';assert(not S.ReservedForCore(bot,creep))
end)
test('cores and illusions do not use support protection',function()
    bot.pos=3;assert(not S.Window(bot));bot.pos=5;bot.illusion=true;assert(not S.Window(bot))
end)
test('post-laning and push farming stay available',function()
    laning=false;assert(not S.Window(bot));laning=true;bot.push=true;assert(not S.Window(bot))
end)
test('intervention keeps a deny without restarting attack',function()
    local deny=unit(false,100);deny.hp=40;deny.team=2;allyCreeps={deny}
    assert(S.Think(bot));assert(bot.target==deny);S.Think(bot);assert(bot.attacks==1)
end)
test('intervention clears stale creep target and repositions',function()
    bot.target=creep;assert(S.Think(bot));assert(bot.target==nil and bot.destination)
    creep.alive=false;assert(not S.Window(bot))
end)
print(passed..' support last-hit scenarios passed')
