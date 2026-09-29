-- Header 2042; displayed role counts sum to 2040.
-- Optional mid (179 matches, 8.8%) is deferred; forced carry/mid use pos 5.
return {
    patch='7.41f', updated='2026-09-30', defaultRole='pos_5',
    source='https://dota2protracker.com/hero/Enchantress?section=builds',
    overviewWindow='last 8 days, 7000+', buildWindow='2026-09-15 to 2026-09-29', buildUpdated='2026-09-29',
    roles={
        pos_1={matches=4,winRate=50,skipped=true},
        pos_2={matches=179,winRate=52.5,skipped=true},
        pos_3={matches=484,winRate=52.1,rating=37,weight=48,buildMatches=776,buildWinRate=53,skillMatches=56,openingMatches=155,openingObserved=776},
        pos_4={matches=405,winRate=45.7,rating=25,weight=41,buildMatches=650,buildWinRate=46,skillMatches=63,openingMatches=43,openingObserved=649},
        pos_5={matches=968,winRate=48.7,rating=31,weight=52,buildMatches=915,buildWinRate=54,skillMatches=77,openingMatches=53,openingObserved=913},
    },
    -- Retained lower-tier items excluded; attack profile fits all three Pike builds.
    neutrals={
        pos_3={tier5Profile='attack',
            neutral={
                [1]={item_duelist_gloves=22.8,item_dormant_curio=16.6,item_stonefeather_satchel=13.4,item_ash_legion_shield=9.3,item_weighted_dice=9.2,item_possessed_mask=7.2,item_kobold_cup=6.1},
                [2]={item_mana_draught=25.7,item_essence_ring=16.6,item_medallion_of_courage=15,item_pogo_stick=11.5,item_crippling_crossbow=8.6,item_poor_mans_shield=4.8},
                [3]={item_serrated_shiv=29.5,item_gunpowder_gauntlets=20.8,item_spellslinger=10,item_partisans_brand=8.1,item_psychic_headband=4.3,item_unrelenting_eye=4.3},
                [4]={item_prophets_pendulum=18.5,item_giant_maul=14.4,item_enchanters_bauble=10.3,item_conjurers_catalyst=7.8,item_dandelion_amulet=7.4,item_idol_of_screeauk=7},
                [5]={item_desolator_2=28.6,item_spider_legs=28.6,item_demonicon=14.3,item_heavy_blade=14.3,item_riftshadow_prism=14.3},
            },
            enhancement={
                [1]={item_enhancement_quickened=46.8,item_enhancement_mystical=45.2,item_enhancement_tough=5},
                [2]={item_enhancement_mystical=43.1,item_enhancement_keen_eyed=30,item_enhancement_quickened=16.4},
                [3]={item_enhancement_mystical=47.6,item_enhancement_keen_eyed=27.4,item_enhancement_quickened=13.4},
                [4]={item_enhancement_mystical=39.5,item_enhancement_keen_eyed=21.8,item_enhancement_quickened=19.8},
                [5]={item_enhancement_fleetfooted=57.1,item_enhancement_evolved=42.9},
            },
        },
        pos_4={tier5Profile='attack',
            neutral={
                [1]={item_ash_legion_shield=19.5,item_duelist_gloves=16,item_polliwog_charm=11.5,item_kobold_cup=11.4,item_dormant_curio=10.6,item_stonefeather_satchel=7.4,item_foragers_kit=7.4},
                [2]={item_essence_ring=21.3,item_mana_draught=15.1,item_crippling_crossbow=14.3,item_pogo_stick=10.7,item_medallion_of_courage=8.3,item_poor_mans_shield=5.2,item_searing_signet=4.4},
                [3]={item_serrated_shiv=22.2,item_gunpowder_gauntlets=20.3,item_psychic_headband=8.8,item_cloak_of_flames=6.2,item_stormcrafter=6,item_unrelenting_eye=5.5,item_spellslinger=5.5},
                [4]={item_prophets_pendulum=19.3,item_giant_maul=13,item_dandelion_amulet=11.1,item_enchanters_bauble=9.7,item_conjurers_catalyst=8.2,item_rattlecage=7.2,item_idol_of_screeauk=5.8},
                [5]={item_desolator_2=25,item_demonicon=25,item_fallen_sky=25,item_heavy_blade=25},
            },
            enhancement={
                [1]={item_enhancement_mystical=44.3,item_enhancement_quickened=43.7,item_enhancement_tough=8.6},
                [2]={item_enhancement_mystical=42.4,item_enhancement_greedy=31.7,item_enhancement_tough=10.1},
                [3]={item_enhancement_mystical=41.5,item_enhancement_greedy=22.2,item_enhancement_tough=13.6},
                [4]={item_enhancement_mystical=45.4,item_enhancement_quickened=25.1,item_enhancement_tough=12.6},
                [5]={item_enhancement_fleetfooted=50,item_enhancement_timeless=50},
            },
        },
        pos_5={tier5Profile='attack',
            neutral={
                [1]={item_ash_legion_shield=17.1,item_duelist_gloves=13.5,item_kobold_cup=13.3,item_dormant_curio=12.6,item_polliwog_charm=9.8,item_stonefeather_satchel=7.3,item_foragers_kit=6.8},
                [2]={item_essence_ring=21.5,item_medallion_of_courage=14.6,item_pogo_stick=13.6,item_mana_draught=13.3,item_crippling_crossbow=11.3,item_poor_mans_shield=4.3},
                [3]={item_serrated_shiv=26,item_gunpowder_gauntlets=18.8,item_psychic_headband=8.3,item_partisans_brand=6.8,item_stormcrafter=5.9,item_cloak_of_flames=5.4},
                [4]={item_prophets_pendulum=21.5,item_giant_maul=16.2,item_idol_of_screeauk=9.4,item_dandelion_amulet=9.4,item_flayers_bota=8.2,item_enchanters_bauble=8,item_conjurers_catalyst=8},
                [5]={item_desolator_2=30,item_demonicon=20,item_spider_legs=10,item_fallen_sky=10,item_minotaur_horn=10,item_heavy_blade=10},
            },
            enhancement={
                [1]={item_enhancement_mystical=44.7,item_enhancement_quickened=39.9,item_enhancement_tough=10.7},
                [2]={item_enhancement_mystical=42.1,item_enhancement_greedy=32.3,item_enhancement_tough=9.7},
                [3]={item_enhancement_mystical=45.6,item_enhancement_greedy=23.2,item_enhancement_tough=14.3},
                [4]={item_enhancement_mystical=47,item_enhancement_quickened=18.9,item_enhancement_tough=16.5},
                [5]={item_enhancement_fleetfooted=40,item_enhancement_timeless=30,item_enhancement_evolved=20},
            },
        },
    },
}
