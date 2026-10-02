local X = {}
local bot = GetBot()
local Abaddon = require(GetScriptDirectory()..'/FunLib/rubick_hero/abaddon')
local AbyssalUnderlord = require(GetScriptDirectory()..'/FunLib/rubick_hero/abyssal_underlord')
local Alchemist = require(GetScriptDirectory()..'/FunLib/rubick_hero/alchemist')
local AncientApparition = require(GetScriptDirectory()..'/FunLib/rubick_hero/ancient_apparition')
local Antimage = require(GetScriptDirectory()..'/FunLib/rubick_hero/antimage')
local ArcWarden = require(GetScriptDirectory()..'/FunLib/rubick_hero/arc_warden')
local Axe = require(GetScriptDirectory()..'/FunLib/rubick_hero/axe')
local Bane = require(GetScriptDirectory()..'/FunLib/rubick_hero/bane')
local Batrider = require(GetScriptDirectory()..'/FunLib/rubick_hero/batrider')
local Beastmaster = require(GetScriptDirectory()..'/FunLib/rubick_hero/beastmaster')
local Bloodseeker = require(GetScriptDirectory()..'/FunLib/rubick_hero/bloodseeker')
local BountyHunter = require(GetScriptDirectory()..'/FunLib/rubick_hero/bounty_hunter')
local Brewmaster = require(GetScriptDirectory()..'/FunLib/rubick_hero/brewmaster')
local Bristleback = require(GetScriptDirectory()..'/FunLib/rubick_hero/bristleback')
local Broodmother = require(GetScriptDirectory()..'/FunLib/rubick_hero/broodmother')
local Centaur = require(GetScriptDirectory()..'/FunLib/rubick_hero/centaur')
local ChaosKnight = require(GetScriptDirectory()..'/FunLib/rubick_hero/chaos_knight')
local Chen = require(GetScriptDirectory()..'/FunLib/rubick_hero/chen')
local Clinkz = require(GetScriptDirectory()..'/FunLib/rubick_hero/clinkz')
local CrystalMaiden = require(GetScriptDirectory()..'/FunLib/rubick_hero/crystal_maiden')
local Clockwerk = require(GetScriptDirectory()..'/FunLib/rubick_hero/rattletrap')
local DarkSeer = require(GetScriptDirectory()..'/FunLib/rubick_hero/dark_seer')
local DarkWillow = require(GetScriptDirectory()..'/FunLib/rubick_hero/dark_willow')
local Dawnbreaker = require(GetScriptDirectory()..'/FunLib/rubick_hero/dawnbreaker')
local DeathProphet = require(GetScriptDirectory()..'/FunLib/rubick_hero/death_prophet')
local Disruptor = require(GetScriptDirectory()..'/FunLib/rubick_hero/disruptor')
local DoomBringer = require(GetScriptDirectory()..'/FunLib/rubick_hero/doom_bringer')
local DragonKnight = require(GetScriptDirectory()..'/FunLib/rubick_hero/dragon_knight')
local DrowRanger = require(GetScriptDirectory()..'/FunLib/rubick_hero/drow_ranger')
local EarthSpirit = require(GetScriptDirectory()..'/FunLib/rubick_hero/earth_spirit')
local Earthshaker = require(GetScriptDirectory()..'/FunLib/rubick_hero/earthshaker')
local ElderTitan = require(GetScriptDirectory()..'/FunLib/rubick_hero/elder_titan')
local Leshrac = require(GetScriptDirectory()..'/FunLib/rubick_hero/leshrac')
local NagaSiren = require(GetScriptDirectory()..'/FunLib/rubick_hero/naga_siren')
local EmberSpirit = require(GetScriptDirectory()..'/FunLib/rubick_hero/ember_spirit')
local Lich = require(GetScriptDirectory()..'/FunLib/rubick_hero/lich')
local Necrolyte = require(GetScriptDirectory()..'/FunLib/rubick_hero/necrolyte')
local Enchantress = require(GetScriptDirectory()..'/FunLib/rubick_hero/enchantress')
local LifeStealer = require(GetScriptDirectory()..'/FunLib/rubick_hero/life_stealer')
local Lina = require(GetScriptDirectory()..'/FunLib/rubick_hero/lina')
local Nevermore = require(GetScriptDirectory()..'/FunLib/rubick_hero/nevermore')
local NightStalker = require(GetScriptDirectory()..'/FunLib/rubick_hero/night_stalker')
local Enigma = require(GetScriptDirectory()..'/FunLib/rubick_hero/enigma')
local Lion = require(GetScriptDirectory()..'/FunLib/rubick_hero/lion')
local NyxAssassin = require(GetScriptDirectory()..'/FunLib/rubick_hero/nyx_assassin')
local Luna = require(GetScriptDirectory()..'/FunLib/rubick_hero/luna')
local FacelessVoid = require(GetScriptDirectory()..'/FunLib/rubick_hero/faceless_void')
local Lycan = require(GetScriptDirectory()..'/FunLib/rubick_hero/lycan')
local ObsidianDestroyer = require(GetScriptDirectory()..'/FunLib/rubick_hero/obsidian_destroyer')
local Furion = require(GetScriptDirectory()..'/FunLib/rubick_hero/furion')
local Magnataur = require(GetScriptDirectory()..'/FunLib/rubick_hero/magnataur')
local OgreMagi = require(GetScriptDirectory()..'/FunLib/rubick_hero/ogre_magi')
local Marci = require(GetScriptDirectory()..'/FunLib/rubick_hero/marci')
local Mars = require(GetScriptDirectory()..'/FunLib/rubick_hero/mars')
local Omniknight = require(GetScriptDirectory()..'/FunLib/rubick_hero/omniknight')
local Grimstroke = require(GetScriptDirectory()..'/FunLib/rubick_hero/grimstroke')
local Gyrocopter = require(GetScriptDirectory()..'/FunLib/rubick_hero/gyrocopter')
local LegionCommander = require(GetScriptDirectory()..'/FunLib/rubick_hero/legion_commander')
local Medusa = require(GetScriptDirectory()..'/FunLib/rubick_hero/medusa')
local Hoodwink = require(GetScriptDirectory()..'/FunLib/rubick_hero/hoodwink')
local Oracle = require(GetScriptDirectory()..'/FunLib/rubick_hero/oracle')
local Meepo = require(GetScriptDirectory()..'/FunLib/rubick_hero/meepo')
local Huskar = require(GetScriptDirectory()..'/FunLib/rubick_hero/huskar')
local Pangolier = require(GetScriptDirectory()..'/FunLib/rubick_hero/pangolier')
local Mirana = require(GetScriptDirectory()..'/FunLib/rubick_hero/mirana')
local Jakiro = require(GetScriptDirectory()..'/FunLib/rubick_hero/jakiro')
local MonkeyKing = require(GetScriptDirectory()..'/FunLib/rubick_hero/monkey_king')
local PhantomAssassin = require(GetScriptDirectory()..'/FunLib/rubick_hero/phantom_assassin')
local Juggernaut = require(GetScriptDirectory()..'/FunLib/rubick_hero/juggernaut')
local KeeperOfTheLight = require(GetScriptDirectory()..'/FunLib/rubick_hero/keeper_of_the_light')
local Morphling = require(GetScriptDirectory()..'/FunLib/rubick_hero/morphling')
local PhantomLancer = require(GetScriptDirectory()..'/FunLib/rubick_hero/phantom_lancer')
local Muerta = require(GetScriptDirectory()..'/FunLib/rubick_hero/muerta')
local Phoenix = require(GetScriptDirectory()..'/FunLib/rubick_hero/phoenix')
local Largo = require(GetScriptDirectory()..'/FunLib/rubick_hero/largo')
local PrimalBeast = require(GetScriptDirectory()..'/FunLib/rubick_hero/primal_beast')
local Kez = require(GetScriptDirectory()..'/FunLib/rubick_hero/kez')
local Puck = require(GetScriptDirectory()..'/FunLib/rubick_hero/puck')
local Kunkka = require(GetScriptDirectory()..'/FunLib/rubick_hero/kunkka')
local Pudge = require(GetScriptDirectory()..'/FunLib/rubick_hero/pudge')
local Pugna = require(GetScriptDirectory()..'/FunLib/rubick_hero/pugna')

