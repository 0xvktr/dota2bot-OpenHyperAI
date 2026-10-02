-- Underlord placement, root follow-up, Shard targeting and Gate follow-through.
local H = dofile('tests/hero_harness.lua')
local bot, J = H.bot, H.J
BOT_ACTION_DESIRE_HIGH=1; BOT_ACTION_DESIRE_NONE=0; BOT_MODE_NONE=0
BOT_MODE_PUSH_TOWER_TOP=1; BOT_MODE_PUSH_TOWER_MID=2; BOT_MODE_PUSH_TOWER_BOT=3
UNIT_LIST_ALLIED_HEROES=1; LANE_TOP=1; LANE_MID=2; LANE_BOT=3
local Vec={}; Vec.__index=Vec
local function V(x,y) return setmetatable({x=x,y=y or 0,z=0},Vec) end
Vec.__sub=function(a,b) return V(a.x-b.x,a.y-b.y) end
Vec.__add=function(a,b) return V(a.x+b.x,a.y+b.y) end
Vec.__mul=function(a,k) return V(a.x*k,a.y*k) end
function Vec:Length2D() return math.sqrt(self.x*self.x+self.y*self.y) end
function Vec:Normalized() local n=self:Length2D(); return n>0 and self*(1/n) or V(0) end
local function dist(a,b) return (a-b):Length2D() end
function GetUnitToLocationDistance(u,v) return dist(u:GetLocation(),v) end
function GetUnitToUnitDistance(a,b) return dist(a:GetLocation(),b:GetLocation()) end
local now=100
function DotaTime() return now end
function IsLocationPassable() return true end
function GetTeam() return 2 end
function GetLaneFrontLocation() return V(4000) end

