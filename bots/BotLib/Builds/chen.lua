-- D2PT 7.41f: https://dota2protracker.com/hero/Chen?section=builds&role=hard_support
-- Retrieved 2026-09-29. Overview: last 8 days; build: Sep 15-29, updated Sep 29.
-- Role counts sum to 412, matching the overview. Weight: sample-scaled D2PT role rating, see aba_hero_pos_weights.ts.
-- Support (26 matches) is below the migration threshold.
return {
    patch='7.41f', updated='2026-09-29', defaultRole='pos_5',
    roles={
        pos_1={matches=5,winRate=40,skipped=true},
        pos_2={matches=2,winRate=0,skipped=true},
        pos_3={matches=0,winRate=0,skipped=true},
        pos_4={matches=26,winRate=57.7,skipped=true},
        pos_5={matches=379,winRate=51.5,rating=43,weight=49,buildMatches=664},
    },
    neutrals={pos_5={tier5Profile='support',
        neutral={
            [1]={item_ash_legion_shield=20.8,item_kobold_cup=17.2,item_polliwog_charm=13.1,item_dormant_curio=10.6,item_stonefeather_satchel=9.5,item_foragers_kit=9.1,item_duelist_gloves=5.9},
            -- Only current-tier rewards; retained Ash Legion Shield, Medallion, Mana Draught,
            -- Essence Ring and Psychic Headband are excluded from later tiers.
            [2]={item_medallion_of_courage=18.8,item_essence_ring=16.2,item_mana_draught=15.2,item_crippling_crossbow=9.9,item_pogo_stick=8.9,item_seeds_of_serenity=8.8},
            [3]={item_psychic_headband=13.0,item_jidi_pollen_bag=9.3,item_stormcrafter=6.9,item_cloak_of_flames=5.4},
            [4]={item_prophets_pendulum=30.2,item_enchanters_bauble=10.9,item_dandelion_amulet=10.9,item_giant_maul=5.4,item_conjurers_catalyst=5.4},
            -- Three observations only; the support profile breaks the tie.
            [5]={item_demonicon=33.3,item_fallen_sky=33.3,item_minotaur_horn=33.3},
        },
        enhancement={
            [1]={item_enhancement_mystical=67.2,item_enhancement_quickened=27.9,item_enhancement_tough=2.9},
            [2]={item_enhancement_greedy=68.6,item_enhancement_keen_eyed=11.1,item_enhancement_mystical=9.9},
            [3]={item_enhancement_greedy=68.3,item_enhancement_keen_eyed=11.7,item_enhancement_quickened=6.9},
            [4]={item_enhancement_quickened=39.5,item_enhancement_tough=23.3,item_enhancement_keen_eyed=20.2},
            [5]={item_enhancement_feverish=33.3,item_enhancement_fleetfooted=33.3,item_enhancement_timeless=33.3},
        },
    }},
}
