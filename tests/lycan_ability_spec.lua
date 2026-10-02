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

UNIT_LIST_ALLIES,UNIT_LIST_ALLIED_HEROES=4,5
local wolves={};local night=false
function GetUnitList(k) if k==UNIT_LIST_ALLIES then return wolves elseif k==UNIT_LIST_ALLIED_HEROES then return allies end return enemies end
function bot:GetPlayerID() return 1 end
function bot:IsRooted() return self.rooted==true end
J.CheckTimeOfDay=function() return 'day' end
function GetTimeOfDay() return night and 0.8 or 0.5 end
J.IsItemAvailable=function() return items[0] end
J.HasBreakModifier=function() return bot.broken==true end
J.SetQueuePtToINT=function(_,_,a) assert(a~=nil);bot.prepared=a end
function bot:ActionQueue_UseAbility(a) actions[#actions+1]={name=a.name} end
function bot:ActionQueue_UseAbilityOnEntity(a,u) actions[#actions+1]={name=a.name,target=u} end
local summon=ability('lycan_summon_wolves',0,130,{wolf_count=2})
local howl=ability('lycan_howl',0,40,{radius=2000})
local shape=ability('lycan_shapeshift',0,100,{})
local bite=ability('lycan_wolf_bite',300,150,{})
local X=dofile('bots/BotLib/hero_lycan.lua')
local R=require('bots.FunLib.rubick_hero.lycan')
reset();summon.castable=true;bot.mode='lane';bot.attacking=true
assert(X.ConsiderSummonWolves()==0,'empty lane cannot summon')
lane={unit(300,0,'creep')};assert(X.ConsiderSummonWolves()>0)
local wolf=unit(100,0,'creep');wolf.name='npc_dota_lycan_wolf1';function wolf:GetPlayerID() return self.owner or 2 end
wolves={wolf};assert(X.ConsiderSummonWolves()>0,'other owner cannot block wolves')
wolf.owner=1;wolves={wolf,wolf};assert(X.ConsiderSummonWolves()==0,'full own pack preserved')
reset();wolves={};howl.castable=true;night=true
local foe=unit(5000);local ally=unit(4900);ally.team=2;ally.attacking=true;ally.attackTarget=foe;allies={ally};enemies={foe}
assert(X.ConsiderHowl()>0,'global howl uses ally origin')
night=false;assert(X.ConsiderHowl()==0,'day outside origin cannot debuff')
foe.immune=true;night=true;assert(X.ConsiderHowl()==0,'non-piercing howl')
reset();night=false;shape.castable=true;bot.mode='retreat';bot.hp=500
foe=unit(700);foe.chasing=bot;enemies={foe};assert(X.ConsiderShapeShift()>0)
bot.rooted=true;assert(X.ConsiderShapeShift()==0,'rooted escape cannot outrun')
bot.rooted=false;bot.mods.modifier_lycan_shapeshift=true;assert(X.ConsiderShapeShift()==0)
reset();wolves={};bite.castable=true;ally=unit(300);foe=unit(500);ally.team=2;ally.mode='attack';ally.target=foe;allies={ally};enemies={foe}
assert(R.BiteTarget(bite)==ally);ally.x=301;assert(R.BiteTarget(bite)==nil)
items[0]=lens;assert(R.BiteTarget(bite)==ally);ally.attackRange=600;assert(R.BiteTarget(bite)==nil,'avoid shrinking ranged ally reach')
ally.attackRange=150;shape.trained=false;assert(R.BiteTarget(bite)==nil,'copied bite lacks linked shape')
shape.trained=true;bot.queued=true;assert(R.ConsiderStolenSpell(bite)==false)
reset();wolf.owner=1;wolf.hp=100;wolf.damaged=true
local tail=ability('lycan_summon_wolves_hightail',0,0,{});tail.castable=true
function wolf:GetAbilityByName() return tail end
function wolf:Action_UseAbility(a) actions[#actions+1]={name=a.name} end
assert(R.UseHightail(wolf));wolf.mods.modifier_lycan_summon_wolves_hightail=true;assert(not R.UseHightail(wolf))
wolf.mods={};wolf.owner=2;assert(not R.UseHightail(wolf),'wrong owner')
wolf.owner=1;wolf.name='npc_dota_neutral_centaur';assert(not R.UseHightail(wolf),'not a wolf')
wolf.name='npc_dota_lycan_wolf1';wolf.queued=true;assert(not R.UseHightail(wolf),'occupied wolf queue')
wolf.queued=false;wolf.channel=true;assert(not R.UseHightail(wolf),'wolf channel preserved')
print('Lycan ability scenarios passed (5 groups)')
