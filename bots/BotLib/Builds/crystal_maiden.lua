-- D2PT 7.41f: https://dota2protracker.com/hero/Crystal%20Maiden?section=builds (&role=hard_support / support / mid)
-- Retrieved 2026-09-29. Overview: last 8 days; builds: Sep 15-29, updated Sep 29.
-- Role counts sum to 4777; overview reports 4785. Weights: sample-scaled D2PT role rating, see aba_hero_pos_weights.ts.
-- Mid is a reviewed exception to the 5% rule (71 matches, 1.5%, 56.3%): it has a distinct
-- 149-match build (Bottle, Treads, Blink, BKB, Scepter, Shiva's), but only 37 matches back
-- its skill order and about 31 its item rates. Supports remain her main draft roles.
return {
    patch='7.41f', updated='2026-09-29', defaultRole='pos_5',
    roles={
        pos_1={matches=3,winRate=0,skipped=true},
        pos_2={matches=71,winRate=56.3,rating=34,weight=36,buildMatches=149},
        pos_3={matches=10,winRate=40,skipped=true},
        pos_4={matches=710,winRate=50.1,rating=36,weight=51,buildMatches=1162},
        pos_5={matches=3983,winRate=48.7,rating=48,weight=78,buildMatches=6447},
    },
    -- Current-tier choices only: retained Dormant Curio, Mana Draught, Searing Signet, Pogo Stick,
    -- Partisan's Brand, Unrelenting Eye, Conjurer's Catalyst and Enchanter's Bauble are excluded
    -- from later tiers. T5 uses pick frequency plus reviewed suitability, not tiny-sample win rates.
    neutrals={
        pos_2={tier5Profile='caster',
            neutral={
                [1]={item_dormant_curio=28.9,item_ash_legion_shield=12.8,item_stonefeather_satchel=11.4,item_polliwog_charm=9.4,item_weighted_dice=8.7,item_occult_bracelet=7.4,item_kobold_cup=6.7},
                [2]={item_mana_draught=30.8,item_searing_signet=24.7,item_essence_ring=12.3,item_pogo_stick=12.3,item_poor_mans_shield=2.1,item_crippling_crossbow=1.4},
                [3]={item_partisans_brand=22.7,item_unrelenting_eye=10.9,item_spellslinger=10.1,item_psychic_headband=5.9},
                [4]={item_conjurers_catalyst=45.0,item_prophets_pendulum=13.3,item_enchanters_bauble=8.3,item_rattlecage=6.7,item_dandelion_amulet=5.0},
                [5]={item_fallen_sky=20.0,item_minotaur_horn=20.0,item_dezun_bloodrite=20.0},
            },
            enhancement={
                [1]={item_enhancement_mystical=81.2,item_enhancement_quickened=18.1,item_enhancement_tough=0.7},
                [2]={item_enhancement_greedy=71.9,item_enhancement_mystical=21.2,item_enhancement_quickened=4.1},
                [3]={item_enhancement_greedy=70.6,item_enhancement_mystical=21.0,item_enhancement_quickened=5.0},
                [4]={item_enhancement_timeless=60.0,item_enhancement_mystical=20.0,item_enhancement_quickened=11.7},
                [5]={item_enhancement_timeless=80.0,item_enhancement_vampiric=20.0},
            },
        },
        pos_4={tier5Profile='support',
            neutral={
                [1]={item_dormant_curio=18.6,item_ash_legion_shield=15.2,item_kobold_cup=14.0,item_foragers_kit=12.7,item_stonefeather_satchel=10.8,item_polliwog_charm=10.6,item_occult_bracelet=7.2},
                [2]={item_mana_draught=26.1,item_searing_signet=23.9,item_pogo_stick=18.0,item_essence_ring=12.4,item_crippling_crossbow=2.4,item_seeds_of_serenity=2.0},
                [3]={item_partisans_brand=16.0,item_spellslinger=15.2,item_psychic_headband=9.1,item_stormcrafter=6.2},
                [4]={item_conjurers_catalyst=41.7,item_enchanters_bauble=15.1,item_prophets_pendulum=9.7,item_dandelion_amulet=7.7,item_idol_of_screeauk=5.6,item_rattlecage=2.3},
                [5]={item_demonicon=30.8,item_dezun_bloodrite=15.4,item_spider_legs=7.7,item_fallen_sky=7.7,item_minotaur_horn=7.7,item_divine_regalia=7.7},
            },
            enhancement={
                [1]={item_enhancement_mystical=61.6,item_enhancement_quickened=37.1,item_enhancement_vital=1.2},
                [2]={item_enhancement_greedy=73.5,item_enhancement_mystical=15.2,item_enhancement_quickened=5.7},
                [3]={item_enhancement_greedy=74.4,item_enhancement_mystical=15.2,item_enhancement_keen_eyed=6.9},
                [4]={item_enhancement_timeless=59.6,item_enhancement_mystical=21.7,item_enhancement_quickened=10.2},
                [5]={item_enhancement_timeless=84.6,item_enhancement_feverish=15.4},
            },
        },
        pos_5={tier5Profile='support',
            neutral={
                [1]={item_dormant_curio=20.0,item_ash_legion_shield=16.6,item_kobold_cup=14.4,item_stonefeather_satchel=11.1,item_polliwog_charm=11.0,item_foragers_kit=10.5,item_occult_bracelet=7.7},
                [2]={item_searing_signet=25.5,item_mana_draught=23.8,item_pogo_stick=18.3,item_essence_ring=13.5,item_medallion_of_courage=2.6,item_poor_mans_shield=1.9},
                [3]={item_spellslinger=17.0,item_partisans_brand=13.3,item_psychic_headband=9.6,item_stormcrafter=6.6},
                [4]={item_conjurers_catalyst=42.0,item_enchanters_bauble=11.9,item_dandelion_amulet=10.2,item_prophets_pendulum=10.1,item_idol_of_screeauk=5.3,item_rattlecage=4.3},
                [5]={item_dezun_bloodrite=26.7,item_demonicon=10.0,item_spider_legs=8.3,item_fallen_sky=6.7,item_harmonizer=6.7},
            },
            enhancement={
                [1]={item_enhancement_mystical=58.8,item_enhancement_quickened=39.5,item_enhancement_vital=1.4},
                [2]={item_enhancement_greedy=76.2,item_enhancement_mystical=14.3,item_enhancement_quickened=4.7},
                [3]={item_enhancement_greedy=76.6,item_enhancement_mystical=12.7,item_enhancement_keen_eyed=6.0},
                [4]={item_enhancement_timeless=57.7,item_enhancement_mystical=19.1,item_enhancement_quickened=12.8},
                [5]={item_enhancement_timeless=70.0,item_enhancement_feverish=16.7,item_enhancement_fleetfooted=6.7},
            },
        },
    },
}
