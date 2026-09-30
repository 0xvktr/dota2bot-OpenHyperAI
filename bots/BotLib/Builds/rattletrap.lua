-- Skipped roles use the hard support build when forced.
return {
    patch='7.41f', updated='2026-09-30', defaultRole='pos_5',
    source='https://dota2protracker.com/hero/Clockwerk?section=builds',
    overviewWindow='last 8 days, 7000+', buildWindow='2026-09-16 to 2026-09-30', buildUpdated='2026-09-30',
    -- Overview header 2484; displayed role rows total 2478.
    roles={
        pos_1={matches=1,winRate=100,skipped=true},
        pos_2={matches=3,winRate=0,skipped=true},
        pos_3={matches=33,winRate=45.5,skipped=true},
        pos_4={matches=1176,winRate=50.1,rating=40,weight=61,buildMatches=2247,buildWinRate=49,skillMatches=489,openingMatches=469,openingObserved=2246},
        pos_5={matches=1265,winRate=51.5,rating=51,weight=71,buildMatches=2418,buildWinRate=51,skillMatches=693,openingMatches=226,openingObserved=2417},
    },
    -- Current-tier observations only; sparse T5 picks use reviewed suitability.
    neutrals={
        pos_5={tier5Profile='tank',
            neutral={
                [1]={item_chipped_vest=17,item_ash_legion_shield=16.6,item_kobold_cup=12.9,item_polliwog_charm=11.3,item_dormant_curio=11.1,item_foragers_kit=9,item_stonefeather_satchel=8.8},
                [2]={item_pogo_stick=18.4,item_essence_ring=16.9,item_mana_draught=16.9,item_searing_signet=14,item_poor_mans_shield=7.1,item_crippling_crossbow=6.7,item_medallion_of_courage=4.9},
                [3]={item_cloak_of_flames=24.3,item_psychic_headband=12.3,item_jidi_pollen_bag=11.6,item_stormcrafter=10.2},
                [4]={item_prophets_pendulum=19.7,item_conjurers_catalyst=17.4,item_dandelion_amulet=16.2,item_rattlecage=13.4,item_idol_of_screeauk=9.7,item_enchanters_bauble=4.9},
                [5]={item_fallen_sky=31.7,item_demonicon=19.5,item_minotaur_horn=12.2,item_spider_legs=7.3,item_heavy_blade=7.3,item_riftshadow_prism=7.3,item_divine_regalia=4.9},
            },
            enhancement={
                [1]={item_enhancement_brawny=59.5,item_enhancement_quickened=37,item_enhancement_vital=3.3},
                [2]={item_enhancement_greedy=71.4,item_enhancement_brawny=16.6,item_enhancement_quickened=8.8},
                [3]={item_enhancement_greedy=71.8,item_enhancement_brawny=16.6,item_enhancement_quickened=6.4},
                [4]={item_enhancement_brawny=48,item_enhancement_quickened=29.3,item_enhancement_tough=11.4},
                [5]={item_enhancement_evolved=56.1,item_enhancement_fleetfooted=17.1,item_enhancement_timeless=14.6},
            },
        },
        pos_4={tier5Profile='tank',
            neutral={
                [1]={item_ash_legion_shield=17.6,item_chipped_vest=15.2,item_kobold_cup=13.1,item_dormant_curio=12.1,item_polliwog_charm=11.1,item_stonefeather_satchel=10.2,item_occult_bracelet=7.6},
                [2]={item_pogo_stick=19.9,item_essence_ring=16.5,item_mana_draught=15.2,item_searing_signet=14.8,item_poor_mans_shield=7.2,item_crippling_crossbow=6.7,item_medallion_of_courage=4.2},
                [3]={item_cloak_of_flames=26.5,item_psychic_headband=12.6,item_jidi_pollen_bag=12.1,item_stormcrafter=10.2},
                [4]={item_prophets_pendulum=19.5,item_dandelion_amulet=15.9,item_rattlecage=15.3,item_conjurers_catalyst=15.3,item_idol_of_screeauk=9.2,item_enchanters_bauble=6.4},
                [5]={item_demonicon=30.8,item_fallen_sky=26.9,item_minotaur_horn=26.9,item_dezun_bloodrite=7.7,item_spider_legs=3.8,item_heavy_blade=3.8},
            },
            enhancement={
                [1]={item_enhancement_brawny=55.2,item_enhancement_quickened=41.4,item_enhancement_vital=3},
                [2]={item_enhancement_greedy=69.3,item_enhancement_brawny=17.8,item_enhancement_quickened=8.9},
                [3]={item_enhancement_greedy=68.3,item_enhancement_brawny=19.4,item_enhancement_quickened=6.3},
                [4]={item_enhancement_brawny=46.1,item_enhancement_quickened=29.4,item_enhancement_timeless=14.1},
                [5]={item_enhancement_evolved=50,item_enhancement_timeless=30.8,item_enhancement_fleetfooted=15.4},
            },
        },
    },
}
