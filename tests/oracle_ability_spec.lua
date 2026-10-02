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
    function a:GetSpecialValueInt(key) assert(self.values[key]~=nil,'unexpected ability key '..self.name..':'..key);return self.values[key] end
    a.GetSpecialValueFloat=a.GetSpecialValueInt
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

function bot:GetCurrentActiveAbility() return self.activeAbility end
function bot:NumQueuedActions() return self.queued and 1 or 0 end
function bot:Action_ClearActions(stop) assert(stop==false);actions[#actions+1]={name='release'} end
J.GetModifierTime=function(u,m) return u.modTime and u.modTime[m] or 0 end
J.IsUnitTargetProjectileIncoming=function(u) return u.incoming==true end
J.IsWillBeCastUnitTargetSpell=function(u) return u.incomingSpell==true end
J.IsKeyWordUnit=function(key,u) return string.find(u:GetUnitName(),key)~=nil end
J.IsOtherAllysTarget=function(u) return u.allyTarget==true end
local function hero(u)
    function u:IsHero() return self.kind=='hero' end
    function u:IsDisarmed() return self.disarmed==true end
    function u:GetIncomingTrackingProjectiles() return self.projectiles or {} end
    return decorate(u)
end
hero(bot)
local q=ability('A1',850,80,{damage=280,bolt_speed=1200,channel_time=2.5},0)
local w=ability('A2',700,70,{duration=5},0.3)
local e=ability('A3',850,75,{damage=360,damage_modifier=1,heal_per_second=45,total_heal_tooltip=450},0.1)
local r=ability('A6',900,200)
local rain=ability('oracle_rain_of_destiny',650,150,{radius=650},0.2)
local N=H.load('npc_dota_hero_oracle','pos_5')
local oldReset=reset
reset=function()
    oldReset();bot.lens=false;bot.activeAbility=nil;bot.oracleFortuneTarget=nil;bot.oracleFortuneChannelStart=nil
end
local function enemy(x,hp) local u=hero(unit(x));u.hp=hp or 1000;enemies[#enemies+1]=u;return u end
local function ally(x,hp) local u=hero(unit(x));u.team=2;u.hp=hp or 1000;allies[#allies+1]=u;return u end
local function tick() actions={};N.SkillsComplement();return actions[1] end
local function cast(name,target) local a=tick();assert(a and a.name==name and (not target or a.target==target),'expected '..name);return a end
local function noCast() assert(tick()==nil,'unexpected action') end
reset();r.castable=true;local friend=ally(900,300);friend.damaged=true;cast('A6',friend)
friend.x=901;noCast();bot.lens=true;cast('A6',friend);friend.mods.modifier_oracle_false_promise_timer=true;noCast()
reset();w.castable=true;friend=ally(700);friend.mods.modifier_necrolyte_reapers_scythe=true;cast('A2',friend)
friend.immune=true;noCast();friend.immune=false;friend.x=701;noCast();bot.lens=true;cast('A2',friend)
reset();w.castable=true;e.castable=true;friend=ally(700,500);cast('A2',friend);friend.mods.modifier_oracle_fates_edict=true;cast('A3',friend)
friend.mods.modifier_ice_blast=true;noCast()
reset();e.castable=true;friend=ally(850,1000);friend.mods.modifier_oracle_false_promise_timer=true;friend.modTime={modifier_oracle_false_promise_timer=8};cast('A3',friend)
friend.modTime.modifier_oracle_false_promise_timer=1;noCast();friend.mods.modifier_oracle_fates_edict=true;cast('A3',friend)
friend.immune=true;noCast()
reset();e.castable=true;local foe=enemy(850,300);cast('A3',foe);foe.x=851;noCast();bot.lens=true;cast('A3',foe)
foe.x=500;foe.hp=1000;bot.mode='attack';bot.target=foe;noCast();q.castable=true;cast('A3',foe)
foe.mods.modifier_oracle_purifying_flames=true;cast('A1',foe)
foe.mods.modifier_oracle_fates_edict=true;e.castable=true;q.castable=false;noCast()
reset();q.castable=true;friend=ally(850);friend.silenced=true;cast('A1',friend);friend.silenced=false;friend.mods.modifier_batrider_flaming_lasso=true;noCast()
-- Own Fortune channel has an observed target and elapsed-time bound; unrelated channels and queues stay protected.
reset();q.castable=true;foe=enemy(600);bot.target=foe;bot.mode='attack';cast('A1',foe)
local realQ=ability('oracle_fortunes_end',850,80,{damage=280,bolt_speed=1200,channel_time=2.5})
bot.channel=true;bot.activeAbility=realQ;noCast();now=1.3;cast('release')
reset();q.castable=true;foe=enemy(500);foe.mods.modifier_oracle_purifying_flames=true;cast('A1',foe)
bot.channel=true;bot.activeAbility=realQ;noCast();now=0.1;cast('release')
reset();bot.channel=true;bot.activeAbility=ability('other_channel',0,0);bot.oracleFortuneTarget=foe;now=4;noCast()
bot.activeAbility=realQ;bot.queued=true;noCast()
reset();rain.castable=true;bot.fight=true;foe=enemy(1100);enemy(1200);local a=cast(rain.name);assert(a.point.x==650)
reset();rain.castable=true;bot.fight=true;friend=ally(500,300);friend.mods.modifier_oracle_false_promise_timer=true;foe=enemy(600);cast(rain.name)
local R=require('bots/FunLib/rubick_hero/oracle')
assert(R.ConsiderStolenSpell(ability('unrelated_spell',0,0))==nil)
-- Lone stolen Flames cannot assume Fortune/Edict; it can still deliver a guaranteed lethal nuke.
reset();local flame=ability('oracle_purifying_flames',850,75,{damage=360,damage_modifier=1,heal_per_second=45,total_heal_tooltip=450},0.1);flame.castable=true
abilities.oracle_fortunes_end=nil;foe=enemy(800);bot.mode='attack';bot.target=foe;assert(not R.ConsiderStolenSpell(flame))
foe.hp=300;assert(R.ConsiderStolenSpell(flame));foe.blocked=true;assert(not R.ConsiderStolenSpell(flame))
print('Oracle ability scenarios passed')