local Snapfire = require(GetScriptDirectory()..'/FunLib/rubick_hero/snapfire')

local Tusk = require(GetScriptDirectory()..'/FunLib/rubick_hero/tusk')

local Queenofpain = require(GetScriptDirectory()..'/FunLib/rubick_hero/queenofpain')

local Sniper = require(GetScriptDirectory()..'/FunLib/rubick_hero/sniper')

local Undying = require(GetScriptDirectory()..'/FunLib/rubick_hero/undying')

local Ursa = require(GetScriptDirectory()..'/FunLib/rubick_hero/ursa')

local Razor = require(GetScriptDirectory()..'/FunLib/rubick_hero/razor')

local Spectre = require(GetScriptDirectory()..'/FunLib/rubick_hero/spectre')

local Riki = require(GetScriptDirectory()..'/FunLib/rubick_hero/riki')

local Vengefulspirit = require(GetScriptDirectory()..'/FunLib/rubick_hero/vengefulspirit')

local WitchDoctor = require(GetScriptDirectory()..'/FunLib/rubick_hero/witch_doctor')

local SpiritBreaker = require(GetScriptDirectory()..'/FunLib/rubick_hero/spirit_breaker')

local Ringmaster = require(GetScriptDirectory()..'/FunLib/rubick_hero/ringmaster')

