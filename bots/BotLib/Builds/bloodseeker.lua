-- D2PT 7.41f: https://dota2protracker.com/hero/Bloodseeker?section=builds
-- Retrieved 2026-09-29. Overview: last 8 days; builds: Sep 15-28, updated Sep 28.
-- Role counts sum to 603; overview reports 605. Weights: sample-scaled D2PT role rating, see aba_hero_pos_weights.ts.
-- Pos 1 only, as requested; offlane (63 matches, 10%) is eligible by the rule but not migrated.
-- Neutrals exclude retained lower-tier items and items neither bot pool can award; T5 samples are tiny,
-- so the reviewed suitability profile breaks ties and fills gaps.
return {
    patch='7.41f', updated='2026-09-29', defaultRole='pos_1',
    roles={
        pos_1={matches=478,winRate=48.1,rating=33,weight=46,buildMatches=645},
        pos_2={matches=45,winRate=57.8,skipped=true},
        pos_3={matches=63,winRate=49.2,skipped=true},
        pos_4={matches=9,winRate=22.2,skipped=true},
        pos_5={matches=8,winRate=75,skipped=true},
    },
    neutrals={
        pos_1={tier5Profile='attack',
            neutral={
                [1]={item_chipped_vest=22.1,item_possessed_mask=20.2,item_duelist_gloves=14.9,item_weighted_dice=11.8,item_occult_bracelet=6.8,item_dormant_curio=6.4,item_dagger_of_ristul=5},
                [2]={item_defiant_shell=20.6,item_poor_mans_shield=15.5,item_mana_draught=11.4,item_searing_signet=9.5,item_crippling_crossbow=7.2,item_medallion_of_courage=5.3,item_essence_ring=5.3},
                [3]={item_serrated_shiv=33.5,item_cloak_of_flames=21.6,item_gunpowder_gauntlets=19.7,item_unrelenting_eye=6.2,item_stormcrafter=4.1,item_partisans_brand=3},
                [4]={item_giant_maul=22.8,item_flayers_bota=16.2,item_prophets_pendulum=13.8,item_conjurers_catalyst=13.8,item_enchanters_bauble=5.2,item_dandelion_amulet=5.2},
                [5]={item_desolator_2=36.4,item_minotaur_horn=27.3,item_heavy_blade=18.2,item_fallen_sky=9.1,item_riftshadow_prism=9.1},
            },
            enhancement={
                [1]={item_enhancement_alert=65.5,item_enhancement_quickened=17.1,item_enhancement_brawny=12.8},
                [2]={item_enhancement_alert=70.9,item_enhancement_nimble=14.2,item_enhancement_brawny=7.5},
                [3]={item_enhancement_alert=75.2,item_enhancement_nimble=15.2,item_enhancement_quickened=4.9},
                [4]={item_enhancement_alert=84.5,item_enhancement_quickened=7.9,item_enhancement_nimble=4.8},
                [5]={item_enhancement_fleetfooted=27.3,item_enhancement_vampiric=27.3,item_enhancement_audacious=18.2},
            },
        },
    },
}
