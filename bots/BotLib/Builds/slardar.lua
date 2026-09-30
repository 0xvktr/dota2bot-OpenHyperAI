-- Header 2293; role rows 2287. Carry/support samples too small; forced skipped roles use offlane.
return {
    patch='7.41f', updated='2026-09-30', defaultRole='pos_3',
    source='https://dota2protracker.com/hero/Slardar?section=builds',
    overviewWindow='last 8 days, 7000+', buildWindow='2026-09-16 to 2026-09-30', buildUpdated='2026-09-30',
    roles={
        pos_1={matches=16,winRate=50.0,skipped=true},
        pos_2={matches=357,winRate=45.9,rating=31,weight=43,buildMatches=723,buildWinRate=47.0,skillMatches=217,openingMatches=96,openingObserved=723},
        pos_3={matches=1890,winRate=44.3,rating=15,weight=45,buildMatches=3618,buildWinRate=45.0,skillMatches=955,openingMatches=545,openingObserved=3615},
        pos_4={matches=19,winRate=36.8,skipped=true},
        pos_5={matches=5,winRate=40.0,skipped=true},
    },
    -- Current-tier pick frequencies; T5 uses reviewed suitability.
    neutrals={
        pos_2={tier5Profile='attack',
            neutral={
                [1]={item_duelist_gloves=24.4,item_chipped_vest=17.3,item_possessed_mask=13.9,item_dormant_curio=7.9,item_ash_legion_shield=6.8,item_occult_bracelet=5.8,item_stonefeather_satchel=5.7},
                [2]={item_defiant_shell=19.2,item_mana_draught=15.5,item_medallion_of_courage=14.5,item_poor_mans_shield=9.8,item_pogo_stick=8.1,item_crippling_crossbow=6.4},
                [3]={item_serrated_shiv=27.6,item_gunpowder_gauntlets=26.7,item_cloak_of_flames=20.5,item_unrelenting_eye=6.7,item_partisans_brand=2.4},
                [4]={item_giant_maul=27.7,item_rattlecage=11.6,item_flayers_bota=9.8,item_prophets_pendulum=9.8,item_idol_of_screeauk=6.7},
                [5]={item_desolator_2=50.0,item_demonicon=25.0,item_heavy_blade=25.0},
            },
            enhancement={
                [1]={item_enhancement_tough=39.5,item_enhancement_brawny=26.8,item_enhancement_quickened=24.8},
                [2]={item_enhancement_tough=65.0,item_enhancement_brawny=18.2,item_enhancement_quickened=9.7},
                [3]={item_enhancement_tough=74.8,item_enhancement_brawny=12.3,item_enhancement_crude=8.4},
                [4]={item_enhancement_tough=70.5,item_enhancement_brawny=9.4,item_enhancement_quickened=8.9},
                [5]={item_enhancement_fleetfooted=50.0,item_enhancement_evolved=50.0},
            },
        },
        pos_3={tier5Profile='attack',
            neutral={
                [1]={item_duelist_gloves=21.4,item_chipped_vest=18.5,item_possessed_mask=14.9,item_polliwog_charm=7.5,item_occult_bracelet=7.2,item_ash_legion_shield=6.6,item_weighted_dice=6.4},
                [2]={item_defiant_shell=20.9,item_mana_draught=14.8,item_medallion_of_courage=13.4,item_poor_mans_shield=11.7,item_essence_ring=7.5,item_pogo_stick=7.1,item_crippling_crossbow=6.1},
                [3]={item_gunpowder_gauntlets=30.6,item_serrated_shiv=21.8,item_cloak_of_flames=20.8,item_unrelenting_eye=5.7,item_stormcrafter=3.5,item_jidi_pollen_bag=2.5},
                [4]={item_giant_maul=27.6,item_rattlecage=12.0,item_prophets_pendulum=11.6,item_flayers_bota=9.7,item_dandelion_amulet=6.6,item_idol_of_screeauk=6.2},
                [5]={item_minotaur_horn=30.6,item_desolator_2=27.8,item_spider_legs=13.9,item_fallen_sky=13.9,item_heavy_blade=5.6,item_dezun_bloodrite=2.8},
            },
            enhancement={
                [1]={item_enhancement_tough=38.8,item_enhancement_brawny=25.2,item_enhancement_vital=18.4},
                [2]={item_enhancement_tough=61.8,item_enhancement_brawny=23.5,item_enhancement_quickened=9.4},
                [3]={item_enhancement_tough=68.7,item_enhancement_brawny=18.5,item_enhancement_quickened=6.1},
                [4]={item_enhancement_tough=60.5,item_enhancement_brawny=18.2,item_enhancement_quickened=12.5},
                [5]={item_enhancement_evolved=69.4,item_enhancement_fleetfooted=13.9,item_enhancement_timeless=11.1},
            },
        },
    },
}
