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

UNIT_LIST_ALLIED_HEROES=5
local owned={};function GetUnitList(k) return k==UNIT_LIST_ALLIED_HEROES and owned or enemies end
function GameTime() return now end
J.IsItemAvailable=function() return items[0] end
J.HasBreakModifier=function() return false end
J.GetMP=function(u) return u.mana/1000 end
J.GetMeepos=function() return owned end
J.IsMeepoClone=function(u) return u.clone==true end
J.GetModifierTime=function(u,m) return u.remaining or 0 end
J.IsStunProjectileIncoming=function(u) return u.projectile==true end
J.SetQueuePtToINT=function(_,_,a) assert(a~=nil) end
function bot:GetPlayerID() return 1 end
function bot:IsRooted() return self.rooted==true end
function bot:ActionQueue_UseAbility(a) actions[#actions+1]={name=a.name} end
function bot:ActionQueue_UseAbilityOnEntity(a,u) assert(u~=nil);actions[#actions+1]={name=a.name,target=u} end
local net=ability('meepo_earthbind',1200,100,{radius=220,speed=1200,duration=2},.3)
local poof=ability('meepo_poof',0,80,{radius=400,poof_damage=140,cast_duration=1.5})
function poof:GetAutoCastState() return self.auto==true end
local dig=ability('meepo_petrify',0,125,{})
local mega=ability('meepo_megameepo',0,0,{radius=600})
local fling=ability('meepo_megameepo_fling',900,0,{})
local baseReset=reset
reset=function() baseReset();bot.rooted=false;bot.projectile=false end
local X=dofile('bots/BotLib/hero_meepo.lua')
local R=require('bots.FunLib.rubick_hero.meepo')
local function clone(x)
 local u=unit(x);u.name='npc_dota_hero_meepo';u.clone=true;u.owner=1;u.fountain=100
 function u:GetPlayerID() return self.owner end
 function u:DistanceFromFountain() return self.fountain end
 return u
end
reset();owned={};dig.castable=true;poof.castable=true;bot.hp=300;bot.mode='retreat';bot.damaged=true
X.SkillsComplement();assert(actions[1].name==dig.name,'invulnerability before1.5secchannel')
bot.rooted=true;assert(not R.DigUseful(dig));assert(R.PoofTarget(poof)==nil)
reset();mega.castable=true;local c=clone(599);c.hp=300;c.damaged=true;owned={c}
assert(R.MegaUseful(mega),'one endangered clone without attackmode');c.x=601;assert(not R.MegaUseful(mega));c.x=500;c.owner=2;assert(not R.MegaUseful(mega))
reset();owned={};net.castable=true;bot.mode='attack';local foe=unit(1300);foe.channel=true;enemies={foe};bot.target=foe
assert(R.NetPoint(net,true).x==1200,'circle extends true center');foe.x=1421;assert(R.NetPoint(net,true)==nil)
foe.x=1000;foe.remaining=2;assert(R.NetPoint(net,true)==nil,'do not overlap active net')
foe.remaining=.2;assert(R.NetPoint(net,true)~=nil,'chain on root expiry')
c=clone(500);c.earth_bind_cast={time=0,flight=1,location=Vector(1000,0)};owned={c};assert(R.NetPoint(net,true)==nil)
now=2;assert(R.NetPoint(net,true)~=nil,'flight-aware pending net expired before our arrival')
reset();owned={};poof.castable=true;bot.mode='lane';lane={unit(100,0,'creep'),unit(200,0,'creep')};lane[1].hp=250;lane[2].hp=250
assert(R.PoofTarget(poof)==bot,'self departure andarrival damage280')
poof.auto=true;assert(R.PoofTarget(poof)==nil,'do not drag vulnerable clones via altcast');poof.auto=false
reset();poof.castable=true;bot.hp=300;bot.mode='retreat';c=clone(5000);owned={c};assert(R.PoofTarget(poof)==c)
local danger=unit(5200);enemies={danger};assert(R.PoofTarget(poof)==nil,'unsafe far clone not refuge')
reset();owned={};fling.castable=true;bot.mods.modifier_meepo_megameepo_self=true;bot.mode='attack';foe=unit(899);bot.target=foe;enemies={foe}
assert(R.FlingTarget(fling)==foe);foe.immune=true;assert(R.FlingTarget(fling)==nil);bot.queued=true;assert(not R.ConsiderStolenSpell(fling))
print('Meepo ability scenarios passed (6 groups)')
