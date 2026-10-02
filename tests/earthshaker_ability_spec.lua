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
UNIT_LIST_ENEMIES=4
DOTA_ABILITY_BEHAVIOR_POINT=16
bit={band=function(value,flag) return math.floor(value/flag)%2==1 and flag or 0 end}
function DotaTime() return now end
function GetUnitList(kind)
    assert(kind==UNIT_LIST_ENEMIES)
    local result={};for _,list in pairs({enemies,lane}) do for _,u in pairs(list) do result[#result+1]=u end end
    return result
end
local function unit(x,y,kind)
    local u={x=x,y=y or 0,kind=kind or 'hero',hp=1000,maxhp=1000,mana=1000,team=3,mods={},mode='',attackRange=150,speed=0}
    function u:GetLocation() return Vector(self.x,self.y) end
    function u:GetTeam() return self.team end
    function u:GetHealth() return self.hp end
    function u:GetMaxHealth() return self.maxhp end
    function u:GetMana() return self.mana end
    function u:GetMaxMana() return 1000 end
    function u:GetAttackRange() return self.attackRange end
    function u:GetAttackDamage() return self.attackDamage or 200 end
    function u:GetBaseDamage() return self.baseDamage or 100 end
    function u:GetBaseDamageVariance() return self.variance or 0 end
    function u:GetAttackPoint() return 0.3 end
    function u:IsHero() return self.kind=='hero' end
    function u:IsRooted() return self.rooted==true end
    function u:IsDisarmed() return self.disarmed==true end
    function u:GetUnitName() return self.name or 'npc_dota_'..self.kind end
    function u:GetAttackTarget() return self.attackTarget end
    function u:HasModifier(m) return m=='modifier_item_aghanims_shard' and self.shard==true or self.mods[m]==true end
    function u:IsMagicImmune() return self.immune==true end
    function u:IsInvulnerable() return self.invulnerable==true end
    function u:IsSilenced() return self.silenced==true end
    function u:IsIllusion() return self.illusion==true end
    function u:IsChanneling() return self.channel==true end
    function u:HasScepter() return self.scepter==true end
    function u:CanBeSeen() return self.visible~=false end
    function u:WasRecentlyDamagedByAnyHero() return self.damaged==true end
    function u:GetActualIncomingDamage(damage,kind) self.incoming=damage;return damage*(kind==DAMAGE_TYPE_MAGICAL and (self.magic or 1) or (self.physical or 1)) end
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
function bot:ActionQueue_UseAbility(a) actions[#actions+1]={name=a.name,queued=true} end
function bot:ActionQueue_Delay(delay) actions[#actions+1]={name='delay',duration=delay} end
function bot:ActionQueue_AttackUnit(target,once) assert(once==true);actions[#actions+1]={name='attack',target=target} end
function IsLocationPassable() return not bot.impassable end
local function ability(name,range,mana,values,point)
    local a={name=name,range=range,mana=mana,values=values or {},point=point or 0,castable=false,trained=true,charges=4}
    function a:GetName() return self.name end
    function a:GetCastRange() return self.range end
    function a:GetManaCost() return self.mana end
    function a:GetCastPoint() return self.point end
    function a:GetSpecialValueInt(key) assert(self.values[key]~=nil,'unexpected ability key '..self.name..':'..key);return self.values[key] end
    a.GetSpecialValueFloat=a.GetSpecialValueInt
    function a:GetCurrentCharges() return self.charges end
    function a:GetBehavior() return self.behavior or 4 end
    function a:GetCooldownTimeRemaining() return self.cooldown or 0 end
    function a:IsNull() return false end
    function a:IsHidden() return self.hidden==true end
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
J.IsStuck=function() return bot.stuck==true end
J.GetTeamFountain=function() return Vector(-7000,0) end
J.IsLocationInChrono=function() return bot.chrono==true end
J.IsLocationInBlackHole=function() return bot.blackhole==true end
J.IsLocationInArena=function() return bot.arena==true end
local lens=ability('item_aether_lens',0,0,{cast_range_bonus=225})
local supremacy=ability('rubick_arcane_supremacy',0,0,{cast_range=240});supremacy.trained=false
local function reset()
    actions,enemies,allies,lane,ownLane,neutrals,items={},{},{},{},{},{},{}
    for k,value in pairs(unit(0)) do bot[k]=value end
    bot.team=2;bot.target=nil;bot.fight=false;bot.channel=false;bot.using=false;bot.queued=false;bot.stunned=false
    bot.shard=false;bot.rooted=false;bot.disarmed=false;bot.stuck=false;bot.chrono=false;bot.blackhole=false;bot.arena=false;bot.impassable=false
    bot.attackRange=150;bot.attackDamage=200;bot.baseDamage=100;bot.variance=0
    bot.silenced=false;bot.scepter=false;bot.invisible=false;bot.damaged=false;bot.spam=true;bot.attacking=false
    now=0
    for _,a in pairs(abilities) do a.castable=false;a.charges=4 end
    supremacy.trained=false
end

local fissure=ability('earthshaker_fissure',1600,130,{fissure_damage=280,fissure_radius=225,fissure_duration=8},0.69)
local totem=ability('earthshaker_enchant_totem',0,75,{distance_scepter=950,scepter_leap_duration=0.8,bonus_attack_range=100,totem_damage_percentage=400},0.5)
local shock=ability('earthshaker_aftershock',0,0,{aftershock_range=350,aftershock_damage=140})
local echo=ability('earthshaker_echo_slam',0,250,{echo_slam_damage_range=700,echo_slam_echo_search_range=700,echo_slam_echo_range=700,echo_slam_initial_damage=180,echo_slam_echo_damage=110})
local blink=ability('item_blink',0,0,{blink_range=1200})
local function load(stolen)
    return stolen and H.realDofile('bots/FunLib/rubick_hero/earthshaker.lua') or H.load('npc_dota_hero_earthshaker','pos_4')
end
local function fresh(stolen)
    reset();shock.trained=true;fissure.cooldown=0;totem.behavior=4;abilities[shock.name]=shock;abilities[totem.name]=totem;abilities[echo.name]=echo
    return load(stolen)
end
local function cast(module,a,stolen)
    return stolen and module.ConsiderStolenSpell(a) or (not stolen and module.SkillsComplement())
end
for _,stolen in pairs({false,true}) do
    local module=fresh(stolen);fissure.castable=true;local enemy=unit(1825);enemy.channel=true;enemies={enemy}
    cast(module,fissure,stolen);assert(#actions==1 and math.abs(actions[1].point.x-1600)<0.001,'legal Fissure endpoint with full damage radius interrupts')
    module=fresh(stolen);fissure.castable=true;enemy=unit(1826);enemy.channel=true;enemies={enemy}
    cast(module,fissure,stolen);assert(#actions==0,'no movement allowance past Fissure line endpoint')
    items[0]=lens;cast(module,fissure,stolen);assert(#actions==1 and actions[1].point.x<=1825,'actual Lens extends Fissure reach')
    module=fresh(stolen);fissure.castable=true;enemy=unit(1700);enemy.speed=200;enemy.channel=true;enemies={enemy}
    cast(module,fissure,stolen);assert(#actions==0,'Fissure uses live0.69 cast delay before testing reach')
    module=fresh(stolen);fissure.castable=true;enemy=unit(1700);enemy.channel=true;enemy.blocked=true;enemy.mods.modifier_antimage_counterspell_ally=true;enemies={enemy}
    cast(module,fissure,stolen);assert(#actions==1,'point Fissure ignores targeted block and reflection')
    module=fresh(stolen);fissure.castable=true;enemy=unit(1700);enemy.channel=true;enemy.immune=true;enemies={enemy}
    cast(module,fissure,stolen);assert(#actions==0,'immune unit cannot be interrupted by Fissure')
    module=fresh(stolen);fissure.castable=true;bot.mode='farm';lane={unit(600,0,'creep'),unit(900,600,'creep'),unit(1200,-600,'creep')}
    cast(module,fissure,stolen);assert(#actions==0,'spread creep wave does not pass linear geometry')
    lane={unit(600,0,'creep'),unit(900,50,'creep'),unit(1200,-40,'creep')}
    cast(module,fissure,stolen);assert(#actions==1,'aligned durable creeps are cleared')
    module=fresh(stolen);fissure.castable=true;bot.mode='attack';enemy=unit(1200);bot.target=enemy;enemies={enemy}
    local ally=unit(500,300);ally.team=2;ally.mode='retreat';ally.damaged=true;allies={ally}
    cast(module,fissure,stolen);assert(#actions==1,'wall that does not cross retreat route is allowed')
    -- Diagonal wall crossing the ally path toward the fountain is suppressed outside emergencies.
    module=fresh(stolen);fissure.castable=true;bot.mode='attack';enemy=unit(1000,500);bot.target=enemy;enemies={enemy}
    ally=unit(600,200);ally.team=2;ally.mode='retreat';ally.damaged=true;allies={ally}
    cast(module,fissure,stolen);assert(#actions==0,'avoid obvious barrier across allied retreat route')
    module=fresh(stolen);totem.castable=true;enemy=unit(350);enemy.channel=true;enemies={enemy}
    cast(module,totem,stolen);assert(#actions==1 and actions[1].name==totem.name and actions[1].target==nil,'cheap real Aftershock interrupt uses full350 radius')
    module=fresh(stolen);totem.castable=true;enemy=unit(350);enemy.speed=1;enemy.channel=true;enemies={enemy}
    cast(module,totem,stolen);assert(#actions==0,'Aftershock predicts Totem castpoint at its radius boundary')
    module=fresh(stolen);totem.castable=true;shock.trained=false;enemy=unit(300);enemy.channel=true;enemies={enemy}
    cast(module,totem,stolen);assert(#actions==0,'untrained Aftershock cannot supply an invented interrupt')
    module=fresh(stolen);totem.castable=true;bot.mods.modifier_silver_edge_debuff=true;enemy=unit(300);enemy.channel=true;enemies={enemy}
    cast(module,totem,stolen);assert(#actions==0,'known break disables Aftershock effect')
    module=fresh(stolen);totem.castable=true;bot.disarmed=true;enemy=unit(300);enemy.channel=true;enemies={enemy}
    cast(module,totem,stolen);assert(#actions==1,'disarm does not stop a real Totem Aftershock interrupt')
    module=fresh(stolen);totem.castable=true;bot.scepter=true;totem.behavior=16;enemy=unit(300);enemy.channel=true;enemies={enemy}
    cast(module,totem,stolen);assert(#actions==1 and actions[1].target==bot,'Scepter self-cast avoids delaying interrupt with a jump')
    module=fresh(stolen);totem.castable=true;bot.mode='lane';local creep=unit(240,0,'creep');creep.hp=550;lane={creep}
    cast(module,totem,stolen);assert(#actions==2 and actions[1].name==totem.name and actions[2].target==creep,'Totem amplifies base rather than green item damage and queues actual last-hit attack')
    module=fresh(stolen);totem.castable=true;bot.mode='lane';creep=unit(240,0,'creep');creep.hp=650;lane={creep}
    cast(module,totem,stolen);assert(#actions==0,'does not amplify full200 attack damage into false1000 damage last hit')
    module=fresh(stolen);totem.castable=true;bot.mode='lane';creep=unit(240,0,'creep');creep.hp=550;creep.magic=1;creep.physical=0.5;lane={creep}
    cast(module,totem,stolen);assert(#actions==0,'physical armor affects empowered attack last hit')
    module=fresh(stolen);totem.castable=true;bot.mode='lane';creep=unit(240,0,'creep');creep.hp=400;creep.team=2;ownLane={creep}
    cast(module,totem,stolen);assert(#actions==2 and actions[2].target==creep,'low-health friendly creep can be denied with buff')
    module=fresh(stolen);totem.castable=true;bot.mode='attack';enemy=unit(900);bot.target=enemy;enemies={enemy}
    cast(module,totem,stolen);assert(#actions==1 and actions[1].point==nil,'prepare a buff near upcoming fight without inventing a leap')
    module=fresh(stolen);totem.castable=true;bot.mode='attack';bot.mods.modifier_earthshaker_enchant_totem=true;enemy=unit(900);bot.target=enemy;enemies={enemy}
    cast(module,totem,stolen);assert(#actions==0,'do not overwrite unused attack buff merely to prepare again')
    module=fresh(stolen);echo.castable=true;bot.fight=true;enemies={unit(600),unit(650)}
    cast(module,echo,stolen);assert(#actions==1,'direct Echo uses actual700 radius instead of half radius')
    module=fresh(stolen);echo.castable=true;bot.fight=true;enemies={unit(-700),unit(700)}
    cast(module,echo,stolen);assert(#actions==0,'separated real units do not produce mutual echoes just because both lie inside initial radius')
    module=fresh(stolen);echo.castable=true;bot.mode='attack';enemy=unit(600);bot.target=enemy;enemies={enemy};lane={unit(610,0,'creep'),unit(620,0,'creep'),unit(630,0,'creep')}
    cast(module,echo,stolen);assert(#actions==1,'single hero inside summon army is an actual Echo opportunity')
    module=fresh(stolen);echo.castable=true;bot.mode='attack';enemy=unit(600);bot.target=enemy;enemies={enemy};local i1=unit(610);local i2=unit(620);local i3=unit(630);i1.illusion=true;i2.illusion=true;i3.illusion=true;enemies={enemy,i1,i2,i3}
    cast(module,echo,stolen);assert(#actions==1,'enemy illusions count as echo bodies despite hero target filtering')
    module=fresh(stolen);echo.castable=true;enemy=unit(340);enemy.channel=true;enemies={enemy}
    cast(module,echo,stolen);assert(#actions==1,'instant Echo interrupts only through real linked Aftershock')
    module=fresh(stolen);echo.castable=true;shock.trained=false;enemy=unit(340);enemy.channel=true;enemies={enemy}
    cast(module,echo,stolen);assert(#actions==0,'standalone Echo has damage but no invented intrinsic stun')
    module=fresh(stolen);echo.castable=true;enemy=unit(650);enemy.hp=179;enemies={enemy}
    cast(module,echo,stolen);assert(#actions==1,'immediate initial damage can secure legitimate isolated kill')
    module=fresh(stolen);echo.castable=true;enemy=unit(650);enemy.hp=200;enemies={enemy}
    cast(module,echo,stolen);assert(#actions==0,'no assumed self echoes or unverified delayed lethal damage')
    module=fresh(stolen);echo.castable=true;bot.mode='attack';bot.hp=350;enemy=unit(600);enemy.mods.modifier_item_blade_mail_reflect=true;enemies={enemy,unit(620)};bot.target=enemy
    cast(module,echo,stolen);assert(#actions==0,'dangerous reflected cluster burst is not committed at low health')
    module=fresh(stolen);echo.castable=true;blink.castable=true;items[0]=blink;bot.mode='attack';enemy=unit(1000);bot.target=enemy;enemies={enemy,unit(1050)};ally=unit(900);ally.team=2;allies={bot,ally}
    cast(module,echo,stolen);assert(#actions==2 and actions[1].name==blink.name and actions[2].name==echo.name,'safe budgeted Blink Echo executes without fictitious Aftershock from item')
    for _,hazard in pairs({'rooted','chrono','blackhole','arena','impassable'}) do
        module=fresh(stolen);echo.castable=true;blink.castable=true;items[0]=blink;bot.mode='attack';bot[hazard]=true;enemy=unit(1000);bot.target=enemy;enemies={enemy,unit(1050)};ally=unit(900);ally.team=2;allies={bot,ally}
        cast(module,echo,stolen);assert(#actions==0,'unsafe Blink initiation rejected '..hazard)
    end
    module=fresh(stolen);echo.castable=true;blink.castable=true;items[0]=blink;bot.mode='attack';bot.mods.modifier_bloodseeker_rupture=true;enemy=unit(1000);bot.target=enemy;enemies={enemy,unit(1050)};allies={bot,unit(900)}
    cast(module,echo,stolen);assert(#actions==0,'Rupture prevents mobility initiation')
    module=fresh(stolen);echo.castable=true;blink.castable=true;items[0]=blink;bot.mode='attack';enemies={unit(1000),unit(1050)};bot.target=enemies[1];allies={bot}
    cast(module,echo,stolen);assert(#actions==0,'bot is not counted twice to make unsafe solo1v2 seem safe')
    module=fresh(stolen);echo.castable=true;blink.castable=true;items[0]=blink;bot.mode='attack';enemies={unit(1901),unit(1950)};bot.target=enemies[1];allies={bot,unit(1000)}
    cast(module,echo,stolen);assert(#actions==0,'Blink cannot exceed actual1200 plus real Echo radius')
    module=fresh(stolen);echo.castable=true;totem.castable=true;bot.scepter=true;totem.behavior=16;bot.mode='attack';enemies={unit(900),unit(950)};bot.target=enemies[1];allies={bot,unit(700)}
    cast(module,totem,stolen);assert(#actions==3 and actions[1].name==totem.name and actions[1].point.x<=950 and math.abs(actions[2].duration-0.85)<0.001 and actions[3].name==echo.name,'Totem jump then post-leap Echo uses current shape and leap duration')
    module=fresh(stolen);echo.castable=true;totem.castable=true;bot.scepter=true;totem.behavior=16;bot.mode='attack';bot.mana=324;enemies={unit(900),unit(950)};bot.target=enemies[1];allies={bot,unit(700)}
    cast(module,totem,stolen);assert(#actions<=1,'insufficient325 mana never queues linked Totem Echo')
    module=fresh(stolen);totem.castable=true;bot.scepter=true;totem.behavior=16;bot.mode='retreat';bot.damaged=true;enemies={unit(400)}
    cast(module,totem,stolen);assert(#actions==1 and math.abs(actions[1].point.x+950)<0.001,'Scepter retreat jump heads toward fountain without chasing pursuer')
    module=fresh(stolen);totem.castable=true;bot.scepter=true;totem.behavior=16;bot.mode='retreat';bot.damaged=true;bot.rooted=true;enemies={unit(300)};enemies[1].chasing=bot
    cast(module,totem,stolen);assert(#actions==1 and actions[1].target==bot,'rooted escape uses legal self Aftershock instead of jump')
    for _,kind in pairs({'roshan','tormentor'}) do
        module=fresh(stolen);totem.castable=true;bot.mode=kind;bot.attacking=true;bot.target=unit(240,0,kind)
        cast(module,totem,stolen);assert(#actions==1 and actions[1].name==totem.name,'Totem attack buff remains useful for actual boss '..kind)
        module=fresh(stolen);fissure.castable=true;bot.mode=kind;bot.attacking=true;bot.target=unit(900,0,kind)
        cast(module,fissure,stolen);assert(#actions==1 and actions[1].point~=nil,'actual boss Fissure '..kind)
    end
    module=fresh(stolen);totem.castable=true;bot.mode='farm';neutrals={unit(100,0,'creep'),unit(200,50,'creep'),unit(300,0,'creep')}
    cast(module,totem,stolen);assert(#actions==1,'trained unbroken Aftershock farms clustered neutrals')
    module=fresh(stolen);totem.castable=true;shock.trained=false;bot.mode='farm';neutrals={unit(100,0,'creep'),unit(200,50,'creep'),unit(300,0,'creep')}
    cast(module,totem,stolen);assert(#actions==0,'no passive means no fake AoE neutral farming')
    module=fresh(stolen);fissure.castable=true;totem.castable=true;echo.castable=true;bot.channel=true;enemy=unit(300);enemy.channel=true;enemies={enemy}
    cast(module,fissure,stolen);assert(#actions==0,'normal channels remain untouched')
end
-- Standalone stolen Totem still buffs a physical attack, but cannot invent magical control.
local buffOnly=fresh(true);totem.castable=true;abilities[shock.name]=nil;bot.mode='attack';bot.attackRange=550;local immuneTarget=unit(650);immuneTarget.immune=true;bot.target=immuneTarget;enemies={immuneTarget}
buffOnly.ConsiderStolenSpell(totem);assert(#actions==1 and actions[1].point==nil,'standalone Totem empowers a real ranged attack against immune hero')
buffOnly=fresh(true);totem.castable=true;abilities[shock.name]=nil;bot.mode='attack';bot.disarmed=true;bot.scepter=true;totem.behavior=16;immuneTarget=unit(900);immuneTarget.immune=true;bot.target=immuneTarget;enemies={immuneTarget}
buffOnly.ConsiderStolenSpell(totem);assert(#actions==0,'disarmed caster without actual control does not jump offensively')
local reflected=fresh(true);echo.castable=true;bot.fight=true;bot.hp=600;local reflectedTarget=unit(600);reflectedTarget.mods.modifier_item_blade_mail_reflect=true;enemies={reflectedTarget,unit(650)}
reflected.ConsiderStolenSpell(echo);assert(#actions==1 and bot.incoming==400,'real emitting hero contributes two echoes to reflection-risk estimate')
-- Recorded Shard ridges require actual cooldown evidence, not just an issued command.
for _,stolen in pairs({false,true}) do
    local module=fresh(stolen);bot.shard=true;fissure.castable=true;bot.mode='attack';local enemy=unit(1200);bot.target=enemy;enemies={enemy}
    cast(module,fissure,stolen);assert(actions[1].name==fissure.name)
    actions={};fissure.castable=false;totem.castable=true;now=0.7;enemy.channel=true;fissure.cooldown=14
    cast(module,totem,stolen);assert(#actions==1 and actions[1].name==totem.name,'confirmed own Shard ridge supplies remote Aftershock interrupt')
    actions={};now=9;cast(module,totem,stolen);assert(#actions==0,'expired ridge is not imagined')
    module=fresh(stolen);bot.shard=true;fissure.castable=true;bot.mode='attack';enemy=unit(1200);bot.target=enemy;enemies={enemy};cast(module,fissure,stolen)
    actions={};fissure.castable=false;totem.castable=true;now=0.7;enemy.channel=true;fissure.cooldown=0
    cast(module,totem,stolen);assert(#actions==0,'cancelled or failed Fissure cannot fabricate remote ridge')
end
-- Late cooldown confirmation must not extend the lifetime of an already existing wall.
local late=fresh(true);bot.shard=true;fissure.castable=true;bot.mode='attack';local lateEnemy=unit(1200);bot.target=lateEnemy;enemies={lateEnemy}
late.ConsiderStolenSpell(fissure);actions={};fissure.castable=false;fissure.cooldown=13;totem.castable=true;lateEnemy.channel=true;now=1.8
late.ConsiderStolenSpell(totem);assert(#actions==1,'late confirmed ridge still active during its actual duration')
actions={};now=8.7;late.ConsiderStolenSpell(totem);assert(#actions==0,'late confirmation never fabricates extra ridge duration')
local native=fresh(false);fissure.castable=true;totem.castable=true;echo.castable=true;local enemy=unit(340);enemy.channel=true;enemies={enemy}
native.SkillsComplement();assert(actions[1].name==echo.name,'instant linked Echo interrupt precedes long Fissure and initiation')
native=fresh(false);fissure.castable=true;totem.castable=true;enemy=unit(340);enemy.channel=true;enemies={enemy}
native.SkillsComplement();assert(actions[1].name==totem.name,'faster cheap Totem Aftershock interrupt precedes0.69 Fissure')
local copy=fresh(true);echo.castable=true;abilities[shock.name]=nil;enemy=unit(300);enemy.channel=true;enemies={enemy}
assert(copy.ConsiderStolenSpell(echo)==false and #actions==0,'standalone stolen Echo with absent live passive never assumes stun')
assert(copy.ConsiderStolenSpell(shock)==false,'passive dispatch explicitly declined')
assert(copy.ConsiderStolenSpell({GetName=function() return 'unrelated' end})==nil,'unknown spell allows fallback')
print('Earthshaker ability scenarios passed')
