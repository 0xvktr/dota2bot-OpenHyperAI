-- Offlane only by request. Header 2339; role rows 2337.
return {
    patch='7.41f', updated='2026-09-30', defaultRole='pos_3',
    source='https://dota2protracker.com/hero/Mars?section=builds',
    overviewWindow='last 8 days, 7000+', buildWindow='2026-09-16 to 2026-09-30', buildUpdated='2026-09-30',
    roles={
        pos_1={matches=3,winRate=66.7,skipped=true},
        pos_2={matches=78,winRate=47.4,skipped=true},
        pos_3={matches=2193,winRate=46.3,rating=21,weight=51,buildMatches=4106,buildWinRate=47,skillMatches=1363,openingMatches=492,openingObserved=4105},
        pos_4={matches=40,winRate=55,skipped=true},
        pos_5={matches=23,winRate=39.1,skipped=true},
    },
    -- Current-tier observations; T5 uses reviewed suitability.
    neutrals={
        pos_3={tier5Profile='tank',
            neutral={
                [1]={item_chipped_vest=22.9,item_possessed_mask=12.8,item_polliwog_charm=10.1,item_dormant_curio=8.9,item_ash_legion_shield=8.7,item_occult_bracelet=8.1,item_duelist_gloves=7.5},
                [2]={item_mana_draught=19.9,item_searing_signet=17,item_pogo_stick=13.6,item_poor_mans_shield=10,item_essence_ring=9.3,item_defiant_shell=5.3,item_crippling_crossbow=5.1},
                [3]={item_cloak_of_flames=29.9,item_gunpowder_gauntlets=27.8,item_serrated_shiv=7.1,item_stormcrafter=5.8,item_jidi_pollen_bag=5.3,item_partisans_brand=4.5,item_unrelenting_eye=3.8},
                [4]={item_conjurers_catalyst=19.8,item_giant_maul=18.5,item_prophets_pendulum=13.1,item_rattlecage=12.6,item_dandelion_amulet=7.3,item_enchanters_bauble=6.3},
                [5]={item_desolator_2=28.8,item_fallen_sky=20.3,item_demonicon=15.3,item_spider_legs=10.2,item_minotaur_horn=8.5,item_dezun_bloodrite=6.8},
            },
            enhancement={
                [1]={item_enhancement_tough=38.4,item_enhancement_brawny=26,item_enhancement_quickened=18.2},
                [2]={item_enhancement_tough=52.5,item_enhancement_brawny=25.7,item_enhancement_quickened=18},
                [3]={item_enhancement_tough=57.9,item_enhancement_brawny=24.6,item_enhancement_quickened=14.1},
                [4]={item_enhancement_tough=41.6,item_enhancement_timeless=22.1,item_enhancement_brawny=19.8},
                [5]={item_enhancement_evolved=45.8,item_enhancement_timeless=25.4,item_enhancement_fleetfooted=13.6},
            },
        },
    },
}
