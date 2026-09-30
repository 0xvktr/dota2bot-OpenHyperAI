-- Skipped roles use hard support; only support roles buy observed wards.
return {
    patch='7.41f', updated='2026-09-30', defaultRole='pos_5',
    source='https://dota2protracker.com/hero/Shadow%20Demon?section=builds',
    overviewWindow='last 8 days, 7000+', buildWindow='2026-09-16 to 2026-09-30', buildUpdated='2026-09-30',
    roles={
        pos_1={matches=1,winRate=100.0,skipped=true},
        pos_2={matches=12,winRate=58.3,skipped=true},
        pos_3={matches=20,winRate=50.0,skipped=true},
        pos_4={matches=564,winRate=47.5,rating=30,weight=46,buildMatches=1064,buildWinRate=45.0,skillMatches=295,openingMatches=46,openingObserved=1063},
        pos_5={matches=811,winRate=43.6,rating=13,weight=38,buildMatches=1524,buildWinRate=47.0,skillMatches=425,openingMatches=108,openingObserved=1524},
    },
    -- Current-tier observations only; sparse T5 picks use reviewed suitability.
    neutrals={
        pos_4={tier5Profile='support',
            neutral={
                [1]={item_dormant_curio=20.5,item_kobold_cup=16.5,item_ash_legion_shield=13.9,item_polliwog_charm=13.4,item_stonefeather_satchel=12.4,item_foragers_kit=8.1,item_occult_bracelet=5.6},
                [2]={item_pogo_stick=23.4,item_searing_signet=19.3,item_mana_draught=17.3,item_essence_ring=14.4,item_crippling_crossbow=5.5,item_medallion_of_courage=4.7},
                [3]={item_psychic_headband=19.5,item_spellslinger=9.7,item_partisans_brand=9.1},
                [4]={item_conjurers_catalyst=27.5,item_prophets_pendulum=15.7,item_enchanters_bauble=15.4,item_dandelion_amulet=13.3,item_idol_of_screeauk=6.5},
                [5]={item_fallen_sky=30.0,item_minotaur_horn=20.0,item_spider_legs=10.0,item_heavy_blade=10.0,item_harmonizer=10.0},
            },
            enhancement={
                [1]={item_enhancement_quickened=50.1,item_enhancement_mystical=47.2,item_enhancement_vital=2.2},
                [2]={item_enhancement_greedy=70.9,item_enhancement_keen_eyed=17.8,item_enhancement_mystical=6.5},
                [3]={item_enhancement_greedy=67.5,item_enhancement_keen_eyed=25.0,item_enhancement_mystical=4.3},
                [4]={item_enhancement_keen_eyed=60.5,item_enhancement_timeless=14.8,item_enhancement_quickened=12.7},
                [5]={item_enhancement_timeless=60.0,item_enhancement_feverish=20.0,item_enhancement_fleetfooted=20.0},
            },
        },
        pos_5={tier5Profile='support',
            neutral={
                [1]={item_dormant_curio=19.4,item_kobold_cup=16.0,item_ash_legion_shield=15.2,item_polliwog_charm=13.1,item_stonefeather_satchel=11.1,item_foragers_kit=8.9,item_occult_bracelet=5.6},
                [2]={item_pogo_stick=22.5,item_searing_signet=20.4,item_essence_ring=16.7,item_mana_draught=15.2,item_medallion_of_courage=5.5,item_crippling_crossbow=4.5},
                [3]={item_psychic_headband=16.3,item_spellslinger=8.5,item_partisans_brand=7.1},
                [4]={item_conjurers_catalyst=26.6,item_enchanters_bauble=17.8,item_prophets_pendulum=16.1,item_dandelion_amulet=14.8,item_idol_of_screeauk=5.8},
                [5]={item_demonicon=33.3,item_fallen_sky=14.3,item_dezun_bloodrite=14.3,item_minotaur_horn=4.8,item_heavy_blade=4.8,item_divine_regalia=4.8},
            },
            enhancement={
                [1]={item_enhancement_mystical=49.2,item_enhancement_quickened=47.6,item_enhancement_vital=2.8},
                [2]={item_enhancement_greedy=70.7,item_enhancement_keen_eyed=19.0,item_enhancement_mystical=5.7},
                [3]={item_enhancement_greedy=67.0,item_enhancement_keen_eyed=24.6,item_enhancement_mystical=4.2},
                [4]={item_enhancement_keen_eyed=59.7,item_enhancement_timeless=18.0,item_enhancement_quickened=11.6},
                [5]={item_enhancement_timeless=57.1,item_enhancement_feverish=33.3,item_enhancement_fleetfooted=9.5},
            },
        },
    },
}
