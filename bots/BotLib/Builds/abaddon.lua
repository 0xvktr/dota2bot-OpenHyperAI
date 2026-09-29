-- D2PT 7.41f, retrieved 2026-09-27: https://dota2protracker.com/hero/Abaddon
-- Role overview (matches, win rate, rating): last 8 days, re-read 2026-09-29 to record role ratings.
-- Build samples: Sep 15-27 (12 days).
-- Data only: safe to load from bot scripts AND server-side neutral distributors.
local X = {
    patch = '7.41f',
    updated = '2026-09-27',
    defaultRole = 'pos_5', -- Most-played role for modes without position assignments.
    roles = {
        -- weight: see the formula in typescript/bots/FunLib/aba_hero_pos_weights.ts.
        pos_1 = { matches = 64, winRate = 46.9, rating = 32, weight = 36, buildMatches = 92 },
        pos_2 = { matches = 1, winRate = 0, skipped = true },
        pos_3 = { matches = 152, winRate = 39.5, rating = 27, weight = 37, buildMatches = 230 },
        pos_4 = { matches = 110, winRate = 47.3, rating = 32, weight = 38, buildMatches = 143 },
        pos_5 = { matches = 599, winRate = 51.8, rating = 46, weight = 55, buildMatches = 848 },
    },
}

