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
ATTRIBUTE_STRENGTH,ATTRIBUTE_AGILITY=0,1
J.HasBreakModifier=function(u) return u.broken==true end
J.HasQueuedAction=function(u) return u.queued end
J.GetEnemiesNearLoc=function(point,r) local out={};for _,u in pairs(enemies) do if GetUnitToLocationDistance(u,point)<=r then out[#out+1]=u end end;return out end
J.IsStunProjectileIncoming=function(u) return u.projectile==true end
J.GetTeamFountain=function() return Vector(-8000,0) end
function IsLocationPassable() return true end
function bot:GetAttributeValue(which) return which==ATTRIBUTE_AGILITY and (self.agi or 100) or (self.str or 60) end
function bot:IsRooted() return self.rooted==true end
function bot:IsAlive() return self.hp>0 end
function bot:IsStunned() return self.stunned end
function bot:IsHexed() return self.hexed==true end
function bot:IsNightmared() return self.nightmared==true end
function bot:IsCastingAbility() return self.casting==true end
function bot:IsUsingAbility() return self.using end
function bot:ActionQueue_UseAbilityOnEntity(a,u) assert(u~=nil);actions[#actions+1]={name=a.name,target=u,queued=true} end
local oldReset=reset
reset=function() oldReset();bot.rooted=false;bot.projectile=false;bot.hexed=false;bot.nightmared=false;bot.casting=false;bot.agi=90;bot.str=60;bot.broken=false end
local wave=ability('morphling_waveform',925,115,{speed=1250,width=200})
local strike=ability('morphling_adaptive_strike_agi',825,60,{damage_min=0.5,damage_max=2.5,damage_base=110,projectile_speed=1150})
local shift=ability('morphling_morph_str',0,0,{castable_while_stunned=0})
shift.toggle=false
function shift:GetToggleState() return self.toggle end
local innate=ability('morphling_ebb_and_flow',0,0,{cast_range_per_str=25});innate.trained=false
local C=dofile('bots/FunLib/rubick_hero/morphling.lua')
reset();strike.castable=true;local foe=unit(700);foe.channel=true;enemies={foe};bot.agi=20
assert(C.AdaptiveTarget(strike,true)==foe,'Strength-heavy unified Strike interrupts channels')
foe.immune=true;assert(C.AdaptiveTarget(strike,true)==nil);foe.immune=false;foe.blocked=true;assert(C.AdaptiveTarget(strike,true)==nil)
reset();strike.castable=true;foe=unit(700);foe.hp=330;enemies={foe};assert(C.AdaptiveTarget(strike,false)==foe);assert(bot.killDamage==335,'Exact 1.5 ratio receives maximum multiplier')
foe.hp=500;bot.agi=20;bot.mode='retreat';foe.chasing=bot;assert(C.AdaptiveTarget(strike,false)==foe,'Control remains useful below damage threshold')
reset();wave.castable=true;bot.mode='retreat';bot.damaged=true;assert(math.abs(C.WavePoint(wave).x+925)<0.1)
bot.rooted=true;assert(C.WavePoint(wave)==nil);bot.rooted=false;bot.mods.modifier_bloodseeker_rupture=true;assert(C.WavePoint(wave)==nil)
reset();items[0]=lens;innate.trained=true;supremacy.trained=true;assert(C.Range(wave)==1405,'Actual Lens, Supremacy, Ebb strength range only');bot.broken=true;assert(C.Range(wave)==1150);innate.trained=false
reset();shift.castable=true;shift.toggle=false;bot.hp=200;bot.damaged=true;bot.stunned=true
assert(not C.UseStrengthShift(),'No Shard stun bypass');shift.values.castable_while_stunned=1;assert(C.UseStrengthShift());assert(actions[1].name==shift.name)
shift.toggle=true;assert(not C.UseStrengthShift());shift.toggle=false;bot.hexed=true;assert(not C.UseStrengthShift());bot.hexed=false;bot.queued=true;assert(not C.UseStrengthShift());bot.queued=false;bot.mods.modifier_doom_bringer_doom=true;assert(not C.UseStrengthShift())
print('morphling_ability_spec: 5 behavioral groups passed')
