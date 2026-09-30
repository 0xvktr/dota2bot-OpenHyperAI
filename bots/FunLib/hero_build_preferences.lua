-- Shared data-only preferences: never execute a hero BotLib in the server VM.
local builds = {
    npc_dota_hero_zuus = require('bots.BotLib.Builds.zuus'),
    npc_dota_hero_witch_doctor = require('bots.BotLib.Builds.witch_doctor'),
    npc_dota_hero_wisp = require('bots.BotLib.Builds.wisp'),
    npc_dota_hero_winter_wyvern = require('bots.BotLib.Builds.winter_wyvern'),
    npc_dota_hero_windrunner = require('bots.BotLib.Builds.windrunner'),
    npc_dota_hero_weaver = require('bots.BotLib.Builds.weaver'),
    npc_dota_hero_warlock = require('bots.BotLib.Builds.warlock'),
    npc_dota_hero_void_spirit = require('bots.BotLib.Builds.void_spirit'),
    npc_dota_hero_visage = require('bots.BotLib.Builds.visage'),
    npc_dota_hero_viper = require('bots.BotLib.Builds.viper'),
    npc_dota_hero_venomancer = require('bots.BotLib.Builds.venomancer'),
    npc_dota_hero_vengefulspirit = require('bots.BotLib.Builds.vengefulspirit'),
    npc_dota_hero_ursa = require('bots.BotLib.Builds.ursa'),
    npc_dota_hero_undying = require('bots.BotLib.Builds.undying'),
    npc_dota_hero_tusk = require('bots.BotLib.Builds.tusk'),
    npc_dota_hero_troll_warlord = require('bots.BotLib.Builds.troll_warlord'),
    npc_dota_hero_treant = require('bots.BotLib.Builds.treant'),
    npc_dota_hero_tiny = require('bots.BotLib.Builds.tiny'),
    npc_dota_hero_tinker = require('bots.BotLib.Builds.tinker'),
    npc_dota_hero_tidehunter = require('bots.BotLib.Builds.tidehunter'),
    npc_dota_hero_terrorblade = require('bots.BotLib.Builds.terrorblade'),
    npc_dota_hero_templar_assassin = require('bots.BotLib.Builds.templar_assassin'),
    npc_dota_hero_techies = require('bots.BotLib.Builds.techies'),
    npc_dota_hero_sven = require('bots.BotLib.Builds.sven'),
    npc_dota_hero_storm_spirit = require('bots.BotLib.Builds.storm_spirit'),
    npc_dota_hero_spirit_breaker = require('bots.BotLib.Builds.spirit_breaker'),
    npc_dota_hero_snapfire = require('bots.BotLib.Builds.snapfire'),
    npc_dota_hero_spectre = require('bots.BotLib.Builds.spectre'),
    npc_dota_hero_sniper = require('bots.BotLib.Builds.sniper'),
    npc_dota_hero_slark = require('bots.BotLib.Builds.slark'),
    npc_dota_hero_slardar = require('bots.BotLib.Builds.slardar'),
    npc_dota_hero_skywrath_mage = require('bots.BotLib.Builds.skywrath_mage'),
    npc_dota_hero_skeleton_king = require('bots.BotLib.Builds.skeleton_king'),
    npc_dota_hero_silencer = require('bots.BotLib.Builds.silencer'),
    npc_dota_hero_shadow_shaman = require('bots.BotLib.Builds.shadow_shaman'),
    npc_dota_hero_shadow_demon = require('bots.BotLib.Builds.shadow_demon'),
    npc_dota_hero_shredder = require('bots.BotLib.Builds.shredder'),
    npc_dota_hero_sand_king = require('bots.BotLib.Builds.sand_king'),
    npc_dota_hero_riki = require('bots.BotLib.Builds.riki'),
    npc_dota_hero_razor = require('bots.BotLib.Builds.razor'),
    npc_dota_hero_rattletrap = require('bots.BotLib.Builds.rattletrap'),
    npc_dota_hero_pudge = require('bots.BotLib.Builds.pudge'),
    npc_dota_hero_puck = require('bots.BotLib.Builds.puck'),
    npc_dota_hero_primal_beast = require('bots.BotLib.Builds.primal_beast'),
    npc_dota_hero_queenofpain = require('bots.BotLib.Builds.queenofpain'),
    npc_dota_hero_pugna = require('bots.BotLib.Builds.pugna'),
    npc_dota_hero_phoenix = require('bots.BotLib.Builds.phoenix'),
    npc_dota_hero_phantom_lancer = require('bots.BotLib.Builds.phantom_lancer'),
    npc_dota_hero_phantom_assassin = require('bots.BotLib.Builds.phantom_assassin'),
    npc_dota_hero_ogre_magi = require('bots.BotLib.Builds.ogre_magi'),
    npc_dota_hero_omniknight = require('bots.BotLib.Builds.omniknight'),
    npc_dota_hero_oracle = require('bots.BotLib.Builds.oracle'),
    npc_dota_hero_pangolier = require('bots.BotLib.Builds.pangolier'),
    npc_dota_hero_necrolyte = require('bots.BotLib.Builds.necrolyte'),
    npc_dota_hero_nevermore = require('bots.BotLib.Builds.nevermore'),
    npc_dota_hero_night_stalker = require('bots.BotLib.Builds.night_stalker'),
    npc_dota_hero_nyx_assassin = require('bots.BotLib.Builds.nyx_assassin'),
    npc_dota_hero_obsidian_destroyer = require('bots.BotLib.Builds.obsidian_destroyer'),
    npc_dota_hero_ringmaster = require('bots.BotLib.Builds.ringmaster'),
    npc_dota_hero_naga_siren = require('bots.BotLib.Builds.naga_siren'),
    npc_dota_hero_muerta = require('bots.BotLib.Builds.muerta'),
    npc_dota_hero_morphling = require('bots.BotLib.Builds.morphling'),
    npc_dota_hero_monkey_king = require('bots.BotLib.Builds.monkey_king'),
    npc_dota_hero_meepo = require('bots.BotLib.Builds.meepo'),
    npc_dota_hero_mirana = require('bots.BotLib.Builds.mirana'),
    npc_dota_hero_medusa = require('bots.BotLib.Builds.medusa'),
    npc_dota_hero_mars = require('bots.BotLib.Builds.mars'),
    npc_dota_hero_marci = require('bots.BotLib.Builds.marci'),
    npc_dota_hero_kez = require('bots.BotLib.Builds.kez'),
    npc_dota_hero_legion_commander = require('bots.BotLib.Builds.legion_commander'),
    npc_dota_hero_leshrac = require('bots.BotLib.Builds.leshrac'),
    npc_dota_hero_lich = require('bots.BotLib.Builds.lich'),
    npc_dota_hero_life_stealer = require('bots.BotLib.Builds.life_stealer'),
    npc_dota_hero_lina = require('bots.BotLib.Builds.lina'),
    npc_dota_hero_lion = require('bots.BotLib.Builds.lion'),
    npc_dota_hero_luna = require('bots.BotLib.Builds.luna'),
    npc_dota_hero_lycan = require('bots.BotLib.Builds.lycan'),
    npc_dota_hero_magnataur = require('bots.BotLib.Builds.magnataur'),
    npc_dota_hero_gyrocopter = require('bots.BotLib.Builds.gyrocopter'),
    npc_dota_hero_jakiro = require('bots.BotLib.Builds.jakiro'),
    npc_dota_hero_juggernaut = require('bots.BotLib.Builds.juggernaut'),
    npc_dota_hero_furion = require('bots.BotLib.Builds.furion'),
    npc_dota_hero_grimstroke = require('bots.BotLib.Builds.grimstroke'),
    npc_dota_hero_hoodwink = require('bots.BotLib.Builds.hoodwink'),
    npc_dota_hero_huskar = require('bots.BotLib.Builds.huskar'),
    npc_dota_hero_keeper_of_the_light = require('bots.BotLib.Builds.keeper_of_the_light'),
    npc_dota_hero_kunkka = require('bots.BotLib.Builds.kunkka'),
    npc_dota_hero_largo = require('bots.BotLib.Builds.largo'),
    npc_dota_hero_faceless_void = require('bots.BotLib.Builds.faceless_void'),
    npc_dota_hero_enigma = require('bots.BotLib.Builds.enigma'),
    npc_dota_hero_elder_titan = require('bots.BotLib.Builds.elder_titan'),
    npc_dota_hero_enchantress = require('bots.BotLib.Builds.enchantress'),
    npc_dota_hero_doom_bringer = require('bots.BotLib.Builds.doom_bringer'),
    npc_dota_hero_dragon_knight = require('bots.BotLib.Builds.dragon_knight'),
    npc_dota_hero_drow_ranger = require('bots.BotLib.Builds.drow_ranger'),
    npc_dota_hero_earth_spirit = require('bots.BotLib.Builds.earth_spirit'),
    npc_dota_hero_earthshaker = require('bots.BotLib.Builds.earthshaker'),
    npc_dota_hero_ember_spirit = require('bots.BotLib.Builds.ember_spirit'),
    npc_dota_hero_disruptor = require('bots.BotLib.Builds.disruptor'),
    npc_dota_hero_death_prophet = require('bots.BotLib.Builds.death_prophet'),
    npc_dota_hero_dark_willow = require('bots.BotLib.Builds.dark_willow'),
    npc_dota_hero_dawnbreaker = require('bots.BotLib.Builds.dawnbreaker'),
    npc_dota_hero_dazzle = require('bots.BotLib.Builds.dazzle'),
    npc_dota_hero_clinkz = require('bots.BotLib.Builds.clinkz'),
    npc_dota_hero_crystal_maiden = require('bots.BotLib.Builds.crystal_maiden'),
    npc_dota_hero_dark_seer = require('bots.BotLib.Builds.dark_seer'),
    npc_dota_hero_centaur = require('bots.BotLib.Builds.centaur'),
    npc_dota_hero_chaos_knight = require('bots.BotLib.Builds.chaos_knight'),
    npc_dota_hero_chen = require('bots.BotLib.Builds.chen'),
    npc_dota_hero_bloodseeker = require('bots.BotLib.Builds.bloodseeker'),
    npc_dota_hero_bounty_hunter = require('bots.BotLib.Builds.bounty_hunter'),
    npc_dota_hero_brewmaster = require('bots.BotLib.Builds.brewmaster'),
    npc_dota_hero_bristleback = require('bots.BotLib.Builds.bristleback'),
    npc_dota_hero_broodmother = require('bots.BotLib.Builds.broodmother'),
    npc_dota_hero_beastmaster = require('bots.BotLib.Builds.beastmaster'),
    npc_dota_hero_batrider = require('bots.BotLib.Builds.batrider'),
    npc_dota_hero_bane = require('bots.BotLib.Builds.bane'),
    npc_dota_hero_axe = require('bots.BotLib.Builds.axe'),
    npc_dota_hero_arc_warden = require('bots.BotLib.Builds.arc_warden'),
    npc_dota_hero_antimage = require('bots.BotLib.Builds.antimage'),
    npc_dota_hero_ancient_apparition = require('bots.BotLib.Builds.ancient_apparition'),
    npc_dota_hero_alchemist = require('bots.BotLib.Builds.alchemist'),
    npc_dota_hero_abaddon = require('bots.BotLib.Builds.abaddon'),
    npc_dota_hero_abyssal_underlord = require('bots.BotLib.Builds.abyssal_underlord'),
}
local X = {}