local Unit={};Unit.__index=Unit
local function U(x,y) return setmetatable({loc=V(x,y),hp=1000,valid=true,mods={},mode='idle'},Unit) end
function Unit:GetLocation() return self.loc end
function Unit:GetExtrapolatedLocation() return self.future or self.loc end
function Unit:GetHealth() return self.hp end
function Unit:GetMaxHealth() return 1000 end
function Unit:IsRooted() return self.rooted==true end
function Unit:IsInvulnerable() return false end
function Unit:IsIllusion() return self.illusion==true end
function Unit:IsChanneling() return self.channeling==true end
function Unit:HasModifier(m) return self.mods[m]==true end
function Unit:GetAttackTarget() return self.target end
function Unit:GetActiveMode() return 0 end
function Unit:WasRecentlyDamagedByAnyHero() return self.recent==true end
local enemies,allies,creeps,neutrals,towers,portals,actions={},{},{},{},{},nil,{}
local target,fight,spam,fightLocation,hazard=nil,false,false,nil,false
setmetatable(bot,Unit)
function bot:GetMana() return 1000 end
function bot:GetMaxMana() return 1000 end
function bot:IsStunned() return false end
function bot:IsHexed() return false end
function bot:IsNightmared() return false end
function bot:IsUsingAbility() return false end
function bot:IsCastingAbility() return false end
function bot:IsAlive() return true end
function bot:GetNearbyTowers() return towers end
function bot:GetNearbyLaneCreeps() return creeps end
function bot:GetNearbyNeutralCreeps() return neutrals end
function bot:FindAoELocation() return {targetloc=self.aoe or V(0),count=2} end
function bot:SetTarget(u) self.target=u;target=u end
for _,kind in ipairs({'OnLocation','OnEntity'}) do
    bot['Action_UseAbility'..kind]=function(_,a,t) actions[#actions+1]={name=a.name,kind=kind,target=t} end
end
local spells={}
local function Spell(name,range,values)
    local a={name=name,range=range,values=values or {},castable=false,level=4}
    function a:GetName() return self.name end
    function a:IsFullyCastable() return self.castable end
    function a:IsHidden() return self.name=='abyssal_underlord_portal_warp' end
    function a:IsNull() return false end
    function a:IsPassive() return false end
    function a:GetCastRange() return self.range end
    function a:GetCastPoint() return 0.25 end
    function a:GetManaCost() return 110 end
    function a:GetLevel() return self.level end
    function a:GetSpecialValueInt(key) return self.values[key] or 0 end
    spells[name]=a;return a
end
local fire=Spell('abyssal_underlord_firestorm',675,{radius=425,can_target_units=0})
local pit=Spell('abyssal_underlord_pit_of_malice',675,{radius=400})
local gate=Spell('abyssal_underlord_dark_portal',0,{minimum_distance=1500,distance_from_fountain=1425,duration=20})
local warp=Spell('abyssal_underlord_portal_warp',300)
function bot:GetAbilityByName(name) return spells[name] or {} end
local function near(list,loc,r)
    local out={};for _,u in ipairs(list) do if u.valid and dist(u.loc,loc)<=r then out[#out+1]=u end end;return out
end
J.IsValid=function(u) return u~=nil and u.valid end
J.IsValidHero=J.IsValid;J.IsValidTarget=J.IsValid
J.IsSuspiciousIllusion=function(u) return u.illusion==true end
J.CanCastOnNonMagicImmune=function(u) return J.IsValid(u) and not u.immune end
J.GetHP=function(u) return u.hp/1000 end
J.GetMP=function() return 1 end
J.CanNotUseAbility=function() return bot.silenced==true end
J.HasQueuedAction=function() return false end
J.GetProperTarget=function(u) return u==bot and target or u.target end
J.GetNearbyHeroes=function(u,r,enemy)
    -- Query relative to queried unit's team, like the engine.
    return near((u.enemy and not enemy or not u.enemy and enemy) and enemies or allies,u.loc,r)
end
J.GetEnemiesNearLoc=function(v,r) return near(enemies,v,r) end
J.GetAlliesNearLoc=function(v,r) return near(allies,v,r) end
J.GetCenterOfUnits=function(units)
    assert(units.x==nil,'center expects a unit list, never a Vector')
    local sum=V(0);for _,u in ipairs(units) do sum=sum+u.loc end
    return #units>0 and sum*(1/#units) or nil
end
J.IsInRange=function(a,b,r) return GetUnitToUnitDistance(a,b)<=r end
J.IsDisabled=function(u) return u.rooted or u.stunned or false end
J.IsInTeamFight=function() return fight end
J.IsGoingOnSomeone=function(u) return u.mode=='attack' end
J.IsRetreating=function(u) return u.mode=='retreat' end
J.IsLaning=function(u) return u.mode=='lane' end
J.IsFarming=function(u) return u.mode=='farm' end
J.IsPushing=function(u) return u.mode=='push' end
J.IsDefending=function(u) return u.mode=='defend' end
J.IsAttacking=function() return true end
J.IsAllowedToSpam=function() return spam end
J.IsDoingRoshan=function() return false end
J.IsDoingTormentor=function() return false end
J.GetTeamFightLocation=function() return fightLocation end
J.IsInLaningPhase=function() return false end
J.IsLocationInChrono=function() return hazard end
J.IsLocationInBlackHole=function() return false end
J.IsLocationInArena=function() return false end
J.IsMeepoClone=function() return false end
J.IsCore=function() return true end
J.GetTeamFountain=function() return V(-6000) end
J.GetUnderlordPortal=function() return portals end
function GetUnitList() return allies end

local Hero=H.load('npc_dota_hero_abyssal_underlord','pos_3')
local Copy=H.realDofile('bots/FunLib/rubick_hero/abyssal_underlord.lua')
package.loaded['bots/FunLib/rubick_hero/abyssal_underlord']=Copy
for _,name in ipairs({'abaddon','alchemist','ancient_apparition','antimage','arc_warden','axe','bane',
    'batrider','beastmaster','bloodseeker','bounty_hunter','brewmaster','bristleback','broodmother',
    'centaur','chaos_knight','chen','clinkz','crystal_maiden','rattletrap','dark_seer','dark_willow','dawnbreaker','death_prophet','disruptor','doom_bringer','dragon_knight','drow_ranger','earth_spirit','earthshaker','elder_titan','ember_spirit','enchantress','enigma','leshrac','lich','life_stealer','lina','lion','naga_siren','necrolyte','nevermore','night_stalker','nyx_assassin','luna','faceless_void','lycan','obsidian_destroyer','furion','magnataur','ogre_magi','marci','mars','omniknight','grimstroke','gyrocopter','legion_commander','medusa','hoodwink','oracle','meepo','huskar','pangolier','mirana','jakiro','monkey_king','phantom_assassin','juggernaut','keeper_of_the_light','morphling','phantom_lancer','muerta','phoenix','largo','primal_beast','kez','puck','kunkka','pudge','pugna','snapfire','tusk','queenofpain','sniper','undying','ursa','razor','spectre','riki','vengefulspirit','witch_doctor','spirit_breaker','ringmaster','venomancer','storm_spirit','viper','sand_king','sven','shadow_demon','techies','visage','zuus','void_spirit','shadow_shaman','templar_assassin','shredder','terrorblade','warlock','slardar','slark','tidehunter','weaver','silencer','tinker','skeleton_king','windrunner','skywrath_mage','tiny','winter_wyvern','treant','wisp','troll_warlord'}) do
    package.loaded['bots/FunLib/rubick_hero/'..name]={ObserveTetherState=function() end,IsRelocating=function() return false end,UseBattleStance=function() return false end,ConsiderStolenArcticBurnToggle=function() return false end,ConsiderStolenPowershotSafety=function() return false end,ConsiderStolenPoisonAutoCast=function() return false end,ConsiderStolenGeminateAutoCast=function() return false end,ObserveStolenTimeLapseHistory=function() end,UseShadowDanceSpells=function() return false end,UseSpellsDuringTimberChain=function() return false end,ConsiderStolenUpheavalSafety=function() return false end,UseDisabledRefraction=function() return false end,ConsiderStolenDissimilatePortal=function() return false end,UseLightningHands=function() return false end,UseCarnivalSouvenir=function() return false end,UseTameTheBeastsCrack=function() return false end,UseBallFlightSpells=function() return false end,IsCharging=function() return false end,UseChargeSupport=function() return false end,UseRestorationDuringChannel=function() return false end,UseSmokeDuringTricks=function() return false end,ConsiderStolenDisabledEnrage=function() return false end,ConsiderStolenTombstoneMinion=function() return false end,ConsiderStolenSnowballContinuation=function() return false end,ConsiderStolenLifeDrainContinuation=function() return false end,ConsiderStolenDismemberSupport=function() return false end,ConsiderStolenPhaseJaunt=function() return false end,UseRhapsodyOff=function() return false end,ConsiderStolenPrimalContinuation=function() return false end,ConsiderStolenEggSunRay=function() return false end,UseGunslinger=function() return false end,UseStrengthShift=function() return false end,UseIlluminateRelease=function() return false end,UseHealingWardDuringSlash=function() return false end,UseSharpshooterRelease=function() return false end,ConsiderStolenFortuneRelease=function() return false end,UseSplitShot=function() return false end,ConsiderSilencedSpell=function() return false end,UseConsume=function() return false end,UseChainsDuringSleight=function() return false end,UseDuringGaze=function() return false end,UsePulseNovaOff=function() return false end,StopDrain=function() return false end,UseGlacierDuringMultishot=function() return false end,UseMagnetizeStone=function() return false end,UseAstralSpirit=function() return false end,HandleLycanMinion=function() return false end,HandleAstralSpiritMinion=function() return false end,ObserveGlimpseHistory=function() end,UseShadowRealmDuringChannel=function() return false end,UsePendingConverge=function() return false end,UseFreezingFieldSpell=function() return false end,UseBarrageInvisibility=function() return false end,UsePendingStomp=function() return false end,
        ConsiderStolenSpell=function() return nil end}
end
function bot:IsSilenced() return self.silenced==true end
function bot:GetCurrentActiveAbility() return nil end
local Dispatcher=H.realDofile('bots/FunLib/rubick_utility.lua')
local function reset()
    now=now+30;enemies,allies,creeps,neutrals,towers,actions={},{},{},{},{},{}
    portals,target,fightLocation=nil,nil,nil;fight,spam,hazard=false,false,false
    for k,v in pairs(U(0)) do bot[k]=v end
    bot.rooted,bot.channeling,bot.recent,bot.aoe,bot.silenced=false,false,false,nil,false
    fire.castable,pit.castable,gate.castable,warp.castable=false,false,false,false
    fire.values.can_target_units=0;fire.level=4
    gate.values.minimum_distance=1500;gate.values.distance_from_fountain=1425
end
local function Enemy(x,y) local e=U(x,y);e.enemy=true;enemies[#enemies+1]=e;return e end
local function run(module,spell)
    actions={}
    if module==Hero then module.SkillsComplement() else Dispatcher.ConsiderStolenSpell(spell) end
    return actions[1]
end
for _,module in ipairs({Hero,Copy}) do
    -- Close enemies must not be overshot by a full cast-range offset.
    reset();target=Enemy(100);bot.mode='attack';pit.castable=true
    local a=run(module,pit)
    assert(a and a.name==pit.name and a.target.x==100,'Pit centres on a nearby target')
    reset();target=Enemy(100);bot.mode='attack';fire.castable=true
    a=run(module,fire);assert(a and a.target.x==100,'Firestorm centres on a nearby target')

    -- An unrelated distant enemy must not pull the centre away from the combat target.
    reset();target=Enemy(600);Enemy(-600);bot.mode='attack';fire.castable=true
    a=run(module,fire);assert(a and dist(a.target,target.loc)<=425,'Firestorm contains its selected target')
    for _,spell in ipairs({fire,pit}) do
        reset();target=Enemy(1000);target.future=V(1200);bot.mode='attack';spell.castable=true
        assert(run(module,spell)==nil,'do not cast beyond predicted coverage at the outer edge')
        reset();fight=true;bot.aoe=V(1200);spell.castable=true
        local first=Enemy(900);first.future=V(1200)
        local second=Enemy(900,10);second.future=V(1200,10)
        assert(run(module,spell)==nil,'teamfight coverage uses prediction after clamping')
    end

    -- Rooted targets receive Firestorm follow-up; targets at the edge remain covered in range.
    reset();target=Enemy(950);target.rooted=true;fire.castable=true
    a=run(module,fire);assert(a and a.target.x==675,'Firestorm reaches a rooted edge target from legal range')
    reset();target=Enemy(100);target.rooted=true;bot.mode='attack';pit.castable=true
    assert(run(module,pit)==nil,'do not overlap Pit roots unnecessarily')

    reset();fire.castable=true;bot.mode='lane';spam=true;fire.level=2
    creeps={U(300),U(340),U(360)}
    assert(run(module,fire)==nil,'early Firestorm preserves lane mana')
    fire.level=3;a=run(module,fire);assert(a,'level-three Firestorm clears a clustered wave')
    creeps={U(-800),U(800),U(1100)};assert(run(module,fire)==nil,'spread creeps do not create a false farm AoE')

    -- Shard uses entity targeting on a mobile ally close to its victim.
    reset();fire.castable=true;fire.values.can_target_units=1
    local ally=U(300);ally.mode='attack';ally.target=Enemy(450);allies={ally}
    a=run(module,fire);assert(a and a.kind=='OnEntity' and a.target==ally,'Shard storm follows the allied frontliner')

    -- Open an escape Gate and use the hidden unit-target interaction next tick.
    reset();gate.castable=true;warp.castable=true;bot.mode='retreat';bot.hp=450;bot.recent=true
    a=run(module,gate);assert(a and a.name==gate.name,'retreat opens a Gate before death')
    portals={U(100),U(-4575)} -- fountain arrival is offset by Valve's 1425-unit key.
    gate.castable=false;bot.silenced=true
    -- A stolen Gate handle can disappear before entry; retain its geometry at creation.
    gate.values.distance_from_fountain=0;gate.values.minimum_distance=99999
    a=run(module,gate);assert(a and a.kind=='OnEntity' and a.name==warp.name and a.target==portals[1],
        'Gate channel targets the nearby source portal, including fountain offset')

    reset();gate.castable=true;warp.castable=true;bot.mode='retreat';bot.hp=450;bot.recent=true
    run(module,gate);portals={U(100),U(-4575)};bot.rooted=true;gate.castable=false
    assert(run(module,gate)==nil,'rooted caster cannot start the Gate channel')
    now=now+3;bot.rooted=false
    a=run(module,gate);assert(a and a.name==warp.name,'Gate intent survives a root longer than two seconds')
    reset();gate.castable=true;warp.castable=true;bot.mode='retreat';bot.hp=450;bot.recent=true
    run(module,gate);portals={U(100),U(-4575)};gate.castable=false;hazard=true
    assert(run(module,gate)==nil,'cancel portal entry if the destination becomes unsafe')
end

-- Main spell ordering catches first, then damages; escape portal safety rejects hazards.
reset();pit.castable=true;fire.castable=true;bot.mode='attack';target=Enemy(500)
assert(run(Hero,pit).name==pit.name,'Pit opens an uncontrolled-target combo')
pit.castable=false;target.rooted=true
assert(run(Hero,fire).name==fire.name,'Firestorm follows the root')
reset();gate.castable=true;bot.mode='retreat';bot.hp=450;bot.recent=true;hazard=true
assert(run(Hero,gate)==nil,'do not create a Gate in a disabled destination')

-- Safe remote fight arrival still works with nearby allies at the source.
reset();gate.castable=true;fightLocation=V(4000);allies={U(100),U(4000)};Enemy(4100)
local a=run(Hero,gate);assert(a and a.target.x==4000,'safe team fight Gate joins allies')
print('Underlord ability scenarios passed')
