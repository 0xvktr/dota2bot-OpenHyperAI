-- Skipped roles use the offlane build when forced.
return {
    patch='7.41f', updated='2026-09-30', defaultRole='pos_3',
    source='https://dota2protracker.com/hero/Razor?section=builds',
    overviewWindow='last 8 days, 7000+', buildWindow='2026-09-16 to 2026-09-30', buildUpdated='2026-09-30',
    -- Overview header 1940; displayed role rows total 1934.
    roles={
        pos_1={matches=457,winRate=53.8,rating=43,weight=51,buildMatches=826,buildWinRate=52,skillMatches=97,openingMatches=135,openingObserved=826},
        pos_2={matches=223,winRate=45.3,rating=31,weight=40,buildMatches=433,buildWinRate=47,skillMatches=31,openingMatches=110,openingObserved=433},
        pos_3={matches=1196,winRate=51.4,rating=43,weight=63,buildMatches=2101,buildWinRate=50,skillMatches=181,openingMatches=344,openingObserved=2101},
        pos_4={matches=29,winRate=48.3,skipped=true},
        pos_5={matches=29,winRate=44.8,skipped=true},
    },
    -- Current-tier observations only; sparse T5 picks use reviewed suitability.
    neutrals={
        pos_3={tier5Profile='attack',
            neutral={
                [1]={item_possessed_mask=18,item_duelist_gloves=16.5,item_chipped_vest=13.8,item_dormant_curio=8.5,item_polliwog_charm=7.8,item_occult_bracelet=7.7,item_ash_legion_shield=7.3},
                [2]={item_mana_draught=15.9,item_essence_ring=14.7,item_searing_signet=14.3,item_poor_mans_shield=11.3,item_defiant_shell=8.6,item_crippling_crossbow=7.6,item_pogo_stick=6.9},
                [3]={item_serrated_shiv=23.8,item_cloak_of_flames=20,item_gunpowder_gauntlets=15.5,item_stormcrafter=13.2,item_unrelenting_eye=6.6,item_partisans_brand=4.7,item_jidi_pollen_bag=2.1},
                [4]={item_giant_maul=17.6,item_rattlecage=16.6,item_conjurers_catalyst=15.6,item_prophets_pendulum=13,item_idol_of_screeauk=7.5,item_dandelion_amulet=6.9,item_flayers_bota=5.7},
                [5]={item_fallen_sky=30.4,item_desolator_2=13,item_spider_legs=13,item_minotaur_horn=13,item_heavy_blade=8.7,item_divine_regalia=8.7,item_demonicon=4.3},
            },
            enhancement={
                [1]={item_enhancement_quickened=34.9,item_enhancement_alert=33.5,item_enhancement_brawny=21.4},
                [2]={item_enhancement_alert=42,item_enhancement_brawny=24,item_enhancement_quickened=19.5},
                [3]={item_enhancement_alert=47,item_enhancement_brawny=22.1,item_enhancement_quickened=16.1},
                [4]={item_enhancement_alert=51.7,item_enhancement_quickened=27.7,item_enhancement_brawny=13.8},
                [5]={item_enhancement_evolved=30.4,item_enhancement_fleetfooted=26.1,item_enhancement_vampiric=26.1},
            },
        },
        pos_1={tier5Profile='attack',
            neutral={
                [1]={item_possessed_mask=21.1,item_duelist_gloves=14.8,item_chipped_vest=12.2,item_weighted_dice=10.1,item_occult_bracelet=8.4,item_dormant_curio=7.7,item_stonefeather_satchel=7},
                [2]={item_mana_draught=24,item_searing_signet=10,item_pogo_stick=9.6,item_poor_mans_shield=9.5,item_crippling_crossbow=9,item_essence_ring=8.5,item_defiant_shell=8},
                [3]={item_serrated_shiv=34.2,item_gunpowder_gauntlets=21.5,item_cloak_of_flames=12.3,item_stormcrafter=7.7,item_unrelenting_eye=7.1,item_partisans_brand=3.6},
                [4]={item_giant_maul=25.4,item_prophets_pendulum=13.6,item_conjurers_catalyst=11.3,item_flayers_bota=9.3,item_rattlecage=8.8,item_idol_of_screeauk=7.3},
                [5]={item_desolator_2=25,item_minotaur_horn=25,item_divine_regalia=25,item_heavy_blade=12.5,item_riftshadow_prism=12.5},
            },
            enhancement={
                [1]={item_enhancement_alert=43.6,item_enhancement_quickened=32.8,item_enhancement_brawny=13.2},
                [2]={item_enhancement_alert=51.6,item_enhancement_quickened=18.1,item_enhancement_nimble=16.7},
                [3]={item_enhancement_alert=60.5,item_enhancement_nimble=17.4,item_enhancement_quickened=12.9},
                [4]={item_enhancement_alert=71.5,item_enhancement_quickened=18.1,item_enhancement_nimble=5.6},
                [5]={item_enhancement_audacious=50,item_enhancement_evolved=37.5,item_enhancement_vampiric=12.5},
            },
        },
        pos_2={tier5Profile='attack',
            neutral={
                [1]={item_duelist_gloves=18.7,item_possessed_mask=15.2,item_dormant_curio=13.9,item_chipped_vest=11.5,item_occult_bracelet=6.9,item_stonefeather_satchel=6.7,item_kobold_cup=6.5},
                [2]={item_essence_ring=17.2,item_mana_draught=16.7,item_searing_signet=14.7,item_crippling_crossbow=10,item_poor_mans_shield=9.3,item_defiant_shell=8.6,item_pogo_stick=7.9},
                [3]={item_serrated_shiv=26,item_cloak_of_flames=18.3,item_gunpowder_gauntlets=18,item_stormcrafter=15.4,item_unrelenting_eye=6.6,item_partisans_brand=2.9,item_jidi_pollen_bag=2.3},
                [4]={item_conjurers_catalyst=19,item_prophets_pendulum=15.2,item_giant_maul=12,item_flayers_bota=12,item_rattlecage=11.4,item_dandelion_amulet=7.6,item_idol_of_screeauk=5.4},
                [5]={item_minotaur_horn=50,item_spider_legs=25,item_desolator_2=12.5,item_heavy_blade=12.5},
            },
            enhancement={
                [1]={item_enhancement_quickened=39.5,item_enhancement_alert=33.5,item_enhancement_brawny=20.3},
                [2]={item_enhancement_alert=47,item_enhancement_quickened=20.5,item_enhancement_brawny=17.9},
                [3]={item_enhancement_alert=54.3,item_enhancement_nimble=17.1,item_enhancement_brawny=14.9},
                [4]={item_enhancement_alert=65.2,item_enhancement_quickened=19.6,item_enhancement_brawny=6.5},
                [5]={item_enhancement_fleetfooted=50,item_enhancement_audacious=25,item_enhancement_evolved=25},
            },
        },
    },
}
