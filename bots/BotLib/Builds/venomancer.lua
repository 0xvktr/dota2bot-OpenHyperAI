-- Header 1255; role rows 1252. Support-only scope; eligible offlane skipped. Forced cores use ward-free pos 5.
return {
    patch='7.41f', updated='2026-09-30', defaultRole='pos_5',
    source='https://dota2protracker.com/hero/Venomancer?section=builds',
    overviewWindow='last 8 days, 7000+', buildWindow='2026-09-16 to 2026-09-30', buildUpdated='2026-09-30',
    roles={
        pos_1={matches=12,winRate=66.7,skipped=true},
        pos_2={matches=14,winRate=0.0,skipped=true},
        pos_3={matches=72,winRate=40.3,rating=30,skipped=true},
        pos_4={matches=392,winRate=40.1,rating=7,weight=33,buildMatches=718,buildWinRate=43.0,skillMatches=61,openingMatches=21,openingObserved=718},
        pos_5={matches=762,winRate=49.5,rating=39,weight=54,buildMatches=1361,buildWinRate=49.0,skillMatches=91,openingMatches=99,openingObserved=1361},
    },
    -- Current-tier pick frequencies; T5 uses reviewed suitability.
    neutrals={
        pos_4={tier5Profile='support',
            neutral={
                [1]={item_dormant_curio=16.8,item_polliwog_charm=13.0,item_ash_legion_shield=12.4,item_foragers_kit=10.8,item_kobold_cup=9.2,item_stonefeather_satchel=8.4,item_duelist_gloves=7.4},
                [2]={item_searing_signet=30.2,item_mana_draught=13.6,item_pogo_stick=12.3,item_essence_ring=11.5,item_crippling_crossbow=7.8,item_medallion_of_courage=5.2},
                [3]={item_jidi_pollen_bag=12.8,item_partisans_brand=12.6,item_psychic_headband=9.7,item_stormcrafter=6.2,item_spellslinger=6.2,item_cloak_of_flames=5.3},
                [4]={item_conjurers_catalyst=39.5,item_enchanters_bauble=14.0,item_dandelion_amulet=10.1,item_prophets_pendulum=6.6,item_rattlecage=4.8,item_idol_of_screeauk=3.5},
                [5]={item_demonicon=40.0,item_dezun_bloodrite=20.0,item_harmonizer=13.3,item_desolator_2=6.7,item_minotaur_horn=6.7},
            },
            enhancement={
                [1]={item_enhancement_mystical=43.7,item_enhancement_quickened=41.1,item_enhancement_alert=8.9},
                [2]={item_enhancement_greedy=68.1,item_enhancement_mystical=13.5,item_enhancement_quickened=12.3},
                [3]={item_enhancement_greedy=71.2,item_enhancement_mystical=12.2,item_enhancement_quickened=11.7},
                [4]={item_enhancement_timeless=70.6,item_enhancement_quickened=17.5,item_enhancement_mystical=7.0},
                [5]={item_enhancement_timeless=73.3,item_enhancement_fleetfooted=20.0,item_enhancement_evolved=6.7},
            },
        },
        pos_5={tier5Profile='support',
            neutral={
                [1]={item_polliwog_charm=15.8,item_ash_legion_shield=15.7,item_foragers_kit=11.9,item_dormant_curio=11.8,item_kobold_cup=11.5,item_stonefeather_satchel=9.3,item_duelist_gloves=6.7},
                [2]={item_searing_signet=25.6,item_essence_ring=15.1,item_mana_draught=14.7,item_pogo_stick=12.6,item_crippling_crossbow=9.9,item_medallion_of_courage=6.6},
                [3]={item_partisans_brand=14.6,item_jidi_pollen_bag=12.3,item_psychic_headband=9.2,item_stormcrafter=8.3,item_cloak_of_flames=5.5,item_unrelenting_eye=5.2},
                [4]={item_conjurers_catalyst=39.2,item_enchanters_bauble=13.7,item_dandelion_amulet=11.8,item_prophets_pendulum=10.0,item_idol_of_screeauk=7.4,item_rattlecage=3.5},
                [5]={item_demonicon=33.3,item_fallen_sky=16.7,item_minotaur_horn=16.7,item_dezun_bloodrite=16.7,item_spider_legs=8.3},
            },
            enhancement={
                [1]={item_enhancement_mystical=44.8,item_enhancement_quickened=40.3,item_enhancement_alert=7.9},
                [2]={item_enhancement_greedy=76.2,item_enhancement_mystical=10.4,item_enhancement_quickened=8.3},
                [3]={item_enhancement_greedy=78.7,item_enhancement_mystical=8.5,item_enhancement_quickened=7.3},
                [4]={item_enhancement_timeless=66.8,item_enhancement_quickened=24.4,item_enhancement_mystical=5.6},
                [5]={item_enhancement_timeless=83.3,item_enhancement_fleetfooted=16.7},
            },
        },
    },
}
