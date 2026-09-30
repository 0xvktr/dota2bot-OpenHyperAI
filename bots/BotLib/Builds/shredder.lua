-- Skipped roles use the offlane build when forced.
return {
    patch='7.41f', updated='2026-09-30', defaultRole='pos_3',
    source='https://dota2protracker.com/hero/Timbersaw?section=builds',
    overviewWindow='last 8 days, 7000+', buildWindow='2026-09-16 to 2026-09-30', buildUpdated='2026-09-30',
    -- Overview header 4205; displayed role rows total 4195.
    roles={
        pos_1={matches=45,winRate=40,skipped=true},
        pos_2={matches=369,winRate=46.9,rating=31,weight=43,buildMatches=677,buildWinRate=46,skillMatches=190,openingMatches=115,openingObserved=677},
        pos_3={matches=3750,winRate=45.6,rating=14,weight=44,buildMatches=6308,buildWinRate=46,skillMatches=1160,openingMatches=724,openingObserved=6299},
        pos_4={matches=20,winRate=40,skipped=true},
        pos_5={matches=11,winRate=27.3,skipped=true},
    },
    -- Current-tier observations only; sparse T5 picks use reviewed suitability.
    neutrals={
        pos_3={tier5Profile='caster',
            neutral={
                [1]={item_chipped_vest=24.7,item_occult_bracelet=18.4,item_polliwog_charm=13.1,item_dormant_curio=11,item_ash_legion_shield=10.9,item_weighted_dice=6,item_stonefeather_satchel=5.3},
                [2]={item_mana_draught=33.5,item_essence_ring=16.9,item_poor_mans_shield=10.9,item_pogo_stick=10.1,item_searing_signet=7.3,item_crippling_crossbow=6.4},
                [3]={item_cloak_of_flames=31.9,item_partisans_brand=20,item_stormcrafter=11.4,item_spellslinger=10.6,item_jidi_pollen_bag=5.6,item_unrelenting_eye=3.8},
                [4]={item_conjurers_catalyst=41.8,item_prophets_pendulum=15.7,item_rattlecage=12,item_enchanters_bauble=7.7,item_dandelion_amulet=7.5},
                [5]={item_fallen_sky=18.1,item_minotaur_horn=16.7,item_harmonizer=16.7,item_dezun_bloodrite=15.3,item_spider_legs=4.2,item_demonicon=4.2},
            },
            enhancement={
                [1]={item_enhancement_brawny=52.7,item_enhancement_vital=31,item_enhancement_quickened=15.9},
                [2]={item_enhancement_greedy=65.6,item_enhancement_brawny=26.3,item_enhancement_quickened=5.4},
                [3]={item_enhancement_greedy=64.8,item_enhancement_brawny=26.3,item_enhancement_tough=5.5},
                [4]={item_enhancement_timeless=63.7,item_enhancement_brawny=23.7,item_enhancement_quickened=7.2},
                [5]={item_enhancement_timeless=66.7,item_enhancement_hulking=15.3,item_enhancement_evolved=13.9},
            },
        },
        pos_2={tier5Profile='caster',
            neutral={
                [1]={item_chipped_vest=26.6,item_occult_bracelet=17.6,item_dormant_curio=12.6,item_polliwog_charm=9.2,item_ash_legion_shield=8.4,item_stonefeather_satchel=5.8,item_weighted_dice=5.5},
                [2]={item_mana_draught=27.6,item_essence_ring=20.3,item_pogo_stick=10.6,item_poor_mans_shield=10.3,item_searing_signet=8.4,item_crippling_crossbow=5.4},
                [3]={item_cloak_of_flames=29.9,item_partisans_brand=22.8,item_stormcrafter=11.5,item_spellslinger=7.9,item_jidi_pollen_bag=5,item_unrelenting_eye=4.8,item_psychic_headband=3.4},
                [4]={item_conjurers_catalyst=44.9,item_prophets_pendulum=15,item_rattlecage=10.9,item_enchanters_bauble=7.7,item_dandelion_amulet=7.3},
                [5]={item_dezun_bloodrite=66.7,item_divine_regalia=33.3},
            },
            enhancement={
                [1]={item_enhancement_brawny=63.7,item_enhancement_quickened=20.8,item_enhancement_vital=14.2},
                [2]={item_enhancement_greedy=54.5,item_enhancement_brawny=32.1,item_enhancement_quickened=8.1},
                [3]={item_enhancement_greedy=54,item_enhancement_brawny=31.6,item_enhancement_tough=9.4},
                [4]={item_enhancement_timeless=69.2,item_enhancement_brawny=18.6,item_enhancement_quickened=6.5},
                [5]={item_enhancement_timeless=66.7,item_enhancement_hulking=33.3},
            },
        },
    },
}
