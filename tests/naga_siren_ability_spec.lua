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

J.Chat={GetNormName=function() return 'target' end}
J.SetQueuePtToINT=function() end
J.SetReportMotive=function() end
J.IsItemAvailable=function() return nil end
J.GetAroundEnemyHeroList=function(r) return nearby(enemies,bot,r) end
J.CanKillTarget=function(u,d,k) return u:GetActualIncomingDamage(d,k)>=u.hp end
local function decorate(u)
    function u:IsRooted() return self.rooted==true end
    function u:GetModifierByName(name) return self.mods[name] and 0 or -1 end
    function u:GetModifierSourceAbility() return self.netSource end
    function u:IsFacingLocation() return true end
    function u:GetLevel() return 10 end
    function u:IsInvisible() return self.invisible==true end
    function u:GetNearbyCreeps() return {} end
    function u:GetNearbyTowers() return {} end
    function u:GetNearbyBarracks() return {} end
    return u
end
decorate(bot)
function bot:ActionQueue_UseAbility(a) self:Action_UseAbility(a) end
function bot:ActionQueue_UseAbilityOnEntity(a,u) self:Action_UseAbilityOnEntity(a,u) end
local q=ability('A1',0,75,{damage=0})
local w=ability('A2',575,100,{damage=0})
local r=ability('A6',0,150,{radius=900})
local cancel=ability('naga_siren_song_of_the_siren_cancel',0,0)
local reel=ability('naga_siren_reel_in',1400,0,{radius=1600})
for _,name in ipairs({'A3','A4','A5','T1','T2','T3','T4','T5','T6','T7','T8'}) do ability(name,0,0,{damage=0}) end
local N=H.load('npc_dota_hero_naga_siren','pos_1')
local function enemy(x) local u=decorate(unit(x));enemies[#enemies+1]=u;return u end
local function tick() actions={};N.SkillsComplement();return actions[1] end
local function cast(name,target) local a=tick();assert(a and a.name==name and (target==nil or a.target==target),'expected '..name);return a end
local function noCast() assert(tick()==nil,'unexpected action') end
reset();r.castable=true;q.castable=true;w.castable=true
bot.mode='retreat';bot.hp=300;bot.damaged=true;enemy(500);cast('A6')
reset();r.castable=true;bot.mode='retreat';bot.hp=300;bot.damaged=true
local e=enemy(901);noCast();e.x=900;cast('A6');e.immune=true;noCast()
reset();r.castable=true;bot.mode='attack';bot.target=enemy(850);noCast()
allies={decorate(unit(100))};allies[1].team=2;cast('A6');bot.target.x=950;noCast()
reset();w.castable=true;e=enemy(575);e.channel=true;cast('A2',e)
e.x=576;noCast();e.x=500;e.immune=true;noCast();bot.scepter=true;cast('A2',e)
reset();w.castable=true;bot.mode='attack';e=enemy(500);bot.target=e
e.invulnerable=true;e.mods.modifier_naga_siren_song_of_the_siren=true;cast('A2',e)
e.mods.modifier_naga_siren_song_of_the_siren=nil;noCast()
reset();q.castable=true;bot.rooted=true;cast('A1');bot.rooted=false;noCast()
reset();cancel.castable=true;cast('naga_siren_song_of_the_siren_cancel')
e=enemy(250);e.mods.modifier_naga_siren_song_of_the_siren=true;bot.mode='retreat';noCast()
bot.mode='attack';bot.target=e;allies={decorate(unit(200))};cast('naga_siren_song_of_the_siren_cancel')
reset();cancel.castable=true;bot.hp=600;noCast();bot.mods.modifier_ice_blast=true;cast('naga_siren_song_of_the_siren_cancel')
reset();reel.castable=true;e=enemy(1500);e.mods.modifier_naga_siren_ensnare=true;e.netSource=w;cast('naga_siren_reel_in')
e.x=1601;noCast();e.x=1500;e.netSource=q;noCast();e.netSource=w;bot.mode='retreat';noCast()
bot.mode='attack';bot.channel=true;noCast();bot.channel=false;e.immune=true;noCast();bot.scepter=true;cast('naga_siren_reel_in')
-- Stolen spells use the passed handle and need no passive/linked spell.
local R=require('bots/FunLib/rubick_hero/naga_siren')
reset();local stolen=ability('naga_siren_ensnare',575,100,{damage=0});stolen.castable=true;e=enemy(500);e.channel=true
assert(R.ConsiderStolenSpell(stolen));assert(actions[#actions].target==e)
e.channel=false;bot.mode='idle';assert(not R.ConsiderStolenSpell(stolen))
reset();stolen=ability('naga_siren_reel_in',1400,0,{radius=1600});stolen.castable=true;e=enemy(1000);e.mods.modifier_naga_siren_ensnare=true;e.netSource=w
abilities.naga_siren_ensnare=nil;assert(not R.ConsiderStolenSpell(stolen))
reset();stolen=ability('naga_siren_song_of_the_siren_cancel',0,0);stolen.castable=true;abilities.naga_siren_song_of_the_siren=nil
assert(R.ConsiderStolenSpell(stolen),'cancel works without primary stolen Song handle')
print('Naga Siren ability scenarios passed')
