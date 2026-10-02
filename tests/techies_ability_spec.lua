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


UNIT_LIST_ALLIED_HEROES=4
local deployed={}
function GetUnitList(kind) return kind==UNIT_LIST_ALLIES and deployed or kind==UNIT_LIST_ALLIED_HEROES and allies or enemies end
J.IsLaning=function(u) return u.mode=='lane' end
J.GetETAWithAcceleration=function(distance,speed,acceleration) return (math.sqrt(speed*speed+2*acceleration*distance)-speed)/acceleration end
local bomb=ability('techies_sticky_bomb',1000,145,{radius=300,explosion_radius=350,damage=320,speed=500,acceleration=2000,countdown=2},0.1)
local tazer=ability('techies_reactive_tazer',600,60,{explosion_radius=400},0.1)
local stop=ability('techies_reactive_tazer_stop',0,0)
local blast=ability('techies_suicide',1000,175,{radius=400,damage=500,hp_cost=20,duration=0.75},1)
local mines=ability('techies_land_mines',450,170,{radius=500,placement_radius=350,min_distance=150,outer_damage=50,damage=700,activation_delay=1,proximity_threshold=1})
local sign=ability('techies_minefield_sign',10,0,{aura_radius=1000,trigger_radius=200},1.25)
local mad=ability('techies_mutually_assured_destruction',450,0,{radius=400,explosion_delay=1.5},1)
local detonate=ability('techies_focused_detonate',0,0)
function tazer:GetCaster() return bot end
local N=H.load('npc_dota_hero_techies','pos_4')
local R=require('bots/FunLib/rubick_hero/techies')
local oldReset=reset
reset=function()
 oldReset();deployed={};bot.attackTarget=nil;bot.invulnerable=false;bot.disarmed=false;bot.rooted=false;bot.chrono=false;bot.tower=false;bot.stuck=false;bot.nightmare=false;bot.hexed=false;bot.casting=false;bot.techiesMinePending=nil;bot.techiesMADPending=nil;bot.attackRange=600
 for _,a in pairs(abilities) do a.null=false;a.hidden=false;a.passive=false;a.activated=true;a.trained=true end
 supremacy.trained=false
end
local function entity(x,kind,name)
 local u=decorate(unit(x,0,kind));u.name=name
 function u:IsNull() return self.null==true end
 function u:IsAlive() return self.hp>0 end
 function u:GetPlayerID() return self.player or 0 end
 function u:GetModifierSourceAbility() return self.source end
 return u