local Venomancer = require(GetScriptDirectory()..'/FunLib/rubick_hero/venomancer')

local StormSpirit = require(GetScriptDirectory()..'/FunLib/rubick_hero/storm_spirit')

local Viper = require(GetScriptDirectory()..'/FunLib/rubick_hero/viper')

local SandKing = require(GetScriptDirectory()..'/FunLib/rubick_hero/sand_king')

local Sven = require(GetScriptDirectory()..'/FunLib/rubick_hero/sven')

local ShadowDemon = require(GetScriptDirectory()..'/FunLib/rubick_hero/shadow_demon')

local Techies = require(GetScriptDirectory()..'/FunLib/rubick_hero/techies')

local Visage = require(GetScriptDirectory()..'/FunLib/rubick_hero/visage')

local Zuus = require(GetScriptDirectory()..'/FunLib/rubick_hero/zuus')

local VoidSpirit = require(GetScriptDirectory()..'/FunLib/rubick_hero/void_spirit')

local ShadowShaman = require(GetScriptDirectory()..'/FunLib/rubick_hero/shadow_shaman')

local TemplarAssassin = require(GetScriptDirectory()..'/FunLib/rubick_hero/templar_assassin')

local Shredder = require(GetScriptDirectory()..'/FunLib/rubick_hero/shredder')

local Terrorblade = require(GetScriptDirectory()..'/FunLib/rubick_hero/terrorblade')

local Warlock = require(GetScriptDirectory()..'/FunLib/rubick_hero/warlock')

local Slardar = require(GetScriptDirectory()..'/FunLib/rubick_hero/slardar')

local Slark = require(GetScriptDirectory()..'/FunLib/rubick_hero/slark')

local Tidehunter = require(GetScriptDirectory()..'/FunLib/rubick_hero/tidehunter')

local Weaver = require(GetScriptDirectory()..'/FunLib/rubick_hero/weaver')

local Silencer = require(GetScriptDirectory()..'/FunLib/rubick_hero/silencer')

local Tinker = require(GetScriptDirectory()..'/FunLib/rubick_hero/tinker')

local SkeletonKing = require(GetScriptDirectory()..'/FunLib/rubick_hero/skeleton_king')

local Windrunner = require(GetScriptDirectory()..'/FunLib/rubick_hero/windrunner')

local SkywrathMage = require(GetScriptDirectory()..'/FunLib/rubick_hero/skywrath_mage')

local Tiny = require(GetScriptDirectory()..'/FunLib/rubick_hero/tiny')

local WinterWyvern = require(GetScriptDirectory()..'/FunLib/rubick_hero/winter_wyvern')

local Treant = require(GetScriptDirectory()..'/FunLib/rubick_hero/treant')

local Wisp = require(GetScriptDirectory()..'/FunLib/rubick_hero/wisp')

