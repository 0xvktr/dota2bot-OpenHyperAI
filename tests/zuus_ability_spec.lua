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
    function u:GetModifierByName(name) return self.mods[name] and 0 or -1 end
    function u:GetModifierRemainingDuration(index) assert(index==0);return self.remaining or 10 end
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
local q=ability('zuus_arc_lightning',800,100,{arc_damage=180,radius=450},0.2)
local w=ability('zuus_lightning_bolt',850,135,{damage=380,aoe_radius=0,spread_aoe=325},0.3)
local e=ability('zuus_heavenly_jump',0,80,{hop_distance=600,hop_duration=0.5,range=1000},0)
local r=ability('zuus_thundergods_wrath',0,500,{damage=575},0.4)
local d=ability('zuus_cloud',0,275,{cloud_radius=450,cloud_bolt_interval=2.5},0.2)
local hands=ability('zuus_lightning_hands',0,0,{},0)
for _,a in pairs(abilities) do
    function a:GetToggleState() return self.on==true end
end
local lastSeen={}
function GetTeamPlayers() return {9} end
function GetOpposingTeam() return 3 end
function IsHeroAlive() return true end
function GetHeroLastSeenInfo(id) return lastSeen[id] end
UNIT_LIST_ALLIES=4
function GetUnitList(kind) return kind==UNIT_LIST_ALLIES and allies or enemies end
function bot:GetSpellAmp() return self.amp or 0 end
function bot:IsRooted() return self.rooted==true end
function bot:IsFacingLocation() return self.facing~=false end
function bot:ActionQueue_UseAbility(a) self:Action_UseAbility(a) end
J.GetFaceTowardDistanceLocation=function(_,distance) return Vector(distance*(bot.direction or 1),0) end
J.GetEscapeLoc=function() return Vector(-3000,0) end
local function reset()
    actions,enemies,allies,lane,ownLane,neutrals,items={},{},{},{},{},{},{}
    for k,value in pairs(unit(0)) do bot[k]=value end
    decorate(bot);bot.team=2;bot.target=nil;bot.attackTarget=nil;bot.scepter=false;bot.disarmed=false;bot.damaged=false;bot.fight=false;bot.active=nil
    for _,flag in pairs({'channel','using','casting','silenced','queued','stunned','hexed','nightmare','invulnerable','invisible','projectile','chrono','hole','muted','rooted'}) do bot[flag]=false end
    lastSeen={};bot.passable=true;bot.spam=true;bot.facing=true;bot.direction=1;bot.amp=0;now=0
    for _,a in pairs(abilities) do a.castable=false;a.hidden=false;a.null=false;a.activated=true;a.on=false;a.trained=true end
    supremacy.trained=false;hands.hidden=true;w.values.aoe_radius=0
