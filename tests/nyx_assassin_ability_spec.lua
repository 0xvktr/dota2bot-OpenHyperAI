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

DAMAGE_TYPE_PURE=4
function bot:IsDisarmed() return self.disarmed==true end
J.GetMP=function(u) return u.mana/1000 end
J.GetLocationToLocationDistance=function(a,b) return (a-b):Length2D() end
J.IsUnitTargetProjectileIncoming=function(u) return u.incoming==true end
J.IsWillBeCastUnitTargetSpell=function(u) return u.incomingSpell==true end
local impale=ability('nyx_assassin_impale',750,120,{impale_damage=280,speed=1600,width=140,duration=2},0.3)
local mind=ability('nyx_assassin_jolt',800,115,{max_mana_as_damage_pct=40,aoe=0,damage_echo_pct=15,damage_echo_duration=15},0.4)
local carapace=ability('nyx_assassin_spiked_carapace',0,40)
local burrow=ability('nyx_assassin_burrow',0,0,{cast_range=500,carapace_radius=400},1.5)
local unburrow=ability('nyx_assassin_unburrow',0,0)
local vendetta=ability('nyx_assassin_vendetta',0,180,{bonus_damage=300})
for _,name in ipairs({'A1','A2','A3','A4','A5','A6','T1','T2','T3','T4','T5','T6','T7','T8'}) do ability(name,0,0) end
local N=H.load('npc_dota_hero_nyx_assassin','pos_4')
local oldReset=reset
reset=function() oldReset();bot.incoming=false;bot.incomingSpell=false;bot.rooted=false;bot.disarmed=false end
local function enemy(x,hp) local u=decorate(unit(x));u.hp=hp or 1000;enemies[#enemies+1]=u;return u end
local function tick() actions={};N.SkillsComplement();return actions[1] end
local function cast(name,target) local a=tick();assert(a and a.name==name and (not target or a.target==target),'expected '..name);return a end
local function noCast() assert(tick()==nil,'unexpected action') end
reset();carapace.castable=true;bot.mods.modifier_nyx_assassin_vendetta=true;bot.incoming=true;cast('nyx_assassin_spiked_carapace')
bot.mods.modifier_nyx_assassin_spiked_carapace=true;noCast()
reset();carapace.castable=true;bot.mods.modifier_nyx_assassin_burrow=true;enemy(400);cast('nyx_assassin_spiked_carapace');enemies[1].x=401;noCast()
reset();impale.castable=true;bot.mods.modifier_nyx_assassin_vendetta=true;local e=enemy(700);bot.mode='attack';bot.target=e;noCast();e.channel=true;cast('nyx_assassin_impale');e.immune=true;noCast()
reset();impale.castable=true;bot.mode='attack';bot.target=enemy(750);local a=cast('nyx_assassin_impale');assert(a.point.x==750)
bot.target.speed=100;noCast();bot.target.speed=0;bot.target.x=751;noCast();bot.mods.modifier_nyx_assassin_burrow=true;bot.target.x=1200;cast('nyx_assassin_impale');bot.target.x=1251;noCast()
reset();impale.castable=true;bot.fight=true;enemy(300);enemy(700);cast('nyx_assassin_impale')
reset();mind.castable=true;e=enemy(800,390);cast('nyx_assassin_jolt',e);e.x=801;noCast();e.x=500;e.immune=true;noCast();e.immune=false;e.blocked=true;noCast()
reset();mind.castable=true;impale.castable=true;bot.mode='attack';bot.target=enemy(500);bot.target.disabled=true;cast('nyx_assassin_jolt',bot.target) -- Held targets can be finished without waiting to overlap Impale.
impale.castable=false;cast('nyx_assassin_jolt',bot.target)
reset();burrow.castable=true;impale.castable=true;bot.mode='defend';enemy(1100);cast('nyx_assassin_burrow')
enemies[1].x=300;noCast();enemies[1].x=1300;noCast()
reset();unburrow.castable=true;bot.mods.modifier_nyx_assassin_burrow=true;bot.mode='retreat';enemy(500);cast('nyx_assassin_unburrow')
bot.mode='defend';noCast();enemies={};cast('nyx_assassin_unburrow')
reset();vendetta.castable=true;bot.mode='attack';bot.target=enemy(700,200);cast('nyx_assassin_vendetta');assert(bot.vendettaTarget==bot.target)
bot.target.hp=1000;cast('nyx_assassin_vendetta');assert(bot.vendettaTarget==nil);bot.disarmed=true;noCast();bot.disarmed=false;bot.invisible=true;noCast()
local R=require('bots/FunLib/rubick_hero/nyx_assassin')
reset();carapace.castable=true;bot.mods.modifier_nyx_assassin_vendetta=true;bot.incomingSpell=true;assert(R.ConsiderStolenSpell(carapace))
reset();mind.castable=true;abilities.nyx_assassin_impale=nil;bot.mode='attack';bot.target=enemy(800);assert(R.ConsiderStolenSpell(mind))
reset();unburrow.castable=true;abilities.nyx_assassin_burrow=nil;bot.mods.modifier_nyx_assassin_burrow=true;bot.mode='retreat';assert(R.ConsiderStolenSpell(unburrow))
print('Nyx Assassin ability scenarios passed')
