-- D2PT 7.41f: https://dota2protracker.com/hero/Centaur%20Warrunner?section=builds
-- Retrieved 2026-09-29. Overview: last 8 days; build: Sep 15-29, updated Sep 29.
-- Role counts sum to 2527; the overview header reports 2530. Weight: sample-scaled D2PT role rating, see aba_hero_pos_weights.ts.
-- The build buys no boots: Horsepower turns Strength into movement speed.
return {
    patch='7.41f', updated='2026-09-29', defaultRole='pos_3',
    roles={
        pos_1={matches=3,winRate=0,skipped=true},
        pos_2={matches=41,winRate=46.3,skipped=true},
        pos_3={matches=2446,winRate=48.7,rating=39,weight=69,buildMatches=4413},
        pos_4={matches=25,winRate=40,skipped=true},
        pos_5={matches=12,winRate=16.7,skipped=true},
    },
    neutrals={pos_3={tier5Profile='tank',
        neutral={
            [1]={item_chipped_vest=30.8,item_polliwog_charm=15.5,item_ash_legion_shield=12.0,item_dormant_curio=8.2,item_possessed_mask=7.0,item_stonefeather_satchel=6.1,item_occult_bracelet=5.7},
            -- Only current-tier rewards; retained Chipped Vest (T2/T3) and Cloak of Flames (T4) are excluded.
            [2]={item_poor_mans_shield=21.8,item_pogo_stick=12.2,item_essence_ring=10.5,item_searing_signet=9.0,item_seeds_of_serenity=7.9,item_mana_draught=5.4},
            [3]={item_cloak_of_flames=39.0,item_stormcrafter=10.5,item_unrelenting_eye=8.8,item_jidi_pollen_bag=8.0,item_gunpowder_gauntlets=8.0,item_partisans_brand=7.7},
            [4]={item_rattlecage=22.4,item_conjurers_catalyst=21.8,item_prophets_pendulum=18.4,item_dandelion_amulet=9.4,item_idol_of_screeauk=5.2,item_enchanters_bauble=5.2},
            -- Sparse pick frequencies (about 37 observations) rank suitable offers; never tiny-sample win rates.
            [5]={item_fallen_sky=21.6,item_minotaur_horn=13.5,item_demonicon=10.8,item_dezun_bloodrite=10.8,item_spider_legs=8.1,item_heavy_blade=8.1,item_desolator_2=5.4},
        },
        enhancement={
            [1]={item_enhancement_vital=44.7,item_enhancement_brawny=34.7,item_enhancement_quickened=20.2},
            [2]={item_enhancement_brawny=47.9,item_enhancement_greedy=26.9,item_enhancement_tough=15.5},
            [3]={item_enhancement_brawny=42.5,item_enhancement_greedy=26.1,item_enhancement_tough=22.1},
            [4]={item_enhancement_brawny=46.3,item_enhancement_tough=21.7,item_enhancement_quickened=16.1},
            [5]={item_enhancement_evolved=51.4,item_enhancement_hulking=32.4,item_enhancement_timeless=10.8},
        },
    }},
}
