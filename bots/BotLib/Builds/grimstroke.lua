-- D2PT 7.41f; role counts sum to 4711, header 4719. Requested supports meet sample/share thresholds.
return {
    patch='7.41f', updated='2026-09-30', defaultRole='pos_5',
    source='https://dota2protracker.com/hero/Grimstroke?section=builds',
    overviewWindow='last 8 days, 7000+', buildWindow='2026-09-15 to 2026-09-29', buildUpdated='2026-09-29',
    roles={
        pos_1={matches=3,winRate=33.3,skipped=true},
        pos_2={matches=129,winRate=48.8,skipped=true},
        pos_3={matches=28,winRate=35.7,skipped=true},
        pos_4={matches=2274,winRate=51.4,rating=50,weight=80,buildMatches=3482,buildWinRate=55,skillMatches=299,openingMatches=160,openingObserved=3481},
        pos_5={matches=2277,winRate=51.2,rating=54,weight=84,buildMatches=3737,buildWinRate=51,skillMatches=259,openingMatches=289,openingObserved=3737},
    },
    -- Current-tier observations only; sparse T5 uses reviewed support suitability.
    neutrals={
        pos_4={tier5Profile='support',
            neutral={
                [1]={item_dormant_curio=20,item_kobold_cup=16.4,item_ash_legion_shield=15,item_polliwog_charm=13.8,item_stonefeather_satchel=10.9,item_foragers_kit=8.8,item_occult_bracelet=5.6},
                [2]={item_searing_signet=28.3,item_mana_draught=20.4,item_pogo_stick=18.9,item_essence_ring=11.4,item_crippling_crossbow=5.5,item_medallion_of_courage=3.3},
                [3]={item_psychic_headband=13.4,item_partisans_brand=13.3,item_spellslinger=12.6},
                [4]={item_conjurers_catalyst=41.3,item_enchanters_bauble=16,item_dandelion_amulet=10.9,item_prophets_pendulum=10.8,item_idol_of_screeauk=5.1},
                [5]={item_demonicon=21.6,item_fallen_sky=19.6,item_dezun_bloodrite=11.8,item_harmonizer=9.8,item_spider_legs=5.9},
            },
            enhancement={
                [1]={item_enhancement_mystical=53.8,item_enhancement_quickened=44.4,item_enhancement_vital=1.6},
                [2]={item_enhancement_greedy=79.4,item_enhancement_keen_eyed=10.1,item_enhancement_mystical=7.6},
                [3]={item_enhancement_greedy=76.4,item_enhancement_keen_eyed=15.8,item_enhancement_mystical=5.9},
                [4]={item_enhancement_keen_eyed=43,item_enhancement_timeless=35.5,item_enhancement_mystical=11.6},
                [5]={item_enhancement_timeless=76.5,item_enhancement_feverish=17.6,item_enhancement_fleetfooted=5.9},
            },
        },
        pos_5={tier5Profile='support',
            neutral={
                [1]={item_dormant_curio=20.8,item_ash_legion_shield=15.6,item_kobold_cup=15,item_polliwog_charm=12.4,item_stonefeather_satchel=10.8,item_foragers_kit=10,item_occult_bracelet=6},
                [2]={item_searing_signet=26.4,item_mana_draught=20,item_pogo_stick=17.4,item_essence_ring=11.8,item_crippling_crossbow=5.3,item_medallion_of_courage=3.8},
                [3]={item_psychic_headband=13.2,item_spellslinger=11.7,item_partisans_brand=10.3},
                [4]={item_conjurers_catalyst=37.8,item_enchanters_bauble=17.6,item_prophets_pendulum=9.3,item_dandelion_amulet=9,item_idol_of_screeauk=5.1},
                [5]={item_demonicon=19.4,item_dezun_bloodrite=16.4,item_harmonizer=10.4,item_fallen_sky=7.5,item_spider_legs=6},
            },
            enhancement={
                [1]={item_enhancement_mystical=55.7,item_enhancement_quickened=42.5,item_enhancement_vital=1.7},
                [2]={item_enhancement_greedy=78.9,item_enhancement_keen_eyed=10.9,item_enhancement_mystical=7.2},
                [3]={item_enhancement_greedy=75.9,item_enhancement_keen_eyed=15,item_enhancement_mystical=6.4},
                [4]={item_enhancement_keen_eyed=43.6,item_enhancement_timeless=32.5,item_enhancement_mystical=14.8},
                [5]={item_enhancement_timeless=64.2,item_enhancement_feverish=20.9,item_enhancement_fleetfooted=11.9},
            },
        },
    },
}
