-- D2PT 7.41f: https://dota2protracker.com/hero/Dazzle?section=builds (&role=hard-support / &role=support)
-- Retrieved 2026-09-29. Overview: last 8 days; builds: Sep 15-29, updated Sep 29.
-- Role counts sum to 2724; overview reports 2732. Weights: sample-scaled D2PT role rating, see aba_hero_pos_weights.ts.
-- Pos 4 (174 matches, 6.4%) repeats the pos 5 core; its item rates come from about 64 matches.
return {
    patch='7.41f', updated='2026-09-29', defaultRole='pos_5',
    roles={
        pos_1={matches=3,winRate=33.3,skipped=true},
        pos_2={matches=15,winRate=46.7,skipped=true},
        pos_3={matches=11,winRate=45.5,skipped=true},
        pos_4={matches=174,winRate=48.3,rating=32,weight=39,buildMatches=203},
        pos_5={matches=2521,winRate=54.4,rating=77,weight=100,buildMatches=3982},
    },
    -- Current-tier choices only: retained Ash Legion Shield, Dormant Curio, Pogo Stick, Essence Ring,
    -- Mana Draught, Medallion, Crossbow, Psychic Headband and Enchanter's Bauble are excluded from later tiers.
    -- T5 uses pick frequency plus support suitability, not tiny-sample win rates.
    neutrals={
        pos_4={tier5Profile='support',
            neutral={
                [1]={item_dormant_curio=17.2,item_polliwog_charm=15.8,item_kobold_cup=15.8,item_ash_legion_shield=14.3,item_duelist_gloves=12.3,item_stonefeather_satchel=7.4,item_foragers_kit=7.4},
                [2]={item_mana_draught=19.3,item_essence_ring=18.3,item_pogo_stick=15.8,item_medallion_of_courage=10.4,item_crippling_crossbow=7.9,item_searing_signet=7.9},
                [3]={item_psychic_headband=22.9,item_spellslinger=8.6,item_stormcrafter=5.7},
                [4]={item_prophets_pendulum=24.2,item_enchanters_bauble=22.6,item_conjurers_catalyst=11.3,item_idol_of_screeauk=8.1,item_dandelion_amulet=4.8,item_metamorphic_mandible=3.2},
                [5]={item_spider_legs=16.7,item_fallen_sky=16.7,item_minotaur_horn=16.7,item_harmonizer=16.7},
            },
            enhancement={
                [1]={item_enhancement_quickened=56.7,item_enhancement_mystical=27.6,item_enhancement_alert=13.3},
                [2]={item_enhancement_greedy=83.2,item_enhancement_quickened=8.4,item_enhancement_mystical=4.5},
                [3]={item_enhancement_greedy=83.4,item_enhancement_quickened=8.6,item_enhancement_mystical=3.4},
                [4]={item_enhancement_quickened=58.1,item_enhancement_mystical=19.4,item_enhancement_timeless=19.4},
                [5]={item_enhancement_timeless=66.7,item_enhancement_fleetfooted=33.3},
            },
        },
        pos_5={tier5Profile='support',
            neutral={
                [1]={item_ash_legion_shield=17.8,item_kobold_cup=16.6,item_polliwog_charm=14.6,item_dormant_curio=14.2,item_stonefeather_satchel=10.7,item_foragers_kit=7.6,item_duelist_gloves=7.4},
                [2]={item_pogo_stick=20.4,item_essence_ring=19.1,item_mana_draught=14.8,item_medallion_of_courage=13.2,item_crippling_crossbow=7.5,item_searing_signet=6.7,item_seeds_of_serenity=4.3},
                [3]={item_psychic_headband=17.1,item_jidi_pollen_bag=7.6,item_spellslinger=7.3},
                [4]={item_prophets_pendulum=22.3,item_dandelion_amulet=20.3,item_conjurers_catalyst=16.3,item_enchanters_bauble=11.7,item_idol_of_screeauk=7.4,item_metamorphic_mandible=3.8},
                [5]={item_demonicon=23.8,item_fallen_sky=19.0,item_minotaur_horn=11.9,item_desolator_2=7.1,item_spider_legs=7.1,item_heavy_blade=7.1,item_riftshadow_prism=4.8},
            },
            enhancement={
                [1]={item_enhancement_quickened=63.0,item_enhancement_mystical=29.1,item_enhancement_alert=6.0},
                [2]={item_enhancement_greedy=84.5,item_enhancement_quickened=8.4,item_enhancement_mystical=4.3},
                [3]={item_enhancement_greedy=84.7,item_enhancement_quickened=8.4,item_enhancement_mystical=4.2},
                [4]={item_enhancement_quickened=61.3,item_enhancement_mystical=18.0,item_enhancement_timeless=15.3},
                [5]={item_enhancement_fleetfooted=54.8,item_enhancement_timeless=16.7,item_enhancement_manic=16.7},
            },
        },
    },
}
