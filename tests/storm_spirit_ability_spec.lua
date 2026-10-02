local H = dofile('tests/hero_harness.lua')
local J, bot = H.J, H.bot
BOT_ACTION_DESIRE_NONE, BOT_ACTION_DESIRE_HIGH = 0, 0.8
BOT_MODE_NONE, DAMAGE_TYPE_MAGICAL, DAMAGE_TYPE_PHYSICAL, UNIT_LIST_ENEMY_HEROES = 0, 2, 1, 2
local v={}; v.__index=v
function Vector(x,y,z) return setmetatable({x=x,y=y or 0,z=z or 0},v) end
function v.__add(a,b) return Vector(a.x+b.x,a.y+b.y,a.z+b.z) end
function v.__sub(a,b) return Vector(a.x-b.x,a.y-b.y,a.z-b.z) end
function v.__mul(a,b) if type(a)=='number' then a,b=b,a end;return Vector(a.x*b,a.y*b,a.z*b) end
function v:Length2D() return math.sqrt(self.x*self.x+self.y*self.y) end
function v:Normalized() local n=self:Length2D();return n==0 and Vector(0,0) or self*(1/n) end
function GetUnitToUnitDistance(a,b) return (a:GetLocation()-b:GetLocation()):Length2D() end
function GetUnitToLocationDistance(a,b) return (a:GetLocation()-b):Length2D() end
local actions,enemies,allies,lane,ownLane,neutrals,items,abilities={},{},{},{},{},{},{},{}
local now=0
function DotaTime() return now end
UNIT_LIST_ALLIES=3
local wards={},{}
function GetUnitList(kind) return kind==UNIT_LIST_ALLIES and wards or enemies end
local function unit(x,y,kind)
    local u={x=x,y=y or 0,kind=kind or 'hero',hp=1000,maxhp=1000,mana=1000,team=3,mods={},mode='',attackRange=150,speed=0}
    function u:GetLocation() return Vector(self.x,self.y) end
    function u:GetTeam() return self.team end
    function u:GetHealth() return self.hp end
    function u:GetMaxHealth() return self.maxhp end
    function u:GetMana() return self.mana end
    function u:GetMaxMana() return 1000 end
    function u:GetAttackRange() return self.attackRange end
    function u:GetAttackDamage() return 100 end
    function u:GetUnitName() return self.name or 'npc_dota_'..self.kind end
    function u:GetAttackTarget() return self.attackTarget end
    function u:HasModifier(m) return self.mods[m]==true end
    function u:IsMagicImmune() return self.immune==true end
    function u:IsInvulnerable() return self.invulnerable==true end
    function u:IsSilenced() return self.silenced==true end
    function u:IsIllusion() return self.illusion==true end
    function u:IsChanneling() return self.channel==true end
    function u:HasScepter() return self.scepter==true end
    function u:CanBeSeen() return self.visible~=false end
    function u:WasRecentlyDamagedByAnyHero() return self.damaged==true end
    function u:GetActualIncomingDamage(damage,kind) return damage*(kind==DAMAGE_TYPE_MAGICAL and (self.magic or 1) or (self.physical or 1)) end
    return u
