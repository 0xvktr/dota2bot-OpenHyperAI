-- Carry/mid by request; eligible offlane/support deferred. Header 1981; role rows 1975.
return {
    patch='7.41f', updated='2026-09-30', defaultRole='pos_1',
    source='https://dota2protracker.com/hero/Monkey%20King?section=builds',
    overviewWindow='last 8 days, 7000+', buildWindow='2026-09-16 to 2026-09-30', buildUpdated='2026-09-30',
    roles={
        pos_1={matches=969,winRate=48.8,rating=33,weight=53,buildMatches=1171,buildWinRate=60,skillMatches=59,openingMatches=293,openingObserved=1171},
        pos_2={matches=693,winRate=47.9,rating=33,weight=49,buildMatches=1265,buildWinRate=49,skillMatches=58,openingMatches=99,openingObserved=1264},
        pos_3={matches=170,winRate=54.1,skipped=true},
        pos_4={matches=112,winRate=42,skipped=true},
        pos_5={matches=31,winRate=38.7,skipped=true},
    },
    -- Current-tier observations; T5 uses reviewed suitability.
    neutrals={
        pos_1={tier5Profile='attack',
            neutral={
                [1]={item_duelist_gloves=21,item_possessed_mask=17.8,item_chipped_vest=11.5,item_weighted_dice=11.4,item_dormant_curio=10.2,item_occult_bracelet=6.9,item_dagger_of_ristul=5},
                [2]={item_defiant_shell=26.3,item_mana_draught=14.6,item_poor_mans_shield=12.9,item_crippling_crossbow=10.5,item_medallion_of_courage=7.2,item_essence_ring=6},
                [3]={item_serrated_shiv=34.1,item_gunpowder_gauntlets=29.4,item_cloak_of_flames=12.1,item_unrelenting_eye=3.4,item_partisans_brand=2.8},
                [4]={item_giant_maul=29.5,item_flayers_bota=17.9,item_prophets_pendulum=12.8,item_enchanters_bauble=8.5,item_rattlecage=3.8},
                [5]={item_desolator_2=34.8,item_divine_regalia=30.4,item_minotaur_horn=13,item_spider_legs=8.7,item_demonicon=4.3,item_heavy_blade=4.3},
            },
            enhancement={
                [1]={item_enhancement_alert=63.6,item_enhancement_brawny=18.4,item_enhancement_quickened=10.7},
                [2]={item_enhancement_alert=74.7,item_enhancement_brawny=17.7,item_enhancement_nimble=5.7},
                [3]={item_enhancement_alert=79.7,item_enhancement_brawny=15.2,item_enhancement_nimble=4.2},
                [4]={item_enhancement_alert=91.5,item_enhancement_brawny=2.9,item_enhancement_timeless=2.2},
                [5]={item_enhancement_audacious=60.9,item_enhancement_evolved=21.7,item_enhancement_fleetfooted=17.4},
            },
        },
        pos_2={tier5Profile='attack',
            neutral={
                [1]={item_duelist_gloves=24.9,item_possessed_mask=17.7,item_weighted_dice=7.9,item_dormant_curio=7.8,item_chipped_vest=7.7,item_ash_legion_shield=7.4,item_dagger_of_ristul=7},
                [2]={item_defiant_shell=25.4,item_poor_mans_shield=12.8,item_medallion_of_courage=12,item_crippling_crossbow=10.1,item_mana_draught=9.6,item_essence_ring=8.6},
                [3]={item_serrated_shiv=32.1,item_gunpowder_gauntlets=30.5,item_cloak_of_flames=11,item_unrelenting_eye=4.5},
                [4]={item_giant_maul=30,item_flayers_bota=14.4,item_enchanters_bauble=9.7,item_prophets_pendulum=8.6,item_dandelion_amulet=5},
                [5]={item_minotaur_horn=42.9,item_desolator_2=28.6,item_fallen_sky=14.3,item_heavy_blade=7.1,item_riftshadow_prism=7.1},
            },
            enhancement={
                [1]={item_enhancement_alert=66.9,item_enhancement_brawny=19.4,item_enhancement_quickened=12.1},
                [2]={item_enhancement_alert=82.3,item_enhancement_brawny=11.1,item_enhancement_nimble=5},
                [3]={item_enhancement_alert=86.9,item_enhancement_brawny=7.7,item_enhancement_nimble=4.1},
                [4]={item_enhancement_alert=93.7,item_enhancement_brawny=2.6,item_enhancement_timeless=1.3},
                [5]={item_enhancement_audacious=42.9,item_enhancement_evolved=35.7,item_enhancement_fleetfooted=21.4},
            },
        },
    },
}
