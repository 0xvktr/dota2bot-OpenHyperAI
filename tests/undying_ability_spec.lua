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



UNIT_LIST_ALLIES=3
local stones={}
function GetUnitList(kind) return kind==UNIT_LIST_ALLIES and stones or enemies end
J.HasAghanimsShard=function(u) return u.mods.modifier_item_aghanims_shard==true end
J.GetEnemiesNearLoc=function(p,r) local out={};for _,u in ipairs(enemies) do if GetUnitToLocationDistance(u,p)<=r then out[#out+1]=u end end;return out end
local oldDecorate=decorate;decorate=function(u)
 oldDecorate(u)
 function u:IsNull() return self.null==true end
 function u:IsAlive() return self.hp>0 end
 function u:IsBuilding() return self.kind=='building' end
 function u:IsStunned() return self.stunned==true end
 function u:IsHexed() return self.hexed==true end
 function u:IsUsingAbility() return self.using==true end
 function u:IsCastingAbility() return self.casting==true end
 function u:NumQueuedActions() return self.queued and 1 or 0 end
 function u:GetPlayerID() return self.player or 0 end
 return u
end
decorate(bot)
function bot:GetNearbyCreeps(r,enemy) return nearby(enemy and lane or ownLane,self,r) end
local q=ability('undying_decay',650,110,{radius=325,decay_damage=140,creep_damage_multiplier=2},0.3)
local w=ability('undying_soul_rip',750,110,{radius=1300,damage_per_unit=50,max_units=10,tombstone_heal=16},0.3)
local e=ability('undying_tombstone',500,200,{radius=1200,hits_to_destroy_tooltip=8},0.6)
local r=ability('undying_flesh_golem',0,150)
local grab=ability('undying_tombstone_unit_grab',1200,0)
local N=H.load('npc_dota_hero_undying','pos_5')
local oldReset=reset;reset=function() oldReset();stones={};bot.tower=false;bot.chrono=false;bot.disarmed=false;bot.null=false;for _,a in pairs(abilities) do a.null=false;a.hidden=false;a.activated=true end end
local function enemy(x,hp) local u=decorate(unit(x));u.hp=hp or 1000;enemies[#enemies+1]=u;return u end
local function friend(x,hp) local u=decorate(unit(x));u.team=2;u.hp=hp or 1000;allies[#allies+1]=u;return u end
local function pack(n,x,team) local list=team==2 and ownLane or lane;for i=1,n do local u=decorate(unit(x+i,0,'creep'));u.team=team or 3;list[#list+1]=u end end
local function stone(x)
 local u=decorate(unit(x,0,'building'));u.name='npc_dota_unit_undying_tombstone';u.hp=20;u.maxhp=32;u.team=2
 function u:GetAbilityByName(name) return name=='undying_tombstone_unit_grab' and grab or nil end
 function u:Action_UseAbilityOnEntity(a,t) actions[#actions+1]={name=a.name,target=t} end
 stones[#stones+1]=u;return u
end
local function tick() actions={};N.SkillsComplement();return actions[1] end
local function cast(name) local a=tick();assert(a and a.name==name,'expected '..name..', got '..(a and a.name or 'nothing'));return a end
local function noCast() assert(tick()==nil,'unexpected action') end
reset();w.castable=true;local foe=enemy(750,250);pack(3,100);pack(2,200,2);local a=cast(w.name);assert(a.target==foe and bot.killDamage==250);foe.x=751;noCast();items[0]=lens;lens.null=true;noCast();lens.null=false;cast(w.name)
reset();w.castable=true;foe=enemy(500,510);pack(30,100);noCast();assert(bot.killDamage==500);foe.hp=500;cast(w.name);for _,u in ipairs(lane) do u.immune=true end;noCast()
reset();w.castable=true;local ally=friend(750,200);pack(3,100);pack(2,200,2);a=cast(w.name);assert(a.target==ally);ally.mods.modifier_ice_blast=true;noCast();ally.mods={};ally.immune=true;cast(w.name);ally.x=751;noCast()
reset();w.castable=true;bot.hp=400;pack(2,100);a=cast(w.name);assert(a.target==bot);for _,u in ipairs(lane) do u.invisible=true end;noCast()
reset();w.castable=true;local tomb=stone(750);foe=enemy(800);foe.attackTarget=tomb;a=cast(w.name);assert(a.target==tomb);tomb.x=751;noCast();tomb.x=750;tomb.hp=32;noCast()
reset();q.castable=true;foe=enemy(975,140);a=cast(q.name);assert(a.point.x==650);foe.x=976;noCast();foe.x=975;foe.immune=true;noCast()
reset();q.castable=true;bot.mode='lane';lane={decorate(unit(700,0,'ranged'))};lane[1].hp=280;cast(q.name);lane[1].regen=1;noCast()
reset();e.castable=true;bot.mods.modifier_item_aghanims_shard=true;ally=friend(500,200);ally.mods.modifier_legion_commander_duel=true;a=cast(e.name);assert(a.target==ally);ally.x=501;noCast();items[0]=lens;cast(e.name);local foe2=enemy(500);foe2.spa=0.2;foe2.attackRange=600;noCast()
reset();e.castable=true;bot.fight=true;enemy(500);enemy(600);a=cast(e.name);assert(a.point.x==-500);stone(-500);noCast();stones={};bot.tower=true;noCast()
reset();r.castable=true;bot.mode='attack';foe=enemy(500);bot.target=foe;bot.attacking=true;cast(r.name);bot.mods.modifier_undying_flesh_golem=true;noCast();bot.mods={};bot.disarmed=true;noCast();bot.disarmed=false;bot.mode='retreat';bot.hp=300;bot.damaged=true;cast(r.name)
local R=require('bots/FunLib/rubick_hero/undying')
assert(R.ConsiderStolenSpell(ability('unrelated_spell',0,0))==nil)
reset();w.castable=true;foe=enemy(500,150);pack(3,100);abilities.undying_tombstone=nil;assert(R.ConsiderStolenSpell(w));abilities.undying_tombstone=e
reset();grab.castable=true;tomb=stone(100);ally=friend(450,200);ally.damaged=true;assert(R.ConsiderStolenTombstoneMinion(tomb));ally.x=451;assert(not R.ConsiderStolenTombstoneMinion(tomb));ally.x=450;tomb.player=1;assert(not R.ConsiderStolenTombstoneMinion(tomb));tomb.player=0;grab.hidden=true;assert(not R.ConsiderStolenTombstoneMinion(tomb));grab.hidden=false;tomb.queued=true;assert(not R.ConsiderStolenTombstoneMinion(tomb));tomb.queued=false;grab.null=true;assert(not R.ConsiderStolenTombstoneMinion(tomb))
print('Undying ability scenarios passed')
