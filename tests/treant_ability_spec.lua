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
UNIT_LIST_ALLIED_HEROES,UNIT_LIST_ALLIED_BUILDINGS=4,5
J.CheckBitfieldFlag=function(value,flag) return math.floor(value/flag)%2==1 end
J.IsMeepoClone=function(u) return u.clone==true end
J.GetTeamFountain=function() return Vector(-8000,0) end
local trees,eyes,buildings={},{},{}
function GetUnitList(kind) if kind==UNIT_LIST_ALLIED_HEROES then return allies elseif kind==UNIT_LIST_ALLIED_BUILDINGS then return buildings elseif kind==UNIT_LIST_ALLIES then return eyes end;return enemies end
function bot:GetNearbyTrees(r) local out={};for id,p in pairs(trees) do if GetUnitToLocationDistance(self,p)<=r then out[#out+1]=id end end;return out end
function GetTreeLocation(id) return trees[id] end
function bot:ActionQueue_UseAbilityOnTree(a,id) actions[#actions+1]={name=a.name,tree=id} end
local oldDecorate3=decorate
decorate=function(u)
 oldDecorate3(u)
 function u:IsNull() return self.null==true end
 function u:IsAlive() return self.hp>0 end
 function u:GetPlayerID() return self.player==nil and 0 or self.player end
 return u
end
decorate(bot)
local oldAbility3=ability
ability=function(...)
 local a=oldAbility3(...)
 function a:GetBehavior() return self.behavior or DOTA_ABILITY_BEHAVIOR_UNIT_TARGET end
 return a
end
local armor=ability('treant_living_armor',0,80,{heal_per_second=13,duration=12,damage_block_base=120},0.3)
local seed=ability('treant_leech_seed',150,35,{leech_damage=80,flat_heal=45,radius=650,duration=0.75})
local grasp=ability('treant_natures_grasp',1500,90,{latch_range=135,initial_latch_delay=0.3,vine_spawn_interval=175,creation_interval=0.1},0.2)
local root=ability('treant_overgrowth',0,300,{radius=800},0.5)
local eye=ability('treant_eyes_in_the_forest',350,30,{vision_aoe=800},0.2)
local guise=ability('treant_natures_guise',0,0,{radius=200});guise.passive=true
local bloom=ability('treant_super_bloom',0,150,{},0.2)
local N=H.load('npc_dota_hero_treant','pos_5')
local R=dofile('bots/FunLib/rubick_hero/treant.lua')
local oldReset=reset
reset=function()
 oldReset();bot.lens=false;bot.disarmed=false;bot.projectile=false;bot.casting=false;bot.using=false;bot.invulnerable=false;bot.tower=false;bot.chrono=false
 bot.player=0;bot.target=nil;bot.treantEyePending=nil;trees,eyes,buildings={},{},{}
 for _,a in pairs(abilities) do a.null=false;a.hidden=false;a.activated=true;a.trained=true;a.behavior=DOTA_ABILITY_BEHAVIOR_UNIT_TARGET end
 supremacy.trained=false;guise.passive=true
end
local function enemy(x,hp) local u=decorate(unit(x));u.hp=hp or 1000;enemies[#enemies+1]=u;return u end
local function friend(x,kind) local u=decorate(unit(x,0,kind));u.team=2;allies[#allies+1]=u;return u end
local function building(x) local u=decorate(unit(x,0,'building'));u.team=2;buildings[#buildings+1]=u;return u end
local function ownEye(x) local u=decorate(unit(x,0,'ward'));u.name='npc_dota_treant_eyes';u.team=2;u.player=0;eyes[#eyes+1]=u;return u end
local function creep(x) local u=decorate(unit(x,0,'creep'));lane[#lane+1]=u;return u end
local function cast(name) actions={};N.SkillsComplement();assert(#actions==1,'expected exactly one '..name);assert(actions[1].name==name);return actions[1] end
local function noCast() actions={};N.SkillsComplement();assert(#actions==0,'unexpected cast '..(#actions>0 and actions[1].name or '')) end
reset();seed.castable=true;bot.mode='attack';bot.target=enemy(150);assert(cast(seed.name).target==bot.target);bot.target.x=151;noCast();items[0]=lens;cast(seed.name)
reset();seed.castable=true;bot.mode='attack';bot.target=enemy(100);bot.disarmed=true;noCast();bot.disarmed=false;bot.target.attackImmune=true;noCast();bot.target.attackImmune=false;bot.target.immune=true;noCast();bot.target.immune=false;bot.mods.modifier_viper_viper_strike_slow=true;noCast()
reset();seed.castable=true;local u=enemy(150,180);cast(seed.name);u.physical=0.5;noCast();u.hp=130;cast(seed.name);u.blocked=true;noCast()
reset();seed.castable=true;enemy(150).channel=true;cast(seed.name)
reset();seed.castable=true;local ally=friend(400);ally.hp=400;local u=creep(150);assert(cast(seed.name).target==u);ally.mods.modifier_ice_blast=true;noCast();ally.mods.modifier_ice_blast=false;ally.x=801;noCast()
reset();seed.castable=true;bot.mode='attack';bot.target=enemy(400);noCast()
reset();armor.castable=true;local ally=friend(7000);ally.hp=200;ally.damaged=true;bot.mode='attack';local core=friend(500);core.hp=500;assert(cast(armor.name).target==ally)
reset();armor.castable=true;local ally=friend(7000);ally.hp=200;ally.damaged=true;ally.mods.modifier_ice_blast=true;assert(cast(armor.name).target==ally);ally.damaged=false;noCast()
reset();armor.castable=true;local ally=friend(7000);ally.hp=500;assert(cast(armor.name).target==ally);ally.mods.modifier_fountain_aura=true;noCast();ally.mods.modifier_fountain_aura=false;ally.mods.modifier_treant_living_armor=true;noCast()
reset();armor.castable=true;local tower=building(7000);tower.hp=400;assert(cast(armor.name).target==tower);bot.mana=80;noCast();enemy(7100).attackTarget=tower;cast(armor.name)
reset();armor.castable=true;local ally=friend(7000);ally.hp=500;armor.behavior=DOTA_ABILITY_BEHAVIOR_POINT;assert(cast(armor.name).point.x==7000)
reset();armor.castable=true;bot.hp=200;bot.damaged=true;bot.mana=80;assert(cast(armor.name).target==bot)
reset();armor.castable=true;local ally=friend(7000);ally.hp=200;ally.illusion=true;noCast();ally.illusion=false;ally.clone=true;noCast();ally.clone=false;ally.mods.modifier_arc_warden_tempest_double=true;noCast()
reset();grasp.castable=true;bot.mode='attack';bot.target=enemy(1500);assert(cast(grasp.name).point.x==1500);bot.target.x=1636;noCast();items[0]=lens;cast(grasp.name)
reset();grasp.castable=true;bot.mode='attack';bot.target=enemy(700);bot.target.speed=100;assert(cast(grasp.name).point.x>800)
reset();grasp.castable=true;local ally=friend(900);enemy(1100).attackTarget=ally;cast(grasp.name);enemies[1].mods.modifier_treant_natures_grasp_damage=true;noCast()
reset();grasp.castable=true;bot.mode='farm';creep(300);creep(650);creep(1000);cast(grasp.name);bot.mana=389;noCast()
reset();grasp.castable=true;bot.mode='farm';creep(300);local u=creep(650);u.y=500;creep(1000);noCast()
reset();root.castable=true;local u=enemy(800);u.channel=true;u.immune=true;cast(root.name);u.x=801;noCast()
reset();root.castable=true;local u=enemy(790);u.channel=true;u.speed=30;noCast();u.speed=0;cast(root.name)
reset();root.castable=true;bot.mode='attack';bot.target=enemy(500);bot.target.immune=true;cast(root.name);bot.target.mods.modifier_treant_overgrowth=true;noCast();bot.target.mods.modifier_treant_overgrowth=false;bot.target.disabled=true;noCast()
reset();root.castable=true;local ally=friend(600);ally.hp=300;ally.damaged=true;enemy(500).attackTarget=ally;cast(root.name)
reset();root.castable=true;bot.fight=true;enemy(500);enemy(600);noCast();friend(700);cast(root.name)
reset();root.castable=true;local u=enemy(5000);u.channel=true;noCast();local e=ownEye(4700);cast(root.name);e.player=1;noCast();e.player=0;e.hp=0;noCast();e.hp=4;e.name='npc_dota_observer_wards';noCast()
reset();eye.castable=true;eye.charges=2;trees[1]=Vector(351,0);noCast();trees[1]=Vector(350,0);assert(cast(eye.name).tree==1);noCast();assert(R.ConsiderStolenSpell(eye)==false);now=4;cast(eye.name)
reset();eye.castable=true;eye.charges=0;trees[1]=Vector(300,0);noCast();eye.charges=1;cast(eye.name);bot.treantEyePending=nil;local e=ownEye(300);noCast();e.hp=0;cast(eye.name)
reset();eye.castable=true;trees[1]=Vector(300,0);local e=ownEye(300);e.player=1;noCast();e.player=-1;noCast();e.team=3;cast(eye.name)
reset();eye.castable=true;trees[1]=Vector(300,0);enemy(500);noCast();enemies={};bot.tower=true;noCast();bot.tower=false;bot.x=-7900;noCast()
reset();guise.castable=true;guise.behavior=DOTA_ABILITY_BEHAVIOR_NO_TARGET;bot.mode='retreat';noCast();guise.passive=false;cast(guise.name);bot.invisible=true;noCast();bot.invisible=false;guise.activated=false;noCast()
reset();armor.castable=true;bot.invisible=true;local ally=friend(5000);ally.hp=200;ally.damaged=true;cast(armor.name)
reset();bloom.castable=true;bot.mode='attack';bot.target=enemy(400);cast(bloom.name);bot.mods.modifier_treant_super_bloom=true;noCast();bot.mods.modifier_treant_super_bloom=false;bot.disarmed=true;noCast()
reset();bloom.castable=true;bot.mode='retreat';bot.hp=400;bot.damaged=true;cast(bloom.name);abilities[root.name]=nil;cast(bloom.name);abilities[root.name]=root
for _,name in ipairs({armor.name,seed.name,grasp.name,root.name,eye.name,guise.name,bloom.name}) do
 reset();local a=abilities[name];a.castable=true;a.hidden=true;assert(R.ConsiderStolenSpell(a)==false);a.hidden=false;a.activated=false;assert(R.ConsiderStolenSpell(a)==false);a.activated=true;a.null=true;assert(R.ConsiderStolenSpell(a)==false)
end
for _,state in ipairs({'queued','channel','using','stunned'}) do reset();root.castable=true;enemy(200).channel=true;bot[state]=true;noCast();assert(R.ConsiderStolenSpell(root)==false) end
reset();root.castable=true;enemy(200).channel=true;assert(R.ConsiderStolenSpell(root));assert(#actions==1)
reset();supremacy.trained=true;assert(R.Range(seed)==390);bot.mods.modifier_viper_viper_strike_slow=true;assert(R.Range(seed)==150)
local oldLookup,oldGate=bot.GetAbilityByName,J.CanNotUseAbility
bot.GetAbilityByName=function() error('unknown lookup') end;J.CanNotUseAbility=function() error('unknown gate') end
assert(R.ConsiderStolenSpell({GetName=function() return 'unknown' end})==nil)
bot.GetAbilityByName=oldLookup;J.CanNotUseAbility=oldGate
print('Treant native/copied focused scenarios passed')
