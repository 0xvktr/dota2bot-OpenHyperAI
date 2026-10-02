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
function GetUnitList(kind) assert(kind==UNIT_LIST_ENEMY_HEROES);return enemies end
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
    function a:GetSpecialValueInt(key) assert(self.values[key]~=nil,'unexpected ability key '..self.name..':'..key);return math.floor(self.values[key]) end
    function a:GetSpecialValueFloat(key) assert(self.values[key]~=nil,'unexpected ability key '..self.name..':'..key);return self.values[key] end
    function a:GetCurrentCharges() return self.charges end
    function a:GetLevel() return self.level or 4 end
    function a:GetAbilityDamage() return self.values.damage or 0 end
    function a:IsHidden() return self.hidden==true end
    function a:IsNull() return self.null==true end
    function a:IsActivated() return self.activated~=false end
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
J.CanCastAbility=function(a) return a~=nil and not a:IsNull() and not a:IsHidden() and a:IsActivated() and a:IsFullyCastable() and a.trained end
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


function bot:GetCurrentActiveAbility() return self.active end
function bot:GetAttackPoint() return 0.3 end
function bot:Action_AttackUnit(u,once) assert(once);actions[#actions+1]={name='pickup',target=u} end
local q=ability('tusk_ice_shards',1400,100,{shard_width=200,shard_speed=1200,shard_damage=300},0.1)
local snow=ability('tusk_snowball',1150,75)
local launch=ability('tusk_launch_snowball',0,0)
local tag=ability('tusk_tag_team',0,70,{radius=350})
local punch=ability('tusk_walrus_punch',150,75,{crit_multiplier=300,bonus_damage=120})
local buddies=ability('tusk_drinking_buddies',1000,80,{min_distance=250})
local N=H.load('npc_dota_hero_tusk','pos_4')
local oldReset=reset;reset=function() oldReset();bot.tuskSnowballTarget=nil;bot.tuskSnowballPurpose=nil;bot.tuskPickupTarget=nil;bot.tuskPickupIssuedAt=nil;bot.active=nil;bot.nightmare=false;bot.hexed=false;bot.casting=false;bot.rooted=false;bot.tower=false;bot.chrono=false;bot.disarmed=false;bot.yspeed=0;bot.projectileDamage=0;bot.attackTarget=nil;for _,a in pairs(abilities) do a.hidden=false;a.null=false;a.activated=true end end
local function enemy(x,hp) local u=decorate(unit(x));u.hp=hp or 1000;enemies[#enemies+1]=u;return u end
local function friend(x,hp) local u=decorate(unit(x));u.team=2;u.hp=hp or 1000;allies[#allies+1]=u;return u end
local function tick() actions={};N.SkillsComplement();return actions[1] end
local function cast(name) local a=tick();assert(a and a.name==name,'expected '..name..', got '..(a and a.name or 'nothing'));return a end
local function noCast() assert(tick()==nil,'unexpected action') end
reset();q.castable=true;local foe=enemy(1400,300);local a=cast(q.name);assert(a.point.x==1400 and math.abs(bot.killDelay-(0.1+1400/1200))<0.001);foe.x=1401;noCast();items[0]=lens;lens.null=true;noCast();lens.null=false;cast(q.name);foe.regen=1;noCast();foe.regen=0;foe.immune=true;noCast()
reset();q.castable=true;bot.mode='attack';foe=enemy(800);foe.speed=120;bot.target=foe;a=cast(q.name);assert(a.point.x>foe.x+100 and a.point.x<1100)
reset();q.castable=true;bot.mode='lane';lane={decorate(unit(700,0,'ranged'))};lane[1].hp=300;cast(q.name);lane[1].regen=1;noCast()
reset();snow.castable=true;bot.mode='retreat';bot.damaged=true;lane={decorate(unit(-800,0,'creep'))};a=cast(snow.name);assert(a.target==lane[1] and bot.tuskSnowballPurpose=='escape');bot.rooted=true;noCast();bot.rooted=false;lane[1].x=-1151;noCast()
reset();snow.castable=true;foe=enemy(1150);foe.channel=true;cast(snow.name);foe.x=1151;noCast();foe.x=1000;bot.tower=true;noCast()
reset();snow.castable=true;foe=enemy(800);local ally=friend(200,300);ally.damaged=true;a=cast(snow.name);assert(bot.tuskSnowballPurpose=='save')
bot.mods.modifier_tusk_snowball_movement=true;bot.invulnerable=true;launch.castable=true;a=cast('pickup');assert(a.target==ally);noCast();now=0.31;cast('pickup');ally.mods.modifier_tusk_snowball_movement_friendly=true;noCast();bot.tuskSnowballPurpose='attack';cast(launch.name);bot.nightmare=true;noCast();bot.nightmare=false;bot.queued=true;noCast();bot.queued=false;bot.channel=true;bot.active=q;noCast()
reset();punch.castable=true;foe=enemy(150,300);foe.immune=true;cast(punch.name);foe.x=151;noCast();items[0]=lens;noCast();foe.x=150;foe.attackImmune=true;noCast();foe.attackImmune=false;bot.disarmed=true;noCast()
reset();punch.castable=true;tag.castable=true;bot.mode='attack';foe=enemy(100);bot.target=foe;cast(tag.name);bot.mods.modifier_tusk_tag_team=true;cast(punch.name);bot.mods={};bot.mana=75;cast(punch.name)
reset();buddies.castable=true;bot.mode='retreat';bot.damaged=true;ally=friend(-1000);a=cast(buddies.name);assert(a.target==ally);ally.x=-1001;noCast();items[0]=lens;cast(buddies.name);ally.rooted=true;noCast();ally.rooted=false;bot.mods.modifier_tusk_snowball_movement=true;noCast()
local R=require('bots/FunLib/rubick_hero/tusk')
assert(R.ConsiderStolenSpell(ability('unrelated_spell',0,0))==nil)
reset();punch.castable=true;foe=enemy(150,300);abilities.tusk_tag_team=nil;assert(R.ConsiderStolenSpell(punch));abilities.tusk_tag_team=tag
reset();bot.mods.modifier_tusk_snowball_movement=true;bot.invulnerable=true;launch.castable=true;assert(R.ConsiderStolenSnowballContinuation());bot.silenced=true;assert(not R.ConsiderStolenSnowballContinuation());bot.silenced=false;launch.hidden=true;assert(not R.ConsiderStolenSnowballContinuation());launch.hidden=false;launch.null=true;assert(not R.ConsiderStolenSnowballContinuation());launch.null=false;launch.activated=false;assert(not R.ConsiderStolenSnowballContinuation());launch.activated=true;bot.mods={};assert(not R.ConsiderStolenSnowballContinuation())
reset();buddies.castable=true;local human=friend(100);human.mode='';human.attackTarget=enemy(150);assert(cast(buddies.name).target==human);assert(R.ConsiderStolenSpell(buddies));human.attackTarget=nil;noCast();assert(not R.ConsiderStolenSpell(buddies))
reset();snow.castable=true;bot.mode='retreat';bot.damaged=true;lane={decorate(unit(-800,0,'creep'))};bot.mods.modifier_puck_coiled=true;noCast();assert(not R.ConsiderStolenSpell(snow));bot.mods={};cast(snow.name)
reset();buddies.castable=true;bot.mode='retreat';bot.damaged=true;local coiled=friend(-1000);coiled.mods.modifier_puck_coiled=true;noCast();assert(not R.ConsiderStolenSpell(buddies));coiled.mods={};cast(buddies.name)
print('Tusk ability scenarios passed')
