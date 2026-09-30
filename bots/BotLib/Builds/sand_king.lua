-- Skipped roles use the offlane build when forced.
return {
    patch='7.41f', updated='2026-09-30', defaultRole='pos_3',
    source='https://dota2protracker.com/hero/Sand%20King?section=builds',
    overviewWindow='last 8 days, 7000+', buildWindow='2026-09-16 to 2026-09-30', buildUpdated='2026-09-30',
    -- Overview header 933; displayed role rows total 932.
    roles={
        pos_1={matches=4,winRate=25,skipped=true},
        pos_2={matches=360,winRate=45,rating=31,weight=43,buildMatches=709,buildWinRate=47,skillMatches=180,openingMatches=104,openingObserved=709},
        pos_3={matches=562,winRate=47,rating=31,weight=46,buildMatches=981,buildWinRate=49,skillMatches=163,openingMatches=152,openingObserved=981},
        pos_4={matches=2,winRate=0,skipped=true},
        pos_5={matches=4,winRate=50,skipped=true},
    },
    -- Current-tier observations only; sparse T5 picks use reviewed suitability.
    neutrals={
        pos_3={tier5Profile='caster',
            neutral={
                [1]={item_chipped_vest=18.3,item_polliwog_charm=15.3,item_occult_bracelet=10.6,item_dormant_curio=10.4,item_ash_legion_shield=9.4,item_weighted_dice=8.4,item_possessed_mask=8.3},
                [2]={item_searing_signet=33,item_mana_draught=18.7,item_essence_ring=10.7,item_pogo_stick=9.1,item_crippling_crossbow=8.6,item_poor_mans_shield=6.9},
                [3]={item_cloak_of_flames=30.5,item_gunpowder_gauntlets=16.1,item_partisans_brand=14.9,item_serrated_shiv=10.9,item_stormcrafter=7.4,item_jidi_pollen_bag=5},
                [4]={item_conjurers_catalyst=41.9,item_enchanters_bauble=9.4,item_giant_maul=9.2,item_rattlecage=7.8,item_dandelion_amulet=5.5,item_prophets_pendulum=4.6},
                [5]={item_desolator_2=28.6,item_dezun_bloodrite=23.8,item_divine_regalia=9.5,item_spider_legs=4.8,item_demonicon=4.8,item_fallen_sky=4.8},
            },
            enhancement={
                [1]={item_enhancement_mystical=41.7,item_enhancement_vital=28.2,item_enhancement_quickened=22.2},
                [2]={item_enhancement_mystical=59.4,item_enhancement_greedy=17.4,item_enhancement_quickened=12.9},
                [3]={item_enhancement_mystical=61.5,item_enhancement_titanic=12.5,item_enhancement_quickened=10.7},
                [4]={item_enhancement_timeless=75.3,item_enhancement_quickened=9.2,item_enhancement_mystical=7.6},
                [5]={item_enhancement_timeless=52.4,item_enhancement_fleetfooted=28.6,item_enhancement_vampiric=9.5},
            },
        },
        pos_2={tier5Profile='caster',
            neutral={
                [1]={item_chipped_vest=18.3,item_dormant_curio=16.2,item_polliwog_charm=10.3,item_occult_bracelet=9.2,item_stonefeather_satchel=8.7,item_weighted_dice=8.5,item_ash_legion_shield=7.9},
                [2]={item_searing_signet=35.1,item_mana_draught=18.1,item_essence_ring=10.9,item_pogo_stick=8.6,item_poor_mans_shield=5.6,item_crippling_crossbow=4.9},
                [3]={item_cloak_of_flames=29.7,item_gunpowder_gauntlets=18.8,item_partisans_brand=15,item_serrated_shiv=11.1,item_jidi_pollen_bag=6.4,item_stormcrafter=4.2},
                [4]={item_conjurers_catalyst=42.3,item_giant_maul=12.9,item_enchanters_bauble=8.7,item_prophets_pendulum=7,item_rattlecage=5.9},
                [5]={item_desolator_2=40,item_dezun_bloodrite=20,item_demonicon=10,item_fallen_sky=10,item_minotaur_horn=10},
            },
            enhancement={
                [1]={item_enhancement_mystical=44,item_enhancement_quickened=41.5,item_enhancement_vital=7.6},
                [2]={item_enhancement_mystical=64,item_enhancement_quickened=17,item_enhancement_greedy=8.7},
                [3]={item_enhancement_mystical=55.7,item_enhancement_titanic=16.9,item_enhancement_quickened=12.5},
                [4]={item_enhancement_timeless=76.9,item_enhancement_titanic=7.7,item_enhancement_quickened=7.3},
                [5]={item_enhancement_timeless=70,item_enhancement_fleetfooted=20,item_enhancement_vampiric=10},
            },
        },
    },
}
