-- D2PT 7.41f: https://dota2protracker.com/hero/Dawnbreaker?section=builds (&role=offlane / &role=mid)
-- Retrieved 2026-09-29. Overview: last 8 days; builds: Sep 15-29, updated Sep 29.
-- Role counts sum to 7193; overview reports 7209. Weights: sample-scaled D2PT role rating, see aba_hero_pos_weights.ts.
-- Mid is a reviewed exception to the 5% rule (231 matches, 3.2%, 49.8%): it has a distinct
-- 360-match build (Bottle, Soul Ring, Phase, Desolator, Echo Sabre, Harpoon); about 61 matches
-- carry its item rates and 145 its skill order. Support (150, 2.1%) is not migrated.
return {
    patch='7.41f', updated='2026-09-29', defaultRole='pos_3',
    roles={
        pos_1={matches=44,winRate=54.5,skipped=true},
        pos_2={matches=231,winRate=49.8,rating=34,weight=42,buildMatches=360},
        pos_3={matches=6679,winRate=51.5,rating=68,weight=98,buildMatches=11444},
        pos_4={matches=150,winRate=44.7,skipped=true},
        pos_5={matches=89,winRate=40.4,skipped=true},
    },
    -- Current-tier choices only: retained Chipped Vest, Dormant Curio, Defiant Shell, Medallion,
    -- Cloak of Flames and Gunpowder Gauntlets are excluded from later tiers.
    -- T5 uses pick frequency plus attack suitability, not tiny-sample win rates.
    neutrals={
        pos_2={tier5Profile='attack',
            neutral={
                [1]={item_chipped_vest=25.0,item_possessed_mask=14.2,item_duelist_gloves=14.2,item_dormant_curio=11.1,item_weighted_dice=10.6,item_occult_bracelet=8.1,item_dagger_of_ristul=7.5},
                [2]={item_defiant_shell=21.6,item_mana_draught=13.7,item_medallion_of_courage=11.5,item_poor_mans_shield=10.6,item_searing_signet=8.7,item_crippling_crossbow=5.9},
                [3]={item_gunpowder_gauntlets=29.7,item_serrated_shiv=21.6,item_cloak_of_flames=19.3,item_unrelenting_eye=4.4,item_jidi_pollen_bag=2.7},
                [4]={item_giant_maul=38.6,item_rattlecage=15.8,item_prophets_pendulum=8.8,item_conjurers_catalyst=7.9,item_flayers_bota=5.3,item_dandelion_amulet=3.5},
                -- One observation; the attack profile decides for other offers.
                [5]={item_minotaur_horn=100},
            },
            enhancement={
                [1]={item_enhancement_tough=67.8,item_enhancement_quickened=15.6,item_enhancement_brawny=12.2},
                [2]={item_enhancement_tough=80.4,item_enhancement_quickened=10.6,item_enhancement_brawny=7.6},
                [3]={item_enhancement_tough=84.5,item_enhancement_quickened=6.8,item_enhancement_brawny=6.8},
                [4]={item_enhancement_tough=73.7,item_enhancement_brawny=11.4,item_enhancement_quickened=10.5},
                [5]={item_enhancement_evolved=100},
            },
        },
        pos_3={tier5Profile='attack',
            neutral={
                [1]={item_chipped_vest=24.7,item_possessed_mask=14.8,item_duelist_gloves=12.2,item_occult_bracelet=10.7,item_dormant_curio=8.0,item_weighted_dice=7.5,item_polliwog_charm=6.1},
                [2]={item_defiant_shell=20.4,item_mana_draught=19.0,item_poor_mans_shield=11.1,item_searing_signet=9.3,item_medallion_of_courage=6.6,item_crippling_crossbow=6.5},
                [3]={item_gunpowder_gauntlets=29.1,item_cloak_of_flames=26.5,item_serrated_shiv=21.3,item_unrelenting_eye=3.7,item_stormcrafter=2.9,item_jidi_pollen_bag=2.6},
                [4]={item_giant_maul=31.0,item_rattlecage=13.3,item_prophets_pendulum=12.0,item_conjurers_catalyst=9.4,item_flayers_bota=7.5},
                [5]={item_desolator_2=36.0,item_fallen_sky=18.4,item_demonicon=9.6,item_minotaur_horn=9.6,item_dezun_bloodrite=8.8,item_divine_regalia=5.3,item_heavy_blade=4.4},
            },
            enhancement={
                [1]={item_enhancement_tough=61.9,item_enhancement_brawny=17.4,item_enhancement_vital=12.5},
                [2]={item_enhancement_tough=79.8,item_enhancement_brawny=11.1,item_enhancement_quickened=6.5},
                [3]={item_enhancement_tough=84.3,item_enhancement_brawny=9.2,item_enhancement_quickened=3.6},
                [4]={item_enhancement_tough=76.5,item_enhancement_brawny=9.5,item_enhancement_quickened=9.0},
                [5]={item_enhancement_evolved=60.5,item_enhancement_fleetfooted=21.1,item_enhancement_vampiric=12.3},
            },
        },
    },
}