local TrollWarlord = require(GetScriptDirectory()..'/FunLib/rubick_hero/troll_warlord')

local J = require( GetScriptDirectory()..'/FunLib/jmz_func' )
local handlers = {
    Abaddon, AbyssalUnderlord, Alchemist, AncientApparition, Antimage, ArcWarden,
    Axe, Bane, Batrider, Beastmaster, Bloodseeker, BountyHunter, Brewmaster,
    Bristleback, Broodmother, Centaur, ChaosKnight, Chen, Clinkz, CrystalMaiden, Clockwerk, DarkSeer, DarkWillow, Dawnbreaker, DeathProphet, Disruptor, DoomBringer, DragonKnight, DrowRanger, EarthSpirit, Earthshaker, ElderTitan,
    Leshrac,
    NagaSiren,
    EmberSpirit,
    Lich,
    Necrolyte,
    Enchantress,
    LifeStealer,
    Lina,
    Nevermore,
    NightStalker,
    Enigma,
    Lion,
    NyxAssassin,
    Luna,
    FacelessVoid,
    Lycan,
    ObsidianDestroyer,
    Furion,
    Magnataur,
    OgreMagi,
    Marci,
    Mars,
    Omniknight,
    Grimstroke,
    Gyrocopter,
    LegionCommander,
    Medusa,
    Hoodwink,
    Oracle,
    Meepo,
    Huskar,
    Pangolier,
    Mirana,
    Jakiro,
    MonkeyKing,
    PhantomAssassin,
    Juggernaut,
    KeeperOfTheLight,
    Morphling,
    PhantomLancer,
    Muerta,
    Phoenix,
    Largo,
    PrimalBeast,
    Kez,
    Puck,
    Kunkka,
    Pudge,
    Pugna,
    Snapfire,
    Tusk,
    Queenofpain,
    Sniper,
    Undying,
    Ursa,
    Razor,
    Spectre,
    Riki,
    Vengefulspirit,
    WitchDoctor,
    SpiritBreaker,
    Ringmaster,
    Venomancer,
    StormSpirit,
    Viper,
    SandKing,
    Sven,
    ShadowDemon,
    Techies,
    Visage,
    Zuus,
    VoidSpirit,
    ShadowShaman,
    TemplarAssassin,
    Shredder,
    Terrorblade,
    Warlock,
    Slardar,
    Slark,
    Tidehunter,
    Weaver,
    Silencer,
    Tinker,
    SkeletonKing,
    Windrunner,
    SkywrathMage,
    Tiny,
    WinterWyvern,
    Treant,
    Wisp,
    TrollWarlord,
}

local UNIT = DOTA_ABILITY_BEHAVIOR_UNIT_TARGET or 8
local POINT = DOTA_ABILITY_BEHAVIOR_POINT or 16
local NO_TARGET = DOTA_ABILITY_BEHAVIOR_NO_TARGET or 4
local HERO = DOTA_UNIT_TARGET_HERO or 1
local ENEMY = DOTA_UNIT_TARGET_TEAM_ENEMY or 2
local FRIENDLY = DOTA_UNIT_TARGET_TEAM_FRIENDLY or 1
local function has(value, flag) return bit.band(value, flag) ~= 0 end

