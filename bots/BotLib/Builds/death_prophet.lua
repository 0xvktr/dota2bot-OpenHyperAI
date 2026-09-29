-- D2PT 7.41f: https://dota2protracker.com/hero/Death%20Prophet?section=builds (&role=offlane / &role=mid)
-- Retrieved 2026-09-29. Overview: last 8 days; builds: Sep 15-29, updated Sep 29.
-- Snapshot role counts sum to 1882; header reported 1887. Live counts may change during review.
-- Pos 5 (66 matches, 3.5%) has only a partial 120-match build without talents/enchantments;
-- leave it disabled until there is enough evidence for a complete support migration.
return {
    patch='7.41f', updated='2026-09-29', defaultRole='pos_3',
    roles={
        pos_1={matches=24,winRate=58.3,skipped=true},
        pos_2={matches=772,winRate=48.7,rating=34,weight=51,buildMatches=1264},
        pos_3={matches=964,winRate=49.6,rating=38,weight=56,buildMatches=1687},
        pos_4={matches=56,winRate=51.8,skipped=true},
        pos_5={matches=66,winRate=48.5,skipped=true},
    },
    -- Exclude retained lower-tier items. Witchbane (mid T5, 5%) is not in the supported pools.
    -- Sparse T5 observations use the reviewed durable-caster profile, never win-rate ranking.
    neutrals={
        pos_2={tier5Profile='caster',
            neutral={
                [1]={item_stonefeather_satchel=15.8,item_dormant_curio=15.3,item_kobold_cup=12.7,item_chipped_vest=12.4,item_occult_bracelet=9.8,item_duelist_gloves=9.0,item_ash_legion_shield=8.4},
                [2]={item_searing_signet=26.7,item_mana_draught=19.3,item_essence_ring=15.4,item_poor_mans_shield=8.0,item_pogo_stick=7.7,item_crippling_crossbow=7.0},
                [3]={item_cloak_of_flames=21.1,item_stormcrafter=14.8,item_partisans_brand=11.7,item_gunpowder_gauntlets=7.1,item_spellslinger=7.0,item_unrelenting_eye=6.2},
                [4]={item_conjurers_catalyst=33.0,item_prophets_pendulum=23.1,item_idol_of_screeauk=9.8,item_rattlecage=9.2,item_dandelion_amulet=7.9,item_enchanters_bauble=6.9,item_giant_maul=2.6},
                [5]={item_minotaur_horn=30,item_fallen_sky=20,item_desolator_2=10,item_demonicon=10,item_spider_legs=5},
            },
            enhancement={
                [1]={item_enhancement_quickened=51.7,item_enhancement_mystical=37.7,item_enhancement_alert=8.7},
                [2]={item_enhancement_mystical=45.2,item_enhancement_quickened=32.5,item_enhancement_greedy=12.4},
                [3]={item_enhancement_mystical=44.0,item_enhancement_quickened=29.8,item_enhancement_alert=12.6},
                [4]={item_enhancement_quickened=46.2,item_enhancement_mystical=20.5,item_enhancement_timeless=18.2},
                [5]={item_enhancement_timeless=30,item_enhancement_evolved=30,item_enhancement_fleetfooted=15},
            },
        },
        pos_3={tier5Profile='caster',
            neutral={
                [1]={item_chipped_vest=14.4,item_dormant_curio=13.9,item_ash_legion_shield=11.5,item_stonefeather_satchel=10.5,item_occult_bracelet=10.5,item_kobold_cup=9.4,item_duelist_gloves=9.2},
                [2]={item_searing_signet=28.2,item_mana_draught=20.9,item_essence_ring=16.0,item_pogo_stick=9.0,item_poor_mans_shield=7.0,item_crippling_crossbow=7.0},
                [3]={item_cloak_of_flames=22.2,item_stormcrafter=15.7,item_partisans_brand=11.6,item_spellslinger=6.9,item_unrelenting_eye=6.4,item_gunpowder_gauntlets=5.6},
                [4]={item_conjurers_catalyst=33.3,item_prophets_pendulum=25.4,item_rattlecage=10.1,item_enchanters_bauble=8.3,item_dandelion_amulet=7.6,item_idol_of_screeauk=5.8},
                [5]={item_fallen_sky=26.1,item_minotaur_horn=21.7,item_desolator_2=8.7,item_spider_legs=8.7,item_demonicon=8.7,item_dezun_bloodrite=8.7},
            },
            enhancement={
                [1]={item_enhancement_quickened=46.8,item_enhancement_mystical=41.1,item_enhancement_alert=9.3},
                [2]={item_enhancement_mystical=50.8,item_enhancement_quickened=22.2,item_enhancement_greedy=18.3},
                [3]={item_enhancement_mystical=45.9,item_enhancement_quickened=22.2,item_enhancement_greedy=19.8},
                [4]={item_enhancement_quickened=47.2,item_enhancement_mystical=22.6,item_enhancement_timeless=18.5},
                [5]={item_enhancement_vampiric=43.5,item_enhancement_fleetfooted=34.8,item_enhancement_timeless=17.4},
            },
        },
    },
}
