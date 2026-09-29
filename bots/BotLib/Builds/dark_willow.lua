-- D2PT 7.41f: https://dota2protracker.com/hero/Dark%20Willow?section=builds (&role=support / &role=hard-support)
-- Retrieved 2026-09-29. Overview: last 8 days; builds: Sep 15-29, updated Sep 29.
-- Role counts sum to 5617; overview reports 5627. Weights: sample-scaled D2PT role rating, see aba_hero_pos_weights.ts.
return {
    patch='7.41f', updated='2026-09-29', defaultRole='pos_4',
    roles={
        pos_1={matches=0,winRate=0,skipped=true},
        pos_2={matches=57,winRate=45.6,skipped=true},
        pos_3={matches=17,winRate=52.9,skipped=true},
        pos_4={matches=3690,winRate=50.2,rating=45,weight=75,buildMatches=6446},
        pos_5={matches=1853,winRate=51.9,rating=52,weight=80,buildMatches=2832},
    },
    -- Current-tier choices only: retained Dormant Curio, Searing Signet, Essence Ring, Partisan's Brand
    -- and Enchanter's Bauble are excluded from later tiers.
    -- T5 uses pick frequency plus support suitability, not tiny-sample win rates.
    neutrals={
        pos_4={tier5Profile='support',
            neutral={
                [1]={item_dormant_curio=16.5,item_kobold_cup=16.0,item_ash_legion_shield=15.8,item_polliwog_charm=13.4,item_stonefeather_satchel=10.1,item_foragers_kit=8.4,item_duelist_gloves=6.6},
                [2]={item_searing_signet=27.6,item_pogo_stick=19.0,item_mana_draught=16.8,item_essence_ring=16.5,item_crippling_crossbow=7.3,item_medallion_of_courage=2.4},
                [3]={item_partisans_brand=14.3,item_psychic_headband=13.8,item_cloak_of_flames=8.0,item_stormcrafter=7.3,item_gunpowder_gauntlets=7.0,item_spellslinger=6.5},
                [4]={item_conjurers_catalyst=37.5,item_enchanters_bauble=15.1,item_dandelion_amulet=13.2,item_prophets_pendulum=12.0,item_idol_of_screeauk=2.7,item_giant_maul=2.6},
                [5]={item_fallen_sky=23.5,item_dezun_bloodrite=22.2,item_demonicon=18.5,item_desolator_2=4.9,item_spider_legs=4.9,item_minotaur_horn=3.7},
            },
            enhancement={
                [1]={item_enhancement_mystical=54.4,item_enhancement_quickened=41.4,item_enhancement_vital=3.5},
                [2]={item_enhancement_greedy=72.2,item_enhancement_mystical=10.8,item_enhancement_keen_eyed=8.6},
                [3]={item_enhancement_greedy=71.6,item_enhancement_keen_eyed=11.9,item_enhancement_mystical=9.8},
                [4]={item_enhancement_timeless=50.3,item_enhancement_keen_eyed=24.9,item_enhancement_quickened=13.0},
                [5]={item_enhancement_timeless=50.6,item_enhancement_feverish=32.1,item_enhancement_fleetfooted=9.9},
            },
        },
        pos_5={tier5Profile='support',
            neutral={
                [1]={item_dormant_curio=18.5,item_kobold_cup=15.4,item_ash_legion_shield=14.0,item_polliwog_charm=13.5,item_stonefeather_satchel=9.8,item_foragers_kit=8.9,item_duelist_gloves=6.9},
                [2]={item_searing_signet=27.3,item_pogo_stick=17.9,item_mana_draught=16.6,item_essence_ring=16.4,item_crippling_crossbow=5.8,item_medallion_of_courage=2.7},
                [3]={item_psychic_headband=12.8,item_partisans_brand=12.2,item_cloak_of_flames=7.3,item_stormcrafter=6.9,item_spellslinger=6.6},
                [4]={item_conjurers_catalyst=35.4,item_dandelion_amulet=16.6,item_enchanters_bauble=11.8,item_prophets_pendulum=9.9,item_idol_of_screeauk=3.9,item_giant_maul=3.4},
                [5]={item_demonicon=15.2,item_desolator_2=12.1,item_spider_legs=12.1,item_fallen_sky=12.1,item_dezun_bloodrite=9.1,item_harmonizer=9.1},
            },
            enhancement={
                [1]={item_enhancement_mystical=55.3,item_enhancement_quickened=39.1,item_enhancement_vital=4.9},
                [2]={item_enhancement_greedy=65.7,item_enhancement_mystical=14.4,item_enhancement_keen_eyed=9.9},
                [3]={item_enhancement_greedy=66.3,item_enhancement_mystical=12.7,item_enhancement_keen_eyed=12.3},
                [4]={item_enhancement_timeless=44.1,item_enhancement_keen_eyed=27.2,item_enhancement_quickened=15.0},
                [5]={item_enhancement_timeless=57.6,item_enhancement_feverish=36.4,item_enhancement_vampiric=6.1},
            },
        },
    },
}
