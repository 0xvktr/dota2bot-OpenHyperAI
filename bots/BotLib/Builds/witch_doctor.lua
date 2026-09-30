-- Supports only; other roles below threshold. Header 4548; role rows 4540.
return {
    patch='7.41f', updated='2026-09-30', defaultRole='pos_5',
    source='https://dota2protracker.com/hero/Witch%20Doctor?section=builds',
    overviewWindow='last 8 days, 7000+', buildWindow='2026-09-16 to 2026-09-30', buildUpdated='2026-09-30',
    roles={
        pos_1={matches=2,winRate=0,skipped=true},
        pos_2={matches=9,winRate=11.1,skipped=true},
        pos_3={matches=8,winRate=50,skipped=true},
        pos_4={matches=791,winRate=49.7,rating=36,weight=53,buildMatches=1217,buildWinRate=53,skillMatches=259,openingMatches=41,openingObserved=1216},
        pos_5={matches=3730,winRate=50,rating=51,weight=81,buildMatches=4831,buildWinRate=53,skillMatches=842,openingMatches=217,openingObserved=4826},
    },
    -- Current-tier pick frequencies; T5 uses reviewed suitability.
    neutrals={
        pos_4={tier5Profile='support',
            neutral={
                [1]={item_dormant_curio=20.3,item_ash_legion_shield=15.1,item_polliwog_charm=13.8,item_kobold_cup=13.5,item_stonefeather_satchel=9.9,item_foragers_kit=7.6,item_occult_bracelet=6.9},
                [2]={item_searing_signet=24.6,item_pogo_stick=17.4,item_mana_draught=16.5,item_essence_ring=15.1,item_crippling_crossbow=3.9,item_poor_mans_shield=3.2},
                [3]={item_psychic_headband=9.8,item_spellslinger=9.7,item_partisans_brand=8.4,item_stormcrafter=7.8,item_jidi_pollen_bag=7.6,item_cloak_of_flames=6.9},
                [4]={item_conjurers_catalyst=36.5,item_enchanters_bauble=15.2,item_prophets_pendulum=13.5,item_dandelion_amulet=12.5,item_idol_of_screeauk=3.2,item_rattlecage=2.5},
                [5]={item_fallen_sky=22.7,item_demonicon=18.2,item_dezun_bloodrite=13.6,item_desolator_2=9.1,item_spider_legs=4.5},
            },
            enhancement={
                [1]={item_enhancement_quickened=50,item_enhancement_mystical=45.7,item_enhancement_vital=3.6},
                [2]={item_enhancement_greedy=62.3,item_enhancement_mystical=16,item_enhancement_keen_eyed=13.5},
                [3]={item_enhancement_greedy=61.9,item_enhancement_keen_eyed=16.5,item_enhancement_mystical=12.7},
                [4]={item_enhancement_keen_eyed=38.2,item_enhancement_timeless=24.8,item_enhancement_mystical=22.1},
                [5]={item_enhancement_timeless=59.1,item_enhancement_feverish=22.7,item_enhancement_fleetfooted=18.2},
            },
        },
        pos_5={tier5Profile='support',
            neutral={
                [1]={item_dormant_curio=19.5,item_ash_legion_shield=16.6,item_kobold_cup=15,item_polliwog_charm=13.2,item_stonefeather_satchel=11,item_foragers_kit=8.8,item_occult_bracelet=6.3},
                [2]={item_searing_signet=23.7,item_pogo_stick=19.4,item_mana_draught=17.8,item_essence_ring=16.3,item_crippling_crossbow=4,item_medallion_of_courage=2.9},
                [3]={item_psychic_headband=12.2,item_partisans_brand=11.8,item_spellslinger=11.2,item_cloak_of_flames=7},
                [4]={item_conjurers_catalyst=33.2,item_enchanters_bauble=16.8,item_prophets_pendulum=15.3,item_dandelion_amulet=12.2,item_idol_of_screeauk=3.5,item_rattlecage=3},
                [5]={item_fallen_sky=24.1,item_dezun_bloodrite=16.7,item_demonicon=14.8,item_harmonizer=11.1,item_spider_legs=9.3,item_minotaur_horn=3.7},
            },
            enhancement={
                [1]={item_enhancement_mystical=49.3,item_enhancement_quickened=46.5,item_enhancement_vital=3.6},
                [2]={item_enhancement_greedy=77.2,item_enhancement_mystical=9,item_enhancement_keen_eyed=8.8},
                [3]={item_enhancement_greedy=74.8,item_enhancement_keen_eyed=13,item_enhancement_mystical=7.9},
                [4]={item_enhancement_keen_eyed=39.1,item_enhancement_timeless=27.4,item_enhancement_mystical=20},
                [5]={item_enhancement_timeless=61.1,item_enhancement_feverish=22.2,item_enhancement_fleetfooted=16.7},
            },
        },
    },
}
