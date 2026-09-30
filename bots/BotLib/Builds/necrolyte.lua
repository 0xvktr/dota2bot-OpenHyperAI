-- Skipped support roles use the offlane build when forced.
return {
    patch='7.41f', updated='2026-09-30', defaultRole='pos_3',
    source='https://dota2protracker.com/hero/Necrophos?section=builds',
    overviewWindow='last 8 days, 7000+', buildWindow='2026-09-16 to 2026-09-30', buildUpdated='2026-09-30',
    -- Overview header 6246; displayed role rows total 6235.
    roles={
        pos_1={matches=1761,winRate=51.9,rating=59,weight=85,buildMatches=3130,buildWinRate=52,skillMatches=1461,openingMatches=679,openingObserved=3129},
        pos_2={matches=2120,winRate=45.7,rating=30,weight=60,buildMatches=3697,buildWinRate=46,skillMatches=1476,openingMatches=492,openingObserved=3695},
        pos_3={matches=2329,winRate=46.9,rating=29,weight=59,buildMatches=4014,buildWinRate=49,skillMatches=2033,openingMatches=472,openingObserved=4013},
        pos_4={matches=12,winRate=16.7,skipped=true},
        pos_5={matches=13,winRate=23.1,skipped=true},
    },
    -- Current-tier observations only; sparse T5 picks use reviewed suitability.
    neutrals={
        pos_3={tier5Profile='caster',
            neutral={
                [1]={item_chipped_vest=23.4,item_dormant_curio=14,item_ash_legion_shield=11.7,item_stonefeather_satchel=9.5,item_occult_bracelet=8.8,item_weighted_dice=8,item_kobold_cup=7.7},
                [2]={item_searing_signet=30.8,item_essence_ring=25.1,item_pogo_stick=14.2,item_poor_mans_shield=6.9,item_crippling_crossbow=4.4},
                [3]={item_cloak_of_flames=38.7,item_stormcrafter=12.7,item_partisans_brand=11.2,item_jidi_pollen_bag=6.4,item_unrelenting_eye=6.2},
                [4]={item_conjurers_catalyst=35.5,item_prophets_pendulum=19.4,item_rattlecage=9.5,item_dandelion_amulet=9,item_enchanters_bauble=8.5,item_idol_of_screeauk=2.6},
                [5]={item_fallen_sky=29.4,item_minotaur_horn=11.8,item_dezun_bloodrite=9.8,item_harmonizer=9.8,item_divine_regalia=5.9},
            },
            enhancement={
                [1]={item_enhancement_quickened=82.6,item_enhancement_mystical=10.3,item_enhancement_vital=5.3},
                [2]={item_enhancement_quickened=43.7,item_enhancement_greedy=27.5,item_enhancement_mystical=24.8},
                [3]={item_enhancement_quickened=35.4,item_enhancement_mystical=30.8,item_enhancement_greedy=25.8},
                [4]={item_enhancement_quickened=54,item_enhancement_timeless=22.8,item_enhancement_mystical=17.2},
                [5]={item_enhancement_timeless=49,item_enhancement_feverish=21.6,item_enhancement_vampiric=17.6},
            },
        },
        pos_2={tier5Profile='caster',
            neutral={
                [1]={item_chipped_vest=22,item_dormant_curio=17.2,item_stonefeather_satchel=10.9,item_ash_legion_shield=9.8,item_occult_bracelet=9,item_weighted_dice=8.9,item_kobold_cup=7.6},
                [2]={item_searing_signet=30.4,item_essence_ring=27.5,item_pogo_stick=13.5,item_poor_mans_shield=6.5,item_crippling_crossbow=3.7},
                [3]={item_cloak_of_flames=38.3,item_stormcrafter=12.4,item_partisans_brand=11.8,item_unrelenting_eye=6.2,item_jidi_pollen_bag=5.8},
                [4]={item_conjurers_catalyst=38.4,item_prophets_pendulum=17.7,item_rattlecage=10.6,item_dandelion_amulet=8.1,item_enchanters_bauble=6.5,item_idol_of_screeauk=4.2},
                [5]={item_fallen_sky=27.5,item_minotaur_horn=15,item_demonicon=12.5,item_divine_regalia=10,item_spider_legs=7.5,item_dezun_bloodrite=7.5,item_harmonizer=7.5},
            },
            enhancement={
                [1]={item_enhancement_quickened=85.3,item_enhancement_mystical=8.8,item_enhancement_vital=3.8},
                [2]={item_enhancement_quickened=42.5,item_enhancement_mystical=30,item_enhancement_greedy=21.7},
                [3]={item_enhancement_mystical=34.8,item_enhancement_quickened=33.5,item_enhancement_greedy=20.5},
                [4]={item_enhancement_quickened=49.6,item_enhancement_timeless=29.4,item_enhancement_mystical=13.9},
                [5]={item_enhancement_timeless=55,item_enhancement_feverish=17.5,item_enhancement_vampiric=15},
            },
        },
        pos_1={tier5Profile='caster',
            neutral={
                [1]={item_chipped_vest=22.3,item_dormant_curio=16.5,item_weighted_dice=11.6,item_stonefeather_satchel=10.5,item_ash_legion_shield=8.6,item_occult_bracelet=8.4,item_kobold_cup=7.1},
                [2]={item_searing_signet=32.7,item_essence_ring=24.4,item_pogo_stick=14.1,item_poor_mans_shield=7.1,item_crippling_crossbow=4.6},
                [3]={item_cloak_of_flames=37.8,item_partisans_brand=14.3,item_stormcrafter=13.3,item_jidi_pollen_bag=5.9,item_unrelenting_eye=5.5},
                [4]={item_conjurers_catalyst=39.4,item_prophets_pendulum=18.7,item_rattlecage=9.9,item_enchanters_bauble=6.5,item_dandelion_amulet=6.1,item_idol_of_screeauk=4.2},
                [5]={item_fallen_sky=20.8,item_minotaur_horn=18.8,item_dezun_bloodrite=10.4,item_divine_regalia=8.3,item_demonicon=6.3},
            },
            enhancement={
                [1]={item_enhancement_quickened=88.8,item_enhancement_mystical=7.7,item_enhancement_vital=2.3},
                [2]={item_enhancement_quickened=51.8,item_enhancement_greedy=24.6,item_enhancement_mystical=19.8},
                [3]={item_enhancement_quickened=41.5,item_enhancement_mystical=26.7,item_enhancement_greedy=22.4},
                [4]={item_enhancement_quickened=54.6,item_enhancement_timeless=28.1,item_enhancement_mystical=11.4},
                [5]={item_enhancement_timeless=60.4,item_enhancement_vampiric=14.6,item_enhancement_feverish=12.5},
            },
        },
    },
}
