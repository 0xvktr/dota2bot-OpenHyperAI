-- D2PT 7.41f; role counts sum to 1462, header 1469. All three migrated roles meet thresholds.
return {
    patch='7.41f', updated='2026-09-30', defaultRole='pos_4',
    source='https://dota2protracker.com/hero/Gyrocopter?section=builds',
    overviewWindow='last 8 days, 7000+', buildWindow='2026-09-15 to 2026-09-29', buildUpdated='2026-09-29',
    roles={
        pos_1={matches=477,winRate=42.6,rating=28,weight=44,buildMatches=784,buildWinRate=43,skillMatches=35,openingMatches=153,openingObserved=783},
        pos_2={matches=37,winRate=43.2,skipped=true},
        pos_3={matches=50,winRate=48,rating=32,skipped=true},
        pos_4={matches=572,winRate=48.4,rating=29,weight=46,buildMatches=990,buildWinRate=46,skillMatches=349,openingMatches=81,openingObserved=990},
        pos_5={matches=326,winRate=47.9,rating=32,weight=43,buildMatches=547,buildWinRate=46,skillMatches=168,openingMatches=28,openingObserved=547},
    },
    -- All roles spend level 10 on the inherited special_bonus_attributes ability.
    -- Current-tier observations only; sparse T5 uses reviewed role suitability.
    neutrals={
        pos_1={tier5Profile='attack',
            neutral={
                [1]={item_possessed_mask=27.4,item_weighted_dice=15.4,item_duelist_gloves=13.9,item_polliwog_charm=6.9,item_chipped_vest=6.8,item_dormant_curio=6.6,item_occult_bracelet=6.5},
                [2]={item_defiant_shell=17.7,item_mana_draught=11.8,item_poor_mans_shield=10.4,item_pogo_stick=8.5,item_essence_ring=7.8},
                [3]={item_serrated_shiv=38.5,item_gunpowder_gauntlets=29.1,item_unrelenting_eye=5.7,item_cloak_of_flames=5.2,item_stormcrafter=3.9},
                [4]={item_giant_maul=28,item_flayers_bota=24.1,item_prophets_pendulum=13.5,item_enchanters_bauble=5.5,item_idol_of_screeauk=4.8},
                [5]={item_divine_regalia=55.6,item_minotaur_horn=22.2,item_desolator_2=11.1,item_fallen_sky=11.1},
            },
            enhancement={
                [1]={item_enhancement_alert=67.3,item_enhancement_quickened=12.6,item_enhancement_brawny=11.2},
                [2]={item_enhancement_alert=71,item_enhancement_nimble=17.4,item_enhancement_brawny=7.6},
                [3]={item_enhancement_alert=75.1,item_enhancement_nimble=18,item_enhancement_brawny=3.9},
                [4]={item_enhancement_alert=89.1,item_enhancement_quickened=4.5,item_enhancement_nimble=4.5},
                [5]={item_enhancement_audacious=44.4,item_enhancement_evolved=33.3,item_enhancement_fleetfooted=22.2},
            },
        },
        pos_4={tier5Profile='support',
            neutral={
                [1]={item_ash_legion_shield=18.1,item_kobold_cup=15.7,item_dormant_curio=13.8,item_stonefeather_satchel=11.8,item_polliwog_charm=11.4,item_foragers_kit=8.8,item_chipped_vest=5.8},
                [2]={item_searing_signet=30.7,item_mana_draught=15.9,item_pogo_stick=14.6,item_essence_ring=11.3,item_crippling_crossbow=9.7,item_poor_mans_shield=3.6},
                [3]={item_partisans_brand=20.3,item_cloak_of_flames=11.8,item_stormcrafter=10.7,item_psychic_headband=9.8,item_jidi_pollen_bag=6.8,item_spellslinger=5.7},
                [4]={item_conjurers_catalyst=38.3,item_enchanters_bauble=13.5,item_prophets_pendulum=10.1,item_dandelion_amulet=9.5,item_rattlecage=5.5,item_metamorphic_mandible=3.7},
                [5]={item_demonicon=25,item_harmonizer=25,item_fallen_sky=12.5,item_dezun_bloodrite=12.5,item_divine_regalia=12.5},
            },
            enhancement={
                [1]={item_enhancement_quickened=56.7,item_enhancement_brawny=36.7,item_enhancement_vital=3.8},
                [2]={item_enhancement_greedy=67.7,item_enhancement_quickened=17.1,item_enhancement_brawny=8.5},
                [3]={item_enhancement_greedy=67.4,item_enhancement_quickened=14.8,item_enhancement_brawny=11.4},
                [4]={item_enhancement_timeless=73.9,item_enhancement_quickened=16.6,item_enhancement_brawny=4.9},
                [5]={item_enhancement_timeless=75,item_enhancement_vampiric=12.5,item_enhancement_evolved=12.5},
            },
        },
        pos_5={tier5Profile='support',
            neutral={
                [1]={item_ash_legion_shield=16.4,item_stonefeather_satchel=15.3,item_kobold_cup=15.1,item_polliwog_charm=13.4,item_dormant_curio=13.1,item_chipped_vest=7.2,item_foragers_kit=6.4},
                [2]={item_searing_signet=24,item_mana_draught=18.5,item_pogo_stick=16.2,item_essence_ring=14.7,item_crippling_crossbow=8,item_poor_mans_shield=4.8,item_medallion_of_courage=3.8},
                [3]={item_partisans_brand=20.2,item_cloak_of_flames=11.6,item_psychic_headband=11.4,item_stormcrafter=10.3,item_jidi_pollen_bag=6.5,item_spellslinger=5.7},
                [4]={item_conjurers_catalyst=41,item_prophets_pendulum=12.1,item_dandelion_amulet=11.6,item_enchanters_bauble=9.2,item_rattlecage=5.2,item_idol_of_screeauk=4},
                [5]={item_fallen_sky=20,item_minotaur_horn=20,item_dezun_bloodrite=20,item_harmonizer=20},
            },
            enhancement={
                [1]={item_enhancement_quickened=49.8,item_enhancement_brawny=42.3,item_enhancement_vital=5.5},
                [2]={item_enhancement_greedy=70.1,item_enhancement_brawny=16.6,item_enhancement_quickened=9},
                [3]={item_enhancement_greedy=66.1,item_enhancement_brawny=18.3,item_enhancement_quickened=10.6},
                [4]={item_enhancement_timeless=64.7,item_enhancement_quickened=17.3,item_enhancement_brawny=12.7},
                [5]={item_enhancement_timeless=100},
            },
        },
    },
}
