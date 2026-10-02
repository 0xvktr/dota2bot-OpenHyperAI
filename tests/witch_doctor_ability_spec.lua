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
local q=ability('witch_doctor_paralyzing_cask',600,140,{base_damage=100,speed=1200,bounce_range=575,creep_damage_pct=100},0.2)
local w=ability('witch_doctor_voodoo_restoration',0,25,{radius=650,heal=50,mana_per_second=18,does_heal_all_allies=1,self_only_heal_percentage=0},0)
local e=ability('witch_doctor_maledict',600,120,{radius=200},0.35)
local r=ability('witch_doctor_death_ward',500,200,{attack_range_tooltip=650,damage=120},0.35)
local s=ability('witch_doctor_voodoo_switcheroo',0,200,{},0.1)
for _,a in pairs(abilities) do
    a.activated=true;a.hidden=false;a.null=false;a.passive=false
    function a:IsNull() return self.null==true end
    function a:IsActivated() return self.activated~=false end
    function a:IsPassive() return self.passive==true end
    function a:GetToggleState() return self.on==true end
end
local function reset()
    actions,enemies,allies,lane,ownLane,neutrals,items={},{},{},{},{},{},{}
    for k,value in pairs(unit(0)) do bot[k]=value end
    decorate(bot);bot.team=2;bot.target=nil;bot.attackTarget=nil;bot.scepter=false;bot.disarmed=false;bot.damaged=false;bot.fight=false;bot.active=nil
    for _,flag in pairs({'channel','using','casting','silenced','queued','stunned','hexed','nightmare','invulnerable','invisible','projectile','chrono','hole','muted'}) do bot[flag]=false end
    bot.passable=true;bot.protectionItem=nil;bot.spam=true;now=0
    for _,a in pairs(abilities) do a.castable=false;a.hidden=false;a.null=false;a.activated=true;a.on=false;a.passive=false end
    supremacy.trained=false;w.values.does_heal_all_allies=1
