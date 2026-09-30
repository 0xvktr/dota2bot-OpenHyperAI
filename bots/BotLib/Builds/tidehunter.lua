-- Header 2370; role rows 2369. Other roles below 5%; forced picks use offlane.
return {
    patch='7.41f', updated='2026-09-30', defaultRole='pos_3',
    source='https://dota2protracker.com/hero/Tidehunter?section=builds',
    overviewWindow='last 8 days, 7000+', buildWindow='2026-09-16 to 2026-09-30', buildUpdated='2026-09-30',
    roles={
        pos_1={matches=5,winRate=80.0,skipped=true},
        pos_2={matches=17,winRate=29.4,skipped=true},
        pos_3={matches=2293,winRate=48.5,rating=34,weight=64,buildMatches=4452,buildWinRate=49.0,skillMatches=913,openingMatches=549,openingObserved=4450},
        pos_4={matches=27,winRate=51.9,skipped=true},
        pos_5={matches=27,winRate=37.0,skipped=true},
    },
    -- Current-tier pick frequencies; T5 uses reviewed suitability.
    neutrals={
        pos_3={tier5Profile='tank',
            neutral={
                [1]={item_chipped_vest=26.9,item_possessed_mask=17.9,item_occult_bracelet=13.2,item_polliwog_charm=7.8,item_dormant_curio=7.5,item_weighted_dice=6.5,item_ash_legion_shield=6.0},
                [2]={item_mana_draught=19.3,item_pogo_stick=10.6,item_searing_signet=10.5,item_poor_mans_shield=9.1,item_essence_ring=9.1,item_defiant_shell=8.0},
                [3]={item_cloak_of_flames=33.4,item_gunpowder_gauntlets=19.5,item_stormcrafter=8.0,item_serrated_shiv=5.9,item_unrelenting_eye=5.4,item_jidi_pollen_bag=5.3,item_spellslinger=5.3},
                [4]={item_conjurers_catalyst=24.2,item_rattlecage=17.6,item_prophets_pendulum=13.8,item_giant_maul=9.8,item_dandelion_amulet=9.5,item_enchanters_bauble=6.1},
                [5]={item_desolator_2=20.6,item_dezun_bloodrite=19.0,item_fallen_sky=17.5,item_minotaur_horn=12.7,item_demonicon=11.1,item_spider_legs=7.9},
            },
            enhancement={
                [1]={item_enhancement_brawny=39.8,item_enhancement_tough=23.6,item_enhancement_vital=21.6},
                [2]={item_enhancement_tough=41.3,item_enhancement_brawny=36.5,item_enhancement_quickened=17.1},
                [3]={item_enhancement_tough=44.0,item_enhancement_brawny=34.5,item_enhancement_quickened=15.6},
                [4]={item_enhancement_brawny=28.2,item_enhancement_tough=26.9,item_enhancement_quickened=22.4},
                [5]={item_enhancement_timeless=44.4,item_enhancement_evolved=31.7,item_enhancement_hulking=14.3},
            },
        },
    },
}