end
local function enemy(x,hp)
    local u=decorate(unit(x));u.hp=hp or 1000;enemies[#enemies+1]=u;return u
end
local function ally(x,hp)
    local u=decorate(unit(x));u.team=2;u.hp=hp or 1000;allies[#allies+1]=u;return u
end
local native=H.load('npc_dota_hero_zuus','pos_2')
local copy=H.realDofile('bots/FunLib/rubick_hero/zuus.lua')
local checks=0
for _,owner in pairs({native,copy}) do
    local function tick(a)
        actions={}
        if owner==native then owner.SkillsComplement() else owner.ConsiderStolenSpell(a) end
    end
    local function cast(a)
        tick(a);assert(#actions==1 and actions[1].name==a.name,'expected one '..a.name);checks=checks+1;return actions[1]
    end
    local function decline(a)
        tick(a);assert(#actions==0,'unexpected cast of '..a.name);checks=checks+1
    end
    reset();q.castable=true;local foe=enemy(800,175);assert(cast(q).target==foe)
    foe.x=801;decline(q);items[0]=lens;foe.x=1025;cast(q);foe.x=1026;decline(q)
    reset();q.castable=true;foe=enemy(500,181);decline(q)
    foe.hp=175;foe.regen=30;decline(q);foe.regen=0;foe.immune=true;decline(q)
    foe.immune=false;foe.blocked=true;decline(q);foe.blocked=false;foe.mods.modifier_nyx_assassin_spiked_carapace=true;decline(q)
    reset();q.castable=true;foe=enemy(500);bot.mode='attack';bot.target=foe;cast(q)
    reset();q.castable=true;foe=enemy(500);local victim=ally(400,200);victim.damaged=true;foe.attackTarget=victim;cast(q)
    reset();q.castable=true;bot.mode='lane';local creep=decorate(unit(400,0,'creep'));creep.name='npc_dota_creep_ranged';creep.hp=170;lane={creep};cast(q)
    creep.mods.modifier_fountain_glyph=true;decline(q)
    reset();q.castable=true;bot.mode='farm';neutrals={decorate(unit(200,0,'creep')),decorate(unit(300,0,'creep')),decorate(unit(400,0,'creep'))};cast(q)
    table.remove(neutrals);decline(q)
    reset();w.castable=true;foe=enemy(850);foe.channel=true;assert(cast(w).target==foe);foe.mods.modifier_teleporting=true;foe.remaining=0.1;decline(w);foe.remaining=2;cast(w);foe.mods.modifier_teleporting=nil
    foe.x=1100;local action=cast(w);assert(action.point:Length2D()==850);foe.x=1176;decline(w)
    reset();w.castable=true;foe=enemy(1100,375);enemy(840);decline(w)
    reset();w.castable=true;foe=enemy(500,375);foe.regen=30;decline(w);foe.regen=0;cast(w)
    w.values.aoe_radius=325;action=cast(w);assert(action.point~=nil and action.target==nil)
    reset();w.castable=true;bot.mode='retreat';bot.damaged=true;lastSeen[9]={{location=Vector(700,0),time_since_seen=0.5}}
    assert(cast(w).point.x==700);lastSeen[9][1].time_since_seen=2;decline(w)
    lastSeen[9][1].time_since_seen=0.5;lastSeen[9][1].location=Vector(851,0);decline(w)
    reset();r.castable=true;foe=enemy(12000,570);cast(r);foe.visible=false;decline(r)
    foe.visible=true;foe.regen=30;decline(r);foe.regen=0;foe.immune=true;decline(r)
    reset();r.castable=true;foe=enemy(12000,570);local reflect=enemy(2000);reflect.mods.modifier_item_blade_mail_reflect=true
    bot.hp=700;decline(r);bot.hp=1000;cast(r);reflect.mods.modifier_nyx_assassin_spiked_carapace=true;decline(r)
    reset();r.castable=true;foe=enemy(12000,600);victim=ally(12100);victim.attackTarget=foe;decline(r)
    local other=enemy(12200,600);ally(12300).attackTarget=other;cast(r)
    reset();d.castable=true;foe=enemy(12000,600);ally(12100).attackTarget=foe;assert(cast(d).point.x==12000);foe.speed=100;assert(cast(d).point.x==12270);foe.speed=0
    local cloud=ally(12000);cloud.name='npc_dota_zeus_cloud';decline(d)
    cloud.owner=1;cast(d);w.hidden=true;decline(d);w.hidden=false;w.trained=false;decline(d)
    reset();e.castable=true;foe=enemy(1400);bot.target=foe;bot.mode='attack';cast(e);foe.x=1601;foe.speed=-10;cast(e);foe.speed=0;decline(e);foe.x=1400
    bot.rooted=true;decline(e);bot.rooted=false;bot.passable=false;decline(e)
    bot.passable=true;bot.chrono=true;decline(e);bot.chrono=false;bot.mods.modifier_puck_coiled=true;decline(e);bot.mods.modifier_puck_coiled=nil;bot.mods.modifier_bloodseeker_rupture=true;decline(e)
    reset();e.castable=true;bot.mode='retreat';bot.damaged=true;bot.direction=-1;enemy(400);cast(e)
    bot.facing=false;decline(e)
    reset();hands.hidden=false;hands.castable=true;bot.silenced=true;bot.invisible=true;cast(hands)
    hands.on=true;decline(hands);hands.on=false;bot.queued=true;decline(hands)
    bot.queued=false;bot.channel=true;decline(hands);bot.channel=false;bot.stunned=true;decline(hands)
    reset();q.castable=true;foe=enemy(500,170);bot.invisible=true;decline(q)
    bot.invisible=false;bot.channel=true;decline(q)
end
reset();local unknown=ability('unrecognized',0,0,{});assert(copy.ConsiderStolenSpell(unknown)==nil)
for _,flag in pairs({'null','hidden','activated','trained'}) do
    reset();q.castable=true;enemy(500,170);q[flag]=flag=='null' or flag=='hidden'
    actions={};assert(copy.ConsiderStolenSpell(q)==false and #actions==0)
end
reset();q.castable=true;local foe=enemy(500,170);local saved=abilities;abilities={[q.name]=q}
assert(copy.ConsiderStolenSpell(q) and #actions==1);abilities=saved
reset();d.castable=true;foe=enemy(12000,600);ally(12100).attackTarget=foe;abilities={[d.name]=d}
assert(copy.ConsiderStolenSpell(d)==false);abilities=saved
print('Zeus ability scenarios passed: '..checks)