-- Reviewed T5 suitability, not additional D2PT observations. Lists also restrict
-- the sparse-data shortlist to supported items: passive effects or existing
-- item-use handlers. Consumers still restrict selection to their allowed pools.
-- Earlier entries break equal pick-rate ties and provide the no-data fallback.
local tier5Profiles = {
    -- Initiation/survivability choices for Axe; active items have existing handlers.
    tank = {
        neutral = {'item_fallen_sky','item_minotaur_horn','item_dezun_bloodrite',
            'item_demonicon','item_spider_legs','item_heavy_blade','item_riftshadow_prism'},
        enhancement = {'item_enhancement_timeless','item_enhancement_evolved',
            'item_enhancement_hulking','item_enhancement_fleetfooted'},
    },
    attack = {
        neutral = {'item_desolator_2','item_heavy_blade','item_divine_regalia',
            'item_riftshadow_prism','item_fallen_sky','item_minotaur_horn',
            'item_spider_legs','item_dezun_bloodrite','item_demonicon'},
        -- Vampiric is ranked last: it only wins when D2PT's pick data prefers it over every other supported choice.
        enhancement = {'item_enhancement_fleetfooted','item_enhancement_evolved','item_enhancement_audacious',
            'item_enhancement_vampiric'},
    },
    support = {
        neutral = {'item_demonicon','item_dezun_bloodrite','item_fallen_sky',
            'item_spider_legs','item_minotaur_horn','item_harmonizer','item_heavy_blade'},
        enhancement = {'item_enhancement_timeless','item_enhancement_fleetfooted',
            'item_enhancement_evolved','item_enhancement_manic','item_enhancement_feverish'},
    },
    caster = {
        neutral = {'item_dezun_bloodrite','item_fallen_sky','item_demonicon',
            'item_minotaur_horn','item_spider_legs','item_harmonizer','item_heavy_blade',
            'item_desolator_2'},
        enhancement = {'item_enhancement_timeless','item_enhancement_evolved',
            -- Observed caster options participate in pick-rate ranking; preserve the existing no-data fallback.
            'item_enhancement_fleetfooted','item_enhancement_feverish','item_enhancement_vampiric'},
    },
}

