-- Shared data-only preferences: never execute a hero BotLib in the server VM.
local builds = {
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