-- Reviewed simple effects only: cast metadata cannot establish safe spell intent.
local fallback = {}
for _,name in ipairs({
    'dazzle_poison_touch',
    'enigma_malefice','enigma_midnight_pulse','grimstroke_dark_artistry',
    'invoker_cold_snap','jakiro_dual_breath','jakiro_ice_path','jakiro_macropyre','kunkka_torrent',
    'leshrac_lightning_storm','leshrac_split_earth','lich_frost_nova','lina_dragon_slave','lina_laguna_blade',
    'lina_light_strike_array','lion_finger_of_death','lion_impale','lion_voodoo','luna_lucent_beam',
    'magnataur_shockwave','medusa_mystic_snake','ogre_magi_fireblast','ogre_magi_ignite',
    'phantom_assassin_stifling_dagger','pugna_nether_blast','riki_smoke_screen','shadow_demon_demonic_purge',
    'shadow_demon_shadow_poison','shadow_shaman_ether_shock','shadow_shaman_voodoo',
    'skeleton_king_hellfire_blast','skywrath_mage_ancient_seal','skywrath_mage_arcane_bolt',
    'skywrath_mage_mystic_flare','snapfire_scatterblast','sniper_shrapnel','sven_storm_bolt',
    'terrorblade_reflection','tidehunter_gush','tinker_laser','tinker_march_of_the_machines','tiny_avalanche',
    'treant_natures_grasp','vengefulspirit_magic_missile','vengefulspirit_wave_of_terror',
    'venomancer_noxious_plague','venomancer_snakebite','venomancer_venomous_gale','viper_nethertoxin',
    'viper_viper_strike','visage_grave_chill','visage_soul_assumption','warlock_fatal_bonds',
    'winter_wyvern_splinter_blast','zuus_arc_lightning','zuus_lightning_bolt',
}) do fallback[name] = {intent='enemy'} end
fallback.queenofpain_scream_of_pain = {intent='enemy', radius='area_of_effect'}
fallback.razor_plasma_field = {intent='enemy', radius='radius'}
fallback.slardar_slithereen_crush = {intent='enemy', radius='crush_radius'}
fallback.tidehunter_ravage = {intent='enemy', radius='radius', minimum=2}
fallback.enigma_black_hole = {intent='enemy', radius='radius', minimum=2, channel=true}
fallback.witch_doctor_death_ward = {intent='enemy', channel=true}
for _,name in ipairs({'omniknight_purification','dazzle_shadow_wave','warlock_shadow_word'}) do
    fallback[name] = {intent='heal'}
end
for _,name in ipairs({'ogre_magi_bloodlust','lich_frost_shield','legion_commander_press_the_attack'}) do
    fallback[name] = {intent='buff'}
end
for _,name in ipairs({'sven_warcry','sven_gods_strength','snapfire_lil_shredder','ursa_overpower','templar_assassin_refraction','windrunner_windrun'}) do
    fallback[name] = {intent='self'}
end

fallback.ogre_magi_bloodlust.autocast = true -- Manual ally targeting is safe; never toggle autocast.

local function ready(ability)
    return ability ~= nil and not ability:IsNull() and not ability:IsHidden()
        and not ability:IsPassive() and ability:GetName() ~= 'rubick_empty1'
        and ability:GetName() ~= 'rubick_empty2' and not ability:GetName():match('^rubick_hidden%d+$')
        and ability:IsFullyCastable()
end

local function canReleaseWhileSilenced(ability)
    return ability:GetName() == 'ancient_apparition_ice_blast_release' and bot:IsSilenced()
        and bot:IsAlive() and not bot:IsInvulnerable() and not bot:IsStunned()
        and not bot:IsHexed() and not bot:IsNightmared() and not J.HasQueuedAction(bot)
        and not bot:HasModifier('modifier_ringmaster_the_box_buff')
        and not bot:HasModifier('modifier_doom_bringer_doom')
        and not bot:HasModifier('modifier_item_forcestaff_active')
end

-- Gate travel must continue after the creating spell enters cooldown.
X.UsePendingGate = AbyssalUnderlord.UsePendingGate
-- Stomp has a movable windup after its immediate cast has entered cooldown.
X.UsePendingStomp = Centaur.UsePendingStomp
X.UseBarrageInvisibility = Clinkz.UseBarrageInvisibility
X.UseFreezingFieldSpell = CrystalMaiden.UseFreezingFieldSpell
X.UseShadowRealmDuringChannel = DarkWillow.UseShadowRealmDuringChannel
X.UsePendingConverge = Dawnbreaker.UsePendingConverge
X.ObserveGlimpseHistory = Disruptor.ObserveGlimpseHistory
X.ObserveTimeLapseHistory = Weaver.ObserveStolenTimeLapseHistory
X.ObserveTetherState = Wisp.ObserveTetherState
X.IsRelocating = Wisp.IsRelocating

