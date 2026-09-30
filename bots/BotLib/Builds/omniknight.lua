-- D2PT 7.41f; Requested pos 5/3; eligible pos 4 deferred.
return {
    patch='7.41f', updated='2026-09-30', defaultRole='pos_5',
    source='https://dota2protracker.com/hero/Omniknight?section=builds',
    overviewWindow='last 8 days, 7000+', buildWindow='2026-09-16 to 2026-09-30', buildUpdated='2026-09-30',
    roles={
        pos_1={matches=24,winRate=41.7,skipped=true},
        pos_2={matches=23,winRate=43.5,skipped=true},
        pos_3={matches=415,winRate=49.6,rating=36,weight=46,buildMatches=653,buildWinRate=49,skillMatches=52,skillWinRate=51.9,openingMatches=121,openingWinRate=51.2,openingObserved=653},
        pos_4={matches=116,winRate=50.9,skipped=true},
        pos_5={matches=568,winRate=51.9,rating=43,weight=53,buildMatches=1071,buildWinRate=54,skillMatches=455,skillWinRate=55.8,openingMatches=59,openingWinRate=50.8,openingObserved=1071},
    },
    -- Current-tier picks; sparse T5 uses the reviewed profile.
    neutrals={
        pos_5={tier5Profile='support',
            neutral={
                [1]={item_ash_legion_shield=17.3,item_kobold_cup=14.5,item_polliwog_charm=13.4,item_dormant_curio=13.2,item_foragers_kit=11.7,item_chipped_vest=10.3,item_stonefeather_satchel=8.6},
                [2]={item_mana_draught=19.9,item_essence_ring=16.1,item_pogo_stick=16.1,item_medallion_of_courage=10.7,item_crippling_crossbow=8.4,item_poor_mans_shield=5.3},
                [3]={item_cloak_of_flames=14.8,item_psychic_headband=14.7,item_spellslinger=10.2,item_jidi_pollen_bag=8.2,item_stormcrafter=6.4},
                [4]={item_prophets_pendulum=26.9,item_dandelion_amulet=22.7,item_enchanters_bauble=11.0,item_idol_of_screeauk=7.2,item_rattlecage=4.9,item_metamorphic_mandible=4.5,item_giant_maul=3.8},
                [5]={item_fallen_sky=33.3,item_demonicon=22.2,item_harmonizer=11.1},
            },
            enhancement={
                [1]={item_enhancement_quickened=49.6,item_enhancement_brawny=45.1,item_enhancement_vital=4.8},
                [2]={item_enhancement_greedy=78.2,item_enhancement_quickened=12.6,item_enhancement_brawny=7.3},
                [3]={item_enhancement_greedy=78.0,item_enhancement_quickened=10.2,item_enhancement_brawny=8.2},
                [4]={item_enhancement_quickened=50.8,item_enhancement_brawny=37.1,item_enhancement_timeless=6.4},
                [5]={item_enhancement_fleetfooted=44.4,item_enhancement_evolved=33.3,item_enhancement_timeless=22.2},
            },
        },
        pos_3={tier5Profile='attack',
            neutral={
                [1]={item_chipped_vest=22.8,item_duelist_gloves=12.9,item_dormant_curio=11.2,item_weighted_dice=9.2,item_occult_bracelet=8.7,item_possessed_mask=8.4,item_stonefeather_satchel=7.2},
                [2]={item_defiant_shell=23.1,item_crippling_crossbow=12.8,item_pogo_stick=12.0,item_mana_draught=11.1,item_poor_mans_shield=10.0,item_essence_ring=6.1},
                [3]={item_cloak_of_flames=30.0,item_gunpowder_gauntlets=27.6,item_serrated_shiv=13.5,item_stormcrafter=5.7,item_unrelenting_eye=4.5,item_partisans_brand=4.3,item_jidi_pollen_bag=3.3},
                [4]={item_giant_maul=23.4,item_prophets_pendulum=17.3,item_rattlecage=9.8,item_dandelion_amulet=8.9,item_conjurers_catalyst=8.4,item_idol_of_screeauk=5.6},
                [5]={item_demonicon=60.0,item_desolator_2=20.0,item_minotaur_horn=20.0},
            },
            enhancement={
                [1]={item_enhancement_quickened=36.1,item_enhancement_tough=30.0,item_enhancement_brawny=29.2},
                [2]={item_enhancement_tough=55.0,item_enhancement_quickened=20.5,item_enhancement_brawny=19.2},
                [3]={item_enhancement_tough=59.0,item_enhancement_brawny=20.6,item_enhancement_quickened=13.7},
                [4]={item_enhancement_tough=48.1,item_enhancement_brawny=22.0,item_enhancement_quickened=19.2},
                [5]={item_enhancement_evolved=80.0,item_enhancement_hulking=20.0},
            },
        },
    },
}
