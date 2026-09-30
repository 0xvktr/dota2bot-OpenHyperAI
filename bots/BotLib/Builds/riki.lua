-- Skipped roles use the carry build when forced.
return {
    patch='7.41f', updated='2026-09-30', defaultRole='pos_1',
    source='https://dota2protracker.com/hero/Riki?section=builds',
    overviewWindow='last 8 days, 7000+', buildWindow='2026-09-16 to 2026-09-30', buildUpdated='2026-09-30',
    -- Overview header 1217; displayed role rows total 1216.
    roles={
        pos_1={matches=514,winRate=53.7,rating=44,weight=52,buildMatches=806,buildWinRate=55,skillMatches=308,openingMatches=243,openingObserved=806},
        pos_2={matches=420,winRate=55.7,rating=46,weight=51,buildMatches=753,buildWinRate=53,skillMatches=178,openingMatches=46,openingObserved=753},
        pos_3={matches=107,winRate=43.9,skipped=true},
        pos_4={matches=148,winRate=37.8,skipped=true},
        pos_5={matches=27,winRate=48.1,skipped=true},
    },
    -- Current-tier observations only; sparse T5 picks use reviewed suitability.
    neutrals={
        pos_1={tier5Profile='attack',
            neutral={
                [1]={item_duelist_gloves=21.4,item_possessed_mask=18.3,item_weighted_dice=12.8,item_dormant_curio=9.3,item_occult_bracelet=7.2,item_stonefeather_satchel=7.2,item_polliwog_charm=7.1},
                [2]={item_mana_draught=23.4,item_medallion_of_courage=17.3,item_crippling_crossbow=15,item_defiant_shell=10.5,item_poor_mans_shield=8.2},
                [3]={item_serrated_shiv=31.6,item_gunpowder_gauntlets=26.6,item_cloak_of_flames=9.7,item_partisans_brand=4.7,item_unrelenting_eye=4.2,item_stormcrafter=2.5},
                [4]={item_giant_maul=29.7,item_enchanters_bauble=12.8,item_flayers_bota=11.3,item_prophets_pendulum=8.9,item_dandelion_amulet=6.7},
                [5]={item_desolator_2=36.4,item_divine_regalia=18.2,item_minotaur_horn=9.1,item_heavy_blade=9.1,item_dezun_bloodrite=9.1},
            },
            enhancement={
                [1]={item_enhancement_alert=56.1,item_enhancement_brawny=24.5,item_enhancement_quickened=12.3},
                [2]={item_enhancement_alert=67.2,item_enhancement_nimble=17.4,item_enhancement_brawny=10.3},
                [3]={item_enhancement_alert=69.2,item_enhancement_nimble=17.6,item_enhancement_brawny=9.7},
                [4]={item_enhancement_alert=84.7,item_enhancement_nimble=8.9,item_enhancement_quickened=4.3},
                [5]={item_enhancement_evolved=72.7,item_enhancement_audacious=18.2,item_enhancement_fleetfooted=9.1},
            },
        },
        pos_2={tier5Profile='attack',
            neutral={
                [1]={item_duelist_gloves=26.5,item_possessed_mask=15.2,item_dormant_curio=11.2,item_weighted_dice=9.1,item_stonefeather_satchel=7.7,item_occult_bracelet=5.9,item_dagger_of_ristul=5.6},
                [2]={item_mana_draught=19.6,item_medallion_of_courage=14.6,item_defiant_shell=12,item_crippling_crossbow=10.2,item_poor_mans_shield=9.4,item_essence_ring=7.9},
                [3]={item_serrated_shiv=33.6,item_gunpowder_gauntlets=28.9,item_cloak_of_flames=5.9,item_unrelenting_eye=4.3,item_stormcrafter=3.8},
                [4]={item_giant_maul=32.1,item_flayers_bota=10.7,item_enchanters_bauble=8.1,item_dandelion_amulet=7,item_prophets_pendulum=3.7},
                [5]={item_demonicon=30,item_desolator_2=20,item_minotaur_horn=20,item_heavy_blade=20,item_spider_legs=10},
            },
            enhancement={
                [1]={item_enhancement_alert=60.6,item_enhancement_brawny=18.5,item_enhancement_quickened=17.4},
                [2]={item_enhancement_alert=68.9,item_enhancement_nimble=13.9,item_enhancement_brawny=9.9},
                [3]={item_enhancement_alert=72.7,item_enhancement_nimble=15,item_enhancement_brawny=7.7},
                [4]={item_enhancement_alert=86.7,item_enhancement_nimble=6.6,item_enhancement_quickened=4.4},
                [5]={item_enhancement_evolved=100},
            },
        },
    },
}
