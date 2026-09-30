-- Header 5469; role rows 5457. Supports only; forced picks use hard support.
return {
    patch='7.41f', updated='2026-09-30', defaultRole='pos_5',
    source='https://dota2protracker.com/hero/Ringmaster?section=builds',
    overviewWindow='last 8 days, 7000+', buildWindow='2026-09-16 to 2026-09-30', buildUpdated='2026-09-30',
    roles={
        pos_1={matches=1,winRate=0,skipped=true},
        pos_2={matches=8,winRate=25,skipped=true},
        pos_3={matches=3,winRate=33.3,skipped=true},
        pos_4={matches=2095,winRate=50.9,rating=45,weight=75,buildMatches=3761,buildWinRate=51,skillMatches=907,openingMatches=226,openingObserved=3757},
        pos_5={matches=3350,winRate=52.2,rating=68,weight=98,buildMatches=5959,buildWinRate=52,skillMatches=1360,openingMatches=405,openingObserved=5957},
    },
    -- Current-tier observations; T5 uses reviewed suitability.
    neutrals={
        pos_5={tier5Profile='support',
            neutral={
                [1]={item_dormant_curio=18.7,item_ash_legion_shield=17.2,item_polliwog_charm=15.4,item_kobold_cup=14.9,item_stonefeather_satchel=11.3,item_foragers_kit=9,item_occult_bracelet=6.1},
                [2]={item_searing_signet=25.1,item_pogo_stick=22.7,item_essence_ring=16.5,item_mana_draught=16.1,item_crippling_crossbow=4.3,item_medallion_of_courage=3.3},
                [3]={item_psychic_headband=17.3,item_partisans_brand=10.5,item_spellslinger=8.7},
                [4]={item_conjurers_catalyst=34.3,item_enchanters_bauble=14.7,item_dandelion_amulet=14,item_prophets_pendulum=12.9,item_idol_of_screeauk=5.1,item_metamorphic_mandible=2.7},
                [5]={item_fallen_sky=20.7,item_dezun_bloodrite=20.7,item_demonicon=19.5,item_minotaur_horn=7.3,item_harmonizer=7.3},
            },
            enhancement={
                [1]={item_enhancement_mystical=51.3,item_enhancement_quickened=45.8,item_enhancement_vital=2.7},
                [2]={item_enhancement_greedy=74.1,item_enhancement_keen_eyed=15.5,item_enhancement_mystical=7.7},
                [3]={item_enhancement_greedy=69.1,item_enhancement_keen_eyed=23,item_enhancement_mystical=6.1},
                [4]={item_enhancement_keen_eyed=60.2,item_enhancement_timeless=18.7,item_enhancement_mystical=12.9},
                [5]={item_enhancement_timeless=61,item_enhancement_feverish=31.7,item_enhancement_fleetfooted=7.3},
            },
        },
        pos_4={tier5Profile='support',
            neutral={
                [1]={item_dormant_curio=18.6,item_ash_legion_shield=17,item_kobold_cup=15.5,item_polliwog_charm=14.6,item_stonefeather_satchel=11.6,item_foragers_kit=8.8,item_occult_bracelet=6.1},
                [2]={item_searing_signet=25.5,item_pogo_stick=23.9,item_mana_draught=16,item_essence_ring=15.3,item_crippling_crossbow=5,item_medallion_of_courage=3.3},
                [3]={item_psychic_headband=16.3,item_partisans_brand=10.5,item_spellslinger=9.1},
                [4]={item_conjurers_catalyst=37.2,item_enchanters_bauble=14.5,item_dandelion_amulet=13,item_prophets_pendulum=12.6,item_idol_of_screeauk=4.2},
                [5]={item_dezun_bloodrite=35.6,item_spider_legs=11.1,item_demonicon=8.9,item_fallen_sky=8.9,item_minotaur_horn=6.7,item_heavy_blade=4.4},
            },
            enhancement={
                [1]={item_enhancement_mystical=52.2,item_enhancement_quickened=45,item_enhancement_vital=2.4},
                [2]={item_enhancement_greedy=75,item_enhancement_keen_eyed=13.3,item_enhancement_mystical=8.5},
                [3]={item_enhancement_greedy=70.2,item_enhancement_keen_eyed=19.9,item_enhancement_mystical=7.5},
                [4]={item_enhancement_keen_eyed=58.6,item_enhancement_timeless=20.9,item_enhancement_mystical=12.7},
                [5]={item_enhancement_timeless=46.7,item_enhancement_feverish=42.2,item_enhancement_fleetfooted=11.1},
            },
        },
    },
}