X.UseGlacierDuringMultishot = DrowRanger.UseGlacierDuringMultishot
X.UseMagnetizeStone = EarthSpirit.UseMagnetizeStone
X.UseAstralSpirit = ElderTitan.UseAstralSpirit
X.HandleAstralSpiritMinion = ElderTitan.HandleAstralSpiritMinion
X.HandleLycanMinion = Lycan.UseHightail
X.HandleTombstoneMinion = Undying.ConsiderStolenTombstoneMinion
X.HandleDeathWard = WitchDoctor.HandleDeathWard
X.HandlePlagueWardMinion = Venomancer.ConsiderStolenPlagueWardMinion
X.UseChainsDuringSleight = EmberSpirit.UseChainsDuringSleight
X.UsePulseNovaOff = Leshrac.UsePulseNovaOff
X.UseDuringGaze = Lich.UseDuringGaze
X.UseConsume = LifeStealer.UseConsume
X.StopDrain = Lion.StopDrain
X.UseSplitShot = Medusa.UseSplitShot
X.UseSharpshooterRelease = Hoodwink.UseSharpshooterRelease
X.UseFortuneRelease = Oracle.ConsiderStolenFortuneRelease
X.UseHealingWardDuringSlash = Juggernaut.UseHealingWardDuringSlash
X.UseStrengthShift = Morphling.UseStrengthShift
X.UseIlluminateRelease = KeeperOfTheLight.UseIlluminateRelease
X.UseGunslinger = Muerta.UseGunslinger
X.UseRhapsodyOff = Largo.UseRhapsodyOff
X.ConsiderPrimalContinuation = PrimalBeast.ConsiderStolenPrimalContinuation
X.ConsiderEggSunRay = Phoenix.ConsiderStolenEggSunRay
X.ConsiderPhaseJaunt = Puck.ConsiderStolenPhaseJaunt
X.ConsiderDismemberSupport = Pudge.ConsiderStolenDismemberSupport
X.ConsiderLifeDrainContinuation = Pugna.ConsiderStolenLifeDrainContinuation
X.ConsiderSnowballContinuation = Tusk.ConsiderStolenSnowballContinuation
X.ConsiderDisabledEnrage = Ursa.ConsiderStolenDisabledEnrage
X.UseSmokeDuringTricks = Riki.UseSmokeDuringTricks
X.UseRestorationDuringChannel = WitchDoctor.UseRestorationDuringChannel
X.UseChargeSupport = SpiritBreaker.UseChargeSupport
X.IsCharging = SpiritBreaker.IsCharging
X.UseBallFlightSpells = StormSpirit.UseBallFlightSpells
X.UseTameTheBeastsCrack = Ringmaster.UseTameTheBeastsCrack
X.UseCarnivalSouvenir = Ringmaster.UseCarnivalSouvenir
X.UseLightningHands = Zuus.UseLightningHands
X.HandleTrapMinion = TemplarAssassin.UseTrapMinion
X.HandleFamiliarMinion = Visage.ConsiderStolenFamiliarMinion
X.ConsiderDissimilatePortal = VoidSpirit.ConsiderStolenDissimilatePortal
X.UseDisabledRefraction = TemplarAssassin.UseDisabledRefraction
X.ConsiderUpheavalSafety = Warlock.ConsiderStolenUpheavalSafety
X.UseSpellsDuringTimberChain = Shredder.UseSpellsDuringTimberChain
X.UseShadowDanceSpells = Slark.UseShadowDanceSpells
X.ConsiderGeminateAutoCast = Weaver.ConsiderStolenGeminateAutoCast
X.ConsiderPoisonAutoCast = Viper.ConsiderStolenPoisonAutoCast
X.ConsiderPowershotSafety = Windrunner.ConsiderStolenPowershotSafety
X.ConsiderArcticBurnToggle = WinterWyvern.ConsiderStolenArcticBurnToggle
X.UseBattleStance = TrollWarlord.UseBattleStance
function X.UseSilencedHammer()
    if not bot:IsSilenced() then return false end
    local hammer = bot:GetAbilityByName('omniknight_hammer_of_purity')
    return hammer ~= nil and Omniknight.ConsiderSilencedSpell(hammer)
end

