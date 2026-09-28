-- D2PT 7.41f: https://dota2protracker.com/hero/Axe?section=builds
-- Retrieved 2026-09-28. Overview: last 8 days; build: Sep 15-28, updated Sep 28.
-- Role counts sum to 6505; the overview header reports 6518.
return {
    patch='7.41f', updated='2026-09-28', defaultRole='pos_3',
    roles={
        pos_1={matches=13,winRate=30.8,skipped=true},
        pos_2={matches=69,winRate=37.7,skipped=true},
        -- Reviewed baseline 30 + D2PT offlane rating 70.
        pos_3={matches=6195,winRate=48.4,rating=70,weight=100,buildMatches=9993},
        pos_4={matches=112,winRate=38.4,skipped=true},
        pos_5={matches=116,winRate=37.1,skipped=true},
    },
    neutrals={pos_3={tier5Profile='tank',
        neutral={
            [1]={item_chipped_vest=30.6,item_polliwog_charm=15.0,item_ash_legion_shield=12.6,item_possessed_mask=7.7,item_occult_bracelet=7.5,item_dormant_curio=7.3,item_stonefeather_satchel=5.4},
            -- Only current-tier rewards; retained Chipped Vest is excluded.
            [2]={item_poor_mans_shield=19.3,item_mana_draught=13.9,item_essence_ring=11.3,item_pogo_stick=11.3,item_defiant_shell=7.8,item_seeds_of_serenity=5.1},
            [3]={item_cloak_of_flames=39.2,item_gunpowder_gauntlets=8.5,item_partisans_brand=8.1,item_stormcrafter=8.0,item_jidi_pollen_bag=7.7,item_unrelenting_eye=7.2},
            [4]={item_conjurers_catalyst=24.7,item_rattlecage=19.9,item_prophets_pendulum=14.9,item_dandelion_amulet=9.8,item_enchanters_bauble=6.3,item_idol_of_screeauk=3.1},
            -- Sparse pick frequencies rank suitable offers; do not rank by tiny-sample win rate.
            [5]={item_fallen_sky=19.8,item_minotaur_horn=19.8,item_dezun_bloodrite=16.5,item_demonicon=9.1,item_spider_legs=7.4,item_heavy_blade=7.4,item_riftshadow_prism=6.6},
        },
        enhancement={
            [1]={item_enhancement_vital=46.8,item_enhancement_brawny=39.9,item_enhancement_quickened=12.9},
            [2]={item_enhancement_brawny=59.6,item_enhancement_greedy=18.3,item_enhancement_quickened=12.5},
            [3]={item_enhancement_brawny=56.2,item_enhancement_greedy=19.6,item_enhancement_tough=13.9},
            [4]={item_enhancement_brawny=53.6,item_enhancement_timeless=23.5,item_enhancement_tough=12.7},
            [5]={item_enhancement_timeless=35.5,item_enhancement_evolved=34.7,item_enhancement_hulking=13.2},
        },
    }},
}
