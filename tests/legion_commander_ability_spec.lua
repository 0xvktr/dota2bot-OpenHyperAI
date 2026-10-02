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

J.IsItemAvailable=function(name) for _,a in pairs(items) do if a.name==name then return a end end return nil end
J.GetModifierCount=function() return bot.stacks or 0 end
J.HasBreakModifier=function() return false end
J.SetReportMotive=function() end
J.SetQueuePtToINT=function(_,_,a) assert(a~=nil) end
function bot:IsInvisible() return self.invisible==true end
function bot:GetLevel() return 10 end
function bot:GetCurrentActiveAbility() return self.active end
function bot:Action_ClearActions() actions[#actions+1]={name='stop'} end
function bot:ActionQueue_UseAbilityOnEntity(a,u) self:Action_UseAbilityOnEntity(a,u) end
function bot:GetNearbyCreeps(r) return nearby(lane,self,r) end
function bot:IsDisarmed() return self.disarmed==true end
function bot:GetSecondsPerAttack() return 1 end
function bot:ActionQueue_UseAbility(a) actions[#actions+1]={name=a.name,queued=true} end
function bot:ActionQueue_UseAbilityOnEntity(a,u) actions[#actions+1]={name=a.name,target=u,queued=true} end
function bot:IsRooted() return self.rooted==true end
function bot:IsIllusion() return false end
function bot:GetAttackTarget() return self.attackTarget end
J.IsInEtherealForm=function(u) return u.ethereal==true end
J.IsKeyWordUnit=function(key,u) return u.name and u.name:find(key)~=nil end
ABILITY_BEHAVIOR_POINT=16
J.CheckBitfieldFlag=function(value,flag) return value==flag end
local function extend(a)
    function a:GetBehavior() return self.behavior or 8 end
    return a
end
local odds=extend(ability('legion_commander_overwhelming_odds',0,90,{radius=600,damage=130,damage_per_hero=130,damage_per_unit=20},0.3))
local press=extend(ability('legion_commander_press_the_attack',700,90,{radius=500,hp_regen=60,duration=5},0.2))
local duel=extend(ability('legion_commander_duel',200,80,{duration=4.5},0.3))
local mail=extend(ability('item_blade_mail',0,25,{}))
abilities.A1=odds;abilities.A2=press;abilities.A6=duel
local function physical(u)
    function u:IsRooted() return self.rooted==true end
    function u:IsDisarmed() return self.disarmed==true end
    function u:GetHealthRegen() return self.regen or 0 end
    function u:GetEstimatedDamageToTarget(_,target,time,kind) return (self.dps or 20)*time end
    return u
end
local X=H.load('npc_dota_hero_legion_commander','pos_3')
local R=require('bots/FunLib/rubick_hero/legion_commander')
local function tick() actions={};X.SkillsComplement();return actions[1] end
-- Current Odds includes both heroes and ordinary units, and has a real Shard radius.
reset();odds.castable=true;bot.mode='lane'
local foe=physical(unit(590));foe.hp=270;enemies={foe};lane={unit(580,0,'creep')}
assert(X.ConsiderQ()>0 and bot.killDamage==280,'real hero/creep scaled nuke')
foe.x=601;foe.hp=100;lane={};assert(X.ConsiderQ()==0,'outside base radius')
odds.values.radius=700;assert(X.ConsiderQ()>0,'runtime Shard radius');odds.values.radius=600
foe.immune=true;assert(X.ConsiderQ()==0,'magical nonpiercing nuke')
-- Urgent strong dispel precedes Duel, including a human ally and a refreshed purge.
reset();press.castable=true;duel.castable=true;bot.mode='attack'
foe=physical(unit(200));foe.channel=true;enemies={foe};bot.target=foe
local ally=physical(unit(650));ally.team=2;ally.disabled=true;ally.mods.modifier_legion_commander_press_the_attack=true;allies={ally}
assert(tick().name==press.name and actions[1].target==ally,'active regen must not prevent new purge')
ally.immune=true;assert(R.PressTarget(press,true)==nil,'base flags exclude immune allies')
ally.immune=false;ally.x=750;assert(R.PressTarget(press,true)==nil,'exact unit cast range')
press.behavior=16;assert(R.PressTarget(press,true)==ally,'ground radius reaches ally beyond center cast range')
assert(tick().point.x==700,'Scepter center is clamped');press.behavior=8
-- Duel pierces immunity and interrupts either control source only within actual range.
reset();duel.castable=true;foe=physical(unit(200));foe.channel=true;foe.immune=true;enemies={foe}
assert(X.ConsiderR()>0,'human immune channel interrupt');foe.x=201;assert(X.ConsiderR()==0,'no extra approach radius')
items[0]=lens;assert(X.ConsiderR()>0,'actual Lens reach');foe.blocked=true;assert(X.ConsiderR()==0,'blocked target')
foe.blocked=false;foe.mods.modifier_item_lotus_orb_active=true;assert(X.ConsiderR()==0,'reflection gate')
-- Pre-duel preparation stays queued and retains cumulative mana for the ultimate.
reset();press.castable=true;duel.castable=true;mail.castable=true;items[0]=mail
foe=physical(unit(150));foe.channel=true;enemies={foe};bot.mode='attack';bot.target=foe;bot.mana=200
tick();assert(#actions==3 and actions[1].name==press.name and actions[2].name==mail.name and actions[3].name==duel.name)
for _,a in pairs(actions) do assert(a.queued,'immediate action would cancel prep') end
bot.mana=170;tick();assert(#actions==2 and actions[2].name==duel.name,'mail must not consume reserved Duel mana')
-- Observed Duel permits spell use while item preparation is forbidden.
reset();odds.castable=true;bot.mods.modifier_legion_commander_duel=true;foe=physical(unit(150));foe.immune=true;enemies={foe};bot.attackTarget=foe
local preparations=0;J.SetQueuePtToINT=function(_,_,a) assert(a);preparations=preparations+1 end
assert(tick().name==odds.name and not actions[1].queued and preparations==0,'Duel attack buff casts without item use')
bot.queued=true;assert(tick()==nil,'pending action preserved')
-- Copied spells do not assume Moment of Courage and preserve unknown dispatch.
reset();duel.castable=true;foe=physical(unit(150));foe.hp=100;foe.dps=20;enemies={foe};bot.mode='attack'
assert(R.ConsiderStolenSpell(duel));foe.ethereal=true;assert(not R.ConsiderStolenSpell(duel))
foe.ethereal=false;foe.dps=500;assert(not R.ConsiderStolenSpell(duel),'avoid lethal forced attacks')
assert(R.ConsiderStolenSpell({GetName=function() return 'unrecognized_spell' end})==nil)
print('Legion Commander ability scenarios passed (6 groups)')
