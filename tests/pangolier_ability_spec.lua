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

function bot:GetFacing() return self.facing or 0 end
function bot:IsFacingLocation(p,angle)
    local dx,dy=p.x-self.x,p.y-self.y
    local desired=math.atan(dy,dx)*180/math.pi
    return math.abs((desired-self:GetFacing()+180)%360-180)<=angle
end
J.IsStuck=function(u) return u.stuck==true end
J.GetEscapeLoc=function() return Vector(-2000,0) end
J.IsLocHaveTower=function(_,_,p) return p.x>0 and bot.tower==true end
J.IsLocationInChrono=function(p) return bot.chrono==true end
J.IsLocationInBlackHole=function(p) return bot.blackhole==true end
function IsLocationPassable(p) return p.x<3000 end
J.IsOtherAllysTarget=function(u) return u.allyTarget==true end
J.IsUnitTargetProjectileIncoming=function(u) return u.incoming==true end
J.IsWillBeCastUnitTargetSpell=function(u) return u.incomingSpell==true end
local q=ability('pangolier_swashbuckle',800,100,{dash_range=800,range=850,damage=125,attack_damage=0,strikes=3,attack_interval=0.1,start_radius=155},0.15)
local w=ability('pangolier_shield_crash',0,75,{damage=240,radius=500,jump_duration=0.4,jump_duration_gyroshell=0.75,jump_horizontal_distance=225})
local r=ability('pangolier_gyroshell',0,150)
local stop=ability('pangolier_gyroshell_stop',0,0)
local up=ability('pangolier_rollup',0,75)
local upStop=ability('pangolier_rollup_stop',0,0)
local N=H.load('npc_dota_hero_pangolier','pos_2')
local oldReset=reset
reset=function()
    oldReset();bot.facing=0;bot.rooted=false;bot.stuck=false;bot.tower=false;bot.incoming=false;bot.incomingSpell=false;bot.chrono=false;bot.blackhole=false
end
local function enemy(x,hp,y) local u=decorate(unit(x,y));u.hp=hp or 1000;enemies[#enemies+1]=u;return u end
local function tick() actions={};N.SkillsComplement();return actions[1] end
local function cast(name) local a=tick();assert(a and a.name==name,'expected '..name);return a end
local function noCast() assert(tick()==nil,'unexpected action') end
reset();q.castable=true;local foe=enemy(1600,350);foe.immune=true;local a=cast(q.name);assert(a.point.x<=800)
foe.y=156;noCast();foe.y=0;foe.mods.modifier_item_blade_mail_reflect=true;noCast();foe.mods={};bot.rooted=true;noCast();bot.rooted=false;bot.mods.modifier_bloodseeker_rupture=true;noCast()
reset();q.castable=true;bot.mode='retreat';bot.damaged=true;a=cast(q.name);assert(a.point.x==-800)
bot.mods.modifier_pangolier_gyroshell=true;noCast()
reset();q.castable=true;bot.mode='lane';lane={unit(600,0,'ranged'),unit(700,170,'ranged')};for _,u in ipairs(lane) do u.hp=300 end
noCast();lane[2].y=155;cast(q.name)
reset();w.castable=true;foe=enemy(725,200);cast(w.name);foe.x=726;noCast();foe.x=725;foe.immune=true;noCast()
foe.immune=false;foe.physical=0;noCast();foe.physical=1;bot.mods.modifier_pangolier_gyroshell=true;noCast();foe.x=500;cast(w.name)
reset();r.castable=true;bot.mode='attack';foe=enemy(900);bot.target=foe;cast(r.name);bot.rooted=true;noCast();bot.rooted=false;bot.mods.modifier_slark_pounce_leash=true;noCast()
reset();r.castable=true;up.castable=true;bot.mode='attack';foe=enemy(600);bot.target=foe;cast(up.name)
bot.mods.modifier_pangolier_rollup=true;cast(r.name)
reset();stop.castable=true;bot.mods.modifier_pangolier_gyroshell=true;bot.mode='retreat';noCast()
bot.mods.modifier_bloodseeker_rupture=true;cast(stop.name)
reset();upStop.castable=true;bot.mods.modifier_pangolier_rollup=true;bot.mode='retreat';cast(upStop.name);bot.incoming=true;noCast()
reset();upStop.castable=true;bot.mods.modifier_pangolier_rollup=true;bot.mods.modifier_pangolier_gyroshell=true;foe=enemy(600);bot.target=foe;cast(upStop.name)
bot.facing=180;noCast()
local R=require('bots/FunLib/rubick_hero/pangolier')
assert(R.ConsiderStolenSpell(ability('unrelated_spell',0,0))==nil)
reset();w.castable=true;foe=enemy(725,200);assert(R.ConsiderStolenSpell(w));bot.channel=true;assert(not R.ConsiderStolenSpell(w))
reset();up.castable=true;bot.incoming=true;abilities.pangolier_gyroshell=nil;assert(R.ConsiderStolenSpell(up))
print('Pangolier ability scenarios passed')
