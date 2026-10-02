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


DAMAGE_TYPE_PURE,UNIT_LIST_ALLIED_HEROES,LANE_MID,DOTA_ABILITY_BEHAVIOR_UNIT_TARGET,DOTA_ABILITY_BEHAVIOR_POINT=4,4,1,8,16
local anchors={}
function GetUnitList(kind) if kind==UNIT_LIST_ALLIES then return anchors elseif kind==UNIT_LIST_ALLIED_HEROES then return allies end;return enemies end
J.IsNotAttackProjectileIncoming=function(u) return u.projectile==true end
J.CheckBitfieldFlag=function(value,flag) return math.floor(value/flag)%2==1 end
J.GetTeamFountain=function() return Vector(-8000,0) end
J.GetMostFarmLaneDesire=function() return 1,bot.farmDesire or 0 end
function GetLaneFrontLocation() return Vector(5000,0) end
local oldAbility3=ability
ability=function(...)
 local a=oldAbility3(...)
 function a:IsInAbilityPhase() return self.phase==true end
 function a:GetCooldownTimeRemaining() return self.cd or 0 end
 function a:GetChannelTime() return self.channelTime or 0 end
 function a:GetBehavior() return self.behavior or DOTA_ABILITY_BEHAVIOR_POINT end
 return a
end
local laser=ability('tinker_laser',600,125,{laser_damage=300,radius_explosion=0},0.4)
local march=ability('tinker_march_of_the_machines',300,160,{radius=900,duration=6,heal_per_second=35},0.53)
local turrets=ability('tinker_deploy_turrets',600,160,{drop_aoe_radius=250,drop_delay=0.5,drop_knockback_distance_tinker=400,drop_damage=160,missile_target_range=800},0.1)
local warp=ability('tinker_warp_grenade',700,80,{damage=150},0.2)
local rearm=ability('tinker_rearm',0,200);rearm.channelTime=1.25
local tp=ability('tinker_keen_teleport',0,75);tp.channelTime=3;tp.level=1
local N=H.load('npc_dota_hero_tinker','pos_2')
local R=require('bots/FunLib/rubick_hero/tinker')
local oldReset3=reset
reset=function()
 oldReset3();anchors={};bot.attackTarget=nil;bot.attackRange=500;bot.invulnerable=false;bot.disarmed=false;bot.rooted=false;bot.nightmare=false;bot.hexed=false;bot.casting=false;bot.projectileDamage=0;bot.projectile=false;bot.stuck=false;bot.tower=false;bot.chrono=false;bot.healInBase=false;bot.farmDesire=0
 bot.tinkerMarchPending=nil;bot.tinkerMarchZones=nil
 for _,a in pairs(abilities) do a.null=false;a.hidden=false;a.passive=false;a.activated=true;a.trained=true;a.cd=0;a.phase=false end
 supremacy.trained=false;tp.level=1;tp.behavior=DOTA_ABILITY_BEHAVIOR_POINT;laser.values.radius_explosion=0
