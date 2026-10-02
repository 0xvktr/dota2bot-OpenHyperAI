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
local wards={}
function GetUnitList(kind) if kind==UNIT_LIST_ALLIES then return wards end;return enemies end
J.GetEnemiesNearLoc=function(p,r) local out={};for _,u in ipairs(enemies) do if GetUnitToLocationDistance(u,p)<=r then out[#out+1]=u end end;return out end
local oldDecorate=decorate;decorate=function(u)
 oldDecorate(u)
 function u:NumModifiers() return #(self.sources or {}) end
 function u:GetModifierSourceAbility(index) return self.sources[index+1] end
 function u:IsNull() return self.null==true end
 function u:IsAlive() return self.hp>0 end
 function u:GetPlayerID() return self.pid or 0 end
 function u:IsStunned() return self.stunned==true end
 function u:IsHexed() return self.hexed==true end
 function u:IsCastingAbility() return self.casting==true end
 function u:IsUsingAbility() return self.using==true end
 function u:NumQueuedActions() return self.queued and 1 or 0 end
 return u
end
decorate(bot)
local q=ability('venomancer_venomous_gale',800,125,{strike_damage=100,speed=1200,radius=125})
local w=ability('venomancer_snakebite',600,100,{base_damage=130},0.2)
local e=ability('venomancer_plague_ward',850,30)
local r=ability('venomancer_noxious_plague',900,300,{debuff_radius=700,damage_per_second=4},0.15)
local N=H.load('npc_dota_hero_venomancer','pos_5')
local oldReset=reset;reset=function() oldReset();wards={};bot.sources={};bot.tower=false;bot.chrono=false;bot.attackTarget=nil;for _,a in pairs(abilities) do a.null=false;a.hidden=false;a.activated=true end end
local function enemy(x,hp,y) local u=decorate(unit(x,y));u.hp=hp or 1000;enemies[#enemies+1]=u;return u end
local function tick() actions={};N.SkillsComplement();return actions[1] end
local function cast(name) local a=tick();assert(a and a.name==name,'expected '..name..', got '..(a and a.name or 'nothing'));return a end
local function noCast() assert(tick()==nil,'unexpected action') end
reset();q.castable=true;local foe=enemy(800,100);cast(q.name);foe.x=801;noCast();foe.x=700;foe.regen=1;noCast();foe.regen=0;foe.hp=101;noCast();bot.mode='attack';bot.target=foe;cast(q.name);foe.sources={q};noCast();foe.sources={};foe.speed=300;noCast();foe.speed=0;foe.immune=true;noCast()
reset();q.castable=true;bot.fight=true;local first=enemy(600);local second=enemy(-600);enemy(-700);assert(cast(q.name).point.x<0)
reset();q.castable=true;bot.mode='farm';lane={decorate(unit(400,0,'creep')),decorate(unit(600,0,'creep')),decorate(unit(800,0,'creep'))};cast(q.name);lane[3].y=500;noCast()
reset();w.castable=true;foe=enemy(600,130);assert(cast(w.name).target==foe);foe.x=601;noCast();items[0]=lens;cast(w.name);foe.hp=1000;foe.attackTarget=bot;foe.attackRange=650;cast(w.name);foe.sources={w};noCast();foe.sources={};foe.blocked=true;noCast()
reset();r.castable=true;foe=enemy(900,1);noCast();bot.mode='attack';bot.target=foe;assert(cast(r.name).target==foe);foe.sources={r};noCast();foe.sources={};foe.x=901;noCast();foe.x=900;foe.immune=true;noCast();foe.immune=false;foe.mods.modifier_item_lotus_orb_active=true;noCast()
reset();r.castable=true;bot.fight=true;first=enemy(800);second=enemy(-500);enemy(-600);enemy(-700);assert(cast(r.name).target==second)
local function ward(x)
 local u=decorate(unit(x,0,'ward'));u.team=2;u.name='npc_dota_venomancer_plague_ward_4';u.attackRange=600
 function u:GetNearbyHeroes(r) return nearby(enemies,self,r) end
 function u:GetNearbyCreeps() return {} end
 function u:GetNearbyTowers() return {} end
 function u:Action_AttackUnit(target) actions[#actions+1]={target=target,name='ward_attack'} end
 return u
end
reset();e.castable=true;bot.mode='attack';foe=enemy(1000);bot.target=foe;assert(cast(e.name).point.x==850);wards={ward(800),ward(850)};noCast();wards[2].hp=0;cast(e.name)
reset();e.castable=true;bot.mode='tormentor';local boss=decorate(unit(900,0,'tormentor'));bot.target=boss;bot.attacking=true;assert(cast(e.name).point.x==600);bot.attacking=false;noCast()
local R=require('bots/FunLib/rubick_hero/venomancer')
assert(R.ConsiderStolenSpell(ability('unrelated_spell',0,0))==nil)
reset();w.castable=true;foe=enemy(1065,130);items[0]=lens;supremacy.trained=true;abilities.venomancer_noxious_plague=nil;assert(R.ConsiderStolenSpell(w));abilities.venomancer_noxious_plague=r;bot.mods.modifier_break=true;assert(not R.ConsiderStolenSpell(w));bot.mods={};w.hidden=true;assert(not R.ConsiderStolenSpell(w))
reset();local own=ward(0);foe=enemy(600);actions={};assert(N.ConsiderPlagueWardMinion(own));assert(actions[1] and actions[1].target==foe);foe.x=601;actions={};N.ConsiderPlagueWardMinion(own);assert(#actions==0);foe.x=500;own.queued=true;N.ConsiderPlagueWardMinion(own);assert(#actions==0);own.queued=false;own.pid=1;assert(not R.ConsiderStolenPlagueWardMinion(own));own.pid=0;foe.visible=false;assert(R.ConsiderStolenPlagueWardMinion(own));assert(#actions==0);own.null=true;assert(not R.ConsiderStolenPlagueWardMinion(own))
reset();w.castable=true;local human=decorate(unit(100));human.team=2;human.mode='';human.damaged=true;allies={human};local hunter=enemy(400);hunter.chasing=human;cast(w.name);assert(R.ConsiderStolenSpell(w));human.damaged=false;noCast();assert(not R.ConsiderStolenSpell(w))
print('Venomancer ability scenarios passed')
