-- Supports only; reviewed offlane is 4.0%, below 5%. Header 9162; role rows 9144.
return {
    patch='7.41f', updated='2026-09-30', defaultRole='pos_5',
    source='https://dota2protracker.com/hero/Winter%20Wyvern?section=builds',
    overviewWindow='last 8 days, 7000+', buildWindow='2026-09-16 to 2026-09-30', buildUpdated='2026-09-30',
    roles={
        pos_1={matches=5,winRate=40,skipped=true},
        pos_2={matches=69,winRate=42,rating=32,skipped=true},
        pos_3={matches=368,winRate=55.7,rating=40,skipped=true},
        pos_4={matches=1230,winRate=48.8,rating=31,weight=54,buildMatches=2011,buildWinRate=51,skillMatches=293,openingMatches=160,openingObserved=2010,skillNote='D2PT shows a fifth Arctic Burn point at 8; use legal Splinter Blast instead.'},
        pos_5={matches=7472,winRate=52.7,rating=75,weight=100,buildMatches=13075,buildWinRate=52,skillMatches=2799,openingMatches=1044,openingObserved=13062,skillNote='D2PT shows a fifth Arctic Burn point at 8; use legal Splinter Blast instead.'},
    },
    -- Current-tier pick frequencies; T5 uses reviewed suitability.
    neutrals={
        pos_4={tier5Profile='support',
            neutral={
                [1]={item_dormant_curio=18.2,item_duelist_gloves=15.2,item_ash_legion_shield=12.1,item_kobold_cup=11.4,item_stonefeather_satchel=10.6,item_polliwog_charm=8.9,item_foragers_kit=6.3},
                [2]={item_searing_signet=27.7,item_pogo_stick=17.4,item_mana_draught=14,item_essence_ring=13.2,item_medallion_of_courage=5.8,item_crippling_crossbow=5.4},
                [3]={item_psychic_headband=13.5,item_gunpowder_gauntlets=12.3,item_partisans_brand=10.9,item_serrated_shiv=8.3,item_spellslinger=5.5},
                [4]={item_conjurers_catalyst=32.5,item_enchanters_bauble=14.1,item_prophets_pendulum=11.6,item_dandelion_amulet=8.2,item_giant_maul=7.9,item_idol_of_screeauk=3.6},
                [5]={item_demonicon=33.3,item_desolator_2=20.8,item_spider_legs=12.5,item_dezun_bloodrite=12.5,item_fallen_sky=8.3,item_divine_regalia=8.3,item_minotaur_horn=4.2},
            },
            enhancement={
                [1]={item_enhancement_quickened=46.1,item_enhancement_mystical=41.1,item_enhancement_tough=12.2},
                [2]={item_enhancement_greedy=56.3,item_enhancement_mystical=14,item_enhancement_keen_eyed=13.8},
                [3]={item_enhancement_greedy=54.2,item_enhancement_keen_eyed=17.3,item_enhancement_mystical=13.6},
                [4]={item_enhancement_keen_eyed=31.8,item_enhancement_timeless=31.5,item_enhancement_mystical=17.2},
                [5]={item_enhancement_timeless=45.8,item_enhancement_feverish=20.8,item_enhancement_evolved=16.7},
            },
        },
        pos_5={tier5Profile='support',
            neutral={
                [1]={item_dormant_curio=16.8,item_ash_legion_shield=15,item_kobold_cup=14.7,item_duelist_gloves=12.2,item_stonefeather_satchel=10.8,item_polliwog_charm=10.6,item_foragers_kit=6.2},
                [2]={item_searing_signet=26.6,item_pogo_stick=20.2,item_mana_draught=14.5,item_essence_ring=12.8,item_medallion_of_courage=6.6,item_crippling_crossbow=6},
                [3]={item_psychic_headband=14.9,item_partisans_brand=10,item_gunpowder_gauntlets=8.7,item_spellslinger=6.9,item_serrated_shiv=6},
                [4]={item_conjurers_catalyst=34.5,item_enchanters_bauble=15.4,item_prophets_pendulum=13,item_dandelion_amulet=11.9,item_giant_maul=4.7,item_idol_of_screeauk=3.5,item_metamorphic_mandible=2.7},
                [5]={item_demonicon=26.1,item_dezun_bloodrite=18.1,item_fallen_sky=13,item_minotaur_horn=8.7,item_desolator_2=7.2,item_heavy_blade=5.8},
            },
            enhancement={
                [1]={item_enhancement_quickened=50.1,item_enhancement_mystical=44.4,item_enhancement_tough=4.5},
                [2]={item_enhancement_greedy=71.2,item_enhancement_keen_eyed=10.8,item_enhancement_mystical=9.1},
                [3]={item_enhancement_greedy=67.8,item_enhancement_keen_eyed=16.2,item_enhancement_mystical=8},
                [4]={item_enhancement_keen_eyed=42.1,item_enhancement_timeless=26.7,item_enhancement_quickened=15},
                [5]={item_enhancement_timeless=48.6,item_enhancement_feverish=22.5,item_enhancement_fleetfooted=21},
            },
        },
    },
}
