-- D2PT 7.41f: https://dota2protracker.com/hero/Chaos%20Knight?section=builds (&role=carry / &role=offlane)
-- Retrieved 2026-09-29. Overview: last 8 days; builds: Sep 15-29, updated Sep 29.
-- Role counts sum to 1226; overview reports 1230. Weights: sample-scaled D2PT role rating, see aba_hero_pos_weights.ts.
-- Support (52 matches, 4.2% of the hero, 53.8%, rating 33) is below the 5% rule; review later.
return {
    patch='7.41f', updated='2026-09-29', defaultRole='pos_3',
    roles={
        pos_1={matches=536,winRate=48.7,rating=32,weight=47,buildMatches=959},
        pos_2={matches=45,winRate=37.8,skipped=true},
        pos_3={matches=575,winRate=52.9,rating=42,weight=53,buildMatches=1008},
        pos_4={matches=52,winRate=53.8,skipped=true},
        pos_5={matches=18,winRate=44.4,skipped=true},
    },
    -- Current-tier choices only: retained Duelist Gloves, Weighted Dice, Dormant Curio, Defiant Shell,
    -- Serrated Shiv, Gunpowder Gauntlets and Enchanter's Bauble are excluded from later tiers.
    -- T5 uses pick frequency plus attack suitability, not tiny-sample win rates.
    neutrals={
        pos_1={tier5Profile='attack',
            neutral={
                [1]={item_duelist_gloves=22.8,item_weighted_dice=17.3,item_possessed_mask=15.3,item_chipped_vest=12.3,item_dormant_curio=8.4,item_dagger_of_ristul=7.2,item_occult_bracelet=5.9},
                [2]={item_defiant_shell=25.7,item_medallion_of_courage=14.3,item_mana_draught=9.9,item_pogo_stick=8.8,item_poor_mans_shield=8.1},
                [3]={item_serrated_shiv=35.2,item_gunpowder_gauntlets=26.0,item_cloak_of_flames=14.9,item_unrelenting_eye=5.2,item_partisans_brand=2.1},
                [4]={item_giant_maul=33.1,item_enchanters_bauble=13.4,item_prophets_pendulum=10.6,item_flayers_bota=9.1,item_rattlecage=4.3},
                [5]={item_fallen_sky=25.0,item_riftshadow_prism=25.0,item_desolator_2=12.5,item_spider_legs=12.5,item_minotaur_horn=12.5,item_divine_regalia=12.5},
            },
            enhancement={
                [1]={item_enhancement_tough=64.7,item_enhancement_quickened=22.8,item_enhancement_brawny=10.2},
                [2]={item_enhancement_tough=61.5,item_enhancement_crude=17.6,item_enhancement_quickened=17.4},
                [3]={item_enhancement_tough=63.0,item_enhancement_crude=21.7,item_enhancement_quickened=11.8},
                [4]={item_enhancement_tough=57.1,item_enhancement_crude=22.0,item_enhancement_quickened=15.1},
                [5]={item_enhancement_evolved=75.0,item_enhancement_fleetfooted=25.0},
            },
        },
        pos_3={tier5Profile='attack',
            neutral={
                [1]={item_duelist_gloves=20.2,item_weighted_dice=15.9,item_chipped_vest=14.5,item_possessed_mask=14.0,item_dormant_curio=8.8,item_dagger_of_ristul=8.7,item_occult_bracelet=6.3},
                [2]={item_defiant_shell=24.6,item_medallion_of_courage=20.3,item_poor_mans_shield=9.9,item_mana_draught=7.3,item_crippling_crossbow=4.9},
                [3]={item_serrated_shiv=33.3,item_gunpowder_gauntlets=25.6,item_cloak_of_flames=16.4,item_stormcrafter=3.5,item_unrelenting_eye=3.4},
                [4]={item_giant_maul=37.5,item_prophets_pendulum=11.1,item_flayers_bota=8.7,item_enchanters_bauble=8.4,item_rattlecage=4.8},
                [5]={item_desolator_2=52.9,item_fallen_sky=17.6,item_minotaur_horn=5.9,item_heavy_blade=5.9,item_divine_regalia=5.9},
            },
            enhancement={
                [1]={item_enhancement_tough=74.5,item_enhancement_quickened=11.7,item_enhancement_brawny=10.6},
                [2]={item_enhancement_tough=72.5,item_enhancement_crude=12.3,item_enhancement_quickened=8.0},
                [3]={item_enhancement_tough=61.1,item_enhancement_crude=25.4,item_enhancement_brawny=7.4},
                [4]={item_enhancement_tough=55.6,item_enhancement_crude=26.7,item_enhancement_quickened=9.6},
                [5]={item_enhancement_evolved=76.5,item_enhancement_fleetfooted=17.6,item_enhancement_timeless=5.9},
            },
        },
    },
}