-- Pick percentages, not win rates: rare late-game wins are not reliable rankings.
-- Consumers intersect these with their allowed tier pool (including active-use restrictions).
-- Lower-tier items retained in later D2PT inventories are deliberately omitted.
X.neutrals = {
    pos_1 = { tier5Profile="attack", -- Updated to 7.41f
        neutral = {
            [1] = { item_possessed_mask=22.8, item_chipped_vest=16.3, item_duelist_gloves=16.3, item_weighted_dice=13.0, item_stonefeather_satchel=8.7 },
            [2] = { item_poor_mans_shield=20.7, item_mana_draught=16.1, item_defiant_shell=14.9, item_crippling_crossbow=14.9, item_medallion_of_courage=6.9 },
            [3] = { item_serrated_shiv=39.2, item_cloak_of_flames=20.3, item_gunpowder_gauntlets=12.2, item_stormcrafter=4.1, item_unrelenting_eye=4.1 },
            [4] = { item_flayers_bota=18.8, item_giant_maul=15.6, item_rattlecage=12.5, item_conjurers_catalyst=12.5, item_enchanters_bauble=9.4 },
            -- T5 rechecked 2026-09-28: ~3 observations, weak pick-frequency evidence.
            [5] = { item_heavy_blade=33.3, item_divine_regalia=33.3, item_riftshadow_prism=33.3 },
        },
        enhancement = {
            [1] = { item_enhancement_alert=52.2, item_enhancement_mystical=21.7, item_enhancement_quickened=18.5 },
            [2] = { item_enhancement_alert=75.9, item_enhancement_mystical=14.9, item_enhancement_quickened=4.6 },
            [3] = { item_enhancement_alert=83.8, item_enhancement_mystical=8.1, item_enhancement_quickened=5.4 },
            [4] = { item_enhancement_alert=100 },
            -- Vampiric is retained from a lower tier, not a T5 enchantment.
            [5] = { item_enhancement_fleetfooted=33.3, item_enhancement_evolved=33.3 },
        },
    },
    pos_3 = { tier5Profile="attack", -- Updated to 7.41f
        neutral = {
            [1] = { item_chipped_vest=20.6, item_possessed_mask=20.2, item_duelist_gloves=17.5, item_occult_bracelet=8.8, item_dormant_curio=7.0 },
            [2] = { item_defiant_shell=18.9, item_mana_draught=13.2, item_crippling_crossbow=13.2, item_poor_mans_shield=11.5, item_essence_ring=8.4 },
            [3] = { item_cloak_of_flames=28.1, item_gunpowder_gauntlets=21.3, item_serrated_shiv=19.7, item_stormcrafter=9.0, item_jidi_pollen_bag=6.2 },
            [4] = { item_giant_maul=20.2, item_conjurers_catalyst=12.4, item_prophets_pendulum=11.2, item_flayers_bota=10.1, item_rattlecage=7.9 },
            -- T5 rechecked 2026-09-28: one observation, not a win-rate ranking.
            [5] = { item_desolator_2=100 },
        },
        enhancement = {
            [1] = { item_enhancement_alert=52.2, item_enhancement_quickened=21.1, item_enhancement_mystical=18.4 },
            [2] = { item_enhancement_alert=57.3, item_enhancement_mystical=26.9, item_enhancement_quickened=11.5 },
            [3] = { item_enhancement_alert=60.1, item_enhancement_mystical=24.7, item_enhancement_quickened=9.6 },
            [4] = { item_enhancement_alert=68.5, item_enhancement_quickened=15.7, item_enhancement_mystical=7.9 },
            [5] = { item_enhancement_evolved=100 },
        },
    },
    pos_4 = { tier5Profile="support", -- Updated to 7.41f, most-played build (not the 22-match alternative)
        neutral = {
            [1] = { item_ash_legion_shield=17.6, item_polliwog_charm=16.9, item_kobold_cup=14.8, item_dormant_curio=12.7, item_chipped_vest=10.6 },
            [2] = { item_mana_draught=25.9, item_medallion_of_courage=13.3, item_essence_ring=10.4, item_pogo_stick=9.6, item_searing_signet=7.4 },
            [3] = { item_cloak_of_flames=19.8, item_psychic_headband=14.0, item_jidi_pollen_bag=8.1, item_spellslinger=8.1, item_stormcrafter=5.8 },
            [4] = { item_dandelion_amulet=20.7, item_rattlecage=13.8, item_conjurers_catalyst=13.8, item_idol_of_screeauk=10.3, item_prophets_pendulum=10.3 },
            -- No T5 observations on 2026-09-28; use the reviewed support profile.
        },
        enhancement = {
            [1] = { item_enhancement_mystical=54.2, item_enhancement_quickened=31.7, item_enhancement_vital=7.7 },
            [2] = { item_enhancement_greedy=65.2, item_enhancement_quickened=16.3, item_enhancement_mystical=12.6 },
            [3] = { item_enhancement_greedy=69.8, item_enhancement_mystical=14.0, item_enhancement_quickened=12.8 },
            [4] = { item_enhancement_quickened=51.7, item_enhancement_mystical=44.8, item_enhancement_titanic=3.4 },
        },
    },
    pos_5 = { tier5Profile="support", -- Updated to 7.41f
        neutral = {
            [1] = { item_polliwog_charm=19.4, item_ash_legion_shield=17.0, item_dormant_curio=13.7, item_foragers_kit=12.1, item_kobold_cup=10.9 },
            [2] = { item_mana_draught=25.1, item_medallion_of_courage=14.7, item_pogo_stick=10.4, item_essence_ring=9.3, item_searing_signet=7.4 },
            [3] = { item_cloak_of_flames=17.0, item_spellslinger=14.8, item_psychic_headband=8.8, item_jidi_pollen_bag=8.3, item_stormcrafter=6.8 },
            [4] = { item_prophets_pendulum=16.9, item_rattlecage=16.4, item_dandelion_amulet=16.4, item_enchanters_bauble=11.3, item_conjurers_catalyst=10.8 },
            -- T5 rechecked 2026-09-28: ~9 observations; retained T4 Bauble excluded.
            [5] = { item_demonicon=22.2, item_fallen_sky=22.2, item_heavy_blade=22.2, item_spider_legs=11.1, item_minotaur_horn=11.1 },
        },
        enhancement = {
            [1] = { item_enhancement_mystical=56.7, item_enhancement_quickened=30.0, item_enhancement_vital=11.5 },
            [2] = { item_enhancement_greedy=78.5, item_enhancement_quickened=10.6, item_enhancement_mystical=9.3 },
            [3] = { item_enhancement_greedy=77.8, item_enhancement_quickened=10.9, item_enhancement_mystical=9.6 },
            [4] = { item_enhancement_quickened=49.2, item_enhancement_mystical=38.5, item_enhancement_timeless=8.7 },
            [5] = { item_enhancement_fleetfooted=44.4, item_enhancement_evolved=33.3, item_enhancement_manic=22.2 },
        },
    },
}
return X
