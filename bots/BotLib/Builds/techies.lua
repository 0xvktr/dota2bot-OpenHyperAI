-- Header 7175; role rows 7162. Mid below 5%; other core samples too small. Forced cores use support without wards.
return {
    patch='7.41f', updated='2026-09-30', defaultRole='pos_4',
    source='https://dota2protracker.com/hero/Techies?section=builds',
    overviewWindow='last 8 days, 7000+', buildWindow='2026-09-16 to 2026-09-30', buildUpdated='2026-09-30',
    roles={
        pos_1={matches=2,winRate=50.0,skipped=true},
        pos_2={matches=308,winRate=43.8,rating=29,skipped=true},
        pos_3={matches=59,winRate=35.6,rating=30,skipped=true},
        pos_4={matches=4229,winRate=49.9,rating=53,weight=83,buildMatches=4015,buildWinRate=58.0,skillMatches=425,openingMatches=288,openingObserved=4011},
        pos_5={matches=2564,winRate=51.4,rating=57,weight=87,buildMatches=3919,buildWinRate=51.0,skillMatches=243,openingMatches=256,openingObserved=3918},
    },
    -- Current-tier pick frequencies; T5 uses reviewed suitability.
    neutrals={
        pos_4={tier5Profile='support',
            neutral={
                [1]={item_dormant_curio=23.7,item_ash_legion_shield=13.6,item_kobold_cup=12.7,item_stonefeather_satchel=10.1,item_polliwog_charm=9.8,item_occult_bracelet=8.9,item_foragers_kit=8.1},
                [2]={item_searing_signet=31.4,item_mana_draught=28.4,item_pogo_stick=12.4,item_essence_ring=8.5,item_crippling_crossbow=3.9,item_medallion_of_courage=1.0},
                [3]={item_partisans_brand=19.1,item_spellslinger=12.7,item_psychic_headband=8.1},
                [4]={item_conjurers_catalyst=41.9,item_enchanters_bauble=19.8,item_prophets_pendulum=8.1,item_dandelion_amulet=6.7,item_rattlecage=2.0},
                [5]={item_fallen_sky=18.9,item_demonicon=16.8,item_dezun_bloodrite=14.7,item_divine_regalia=10.5,item_harmonizer=7.0},
            },
            enhancement={
                [1]={item_enhancement_mystical=73.2,item_enhancement_quickened=25.0,item_enhancement_vital=1.3},
                [2]={item_enhancement_greedy=86.2,item_enhancement_mystical=10.6,item_enhancement_quickened=3.1},
                [3]={item_enhancement_greedy=88.5,item_enhancement_mystical=8.1,item_enhancement_quickened=3.1},
                [4]={item_enhancement_timeless=93.1,item_enhancement_quickened=3.5,item_enhancement_mystical=2.9},
                [5]={item_enhancement_timeless=97.2,item_enhancement_fleetfooted=1.4,item_enhancement_manic=1.4},
            },
        },
        pos_5={tier5Profile='support',
            neutral={
                [1]={item_dormant_curio=22.6,item_ash_legion_shield=14.0,item_kobold_cup=11.9,item_polliwog_charm=10.9,item_foragers_kit=9.9,item_occult_bracelet=9.6,item_stonefeather_satchel=9.0},
                [2]={item_searing_signet=29.5,item_mana_draught=29.4,item_pogo_stick=11.8,item_essence_ring=9.8,item_crippling_crossbow=4.2,item_poor_mans_shield=1.5},
                [3]={item_partisans_brand=19.5,item_spellslinger=15.1,item_psychic_headband=7.6,item_stormcrafter=4.5},
                [4]={item_conjurers_catalyst=44.0,item_enchanters_bauble=18.0,item_prophets_pendulum=9.1,item_dandelion_amulet=8.6,item_rattlecage=1.8},
                [5]={item_fallen_sky=20.0,item_demonicon=17.5,item_dezun_bloodrite=8.8,item_minotaur_horn=7.5,item_harmonizer=7.5},
            },
            enhancement={
                [1]={item_enhancement_mystical=70.2,item_enhancement_quickened=26.7,item_enhancement_vital=2.7},
                [2]={item_enhancement_greedy=84.1,item_enhancement_mystical=12.4,item_enhancement_quickened=3.3},
                [3]={item_enhancement_greedy=86.0,item_enhancement_mystical=10.9,item_enhancement_quickened=2.8},
                [4]={item_enhancement_timeless=87.9,item_enhancement_quickened=6.5,item_enhancement_mystical=5.5},
                [5]={item_enhancement_timeless=96.3,item_enhancement_fleetfooted=2.5,item_enhancement_vampiric=1.3},
            },
        },
    },
}
