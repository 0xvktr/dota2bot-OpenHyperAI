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


function bot:GetActiveMode() return self.mode end
function bot:IsMuted() return false end
function bot:NumQueuedActions() return self.queued and 1 or 0 end
J.IsLaning=function(u) return u.mode=='lane' end
J.IsRunning=function() return false end
J.ConsiderForMkbDisassembleMask=function() end
local hammer=ability('sven_storm_bolt',600,110,{bolt_aoe=310,bolt_speed=1000,scepter_bonus_damage=180,damage=320},0.2)
local warcry=ability('sven_warcry',0,45,{radius=700})
local strength=ability('sven_gods_strength',0,150)
local cleave=ability('sven_great_cleave',0,0)
for _,a in ipairs({hammer,warcry,strength,cleave}) do
 function a:GetCooldownTimeRemaining() return self.cd or 0 end
 function a:GetAutoCastState() return self.auto==true end
end
J.Skill.GetAbilityList=function() return {hammer.name,cleave.name,warcry.name,'A4','A5',strength.name} end
local N=H.load('npc_dota_hero_sven','pos_1')
local R=require('bots/FunLib/rubick_hero/sven')
local P=require('bots/FunLib/item_cast_policy')
local oldReset=reset
reset=function()
 oldReset();bot.attackTarget=nil;bot.invulnerable=false;bot.disarmed=false;bot.rooted=false;bot.chrono=false;bot.tower=false;bot.using=false;bot.casting=false;bot.attackRange=150;bot.ohaManaCastIntent=nil;warcry.values.radius=700
 for _,a in pairs(abilities) do a.null=false;a.hidden=false;a.passive=false;a.activated=true;a.trained=true;a.cd=0;a.auto=false end
 supremacy.trained=false;cleave.passive=true
end
local function enemy(x,hp) local u=decorate(unit(x));function u:IsAlive() return self.hp>0 end;u.hp=hp or 1000;enemies[#enemies+1]=u;return u end
local function friend(x) local u=decorate(unit(x));u.team=2;allies[#allies+1]=u;return u end
local function tick() actions={};N.SkillsComplement();return actions[1] end
local function cast(name) local a=tick();assert(a and a.name==name,'expected '..name..', got '..(a and a.name or 'nothing'));assert(#actions==1);return a end
local function noCast() assert(tick()==nil,'unexpected action') end
reset();hammer.castable=true;local foe=enemy(600);foe.channel=true;local a=cast(hammer.name);assert(a.target==foe);foe.x=601;noCast();items[0]=lens;cast(hammer.name);foe.blocked=true;noCast();foe.blocked=false;foe.immune=true;noCast()
reset();hammer.castable=true;foe=enemy(900);foe.channel=true;local creep=decorate(unit(600,0,'creep'));lane={creep};a=cast(hammer.name);assert(a.target==creep);creep.x=601;noCast()
reset();hammer.castable=true;foe=enemy(600,320);cast(hammer.name);assert(math.abs(bot.killDelay-0.8)<0.001);foe.regen=1;noCast();foe.regen=0;foe.mods.modifier_dazzle_shallow_grave=true;foe.protected=true;noCast()
reset();hammer.castable=true;foe=enemy(600);foe.channel=true;foe.mods.modifier_teleporting=true;foe.modRemaining=0.8;noCast();foe.modRemaining=0.81;cast(hammer.name)
reset();hammer.castable=true;bot.scepter=true;hammer.range=750;hammer.values.bolt_speed=1250;foe=enemy(750,500);noCast();hammer.auto=true;a=cast(hammer.name);assert(a.target==foe and bot.killDamage==500);bot.rooted=true;noCast();bot.rooted=false;bot.chrono=true;noCast();bot.chrono=false;bot.tower=true;noCast();hammer.range=600;hammer.values.bolt_speed=1000
reset();hammer.castable=true;bot.mode='lane';lane={decorate(unit(600,0,'creep'))};lane[1].name='npc_dota_creep_badguys_ranged';lane[1].hp=320;a=cast(hammer.name);assert(a.target==lane[1]);lane[1].mods.modifier_fountain_glyph=true;noCast()
reset();warcry.castable=true;local ally=friend(700);foe=enemy(800);foe.attackTarget=ally;cast(warcry.name);ally.x=701;noCast();warcry.values.radius=900;cast(warcry.name);ally.mods.modifier_sven_warcry=true;noCast();ally.mods={};ally.illusion=true;noCast()
reset();warcry.castable=true;foe=enemy(500);bot.attackTarget=foe;cast(warcry.name);bot.disarmed=true;noCast();bot.disarmed=false;bot.mods.modifier_sven_warcry=true;noCast()
reset();strength.castable=true;bot.mode='attack';foe=enemy(600);bot.target=foe;noCast();hammer.castable=true;bot.mana=259;cast(hammer.name);bot.mana=260;cast(strength.name);bot.mods.modifier_sven_gods_strength=true;cast(hammer.name);bot.mods={};bot.disarmed=true;cast(hammer.name)
reset();strength.castable=true;bot.mode='attack';foe=enemy(200);bot.target=foe;cast(strength.name);foe.attackImmune=true;noCast();foe.attackImmune=false;foe.mods.modifier_item_blade_mail_reflect=true;noCast();foe.mods={};bot.mode='retreat';bot.damaged=true;noCast()
reset();strength.castable=true;bot.mode='farm';neutrals={decorate(unit(100,0,'creep')),decorate(unit(200,0,'creep')),decorate(unit(300,0,'creep')),decorate(unit(400,0,'creep'))};cast(strength.name);bot.mods.modifier_viper_viper_strike_slow=true;noCast();bot.mods={};abilities.sven_great_cleave=nil;noCast();abilities.sven_great_cleave=cleave
reset();hammer.castable=true;foe=enemy(500);foe.channel=true;bot.mana=50;local mango=ability('item_enchanted_mango',0,0,{replenish_amount=100});mango.castable=true;items[0]=mango;noCast();assert(bot.ohaManaCastIntent and bot.ohaManaCastIntent.ability==hammer);bot.mana=110;cast(hammer.name);assert(bot.ohaManaCastIntent==nil)
reset();hammer.castable=true;foe=enemy(500);foe.channel=true;bot.queued=true;noCast();bot.queued=false;bot.channel=true;noCast();bot.channel=false;hammer.hidden=true;noCast();hammer.hidden=false;hammer.activated=false;noCast();hammer.activated=true;hammer.null=true;assert(not R.ConsiderStolenSpell(hammer));hammer.null=false;hammer.trained=false;assert(not R.ConsiderStolenSpell(hammer))
reset();hammer.castable=true;bot.scepter=true;hammer.auto=true;local foe=enemy(600);foe.channel=true;cast(hammer.name);bot.mods.modifier_puck_coiled=true;noCast()
local lookup=bot.GetAbilityByName
function bot:GetAbilityByName() error('unknown handler looked up linked spell') end
assert(R.ConsiderStolenSpell(ability('unrelated_spell',0,0))==nil)
bot.GetAbilityByName=lookup
print('Sven ability scenarios passed')
