-- Skipped roles use the carry build when forced.
return {
    patch='7.41f', updated='2026-09-30', defaultRole='pos_1',
    source='https://dota2protracker.com/hero/Phantom%20Assassin?section=builds',
    overviewWindow='last 8 days, 7000+', buildWindow='2026-09-16 to 2026-09-30', buildUpdated='2026-09-30',
    -- Overview header 2220; displayed role rows total 2215.
    roles={
        pos_1={matches=2149,winRate=48.6,rating=36,weight=66,buildMatches=3689,buildWinRate=50,skillMatches=484,openingMatches=1254,openingObserved=3689},
        pos_2={matches=32,winRate=56.3,skipped=true},
        pos_3={matches=20,winRate=20,skipped=true},
        pos_4={matches=6,winRate=50,skipped=true},
        pos_5={matches=8,winRate=37.5,skipped=true},
    },
    -- Current-tier observations only; sparse T5 picks use reviewed suitability.
    neutrals={
        pos_1={tier5Profile='attack',
            neutral={
                [1]={item_possessed_mask=22.9,item_weighted_dice=15.6,item_duelist_gloves=14.1,item_chipped_vest=11.9,item_dormant_curio=9.9,item_dagger_of_ristul=8.6,item_occult_bracelet=5},
                [2]={item_defiant_shell=20.6,item_medallion_of_courage=17.2,item_poor_mans_shield=12.6,item_mana_draught=6.3,item_crippling_crossbow=5.9},
                [3]={item_serrated_shiv=37.7,item_gunpowder_gauntlets=28.1,item_cloak_of_flames=8.4,item_unrelenting_eye=3.6},
                [4]={item_giant_maul=30.7,item_flayers_bota=21,item_prophets_pendulum=13.1,item_enchanters_bauble=6.4,item_dandelion_amulet=3.8},
                [5]={item_desolator_2=51.3,item_minotaur_horn=10.3,item_fallen_sky=7.7,item_divine_regalia=7.7,item_demonicon=5.1,item_riftshadow_prism=5.1},
            },
            enhancement={
                [1]={item_enhancement_alert=75.5,item_enhancement_brawny=14.7,item_enhancement_quickened=6.5},
                [2]={item_enhancement_alert=70.5,item_enhancement_nimble=18,item_enhancement_brawny=9.2},
                [3]={item_enhancement_alert=74.4,item_enhancement_nimble=16.9,item_enhancement_brawny=7.9},
                [4]={item_enhancement_alert=88.8,item_enhancement_nimble=7.5,item_enhancement_brawny=2.3},
                [5]={item_enhancement_evolved=48.7,item_enhancement_audacious=28.2,item_enhancement_fleetfooted=15.4},
            },
        },
    },
}
