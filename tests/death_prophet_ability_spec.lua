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

local swarm=ability('death_prophet_carrion_swarm',900,110,{damage=325,start_radius=110,end_radius=300,range=900,speed=1100},0.2)
local silence=ability('death_prophet_silence',900,110,{radius=450,projectile_speed=1750},0.2)
local siphon=ability('death_prophet_spirit_siphon',500,60,{damage=100},0.1)
local exorcism=ability('death_prophet_exorcism',0,400,{radius=700},0.5)
local native=H.load('npc_dota_hero_death_prophet','pos_2')
local copy=H.realDofile('bots/FunLib/rubick_hero/death_prophet.lua')
local function cast(module,a)
    if module==native then module.SkillsComplement() else module.ConsiderStolenSpell(a) end
end
for _,module in pairs({native,copy}) do
    reset();silence.castable=true;local enemy=unit(1300);enemy.channel=true;enemies={enemy}
    cast(module,silence);assert(#actions==1 and actions[1].point.x==900,'legal Silence edge cast reaches channel through full AoE radius')
    reset();silence.castable=true;enemy=unit(1351);enemy.channel=true;enemies={enemy}
    cast(module,silence);assert(#actions==0,'Silence refuses beyond actual radius and range')
    reset();silence.castable=true;enemy=unit(1300);enemy.speed=200;enemy.channel=true;enemies={enemy}
    cast(module,silence);assert(#actions==0,'Silence predicts projectile travel rather than only cast point')
    reset();silence.castable=true;bot.mode='attack';enemy=unit(1000);enemy.silenced=true;bot.target=enemy;enemies={enemy}
    cast(module,silence);assert(#actions==0,'avoid redundant silence')
    reset();swarm.castable=true;enemy=unit(880);enemy.hp=320;enemy.regen=10;enemies={enemy}
    cast(module,swarm);assert(#actions==0 and bot.killDelay>0.99,'projectile travel and regen prevent false kill')
    enemy.regen=0;cast(module,swarm);assert(#actions==1,'current damage key and predicted legal Swarm kill')
    reset();swarm.castable=true;bot.mode='attack';enemy=unit(800);enemy.blocked=true;enemy.mods.modifier_antimage_counterspell=true;bot.target=enemy;enemies={enemy}
    cast(module,swarm);assert(#actions==1,'point Swarm bypasses unit-target spell block and reflect')
    reset();swarm.castable=true;bot.mode='attack';enemy=unit(901);bot.target=enemy;enemies={enemy}
    cast(module,swarm);assert(#actions==0,'Lens cannot lengthen fixed projectile travel arbitrarily')
    reset();swarm.castable=true;bot.mode='farm';lane={unit(800,-600,'creep'),unit(800,0,'creep'),unit(800,600,'creep')}
    cast(module,swarm);assert(#actions==0,'spread wave does not pass cone geometry count')
    lane={unit(700,0,'creep'),unit(800,60,'creep'),unit(850,100,'creep')}
    cast(module,swarm);assert(#actions==1,'aligned creeps are cleared')
    reset();swarm.castable=true;bot.mode='lane';local ranged=unit(850,0,'creep');ranged.name='npc_dota_creep_badguys_ranged';ranged.hp=200;ranged.magic=0.5;lane={ranged}
    cast(module,swarm);assert(#actions==0,'mitigated ranged last hit refuses nonlethal damage')
    ranged.magic=1;cast(module,swarm);assert(#actions==1,'secure otherwise difficult ranged last hit')
    reset();siphon.castable=true;bot.hp=350;bot.damaged=true;local creep=unit(499,0,'creep');creep.hp=1800;lane={creep}
    cast(module,siphon);assert(#actions==1 and actions[1].target==creep,'urgent sustain drains durable enemy creep even outside farm mode')
    reset();siphon.castable=true;bot.hp=350;bot.damaged=true;creep=unit(501,0,'creep');lane={creep}
    cast(module,siphon);assert(#actions==0,'no artificial movement allowance for Siphon')
    items[0]=lens;cast(module,siphon);assert(#actions==1,'active Lens extends real targeted range')
    for _,modifier in pairs({'modifier_antimage_counterspell','modifier_antimage_counterspell_ally','modifier_death_prophet_spirit_siphon_slow','modifier_item_lotus_orb_active'}) do
        reset();siphon.castable=true;bot.mode='attack';enemy=unit(450);enemy.mods[modifier]=true;bot.target=enemy;enemies={enemy}
        cast(module,siphon);assert(#actions==0,'reject illegal reflected or already linked Siphon '..modifier)
    end
    reset();siphon.castable=true;bot.mode='attack';enemy=unit(400);enemy.immune=true;bot.target=enemy;enemies={enemy}
    cast(module,siphon);assert(#actions==0,'Siphon cannot affect immune enemy')
    reset();siphon.castable=true;bot.mode='attack';enemy=unit(400);enemy.hp=90;enemies={enemy};bot.target=enemy
    cast(module,siphon);assert(#actions==0,'avoid brief link on dying target')
    reset();siphon.castable=true;bot.mode='attack';enemy=unit(400);enemy.mods.modifier_death_prophet_spirit_siphon_slow=true;local second=unit(300);enemies={enemy,second};bot.target=enemy
    cast(module,siphon);assert(#actions==1 and actions[1].target==second,'spread independent charges across live targets')
    reset();siphon.castable=true;siphon.charges=1;bot.mode='lane';bot.hp=600;lane={unit(450,0,'creep')}
    cast(module,siphon);assert(#actions==0,'retain final charge for mild creep sustain')
    bot.hp=350;cast(module,siphon);assert(#actions==1,'emergency may use final charge')
    reset();siphon.castable=true;bot.hp=350;bot.mods.modifier_ice_blast=true;lane={unit(400,0,'creep')}
    cast(module,siphon);assert(#actions==0,'heal block cannot justify creep sustain')
    for _,kind in pairs({'roshan','tormentor'}) do
        reset();siphon.castable=true;swarm.castable=false;bot.mode=kind;bot.attacking=true;bot.target=unit(400,0,kind)
        cast(module,siphon);assert(#actions==1 and actions[1].target==bot.target,'actual boss Siphon target '..kind)
        reset();swarm.castable=true;bot.mode=kind;bot.attacking=true;bot.target=unit(600,0,kind)
        cast(module,swarm);assert(#actions==1,'Swarm boss attack '..kind)
    end
    reset();exorcism.castable=true;bot.mode='attack';enemy=unit(700);enemy.immune=true;bot.target=enemy;enemies={enemy}
    cast(module,exorcism);assert(#actions==1,'physical Exorcism attacks immune hero at current acquisition radius')
    reset();exorcism.castable=true;bot.mode='attack';enemy=unit(701);bot.target=enemy;enemies={enemy}
    cast(module,exorcism);assert(#actions==0,'do not open Exorcism on distant lone target')
    reset();exorcism.castable=true;bot.mode='push';local tower=unit(600,0,'building');bot.target=tower;ownLane={unit(300,0,'creep')}
    cast(module,exorcism);assert(#actions==1,'real tower with friendly wave justifies Exorcism')
    for _,modifier in pairs({'modifier_fountain_glyph','modifier_backdoor_protection','modifier_backdoor_protection_active'}) do
        reset();exorcism.castable=true;bot.mode='push';tower=unit(600,0,'building');tower.mods[modifier]=true;bot.target=tower;ownLane={unit(300,0,'creep')}
        cast(module,exorcism);assert(#actions==0,'protected structures do not waste ultimate '..modifier)
    end
    reset();exorcism.castable=true;bot.mode='roshan';bot.attacking=true;bot.target=unit(500,0,'roshan');bot.target.immune=true
    cast(module,exorcism);assert(#actions==1,'Exorcism remains useful on immune physical boss')
    reset();exorcism.castable=true;bot.mode='tormentor';bot.attacking=true;bot.target=unit(500,0,'tormentor');allies={bot,unit(200),unit(400)}
    cast(module,exorcism);assert(#actions==1,'healthy grouped Tormentor ultimate')
    reset();exorcism.castable=true;bot.mode='tormentor';bot.attacking=true;bot.target=unit(500,0,'tormentor');allies={bot}
    cast(module,exorcism);assert(#actions==0,'do not commit solo reflected Tormentor ultimate')
    reset();exorcism.castable=true;bot.mode='attack';bot.hp=300;bot.target=unit(400);enemies={bot.target}
    cast(module,exorcism);assert(#actions==0,'critical health avoids long new ultimate')
    reset();exorcism.castable=true;bot.mode='attack';bot.mods.modifier_death_prophet_exorcism=true;bot.target=unit(400);enemies={bot.target}
    cast(module,exorcism);assert(#actions==0,'active Exorcism is never overwritten')
    reset();silence.castable=true;bot.channel=true;enemy=unit(300);enemy.channel=true;enemies={enemy}
    cast(module,silence);assert(#actions==0,'normal channels preserved')
end
reset();swarm.castable=true;silence.castable=true;siphon.castable=true;exorcism.castable=true;bot.mode='attack';bot.hp=350;bot.damaged=true;bot.target=unit(400);bot.target.channel=true;enemies={bot.target}
native.SkillsComplement();assert(actions[1].name==silence.name,'native interrupt precedes sustain and ultimate')
bot.target.channel=false;actions={};native.SkillsComplement();assert(actions[1].name==siphon.name,'urgent Siphon precedes Exorcism commitment')
assert(copy.ConsiderStolenSpell({GetName=function() return 'unrelated' end})==nil,'unknown spells allow fallback')
print('Death Prophet ability scenarios passed')
