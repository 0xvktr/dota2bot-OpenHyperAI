-- Header 2081; role rows 2077. Mid/support samples too small; forced skipped roles use offlane.
return {
    patch='7.41f', updated='2026-09-30', defaultRole='pos_3',
    source='https://dota2protracker.com/hero/Wraith%20King?section=builds',
    overviewWindow='last 8 days, 7000+', buildWindow='2026-09-16 to 2026-09-30', buildUpdated='2026-09-30',
    roles={
        pos_1={matches=868,winRate=55.0,rating=58,weight=68,buildMatches=1510,buildWinRate=54.0,skillMatches=385,openingMatches=276,openingObserved=1510},
        pos_2={matches=11,winRate=45.5,skipped=true},
        pos_3={matches=1179,winRate=50.6,rating=41,weight=61,buildMatches=2153,buildWinRate=52.0,skillMatches=511,openingMatches=307,openingObserved=2153},
        pos_4={matches=11,winRate=18.2,skipped=true},
        pos_5={matches=8,winRate=50.0,skipped=true},
    },
    -- Current-tier pick frequencies; T5 uses reviewed suitability.
    neutrals={
        pos_1={tier5Profile='attack',
            neutral={
                [1]={item_chipped_vest=22.7,item_duelist_gloves=17.7,item_weighted_dice=13.5,item_possessed_mask=12.2,item_dormant_curio=9.5,item_dagger_of_ristul=6.7,item_occult_bracelet=6.0},
                [2]={item_defiant_shell=26.8,item_medallion_of_courage=13.0,item_poor_mans_shield=12.2,item_crippling_crossbow=8.6,item_pogo_stick=6.4,item_mana_draught=6.0},
                [3]={item_gunpowder_gauntlets=28.3,item_serrated_shiv=26.9,item_cloak_of_flames=23.6,item_unrelenting_eye=3.8,item_stormcrafter=2.7,item_jidi_pollen_bag=2.3},
                [4]={item_giant_maul=32.6,item_flayers_bota=17.5,item_rattlecage=8.7,item_prophets_pendulum=6.6},
                [5]={item_desolator_2=32.3,item_fallen_sky=16.1,item_minotaur_horn=12.9,item_spider_legs=9.7,item_divine_regalia=9.7,item_demonicon=3.2},
            },
            enhancement={
                [1]={item_enhancement_tough=76.4,item_enhancement_quickened=11.4,item_enhancement_brawny=7.2},
                [2]={item_enhancement_tough=82.6,item_enhancement_quickened=6.7,item_enhancement_crude=6.1},
                [3]={item_enhancement_tough=83.1,item_enhancement_crude=9.8,item_enhancement_quickened=4.3},
                [4]={item_enhancement_tough=71.8,item_enhancement_crude=16.6,item_enhancement_quickened=7.6},
                [5]={item_enhancement_evolved=48.4,item_enhancement_fleetfooted=45.2,item_enhancement_timeless=6.5},
            },
        },
        pos_3={tier5Profile='attack',
            neutral={
                [1]={item_chipped_vest=24.1,item_duelist_gloves=18.4,item_weighted_dice=11.3,item_possessed_mask=10.0,item_dormant_curio=8.8,item_occult_bracelet=6.6,item_dagger_of_ristul=5.1},
                [2]={item_defiant_shell=26.1,item_poor_mans_shield=13.6,item_medallion_of_courage=10.9,item_crippling_crossbow=10.0,item_pogo_stick=4.8},
                [3]={item_gunpowder_gauntlets=28.2,item_cloak_of_flames=26.0,item_serrated_shiv=22.7,item_unrelenting_eye=3.5,item_stormcrafter=3.1,item_jidi_pollen_bag=2.8},
                [4]={item_giant_maul=31.5,item_rattlecage=10.1,item_flayers_bota=9.4,item_prophets_pendulum=6.3},
                [5]={item_desolator_2=33.3,item_spider_legs=11.1,item_demonicon=11.1,item_fallen_sky=11.1,item_divine_regalia=11.1,item_minotaur_horn=5.6},
            },
            enhancement={
                [1]={item_enhancement_tough=65.2,item_enhancement_quickened=16.2,item_enhancement_brawny=14.9},
                [2]={item_enhancement_tough=76.8,item_enhancement_brawny=9.8,item_enhancement_quickened=9.0},
                [3]={item_enhancement_tough=79.3,item_enhancement_brawny=8.5,item_enhancement_crude=6.0},
                [4]={item_enhancement_tough=69.3,item_enhancement_quickened=12.5,item_enhancement_brawny=8.6},
                [5]={item_enhancement_evolved=66.7,item_enhancement_fleetfooted=22.2,item_enhancement_vampiric=11.1},
            },
        },
    },
}
