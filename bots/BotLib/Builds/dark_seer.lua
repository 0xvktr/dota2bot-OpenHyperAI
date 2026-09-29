-- D2PT 7.41f: https://dota2protracker.com/hero/Dark%20Seer?section=builds&role=offlane
-- Retrieved 2026-09-29. Overview: last 8 days; build: Sep 15-29, updated Sep 29.
-- Role counts sum to 7305; overview reports 7319. Weight: sample-scaled D2PT role rating, see aba_hero_pos_weights.ts.
-- Mid (75 matches, 1%, 54.7%) is not migrated: its build repeats the offlane items and only
-- about 7 matches carry item data. The build buys no boots (Arcane Boots: 3.8%).
return {
    patch='7.41f', updated='2026-09-29', defaultRole='pos_3',
    roles={
        pos_1={matches=14,winRate=35.7,skipped=true},
        pos_2={matches=75,winRate=54.7,skipped=true},
        pos_3={matches=7186,winRate=51.5,rating=69,weight=99,buildMatches=12560},
        pos_4={matches=15,winRate=20,skipped=true},
        pos_5={matches=15,winRate=40,skipped=true},
    },
    neutrals={pos_3={tier5Profile='caster',
        neutral={
            [1]={item_chipped_vest=22.7,item_occult_bracelet=15.8,item_polliwog_charm=12.6,item_ash_legion_shield=12.5,item_dormant_curio=10.0,item_weighted_dice=6.7,item_possessed_mask=4.9},
            -- Only current-tier rewards; retained Dormant Curio, Searing Signet, Cloak of Flames,
            -- Conjurer's Catalyst and Enchanter's Bauble are excluded from later tiers.
            [2]={item_mana_draught=22.4,item_searing_signet=16.9,item_essence_ring=15.3,item_pogo_stick=11.7,item_poor_mans_shield=11.2,item_crippling_crossbow=7.9},
            [3]={item_cloak_of_flames=36.5,item_gunpowder_gauntlets=11.4,item_partisans_brand=11.2,item_stormcrafter=9.7,item_jidi_pollen_bag=6.9,item_spellslinger=5.0},
            [4]={item_conjurers_catalyst=40.0,item_prophets_pendulum=14.8,item_rattlecage=9.0,item_enchanters_bauble=8.1,item_dandelion_amulet=6.9,item_giant_maul=5.1},
            -- Sparse pick frequencies rank suitable offers; never tiny-sample win rates.
            [5]={item_dezun_bloodrite=25.2,item_fallen_sky=18.0,item_demonicon=13.7,item_spider_legs=5.0,item_heavy_blade=3.6},
        },
        enhancement={
            [1]={item_enhancement_mystical=65.1,item_enhancement_quickened=18.6,item_enhancement_vital=15.8},
            [2]={item_enhancement_greedy=52.7,item_enhancement_mystical=32.3,item_enhancement_tough=9.8},
            [3]={item_enhancement_greedy=50.9,item_enhancement_mystical=29.1,item_enhancement_tough=14.9},
            [4]={item_enhancement_timeless=37.7,item_enhancement_mystical=20.4,item_enhancement_tough=19.2},
            [5]={item_enhancement_timeless=43.2,item_enhancement_feverish=33.1,item_enhancement_vampiric=13.7},
        },
    }},
}
