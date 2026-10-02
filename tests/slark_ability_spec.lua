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
local lens=ability('item_aether_lens',0,0,{cast_range_bonus=225})
local supremacy=ability('rubick_arcane_supremacy',0,0,{cast_range=240});supremacy.trained=false
local q=ability('slark_dark_pact',0,65,{delay=1.5,radius=325,total_damage=300,total_pulses=10,self_damage_pct=30},0.001)
local w=ability('slark_pounce',0,75,{pounce_distance=700,pounce_distance_scepter=900,pounce_speed=933.33,pounce_acceleration=7000,pounce_radius=120},0)
local e=ability('slark_saltwater_shiv',150,40,{melee_range_buffer=50},0)
local r=ability('slark_shadow_dance',0,100,{},0)
local d=ability('slark_depth_shroud',400,75,{radius=225},0.1)
function bot:IsRooted() return self.rooted==true end
function bot:ActionQueue_UseAbility(a) self:Action_UseAbility(a) end
local function state(u)
    function u:GetModifierByName(name) return self.mods[name] and 0 or -1 end
    function u:GetModifierSourceAbility() return self.source end
    function u:GetNearbyHeroes(radius,enemy) return nearby(enemy and enemies or allies,self,radius) end
    return u
end
state(bot)
for _,a in pairs(abilities) do function a:GetCaster() return self.caster or bot end end
J.GetFaceTowardDistanceLocation=function(_,distance) return Vector(distance*(bot.direction or 1),0) end
J.GetEscapeLoc=function() return Vector(-3000,0) end
J.IsStuck=function() return bot.stuck==true end
J.IsLocHaveTower=function() return bot.tower==true end
J.GetETAWithAcceleration=function(distance,speed,acceleration) return distance/speed+speed/acceleration/2 end
J.GetAttackProjectileDamageByRange=function() return bot.incoming or 0 end
function bot:IsFacingLocation() return self.facing~=false end
local function reset()
    actions,enemies,allies,lane,ownLane,neutrals,items={},{},{},{},{},{},{}
    for k,value in pairs(unit(0)) do bot[k]=value end
    decorate(bot);state(bot);bot.team=2;bot.target=nil;bot.attackTarget=nil;bot.scepter=false;bot.disarmed=false;bot.damaged=false;bot.fight=false;bot.active=nil;bot.source=nil
    for _,flag in pairs({'channel','using','casting','silenced','queued','stunned','hexed','nightmare','invulnerable','invisible','projectile','chrono','hole','muted','rooted','stuck','tower'}) do bot[flag]=false end
    bot.passable=true;bot.spam=true;bot.facing=true;bot.direction=1;bot.incoming=0;now=0
    for _,a in pairs(abilities) do a.castable=false;a.hidden=false;a.null=false;a.activated=true;a.trained=true;a.caster=nil end
    supremacy.trained=false;w.charges=2
