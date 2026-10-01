local H = dofile('tests/hero_harness.lua')
local J, bot = H.J, H.bot
BOT_ACTION_DESIRE_NONE, BOT_ACTION_DESIRE_HIGH = 0, 0.8
BOT_MODE_NONE, DAMAGE_TYPE_MAGICAL = 0, 2
DOTA_ABILITY_BEHAVIOR_VECTOR_TARGETING = 1073741824
bit={band=function(value,flag) return math.floor(value/flag)%2==1 and flag or 0 end}
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
local function unit(x,y,kind)
    local u={x=x,y=y or 0,kind=kind or 'hero',hp=1000,maxhp=1000,mana=1000,team=3,mods={},mode='',attackRange=150,speed=0}
    function u:GetLocation() return Vector(self.x,self.y) end
    function u:GetTeam() return self.team end
    function u:GetHealth() return self.hp end
    function u:GetMaxHealth() return self.maxhp end
    function u:GetMana() return self.mana end
    function u:GetMaxMana() return 1000 end
    function u:GetAttackRange() return self.attackRange end
    function u:HasModifier(m) return self.mods[m]==true end
    function u:IsMagicImmune() return self.immune==true end
    function u:IsInvulnerable() return self.invulnerable==true end
    function u:IsRooted() return self.rooted==true end
    function u:IsStunned() return self.stunned==true end
    function u:IsHexed() return self.hexed==true end
    function u:IsNightmared() return self.nightmare==true end
    function u:IsChanneling() return self.channel==true end
    function u:CanBeSeen() return self.visible~=false end
    function u:WasRecentlyDamagedByAnyHero() return self.damaged==true end
    return u
