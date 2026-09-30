-- D2PT 7.41f; Only mid/offlane meet the sample thresholds.
return {
    patch='7.41f', updated='2026-09-30', defaultRole='pos_2',
    source='https://dota2protracker.com/hero/Pangolier?section=builds',
    overviewWindow='last 8 days, 7000+', buildWindow='2026-09-16 to 2026-09-30', buildUpdated='2026-09-30',
    roles={
        pos_1={matches=7,winRate=42.9,skipped=true},
        pos_2={matches=2735,winRate=47.7,rating=34,weight=64,buildMatches=4747,buildWinRate=48,skillMatches=1907,skillWinRate=46.6,openingMatches=1617,openingWinRate=49,openingObserved=4746},
        pos_3={matches=737,winRate=43.7,rating=16,weight=40,buildMatches=1335,buildWinRate=44,skillMatches=451,skillWinRate=43.5,openingMatches=144,openingWinRate=42.4,openingObserved=1334},
        pos_4={matches=12,winRate=33.3,skipped=true},
        pos_5={matches=5,winRate=20,skipped=true},
    },
    -- Current-tier picks; sparse T5 uses the reviewed profile.
    neutrals={
        pos_2={tier5Profile='attack',
            neutral={
                [1]={item_possessed_mask=21.6,item_dormant_curio=11.8,item_duelist_gloves=11.6,item_occult_bracelet=11.1,item_chipped_vest=10.7,item_weighted_dice=9.7,item_ash_legion_shield=7.2},
                [2]={item_mana_draught=27.4,item_medallion_of_courage=12.1,item_essence_ring=10.7,item_pogo_stick=9.2,item_crippling_crossbow=8.3,item_defiant_shell=7.9,item_poor_mans_shield=6.7},
                [3]={item_serrated_shiv=32.1,item_gunpowder_gauntlets=25.6,item_cloak_of_flames=15.9,item_stormcrafter=6.0,item_partisans_brand=3.9,item_jidi_pollen_bag=2.4},
                [4]={item_giant_maul=22.3,item_conjurers_catalyst=21.8,item_prophets_pendulum=12.2,item_rattlecage=8.0,item_enchanters_bauble=7.2,item_dandelion_amulet=5.5},
                [5]={item_desolator_2=26.2,item_fallen_sky=18.0,item_minotaur_horn=18.0,item_demonicon=11.5,item_dezun_bloodrite=9.8,item_divine_regalia=6.6},
            },
            enhancement={
                [1]={item_enhancement_mystical=62.8,item_enhancement_alert=23.0,item_enhancement_quickened=11.3},
                [2]={item_enhancement_mystical=58.8,item_enhancement_alert=25.1,item_enhancement_quickened=8.6},
                [3]={item_enhancement_mystical=51.0,item_enhancement_alert=29.4,item_enhancement_titanic=11.6},
                [4]={item_enhancement_alert=32.9,item_enhancement_timeless=18.3,item_enhancement_titanic=17.4},
                [5]={item_enhancement_evolved=50.8,item_enhancement_timeless=24.6,item_enhancement_fleetfooted=13.1},
            },
        },
        pos_3={tier5Profile='attack',
            neutral={
                [1]={item_possessed_mask=23.7,item_chipped_vest=15.9,item_occult_bracelet=11.1,item_polliwog_charm=9.4,item_dormant_curio=9.3,item_ash_legion_shield=8.0,item_weighted_dice=7.9},
                [2]={item_mana_draught=26.5,item_essence_ring=10.9,item_medallion_of_courage=10.6,item_pogo_stick=9.0,item_poor_mans_shield=8.6,item_defiant_shell=7.4,item_crippling_crossbow=7.3},
                [3]={item_serrated_shiv=31.4,item_gunpowder_gauntlets=20.7,item_cloak_of_flames=18.3,item_stormcrafter=8.4,item_jidi_pollen_bag=3.7,item_spellslinger=3.4,item_partisans_brand=3.4},
                [4]={item_conjurers_catalyst=23.1,item_giant_maul=20.2,item_prophets_pendulum=12.2,item_rattlecage=9.7,item_enchanters_bauble=8.7,item_dandelion_amulet=6.0},
                [5]={item_desolator_2=28.6,item_fallen_sky=21.4,item_demonicon=14.3,item_minotaur_horn=7.1,item_dezun_bloodrite=7.1},
            },
            enhancement={
                [1]={item_enhancement_mystical=69.2,item_enhancement_alert=15.7,item_enhancement_vital=9.1},
                [2]={item_enhancement_mystical=65.6,item_enhancement_alert=19.4,item_enhancement_quickened=6.1},
                [3]={item_enhancement_mystical=61.8,item_enhancement_alert=21.3,item_enhancement_titanic=8.2},
                [4]={item_enhancement_alert=26.8,item_enhancement_mystical=25.8,item_enhancement_quickened=16.1},
                [5]={item_enhancement_evolved=35.7,item_enhancement_timeless=28.6,item_enhancement_vampiric=21.4},
            },
        },
    },
}
