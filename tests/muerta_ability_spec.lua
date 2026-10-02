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
    function a:GetLevel() return 4 end
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
J.HasBreakModifier=function(u) return u.broken==true end
J.HasQueuedAction=function(u) return u.queued end
J.IsStunProjectileIncoming=function(u) return u.projectile==true end
J.IsKeyWordUnit=function(word,u) return string.find(u:GetUnitName(),word)~=nil end
function bot:IsAlive() return self.hp>0 end
function bot:IsStunned() return self.stunned end
function bot:IsHexed() return self.hexed==true end
function bot:IsNightmared() return self.nightmared==true end
function bot:IsCastingAbility() return self.casting==true end
function bot:IsUsingAbility() return self.using end
function bot:IsDisarmed() return self.disarmed==true end
function bot:ActionQueue_UseAbility(a) actions[#actions+1]={name=a.name,queued=true} end
function bot:ActionQueue_UseAbilityOnEntity(a,u) assert(u~=nil);actions[#actions+1]={name=a.name,target=u,queued=true} end
local oldUnit=unit
unit=function(...) local u=oldUnit(...);function u:IsDisarmed() return self.disarmed==true end;return u end
local oldReset=reset
reset=function() oldReset();bot.hexed=false;bot.nightmared=false;bot.casting=false;bot.disarmed=false;bot.projectile=false end
local gun=ability('muerta_gunslinger',0,0,{});gun.toggle=false
function gun:GetToggleState() return self.toggle end
local dead=ability('muerta_dead_shot',1000,160,{damage=325,speed=2000},0.15)
local calling=ability('muerta_the_calling',600,180,{dead_zone_distance=340,hit_radius=120},0.1)
local veil=ability('muerta_pierce_the_veil',0,350,{},0.0)
local slug=ability('muerta_spectral_slug',500,75,{damage=225,projectile_speed=2500},0.1)
local C=dofile('bots/FunLib/rubick_hero/muerta.lua')
reset();gun.castable=true;bot.silenced=true;bot.invisible=true;assert(C.UseGunslinger());assert(actions[1].name==gun.name)
gun.castable=false;assert(not C.UseGunslinger(),'Inactive Gunslinger is not issued');gun.castable=true;gun.toggle=true;assert(not C.UseGunslinger());gun.toggle=false;bot.stunned=true;assert(not C.UseGunslinger());bot.stunned=false;bot.queued=true;assert(not C.UseGunslinger());bot.queued=false;bot.mods.modifier_doom_bringer_doom=true;assert(not C.UseGunslinger())
reset();dead.castable=true;local foe=unit(700);foe.hp=300;foe.physical=0.1;enemies={foe};assert(C.DeadShotTarget(dead)==foe,'Dead Shot damage is magical')
foe.hp=1000;foe.channel=true;assert(C.DeadShotTarget(dead)==nil,'Direct impact cannot promise fear interruption');bot.mode='retreat';foe.chasing=bot;assert(C.DeadShotTarget(dead)==foe,'Retreat uses actual chaser, not absent current target');foe.blocked=true;assert(C.DeadShotTarget(dead)==nil)
reset();veil.castable=true;bot.attackRange=575;bot.mode='attack';foe=unit(500);enemies={foe};bot.target=foe;assert(C.ShouldVeil(veil),'Committed solo ultimate is no longer disabled')
foe.immune=true;assert(not C.ShouldVeil(veil));foe.immune=false;bot.disarmed=true;assert(not C.ShouldVeil(veil));bot.disarmed=false;foe.mods.modifier_item_blade_mail_reflect=true;assert(not C.ShouldVeil(veil));bot.projectile=true;assert(C.ShouldVeil(veil),'Projectile defense independently justifies transform')
reset();calling.castable=true;bot.mode='attack';foe=unit(850);enemies={foe};bot.target=foe;local point=C.CallingPoint(calling);assert(point~=nil and math.abs(point.x-600)<0.01,'Calling center obeys true range while aura can reach further');foe.x=1150;assert(C.CallingPoint(calling)==nil)
reset();slug.castable=true;bot.mode='attack';foe=unit(450);enemies={foe};bot.target=foe;bot.attackRange=575;veil.trained=false;assert(C.SlugTarget(slug)==nil,'Copied Slug does not assume ethereal attack passive');veil.trained=true;assert(C.SlugTarget(slug)==foe);foe.blocked=true;assert(C.SlugTarget(slug)==nil);foe.blocked=false;foe.mods.modifier_muerta_spectral_slug_ethereal=true;assert(C.SlugTarget(slug)==nil)
print('muerta_ability_spec: 5 behavioral groups passed')
