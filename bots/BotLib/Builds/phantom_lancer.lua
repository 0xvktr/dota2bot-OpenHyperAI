-- Skipped roles use the carry build when forced.
return {
    patch='7.41f', updated='2026-09-30', defaultRole='pos_1',
    source='https://dota2protracker.com/hero/Phantom%20Lancer?section=builds',
    overviewWindow='last 8 days, 7000+', buildWindow='2026-09-16 to 2026-09-30', buildUpdated='2026-09-30',
    -- Overview header 7706; displayed role rows total 7684.
    roles={
        pos_1={matches=7621,winRate=51.9,rating=100,weight=100,buildMatches=13682,buildWinRate=52,skillMatches=6029,openingMatches=3206,openingObserved=13675},
        pos_2={matches=19,winRate=42.1,skipped=true},
        pos_3={matches=26,winRate=34.6,skipped=true},
        pos_4={matches=6,winRate=50,skipped=true},
        pos_5={matches=12,winRate=25,skipped=true},
    },
    -- Current-tier observations only; sparse T5 picks use reviewed suitability.
    neutrals={
        pos_1={tier5Profile='attack',
            neutral={
                [1]={item_possessed_mask=25.8,item_weighted_dice=18.1,item_duelist_gloves=13.7,item_chipped_vest=9.4,item_dormant_curio=9,item_polliwog_charm=7.6,item_occult_bracelet=4.6},
                [2]={item_mana_draught=15.6,item_poor_mans_shield=15.3,item_defiant_shell=11.7,item_crippling_crossbow=11.1,item_medallion_of_courage=7.5},
                [3]={item_serrated_shiv=33.2,item_cloak_of_flames=24.8,item_gunpowder_gauntlets=18.7,item_unrelenting_eye=3.7},
                [4]={item_giant_maul=29.1,item_prophets_pendulum=17.5,item_enchanters_bauble=8.5,item_flayers_bota=5.6,item_dandelion_amulet=5.4},
                [5]={item_desolator_2=35.2,item_divine_regalia=14.3,item_fallen_sky=11,item_minotaur_horn=11,item_riftshadow_prism=7.7,item_heavy_blade=6.6},
            },
            enhancement={
                [1]={item_enhancement_alert=74.2,item_enhancement_brawny=11.4,item_enhancement_quickened=7.6},
                [2]={item_enhancement_alert=79.8,item_enhancement_brawny=12.4,item_enhancement_nimble=4.5},
                [3]={item_enhancement_alert=78.4,item_enhancement_brawny=16.9,item_enhancement_nimble=3.1},
                [4]={item_enhancement_alert=79.4,item_enhancement_brawny=13.8,item_enhancement_quickened=5.1},
                [5]={item_enhancement_evolved=56.6,item_enhancement_fleetfooted=20.9,item_enhancement_audacious=18.7},
            },
        },
    },
}
