-- Carry only by request; eligible support deferred. Header 1309; role rows 1307.
return {
    patch='7.41f', updated='2026-09-30', defaultRole='pos_1',
    source='https://dota2protracker.com/hero/Muerta?section=builds',
    overviewWindow='last 8 days, 7000+', buildWindow='2026-09-16 to 2026-09-30', buildUpdated='2026-09-30',
    roles={
        pos_1={matches=1018,winRate=49.1,rating=35,weight=55,buildMatches=1890,buildWinRate=49,skillMatches=388,openingMatches=520,openingObserved=1890},
        pos_2={matches=51,winRate=47.1,skipped=true},
        pos_3={matches=50,winRate=48,skipped=true},
        pos_4={matches=124,winRate=49.2,skipped=true},
        pos_5={matches=64,winRate=39.1,skipped=true},
    },
    -- Current-tier observations; T5 uses reviewed suitability.
    neutrals={
        pos_1={tier5Profile='attack',
            neutral={
                [1]={item_possessed_mask=26.9,item_duelist_gloves=16.8,item_weighted_dice=15.6,item_dormant_curio=9.5,item_polliwog_charm=7.4,item_stonefeather_satchel=5,item_occult_bracelet=4.5},
                [2]={item_mana_draught=15.1,item_searing_signet=13.4,item_defiant_shell=11.4,item_pogo_stick=10.7,item_essence_ring=6.8},
                [3]={item_serrated_shiv=40.7,item_gunpowder_gauntlets=23.7,item_partisans_brand=10.5,item_unrelenting_eye=3.9,item_stormcrafter=1.9},
                [4]={item_giant_maul=24,item_flayers_bota=21.3,item_conjurers_catalyst=19.4,item_prophets_pendulum=7.6,item_enchanters_bauble=7.3},
                [5]={item_desolator_2=42.4,item_minotaur_horn=18.2,item_divine_regalia=12.1,item_spider_legs=6.1,item_fallen_sky=6.1},
            },
            enhancement={
                [1]={item_enhancement_tough=58.4,item_enhancement_quickened=18.5,item_enhancement_mystical=17.2},
                [2]={item_enhancement_tough=49.8,item_enhancement_quickened=24.7,item_enhancement_mystical=23.7},
                [3]={item_enhancement_tough=56.6,item_enhancement_quickened=21.9,item_enhancement_mystical=19.8},
                [4]={item_enhancement_tough=42.5,item_enhancement_quickened=32.9,item_enhancement_timeless=17.2},
                [5]={item_enhancement_vampiric=33.3,item_enhancement_fleetfooted=30.3,item_enhancement_timeless=18.2},
            },
        },
    },
}