end
local function enemy(x,hp) local u=decorate(unit(x));u.hp=hp or 1000;enemies[#enemies+1]=u;return u end
local function friend(x) local u=decorate(unit(x));u.team=2;allies[#allies+1]=u;return u end
local function anchor(x,kind)
 local u=decorate(unit(x,0,kind));u.team=2
 function u:IsNull() return self.null==true end
 function u:IsAlive() return self.hp>0 end
 function u:IsCreep() return self.kind=='creep' end
 anchors[#anchors+1]=u;return u
end
local function creep(x,hp,name) local u=decorate(unit(x,0,'creep'));u.hp=hp or 1000;u.name=name or 'npc_dota_creep_melee';lane[#lane+1]=u;return u end
local function tick() actions={};N.SkillsComplement();return actions[1] end
local function cast(name) local a=tick();assert(a and a.name==name,'expected '..name..', got '..(a and a.name or 'nothing'));assert(#actions==1);return a end
local function noCast() assert(tick()==nil,'unexpected action') end
reset();laser.castable=true;bot.mode='attack';bot.target=enemy(600);cast(laser.name);bot.target.x=601;noCast();items[0]=lens;bot.target.x=825;cast(laser.name);bot.target.x=826;noCast()
reset();laser.castable=true;local u=enemy(600,300);cast(laser.name);u.regen=1;noCast();u.regen=0;u.blocked=true;noCast();u.blocked=false;u.immune=true;noCast()
reset();laser.castable=true;enemy(500).attackTarget=friend(600);cast(laser.name);enemies[1].mods.modifier_tinker_laser_blind=true;noCast()
reset();laser.castable=true;bot.mode='lane';creep(600,200,'npc_dota_creep_ranged');cast(laser.name);bot.mana=199;noCast()
reset();laser.castable=true;bot.mode='push';creep(500,200);creep(550,200);noCast();laser.values.radius_explosion=250;cast(laser.name)
reset();march.castable=true;bot.mode='attack';bot.target=enemy(1200);cast(march.name);assert(actions[1].point.x==300);assert(#bot.tinkerMarchZones==0,'request was incorrectly confirmed')
noCast();now=4;cast(march.name);assert(#bot.tinkerMarchZones==0,'canceled queue created a live zone')
march.cd=29;bot.queued=true;noCast();assert(#bot.tinkerMarchZones==1 and bot.tinkerMarchPending==nil);bot.queued=false;march.cd=0;noCast();now=11;cast(march.name)
reset();march.castable=true;bot.mode='attack';bot.target=enemy(1201);noCast();items[0]=lens;cast(march.name);assert(actions[1].point.x==525)
reset();march.castable=true;bot.scepter=true;local ally=friend(700);ally.hp=400;cast(march.name);ally.mods.modifier_ice_blast=true;bot.tinkerMarchPending=nil;noCast()
reset();march.castable=true;local ally=friend(700);ally.hp=400;noCast()
reset();march.castable=true;bot.mode='farm';creep(700);creep(900);cast(march.name);assert(actions[1].point.x==300)
reset();turrets.castable=true;bot.mode='attack';bot.target=enemy(1400);cast(turrets.name);assert(actions[1].point.x==600);bot.target.x=1401;noCast()
reset();turrets.castable=true;local u=enemy(700,160);cast(turrets.name);assert(bot.killDelay==0.6);u.regen=1;noCast()
reset();turrets.castable=true;bot.mode='push';bot.target=decorate(unit(500,0,'building'));noCast();bot.mode='roshan';bot.target=decorate(unit(500,0,'roshan'));noCast()
reset();turrets.castable=true;bot.mode='retreat';bot.damaged=true;enemy(400);friend(-500);cast(turrets.name);assert(actions[1].point.x==150)
bot.rooted=true;noCast();bot.rooted=false;bot.mods.modifier_bloodseeker_rupture=true;noCast()
reset();turrets.castable=true;bot.mode='attack';bot.target=enemy(100);friend(-500);bot.mods.modifier_puck_coiled=true;noCast()
reset();warp.castable=true;local u=enemy(700);u.chasing=bot;cast(warp.name);u.x=701;noCast();u.x=700;u.blocked=true;noCast();u.blocked=false;u.mods.modifier_tinker_warp_grenade=true;noCast()
reset();warp.castable=true;local ally=friend(500);ally.hp=300;ally.damaged=true;enemy(400).attackTarget=ally;cast(warp.name)
reset();rearm.castable=true;bot.mode='farm';laser.cd=16;cast(rearm.name);bot.mana=324;noCast();bot.mana=325;cast(rearm.name);laser.cd=1;noCast()
reset();rearm.castable=true;bot.mode='farm';noCast();items[0]=ability('item_blink',1200,0);items[0].cd=10;noCast()
reset();rearm.castable=true;bot.mode='attack';march.cd=29;enemy(600);noCast();enemies={};bot.projectile=true;noCast();bot.projectile=false;bot.damaged=true;noCast()
reset();tp.castable=true;bot.mana=200;local base=anchor(-7900,'building');cast(tp.name);assert(actions[1].point.x==-7900)
tp.behavior=DOTA_ABILITY_BEHAVIOR_UNIT_TARGET;cast(tp.name);assert(actions[1].target==base);bot.rooted=true;noCast();bot.rooted=false;bot.mods.modifier_kunkka_x_marks_the_spot=true;noCast()
reset();tp.castable=true;bot.mana=200;anchor(-7900,'creep');noCast();tp.level=2;cast(tp.name)
reset();tp.castable=true;bot.mana=200;anchor(-7900,'hero');noCast();tp.level=3;cast(tp.name);anchors[1].hp=0;noCast()
reset();tp.castable=true;bot.mana=200;noCast();anchor(-7900,'building').team=3;noCast()
reset();tp.castable=true;tp.level=3;local ally=anchor(5000,'hero');allies[1]=ally;ally.attackTarget=enemy(5800);cast(tp.name);assert(actions[1].point.x==5000);ally.speed=100;enemies[1].x=5500;noCast()
for _,name in ipairs({rearm.name,tp.name}) do
 reset();laser.castable=true;bot.mode='attack';bot.target=enemy(400);abilities[name].phase=true;noCast();assert(R.ConsiderStolenSpell(laser)==false)
end
for _,m in ipairs({'modifier_tinker_rearm','modifier_teleporting'}) do reset();laser.castable=true;bot.mode='attack';bot.target=enemy(400);bot.mods[m]=true;noCast() end
reset();laser.castable=true;bot.mode='attack';bot.target=enemy(400);assert(R.ConsiderStolenSpell(laser));assert(#actions==1)
for _,field in ipairs({'hidden','null','passive'}) do reset();laser.castable=true;laser[field]=true;bot.mode='attack';bot.target=enemy(400);assert(R.ConsiderStolenSpell(laser)==false) end
for _,state in ipairs({'queued','channel','using','stunned'}) do reset();laser.castable=true;bot[state]=true;bot.mode='attack';bot.target=enemy(400);noCast();assert(R.ConsiderStolenSpell(laser)==false) end
reset();supremacy.trained=true;assert(R.Range(laser)==840);bot.mods.modifier_viper_viper_strike_slow=true;assert(R.Range(laser)==600)
reset();march.castable=true;bot.mode='attack';bot.target=enemy(1000);cast(march.name);local replacement=ability(march.name,300,160,{radius=900,duration=6,heal_per_second=35},0.53);replacement.cd=29;bot.queued=true;noCast();assert(bot.tinkerMarchPending==nil and #bot.tinkerMarchZones==0);abilities[march.name]=march
local oldLookup,oldGate=bot.GetAbilityByName,J.CanNotUseAbility
bot.GetAbilityByName=function() error('unknown lookup') end;J.CanNotUseAbility=function() error('unknown gate') end
assert(R.ConsiderStolenSpell({GetName=function() return 'unknown' end})==nil)
bot.GetAbilityByName=oldLookup;J.CanNotUseAbility=oldGate
print('Tinker native/copied focused scenarios passed')
