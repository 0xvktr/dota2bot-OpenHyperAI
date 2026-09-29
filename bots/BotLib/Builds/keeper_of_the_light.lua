-- Header 3888; displayed role counts sum to 3876. Mid/support only; forced picks use mid.
return {
    patch='7.41f', updated='2026-09-30', defaultRole='pos_2',
    source='https://dota2protracker.com/hero/Keeper%20of%20the%20Light?section=builds',
    overviewWindow='last 8 days, 7000+', buildWindow='2026-09-15 to 2026-09-29', buildUpdated='2026-09-29',
    roles={
        pos_1={matches=8,winRate=50,skipped=true},
        pos_2={matches=2386,winRate=52.8,rating=66,weight=96,buildMatches=4409,buildWinRate=53,skillMatches=2555,openingMatches=381,openingObserved=4409},
        pos_3={matches=116,winRate=44.8,skipped=true},
        pos_4={matches=1176,winRate=50,rating=42,weight=62,buildMatches=2169,buildWinRate=50,skillMatches=246,openingMatches=308,openingObserved=2165},
        pos_5={matches=190,winRate=49.5,skipped=true},
    },
    -- Current-tier observations only; T5 uses reviewed caster/support suitability.
    neutrals={
        pos_2={tier5Profile='caster',
            neutral={
                [1]={item_dormant_curio=22.2,item_kobold_cup=17.3,item_stonefeather_satchel=14.7,item_ash_legion_shield=12,item_weighted_dice=9.1,item_polliwog_charm=7.7,item_duelist_gloves=5.1},
                [2]={item_searing_signet=34.5,item_pogo_stick=20.8,item_essence_ring=15.7,item_crippling_crossbow=7.7},
                [3]={item_partisans_brand=19.6,item_psychic_headband=11.4,item_stormcrafter=6.4,item_unrelenting_eye=5.9},
                [4]={item_conjurers_catalyst=43.2,item_enchanters_bauble=18.3,item_prophets_pendulum=9.7,item_dandelion_amulet=6.9,item_idol_of_screeauk=2.7},
                [5]={item_fallen_sky=13.4,item_harmonizer=11.9,item_spider_legs=10.4,item_minotaur_horn=9,item_demonicon=7.5},
            },
            enhancement={
                [1]={item_enhancement_quickened=97.9,item_enhancement_mystical=1.3,item_enhancement_vital=0.7},
                [2]={item_enhancement_greedy=47.2,item_enhancement_keen_eyed=25.2,item_enhancement_quickened=25.1},
                [3]={item_enhancement_greedy=47.2,item_enhancement_keen_eyed=28.9,item_enhancement_quickened=21.3},
                [4]={item_enhancement_timeless=56.5,item_enhancement_keen_eyed=26.1,item_enhancement_quickened=16.6},
                [5]={item_enhancement_timeless=76.1,item_enhancement_feverish=23.9},
            },
        },
        pos_4={tier5Profile='support',
            neutral={
                [1]={item_kobold_cup=19.2,item_dormant_curio=18.5,item_ash_legion_shield=16.3,item_stonefeather_satchel=14.2,item_polliwog_charm=13.1,item_foragers_kit=5.6,item_occult_bracelet=3.8},
                [2]={item_searing_signet=27.1,item_pogo_stick=21.1,item_essence_ring=16.8,item_crippling_crossbow=7.7,item_medallion_of_courage=4.8,item_mana_draught=4.4},
                [3]={item_psychic_headband=18.1,item_partisans_brand=13.1,item_spellslinger=5.8,item_stormcrafter=5.3},
                [4]={item_conjurers_catalyst=42.6,item_enchanters_bauble=17,item_prophets_pendulum=12.2,item_dandelion_amulet=8.9,item_idol_of_screeauk=4.6},
                [5]={item_fallen_sky=31.3,item_spider_legs=12.5,item_demonicon=6.3,item_minotaur_horn=6.3,item_dezun_bloodrite=6.3},
            },
            enhancement={
                [1]={item_enhancement_quickened=95.9,item_enhancement_mystical=2.9,item_enhancement_vital=1},
                [2]={item_enhancement_greedy=81,item_enhancement_quickened=11.8,item_enhancement_keen_eyed=6.3},
                [3]={item_enhancement_greedy=79.4,item_enhancement_quickened=11.3,item_enhancement_keen_eyed=8.8},
                [4]={item_enhancement_timeless=35.6,item_enhancement_keen_eyed=32.1,item_enhancement_quickened=30.1},
                [5]={item_enhancement_timeless=62.5,item_enhancement_feverish=31.3,item_enhancement_fleetfooted=6.3},
            },
        },
    },
}
