local H = dofile('tests/hero_harness.lua')
local bot, J = H.bot, H.J
BOT_ACTION_DESIRE_NONE=0; BOT_ACTION_DESIRE_HIGH=1; BOT_MODE_NONE=0
DAMAGE_TYPE_MAGICAL=2; ABILITY_BEHAVIOR_UNIT_TARGET=8
local now, mode, target, enemies, allies, creeps, neutrals, actions = 100, '', nil, {}, {}, {}, {}, {}
function DotaTime() return now end
function GetLocationToLocationDistance(a,b) return math.sqrt((a.x-b.x)^2+(a.y-b.y)^2) end
function GetUnitToLocationDistance(a,b) return GetLocationToLocationDistance(a:GetLocation(),b) end
function GetUnitToUnitDistance(a,b) return GetUnitToLocationDistance(a,b:GetLocation()) end
local function unit(x,hp)
    local u={loc=Vector(x,0),hp=hp or 1000,mods={}}
    function u:GetLocation() return self.loc end
    function u:GetHealth() return self.hp end
    function u:HasModifier(n) return self.mods[n]==true end
    function u:IsInvulnerable() return self.invulnerable==true end
    function u:IsAttackImmune() return false end
    function u:IsChanneling() return false end
    function u:WasRecentlyDamagedByAnyHero() return self.damaged==true end
    function u:IsAncientCreep() return self.ancient==true end
    return u