-- Read-only view for tests/build_validator.lua.
X.tier5Profiles = tier5Profiles

function X.Get(bot, useDefaultRole)
    if bot == nil then return nil end
    local build = builds[bot:GetUnitName()]
    if build == nil then return nil end
    local role = (bot.stats and bot.stats.role) or bot.assignedRole
    if role == nil and useDefaultRole then role = build.defaultRole end
    if type(role) == 'number' then role = 'pos_'..role end
    return build.neutrals[role]
end

-- Return the best observed preference among the actual available candidates.
-- Unknown hero/role/tier or no matching item returns nil for the caller's old fallback.
function X.Select(bot, kind, tier, candidates, useDefaultRole)
    local preferences = X.Get(bot, useDefaultRole)
    local weights = preferences and preferences[kind] and preferences[kind][tier]
    local profile = tier == 5 and preferences and tier5Profiles[preferences.tier5Profile]
    local ranked = profile and profile[kind]
    if ranked then
        local best, bestPick, bestFit = nil, -1, -1
        local suitability = {}
        for i, name in ipairs(ranked) do suitability[name] = #ranked - i + 1 end
        for _, candidate in ipairs(candidates) do
            local name = type(candidate) == 'table' and candidate.name or candidate
            local fit = suitability[name]
            local pick = weights and weights[name] or 0
            if fit and (pick > bestPick or (pick == bestPick and fit > bestFit)) then
                best, bestPick, bestFit = candidate, pick, fit
            end
        end
        -- Even a sparse observed choice beats an unobserved suitable choice.
        -- With no observed candidates, fit alone decides. Nil is the last resort
        -- for entirely unreviewed offers, preserving the consumer's legacy path.
        return best
    end
    if weights == nil then return nil end
    local best, bestWeight = nil, 0
    for _, candidate in ipairs(candidates) do
        local name = type(candidate) == 'table' and candidate.name or candidate
        local weight = weights[name] or 0
        if weight > bestWeight then
            best, bestWeight = candidate, weight
        end
    end
    return best
end

return X
