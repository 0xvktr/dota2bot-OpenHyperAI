import { HeroMatchups } from "bots/ts_libs/bots";

// Reviewed D2PT entries below: up to 8 positive normalized pairings, >=100 matches.
// Weighted mean of displayed opponent/ally-role rows with the All filter; not raw win rate.
// Source role is required by D2PT; resulting lists have no runtime role preference.
// counter lists enemies this hero performs well AGAINST, not heroes that counter it.
// Unmarked entries retain their legacy data. See docs/D2PT_BUILD_UPDATES.md.
const heroes: HeroMatchups = {
    // D2PT 7.41f, 2026-09-28; source role: Hard Support; applied without role restrictions.
    npc_dota_hero_abaddon: {
        synergy: [
            "npc_dota_hero_hoodwink", // n=145, normalized +10.00 pp
            "npc_dota_hero_earthshaker", // n=129, normalized +8.84 pp
            "npc_dota_hero_bounty_hunter", // n=144, normalized +6.30 pp
            "npc_dota_hero_luna", // n=197, normalized +5.50 pp
            "npc_dota_hero_spirit_breaker", // n=134, normalized +5.24 pp
            "npc_dota_hero_axe", // n=150, normalized +4.70 pp
            "npc_dota_hero_windrunner", // n=217, normalized +3.71 pp
            "npc_dota_hero_invoker", // n=221, normalized +2.28 pp
        ],
        counter: [
            "npc_dota_hero_juggernaut", // n=120, normalized +9.90 pp
            "npc_dota_hero_dragon_knight", // n=101, normalized +9.15 pp
            "npc_dota_hero_axe", // n=111, normalized +7.50 pp
            "npc_dota_hero_hoodwink", // n=161, normalized +7.22 pp
            "npc_dota_hero_mirana", // n=221, normalized +6.80 pp
            "npc_dota_hero_ember_spirit", // n=132, normalized +5.30 pp
            "npc_dota_hero_lich", // n=122, normalized +4.80 pp
            "npc_dota_hero_lion", // n=189, normalized +3.13 pp
        ],
    },
    // D2PT 7.41f, 2026-09-28; source role: Offlane; applied without role restrictions.
    npc_dota_hero_abyssal_underlord: {
        synergy: [
            "npc_dota_hero_largo", // n=162, normalized +10.09 pp
            "npc_dota_hero_primal_beast", // n=144, normalized +9.30 pp
            "npc_dota_hero_bounty_hunter", // n=1891, normalized +7.87 pp
            "npc_dota_hero_dazzle", // n=392, normalized +7.70 pp
            "npc_dota_hero_oracle", // n=446, normalized +7.00 pp
            "npc_dota_hero_ursa", // n=281, normalized +6.80 pp
            "npc_dota_hero_omniknight", // n=129, normalized +6.30 pp
            "npc_dota_hero_chaos_knight", // n=102, normalized +6.20 pp
        ],
        counter: [
            "npc_dota_hero_templar_assassin", // n=385, normalized +10.80 pp
            "npc_dota_hero_riki", // n=126, normalized +9.92 pp
            "npc_dota_hero_queenofpain", // n=565, normalized +8.48 pp
            "npc_dota_hero_pangolier", // n=816, normalized +7.77 pp
            "npc_dota_hero_drow_ranger", // n=561, normalized +6.90 pp
            "npc_dota_hero_bristleback", // n=171, normalized +6.60 pp
            "npc_dota_hero_abaddon", // n=103, normalized +6.60 pp
            "npc_dota_hero_jakiro", // n=377, normalized +6.39 pp
        ],
    },

    // D2PT 7.41f, 2026-09-28; source role: Carry; applied without role restrictions.
    npc_dota_hero_alchemist: {
        synergy: [
            "npc_dota_hero_bounty_hunter", // n=117, normalized +15.46 pp
            "npc_dota_hero_pudge", // n=169, normalized +13.37 pp
            "npc_dota_hero_mirana", // n=123, normalized +2.76 pp
            "npc_dota_hero_undying", // n=101, normalized +1.32 pp
        ],
        counter: [
            "npc_dota_hero_windrunner", // n=142, normalized +5.47 pp
            "npc_dota_hero_nevermore", // n=114, normalized +4.81 pp
            "npc_dota_hero_luna", // n=132, normalized +4.80 pp
            "npc_dota_hero_invoker", // n=123, normalized +4.41 pp
            "npc_dota_hero_lion", // n=111, normalized +3.44 pp
            "npc_dota_hero_lina", // n=120, normalized +3.15 pp
            "npc_dota_hero_rubick", // n=145, normalized +2.40 pp
            "npc_dota_hero_spirit_breaker", // n=102, normalized +1.88 pp
        ],
    },

    // D2PT 7.41f, 2026-09-28; source role: Hard Support; applied without role restrictions.
    npc_dota_hero_ancient_apparition: {
        synergy: [
            "npc_dota_hero_centaur", // n=124, normalized +12.70 pp
            "npc_dota_hero_primal_beast", // n=101, normalized +9.04 pp
            "npc_dota_hero_phantom_lancer", // n=355, normalized +8.10 pp
            "npc_dota_hero_spirit_breaker", // n=396, normalized +6.40 pp
            "npc_dota_hero_nyx_assassin", // n=158, normalized +6.30 pp
            "npc_dota_hero_dragon_knight", // n=345, normalized +6.02 pp
            "npc_dota_hero_bounty_hunter", // n=409, normalized +5.60 pp
            "npc_dota_hero_enigma", // n=179, normalized +5.40 pp
        ],
        counter: [
            "npc_dota_hero_shredder", // n=103, normalized +13.76 pp
            "npc_dota_hero_necrolyte", // n=139, normalized +12.50 pp
            "npc_dota_hero_abyssal_underlord", // n=232, normalized +9.70 pp
            "npc_dota_hero_grimstroke", // n=179, normalized +9.28 pp
            "npc_dota_hero_wisp", // n=203, normalized +8.76 pp
            "npc_dota_hero_axe", // n=279, normalized +8.70 pp
            "npc_dota_hero_slardar", // n=177, normalized +8.30 pp
            "npc_dota_hero_tiny", // n=152, normalized +6.55 pp
        ],
    },

    // D2PT 7.41f, 2026-09-28; source role: Carry; applied without role restrictions.
    npc_dota_hero_antimage: {
        synergy: [
            "npc_dota_hero_lycan", // n=104, normalized +11.90 pp
            "npc_dota_hero_enigma", // n=349, normalized +11.20 pp
            "npc_dota_hero_leshrac", // n=115, normalized +10.20 pp
            "npc_dota_hero_oracle", // n=329, normalized +8.71 pp
            "npc_dota_hero_marci", // n=208, normalized +7.60 pp
            "npc_dota_hero_primal_beast", // n=214, normalized +6.89 pp
            "npc_dota_hero_kez", // n=110, normalized +6.70 pp
            "npc_dota_hero_legion_commander", // n=346, normalized +6.60 pp
        ],
        counter: [
            "npc_dota_hero_bristleback", // n=122, normalized +14.90 pp
            "npc_dota_hero_shadow_demon", // n=171, normalized +11.61 pp
            "npc_dota_hero_kunkka", // n=137, normalized +11.29 pp
            "npc_dota_hero_largo", // n=301, normalized +9.98 pp
            "npc_dota_hero_muerta", // n=112, normalized +8.30 pp
            "npc_dota_hero_abyssal_underlord", // n=420, normalized +7.80 pp
            "npc_dota_hero_sniper", // n=214, normalized +7.41 pp
            "npc_dota_hero_storm_spirit", // n=384, normalized +6.60 pp
        ],
    },

    // D2PT 7.41f, 2026-09-28; source role: Mid; applied without role restrictions.
    npc_dota_hero_arc_warden: {
        synergy: [
            "npc_dota_hero_enigma", // n=270, normalized +10.10 pp
            "npc_dota_hero_brewmaster", // n=118, normalized +10.10 pp
            "npc_dota_hero_bounty_hunter", // n=659, normalized +7.11 pp
            "npc_dota_hero_jakiro", // n=117, normalized +6.39 pp
            "npc_dota_hero_oracle", // n=185, normalized +6.10 pp
            "npc_dota_hero_vengefulspirit", // n=187, normalized +4.95 pp
            "npc_dota_hero_mars", // n=129, normalized +4.90 pp
            "npc_dota_hero_tiny", // n=205, normalized +4.84 pp
        ],
        counter: [
            "npc_dota_hero_weaver", // n=110, normalized +18.27 pp
            "npc_dota_hero_templar_assassin", // n=132, normalized +13.40 pp
            "npc_dota_hero_tiny", // n=148, normalized +11.13 pp
            "npc_dota_hero_silencer", // n=178, normalized +9.49 pp
            "npc_dota_hero_mars", // n=154, normalized +8.70 pp
            "npc_dota_hero_tinker", // n=170, normalized +7.70 pp
            "npc_dota_hero_storm_spirit", // n=245, normalized +7.50 pp
            "npc_dota_hero_viper", // n=110, normalized +7.37 pp
        ],
    },
    // D2PT 7.41f, 2026-09-28; source role: Offlane; applied without role restrictions.
    npc_dota_hero_axe: {
        synergy: [
            "npc_dota_hero_meepo", // n=124, normalized +8.80 pp
            "npc_dota_hero_bounty_hunter", // n=2007, normalized +8.12 pp
            "npc_dota_hero_dazzle", // n=586, normalized +6.55 pp
            "npc_dota_hero_oracle", // n=697, normalized +6.42 pp
            "npc_dota_hero_abaddon", // n=150, normalized +6.30 pp
            "npc_dota_hero_visage", // n=103, normalized +6.00 pp
            "npc_dota_hero_puck", // n=661, normalized +5.40 pp
            "npc_dota_hero_slardar", // n=121, normalized +5.30 pp
        ],
        counter: [
            "npc_dota_hero_medusa", // n=142, normalized +10.70 pp
            "npc_dota_hero_jakiro", // n=402, normalized +9.53 pp
            "npc_dota_hero_kez", // n=781, normalized +8.46 pp
            "npc_dota_hero_antimage", // n=474, normalized +8.30 pp
            "npc_dota_hero_slardar", // n=794, normalized +8.24 pp
            "npc_dota_hero_bristleback", // n=220, normalized +8.00 pp
            "npc_dota_hero_muerta", // n=198, normalized +7.70 pp
            "npc_dota_hero_terrorblade", // n=909, normalized +7.00 pp
        ],
    },

    // D2PT 7.41f, 2026-09-28; source role: Hard Support; applied without role restrictions.
    npc_dota_hero_bane: {
        synergy: [
            "npc_dota_hero_bounty_hunter", // n=908, normalized +12.60 pp
            "npc_dota_hero_brewmaster", // n=169, normalized +10.30 pp
            "npc_dota_hero_rattletrap", // n=176, normalized +10.10 pp
            "npc_dota_hero_enigma", // n=475, normalized +8.40 pp
            "npc_dota_hero_earth_spirit", // n=731, normalized +8.22 pp
            "npc_dota_hero_snapfire", // n=567, normalized +7.81 pp
            "npc_dota_hero_sven", // n=658, normalized +7.50 pp
            "npc_dota_hero_dark_seer", // n=890, normalized +7.00 pp
        ],
        counter: [
            "npc_dota_hero_templar_assassin", // n=195, normalized +15.10 pp
            "npc_dota_hero_tinker", // n=225, normalized +11.80 pp
            "npc_dota_hero_jakiro", // n=198, normalized +11.11 pp
            "npc_dota_hero_gyrocopter", // n=152, normalized +11.02 pp
            "npc_dota_hero_queenofpain", // n=235, normalized +10.10 pp
            "npc_dota_hero_zuus", // n=426, normalized +9.89 pp
            "npc_dota_hero_shredder", // n=211, normalized +9.70 pp
            "npc_dota_hero_kez", // n=359, normalized +9.56 pp
        ],
    },

    // D2PT 7.41f, 2026-09-28; source role: Mid; applied without role restrictions.
    npc_dota_hero_batrider: {
        synergy: [ // No positive pairing meets the 100-match minimum.
        ],
        counter: [
            "npc_dota_hero_pudge", // n=132, normalized +5.88 pp
        ],
    },
    npc_dota_hero_beastmaster: {
        synergy: [
            "npc_dota_hero_arc_warden",
            "npc_dota_hero_primal_beast",
            "npc_dota_hero_shredder",
            "npc_dota_hero_batrider",
            "npc_dota_hero_night_stalker",
            "npc_dota_hero_dazzle",
            "npc_dota_hero_magnataur",
            "npc_dota_hero_lone_druid",
            "npc_dota_hero_dragon_knight",
            "npc_dota_hero_earthshaker",
        ],
        counter: [
            "npc_dota_hero_visage",
            "npc_dota_hero_naga_siren",
            "npc_dota_hero_arc_warden",
            "npc_dota_hero_phantom_lancer",
            "npc_dota_hero_night_stalker",
            "npc_dota_hero_slardar",
            "npc_dota_hero_broodmother",
            "npc_dota_hero_oracle",
        ],
    },
    npc_dota_hero_bloodseeker: {
        synergy: [
            "npc_dota_hero_slark",
            "npc_dota_hero_death_prophet",
            "npc_dota_hero_riki",
            "npc_dota_hero_chaos_knight",
            "npc_dota_hero_juggernaut",
            "npc_dota_hero_omniknight",
            "npc_dota_hero_abyssal_underlord",
            "npc_dota_hero_axe",
            "npc_dota_hero_bristleback",
        ],
        counter: [
            "npc_dota_hero_antimage",
            "npc_dota_hero_slark",
            "npc_dota_hero_night_stalker",
            "npc_dota_hero_primal_beast",
            "npc_dota_hero_phoenix",
            "npc_dota_hero_phantom_lancer",
            "npc_dota_hero_bane",
            "npc_dota_hero_riki",
            "npc_dota_hero_lycan",
        ],
    },

    npc_dota_hero_bounty_hunter: {
        synergy: [
            "npc_dota_hero_axe",
            "npc_dota_hero_spectre",
            "npc_dota_hero_phantom_lancer",
            "npc_dota_hero_muerta",
            "npc_dota_hero_legion_commander",
            "npc_dota_hero_void_spirit",
            "npc_dota_hero_obsidian_destroyer",
        ],
        counter: [
            "npc_dota_hero_clinkz",
            "npc_dota_hero_leshrac",
            "npc_dota_hero_visage",
            "npc_dota_hero_lycan",
            "npc_dota_hero_weaver",
            "npc_dota_hero_skeleton_king",
            "npc_dota_hero_bristleback",
            "npc_dota_hero_warlock",
            "npc_dota_hero_alchemist",
        ],
    },

    npc_dota_hero_brewmaster: {
        synergy: [
            "npc_dota_hero_visage",
            "npc_dota_hero_chaos_knight",
            "npc_dota_hero_broodmother",
            "npc_dota_hero_naga_siren",
            "npc_dota_hero_dark_willow",
            "npc_dota_hero_dawnbreaker",
            "npc_dota_hero_monkey_king",
            "npc_dota_hero_ancient_apparition",
            "npc_dota_hero_gyrocopter",
        ],
        counter: [
            "npc_dota_hero_beastmaster",
            "npc_dota_hero_naga_siren",
            "npc_dota_hero_sven",
            "npc_dota_hero_terrorblade",
            "npc_dota_hero_dark_seer",
            "npc_dota_hero_ancient_apparition",
            "npc_dota_hero_shredder",
            "npc_dota_hero_troll_warlord",
            "npc_dota_hero_lone_druid",
        ],
    },

    npc_dota_hero_bristleback: {
        synergy: [
            "npc_dota_hero_chaos_knight",
            "npc_dota_hero_naga_siren",
            "npc_dota_hero_legion_commander",
            "npc_dota_hero_slardar",
            "npc_dota_hero_sand_king",
            "npc_dota_hero_axe",
            "npc_dota_hero_nyx_assassin",
            "npc_dota_hero_mars",
            "npc_dota_hero_meepo",
        ],
        counter: [
            "npc_dota_hero_visage",
            "npc_dota_hero_beastmaster",
            "npc_dota_hero_huskar",
            "npc_dota_hero_enigma",
            "npc_dota_hero_witch_doctor",
            "npc_dota_hero_arc_warden",
            "npc_dota_hero_leshrac",
            "npc_dota_hero_sven",
            "npc_dota_hero_death_prophet",
        ],
    },

    npc_dota_hero_broodmother: {
        synergy: [
            "npc_dota_hero_dawnbreaker",
            "npc_dota_hero_earthshaker",
            "npc_dota_hero_batrider",
            "npc_dota_hero_skywrath_mage",
            "npc_dota_hero_mars",
            "npc_dota_hero_marci",
            "npc_dota_hero_nyx_assassin",
            "npc_dota_hero_snapfire",
            "npc_dota_hero_lich",
        ],
        counter: [
            "npc_dota_hero_arc_warden",
            "npc_dota_hero_furion",
            "npc_dota_hero_silencer",
            "npc_dota_hero_invoker",
            "npc_dota_hero_void_spirit",
            "npc_dota_hero_earth_spirit",
            "npc_dota_hero_obsidian_destroyer",
            "npc_dota_hero_skywrath_mage",
        ],
    },

    npc_dota_hero_centaur: {
        synergy: [
            "npc_dota_hero_beastmaster",
            "npc_dota_hero_bristleback",
            "npc_dota_hero_huskar",
            "npc_dota_hero_omniknight",
            "npc_dota_hero_dark_seer",
            "npc_dota_hero_alchemist",
            "npc_dota_hero_lone_druid",
            "npc_dota_hero_sven",
            "npc_dota_hero_broodmother",
        ],
        counter: [
            "npc_dota_hero_medusa",
            "npc_dota_hero_spectre",
            "npc_dota_hero_sniper",
            "npc_dota_hero_phantom_lancer",
            "npc_dota_hero_phantom_assassin",
            "npc_dota_hero_riki",
            "npc_dota_hero_muerta",
            "npc_dota_hero_drow_ranger",
            "npc_dota_hero_gyrocopter",
        ],
    },

    npc_dota_hero_chaos_knight: {
        synergy: [
            "npc_dota_hero_abyssal_underlord",
            "npc_dota_hero_beastmaster",
            "npc_dota_hero_dawnbreaker",
            "npc_dota_hero_earthshaker",
            "npc_dota_hero_death_prophet",
            "npc_dota_hero_treant",
            "npc_dota_hero_drow_ranger",
            "npc_dota_hero_ancient_apparition",
            "npc_dota_hero_batrider",
            "npc_dota_hero_viper",
        ],
        counter: [
            "npc_dota_hero_huskar",
            "npc_dota_hero_viper",
            "npc_dota_hero_lycan",
            "npc_dota_hero_ogre_magi",
            "npc_dota_hero_razor",
            "npc_dota_hero_broodmother",
            "npc_dota_hero_vengefulspirit",
            "npc_dota_hero_pugna",
        ],
    },

    npc_dota_hero_chen: {
        synergy: [
            "npc_dota_hero_omniknight",
            "npc_dota_hero_visage",
            "npc_dota_hero_marci",
            "npc_dota_hero_techies",
            "npc_dota_hero_batrider",
            "npc_dota_hero_arc_warden",
            "npc_dota_hero_primal_beast",
            "npc_dota_hero_mars",
        ],
        counter: [
            "npc_dota_hero_huskar",
            "npc_dota_hero_medusa",
            "npc_dota_hero_sven",
            "npc_dota_hero_muerta",
            "npc_dota_hero_beastmaster",
            "npc_dota_hero_batrider",
            "npc_dota_hero_anti-mage",
            "npc_dota_hero_phoenix",
        ],
    },

    npc_dota_hero_clinkz: {
        synergy: [
            "npc_dota_hero_keeper_of_the_light",
            "npc_dota_hero_arc_warden",
            "npc_dota_hero_beastmaster",
            "npc_dota_hero_spectre",
            "npc_dota_hero_luna",
            "npc_dota_hero_undying",
            "npc_dota_hero_abyssal_underlord",
            "npc_dota_hero_phantom_lancer",
            "npc_dota_hero_techies",
        ],
        counter: [
            "npc_dota_hero_broodmother",
            "npc_dota_hero_beastmaster",
            "npc_dota_hero_leshrac",
            "npc_dota_hero_death_prophet",
            "npc_dota_hero_huskar",
            "npc_dota_hero_rubick",
            "npc_dota_hero_doom_bringer",
            "npc_dota_hero_sand_king",
        ],
    },

    npc_dota_hero_crystal_maiden: {
        synergy: [
            "npc_dota_hero_silencer",
            "npc_dota_hero_lycan",
            "npc_dota_hero_pudge",
            "npc_dota_hero_drow_ranger",
            "npc_dota_hero_alchemist",
            "npc_dota_hero_bristleback",
            "npc_dota_hero_meepo",
        ],
        counter: [
            "npc_dota_hero_phantom_lancer",
            "npc_dota_hero_meepo",
            "npc_dota_hero_enchantress",
            "npc_dota_hero_lycan",
            "npc_dota_hero_bounty_hunter",
            "npc_dota_hero_furion",
            "npc_dota_hero_mirana",
            "npc_dota_hero_keeper_of_the_light",
        ],
    },
    npc_dota_hero_dark_seer: {
        synergy: [
            "npc_dota_hero_doom_bringer",
            "npc_dota_hero_primal_beast",
            "npc_dota_hero_naga_siren",
            "npc_dota_hero_centaur",
            "npc_dota_hero_bristleback",
            "npc_dota_hero_dawnbreaker",
            "npc_dota_hero_earth_spirit",
            "npc_dota_hero_spirit_breaker",
        ],
        counter: [
            "npc_dota_hero_medusa",
            "npc_dota_hero_meepo",
            "npc_dota_hero_terrorblade",
            "npc_dota_hero_tidehunter",
            "npc_dota_hero_enigma",
            "npc_dota_hero_chaos_knight",
            "npc_dota_hero_viper",
            "npc_dota_hero_doom_bringer",
            "npc_dota_hero_lone_druid",
        ],
    },
    npc_dota_hero_dawnbreaker: {
        synergy: [
            "npc_dota_hero_death_prophet",
            "npc_dota_hero_shredder",
            "npc_dota_hero_tidehunter",
            "npc_dota_hero_naga_siren",
            "npc_dota_hero_dark_seer",
            "npc_dota_hero_chaos_knight",
            "npc_dota_hero_mars",
            "npc_dota_hero_venomancer",
            "npc_dota_hero_void_spirit",
            "npc_dota_hero_crystal_maiden",
        ],
        counter: ["npc_dota_hero_naga_siren", "npc_dota_hero_shadow_demon", "npc_dota_hero_treant", "npc_dota_hero_troll_warlord", "npc_dota_hero_abaddon"],
    },

    npc_dota_hero_dazzle: {
        synergy: [
            "npc_dota_hero_broodmother",
            "npc_dota_hero_marci",
            "npc_dota_hero_tidehunter",
            "npc_dota_hero_visage",
            "npc_dota_hero_primal_beast",
            "npc_dota_hero_crystal_maiden",
            "npc_dota_hero_dawnbreaker",
            "npc_dota_hero_razor",
            "npc_dota_hero_shadow_demon",
        ],
        counter: [
            "npc_dota_hero_naga_siren",
            "npc_dota_hero_visage",
            "npc_dota_hero_spectre",
            "npc_dota_hero_arc_warden",
            "npc_dota_hero_lycan",
            "npc_dota_hero_beastmaster",
            "npc_dota_hero_shadow_demon",
            "npc_dota_hero_bloodseeker",
            "npc_dota_hero_bane",
        ],
    },

    npc_dota_hero_disruptor: {
        synergy: [
            "npc_dota_hero_arc_warden",
            "npc_dota_hero_oracle",
            "npc_dota_hero_bristleback",
            "npc_dota_hero_omniknight",
            "npc_dota_hero_furion",
            "npc_dota_hero_monkey_king",
            "npc_dota_hero_lycan",
            "npc_dota_hero_bounty_hunter",
            "npc_dota_hero_razor",
            "npc_dota_hero_mirana",
        ],
        counter: [
            "npc_dota_hero_riki",
            "npc_dota_hero_slark",
            "npc_dota_hero_magnataur",
            "npc_dota_hero_batrider",
            "npc_dota_hero_spectre",
            "npc_dota_hero_primal_beast",
            "npc_dota_hero_earthshaker",
            "npc_dota_hero_mirana",
        ],
    },

    npc_dota_hero_death_prophet: {
        synergy: [
            "npc_dota_hero_meepo",
            "npc_dota_hero_lycan",
            "npc_dota_hero_treant",
            "npc_dota_hero_enchantress",
            "npc_dota_hero_chaos_knight",
            "npc_dota_hero_slark",
            "npc_dota_hero_storm_spirit",
            "npc_dota_hero_phantom_assassin",
        ],
        counter: [
            "npc_dota_hero_necrolyte",
            "npc_dota_hero_oracle",
            "npc_dota_hero_alchemist",
            "npc_dota_hero_naga_siren",
            "npc_dota_hero_meepo",
            "npc_dota_hero_huskar",
            "npc_dota_hero_omniknight",
            "npc_dota_hero_life_stealer",
        ],
    },

    npc_dota_hero_doom_bringer: {
        synergy: [
            "npc_dota_hero_meepo",
            "npc_dota_hero_beastmaster",
            "npc_dota_hero_sand_king",
            "npc_dota_hero_dark_seer",
            "npc_dota_hero_furion",
            "npc_dota_hero_sven",
            "npc_dota_hero_night_stalker",
            "npc_dota_hero_bristleback",
        ],
        counter: [
            "npc_dota_hero_omniknight",
            "npc_dota_hero_necrolyte",
            "npc_dota_hero_enchantress",
            "npc_dota_hero_axe",
            "npc_dota_hero_oracle",
            "npc_dota_hero_marci",
            "npc_dota_hero_ember_spirit",
            "npc_dota_hero_faceless_void",
            "npc_dota_hero_shredder",
        ],
    },

    npc_dota_hero_dragon_knight: {
        synergy: [
            "npc_dota_hero_primal_beast",
            "npc_dota_hero_mars",
            "npc_dota_hero_abyssal_underlord",
            "npc_dota_hero_earthshaker",
            "npc_dota_hero_centaur",
            "npc_dota_hero_omniknight",
            "npc_dota_hero_night_stalker",
            "npc_dota_hero_riki",
            "npc_dota_hero_sand_king",
        ],
        counter: [
            "npc_dota_hero_lycan",
            "npc_dota_hero_bristleback",
            "npc_dota_hero_skywrath_mage",
            "npc_dota_hero_oracle",
            "npc_dota_hero_skeleton_king",
            "npc_dota_hero_templar_assassin",
            "npc_dota_hero_void_spirit",
        ],
    },

    npc_dota_hero_drow_ranger: {
        synergy: [
            "npc_dota_hero_vengefulspirit",
            "npc_dota_hero_storm_spirit",
            "npc_dota_hero_nevermore",
            "npc_dota_hero_arc_warden",
            "npc_dota_hero_crystal_maiden",
            "npc_dota_hero_venomancer",
            "npc_dota_hero_riki",
            "npc_dota_hero_pudge",
            "npc_dota_hero_razor",
            "npc_dota_hero_beastmaster",
        ],
        counter: [
            "npc_dota_hero_necrolyte",
            "npc_dota_hero_weaver",
            "npc_dota_hero_bristleback",
            "npc_dota_hero_death_prophet",
            "npc_dota_hero_leshrac",
            "npc_dota_hero_riki",
            "npc_dota_hero_slardar",
            "npc_dota_hero_troll_warlord",
            "npc_dota_hero_sand_king",
        ],
    },

    npc_dota_hero_earth_spirit: {
        synergy: [
            "npc_dota_hero_enigma",
            "npc_dota_hero_beastmaster",
            "npc_dota_hero_treant",
            "npc_dota_hero_silencer",
            "npc_dota_hero_skeleton_king",
            "npc_dota_hero_undying",
            "npc_dota_hero_venomancer",
            "npc_dota_hero_dazzle",
        ],
        counter: [
            "npc_dota_hero_abyssal_underlord",
            "npc_dota_hero_keeper_of_the_light",
            "npc_dota_hero_beastmaster",
            "npc_dota_hero_sniper",
            "npc_dota_hero_broodmother",
            "npc_dota_hero_axe",
            "npc_dota_hero_drow_ranger",
            "npc_dota_hero_phantom_lancer",
        ],
    },

    npc_dota_hero_earthshaker: {
        synergy: [
            "npc_dota_hero_night_stalker",
            "npc_dota_hero_visage",
            "npc_dota_hero_naga_siren",
            "npc_dota_hero_broodmother",
            "npc_dota_hero_dark_seer",
            "npc_dota_hero_omniknight",
            "npc_dota_hero_dragon_knight",
            "npc_dota_hero_shredder",
        ],
        counter: [
            "npc_dota_hero_meepo",
            "npc_dota_hero_broodmother",
            "npc_dota_hero_naga_siren",
            "npc_dota_hero_phantom_lancer",
            "npc_dota_hero_chaos_knight",
            "npc_dota_hero_arc_warden",
            "npc_dota_hero_visage",
            "npc_dota_hero_lone_druid",
        ],
    },
    npc_dota_hero_ember_spirit: {
        synergy: [
            "npc_dota_hero_dark_seer",
            "npc_dota_hero_pugna",
            "npc_dota_hero_treant",
            "npc_dota_hero_alchemist",
            "npc_dota_hero_bane",
            "npc_dota_hero_bounty_hunter",
            "npc_dota_hero_bloodseeker",
        ],
        counter: [
            "npc_dota_hero_phantom_lancer",
            "npc_dota_hero_batrider",
            "npc_dota_hero_centaur",
            "npc_dota_hero_enigma",
            "npc_dota_hero_rattletrap",
            "npc_dota_hero_bristleback",
            "npc_dota_hero_kunkka",
            "npc_dota_hero_storm_spirit",
            "npc_dota_hero_zuus",
            "npc_dota_hero_vengefulspirit",
        ],
    },

    npc_dota_hero_enchantress: {
        synergy: [
            "npc_dota_hero_keeper_of_the_light",
            "npc_dota_hero_abyssal_underlord",
            "npc_dota_hero_winter_wyvern",
            "npc_dota_hero_nyx_assassin",
            "npc_dota_hero_furion",
            "npc_dota_hero_warlock",
            "npc_dota_hero_dawnbreaker",
            "npc_dota_hero_kunkka",
            "npc_dota_hero_tidehunter",
            "npc_dota_hero_muerta",
        ],
        counter: [
            "npc_dota_hero_visage",
            "npc_dota_hero_venomancer",
            "npc_dota_hero_death_prophet",
            "npc_dota_hero_sven",
            "npc_dota_hero_faceless_void",
            "npc_dota_hero_batrider",
            "npc_dota_hero_huskar",
            "npc_dota_hero_spectre",
        ],
    },

    npc_dota_hero_enigma: {
        synergy: [
            "npc_dota_hero_batrider",
            "npc_dota_hero_earth_spirit",
            "npc_dota_hero_leshrac",
            "npc_dota_hero_marci",
            "npc_dota_hero_huskar",
            "npc_dota_hero_phoenix",
            "npc_dota_hero_skeleton_king",
            "npc_dota_hero_medusa",
        ],
        counter: [
            "npc_dota_hero_batrider",
            "npc_dota_hero_beastmaster",
            "npc_dota_hero_meepo",
            "npc_dota_hero_razor",
            "npc_dota_hero_obsidian_destroyer",
            "npc_dota_hero_ogre_magi",
            "npc_dota_hero_slardar",
            "npc_dota_hero_venomancer",
        ],
    },
    npc_dota_hero_faceless_void: {
        synergy: [
            "npc_dota_hero_razor",
            "npc_dota_hero_viper",
            "npc_dota_hero_obsidian_destroyer",
            "npc_dota_hero_doom_bringer",
            "npc_dota_hero_necrolyte",
            "npc_dota_hero_bounty_hunter",
            "npc_dota_hero_nyx_assassin",
            "npc_dota_hero_abyssal_underlord",
            "npc_dota_hero_enchantress",
        ],
        counter: [
            "npc_dota_hero_weaver",
            "npc_dota_hero_windrunner",
            "npc_dota_hero_primal_beast",
            "npc_dota_hero_shredder",
            "npc_dota_hero_undying",
            "npc_dota_hero_magnataur",
            "npc_dota_hero_batrider",
            "npc_dota_hero_queenofpain",
            "npc_dota_hero_shadow_demon",
            "npc_dota_hero_zuus",
        ],
    },

    npc_dota_hero_furion: {
        synergy: [
            "npc_dota_hero_doom_bringer",
            "npc_dota_hero_enchantress",
            "npc_dota_hero_necrolyte",
            "npc_dota_hero_sand_king",
            "npc_dota_hero_death_prophet",
            "npc_dota_hero_obsidian_destroyer",
            "npc_dota_hero_night_stalker",
            "npc_dota_hero_earthshaker",
        ],
        counter: [
            "npc_dota_hero_life_stealer",
            "npc_dota_hero_keeper_of_the_light",
            "npc_dota_hero_windrunner",
            "npc_dota_hero_lone_druid",
            "npc_dota_hero_bloodseeker",
            "npc_dota_hero_leshrac",
            "npc_dota_hero_venomancer",
            "npc_dota_hero_visage",
            "npc_dota_hero_doom_bringer",
        ],
    },

    npc_dota_hero_grimstroke: {
        synergy: [
            "npc_dota_hero_visage",
            "npc_dota_hero_beastmaster",
            "npc_dota_hero_alchemist",
            "npc_dota_hero_batrider",
            "npc_dota_hero_meepo",
            "npc_dota_hero_lich",
            "npc_dota_hero_phantom_lancer",
            "npc_dota_hero_broodmother",
        ],
        counter: [
            "npc_dota_hero_shredder",
            "npc_dota_hero_primal_beast",
            "npc_dota_hero_omniknight",
            "npc_dota_hero_slark",
            "npc_dota_hero_necrolyte",
            "npc_dota_hero_broodmother",
            "npc_dota_hero_storm_spirit",
            "npc_dota_hero_faceless_void",
        ],
    },

    npc_dota_hero_gyrocopter: {
        synergy: [
            "npc_dota_hero_broodmother",
            "npc_dota_hero_riki",
            "npc_dota_hero_storm_spirit",
            "npc_dota_hero_beastmaster",
            "npc_dota_hero_primal_beast",
            "npc_dota_hero_lone_druid",
            "npc_dota_hero_oracle",
            "npc_dota_hero_treant",
        ],
        counter: [
            "npc_dota_hero_batrider",
            "npc_dota_hero_dazzle",
            "npc_dota_hero_undying",
            "npc_dota_hero_dawnbreaker",
            "npc_dota_hero_grimstroke",
            "npc_dota_hero_sven",
            "npc_dota_hero_enigma",
        ],
    },
    npc_dota_hero_huskar: {
        synergy: [
            "npc_dota_hero_beastmaster",
            "npc_dota_hero_troll_warlord",
            "npc_dota_hero_lycan",
            "npc_dota_hero_naga_siren",
            "npc_dota_hero_oracle",
            "npc_dota_hero_enigma",
            "npc_dota_hero_magnataur",
            "npc_dota_hero_phoenix",
            "npc_dota_hero_bristleback",
        ],
        counter: [
            "npc_dota_hero_anti-mage",
            "npc_dota_hero_void_spirit",
            "npc_dota_hero_ember_spirit",
            "npc_dota_hero_lone_druid",
            "npc_dota_hero_meepo",
            "npc_dota_hero_night_stalker",
            "npc_dota_hero_bounty_hunter",
            "npc_dota_hero_obsidian_destroyer",
            "npc_dota_hero_queenofpain",
        ],
    },

    npc_dota_hero_invoker: {
        synergy: [
            "npc_dota_hero_phantom_lancer",
            "npc_dota_hero_batrider",
            "npc_dota_hero_undying",
            "npc_dota_hero_faceless_void",
            "npc_dota_hero_life_stealer",
            "npc_dota_hero_skeleton_king",
            "npc_dota_hero_shredder",
            "npc_dota_hero_dark_seer",
            "npc_dota_hero_furion",
            "npc_dota_hero_anti-mage",
        ],
        counter: [
            "npc_dota_hero_medusa",
            "npc_dota_hero_viper",
            "npc_dota_hero_death_prophet",
            "npc_dota_hero_abyssal_underlord",
            "npc_dota_hero_visage",
            "npc_dota_hero_batrider",
            "npc_dota_hero_doom_bringer",
            "npc_dota_hero_muerta",
            "npc_dota_hero_naga_siren",
        ],
    },

    npc_dota_hero_jakiro: {
        synergy: [
            "npc_dota_hero_terrorblade",
            "npc_dota_hero_broodmother",
            "npc_dota_hero_meepo",
            "npc_dota_hero_marci",
            "npc_dota_hero_naga_siren",
            "npc_dota_hero_void_spirit",
            "npc_dota_hero_pudge",
            "npc_dota_hero_chaos_knight",
            "npc_dota_hero_earth_spirit",
            "npc_dota_hero_slark",
        ],
        counter: [
            "npc_dota_hero_naga_siren",
            "npc_dota_hero_meepo",
            "npc_dota_hero_broodmother",
            "npc_dota_hero_beastmaster",
            "npc_dota_hero_chaos_knight",
            "npc_dota_hero_dawnbreaker",
            "npc_dota_hero_visage",
            "npc_dota_hero_enigma",
            "npc_dota_hero_riki",
        ],
    },

    npc_dota_hero_juggernaut: {
        synergy: [
            "npc_dota_hero_bloodseeker",
            "npc_dota_hero_magnataur",
            "npc_dota_hero_ogre_magi",
            "npc_dota_hero_kunkka",
            "npc_dota_hero_gyrocopter",
            "npc_dota_hero_zuus",
            "npc_dota_hero_mirana",
            "npc_dota_hero_centaur",
            "npc_dota_hero_dark_seer",
            "npc_dota_hero_bounty_hunter",
        ],
        counter: [
            "npc_dota_hero_abyssal_underlord",
            "npc_dota_hero_bristleback",
            "npc_dota_hero_tidehunter",
            "npc_dota_hero_bloodseeker",
            "npc_dota_hero_kunkka",
            "npc_dota_hero_viper",
            "npc_dota_hero_dark_willow",
            "npc_dota_hero_phoenix",
            "npc_dota_hero_spectre",
        ],
    },

    npc_dota_hero_keeper_of_the_light: {
        synergy: [
            "npc_dota_hero_terrorblade",
            "npc_dota_hero_obsidian_destroyer",
            "npc_dota_hero_enchantress",
            "npc_dota_hero_visage",
            "npc_dota_hero_medusa",
            "npc_dota_hero_clinkz",
            "npc_dota_hero_void_spirit",
            "npc_dota_hero_razor",
            "npc_dota_hero_beastmaster",
            "npc_dota_hero_chaos_knight",
        ],
        counter: [
            "npc_dota_hero_dark_seer",
            "npc_dota_hero_warlock",
            "npc_dota_hero_abaddon",
            "npc_dota_hero_lone_druid",
            "npc_dota_hero_bloodseeker",
            "npc_dota_hero_arc_warden",
            "npc_dota_hero_troll_warlord",
            "npc_dota_hero_beastmaster",
            "npc_dota_hero_naga_siren",
        ],
    },

    npc_dota_hero_kunkka: {
        synergy: [
            "npc_dota_hero_dawnbreaker",
            "npc_dota_hero_necrolyte",
            "npc_dota_hero_beastmaster",
            "npc_dota_hero_shadow_demon",
            "npc_dota_hero_lycan",
            "npc_dota_hero_slark",
            "npc_dota_hero_huskar",
            "npc_dota_hero_sven",
            "npc_dota_hero_bristleback",
        ],
        counter: [
            "npc_dota_hero_naga_siren",
            "npc_dota_hero_medusa",
            "npc_dota_hero_meepo",
            "npc_dota_hero_arc_warden",
            "npc_dota_hero_marci",
            "npc_dota_hero_lone_druid",
            "npc_dota_hero_grimstroke",
            "npc_dota_hero_chaos_knight",
            "npc_dota_hero_dark_seer",
        ],
    },
    npc_dota_hero_legion_commander: {
        synergy: [
            "npc_dota_hero_omniknight",
            "npc_dota_hero_bristleback",
            "npc_dota_hero_shredder",
            "npc_dota_hero_troll_warlord",
            "npc_dota_hero_dawnbreaker",
            "npc_dota_hero_undying",
            "npc_dota_hero_leshrac",
            "npc_dota_hero_necrolyte",
            "npc_dota_hero_broodmother",
            "npc_dota_hero_snapfire",
        ],
        counter: [
            "npc_dota_hero_bristleback",
            "npc_dota_hero_meepo",
            "npc_dota_hero_arc_warden",
            "npc_dota_hero_phantom_lancer",
            "npc_dota_hero_anti-mage",
            "npc_dota_hero_faceless_void",
            "npc_dota_hero_bounty_hunter",
            "npc_dota_hero_weaver",
            "npc_dota_hero_venomancer",
            "npc_dota_hero_huskar",
        ],
    },

    npc_dota_hero_leshrac: {
        synergy: [
            "npc_dota_hero_enigma",
            "npc_dota_hero_magnataur",
            "npc_dota_hero_bane",
            "npc_dota_hero_treant",
            "npc_dota_hero_ancient_apparition",
            "npc_dota_hero_mirana",
            "npc_dota_hero_sven",
            "npc_dota_hero_beastmaster",
        ],
        counter: [
            "npc_dota_hero_meepo",
            "npc_dota_hero_necrolyte",
            "npc_dota_hero_phantom_lancer",
            "npc_dota_hero_naga_siren",
            "npc_dota_hero_omniknight",
            "npc_dota_hero_riki",
            "npc_dota_hero_axe",
            "npc_dota_hero_arc_warden",
            "npc_dota_hero_tidehunter",
        ],
    },

    npc_dota_hero_lich: {
        synergy: [
            "npc_dota_hero_lone_druid",
            "npc_dota_hero_huskar",
            "npc_dota_hero_naga_siren",
            "npc_dota_hero_grimstroke",
            "npc_dota_hero_beastmaster",
            "npc_dota_hero_lycan",
            "npc_dota_hero_pudge",
            "npc_dota_hero_visage",
            "npc_dota_hero_spirit_breaker",
            "npc_dota_hero_slark",
        ],
        counter: [
            "npc_dota_hero_muerta",
            "npc_dota_hero_medusa",
            "npc_dota_hero_terrorblade",
            "npc_dota_hero_naga_siren",
            "npc_dota_hero_chaos_knight",
            "npc_dota_hero_monkey_king",
            "npc_dota_hero_marci",
            "npc_dota_hero_arc_warden",
            "npc_dota_hero_tidehunter",
        ],
    },

    npc_dota_hero_life_stealer: {
        synergy: [
            "npc_dota_hero_batrider",
            "npc_dota_hero_phoenix",
            "npc_dota_hero_axe",
            "npc_dota_hero_primal_beast",
            "npc_dota_hero_dark_willow",
            "npc_dota_hero_invoker",
            "npc_dota_hero_earth_spirit",
            "npc_dota_hero_gyrocopter",
        ],
        counter: [
            "npc_dota_hero_centaur",
            "npc_dota_hero_tiny",
            "npc_dota_hero_skeleton_king",
            "npc_dota_hero_abyssal_underlord",
            "npc_dota_hero_spectre",
            "npc_dota_hero_phoenix",
            "npc_dota_hero_mars",
            "npc_dota_hero_kunkka",
            "npc_dota_hero_snapfire",
            "npc_dota_hero_sand_king",
        ],
    },

    npc_dota_hero_lina: {
        synergy: [
            "npc_dota_hero_naga_siren",
            "npc_dota_hero_meepo",
            "npc_dota_hero_storm_spirit",
            "npc_dota_hero_riki",
            "npc_dota_hero_void_spirit",
            "npc_dota_hero_warlock",
            "npc_dota_hero_faceless_void",
            "npc_dota_hero_undying",
        ],
        counter: [
            "npc_dota_hero_naga_siren",
            "npc_dota_hero_lone_druid",
            "npc_dota_hero_phoenix",
            "npc_dota_hero_huskar",
            "npc_dota_hero_bloodseeker",
            "npc_dota_hero_meepo",
            "npc_dota_hero_troll_warlord",
            "npc_dota_hero_dawnbreaker",
            "npc_dota_hero_visage",
        ],
    },

    npc_dota_hero_lion: {
        synergy: [
            "npc_dota_hero_lycan",
            "npc_dota_hero_meepo",
            "npc_dota_hero_naga_siren",
            "npc_dota_hero_grimstroke",
            "npc_dota_hero_visage",
            "npc_dota_hero_dark_seer",
            "npc_dota_hero_lone_druid",
            "npc_dota_hero_shredder",
            "npc_dota_hero_silencer",
        ],
        counter: [
            "npc_dota_hero_naga_siren",
            "npc_dota_hero_batrider",
            "npc_dota_hero_troll_warlord",
            "npc_dota_hero_legion_commander",
            "npc_dota_hero_slark",
            "npc_dota_hero_terrorblade",
            "npc_dota_hero_meepo",
            "npc_dota_hero_faceless_void",
            "npc_dota_hero_phoenix",
        ],
    },
    npc_dota_hero_luna: {
        synergy: [
            "npc_dota_hero_visage",
            "npc_dota_hero_riki",
            "npc_dota_hero_broodmother",
            "npc_dota_hero_night_stalker",
            "npc_dota_hero_omniknight",
            "npc_dota_hero_mars",
            "npc_dota_hero_void_spirit",
            "npc_dota_hero_primal_beast",
            "npc_dota_hero_oracle",
        ],
        counter: ["npc_dota_hero_night_stalker", "npc_dota_hero_slardar", "npc_dota_hero_undying", "npc_dota_hero_lycan", "npc_dota_hero_sven", "npc_dota_hero_weaver"],
    },

    npc_dota_hero_lycan: {
        synergy: [
            "npc_dota_hero_batrider",
            "npc_dota_hero_death_prophet",
            "npc_dota_hero_magnataur",
            "npc_dota_hero_nevermore",
            "npc_dota_hero_huskar",
            "npc_dota_hero_bristleback",
            "npc_dota_hero_lion",
            "npc_dota_hero_troll_warlord",
        ],
        counter: [
            "npc_dota_hero_beastmaster",
            "npc_dota_hero_night_stalker",
            "npc_dota_hero_death_prophet",
            "npc_dota_hero_skywrath_mage",
            "npc_dota_hero_silencer",
            "npc_dota_hero_arc_warden",
            "npc_dota_hero_ancient_apparition",
            "npc_dota_hero_viper",
            "npc_dota_hero_warlock",
        ],
    },

    npc_dota_hero_magnataur: {
        synergy: [
            "npc_dota_hero_beastmaster",
            "npc_dota_hero_leshrac",
            "npc_dota_hero_lycan",
            "npc_dota_hero_slardar",
            "npc_dota_hero_huskar",
            "npc_dota_hero_sand_king",
            "npc_dota_hero_broodmother",
            "npc_dota_hero_viper",
        ],
        counter: [
            "npc_dota_hero_shadow_demon",
            "npc_dota_hero_marci",
            "npc_dota_hero_beastmaster",
            "npc_dota_hero_naga_siren",
            "npc_dota_hero_drow_ranger",
            "npc_dota_hero_lycan",
            "npc_dota_hero_pudge",
            "npc_dota_hero_bounty_hunter",
        ],
    },
    npc_dota_hero_mars: {
        synergy: [
            "npc_dota_hero_lone_druid",
            "npc_dota_hero_dawnbreaker",
            "npc_dota_hero_slardar",
            "npc_dota_hero_night_stalker",
            "npc_dota_hero_tidehunter",
            "npc_dota_hero_dragon_knight",
            "npc_dota_hero_broodmother",
            "npc_dota_hero_arc_warden",
        ],
        counter: [
            "npc_dota_hero_drow_ranger",
            "npc_dota_hero_slark",
            "npc_dota_hero_beastmaster",
            "npc_dota_hero_sniper",
            "npc_dota_hero_naga_siren",
            "npc_dota_hero_enchantress",
            "npc_dota_hero_death_prophet",
            "npc_dota_hero_mirana",
            "npc_dota_hero_windrunner",
            "npc_dota_hero_magnataur",
        ],
    },

    npc_dota_hero_medusa: {
        synergy: [
            "npc_dota_hero_naga_siren",
            "npc_dota_hero_meepo",
            "npc_dota_hero_bloodseeker",
            "npc_dota_hero_riki",
            "npc_dota_hero_batrider",
            "npc_dota_hero_spectre",
            "npc_dota_hero_chaos_knight",
            "npc_dota_hero_void_spirit",
            "npc_dota_hero_keeper_of_the_light",
        ],
        counter: [
            "npc_dota_hero_beastmaster",
            "npc_dota_hero_meepo",
            "npc_dota_hero_visage",
            "npc_dota_hero_naga_siren",
            "npc_dota_hero_undying",
            "npc_dota_hero_death_prophet",
            "npc_dota_hero_chaos_knight",
            "npc_dota_hero_queenofpain",
            "npc_dota_hero_dawnbreaker",
            "npc_dota_hero_obsidian_destroyer",
        ],
    },

    npc_dota_hero_meepo: {
        synergy: [
            "npc_dota_hero_visage",
            "npc_dota_hero_monkey_king",
            "npc_dota_hero_doom_bringer",
            "npc_dota_hero_winter_wyvern",
            "npc_dota_hero_medusa",
            "npc_dota_hero_terrorblade",
            "npc_dota_hero_dark_willow",
            "npc_dota_hero_batrider",
        ],
        counter: [
            "npc_dota_hero_arc_warden",
            "npc_dota_hero_void_spirit",
            "npc_dota_hero_anti-mage",
            "npc_dota_hero_phantom_lancer",
            "npc_dota_hero_storm_spirit",
            "npc_dota_hero_faceless_void",
            "npc_dota_hero_clinkz",
            "npc_dota_hero_mirana",
            "npc_dota_hero_doom_bringer",
        ],
    },

    npc_dota_hero_mirana: {
        synergy: [
            "npc_dota_hero_meepo",
            "npc_dota_hero_leshrac",
            "npc_dota_hero_viper",
            "npc_dota_hero_axe",
            "npc_dota_hero_obsidian_destroyer",
            "npc_dota_hero_ember_spirit",
            "npc_dota_hero_medusa",
            "npc_dota_hero_alchemist",
            "npc_dota_hero_dragon_knight",
        ],
        counter: [
            "npc_dota_hero_beastmaster",
            "npc_dota_hero_medusa",
            "npc_dota_hero_death_prophet",
            "npc_dota_hero_visage",
            "npc_dota_hero_keeper_of_the_light",
            "npc_dota_hero_phoenix",
            "npc_dota_hero_razor",
            "npc_dota_hero_weaver",
            "npc_dota_hero_broodmother",
        ],
    },

    npc_dota_hero_morphling: {
        synergy: [
            "npc_dota_hero_spectre",
            "npc_dota_hero_bloodseeker",
            "npc_dota_hero_clinkz",
            "npc_dota_hero_gyrocopter",
            "npc_dota_hero_death_prophet",
            "npc_dota_hero_naga_siren",
            "npc_dota_hero_visage",
            "npc_dota_hero_leshrac",
            "npc_dota_hero_doom_bringer",
        ],
        counter: [
            "npc_dota_hero_terrorblade",
            "npc_dota_hero_visage",
            "npc_dota_hero_sniper",
            "npc_dota_hero_viper",
            "npc_dota_hero_enigma",
            "npc_dota_hero_juggernaut",
            "npc_dota_hero_bloodseeker",
            "npc_dota_hero_furion",
        ],
    },

    npc_dota_hero_monkey_king: {
        synergy: [
            "npc_dota_hero_meepo",
            "npc_dota_hero_alchemist",
            "npc_dota_hero_batrider",
            "npc_dota_hero_treant",
            "npc_dota_hero_oracle",
            "npc_dota_hero_abaddon",
            "npc_dota_hero_beastmaster",
            "npc_dota_hero_shadow_demon",
        ],
        counter: [
            "npc_dota_hero_lone_druid",
            "npc_dota_hero_meepo",
            "npc_dota_hero_naga_siren",
            "npc_dota_hero_broodmother",
            "npc_dota_hero_ember_spirit",
            "npc_dota_hero_visage",
            "npc_dota_hero_abaddon",
            "npc_dota_hero_medusa",
        ],
    },

    npc_dota_hero_muerta: {
        synergy: [
            "npc_dota_hero_tidehunter",
            "npc_dota_hero_necrolyte",
            "npc_dota_hero_marci",
            "npc_dota_hero_grimstroke",
            "npc_dota_hero_death_prophet",
            "npc_dota_hero_phoenix",
            "npc_dota_hero_visage",
            "npc_dota_hero_slark",
        ],
        counter: [
            "npc_dota_hero_kunkka",
            "npc_dota_hero_enchantress",
            "npc_dota_hero_keeper_of_the_light",
            "npc_dota_hero_medusa",
            "npc_dota_hero_lina",
            "npc_dota_hero_void_spirit",
            "npc_dota_hero_spectre",
            "npc_dota_hero_naga_siren",
            "npc_dota_hero_skywrath_mage",
        ],
    },

    npc_dota_hero_naga_siren: {
        synergy: [
            "npc_dota_hero_nyx_assassin",
            "npc_dota_hero_bristleback",
            "npc_dota_hero_earth_spirit",
            "npc_dota_hero_lina",
            "npc_dota_hero_techies",
            "npc_dota_hero_medusa",
            "npc_dota_hero_earthshaker",
            "npc_dota_hero_winter_wyvern",
            "npc_dota_hero_jakiro",
        ],
        counter: [
            "npc_dota_hero_lycan",
            "npc_dota_hero_night_stalker",
            "npc_dota_hero_chaos_knight",
            "npc_dota_hero_broodmother",
            "npc_dota_hero_viper",
            "npc_dota_hero_clinkz",
            "npc_dota_hero_ancient_apparition",
            "npc_dota_hero_faceless_void",
        ],
    },

    npc_dota_hero_necrolyte: {
        synergy: [
            "npc_dota_hero_riki",
            "npc_dota_hero_kunkka",
            "npc_dota_hero_mars",
            "npc_dota_hero_omniknight",
            "npc_dota_hero_furion",
            "npc_dota_hero_enigma",
            "npc_dota_hero_night_stalker",
            "npc_dota_hero_spirit_breaker",
            "npc_dota_hero_dawnbreaker",
        ],
        counter: [
            "npc_dota_hero_phantom_lancer",
            "npc_dota_hero_huskar",
            "npc_dota_hero_spectre",
            "npc_dota_hero_tiny",
            "npc_dota_hero_tidehunter",
            "npc_dota_hero_axe",
            "npc_dota_hero_spirit_breaker",
            "npc_dota_hero_naga_siren",
            "npc_dota_hero_omniknight",
            "npc_dota_hero_zuus",
        ],
    },

    npc_dota_hero_nevermore: {
        synergy: [
            "npc_dota_hero_marci",
            "npc_dota_hero_lycan",
            "npc_dota_hero_bane",
            "npc_dota_hero_skeleton_king",
            "npc_dota_hero_shadow_shaman",
            "npc_dota_hero_night_stalker",
            "npc_dota_hero_dazzle",
            "npc_dota_hero_phantom_assassin",
        ],
        counter: [
            "npc_dota_hero_meepo",
            "npc_dota_hero_necrolyte",
            "npc_dota_hero_oracle",
            "npc_dota_hero_ember_spirit",
            "npc_dota_hero_anti-mage",
            "npc_dota_hero_huskar",
            "npc_dota_hero_slark",
            "npc_dota_hero_lone_druid",
            "npc_dota_hero_beastmaster",
        ],
    },

    npc_dota_hero_night_stalker: {
        synergy: [
            "npc_dota_hero_dawnbreaker",
            "npc_dota_hero_beastmaster",
            "npc_dota_hero_primal_beast",
            "npc_dota_hero_earthshaker",
            "npc_dota_hero_luna",
            "npc_dota_hero_mars",
            "npc_dota_hero_sand_king",
            "npc_dota_hero_winter_wyvern",
            "npc_dota_hero_dragon_knight",
        ],
        counter: [
            "npc_dota_hero_juggernaut",
            "npc_dota_hero_shredder",
            "npc_dota_hero_storm_spirit",
            "npc_dota_hero_queenofpain",
            "npc_dota_hero_earth_spirit",
            "npc_dota_hero_void_spirit",
            "npc_dota_hero_drow_ranger",
        ],
    },

    npc_dota_hero_nyx_assassin: {
        synergy: [
            "npc_dota_hero_naga_siren",
            "npc_dota_hero_enchantress",
            "npc_dota_hero_tidehunter",
            "npc_dota_hero_medusa",
            "npc_dota_hero_faceless_void",
            "npc_dota_hero_sniper",
            "npc_dota_hero_dark_seer",
            "npc_dota_hero_beastmaster",
            "npc_dota_hero_sven",
            "npc_dota_hero_warlock",
        ],
        counter: [
            "npc_dota_hero_medusa",
            "npc_dota_hero_muerta",
            "npc_dota_hero_weaver",
            "npc_dota_hero_enigma",
            "npc_dota_hero_sniper",
            "npc_dota_hero_storm_spirit",
            "npc_dota_hero_dawnbreaker",
            "npc_dota_hero_shredder",
        ],
    },

    npc_dota_hero_obsidian_destroyer: {
        synergy: [
            "npc_dota_hero_abyssal_underlord",
            "npc_dota_hero_keeper_of_the_light",
            "npc_dota_hero_faceless_void",
            "npc_dota_hero_primal_beast",
            "npc_dota_hero_treant",
            "npc_dota_hero_razor",
            "npc_dota_hero_mirana",
            "npc_dota_hero_rattletrap",
            "npc_dota_hero_alchemist",
        ],
        counter: [
            "npc_dota_hero_shredder",
            "npc_dota_hero_axe",
            "npc_dota_hero_abaddon",
            "npc_dota_hero_leshrac",
            "npc_dota_hero_troll_warlord",
            "npc_dota_hero_omniknight",
            "npc_dota_hero_oracle",
            "npc_dota_hero_faceless_void",
            "npc_dota_hero_winter_wyvern",
            "npc_dota_hero_slark",
        ],
    },

    npc_dota_hero_ogre_magi: {
        synergy: [
            "npc_dota_hero_keeper_of_the_light",
            "npc_dota_hero_sniper",
            "npc_dota_hero_warlock",
            "npc_dota_hero_medusa",
            "npc_dota_hero_juggernaut",
            "npc_dota_hero_troll_warlord",
            "npc_dota_hero_sven",
            "npc_dota_hero_tiny",
        ],
        counter: [
            "npc_dota_hero_ursa",
            "npc_dota_hero_troll_warlord",
            "npc_dota_hero_medusa",
            "npc_dota_hero_batrider",
            "npc_dota_hero_windrunner",
            "npc_dota_hero_phantom_assassin",
            "npc_dota_hero_night_stalker",
            "npc_dota_hero_keeper_of_the_light",
            "npc_dota_hero_bane",
        ],
    },

    npc_dota_hero_omniknight: {
        synergy: [
            "npc_dota_hero_bristleback",
            "npc_dota_hero_abyssal_underlord",
            "npc_dota_hero_visage",
            "npc_dota_hero_shredder",
            "npc_dota_hero_muerta",
            "npc_dota_hero_legion_commander",
            "npc_dota_hero_bloodseeker",
            "npc_dota_hero_primal_beast",
        ],
        counter: [
            "npc_dota_hero_legion_commander",
            "npc_dota_hero_meepo",
            "npc_dota_hero_slark",
            "npc_dota_hero_keeper_of_the_light",
            "npc_dota_hero_abyssal_underlord",
            "npc_dota_hero_naga_siren",
            "npc_dota_hero_dazzle",
            "npc_dota_hero_abaddon",
            "npc_dota_hero_ursa",
        ],
    },

    npc_dota_hero_oracle: {
        synergy: [
            "npc_dota_hero_visage",
            "npc_dota_hero_huskar",
            "npc_dota_hero_windrunner",
            "npc_dota_hero_sand_king",
            "npc_dota_hero_rubick",
            "npc_dota_hero_gyrocopter",
            "npc_dota_hero_luna",
        ],
        counter: [
            "npc_dota_hero_legion_commander",
            "npc_dota_hero_skywrath_mage",
            "npc_dota_hero_centaur",
            "npc_dota_hero_necrolyte",
            "npc_dota_hero_bloodseeker",
            "npc_dota_hero_dark_seer",
            "npc_dota_hero_troll_warlord",
            "npc_dota_hero_storm_spirit",
        ],
    },

    npc_dota_hero_pangolier: {
        synergy: [
            "npc_dota_hero_beastmaster",
            "npc_dota_hero_meepo",
            "npc_dota_hero_razor",
            "npc_dota_hero_oracle",
            "npc_dota_hero_lycan",
            "npc_dota_hero_luna",
            "npc_dota_hero_phantom_lancer",
        ],
        counter: [
            "npc_dota_hero_life_stealer",
            "npc_dota_hero_dawnbreaker",
            "npc_dota_hero_enigma",
            "npc_dota_hero_oracle",
            "npc_dota_hero_leshrac",
            "npc_dota_hero_chaos_knight",
            "npc_dota_hero_arc_warden",
            "npc_dota_hero_pugna",
            "npc_dota_hero_earth_spirit",
        ],
    },

    npc_dota_hero_phantom_lancer: {
        synergy: [
            "npc_dota_hero_grimstroke",
            "npc_dota_hero_kunkka",
            "npc_dota_hero_invoker",
            "npc_dota_hero_lone_druid",
            "npc_dota_hero_skywrath_mage",
            "npc_dota_hero_bane",
            "npc_dota_hero_arc_warden",
            "npc_dota_hero_keeper_of_the_light",
            "npc_dota_hero_witch_doctor",
        ],
        counter: [
            "npc_dota_hero_viper",
            "npc_dota_hero_templar_assassin",
            "npc_dota_hero_arc_warden",
            "npc_dota_hero_obsidian_destroyer",
            "npc_dota_hero_dragon_knight",
            "npc_dota_hero_ogre_magi",
            "npc_dota_hero_chaos_knight",
            "npc_dota_hero_skeleton_king",
            "npc_dota_hero_shadow_shaman",
            "npc_dota_hero_slardar",
        ],
    },
    npc_dota_hero_phantom_assassin: {
        synergy: [
            "npc_dota_hero_arc_warden",
            "npc_dota_hero_bristleback",
            "npc_dota_hero_enchantress",
            "npc_dota_hero_death_prophet",
            "npc_dota_hero_nevermore",
            "npc_dota_hero_slark",
            "npc_dota_hero_broodmother",
            "npc_dota_hero_magnataur",
            "npc_dota_hero_techies",
            "npc_dota_hero_tidehunter",
        ],
        counter: [
            "npc_dota_hero_lone_druid",
            "npc_dota_hero_anti-mage",
            "npc_dota_hero_broodmother",
            "npc_dota_hero_keeper_of_the_light",
            "npc_dota_hero_visage",
            "npc_dota_hero_huskar",
            "npc_dota_hero_life_stealer",
            "npc_dota_hero_enchantress",
            "npc_dota_hero_furion",
            "npc_dota_hero_lina",
        ],
    },

    npc_dota_hero_phoenix: {
        synergy: [
            "npc_dota_hero_broodmother",
            "npc_dota_hero_lone_druid",
            "npc_dota_hero_beastmaster",
            "npc_dota_hero_terrorblade",
            "npc_dota_hero_enigma",
            "npc_dota_hero_marci",
            "npc_dota_hero_huskar",
        ],
        counter: [
            "npc_dota_hero_chaos_knight",
            "npc_dota_hero_lone_druid",
            "npc_dota_hero_skeleton_king",
            "npc_dota_hero_lycan",
            "npc_dota_hero_treant",
            "npc_dota_hero_sven",
            "npc_dota_hero_templar_assassin",
            "npc_dota_hero_broodmother",
            "npc_dota_hero_tiny",
        ],
    },

    npc_dota_hero_puck: {
        synergy: [
            "npc_dota_hero_terrorblade",
            "npc_dota_hero_snapfire",
            "npc_dota_hero_life_stealer",
            "npc_dota_hero_gyrocopter",
            "npc_dota_hero_bounty_hunter",
            "npc_dota_hero_ursa",
        ],
        counter: [
            "npc_dota_hero_phantom_lancer",
            "npc_dota_hero_enchantress",
            "npc_dota_hero_terrorblade",
            "npc_dota_hero_mars",
            "npc_dota_hero_storm_spirit",
            "npc_dota_hero_dark_seer",
            "npc_dota_hero_dawnbreaker",
        ],
    },

    npc_dota_hero_pudge: {
        synergy: [
            "npc_dota_hero_pugna",
            "npc_dota_hero_enigma",
            "npc_dota_hero_abyssal_underlord",
            "npc_dota_hero_silencer",
            "npc_dota_hero_ancient_apparition",
            "npc_dota_hero_winter_wyvern",
            "npc_dota_hero_muerta",
            "npc_dota_hero_treant",
            "npc_dota_hero_jakiro",
            "npc_dota_hero_dark_willow",
        ],
        counter: [
            "npc_dota_hero_spectre",
            "npc_dota_hero_necrolyte",
            "npc_dota_hero_phantom_assassin",
            "npc_dota_hero_muerta",
            "npc_dota_hero_axe",
            "npc_dota_hero_sniper",
            "npc_dota_hero_naga_siren",
            "npc_dota_hero_pugna",
            "npc_dota_hero_phantom_lancer",
            "npc_dota_hero_crystal_maiden",
        ],
    },

    npc_dota_hero_pugna: {
        synergy: [
            "npc_dota_hero_visage",
            "npc_dota_hero_bloodseeker",
            "npc_dota_hero_ember_spirit",
            "npc_dota_hero_winter_wyvern",
            "npc_dota_hero_pudge",
            "npc_dota_hero_axe",
            "npc_dota_hero_abyssal_underlord",
            "npc_dota_hero_alchemist",
            "npc_dota_hero_spirit_breaker",
            "npc_dota_hero_furion",
        ],
        counter: [
            "npc_dota_hero_shredder",
            "npc_dota_hero_storm_spirit",
            "npc_dota_hero_omniknight",
            "npc_dota_hero_necrolyte",
            "npc_dota_hero_grimstroke",
            "npc_dota_hero_winter_wyvern",
            "npc_dota_hero_queenofpain",
            "npc_dota_hero_bane",
        ],
    },

    npc_dota_hero_queenofpain: {
        synergy: [
            "npc_dota_hero_alchemist",
            "npc_dota_hero_muerta",
            "npc_dota_hero_mars",
            "npc_dota_hero_ember_spirit",
            "npc_dota_hero_enigma",
            "npc_dota_hero_nyx_assassin",
            "npc_dota_hero_abyssal_underlord",
            "npc_dota_hero_doom_bringer",
            "npc_dota_hero_death_prophet",
            "npc_dota_hero_life_stealer",
        ],
        counter: [
            "npc_dota_hero_razor",
            "npc_dota_hero_keeper_of_the_light",
            "npc_dota_hero_monkey_king",
            "npc_dota_hero_rattletrap",
            "npc_dota_hero_dark_seer",
            "npc_dota_hero_shadow_demon",
            "npc_dota_hero_alchemist",
            "npc_dota_hero_beastmaster",
            "npc_dota_hero_leshrac",
        ],
    },

    npc_dota_hero_rattletrap: {
        synergy: [
            "npc_dota_hero_beastmaster",
            "npc_dota_hero_bloodseeker",
            "npc_dota_hero_naga_siren",
            "npc_dota_hero_winter_wyvern",
            "npc_dota_hero_dark_seer",
            "npc_dota_hero_broodmother",
            "npc_dota_hero_obsidian_destroyer",
            "npc_dota_hero_huskar",
            "npc_dota_hero_keeper_of_the_light",
        ],
        counter: [
            "npc_dota_hero_slark",
            "npc_dota_hero_sniper",
            "npc_dota_hero_razor",
            "npc_dota_hero_spirit_breaker",
            "npc_dota_hero_drow_ranger",
            "npc_dota_hero_windrunner",
            "npc_dota_hero_treant",
            "npc_dota_hero_crystal_maiden",
            "npc_dota_hero_medusa",
        ],
    },
    npc_dota_hero_razor: {
        synergy: [
            "npc_dota_hero_faceless_void",
            "npc_dota_hero_dawnbreaker",
            "npc_dota_hero_bloodseeker",
            "npc_dota_hero_keeper_of_the_light",
            "npc_dota_hero_obsidian_destroyer",
            "npc_dota_hero_spirit_breaker",
            "npc_dota_hero_abyssal_underlord",
        ],
        counter: [
            "npc_dota_hero_troll_warlord",
            "npc_dota_hero_tidehunter",
            "npc_dota_hero_dazzle",
            "npc_dota_hero_life_stealer",
            "npc_dota_hero_death_prophet",
            "npc_dota_hero_lion",
            "npc_dota_hero_shadow_demon",
            "npc_dota_hero_grimstroke",
            "npc_dota_hero_abaddon",
        ],
    },

    npc_dota_hero_riki: {
        synergy: [
            "npc_dota_hero_silencer",
            "npc_dota_hero_luna",
            "npc_dota_hero_necrolyte",
            "npc_dota_hero_medusa",
            "npc_dota_hero_meepo",
            "npc_dota_hero_warlock",
            "npc_dota_hero_terrorblade",
            "npc_dota_hero_muerta",
            "npc_dota_hero_bristleback",
        ],
        counter: [
            "npc_dota_hero_storm_spirit",
            "npc_dota_hero_clinkz",
            "npc_dota_hero_witch_doctor",
            "npc_dota_hero_ursa",
            "npc_dota_hero_queenofpain",
            "npc_dota_hero_oracle",
            "npc_dota_hero_juggernaut",
        ],
    },

    npc_dota_hero_rubick: {
        synergy: [
            "npc_dota_hero_oracle",
            "npc_dota_hero_naga_siren",
            "npc_dota_hero_beastmaster",
            "npc_dota_hero_life_stealer",
            "npc_dota_hero_broodmother",
            "npc_dota_hero_keeper_of_the_light",
            "npc_dota_hero_visage",
        ],
        counter: [
            "npc_dota_hero_abyssal_underlord",
            "npc_dota_hero_enigma",
            "npc_dota_hero_jakiro",
            "npc_dota_hero_obsidian_destroyer",
            "npc_dota_hero_beastmaster",
            "npc_dota_hero_crystal_maiden",
            "npc_dota_hero_weaver",
            "npc_dota_hero_medusa",
            "npc_dota_hero_phantom_lancer",
            "npc_dota_hero_skeleton_king",
        ],
    },

    npc_dota_hero_sand_king: {
        synergy: [
            "npc_dota_hero_omniknight",
            "npc_dota_hero_abaddon",
            "npc_dota_hero_doom_bringer",
            "npc_dota_hero_slardar",
            "npc_dota_hero_dark_seer",
            "npc_dota_hero_chaos_knight",
            "npc_dota_hero_night_stalker",
            "npc_dota_hero_oracle",
            "npc_dota_hero_magnataur",
        ],
        counter: [
            "npc_dota_hero_naga_siren",
            "npc_dota_hero_phantom_lancer",
            "npc_dota_hero_chaos_knight",
            "npc_dota_hero_dark_seer",
            "npc_dota_hero_meepo",
            "npc_dota_hero_shadow_demon",
            "npc_dota_hero_medusa",
            "npc_dota_hero_primal_beast",
            "npc_dota_hero_lone_druid",
            "npc_dota_hero_skeleton_king",
        ],
    },

    npc_dota_hero_shadow_demon: {
        synergy: [
            "npc_dota_hero_terrorblade",
            "npc_dota_hero_visage",
            "npc_dota_hero_lone_druid",
            "npc_dota_hero_dark_seer",
            "npc_dota_hero_bloodseeker",
            "npc_dota_hero_dark_willow",
        ],
        counter: [
            "npc_dota_hero_oracle",
            "npc_dota_hero_abaddon",
            "npc_dota_hero_arc_warden",
            "npc_dota_hero_huskar",
            "npc_dota_hero_muerta",
            "npc_dota_hero_obsidian_destroyer",
            "npc_dota_hero_omniknight",
        ],
    },

    npc_dota_hero_shadow_shaman: {
        synergy: [
            "npc_dota_hero_keeper_of_the_light",
            "npc_dota_hero_beastmaster",
            "npc_dota_hero_enigma",
            "npc_dota_hero_tidehunter",
            "npc_dota_hero_medusa",
            "npc_dota_hero_earth_spirit",
            "npc_dota_hero_skywrath_mage",
            "npc_dota_hero_treant",
        ],
        counter: [
            "npc_dota_hero_death_prophet",
            "npc_dota_hero_storm_spirit",
            "npc_dota_hero_lycan",
            "npc_dota_hero_ursa",
            "npc_dota_hero_bloodseeker",
            "npc_dota_hero_clinkz",
            "npc_dota_hero_faceless_void",
            "npc_dota_hero_earth_spirit",
            "npc_dota_hero_oracle",
        ],
    },

    npc_dota_hero_shredder: {
        synergy: [
            "npc_dota_hero_tidehunter",
            "npc_dota_hero_lone_druid",
            "npc_dota_hero_omniknight",
            "npc_dota_hero_legion_commander",
            "npc_dota_hero_visage",
            "npc_dota_hero_dawnbreaker",
            "npc_dota_hero_spirit_breaker",
            "npc_dota_hero_dark_seer",
            "npc_dota_hero_abaddon",
        ],
        counter: [
            "npc_dota_hero_phantom_lancer",
            "npc_dota_hero_meepo",
            "npc_dota_hero_naga_siren",
            "npc_dota_hero_huskar",
            "npc_dota_hero_chaos_knight",
            "npc_dota_hero_axe",
            "npc_dota_hero_terrorblade",
            "npc_dota_hero_shadow_demon",
            "npc_dota_hero_treant",
            "npc_dota_hero_techies",
        ],
    },
    npc_dota_hero_silencer: {
        synergy: [
            "npc_dota_hero_riki",
            "npc_dota_hero_earth_spirit",
            "npc_dota_hero_pudge",
            "npc_dota_hero_shadow_shaman",
            "npc_dota_hero_crystal_maiden",
            "npc_dota_hero_rattletrap",
            "npc_dota_hero_death_prophet",
            "npc_dota_hero_magnataur",
            "npc_dota_hero_enigma",
            "npc_dota_hero_lion",
        ],
        counter: [
            "npc_dota_hero_leshrac",
            "npc_dota_hero_shredder",
            "npc_dota_hero_shadow_shaman",
            "npc_dota_hero_storm_spirit",
            "npc_dota_hero_death_prophet",
            "npc_dota_hero_bane",
            "npc_dota_hero_bristleback",
            "npc_dota_hero_obsidian_destroyer",
            "npc_dota_hero_dawnbreaker",
        ],
    },

    npc_dota_hero_skeleton_king: {
        synergy: [
            "npc_dota_hero_arc_warden",
            "npc_dota_hero_enigma",
            "npc_dota_hero_bloodseeker",
            "npc_dota_hero_huskar",
            "npc_dota_hero_earth_spirit",
            "npc_dota_hero_bristleback",
            "npc_dota_hero_kunkka",
            "npc_dota_hero_nevermore",
            "npc_dota_hero_beastmaster",
        ],
        counter: [
            "npc_dota_hero_silencer",
            "npc_dota_hero_riki",
            "npc_dota_hero_enigma",
            "npc_dota_hero_huskar",
            "npc_dota_hero_skywrath_mage",
            "npc_dota_hero_muerta",
            "npc_dota_hero_legion_commander",
            "npc_dota_hero_axe",
            "npc_dota_hero_doom_bringer",
        ],
    },

    npc_dota_hero_skywrath_mage: {
        synergy: [
            "npc_dota_hero_terrorblade",
            "npc_dota_hero_broodmother",
            "npc_dota_hero_troll_warlord",
            "npc_dota_hero_beastmaster",
            "npc_dota_hero_phantom_lancer",
            "npc_dota_hero_visage",
            "npc_dota_hero_arc_warden",
            "npc_dota_hero_medusa",
        ],
        counter: [
            "npc_dota_hero_phoenix",
            "npc_dota_hero_necrolyte",
            "npc_dota_hero_muerta",
            "npc_dota_hero_sand_king",
            "npc_dota_hero_storm_spirit",
            "npc_dota_hero_terrorblade",
            "npc_dota_hero_leshrac",
            "npc_dota_hero_juggernaut",
            "npc_dota_hero_shredder",
        ],
    },

    npc_dota_hero_slardar: {
        synergy: [
            "npc_dota_hero_dawnbreaker",
            "npc_dota_hero_mars",
            "npc_dota_hero_bristleback",
            "npc_dota_hero_alchemist",
            "npc_dota_hero_sand_king",
            "npc_dota_hero_muerta",
            "npc_dota_hero_chaos_knight",
            "npc_dota_hero_lone_druid",
            "npc_dota_hero_primal_beast",
        ],
        counter: [
            "npc_dota_hero_life_stealer",
            "npc_dota_hero_anti-mage",
            "npc_dota_hero_leshrac",
            "npc_dota_hero_pudge",
            "npc_dota_hero_clinkz",
            "npc_dota_hero_centaur",
            "npc_dota_hero_ember_spirit",
            "npc_dota_hero_ursa",
        ],
    },
    npc_dota_hero_slark: {
        synergy: [
            "npc_dota_hero_bloodseeker",
            "npc_dota_hero_anti-mage",
            "npc_dota_hero_abyssal_underlord",
            "npc_dota_hero_kunkka",
            "npc_dota_hero_death_prophet",
            "npc_dota_hero_bristleback",
            "npc_dota_hero_lich",
            "npc_dota_hero_grimstroke",
            "npc_dota_hero_jakiro",
        ],
        counter: [
            "npc_dota_hero_bristleback",
            "npc_dota_hero_troll_warlord",
            "npc_dota_hero_ember_spirit",
            "npc_dota_hero_broodmother",
            "npc_dota_hero_lycan",
            "npc_dota_hero_tidehunter",
            "npc_dota_hero_bane",
            "npc_dota_hero_medusa",
            "npc_dota_hero_batrider",
        ],
    },

    npc_dota_hero_snapfire: {
        synergy: [
            "npc_dota_hero_meepo",
            "npc_dota_hero_visage",
            "npc_dota_hero_beastmaster",
            "npc_dota_hero_void_spirit",
            "npc_dota_hero_marci",
            "npc_dota_hero_huskar",
            "npc_dota_hero_lone_druid",
        ],
        counter: [
            "npc_dota_hero_earth_spirit",
            "npc_dota_hero_pugna",
            "npc_dota_hero_beastmaster",
            "npc_dota_hero_visage",
            "npc_dota_hero_dawnbreaker",
            "npc_dota_hero_abyssal_underlord",
            "npc_dota_hero_meepo",
            "npc_dota_hero_doom_bringer",
        ],
    },

    npc_dota_hero_sniper: {
        synergy: [
            "npc_dota_hero_ogre_magi",
            "npc_dota_hero_nyx_assassin",
            "npc_dota_hero_omniknight",
            "npc_dota_hero_vengefulspirit",
            "npc_dota_hero_pudge",
            "npc_dota_hero_slark",
            "npc_dota_hero_skeleton_king",
            "npc_dota_hero_slardar",
            "npc_dota_hero_chaos_knight",
        ],
        counter: [
            "npc_dota_hero_sand_king",
            "npc_dota_hero_medusa",
            "npc_dota_hero_leshrac",
            "npc_dota_hero_enigma",
            "npc_dota_hero_keeper_of_the_light",
            "npc_dota_hero_templar_assassin",
            "npc_dota_hero_huskar",
            "npc_dota_hero_silencer",
            "npc_dota_hero_pugna",
        ],
    },

    npc_dota_hero_spectre: {
        synergy: [
            "npc_dota_hero_medusa",
            "npc_dota_hero_bristleback",
            "npc_dota_hero_clinkz",
            "npc_dota_hero_enchantress",
            "npc_dota_hero_witch_doctor",
            "npc_dota_hero_keeper_of_the_light",
            "npc_dota_hero_omniknight",
            "npc_dota_hero_muerta",
        ],
        counter: [
            "npc_dota_hero_sniper",
            "npc_dota_hero_luna",
            "npc_dota_hero_arc_warden",
            "npc_dota_hero_muerta",
            "npc_dota_hero_riki",
            "npc_dota_hero_broodmother",
            "npc_dota_hero_silencer",
            "npc_dota_hero_windrunner",
            "npc_dota_hero_furion",
            "npc_dota_hero_clinkz",
        ],
    },

    npc_dota_hero_spirit_breaker: {
        synergy: [
            "npc_dota_hero_beastmaster",
            "npc_dota_hero_dark_seer",
            "npc_dota_hero_abyssal_underlord",
            "npc_dota_hero_shredder",
            "npc_dota_hero_warlock",
            "npc_dota_hero_alchemist",
            "npc_dota_hero_earthshaker",
            "npc_dota_hero_kunkka",
            "npc_dota_hero_keeper_of_the_light",
        ],
        counter: [
            "npc_dota_hero_broodmother",
            "npc_dota_hero_legion_commander",
            "npc_dota_hero_bloodseeker",
            "npc_dota_hero_juggernaut",
            "npc_dota_hero_life_stealer",
            "npc_dota_hero_sniper",
            "npc_dota_hero_nevermore",
            "npc_dota_hero_night_stalker",
            "npc_dota_hero_windrunner",
        ],
    },
    npc_dota_hero_storm_spirit: {
        synergy: [
            "npc_dota_hero_ancient_apparition",
            "npc_dota_hero_abyssal_underlord",
            "npc_dota_hero_beastmaster",
            "npc_dota_hero_gyrocopter",
            "npc_dota_hero_shadow_demon",
            "npc_dota_hero_dawnbreaker",
            "npc_dota_hero_drow_ranger",
            "npc_dota_hero_jakiro",
            "npc_dota_hero_phoenix",
            "npc_dota_hero_techies",
        ],
        counter: [
            "npc_dota_hero_sniper",
            "npc_dota_hero_zuus",
            "npc_dota_hero_mars",
            "npc_dota_hero_venomancer",
            "npc_dota_hero_bristleback",
            "npc_dota_hero_razor",
            "npc_dota_hero_ancient_apparition",
            "npc_dota_hero_keeper_of_the_light",
            "npc_dota_hero_bloodseeker",
            "npc_dota_hero_spectre",
        ],
    },

    npc_dota_hero_sven: {
        synergy: [
            "npc_dota_hero_beastmaster",
            "npc_dota_hero_omniknight",
            "npc_dota_hero_bloodseeker",
            "npc_dota_hero_doom_bringer",
            "npc_dota_hero_leshrac",
            "npc_dota_hero_muerta",
            "npc_dota_hero_slardar",
            "npc_dota_hero_necrolyte",
        ],
        counter: [
            "npc_dota_hero_meepo",
            "npc_dota_hero_lycan",
            "npc_dota_hero_primal_beast",
            "npc_dota_hero_pugna",
            "npc_dota_hero_beastmaster",
            "npc_dota_hero_broodmother",
            "npc_dota_hero_ember_spirit",
            "npc_dota_hero_phantom_lancer",
            "npc_dota_hero_lone_druid",
        ],
    },

    npc_dota_hero_techies: {
        synergy: [
            "npc_dota_hero_naga_siren",
            "npc_dota_hero_arc_warden",
            "npc_dota_hero_lone_druid",
            "npc_dota_hero_bane",
            "npc_dota_hero_visage",
            "npc_dota_hero_broodmother",
            "npc_dota_hero_huskar",
        ],
        counter: [
            "npc_dota_hero_lone_druid",
            "npc_dota_hero_slark",
            "npc_dota_hero_naga_siren",
            "npc_dota_hero_meepo",
            "npc_dota_hero_marci",
            "npc_dota_hero_legion_commander",
            "npc_dota_hero_riki",
            "npc_dota_hero_beastmaster",
            "npc_dota_hero_windrunner",
            "npc_dota_hero_sven",
        ],
    },

    npc_dota_hero_terrorblade: {
        synergy: [
            "npc_dota_hero_primal_beast",
            "npc_dota_hero_visage",
            "npc_dota_hero_arc_warden",
            "npc_dota_hero_shadow_demon",
            "npc_dota_hero_lone_druid",
            "npc_dota_hero_batrider",
            "npc_dota_hero_dawnbreaker",
            "npc_dota_hero_broodmother",
            "npc_dota_hero_skywrath_mage",
        ],
        counter: [
            "npc_dota_hero_broodmother",
            "npc_dota_hero_visage",
            "npc_dota_hero_lone_druid",
            "npc_dota_hero_slardar",
            "npc_dota_hero_templar_assassin",
            "npc_dota_hero_anti-mage",
            "npc_dota_hero_chaos_knight",
            "npc_dota_hero_viper",
            "npc_dota_hero_beastmaster",
        ],
    },

    npc_dota_hero_templar_assassin: {
        synergy: [
            "npc_dota_hero_beastmaster",
            "npc_dota_hero_oracle",
            "npc_dota_hero_vengefulspirit",
            "npc_dota_hero_snapfire",
            "npc_dota_hero_abyssal_underlord",
            "npc_dota_hero_mars",
            "npc_dota_hero_muerta",
            "npc_dota_hero_disruptor",
        ],
        counter: [
            "npc_dota_hero_leshrac",
            "npc_dota_hero_obsidian_destroyer",
            "npc_dota_hero_sven",
            "npc_dota_hero_skywrath_mage",
            "npc_dota_hero_bloodseeker",
            "npc_dota_hero_nyx_assassin",
            "npc_dota_hero_shredder",
            "npc_dota_hero_night_stalker",
            "npc_dota_hero_oracle",
        ],
    },
    npc_dota_hero_tidehunter: {
        synergy: [
            "npc_dota_hero_shredder",
            "npc_dota_hero_bloodseeker",
            "npc_dota_hero_arc_warden",
            "npc_dota_hero_alchemist",
            "npc_dota_hero_marci",
            "npc_dota_hero_nyx_assassin",
            "npc_dota_hero_spirit_breaker",
            "npc_dota_hero_slardar",
            "npc_dota_hero_omniknight",
        ],
        counter: [
            "npc_dota_hero_naga_siren",
            "npc_dota_hero_chaos_knight",
            "npc_dota_hero_arc_warden",
            "npc_dota_hero_earth_spirit",
            "npc_dota_hero_broodmother",
            "npc_dota_hero_lone_druid",
            "npc_dota_hero_meepo",
            "npc_dota_hero_visage",
            "npc_dota_hero_phantom_lancer",
        ],
    },

    npc_dota_hero_tinker: {
        synergy: [
            "npc_dota_hero_grimstroke",
            "npc_dota_hero_beastmaster",
            "npc_dota_hero_snapfire",
            "npc_dota_hero_night_stalker",
            "npc_dota_hero_anti-mage",
            "npc_dota_hero_furion",
            "npc_dota_hero_gyrocopter",
            "npc_dota_hero_kunkka",
            "npc_dota_hero_rattletrap",
        ],
        counter: [
            "npc_dota_hero_terrorblade",
            "npc_dota_hero_ember_spirit",
            "npc_dota_hero_skeleton_king",
            "npc_dota_hero_phantom_lancer",
            "npc_dota_hero_meepo",
            "npc_dota_hero_keeper_of_the_light",
            "npc_dota_hero_chaos_knight",
            "npc_dota_hero_arc_warden",
            "npc_dota_hero_venomancer",
            "npc_dota_hero_viper",
        ],
    },

    npc_dota_hero_tiny: {
        synergy: [
            "npc_dota_hero_dark_seer",
            "npc_dota_hero_ancient_apparition",
            "npc_dota_hero_dawnbreaker",
            "npc_dota_hero_magnataur",
            "npc_dota_hero_primal_beast",
            "npc_dota_hero_winter_wyvern",
            "npc_dota_hero_keeper_of_the_light",
        ],
        counter: [
            "npc_dota_hero_antimage",
            "npc_dota_hero_naga_siren",
            "npc_dota_hero_riki",
            "npc_dota_hero_axe",
            "npc_dota_hero_beastmaster",
            "npc_dota_hero_spirit_breaker",
            "npc_dota_hero_enigma",
            "npc_dota_hero_chaos_knight",
            "npc_dota_hero_dark_seer",
        ],
    },

    npc_dota_hero_treant: {
        synergy: [
            "npc_dota_hero_visage",
            "npc_dota_hero_earth_spirit",
            "npc_dota_hero_ember_spirit",
            "npc_dota_hero_monkey_king",
            "npc_dota_hero_death_prophet",
            "npc_dota_hero_leshrac",
            "npc_dota_hero_dawnbreaker",
            "npc_dota_hero_obsidian_destroyer",
            "npc_dota_hero_pudge",
            "npc_dota_hero_lycan",
        ],
        counter: [
            "npc_dota_hero_mirana",
            "npc_dota_hero_enigma",
            "npc_dota_hero_skeleton_king",
            "npc_dota_hero_dragon_knight",
            "npc_dota_hero_legion_commander",
            "npc_dota_hero_abyssal_underlord",
            "npc_dota_hero_shadow_shaman",
            "npc_dota_hero_templar_assassin",
            "npc_dota_hero_chaos_knight",
        ],
    },
    npc_dota_hero_troll_warlord: {
        synergy: [
            "npc_dota_hero_batrider",
            "npc_dota_hero_huskar",
            "npc_dota_hero_skywrath_mage",
            "npc_dota_hero_legion_commander",
            "npc_dota_hero_lycan",
            "npc_dota_hero_night_stalker",
            "npc_dota_hero_meepo",
            "npc_dota_hero_nevermore",
            "npc_dota_hero_marci",
        ],
        counter: [
            "npc_dota_hero_meepo",
            "npc_dota_hero_lycan",
            "npc_dota_hero_slardar",
            "npc_dota_hero_earth_spirit",
            "npc_dota_hero_marci",
            "npc_dota_hero_templar_assassin",
            "npc_dota_hero_void_spirit",
            "npc_dota_hero_ember_spirit",
        ],
    },

    npc_dota_hero_tusk: {
        synergy: [
            "npc_dota_hero_visage",
            "npc_dota_hero_monkey_king",
            "npc_dota_hero_muerta",
            "npc_dota_hero_abyssal_underlord",
            "npc_dota_hero_shadow_demon",
            "npc_dota_hero_mars",
            "npc_dota_hero_bristleback",
            "npc_dota_hero_sven",
        ],
        counter: [
            "npc_dota_hero_sven",
            "npc_dota_hero_legion_commander",
            "npc_dota_hero_clinkz",
            "npc_dota_hero_shadow_demon",
            "npc_dota_hero_visage",
            "npc_dota_hero_obsidian_destroyer",
            "npc_dota_hero_alchemist",
            "npc_dota_hero_arc_warden",
            "npc_dota_hero_bane",
        ],
    },

    npc_dota_hero_undying: {
        synergy: [
            "npc_dota_hero_winter_wyvern",
            "npc_dota_hero_batrider",
            "npc_dota_hero_axe",
            "npc_dota_hero_earth_spirit",
            "npc_dota_hero_windrunner",
            "npc_dota_hero_mars",
            "npc_dota_hero_legion_commander",
            "npc_dota_hero_sand_king",
            "npc_dota_hero_disruptor",
        ],
        counter: [
            "npc_dota_hero_spectre",
            "npc_dota_hero_lone_druid",
            "npc_dota_hero_abaddon",
            "npc_dota_hero_leshrac",
            "npc_dota_hero_beastmaster",
            "npc_dota_hero_shadow_demon",
            "npc_dota_hero_centaur",
            "npc_dota_hero_skeleton_king",
            "npc_dota_hero_primal_beast",
            "npc_dota_hero_death_prophet",
        ],
    },

    npc_dota_hero_ursa: {
        synergy: [
            "npc_dota_hero_alchemist",
            "npc_dota_hero_mars",
            "npc_dota_hero_primal_beast",
            "npc_dota_hero_earth_spirit",
            "npc_dota_hero_kunkka",
            "npc_dota_hero_oracle",
            "npc_dota_hero_snapfire",
            "npc_dota_hero_phoenix",
            "npc_dota_hero_shredder",
            "npc_dota_hero_leshrac",
        ],
        counter: [
            "npc_dota_hero_bloodseeker",
            "npc_dota_hero_shredder",
            "npc_dota_hero_pudge",
            "npc_dota_hero_leshrac",
            "npc_dota_hero_tidehunter",
            "npc_dota_hero_juggernaut",
            "npc_dota_hero_lycan",
            "npc_dota_hero_anti-mage",
            "npc_dota_hero_abyssal_underlord",
            "npc_dota_hero_rubick",
        ],
    },

    npc_dota_hero_vengefulspirit: {
        synergy: [
            "npc_dota_hero_lone_druid",
            "npc_dota_hero_drow_ranger",
            "npc_dota_hero_templar_assassin",
            "npc_dota_hero_muerta",
            "npc_dota_hero_tiny",
            "npc_dota_hero_warlock",
            "npc_dota_hero_meepo",
            "npc_dota_hero_sniper",
            "npc_dota_hero_luna",
        ],
        counter: [
            "npc_dota_hero_legion_commander",
            "npc_dota_hero_clinkz",
            "npc_dota_hero_bloodseeker",
            "npc_dota_hero_weaver",
            "npc_dota_hero_shredder",
            "npc_dota_hero_furion",
            "npc_dota_hero_skywrath_mage",
            "npc_dota_hero_enchantress",
            "npc_dota_hero_death_prophet",
        ],
    },

    npc_dota_hero_venomancer: {
        synergy: [
            "npc_dota_hero_pudge",
            "npc_dota_hero_earth_spirit",
            "npc_dota_hero_drow_ranger",
            "npc_dota_hero_ember_spirit",
            "npc_dota_hero_void_spirit",
            "npc_dota_hero_arc_warden",
            "npc_dota_hero_obsidian_destroyer",
            "npc_dota_hero_centaur",
        ],
        counter: [
            "npc_dota_hero_axe",
            "npc_dota_hero_visage",
            "npc_dota_hero_tiny",
            "npc_dota_hero_kunkka",
            "npc_dota_hero_lone_druid",
            "npc_dota_hero_mars",
            "npc_dota_hero_spirit_breaker",
            "npc_dota_hero_dragon_knight",
            "npc_dota_hero_night_stalker",
            "npc_dota_hero_chaos_knight",
        ],
    },

    npc_dota_hero_viper: {
        synergy: [
            "npc_dota_hero_faceless_void",
            "npc_dota_hero_naga_siren",
            "npc_dota_hero_omniknight",
            "npc_dota_hero_primal_beast",
            "npc_dota_hero_magnataur",
            "npc_dota_hero_mirana",
            "npc_dota_hero_meepo",
            "npc_dota_hero_dark_seer",
        ],
        counter: [
            "npc_dota_hero_huskar",
            "npc_dota_hero_bristleback",
            "npc_dota_hero_beastmaster",
            "npc_dota_hero_tiny",
            "npc_dota_hero_dragon_knight",
            "npc_dota_hero_spectre",
            "npc_dota_hero_necrolyte",
            "npc_dota_hero_visage",
            "npc_dota_hero_night_stalker",
        ],
    },

    npc_dota_hero_visage: {
        synergy: [
            "npc_dota_hero_terrorblade",
            "npc_dota_hero_batrider",
            "npc_dota_hero_luna",
            "npc_dota_hero_shadow_demon",
            "npc_dota_hero_meepo",
            "npc_dota_hero_grimstroke",
            "npc_dota_hero_broodmother",
            "npc_dota_hero_omniknight",
        ],
        counter: [
            "npc_dota_hero_leshrac",
            "npc_dota_hero_shadow_demon",
            "npc_dota_hero_life_stealer",
            "npc_dota_hero_obsidian_destroyer",
            "npc_dota_hero_night_stalker",
            "npc_dota_hero_oracle",
            "npc_dota_hero_batrider",
            "npc_dota_hero_beastmaster",
            "npc_dota_hero_juggernaut",
        ],
    },

    npc_dota_hero_void_spirit: {
        synergy: [
            "npc_dota_hero_medusa",
            "npc_dota_hero_keeper_of_the_light",
            "npc_dota_hero_ancient_apparition",
            "npc_dota_hero_snapfire",
            "npc_dota_hero_luna",
            "npc_dota_hero_alchemist",
            "npc_dota_hero_phoenix",
            "npc_dota_hero_jakiro",
            "npc_dota_hero_winter_wyvern",
        ],
        counter: [
            "npc_dota_hero_ancient_apparition",
            "npc_dota_hero_clinkz",
            "npc_dota_hero_queenofpain",
            "npc_dota_hero_mars",
            "npc_dota_hero_juggernaut",
            "npc_dota_hero_sniper",
            "npc_dota_hero_pudge",
            "npc_dota_hero_invoker",
            "npc_dota_hero_bristleback",
            "npc_dota_hero_phantom_assassin",
        ],
    },
    npc_dota_hero_warlock: {
        synergy: [
            "npc_dota_hero_bane",
            "npc_dota_hero_riki",
            "npc_dota_hero_spirit_breaker",
            "npc_dota_hero_ogre_magi",
            "npc_dota_hero_enchantress",
            "npc_dota_hero_earth_spirit",
            "npc_dota_hero_shadow_shaman",
            "npc_dota_hero_vengefulspirit",
            "npc_dota_hero_sven",
            "npc_dota_hero_slardar",
        ],
        counter: [
            "npc_dota_hero_phantom_lancer",
            "npc_dota_hero_meepo",
            "npc_dota_hero_naga_siren",
            "npc_dota_hero_chaos_knight",
            "npc_dota_hero_omniknight",
            "npc_dota_hero_enigma",
            "npc_dota_hero_arc_warden",
            "npc_dota_hero_lone_druid",
            "npc_dota_hero_medusa",
            "npc_dota_hero_beastmaster",
        ],
    },

    npc_dota_hero_weaver: {
        synergy: [
            "npc_dota_hero_muerta",
            "npc_dota_hero_bloodseeker",
            "npc_dota_hero_luna",
            "npc_dota_hero_visage",
            "npc_dota_hero_spectre",
            "npc_dota_hero_sand_king",
            "npc_dota_hero_shadow_shaman",
            "npc_dota_hero_treant",
            "npc_dota_hero_axe",
        ],
        counter: [
            "npc_dota_hero_shredder",
            "npc_dota_hero_warlock",
            "npc_dota_hero_ursa",
            "npc_dota_hero_primal_beast",
            "npc_dota_hero_razor",
            "npc_dota_hero_venomancer",
            "npc_dota_hero_lone_druid",
            "npc_dota_hero_dazzle",
            "npc_dota_hero_lycan",
        ],
    },

    npc_dota_hero_windrunner: {
        synergy: [
            "npc_dota_hero_oracle",
            "npc_dota_hero_lone_druid",
            "npc_dota_hero_abaddon",
            "npc_dota_hero_undying",
            "npc_dota_hero_batrider",
            "npc_dota_hero_warlock",
            "npc_dota_hero_sven",
            "npc_dota_hero_venomancer",
        ],
        counter: [
            "npc_dota_hero_troll_warlord",
            "npc_dota_hero_lone_druid",
            "npc_dota_hero_huskar",
            "npc_dota_hero_batrider",
            "npc_dota_hero_terrorblade",
            "npc_dota_hero_ursa",
            "npc_dota_hero_night_stalker",
            "npc_dota_hero_leshrac",
            "npc_dota_hero_medusa",
            "npc_dota_hero_venomancer",
        ],
    },
    npc_dota_hero_winter_wyvern: {
        synergy: [
            "npc_dota_hero_broodmother",
            "npc_dota_hero_meepo",
            "npc_dota_hero_naga_siren",
            "npc_dota_hero_beastmaster",
            "npc_dota_hero_enchantress",
            "npc_dota_hero_undying",
            "npc_dota_hero_arc_warden",
            "npc_dota_hero_night_stalker",
            "npc_dota_hero_batrider",
            "npc_dota_hero_rattletrap",
        ],
        counter: [
            "npc_dota_hero_meepo",
            "npc_dota_hero_visage",
            "npc_dota_hero_lone_druid",
            "npc_dota_hero_legion_commander",
            "npc_dota_hero_troll_warlord",
            "npc_dota_hero_medusa",
            "npc_dota_hero_dawnbreaker",
            "npc_dota_hero_magnataur",
            "npc_dota_hero_templar_assassin",
        ],
    },

    npc_dota_hero_witch_doctor: {
        synergy: [
            "npc_dota_hero_meepo",
            "npc_dota_hero_terrorblade",
            "npc_dota_hero_shadow_shaman",
            "npc_dota_hero_naga_siren",
            "npc_dota_hero_spectre",
            "npc_dota_hero_lone_druid",
            "npc_dota_hero_chaos_knight",
            "npc_dota_hero_void_spirit",
            "npc_dota_hero_phantom_lancer",
            "npc_dota_hero_grimstroke",
        ],
        counter: [
            "npc_dota_hero_dark_seer",
            "npc_dota_hero_axe",
            "npc_dota_hero_undying",
            "npc_dota_hero_lone_druid",
            "npc_dota_hero_bloodseeker",
            "npc_dota_hero_beastmaster",
            "npc_dota_hero_razor",
            "npc_dota_hero_abyssal_underlord",
            "npc_dota_hero_queenofpain",
            "npc_dota_hero_shredder",
        ],
    },

    npc_dota_hero_zuus: {
        synergy: [
            "npc_dota_hero_legion_commander",
            "npc_dota_hero_spirit_breaker",
            "npc_dota_hero_storm_spirit",
            "npc_dota_hero_void_spirit",
            "npc_dota_hero_juggernaut",
            "npc_dota_hero_riki",
            "npc_dota_hero_witch_doctor",
        ],
        counter: [
            "npc_dota_hero_nevermore",
            "npc_dota_hero_monkey_king",
            "npc_dota_hero_riki",
            "npc_dota_hero_terrorblade",
            "npc_dota_hero_windrunner",
            "npc_dota_hero_doom_bringer",
            "npc_dota_hero_drow_ranger",
            "npc_dota_hero_naga_siren",
        ],
    },

    npc_dota_hero_ringmaster: {
        synergy: [
            "npc_dota_hero_skeleton_king",
            "npc_dota_hero_storm_spirit",
            "npc_dota_hero_omniknight",
            "npc_dota_hero_juggernaut",
            "npc_dota_hero_meepo",
            "npc_dota_hero_puck",
            "npc_dota_hero_mars",
            "npc_dota_hero_medusa",
            "npc_dota_hero_legion_commander",
            "npc_dota_hero_sand_king",
        ],
        counter: [
            "npc_dota_hero_ember_spirit",
            "npc_dota_hero_slark",
            "npc_dota_hero_primal_beast",
            "npc_dota_hero_sven",
            "npc_dota_hero_troll_warlord",
            "npc_dota_hero_dark_seer",
            "npc_dota_hero_phantom_lancer",
            "npc_dota_hero_tiny",
            "npc_dota_hero_axe",
            "npc_dota_hero_leshrac",
            "npc_dota_hero_dragon_knight",
        ],
    },
};

export function GetHeroMatchups(heroName: string, type: "counter" | "synergy"): string[] {
    const matchups = heroes[heroName];
    if (!matchups) {
        return [];
    }
    return matchups[type];
}

export function IsSynergy(name1: string, name2: string) {
    return GetHeroMatchups(name1, "synergy").includes(name2);
}
export function IsCounter(name1: string, name2: string) {
    return GetHeroMatchups(name1, "counter").includes(name2);
}
