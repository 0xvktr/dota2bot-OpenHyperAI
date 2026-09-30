--[[ Generated with https://github.com/TypeScriptToLua/TypeScriptToLua ]]
-- Lua Library inline imports
local function __TS__ArrayIncludes(self, searchElement, fromIndex)
    if fromIndex == nil then
        fromIndex = 0
    end
    local len = #self
    local k = fromIndex
    if fromIndex < 0 then
        k = len + fromIndex
    end
    if k < 0 then
        k = 0
    end
    for i = k + 1, len do
        if self[i] == searchElement then
            return true
        end
    end
    return false
end
-- End of Lua Library inline imports
local ____exports = {}
local heroes = {
    -- D2PT 7.41f, 2026-09-30; source role: Mid; All roles, Normalized.
    npc_dota_hero_marci = {
        synergy = {
            "npc_dota_hero_enigma", -- n=110, normalized +10.50 pp
            "npc_dota_hero_magnataur", -- n=134, normalized +7.41 pp
            "npc_dota_hero_doom_bringer", -- n=147, normalized +7.20 pp
            "npc_dota_hero_lion", -- n=199, normalized +7.06 pp
            "npc_dota_hero_bounty_hunter", -- n=281, normalized +6.20 pp
            "npc_dota_hero_treant", -- n=156, normalized +4.74 pp
            "npc_dota_hero_winter_wyvern", -- n=279, normalized +4.15 pp
            "npc_dota_hero_night_stalker", -- n=174, normalized +4.10 pp
        },
        counter = {
            "npc_dota_hero_storm_spirit", -- n=103, normalized +13.10 pp
            "npc_dota_hero_nevermore", -- n=337, normalized +10.01 pp
            "npc_dota_hero_lina", -- n=417, normalized +9.21 pp
            "npc_dota_hero_night_stalker", -- n=195, normalized +7.80 pp
            "npc_dota_hero_abyssal_underlord", -- n=146, normalized +6.90 pp
            "npc_dota_hero_terrorblade", -- n=170, normalized +6.80 pp
            "npc_dota_hero_lich", -- n=158, normalized +5.87 pp
            "npc_dota_hero_undying", -- n=307, normalized +5.81 pp
        },
    },

    -- D2PT 7.41f, 2026-09-30; source role: Carry; All roles, Normalized.
    npc_dota_hero_kez = {
        synergy = {
            "npc_dota_hero_pugna", -- n=121, normalized +11.84 pp
            "npc_dota_hero_nyx_assassin", -- n=260, normalized +10.57 pp
            "npc_dota_hero_leshrac", -- n=114, normalized +9.20 pp
            "npc_dota_hero_brewmaster", -- n=175, normalized +9.10 pp
            "npc_dota_hero_lycan", -- n=118, normalized +8.20 pp
            "npc_dota_hero_bounty_hunter", -- n=886, normalized +8.09 pp
            "npc_dota_hero_shadow_shaman", -- n=278, normalized +7.77 pp
            "npc_dota_hero_enigma", -- n=415, normalized +7.40 pp
        },
        counter = {
            "npc_dota_hero_warlock", -- n=120, normalized +12.30 pp
            "npc_dota_hero_queenofpain", -- n=267, normalized +11.00 pp
            "npc_dota_hero_furion", -- n=385, normalized +8.32 pp
            "npc_dota_hero_mars", -- n=202, normalized +7.80 pp
            "npc_dota_hero_abyssal_underlord", -- n=468, normalized +7.60 pp
            "npc_dota_hero_weaver", -- n=112, normalized +7.53 pp
            "npc_dota_hero_pangolier", -- n=344, normalized +7.49 pp
            "npc_dota_hero_morphling", -- n=219, normalized +7.40 pp
        },
    },

    npc_dota_hero_abaddon = {synergy = {
        "npc_dota_hero_hoodwink",
        "npc_dota_hero_earthshaker",
        "npc_dota_hero_bounty_hunter",
        "npc_dota_hero_luna",
        "npc_dota_hero_spirit_breaker",
        "npc_dota_hero_axe",
        "npc_dota_hero_windrunner",
        "npc_dota_hero_invoker"
    }, counter = {
        "npc_dota_hero_juggernaut",
        "npc_dota_hero_dragon_knight",
        "npc_dota_hero_axe",
        "npc_dota_hero_hoodwink",
        "npc_dota_hero_mirana",
        "npc_dota_hero_ember_spirit",
        "npc_dota_hero_lich",
        "npc_dota_hero_lion"
    }},
    npc_dota_hero_abyssal_underlord = {synergy = {
        "npc_dota_hero_largo",
        "npc_dota_hero_primal_beast",
        "npc_dota_hero_bounty_hunter",
        "npc_dota_hero_dazzle",
        "npc_dota_hero_oracle",
        "npc_dota_hero_ursa",
        "npc_dota_hero_omniknight",
        "npc_dota_hero_chaos_knight"
    }, counter = {
        "npc_dota_hero_templar_assassin",
        "npc_dota_hero_riki",
        "npc_dota_hero_queenofpain",
        "npc_dota_hero_pangolier",
        "npc_dota_hero_drow_ranger",
        "npc_dota_hero_bristleback",
        "npc_dota_hero_abaddon",
        "npc_dota_hero_jakiro"
    }},
    npc_dota_hero_alchemist = {synergy = {"npc_dota_hero_bounty_hunter", "npc_dota_hero_pudge", "npc_dota_hero_mirana", "npc_dota_hero_undying"}, counter = {
        "npc_dota_hero_windrunner",
        "npc_dota_hero_nevermore",
        "npc_dota_hero_luna",
        "npc_dota_hero_invoker",
        "npc_dota_hero_lion",
        "npc_dota_hero_lina",
        "npc_dota_hero_rubick",
        "npc_dota_hero_spirit_breaker"
    }},
    npc_dota_hero_ancient_apparition = {synergy = {
        "npc_dota_hero_centaur",
        "npc_dota_hero_primal_beast",
        "npc_dota_hero_phantom_lancer",
        "npc_dota_hero_spirit_breaker",
        "npc_dota_hero_nyx_assassin",
        "npc_dota_hero_dragon_knight",
        "npc_dota_hero_bounty_hunter",
        "npc_dota_hero_enigma"
    }, counter = {
        "npc_dota_hero_shredder",
        "npc_dota_hero_necrolyte",
        "npc_dota_hero_abyssal_underlord",
        "npc_dota_hero_grimstroke",
        "npc_dota_hero_wisp",
        "npc_dota_hero_axe",
        "npc_dota_hero_slardar",
        "npc_dota_hero_tiny"
    }},
    npc_dota_hero_antimage = {synergy = {
        "npc_dota_hero_lycan",
        "npc_dota_hero_enigma",
        "npc_dota_hero_leshrac",
        "npc_dota_hero_oracle",
        "npc_dota_hero_marci",
        "npc_dota_hero_primal_beast",
        "npc_dota_hero_kez",
        "npc_dota_hero_legion_commander"
    }, counter = {
        "npc_dota_hero_bristleback",
        "npc_dota_hero_shadow_demon",
        "npc_dota_hero_kunkka",
        "npc_dota_hero_largo",
        "npc_dota_hero_muerta",
        "npc_dota_hero_abyssal_underlord",
        "npc_dota_hero_sniper",
        "npc_dota_hero_storm_spirit"
    }},
    npc_dota_hero_arc_warden = {synergy = {
        "npc_dota_hero_enigma",
        "npc_dota_hero_brewmaster",
        "npc_dota_hero_bounty_hunter",
        "npc_dota_hero_jakiro",
        "npc_dota_hero_oracle",
        "npc_dota_hero_vengefulspirit",
        "npc_dota_hero_mars",
        "npc_dota_hero_tiny"
    }, counter = {
        "npc_dota_hero_weaver",
        "npc_dota_hero_templar_assassin",
        "npc_dota_hero_tiny",
        "npc_dota_hero_silencer",
        "npc_dota_hero_mars",
        "npc_dota_hero_tinker",
        "npc_dota_hero_storm_spirit",
        "npc_dota_hero_viper"
    }},
    npc_dota_hero_axe = {synergy = {
        "npc_dota_hero_meepo",
        "npc_dota_hero_bounty_hunter",
        "npc_dota_hero_dazzle",
        "npc_dota_hero_oracle",
        "npc_dota_hero_abaddon",
        "npc_dota_hero_visage",
        "npc_dota_hero_puck",
        "npc_dota_hero_slardar"
    }, counter = {
        "npc_dota_hero_medusa",
        "npc_dota_hero_jakiro",
        "npc_dota_hero_kez",
        "npc_dota_hero_antimage",
        "npc_dota_hero_slardar",
        "npc_dota_hero_bristleback",
        "npc_dota_hero_muerta",
        "npc_dota_hero_terrorblade"
    }},
    npc_dota_hero_bane = {synergy = {
        "npc_dota_hero_bounty_hunter",
        "npc_dota_hero_brewmaster",
        "npc_dota_hero_rattletrap",
        "npc_dota_hero_enigma",
        "npc_dota_hero_earth_spirit",
        "npc_dota_hero_snapfire",
        "npc_dota_hero_sven",
        "npc_dota_hero_dark_seer"
    }, counter = {
        "npc_dota_hero_templar_assassin",
        "npc_dota_hero_tinker",
        "npc_dota_hero_jakiro",
        "npc_dota_hero_gyrocopter",
        "npc_dota_hero_queenofpain",
        "npc_dota_hero_zuus",
        "npc_dota_hero_shredder",
        "npc_dota_hero_kez"
    }},
    npc_dota_hero_batrider = {synergy = {}, counter = {"npc_dota_hero_pudge"}},
    npc_dota_hero_beastmaster = {synergy = {
        "npc_dota_hero_keeper_of_the_light",
        "npc_dota_hero_life_stealer",
        "npc_dota_hero_bounty_hunter",
        "npc_dota_hero_crystal_maiden",
        "npc_dota_hero_dragon_knight",
        "npc_dota_hero_slark",
        "npc_dota_hero_earth_spirit",
        "npc_dota_hero_spectre"
    }, counter = {
        "npc_dota_hero_storm_spirit",
        "npc_dota_hero_tiny",
        "npc_dota_hero_life_stealer",
        "npc_dota_hero_queenofpain",
        "npc_dota_hero_silencer",
        "npc_dota_hero_ogre_magi",
        "npc_dota_hero_vengefulspirit",
        "npc_dota_hero_rattletrap"
    }},
    npc_dota_hero_bloodseeker = {synergy = {
        "npc_dota_hero_spirit_breaker",
        "npc_dota_hero_bounty_hunter",
        "npc_dota_hero_invoker",
        "npc_dota_hero_dragon_knight",
        "npc_dota_hero_dawnbreaker",
        "npc_dota_hero_dark_seer",
        "npc_dota_hero_winter_wyvern",
        "npc_dota_hero_rubick"
    }, counter = {
        "npc_dota_hero_undying",
        "npc_dota_hero_night_stalker",
        "npc_dota_hero_nevermore",
        "npc_dota_hero_mirana",
        "npc_dota_hero_hoodwink",
        "npc_dota_hero_phantom_lancer",
        "npc_dota_hero_windrunner",
        "npc_dota_hero_winter_wyvern"
    }},
    npc_dota_hero_bounty_hunter = {synergy = {
        "npc_dota_hero_meepo",
        "npc_dota_hero_batrider",
        "npc_dota_hero_brewmaster",
        "npc_dota_hero_bane",
        "npc_dota_hero_earth_spirit",
        "npc_dota_hero_skeleton_king",
        "npc_dota_hero_keeper_of_the_light",
        "npc_dota_hero_oracle"
    }, counter = {
        "npc_dota_hero_templar_assassin",
        "npc_dota_hero_weaver",
        "npc_dota_hero_sand_king",
        "npc_dota_hero_drow_ranger",
        "npc_dota_hero_warlock",
        "npc_dota_hero_lina",
        "npc_dota_hero_viper",
        "npc_dota_hero_furion"
    }},
    npc_dota_hero_brewmaster = {synergy = {
        "npc_dota_hero_bounty_hunter",
        "npc_dota_hero_dazzle",
        "npc_dota_hero_arc_warden",
        "npc_dota_hero_puck",
        "npc_dota_hero_earth_spirit",
        "npc_dota_hero_ursa",
        "npc_dota_hero_sven",
        "npc_dota_hero_invoker"
    }, counter = {
        "npc_dota_hero_terrorblade",
        "npc_dota_hero_templar_assassin",
        "npc_dota_hero_shredder",
        "npc_dota_hero_witch_doctor",
        "npc_dota_hero_ancient_apparition",
        "npc_dota_hero_furion",
        "npc_dota_hero_abyssal_underlord",
        "npc_dota_hero_skeleton_king"
    }},
    npc_dota_hero_bristleback = {synergy = {
        "npc_dota_hero_witch_doctor",
        "npc_dota_hero_techies",
        "npc_dota_hero_bounty_hunter",
        "npc_dota_hero_lich",
        "npc_dota_hero_disruptor",
        "npc_dota_hero_sven",
        "npc_dota_hero_earthshaker",
        "npc_dota_hero_keeper_of_the_light"
    }, counter = {
        "npc_dota_hero_kez",
        "npc_dota_hero_furion",
        "npc_dota_hero_undying",
        "npc_dota_hero_zuus",
        "npc_dota_hero_centaur",
        "npc_dota_hero_abyssal_underlord",
        "npc_dota_hero_nevermore",
        "npc_dota_hero_magnataur"
    }},
    npc_dota_hero_broodmother = {synergy = {
        "npc_dota_hero_bounty_hunter",
        "npc_dota_hero_dark_seer",
        "npc_dota_hero_luna",
        "npc_dota_hero_treant"
    }, counter = {
        "npc_dota_hero_life_stealer",
        "npc_dota_hero_undying",
        "npc_dota_hero_ringmaster",
        "npc_dota_hero_pudge"
    }},
    npc_dota_hero_centaur = {synergy = {
        "npc_dota_hero_ancient_apparition",
        "npc_dota_hero_bounty_hunter",
        "npc_dota_hero_huskar",
        "npc_dota_hero_clinkz",
        "npc_dota_hero_dragon_knight",
        "npc_dota_hero_keeper_of_the_light",
        "npc_dota_hero_dark_willow",
        "npc_dota_hero_juggernaut"
    }, counter = {
        "npc_dota_hero_viper",
        "npc_dota_hero_sniper",
        "npc_dota_hero_jakiro",
        "npc_dota_hero_kunkka",
        "npc_dota_hero_drow_ranger",
        "npc_dota_hero_sand_king",
        "npc_dota_hero_spectre",
        "npc_dota_hero_pangolier"
    }},
    npc_dota_hero_chaos_knight = {synergy = {
        "npc_dota_hero_disruptor",
        "npc_dota_hero_bounty_hunter",
        "npc_dota_hero_phantom_lancer",
        "npc_dota_hero_spectre",
        "npc_dota_hero_lina",
        "npc_dota_hero_sven",
        "npc_dota_hero_winter_wyvern",
        "npc_dota_hero_mirana"
    }, counter = {
        "npc_dota_hero_nevermore",
        "npc_dota_hero_doom_bringer",
        "npc_dota_hero_night_stalker",
        "npc_dota_hero_undying",
        "npc_dota_hero_necrolyte",
        "npc_dota_hero_mirana",
        "npc_dota_hero_zuus",
        "npc_dota_hero_earth_spirit"
    }},
    npc_dota_hero_chen = {synergy = {
        "npc_dota_hero_spirit_breaker",
        "npc_dota_hero_lina",
        "npc_dota_hero_pudge",
        "npc_dota_hero_invoker",
        "npc_dota_hero_luna",
        "npc_dota_hero_windrunner"
    }, counter = {
        "npc_dota_hero_hoodwink",
        "npc_dota_hero_luna",
        "npc_dota_hero_rubick",
        "npc_dota_hero_winter_wyvern"
    }},
    npc_dota_hero_clinkz = {synergy = {
        "npc_dota_hero_tidehunter",
        "npc_dota_hero_primal_beast",
        "npc_dota_hero_oracle",
        "npc_dota_hero_enigma",
        "npc_dota_hero_tinker",
        "npc_dota_hero_keeper_of_the_light",
        "npc_dota_hero_earthshaker",
        "npc_dota_hero_spirit_breaker"
    }, counter = {
        "npc_dota_hero_abyssal_underlord",
        "npc_dota_hero_pangolier",
        "npc_dota_hero_beastmaster",
        "npc_dota_hero_lone_druid",
        "npc_dota_hero_queenofpain",
        "npc_dota_hero_undying",
        "npc_dota_hero_slardar",
        "npc_dota_hero_grimstroke"
    }},
    npc_dota_hero_crystal_maiden = {synergy = {
        "npc_dota_hero_visage",
        "npc_dota_hero_antimage",
        "npc_dota_hero_enigma",
        "npc_dota_hero_spirit_breaker",
        "npc_dota_hero_lycan",
        "npc_dota_hero_bounty_hunter",
        "npc_dota_hero_grimstroke",
        "npc_dota_hero_rattletrap"
    }, counter = {
        "npc_dota_hero_gyrocopter",
        "npc_dota_hero_jakiro",
        "npc_dota_hero_warlock",
        "npc_dota_hero_centaur",
        "npc_dota_hero_ancient_apparition",
        "npc_dota_hero_muerta",
        "npc_dota_hero_omniknight",
        "npc_dota_hero_viper"
    }},
    npc_dota_hero_dark_seer = {synergy = {
        "npc_dota_hero_riki",
        "npc_dota_hero_naga_siren",
        "npc_dota_hero_razor",
        "npc_dota_hero_bounty_hunter",
        "npc_dota_hero_primal_beast",
        "npc_dota_hero_shadow_shaman",
        "npc_dota_hero_slark",
        "npc_dota_hero_broodmother"
    }, counter = {
        "npc_dota_hero_drow_ranger",
        "npc_dota_hero_templar_assassin",
        "npc_dota_hero_venomancer",
        "npc_dota_hero_viper",
        "npc_dota_hero_alchemist",
        "npc_dota_hero_slardar",
        "npc_dota_hero_terrorblade",
        "npc_dota_hero_sniper"
    }},
    npc_dota_hero_dark_willow = {synergy = {
        "npc_dota_hero_monkey_king",
        "npc_dota_hero_pugna",
        "npc_dota_hero_enigma",
        "npc_dota_hero_phantom_assassin",
        "npc_dota_hero_rattletrap",
        "npc_dota_hero_spirit_breaker",
        "npc_dota_hero_dragon_knight",
        "npc_dota_hero_bane"
    }, counter = {
        "npc_dota_hero_drow_ranger",
        "npc_dota_hero_muerta",
        "npc_dota_hero_templar_assassin",
        "npc_dota_hero_sniper",
        "npc_dota_hero_sand_king",
        "npc_dota_hero_razor",
        "npc_dota_hero_chaos_knight",
        "npc_dota_hero_ancient_apparition"
    }},
    npc_dota_hero_dawnbreaker = {synergy = {
        "npc_dota_hero_largo",
        "npc_dota_hero_troll_warlord",
        "npc_dota_hero_oracle",
        "npc_dota_hero_riki",
        "npc_dota_hero_chaos_knight",
        "npc_dota_hero_nyx_assassin",
        "npc_dota_hero_leshrac",
        "npc_dota_hero_phoenix"
    }, counter = {
        "npc_dota_hero_weaver",
        "npc_dota_hero_bristleback",
        "npc_dota_hero_sand_king",
        "npc_dota_hero_sniper",
        "npc_dota_hero_furion",
        "npc_dota_hero_tiny",
        "npc_dota_hero_lone_druid",
        "npc_dota_hero_gyrocopter"
    }},
    npc_dota_hero_dazzle = {synergy = {
        "npc_dota_hero_primal_beast",
        "npc_dota_hero_grimstroke",
        "npc_dota_hero_faceless_void",
        "npc_dota_hero_brewmaster",
        "npc_dota_hero_spirit_breaker",
        "npc_dota_hero_tinker",
        "npc_dota_hero_slark",
        "npc_dota_hero_marci"
    }, counter = {
        "npc_dota_hero_templar_assassin",
        "npc_dota_hero_centaur",
        "npc_dota_hero_jakiro",
        "npc_dota_hero_ogre_magi",
        "npc_dota_hero_legion_commander",
        "npc_dota_hero_huskar",
        "npc_dota_hero_drow_ranger",
        "npc_dota_hero_phantom_assassin"
    }},
    -- D2PT 7.41f, 2026-09-29: hard support, All roles, Normalized; weighted displayed rows, >=100 matches.
    npc_dota_hero_disruptor = {
        synergy = {
            "npc_dota_hero_bounty_hunter", -- n=1838, normalized +8.10 pp
            "npc_dota_hero_chaos_knight", -- n=195, normalized +6.82 pp
            "npc_dota_hero_pugna", -- n=114, normalized +5.23 pp
            "npc_dota_hero_enigma", -- n=702, normalized +5.04 pp
            "npc_dota_hero_marci", -- n=332, normalized +4.88 pp
            "npc_dota_hero_lycan", -- n=237, normalized +3.90 pp
            "npc_dota_hero_obsidian_destroyer", -- n=1265, normalized +3.85 pp
            "npc_dota_hero_enchantress", -- n=184, normalized +3.85 pp
        },
        counter = {
            "npc_dota_hero_slardar", -- n=560, normalized +10.41 pp
            "npc_dota_hero_bristleback", -- n=161, normalized +9.50 pp
            "npc_dota_hero_sand_king", -- n=165, normalized +7.37 pp
            "npc_dota_hero_gyrocopter", -- n=228, normalized +6.59 pp
            "npc_dota_hero_templar_assassin", -- n=470, normalized +5.39 pp
            "npc_dota_hero_necrolyte", -- n=1026, normalized +5.15 pp
            "npc_dota_hero_storm_spirit", -- n=442, normalized +4.80 pp
            "npc_dota_hero_drow_ranger", -- n=366, normalized +4.70 pp
        },
    },
    -- D2PT 7.41f, 2026-09-29: offlane, All roles, Normalized; weighted displayed rows, >=100 matches.
    npc_dota_hero_death_prophet = {
        synergy = {
            "npc_dota_hero_puck", -- 100 matches, +9.50 pp
            "npc_dota_hero_keeper_of_the_light", -- 113 matches, +8.89 pp
            "npc_dota_hero_bounty_hunter", -- 445 matches, +8.47 pp
            "npc_dota_hero_invoker", -- 324 matches, +7.97 pp
            "npc_dota_hero_oracle", -- 110 matches, +7.77 pp
            "npc_dota_hero_crystal_maiden", -- 136 matches, +7.11 pp
            "npc_dota_hero_pangolier", -- 102 matches, +5.40 pp
            "npc_dota_hero_life_stealer", -- 350 matches, +5.40 pp
        },
        counter = {
            "npc_dota_hero_shredder", -- 147 matches, +11.08 pp
            "npc_dota_hero_pangolier", -- 106 matches, +10.85 pp
            "npc_dota_hero_bane", -- 116 matches, +8.27 pp
            "npc_dota_hero_queenofpain", -- 118 matches, +8.10 pp
            "npc_dota_hero_zuus", -- 141 matches, +7.96 pp
            "npc_dota_hero_necrolyte", -- 235 matches, +7.53 pp
            "npc_dota_hero_juggernaut", -- 200 matches, +7.50 pp
            "npc_dota_hero_earthshaker", -- 198 matches, +7.08 pp
        },
    },
    -- D2PT 7.41f, 2026-09-30: offlane, All roles, Normalized; weighted displayed rows, >=100 matches.
    npc_dota_hero_doom_bringer = {
        synergy = {
            "npc_dota_hero_meepo", -- n=107, normalized +6.80 pp
            "npc_dota_hero_visage", -- n=100, normalized +6.79 pp
            "npc_dota_hero_primal_beast", -- n=141, normalized +6.60 pp
            "npc_dota_hero_dazzle", -- n=336, normalized +5.20 pp
            "npc_dota_hero_puck", -- n=536, normalized +4.90 pp
            "npc_dota_hero_marci", -- n=260, normalized +4.82 pp
            "npc_dota_hero_keeper_of_the_light", -- n=723, normalized +4.69 pp
            "npc_dota_hero_spirit_breaker", -- n=1127, normalized +4.40 pp
        },
        counter = {
            "npc_dota_hero_huskar", -- n=183, normalized +7.22 pp
            "npc_dota_hero_abyssal_underlord", -- n=865, normalized +6.50 pp
            "npc_dota_hero_queenofpain", -- n=565, normalized +6.11 pp
            "npc_dota_hero_shredder", -- n=698, normalized +5.98 pp
            "npc_dota_hero_ogre_magi", -- n=564, normalized +5.32 pp
            "npc_dota_hero_warlock", -- n=209, normalized +4.87 pp
            "npc_dota_hero_omniknight", -- n=188, normalized +4.64 pp
            "npc_dota_hero_drow_ranger", -- n=448, normalized +4.10 pp
        },
    },
    -- D2PT 7.41f, 2026-09-30: offlane, All roles, Normalized; weighted displayed rows, >=100 matches.
    npc_dota_hero_dragon_knight = {
        synergy = {
            "npc_dota_hero_rattletrap", -- n=312, normalized +5.21 pp
            "npc_dota_hero_ursa", -- n=241, normalized +5.10 pp
            "npc_dota_hero_obsidian_destroyer", -- n=782, normalized +5.00 pp
            "npc_dota_hero_nyx_assassin", -- n=278, normalized +4.96 pp
            "npc_dota_hero_earth_spirit", -- n=496, normalized +4.85 pp
            "npc_dota_hero_bane", -- n=353, normalized +4.46 pp
            "npc_dota_hero_phantom_assassin", -- n=175, normalized +4.40 pp
            "npc_dota_hero_spirit_breaker", -- n=683, normalized +4.32 pp
        },
        counter = {
            "npc_dota_hero_templar_assassin", -- n=219, normalized +12.60 pp
            "npc_dota_hero_jakiro", -- n=162, normalized +10.81 pp
            "npc_dota_hero_shadow_demon", -- n=144, normalized +8.89 pp
            "npc_dota_hero_gyrocopter", -- n=118, normalized +8.79 pp
            "npc_dota_hero_furion", -- n=395, normalized +8.05 pp
            "npc_dota_hero_sand_king", -- n=108, normalized +7.06 pp
            "npc_dota_hero_monkey_king", -- n=167, normalized +7.06 pp
            "npc_dota_hero_tiny", -- n=252, normalized +6.56 pp
        },
    },
    -- D2PT 7.41f, 2026-09-30: carry, All roles, Normalized; weighted displayed rows, >=100 matches.
    npc_dota_hero_drow_ranger = {
        synergy = {
            "npc_dota_hero_dazzle", -- n=114, normalized +7.90 pp
            "npc_dota_hero_bounty_hunter", -- n=796, normalized +6.69 pp
            "npc_dota_hero_largo", -- n=190, normalized +6.69 pp
            "npc_dota_hero_vengefulspirit", -- n=173, normalized +4.99 pp
            "npc_dota_hero_enigma", -- n=268, normalized +4.60 pp
            "npc_dota_hero_nyx_assassin", -- n=225, normalized +4.18 pp
            "npc_dota_hero_bane", -- n=198, normalized +4.04 pp
            "npc_dota_hero_ringmaster", -- n=338, normalized +3.53 pp
        },
        counter = {
            "npc_dota_hero_ursa", -- n=122, normalized +11.70 pp
            "npc_dota_hero_templar_assassin", -- n=162, normalized +10.90 pp
            "npc_dota_hero_beastmaster", -- n=105, normalized +10.69 pp
            "npc_dota_hero_ancient_apparition", -- n=144, normalized +9.11 pp
            "npc_dota_hero_kez", -- n=234, normalized +9.09 pp
            "npc_dota_hero_jakiro", -- n=154, normalized +8.04 pp
            "npc_dota_hero_viper", -- n=210, normalized +6.87 pp
            "npc_dota_hero_shredder", -- n=313, normalized +6.20 pp
        },
    },
    -- D2PT 7.41f, 2026-09-30: mid, All roles, Normalized; weighted displayed rows, >=100 matches.
    npc_dota_hero_earth_spirit = {
        synergy = {
            "npc_dota_hero_enigma", -- n=646, normalized +12.25 pp
            "npc_dota_hero_visage", -- n=172, normalized +8.13 pp
            "npc_dota_hero_keeper_of_the_light", -- n=344, normalized +8.12 pp
            "npc_dota_hero_bounty_hunter", -- n=1464, normalized +7.98 pp
            "npc_dota_hero_brewmaster", -- n=208, normalized +7.50 pp
            "npc_dota_hero_elder_titan", -- n=107, normalized +6.77 pp
            "npc_dota_hero_dragon_knight", -- n=408, normalized +6.63 pp
            "npc_dota_hero_omniknight", -- n=120, normalized +6.32 pp
        },
        counter = {
            "npc_dota_hero_drow_ranger", -- n=299, normalized +11.40 pp
            "npc_dota_hero_sand_king", -- n=134, normalized +10.03 pp
            "npc_dota_hero_mars", -- n=261, normalized +9.40 pp
            "npc_dota_hero_weaver", -- n=195, normalized +8.85 pp
            "npc_dota_hero_tiny", -- n=488, normalized +8.64 pp
            "npc_dota_hero_shadow_demon", -- n=193, normalized +8.38 pp
            "npc_dota_hero_clinkz", -- n=258, normalized +7.77 pp
            "npc_dota_hero_sniper", -- n=215, normalized +7.45 pp
        },
    },
    -- D2PT 7.41f, 2026-09-30: mid, All roles, Normalized; weighted displayed rows, >=100 matches.
    npc_dota_hero_earthshaker = {
        synergy = {
            "npc_dota_hero_oracle", -- n=321, normalized +11.02 pp
            "npc_dota_hero_enigma", -- n=457, normalized +10.70 pp
            "npc_dota_hero_chaos_knight", -- n=110, normalized +10.52 pp
            "npc_dota_hero_earth_spirit", -- n=213, normalized +10.20 pp
            "npc_dota_hero_bounty_hunter", -- n=1043, normalized +7.51 pp
            "npc_dota_hero_nyx_assassin", -- n=208, normalized +6.30 pp
            "npc_dota_hero_muerta", -- n=106, normalized +6.20 pp
            "npc_dota_hero_dazzle", -- n=223, normalized +6.10 pp
        },
        counter = {
            "npc_dota_hero_ancient_apparition", -- n=197, normalized +10.50 pp
            "npc_dota_hero_faceless_void", -- n=198, normalized +9.70 pp
            "npc_dota_hero_sniper", -- n=188, normalized +8.16 pp
            "npc_dota_hero_furion", -- n=404, normalized +8.06 pp
            "npc_dota_hero_undying", -- n=801, normalized +7.91 pp
            "npc_dota_hero_tinker", -- n=249, normalized +7.80 pp
            "npc_dota_hero_antimage", -- n=293, normalized +7.60 pp
            "npc_dota_hero_broodmother", -- n=163, normalized +7.26 pp
        },
    },
    -- D2PT 7.41f, 2026-09-30: hard-support, All roles, Normalized; weighted displayed rows, >=100 matches.
    npc_dota_hero_elder_titan = {
        synergy = {
            "npc_dota_hero_obsidian_destroyer", -- n=131, normalized +11.10 pp
            "npc_dota_hero_dragon_knight", -- n=109, normalized +7.79 pp
            "npc_dota_hero_rubick", -- n=191, normalized +6.55 pp
            "npc_dota_hero_life_stealer", -- n=139, normalized +6.10 pp
            "npc_dota_hero_necrolyte", -- n=109, normalized +5.97 pp
            "npc_dota_hero_earth_spirit", -- n=102, normalized +5.85 pp
            "npc_dota_hero_ember_spirit", -- n=154, normalized +5.80 pp
            "npc_dota_hero_phantom_lancer", -- n=117, normalized +3.80 pp
        },
        counter = {
            "npc_dota_hero_earth_spirit", -- n=102, normalized +11.78 pp
            "npc_dota_hero_obsidian_destroyer", -- n=121, normalized +9.50 pp
            "npc_dota_hero_lion", -- n=127, normalized +8.27 pp
            "npc_dota_hero_luna", -- n=141, normalized +7.40 pp
            "npc_dota_hero_rubick", -- n=225, normalized +6.00 pp
            "npc_dota_hero_nevermore", -- n=149, normalized +5.71 pp
            "npc_dota_hero_undying", -- n=172, normalized +5.26 pp
            "npc_dota_hero_earthshaker", -- n=113, normalized +4.86 pp
        },
    },

    -- D2PT 7.41f, 2026-09-30: mid, All roles, Normalized; weighted displayed rows, >=100 matches.
    npc_dota_hero_ember_spirit = {
        synergy = {
            "npc_dota_hero_skeleton_king", -- n=486, normalized +8.55 pp
            "npc_dota_hero_oracle", -- n=846, normalized +6.51 pp
            "npc_dota_hero_bounty_hunter", -- n=3083, normalized +6.49 pp
            "npc_dota_hero_primal_beast", -- n=384, normalized +5.10 pp
            "npc_dota_hero_sven", -- n=1903, normalized +5.00 pp
            "npc_dota_hero_enigma", -- n=1303, normalized +5.00 pp
            "npc_dota_hero_troll_warlord", -- n=182, normalized +4.60 pp
            "npc_dota_hero_visage", -- n=304, normalized +4.36 pp
        },
        counter = {
            "npc_dota_hero_queenofpain", -- n=986, normalized +9.45 pp
            "npc_dota_hero_tiny", -- n=1016, normalized +8.54 pp
            "npc_dota_hero_elder_titan", -- n=222, normalized +8.11 pp
            "npc_dota_hero_templar_assassin", -- n=729, normalized +8.10 pp
            "npc_dota_hero_bristleback", -- n=267, normalized +7.90 pp
            "npc_dota_hero_batrider", -- n=165, normalized +6.69 pp
            "npc_dota_hero_void_spirit", -- n=951, normalized +6.59 pp
            "npc_dota_hero_sniper", -- n=596, normalized +6.12 pp
        },
    },
    -- D2PT 7.41f, 2026-09-30: hard-support, All roles, Normalized; weighted displayed rows, >=100 matches.
    npc_dota_hero_enchantress = {
        synergy = {
            "npc_dota_hero_bounty_hunter", -- n=337, normalized +5.90 pp
            "npc_dota_hero_enigma", -- n=164, normalized +5.00 pp
            "npc_dota_hero_dawnbreaker", -- n=218, normalized +4.60 pp
            "npc_dota_hero_invoker", -- n=314, normalized +4.52 pp
            "npc_dota_hero_windrunner", -- n=316, normalized +4.17 pp
            "npc_dota_hero_keeper_of_the_light", -- n=166, normalized +3.75 pp
            "npc_dota_hero_antimage", -- n=114, normalized +3.10 pp
            "npc_dota_hero_shredder", -- n=144, normalized +2.70 pp
        },
        counter = {
            "npc_dota_hero_puck", -- n=126, normalized +6.90 pp
            "npc_dota_hero_tiny", -- n=113, normalized +6.21 pp
            "npc_dota_hero_lion", -- n=270, normalized +6.14 pp
            "npc_dota_hero_magnataur", -- n=184, normalized +5.69 pp
            "npc_dota_hero_pangolier", -- n=139, normalized +5.29 pp
            "npc_dota_hero_viper", -- n=119, normalized +5.09 pp
            "npc_dota_hero_storm_spirit", -- n=144, normalized +4.80 pp
            "npc_dota_hero_shredder", -- n=183, normalized +4.34 pp
        },
    },
    -- D2PT 7.41f, 2026-09-30: offlane, All roles, Normalized; weighted displayed rows, >=100 matches.
    npc_dota_hero_enigma = {
        synergy = {
            "npc_dota_hero_skeleton_king", -- n=121, normalized +10.80 pp
            "npc_dota_hero_largo", -- n=162, normalized +9.10 pp
            "npc_dota_hero_meepo", -- n=141, normalized +8.31 pp
            "npc_dota_hero_bounty_hunter", -- n=1880, normalized +6.66 pp
            "npc_dota_hero_earth_spirit", -- n=960, normalized +5.50 pp
            "npc_dota_hero_antimage", -- n=366, normalized +5.30 pp
            "npc_dota_hero_rattletrap", -- n=695, normalized +4.76 pp
            "npc_dota_hero_arc_warden", -- n=263, normalized +4.60 pp
        },
        counter = {
            "npc_dota_hero_life_stealer", -- n=1098, normalized +9.28 pp
            "npc_dota_hero_kez", -- n=613, normalized +7.11 pp
            "npc_dota_hero_ogre_magi", -- n=513, normalized +6.59 pp
            "npc_dota_hero_morphling", -- n=284, normalized +5.70 pp
            "npc_dota_hero_mars", -- n=281, normalized +5.70 pp
            "npc_dota_hero_venomancer", -- n=182, normalized +5.62 pp
            "npc_dota_hero_sand_king", -- n=145, normalized +5.09 pp
            "npc_dota_hero_slardar", -- n=436, normalized +4.93 pp
        },
    },
    -- D2PT 7.41f, 2026-09-30: carry, All roles, Normalized; weighted displayed rows, >=100 matches.
    npc_dota_hero_faceless_void = {
        synergy = {
            "npc_dota_hero_dazzle", -- n=146, normalized +11.20 pp
            "npc_dota_hero_oracle", -- n=216, normalized +9.80 pp
            "npc_dota_hero_marci", -- n=125, normalized +9.60 pp
            "npc_dota_hero_nyx_assassin", -- n=240, normalized +8.35 pp
            "npc_dota_hero_obsidian_destroyer", -- n=492, normalized +8.10 pp
            "npc_dota_hero_pugna", -- n=102, normalized +6.47 pp
            "npc_dota_hero_phoenix", -- n=449, normalized +6.13 pp
            "npc_dota_hero_tidehunter", -- n=188, normalized +6.00 pp
        },
        counter = {
            "npc_dota_hero_weaver", -- n=232, normalized +11.69 pp
            "npc_dota_hero_queenofpain", -- n=224, normalized +11.60 pp
            "npc_dota_hero_mars", -- n=215, normalized +10.50 pp
            "npc_dota_hero_storm_spirit", -- n=275, normalized +10.30 pp
            "npc_dota_hero_abyssal_underlord", -- n=348, normalized +6.80 pp
            "npc_dota_hero_jakiro", -- n=133, normalized +6.70 pp
            "npc_dota_hero_terrorblade", -- n=365, normalized +6.60 pp
            "npc_dota_hero_razor", -- n=146, normalized +6.45 pp
        },
    },
    -- D2PT 7.41f, 2026-09-30: carry, All roles, Normalized; weighted displayed rows, >=100 matches.
    npc_dota_hero_furion = {
        synergy = {
            "npc_dota_hero_slark", -- n=108, normalized +12.00 pp
            "npc_dota_hero_enigma", -- n=369, normalized +10.10 pp
            "npc_dota_hero_bounty_hunter", -- n=941, normalized +9.53 pp
            "npc_dota_hero_rattletrap", -- n=367, normalized +7.91 pp
            "npc_dota_hero_obsidian_destroyer", -- n=576, normalized +7.70 pp
            "npc_dota_hero_legion_commander", -- n=260, normalized +7.50 pp
            "npc_dota_hero_nyx_assassin", -- n=275, normalized +7.19 pp
            "npc_dota_hero_shadow_shaman", -- n=286, normalized +7.19 pp
        },
        counter = {
            "npc_dota_hero_drow_ranger", -- n=174, normalized +17.50 pp
            "npc_dota_hero_gyrocopter", -- n=136, normalized +9.59 pp
            "npc_dota_hero_silencer", -- n=231, normalized +7.37 pp
            "npc_dota_hero_shredder", -- n=348, normalized +6.89 pp
            "npc_dota_hero_viper", -- n=158, normalized +6.87 pp
            "npc_dota_hero_skywrath_mage", -- n=350, normalized +6.83 pp
            "npc_dota_hero_pugna", -- n=121, normalized +6.60 pp
            "npc_dota_hero_ogre_magi", -- n=252, normalized +6.49 pp
        },
    },
    -- D2PT 7.41f, 2026-09-30: hard-support, All roles, Normalized; weighted displayed rows, >=100 matches.
    npc_dota_hero_grimstroke = {
        synergy = {
            "npc_dota_hero_bounty_hunter", -- n=675, normalized +9.90 pp
            "npc_dota_hero_primal_beast", -- n=192, normalized +6.67 pp
            "npc_dota_hero_enigma", -- n=271, normalized +6.40 pp
            "npc_dota_hero_nyx_assassin", -- n=206, normalized +6.10 pp
            "npc_dota_hero_viper", -- n=125, normalized +4.83 pp
            "npc_dota_hero_keeper_of_the_light", -- n=310, normalized +4.66 pp
            "npc_dota_hero_visage", -- n=106, normalized +4.52 pp
            "npc_dota_hero_dawnbreaker", -- n=392, normalized +4.40 pp
        },
        counter = {
            "npc_dota_hero_pangolier", -- n=182, normalized +10.95 pp
            "npc_dota_hero_shredder", -- n=165, normalized +10.70 pp
            "npc_dota_hero_largo", -- n=143, normalized +8.30 pp
            "npc_dota_hero_terrorblade", -- n=282, normalized +8.10 pp
            "npc_dota_hero_drow_ranger", -- n=159, normalized +8.00 pp
            "npc_dota_hero_faceless_void", -- n=162, normalized +6.90 pp
            "npc_dota_hero_ogre_magi", -- n=245, normalized +6.78 pp
            "npc_dota_hero_warlock", -- n=104, normalized +6.50 pp
        },
    },
    -- D2PT 7.41f, 2026-09-30: support, All roles, Normalized; weighted displayed rows, >=100 matches.
    npc_dota_hero_gyrocopter = {
        synergy = {
            "npc_dota_hero_windrunner", -- n=123, normalized +10.91 pp
            "npc_dota_hero_invoker", -- n=156, normalized +7.30 pp
            "npc_dota_hero_axe", -- n=117, normalized +4.60 pp
            "npc_dota_hero_winter_wyvern", -- n=151, normalized +4.60 pp
            "npc_dota_hero_juggernaut", -- n=136, normalized +3.00 pp
            "npc_dota_hero_dark_seer", -- n=105, normalized +1.10 pp
            "npc_dota_hero_life_stealer", -- n=167, normalized +0.10 pp
        },
        counter = {
            "npc_dota_hero_hoodwink", -- n=171, normalized +5.93 pp
            "npc_dota_hero_dawnbreaker", -- n=145, normalized +2.60 pp
            "npc_dota_hero_sven", -- n=140, normalized +1.60 pp
            "npc_dota_hero_lion", -- n=156, normalized +1.58 pp
            "npc_dota_hero_snapfire", -- n=118, normalized +1.58 pp
            "npc_dota_hero_rubick", -- n=254, normalized +1.57 pp
            "npc_dota_hero_winter_wyvern", -- n=197, normalized +1.32 pp
            "npc_dota_hero_nevermore", -- n=170, normalized +1.00 pp
        },
    },
    -- D2PT 7.41f, 2026-09-30: support, All roles, Normalized; weighted displayed rows, >=100 matches.
    npc_dota_hero_hoodwink = {
        synergy = {
            "npc_dota_hero_abaddon", -- n=142, normalized +12.50 pp
            "npc_dota_hero_visage", -- n=267, normalized +11.77 pp
            "npc_dota_hero_meepo", -- n=123, normalized +9.50 pp
            "npc_dota_hero_bounty_hunter", -- n=316, normalized +9.20 pp
            "npc_dota_hero_oracle", -- n=565, normalized +6.40 pp
            "npc_dota_hero_shadow_demon", -- n=190, normalized +6.30 pp
            "npc_dota_hero_spirit_breaker", -- n=414, normalized +6.01 pp
            "npc_dota_hero_keeper_of_the_light", -- n=732, normalized +5.98 pp
        },
        counter = {
            "npc_dota_hero_bristleback", -- n=117, normalized +16.70 pp
            "npc_dota_hero_sand_king", -- n=219, normalized +8.73 pp
            "npc_dota_hero_medusa", -- n=150, normalized +8.60 pp
            "npc_dota_hero_antimage", -- n=476, normalized +7.20 pp
            "npc_dota_hero_furion", -- n=909, normalized +6.30 pp
            "npc_dota_hero_tiny", -- n=694, normalized +5.77 pp
            "npc_dota_hero_templar_assassin", -- n=453, normalized +5.40 pp
            "npc_dota_hero_jakiro", -- n=391, normalized +5.01 pp
        },
    },

    -- D2PT 7.41f, 2026-09-30: mid, All roles, Normalized; weighted displayed rows, >=100 matches.
    npc_dota_hero_huskar = {
        synergy = {
            "npc_dota_hero_oracle", -- n=273, normalized +9.23 pp
            "npc_dota_hero_centaur", -- n=164, normalized +7.50 pp
            "npc_dota_hero_dazzle", -- n=176, normalized +5.90 pp
            "npc_dota_hero_lone_druid", -- n=107, normalized +5.60 pp
            "npc_dota_hero_bane", -- n=190, normalized +5.55 pp
            "npc_dota_hero_juggernaut", -- n=358, normalized +5.30 pp
            "npc_dota_hero_sven", -- n=334, normalized +5.00 pp
            "npc_dota_hero_magnataur", -- n=204, normalized +3.83 pp
        },
        counter = {
            "npc_dota_hero_largo", -- n=152, normalized +15.17 pp
            "npc_dota_hero_zuus", -- n=249, normalized +10.01 pp
            "npc_dota_hero_shredder", -- n=131, normalized +9.40 pp
            "npc_dota_hero_pangolier", -- n=209, normalized +8.33 pp
            "npc_dota_hero_enchantress", -- n=109, normalized +7.37 pp
            "npc_dota_hero_tiny", -- n=147, normalized +6.49 pp
            "npc_dota_hero_abyssal_underlord", -- n=352, normalized +5.90 pp
            "npc_dota_hero_templar_assassin", -- n=167, normalized +5.90 pp
        },
    },
    npc_dota_hero_invoker = {synergy = {
        "npc_dota_hero_phantom_lancer",
        "npc_dota_hero_batrider",
        "npc_dota_hero_undying",
        "npc_dota_hero_faceless_void",
        "npc_dota_hero_life_stealer",
        "npc_dota_hero_skeleton_king",
        "npc_dota_hero_shredder",
        "npc_dota_hero_dark_seer",
        "npc_dota_hero_furion",
        "npc_dota_hero_anti-mage"
    }, counter = {
        "npc_dota_hero_medusa",
        "npc_dota_hero_viper",
        "npc_dota_hero_death_prophet",
        "npc_dota_hero_abyssal_underlord",
        "npc_dota_hero_visage",
        "npc_dota_hero_batrider",
        "npc_dota_hero_doom_bringer",
        "npc_dota_hero_muerta",
        "npc_dota_hero_naga_siren"
    }},
    -- D2PT 7.41f, 2026-09-30: hard-support, All roles, Normalized; weighted displayed rows, >=100 matches.
    npc_dota_hero_jakiro = {
        synergy = {
            "npc_dota_hero_skeleton_king", -- n=101, normalized +7.06 pp
            "npc_dota_hero_enigma", -- n=208, normalized +6.00 pp
            "npc_dota_hero_viper", -- n=111, normalized +5.92 pp
            "npc_dota_hero_dawnbreaker", -- n=355, normalized +5.60 pp
            "npc_dota_hero_keeper_of_the_light", -- n=202, normalized +5.59 pp
            "npc_dota_hero_dark_seer", -- n=428, normalized +5.30 pp
            "npc_dota_hero_spirit_breaker", -- n=431, normalized +4.90 pp
            "npc_dota_hero_luna", -- n=363, normalized +4.70 pp
        },
        counter = {
            "npc_dota_hero_shredder", -- n=123, normalized +12.30 pp
            "npc_dota_hero_kez", -- n=181, normalized +9.87 pp
            "npc_dota_hero_doom_bringer", -- n=238, normalized +7.50 pp
            "npc_dota_hero_ogre_magi", -- n=193, normalized +6.37 pp
            "npc_dota_hero_wisp", -- n=131, normalized +5.71 pp
            "npc_dota_hero_nevermore", -- n=476, normalized +5.40 pp
            "npc_dota_hero_abyssal_underlord", -- n=282, normalized +4.90 pp
            "npc_dota_hero_tidehunter", -- n=178, normalized +4.60 pp
        },
    },
    -- D2PT 7.41f, 2026-09-30: carry, All roles, Normalized; weighted displayed rows, >=100 matches.
    npc_dota_hero_juggernaut = {
        synergy = {
            "npc_dota_hero_skeleton_king", -- n=258, normalized +10.00 pp
            "npc_dota_hero_primal_beast", -- n=481, normalized +8.39 pp
            "npc_dota_hero_bounty_hunter", -- n=2313, normalized +8.02 pp
            "npc_dota_hero_enigma", -- n=862, normalized +7.50 pp
            "npc_dota_hero_oracle", -- n=675, normalized +6.48 pp
            "npc_dota_hero_brewmaster", -- n=390, normalized +6.30 pp
            "npc_dota_hero_lone_druid", -- n=110, normalized +5.50 pp
            "npc_dota_hero_nyx_assassin", -- n=786, normalized +5.45 pp
        },
        counter = {
            "npc_dota_hero_sand_king", -- n=245, normalized +10.70 pp
            "npc_dota_hero_medusa", -- n=109, normalized +8.70 pp
            "npc_dota_hero_abyssal_underlord", -- n=1483, normalized +8.30 pp
            "npc_dota_hero_bristleback", -- n=212, normalized +8.10 pp
            "npc_dota_hero_gyrocopter", -- n=298, normalized +7.83 pp
            "npc_dota_hero_shredder", -- n=777, normalized +7.28 pp
            "npc_dota_hero_venomancer", -- n=389, normalized +7.19 pp
            "npc_dota_hero_sniper", -- n=482, normalized +7.00 pp
        },
    },
    -- D2PT 7.41f, 2026-09-30: mid, All roles, Normalized; weighted displayed rows, >=100 matches.
    npc_dota_hero_keeper_of_the_light = {
        synergy = {
            "npc_dota_hero_marci", -- n=134, normalized +12.84 pp
            "npc_dota_hero_visage", -- n=101, normalized +12.50 pp
            "npc_dota_hero_nyx_assassin", -- n=307, normalized +10.71 pp
            "npc_dota_hero_primal_beast", -- n=181, normalized +10.70 pp
            "npc_dota_hero_bounty_hunter", -- n=1118, normalized +9.84 pp
            "npc_dota_hero_enigma", -- n=429, normalized +9.00 pp
            "npc_dota_hero_slark", -- n=387, normalized +8.47 pp
            "npc_dota_hero_wisp", -- n=226, normalized +6.93 pp
        },
        counter = {
            "npc_dota_hero_enchantress", -- n=205, normalized +13.05 pp
            "npc_dota_hero_weaver", -- n=155, normalized +10.42 pp
            "npc_dota_hero_death_prophet", -- n=183, normalized +10.05 pp
            "npc_dota_hero_shadow_demon", -- n=144, normalized +9.69 pp
            "npc_dota_hero_shredder", -- n=386, normalized +9.38 pp
            "npc_dota_hero_leshrac", -- n=115, normalized +8.90 pp
            "npc_dota_hero_furion", -- n=416, normalized +8.73 pp
            "npc_dota_hero_jakiro", -- n=195, normalized +7.71 pp
        },
    },
    -- D2PT 7.41f, 2026-09-30: offlane, All roles, Normalized; weighted displayed rows, >=100 matches.
    npc_dota_hero_kunkka = {
        synergy = {
            "npc_dota_hero_nyx_assassin", -- n=109, normalized +16.29 pp
            "npc_dota_hero_oracle", -- n=105, normalized +9.30 pp
            "npc_dota_hero_earthshaker", -- n=141, normalized +6.28 pp
            "npc_dota_hero_ember_spirit", -- n=252, normalized +5.40 pp
            "npc_dota_hero_juggernaut", -- n=213, normalized +5.20 pp
            "npc_dota_hero_windrunner", -- n=285, normalized +4.62 pp
            "npc_dota_hero_witch_doctor", -- n=124, normalized +4.31 pp
            "npc_dota_hero_antimage", -- n=104, normalized +4.10 pp
        },
        counter = {
            "npc_dota_hero_kez", -- n=105, normalized +8.34 pp
            "npc_dota_hero_furion", -- n=125, normalized +7.83 pp
            "npc_dota_hero_sven", -- n=180, normalized +6.90 pp
            "npc_dota_hero_storm_spirit", -- n=123, normalized +6.30 pp
            "npc_dota_hero_skywrath_mage", -- n=125, normalized +5.46 pp
            "npc_dota_hero_pangolier", -- n=129, normalized +5.30 pp
            "npc_dota_hero_terrorblade", -- n=171, normalized +5.20 pp
            "npc_dota_hero_nevermore", -- n=281, normalized +5.05 pp
        },
    },
    -- D2PT 7.41f, 2026-09-30: offlane, All roles, Normalized; weighted displayed rows, >=100 matches.
    npc_dota_hero_largo = {
        synergy = {
            "npc_dota_hero_keeper_of_the_light", -- n=272, normalized +12.40 pp
            "npc_dota_hero_tiny", -- n=109, normalized +10.10 pp
            "npc_dota_hero_rattletrap", -- n=167, normalized +8.96 pp
            "npc_dota_hero_winter_wyvern", -- n=474, normalized +8.43 pp
            "npc_dota_hero_lone_druid", -- n=101, normalized +7.50 pp
            "npc_dota_hero_wisp", -- n=418, normalized +7.44 pp
            "npc_dota_hero_phantom_lancer", -- n=321, normalized +7.40 pp
            "npc_dota_hero_slark", -- n=215, normalized +7.10 pp
        },
        counter = {
            "npc_dota_hero_warlock", -- n=113, normalized +15.20 pp
            "npc_dota_hero_vengefulspirit", -- n=102, normalized +14.81 pp
            "npc_dota_hero_ogre_magi", -- n=141, normalized +9.68 pp
            "npc_dota_hero_undying", -- n=312, normalized +8.93 pp
            "npc_dota_hero_ember_spirit", -- n=372, normalized +8.50 pp
            "npc_dota_hero_terrorblade", -- n=248, normalized +7.10 pp
            "npc_dota_hero_dark_seer", -- n=510, normalized +7.00 pp
            "npc_dota_hero_shredder", -- n=181, normalized +7.00 pp
        },
    },

    -- D2PT 7.41f, 2026-09-30: offlane, All roles, Normalized; weighted displayed rows, >=100 matches.
    npc_dota_hero_legion_commander = {
        synergy = {
            "npc_dota_hero_riki", -- n=109, normalized +9.30 pp
            "npc_dota_hero_antimage", -- n=356, normalized +5.40 pp
            "npc_dota_hero_death_prophet", -- n=100, normalized +4.90 pp
            "npc_dota_hero_ringmaster", -- n=649, normalized +4.62 pp
            "npc_dota_hero_oracle", -- n=374, normalized +4.45 pp
            "npc_dota_hero_lich", -- n=649, normalized +4.28 pp
            "npc_dota_hero_obsidian_destroyer", -- n=740, normalized +3.60 pp
            "npc_dota_hero_wisp", -- n=406, normalized +3.59 pp
        },
        counter = {
            "npc_dota_hero_queenofpain", -- n=386, normalized +9.12 pp
            "npc_dota_hero_templar_assassin", -- n=345, normalized +8.40 pp
            "npc_dota_hero_kez", -- n=379, normalized +7.59 pp
            "npc_dota_hero_furion", -- n=527, normalized +7.29 pp
            "npc_dota_hero_jakiro", -- n=362, normalized +7.16 pp
            "npc_dota_hero_weaver", -- n=252, normalized +6.47 pp
            "npc_dota_hero_enchantress", -- n=177, normalized +6.25 pp
            "npc_dota_hero_sniper", -- n=293, normalized +5.99 pp
        },
    },
    -- D2PT 7.41f, 2026-09-30: mid, All roles, Normalized; weighted displayed rows, >=100 matches.
    npc_dota_hero_leshrac = {
        synergy = {
            "npc_dota_hero_nyx_assassin", -- n=132, normalized +12.02 pp
            "npc_dota_hero_oracle", -- n=137, normalized +11.98 pp
            "npc_dota_hero_slark", -- n=173, normalized +11.02 pp
            "npc_dota_hero_antimage", -- n=120, normalized +9.20 pp
            "npc_dota_hero_spirit_breaker", -- n=385, normalized +7.36 pp
            "npc_dota_hero_dawnbreaker", -- n=293, normalized +5.43 pp
            "npc_dota_hero_wisp", -- n=195, normalized +5.03 pp
            "npc_dota_hero_earthshaker", -- n=137, normalized +4.62 pp
        },
        counter = {
            "npc_dota_hero_kez", -- n=114, normalized +14.11 pp
            "npc_dota_hero_necrolyte", -- n=344, normalized +7.30 pp
            "npc_dota_hero_techies", -- n=275, normalized +6.99 pp
            "npc_dota_hero_abyssal_underlord", -- n=208, normalized +5.40 pp
            "npc_dota_hero_crystal_maiden", -- n=183, normalized +4.93 pp
            "npc_dota_hero_legion_commander", -- n=137, normalized +4.60 pp
            "npc_dota_hero_nevermore", -- n=329, normalized +4.21 pp
            "npc_dota_hero_skywrath_mage", -- n=164, normalized +4.05 pp
        },
    },
    -- D2PT 7.41f, 2026-09-30: hard-support, All roles, Normalized; weighted displayed rows, >=100 matches.
    npc_dota_hero_lich = {
        synergy = {
            "npc_dota_hero_nyx_assassin", -- n=524, normalized +9.04 pp
            "npc_dota_hero_bounty_hunter", -- n=1450, normalized +8.70 pp
            "npc_dota_hero_lycan", -- n=214, normalized +8.51 pp
            "npc_dota_hero_earth_spirit", -- n=893, normalized +7.52 pp
            "npc_dota_hero_enigma", -- n=638, normalized +7.12 pp
            "npc_dota_hero_legion_commander", -- n=526, normalized +7.10 pp
            "npc_dota_hero_visage", -- n=247, normalized +6.77 pp
            "npc_dota_hero_lone_druid", -- n=408, normalized +6.69 pp
        },
        counter = {
            "npc_dota_hero_venomancer", -- n=180, normalized +10.66 pp
            "npc_dota_hero_mars", -- n=354, normalized +8.60 pp
            "npc_dota_hero_bristleback", -- n=151, normalized +7.70 pp
            "npc_dota_hero_nevermore", -- n=1460, normalized +6.85 pp
            "npc_dota_hero_tiny", -- n=448, normalized +6.80 pp
            "npc_dota_hero_tusk", -- n=838, normalized +6.66 pp
            "npc_dota_hero_medusa", -- n=103, normalized +6.40 pp
            "npc_dota_hero_ogre_magi", -- n=565, normalized +6.03 pp
        },
    },
    -- D2PT 7.41f, 2026-09-30: carry, All roles, Normalized; weighted displayed rows, >=100 matches.
    npc_dota_hero_life_stealer = {
        synergy = {
            "npc_dota_hero_enigma", -- n=1707, normalized +8.86 pp
            "npc_dota_hero_meepo", -- n=185, normalized +8.70 pp
            "npc_dota_hero_elder_titan", -- n=253, normalized +8.40 pp
            "npc_dota_hero_bounty_hunter", -- n=3678, normalized +7.70 pp
            "npc_dota_hero_lone_druid", -- n=213, normalized +7.17 pp
            "npc_dota_hero_nyx_assassin", -- n=1130, normalized +6.97 pp
            "npc_dota_hero_dazzle", -- n=889, normalized +5.63 pp
            "npc_dota_hero_legion_commander", -- n=1202, normalized +5.40 pp
        },
        counter = {
            "npc_dota_hero_sniper", -- n=877, normalized +10.61 pp
            "npc_dota_hero_abyssal_underlord", -- n=2291, normalized +10.30 pp
            "npc_dota_hero_tiny", -- n=1190, normalized +10.21 pp
            "npc_dota_hero_sand_king", -- n=318, normalized +8.47 pp
            "npc_dota_hero_gyrocopter", -- n=467, normalized +8.38 pp
            "npc_dota_hero_shadow_demon", -- n=463, normalized +8.22 pp
            "npc_dota_hero_templar_assassin", -- n=950, normalized +7.76 pp
            "npc_dota_hero_mars", -- n=808, normalized +7.40 pp
        },
    },
    -- D2PT 7.41f, 2026-09-30: mid, All roles, Normalized; weighted displayed rows, >=100 matches.
    npc_dota_hero_lina = {
        synergy = {
            "npc_dota_hero_enigma", -- n=1483, normalized +10.71 pp
            "npc_dota_hero_naga_siren", -- n=187, normalized +10.20 pp
            "npc_dota_hero_bounty_hunter", -- n=3465, normalized +9.93 pp
            "npc_dota_hero_void_spirit", -- n=141, normalized +9.50 pp
            "npc_dota_hero_troll_warlord", -- n=252, normalized +9.00 pp
            "npc_dota_hero_chen", -- n=121, normalized +8.80 pp
            "npc_dota_hero_chaos_knight", -- n=395, normalized +7.66 pp
            "npc_dota_hero_treant", -- n=2080, normalized +7.43 pp
        },
        counter = {
            "npc_dota_hero_venomancer", -- n=369, normalized +9.86 pp
            "npc_dota_hero_abyssal_underlord", -- n=1893, normalized +9.80 pp
            "npc_dota_hero_bristleback", -- n=291, normalized +9.80 pp
            "npc_dota_hero_medusa", -- n=220, normalized +9.80 pp
            "npc_dota_hero_muerta", -- n=393, normalized +9.49 pp
            "npc_dota_hero_gyrocopter", -- n=416, normalized +9.25 pp
            "npc_dota_hero_sniper", -- n=1198, normalized +8.75 pp
            "npc_dota_hero_kez", -- n=1254, normalized +8.72 pp
        },
    },
    -- D2PT 7.41f, 2026-09-30: hard-support, All roles, Normalized; weighted displayed rows, >=100 matches.
    npc_dota_hero_lion = {
        synergy = {
            "npc_dota_hero_lycan", -- n=149, normalized +8.00 pp
            "npc_dota_hero_marci", -- n=250, normalized +7.65 pp
            "npc_dota_hero_enigma", -- n=493, normalized +6.80 pp
            "npc_dota_hero_monkey_king", -- n=206, normalized +5.94 pp
            "npc_dota_hero_skeleton_king", -- n=270, normalized +5.93 pp
            "npc_dota_hero_clinkz", -- n=217, normalized +5.87 pp
            "npc_dota_hero_bounty_hunter", -- n=1349, normalized +4.60 pp
            "npc_dota_hero_arc_warden", -- n=226, normalized +4.10 pp
        },
        counter = {
            "npc_dota_hero_storm_spirit", -- n=365, normalized +8.30 pp
            "npc_dota_hero_shredder", -- n=337, normalized +7.19 pp
            "npc_dota_hero_gyrocopter", -- n=146, normalized +6.48 pp
            "npc_dota_hero_templar_assassin", -- n=340, normalized +5.80 pp
            "npc_dota_hero_morphling", -- n=219, normalized +5.30 pp
            "npc_dota_hero_abyssal_underlord", -- n=722, normalized +4.80 pp
            "npc_dota_hero_sniper", -- n=312, normalized +4.78 pp
            "npc_dota_hero_skywrath_mage", -- n=526, normalized +4.60 pp
        },
    },
    -- D2PT 7.41f, 2026-09-30: carry, All roles, Normalized; weighted displayed rows, >=100 matches.
    npc_dota_hero_luna = {
        synergy = {
            "npc_dota_hero_meepo", -- n=198, normalized +9.70 pp
            "npc_dota_hero_riki", -- n=120, normalized +7.90 pp
            "npc_dota_hero_bounty_hunter", -- n=3269, normalized +7.49 pp
            "npc_dota_hero_visage", -- n=529, normalized +6.71 pp
            "npc_dota_hero_enigma", -- n=1253, normalized +6.40 pp
            "npc_dota_hero_oracle", -- n=943, normalized +5.52 pp
            "npc_dota_hero_nyx_assassin", -- n=994, normalized +5.33 pp
            "npc_dota_hero_abaddon", -- n=196, normalized +5.20 pp
        },
        counter = {
            "npc_dota_hero_undying", -- n=2730, normalized +7.06 pp
            "npc_dota_hero_bloodseeker", -- n=115, normalized +7.00 pp
            "npc_dota_hero_bristleback", -- n=252, normalized +6.80 pp
            "npc_dota_hero_jakiro", -- n=538, normalized +6.45 pp
            "npc_dota_hero_gyrocopter", -- n=405, normalized +6.40 pp
            "npc_dota_hero_tiny", -- n=1013, normalized +6.18 pp
            "npc_dota_hero_warlock", -- n=407, normalized +6.10 pp
            "npc_dota_hero_slardar", -- n=915, normalized +5.92 pp
        },
    },
    -- D2PT 7.41f, 2026-09-30: offlane, All roles, Normalized; weighted displayed rows, >=100 matches.
    npc_dota_hero_lycan = {
        synergy = {
            "npc_dota_hero_nyx_assassin", -- n=120, normalized +20.01 pp
            "npc_dota_hero_antimage", -- n=113, normalized +12.90 pp
            "npc_dota_hero_invoker", -- n=354, normalized +6.83 pp
            "npc_dota_hero_disruptor", -- n=237, normalized +5.33 pp
            "npc_dota_hero_phoenix", -- n=112, normalized +4.60 pp
            "npc_dota_hero_slark", -- n=215, normalized +4.59 pp
            "npc_dota_hero_rubick", -- n=528, normalized +4.38 pp
            "npc_dota_hero_lich", -- n=225, normalized +4.31 pp
        },
        counter = {
            "npc_dota_hero_silencer", -- n=185, normalized +9.39 pp
            "npc_dota_hero_skywrath_mage", -- n=272, normalized +8.28 pp
            "npc_dota_hero_doom_bringer", -- n=224, normalized +8.10 pp
            "npc_dota_hero_centaur", -- n=124, normalized +8.00 pp
            "npc_dota_hero_tiny", -- n=114, normalized +7.94 pp
            "npc_dota_hero_puck", -- n=133, normalized +7.70 pp
            "npc_dota_hero_spectre", -- n=167, normalized +7.60 pp
            "npc_dota_hero_shadow_shaman", -- n=153, normalized +7.14 pp
        },
    },
    -- D2PT 7.41f, 2026-09-30: offlane, All roles, Normalized; weighted displayed rows, >=100 matches.
    npc_dota_hero_magnataur = {
        synergy = {
            "npc_dota_hero_bounty_hunter", -- n=829, normalized +8.52 pp
            "npc_dota_hero_nyx_assassin", -- n=281, normalized +7.14 pp
            "npc_dota_hero_marci", -- n=167, normalized +7.07 pp
            "npc_dota_hero_juggernaut", -- n=897, normalized +5.90 pp
            "npc_dota_hero_ursa", -- n=200, normalized +5.70 pp
            "npc_dota_hero_dragon_knight", -- n=337, normalized +5.69 pp
            "npc_dota_hero_undying", -- n=604, normalized +5.68 pp
            "npc_dota_hero_keeper_of_the_light", -- n=421, normalized +5.53 pp
        },
        counter = {
            "npc_dota_hero_venomancer", -- n=133, normalized +10.33 pp
            "npc_dota_hero_ancient_apparition", -- n=182, normalized +8.39 pp
            "npc_dota_hero_sniper", -- n=227, normalized +8.32 pp
            "npc_dota_hero_mars", -- n=224, normalized +8.20 pp
            "npc_dota_hero_viper", -- n=176, normalized +8.13 pp
            "npc_dota_hero_jakiro", -- n=209, normalized +8.02 pp
            "npc_dota_hero_crystal_maiden", -- n=441, normalized +7.29 pp
            "npc_dota_hero_slardar", -- n=310, normalized +7.27 pp
        },
    },
    -- D2PT 7.41f, 2026-09-30; source role: Offlane; All roles, Normalized.
    npc_dota_hero_mars = {
        synergy = {
            "npc_dota_hero_obsidian_destroyer", -- n=518, normalized +9.30 pp
            "npc_dota_hero_dazzle", -- n=161, normalized +9.00 pp
            "npc_dota_hero_arc_warden", -- n=133, normalized +8.60 pp
            "npc_dota_hero_bounty_hunter", -- n=679, normalized +7.06 pp
            "npc_dota_hero_slark", -- n=357, normalized +6.96 pp
            "npc_dota_hero_huskar", -- n=115, normalized +6.80 pp
            "npc_dota_hero_vengefulspirit", -- n=173, normalized +6.33 pp
            "npc_dota_hero_tinker", -- n=182, normalized +5.90 pp
        },
        counter = {
            "npc_dota_hero_drow_ranger", -- n=140, normalized +16.60 pp
            "npc_dota_hero_templar_assassin", -- n=165, normalized +12.50 pp
            "npc_dota_hero_weaver", -- n=110, normalized +10.06 pp
            "npc_dota_hero_tinker", -- n=186, normalized +9.60 pp
            "npc_dota_hero_abyssal_underlord", -- n=387, normalized +9.50 pp
            "npc_dota_hero_nevermore", -- n=707, normalized +7.86 pp
            "npc_dota_hero_tiny", -- n=233, normalized +7.36 pp
            "npc_dota_hero_puck", -- n=248, normalized +6.50 pp
        },
    },
    -- D2PT 7.41f, 2026-09-30; source role: Carry; All roles, Normalized.
    npc_dota_hero_medusa = {
        synergy = {
            "npc_dota_hero_invoker", -- n=304, normalized +9.26 pp
            "npc_dota_hero_bounty_hunter", -- n=228, normalized +7.27 pp
            "npc_dota_hero_pudge", -- n=351, normalized +6.87 pp
            "npc_dota_hero_legion_commander", -- n=102, normalized +6.20 pp
            "npc_dota_hero_dark_seer", -- n=180, normalized +5.00 pp
            "npc_dota_hero_techies", -- n=167, normalized +4.79 pp
            "npc_dota_hero_lion", -- n=212, normalized +3.32 pp
            "npc_dota_hero_disruptor", -- n=101, normalized +2.81 pp
        },
        counter = {
            "npc_dota_hero_nevermore", -- n=224, normalized +5.94 pp
            "npc_dota_hero_zuus", -- n=113, normalized +5.51 pp
            "npc_dota_hero_life_stealer", -- n=234, normalized +5.40 pp
            "npc_dota_hero_skywrath_mage", -- n=118, normalized +4.14 pp
            "npc_dota_hero_doom_bringer", -- n=341, normalized +4.03 pp
            "npc_dota_hero_undying", -- n=236, normalized +3.70 pp
            "npc_dota_hero_ember_spirit", -- n=193, normalized +3.60 pp
            "npc_dota_hero_necrolyte", -- n=183, normalized +3.02 pp
        },
    },
    -- D2PT 7.41f, 2026-09-30; source role: Mid; All roles, Normalized.
    npc_dota_hero_meepo = {
        synergy = {
            "npc_dota_hero_bounty_hunter", -- n=208, normalized +9.47 pp
            "npc_dota_hero_enigma", -- n=108, normalized +9.30 pp
            "npc_dota_hero_winter_wyvern", -- n=260, normalized +5.12 pp
            "npc_dota_hero_windrunner", -- n=187, normalized +4.54 pp
            "npc_dota_hero_grimstroke", -- n=105, normalized +3.59 pp
            "npc_dota_hero_luna", -- n=200, normalized +3.10 pp
            "npc_dota_hero_axe", -- n=123, normalized +2.10 pp
            "npc_dota_hero_ringmaster", -- n=120, normalized +1.92 pp
        },
        counter = {
            "npc_dota_hero_mirana", -- n=263, normalized +6.71 pp
            "npc_dota_hero_zuus", -- n=100, normalized +5.58 pp
            "npc_dota_hero_undying", -- n=228, normalized +4.09 pp
            "npc_dota_hero_luna", -- n=184, normalized +3.40 pp
            "npc_dota_hero_doom_bringer", -- n=125, normalized +2.80 pp
            "npc_dota_hero_grimstroke", -- n=112, normalized +2.48 pp
            "npc_dota_hero_keeper_of_the_light", -- n=114, normalized +2.31 pp
            "npc_dota_hero_bane", -- n=106, normalized +1.11 pp
        },
    },
    -- D2PT 7.41f, 2026-09-30; source role: Support; All roles, Normalized.
    npc_dota_hero_mirana = {
        synergy = {
            "npc_dota_hero_meepo", -- n=176, normalized +11.91 pp
            "npc_dota_hero_batrider", -- n=106, normalized +7.00 pp
            "npc_dota_hero_chaos_knight", -- n=248, normalized +6.71 pp
            "npc_dota_hero_enigma", -- n=747, normalized +6.50 pp
            "npc_dota_hero_skywrath_mage", -- n=292, normalized +5.59 pp
            "npc_dota_hero_visage", -- n=230, normalized +4.24 pp
            "npc_dota_hero_oracle", -- n=595, normalized +4.20 pp
            "npc_dota_hero_lich", -- n=965, normalized +4.10 pp
        },
        counter = {
            "npc_dota_hero_gyrocopter", -- n=281, normalized +7.81 pp
            "npc_dota_hero_kez", -- n=746, normalized +7.17 pp
            "npc_dota_hero_ursa", -- n=346, normalized +6.10 pp
            "npc_dota_hero_warlock", -- n=298, normalized +5.80 pp
            "npc_dota_hero_abyssal_underlord", -- n=1195, normalized +4.90 pp
            "npc_dota_hero_jakiro", -- n=435, normalized +4.83 pp
            "npc_dota_hero_venomancer", -- n=253, normalized +4.78 pp
            "npc_dota_hero_sniper", -- n=499, normalized +4.71 pp
        },
    },
    -- D2PT 7.41f, 2026-09-30; source role: Carry; All roles, Normalized.
    npc_dota_hero_morphling = {
        synergy = {
            "npc_dota_hero_bounty_hunter", -- n=928, normalized +11.96 pp
            "npc_dota_hero_shadow_shaman", -- n=305, normalized +10.95 pp
            "npc_dota_hero_enigma", -- n=363, normalized +10.00 pp
            "npc_dota_hero_brewmaster", -- n=149, normalized +8.90 pp
            "npc_dota_hero_primal_beast", -- n=213, normalized +8.65 pp
            "npc_dota_hero_nyx_assassin", -- n=324, normalized +8.18 pp
            "npc_dota_hero_tinker", -- n=218, normalized +7.80 pp
            "npc_dota_hero_visage", -- n=150, normalized +7.26 pp
        },
        counter = {
            "npc_dota_hero_kunkka", -- n=169, normalized +11.79 pp
            "npc_dota_hero_abyssal_underlord", -- n=451, normalized +11.50 pp
            "npc_dota_hero_queenofpain", -- n=304, normalized +11.09 pp
            "npc_dota_hero_shadow_demon", -- n=130, normalized +10.93 pp
            "npc_dota_hero_sniper", -- n=182, normalized +10.40 pp
            "npc_dota_hero_pangolier", -- n=325, normalized +9.80 pp
            "npc_dota_hero_largo", -- n=218, normalized +9.65 pp
            "npc_dota_hero_drow_ranger", -- n=288, normalized +9.10 pp
        },
    },
    -- D2PT 7.41f, 2026-09-30; source role: Carry; All roles, Normalized.
    npc_dota_hero_monkey_king = {
        synergy = {
            "npc_dota_hero_lion", -- n=226, normalized +8.72 pp
            "npc_dota_hero_obsidian_destroyer", -- n=208, normalized +7.90 pp
            "npc_dota_hero_dark_willow", -- n=165, normalized +7.51 pp
            "npc_dota_hero_enigma", -- n=113, normalized +6.90 pp
            "npc_dota_hero_disruptor", -- n=220, normalized +6.61 pp
            "npc_dota_hero_puck", -- n=101, normalized +6.60 pp
            "npc_dota_hero_invoker", -- n=288, normalized +5.31 pp
            "npc_dota_hero_treant", -- n=104, normalized +5.00 pp
        },
        counter = {
            "npc_dota_hero_centaur", -- n=116, normalized +19.30 pp
            "npc_dota_hero_shredder", -- n=100, normalized +14.20 pp
            "npc_dota_hero_furion", -- n=156, normalized +11.46 pp
            "npc_dota_hero_kez", -- n=104, normalized +8.85 pp
            "npc_dota_hero_skywrath_mage", -- n=137, normalized +8.13 pp
            "npc_dota_hero_storm_spirit", -- n=123, normalized +6.50 pp
            "npc_dota_hero_abyssal_underlord", -- n=146, normalized +6.00 pp
            "npc_dota_hero_antimage", -- n=103, normalized +5.60 pp
        },
    },
    -- D2PT 7.41f, 2026-09-30; source role: Carry; All roles, Normalized.
    npc_dota_hero_muerta = {
        synergy = {
            "npc_dota_hero_enigma", -- n=140, normalized +9.41 pp
            "npc_dota_hero_dragon_knight", -- n=236, normalized +8.53 pp
            "npc_dota_hero_bounty_hunter", -- n=425, normalized +7.55 pp
            "npc_dota_hero_invoker", -- n=417, normalized +7.23 pp
            "npc_dota_hero_wisp", -- n=356, normalized +6.20 pp
            "npc_dota_hero_nyx_assassin", -- n=121, normalized +4.61 pp
            "npc_dota_hero_earthshaker", -- n=221, normalized +4.26 pp
            "npc_dota_hero_phoenix", -- n=148, normalized +4.24 pp
        },
        counter = {
            "npc_dota_hero_slardar", -- n=113, normalized +11.10 pp
            "npc_dota_hero_kez", -- n=144, normalized +9.22 pp
            "npc_dota_hero_queenofpain", -- n=117, normalized +7.30 pp
            "npc_dota_hero_disruptor", -- n=213, normalized +6.27 pp
            "npc_dota_hero_ember_spirit", -- n=336, normalized +5.90 pp
            "npc_dota_hero_ringmaster", -- n=201, normalized +5.09 pp
            "npc_dota_hero_doom_bringer", -- n=159, normalized +5.00 pp
            "npc_dota_hero_nevermore", -- n=377, normalized +4.97 pp
        },
    },
    -- D2PT 7.41f, 2026-09-30; source role: Carry; All roles, Normalized.
    npc_dota_hero_naga_siren = {
        synergy = {
            "npc_dota_hero_earthshaker", -- n=119, normalized +9.83 pp
            "npc_dota_hero_dark_seer", -- n=142, normalized +7.30 pp
            "npc_dota_hero_obsidian_destroyer", -- n=139, normalized +6.40 pp
            "npc_dota_hero_invoker", -- n=212, normalized +5.90 pp
            "npc_dota_hero_keeper_of_the_light", -- n=106, normalized +5.46 pp
            "npc_dota_hero_pudge", -- n=266, normalized +3.13 pp
            "npc_dota_hero_lina", -- n=184, normalized +3.10 pp
            "npc_dota_hero_spirit_breaker", -- n=169, normalized +2.79 pp
        },
        counter = {
            "npc_dota_hero_night_stalker", -- n=194, normalized +8.90 pp
            "npc_dota_hero_undying", -- n=177, normalized +8.17 pp
            "npc_dota_hero_mirana", -- n=200, normalized +5.47 pp
            "npc_dota_hero_nevermore", -- n=186, normalized +5.09 pp
            "npc_dota_hero_terrorblade", -- n=121, normalized +4.70 pp
            "npc_dota_hero_necrolyte", -- n=123, normalized +4.55 pp
            "npc_dota_hero_ember_spirit", -- n=150, normalized +4.00 pp
            "npc_dota_hero_doom_bringer", -- n=102, normalized +3.80 pp
        },
    },
    npc_dota_hero_necrolyte = {synergy = {
        "npc_dota_hero_riki",
        "npc_dota_hero_kunkka",
        "npc_dota_hero_mars",
        "npc_dota_hero_omniknight",
        "npc_dota_hero_furion",
        "npc_dota_hero_enigma",
        "npc_dota_hero_night_stalker",
        "npc_dota_hero_spirit_breaker",
        "npc_dota_hero_dawnbreaker"
    }, counter = {
        "npc_dota_hero_phantom_lancer",
        "npc_dota_hero_huskar",
        "npc_dota_hero_spectre",
        "npc_dota_hero_tiny",
        "npc_dota_hero_tidehunter",
        "npc_dota_hero_axe",
        "npc_dota_hero_spirit_breaker",
        "npc_dota_hero_naga_siren",
        "npc_dota_hero_omniknight",
        "npc_dota_hero_zuus"
    }},
    npc_dota_hero_nevermore = {synergy = {
        "npc_dota_hero_marci",
        "npc_dota_hero_lycan",
        "npc_dota_hero_bane",
        "npc_dota_hero_skeleton_king",
        "npc_dota_hero_shadow_shaman",
        "npc_dota_hero_night_stalker",
        "npc_dota_hero_dazzle",
        "npc_dota_hero_phantom_assassin"
    }, counter = {
        "npc_dota_hero_meepo",
        "npc_dota_hero_necrolyte",
        "npc_dota_hero_oracle",
        "npc_dota_hero_ember_spirit",
        "npc_dota_hero_anti-mage",
        "npc_dota_hero_huskar",
        "npc_dota_hero_slark",
        "npc_dota_hero_lone_druid",
        "npc_dota_hero_beastmaster"
    }},
    npc_dota_hero_night_stalker = {synergy = {
        "npc_dota_hero_dawnbreaker",
        "npc_dota_hero_beastmaster",
        "npc_dota_hero_primal_beast",
        "npc_dota_hero_earthshaker",
        "npc_dota_hero_luna",
        "npc_dota_hero_mars",
        "npc_dota_hero_sand_king",
        "npc_dota_hero_winter_wyvern",
        "npc_dota_hero_dragon_knight"
    }, counter = {
        "npc_dota_hero_juggernaut",
        "npc_dota_hero_shredder",
        "npc_dota_hero_storm_spirit",
        "npc_dota_hero_queenofpain",
        "npc_dota_hero_earth_spirit",
        "npc_dota_hero_void_spirit",
        "npc_dota_hero_drow_ranger"
    }},
    npc_dota_hero_nyx_assassin = {synergy = {
        "npc_dota_hero_naga_siren",
        "npc_dota_hero_enchantress",
        "npc_dota_hero_tidehunter",
        "npc_dota_hero_medusa",
        "npc_dota_hero_faceless_void",
        "npc_dota_hero_sniper",
        "npc_dota_hero_dark_seer",
        "npc_dota_hero_beastmaster",
        "npc_dota_hero_sven",
        "npc_dota_hero_warlock"
    }, counter = {
        "npc_dota_hero_medusa",
        "npc_dota_hero_muerta",
        "npc_dota_hero_weaver",
        "npc_dota_hero_enigma",
        "npc_dota_hero_sniper",
        "npc_dota_hero_storm_spirit",
        "npc_dota_hero_dawnbreaker",
        "npc_dota_hero_shredder"
    }},
    npc_dota_hero_obsidian_destroyer = {synergy = {
        "npc_dota_hero_abyssal_underlord",
        "npc_dota_hero_keeper_of_the_light",
        "npc_dota_hero_faceless_void",
        "npc_dota_hero_primal_beast",
        "npc_dota_hero_treant",
        "npc_dota_hero_razor",
        "npc_dota_hero_mirana",
        "npc_dota_hero_rattletrap",
        "npc_dota_hero_alchemist"
    }, counter = {
        "npc_dota_hero_shredder",
        "npc_dota_hero_axe",
        "npc_dota_hero_abaddon",
        "npc_dota_hero_leshrac",
        "npc_dota_hero_troll_warlord",
        "npc_dota_hero_omniknight",
        "npc_dota_hero_oracle",
        "npc_dota_hero_faceless_void",
        "npc_dota_hero_winter_wyvern",
        "npc_dota_hero_slark"
    }},
    npc_dota_hero_ogre_magi = {synergy = {
        "npc_dota_hero_keeper_of_the_light",
        "npc_dota_hero_sniper",
        "npc_dota_hero_warlock",
        "npc_dota_hero_medusa",
        "npc_dota_hero_juggernaut",
        "npc_dota_hero_troll_warlord",
        "npc_dota_hero_sven",
        "npc_dota_hero_tiny"
    }, counter = {
        "npc_dota_hero_ursa",
        "npc_dota_hero_troll_warlord",
        "npc_dota_hero_medusa",
        "npc_dota_hero_batrider",
        "npc_dota_hero_windrunner",
        "npc_dota_hero_phantom_assassin",
        "npc_dota_hero_night_stalker",
        "npc_dota_hero_keeper_of_the_light",
        "npc_dota_hero_bane"
    }},
    npc_dota_hero_omniknight = {synergy = {
        "npc_dota_hero_bristleback",
        "npc_dota_hero_abyssal_underlord",
        "npc_dota_hero_visage",
        "npc_dota_hero_shredder",
        "npc_dota_hero_muerta",
        "npc_dota_hero_legion_commander",
        "npc_dota_hero_bloodseeker",
        "npc_dota_hero_primal_beast"
    }, counter = {
        "npc_dota_hero_legion_commander",
        "npc_dota_hero_meepo",
        "npc_dota_hero_slark",
        "npc_dota_hero_keeper_of_the_light",
        "npc_dota_hero_abyssal_underlord",
        "npc_dota_hero_naga_siren",
        "npc_dota_hero_dazzle",
        "npc_dota_hero_abaddon",
        "npc_dota_hero_ursa"
    }},
    npc_dota_hero_oracle = {synergy = {
        "npc_dota_hero_visage",
        "npc_dota_hero_huskar",
        "npc_dota_hero_windrunner",
        "npc_dota_hero_sand_king",
        "npc_dota_hero_rubick",
        "npc_dota_hero_gyrocopter",
        "npc_dota_hero_luna"
    }, counter = {
        "npc_dota_hero_legion_commander",
        "npc_dota_hero_skywrath_mage",
        "npc_dota_hero_centaur",
        "npc_dota_hero_necrolyte",
        "npc_dota_hero_bloodseeker",
        "npc_dota_hero_dark_seer",
        "npc_dota_hero_troll_warlord",
        "npc_dota_hero_storm_spirit"
    }},
    npc_dota_hero_pangolier = {synergy = {
        "npc_dota_hero_beastmaster",
        "npc_dota_hero_meepo",
        "npc_dota_hero_razor",
        "npc_dota_hero_oracle",
        "npc_dota_hero_lycan",
        "npc_dota_hero_luna",
        "npc_dota_hero_phantom_lancer"
    }, counter = {
        "npc_dota_hero_life_stealer",
        "npc_dota_hero_dawnbreaker",
        "npc_dota_hero_enigma",
        "npc_dota_hero_oracle",
        "npc_dota_hero_leshrac",
        "npc_dota_hero_chaos_knight",
        "npc_dota_hero_arc_warden",
        "npc_dota_hero_pugna",
        "npc_dota_hero_earth_spirit"
    }},
    npc_dota_hero_phantom_lancer = {synergy = {
        "npc_dota_hero_grimstroke",
        "npc_dota_hero_kunkka",
        "npc_dota_hero_invoker",
        "npc_dota_hero_lone_druid",
        "npc_dota_hero_skywrath_mage",
        "npc_dota_hero_bane",
        "npc_dota_hero_arc_warden",
        "npc_dota_hero_keeper_of_the_light",
        "npc_dota_hero_witch_doctor"
    }, counter = {
        "npc_dota_hero_viper",
        "npc_dota_hero_templar_assassin",
        "npc_dota_hero_arc_warden",
        "npc_dota_hero_obsidian_destroyer",
        "npc_dota_hero_dragon_knight",
        "npc_dota_hero_ogre_magi",
        "npc_dota_hero_chaos_knight",
        "npc_dota_hero_skeleton_king",
        "npc_dota_hero_shadow_shaman",
        "npc_dota_hero_slardar"
    }},
    npc_dota_hero_phantom_assassin = {synergy = {
        "npc_dota_hero_arc_warden",
        "npc_dota_hero_bristleback",
        "npc_dota_hero_enchantress",
        "npc_dota_hero_death_prophet",
        "npc_dota_hero_nevermore",
        "npc_dota_hero_slark",
        "npc_dota_hero_broodmother",
        "npc_dota_hero_magnataur",
        "npc_dota_hero_techies",
        "npc_dota_hero_tidehunter"
    }, counter = {
        "npc_dota_hero_lone_druid",
        "npc_dota_hero_anti-mage",
        "npc_dota_hero_broodmother",
        "npc_dota_hero_keeper_of_the_light",
        "npc_dota_hero_visage",
        "npc_dota_hero_huskar",
        "npc_dota_hero_life_stealer",
        "npc_dota_hero_enchantress",
        "npc_dota_hero_furion",
        "npc_dota_hero_lina"
    }},
    npc_dota_hero_phoenix = {synergy = {
        "npc_dota_hero_broodmother",
        "npc_dota_hero_lone_druid",
        "npc_dota_hero_beastmaster",
        "npc_dota_hero_terrorblade",
        "npc_dota_hero_enigma",
        "npc_dota_hero_marci",
        "npc_dota_hero_huskar"
    }, counter = {
        "npc_dota_hero_chaos_knight",
        "npc_dota_hero_lone_druid",
        "npc_dota_hero_skeleton_king",
        "npc_dota_hero_lycan",
        "npc_dota_hero_treant",
        "npc_dota_hero_sven",
        "npc_dota_hero_templar_assassin",
        "npc_dota_hero_broodmother",
        "npc_dota_hero_tiny"
    }},
    npc_dota_hero_puck = {synergy = {
        "npc_dota_hero_terrorblade",
        "npc_dota_hero_snapfire",
        "npc_dota_hero_life_stealer",
        "npc_dota_hero_gyrocopter",
        "npc_dota_hero_bounty_hunter",
        "npc_dota_hero_ursa"
    }, counter = {
        "npc_dota_hero_phantom_lancer",
        "npc_dota_hero_enchantress",
        "npc_dota_hero_terrorblade",
        "npc_dota_hero_mars",
        "npc_dota_hero_storm_spirit",
        "npc_dota_hero_dark_seer",
        "npc_dota_hero_dawnbreaker"
    }},
    npc_dota_hero_pudge = {synergy = {
        "npc_dota_hero_pugna",
        "npc_dota_hero_enigma",
        "npc_dota_hero_abyssal_underlord",
        "npc_dota_hero_silencer",
        "npc_dota_hero_ancient_apparition",
        "npc_dota_hero_winter_wyvern",
        "npc_dota_hero_muerta",
        "npc_dota_hero_treant",
        "npc_dota_hero_jakiro",
        "npc_dota_hero_dark_willow"
    }, counter = {
        "npc_dota_hero_spectre",
        "npc_dota_hero_necrolyte",
        "npc_dota_hero_phantom_assassin",
        "npc_dota_hero_muerta",
        "npc_dota_hero_axe",
        "npc_dota_hero_sniper",
        "npc_dota_hero_naga_siren",
        "npc_dota_hero_pugna",
        "npc_dota_hero_phantom_lancer",
        "npc_dota_hero_crystal_maiden"
    }},
    npc_dota_hero_pugna = {synergy = {
        "npc_dota_hero_visage",
        "npc_dota_hero_bloodseeker",
        "npc_dota_hero_ember_spirit",
        "npc_dota_hero_winter_wyvern",
        "npc_dota_hero_pudge",
        "npc_dota_hero_axe",
        "npc_dota_hero_abyssal_underlord",
        "npc_dota_hero_alchemist",
        "npc_dota_hero_spirit_breaker",
        "npc_dota_hero_furion"
    }, counter = {
        "npc_dota_hero_shredder",
        "npc_dota_hero_storm_spirit",
        "npc_dota_hero_omniknight",
        "npc_dota_hero_necrolyte",
        "npc_dota_hero_grimstroke",
        "npc_dota_hero_winter_wyvern",
        "npc_dota_hero_queenofpain",
        "npc_dota_hero_bane"
    }},
    npc_dota_hero_queenofpain = {synergy = {
        "npc_dota_hero_alchemist",
        "npc_dota_hero_muerta",
        "npc_dota_hero_mars",
        "npc_dota_hero_ember_spirit",
        "npc_dota_hero_enigma",
        "npc_dota_hero_nyx_assassin",
        "npc_dota_hero_abyssal_underlord",
        "npc_dota_hero_doom_bringer",
        "npc_dota_hero_death_prophet",
        "npc_dota_hero_life_stealer"
    }, counter = {
        "npc_dota_hero_razor",
        "npc_dota_hero_keeper_of_the_light",
        "npc_dota_hero_monkey_king",
        "npc_dota_hero_rattletrap",
        "npc_dota_hero_dark_seer",
        "npc_dota_hero_shadow_demon",
        "npc_dota_hero_alchemist",
        "npc_dota_hero_beastmaster",
        "npc_dota_hero_leshrac"
    }},
    npc_dota_hero_rattletrap = {synergy = {
        "npc_dota_hero_beastmaster",
        "npc_dota_hero_bloodseeker",
        "npc_dota_hero_naga_siren",
        "npc_dota_hero_winter_wyvern",
        "npc_dota_hero_dark_seer",
        "npc_dota_hero_broodmother",
        "npc_dota_hero_obsidian_destroyer",
        "npc_dota_hero_huskar",
        "npc_dota_hero_keeper_of_the_light"
    }, counter = {
        "npc_dota_hero_slark",
        "npc_dota_hero_sniper",
        "npc_dota_hero_razor",
        "npc_dota_hero_spirit_breaker",
        "npc_dota_hero_drow_ranger",
        "npc_dota_hero_windrunner",
        "npc_dota_hero_treant",
        "npc_dota_hero_crystal_maiden",
        "npc_dota_hero_medusa"
    }},
    npc_dota_hero_razor = {synergy = {
        "npc_dota_hero_faceless_void",
        "npc_dota_hero_dawnbreaker",
        "npc_dota_hero_bloodseeker",
        "npc_dota_hero_keeper_of_the_light",
        "npc_dota_hero_obsidian_destroyer",
        "npc_dota_hero_spirit_breaker",
        "npc_dota_hero_abyssal_underlord"
    }, counter = {
        "npc_dota_hero_troll_warlord",
        "npc_dota_hero_tidehunter",
        "npc_dota_hero_dazzle",
        "npc_dota_hero_life_stealer",
        "npc_dota_hero_death_prophet",
        "npc_dota_hero_lion",
        "npc_dota_hero_shadow_demon",
        "npc_dota_hero_grimstroke",
        "npc_dota_hero_abaddon"
    }},
    npc_dota_hero_riki = {synergy = {
        "npc_dota_hero_silencer",
        "npc_dota_hero_luna",
        "npc_dota_hero_necrolyte",
        "npc_dota_hero_medusa",
        "npc_dota_hero_meepo",
        "npc_dota_hero_warlock",
        "npc_dota_hero_terrorblade",
        "npc_dota_hero_muerta",
        "npc_dota_hero_bristleback"
    }, counter = {
        "npc_dota_hero_storm_spirit",
        "npc_dota_hero_clinkz",
        "npc_dota_hero_witch_doctor",
        "npc_dota_hero_ursa",
        "npc_dota_hero_queenofpain",
        "npc_dota_hero_oracle",
        "npc_dota_hero_juggernaut"
    }},
    npc_dota_hero_rubick = {synergy = {
        "npc_dota_hero_oracle",
        "npc_dota_hero_naga_siren",
        "npc_dota_hero_beastmaster",
        "npc_dota_hero_life_stealer",
        "npc_dota_hero_broodmother",
        "npc_dota_hero_keeper_of_the_light",
        "npc_dota_hero_visage"
    }, counter = {
        "npc_dota_hero_abyssal_underlord",
        "npc_dota_hero_enigma",
        "npc_dota_hero_jakiro",
        "npc_dota_hero_obsidian_destroyer",
        "npc_dota_hero_beastmaster",
        "npc_dota_hero_crystal_maiden",
        "npc_dota_hero_weaver",
        "npc_dota_hero_medusa",
        "npc_dota_hero_phantom_lancer",
        "npc_dota_hero_skeleton_king"
    }},
    npc_dota_hero_sand_king = {synergy = {
        "npc_dota_hero_omniknight",
        "npc_dota_hero_abaddon",
        "npc_dota_hero_doom_bringer",
        "npc_dota_hero_slardar",
        "npc_dota_hero_dark_seer",
        "npc_dota_hero_chaos_knight",
        "npc_dota_hero_night_stalker",
        "npc_dota_hero_oracle",
        "npc_dota_hero_magnataur"
    }, counter = {
        "npc_dota_hero_naga_siren",
        "npc_dota_hero_phantom_lancer",
        "npc_dota_hero_chaos_knight",
        "npc_dota_hero_dark_seer",
        "npc_dota_hero_meepo",
        "npc_dota_hero_shadow_demon",
        "npc_dota_hero_medusa",
        "npc_dota_hero_primal_beast",
        "npc_dota_hero_lone_druid",
        "npc_dota_hero_skeleton_king"
    }},
    npc_dota_hero_shadow_demon = {synergy = {
        "npc_dota_hero_terrorblade",
        "npc_dota_hero_visage",
        "npc_dota_hero_lone_druid",
        "npc_dota_hero_dark_seer",
        "npc_dota_hero_bloodseeker",
        "npc_dota_hero_dark_willow"
    }, counter = {
        "npc_dota_hero_oracle",
        "npc_dota_hero_abaddon",
        "npc_dota_hero_arc_warden",
        "npc_dota_hero_huskar",
        "npc_dota_hero_muerta",
        "npc_dota_hero_obsidian_destroyer",
        "npc_dota_hero_omniknight"
    }},
    npc_dota_hero_shadow_shaman = {synergy = {
        "npc_dota_hero_keeper_of_the_light",
        "npc_dota_hero_beastmaster",
        "npc_dota_hero_enigma",
        "npc_dota_hero_tidehunter",
        "npc_dota_hero_medusa",
        "npc_dota_hero_earth_spirit",
        "npc_dota_hero_skywrath_mage",
        "npc_dota_hero_treant"
    }, counter = {
        "npc_dota_hero_death_prophet",
        "npc_dota_hero_storm_spirit",
        "npc_dota_hero_lycan",
        "npc_dota_hero_ursa",
        "npc_dota_hero_bloodseeker",
        "npc_dota_hero_clinkz",
        "npc_dota_hero_faceless_void",
        "npc_dota_hero_earth_spirit",
        "npc_dota_hero_oracle"
    }},
    npc_dota_hero_shredder = {synergy = {
        "npc_dota_hero_tidehunter",
        "npc_dota_hero_lone_druid",
        "npc_dota_hero_omniknight",
        "npc_dota_hero_legion_commander",
        "npc_dota_hero_visage",
        "npc_dota_hero_dawnbreaker",
        "npc_dota_hero_spirit_breaker",
        "npc_dota_hero_dark_seer",
        "npc_dota_hero_abaddon"
    }, counter = {
        "npc_dota_hero_phantom_lancer",
        "npc_dota_hero_meepo",
        "npc_dota_hero_naga_siren",
        "npc_dota_hero_huskar",
        "npc_dota_hero_chaos_knight",
        "npc_dota_hero_axe",
        "npc_dota_hero_terrorblade",
        "npc_dota_hero_shadow_demon",
        "npc_dota_hero_treant",
        "npc_dota_hero_techies"
    }},
    npc_dota_hero_silencer = {synergy = {
        "npc_dota_hero_riki",
        "npc_dota_hero_earth_spirit",
        "npc_dota_hero_pudge",
        "npc_dota_hero_shadow_shaman",
        "npc_dota_hero_crystal_maiden",
        "npc_dota_hero_rattletrap",
        "npc_dota_hero_death_prophet",
        "npc_dota_hero_magnataur",
        "npc_dota_hero_enigma",
        "npc_dota_hero_lion"
    }, counter = {
        "npc_dota_hero_leshrac",
        "npc_dota_hero_shredder",
        "npc_dota_hero_shadow_shaman",
        "npc_dota_hero_storm_spirit",
        "npc_dota_hero_death_prophet",
        "npc_dota_hero_bane",
        "npc_dota_hero_bristleback",
        "npc_dota_hero_obsidian_destroyer",
        "npc_dota_hero_dawnbreaker"
    }},
    npc_dota_hero_skeleton_king = {synergy = {
        "npc_dota_hero_arc_warden",
        "npc_dota_hero_enigma",
        "npc_dota_hero_bloodseeker",
        "npc_dota_hero_huskar",
        "npc_dota_hero_earth_spirit",
        "npc_dota_hero_bristleback",
        "npc_dota_hero_kunkka",
        "npc_dota_hero_nevermore",
        "npc_dota_hero_beastmaster"
    }, counter = {
        "npc_dota_hero_silencer",
        "npc_dota_hero_riki",
        "npc_dota_hero_enigma",
        "npc_dota_hero_huskar",
        "npc_dota_hero_skywrath_mage",
        "npc_dota_hero_muerta",
        "npc_dota_hero_legion_commander",
        "npc_dota_hero_axe",
        "npc_dota_hero_doom_bringer"
    }},
    npc_dota_hero_skywrath_mage = {synergy = {
        "npc_dota_hero_terrorblade",
        "npc_dota_hero_broodmother",
        "npc_dota_hero_troll_warlord",
        "npc_dota_hero_beastmaster",
        "npc_dota_hero_phantom_lancer",
        "npc_dota_hero_visage",
        "npc_dota_hero_arc_warden",
        "npc_dota_hero_medusa"
    }, counter = {
        "npc_dota_hero_phoenix",
        "npc_dota_hero_necrolyte",
        "npc_dota_hero_muerta",
        "npc_dota_hero_sand_king",
        "npc_dota_hero_storm_spirit",
        "npc_dota_hero_terrorblade",
        "npc_dota_hero_leshrac",
        "npc_dota_hero_juggernaut",
        "npc_dota_hero_shredder"
    }},
    npc_dota_hero_slardar = {synergy = {
        "npc_dota_hero_dawnbreaker",
        "npc_dota_hero_mars",
        "npc_dota_hero_bristleback",
        "npc_dota_hero_alchemist",
        "npc_dota_hero_sand_king",
        "npc_dota_hero_muerta",
        "npc_dota_hero_chaos_knight",
        "npc_dota_hero_lone_druid",
        "npc_dota_hero_primal_beast"
    }, counter = {
        "npc_dota_hero_life_stealer",
        "npc_dota_hero_anti-mage",
        "npc_dota_hero_leshrac",
        "npc_dota_hero_pudge",
        "npc_dota_hero_clinkz",
        "npc_dota_hero_centaur",
        "npc_dota_hero_ember_spirit",
        "npc_dota_hero_ursa"
    }},
    npc_dota_hero_slark = {synergy = {
        "npc_dota_hero_bloodseeker",
        "npc_dota_hero_anti-mage",
        "npc_dota_hero_abyssal_underlord",
        "npc_dota_hero_kunkka",
        "npc_dota_hero_death_prophet",
        "npc_dota_hero_bristleback",
        "npc_dota_hero_lich",
        "npc_dota_hero_grimstroke",
        "npc_dota_hero_jakiro"
    }, counter = {
        "npc_dota_hero_bristleback",
        "npc_dota_hero_troll_warlord",
        "npc_dota_hero_ember_spirit",
        "npc_dota_hero_broodmother",
        "npc_dota_hero_lycan",
        "npc_dota_hero_tidehunter",
        "npc_dota_hero_bane",
        "npc_dota_hero_medusa",
        "npc_dota_hero_batrider"
    }},
    npc_dota_hero_snapfire = {synergy = {
        "npc_dota_hero_meepo",
        "npc_dota_hero_visage",
        "npc_dota_hero_beastmaster",
        "npc_dota_hero_void_spirit",
        "npc_dota_hero_marci",
        "npc_dota_hero_huskar",
        "npc_dota_hero_lone_druid"
    }, counter = {
        "npc_dota_hero_earth_spirit",
        "npc_dota_hero_pugna",
        "npc_dota_hero_beastmaster",
        "npc_dota_hero_visage",
        "npc_dota_hero_dawnbreaker",
        "npc_dota_hero_abyssal_underlord",
        "npc_dota_hero_meepo",
        "npc_dota_hero_doom_bringer"
    }},
    npc_dota_hero_sniper = {synergy = {
        "npc_dota_hero_ogre_magi",
        "npc_dota_hero_nyx_assassin",
        "npc_dota_hero_omniknight",
        "npc_dota_hero_vengefulspirit",
        "npc_dota_hero_pudge",
        "npc_dota_hero_slark",
        "npc_dota_hero_skeleton_king",
        "npc_dota_hero_slardar",
        "npc_dota_hero_chaos_knight"
    }, counter = {
        "npc_dota_hero_sand_king",
        "npc_dota_hero_medusa",
        "npc_dota_hero_leshrac",
        "npc_dota_hero_enigma",
        "npc_dota_hero_keeper_of_the_light",
        "npc_dota_hero_templar_assassin",
        "npc_dota_hero_huskar",
        "npc_dota_hero_silencer",
        "npc_dota_hero_pugna"
    }},
    npc_dota_hero_spectre = {synergy = {
        "npc_dota_hero_medusa",
        "npc_dota_hero_bristleback",
        "npc_dota_hero_clinkz",
        "npc_dota_hero_enchantress",
        "npc_dota_hero_witch_doctor",
        "npc_dota_hero_keeper_of_the_light",
        "npc_dota_hero_omniknight",
        "npc_dota_hero_muerta"
    }, counter = {
        "npc_dota_hero_sniper",
        "npc_dota_hero_luna",
        "npc_dota_hero_arc_warden",
        "npc_dota_hero_muerta",
        "npc_dota_hero_riki",
        "npc_dota_hero_broodmother",
        "npc_dota_hero_silencer",
        "npc_dota_hero_windrunner",
        "npc_dota_hero_furion",
        "npc_dota_hero_clinkz"
    }},
    npc_dota_hero_spirit_breaker = {synergy = {
        "npc_dota_hero_beastmaster",
        "npc_dota_hero_dark_seer",
        "npc_dota_hero_abyssal_underlord",
        "npc_dota_hero_shredder",
        "npc_dota_hero_warlock",
        "npc_dota_hero_alchemist",
        "npc_dota_hero_earthshaker",
        "npc_dota_hero_kunkka",
        "npc_dota_hero_keeper_of_the_light"
    }, counter = {
        "npc_dota_hero_broodmother",
        "npc_dota_hero_legion_commander",
        "npc_dota_hero_bloodseeker",
        "npc_dota_hero_juggernaut",
        "npc_dota_hero_life_stealer",
        "npc_dota_hero_sniper",
        "npc_dota_hero_nevermore",
        "npc_dota_hero_night_stalker",
        "npc_dota_hero_windrunner"
    }},
    npc_dota_hero_storm_spirit = {synergy = {
        "npc_dota_hero_ancient_apparition",
        "npc_dota_hero_abyssal_underlord",
        "npc_dota_hero_beastmaster",
        "npc_dota_hero_gyrocopter",
        "npc_dota_hero_shadow_demon",
        "npc_dota_hero_dawnbreaker",
        "npc_dota_hero_drow_ranger",
        "npc_dota_hero_jakiro",
        "npc_dota_hero_phoenix",
        "npc_dota_hero_techies"
    }, counter = {
        "npc_dota_hero_sniper",
        "npc_dota_hero_zuus",
        "npc_dota_hero_mars",
        "npc_dota_hero_venomancer",
        "npc_dota_hero_bristleback",
        "npc_dota_hero_razor",
        "npc_dota_hero_ancient_apparition",
        "npc_dota_hero_keeper_of_the_light",
        "npc_dota_hero_bloodseeker",
        "npc_dota_hero_spectre"
    }},
    npc_dota_hero_sven = {synergy = {
        "npc_dota_hero_beastmaster",
        "npc_dota_hero_omniknight",
        "npc_dota_hero_bloodseeker",
        "npc_dota_hero_doom_bringer",
        "npc_dota_hero_leshrac",
        "npc_dota_hero_muerta",
        "npc_dota_hero_slardar",
        "npc_dota_hero_necrolyte"
    }, counter = {
        "npc_dota_hero_meepo",
        "npc_dota_hero_lycan",
        "npc_dota_hero_primal_beast",
        "npc_dota_hero_pugna",
        "npc_dota_hero_beastmaster",
        "npc_dota_hero_broodmother",
        "npc_dota_hero_ember_spirit",
        "npc_dota_hero_phantom_lancer",
        "npc_dota_hero_lone_druid"
    }},
    npc_dota_hero_techies = {synergy = {
        "npc_dota_hero_naga_siren",
        "npc_dota_hero_arc_warden",
        "npc_dota_hero_lone_druid",
        "npc_dota_hero_bane",
        "npc_dota_hero_visage",
        "npc_dota_hero_broodmother",
        "npc_dota_hero_huskar"
    }, counter = {
        "npc_dota_hero_lone_druid",
        "npc_dota_hero_slark",
        "npc_dota_hero_naga_siren",
        "npc_dota_hero_meepo",
        "npc_dota_hero_marci",
        "npc_dota_hero_legion_commander",
        "npc_dota_hero_riki",
        "npc_dota_hero_beastmaster",
        "npc_dota_hero_windrunner",
        "npc_dota_hero_sven"
    }},
    npc_dota_hero_terrorblade = {synergy = {
        "npc_dota_hero_primal_beast",
        "npc_dota_hero_visage",
        "npc_dota_hero_arc_warden",
        "npc_dota_hero_shadow_demon",
        "npc_dota_hero_lone_druid",
        "npc_dota_hero_batrider",
        "npc_dota_hero_dawnbreaker",
        "npc_dota_hero_broodmother",
        "npc_dota_hero_skywrath_mage"
    }, counter = {
        "npc_dota_hero_broodmother",
        "npc_dota_hero_visage",
        "npc_dota_hero_lone_druid",
        "npc_dota_hero_slardar",
        "npc_dota_hero_templar_assassin",
        "npc_dota_hero_anti-mage",
        "npc_dota_hero_chaos_knight",
        "npc_dota_hero_viper",
        "npc_dota_hero_beastmaster"
    }},
    npc_dota_hero_templar_assassin = {synergy = {
        "npc_dota_hero_beastmaster",
        "npc_dota_hero_oracle",
        "npc_dota_hero_vengefulspirit",
        "npc_dota_hero_snapfire",
        "npc_dota_hero_abyssal_underlord",
        "npc_dota_hero_mars",
        "npc_dota_hero_muerta",
        "npc_dota_hero_disruptor"
    }, counter = {
        "npc_dota_hero_leshrac",
        "npc_dota_hero_obsidian_destroyer",
        "npc_dota_hero_sven",
        "npc_dota_hero_skywrath_mage",
        "npc_dota_hero_bloodseeker",
        "npc_dota_hero_nyx_assassin",
        "npc_dota_hero_shredder",
        "npc_dota_hero_night_stalker",
        "npc_dota_hero_oracle"
    }},
    npc_dota_hero_tidehunter = {synergy = {
        "npc_dota_hero_shredder",
        "npc_dota_hero_bloodseeker",
        "npc_dota_hero_arc_warden",
        "npc_dota_hero_alchemist",
        "npc_dota_hero_marci",
        "npc_dota_hero_nyx_assassin",
        "npc_dota_hero_spirit_breaker",
        "npc_dota_hero_slardar",
        "npc_dota_hero_omniknight"
    }, counter = {
        "npc_dota_hero_naga_siren",
        "npc_dota_hero_chaos_knight",
        "npc_dota_hero_arc_warden",
        "npc_dota_hero_earth_spirit",
        "npc_dota_hero_broodmother",
        "npc_dota_hero_lone_druid",
        "npc_dota_hero_meepo",
        "npc_dota_hero_visage",
        "npc_dota_hero_phantom_lancer"
    }},
    npc_dota_hero_tinker = {synergy = {
        "npc_dota_hero_grimstroke",
        "npc_dota_hero_beastmaster",
        "npc_dota_hero_snapfire",
        "npc_dota_hero_night_stalker",
        "npc_dota_hero_anti-mage",
        "npc_dota_hero_furion",
        "npc_dota_hero_gyrocopter",
        "npc_dota_hero_kunkka",
        "npc_dota_hero_rattletrap"
    }, counter = {
        "npc_dota_hero_terrorblade",
        "npc_dota_hero_ember_spirit",
        "npc_dota_hero_skeleton_king",
        "npc_dota_hero_phantom_lancer",
        "npc_dota_hero_meepo",
        "npc_dota_hero_keeper_of_the_light",
        "npc_dota_hero_chaos_knight",
        "npc_dota_hero_arc_warden",
        "npc_dota_hero_venomancer",
        "npc_dota_hero_viper"
    }},
    npc_dota_hero_tiny = {synergy = {
        "npc_dota_hero_dark_seer",
        "npc_dota_hero_ancient_apparition",
        "npc_dota_hero_dawnbreaker",
        "npc_dota_hero_magnataur",
        "npc_dota_hero_primal_beast",
        "npc_dota_hero_winter_wyvern",
        "npc_dota_hero_keeper_of_the_light"
    }, counter = {
        "npc_dota_hero_antimage",
        "npc_dota_hero_naga_siren",
        "npc_dota_hero_riki",
        "npc_dota_hero_axe",
        "npc_dota_hero_beastmaster",
        "npc_dota_hero_spirit_breaker",
        "npc_dota_hero_enigma",
        "npc_dota_hero_chaos_knight",
        "npc_dota_hero_dark_seer"
    }},
    npc_dota_hero_treant = {synergy = {
        "npc_dota_hero_visage",
        "npc_dota_hero_earth_spirit",
        "npc_dota_hero_ember_spirit",
        "npc_dota_hero_monkey_king",
        "npc_dota_hero_death_prophet",
        "npc_dota_hero_leshrac",
        "npc_dota_hero_dawnbreaker",
        "npc_dota_hero_obsidian_destroyer",
        "npc_dota_hero_pudge",
        "npc_dota_hero_lycan"
    }, counter = {
        "npc_dota_hero_mirana",
        "npc_dota_hero_enigma",
        "npc_dota_hero_skeleton_king",
        "npc_dota_hero_dragon_knight",
        "npc_dota_hero_legion_commander",
        "npc_dota_hero_abyssal_underlord",
        "npc_dota_hero_shadow_shaman",
        "npc_dota_hero_templar_assassin",
        "npc_dota_hero_chaos_knight"
    }},
    npc_dota_hero_troll_warlord = {synergy = {
        "npc_dota_hero_batrider",
        "npc_dota_hero_huskar",
        "npc_dota_hero_skywrath_mage",
        "npc_dota_hero_legion_commander",
        "npc_dota_hero_lycan",
        "npc_dota_hero_night_stalker",
        "npc_dota_hero_meepo",
        "npc_dota_hero_nevermore",
        "npc_dota_hero_marci"
    }, counter = {
        "npc_dota_hero_meepo",
        "npc_dota_hero_lycan",
        "npc_dota_hero_slardar",
        "npc_dota_hero_earth_spirit",
        "npc_dota_hero_marci",
        "npc_dota_hero_templar_assassin",
        "npc_dota_hero_void_spirit",
        "npc_dota_hero_ember_spirit"
    }},
    npc_dota_hero_tusk = {synergy = {
        "npc_dota_hero_visage",
        "npc_dota_hero_monkey_king",
        "npc_dota_hero_muerta",
        "npc_dota_hero_abyssal_underlord",
        "npc_dota_hero_shadow_demon",
        "npc_dota_hero_mars",
        "npc_dota_hero_bristleback",
        "npc_dota_hero_sven"
    }, counter = {
        "npc_dota_hero_sven",
        "npc_dota_hero_legion_commander",
        "npc_dota_hero_clinkz",
        "npc_dota_hero_shadow_demon",
        "npc_dota_hero_visage",
        "npc_dota_hero_obsidian_destroyer",
        "npc_dota_hero_alchemist",
        "npc_dota_hero_arc_warden",
        "npc_dota_hero_bane"
    }},
    npc_dota_hero_undying = {synergy = {
        "npc_dota_hero_winter_wyvern",
        "npc_dota_hero_batrider",
        "npc_dota_hero_axe",
        "npc_dota_hero_earth_spirit",
        "npc_dota_hero_windrunner",
        "npc_dota_hero_mars",
        "npc_dota_hero_legion_commander",
        "npc_dota_hero_sand_king",
        "npc_dota_hero_disruptor"
    }, counter = {
        "npc_dota_hero_spectre",
        "npc_dota_hero_lone_druid",
        "npc_dota_hero_abaddon",
        "npc_dota_hero_leshrac",
        "npc_dota_hero_beastmaster",
        "npc_dota_hero_shadow_demon",
        "npc_dota_hero_centaur",
        "npc_dota_hero_skeleton_king",
        "npc_dota_hero_primal_beast",
        "npc_dota_hero_death_prophet"
    }},
    npc_dota_hero_ursa = {synergy = {
        "npc_dota_hero_alchemist",
        "npc_dota_hero_mars",
        "npc_dota_hero_primal_beast",
        "npc_dota_hero_earth_spirit",
        "npc_dota_hero_kunkka",
        "npc_dota_hero_oracle",
        "npc_dota_hero_snapfire",
        "npc_dota_hero_phoenix",
        "npc_dota_hero_shredder",
        "npc_dota_hero_leshrac"
    }, counter = {
        "npc_dota_hero_bloodseeker",
        "npc_dota_hero_shredder",
        "npc_dota_hero_pudge",
        "npc_dota_hero_leshrac",
        "npc_dota_hero_tidehunter",
        "npc_dota_hero_juggernaut",
        "npc_dota_hero_lycan",
        "npc_dota_hero_anti-mage",
        "npc_dota_hero_abyssal_underlord",
        "npc_dota_hero_rubick"
    }},
    npc_dota_hero_vengefulspirit = {synergy = {
        "npc_dota_hero_lone_druid",
        "npc_dota_hero_drow_ranger",
        "npc_dota_hero_templar_assassin",
        "npc_dota_hero_muerta",
        "npc_dota_hero_tiny",
        "npc_dota_hero_warlock",
        "npc_dota_hero_meepo",
        "npc_dota_hero_sniper",
        "npc_dota_hero_luna"
    }, counter = {
        "npc_dota_hero_legion_commander",
        "npc_dota_hero_clinkz",
        "npc_dota_hero_bloodseeker",
        "npc_dota_hero_weaver",
        "npc_dota_hero_shredder",
        "npc_dota_hero_furion",
        "npc_dota_hero_skywrath_mage",
        "npc_dota_hero_enchantress",
        "npc_dota_hero_death_prophet"
    }},
    npc_dota_hero_venomancer = {synergy = {
        "npc_dota_hero_pudge",
        "npc_dota_hero_earth_spirit",
        "npc_dota_hero_drow_ranger",
        "npc_dota_hero_ember_spirit",
        "npc_dota_hero_void_spirit",
        "npc_dota_hero_arc_warden",
        "npc_dota_hero_obsidian_destroyer",
        "npc_dota_hero_centaur"
    }, counter = {
        "npc_dota_hero_axe",
        "npc_dota_hero_visage",
        "npc_dota_hero_tiny",
        "npc_dota_hero_kunkka",
        "npc_dota_hero_lone_druid",
        "npc_dota_hero_mars",
        "npc_dota_hero_spirit_breaker",
        "npc_dota_hero_dragon_knight",
        "npc_dota_hero_night_stalker",
        "npc_dota_hero_chaos_knight"
    }},
    npc_dota_hero_viper = {synergy = {
        "npc_dota_hero_faceless_void",
        "npc_dota_hero_naga_siren",
        "npc_dota_hero_omniknight",
        "npc_dota_hero_primal_beast",
        "npc_dota_hero_magnataur",
        "npc_dota_hero_mirana",
        "npc_dota_hero_meepo",
        "npc_dota_hero_dark_seer"
    }, counter = {
        "npc_dota_hero_huskar",
        "npc_dota_hero_bristleback",
        "npc_dota_hero_beastmaster",
        "npc_dota_hero_tiny",
        "npc_dota_hero_dragon_knight",
        "npc_dota_hero_spectre",
        "npc_dota_hero_necrolyte",
        "npc_dota_hero_visage",
        "npc_dota_hero_night_stalker"
    }},
    npc_dota_hero_visage = {synergy = {
        "npc_dota_hero_terrorblade",
        "npc_dota_hero_batrider",
        "npc_dota_hero_luna",
        "npc_dota_hero_shadow_demon",
        "npc_dota_hero_meepo",
        "npc_dota_hero_grimstroke",
        "npc_dota_hero_broodmother",
        "npc_dota_hero_omniknight"
    }, counter = {
        "npc_dota_hero_leshrac",
        "npc_dota_hero_shadow_demon",
        "npc_dota_hero_life_stealer",
        "npc_dota_hero_obsidian_destroyer",
        "npc_dota_hero_night_stalker",
        "npc_dota_hero_oracle",
        "npc_dota_hero_batrider",
        "npc_dota_hero_beastmaster",
        "npc_dota_hero_juggernaut"
    }},
    npc_dota_hero_void_spirit = {synergy = {
        "npc_dota_hero_medusa",
        "npc_dota_hero_keeper_of_the_light",
        "npc_dota_hero_ancient_apparition",
        "npc_dota_hero_snapfire",
        "npc_dota_hero_luna",
        "npc_dota_hero_alchemist",
        "npc_dota_hero_phoenix",
        "npc_dota_hero_jakiro",
        "npc_dota_hero_winter_wyvern"
    }, counter = {
        "npc_dota_hero_ancient_apparition",
        "npc_dota_hero_clinkz",
        "npc_dota_hero_queenofpain",
        "npc_dota_hero_mars",
        "npc_dota_hero_juggernaut",
        "npc_dota_hero_sniper",
        "npc_dota_hero_pudge",
        "npc_dota_hero_invoker",
        "npc_dota_hero_bristleback",
        "npc_dota_hero_phantom_assassin"
    }},
    npc_dota_hero_warlock = {synergy = {
        "npc_dota_hero_bane",
        "npc_dota_hero_riki",
        "npc_dota_hero_spirit_breaker",
        "npc_dota_hero_ogre_magi",
        "npc_dota_hero_enchantress",
        "npc_dota_hero_earth_spirit",
        "npc_dota_hero_shadow_shaman",
        "npc_dota_hero_vengefulspirit",
        "npc_dota_hero_sven",
        "npc_dota_hero_slardar"
    }, counter = {
        "npc_dota_hero_phantom_lancer",
        "npc_dota_hero_meepo",
        "npc_dota_hero_naga_siren",
        "npc_dota_hero_chaos_knight",
        "npc_dota_hero_omniknight",
        "npc_dota_hero_enigma",
        "npc_dota_hero_arc_warden",
        "npc_dota_hero_lone_druid",
        "npc_dota_hero_medusa",
        "npc_dota_hero_beastmaster"
    }},
    npc_dota_hero_weaver = {synergy = {
        "npc_dota_hero_muerta",
        "npc_dota_hero_bloodseeker",
        "npc_dota_hero_luna",
        "npc_dota_hero_visage",
        "npc_dota_hero_spectre",
        "npc_dota_hero_sand_king",
        "npc_dota_hero_shadow_shaman",
        "npc_dota_hero_treant",
        "npc_dota_hero_axe"
    }, counter = {
        "npc_dota_hero_shredder",
        "npc_dota_hero_warlock",
        "npc_dota_hero_ursa",
        "npc_dota_hero_primal_beast",
        "npc_dota_hero_razor",
        "npc_dota_hero_venomancer",
        "npc_dota_hero_lone_druid",
        "npc_dota_hero_dazzle",
        "npc_dota_hero_lycan"
    }},
    npc_dota_hero_windrunner = {synergy = {
        "npc_dota_hero_oracle",
        "npc_dota_hero_lone_druid",
        "npc_dota_hero_abaddon",
        "npc_dota_hero_undying",
        "npc_dota_hero_batrider",
        "npc_dota_hero_warlock",
        "npc_dota_hero_sven",
        "npc_dota_hero_venomancer"
    }, counter = {
        "npc_dota_hero_troll_warlord",
        "npc_dota_hero_lone_druid",
        "npc_dota_hero_huskar",
        "npc_dota_hero_batrider",
        "npc_dota_hero_terrorblade",
        "npc_dota_hero_ursa",
        "npc_dota_hero_night_stalker",
        "npc_dota_hero_leshrac",
        "npc_dota_hero_medusa",
        "npc_dota_hero_venomancer"
    }},
    npc_dota_hero_winter_wyvern = {synergy = {
        "npc_dota_hero_broodmother",
        "npc_dota_hero_meepo",
        "npc_dota_hero_naga_siren",
        "npc_dota_hero_beastmaster",
        "npc_dota_hero_enchantress",
        "npc_dota_hero_undying",
        "npc_dota_hero_arc_warden",
        "npc_dota_hero_night_stalker",
        "npc_dota_hero_batrider",
        "npc_dota_hero_rattletrap"
    }, counter = {
        "npc_dota_hero_meepo",
        "npc_dota_hero_visage",
        "npc_dota_hero_lone_druid",
        "npc_dota_hero_legion_commander",
        "npc_dota_hero_troll_warlord",
        "npc_dota_hero_medusa",
        "npc_dota_hero_dawnbreaker",
        "npc_dota_hero_magnataur",
        "npc_dota_hero_templar_assassin"
    }},
    npc_dota_hero_witch_doctor = {synergy = {
        "npc_dota_hero_meepo",
        "npc_dota_hero_terrorblade",
        "npc_dota_hero_shadow_shaman",
        "npc_dota_hero_naga_siren",
        "npc_dota_hero_spectre",
        "npc_dota_hero_lone_druid",
        "npc_dota_hero_chaos_knight",
        "npc_dota_hero_void_spirit",
        "npc_dota_hero_phantom_lancer",
        "npc_dota_hero_grimstroke"
    }, counter = {
        "npc_dota_hero_dark_seer",
        "npc_dota_hero_axe",
        "npc_dota_hero_undying",
        "npc_dota_hero_lone_druid",
        "npc_dota_hero_bloodseeker",
        "npc_dota_hero_beastmaster",
        "npc_dota_hero_razor",
        "npc_dota_hero_abyssal_underlord",
        "npc_dota_hero_queenofpain",
        "npc_dota_hero_shredder"
    }},
    npc_dota_hero_zuus = {synergy = {
        "npc_dota_hero_legion_commander",
        "npc_dota_hero_spirit_breaker",
        "npc_dota_hero_storm_spirit",
        "npc_dota_hero_void_spirit",
        "npc_dota_hero_juggernaut",
        "npc_dota_hero_riki",
        "npc_dota_hero_witch_doctor"
    }, counter = {
        "npc_dota_hero_nevermore",
        "npc_dota_hero_monkey_king",
        "npc_dota_hero_riki",
        "npc_dota_hero_terrorblade",
        "npc_dota_hero_windrunner",
        "npc_dota_hero_doom_bringer",
        "npc_dota_hero_drow_ranger",
        "npc_dota_hero_naga_siren"
    }},
    npc_dota_hero_ringmaster = {synergy = {
        "npc_dota_hero_skeleton_king",
        "npc_dota_hero_storm_spirit",
        "npc_dota_hero_omniknight",
        "npc_dota_hero_juggernaut",
        "npc_dota_hero_meepo",
        "npc_dota_hero_puck",
        "npc_dota_hero_mars",
        "npc_dota_hero_medusa",
        "npc_dota_hero_legion_commander",
        "npc_dota_hero_sand_king"
    }, counter = {
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
        "npc_dota_hero_dragon_knight"
    }}
}
function ____exports.GetHeroMatchups(heroName, ____type)
    local matchups = heroes[heroName]
    if not matchups then
        return {}
    end
    return matchups[____type]
end
function ____exports.IsSynergy(name1, name2)
    return __TS__ArrayIncludes(
        ____exports.GetHeroMatchups(name1, "synergy"),
        name2
    )
end
function ____exports.IsCounter(name1, name2)
    return __TS__ArrayIncludes(
        ____exports.GetHeroMatchups(name1, "counter"),
        name2
    )
end
return ____exports
