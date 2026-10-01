-- Arc Warden and Rubick: isolation, combat order, point targeting and Double ownership.
local H = dofile('tests/hero_harness.lua')
local bot, J = H.bot, H.J
BOT_ACTION_DESIRE_NONE=0; BOT_ACTION_DESIRE_LOW=0.2; BOT_ACTION_DESIRE_MODERATE=0.5; BOT_ACTION_DESIRE_HIGH=0.8
BOT_MODE_NONE=0; BOT_MODE_ATTACK=1; BOT_MODE_RETREAT=2; BOT_MODE_RUNE=3; BOT_MODE_ROSHAN=4; BOT_MODE_FARM=5; BOT_MODE_LANING=6
UNIT_LIST_ENEMY_HEROES=1; UNIT_LIST_ENEMY_CREEPS=2; UNIT_LIST_ALLIED_HEROES=3
DAMAGE_TYPE_MAGICAL=2; DAMAGE_TYPE_ALL=4
RUNE_POWERUP_1=1; RUNE_POWERUP_2=2; RUNE_STATUS_AVAILABLE=1

local Vec={}; Vec.__index=Vec
local function V(x,y) return setmetatable({x=x,y=y or 0,z=0},Vec) end
Vec.__add=function(a,b) return V(a.x+b.x,a.y+b.y) end
Vec.__sub=function(a,b) return V(a.x-b.x,a.y-b.y) end
Vec.__mul=function(a,b) return V(a.x*b,a.y*b) end
function Vec:Length2D() return math.sqrt(self.x*self.x+self.y*self.y) end
function Vec:Normalized() local n=self:Length2D(); return n>0 and V(self.x/n,self.y/n) or V(0) end
local function dist(a,b) return (a-b):Length2D() end
function Vector(x,y) return V(x,y) end
function GetUnitToUnitDistance(a,b) return dist(a.loc,b.loc) end
function GetUnitToLocationDistance(a,b) return dist(a.loc,b) end
function DotaTime() return 100 end
function IsLocationVisible() return true end
function IsLocationPassable() return true end

local enemies,creeps,allies,actions,runes={},{},{},{},{}
local mode,target,fight,spam='idle',nil,false,false
local Unit={}; Unit.__index=Unit
local function unit(x,hp)
    return setmetatable({loc=V(x),hp=hp or 1000,mods={},valid=true,hero=true,player=0,
        attackRange=625,move=0,mode='idle',recent=false,illusion=false},Unit)
