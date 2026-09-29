-- D2PT 7.41f; role counts sum to 5603, header 5612. Requested migrated roles meet thresholds.
return {
    patch='7.41f', updated='2026-09-30', defaultRole='pos_5',
    source='https://dota2protracker.com/hero/Lich?section=builds',
    overviewWindow='last 8 days, 7000+', buildWindow='2026-09-15 to 2026-09-29', buildUpdated='2026-09-29',
    roles={
        pos_1={matches=4,winRate=0,skipped=true},
        pos_2={matches=7,winRate=42.9,skipped=true},
        pos_3={matches=2,winRate=50,skipped=true},
        pos_4={matches=820,winRate=46.3,rating=16,weight=40,buildMatches=1435,buildWinRate=49,skillMatches=323,skillWinRate=48.6,openingMatches=53,openingWinRate=47.2,openingObserved=1435},
        pos_5={matches=4770,winRate=49.9,rating=64,weight=94,buildMatches=7413,buildWinRate=52,skillMatches=1917,skillWinRate=54.1,openingMatches=349,openingWinRate=49,openingObserved=7412},
    },
    -- Current-tier observations only; sparse T5 uses reviewed role suitability.
    neutrals={
        pos_4={tier5Profile='support',
            neutral={
                [1]={item_dormant_curio=20.4,item_kobold_cup=16.5,item_ash_legion_shield=16,item_polliwog_charm=11.5,item_stonefeather_satchel=9.4,item_foragers_kit=8.6,item_occult_bracelet=6.7},
                [2]={item_searing_signet=32.6,item_pogo_stick=17.7,item_essence_ring=14.9,item_mana_draught=12.8,item_crippling_crossbow=2.8,item_medallion_of_courage=2.5},
                [3]={item_partisans_brand=15.3,item_spellslinger=11.3,item_psychic_headband=10.1,item_stormcrafter=6.3},
                [4]={item_conjurers_catalyst=43.1,item_enchanters_bauble=16.2,item_dandelion_amulet=9.6,item_prophets_pendulum=9.2,item_rattlecage=2.5},
                [5]={item_harmonizer=22.7,item_demonicon=18.2,item_fallen_sky=9.1,item_divine_regalia=9.1,item_spider_legs=4.5,item_minotaur_horn=4.5},
            },
            enhancement={
                [1]={item_enhancement_quickened=62.8,item_enhancement_mystical=33.4,item_enhancement_vital=3.6},
                [2]={item_enhancement_greedy=75.1,item_enhancement_keen_eyed=10.5,item_enhancement_mystical=8.6},
                [3]={item_enhancement_greedy=76.3,item_enhancement_keen_eyed=11.5,item_enhancement_mystical=7.6},
                [4]={item_enhancement_timeless=69.1,item_enhancement_keen_eyed=16.8,item_enhancement_quickened=6.5},
                [5]={item_enhancement_timeless=86.4,item_enhancement_feverish=9.1,item_enhancement_fleetfooted=4.5},
            },
        },
        pos_5={tier5Profile='support',
            neutral={
                [1]={item_dormant_curio=20.1,item_ash_legion_shield=17.7,item_kobold_cup=16.1,item_polliwog_charm=11.8,item_stonefeather_satchel=11,item_foragers_kit=8.3,item_occult_bracelet=5.5},
                [2]={item_searing_signet=31,item_pogo_stick=19.4,item_essence_ring=16.3,item_mana_draught=11,item_medallion_of_courage=3.7,item_crippling_crossbow=3.5},
                [3]={item_partisans_brand=16,item_psychic_headband=11.5,item_spellslinger=10,item_stormcrafter=5.5},
                [4]={item_conjurers_catalyst=42,item_enchanters_bauble=15.2,item_dandelion_amulet=11.8,item_prophets_pendulum=9.5,item_idol_of_screeauk=2.9},
                [5]={item_demonicon=16.8,item_dezun_bloodrite=15,item_harmonizer=8.4,item_spider_legs=7.5,item_fallen_sky=7.5,item_minotaur_horn=7.5},
            },
            enhancement={
                [1]={item_enhancement_quickened=63.1,item_enhancement_mystical=34,item_enhancement_vital=2.7},
                [2]={item_enhancement_greedy=79.2,item_enhancement_keen_eyed=9.4,item_enhancement_mystical=7.5},
                [3]={item_enhancement_greedy=77.7,item_enhancement_keen_eyed=12.5,item_enhancement_mystical=6.9},
                [4]={item_enhancement_timeless=60.3,item_enhancement_keen_eyed=25.8,item_enhancement_mystical=6.7},
                [5]={item_enhancement_timeless=81.3,item_enhancement_feverish=14,item_enhancement_fleetfooted=3.7},
            },
        },
    },
}
