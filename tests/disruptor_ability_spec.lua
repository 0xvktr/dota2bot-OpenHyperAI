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
    function a:IsNull() return false end
    function a:IsHidden() return self.hidden==true end
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

local strike=ability('disruptor_thunder_strike',800,130,{radius=260,strikes=4,strike_damage=120,strike_damage_bonus=15,strike_interval=2},0.05)
local glimpse=ability('disruptor_glimpse',1800,115,{backtrack_time=4},0.05)
local field=ability('disruptor_kinetic_field',900,70,{radius=350,formation_time=1},0.05)
local storm=ability('disruptor_static_storm',800,225,{radius=550},0.05)
local fence=ability('disruptor_kinetic_fence',1200,70,{})
local function load(stolen)
    return stolen and H.realDofile('bots/FunLib/rubick_hero/disruptor.lua') or H.load('npc_dota_hero_disruptor','pos_5')
end
local function cast(module,a,stolen)
    if stolen then return module.ConsiderStolenSpell(a) else module.SkillsComplement() end
end
local function observe(module,enemy,from,to)
    enemies={enemy}
    for index=0,20 do
        now=index*0.2;enemy.x=from+(to-from)*index/20;module.ObserveGlimpseHistory()
    end
end
for _,stolen in pairs({false,true}) do
    reset();local module=load(stolen);glimpse.castable=true;local enemy=unit(1700);enemy.channel=true;enemies={enemy}
    cast(module,glimpse,stolen);assert(#actions==1 and actions[1].target==enemy,'Glimpse interrupts standalone beyond nearby API cap without movement history')
    reset();module=load(stolen);glimpse.castable=true;enemy=unit(1801);enemy.channel=true;enemies={enemy}
    cast(module,glimpse,stolen);assert(#actions==0,'strict Glimpse range has no movement allowance')
    items[0]=lens;cast(module,glimpse,stolen);assert(#actions==1,'actual Lens Glimpse range')
    reset();module=load(stolen);glimpse.castable=true;supremacy.trained=true;enemy=unit(2040);enemy.channel=true;enemies={enemy}
    cast(module,glimpse,stolen);assert(#actions==1,'real unbroken Supremacy range')
    actions={};bot.mods.modifier_silver_edge_debuff=true;cast(module,glimpse,stolen);assert(#actions==0,'known break removes Supremacy range')
    for _,modifier in pairs({'modifier_antimage_counterspell','modifier_antimage_counterspell_ally','modifier_item_lotus_orb_active'}) do
        reset();module=load(stolen);glimpse.castable=true;enemy=unit(500);enemy.channel=true;enemy.mods[modifier]=true;enemies={enemy}
        cast(module,glimpse,stolen);assert(#actions==0,'active reflection blocks targeted Glimpse '..modifier)
    end
    reset();module=load(stolen);glimpse.castable=true;enemy=unit(500);enemy.illusion=true;enemy.attackTarget=bot;enemies={enemy}
    cast(module,glimpse,stolen);assert(#actions==1 and actions[1].target==enemy,'actual threatening illusion may be destroyed despite Advanced illusion filter')
    reset();module=load(stolen);glimpse.castable=true;bot.mode='attack';enemy=unit(1200);bot.target=enemy;bot.chasing=enemy;enemies={enemy}
    cast(module,glimpse,stolen);assert(#actions==0,'no invented four-second return point')
    reset();module=load(stolen);glimpse.castable=true;enemy=unit(400);bot.mode='attack';bot.target=enemy;bot.chasing=enemy
    observe(module,enemy,400,1200);cast(module,glimpse,stolen)
    assert(#actions==1 and actions[1].target==enemy,'continuous four-second observed escape may be caught')
    reset();module=load(stolen);glimpse.castable=true;enemy=unit(1200);bot.mode='attack';bot.target=enemy;bot.chasing=enemy
    observe(module,enemy,1200,400);cast(module,glimpse,stolen);assert(#actions==0,'do not push a close target farther from own team')
    reset();module=load(stolen);glimpse.castable=true;enemy=unit(1500);bot.mode='retreat';bot.damaged=true;enemy.chasing=bot
    observe(module,enemy,1500,400);cast(module,glimpse,stolen)
    assert(#actions==1 and actions[1].target==enemy,'observed incoming pursuer can be sent away for self save')
    reset();module=load(stolen);glimpse.castable=true;enemy=unit(1500);local ally=unit(200);ally.team=2;ally.mode='retreat';ally.damaged=true;allies={ally};enemy.chasing=ally
    observe(module,enemy,1500,500);cast(module,glimpse,stolen);assert(#actions==1,'observed ally save')
    reset();module=load(stolen);glimpse.castable=true;enemy=unit(1500);bot.mode='retreat';bot.damaged=true;enemy.chasing=bot
    observe(module,enemy,400,500);cast(module,glimpse,stolen);assert(#actions==0,'unhelpful historical save destination refused')
    reset();module=load(stolen);glimpse.castable=true;enemy=unit(400);bot.mode='attack';bot.target=enemy;bot.chasing=enemy
    observe(module,enemy,400,1000);now=4.8;module.ObserveGlimpseHistory();cast(module,glimpse,stolen)
    assert(#actions==0,'visibility or sampling gap invalidates old history')
    reset();module=load(stolen);glimpse.castable=true;enemy=unit(400);bot.mode='attack';bot.target=enemy;bot.chasing=enemy
    observe(module,enemy,400,1200);enemy.mods.modifier_disruptor_static_storm=true;cast(module,glimpse,stolen)
    assert(#actions==0,'do not rescue enemy already caught in Static Storm')
    reset();module=load(stolen);glimpse.castable=true;enemy=unit(4000)
    observe(module,enemy,4000,4000);now=4.2;enemy.x=500;module.ObserveGlimpseHistory();cast(module,glimpse,stolen)
    assert(#actions==1,'observed recent teleport arrival may be returned to distant origin')
    reset();module=load(stolen);glimpse.castable=true;enemy=unit(4000)
    observe(module,enemy,4000,4000);enemy.visible=false;now=4.7;module.ObserveGlimpseHistory();enemy.visible=true;now=4.9;enemy.x=500;cast(module,glimpse,stolen)
    assert(#actions==0,'unseen teleport arrival does not create historical knowledge')
    reset();module=load(stolen);field.castable=true;bot.mode='attack';enemy=unit(800);enemy.speed=400;bot.target=enemy;enemies={enemy}
    cast(module,field,stolen);assert(#actions==1 and actions[1].point.x==900,'full one-second formation prediction and legal Field edge radius')
    reset();module=load(stolen);field.castable=true;bot.mode='attack';enemy=unit(800);enemy.speed=500;bot.target=enemy;enemies={enemy}
    cast(module,field,stolen);assert(#actions==0,'escaping before formation cannot be trapped by current-position cast')
    reset();module=load(stolen);storm.castable=true;enemy=unit(1200);enemy.channel=true;enemies={enemy}
    cast(module,storm,stolen);assert(#actions==1 and actions[1].point.x==800,'standalone Storm interrupts using legal center and actual AoE radius')
    reset();module=load(stolen);storm.castable=true;enemy=unit(500);enemy.immune=true;enemy.channel=true;enemies={enemy}
    cast(module,storm,stolen);assert(#actions==0,'Scepter does not cancel already active immunity')
    reset();module=load(stolen);storm.castable=true;field.castable=true;bot.mana=294;bot.mode='attack';enemy=unit(600);enemy.core=true;bot.target=enemy;enemies={enemy}
    cast(module,storm,stolen);assert(#actions==1 and actions[1].name==storm.name,'standalone Storm is allowed below linked combo mana')
    reset();module=load(stolen);storm.castable=true;field.castable=true;bot.mana=295;bot.mode='attack';enemy=unit(600);enemy.core=true;bot.target=enemy;enemies={enemy}
    cast(module,storm,stolen);assert(#actions==2 and actions[1].name==storm.name and actions[2].name==field.name and actions[2].queued,'budgeted Storm first then Field with no delayed silence')
    reset();module=load(stolen);storm.castable=true;field.castable=true;bot.mode='attack';enemy=unit(1100);enemy.core=true;enemy.speed=400;bot.target=enemy;enemies={enemy}
    cast(module,storm,stolen);assert(#actions==1,'linked Field queue refused when enemy leaves its area by formation')
    reset();module=load(stolen);strike.castable=true;enemy=unit(700);enemy.hp=555;enemies={enemy}
    cast(module,strike,stolen);assert(#actions==1 and bot.killDamage==570 and bot.killDelay==6.05,'progressive strike talent damage includes six-second completion delay')
    reset();module=load(stolen);strike.castable=true;enemy=unit(700);enemy.hp=555;enemy.regen=5;enemies={enemy}
    cast(module,strike,stolen);assert(#actions==0,'regen prevents false repeated-damage kill')
    reset();module=load(stolen);strike.castable=true;bot.mode='attack';enemy=unit(801);bot.target=enemy;enemies={enemy}
    cast(module,strike,stolen);assert(#actions==0,'strict Thunder Strike range')
    reset();module=load(stolen);strike.castable=true;bot.mode='lane';enemy=unit(700);enemy.mods.modifier_disruptor_thunder_strike=true;bot.target=enemy;enemies={enemy}
    cast(module,strike,stolen);assert(#actions==0,'no duplicate Thunder Strike debuff')
    reset();module=load(stolen);strike.castable=true;bot.mode='push';lane={unit(500,0,'creep'),unit(600,50,'creep'),unit(650,0,'creep')}
    cast(module,strike,stolen);assert(#actions==1,'durable clustered wave gets repeated Thunder Strike')
    reset();module=load(stolen);strike.castable=true;bot.mode='push';lane={unit(200,0,'creep'),unit(500,0,'creep'),unit(800,0,'creep')}
    cast(module,strike,stolen);assert(#actions==0,'spread wave is not miscounted')
    for _,kind in pairs({'roshan','tormentor'}) do
        reset();module=load(stolen);strike.castable=true;bot.mode=kind;bot.attacking=true;bot.target=unit(700,0,kind)
        cast(module,strike,stolen);assert(#actions==1 and actions[1].target==bot.target,'actual objective entity '..kind)
    end
    reset();module=load(stolen);fence.castable=true;bot.mode='attack';bot.target=unit(600);enemies={bot.target}
    local result=cast(module,fence,stolen);assert(#actions==0 and (not stolen or result==false),'vector Fence explicitly skipped')
    reset();module=load(stolen);glimpse.castable=true;bot.channel=true;enemy=unit(500);enemy.channel=true;enemies={enemy}
    cast(module,glimpse,stolen);assert(#actions==0,'normal channels and action queues preserved')
end
-- Early copy observation remains useful while the live stolen spell is on cooldown.
reset();local observing=load(true);local observed=unit(400);bot.mode='attack';bot.target=observed;bot.chasing=observed
observe(observing,observed,400,1200);glimpse.castable=true;observing.ConsiderStolenSpell(glimpse)
assert(#actions==1,'history collected during cooldown survives first ready opportunity')
reset();observing=load(true);abilities[glimpse.name]=nil;enemies={unit(500)}
assert(observing.ObserveGlimpseHistory()==false,'unrelated stolen spells cannot collect Glimpse history')
abilities[glimpse.name]=glimpse;glimpse.hidden=true
assert(observing.ObserveGlimpseHistory()==false,'hidden linked spell cannot collect history')
glimpse.hidden=false
reset();local native=load(false);glimpse.castable=true;strike.castable=true;storm.castable=true;field.castable=true;bot.mode='attack';bot.target=unit(500);bot.target.channel=true;bot.target.core=true;enemies={bot.target}
native.SkillsComplement();assert(#actions==1 and actions[1].name==glimpse.name,'native direct Glimpse interrupt wins over combo and damage')
reset();local copy=load(true);storm.castable=true;field.castable=true;bot.mode='attack';bot.target=unit(500);bot.target.core=true;enemies={bot.target}
abilities[field.name]=nil;copy.ConsiderStolenSpell(storm);assert(#actions==1,'removed linked stolen Field handle is refreshed before queueing')
abilities[field.name]=field
assert(copy.ConsiderStolenSpell({GetName=function() return 'unrelated' end})==nil,'unknown spells allow fallback')
print('Disruptor ability scenarios passed')
