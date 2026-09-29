-- D2PT 7.41f: https://dota2protracker.com/hero/Clinkz?section=builds (&role=carry / &role=mid)
-- Retrieved 2026-09-29. Overview: last 8 days; builds: Sep 15-29, updated Sep 29.
-- Role counts sum to 1960; overview reports 1961. Weights: sample-scaled D2PT role rating, see aba_hero_pos_weights.ts.
-- Mid's skill order comes from 102 matches; its item and neutral data from the 514-match build.
return {
    patch='7.41f', updated='2026-09-29', defaultRole='pos_1',
    roles={
        pos_1={matches=1600,winRate=53.4,rating=52,weight=77,buildMatches=2558},
        pos_2={matches=311,winRate=53.7,rating=40,weight=46,buildMatches=514},
        pos_3={matches=18,winRate=38.9,skipped=true},
        pos_4={matches=22,winRate=31.8,skipped=true},
        pos_5={matches=9,winRate=33.3,skipped=true},
    },
    -- Current-tier choices only: retained Duelist Gloves, Weighted Dice, Dormant Curio, Mana Draught,
    -- Medallion, Crossbow, Serrated Shiv, Gunpowder Gauntlets and Enchanter's Bauble are excluded
    -- from later tiers. T5 uses pick frequency plus attack suitability, not tiny-sample win rates.
    neutrals={
        pos_1={tier5Profile='attack',
            neutral={
                [1]={item_duelist_gloves=22.0,item_weighted_dice=16.7,item_possessed_mask=14.4,item_dagger_of_ristul=11.7,item_dormant_curio=11.2,item_occult_bracelet=8.4,item_stonefeather_satchel=4.7},
                [2]={item_mana_draught=34.0,item_medallion_of_courage=20.3,item_crippling_crossbow=7.5,item_defiant_shell=4.4},
                [3]={item_serrated_shiv=37.2,item_gunpowder_gauntlets=25.2,item_spellslinger=5.5,item_unrelenting_eye=3.7},
                [4]={item_giant_maul=32.3,item_flayers_bota=16.9,item_enchanters_bauble=10.3,item_prophets_pendulum=7.8},
                [5]={item_desolator_2=50.0,item_divine_regalia=16.7,item_minotaur_horn=7.1,item_spider_legs=4.8,item_heavy_blade=4.8},
            },
            enhancement={
                [1]={item_enhancement_alert=77.4,item_enhancement_quickened=13.4,item_enhancement_brawny=8.0},
                [2]={item_enhancement_alert=69.4,item_enhancement_nimble=22.3,item_enhancement_quickened=6.4},
                [3]={item_enhancement_alert=74.8,item_enhancement_nimble=19.2,item_enhancement_quickened=4.2},
                [4]={item_enhancement_alert=92.8,item_enhancement_nimble=4.4,item_enhancement_quickened=2.1},
                [5]={item_enhancement_audacious=45.2,item_enhancement_fleetfooted=28.6,item_enhancement_evolved=21.4},
            },
        },
        pos_2={tier5Profile='attack',
            neutral={
                [1]={item_duelist_gloves=24.6,item_weighted_dice=14.8,item_dagger_of_ristul=12.9,item_possessed_mask=11.9,item_dormant_curio=11.7,item_occult_bracelet=6.6,item_stonefeather_satchel=5.5},
                [2]={item_mana_draught=25.0,item_medallion_of_courage=20.4,item_crippling_crossbow=12.7,item_defiant_shell=6.0,item_essence_ring=4.6},
                [3]={item_serrated_shiv=35.9,item_gunpowder_gauntlets=18.4,item_spellslinger=5.1,item_unrelenting_eye=3.8},
                [4]={item_giant_maul=35.2,item_enchanters_bauble=12.6,item_flayers_bota=11.5,item_prophets_pendulum=4.4,item_conjurers_catalyst=4.4},
                [5]={item_desolator_2=44.4,item_minotaur_horn=22.2,item_demonicon=11.1,item_heavy_blade=11.1,item_divine_regalia=11.1},
            },
            enhancement={
                [1]={item_enhancement_alert=74.1,item_enhancement_brawny=15.2,item_enhancement_quickened=10.3},
                [2]={item_enhancement_alert=56.3,item_enhancement_nimble=31.7,item_enhancement_quickened=10.1},
                [3]={item_enhancement_alert=58.8,item_enhancement_nimble=32.8,item_enhancement_quickened=6.6},
                [4]={item_enhancement_alert=94.5,item_enhancement_nimble=2.7,item_enhancement_quickened=2.2},
                [5]={item_enhancement_audacious=55.6,item_enhancement_fleetfooted=22.2,item_enhancement_evolved=22.2},
            },
        },
    },
}
