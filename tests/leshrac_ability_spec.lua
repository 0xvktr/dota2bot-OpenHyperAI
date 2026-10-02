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

J.GetProperCastRange=function(_,_,r) return r+(items[0] and 225 or 0) end
J.IsValidTarget=J.IsValid
J.IsItemAvailable=function() return items[0] end
function bot:IsCastingAbility() return self.using==true end
function bot:IsUsingAbility() return self.using==true end
J.GetMP=function(u) return u.mana/1000 end
J.GetManaAfter=function(cost) return (bot.mana-cost)/1000 end
J.CanKillTarget=function(u,d,k) return u:GetActualIncomingDamage(d,k)>=u.hp end
J.GetEnemiesNearLoc=function(p,r) local out={};for _,u in pairs(enemies) do if GetUnitToLocationDistance(u,p)<=r then out[#out+1]=u end end;return out end
J.GetCenterOfUnits=function(units) local p=Vector(0,0);for _,u in pairs(units) do p=p+u:GetLocation() end;return p*(1/#units) end
J.IsWithoutTarget=function() return true end
J.GetAttackProjectileDamageByRange=function() return 0 end
J.IsTaunted=function() return false end
J.SetQueuePtToINT=function(_,_,a) assert(a~=nil,'pass the real spell for item preparation') end
J.HasBreakModifier=function() return false end
J.Site={GetXUnitsTowardsLocation=function(u,p,r) local offset=p-u:GetLocation();return u:GetLocation()+offset:Normalized()*r end}
function bot:GetNearbyTowers(r) return nearby(items.towers or {},self,r) end
function bot:ActionQueue_UseAbilityOnEntity(a,u) self:Action_UseAbilityOnEntity(a,u) end
function bot:ActionQueue_UseAbility(a) self:Action_UseAbility(a) end
function bot:FindAoELocation() return {count=0,targetloc=Vector(0,0)} end
function bot:GetHealthRegen() return 0 end
local split=ability('leshrac_split_earth',650,100,{radius=190,delay=0.35},0.7)
function split:GetAbilityDamage() return 225 end
local edict=ability('leshrac_diabolic_edict',0,150,{radius=450})
local storm=ability('leshrac_lightning_storm',600,120,{radius=450,damage=190})
local nova=ability('leshrac_pulse_nova',0,60,{radius=500,mana_cost_per_second=40})
local nihil=ability('leshrac_greater_lightning_storm',0,75,{radius=500})
for _,a in pairs(abilities) do
    function a:IsHidden() return false end
    function a:IsActivated() return true end
    function a:GetToggleState() return self.on==true end
end
local hero=H.load('npc_dota_hero_leshrac','pos_2')
local stolen=require('bots/FunLib/rubick_hero/leshrac')
local function tick() actions={};hero.SkillsComplement();return actions[1] end
-- An interrupt takes priority over Pulse Nova and routine Lightning Storm.
reset();bot.mode='attack';local enemy=unit(400);enemy.channel=true;bot.target=enemy;enemies={enemy}
split.castable=true;storm.castable=true;nova.castable=true
assert(tick().name==split.name)
-- Edict affects debuff-immune enemies but requires the actual radius.
reset();bot.mode='attack';enemy=unit(449);enemy.immune=true;enemies={enemy};bot.target=enemy;edict.castable=true
assert(tick().name==edict.name)
enemy.x=451;assert(tick()==nil)
-- Tower use must not begin at the old 1000-unit query radius.
reset();bot.mode='push';edict.castable=true;items.towers={unit(451,0,'building')}
assert(tick()==nil);items.towers[1].x=449;assert(tick().name==edict.name)
-- A running Pulse Nova turns off even below its activation mana cost.
reset();nova.on=true;bot.mana=10;assert(tick().name==nova.name)
nova.on=false;nova.castable=true;bot.mana=200;enemy=unit(300);enemies={enemy};assert(tick()==nil)
-- Farming keeps Pulse Nova active for a surviving neutral pair.
reset();nova.on=true;bot.mode='farm';bot.attacking=true;neutrals={unit(100,0,'creep'),unit(200,0,'creep')}
assert(tick()==nil);neutrals={};assert(tick().name==nova.name)
-- Farm Split Earth computes its center from lane creeps, even with no heroes.
reset();bot.mode='farm';bot.attacking=true;split.castable=true
lane={unit(100,0,'creep'),unit(110,0,'creep'),unit(120,0,'creep'),unit(130,0,'creep')}
assert(tick().point.x==115)
-- Nihilism supports ongoing AoE damage, with immunity respected.
reset();bot.mode='attack';enemy=unit(300);enemies={enemy};bot.target=enemy;nihil.castable=true;nova.on=true
assert(tick().name==nihil.name);enemy.immune=true;assert(tick().name==nova.name)
-- Stolen Split Earth predicts total delay and rejects a fleeing out-of-range point.
reset();bot.mode='attack';enemy=unit(500);enemy.speed=100;bot.target=enemy;enemies={enemy};split.castable=true
assert(stolen.ConsiderStolenSpell(split));assert(actions[1].point.x==605)
enemy.speed=200;actions={};assert(not stolen.ConsiderStolenSpell(split));assert(#actions==0)
-- Blocked unit targets and occupied action queues never receive a stolen spell.
reset();bot.mode='attack';enemy=unit(300);enemy.blocked=true;bot.target=enemy;enemies={enemy};storm.castable=true
assert(not stolen.ConsiderStolenSpell(storm));enemy.blocked=false;bot.queued=true;assert(not stolen.ConsiderStolenSpell(storm))
reset();nova.on=true;bot.mana=10;assert(stolen.UsePulseNovaOff());bot.channel=true;assert(not stolen.UsePulseNovaOff())
print('Leshrac ability scenarios passed')