end
for k,value in pairs(unit(0)) do bot[k]=value end
function bot:GetAbilityByName(name) return abilities[name] end
function bot:GetItemInSlot(slot) return items[slot] end
function bot:GetNearbyLaneCreeps(_,enemy) return enemy and lane or ownLane end
function bot:GetNearbyNeutralCreeps() return neutrals end
function bot:FindAoELocation() return self.aoe or {targetloc=Vector(0,0),count=0} end
function bot:Action_UseAbilityOnLocation(a,p) actions[#actions+1]={name=a.name,point=p} end
function bot:Action_UseAbilityOnEntity(a,u) actions[#actions+1]={name=a.name,target=u} end
bot.ActionQueue_UseAbilityOnLocation=bot.Action_UseAbilityOnLocation
function bot:Action_ClearActions() end
function bot:ActionQueue_Delay(t) actions[#actions+1]={name='delay',duration=t} end
function GetTeam() return bot.team end
function IsLocationPassable() return not bot.impassable end
local function ability(name,range,mana,values,point)
    local a={name=name,range=range,mana=mana,values=values or {},point=point or 0,castable=false,behavior=16}
    function a:GetName() return self.name end
    function a:GetCastRange() return self.range end
    function a:GetManaCost() return self.mana end
    function a:GetCastPoint() return self.point end
    function a:GetSpecialValueInt(key) return self.values[key] or 0 end
    a.GetSpecialValueFloat=a.GetSpecialValueInt
    function a:GetLevel() return self.level or 3 end
    function a:GetBehavior() return self.behavior end
    function a:IsTrained() return self.trained==true end
    function a:IsFullyCastable() return self.castable end
    abilities[name]=a;return a
end
local vacuum=ability('dark_seer_vacuum',600,150,{radius=550,damage=250,duration=0.6},0.4)
local shell=ability('dark_seer_ion_shell',800,130,{radius=275},0.2)
local surge=ability('dark_seer_surge',600,50,{},0.4)
local wall=ability('dark_seer_wall_of_replica',1000,375,{},0.2)
local blink=ability('item_blink',0,0,{blink_range=1200})
local lens=ability('item_aether_lens',0,0,{cast_range_bonus=225})
local supremacy=ability('rubick_arcane_supremacy',0,0,{cast_range=240})
local function nearby(list,u,r)
    local out={};for _,other in pairs(list) do if other~=u and GetUnitToUnitDistance(u,other)<=r then out[#out+1]=other end end;return out
end
J.IsValid=function(u) return u~=nil and not u.invalid and u:CanBeSeen() end
J.IsValidHero=function(u) return J.IsValid(u) and u.kind=='hero' end
J.IsSuspiciousIllusion=function(u) return u.illusion==true end
J.CanCastOnNonMagicImmune=function(u) return u:CanBeSeen() and not u.immune and not u.invulnerable and not u.illusion end
J.CanCastOnMagicImmune=function(u) return u:CanBeSeen() and not u.invulnerable and not u.illusion end
J.CanCastOnTargetAdvanced=function(u) return not u.blocked end
J.CanCastAbility=function(a) return a~=nil and a.castable end
J.CanNotUseAbility=function(u) return u.channel or u.using or u.silenced or u.queued or u.stunned or false end
J.GetProperTarget=function(u) assert(u.kind=='hero','creeps do not have a hero target/mode API');return u.target end
J.GetNearbyHeroes=function(u,r,enemy) return nearby(enemy and enemies or allies,u,r) end
J.GetAlliesNearLoc=function(p,r)
    local out={};for _,u in pairs(allies) do if GetUnitToLocationDistance(u,p)<=r then out[#out+1]=u end end;return out
end
J.GetEnemiesNearLoc=function(p,r)
    local out={};for _,u in pairs(enemies) do if GetUnitToLocationDistance(u,p)<=r then out[#out+1]=u end end;return out
end
J.GetCorrectLoc=function(u,delay) return Vector(u.x+u.speed*delay,u.y) end
J.CannotBeKilled=function(_,u) return u.protected==true end
J.WillKillTarget=function(u,damage,kind,delay) assert(kind==DAMAGE_TYPE_MAGICAL);bot.killDelay=delay;return damage*(u.magic or 1)>=u.hp+delay*(u.regen or 0) end
J.IsInRange=function(a,b,r) return GetUnitToUnitDistance(a,b)<=r end
J.IsInTeamFight=function() return bot.fight==true end
J.IsGoingOnSomeone=function(u) assert(u.kind=='hero','creeps do not have bot modes');return u.mode=='attack' end
J.IsRetreating=function(u) return u.mode=='retreat' end
J.IsChasingTarget=function(a,b) return a.chasing==b end
J.IsDisabled=function(u) return u.disabled==true or u.stunned==true end
J.IsCastingUltimateAbility=function(u) return u.usingUlt==true end
J.IsLaning=function() return bot.mode=='lane' end
J.IsFarming=function() return bot.mode=='farm' end
J.IsPushing=function() return bot.mode=='push' end
J.IsDefending=function() return bot.mode=='defend' end
J.GetCurrentRoshanLocation=function() return Vector(8000,0) end
J.GetTormentorLocation=function() return Vector(-8000,0) end
J.IsDoingRoshan=function() return bot.mode=='roshan' end
J.IsDoingTormentor=function() return bot.mode=='tormentor' end
J.IsRoshan=function(u) return u~=nil and u.kind=='roshan' end
J.IsTormentor=function(u) return u~=nil and u.kind=='tormentor' end
J.IsAttacking=function(u) return u.attacking==true end
J.IsCore=function(u) return u.core~=false end
J.GetHP=function(u) return u.hp/u.maxhp end
J.GetModifierTime=function(u,m) return u.time or 10 end
J.IsAllowedToSpam=function() return bot.spam~=false end
J.IsLocationInChrono=function() return bot.hazard=='chrono' end
J.IsLocationInBlackHole=function() return bot.hazard=='blackhole' end
J.IsLocationInArena=function() return bot.hazard=='arena' end
local native=H.load('npc_dota_hero_dark_seer','pos_3')
local copy=H.realDofile('bots/FunLib/rubick_hero/dark_seer.lua')
local function reset()
    actions,enemies,allies,lane,ownLane,neutrals,items={},{},{},{},{},{},{}
    for k,value in pairs(unit(0)) do bot[k]=value end
    bot.team=2;bot.fight,bot.using,bot.silenced,bot.queued,bot.impassable,bot.hazard,bot.target,bot.aoe=false,false,false,false,false,nil,nil,nil
    bot.spam=true;bot.channel=false;bot.killDelay=nil
    bot.rooted,bot.stunned,bot.hexed,bot.nightmare,bot.damaged=false,false,false,false,false
    bot.chasing=nil
    for _,a in pairs(abilities) do a.castable=false;a.trained=false end
    wall.behavior=16+DOTA_ABILITY_BEHAVIOR_VECTOR_TARGETING
end
local function cast(module,a)
    if module==native then module.SkillsComplement() else module.ConsiderStolenSpell(a) end
end
for _,module in ipairs({native,copy}) do
    reset();vacuum.castable=true;local enemy=unit(1000);enemy.channel=true;enemies={enemy}
    cast(module,vacuum);assert(#actions==1 and actions[1].point.x==600,'clamp interrupt center within actual range while covering outer enemy')
    reset();vacuum.castable=true;enemy=unit(1151);enemy.channel=true;enemies={enemy}
    cast(module,vacuum);assert(#actions==0,'outside radius cannot trigger interrupt')
    reset();vacuum.castable=true;enemy=unit(1100);enemy.channel=true;enemy.speed=200;enemies={enemy}
    cast(module,vacuum);assert(#actions==0,'prediction rejects enemy leaving outer coverage')
    reset();vacuum.castable=true;enemy=unit(500);enemy.hp=240;enemy.regen=20;enemies={enemy}
    cast(module,vacuum);assert(#actions==0 and bot.killDelay==1,'Vacuum lethal includes full pull damage delay')
    reset();vacuum.castable=true;enemy=unit(500);enemy.hp=200;enemies={enemy}
    cast(module,vacuum);assert(#actions==1,'legal lethal pull')
    for _,flag in ipairs({'immune','protected','channel'}) do
        reset();vacuum.castable=true;enemy=unit(300);enemy.hp=100;enemies={enemy}
        if flag=='channel' then bot.channel=true else enemy[flag]=true end
        cast(module,vacuum);assert(#actions==0,'Vacuum safety '..flag)
    end
    reset();vacuum.castable=true;wall.castable=true;bot.fight=true;enemies={unit(400),unit(600)};bot.aoe={targetloc=Vector(500,0),count=2};items[0]=blink;blink.castable=true
    cast(module,vacuum);assert(#actions==1 and actions[1].name==vacuum.name,'ready unsupported Wall/Blink does not suppress direct Vacuum')
    reset();surge.castable=true;local ally=unit(550);ally.team=2;ally.mode='retreat';ally.hp=250;ally.damaged=true
    enemy=unit(1050);enemy.chasing=ally;enemies={enemy};allies={ally};bot.mode='attack';bot.target=enemy;bot.chasing=enemy
    cast(module,surge);assert(#actions==1 and actions[1].target==ally,'save ally even when pursuer outside Surge cast range')
    for _,flag in ipairs({'rooted','channel','rupture','buffed','range'}) do
        reset();surge.castable=true;ally=unit(550);ally.team=2;ally.mode='retreat';ally.hp=250;ally.damaged=true;enemy=unit(1050);enemy.chasing=ally;enemies={enemy};allies={ally}
        if flag=='rupture' then ally.mods.modifier_bloodseeker_rupture=true elseif flag=='buffed' then ally.mods.modifier_dark_seer_surge=true elseif flag=='range' then ally.x=601 else ally[flag]=true end
        cast(module,surge);assert(#actions==0,'avoid wasted/unsafe Surge '..flag)
    end
    reset();surge.castable=true;bot.mode='retreat';bot.damaged=true;bot.mods.modifier_dark_seer_ion_shell=true
    enemy=unit(300);enemy.immune=true;enemy.chasing=bot;enemies={enemy}
    cast(module,surge);assert(#actions==1 and actions[1].target==bot,'Ion Shell and enemy BKB do not suppress self escape')
    reset();surge.castable=true;bot.mode='attack';enemy=unit(900);enemy.immune=true;enemies={enemy};bot.target=enemy;bot.chasing=enemy
    cast(module,surge);assert(#actions==1,'chase immunity target with movement buff')
    reset();shell.castable=true;bot.mode='attack';ally=unit(750);ally.team=2;ally.immune=true;allies={ally};enemy=unit(900);enemies={enemy}
    cast(module,shell);assert(#actions==1 and actions[1].target==ally,'select useful BKB ally host rather than distant self')
    ally.mods.modifier_dark_seer_ion_shell=true;actions={};cast(module,shell);assert(#actions==0,'do not replace long-lived shell')
    ally.time=1;actions={};cast(module,shell);assert(#actions==1,'renew expiring shell')
    reset();shell.castable=true;bot.mode='lane';local creep=unit(750,0,'creep');creep.team=2;ownLane={creep};lane={unit(900,0,'creep'),unit(950,0,'creep'),unit(1000,0,'creep')}
    cast(module,shell);assert(#actions==1 and actions[1].target==creep,'push dangerous wave through durable nearby melee creep')
    reset();shell.castable=true;bot.mode='farm';neutrals={unit(100,0,'creep'),unit(200,0,'creep')}
    cast(module,shell);assert(#actions==1 and actions[1].target==bot,'self shell clears real neutral cluster')
    reset();shell.castable=true;bot.mode='idle';lane={unit(100,0,'creep'),unit(200,0,'creep')}
    cast(module,shell);assert(#actions==0,'no idle wave spam')
    reset();shell.castable=true;bot.mode='lane';bot.mods.modifier_dark_seer_ion_shell=true
    local host=unit(700,0,'creep');lane={host,unit(850,0,'creep'),unit(900,0,'creep')}
    cast(module,shell);assert(#actions==1 and actions[1].target==host,'enemy melee creep may carry shell; shell cannot damage host itself')
    for _,mod in ipairs({'modifier_antimage_counterspell','modifier_antimage_counterspell_ally'}) do
        host.mods[mod]=true;actions={};cast(module,shell);assert(#actions==0,'reflected enemy host rejected');host.mods[mod]=nil
    end
    for _,boss in ipairs({'roshan','tormentor'}) do
        reset();shell.castable=true;bot.mode=boss;bot.attacking=true;bot.target=unit(200,0,boss)
        cast(module,shell);assert(#actions==1 and actions[1].target==bot,'objective self shell '..boss)
    end
    reset();surge.castable=true;vacuum.castable=true;shell.castable=true;bot.mode='roshan';bot.mana=329
    cast(module,surge);assert(#actions==0,'objective travel reserves available Vacuum and Shell mana')
    bot.mana=330;actions={};cast(module,surge);assert(#actions==1 and actions[1].target==bot,'budgeted objective travel Surge')
    reset();shell.castable=true;bot.mode='lane';local distantCreep=unit(700,0,'creep');distantCreep.team=2;ownLane={distantCreep}
    cast(module,shell);assert(#actions==0,'quiet creep host never uses hero mode APIs')
    reset();shell.castable=true;surge.trained=true;bot.mode='farm';bot.mana=179;neutrals={unit(100,0,'creep'),unit(200,0,'creep')}
    cast(module,shell);assert(#actions==0,'farm shell reserves trained Surge escape mana')
    reset();wall.castable=true;bot.fight=true;enemy=unit(400);enemy.disabled=true;enemies={enemy}
    cast(module,wall);assert(#actions==0,'current vector Wall never dispatched as an unverified point')
end
-- Native-only coordinated decisions; standalone stolen spells never assume linked Wall or Blink.
reset();surge.castable=true;shell.castable=true;bot.mode='roshan';bot.mana=179
abilities.dark_seer_vacuum=nil
cast(copy,surge);assert(#actions==0,'stolen Surge reserves linked Shell even without Vacuum')
bot.mana=180;cast(copy,surge);assert(#actions==1,'standalone Surge uses actual linked spell budget')
abilities.dark_seer_vacuum=vacuum
reset();vacuum.castable=true;surge.castable=true;enemy=unit(400);enemy.channel=true;enemies={enemy};bot.mode='retreat';bot.damaged=true;enemy.chasing=bot
native.SkillsComplement();assert(#actions==1 and actions[1].name==vacuum.name,'direct interrupt before movement save')
for _,variant in ipairs({'safe','mana','root','rupture','hazard','outnumber','reach'}) do
    reset();vacuum.castable=true;items[0]=blink;blink.castable=true;bot.fight=true;bot.aoe={targetloc=Vector(1400,0),count=2};enemies={unit(1300),unit(1500)}
    local ally=unit(900);ally.team=2;allies={bot,ally}
    if variant=='mana' then bot.mana=149 elseif variant=='root' then bot.rooted=true elseif variant=='rupture' then bot.mods.modifier_bloodseeker_rupture=true
    elseif variant=='hazard' then bot.hazard='chrono' elseif variant=='outnumber' then allies={bot}
    elseif variant=='reach' then bot.aoe.targetloc=Vector(1900,0);enemies={unit(1550),unit(1600)} end
    local desire,landing,center=native.ConsiderBlinkVacuum()
    if variant=='safe' then assert(desire>0 and landing.x<=1200 and center.x==1400,'bounded safe Blink and reachable cast center') else assert(desire==0,'Blink safety '..variant) end
end
reset();vacuum.castable=true;items[0]=blink;blink.castable=true;bot.fight=true;bot.aoe={targetloc=Vector(1400,0),count=2};enemies={unit(1300),unit(1500)};local ally=unit(900);ally.team=2;allies={bot,ally}
for _,module in ipairs({native,copy}) do
    actions={};cast(module,vacuum)
    assert(#actions==2 and actions[1].name==blink.name and actions[2].name==vacuum.name,'native/stolen Blink precedes Vacuum without bogus vector Wall queue')
end
-- Point-only compatibility uses live metadata, with pull/Wall timing derived from actual cast points.
reset();vacuum.castable=true;wall.castable=true;wall.behavior=16;bot.fight=true;bot.aoe={targetloc=Vector(500,0),count=2};enemies={unit(400),unit(600)}
native.SkillsComplement();assert(#actions==3 and actions[1].name==vacuum.name and actions[2].name=='delay' and math.abs(actions[2].duration-0.4)<0.001 and actions[3].name==wall.name,'point-mode compatibility derives follow-up delay')
print('Dark Seer ability scenarios passed')
