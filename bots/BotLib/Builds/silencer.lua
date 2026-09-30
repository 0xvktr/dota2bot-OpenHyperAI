-- Skipped roles use hard support; only support roles buy observed wards.
return {
    patch='7.41f', updated='2026-09-30', defaultRole='pos_5',
    source='https://dota2protracker.com/hero/Silencer?section=builds',
    overviewWindow='last 8 days, 7000+', buildWindow='2026-09-16 to 2026-09-30', buildUpdated='2026-09-30',
    roles={
        pos_1={matches=8,winRate=50.0,skipped=true},
        pos_2={matches=141,winRate=48.2,skipped=true},
        pos_3={matches=43,winRate=53.5,skipped=true},
        pos_4={matches=827,winRate=45.7,rating=11,weight=37,buildMatches=1550,buildWinRate=47.0,skillMatches=150,openingMatches=102,openingObserved=1550},
        pos_5={matches=1741,winRate=48.2,rating=30,weight=58,buildMatches=3175,buildWinRate=48.0,skillMatches=430,openingMatches=123,openingObserved=3174},
    },
    -- Current-tier observations only; sparse T5 picks use reviewed suitability.
    neutrals={
        pos_4={tier5Profile='support',
            neutral={
                [1]={item_dormant_curio=16.4,item_duelist_gloves=13.9,item_kobold_cup=13.4,item_ash_legion_shield=10.3,item_stonefeather_satchel=10.1,item_polliwog_charm=9.8,item_foragers_kit=9.2},
                [2]={item_searing_signet=29.2,item_mana_draught=15.1,item_essence_ring=13.3,item_pogo_stick=12.7,item_crippling_crossbow=6.7},
                [3]={item_spellslinger=11.8,item_gunpowder_gauntlets=9.3,item_partisans_brand=9.3,item_psychic_headband=9.0,item_serrated_shiv=8.7,item_stormcrafter=5.3},
                [4]={item_conjurers_catalyst=29.4,item_enchanters_bauble=16.9,item_prophets_pendulum=11.3,item_dandelion_amulet=7.7,item_giant_maul=4.8,item_idol_of_screeauk=4.2},
                [5]={item_spider_legs=12.5,item_demonicon=12.5,item_fallen_sky=12.5,item_dezun_bloodrite=12.5,item_desolator_2=4.2},
            },
            enhancement={
                [1]={item_enhancement_quickened=48.3,item_enhancement_mystical=45.2,item_enhancement_vital=4.2},
                [2]={item_enhancement_greedy=54.5,item_enhancement_mystical=24.4,item_enhancement_quickened=10.2},
                [3]={item_enhancement_greedy=53.4,item_enhancement_mystical=23.9,item_enhancement_tough=9.7},
                [4]={item_enhancement_timeless=49.0,item_enhancement_mystical=26.0,item_enhancement_quickened=15.4},
                [5]={item_enhancement_feverish=33.3,item_enhancement_timeless=33.3,item_enhancement_fleetfooted=16.7},
            },
        },
        pos_5={tier5Profile='support',
            neutral={
                [1]={item_dormant_curio=16.0,item_ash_legion_shield=14.6,item_kobold_cup=12.9,item_duelist_gloves=11.7,item_polliwog_charm=11.5,item_foragers_kit=9.2,item_stonefeather_satchel=9.1},
                [2]={item_searing_signet=27.8,item_mana_draught=16.3,item_essence_ring=14.9,item_pogo_stick=13.8,item_crippling_crossbow=4.5,item_medallion_of_courage=3.7},
                [3]={item_spellslinger=11.9,item_psychic_headband=10.6,item_partisans_brand=9.3,item_gunpowder_gauntlets=7.3,item_stormcrafter=6.4,item_serrated_shiv=6.0},
                [4]={item_conjurers_catalyst=28.6,item_enchanters_bauble=20.6,item_prophets_pendulum=9.9,item_dandelion_amulet=9.2,item_giant_maul=6.4,item_idol_of_screeauk=4.3},
                [5]={item_demonicon=20.4,item_fallen_sky=10.2,item_heavy_blade=8.2,item_spider_legs=6.1,item_minotaur_horn=6.1},
            },
            enhancement={
                [1]={item_enhancement_mystical=49.0,item_enhancement_quickened=45.5,item_enhancement_vital=3.8},
                [2]={item_enhancement_greedy=67.9,item_enhancement_mystical=16.6,item_enhancement_quickened=8.1},
                [3]={item_enhancement_greedy=68.4,item_enhancement_mystical=15.9,item_enhancement_quickened=7.2},
                [4]={item_enhancement_timeless=53.7,item_enhancement_mystical=21.6,item_enhancement_quickened=15.4},
                [5]={item_enhancement_timeless=55.1,item_enhancement_feverish=32.7,item_enhancement_evolved=10.2},
            },
        },
    },
}