end
local function enemy(x,hp)
    local u=decorate(unit(x));u.hp=hp or 1000;enemies[#enemies+1]=u;return u
end
local function ally(x,hp)
    local u=decorate(unit(x));u.team=2;u.hp=hp or 1000;allies[#allies+1]=u;return u
end
local native=H.load('npc_dota_hero_witch_doctor','pos_5')
local copy=H.realDofile('bots/FunLib/rubick_hero/witch_doctor.lua')
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
    reset();q.castable=true;local foe=enemy(600,90)
    assert(cast(q).target==foe);foe.x=601;decline(q)
    items[0]=lens;foe.x=825;cast(q);foe.x=826;decline(q)
    reset();q.castable=true;foe=enemy(500,120);decline(q)
    foe.hp=90;foe.regen=50;decline(q);foe.regen=0;foe.immune=true;decline(q)
    foe.immune=false;foe.blocked=true;decline(q);foe.blocked=false;foe.mods.modifier_nyx_assassin_spiked_carapace=true;decline(q)
    reset();q.castable=true;foe=enemy(500);foe.channel=true;cast(q);foe.mods.modifier_teleporting=true;foe.remaining=0.1;decline(q);foe.remaining=2;cast(q)
    reset();q.castable=true;foe=enemy(500);local victim=ally(450,300);victim.damaged=true;foe.attackTarget=victim;assert(cast(q).target==foe)
    reset();q.castable=true;bot.mode='lane';local creep=decorate(unit(400,0,'creep'));creep.name='npc_dota_creep_ranged';creep.hp=90;lane={creep};cast(q);creep.hp=110;decline(q)
    reset();q.castable=true;bot.mode='farm';neutrals={decorate(unit(300,0,'creep')),decorate(unit(500,0,'creep')),decorate(unit(600,0,'creep'))};cast(q)
    reset();e.castable=true;bot.mode='attack';foe=enemy(790);bot.target=foe
    local a=cast(e);assert(a.point:Length2D()==600);foe.x=801;decline(e)
    foe.x=500;foe.speed=1000;decline(e);foe.speed=0;foe.immune=true;decline(e)
    foe.immune=false;foe.mods.modifier_maledict=true;decline(e)
    reset();r.castable=true;bot.mode='attack';foe=enemy(1100);foe.disabled=true;foe.immune=true;bot.target=foe
    a=cast(r);assert(a.point:Length2D()==500);foe.x=1151;decline(r)
    foe.x=900;foe.attackImmune=true;decline(r);foe.attackImmune=false;bot.chrono=true;decline(r)
    bot.chrono=false;foe.disabled=false;decline(r);ally(850).attackTarget=foe;cast(r)
    foe.attackTarget=bot;decline(r)
    reset();w.castable=true;victim=ally(650,200);victim.immune=true;cast(w)
    victim.x=651;decline(w);victim.x=400;victim.mods.modifier_ice_blast=true;decline(w)
    reset();w.castable=true;bot.hp=250;cast(w);bot.mana=50;decline(w)
    w.on=true;w.castable=false;bot.mana=20;cast(w)
    reset();w.on=true;w.castable=false;cast(w);w.hidden=true;decline(w)
    reset();w.castable=true;bot.hp=200;bot.channel=true;bot.active=r
    cast(w);bot.active=q;decline(w);bot.active=ability('item_tpscroll',0,0,{});cast(w)
    bot.queued=true;decline(w);bot.queued=false;bot.silenced=true;decline(w)
    bot.silenced=false;w.activated=false;decline(w);w.activated=true;w.null=true;decline(w)
    reset();s.castable=true;bot.projectile=true;cast(s)
    bot.queued=true;decline(s);bot.queued=false;s.hidden=true;decline(s)
    reset();s.castable=true;bot.mode='attack';foe=enemy(500);foe.disabled=true;cast(s)
    reset();q.castable=true;foe=enemy(500,80);bot.invisible=true;decline(q)
    bot.invisible=false;bot.channel=true;bot.active=r;decline(q)
end
reset();q.castable=true;local foe=enemy(500,80)
local supplied=ability('foreign',0,0,{});assert(copy.ConsiderStolenSpell(supplied)==nil)
for _,flag in pairs({'null','hidden','activated'}) do
    reset();q.castable=true;foe=enemy(500,80);q[flag]=flag~='activated'
    actions={};assert(copy.ConsiderStolenSpell(q)==false and #actions==0)
end
reset();q.castable=true;local solo=enemy(500,80)
local saved=abilities
abilities={[q.name]=q}
actions={};assert(copy.ConsiderStolenSpell(q) and #actions==1 and actions[1].target==solo)
abilities=saved
reset();w.castable=true;bot.hp=200;bot.channel=true
local foreignWard=ability('foreign_ward',500,200,{attack_range_tooltip=650},0.35)
foreignWard.GetName=function() return 'witch_doctor_death_ward' end
bot.active=foreignWard;actions={};assert(not copy.UseRestorationDuringChannel() and #actions==0)
bot.active=r
for _,modifier in pairs({'modifier_ringmaster_the_box_buff','modifier_doom_bringer_doom','modifier_item_forcestaff_active'}) do
    bot.mods[modifier]=true;assert(not copy.UseRestorationDuringChannel());bot.mods[modifier]=nil
end
reset();r.castable=true;bot.channel=true;bot.active=r
local glimmer=ability('item_glimmer_cape',0,0,{});glimmer.castable=true;bot.protectionItem=glimmer
native.SkillsComplement();assert(#actions==1 and actions[1].name==glimmer.name and actions[1].target==bot)
actions={};bot.active=q;native.SkillsComplement();assert(#actions==0)
reset();foe=enemy(200);foe.immune=true;bot.target=foe
local ward=decorate(unit(0,0,'ward'));ward.name='npc_dota_witch_doctor_death_ward';ward.team=2;ward.attackRange=650;ward.invulnerable=true
assert(copy.HandleDeathWard(ward));assert(actions[1].name=='ward_attack' and actions[1].target==foe)
actions={};ward.owner=1;assert(not copy.HandleDeathWard(ward) and #actions==0)
ward.owner=0;foe.attackImmune=true;assert(copy.HandleDeathWard(ward) and #actions==0)
foe.attackImmune=false;ward.queued=true;assert(copy.HandleDeathWard(ward) and #actions==0)
print('Witch Doctor ability scenarios passed: '..checks)