end
local function enemy(x,hp) local u=entity(x,'hero');u.hp=hp or 1000;enemies[#enemies+1]=u;return u end
local function friend(x) local u=entity(x,'hero');u.team=2;allies[#allies+1]=u;return u end
local function mine(x,name) local u=entity(x,'creep',name or 'npc_dota_techies_land_mine');u.team=2;deployed[#deployed+1]=u;return u end
local function tick() actions={};N.SkillsComplement();return actions[1] end
local function cast(name) local a=tick();assert(a and a.name==name,'expected '..name..', got '..(a and a.name or 'nothing'));assert(#actions==1);return a end
local function noCast() assert(tick()==nil,'unexpected action') end
reset();bomb.castable=true;local foe=enemy(1000,320);local a=cast(bomb.name);assert(a.point.x==1000 and bot.killDelay>2.1);foe.regen=1;noCast();foe.regen=0;foe.x=1301;noCast();items[0]=lens;cast(bomb.name)
reset();bomb.castable=true;bot.mode='attack';foe=enemy(1000);bot.target=foe;foe.speed=1000;noCast();foe.speed=0;cast(bomb.name);foe.immune=true;noCast();foe.immune=false;foe.mods.modifier_nyx_assassin_spiked_carapace=true;noCast()
reset();bomb.castable=true;local ally=friend(800);ally.damaged=true;foe=enemy(900);foe.attackTarget=ally;cast(bomb.name)
reset();bomb.castable=true;bot.mode='farm';neutrals={entity(500,'creep'),entity(600,'creep')};cast(bomb.name);neutrals={entity(500,'creep')};noCast()
reset();tazer.castable=true;ally=friend(600);foe=enemy(700);foe.attackTarget=ally;a=cast(tazer.name);assert(a.target==ally);ally.x=601;noCast();items[0]=lens;cast(tazer.name);ally.mods.modifier_techies_reactive_tazer=true;noCast();ally.mods={};ally.illusion=true;noCast();ally.illusion=false;foe.disarmed=true;noCast()
reset();stop.castable=true;ally=friend(1500);ally.mods.modifier_techies_reactive_tazer=true;ally.source=tazer;foe=enemy(1600);a=cast(stop.name);assert(a.target==nil);ally.source=nil;noCast();ally.source=tazer;foe.disarmed=true;noCast();foe.disarmed=false;abilities.techies_reactive_tazer=nil;noCast();abilities.techies_reactive_tazer=tazer
reset();blast.castable=true;bot.mode='attack';foe=enemy(1000);bot.target=foe;a=cast(blast.name);assert(a.point.x==1000);bot.rooted=true;noCast();bot.rooted=false;bot.hp=300;noCast();bot.hp=1000;bot.chrono=true;noCast();bot.chrono=false;bot.tower=true;noCast()
reset();blast.castable=true;foe=enemy(1000);foe.channel=true;foe.mods.modifier_teleporting=true;foe.modRemaining=1.75;noCast();foe.modRemaining=1.76;cast(blast.name)
reset();blast.castable=true;tazer.castable=true;bot.mode='attack';foe=enemy(1000);bot.target=foe;a=cast(tazer.name);assert(a.target==bot);bot.mods.modifier_techies_reactive_tazer=true;cast(blast.name);bot.using=true;noCast();bot.using=false
reset();blast.castable=true;bot.mode='retreat';bot.damaged=true;bot.hp=100;foe=enemy(100);a=cast(blast.name);assert(a.point.x==-1000);bot.mods.modifier_bloodseeker_rupture=true;noCast()
reset();mines.castable=true;bot.mode='attack';foe=enemy(450,700);bot.target=foe;a=cast(mines.name);assert(a.point.x==450 and bot.killDelay==2);assert(bot.techiesMinePending[1].point.x==450);foe.disabled=true;mine(450);a=cast(mines.name);assert((a.point-Vector(450,0)):Length2D()>350 and GetUnitToLocationDistance(bot,a.point)<=450);mines.charges=0;noCast()
reset();mines.castable=true;bot.mode='attack';foe=enemy(950,351);bot.target=foe;noCast();foe.x=949;foe.hp=350;a=cast(mines.name);assert(math.abs(a.point.x-450)<0.001 and bot.killDamage==350);foe.regen=1;noCast();foe.regen=0;foe.hp=351;noCast()
reset();mines.castable=true;bot.mode='farm';neutrals={entity(300,'creep'),entity(350,'creep'),entity(400,'creep')};cast(mines.name);mines.charges=1;noCast();mines.charges=3;bot.mana=405;noCast();bot.mana=406;now=4;cast(mines.name)
reset();mines.castable=true;bot.mode='defend';a=cast(mines.name);assert(a.point.x==0);assert(R.MinePoint(mines,Vector(0,0))~=nil);now=4;assert(R.MinePoint(mines,Vector(0,0)).x==0)
reset();sign.castable=true;mine(500);mine(700);a=cast(sign.name);assert(a.point.x==0);bot.mods.modifier_techies_minefield_sign_aura=true;noCast();bot.mods={};sign.hidden=true;noCast()
reset();mad.castable=true;mad.passive=true;bot.mode='attack';foe=enemy(600);foe.disabled=true;noCast();mad.passive=false;a=cast(mad.name);assert(a.point.x==450 and bot.techiesMADPending==3);noCast();now=4;cast(mad.name);mine(450,'npc_dota_techies_innate_mine');noCast()
reset();detonate.castable=true;mad.passive=false;local barrel=mine(1000,'npc_dota_techies_innate_mine');foe=enemy(1400);cast(detonate.name);foe.x=1401;noCast();foe.x=1400;foe.speed=100;noCast();foe.speed=0;barrel.player=1;noCast();barrel.player=0;barrel.hp=0;noCast();barrel.hp=200;abilities.techies_mutually_assured_destruction=nil;noCast();abilities.techies_mutually_assured_destruction=mad
reset();bomb.castable=true;foe=enemy(500,1);bot.queued=true;noCast();bot.queued=false;bot.channel=true;noCast();bot.channel=false;bomb.null=true;assert(not R.ConsiderStolenSpell(bomb));bomb.null=false;bomb.hidden=true;assert(not R.ConsiderStolenSpell(bomb));bomb.hidden=false;bomb.activated=false;assert(not R.ConsiderStolenSpell(bomb));bomb.activated=true;bomb.trained=false;assert(not R.ConsiderStolenSpell(bomb))
reset();blast.castable=true;bot.mode='attack';local foe=enemy(1000);bot.target=foe;cast(blast.name);bot.mods.modifier_puck_coiled=true;noCast()
local lookup=bot.GetAbilityByName
function bot:GetAbilityByName() error('unknown handler looked up linked spell') end
assert(R.ConsiderStolenSpell(ability('unrelated_spell',0,0))==nil)
bot.GetAbilityByName=lookup
print('Techies ability scenarios passed')
