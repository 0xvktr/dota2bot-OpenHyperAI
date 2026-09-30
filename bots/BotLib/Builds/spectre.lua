-- Header 3608; role rows 3602. Other role samples too small; forced picks use carry.
return {
    patch='7.41f', updated='2026-09-30', defaultRole='pos_1',
    source='https://dota2protracker.com/hero/Spectre?section=builds',
    overviewWindow='last 8 days, 7000+', buildWindow='2026-09-16 to 2026-09-30', buildUpdated='2026-09-30',
    roles={
        pos_1={matches=3531,winRate=51.9,rating=70,weight=100,buildMatches=5804,buildWinRate=53.0,skillMatches=2551,openingMatches=1298,openingObserved=5801},
        pos_2={matches=8,winRate=25.0,skipped=true},
        pos_3={matches=32,winRate=59.4,skipped=true},
        pos_4={matches=16,winRate=37.5,skipped=true},
        pos_5={matches=15,winRate=46.7,skipped=true},
    },
    -- Current-tier pick frequencies; T5 uses reviewed suitability.
    neutrals={
        pos_1={tier5Profile='attack',
            neutral={
                [1]={item_chipped_vest=27.2,item_possessed_mask=20.2,item_duelist_gloves=11.5,item_weighted_dice=11.0,item_polliwog_charm=7.8,item_occult_bracelet=7.5,item_dormant_curio=6.8},
                [2]={item_poor_mans_shield=19.0,item_mana_draught=17.1,item_defiant_shell=16.2,item_crippling_crossbow=7.8,item_essence_ring=6.1},
                [3]={item_cloak_of_flames=34.7,item_serrated_shiv=27.8,item_gunpowder_gauntlets=17.7,item_unrelenting_eye=3.3,item_stormcrafter=3.3,item_jidi_pollen_bag=2.0},
                [4]={item_giant_maul=28.0,item_prophets_pendulum=10.7,item_flayers_bota=9.7,item_rattlecage=9.0,item_enchanters_bauble=5.8},
                [5]={item_desolator_2=24.5,item_riftshadow_prism=18.1,item_divine_regalia=17.0,item_minotaur_horn=13.8,item_fallen_sky=7.4,item_heavy_blade=7.4,item_spider_legs=5.3},
            },
            enhancement={
                [1]={item_enhancement_alert=55.4,item_enhancement_vital=28.6,item_enhancement_brawny=13.0},
                [2]={item_enhancement_alert=66.9,item_enhancement_brawny=27.5,item_enhancement_nimble=3.0},
                [3]={item_enhancement_alert=76.9,item_enhancement_brawny=18.5,item_enhancement_nimble=2.9},
                [4]={item_enhancement_alert=89.3,item_enhancement_brawny=6.2,item_enhancement_quickened=2.6},
                [5]={item_enhancement_evolved=50.0,item_enhancement_audacious=25.5,item_enhancement_fleetfooted=23.4},
            },
        },
    },
}
