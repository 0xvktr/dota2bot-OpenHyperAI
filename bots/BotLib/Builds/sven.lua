-- Skipped roles use carry; Madness lifesteal is reused by Satanic.
return {
    patch='7.41f', updated='2026-09-30', defaultRole='pos_1',
    source='https://dota2protracker.com/hero/Sven?section=builds',
    overviewWindow='last 8 days, 7000+', buildWindow='2026-09-16 to 2026-09-30', buildUpdated='2026-09-30',
    roles={
        pos_1={matches=8143,winRate=52.2,rating=73,weight=100,buildMatches=13356,buildWinRate=52.0,skillMatches=2931,openingMatches=1700,openingObserved=13351},
        pos_2={matches=16,winRate=56.3,skipped=true},
        pos_3={matches=56,winRate=42.9,skipped=true},
        pos_4={matches=13,winRate=46.2,skipped=true},
        pos_5={matches=16,winRate=31.3,skipped=true},
    },
    -- Current-tier observations only; sparse T5 picks use reviewed suitability.
    neutrals={
        pos_1={tier5Profile='attack',
            neutral={
                [1]={item_possessed_mask=19.2,item_duelist_gloves=15.9,item_weighted_dice=15.8,item_chipped_vest=15.6,item_dormant_curio=7.6,item_polliwog_charm=5.8,item_dagger_of_ristul=5.6},
                [2]={item_defiant_shell=30.9,item_pogo_stick=12.1,item_poor_mans_shield=10.8,item_medallion_of_courage=8.9,item_mana_draught=7.5,item_crippling_crossbow=6.3},
                [3]={item_serrated_shiv=33.9,item_gunpowder_gauntlets=30.0,item_cloak_of_flames=7.6,item_unrelenting_eye=5.7,item_partisans_brand=1.8},
                [4]={item_giant_maul=35.0,item_flayers_bota=20.7,item_prophets_pendulum=8.6,item_enchanters_bauble=5.2},
                [5]={item_desolator_2=35.2,item_minotaur_horn=15.3,item_divine_regalia=13.1,item_fallen_sky=12.5,item_spider_legs=8.0,item_heavy_blade=5.1,item_riftshadow_prism=4.0},
            },
            enhancement={
                [1]={item_enhancement_tough=62.6,item_enhancement_quickened=25.4,item_enhancement_vital=7.4},
                [2]={item_enhancement_tough=73.2,item_enhancement_quickened=14.9,item_enhancement_crude=10.0},
                [3]={item_enhancement_tough=76.4,item_enhancement_crude=13.4,item_enhancement_quickened=8.8},
                [4]={item_enhancement_tough=65.2,item_enhancement_crude=17.7,item_enhancement_quickened=14.9},
                [5]={item_enhancement_evolved=67.6,item_enhancement_fleetfooted=28.4,item_enhancement_vampiric=3.4},
            },
        },
    },
}
