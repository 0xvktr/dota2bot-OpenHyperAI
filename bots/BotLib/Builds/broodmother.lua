-- D2PT 7.41f: https://dota2protracker.com/hero/Broodmother?section=builds
-- Retrieved 2026-09-29. Overview: last 8 days; builds: Sep 15-28, updated Sep 28.
-- Role counts sum to 857; overview reports 858. Weights: sample-scaled D2PT role rating, see aba_hero_pos_weights.ts.
-- Neutrals exclude retained lower-tier items and items neither bot pool can award; T5 samples are tiny,
-- so the reviewed suitability profile breaks ties and fills gaps.
return {
    patch='7.41f', updated='2026-09-29', defaultRole='pos_2',
    roles={
        pos_1={matches=214,winRate=56.1,rating=41,weight=43,buildMatches=323},
        pos_2={matches=499,winRate=52.1,rating=43,weight=51,buildMatches=776},
        pos_3={matches=141,winRate=55.3,rating=36,weight=40,buildMatches=284},
        pos_4={matches=1,winRate=100,skipped=true},
        pos_5={matches=2,winRate=50,skipped=true},
    },
    neutrals={
        pos_2={tier5Profile='attack',
            neutral={
                [1]={item_duelist_gloves=15.5,item_possessed_mask=13.8,item_weighted_dice=12.9,item_ash_legion_shield=12.7,item_dormant_curio=10.2,item_stonefeather_satchel=9.2,item_occult_bracelet=7.4},
                [2]={item_mana_draught=23.5,item_medallion_of_courage=19.7,item_crippling_crossbow=11.4,item_essence_ring=9.7,item_defiant_shell=9.3,item_poor_mans_shield=7.4},
                [3]={item_serrated_shiv=35.6,item_gunpowder_gauntlets=22.2,item_cloak_of_flames=13.2,item_unrelenting_eye=6.1,item_jidi_pollen_bag=2.2},
                [4]={item_giant_maul=36.9,item_flayers_bota=18,item_prophets_pendulum=7.8,item_enchanters_bauble=4.6,item_idol_of_screeauk=3.7},
                [5]={item_desolator_2=60,item_minotaur_horn=20},
            },
            enhancement={
                [1]={item_enhancement_alert=45.5,item_enhancement_quickened=28.2,item_enhancement_brawny=25.5},
                [2]={item_enhancement_alert=65.8,item_enhancement_nimble=13.1,item_enhancement_brawny=10.7},
                [3]={item_enhancement_alert=77.8,item_enhancement_nimble=10.4,item_enhancement_brawny=6},
                [4]={item_enhancement_alert=91.7,item_enhancement_quickened=4.1,item_enhancement_nimble=3.7},
                [5]={item_enhancement_evolved=60,item_enhancement_audacious=40},
            },
        },
        pos_1={tier5Profile='attack',
            neutral={
                [1]={item_duelist_gloves=21.7,item_possessed_mask=15.2,item_ash_legion_shield=11.5,item_weighted_dice=9,item_stonefeather_satchel=7.8,item_chipped_vest=7.5,item_kobold_cup=5.9},
                [2]={item_mana_draught=27.9,item_medallion_of_courage=18.5,item_crippling_crossbow=14,item_defiant_shell=12.3,item_poor_mans_shield=7.1,item_essence_ring=6.5},
                [3]={item_serrated_shiv=38.3,item_gunpowder_gauntlets=28.4,item_cloak_of_flames=10.8,item_unrelenting_eye=3.2,item_jidi_pollen_bag=1.8},
                [4]={item_flayers_bota=29,item_giant_maul=28,item_prophets_pendulum=10,item_dandelion_amulet=5,item_enchanters_bauble=4,item_rattlecage=3},
                [5]={item_minotaur_horn=100},
            },
            enhancement={
                [1]={item_enhancement_alert=59.3,item_enhancement_brawny=20.2,item_enhancement_quickened=19.6},
                [2]={item_enhancement_alert=74.7,item_enhancement_nimble=9.1,item_enhancement_brawny=8.4},
                [3]={item_enhancement_alert=81.1,item_enhancement_brawny=9,item_enhancement_nimble=7.7},
                [4]={item_enhancement_alert=97,item_enhancement_quickened=1,item_enhancement_timeless=1},
                [5]={item_enhancement_evolved=100},
            },
        },
        pos_3={tier5Profile='attack',
            neutral={
                [1]={item_duelist_gloves=19.4,item_ash_legion_shield=14.4,item_possessed_mask=13,item_chipped_vest=9.2,item_weighted_dice=9.2,item_dormant_curio=8.5,item_kobold_cup=6.7},
                [2]={item_mana_draught=19.9,item_medallion_of_courage=18.5,item_crippling_crossbow=14,item_defiant_shell=10.7,item_poor_mans_shield=8.5,item_essence_ring=7.7,item_searing_signet=7.7},
                [3]={item_serrated_shiv=38.6,item_gunpowder_gauntlets=27.2,item_cloak_of_flames=8.4,item_unrelenting_eye=6.4,item_jidi_pollen_bag=3},
                [4]={item_giant_maul=34.5,item_flayers_bota=15.5,item_prophets_pendulum=11.9,item_dandelion_amulet=6,item_enchanters_bauble=4.8},
                [5]={item_divine_regalia=50,item_minotaur_horn=25,item_heavy_blade=25},
            },
            enhancement={
                [1]={item_enhancement_alert=57.7,item_enhancement_quickened=22.5,item_enhancement_brawny=18.7},
                [2]={item_enhancement_alert=72.7,item_enhancement_nimble=9.2,item_enhancement_brawny=8.9},
                [3]={item_enhancement_alert=83.7,item_enhancement_nimble=5.9,item_enhancement_brawny=5.4},
                [4]={item_enhancement_alert=92.9,item_enhancement_quickened=2.4,item_enhancement_brawny=2.4},
                [5]={item_enhancement_audacious=50,item_enhancement_evolved=50},
            },
        },
    },
}
