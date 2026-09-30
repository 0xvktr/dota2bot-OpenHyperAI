-- D2PT 7.41f; Pos 4 meets the sample thresholds.
return {
    patch='7.41f', updated='2026-09-30', defaultRole='pos_5',
    source='https://dota2protracker.com/hero/Oracle?section=builds',
    overviewWindow='last 8 days, 7000+', buildWindow='2026-09-16 to 2026-09-30', buildUpdated='2026-09-30',
    roles={
        pos_1={matches=0,winRate=0,skipped=true},
        pos_2={matches=54,winRate=44.4,skipped=true},
        pos_3={matches=4,winRate=0,skipped=true},
        pos_4={matches=283,winRate=53,rating=35,weight=43,buildMatches=525,buildWinRate=52,skillMatches=224,skillWinRate=54,openingMatches=21,openingWinRate=28.6,openingObserved=525},
        pos_5={matches=3009,winRate=53.5,rating=80,weight=100,buildMatches=5216,buildWinRate=54,skillMatches=2232,skillWinRate=56.5,openingMatches=351,openingWinRate=55.8,openingObserved=5215},
    },
    -- Current-tier picks; sparse T5 uses the reviewed profile.
    neutrals={
        pos_5={tier5Profile='support',
            neutral={
                [1]={item_dormant_curio=19.8,item_polliwog_charm=16.4,item_kobold_cup=16.2,item_ash_legion_shield=16.1,item_stonefeather_satchel=10.6,item_foragers_kit=8.4,item_occult_bracelet=6.4},
                [2]={item_pogo_stick=22.1,item_mana_draught=20.3,item_essence_ring=17.1,item_searing_signet=12.6,item_medallion_of_courage=6.0,item_seeds_of_serenity=4.1},
                [3]={item_psychic_headband=17.9,item_spellslinger=14.6,item_stormcrafter=4.1},
                [4]={item_prophets_pendulum=23.0,item_dandelion_amulet=16.4,item_enchanters_bauble=16.0,item_conjurers_catalyst=14.6,item_idol_of_screeauk=6.3},
                [5]={item_demonicon=30.2,item_fallen_sky=18.9,item_minotaur_horn=17.0,item_spider_legs=7.5,item_dezun_bloodrite=5.7},
            },
            enhancement={
                [1]={item_enhancement_mystical=55.8,item_enhancement_quickened=42.9,item_enhancement_vital=1.1},
                [2]={item_enhancement_greedy=70.7,item_enhancement_keen_eyed=21.0,item_enhancement_mystical=5.1},
                [3]={item_enhancement_greedy=65.7,item_enhancement_keen_eyed=27.5,item_enhancement_mystical=4.6},
                [4]={item_enhancement_keen_eyed=70.9,item_enhancement_mystical=14.4,item_enhancement_quickened=11.0},
                [5]={item_enhancement_feverish=69.8,item_enhancement_fleetfooted=22.6,item_enhancement_timeless=5.7},
            },
        },
        pos_4={tier5Profile='support',
            neutral={
                [1]={item_polliwog_charm=18.5,item_dormant_curio=18.5,item_kobold_cup=16.6,item_ash_legion_shield=13.0,item_stonefeather_satchel=12.8,item_foragers_kit=9.0,item_occult_bracelet=5.2},
                [2]={item_pogo_stick=22.2,item_mana_draught=20.0,item_searing_signet=17.5,item_essence_ring=15.5,item_seeds_of_serenity=4.8,item_medallion_of_courage=4.4},
                [3]={item_spellslinger=16.1,item_psychic_headband=15.8,item_stormcrafter=4.8},
                [4]={item_prophets_pendulum=21.7,item_dandelion_amulet=12.2,item_conjurers_catalyst=11.3,item_idol_of_screeauk=9.6,item_enchanters_bauble=9.6},
                [5]={item_fallen_sky=33.3,item_dezun_bloodrite=33.3,item_riftshadow_prism=33.3},
            },
            enhancement={
                [1]={item_enhancement_mystical=51.2,item_enhancement_quickened=47.8,item_enhancement_vital=1.0},
                [2]={item_enhancement_greedy=64.1,item_enhancement_keen_eyed=25.4,item_enhancement_mystical=6.5},
                [3]={item_enhancement_greedy=60.3,item_enhancement_keen_eyed=31.0,item_enhancement_mystical=5.4},
                [4]={item_enhancement_keen_eyed=66.1,item_enhancement_mystical=15.7,item_enhancement_quickened=13.0},
                [5]={item_enhancement_feverish=66.7,item_enhancement_fleetfooted=33.3},
            },
        },
    },
}