function X.ConsiderStolenSpell(ability)
    X.ObserveGlimpseHistory()
    X.ObserveTimeLapseHistory()
    X.ObserveTetherState()
    bot = GetBot()
    if X.IsRelocating() then return false end
    if X.UseShadowRealmDuringChannel()
        or X.UsePendingConverge()
        or X.UseFreezingFieldSpell()
        or X.UseBarrageInvisibility()
        or X.UsePendingStomp()
        or X.UsePendingGate()
        or X.UseGlacierDuringMultishot()
        or X.UseMagnetizeStone()
        or X.UseAstralSpirit()
        or X.UseChainsDuringSleight()
        or X.UseDuringGaze()
        or X.UsePulseNovaOff()
        or X.UseConsume()
        or X.StopDrain()
        or X.UseSplitShot()
        or X.UseSilencedHammer()
        or X.UseSharpshooterRelease()
        or X.UseFortuneRelease()
        or X.UseHealingWardDuringSlash()
        or X.UseStrengthShift()
        or X.UseIlluminateRelease()
        or X.UseGunslinger()
        or X.UseRhapsodyOff()
        or X.ConsiderPrimalContinuation()
        or X.ConsiderEggSunRay()
        or X.ConsiderPhaseJaunt()
        or X.ConsiderDismemberSupport()
        or X.ConsiderSnowballContinuation()
        or X.ConsiderDisabledEnrage()
        or X.UseSmokeDuringTricks()
        or X.UseRestorationDuringChannel()
        or X.UseChargeSupport()
        or X.UseBallFlightSpells()
        or X.UseTameTheBeastsCrack()
        or X.UseCarnivalSouvenir()
        or X.UseLightningHands()
        or X.ConsiderDissimilatePortal()
        or X.UseDisabledRefraction()
        or X.ConsiderUpheavalSafety()
        or X.UseSpellsDuringTimberChain()
        or X.UseShadowDanceSpells()
        or X.ConsiderGeminateAutoCast()
        or X.ConsiderPoisonAutoCast()
        or X.ConsiderPowershotSafety()
        or X.ConsiderArcticBurnToggle()
        or X.UseBattleStance()
        or X.ConsiderLifeDrainContinuation() then return true end
    if X.IsCharging() or not ready(ability) or (J.CanNotUseAbility(bot) and not canReleaseWhileSilenced(ability))
        or bot:IsChanneling() or bot:IsCastingAbility() or bot:IsUsingAbility() then return false end

    for _,handler in ipairs(handlers) do
        local result = handler.ConsiderStolenSpell(ability)
        if result ~= nil then return result == true end
    end

    local props = X.LoadAbilityProperties(ability)
    local desire, target, shape = X.ConsiderSpellBehavior(ability, props)
    if desire <= 0 then return false end
    if shape == 'unit' then bot:Action_UseAbilityOnEntity(ability, target)
    elseif shape == 'point' then bot:Action_UseAbilityOnLocation(ability, target)
    elseif shape == 'none' then bot:Action_UseAbility(ability)
    else return false end
    return true
end

local function safeHero(target)
    return J.IsValidHero(target) and not target:IsInvulnerable()
        and not J.IsSuspiciousIllusion(target) and J.CanCastOnNonMagicImmune(target)
end

function X.CanCastAbilityROnTarget(target)
    return safeHero(target) and target:GetTeam() ~= bot:GetTeam()
        and J.CanCastOnTargetAdvanced(target)
        and not target:HasModifier('modifier_arc_warden_tempest_double')
end

