-- Skipped roles use pos 5; forced cores omit wards.
return {
    patch='7.41f', updated='2026-09-30', defaultRole='pos_5',
    source='https://dota2protracker.com/hero/Tusk?section=builds',
    overviewWindow='last 8 days, 7000+', buildWindow='2026-09-16 to 2026-09-30', buildUpdated='2026-09-30',
    roles={
        pos_1={matches=6,winRate=50.0,skipped=true},
        pos_2={matches=155,winRate=49.7,skipped=true},
        pos_3={matches=217,winRate=43.8,skipped=true},
        pos_4={matches=1810,winRate=48.3,rating=28,weight=57,buildMatches=3340,buildWinRate=49.0,skillMatches=369,openingMatches=496,openingObserved=3337},
        pos_5={matches=2683,winRate=48.5,rating=43,weight=73,buildMatches=5007,buildWinRate=48.0,skillMatches=648,openingMatches=305,openingObserved=5007},
    },
    -- Current-tier picks only; sparse T5 uses reviewed suitability.
    neutrals={
        pos_4={tier5Profile='support',
            neutral={
                [1]={item_ash_legion_shield=16.8,item_dormant_curio=12.7,item_kobold_cup=12.3,item_chipped_vest=11.9,item_polliwog_charm=10.1,item_duelist_gloves=9.0,item_stonefeather_satchel=8.4},
                [2]={item_mana_draught=22.2,item_pogo_stick=19.2,item_essence_ring=14.3,item_medallion_of_courage=9.7,item_searing_signet=8.0,item_crippling_crossbow=6.6,item_poor_mans_shield=5.8},
                [3]={item_gunpowder_gauntlets=20.2,item_cloak_of_flames=18.8,item_psychic_headband=11.1,item_jidi_pollen_bag=6.7,item_stormcrafter=6.6},
                [4]={item_prophets_pendulum=16.5,item_giant_maul=14.0,item_dandelion_amulet=13.4,item_conjurers_catalyst=13.3,item_rattlecage=8.8,item_idol_of_screeauk=7.3,item_enchanters_bauble=7.2},
                [5]={item_demonicon=30.3,item_desolator_2=18.2,item_minotaur_horn=18.2,item_fallen_sky=12.1,item_spider_legs=9.1,item_heavy_blade=9.1},
            },
            enhancement={
                [1]={item_enhancement_quickened=44.5,item_enhancement_brawny=37.1,item_enhancement_tough=14.3},
                [2]={item_enhancement_greedy=47.3,item_enhancement_quickened=19.6,item_enhancement_tough=18.3},
                [3]={item_enhancement_greedy=48.3,item_enhancement_tough=22.4,item_enhancement_quickened=15.2},
                [4]={item_enhancement_quickened=39.4,item_enhancement_brawny=26.6,item_enhancement_tough=21.7},
                [5]={item_enhancement_evolved=60.6,item_enhancement_fleetfooted=21.2,item_enhancement_timeless=9.1},
            },
        },
        pos_5={tier5Profile='support',
            neutral={
                [1]={item_ash_legion_shield=18.1,item_kobold_cup=14.3,item_chipped_vest=11.5,item_dormant_curio=11.1,item_polliwog_charm=10.0,item_stonefeather_satchel=9.1,item_duelist_gloves=8.9},
                [2]={item_pogo_stick=20.7,item_mana_draught=20.2,item_essence_ring=14.1,item_medallion_of_courage=11.1,item_searing_signet=7.4,item_crippling_crossbow=6.3,item_poor_mans_shield=5.2},
                [3]={item_gunpowder_gauntlets=20.2,item_cloak_of_flames=19.1,item_psychic_headband=12.2,item_jidi_pollen_bag=6.4,item_stormcrafter=5.5},
                [4]={item_prophets_pendulum=18.2,item_dandelion_amulet=15.1,item_giant_maul=13.7,item_conjurers_catalyst=13.4,item_rattlecage=8.0,item_enchanters_bauble=6.7,item_idol_of_screeauk=5.7},
                [5]={item_fallen_sky=40.7,item_demonicon=18.6,item_spider_legs=10.2,item_desolator_2=8.5,item_minotaur_horn=8.5,item_heavy_blade=5.1,item_riftshadow_prism=3.4},
            },
            enhancement={
                [1]={item_enhancement_quickened=45.1,item_enhancement_brawny=38.0,item_enhancement_tough=13.7},
                [2]={item_enhancement_greedy=54.8,item_enhancement_quickened=16.6,item_enhancement_tough=15.4},
                [3]={item_enhancement_greedy=55.3,item_enhancement_tough=19.3,item_enhancement_quickened=13.1},
                [4]={item_enhancement_quickened=39.6,item_enhancement_brawny=24.3,item_enhancement_tough=22.2},
                [5]={item_enhancement_evolved=33.9,item_enhancement_fleetfooted=30.5,item_enhancement_timeless=16.9},
            },
        },
    },
}