end
local function enemy(x,hp)
    local u=state(decorate(unit(x)));u.hp=hp or 1000;enemies[#enemies+1]=u;return u
end
local function ally(x,hp)
    local u=state(decorate(unit(x)));u.team=2;u.hp=hp or 1000;allies[#allies+1]=u;return u
end
local native=H.load('npc_dota_hero_slark','pos_1')
local copy=H.realDofile('bots/FunLib/rubick_hero/slark.lua')
local checks=0
for _,owner in pairs({native,copy}) do
    local function tick(a)
        actions={};if owner==native then owner.SkillsComplement() else owner.ConsiderStolenSpell(a) end
    end
    local function cast(a)
        tick(a);assert(#actions==1 and actions[1].name==a.name,'expected one '..a.name);checks=checks+1;return actions[1]
    end
    local function decline(a)
        tick(a);assert(#actions==0,'unexpected cast of '..a.name);checks=checks+1
    end
    reset();q.castable=true;local foe=enemy(325,29);cast(q);foe.x=326;decline(q)
    foe.x=300;foe.hp=29;foe.regen=1;decline(q);foe.regen=0;foe.speed=100;decline(q)
    foe.speed=0;foe.hp=31;decline(q);foe.hp=29;foe.immune=true;decline(q)
    foe.immune=false;foe.mods.modifier_nyx_assassin_spiked_carapace=true;decline(q)
    reset();q.castable=true;foe=enemy(300);bot.mode='attack';bot.target=foe;cast(q)
    bot.mods.modifier_slark_dark_pact=true;decline(q);bot.mods.modifier_slark_dark_pact=nil;bot.hp=350;decline(q)
    bot.rooted=true;cast(q);bot.rooted=false;bot.mods.modifier_slark_pounce_leash=true;decline(q)
    reset();q.castable=true;bot.projectile=true;cast(q);bot.stunned=true;decline(q)
    reset();q.castable=true;bot.mode='farm';neutrals={decorate(unit(200,0,'creep')),decorate(unit(250,0,'creep')),decorate(unit(300,0,'creep'))};cast(q)
    table.remove(neutrals);decline(q)
    reset();w.castable=true;foe=enemy(700);bot.mode='attack';bot.target=foe;cast(w)
    foe.y=121;decline(w);foe.y=0;foe.speed=500;decline(w)
    foe.speed=0;ally(750);local blocker=enemy(300);decline(w);blocker.illusion=true;cast(w)
    blocker.illusion=false;blocker.immune=true;decline(w)
    reset();w.castable=true;foe=enemy(880);bot.mode='attack';bot.target=foe;decline(w)
    bot.scepter=true;cast(w);w.charges=1;decline(w);r.castable=true
    if owner==native then native.SkillsComplement() else assert(copy.ConsiderStolenSpell(w)) end
    assert(actions[#actions].name==w.name);checks=checks+1
    reset();w.castable=true;bot.mode='retreat';bot.damaged=true;bot.direction=-1;enemy(300);cast(w)
    enemy(-300);decline(w);enemies={};bot.mods.modifier_bloodseeker_rupture=true;decline(w)
    bot.mods.modifier_bloodseeker_rupture=nil;bot.rooted=true;decline(w)
    bot.rooted=false;bot.passable=false;decline(w);bot.passable=true;bot.tower=true;decline(w)
    reset();e.castable=true;foe=enemy(200);bot.mode='attack';bot.target=foe;assert(cast(e).target==foe)
    foe.x=201;decline(e);items[0]=lens;decline(e);foe.x=200;bot.disarmed=true;decline(e)
    bot.disarmed=false;foe.attackImmune=true;decline(e);foe.attackImmune=false;foe.blocked=true;decline(e)
    reset();d.castable=true;local victim=ally(600,200);victim.immune=true;victim.damaged=true;foe=enemy(650);foe.attackTarget=victim
    local action=cast(d);assert(action.point.x==400);victim.x=626;decline(d)
    victim.x=600;victim.damaged=false;decline(d);victim.mods.modifier_legion_commander_duel=true;cast(d)
    victim.mods.modifier_slark_shadow_dance=true;decline(d)
    reset();r.castable=true;bot.hp=400;bot.damaged=true;foe=enemy(300);foe.attackTarget=bot;cast(r)
    bot.mods.modifier_slark_shadow_dance=true;decline(r)
    reset();r.castable=true;bot.incoming=400;cast(r);bot.queued=true;decline(r)
    reset();r.castable=true;q.castable=true;bot.hp=400;bot.damaged=true;foe=enemy(300,20);foe.attackTarget=bot
    if owner==native then cast(r) else cast(q) end
    reset();q.castable=true;foe=enemy(300,20);bot.invisible=true;decline(q)
    bot.mods.modifier_slark_shadow_dance=true;bot.source=r;cast(q)
    bot.source=nil;decline(q);bot.source=r;r.caster=enemy(900);decline(q)
    r.caster=nil;bot.source=d;cast(q);bot.channel=true;decline(q)
end
reset();local unknown=ability('foreign',0,0,{});assert(copy.ConsiderStolenSpell(unknown)==nil)
for _,flag in pairs({'null','hidden','activated','trained'}) do
    reset();q.castable=true;enemy(300,20);q[flag]=flag=='null' or flag=='hidden'
    actions={};assert(copy.ConsiderStolenSpell(q)==false and #actions==0)
end
reset();q.castable=true;enemy(300,20);local saved=abilities;abilities={[q.name]=q}
assert(copy.ConsiderStolenSpell(q) and #actions==1);abilities=saved
reset();q.castable=true;enemy(300,20);bot.invisible=true;bot.mods.modifier_slark_shadow_dance=true;bot.source=r
assert(copy.UseShadowDanceSpells() and #actions==1);actions={};bot.queued=true;assert(not copy.UseShadowDanceSpells() and #actions==0)
print('Slark ability scenarios passed: '..checks)
