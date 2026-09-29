-- Header 8897; role rows sum to 8878. Carry only; forced picks use carry.
return {
    patch='7.41f', updated='2026-09-30', defaultRole='pos_1',
    source='https://dota2protracker.com/hero/Luna?section=builds',
    overviewWindow='last 8 days, 7000+', buildWindow='2026-09-15 to 2026-09-29', buildUpdated='2026-09-29',
    roles={
        pos_1={matches=8804,winRate=50.4,rating=64,weight=94,buildMatches=14997,buildWinRate=51,skillMatches=1252,openingMatches=3374,openingObserved=14997},
        pos_2={matches=38,winRate=42.1,skipped=true},
        pos_3={matches=19,winRate=36.8,skipped=true},
        pos_4={matches=5,winRate=0,skipped=true},
        pos_5={matches=12,winRate=41.7,skipped=true},
    },
    -- Current-tier observations only; sparse T5 picks use reviewed suitability.
    neutrals={
        pos_1={tier5Profile='attack',
            neutral={
                [1]={item_possessed_mask=26,item_weighted_dice=17.6,item_duelist_gloves=11.6,item_chipped_vest=9.4,item_dormant_curio=7.5,item_polliwog_charm=6.7,item_stonefeather_satchel=6.4},
                [2]={item_defiant_shell=17.9,item_pogo_stick=14.1,item_mana_draught=12.6,item_poor_mans_shield=11.8,item_essence_ring=6},
                [3]={item_serrated_shiv=37.5,item_gunpowder_gauntlets=27.2,item_cloak_of_flames=9.1,item_unrelenting_eye=4.6,item_partisans_brand=3.2},
                [4]={item_giant_maul=31.1,item_flayers_bota=21.2,item_prophets_pendulum=12.5,item_enchanters_bauble=6.9,item_conjurers_catalyst=4.5},
                [5]={item_desolator_2=30.6,item_divine_regalia=17.7,item_minotaur_horn=15,item_fallen_sky=10.9,item_spider_legs=8.8,item_riftshadow_prism=7.5},
            },
            enhancement={
                [1]={item_enhancement_alert=70.3,item_enhancement_quickened=21.6,item_enhancement_vital=4.1},
                [2]={item_enhancement_alert=65.9,item_enhancement_nimble=21.9,item_enhancement_quickened=10},
                [3]={item_enhancement_alert=74.9,item_enhancement_nimble=18.3,item_enhancement_quickened=4.7},
                [4]={item_enhancement_alert=90.2,item_enhancement_nimble=4.9,item_enhancement_quickened=4},
                [5]={item_enhancement_evolved=40.1,item_enhancement_audacious=32.7,item_enhancement_fleetfooted=19.7},
            },
        },
    },
}
