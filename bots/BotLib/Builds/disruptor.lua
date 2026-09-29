-- D2PT 7.41f, retrieved 2026-09-29. Overview: last 8 days; builds: Sep 15-29, updated Sep 29.
-- Role counts sum to 6243; header reported 6257.
return {
    patch='7.41f', updated='2026-09-29', defaultRole='pos_5',
    source='https://dota2protracker.com/hero/Disruptor?section=builds',
    roles={
        pos_1={matches=1,winRate=100.0,skipped=true},
        pos_2={matches=6,winRate=33.3,skipped=true},
        pos_3={matches=1,winRate=0.0,skipped=true},
        pos_4={matches=700,winRate=46.1,rating=20,weight=42,buildMatches=1119,skillMatches=173,observedOpenings=1119,openingMatches=37},
        pos_5={matches=5535,winRate=52.6,rating=82,weight=100,buildMatches=8170,skillMatches=1738,observedOpenings=8167,openingMatches=344},
    },
    -- Current tiers only; sparse T5 picks use the support profile.
    -- Legacy names: Tumbler's Toy = Pogo Stick; Witchbane = Heavy Blade.
    neutrals={
        pos_4={tier5Profile='support',
            neutral={
                [1]={item_dormant_curio=19.1,item_kobold_cup=17.2,item_ash_legion_shield=13.2,item_polliwog_charm=12.5,item_stonefeather_satchel=10.5,item_foragers_kit=10.0,item_occult_bracelet=7.9},
                [2]={item_searing_signet=25.8,item_pogo_stick=19.7,item_mana_draught=16.2,item_essence_ring=15.9,item_medallion_of_courage=4.0,item_crippling_crossbow=3.5},
                [3]={item_psychic_headband=13.2,item_spellslinger=9.0,item_partisans_brand=8.8,item_stormcrafter=7.5},
                [4]={item_conjurers_catalyst=29.3,item_enchanters_bauble=16.8,item_prophets_pendulum=15.1,item_dandelion_amulet=14.2,item_idol_of_screeauk=4.0,item_metamorphic_mandible=2.8},
                [5]={item_demonicon=40.0,item_fallen_sky=20.0,item_dezun_bloodrite=20.0,item_riftshadow_prism=10.0},
            },
            enhancement={
                [1]={item_enhancement_quickened=55.0,item_enhancement_mystical=41.1,item_enhancement_vital=3.8},
                [2]={item_enhancement_greedy=72.3,item_enhancement_keen_eyed=15.2,item_enhancement_mystical=7.8},
                [3]={item_enhancement_greedy=72.7,item_enhancement_keen_eyed=17.2,item_enhancement_mystical=6.2},
                [4]={item_enhancement_keen_eyed=45.0,item_enhancement_timeless=29.3,item_enhancement_quickened=16.0},
                [5]={item_enhancement_timeless=90.0,item_enhancement_fleetfooted=10.0},
            },
        },
        pos_5={tier5Profile='support',
            neutral={
                [1]={item_dormant_curio=19.7,item_kobold_cup=15.6,item_polliwog_charm=15.5,item_ash_legion_shield=14.7,item_foragers_kit=9.9,item_stonefeather_satchel=9.7,item_occult_bracelet=6.6},
                [2]={item_searing_signet=25.6,item_pogo_stick=22.7,item_essence_ring=16.3,item_mana_draught=15.6,item_medallion_of_courage=3.4,item_crippling_crossbow=2.9},
                [3]={item_psychic_headband=15.4,item_spellslinger=7.9,item_stormcrafter=6.9,item_partisans_brand=6.8},
                [4]={item_conjurers_catalyst=35.9,item_enchanters_bauble=17.3,item_dandelion_amulet=13.1,item_prophets_pendulum=12.0,item_idol_of_screeauk=3.4,item_metamorphic_mandible=2.4},
                [5]={item_demonicon=25.0,item_dezun_bloodrite=22.8,item_fallen_sky=12.0,item_minotaur_horn=9.8,item_spider_legs=8.7,item_heavy_blade=4.3},
            },
            enhancement={
                [1]={item_enhancement_quickened=53.8,item_enhancement_mystical=43.6,item_enhancement_vital=2.4},
                [2]={item_enhancement_greedy=78.2,item_enhancement_keen_eyed=11.6,item_enhancement_mystical=5.8},
                [3]={item_enhancement_greedy=78.4,item_enhancement_keen_eyed=13.4,item_enhancement_mystical=4.7},
                [4]={item_enhancement_keen_eyed=45.3,item_enhancement_timeless=28.9,item_enhancement_quickened=13.5},
                [5]={item_enhancement_timeless=47.8,item_enhancement_feverish=44.6,item_enhancement_fleetfooted=7.6},
            },
        },
    },
}
