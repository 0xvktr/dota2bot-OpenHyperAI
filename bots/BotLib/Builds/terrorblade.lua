-- Header 4640; role rows 4623. Other roles below 5%; forced picks use carry.
return {
    patch='7.41f', updated='2026-09-30', defaultRole='pos_1',
    source='https://dota2protracker.com/hero/Terrorblade?section=builds',
    overviewWindow='last 8 days, 7000+', buildWindow='2026-09-16 to 2026-09-30', buildUpdated='2026-09-30',
    roles={
        pos_1={matches=4536,winRate=48.2,rating=40,weight=70,buildMatches=8507,buildWinRate=48.0,skillMatches=1099,openingMatches=1816,openingObserved=8506},
        pos_2={matches=4,winRate=50.0,skipped=true},
        pos_3={matches=62,winRate=48.4,rating=33,skipped=true},
        pos_4={matches=15,winRate=26.7,skipped=true},
        pos_5={matches=6,winRate=16.7,skipped=true},
    },
    -- Current-tier pick frequencies; T5 uses reviewed suitability.
    neutrals={
        pos_1={tier5Profile='attack',
            neutral={
                [1]={item_possessed_mask=25.6,item_weighted_dice=16.9,item_duelist_gloves=13.0,item_chipped_vest=8.7,item_occult_bracelet=8.2,item_dormant_curio=7.7,item_polliwog_charm=5.7},
                [2]={item_mana_draught=24.8,item_poor_mans_shield=12.8,item_defiant_shell=12.5,item_crippling_crossbow=8.6,item_pogo_stick=6.1,item_medallion_of_courage=6.0},
                [3]={item_serrated_shiv=36.8,item_gunpowder_gauntlets=24.1,item_cloak_of_flames=17.2,item_unrelenting_eye=4.5},
                [4]={item_giant_maul=30.1,item_flayers_bota=19.2,item_prophets_pendulum=13.6,item_enchanters_bauble=7.6,item_dandelion_amulet=3.3},
                [5]={item_desolator_2=32.3,item_minotaur_horn=17.7,item_divine_regalia=16.7,item_fallen_sky=11.5,item_spider_legs=7.3,item_riftshadow_prism=6.3,item_heavy_blade=4.2},
            },
            enhancement={
                [1]={item_enhancement_alert=69.3,item_enhancement_quickened=17.8,item_enhancement_brawny=9.0},
                [2]={item_enhancement_alert=73.7,item_enhancement_nimble=11.7,item_enhancement_quickened=9.2},
                [3]={item_enhancement_alert=81.9,item_enhancement_nimble=9.5,item_enhancement_quickened=4.6},
                [4]={item_enhancement_alert=95.5,item_enhancement_quickened=2.1,item_enhancement_nimble=1.2},
                [5]={item_enhancement_evolved=40.6,item_enhancement_audacious=31.3,item_enhancement_fleetfooted=22.9},
            },
        },
    },
}
