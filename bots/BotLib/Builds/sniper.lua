-- Header 2432; role rows 2431. Mid-only scope; eligible carry/support roles skipped. Forced picks use mid.
return {
    patch='7.41f', updated='2026-09-30', defaultRole='pos_2',
    source='https://dota2protracker.com/hero/Sniper?section=builds',
    overviewWindow='last 8 days, 7000+', buildWindow='2026-09-16 to 2026-09-30', buildUpdated='2026-09-30',
    roles={
        pos_1={matches=205,winRate=46.8,rating=32,skipped=true},
        pos_2={matches=1907,winRate=46.3,rating=29,weight=58,buildMatches=1801,buildWinRate=46.0,skillMatches=251,openingMatches=304,openingObserved=1801},
        pos_3={matches=34,winRate=47.1,skipped=true},
        pos_4={matches=207,winRate=40.1,rating=18,skipped=true},
        pos_5={matches=78,winRate=38.5,rating=29,skipped=true},
    },
    -- Current-tier pick frequencies; T5 uses reviewed suitability.
    neutrals={
        pos_2={tier5Profile='attack',
            neutral={
                [1]={item_duelist_gloves=22.9,item_possessed_mask=22.4,item_dormant_curio=13.2,item_weighted_dice=11.2,item_dagger_of_ristul=6.1,item_stonefeather_satchel=5.2,item_polliwog_charm=4.7},
                [2]={item_pogo_stick=13.7,item_searing_signet=11.0,item_mana_draught=9.8,item_essence_ring=9.3,item_defiant_shell=8.7},
                [3]={item_serrated_shiv=38.8,item_gunpowder_gauntlets=28.2,item_unrelenting_eye=4.3,item_psychic_headband=4.2,item_partisans_brand=3.9},
                [4]={item_giant_maul=31.0,item_flayers_bota=16.4,item_enchanters_bauble=10.1,item_conjurers_catalyst=6.5,item_prophets_pendulum=4.4},
                [5]={item_desolator_2=37.5,item_divine_regalia=18.8,item_minotaur_horn=9.4,item_heavy_blade=9.4,item_riftshadow_prism=9.4,item_spider_legs=6.3},
            },
            enhancement={
                [1]={item_enhancement_alert=75.5,item_enhancement_quickened=11.5,item_enhancement_brawny=11.0},
                [2]={item_enhancement_alert=84.2,item_enhancement_nimble=7.6,item_enhancement_brawny=4.9},
                [3]={item_enhancement_alert=88.2,item_enhancement_nimble=6.9,item_enhancement_brawny=3.2},
                [4]={item_enhancement_alert=94.7,item_enhancement_timeless=2.2,item_enhancement_quickened=2.0},
                [5]={item_enhancement_audacious=46.9,item_enhancement_evolved=37.5,item_enhancement_fleetfooted=12.5},
            },
        },
    },
}
