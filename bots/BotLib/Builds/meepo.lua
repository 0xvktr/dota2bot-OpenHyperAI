-- Mid/carry; other roles below threshold. Header 990; role rows 983.
return {
    patch='7.41f', updated='2026-09-30', defaultRole='pos_2',
    source='https://dota2protracker.com/hero/Meepo?section=builds',
    overviewWindow='last 8 days, 7000+', buildWindow='2026-09-16 to 2026-09-30', buildUpdated='2026-09-30',
    roles={
        pos_1={matches=223,winRate=57.8,rating=44,weight=45,buildMatches=394,buildWinRate=60,skillMatches=124,openingMatches=102,openingObserved=393},
        pos_2={matches=723,winRate=56.4,rating=61,weight=67,buildMatches=1260,buildWinRate=55,skillMatches=195,openingMatches=173,openingObserved=1260},
        pos_3={matches=33,winRate=45.5,skipped=true},
        pos_4={matches=3,winRate=0,skipped=true},
        pos_5={matches=1,winRate=0,skipped=true},
    },
    -- Current-tier observations; T5 uses reviewed suitability.
    neutrals={
        pos_1={tier5Profile='attack',
            neutral={
                [1]={item_possessed_mask=23.5,item_weighted_dice=13.7,item_chipped_vest=13.4,item_occult_bracelet=10.6,item_duelist_gloves=10.6,item_stonefeather_satchel=9.9,item_dormant_curio=6.3},
                [2]={item_poor_mans_shield=18.3,item_medallion_of_courage=16.3,item_defiant_shell=13.4,item_crippling_crossbow=9.8,item_searing_signet=7},
                [3]={item_cloak_of_flames=25,item_serrated_shiv=23.9,item_gunpowder_gauntlets=15.1,item_unrelenting_eye=11.8,item_jidi_pollen_bag=4.8,item_partisans_brand=4},
                [4]={item_prophets_pendulum=23.9,item_giant_maul=20.2,item_rattlecage=17.4,item_enchanters_bauble=6.4,item_conjurers_catalyst=6.4},
                [5]={item_heavy_blade=100},
            },
            enhancement={
                [1]={item_enhancement_quickened=54.2,item_enhancement_alert=34.9,item_enhancement_brawny=9.1},
                [2]={item_enhancement_alert=35.7,item_enhancement_nimble=32.3,item_enhancement_quickened=15.8},
                [3]={item_enhancement_alert=46,item_enhancement_nimble=30.1,item_enhancement_quickened=15.4},
                [4]={item_enhancement_alert=72.5,item_enhancement_quickened=20.2,item_enhancement_nimble=5.5},
                [5]={item_enhancement_evolved=100},
            },
        },
        pos_2={tier5Profile='attack',
            neutral={
                [1]={item_possessed_mask=19,item_duelist_gloves=14.9,item_chipped_vest=14.6,item_stonefeather_satchel=12.3,item_weighted_dice=10.8,item_dormant_curio=7.8,item_ash_legion_shield=7.2},
                [2]={item_poor_mans_shield=16.6,item_medallion_of_courage=13.1,item_defiant_shell=10.9,item_crippling_crossbow=8.6,item_searing_signet=7.9},
                [3]={item_serrated_shiv=29.7,item_cloak_of_flames=18.8,item_gunpowder_gauntlets=13.6,item_unrelenting_eye=9.5,item_partisans_brand=4.4},
                [4]={item_giant_maul=23,item_prophets_pendulum=16.9,item_conjurers_catalyst=15.1,item_rattlecage=10.3,item_enchanters_bauble=5.4,item_dandelion_amulet=3.6},
                [5]={item_desolator_2=33.3,item_divine_regalia=33.3,item_spider_legs=16.7},
            },
            enhancement={
                [1]={item_enhancement_quickened=51.5,item_enhancement_alert=34.9,item_enhancement_brawny=12.8},
                [2]={item_enhancement_alert=41.1,item_enhancement_nimble=28.4,item_enhancement_brawny=12.5},
                [3]={item_enhancement_alert=49.2,item_enhancement_nimble=29.4,item_enhancement_brawny=11.4},
                [4]={item_enhancement_alert=59.8,item_enhancement_nimble=15.1,item_enhancement_quickened=13},
                [5]={item_enhancement_evolved=66.7,item_enhancement_audacious=33.3},
            },
        },
    },
}
