-- Header 2406; role rows 2403. Mid included at 6.7%; support has no measured row (0 placeholder). Forced skipped roles use carry.
return {
    patch='7.41f', updated='2026-09-30', defaultRole='pos_1',
    source='https://dota2protracker.com/hero/Templar%20Assassin?section=builds',
    overviewWindow='last 8 days, 7000+', buildWindow='2026-09-16 to 2026-09-30', buildUpdated='2026-09-30',
    roles={
        pos_1={matches=2232,winRate=46.3,rating=31,weight=61,buildMatches=4300,buildWinRate=46.0,skillMatches=699,openingMatches=1155,openingObserved=4299},
        pos_2={matches=162,winRate=35.8,rating=28,weight=38,buildMatches=283,buildWinRate=40.0,skillMatches=15,openingMatches=31,openingObserved=282},
        pos_3={matches=5,winRate=20.0,skipped=true},
        pos_4={matches=0,winRate=0,skipped=true},
        pos_5={matches=4,winRate=75.0,skipped=true},
    },
    -- Current-tier pick frequencies; T5 uses reviewed suitability.
    neutrals={
        pos_1={tier5Profile='attack',
            neutral={
                [1]={item_possessed_mask=20.3,item_duelist_gloves=17.0,item_weighted_dice=16.9,item_dormant_curio=9.8,item_polliwog_charm=6.8,item_occult_bracelet=6.8,item_stonefeather_satchel=6.3},
                [2]={item_mana_draught=26.1,item_pogo_stick=17.6,item_medallion_of_courage=12.6,item_defiant_shell=9.7,item_crippling_crossbow=7.0},
                [3]={item_serrated_shiv=39.0,item_gunpowder_gauntlets=29.9,item_unrelenting_eye=3.7,item_psychic_headband=2.4,item_cloak_of_flames=2.3},
                [4]={item_giant_maul=35.3,item_flayers_bota=19.2,item_enchanters_bauble=10.0,item_prophets_pendulum=4.0,item_idol_of_screeauk=2.3},
                [5]={item_desolator_2=31.5,item_divine_regalia=20.4,item_minotaur_horn=18.5,item_spider_legs=9.3,item_heavy_blade=5.6,item_fallen_sky=3.7},
            },
            enhancement={
                [1]={item_enhancement_alert=70.3,item_enhancement_quickened=24.3,item_enhancement_brawny=3.2},
                [2]={item_enhancement_alert=80.9,item_enhancement_nimble=10.2,item_enhancement_quickened=8.4},
                [3]={item_enhancement_alert=88.5,item_enhancement_nimble=8.9,item_enhancement_quickened=2.2},
                [4]={item_enhancement_alert=96.4,item_enhancement_quickened=2.0,item_enhancement_nimble=1.5},
                [5]={item_enhancement_audacious=55.6,item_enhancement_evolved=29.6,item_enhancement_fleetfooted=13.0},
            },
        },
        pos_2={tier5Profile='attack',
            neutral={
                [1]={item_duelist_gloves=25.4,item_possessed_mask=16.3,item_occult_bracelet=12.7,item_weighted_dice=12.0,item_dormant_curio=10.2,item_dagger_of_ristul=7.8,item_stonefeather_satchel=4.6},
                [2]={item_mana_draught=22.3,item_medallion_of_courage=18.1,item_pogo_stick=14.9,item_defiant_shell=8.2,item_crippling_crossbow=7.4,item_essence_ring=3.9},
                [3]={item_serrated_shiv=40.0,item_gunpowder_gauntlets=25.1,item_unrelenting_eye=2.3},
                [4]={item_giant_maul=33.7,item_flayers_bota=20.2,item_enchanters_bauble=3.4,item_metamorphic_mandible=2.2,item_prophets_pendulum=2.2},
                [5]={item_divine_regalia=100.0},
            },
            enhancement={
                [1]={item_enhancement_alert=78.1,item_enhancement_quickened=17.3,item_enhancement_brawny=2.8},
                [2]={item_enhancement_alert=85.5,item_enhancement_nimble=7.4,item_enhancement_quickened=5.7},
                [3]={item_enhancement_alert=89.8,item_enhancement_nimble=6.5,item_enhancement_quickened=2.8},
                [4]={item_enhancement_alert=98.9,item_enhancement_nimble=1.1},
                [5]={item_enhancement_fleetfooted=100.0},
            },
        },
    },
}
