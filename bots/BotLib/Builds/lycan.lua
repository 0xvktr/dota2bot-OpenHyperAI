-- Header 1362; displayed role rows sum to 1359. Pos5 absent; zero displayed sample.
-- Requested offlane only; eligible mid deferred, forced picks use offlane.
return {
    patch='7.41f', updated='2026-09-30', defaultRole='pos_3',
    source='https://dota2protracker.com/hero/Lycan?section=builds',
    overviewWindow='last 8 days, 7000+', buildWindow='2026-09-15 to 2026-09-29', buildUpdated='2026-09-29',
    roles={
        pos_1={matches=5,winRate=60,skipped=true},
        pos_2={matches=178,winRate=53.9,skipped=true},
        pos_3={matches=1161,winRate=51.7,rating=47,weight=66,buildMatches=2091,buildWinRate=52,skillMatches=1331,openingMatches=170,openingObserved=2091},
        pos_4={matches=15,winRate=26.7,skipped=true},
        pos_5={matches=0,winRate=0,skipped=true},
    },
    -- Current-tier observations only; sparse T5 picks use reviewed suitability.
    neutrals={
        pos_3={tier5Profile='attack',
            neutral={
                [1]={item_duelist_gloves=17.2,item_chipped_vest=17.1,item_ash_legion_shield=13.5,item_weighted_dice=10.6,item_possessed_mask=9.9,item_occult_bracelet=8.6,item_dagger_of_ristul=7.3},
                [2]={item_medallion_of_courage=26.6,item_crippling_crossbow=16.2,item_defiant_shell=13.9,item_mana_draught=13.9,item_poor_mans_shield=9.3,item_essence_ring=4.3},
                [3]={item_serrated_shiv=27.6,item_gunpowder_gauntlets=27,item_cloak_of_flames=17,item_stormcrafter=5,item_jidi_pollen_bag=3.1},
                [4]={item_giant_maul=33.1,item_flayers_bota=17.3,item_prophets_pendulum=9.1,item_rattlecage=8.2,item_idol_of_screeauk=5},
                [5]={item_desolator_2=34.6,item_demonicon=23.1,item_fallen_sky=19.2,item_minotaur_horn=11.5,item_spider_legs=7.7,item_heavy_blade=3.8},
            },
            enhancement={
                [1]={item_enhancement_tough=63.3,item_enhancement_quickened=16.3,item_enhancement_brawny=14.7},
                [2]={item_enhancement_tough=71.6,item_enhancement_brawny=9.1,item_enhancement_greedy=7.2},
                [3]={item_enhancement_tough=75.9,item_enhancement_brawny=8.8,item_enhancement_crude=7.8},
                [4]={item_enhancement_tough=71.4,item_enhancement_crude=14.6,item_enhancement_quickened=7.8},
                [5]={item_enhancement_evolved=84.6,item_enhancement_fleetfooted=7.7,item_enhancement_hulking=7.7},
            },
        },
    },
}
