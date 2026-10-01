local H = dofile('tests/hero_harness.lua')
local J, bot = H.J, H.bot
BOT_ACTION_DESIRE_NONE, BOT_ACTION_DESIRE_HIGH = 0, 0.8
BOT_MODE_NONE, DAMAGE_TYPE_PHYSICAL, DAMAGE_TYPE_MAGICAL, UNIT_LIST_ALLIES = 0, 1, 2, 1
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
local units, now, minionActions = {}, 100, 0
function DotaTime() return now end
function GetUnitList() return units end
local function unit(x,y,kind)
    local u={x=x,y=y or 0,kind=kind or 'hero',hp=1000,maxhp=1000,mana=1000,team=3,mods={},mode='',attackRange=150,speed=0}
    function u:IsNull() return self.invalid==true end
    function u:IsAlive() return self.dead~=true end
    function u:GetPlayerID() return self.owner or 0 end
    function u:GetUnitName() return self.name or 'npc_dota_hero_test' end
    function u:GetActualIncomingDamage(d,k) return d*(k==DAMAGE_TYPE_MAGICAL and (self.magic or 1) or (self.physical or 1)) end
    function u:GetHealthRegen() return self.regen or 0 end
    function u:GetCurrentMovementSpeed() return self.speed end
    function u:GetAbilityByName(name) return self.echo end
    function u:GetNearbyLaneCreeps() return lane end
    function u:GetNearbyNeutralCreeps() return neutrals end
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
    function u:IsUsingAbility() return self.using==true end
    function u:IsCastingAbility() return self.casting==true end
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
function bot:Action_ClearActions() actions[#actions+1]={name="clear"} end
function bot:Action_UseAbility(a) actions[#actions+1]={name=a.name} end
function bot:IsChanneling() return self.channel==true end
function bot:IsUsingAbility() return self.using==true end
function bot:IsCastingAbility() return self.casting==true end
function bot:HasShard() return self.shard==true end
function bot:ActionQueue_Delay(t) actions[#actions+1]={name='delay',duration=t} end
function GetTeam() return bot.team end
function IsLocationPassable() return not bot.impassable end
local function ability(name,range,mana,values,point)
    local a={name=name,range=range,mana=mana,values=values or {},point=point or 0,castable=false,behavior=16}
    function a:GetChannelTime() return self.channel or 0 end
    function a:GetAutoCastState() return self.alt==true end
    function a:IsHidden() return self.hidden==true end
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
local stomp=ability('elder_titan_echo_stomp',500,100,{radius=475,stomp_damage=200},0.4);stomp.channel=1.3
local astral=ability('elder_titan_ancestral_spirit',1200,100,{radius=275,spirit_duration=10},0.4)
local move=ability('elder_titan_move_spirit',0,0)
local recall=ability('elder_titan_return_spirit',0,0)
local splitter=ability('elder_titan_earth_splitter',2400,175,{crack_time=2.7182,crack_width=315,crack_distance=2400,damage_pct=50},0.4)
local echo=ability('elder_titan_echo_stomp_spirit',500,0,{radius=475,stomp_damage=180})
local function nearby(list,u,r)
    local out={};for _,other in pairs(list) do if other~=u and GetUnitToUnitDistance(u,other)<=r then out[#out+1]=other end end;return out
end
J.IsValid=function(u) return u~=nil and not u.invalid and u:CanBeSeen() end
J.IsValidHero=function(u) return J.IsValid(u) and u.kind=='hero' end
J.IsSuspiciousIllusion=function(u) return u.illusion==true end
J.CanCastOnNonMagicImmune=function(u) return u:CanBeSeen() and not u.immune and not u.invulnerable and not u.illusion end
J.CanCastAbility=function(a) return a~=nil and a.castable and not a.hidden end
J.CanNotUseAbility=function(u) return u.channel or u.using or u.silenced or u.queued or u.stunned or false end
J.GetProperTarget=function(u) return u.target end
J.GetNearbyHeroes=function(u,r,enemy) return nearby(enemy and enemies or allies,u,r) end
J.GetCorrectLoc=function(u,delay) return Vector(u.x+u.speed*delay,u.y) end
J.IsInEtherealForm=function(u) return u.ethereal==true end
J.CannotBeKilled=function(_,u) return u.protected==true end
J.IsInTeamFight=function() return bot.fight==true end
J.IsGoingOnSomeone=function(u) return u.mode=='attack' end
J.IsRetreating=function(u) return u.mode=='retreat' end
J.IsChasingTarget=function(a,b) return a.chasing==b end
J.IsLaning=function() return bot.mode=='lane' end
J.IsFarming=function() return bot.mode=='farm' end
J.IsPushing=function() return bot.mode=='push' end
J.IsDefending=function() return bot.mode=='defend' end
J.GetModifierTime=function(u,m) return u.time or 0 end
J.IsAllowedToSpam=function() return bot.spam~=false end
local originalDofile=dofile
dofile=function(path)
    if path=='bots/FunLib/aba_minion' then return {MinionThink=function() minionActions=minionActions+1 end} end
    return originalDofile(path)
end
local native=H.load('npc_dota_hero_elder_titan','pos_3')
local copy=H.realDofile('bots/FunLib/rubick_hero/elder_titan.lua')
local function reset()
    for _,u in pairs(units) do u.dead=true end
    actions,enemies,allies,lane,ownLane,neutrals,items,units={},{},{},{},{},{},{},{}
    now=now+20;minionActions=0
    for k,value in pairs(unit(0)) do bot[k]=value end
    function bot:GetAbilityByName(name) return abilities[name] end
    bot.team=2;bot.mode='idle';bot.fight=false;bot.target=nil;bot.spam=true
    bot.channel,bot.using,bot.casting,bot.silenced,bot.queued,bot.stunned,bot.shard=false,false,false,false,false,false,false
    for _,a in pairs(abilities) do a.castable=false;a.trained=false;a.hidden=false;a.alt=false end
end
local function cast(module,a)
    if module==native then module.SkillsComplement() else module.ConsiderStolenSpell(a) end
end
local function summon(x)
    local u=unit(x,0,'spirit');u.team=2;u.name='npc_dota_elder_titan_ancestral_spirit';u.speed=900;u.echo=echo
    units={u};return u
end
for _,module in ipairs({native,copy}) do
    reset();stomp.castable=true;bot.mode='attack';local e=unit(400);enemies={e};bot.target=e
    cast(module,stomp);assert(#actions==1 and actions[1].name==stomp.name,'target Stomp single action')
    reset();stomp.castable=true;e=unit(450);e.speed=100;e.channel=true;enemies={e}
    cast(module,stomp);assert(#actions==0,'full cast/channel prediction rejects departing hero')
    reset();stomp.castable=true;e=unit(200);e.channel=true;e.mods.modifier_teleporting=true;e.time=0.5;enemies={e}
    cast(module,stomp);assert(#actions==0,'short remaining TP cannot be interrupted by full Stomp delay')
    e.time=2;cast(module,stomp);assert(#actions==1,'observed TP longer than Stomp delay permits interrupt')
    reset();stomp.castable=true;bot.fight=true;enemies={unit(350),unit(450)}
    cast(module,stomp);assert(#actions==1,'two hero Stomp control')
    for _,flag in ipairs({'channel','using','queued','silenced'}) do
        reset();stomp.castable=true;e=unit(100);e.hp=100;enemies={e};bot[flag]=true
        cast(module,stomp);assert(#actions==0,'preserve actor state '..flag)
    end
    for _,flag in ipairs({'immune','protected','illusion'}) do
        reset();stomp.castable=true;e=unit(100);e.hp=100;e[flag]=true;enemies={e}
        cast(module,stomp);assert(#actions==0,'Stomp safe lethal '..flag)
    end
    for _,protection in ipairs({'ethereal','modifier_omniknight_guardian_angel','modifier_winter_wyvern_cold_embrace'}) do
        reset();stomp.castable=true;e=unit(100);e.hp=100;enemies={e}
        if protection=='ethereal' then e.ethereal=true else e.mods[protection]=true end
        cast(module,stomp);assert(#actions==0,'physical immune target is not a lethal Stomp '..protection)
        reset();splitter.castable=true;e=unit(800);e.hp=300;enemies={e}
        if protection=='ethereal' then e.ethereal=true else e.mods[protection]=true end
        cast(module,splitter);assert(#actions==0,'mixed Splitter physical protection '..protection)
    end
    reset();stomp.castable=true;e=unit(100);e.hp=199;e.regen=2;enemies={e}
    cast(module,stomp);assert(#actions==0,'physical-only proven damage reserves regen; no inferred copied second component')
    reset();stomp.castable=true;astral.trained=true;local sp=summon(1000);echo.trained=true;e=unit(1100);e.channel=true;enemies={e}
    cast(module,stomp);assert(#actions==1,'owned actual Spirit Stomp reaches remote channel')
    reset();stomp.castable=true;astral.trained=true;sp=summon(2000);echo.trained=true;e=unit(2100);e.channel=true;enemies={e}
    cast(module,stomp);assert(#actions==1,'Spirit supplies visible enemies beyond actor nearby search')
    reset();stomp.castable=true;astral.trained=true;sp=summon(1000);echo.trained=true;sp.owner=7;e=unit(1100);e.channel=true;enemies={e}
    cast(module,stomp);assert(#actions==0,'other owner spirit cannot contribute Stomp')
    reset();stomp.castable=true;astral.trained=true;sp=summon(1000);sp.echo=nil;e=unit(1100);e.channel=true;enemies={e}
    cast(module,stomp);assert(#actions==0,'copied Spirit without actual Stomp cannot contribute control')
    reset();stomp.castable=true;bot.shard=true;stomp.alt=true;e=unit(100);e.channel=true;enemies={e}
    cast(module,stomp);assert(#actions==0,'unverified alt cast teleport stays skipped')
    reset();splitter.castable=true;e=unit(800);e.mods.modifier_elder_titan_echo_stomp=true;e.time=3;enemies={e}
    cast(module,splitter);assert(#actions==0,'level two sleep cannot guarantee current Splitter impact')
    e.time=3.2;cast(module,splitter);assert(#actions==1,'observed adequate remaining sleep enables Splitter')
    reset();splitter.castable=true;e=unit(800);e.hp=400;e.physical=0.5;e.magic=0.5;enemies={e}
    cast(module,splitter);assert(#actions==0,'half physical half magical mitigation excludes false lethal')
    e.hp=200;cast(module,splitter);assert(#actions==1,'mitigated split damage lethal')
    reset();splitter.castable=true;bot.fight=true;enemies={unit(800,300),unit(800,-300)}
    cast(module,splitter);assert(#actions==0,'circular cluster does not imply linear hit coverage')
    enemies={unit(800,0),unit(1000,100)};enemies[1].immune=true
    cast(module,splitter);assert(#actions==1,'line combo counts actual piercing immunity targets')
    reset();astral.castable=true;bot.mode='attack';e=unit(1450);enemies={e};bot.target=e
    cast(module,astral);assert(#actions==1 and math.abs(actions[1].point.x-1200)<0.001,'outer radius point clamped to live cast range')
    reset();astral.castable=true;bot.mode='attack';e=unit(1000);e.mods.modifier_elder_titan_echo_stomp=true;enemies={e};bot.target=e
    cast(module,astral);assert(#actions==0,'do not wake existing sleep setup with Spirit pass')
    reset();astral.castable=true;stomp.trained=true;splitter.trained=true;bot.mode='farm';bot.mana=374
    neutrals={unit(700,0,'creep'),unit(750,0,'creep'),unit(800,0,'creep')}
    cast(module,astral);assert(#actions==0,'farm reserves linked combo mana')
    bot.mana=375;cast(module,astral);assert(#actions==1,'budgeted clustered neutral Spirit')
    reset();astral.trained=true;move.castable=true;recall.castable=true;sp=summon(1000);e=unit(1200);enemies={e};bot.mode='attack'
    assert(module.UseAstralSpirit() and #actions==1 and actions[1].name==recall.name,'observed touch inside full 275 radius returns combat buff')
    actions={};assert(not module.UseAstralSpirit() and #actions==0,'return command is not repeatedly reissued')
    reset();astral.trained=true;move.castable=true;recall.castable=true;sp=summon(1000);e=unit(1100);enemies={e,unit(1400)}
    assert(module.UseAstralSpirit() and actions[1].name==move.name,'touch before another untapped hero')
    enemies={};actions={}
    assert(module.UseAstralSpirit() and actions[1].name==recall.name,'earned touches remain useful after heroes leave nearby observations')
    reset();astral.trained=true;move.castable=true;recall.castable=true;sp=summon(1000);e=unit(1350);enemies={e}
    assert(module.UseAstralSpirit() and actions[1].name==move.name,'commanded destination is not counted as actual touch')
    e.x=1600;actions={};module.UseAstralSpirit();assert(actions[1].point.x==1600,'moving target refreshed rather than stale cached waypoint')
    reset();astral.trained=true;move.castable=true;recall.castable=true;sp=summon(1000);e=unit(1300);enemies={e};bot.channel=true
    assert(module.HandleAstralSpiritMinion(sp),'own synchronized minion is consumed by controller')
    assert(not module.UseAstralSpirit() and #actions==0,'Spirit callback preserves channel without clear action')
    reset();astral.trained=true;move.castable=true;recall.castable=true;sp=summon(1000);sp.channel=true;e=unit(1300);enemies={e}
    assert(not module.UseAstralSpirit() and #actions==0,'preserve Spirit own synchronized channel')
    reset();astral.trained=true;recall.castable=true;sp=summon(1000);module.UseAstralSpirit();now=now+9
    assert(module.UseAstralSpirit() and actions[1].name==recall.name,'return near observed Spirit expiry')
end
reset();local sp=summon(800);bot.channel=true;native.MinionThink(sp)
assert(#actions==0 and minionActions==0,'native minion callback never cancels Stomp or overwrites Spirit')
sp.owner=8;native.MinionThink(sp);assert(minionActions==1,'ordinary/other owned minion delegates normally')
reset();stomp.castable=true;astral.castable=true;splitter.castable=true;bot.mode='attack';local e=unit(100);e.hp=100;enemies={e};bot.target=e
native.SkillsComplement();assert(#actions==1,'cast priority never overwrites queued multiple spells')
reset();stomp.castable=true;local e=unit(100);e.channel=true;enemies={e}
abilities.elder_titan_echo_stomp=nil
assert(copy.ConsiderStolenSpell(stomp) and actions[1].name==stomp.name,'supplied isolated stolen handle is authoritative')
abilities.elder_titan_echo_stomp=stomp
print('Elder Titan ability scenarios passed')
