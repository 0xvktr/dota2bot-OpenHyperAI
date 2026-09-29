-- D2PT 7.41f, retrieved 2026-09-27: https://dota2protracker.com/hero/Underlord
-- Role overview: last 8 days. Selected build: Sep 15-27 (12 days).
-- Displayed role counts sum to 2760; the overview header reports 2765.
return {
    patch = '7.41f',
    updated = '2026-09-27',
    defaultRole = 'pos_3',
    roles = {
        pos_1 = { matches=4, winRate=50.0, skipped=true },
        pos_2 = { matches=29, winRate=34.5, skipped=true },
        -- Role concentration alone must not outweigh a 45.3% win rate.
        pos_3 = { matches=2696, winRate=45.3, rating=24, weight=54, buildMatches=4202 },
        pos_4 = { matches=18, winRate=33.3, skipped=true },
        pos_5 = { matches=13, winRate=53.8, skipped=true },
    },
    neutrals = {
        pos_3 = { tier5Profile="caster", -- Updated to 7.41f; pick percentages, not win-rate rankings.
            neutral = {
                [1] = { item_chipped_vest=22.9, item_polliwog_charm=13.0, item_occult_bracelet=11.7, item_dormant_curio=10.9, item_ash_legion_shield=9.6 },
                [2] = { item_searing_signet=35.4, item_mana_draught=19.2, item_essence_ring=8.8, item_poor_mans_shield=8.7, item_pogo_stick=6.5 },
                [3] = { item_cloak_of_flames=30.9, item_partisans_brand=13.8, item_stormcrafter=7.9, item_jidi_pollen_bag=6.0, item_gunpowder_gauntlets=5.6 },
                [4] = { item_conjurers_catalyst=42.7, item_rattlecage=12.2, item_prophets_pendulum=11.3, item_enchanters_bauble=9.9, item_dandelion_amulet=5.5 },
                -- Roughly 80 observed T5 inventories; omit retained Conjurer's Catalyst.
                [5] = { item_dezun_bloodrite=43.8, item_fallen_sky=13.8, item_demonicon=12.5, item_desolator_2=5.0, item_spider_legs=5.0 },
            },
            enhancement = {
                [1] = { item_enhancement_brawny=44.7, item_enhancement_vital=35.0, item_enhancement_quickened=17.9 },
                [2] = { item_enhancement_brawny=45.9, item_enhancement_greedy=31.3, item_enhancement_quickened=13.6 },
                [3] = { item_enhancement_brawny=42.4, item_enhancement_greedy=32.2, item_enhancement_tough=14.1 },
                [4] = { item_enhancement_timeless=55.7, item_enhancement_brawny=24.7, item_enhancement_quickened=11.7 },
                [5] = { item_enhancement_timeless=60.0, item_enhancement_evolved=28.7, item_enhancement_fleetfooted=8.8 },
            },
        },
    },
}
