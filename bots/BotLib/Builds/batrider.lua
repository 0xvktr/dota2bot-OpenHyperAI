-- D2PT 7.41f: https://dota2protracker.com/hero/Batrider?section=builds
-- Retrieved 2026-09-28. Overview: last 8 days; builds: Sep 15-28, updated Sep 28.
-- Role counts sum to 728; overview reports 729. Weights: 30 + D2PT role rating.
return {
    patch='7.41f', updated='2026-09-28', defaultRole='pos_2',
    roles={
        pos_1={matches=1,winRate=0,skipped=true},
        pos_2={matches=261,winRate=47.9,rating=33,weight=63,buildMatches=458},
        pos_3={matches=258,winRate=48.4,rating=33,weight=63,buildMatches=476},
        pos_4={matches=130,winRate=43.8,skipped=true},
        pos_5={matches=79,winRate=39.2,skipped=true},
    },
    -- Exclude retained lower-tier items, including Bauble/Catalyst in offlane T5.
    -- T5 samples are tiny. Utility suitability keeps mobility/casting options (including
    -- mid's observed Manic), with deterministic reviewed fallback when not offered.
    neutrals={
        pos_2={tier5Profile='support',
            neutral={
                [1]={item_kobold_cup=15.1,item_dormant_curio=14.4,item_stonefeather_satchel=13.8,item_duelist_gloves=10.7,item_ash_legion_shield=10.3,item_chipped_vest=8.5,item_polliwog_charm=8.5},
                [2]={item_searing_signet=29.7,item_pogo_stick=24.8,item_essence_ring=10.5,item_mana_draught=10.3,item_crippling_crossbow=10,item_poor_mans_shield=3.3},
                [3]={item_cloak_of_flames=24.6,item_partisans_brand=16.9,item_gunpowder_gauntlets=11.7,item_unrelenting_eye=7.4,item_serrated_shiv=7.4,item_stormcrafter=7.1},
                [4]={item_conjurers_catalyst=41.9,item_enchanters_bauble=14.2,item_prophets_pendulum=8.8,item_rattlecage=5.4,item_giant_maul=4.1},
                [5]={item_minotaur_horn=100},
            },
            enhancement={
                [1]={item_enhancement_quickened=72.9,item_enhancement_alert=15.7,item_enhancement_mystical=8.3},
                [2]={item_enhancement_quickened=43.8,item_enhancement_greedy=21.4,item_enhancement_alert=17.6},
                [3]={item_enhancement_quickened=38.9,item_enhancement_alert=26.6,item_enhancement_greedy=21.7},
                [4]={item_enhancement_alert=44.6,item_enhancement_timeless=30.4,item_enhancement_quickened=21.6},
                [5]={item_enhancement_manic=100},
            },
        },
        pos_3={tier5Profile='support',
            neutral={
                [1]={item_kobold_cup=16.7,item_dormant_curio=13.5,item_stonefeather_satchel=12.9,item_polliwog_charm=9.7,item_ash_legion_shield=9.5,item_occult_bracelet=9.1,item_chipped_vest=8.2},
                [2]={item_searing_signet=25.4,item_pogo_stick=19.1,item_mana_draught=19.1,item_essence_ring=11.1,item_crippling_crossbow=8,item_poor_mans_shield=3.5},
                [3]={item_cloak_of_flames=28.7,item_partisans_brand=16.4,item_stormcrafter=12.9,item_gunpowder_gauntlets=5.3,item_jidi_pollen_bag=5.3,item_unrelenting_eye=5},
                [4]={item_conjurers_catalyst=37.2,item_enchanters_bauble=14.6,item_prophets_pendulum=8,item_dandelion_amulet=7.3,item_giant_maul=5.8,item_idol_of_screeauk=5.8},
                [5]={item_demonicon=33.3},
            },
            enhancement={
                [1]={item_enhancement_quickened=61.1,item_enhancement_mystical=24.1,item_enhancement_alert=8},
                [2]={item_enhancement_quickened=41,item_enhancement_greedy=34.9,item_enhancement_mystical=16.1},
                [3]={item_enhancement_quickened=36.5,item_enhancement_greedy=32.7,item_enhancement_alert=17.5},
                [4]={item_enhancement_quickened=36.5,item_enhancement_alert=33.6,item_enhancement_timeless=27},
                [5]={item_enhancement_timeless=66.7,item_enhancement_evolved=33.3},
            },
        },
    },
}
