-- Skipped roles use hard support; only support roles buy observed wards.
return {
    patch='7.41f', updated='2026-09-30', defaultRole='pos_5',
    source='https://dota2protracker.com/hero/Shadow%20Shaman?section=builds',
    overviewWindow='last 8 days, 7000+', buildWindow='2026-09-16 to 2026-09-30', buildUpdated='2026-09-30',
    roles={
        pos_1={matches=1,winRate=0.0,skipped=true},
        pos_2={matches=8,winRate=25.0,skipped=true},
        pos_3={matches=4,winRate=0.0,skipped=true},
        pos_4={matches=1026,winRate=49.1,rating=38,weight=57,buildMatches=1956,buildWinRate=50.0,skillMatches=289,openingMatches=163,openingObserved=1955},
        pos_5={matches=2282,winRate=50.9,rating=53,weight=83,buildMatches=4043,buildWinRate=51.0,skillMatches=754,openingMatches=223,openingObserved=4043},
    },
    -- Current-tier observations only; sparse T5 picks use reviewed suitability.
    neutrals={
        pos_4={tier5Profile='support',
            neutral={
                [1]={item_dormant_curio=18.0,item_kobold_cup=16.7,item_ash_legion_shield=15.0,item_polliwog_charm=11.5,item_foragers_kit=10.8,item_stonefeather_satchel=10.3,item_occult_bracelet=6.5},
                [2]={item_pogo_stick=26.5,item_mana_draught=21.3,item_searing_signet=16.9,item_essence_ring=13.0,item_medallion_of_courage=3.0,item_crippling_crossbow=2.7},
                [3]={item_spellslinger=16.2,item_psychic_headband=14.3,item_stormcrafter=5.4},
                [4]={item_conjurers_catalyst=22.8,item_enchanters_bauble=20.3,item_prophets_pendulum=15.5,item_dandelion_amulet=12.8,item_idol_of_screeauk=5.2,item_rattlecage=3.1},
                [5]={item_demonicon=26.7,item_spider_legs=20.0,item_minotaur_horn=20.0,item_harmonizer=20.0,item_heavy_blade=6.7},
            },
            enhancement={
                [1]={item_enhancement_quickened=55.3,item_enhancement_mystical=42.5,item_enhancement_vital=1.9},
                [2]={item_enhancement_greedy=60.7,item_enhancement_keen_eyed=25.0,item_enhancement_mystical=8.1},
                [3]={item_enhancement_greedy=54.2,item_enhancement_keen_eyed=33.3,item_enhancement_mystical=7.5},
                [4]={item_enhancement_keen_eyed=57.1,item_enhancement_timeless=15.3,item_enhancement_mystical=14.6},
                [5]={item_enhancement_feverish=40.0,item_enhancement_timeless=40.0,item_enhancement_fleetfooted=20.0},
            },
        },
        pos_5={tier5Profile='support',
            neutral={
                [1]={item_dormant_curio=21.6,item_kobold_cup=16.1,item_ash_legion_shield=13.4,item_polliwog_charm=11.9,item_stonefeather_satchel=10.6,item_foragers_kit=7.8,item_occult_bracelet=7.2},
                [2]={item_pogo_stick=23.9,item_mana_draught=18.3,item_searing_signet=17.4,item_essence_ring=14.4,item_medallion_of_courage=4.3,item_crippling_crossbow=2.3},
                [3]={item_spellslinger=13.9,item_psychic_headband=13.5},
                [4]={item_conjurers_catalyst=20.2,item_enchanters_bauble=17.8,item_prophets_pendulum=14.1,item_dandelion_amulet=13.7,item_idol_of_screeauk=5.6,item_rattlecage=4.5},
                [5]={item_fallen_sky=31.4,item_spider_legs=14.3,item_demonicon=14.3,item_minotaur_horn=8.6,item_desolator_2=5.7,item_riftshadow_prism=5.7},
            },
            enhancement={
                [1]={item_enhancement_quickened=53.2,item_enhancement_mystical=44.6,item_enhancement_vital=2.0},
                [2]={item_enhancement_greedy=60.4,item_enhancement_keen_eyed=25.0,item_enhancement_mystical=8.6},
                [3]={item_enhancement_greedy=54.4,item_enhancement_keen_eyed=32.5,item_enhancement_mystical=8.5},
                [4]={item_enhancement_keen_eyed=55.7,item_enhancement_timeless=16.6,item_enhancement_mystical=15.2},
                [5]={item_enhancement_timeless=48.6,item_enhancement_fleetfooted=25.7,item_enhancement_feverish=20.0},
            },
        },
    },
}
