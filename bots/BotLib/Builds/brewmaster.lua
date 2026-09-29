-- D2PT 7.41f: https://dota2protracker.com/hero/Brewmaster?section=builds
-- Retrieved 2026-09-29. Overview: last 8 days; builds: Sep 15-28, updated Sep 28.
-- Role counts sum to 2332; overview reports 2,335. Weights: sample-scaled D2PT role rating, see aba_hero_pos_weights.ts.
-- Pos 2 is 90 matches = 3.9% of the hero (below the 5% share rule) with a 116-match build sample: migrated on request, review before trusting.
-- Neutrals exclude retained lower-tier items and items neither bot pool can award; T5 samples are tiny,
-- so the reviewed suitability profile breaks ties and fills gaps.
return {
    patch='7.41f', updated='2026-09-29', defaultRole='pos_3',
    roles={
        pos_1={matches=6,winRate=16.7,skipped=true},
        pos_2={matches=90,winRate=55.6,rating=35,weight=37,buildMatches=116},
        pos_3={matches=2172,winRate=52.5,rating=54,weight=84,buildMatches=2518},
        pos_4={matches=39,winRate=43.6,skipped=true},
        pos_5={matches=25,winRate=60,skipped=true},
    },
    neutrals={
        pos_2={tier5Profile='tank',
            neutral={
                [1]={item_occult_bracelet=21.6,item_chipped_vest=19,item_duelist_gloves=10.3,item_possessed_mask=9.5,item_stonefeather_satchel=9.5,item_polliwog_charm=7.8,item_dormant_curio=6.9},
                [2]={item_searing_signet=32.5,item_mana_draught=21.1,item_poor_mans_shield=8.8,item_defiant_shell=7.9,item_medallion_of_courage=4.4,item_pogo_stick=4.4,item_essence_ring=3.5},
                [3]={item_cloak_of_flames=41.6,item_stormcrafter=24.7,item_serrated_shiv=6.7,item_unrelenting_eye=4.5,item_gunpowder_gauntlets=3.4},
                [4]={item_conjurers_catalyst=13.5,item_flayers_bota=8.1,item_prophets_pendulum=5.4,item_dandelion_amulet=5.4},
                [5]={item_desolator_2=33.3,item_minotaur_horn=33.3,item_riftshadow_prism=33.3},
            },
            enhancement={
                [1]={item_enhancement_mystical=57.8,item_enhancement_quickened=29.3,item_enhancement_alert=10.3},
                [2]={item_enhancement_mystical=68.4,item_enhancement_quickened=14,item_enhancement_alert=13.2},
                [3]={item_enhancement_mystical=60.7,item_enhancement_alert=18,item_enhancement_quickened=15.7},
                [4]={item_enhancement_mystical=54.1,item_enhancement_alert=29.7,item_enhancement_timeless=8.1},
                [5]={item_enhancement_evolved=100},
            },
        },
        pos_3={tier5Profile='tank',
            neutral={
                [1]={item_chipped_vest=20,item_occult_bracelet=11.9,item_polliwog_charm=10.6,item_duelist_gloves=10.3,item_dormant_curio=9.5,item_possessed_mask=8.7,item_weighted_dice=6.9},
                [2]={item_searing_signet=24,item_mana_draught=19.9,item_poor_mans_shield=8.9,item_essence_ring=8.8,item_pogo_stick=8.3,item_crippling_crossbow=8.2,item_defiant_shell=5.9},
                [3]={item_cloak_of_flames=43.5,item_stormcrafter=12.7,item_gunpowder_gauntlets=12.1,item_serrated_shiv=7.7,item_jidi_pollen_bag=6.2,item_unrelenting_eye=2.8},
                [4]={item_prophets_pendulum=17.1,item_conjurers_catalyst=15.2,item_giant_maul=12.3,item_rattlecage=8.7,item_dandelion_amulet=7.5,item_enchanters_bauble=4.7},
                [5]={item_demonicon=33.3,item_fallen_sky=20,item_desolator_2=10,item_spider_legs=10,item_minotaur_horn=10,item_riftshadow_prism=6.7},
            },
            enhancement={
                [1]={item_enhancement_mystical=46.2,item_enhancement_alert=24.5,item_enhancement_quickened=18.2},
                [2]={item_enhancement_mystical=47.8,item_enhancement_alert=21.3,item_enhancement_greedy=16.9},
                [3]={item_enhancement_mystical=40.6,item_enhancement_alert=26.5,item_enhancement_greedy=18.3},
                [4]={item_enhancement_alert=36.6,item_enhancement_mystical=26,item_enhancement_quickened=21.9},
                [5]={item_enhancement_fleetfooted=36.7,item_enhancement_evolved=36.7,item_enhancement_manic=13.3},
            },
        },
    },
}
