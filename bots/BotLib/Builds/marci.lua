-- Mid/offlane; eligible supports deferred after reviewing combat-heavy builds and low role ratings. Header 2190; role rows 2182.
return {
    patch='7.41f', updated='2026-09-30', defaultRole='pos_2',
    source='https://dota2protracker.com/hero/Marci?section=builds',
    overviewWindow='last 8 days, 7000+', buildWindow='2026-09-16 to 2026-09-30', buildUpdated='2026-09-30',
    roles={
        pos_1={matches=64,winRate=54.7,skipped=true},
        pos_2={matches=805,winRate=56.8,rating=61,weight=69,buildMatches=1213,buildWinRate=61,skillMatches=304,openingMatches=87,openingObserved=1213},
        pos_3={matches=542,winRate=55,rating=44,weight=53,buildMatches=923,buildWinRate=57,skillMatches=158,openingMatches=104,openingObserved=923},
        pos_4={matches=378,winRate=46.3,skipped=true},
        pos_5={matches=393,winRate=45.5,skipped=true},
    },
    -- Current-tier observations; T5 uses reviewed suitability.
    neutrals={
        pos_2={tier5Profile='attack',
            neutral={
                [1]={item_possessed_mask=18.1,item_duelist_gloves=12.2,item_dagger_of_ristul=12.1,item_chipped_vest=11.8,item_dormant_curio=11.6,item_weighted_dice=10.1,item_stonefeather_satchel=5.9},
                [2]={item_medallion_of_courage=14.2,item_crippling_crossbow=12,item_mana_draught=11.5,item_defiant_shell=11,item_searing_signet=8,item_poor_mans_shield=6.9,item_essence_ring=6.4},
                [3]={item_serrated_shiv=38,item_gunpowder_gauntlets=24,item_cloak_of_flames=12,item_unrelenting_eye=4.3,item_stormcrafter=2.7,item_partisans_brand=2.5},
                [4]={item_giant_maul=35.2,item_flayers_bota=12.9,item_prophets_pendulum=8.8,item_conjurers_catalyst=5.2,item_enchanters_bauble=5},
                [5]={item_desolator_2=36.4,item_heavy_blade=36.4,item_minotaur_horn=9.1,item_divine_regalia=9.1,item_riftshadow_prism=9.1},
            },
            enhancement={
                [1]={item_enhancement_quickened=37.5,item_enhancement_alert=36.3,item_enhancement_mystical=23.2},
                [2]={item_enhancement_alert=42.9,item_enhancement_mystical=25.5,item_enhancement_quickened=16.2},
                [3]={item_enhancement_alert=49.9,item_enhancement_titanic=21.3,item_enhancement_mystical=16.2},
                [4]={item_enhancement_alert=68.8,item_enhancement_titanic=20,item_enhancement_quickened=5.7},
                [5]={item_enhancement_evolved=81.8,item_enhancement_fleetfooted=9.1,item_enhancement_vampiric=9.1},
            },
        },
        pos_3={tier5Profile='attack',
            neutral={
                [1]={item_possessed_mask=15.9,item_chipped_vest=15.1,item_duelist_gloves=12,item_dagger_of_ristul=11.4,item_weighted_dice=9.1,item_stonefeather_satchel=7.8,item_dormant_curio=7.4},
                [2]={item_mana_draught=14.8,item_medallion_of_courage=12.3,item_defiant_shell=11.7,item_poor_mans_shield=11.1,item_essence_ring=10.6,item_crippling_crossbow=10.5,item_searing_signet=5.2},
                [3]={item_serrated_shiv=35.3,item_gunpowder_gauntlets=23.8,item_cloak_of_flames=17.7,item_stormcrafter=3.7,item_unrelenting_eye=2.8},
                [4]={item_giant_maul=28.1,item_flayers_bota=9.6,item_enchanters_bauble=9.4,item_conjurers_catalyst=6.4,item_dandelion_amulet=6.1},
                [5]={item_desolator_2=50,item_minotaur_horn=16.7,item_divine_regalia=16.7,item_fallen_sky=8.3,item_heavy_blade=8.3},
            },
            enhancement={
                [1]={item_enhancement_quickened=32.3,item_enhancement_mystical=32.1,item_enhancement_alert=30.7},
                [2]={item_enhancement_alert=35.9,item_enhancement_mystical=32.2,item_enhancement_quickened=22.4},
                [3]={item_enhancement_alert=41.3,item_enhancement_mystical=26.4,item_enhancement_quickened=16.2},
                [4]={item_enhancement_alert=66.1,item_enhancement_titanic=14.9,item_enhancement_quickened=9.6},
                [5]={item_enhancement_evolved=58.3,item_enhancement_vampiric=25,item_enhancement_fleetfooted=16.7},
            },
        },
    },
}
