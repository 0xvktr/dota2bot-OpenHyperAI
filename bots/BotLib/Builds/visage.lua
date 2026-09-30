-- Mid/offlane; eligible support deferred. Header 1743; role rows 1740.
return {
    patch='7.41f', updated='2026-09-30', defaultRole='pos_3',
    source='https://dota2protracker.com/hero/Visage?section=builds',
    overviewWindow='last 8 days, 7000+', buildWindow='2026-09-16 to 2026-09-30', buildUpdated='2026-09-30',
    roles={
        pos_1={matches=3,winRate=66.7,skipped=true},
        pos_2={matches=483,winRate=55.7,rating=48,weight=54,buildMatches=770,buildWinRate=57,skillMatches=64,openingMatches=79,openingObserved=770},
        pos_3={matches=996,winRate=54.8,rating=51,weight=66,buildMatches=1674,buildWinRate=55,skillMatches=189,openingMatches=183,openingObserved=1674},
        pos_4={matches=181,winRate=49.2,rating=33,skipped=true},
        pos_5={matches=77,winRate=40.3,rating=30,skipped=true},
    },
    -- Current-tier pick frequencies; T5 uses reviewed suitability.
    neutrals={
        pos_2={tier5Profile='caster',
            neutral={
                [1]={item_duelist_gloves=15.7,item_kobold_cup=13.7,item_stonefeather_satchel=11.7,item_dormant_curio=11.4,item_ash_legion_shield=8.8,item_occult_bracelet=8.6,item_weighted_dice=7.7},
                [2]={item_medallion_of_courage=35.2,item_crippling_crossbow=17.2,item_searing_signet=12.6,item_mana_draught=7.7,item_essence_ring=6.2,item_poor_mans_shield=6.1,item_pogo_stick=3.5},
                [3]={item_serrated_shiv=22.7,item_gunpowder_gauntlets=14.1,item_partisans_brand=8.9,item_stormcrafter=5.8,item_unrelenting_eye=3.8},
                [4]={item_giant_maul=19.2,item_prophets_pendulum=19.2,item_conjurers_catalyst=13.6,item_rattlecage=8.5,item_dandelion_amulet=7.9},
                [5]={item_desolator_2=40,item_demonicon=20,item_fallen_sky=20,item_heavy_blade=20},
            },
            enhancement={
                [1]={item_enhancement_mystical=40.3,item_enhancement_quickened=37.5,item_enhancement_alert=21.3},
                [2]={item_enhancement_alert=31.6,item_enhancement_quickened=26.2,item_enhancement_greedy=22},
                [3]={item_enhancement_alert=38.6,item_enhancement_quickened=28.2,item_enhancement_greedy=17.5},
                [4]={item_enhancement_alert=44.1,item_enhancement_quickened=35,item_enhancement_timeless=16.4},
                [5]={item_enhancement_evolved=40,item_enhancement_fleetfooted=20,item_enhancement_timeless=20},
            },
        },
        pos_3={tier5Profile='caster',
            neutral={
                [1]={item_ash_legion_shield=15.5,item_kobold_cup=14.8,item_dormant_curio=14.2,item_duelist_gloves=11.8,item_possessed_mask=8.3,item_weighted_dice=8.2,item_stonefeather_satchel=6.7},
                [2]={item_medallion_of_courage=26.5,item_searing_signet=18.4,item_crippling_crossbow=14.1,item_mana_draught=9.8,item_essence_ring=9.4,item_poor_mans_shield=5.9},
                [3]={item_gunpowder_gauntlets=15.7,item_serrated_shiv=15.2,item_cloak_of_flames=8,item_partisans_brand=7.7,item_unrelenting_eye=6.6,item_stormcrafter=5.9},
                [4]={item_conjurers_catalyst=19.1,item_prophets_pendulum=18.8,item_giant_maul=15.9,item_rattlecage=8.3,item_dandelion_amulet=7.1,item_enchanters_bauble=6.8},
                [5]={item_desolator_2=33.3,item_demonicon=33.3,item_heavy_blade=11.1,item_divine_regalia=11.1},
            },
            enhancement={
                [1]={item_enhancement_mystical=41.8,item_enhancement_quickened=35.1,item_enhancement_alert=21.3},
                [2]={item_enhancement_greedy=36,item_enhancement_mystical=26.2,item_enhancement_alert=24.8},
                [3]={item_enhancement_greedy=35.5,item_enhancement_alert=28.9,item_enhancement_mystical=21.5},
                [4]={item_enhancement_alert=36.9,item_enhancement_quickened=34,item_enhancement_timeless=14.7},
                [5]={item_enhancement_fleetfooted=55.6,item_enhancement_timeless=22.2,item_enhancement_evolved=11.1},
            },
        },
    },
}
