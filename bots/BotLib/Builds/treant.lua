-- Header 1004; role rows 1002. Core samples too small; forced picks use ward-free hard support.
return {
    patch='7.41f', updated='2026-09-30', defaultRole='pos_5',
    source='https://dota2protracker.com/hero/Treant%20Protector?section=builds',
    overviewWindow='last 8 days, 7000+', buildWindow='2026-09-16 to 2026-09-30', buildUpdated='2026-09-30',
    roles={
        pos_1={matches=0,winRate=0,skipped=true},
        pos_2={matches=1,winRate=0.0,skipped=true},
        pos_3={matches=15,winRate=20.0,skipped=true},
        pos_4={matches=147,winRate=50.3,rating=34,weight=39,buildMatches=333,buildWinRate=48.0,skillMatches=58,openingMatches=115,openingObserved=333},
        pos_5={matches=839,winRate=43.3,rating=20,weight=43,buildMatches=2089,buildWinRate=45.0,skillMatches=620,openingMatches=571,openingObserved=2074},
    },
    -- Current-tier pick frequencies; T5 uses reviewed suitability.
    neutrals={
        pos_4={tier5Profile='support',
            neutral={
                [1]={item_polliwog_charm=15.3,item_ash_legion_shield=14.7,item_kobold_cup=12.6,item_dormant_curio=12.6,item_foragers_kit=10.8,item_chipped_vest=10.2,item_stonefeather_satchel=9.3},
                [2]={item_mana_draught=23.3,item_pogo_stick=19.6,item_searing_signet=15.2,item_essence_ring=9.6,item_medallion_of_courage=6.5,item_seeds_of_serenity=4.7},
                [3]={item_cloak_of_flames=23.0,item_jidi_pollen_bag=11.7,item_psychic_headband=8.4,item_stormcrafter=7.5,item_gunpowder_gauntlets=7.5},
                [4]={item_conjurers_catalyst=25.0,item_prophets_pendulum=14.0,item_dandelion_amulet=12.0,item_rattlecage=11.0,item_enchanters_bauble=10.0,item_giant_maul=8.0,item_idol_of_screeauk=7.0},
                [5]={item_spider_legs=25.0,item_fallen_sky=25.0,item_demonicon=12.5,item_minotaur_horn=12.5,item_dezun_bloodrite=12.5,item_riftshadow_prism=12.5},
            },
            enhancement={
                [1]={item_enhancement_quickened=53.2,item_enhancement_brawny=36.6,item_enhancement_vital=8.1},
                [2]={item_enhancement_greedy=73.9,item_enhancement_quickened=13.4,item_enhancement_brawny=9.0},
                [3]={item_enhancement_greedy=69.0,item_enhancement_quickened=13.4,item_enhancement_brawny=12.6},
                [4]={item_enhancement_timeless=46.0,item_enhancement_quickened=31.0,item_enhancement_brawny=17.0},
                [5]={item_enhancement_evolved=62.5,item_enhancement_timeless=25.0,item_enhancement_fleetfooted=12.5},
            },
        },
        pos_5={tier5Profile='support',
            neutral={
                [1]={item_ash_legion_shield=16.6,item_kobold_cup=13.4,item_polliwog_charm=13.3,item_dormant_curio=12.2,item_chipped_vest=11.3,item_stonefeather_satchel=9.9,item_foragers_kit=9.4},
                [2]={item_pogo_stick=22.9,item_mana_draught=18.0,item_medallion_of_courage=11.9,item_searing_signet=10.5,item_essence_ring=9.8,item_crippling_crossbow=7.6,item_seeds_of_serenity=4.6},
                [3]={item_cloak_of_flames=17.7,item_jidi_pollen_bag=13.3,item_psychic_headband=9.3,item_stormcrafter=5.0,item_partisans_brand=4.6},
                [4]={item_conjurers_catalyst=25.4,item_prophets_pendulum=14.0,item_dandelion_amulet=13.3,item_rattlecage=7.7,item_enchanters_bauble=7.1,item_idol_of_screeauk=6.0},
                [5]={item_demonicon=31.6,item_minotaur_horn=26.3,item_spider_legs=10.5,item_fallen_sky=10.5,item_dezun_bloodrite=10.5,item_riftshadow_prism=5.3},
            },
            enhancement={
                [1]={item_enhancement_quickened=58.8,item_enhancement_brawny=35.5,item_enhancement_vital=4.2},
                [2]={item_enhancement_greedy=81.5,item_enhancement_quickened=9.2,item_enhancement_brawny=7.1},
                [3]={item_enhancement_greedy=81.9,item_enhancement_quickened=8.8,item_enhancement_brawny=6.0},
                [4]={item_enhancement_timeless=37.6,item_enhancement_quickened=36.1,item_enhancement_brawny=20.9},
                [5]={item_enhancement_fleetfooted=36.8,item_enhancement_timeless=31.6,item_enhancement_evolved=31.6},
            },
        },
    },
}
