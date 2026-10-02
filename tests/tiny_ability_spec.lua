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


DOTA_ABILITY_BEHAVIOR_UNIT_TARGET,DOTA_ABILITY_BEHAVIOR_POINT,DOTA_ABILITY_BEHAVIOR_NO_TARGET=8,16,4
J.CheckBitfieldFlag=function(value,flag) return math.floor(value/flag)%2==1 end
J.IsNotAttackProjectileIncoming=function(u) return u.projectile==true end
local trees={}
function bot:GetNearbyTrees(r) local out={};for id,p in pairs(trees) do if GetUnitToLocationDistance(self,p)<=r then out[#out+1]=id end end;return out end
function GetTreeLocation(id) return trees[id] end
function bot:ActionQueue_UseAbilityOnTree(a,id) actions[#actions+1]={name=a.name,tree=id} end
function bot:GetModifierSourceAbility() return self.treeSource end
function bot:GetModifierStackCount() return self.treeCharges or 5 end
function bot:GetNearbyCreeps(r,enemy) return nearby(enemy and lane or ownLane,self,r) end
local oldAbility3=ability
ability=function(...)
 local a=oldAbility3(...)
 function a:GetCaster() return self.caster or bot end
 function a:GetBehavior() return self.behavior or DOTA_ABILITY_BEHAVIOR_UNIT_TARGET end
 return a
end
local avalanche=ability('tiny_avalanche',600,150,{radius=370,projectile_speed=1200,total_duration=1.5,avalanche_damage=360})
local toss=ability('tiny_toss',1100,125,{grab_radius=300,radius=275,toss_damage=360,duration=1.1})
local grab=ability('tiny_tree_grab',200,25,{attack_range=300},0.2)
local throw=ability('tiny_toss_tree',1000,0,{speed=900},0.2)
local volley=ability('tiny_tree_channel',1200,150,{tree_grab_radius=700,speed=1000},0.2)
local grow=ability('tiny_grow',0,0,{toss_bonus_damage=350});grow.passive=true
local N=H.load('npc_dota_hero_tiny','pos_1')
local R=dofile('bots/FunLib/rubick_hero/tiny.lua')
local oldReset=reset
reset=function()
 oldReset();bot.lens=false;bot.treeSource=nil;bot.treeCharges=5;bot.disarmed=false;bot.rooted=false;bot.projectile=false;bot.casting=false
 bot.using=false;bot.invulnerable=false;bot.tower=false;bot.chrono=false;bot.target=nil;trees={}
 for _,a in pairs(abilities) do a.null=false;a.hidden=false;a.activated=true;a.trained=true;a.behavior=DOTA_ABILITY_BEHAVIOR_UNIT_TARGET end
 supremacy.trained=false;grow.trained=true
end
local function enemy(x,hp) local u=decorate(unit(x));u.hp=hp or 1000;enemies[#enemies+1]=u;return u end
local function friend(x,kind) local u=decorate(unit(x,0,kind));u.team=2;allies[#allies+1]=u;return u end
local function creep(x,own) local u=decorate(unit(x,0,'creep'));u.team=own and 2 or 3;local group=own and ownLane or lane;group[#group+1]=u;return u end
local function cast(name) actions={};N.SkillsComplement();assert(#actions==1,'expected exactly one '..name);assert(actions[1].name==name);return actions[1] end
local function noCast() actions={};N.SkillsComplement();assert(#actions==0,'unexpected cast '..(#actions>0 and actions[1].name or '')) end
reset();avalanche.castable=true;bot.mode='attack';bot.target=enemy(970);assert(cast(avalanche.name).point.x==600);bot.target.x=971;noCast()
reset();avalanche.castable=true;local u=enemy(500,360);cast(avalanche.name);assert(math.abs(bot.killDelay-(1.5+500/1200))<0.001);u.regen=1;noCast()
reset();avalanche.castable=true;local u=enemy(500,360);u.speed=300;noCast();u.channel=true;cast(avalanche.name)
reset();avalanche.castable=true;local ally=friend(400);enemy(500).attackTarget=ally;cast(avalanche.name)
reset();avalanche.castable=true;enemy(500).immune=true;noCast()
reset();toss.castable=true;bot.mode='attack';local u=enemy(250);bot.target=u;cast(toss.name);friend(100);noCast()
reset();toss.castable=true;bot.mode='attack';local u=enemy(250);bot.target=u;creep(100,true);assert(cast(toss.name).target==u)
reset();toss.castable=true;bot.mode='attack';bot.target=enemy(250);creep(-250);noCast()
reset();toss.castable=true;local u=enemy(200);u.channel=true;u.blocked=true;noCast();u.blocked=false;cast(toss.name)
reset();toss.castable=true;enemy(301).channel=true;noCast();enemies[1].x=300;cast(toss.name)
reset();toss.castable=true;local u=enemy(250,710);cast(toss.name);assert(bot.killDelay==1.1);u.regen=1;noCast();u.regen=0;grow.trained=false;noCast();grow.trained=true;abilities[grow.name]=nil;noCast();abilities[grow.name]=grow
reset();toss.castable=true;local ally=friend(100);ally.hp=300;ally.damaged=true;local anchor=friend(-1000);assert(cast(toss.name).target==anchor);ally.channel=true;noCast();ally.channel=false;bot.tower=true;noCast()
reset();toss.castable=true;local ally=friend(100);ally.hp=300;ally.damaged=true;friend(-1101);noCast();items[0]=lens;cast(toss.name)
reset();toss.castable=true;bot.mode='retreat';local u=enemy(200);u.chasing=bot;local anchor=friend(-900);assert(cast(toss.name).target==anchor)
reset();toss.castable=true;toss.behavior=DOTA_ABILITY_BEHAVIOR_NO_TARGET;local u=enemy(200);u.channel=true;assert(cast(toss.name).target==nil);enemies={};local ally=friend(100);ally.hp=200;ally.damaged=true;friend(-900);noCast()
reset();avalanche.castable=true;toss.castable=true;bot.mode='attack';bot.target=enemy(250);cast(avalanche.name);avalanche.castable=false;cast(toss.name);avalanche.castable=true;bot.target.channel=true;cast(toss.name)
reset();grab.castable=true;bot.mode='attack';bot.target=enemy(400);trees[1]=Vector(201,0);noCast();trees[1]=Vector(200,0);assert(cast(grab.name).tree==1);bot.disarmed=true;noCast()
reset();grab.castable=true;bot.mode='attack';bot.target=enemy(400);trees[1]=Vector(425,0);items[0]=lens;cast(grab.name);bot.mods.modifier_tiny_tree_grab=true;noCast()
reset();throw.castable=true;bot.mode='attack';bot.target=enemy(1000);noCast();bot.mods.modifier_tiny_tree_grab=true;noCast();bot.treeSource=grab;cast(throw.name);bot.target.x=1001;noCast()
reset();throw.castable=true;bot.mods.modifier_tiny_tree_grab=true;bot.treeSource=grab;local u=enemy(800,100);cast(throw.name);assert(math.abs(bot.killDelay-(0.2+800/900))<0.001);u.regen=1;noCast();u.regen=0;u.attackImmune=true;noCast();u.attackImmune=false;u.immune=true;noCast()
reset();throw.castable=true;bot.mods.modifier_tiny_tree_grab=true;bot.treeSource=grab;enemy(150,100);noCast();bot.treeCharges=1;cast(throw.name);grab.caster=friend(1000);noCast();grab.caster=nil
reset();throw.castable=true;bot.mods.modifier_tiny_tree_grab=true;bot.treeSource=grab;bot.mode='attack';bot.target=enemy(700);abilities[grab.name]=nil;cast(throw.name);abilities[grab.name]=grab
reset();volley.castable=true;bot.scepter=true;bot.mode='attack';bot.target=enemy(1200);trees[1]=Vector(100,0);trees[2]=Vector(200,0);assert(cast(volley.name).point.x==1200);bot.target.x=1201;noCast();bot.target.x=1100;bot.target.immune=true;cast(volley.name);bot.target.attackImmune=true;noCast()
reset();volley.castable=true;bot.mode='attack';bot.target=enemy(1000);trees[1]=Vector(100,0);noCast();trees[2]=Vector(200,0);cast(volley.name);bot.projectile=true;noCast();bot.projectile=false;bot.damaged=true;noCast();bot.damaged=false;enemy(700);noCast()
for _,name in ipairs({avalanche.name,toss.name,grab.name,throw.name,volley.name}) do
 reset();local a=abilities[name];a.castable=true;a.hidden=true;assert(R.ConsiderStolenSpell(a)==false);a.hidden=false;a.activated=false;assert(R.ConsiderStolenSpell(a)==false);a.activated=true;a.null=true;assert(R.ConsiderStolenSpell(a)==false)
end
for _,state in ipairs({'queued','channel','using','stunned'}) do reset();toss.castable=true;enemy(200).channel=true;bot[state]=true;noCast();assert(R.ConsiderStolenSpell(toss)==false) end
reset();toss.castable=true;enemy(200).channel=true;assert(R.ConsiderStolenSpell(toss));assert(#actions==1)
reset();supremacy.trained=true;assert(R.Range(grab)==440);bot.mods.modifier_viper_viper_strike_slow=true;assert(R.Range(grab)==200)
reset();toss.castable=true;local ally=friend(100);ally.hp=300;ally.damaged=true;friend(-1000);cast(toss.name);ally.mods.modifier_puck_coiled=true;noCast();ally.mods.modifier_puck_coiled=nil;ally.mods.modifier_bloodseeker_rupture=true;noCast()
local oldLookup,oldGate=bot.GetAbilityByName,J.CanNotUseAbility
bot.GetAbilityByName=function() error('unknown lookup') end;J.CanNotUseAbility=function() error('unknown gate') end
assert(R.ConsiderStolenSpell({GetName=function() return 'unknown' end})==nil)
bot.GetAbilityByName=oldLookup;J.CanNotUseAbility=oldGate
print('Tiny native/copied focused scenarios passed')
