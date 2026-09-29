-- D2PT 7.41f: https://dota2protracker.com/hero/Beastmaster?section=builds
-- Retrieved 2026-09-29. Overview: last 8 days; builds: Sep 15-28, updated Sep 28.
-- Role counts sum to 1541; overview reports 1,548. Weights: sample-scaled D2PT role rating, see aba_hero_pos_weights.ts.
-- Pos 1 (21 matches) is below the 50-match eligibility rule and is skipped.
return {
    patch='7.41f', updated='2026-09-29', defaultRole='pos_3',
    roles={
        pos_1={matches=21,winRate=52.4,skipped=true},
        pos_2={matches=327,winRate=47.7,rating=33,weight=43,buildMatches=510},
        pos_3={matches=1181,winRate=51.3,rating=46,weight=65,buildMatches=1967},
        pos_4={matches=5,winRate=60,skipped=true},
        pos_5={matches=7,winRate=42.9,skipped=true},
    },
    -- Exclude retained lower-tier items (e.g. Searing Signet in T3, Serrated Shiv in T4, Catalyst in T5).
    -- T5 internal names: Book of the Dead = item_demonicon, Witchbane = item_heavy_blade.
    -- T5 samples are tiny (~22 offlane, 4 mid), so the reviewed suitability profile breaks
    -- ties and fills gaps.
    neutrals={
        pos_2={tier5Profile='attack',
            neutral={
                [1]={item_duelist_gloves=17,item_chipped_vest=11.5,item_possessed_mask=10.1,item_occult_bracelet=10.1,item_dormant_curio=8.9,item_kobold_cup=8.3,item_weighted_dice=7.7},
                [2]={item_searing_signet=29.1,item_mana_draught=14.5,item_medallion_of_courage=11.8,item_crippling_crossbow=11.2,item_pogo_stick=7.3,item_essence_ring=5.5,item_defiant_shell=5.1},
                [3]={item_serrated_shiv=26.5,item_cloak_of_flames=20.4,item_gunpowder_gauntlets=19.9,item_partisans_brand=7.7,item_jidi_pollen_bag=4.5,item_stormcrafter=3.4},
                [4]={item_conjurers_catalyst=32.9,item_flayers_bota=16.8,item_giant_maul=15.6,item_prophets_pendulum=11,item_enchanters_bauble=8.1},
                [5]={item_demonicon=25,item_desolator_2=25,item_fallen_sky=25,item_divine_regalia=25},
            },
            enhancement={
                [1]={item_enhancement_mystical=41.7,item_enhancement_quickened=29.8,item_enhancement_alert=24.7},
                [2]={item_enhancement_alert=61.5,item_enhancement_mystical=24.6,item_enhancement_quickened=8.4},
                [3]={item_enhancement_alert=74.5,item_enhancement_mystical=16.2,item_enhancement_greedy=4.8},
                [4]={item_enhancement_alert=68.8,item_enhancement_timeless=24.3,item_enhancement_mystical=2.9},
                [5]={item_enhancement_manic=50,item_enhancement_fleetfooted=25,item_enhancement_evolved=25},
            },
        },
        pos_3={tier5Profile='tank',
            neutral={
                [1]={item_ash_legion_shield=14.2,item_chipped_vest=12.9,item_occult_bracelet=10.6,item_dormant_curio=9.9,item_duelist_gloves=9.9,item_possessed_mask=8.7,item_polliwog_charm=8.3},
                [2]={item_searing_signet=21,item_mana_draught=16.7,item_medallion_of_courage=12,item_pogo_stick=11.6,item_crippling_crossbow=8.6,item_essence_ring=8,item_poor_mans_shield=7.3},
                [3]={item_cloak_of_flames=24,item_serrated_shiv=21,item_gunpowder_gauntlets=18.5,item_partisans_brand=7.3,item_stormcrafter=5.8,item_jidi_pollen_bag=4.4},
                [4]={item_conjurers_catalyst=29,item_giant_maul=17.6,item_prophets_pendulum=11.9,item_enchanters_bauble=6.8,item_flayers_bota=6.6,item_rattlecage=6.3,item_dandelion_amulet=5.8},
                [5]={item_demonicon=31.8,item_fallen_sky=18.2,item_minotaur_horn=18.2,item_desolator_2=9.1,item_heavy_blade=4.5,item_dezun_bloodrite=4.5},
            },
            enhancement={
                [1]={item_enhancement_mystical=58.4,item_enhancement_alert=18.4,item_enhancement_quickened=17.1},
                [2]={item_enhancement_alert=44.1,item_enhancement_mystical=33.8,item_enhancement_quickened=11.5},
                [3]={item_enhancement_alert=60.6,item_enhancement_mystical=20.9,item_enhancement_quickened=8.8},
                [4]={item_enhancement_alert=60,item_enhancement_timeless=19.6,item_enhancement_quickened=12.7},
                [5]={item_enhancement_timeless=40.9,item_enhancement_evolved=31.8,item_enhancement_fleetfooted=13.6},
            },
        },
    },
}
