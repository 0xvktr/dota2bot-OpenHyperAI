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






UNIT_LIST_ENEMIES=5;UNIT_LIST_ALLIES=6
function GetUnitList(kind) if kind==UNIT_LIST_ENEMY_HEROES then return enemies end;local out={};if kind==UNIT_LIST_ALLIES then for _,u in ipairs(allies) do out[#out+1]=u end;for _,u in ipairs(ownLane) do out[#out+1]=u end;return out end;assert(kind==UNIT_LIST_ENEMIES);for _,u in ipairs(enemies) do out[#out+1]=u end;for _,u in ipairs(lane) do out[#out+1]=u end;return out end
local trees={}
function GetTreeLocation(id) return trees[id] end
J.GetRemainStunTime=function(u) return u.stunRemaining or 0 end
function bot:NumQueuedActions() return self.queued and 1 or 0 end
function bot:GetCurrentActiveAbility() return self.active end
function bot:Action_ClearActions(clear) actions[#actions+1]={name='clear',clear=clear} end
function bot:Action_MoveToLocation(p) actions[#actions+1]={name='escape_move',point=p} end
J.IsKeyWordUnit=function(word,u) return u.name and string.find(u.name,word)~=nil end

J.IsInEtherealForm=function(u) return u.ethereal==true end
local oldDecorate=decorate;decorate=function(u)
 oldDecorate(u)
 function u:GetModifierByName(name) return self.mods[name] and 1 or -1 end
 function u:GetModifierSourceAbility(index) return self.curseSource end
 function u:IsAlive() return self.hp>0 end
 return u
end
decorate(bot)
local q=ability('winter_wyvern_arctic_burn',0,100,{attack_range_bonus=325,mana_cost_scepter=20})
function q:GetToggleState() return self.toggle==true end
local w=ability('winter_wyvern_splinter_blast',1150,135,{split_radius=500,damage=320,projectile_speed=1200,secondary_projectile_speed=1000,projectile_max_time=1},0.3)
local e=ability('winter_wyvern_cold_embrace',1000,80,{duration=4,heal_additive=55,heal_percentage=4.5},0.3)
local r=ability('winter_wyvern_winters_curse',800,250,{radius=525,duration=2},0.3)
function r:GetCaster() return self.owner or bot end
local N=H.load('npc_dota_hero_winter_wyvern','pos_5')
local oldReset=reset;reset=function() oldReset();bot.disarmed=false;bot.attackRange=450;bot.projectileDamage=0;q.toggle=false;for _,a in pairs(abilities) do a.null=false;a.hidden=false;a.activated=true;a.trained=true end;supremacy.trained=false;r.owner=nil end
local function enemy(x,hp,y) local u=decorate(unit(x,y));u.hp=hp or 1000;enemies[#enemies+1]=u;return u end
local function ally(x,hp) local u=decorate(unit(x));u.team=2;u.hp=hp or 1000;allies[#allies+1]=u;return u end
local function tick() actions={};N.SkillsComplement();return actions[1] end
local function cast(name) local a=tick();assert(a and a.name==name,'expected '..name..', got '..(a and a.name or 'nothing'));return a end
local function noCast() assert(tick()==nil,'unexpected action') end
-- The unaffected primary needs a different legal nearby unit, including a human ally.
reset();w.castable=true;local foe=enemy(1100,320);noCast();local human=ally(1000);assert(cast(w.name).target==human);foe.regen=1;noCast();foe.regen=0;human.x=1151;noCast();items[0]=lens;cast(w.name);human.x=1000;foe.x=1501;noCast();foe.x=1500;cast(w.name);foe.immune=true;noCast()
reset();w.castable=true;foe=enemy(1000,320);local host=decorate(unit(500,0,'creep'));lane={host};assert(cast(w.name).target==host);host.blocked=true;noCast();host.blocked=false;foe.speed=200;noCast();foe.speed=0;host.hidden=true;host.invalid=true;noCast()
reset();w.castable=true;bot.mode='attack';foe=enemy(1000);bot.target=foe;human=ally(700);cast(w.name);human.x=499;noCast()
reset();w.castable=true;bot.mode='farm';neutrals={decorate(unit(500,0,'creep')),decorate(unit(600,0,'creep')),decorate(unit(700,0,'creep'))};noCast();neutrals[4]=decorate(unit(800,0,'creep'));cast(w.name);neutrals[4].x=1600;noCast()
-- Curse ownership permits caster damage only after an actual source modifier.
reset();w.castable=true;foe=enemy(1000,320);human=ally(800);foe.mods.modifier_winter_wyvern_winters_curse=true;noCast();foe.curseSource=r;cast(w.name);r.owner=human;noCast();r.owner=nil;foe.mods.modifier_necrolyte_reapers_scythe=true;noCast()
-- Physical saves do not rely on human retreat or core mode.
reset();e.castable=true;human=ally(1000,300);foe=enemy(1100);foe.attackTarget=human;foe.physThreat=400;foe.allThreat=400;assert(cast(e.name).target==human);human.x=1001;noCast();items[0]=lens;cast(e.name);human.channel=true;cast(e.name);foe.physThreat=200;foe.allThreat=200;noCast();human.channel=false;cast(e.name);human.immune=true;cast(e.name)
reset();e.castable=true;human=ally(500,300);foe=enemy(600);foe.physThreat=200;foe.allThreat=1000;foe.attackTarget=human;noCast();foe.physThreat=500;foe.allThreat=1000;cast(e.name);human.mods.modifier_ice_blast=true;cast(e.name);human.ethereal=true;noCast()
reset();e.castable=true;bot.hp=600;assert(cast(e.name).target==bot);assert(e:GetSpecialValueInt('heal_percentage')==4 and e:GetSpecialValueFloat('heal_percentage')==4.5);bot.mods.modifier_ice_blast=true;noCast();bot.mods={};bot.channel=true;noCast()
reset();e.castable=true;bot.hp=200;bot.projectileDamage=300;bot.mods.modifier_ice_blast=true;cast(e.name);bot.mods.modifier_winter_wyvern_cold_embrace=true;noCast()
reset();e.castable=true;local small=ally(500,400);local large=ally(700,1000);large.maxhp=3000;local physicalA=enemy(550);physicalA.attackTarget=small;physicalA.physThreat=365;physicalA.allThreat=365;local physicalB=enemy(750);physicalB.attackTarget=large;physicalB.physThreat=40;physicalB.allThreat=40;assert(cast(e.name).target==large,'fractional healing must affect save ranking')
-- Primary Curse pierces immunity and interrupts a lone low-health channel.
reset();r.castable=true;foe=enemy(800,100);foe.immune=true;foe.channel=true;cast(r.name);foe.x=801;noCast();items[0]=lens;cast(r.name);foe.blocked=true;noCast()
reset();r.castable=true;bot.mode='attack';foe=enemy(600,500);bot.target=foe;foe.physThreat=10000;noCast();local attacker=enemy(800);attacker.physThreat=200;cast(r.name);attacker.immune=true;noCast();attacker.immune=false;attacker.disarmed=true;noCast();attacker.disarmed=false;attacker.disabled=true;noCast();attacker.disabled=false;attacker.x=1126;noCast();attacker.x=1125;cast(r.name);foe.mods.modifier_faceless_void_chronosphere_freeze=true;noCast()
reset();r.castable=true;bot.mode='retreat';bot.hp=900;bot.damaged=true;foe=enemy(500,200);foe.chasing=bot;cast(r.name);bot.damaged=false;noCast()
-- Burn uses actual current attack range once buffed; toggle OFF survives cooldown.
reset();q.castable=true;bot.mode='attack';foe=enemy(775);bot.target=foe;cast(q.name);foe.x=776;noCast();foe.x=700;bot.mods.modifier_winter_wyvern_arctic_burn_flight=true;noCast();bot.mods={};foe.immune=true;noCast()
reset();q.toggle=true;bot.scepter=true;bot.mana=0;cast(q.name);q.hidden=true;noCast();q.hidden=false;q.activated=false;noCast();q.activated=true;q.null=true;noCast()
reset();q.castable=true;bot.scepter=true;bot.mode='attack';bot.attackRange=775;q.toggle=true;foe=enemy(1000);bot.target=foe;cast(q.name);foe.x=775;noCast();bot.mana=100;cast(q.name)
local R=require('bots/FunLib/rubick_hero/winter_wyvern')
local unknown=setmetatable({GetName=function() return 'unrelated_spell' end},{__index=function(_,key) error('unknown spell queried '..key) end});assert(R.ConsiderStolenSpell(unknown)==nil)
reset();r.castable=true;foe=enemy(1265);foe.channel=true;items[0]=lens;supremacy.trained=true;assert(R.ConsiderStolenSpell(r));bot.mods.modifier_break=true;assert(not R.ConsiderStolenSpell(r))
reset();w.castable=true;foe=enemy(1000,320);human=ally(800);abilities.winter_wyvern_arctic_burn=nil;abilities.winter_wyvern_winters_curse=nil;assert(R.ConsiderStolenSpell(w));abilities.winter_wyvern_arctic_burn=q;abilities.winter_wyvern_winters_curse=r;bot.queued=true;assert(not R.ConsiderStolenSpell(w))
reset();bot.scepter=true;q.toggle=true;bot.mana=0;actions={};assert(R.ConsiderStolenArcticBurnToggle());assert(actions[1].name==q.name);q.hidden=true;assert(not R.ConsiderStolenArcticBurnToggle());q.hidden=false;bot.channel=true;assert(not R.ConsiderStolenArcticBurnToggle());bot.channel=false;q.toggle=false;assert(not R.ConsiderStolenArcticBurnToggle())
print('Winter Wyvern ability scenarios passed')
