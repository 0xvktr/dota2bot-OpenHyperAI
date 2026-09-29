-- D2PT 7.41f: https://dota2protracker.com/hero/Bounty%20Hunter?section=builds
-- Retrieved 2026-09-29. Overview: last 8 days; builds: Sep 15-28, updated Sep 28.
-- Role counts sum to 9348; overview reports 9,362. Weights: sample-scaled D2PT role rating, see aba_hero_pos_weights.ts.
-- Pos 4 rating is 100/100: 30 + 100 is capped at the maximum weight of 100.
-- Neutrals exclude retained lower-tier items and items neither bot pool can award; T5 samples are tiny,
-- so the reviewed suitability profile breaks ties and fills gaps.
return {
    patch='7.41f', updated='2026-09-29', defaultRole='pos_4',
    roles={
        pos_1={matches=7,winRate=42.9,skipped=true},
        pos_2={matches=43,winRate=37.2,skipped=true},
        pos_3={matches=51,winRate=39.2,skipped=true},
        pos_4={matches=8188,winRate=57.1,rating=100,weight=100,buildMatches=12725},
        pos_5={matches=1059,winRate=50.7,rating=51,weight=67,buildMatches=1706},
    },
    neutrals={
        pos_4={tier5Profile='support',
            neutral={
                [1]={item_ash_legion_shield=15.4,item_kobold_cup=15,item_dormant_curio=14.4,item_stonefeather_satchel=13.9,item_polliwog_charm=9,item_duelist_gloves=8.1,item_foragers_kit=7},
                [2]={item_searing_signet=16.2,item_essence_ring=16.1,item_mana_draught=15.8,item_pogo_stick=11.6,item_crippling_crossbow=10.8,item_medallion_of_courage=9.2,item_poor_mans_shield=5.5},
                [3]={item_psychic_headband=12.9,item_jidi_pollen_bag=11.1,item_cloak_of_flames=10.3,item_gunpowder_gauntlets=9.8,item_unrelenting_eye=8,item_stormcrafter=6.7},
                [4]={item_prophets_pendulum=21.2,item_dandelion_amulet=18.5,item_conjurers_catalyst=11.5,item_enchanters_bauble=9.4,item_giant_maul=8.8,item_rattlecage=8.3,item_idol_of_screeauk=6.5},
                [5]={item_fallen_sky=25,item_demonicon=20.7,item_desolator_2=16.3,item_spider_legs=10.9,item_heavy_blade=10.9,item_minotaur_horn=8.7,item_riftshadow_prism=3.3},
            },
            enhancement={
                [1]={item_enhancement_quickened=66.4,item_enhancement_brawny=25.6,item_enhancement_alert=6.6},
                [2]={item_enhancement_greedy=55.8,item_enhancement_quickened=24.6,item_enhancement_brawny=8.9},
                [3]={item_enhancement_greedy=57,item_enhancement_quickened=20.7,item_enhancement_brawny=9.6},
                [4]={item_enhancement_quickened=54,item_enhancement_brawny=17.7,item_enhancement_alert=14},
                [5]={item_enhancement_fleetfooted=46.7,item_enhancement_evolved=19.6,item_enhancement_timeless=18.5},
            },
        },
        pos_5={tier5Profile='support',
            neutral={
                [1]={item_ash_legion_shield=15,item_kobold_cup=14.8,item_dormant_curio=14.3,item_stonefeather_satchel=12.5,item_polliwog_charm=10.2,item_foragers_kit=8.2,item_duelist_gloves=7.6},
                [2]={item_essence_ring=16.4,item_mana_draught=15.1,item_searing_signet=14.7,item_pogo_stick=12.1,item_crippling_crossbow=11.1,item_medallion_of_courage=9,item_poor_mans_shield=5.7},
                [3]={item_psychic_headband=12.5,item_cloak_of_flames=10.6,item_jidi_pollen_bag=10.6,item_gunpowder_gauntlets=9.2,item_unrelenting_eye=7.9,item_stormcrafter=7.8},
                [4]={item_prophets_pendulum=21.9,item_dandelion_amulet=17.2,item_conjurers_catalyst=10,item_idol_of_screeauk=9.3,item_enchanters_bauble=8.9,item_rattlecage=8.4,item_giant_maul=6.8},
                [5]={item_fallen_sky=66.7,item_demonicon=22.2},
            },
            enhancement={
                [1]={item_enhancement_quickened=61.3,item_enhancement_brawny=31.9,item_enhancement_alert=4.9},
                [2]={item_enhancement_greedy=54.2,item_enhancement_quickened=23.3,item_enhancement_brawny=12.5},
                [3]={item_enhancement_greedy=55.9,item_enhancement_quickened=19.8,item_enhancement_brawny=12.8},
                [4]={item_enhancement_quickened=56.9,item_enhancement_brawny=19.6,item_enhancement_timeless=9.3},
                [5]={item_enhancement_fleetfooted=44.4,item_enhancement_timeless=44.4,item_enhancement_evolved=11.1},
            },
        },
    },
}
