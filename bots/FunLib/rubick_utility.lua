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

local J = require( GetScriptDirectory()..'/FunLib/jmz_func' )
local handlers = {
    Abaddon, AbyssalUnderlord, Alchemist, AncientApparition, Antimage, ArcWarden,
    Axe, Bane, Batrider, Beastmaster, Bloodseeker, BountyHunter, Brewmaster,
    Bristleback, Broodmother, Centaur, ChaosKnight, Chen, Clinkz, CrystalMaiden, Clockwerk, DarkSeer, DarkWillow, Dawnbreaker, DeathProphet, Disruptor, DoomBringer, DragonKnight, DrowRanger, EarthSpirit, Earthshaker, ElderTitan,
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

X.UseGlacierDuringMultishot = DrowRanger.UseGlacierDuringMultishot
X.UseMagnetizeStone = EarthSpirit.UseMagnetizeStone
X.UseAstralSpirit = ElderTitan.UseAstralSpirit
X.HandleAstralSpiritMinion = ElderTitan.HandleAstralSpiritMinion

function X.ConsiderStolenSpell(ability)
    X.ObserveGlimpseHistory()
    bot = GetBot()
    if X.UseShadowRealmDuringChannel() or X.UsePendingConverge() or X.UseFreezingFieldSpell() or X.UseBarrageInvisibility() or X.UsePendingStomp() or X.UsePendingGate() or X.UseGlacierDuringMultishot() or X.UseMagnetizeStone() or X.UseAstralSpirit() then return true end
    if not ready(ability) or (J.CanNotUseAbility(bot) and not canReleaseWhileSilenced(ability))
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