function X.ConsiderSpellBehavior(ability, props)
    local policy = fallback[ability:GetName()]
    if not props.isReady or policy == nil or props.unsafe
        or (props.channelled and not policy.channel) or (props.autocast and not policy.autocast) then return BOT_ACTION_DESIRE_NONE end
    local combat = J.IsGoingOnSomeone(bot) or J.IsInTeamFight(bot, 1200)
    local target = J.GetProperTarget(bot)
    local radius = props.aoeRadius
    if radius <= 0 and policy.radius then radius = ability:GetSpecialValueInt(policy.radius) end

    if policy.intent == 'self' then
        if combat and props.isForNoTarget and not props.isForUnitTarget and not props.isForSinglePoint
            and not bot:HasModifier('modifier_'..ability:GetName()) then
            return BOT_ACTION_DESIRE_HIGH, nil, 'none'
        end
    elseif policy.intent == 'heal' or policy.intent == 'buff' then
        if not props.isForUnitTarget or not props.isForTargetHero or not props.isForTargetAllies
            then return BOT_ACTION_DESIRE_NONE end
        local selected, lowest = nil, 1
        local allies = J.GetNearbyHeroes(bot, math.min(props.castRange, 1600), false, BOT_MODE_NONE)
        for _,ally in ipairs(allies) do
            if safeHero(ally) and ally:GetTeam() == bot:GetTeam() and J.IsInRange(bot, ally, props.castRange)
                and not ally:HasModifier('modifier_'..ability:GetName()) then
                local fraction = ally:GetHealth() / ally:GetMaxHealth()
                if ((policy.intent == 'heal' and fraction <= 0.65 and fraction < lowest)
                    or (policy.intent == 'buff' and (combat or J.IsGoingOnSomeone(ally)))) then
                    selected, lowest = ally, fraction
                end
            end
        end
        if selected then return BOT_ACTION_DESIRE_HIGH, selected, 'unit' end
    elseif (props.targetTeam == 0 or props.isForTargetEnemy) and X.CanCastAbilityROnTarget(target)
        and (combat or target:IsChanneling() or (J.IsRetreating(bot) and bot:WasRecentlyDamagedByAnyHero(2)))
        and J.IsAllowedToSpam(bot, props.manaCost) then
        if props.isForUnitTarget then
            if props.isForTargetHero and props.isForTargetEnemy and J.IsInRange(bot, target, props.castRange) then
                return BOT_ACTION_DESIRE_HIGH, target, 'unit'
            end
        elseif props.isForSinglePoint then
            local location = target:GetLocation()
            if GetUnitToLocationDistance(bot, location) <= props.castRange then
                if (policy.minimum or 1) > 1 then
                    if radius <= 0 then return BOT_ACTION_DESIRE_NONE end
                    local aoe = bot:FindAoELocation(true, true, bot:GetLocation(), props.castRange,
                        radius, ability:GetCastPoint(), 0)
                    if aoe.count < policy.minimum or GetUnitToLocationDistance(bot, aoe.targetloc) > props.castRange
                        then return BOT_ACTION_DESIRE_NONE end
                    location = aoe.targetloc
                end
                return BOT_ACTION_DESIRE_HIGH, location, 'point'
            end
        elseif props.isForNoTarget and radius > 0 and J.IsInRange(bot, target, radius) then
            if (policy.minimum or 1) > 1 then
                local count = 0
                for _,enemy in ipairs(J.GetNearbyHeroes(bot, math.min(radius, 1600), true, BOT_MODE_NONE)) do
                    if X.CanCastAbilityROnTarget(enemy) and J.IsInRange(bot, enemy, radius) then count = count + 1 end
                end
                if count < policy.minimum then return BOT_ACTION_DESIRE_NONE end
            end
            return BOT_ACTION_DESIRE_HIGH, nil, 'none'
        end
    end
    return BOT_ACTION_DESIRE_NONE
end

function X.LoadAbilityProperties(ability)
    local targetType, targetTeam, behavior = ability:GetTargetType(), ability:GetTargetTeam(), ability:GetBehavior()
    return {
        targetTeam=targetTeam, castRange=math.max(0, ability:GetCastRange()), manaCost=ability:GetManaCost(),
        isReady=ready(ability), aoeRadius=ability:GetAOERadius(),
        isForTargetHero=has(targetType, HERO), isForTargetEnemy=has(targetTeam, ENEMY),
        isForTargetAllies=has(targetTeam, FRIENDLY), isForUnitTarget=has(behavior, UNIT),
        isForSinglePoint=has(behavior, POINT), isForNoTarget=has(behavior, NO_TARGET),
        channelled=has(behavior, DOTA_ABILITY_BEHAVIOR_CHANNELLED or 128),
        autocast=has(behavior, DOTA_ABILITY_BEHAVIOR_AUTOCAST or 4096),
        unsafe=has(behavior, DOTA_ABILITY_BEHAVIOR_TOGGLE or 512)
            or has(behavior, DOTA_ABILITY_BEHAVIOR_VECTOR_TARGETING or 1073741824),
    }
end

return X
