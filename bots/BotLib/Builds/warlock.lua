-- Hard support only; eligible support deferred; carry not displayed. Header 1678; role rows 1675.
return {
    patch='7.41f', updated='2026-09-30', defaultRole='pos_5',
    source='https://dota2protracker.com/hero/Warlock?section=builds',
    overviewWindow='last 8 days, 7000+', buildWindow='2026-09-16 to 2026-09-30', buildUpdated='2026-09-30',
    roles={
        pos_1={matches=0,winRate=0,skipped=true},
        pos_2={matches=5,winRate=20,skipped=true},
        pos_3={matches=2,winRate=100,skipped=true},
        pos_4={matches=142,winRate=38,rating=23,skipped=true},
        pos_5={matches=1526,winRate=48.3,rating=30,weight=56,buildMatches=2609,buildWinRate=48,skillMatches=472,openingMatches=104,openingObserved=2608},
    },
    -- Current-tier pick frequencies; T5 uses reviewed suitability.
    neutrals={
        pos_5={tier5Profile='support',
            neutral={
                [1]={item_dormant_curio=18.5,item_ash_legion_shield=18.1,item_polliwog_charm=15.5,item_kobold_cup=14.3,item_foragers_kit=10.6,item_stonefeather_satchel=7.7,item_occult_bracelet=5.2},
                [2]={item_searing_signet=24.2,item_mana_draught=20.5,item_pogo_stick=16.1,item_essence_ring=13,item_medallion_of_courage=6.8,item_seeds_of_serenity=3},
                [3]={item_spellslinger=14,item_partisans_brand=12.3,item_psychic_headband=11.2},
                [4]={item_conjurers_catalyst=37.5,item_enchanters_bauble=19.2,item_dandelion_amulet=10.2,item_prophets_pendulum=10,item_idol_of_screeauk=2.8,item_metamorphic_mandible=2.4},
                [5]={item_demonicon=18.5,item_fallen_sky=14.8,item_spider_legs=11.1,item_dezun_bloodrite=11.1,item_harmonizer=11.1},
            },
            enhancement={
                [1]={item_enhancement_mystical=68.4,item_enhancement_quickened=29.8,item_enhancement_vital=1.4},
                [2]={item_enhancement_greedy=83.8,item_enhancement_mystical=7,item_enhancement_keen_eyed=6.8},
                [3]={item_enhancement_greedy=78.8,item_enhancement_keen_eyed=13.6,item_enhancement_mystical=5.4},
                [4]={item_enhancement_keen_eyed=41.6,item_enhancement_timeless=33.6,item_enhancement_mystical=13.3},
                [5]={item_enhancement_timeless=44.4,item_enhancement_feverish=33.3,item_enhancement_fleetfooted=22.2},
            },
        },
    },
}
