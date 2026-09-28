-- D2PT 7.41f: https://dota2protracker.com/hero/Bane?section=builds
-- Retrieved 2026-09-28. Overview: last 8 days; builds: Sep 15-28, updated Sep 28.
-- Role counts sum to 3287; overview reports 3293. Weights: 30 + D2PT role rating.
return {
    patch='7.41f', updated='2026-09-28', defaultRole='pos_5',
    roles={
        pos_1={matches=1,winRate=0,skipped=true},
        pos_2={matches=30,winRate=46.7,skipped=true},
        pos_3={matches=4,winRate=50,skipped=true},
        pos_4={matches=600,winRate=48.8,rating=32,weight=62,buildMatches=1011},
        pos_5={matches=2652,winRate=49.5,rating=41,weight=71,buildMatches=4471},
    },
    -- Current-tier choices only: retained Tumbler/Essence/Mana/Signet/Bauble excluded.
    -- Consumers still filter offers to supported pools (e.g. Headband may be unavailable).
    -- T5 uses pick frequency plus support suitability, not tiny-sample win rates.
    neutrals={
        pos_4={tier5Profile='support',
            neutral={
                [1]={item_dormant_curio=19.4,item_ash_legion_shield=16.1,item_kobold_cup=15.5,item_stonefeather_satchel=14.9,item_polliwog_charm=9.7,item_foragers_kit=8.3,item_occult_bracelet=5},
                [2]={item_pogo_stick=27.9,item_essence_ring=17.3,item_mana_draught=17.1,item_searing_signet=11.1,item_crippling_crossbow=5,item_medallion_of_courage=4.8},
                [3]={item_psychic_headband=17.5,item_spellslinger=8.6,item_partisans_brand=6.8},
                [4]={item_conjurers_catalyst=29.1,item_prophets_pendulum=14.5,item_enchanters_bauble=13.7,item_dandelion_amulet=11,item_idol_of_screeauk=5.7,item_metamorphic_mandible=4.4},
                [5]={item_minotaur_horn=22.2,item_desolator_2=11.1,item_spider_legs=11.1,item_fallen_sky=11.1,item_heavy_blade=11.1},
            },
            enhancement={
                [1]={item_enhancement_quickened=74.7,item_enhancement_mystical=23.6,item_enhancement_vital=1.4},
                [2]={item_enhancement_greedy=81,item_enhancement_quickened=11.6,item_enhancement_mystical=5.9},
                [3]={item_enhancement_greedy=85,item_enhancement_quickened=9.4,item_enhancement_mystical=4.6},
                [4]={item_enhancement_timeless=65.6,item_enhancement_quickened=28.2,item_enhancement_mystical=5.3},
                [5]={item_enhancement_timeless=100},
            },
        },
        pos_5={tier5Profile='support',
            neutral={
                [1]={item_kobold_cup=17.9,item_ash_legion_shield=17,item_dormant_curio=16.9,item_stonefeather_satchel=12.8,item_polliwog_charm=11.2,item_foragers_kit=9.1,item_occult_bracelet=5.4},
                [2]={item_pogo_stick=30.8,item_essence_ring=17.7,item_mana_draught=17.4,item_searing_signet=11.2,item_crippling_crossbow=4.7,item_medallion_of_courage=4.1},
                [3]={item_psychic_headband=17.6,item_spellslinger=7.4,item_partisans_brand=6.5},
                [4]={item_conjurers_catalyst=22.2,item_enchanters_bauble=21,item_prophets_pendulum=18.3,item_dandelion_amulet=14,item_idol_of_screeauk=6.4,item_metamorphic_mandible=3.5},
                [5]={item_demonicon=35,item_spider_legs=17.5,item_fallen_sky=7.5,item_minotaur_horn=7.5,item_desolator_2=2.5,item_heavy_blade=2.5},
            },
            enhancement={
                [1]={item_enhancement_quickened=76.1,item_enhancement_mystical=21.5,item_enhancement_vital=1.2},
                [2]={item_enhancement_greedy=87.6,item_enhancement_quickened=8.8,item_enhancement_mystical=2.4},
                [3]={item_enhancement_greedy=89.6,item_enhancement_quickened=7.3,item_enhancement_mystical=2},
                [4]={item_enhancement_timeless=67.7,item_enhancement_quickened=27.4,item_enhancement_mystical=3.7},
                [5]={item_enhancement_timeless=90,item_enhancement_fleetfooted=7.5,item_enhancement_manic=2.5},
            },
        },
    },
}
