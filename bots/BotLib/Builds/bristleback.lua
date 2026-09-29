-- D2PT 7.41f: https://dota2protracker.com/hero/Bristleback?section=builds
-- Retrieved 2026-09-29. Overview: last 8 days; builds: Sep 15-28, updated Sep 28.
-- Role counts sum to 944; overview reports 945. Weights: sample-scaled D2PT role rating, see aba_hero_pos_weights.ts.
-- Pos 3 wins only 43.4% (rating 21); pos 1 rates higher but has just 69 carry matches, so it weighs less.
-- Pos 1 build sample is small (98 matches; 34 for the skill order).
-- Neutrals exclude retained lower-tier items and items neither bot pool can award; T5 samples are tiny,
-- so the reviewed suitability profile breaks ties and fills gaps.
return {
    patch='7.41f', updated='2026-09-29', defaultRole='pos_3',
    roles={
        pos_1={matches=69,winRate=50.7,rating=33,weight=36,buildMatches=98},
        pos_2={matches=39,winRate=56.4,skipped=true},
        pos_3={matches=821,winRate=43.4,rating=21,weight=43,buildMatches=1417},
        pos_4={matches=4,winRate=50,skipped=true},
        pos_5={matches=11,winRate=18.2,skipped=true},
    },
    neutrals={
        pos_1={tier5Profile='tank',
            neutral={
                [1]={item_chipped_vest=22.7,item_occult_bracelet=20.6,item_polliwog_charm=11.3,item_stonefeather_satchel=10.3,item_foragers_kit=10.3,item_dormant_curio=7.2,item_possessed_mask=6.2},
                [2]={item_mana_draught=29.5,item_poor_mans_shield=22.1,item_medallion_of_courage=13.7,item_essence_ring=6.3,item_defiant_shell=6.3},
                [3]={item_cloak_of_flames=27.4,item_serrated_shiv=20.5,item_unrelenting_eye=9.6,item_stormcrafter=8.2,item_gunpowder_gauntlets=8.2,item_spellslinger=5.5},
                [4]={item_giant_maul=20.6,item_flayers_bota=14.7,item_prophets_pendulum=14.7,item_conjurers_catalyst=14.7,item_rattlecage=8.8,item_dandelion_amulet=5.9},
                [5]={},
            },
            enhancement={
                [1]={item_enhancement_vital=63.9,item_enhancement_brawny=25.8,item_enhancement_quickened=10.3},
                [2]={item_enhancement_brawny=70.5,item_enhancement_tough=15.8,item_enhancement_quickened=5.3},
                [3]={item_enhancement_brawny=49.3,item_enhancement_tough=34.2,item_enhancement_quickened=11},
                [4]={item_enhancement_brawny=38.2,item_enhancement_tough=38.2,item_enhancement_quickened=14.7},
                [5]={item_enhancement_hulking=100},
            },
        },
        pos_3={tier5Profile='tank',
            neutral={
                [1]={item_chipped_vest=24.5,item_occult_bracelet=14.5,item_polliwog_charm=14.3,item_ash_legion_shield=9.8,item_duelist_gloves=7.4,item_possessed_mask=7.2,item_dormant_curio=6},
                [2]={item_poor_mans_shield=20.2,item_mana_draught=18,item_essence_ring=16.1,item_defiant_shell=10.3,item_medallion_of_courage=6.8,item_crippling_crossbow=6},
                [3]={item_cloak_of_flames=33.6,item_gunpowder_gauntlets=15.4,item_unrelenting_eye=10.1,item_serrated_shiv=6.7,item_stormcrafter=6.1,item_partisans_brand=5.5,item_jidi_pollen_bag=3.7},
                [4]={item_rattlecage=23.9,item_prophets_pendulum=18.5,item_conjurers_catalyst=15.1,item_giant_maul=11.8,item_dandelion_amulet=5.8,item_enchanters_bauble=5.2},
                [5]={item_minotaur_horn=40,item_desolator_2=30,item_spider_legs=10,item_fallen_sky=10,item_harmonizer=10},
            },
            enhancement={
                [1]={item_enhancement_vital=47.6,item_enhancement_brawny=40.3,item_enhancement_quickened=11.2},
                [2]={item_enhancement_brawny=69.9,item_enhancement_tough=15.4,item_enhancement_quickened=8.1},
                [3]={item_enhancement_brawny=60.9,item_enhancement_tough=24,item_enhancement_quickened=6},
                [4]={item_enhancement_brawny=53.1,item_enhancement_tough=21.3,item_enhancement_quickened=14.4},
                [5]={item_enhancement_fleetfooted=30,item_enhancement_evolved=30,item_enhancement_vampiric=20},
            },
        },
    },
}
