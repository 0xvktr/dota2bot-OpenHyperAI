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
    function a:GetSpecialValueInt(key) assert(self.values[key]~=nil,'unexpected ability key '..self.name..':'..key);return math.floor(self.values[key]) end
    function a:GetSpecialValueFloat(key) assert(self.values[key]~=nil,'unexpected ability key '..self.name..':'..key);return self.values[key] end
    function a:GetCurrentCharges() return self.charges end
    function a:GetLevel() return self.level or 4 end
    function a:GetAbilityDamage() return self.values.damage or 0 end
    function a:IsHidden() return self.hidden==true end
    function a:IsNull() return self.null==true end
    function a:IsActivated() return self.activated~=false end
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
J.CanCastAbility=function(a) return a~=nil and not a:IsNull() and not a:IsHidden() and a:IsActivated() and a:IsFullyCastable() and a.trained end
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

UNIT_LIST_ENEMIES=3
function GetUnitList(kind)
    if kind==UNIT_LIST_ENEMIES then
        local out={};for _,list in pairs({enemies,lane,neutrals}) do for _,u in pairs(list) do out[#out+1]=u end end;return out
    end
    return enemies
end
local function decorate(u)
    function u:IsNull() return self.null==true end
    function u:IsAlive() return self.hp>0 end
    function u:IsBuilding() return self.kind=='building' end
    function u:IsInvisible() return self.invisible==true end
    function u:IsDisarmed() return self.disarmed==true end
    function u:IsStunned() return self.stunned==true end
    function u:IsHexed() return self.hexed==true end
    function u:IsNightmared() return self.nightmare==true end
    function u:IsMuted() return self.muted==true end
    function u:IsUsingAbility() return self.using==true end
    function u:IsCastingAbility() return self.casting==true end
    function u:GetPlayerID() return self.owner or 0 end
    function u:NumQueuedActions() return self.queued and 1 or 0 end
    function u:Action_AttackUnit(target) actions[#actions+1]={name='ward_attack',target=target} end
    return u
end
decorate(bot)
function bot:IsCastingAbility() return self.casting==true end
function bot:GetCurrentActiveAbility() return self.active end
function bot:GetNearbyTowers() return {} end
function bot:ActionQueue_UseAbilityOnEntity(a,u) self:Action_UseAbilityOnEntity(a,u) end
J.SetQueuePtToINT=function() end
J.IsItemAvailable=function() return bot.protectionItem end
J.HasQueuedAction=function(u) return u.queued==true end
J.IsStunProjectileIncoming=function() return bot.projectile==true end
J.IsLocationInChrono=function() return bot.chrono==true end
J.IsLocationInBlackHole=function() return bot.hole==true end
function IsLocationPassable() return bot.passable~=false end
J.GetEnemiesNearLoc=function(p,r)
    local out={};for _,u in pairs(enemies) do if GetUnitToLocationDistance(u,p)<=r then out[#out+1]=u end end;return out
end
J.CanCastAbility=function(a)
    return a~=nil and not a:IsNull() and not a:IsHidden() and a:IsActivated() and not a:IsPassive() and a:IsFullyCastable() and a:IsTrained()
end
J.CanNotUseAbility=function(u)
    return u.channel or u.using or u.casting or u.silenced or u.queued or u.stunned or u.hexed or u.nightmare or u.invulnerable or false
end

UNIT_LIST_ALLIED_HEROES=5
function GetUnitList(kind) return kind==UNIT_LIST_ALLIED_HEROES and allies or enemies end
local function effects(u)
    function u:NumModifiers() return #(self.effects or {}) end
    function u:GetModifierByName(name) for i,e in ipairs(self.effects or {}) do if e.name==name then return i-1 end end;return -1 end
    function u:GetModifierSourceAbility(index) assert(type(index)=='number');return self.effects[index+1].source end
    function u:GetModifierAuxiliaryUnits(index) assert(type(index)=='number');return self.effects[index+1].units end
    function u:GetHealthRegen() return self.regen or 1 end
    function u:IsHero() return self.kind=='hero' end
    return u
end
effects(bot)
function bot:IsRooted() return self.rooted==true end
local lens=ability('item_aether_lens',0,0,{cast_range_bonus=225})
local sup=ability('rubick_arcane_supremacy',0,0,{cast_range=240});sup.trained=false
local tether=ability('wisp_tether',1600,40,{latch_distance=700,latch_speed=1000,radius=1000},0)
local spirits=ability('wisp_spirits',0,120,{max_range=650,min_range=200,hero_hit_radius=110,explode_radius=360},0)
local over=ability('wisp_overcharge',0,100,{},0)
local relocate=ability('wisp_relocate',0,175,{cast_delay=3.25,return_time=12},0)
local cancel=ability('wisp_tether_break',0,0,{},0)
local inward=ability('wisp_spirits_in',0,0,{},0)
local outward=ability('wisp_spirits_out',0,0,{},0)
for _,a in pairs(abilities) do
    function a:GetCaster() return self.caster or bot end
    function a:GetCooldownTimeRemaining() return self.cd or 0 end
    function a:IsInAbilityPhase() return self.phase==true end
    function a:GetToggleState() return self.on==true end
end
J.GetAttackProjectileDamageByRange=function(u) return u.projectileDamage or 0 end
J.GetTeamFountain=function() return Vector(-10000,0) end
J.IsLocHaveTower=function() return bot.tower==true end
local function reset()
    actions,enemies,allies,lane,ownLane,neutrals,items={},{},{},{},{},{},{}
    for k,value in pairs(unit(0)) do bot[k]=value end
    decorate(bot);effects(bot);bot.team=2;bot.effects={};bot.projectileDamage=0;bot.regen=1;bot.tower=false;bot.stateTetheredHero=nil
    bot.target=nil;bot.attackTarget=nil;bot.scepter=false;bot.attacking=false;bot.damaged=false;bot.fight=false;bot.active=nil
    for _,flag in pairs({'channel','using','casting','silenced','queued','stunned','hexed','nightmare','invulnerable','invisible','projectile','chrono','hole','muted','rooted'}) do bot[flag]=false end
    bot.passable=true;bot.spam=true;now=now+20
    for _,a in pairs(abilities) do a.castable=false;a.hidden=false;a.null=false;a.activated=true;a.on=false;a.trained=true;a.cd=0;a.phase=false;a.caster=nil end
    sup.trained=false
end
local function enemy(x,hp)
    local u=effects(decorate(unit(x)));u.hp=hp or 1000;enemies[#enemies+1]=u;return u
end
local function ally(x,hp)
    local u=effects(decorate(unit(x)));u.team=2;u.hp=hp or 1000;allies[#allies+1]=u;return u
end
local function bind(u,source)
    bot.effects={{name='modifier_wisp_tether',source=source or tether,units={u}}};bot.mods.modifier_wisp_tether=true
end
local function orbs(radius)
    local orb=effects(decorate(unit(radius,0,'orb')));orb.team=2
    bot.effects={{name='observed_spirit_effect',source=spirits,units={orb}}};return orb
end
local native=H.load('npc_dota_hero_wisp','pos_5')
local copy=H.realDofile('bots/FunLib/rubick_hero/wisp.lua')
local checks=0
for _,owner in ipairs({native,copy}) do
    local function tick(a)
        actions={};if owner==native then owner.SkillsComplement() else owner.ConsiderStolenSpell(a) end
    end
    local function cast(a)
        tick(a);assert(#actions==1 and actions[1].name==a.name,'expected '..a.name..', got '..(#actions>0 and actions[1].name or 'none'));checks=checks+1;return actions[1]
    end
    local function noCast(a)
        tick(a);assert(#actions==0,'unexpected '..(#actions>0 and actions[1].name or 'action'));checks=checks+1
    end
    reset();tether.castable=true;local friend=ally(500,600);bot.regen=3
    assert(cast(tether).target==friend);assert(bot.stateTetheredHero==nil,'cast request is not a Tether observation')
    friend.immune=true;assert(cast(tether).target==friend);friend.hp=1000;noCast(tether)
    friend.hp=600;friend.illusion=true;noCast(tether);friend.illusion=false;friend.invulnerable=true;noCast(tether)
    reset();tether.castable=true;friend=ally(1600,500);bot.regen=3;cast(tether)
    friend.x=1601;noCast(tether);items[0]=lens;friend.x=1825;cast(tether);friend.x=1826;noCast(tether)
    reset();tether.castable=true;friend=ally(900,500);bot.regen=3;bot.rooted=true;noCast(tether)
    friend.x=500;cast(tether);bot.mods.modifier_puck_coiled=true;cast(tether);friend.x=900;bot.rooted=false;bot.tower=true;noCast(tether)
    bot.tower=false;bot.mods.modifier_puck_coiled=true;noCast(tether)
    reset();over.castable=true;friend=ally(500);friend.attacking=true;friend.attackTarget=enemy(600);bind(friend)
    cast(over);assert(bot.stateTetheredHero==friend)
    bot.effects={};noCast(over);assert(bot.stateTetheredHero==nil)
    tether.caster=enemy(100);bind(friend);noCast(over);tether.caster=nil
    reset();over.castable=true;friend=ally(500,500);friend.damaged=true;friend.immune=true;bind(friend);cast(over)
    friend.mods.modifier_ice_blast=true;noCast(over);friend.using=true;cast(over)
    friend.using=false;friend.mods={};friend.channel=true;cast(over)
    bot.effects[#bot.effects+1]={name='actual_overcharge',source=over,units={}};noCast(over)
    reset();over.castable=true;bot.attacking=true;bot.attackTarget=enemy(100);cast(over)
    bot.attackTarget.x=700;noCast(over)
    reset();spirits.castable=true;bot.mode='attack';bot.target=enemy(700);cast(spirits)
    bot.target.x=761;noCast(spirits);bot.target.x=700;bot.target.immune=true;noCast(spirits)
    bot.target.immune=false;bot.target.mods.modifier_item_blade_mail_reflect=true;noCast(spirits)
    reset();spirits.castable=true;bot.mode='farm';neutrals={unit(200,0,'creep'),unit(300,0,'creep')};noCast(spirits)
    neutrals[3]=unit(400,0,'creep');cast(spirits);orbs(425);noCast(spirits)
    reset();spirits.castable=true;bot.scepter=true;enemy(500);noCast(spirits)
    local orb=orbs(425);cast(spirits);orb.owner=2;noCast(spirits)
    reset();inward.castable=true;outward.castable=true;bot.target=enemy(200);orbs(600);cast(inward)
    inward.on=true;noCast(inward);orbs(200);cast(inward)
    inward.on=false;bot.target.x=650;cast(outward)
    outward.on=true;orbs(650);cast(outward);outward.on=false;bot.effects={};noCast(outward)
    reset();relocate.castable=true;bot.hp=250;bot.damaged=true;enemy(1000);assert(cast(relocate).point.x==-10000)
    now=now+0.2;noCast(relocate);now=now+0.3;cast(relocate)
    relocate.cd=70;now=now+0.1;noCast(relocate);now=now+3.2;noCast(relocate);now=now+0.3;cast(relocate)
    reset();relocate.castable=true;bot.hp=250;bot.damaged=true;enemy(1000);cast(relocate);relocate.cd=70;now=now+0.1;noCast(relocate);bot.stunned=true;noCast(relocate);bot.stunned=false;relocate.castable=false;over.castable=true;cast(over)
    reset();relocate.castable=true;friend=ally(1000,200);friend.damaged=true;friend.immune=true;enemy(1100);bind(friend)
    friend.mods.modifier_kunkka_x_marks_the_spot=true;noCast(relocate);friend.mods={};friend.projectileDamage=250;noCast(relocate);friend.projectileDamage=0;cast(relocate);assert(bot.hp==1000,'ally save has no arbitrary caster-HP requirement')
    reset();relocate.castable=true;bot.hp=200;bot.damaged=true;enemy(500);noCast(relocate)
    enemies[1].x=1000;bot.projectileDamage=100;noCast(relocate);bot.projectileDamage=0;bot.mods.modifier_kunkka_x_marks_the_spot=true;noCast(relocate)
    reset();relocate.castable=true;bot.hp=200;bot.damaged=true;enemy(1000);bot.effects={{name='modifier_wisp_tether',source=tether,units={}}};noCast(relocate)
    reset();relocate.castable=true;bot.hp=200;bot.damaged=true;friend=ally(400);bind(friend);enemy(1000);noCast(relocate)
    friend.invulnerable=true;noCast(relocate);assert(bot.stateTetheredHero==friend);friend.invulnerable=false;friend.channel=true;noCast(relocate);cancel.castable=true;bot.hp=190;cast(cancel)
    reset();relocate.castable=true;friend=ally(850);friend.attacking=true;friend.attackTarget=enemy(1000);bind(friend);local remote=ally(5000);remote.damaged=true;ally(5100);enemy(5200);friend.attacking=false;noCast(relocate);friend.attacking=true;cast(relocate)
    reset();relocate.castable=true;remote=ally(5000);remote.damaged=true;ally(5100);enemy(5200);noCast(relocate)
    reset();relocate.castable=true;friend=ally(500);bind(friend);remote=ally(5000);remote.damaged=true;ally(5100);enemy(5200);bot.tower=true;noCast(relocate)
    reset();tether.castable=true;friend=ally(500,500);bot.regen=3;bot.invisible=true;noCast(tether)
    bot.invisible=false;bot.channel=true;noCast(tether);bot.channel=false;bot.queued=true;noCast(tether)
    bot.queued=false;bot.stunned=true;noCast(tether)
end
reset();tether.castable=true;local friend=ally(500,500);bot.regen=3
for _,flag in ipairs({'null','hidden','trained','activated'}) do
    tether[flag]=flag=='null' or flag=='hidden';actions={};assert(copy.ConsiderStolenSpell(tether)==false and #actions==0);checks=checks+1
    tether[flag]=flag=='trained' or flag=='activated'
end
reset();over.castable=true;bot.hp=400;bot.damaged=true;local saved=abilities;abilities={[over.name]=over};assert(copy.ConsiderStolenSpell(over));abilities=saved;checks=checks+1
local original=GetBot;GetBot=function() error('unknown actor lookup') end
assert(copy.ConsiderStolenSpell({GetName=function() return 'unknown' end})==nil);GetBot=original;checks=checks+1
print('Io ability scenarios passed: '..checks)