end
function Unit:GetLocation() return self.loc end
function Unit:GetExtrapolatedLocation(delay) self.predictedDelay=delay; return self.loc+V(self.move*delay) end
function Unit:HasModifier(name) return self.mods[name]==true end
function Unit:GetHealth() return self.hp end
function Unit:GetMaxHealth() return 1000 end
function Unit:GetPlayerID() return self.player end
function Unit:GetAttackRange() return self.attackRange end
function Unit:GetAttackTarget() return self.attackTarget end
function Unit:GetEstimatedDamageToTarget() return 100 end
function Unit:GetUnitName() return self.hero and 'npc_dota_hero_arc_warden' or 'npc_dota_creep_badguys_ranged' end
function Unit:IsAlive() return self.valid end
function Unit:IsIllusion() return self.illusion end
function Unit:IsCastingAbility() return self.casting==true end
function Unit:IsUsingAbility() return self.casting==true end
function Unit:IsAncientCreep() return false end
function Unit:WasRecentlyDamagedByHero() return self.recent end
function Unit:WasRecentlyDamagedByAnyHero() return self.recent end
local function near(list,loc,range)
    local out={}; for _,u in ipairs(list) do if u.valid and dist(u.loc,loc)<=range then out[#out+1]=u end end
    return out
end
function Unit:GetNearbyHeroes(range,enemy) return near(enemy and enemies or allies,self.loc,range) end
setmetatable(bot,Unit)
function bot:GetLevel() return 6 end
function bot:GetMana() return self.mana end
function bot:GetMaxMana() return 1000 end
function bot:GetActiveMode() return mode=='rune' and BOT_MODE_RUNE or mode=='lane' and BOT_MODE_LANING or BOT_MODE_NONE end
function bot:GetActiveModeDesire() return 1 end
function bot:GetNearbyLaneCreeps() return creeps end
function bot:GetNearbyNeutralCreeps() return {} end
function bot:GetNearbyCreeps() return creeps end
function bot:GetNearbyTowers() return {} end
function bot:DistanceFromFountain() return 1000 end
function bot:FindAoELocation() return {count=0,targetloc=V(0)} end
function bot:ActionQueue_UseAbilityOnEntity(a,u) actions[#actions+1]={name=a.name,target=u} end
function bot:ActionQueue_UseAbilityOnLocation(a,v) actions[#actions+1]={name=a.name,loc=v} end
bot.Action_UseAbilityOnEntity=bot.ActionQueue_UseAbilityOnEntity
bot.Action_UseAbilityOnLocation=bot.ActionQueue_UseAbilityOnLocation
function GetUnitList(kind) return kind==UNIT_LIST_ENEMY_HEROES and enemies or kind==UNIT_LIST_ENEMY_CREEPS and creeps or allies end
function GetRuneSpawnLocation(id) return runes[id] and runes[id].loc or V(10000) end
function GetRuneStatus(id) return runes[id] and RUNE_STATUS_AVAILABLE or 0 end

local abilities={}
local function ability(name,range,cost,values)
    local a={name=name,range=range,cost=cost,values=values,castable=false,level=1}
    function a:GetName() return self.name end
    function a:IsFullyCastable() return self.castable end
    function a:GetLevel() return self.level end
    function a:GetCastRange() return self.range end
    function a:GetManaCost() return self.cost end
    function a:GetCastPoint() return 0.3 end
    function a:GetSpecialValueInt(k) return math.floor(self.values[k] or 0) end
    function a:GetSpecialValueFloat(k) return self.values[k] or 0 end
    abilities[name]=a; return a
end
local Flux=ability('arc_warden_flux',625,75,{damage_per_second=15,duration=6,search_radius=225})
local Field=ability('arc_warden_magnetic_field',900,60,{radius=300})
local Spark=ability('arc_warden_spark_wraith',2000,80,{radius=375,spark_damage_base=100,base_activation_delay=1.5})
local Double=ability('arc_warden_tempest_double',700,0,{})
bot.GetAbilityByName=function(_,name) return abilities[name] or {} end

setmetatable(J,{__index=function() return function() return false end end})
J.CanNotUseAbility=function() return false end
J.IsRealInvisible=function() return false end
J.GetProperTarget=function() return target end
J.GetProperCastRange=function(_,_,r) return r+200 end -- Detect accidental walking casts.
J.IsValid=function(u) return u~=nil and u.valid end
J.IsValidHero=function(u) return J.IsValid(u) and u.hero end
J.IsValidTarget=J.IsValid
J.IsInRange=function(a,b,r) return GetUnitToUnitDistance(a,b)<=r end
J.IsSuspiciousIllusion=function(u) return u.illusion end
J.CanCastOnNonMagicImmune=function(u) return J.IsValid(u) and not u.immune end
J.CanCastOnTargetAdvanced=J.IsValid
J.CanCastOnMagicImmune=J.IsValid
J.CanBeAttacked=J.IsValid
J.CanKillTarget=function(u,dmg) return dmg*(u.magicMultiplier or 1)>=u.hp end
J.GetHP=function(u) return u.hp/1000 end
J.GetMP=function() return bot.mana/1000 end
J.GetManaAfter=function(cost) return (bot.mana-cost)/1000 end
J.GetNearbyHeroes=function(u,r,enemy)
    if u:HasModifier('modifier_arc_warden_tempest_double') then return {} end
    return u:GetNearbyHeroes(r,enemy)
end
J.GetAlliesNearLoc=function(v,r) return near(allies,v,r) end
J.GetEnemiesNearLoc=function(v,r) return near(enemies,v,r) end
J.IsGoingOnSomeone=function() return mode=='attack' end
J.IsRetreating=function(u) return (u==bot and mode=='retreat') or u.mode=='retreat' end
J.IsLaning=function() return mode=='lane' end
J.IsInLaningPhase=function() return true end
J.IsInTeamFight=function() return fight end
J.IsChasingTarget=function(u) return u.chasing==true end
J.IsRunning=function(u) return u.move~=0 end
J.IsDisabled=function() return false end
J.IsPushing=function() return mode=='push' end
J.IsDefending=function() return false end
J.IsFarming=function() return mode=='farm' end
J.IsAllowedToSpam=function() return spam end
J.IsAttacking=function() return bot.attackTarget~=nil end
J.SetQueuePtToINT=function() end
J.GetComboItem=function() return nil end
J.GetVulnerableUnitNearLoc=function() return creeps[1] end
J.IsKeyWordUnit=function() return true end
J.GetEnemyFountain=function() return V(10000) end
J.GetLocationTowardDistanceLocation=function(u,v,r) return u.loc+(v-u.loc):Normalized()*r end
J.GetDistanceFromEnemyFountain=function() return 10000 end
J.Site={GetXUnitsTowardsLocation=J.GetLocationTowardDistanceLocation}

local Arc=H.load('npc_dota_hero_arc_warden','pos_2')
local Rubick=H.realDofile('bots/FunLib/rubick_hero/arc_warden.lua')
local function reset()
    enemies,creeps,allies,actions,runes={},{},{},{},{}
    mode,target,fight,spam='idle',nil,false,false
    for k in pairs(bot) do if type(bot[k])~='function' then bot[k]=nil end end
    for k,v in pairs(unit(0)) do bot[k]=v end
    bot.mana=400; bot.player=0
    for _,a in pairs(abilities) do a.castable=false; a.level=1 end
end
local function tick() actions={}; Arc.SkillsComplement(); return actions[1] end
local function cast(a,u) local r=tick(); assert(r and r.name==a.name and (not u or r.target==u),'expected '..a.name); return r end
local function noCast() assert(tick()==nil,'expected no cast') end
local function stolen(a) actions={}; local handled=Rubick.ConsiderStolenSpell(a); return actions[1],handled end

-- Flux opens the isolated gank before creating the Double or boosting attacks.
reset(); Flux.castable=true; Double.castable=true; Field.castable=true
mode='attack'; target=unit(500); enemies={target}; bot.attackTarget=target
cast(Flux,target)
Flux.castable=false; cast(Double)

-- Friendly heroes, ordinary creeps and summons pause Flux damage. Retreat slow still works.
reset(); Flux.castable=true; target=unit(500,80); enemies={target}
cast(Flux,target)
target.mods.modifier_antimage_counterspell=true;noCast();target.mods={}
enemies[2]=unit(600); noCast()
enemies={target}; local creep=unit(600); creep.hero=false; creeps={creep}; noCast()
mode='retreat'; target.chasing=true; cast(Flux,target)
mode='attack'; target.chasing=false; noCast()
creeps={}; target.loc=V(626); noCast()

-- Both main and Double can slow the target; the Double must never cast the ultimate.
reset(); Flux.castable=true; Double.castable=true; bot.mods.modifier_arc_warden_tempest_double=true
mode='attack'; target=unit(500); enemies={target}
cast(Flux,target)
Flux.castable=false; noCast()

-- Field includes the caster, protects remote allies at their location, and chains after the buff ends.
reset(); Field.castable=true; mode='attack'; target=unit(500); enemies={target}; bot.attackTarget=target
local field=cast(Field); assert(field.loc==bot.loc,'self Field works without another hero nearby')
bot.mods.modifier_arc_warden_magnetic_field=true; noCast()
local ally=unit(800); ally.attackTarget=unit(1000); allies={ally}
field=cast(Field); assert(field.loc==ally.loc,'remote Field is centred on the attacking ally')
ally.loc=V(901); noCast()

-- Defensive Field wins over a damage spell only when its outside-attacker evasion can help.
reset(); Field.castable=true; Flux.castable=true; mode='retreat'; bot.hp=400
target=unit(600,80); target.attackTarget=bot; enemies={target}
cast(Field)
target.loc=V(200); cast(Flux,target)

-- Power rune capture is an actual point cast; enemy structures alone do not trigger Field.
reset(); Field.castable=true; mode='rune'; runes[1]={loc=V(850)}
field=cast(Field); assert(field.loc==runes[1].loc,'Field activates a reachable river rune')
runes[1].loc=V(901); noCast()

-- Spark uses activation plus cast point; prediction is constrained to legal cast range.
reset(); Spark.castable=true; target=unit(1900,50); target.move=200; enemies={target}
local spark=cast(Spark)
assert(math.abs(target.predictedDelay-1.8)<0.001,'Spark predicts through its full activation delay')
assert(dist(bot.loc,spark.loc)<=2000,'predicted Spark location is within the actual cast range')
target.loc=V(1000); target.move=0; creep=unit(1050); creep.hero=false; creeps={creep}
noCast()

-- Ranged-creep securing checks magical damage and never casts beyond range.
reset(); Spark.castable=true; mode='lane'; creep=unit(1000,90); creep.hero=false; creeps={creep}
cast(Spark)
creep.magicMultiplier=0.5; noCast()
creep.magicMultiplier=1; creep.loc=V(2001); noCast()

-- Do not replace a living owned Double; ignore somebody else's and clear dead handles.
reset(); Double.castable=true; mode='attack'; target=unit(500); enemies={target}
local own=unit(200); own.mods.modifier_arc_warden_tempest_double=true; allies={own}
noCast()
own.valid=false; cast(Double)
own.valid=true; own.player=1; cast(Double)

-- Rubick mirrors isolated damage, pack slow, remote Field and Spark creep safety.
reset(); Flux.castable=true; target=unit(500,80); enemies={target}
local action,handled=stolen(Flux); assert(handled and action.target==target,'stolen Flux kills an isolated target')
target.mods.modifier_antimage_counterspell=true;action,handled=stolen(Flux)
assert(not action and handled==false,'stolen Flux avoids active Counterspell');target.mods={} 
creep=unit(600); creep.hero=false; creeps={creep}
action,handled=stolen(Flux); assert(not action and handled==false,'stolen Flux does not count paused damage')
mode='retreat'; target.chasing=true; action,handled=stolen(Flux); assert(action.target==target,'stolen Flux still slows a pack pursuer')
reset(); Field.castable=true; mode='attack'; ally=unit(800); ally.attackTarget=unit(1000); allies={ally}
action,handled=stolen(Field); assert(handled and action.loc==ally.loc,'stolen Field buffs the remote attacker')
reset(); Spark.castable=true; target=unit(1900,50); target.move=200; enemies={target}
action,handled=stolen(Spark); assert(handled and dist(bot.loc,action.loc)<=2000,'stolen Spark prediction stays in range')
target.loc=V(1000); target.move=0; creep=unit(1050); creep.hero=false; creeps={creep}
action,handled=stolen(Spark); assert(not action and handled==false,'stolen Spark avoids a creep-soaked kill')
reset(); Spark.castable=true; mode='retreat'; bot.recent=true; target=unit(600); enemies={target}
action,handled=stolen(Spark)
assert(handled and action.loc==bot.loc,'stolen Spark protects the retreat path without a kill target')

print('Arc Warden ability scenarios passed')
