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


UNIT_LIST_ALLIED_HEROES,UNIT_LIST_ENEMY_CREEPS,UNIT_LIST_NEUTRAL_CREEPS=4,5,6
function GetUnitList(kind) if kind==UNIT_LIST_ALLIED_HEROES then return allies elseif kind==UNIT_LIST_ENEMY_CREEPS then return lane elseif kind==UNIT_LIST_NEUTRAL_CREEPS then return neutrals end;return enemies end
J.IsUnitTargetProjectileIncoming=function(u) return u.projectile==true end
local charge=ability('spirit_breaker_charge_of_darkness',0,110,{movement_speed=425,windup_time=1.5,bash_radius=300},0.1)
local bulldoze=ability('spirit_breaker_bulldoze',0,60)
local bash=ability('spirit_breaker_greater_bash',0,0,{damage=40})
local nether=ability('spirit_breaker_nether_strike',700,175,{damage=350},1)
local pocket=ability('spirit_breaker_planar_pocket',700,100,{break_distance=900})
function charge:GetCaster() return bot end
function charge:IsInAbilityPhase() return self.phase==true end
function bot:GetModifierSourceAbility() return self.chargeSource end
local N=H.load('npc_dota_hero_spirit_breaker','pos_3')
local R=require('bots/FunLib/rubick_hero/spirit_breaker')
local oldReset2=reset
reset=function()
 oldReset2();bot.attackTarget=nil;bot.invulnerable=false;bot.passable=true;bot.tower=false;bot.chrono=false;bot.disarmed=false;bot.rooted=false;bot.stuck=false;bot.nightmare=false;bot.hexed=false;bot.casting=false;bot.projectile=false;bot.spiritBreakerEscapeStart=nil;bot.chargeSource=nil;charge.phase=false;bot.attackRange=150
 for _,a in pairs(abilities) do a.null=false;a.hidden=false;a.passive=false;a.activated=true;a.trained=true end
 supremacy.trained=false