end
function bot:GetLocation() return Vector(0,0) end
function bot:GetMana() return self.mana end
function bot:GetNearbyHeroes(_,enemy) return enemy and enemies or allies end
function bot:GetNearbyLaneCreeps() return creeps end
function bot:GetNearbyNeutralCreeps() return neutrals end
function bot:FindAoELocation() return {count=0,targetloc=Vector(0,0)} end
function bot:WasRecentlyDamagedByAnyHero() return self.damaged end
function bot:WasRecentlyDamagedByHero() return self.damaged end
function bot:IsAlive() return true end
function bot:IsStunned() return false end
function bot:IsHexed() return false end
function bot:IsNightmared() return false end
function bot:IsChanneling() return self.channel==true end
function bot:IsUsingAbility() return false end
function bot:IsCastingAbility() return false end
function bot:NumQueuedActions() return self.queued or 0 end
function bot:IsInvulnerable() return false end
function bot:HasModifier(n) return self.mods[n]==true end
for _,name in ipairs({'Action_UseAbility','Action_UseAbilityOnEntity','Action_UseAbilityOnLocation', 'ActionQueue_UseAbility'}) do
    bot[name]=function(_,a,arg) actions[#actions+1]={ability=a.name,arg=arg,shape=name} end
end
local abilities={}
local function ability(name,range,cost,values)
    local a={name=name,range=range,cost=cost,values=values or {},ready=false,behavior=0}
    function a:GetName() return self.name end
    function a:IsFullyCastable() return self.ready end
    function a:IsTrained() return true end
    function a:GetCastRange() return self.range end
    function a:GetManaCost() return self.cost end
    function a:GetCastPoint() return 0.2 end
    function a:GetBehavior() return self.behavior end
    function a:GetSpecialValueInt(k) return self.values[k] or 0 end
    abilities[name]=a; return a
end
local clap=ability('brewmaster_thunder_clap',0,100,{radius=400,damage=300})
local cinder=ability('brewmaster_cinder_brew',950,80,{radius=400,projectile_speed=950})
local split=ability('brewmaster_primal_split',0,250)
local stance=ability('brewmaster_drunken_brawler',0,0)
local liquid=ability('brewmaster_liquid_courage',800,50)
function bot:GetAbilityByName(n) return abilities[n] end
J.CanCastAbility=function(a) return a~=nil and a.ready and not a.passive and not a.hidden end
J.CanNotUseAbility=function() return bot.silenced==true end
J.CheckBitfieldFlag=function(value,flag) return value==flag end
J.IsItemAvailable=function() return nil end
J.GetProperTarget=function() return target end
J.IsValid=function(u) return u~=nil end
J.IsValidHero=J.IsValid; J.IsValidTarget=J.IsValid
J.CanCastOnNonMagicImmune=function(u) return u~=nil and not u.immune and not u.invulnerable end
J.IsSuspiciousIllusion=function(u) return u.illusion==true end
J.CanBeAttacked=function(u) return u~=nil and not u.invulnerable end
J.CanKillTarget=function(u,d) return u.hp<=d*(u.mitigation or 1) end
J.IsInRange=function(a,b,r) return b~=nil and GetUnitToUnitDistance(a,b)<=r end
J.GetHP=function(u) return u.hp/1000 end
J.GetMP=function() return bot.mana/1000 end
J.IsRealInvisible=function() return false end
J.IsChasingTarget=function() return true end
J.GetCorrectLoc=function(u,delay) u.delay=delay; return u.predicted or u.loc end
J.IsCore=function() return true end
J.WeAreStronger=function() return false end
J.IsLocationInChrono=function() return false end
J.IsInTeamFight=function() return mode=='fight' end
J.IsAttacking=function() return mode=='attack' or mode=='farm' end
J.GetEnemiesNearLoc=function() return enemies end
J.IsKeyWordUnit=function(k,u) return u.key==k end
J.SetQueuePtToINT=function() end
J.Site={GetXUnitsTowardsLocation=function(_,v,r) local d=GetUnitToLocationDistance(bot,v); return Vector(v.x*r/d,v.y*r/d) end}
for method,value in pairs({IsGoingOnSomeone='attack',IsRetreating='retreat',IsLaning='lane',IsPushing='push',IsDefending='defend',IsFarming='farm',IsDoingRoshan='roshan',IsDoingTormentor='tormentor'}) do
    J[method]=function() return mode==value end
end
local hero=H.load('npc_dota_hero_brewmaster','pos_3')
local copy=H.realDofile('bots/FunLib/rubick_hero/brewmaster.lua')
local function reset()
    mode,target,enemies,allies,creeps,neutrals,actions='',nil,{},{},{},{},{}
    now=now+10; bot.mana=1000; bot.hp=1000; bot.damaged=false; bot.silenced=false; bot.channel=false; bot.queued=0; bot.mods={}
    for _,a in pairs(abilities) do a.ready=false end
    liquid.passive=false; liquid.hidden=false; liquid.behavior=8
end
reset(); mode='retreat'; bot.hp=300; bot.damaged=true; enemies={unit(300)}; split.ready=true; cinder.ready=true; clap.ready=true
hero.SkillsComplement(); assert(actions[1].ability==split.name,'solo emergency Split precedes ordinary spells')
actions={}; assert(copy.ConsiderStolenSpell(split)==true and actions[1].ability==split.name,'standalone stolen Split saves Rubick')
reset(); mode='attack'; target=unit(350); enemies={target}; split.ready=true; clap.ready=true; cinder.ready=true; bot.mana=300
assert(hero.ConsiderCinderBrew()==0 and hero.ConsiderThunderClap()==0,'reserve available Split mana under pressure')
reset(); mode='attack'; target=unit(390); enemies={target}; clap.ready=true
assert(hero.ConsiderThunderClap()>0,'full radius and disabled follow-up can Clap')
target.hp=100; cinder.ready=true; hero.SkillsComplement(); assert(actions[1].ability==clap.name,'lethal Clap wins over barrel setup')
reset(); mode='attack'; target=unit(300); enemies={target}; clap.ready=true; cinder.ready=true
hero.SkillsComplement(); assert(actions[1].ability==cinder.name,'barrel precedes ordinary ignition')
cinder.ready=false; actions={}; now=now+0.1; hero.SkillsComplement(); assert(#actions==0,'wait for physical barrel impact before ignition')
now=now+1; hero.SkillsComplement(); assert(actions[1].ability==clap.name,'ignite after barrel arrives')
reset(); mode='attack'; target=unit(1200); cinder.ready=true
local d,loc=hero.ConsiderCinderBrew(); assert(d>0 and loc.x==950 and target.delay>1,'legal edge placement includes travel prediction')
target.predicted=Vector(1500,0); assert(hero.ConsiderCinderBrew()==0,'reject escaping target outside barrel footprint')
reset(); mode='farm'; cinder.ready=true; neutrals={unit(300),unit(350),unit(370),unit(1400)}
local _,camp=hero.ConsiderCinderBrew(); assert(camp.x<400,'choose real camp cluster instead of remote mean')
reset(); mode='lane'; clap.ready=true; creeps={unit(100,200),unit(200,200)}; for _,u in pairs(creeps) do u.mitigation=0.5 end
assert(hero.ConsiderThunderClap()==0,'mitigated lane damage does not invent last hits')
reset(); liquid.ready=true; liquid.passive=true; assert(hero.ConsiderLiquidCourage()==0,'base passive innate is not cast')
liquid.passive=false; liquid.behavior=0; assert(hero.ConsiderLiquidCourage()==0,'live Shard must have unit behavior')
liquid.behavior=8; local ally=unit(600,400); ally.damaged=true; allies={ally}; hero.SkillsComplement()
assert(actions[1].arg==ally and actions[1].shape=='Action_UseAbilityOnEntity','Shard drink selects injured ally with entity shape')
reset(); liquid.ready=true; bot.hp=400; bot.damaged=true; hero.SkillsComplement(); assert(actions[1].arg==bot,'Shard drink can heal self')
reset(); stance.ready=true; bot.silenced=true; mode='retreat'; hero.SkillsComplement(); assert(actions[1].ability==stance.name,'stance cycles while silenced')
reset(); stance.ready=true; mode='attack'; bot.mods.modifier_brewmaster_drunken_brawler_storm=true; hero.SkillsComplement()
assert(actions[1].ability==stance.name,'observed stance synchronizes cycling')
reset(); bot.channel=true; split.ready=true; hero.SkillsComplement(); assert(#actions==0,'preserve active channel')
assert(copy.ConsiderStolenSpell(ability('unknown',0,0))==nil,'unknown copied spell keeps fallback')
print('Brewmaster ability scenarios passed')
