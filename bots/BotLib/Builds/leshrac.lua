-- D2PT 7.41f; role counts sum to 1606, header 1609. Requested migrated roles meet thresholds.
return {
    patch='7.41f', updated='2026-09-30', defaultRole='pos_2',
    source='https://dota2protracker.com/hero/Leshrac?section=builds',
    overviewWindow='last 8 days, 7000+', buildWindow='2026-09-15 to 2026-09-29', buildUpdated='2026-09-29',
    roles={
        pos_1={matches=147,winRate=66,rating=45,skipped=true},
        pos_2={matches=1259,winRate=50.8,rating=41,weight=63,buildMatches=2064,buildWinRate=51,skillMatches=191,skillWinRate=48.2,openingMatches=814,openingWinRate=51.4,openingObserved=2064},
        pos_3={matches=90,winRate=54.4,rating=34,skipped=true},
        pos_4={matches=64,winRate=37.5,rating=28,skipped=true},
        pos_5={matches=46,winRate=45.7,skipped=true},
    },
    -- Current-tier observations only; sparse T5 uses reviewed role suitability.
    neutrals={
        pos_2={tier5Profile='caster',
            neutral={
                [1]={item_dormant_curio=23.7,item_occult_bracelet=17,item_stonefeather_satchel=11.1,item_kobold_cup=9.6,item_polliwog_charm=9.5,item_ash_legion_shield=8.2,item_chipped_vest=6.3},
                [2]={item_mana_draught=31.2,item_searing_signet=31,item_essence_ring=14,item_pogo_stick=10.1,item_poor_mans_shield=2.1,item_crippling_crossbow=1.7},
                [3]={item_cloak_of_flames=21.7,item_partisans_brand=19.9,item_spellslinger=15.2,item_stormcrafter=7.8},
                [4]={item_conjurers_catalyst=39.3,item_enchanters_bauble=13.1,item_prophets_pendulum=12.6,item_rattlecage=8,item_dandelion_amulet=6.3},
                [5]={item_harmonizer=20,item_dezun_bloodrite=16,item_divine_regalia=12,item_spider_legs=8,item_minotaur_horn=8},
            },
            enhancement={
                [1]={item_enhancement_mystical=69.5,item_enhancement_quickened=29.9,item_enhancement_vital=0.6},
                [2]={item_enhancement_mystical=55,item_enhancement_greedy=34.5,item_enhancement_quickened=9.1},
                [3]={item_enhancement_mystical=53.7,item_enhancement_greedy=34.5,item_enhancement_quickened=8.2},
                [4]={item_enhancement_timeless=47.9,item_enhancement_mystical=42.3,item_enhancement_quickened=7.6},
                [5]={item_enhancement_timeless=92,item_enhancement_fleetfooted=8},
            },
        },
    },
}