end
local function enemy(x,hp) local u=decorate(unit(x));u.hp=hp or 1000;enemies[#enemies+1]=u;return u end
local function friend(x) local u=decorate(unit(x));u.team=2;allies[#allies+1]=u;return u end
local function tick() actions={};N.SkillsComplement();return actions[1] end
local function cast(name) local a=tick();assert(a and a.name==name,'expected '..name..', got '..(a and a.name or 'nothing'));assert(#actions==1);return a end
local function noCast() assert(tick()==nil,'unexpected action') end
reset();charge.castable=true;bot.mode='farm';local foe=enemy(5000);local ally=friend(4900);ally.attackTarget=foe;local a=cast(charge.name);assert(a.target==foe);ally.attackTarget=nil;noCast();ally.attackTarget=foe;foe.immune=true;noCast();foe.immune=false;foe.blocked=true;noCast();foe.blocked=false;bot.rooted=true;noCast()
reset();charge.castable=true;bot.mode='attack';foe=enemy(1200);bot.target=foe;local first=enemy(600);friend(1100);a=cast(charge.name);assert(a.target==foe);bot.tower=true;noCast()
reset();charge.castable=true;bot.mode='farm';lane={decorate(unit(500,0,'creep')),decorate(unit(600,0,'creep')),decorate(unit(700,0,'creep'))};a=cast(charge.name);assert(a.target==lane[3]);assert(a.target~=nil);abilities.spirit_breaker_greater_bash=nil;noCast();abilities.spirit_breaker_greater_bash=bash
reset();charge.castable=true;bot.mode='retreat';bot.hp=300;foe=enemy(100);local wrong=decorate(unit(2500,0,'creep'));local right=decorate(unit(-2500,0,'creep'));lane={wrong,right};a=cast(charge.name);assert(a.target==right and bot.spiritBreakerEscapeStart.x==0);right.visible=false;noCast()
reset();charge.castable=true;bulldoze.castable=true;bot.mode='attack';foe=enemy(1000);bot.target=foe;a=cast(bulldoze.name);assert(#actions==1);bot.mods.modifier_spirit_breaker_bulldoze=true;a=cast(charge.name);assert(a.target==foe)
reset();charge.castable=true;foe=enemy(500);foe.channel=true;foe.mods.modifier_teleporting=true;foe.modRemaining=2;noCast();foe.modRemaining=3;cast(charge.name)
reset();bot.mods.modifier_spirit_breaker_charge_of_darkness=true;bot.chargeSource=charge;bot.using=true;bulldoze.castable=true;a=cast(bulldoze.name);bot.mods.modifier_spirit_breaker_bulldoze=true;noCast();assert(R.IsCharging());nether.castable=true;foe=enemy(500,10);assert(not R.ConsiderStolenSpell(nether));bot.mods.modifier_spirit_breaker_bulldoze=nil;bot.queued=true;noCast();bot.queued=false;bot.silenced=true;noCast();bot.silenced=false;bot.channel=true;noCast();bot.channel=false;bot.nightmare=true;noCast();bot.nightmare=false;bot.chargeSource=nil;noCast()
-- Charge support bypasses only the observed own charge, retaining every other occupied state.
for _,state in ipairs({'stunned','hexed','nightmare','silenced','invulnerable','channel','casting','queued'}) do
 reset();bot.mods.modifier_spirit_breaker_charge_of_darkness=true;bot.chargeSource=charge;bulldoze.castable=true;bot[state]=true
 assert(not R.UseChargeSupport() and #actions==0,state..' should block support')
end
for _,modifier in ipairs({'modifier_ringmaster_the_box_buff','modifier_doom_bringer_doom','modifier_item_forcestaff_active'}) do
 reset();bot.mods.modifier_spirit_breaker_charge_of_darkness=true;bot.chargeSource=charge;bulldoze.castable=true;bot.mods[modifier]=true
 assert(not R.UseChargeSupport() and #actions==0)
end
reset();bot.mods.modifier_spirit_breaker_charge_of_darkness=true;bot.chargeSource=charge;bulldoze.castable=true;bot.hp=0;assert(not R.UseChargeSupport())
reset();bot.mods.modifier_spirit_breaker_charge_of_darkness=true;bot.chargeSource=charge;bulldoze.castable=true;bulldoze.hidden=true;assert(not R.UseChargeSupport())
reset();bot.mods.modifier_spirit_breaker_charge_of_darkness=true;bot.chargeSource=charge;bot.spiritBreakerEscapeStart=Vector(0,0);bot.x=-1200;a=cast('clear');assert(bot.spiritBreakerEscapeStart==nil)
reset();bulldoze.castable=true;bot.mode='retreat';foe=enemy(800);foe.chasing=bot;cast(bulldoze.name);bot.mods.modifier_spirit_breaker_bulldoze=true;noCast()
reset();nether.castable=true;foe=enemy(700,470);a=cast(nether.name);assert(a.target==foe and bot.killDamage==470 and bot.killDelay==1);foe.x=701;noCast();items[0]=lens;cast(nether.name);foe.regen=1;noCast();foe.regen=0;bot.mods.modifier_viper_viper_strike_slow=true;cast(nether.name);foe.immune=true;cast(nether.name);foe.mods.modifier_item_lotus_orb_active=true;noCast()
reset();nether.castable=true;foe=enemy(700);foe.channel=true;cast(nether.name);abilities.spirit_breaker_greater_bash=nil;noCast();foe.hp=350;cast(nether.name);abilities.spirit_breaker_greater_bash=bash;foe.hp=1000;foe.mods.modifier_teleporting=true;foe.modRemaining=1;noCast();foe.modRemaining=1.1;cast(nether.name)
reset();pocket.castable=true;ally=friend(700);ally.projectile=true;a=cast(pocket.name);assert(a.target==ally);ally.x=701;noCast();items[0]=lens;cast(pocket.name);ally.x=901;noCast();ally.x=700;ally.mods.modifier_spirit_breaker_planar_pocket_aura=true;noCast();ally.mods={};bot.hp=500;noCast()
reset();pocket.castable=true;bot.projectile=true;a=cast(pocket.name);assert(a.target==bot);bot.mods.modifier_spirit_breaker_planar_pocket=true;noCast()
reset();charge.phase=true;nether.castable=true;foe=enemy(500,10);noCast();assert(R.IsCharging());charge.phase=false;bot.queued=true;noCast();bot.queued=false;bot.channel=true;noCast()
reset();charge.castable=true;bot.mode='attack';foe=enemy(1000);bot.target=foe;abilities.spirit_breaker_bulldoze=nil;abilities.spirit_breaker_greater_bash=nil;assert(R.ConsiderStolenSpell(charge));abilities.spirit_breaker_bulldoze=bulldoze;abilities.spirit_breaker_greater_bash=bash;charge.hidden=true;assert(not R.ConsiderStolenSpell(charge));charge.hidden=false;charge.null=true;assert(not R.ConsiderStolenSpell(charge));charge.null=false;charge.activated=false;assert(not R.ConsiderStolenSpell(charge));charge.activated=true;charge.trained=false;assert(not R.ConsiderStolenSpell(charge))
reset();charge.castable=true;bot.mode='attack';local foe=enemy(1000);bot.target=foe;cast(charge.name);bot.mods.modifier_puck_coiled=true;noCast()
local oldLookup=bot.GetAbilityByName
function bot:GetAbilityByName() error('unknown handler looked up linked spell') end
assert(R.ConsiderStolenSpell(ability('unrelated_spell',0,0))==nil)
bot.GetAbilityByName=oldLookup
print('Spirit Breaker ability scenarios passed')
