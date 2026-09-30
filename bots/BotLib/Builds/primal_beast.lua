-- Skipped roles use offlane; both source roles share the observed skill order.
return {
    patch='7.41f', updated='2026-09-30', defaultRole='pos_3',
    source='https://dota2protracker.com/hero/Primal%20Beast?section=builds',
    overviewWindow='last 8 days, 7000+', buildWindow='2026-09-16 to 2026-09-30', buildUpdated='2026-09-30',
    roles={
        pos_1={matches=4,winRate=75.0,skipped=true},
        pos_2={matches=739,winRate=53.7,rating=49,weight=60,buildMatches=1213,buildWinRate=58.0,skillMatches=386,openingMatches=299,openingObserved=1213},
        pos_3={matches=1298,winRate=53.5,rating=51,weight=71,buildMatches=2326,buildWinRate=52.0,skillMatches=772,openingMatches=351,openingObserved=2326},
        pos_4={matches=21,winRate=42.9,skipped=true},
        pos_5={matches=7,winRate=57.1,skipped=true},
    },
    -- Current-tier observations only; sparse T5 picks use reviewed suitability.
    neutrals={
        pos_2={tier5Profile='tank',
            neutral={
                [1]={item_chipped_vest=19.9,item_stonefeather_satchel=18.3,item_kobold_cup=14.8,item_occult_bracelet=11.0,item_dormant_curio=10.9,item_polliwog_charm=7.9,item_ash_legion_shield=6.3},
                [2]={item_searing_signet=28.2,item_mana_draught=22.7,item_pogo_stick=13.6,item_poor_mans_shield=8.6,item_essence_ring=7.0},
                [3]={item_cloak_of_flames=34.3,item_partisans_brand=19.8,item_unrelenting_eye=9.6,item_stormcrafter=8.3,item_spellslinger=4.6,item_jidi_pollen_bag=4.1},
                [4]={item_conjurers_catalyst=43.0,item_prophets_pendulum=13.2,item_rattlecage=11.1,item_enchanters_bauble=6.5,item_dandelion_amulet=4.8,item_idol_of_screeauk=4.6},
                [5]={item_dezun_bloodrite=27.8,item_spider_legs=22.2,item_fallen_sky=11.1,item_minotaur_horn=5.6,item_harmonizer=5.6},
            },
            enhancement={
                [1]={item_enhancement_quickened=73.5,item_enhancement_brawny=21.5,item_enhancement_vital=4.1},
                [2]={item_enhancement_quickened=60.7,item_enhancement_brawny=24.0,item_enhancement_greedy=8.9},
                [3]={item_enhancement_quickened=54.5,item_enhancement_brawny=26.4,item_enhancement_tough=11.3},
                [4]={item_enhancement_timeless=42.4,item_enhancement_quickened=34.7,item_enhancement_brawny=17.3},
                [5]={item_enhancement_fleetfooted=33.3,item_enhancement_timeless=27.8,item_enhancement_evolved=27.8},
            },
        },
        pos_3={tier5Profile='tank',
            neutral={
                [1]={item_chipped_vest=20.6,item_stonefeather_satchel=16.4,item_polliwog_charm=13.6,item_kobold_cup=12.0,item_dormant_curio=9.9,item_occult_bracelet=9.7,item_ash_legion_shield=5.7},
                [2]={item_searing_signet=26.4,item_mana_draught=25.1,item_pogo_stick=10.3,item_poor_mans_shield=9.1,item_essence_ring=7.5},
                [3]={item_cloak_of_flames=33.5,item_partisans_brand=18.5,item_unrelenting_eye=10.2,item_stormcrafter=8.7,item_jidi_pollen_bag=5.3,item_spellslinger=3.9},
                [4]={item_conjurers_catalyst=41.1,item_prophets_pendulum=13.4,item_rattlecage=11.0,item_enchanters_bauble=6.5,item_idol_of_screeauk=5.6,item_dandelion_amulet=5.2},
                [5]={item_dezun_bloodrite=35.5,item_fallen_sky=22.6,item_minotaur_horn=6.5,item_spider_legs=3.2,item_demonicon=3.2},
            },
            enhancement={
                [1]={item_enhancement_quickened=61.9,item_enhancement_brawny=23.9,item_enhancement_vital=13.5},
                [2]={item_enhancement_quickened=56.2,item_enhancement_brawny=30.6,item_enhancement_greedy=6.8},
                [3]={item_enhancement_quickened=47.6,item_enhancement_brawny=31.6,item_enhancement_tough=14.3},
                [4]={item_enhancement_timeless=37.4,item_enhancement_quickened=32.0,item_enhancement_brawny=23.6},
                [5]={item_enhancement_timeless=38.7,item_enhancement_evolved=29.0,item_enhancement_fleetfooted=25.8},
            },
        },
    },
}
