-- D2PT 7.41f; role counts sum to 3812, header 3821. Requested migrated roles meet thresholds.
return {
    patch='7.41f', updated='2026-09-30', defaultRole='pos_3',
    source='https://dota2protracker.com/hero/Legion%20Commander?section=builds',
    overviewWindow='last 8 days, 7000+', buildWindow='2026-09-15 to 2026-09-29', buildUpdated='2026-09-29',
    roles={
        pos_1={matches=25,winRate=48,skipped=true},
        pos_2={matches=84,winRate=45.2,rating=32,skipped=true},
        pos_3={matches=3651,winRate=53.1,rating=67,weight=97,buildMatches=6161,buildWinRate=53,skillMatches=2519,skillWinRate=54.9,openingMatches=1417,openingWinRate=54.5,openingObserved=6161},
        pos_4={matches=37,winRate=45.9,skipped=true},
        pos_5={matches=15,winRate=53.3,skipped=true},
    },
    -- Current-tier observations only; sparse T5 uses reviewed role suitability.
    neutrals={
        pos_3={tier5Profile='attack',
            neutral={
                [1]={item_chipped_vest=28.3,item_duelist_gloves=20.4,item_possessed_mask=12.5,item_weighted_dice=6.9,item_occult_bracelet=6.8,item_dormant_curio=6.6,item_dagger_of_ristul=5.5},
                [2]={item_defiant_shell=29.6,item_poor_mans_shield=11.8,item_mana_draught=9.7,item_pogo_stick=5.4,item_medallion_of_courage=4.3},
                [3]={item_serrated_shiv=30.8,item_gunpowder_gauntlets=21.7,item_cloak_of_flames=18.9,item_unrelenting_eye=2.9},
                [4]={item_giant_maul=29,item_rattlecage=13.7,item_prophets_pendulum=11.7,item_flayers_bota=8.1,item_enchanters_bauble=5.8},
                [5]={item_desolator_2=40.3,item_fallen_sky=19.4,item_demonicon=10.4,item_minotaur_horn=10.4,item_spider_legs=4.5,item_riftshadow_prism=4.5},
            },
            enhancement={
                [1]={item_enhancement_tough=62.3,item_enhancement_quickened=15.5,item_enhancement_brawny=14.2},
                [2]={item_enhancement_tough=79.4,item_enhancement_brawny=9.3,item_enhancement_quickened=7.4},
                [3]={item_enhancement_tough=80.8,item_enhancement_brawny=8.2,item_enhancement_crude=5.7},
                [4]={item_enhancement_tough=74.1,item_enhancement_brawny=9.3,item_enhancement_crude=7.9},
                [5]={item_enhancement_evolved=77.6,item_enhancement_fleetfooted=13.4,item_enhancement_vampiric=6},
            },
        },
    },
}