end
for k,value in pairs(unit(0)) do bot[k]=value end
function bot:GetAbilityByName(name) return abilities[name] end
function bot:GetItemInSlot(slot) return items[slot] end
local function nearby(list,u,r)
    local out={};for _,other in pairs(list) do if other~=u and GetUnitToUnitDistance(u,other)<=r then out[#out+1]=other end end;return out
end
function bot:GetNearbyLaneCreeps(r,enemy) return nearby(enemy and lane or ownLane,self,r) end
function bot:GetNearbyNeutralCreeps(r) return nearby(neutrals,self,r) end
function bot:Action_UseAbilityOnLocation(a,p) assert(a~=nil);actions[#actions+1]={name=a.name,point=p} end
function bot:Action_UseAbilityOnEntity(a,u) assert(a~=nil and u~=nil);actions[#actions+1]={name=a.name,target=u} end
function bot:Action_UseAbility(a) assert(a~=nil);actions[#actions+1]={name=a.name} end
function bot:ActionQueue_UseAbilityOnLocation(a,p) actions[#actions+1]={name=a.name,point=p,queued=true} end
local function ability(name,range,mana,values,point)
    local a={name=name,range=range,mana=mana,values=values or {},point=point or 0,castable=false,trained=true,charges=4}
    function a:GetName() return self.name end
    function a:GetCastRange() return self.range end
    function a:GetManaCost() return self.mana end
    function a:GetCastPoint() return self.point end
    function a:GetSpecialValueFloat(key) assert(self.values[key]~=nil,'unexpected ability key '..self.name..':'..key);return self.values[key] end
    function a:GetSpecialValueInt(key) local value=self:GetSpecialValueFloat(key);return value>=0 and math.floor(value) or math.ceil(value) end
    function a:GetCurrentCharges() return self.charges end
    function a:GetLevel() return self.level or 4 end
    function a:GetAbilityDamage() return self.values.damage or 0 end
    function a:IsHidden() return self.hidden==true end
    function a:IsNull() return false end
    function a:IsPassive() return false end
    function a:IsTrained() return self.trained end
    function a:IsFullyCastable() return self.castable and bot.mana>=self.mana end
    abilities[name]=a;return a
end
J.IsValid=function(u) return u~=nil and not u.invalid and u:CanBeSeen() and u.hp>0 and u.kind~='building' end
J.IsValidHero=function(u) return J.IsValid(u) and u.kind=='hero' end
J.IsValidBuilding=function(u) return u~=nil and u.kind=='building' and u:CanBeSeen() and u.hp>0 end
J.IsSuspiciousIllusion=function(u) return u.illusion==true end
J.CanCastOnNonMagicImmune=function(u) return u~=nil and u:CanBeSeen() and not u.immune and not u.invulnerable and not u.illusion end
J.CanCastOnMagicImmune=function(u) return u~=nil and u:CanBeSeen() and not u.invulnerable and not u.illusion end
J.CanCastOnTargetAdvanced=function(u) return not u.blocked and not u.illusion and not u.mods.modifier_item_lotus_orb_active end
J.CanBeAttacked=function(u) return u~=nil and u:CanBeSeen() and not u.invulnerable and not u.attackImmune end
J.CanCastAbility=function(a) return a~=nil and a:IsFullyCastable() and a.trained end
J.CanNotUseAbility=function(u) return u.channel or u.using or u.silenced or u.queued or u.stunned or false end
J.IsRealInvisible=function(u) return u.invisible==true end
J.GetProperTarget=function(u) assert(u.kind=='hero','creeps do not have a hero target API');return u.target end
J.GetNearbyHeroes=function(u,r,enemy) assert(r<=1600);return nearby(enemy and enemies or allies,u,r) end
J.GetAlliesNearLoc=function(p,r)
    local out={};for _,u in pairs(allies) do if GetUnitToLocationDistance(u,p)<=r then out[#out+1]=u end end;return out
end
J.GetCorrectLoc=function(u,delay) return Vector(u.x+u.speed*delay,u.y+(u.yspeed or 0)*delay) end
J.CannotBeKilled=function(_,u) return u~=nil and u.protected==true end
J.WillKillTarget=function(u,damage,kind,delay) bot.killDamage=damage;bot.killDelay=delay;return u:GetActualIncomingDamage(damage,kind)>=u.hp+delay*(u.regen or 0) end
J.IsInRange=function(a,b,r) return GetUnitToUnitDistance(a,b)<=r end
J.IsInTeamFight=function() return bot.fight==true end
J.IsGoingOnSomeone=function(u) assert(u.kind=='hero');return u.mode=='attack' end
J.IsRetreating=function(u) return u.mode=='retreat' end
J.IsChasingTarget=function(a,b) return a.chasing==b end
J.IsDisabled=function(u) return u.disabled==true or u.stunned==true end
J.IsCastingUltimateAbility=function(u) return u.usingUlt==true end
J.IsCore=function(u) return u.core==true end
J.IsLaning=function() return bot.mode=='lane' end
J.IsFarming=function() return bot.mode=='farm' end
J.IsPushing=function() return bot.mode=='push' end
J.IsDefending=function() return bot.mode=='defend' end
J.IsDoingRoshan=function() return bot.mode=='roshan' end
J.IsDoingTormentor=function() return bot.mode=='tormentor' end
J.IsRoshan=function(u) return u~=nil and u.kind=='roshan' end
J.IsTormentor=function(u) return u~=nil and u.kind=='tormentor' end
J.IsAttacking=function(u) return u.attacking==true end
J.IsAllowedToSpam=function() return bot.spam~=false end
J.GetHP=function(u) return u.hp/u.maxhp end
local lens=ability('item_aether_lens',0,0,{cast_range_bonus=225})
local supremacy=ability('rubick_arcane_supremacy',0,0,{cast_range=240});supremacy.trained=false
local function reset()
    actions,enemies,allies,lane,ownLane,neutrals,items={},{},{},{},{},{},{}
    for k,value in pairs(unit(0)) do bot[k]=value end
    bot.team=2;bot.target=nil;bot.fight=false;bot.channel=false;bot.using=false;bot.queued=false;bot.stunned=false
    bot.silenced=false;bot.scepter=false;bot.invisible=false;bot.damaged=false;bot.spam=true;bot.attacking=false
    now=0
    for _,a in pairs(abilities) do a.castable=false;a.charges=4 end
    supremacy.trained=false
end

DAMAGE_TYPE_ALL=4
J.SetQueuePtToINT=function() end
J.IsItemAvailable=function() return bot.lens and lens or nil end
J.GetAttackProjectileDamageByRange=function(u) return u.projectileDamage or 0 end
J.CanKillTarget=function(u,d,k) return u:GetActualIncomingDamage(d,k)>=u.hp end
J.IsHaveAegis=function(u) return u.aegis==true end
local function decorate(u)
    function u:IsRooted() return self.rooted==true end
    function u:GetLevel() return 10 end
    function u:IsInvisible() return self.invisible==true end
    function u:GetHealthRegen() return self.regen or 0 end
    function u:GetEstimatedDamageToTarget(_,_,_,kind) return kind==DAMAGE_TYPE_PHYSICAL and (self.physThreat or 0) or (self.allThreat or 0) end
    return u
end
decorate(bot)
function bot:GetNearbyCreeps(r) return nearby(lane,self,r) end
function bot:ActionQueue_UseAbility(a) self:Action_UseAbility(a) end
function bot:ActionQueue_UseAbilityOnEntity(a,u) self:Action_UseAbilityOnEntity(a,u) end

local oldDecorate=decorate;decorate=function(u)
 oldDecorate(u)
 function u:IsDisarmed() return self.disarmed==true end
 function u:GetSecondsPerAttack() return self.spa or 2 end
 function u:GetCurrentMovementSpeed() return self.moveSpeed or 300 end
 function u:GetModifierByName() return 0 end
 function u:GetModifierRemainingDuration() return self.modRemaining or 4 end
 return u
end
decorate(bot)
function bot:IsNightmared() return self.nightmare==true end
function bot:IsAlive() return self.hp>0 end
function bot:IsStunned() return self.stunned==true end
function bot:IsHexed() return self.hexed==true end
function bot:IsCastingAbility() return self.casting==true end
function bot:IsUsingAbility() return self.using==true end
function bot:GetFacing() return self.facing or 0 end
function bot:IsFacingLocation() return self.facingTarget~=false end
J.HasQueuedAction=function(u) return u.queued==true end
J.IsStuck=function(u) return u.stuck==true end
J.GetEscapeLoc=function() return Vector(-3000,0) end
J.IsLocHaveTower=function(_,_,p) return bot.tower==true end
J.IsLocationInChrono=function() return bot.chrono==true end
J.IsLocationInBlackHole=function() return false end
function IsLocationPassable() return true end


J.HasAghanimsShard=function(u) return u.mods.modifier_item_aghanims_shard==true end
J.HasBreakModifier=function(u) return u.mods.modifier_viper_viper_strike_slow==true end
J.GetEnemiesNearLoc=function(p,r) local out={};for _,u in ipairs(enemies) do if GetUnitToLocationDistance(u,p)<=r then out[#out+1]=u end end;return out end
function bot:GetCurrentActiveAbility() return self.active end
local buildings={}
function bot:GetNearbyTowers(r) return nearby(buildings,self,r) end
function bot:GetNearbyBarracks() return {} end
function bot:Action_ClearActions(stop) assert(stop);actions[#actions+1]={name='clear'} end

-- Model the real handle gate, including unavailable linked spells.
J.CanCastAbility=function(a) return a~=nil and not a:IsNull() and not a:IsHidden() and not a:IsPassive() and a:IsTrained() and a:IsFullyCastable() and a:IsActivated() end
J.GetMP=function(u) return u.mana/u:GetMaxMana() end
J.GetCenterOfUnits=function(units) local p=Vector(0,0);for _,u in ipairs(units) do p=p+u:GetLocation() end;return p*(1/#units) end
J.IsItemAvailable=function(name) for _,i in pairs(items) do if i:GetName()==name then return i end end end
local oldAbility=ability
ability=function(...)
 local a=oldAbility(...)
 function a:IsNull() return self.null==true end
 function a:IsPassive() return self.passive==true end
 function a:IsActivated() return self.activated~=false end
 return a
end
local oldDecorate2=decorate
decorate=function(u)
 oldDecorate2(u)
 function u:IsBuilding() return self.kind=='building' end
 function u:IsHero() return self.kind=='hero' end
 function u:IsAncientCreep() return self.ancient==true end
 function u:GetFacing() return self.facing or 0 end
 return u
end
decorate(bot)
function bot:GetNearbyCreeps(r) return nearby(lane,self,r) end
function bot:ActionQueue_UseAbility(a) self:Action_UseAbility(a) end
function bot:ActionQueue_UseAbilityOnEntity(a,u) self:Action_UseAbilityOnEntity(a,u) end


ABILITY_BEHAVIOR_POINT=16
J.CheckBitfieldFlag=function(value,flag) return value==flag end
local remnant=ability('storm_spirit_static_remnant',800,100,{is_point_targeted=1,static_remnant_radius=235,static_remnant_damage_radius=300,static_remnant_delay=0.75,static_remnant_travel_speed=300,static_remnant_damage=280})
local vortex=ability('storm_spirit_electric_vortex',300,90,{radius_scepter=475},0.3)
local overload=ability('storm_spirit_overload',0,100,{shard_activation_radius=750})
local rave=ability('storm_spirit_electric_rave',0,100,{radius=750})
local ball=ability('storm_spirit_ball_lightning',0,30,{ball_lightning_initial_mana_base=25,ball_lightning_initial_mana_percentage=7.5,ball_lightning_travel_cost_base=10,ball_lightning_travel_cost_percent=0.65,ball_lightning_move_speed=2300},0.3)
function remnant:GetBehavior() return self.noPoint and 0 or ABILITY_BEHAVIOR_POINT end
function ball:IsInAbilityPhase() return self.phase==true end
function ball:GetCaster() return bot end
function bot:GetModifierSourceAbility() return self.flightSource end
local N=H.load('npc_dota_hero_storm_spirit','pos_2')
local R=require('bots/FunLib/rubick_hero/storm_spirit')
local oldReset=reset
reset=function()
 oldReset();bot.attackTarget=nil;bot.chrono=false;bot.tower=false;bot.invulnerable=false;bot.disarmed=false;bot.rooted=false;bot.stuck=false;bot.nightmare=false;bot.hexed=false;bot.casting=false;bot.flightSource=nil;bot.attackRange=480;ball.phase=false;remnant.noPoint=false;remnant.values.is_point_targeted=1
 for _,a in pairs(abilities) do a.null=false;a.hidden=false;a.passive=false;a.activated=true;a.trained=true end
 overload.passive=true;supremacy.trained=false
end
local function enemy(x,hp) local u=decorate(unit(x));u.hp=hp or 1000;enemies[#enemies+1]=u;return u end
local function friend(x) local u=decorate(unit(x));u.team=2;allies[#allies+1]=u;return u end
local function tick() actions={};N.SkillsComplement();return actions[1] end
local function cast(name) local a=tick();assert(a and a.name==name,'expected '..name..', got '..(a and a.name or 'nothing'));assert(#actions==1);return a end
local function noCast() assert(tick()==nil,'unexpected action') end
reset();remnant.castable=true;local foe=enemy(800,280);local a=cast(remnant.name);assert(a.point.x==800 and bot.killDelay==0.75+800/300);foe.regen=1;noCast();foe.regen=0;foe.x=1036;noCast();items[0]=lens;cast(remnant.name)
reset();remnant.castable=true;remnant.noPoint=true;remnant.values.is_point_targeted=0;foe=enemy(235,280);a=cast(remnant.name);assert(a.point==nil and bot.killDelay==0.75);foe.x=236;noCast()
reset();remnant.castable=true;bot.mode='farm';lane={decorate(unit(600,0,'creep')),decorate(unit(650,0,'creep'))};a=cast(remnant.name);assert(a.point.x==600 or a.point.x==650);lane={decorate(unit(600,0,'creep'))};noCast()
reset();vortex.castable=true;foe=enemy(300);foe.channel=true;a=cast(vortex.name);assert(a.target==foe);foe.x=301;noCast();items[0]=lens;cast(vortex.name);foe.blocked=true;noCast();foe.blocked=false;foe.immune=true;noCast()
reset();vortex.castable=true;bot.scepter=true;foe=enemy(475);foe.channel=true;a=cast(vortex.name);assert(a.target==nil);foe.x=476;noCast();items[0]=lens;noCast();foe.x=475;foe.blocked=true;cast(vortex.name)
reset();vortex.castable=true;foe=enemy(300);foe.channel=true;foe.mods.modifier_teleporting=true;foe.modRemaining=0.3;noCast();foe.modRemaining=0.4;cast(vortex.name)
reset();rave.castable=true;local ally=friend(750);foe=enemy(900);ally.attackTarget=foe;a=cast(rave.name);ally.x=751;noCast();ally.x=750;ally.disarmed=true;noCast();ally.disarmed=false;bot.mods.modifier_viper_viper_strike_slow=true;noCast();bot.mods={};bot.mods.modifier_storm_spirit_electric_rave=true;noCast()
reset();overload.castable=true;foe=enemy(400);bot.attackTarget=foe;noCast();overload.passive=false;assert(R.ConsiderStolenSpell(overload));overload.hidden=true;assert(not R.ConsiderStolenSpell(overload))
reset();ball.castable=true;bot.mode='attack';foe=enemy(1000);bot.target=foe;bot.mana=463;noCast();bot.mana=464;a=cast(ball.name);assert(a.point.x==1000);assert(R.BallCost(ball,1000)==265);bot.rooted=true;noCast();bot.rooted=false;bot.chrono=true;noCast()
reset();ball.castable=true;vortex.castable=true;remnant.castable=true;bot.mode='attack';foe=enemy(1200);bot.target=foe;bot.mana=686;noCast();bot.mana=687.1;cast(ball.name);bot.mods.modifier_storm_spirit_ball_lightning=true;bot.using=true;bot.invulnerable=true;noCast();bot.flightSource=ball;bot.x=1000;a=cast(vortex.name);assert(a.target==foe);bot.mods={};bot.using=false;bot.invulnerable=false;bot.x=1000;cast(vortex.name)
reset();ball.castable=true;bot.mode='retreat';bot.damaged=true;foe=enemy(100);bot.mana=215.4;noCast();bot.mana=215.5;a=cast(ball.name);assert(a.point.x==-700)
reset();bot.mods.modifier_storm_spirit_ball_lightning=true;bot.flightSource=ball;bot.invulnerable=true;remnant.castable=true;foe=enemy(100,280);a=cast(remnant.name);assert(a.point.x==100);bot.queued=true;noCast();bot.queued=false;bot.silenced=true;noCast();bot.silenced=false;bot.channel=true;noCast();bot.channel=false;bot.flightSource=nil;noCast()
for _,state in ipairs({'stunned','hexed','nightmare','silenced','channel','casting','queued'}) do
 reset();bot.mods.modifier_storm_spirit_ball_lightning=true;bot.flightSource=ball;remnant.castable=true;enemy(100,280);bot[state]=true;assert(not R.UseBallFlightSpells())
end
for _,modifier in ipairs({'modifier_ringmaster_the_box_buff','modifier_doom_bringer_doom','modifier_item_forcestaff_active'}) do
 reset();bot.mods.modifier_storm_spirit_ball_lightning=true;bot.flightSource=ball;remnant.castable=true;enemy(100,280);bot.mods[modifier]=true;assert(not R.UseBallFlightSpells())
end
reset();bot.queued=true;assert(not R.ConsiderStolenSpell(ball));bot.queued=false;ball.null=true;assert(not R.ConsiderStolenSpell(ball));ball.null=false;ball.activated=false;assert(not R.ConsiderStolenSpell(ball))
reset();ball.castable=true;bot.mode='attack';local foe=enemy(1000);bot.target=foe;cast(ball.name);bot.mods.modifier_puck_coiled=true;noCast()
local lookup=bot.GetAbilityByName
function bot:GetAbilityByName() error('unknown handler looked up linked spell') end
assert(R.ConsiderStolenSpell(ability('unrelated_spell',0,0))==nil)
bot.GetAbilityByName=lookup
print('Storm Spirit ability scenarios passed')
