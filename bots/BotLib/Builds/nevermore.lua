-- Skipped support roles use the carry build when forced.
return {
    patch='7.41f', updated='2026-09-30', defaultRole='pos_1',
    source='https://dota2protracker.com/hero/Shadow%20Fiend?section=builds',
    overviewWindow='last 8 days, 7000+', buildWindow='2026-09-16 to 2026-09-30', buildUpdated='2026-09-30',
    -- Overview header 3713; displayed role rows total 3709.
    roles={
        pos_1={matches=1890,winRate=37.9,rating=7,weight=37,buildMatches=4833,buildWinRate=39,skillMatches=2204,openingMatches=1778,openingObserved=4831},
        pos_2={matches=1752,winRate=37.8,rating=7,weight=37,buildMatches=3383,buildWinRate=39,skillMatches=1022,openingMatches=669,openingObserved=3382},
        pos_3={matches=25,winRate=48,skipped=true},
        pos_4={matches=23,winRate=39.1,skipped=true},
        pos_5={matches=19,winRate=31.6,skipped=true},
    },
    -- Current-tier observations only; sparse T5 picks use reviewed suitability.
    neutrals={
        pos_1={tier5Profile='attack',
            neutral={
                [1]={item_possessed_mask=24.1,item_duelist_gloves=18.3,item_weighted_dice=13.4,item_dormant_curio=9.2,item_occult_bracelet=8.2,item_polliwog_charm=5.9,item_chipped_vest=5},
                [2]={item_mana_draught=23.9,item_defiant_shell=13.7,item_pogo_stick=13.2,item_poor_mans_shield=6.3,item_medallion_of_courage=6,item_essence_ring=5.9},
                [3]={item_serrated_shiv=39.7,item_gunpowder_gauntlets=27.8,item_unrelenting_eye=5.7,item_cloak_of_flames=2.9,item_partisans_brand=2.7},
                [4]={item_giant_maul=32,item_flayers_bota=19.9,item_prophets_pendulum=9.3,item_enchanters_bauble=6.9,item_conjurers_catalyst=3.6},
                [5]={item_desolator_2=40,item_divine_regalia=20,item_fallen_sky=12.7,item_minotaur_horn=10.9,item_riftshadow_prism=5.5,item_spider_legs=3.6,item_heavy_blade=1.8},
            },
            enhancement={
                [1]={item_enhancement_alert=70,item_enhancement_quickened=18.7,item_enhancement_brawny=9.5},
                [2]={item_enhancement_alert=78.4,item_enhancement_nimble=11,item_enhancement_quickened=8.2},
                [3]={item_enhancement_alert=86.5,item_enhancement_nimble=8.5,item_enhancement_quickened=3.3},
                [4]={item_enhancement_alert=92.7,item_enhancement_quickened=2.4,item_enhancement_timeless=2.4},
                [5]={item_enhancement_audacious=38.2,item_enhancement_evolved=27.3,item_enhancement_fleetfooted=18.2},
            },
        },
        pos_2={tier5Profile='caster',
            neutral={
                [1]={item_dormant_curio=15.8,item_duelist_gloves=14.6,item_possessed_mask=14.5,item_occult_bracelet=10,item_weighted_dice=9.7,item_stonefeather_satchel=8,item_kobold_cup=7.8},
                [2]={item_mana_draught=24.9,item_searing_signet=20.4,item_pogo_stick=19.1,item_essence_ring=9.6,item_crippling_crossbow=3.7,item_defiant_shell=3.6},
                [3]={item_gunpowder_gauntlets=19.9,item_serrated_shiv=19.3,item_partisans_brand=14.3,item_cloak_of_flames=5.5,item_stormcrafter=5.2},
                [4]={item_conjurers_catalyst=37.1,item_enchanters_bauble=13.3,item_giant_maul=12.5,item_prophets_pendulum=6.9,item_dandelion_amulet=5.7,item_flayers_bota=5},
                [5]={item_desolator_2=19.2,item_fallen_sky=11.5,item_divine_regalia=11.5,item_harmonizer=11.5,item_spider_legs=7.7,item_dezun_bloodrite=7.7},
            },
            enhancement={
                [1]={item_enhancement_quickened=58.4,item_enhancement_alert=30.5,item_enhancement_brawny=10.4},
                [2]={item_enhancement_quickened=46.9,item_enhancement_alert=32.3,item_enhancement_nimble=8.4},
                [3]={item_enhancement_alert=41.3,item_enhancement_quickened=37.1,item_enhancement_nimble=9.7},
                [4]={item_enhancement_timeless=60.6,item_enhancement_alert=27.2,item_enhancement_quickened=10.4},
                [5]={item_enhancement_timeless=71.2,item_enhancement_fleetfooted=13.5,item_enhancement_audacious=7.7},
            },
        },
    },
}
