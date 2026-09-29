-- Header 4952; role rows sum to 4943. Requested mid/offlane only.
-- Eligible supports deferred; forced picks use offlane.
return {
    patch='7.41f', updated='2026-09-30', defaultRole='pos_3',
    source='https://dota2protracker.com/hero/Magnus?section=builds',
    overviewWindow='last 8 days, 7000+', buildWindow='2026-09-15 to 2026-09-29', buildUpdated='2026-09-29',
    roles={
        pos_1={matches=69,winRate=43.5,skipped=true},
        pos_2={matches=953,winRate=49.7,rating=36,weight=55,buildMatches=1656,buildWinRate=50,skillMatches=359,openingMatches=219,openingObserved=1656},
        pos_3={matches=2880,winRate=49.8,rating=48,weight=78,buildMatches=5012,buildWinRate=50,skillMatches=678,openingMatches=514,openingObserved=5012},
        pos_4={matches=645,winRate=48.2,skipped=true},
        pos_5={matches=396,winRate=50.8,skipped=true},
    },
    -- Current-tier observations only; sparse T5 picks use reviewed suitability.
    neutrals={
        pos_3={tier5Profile='tank',
            neutral={
                [1]={item_possessed_mask=17.6,item_chipped_vest=17.5,item_duelist_gloves=14.8,item_dormant_curio=9.2,item_polliwog_charm=9.1,item_weighted_dice=7.6,item_occult_bracelet=6.7},
                [2]={item_pogo_stick=18.4,item_searing_signet=17,item_defiant_shell=15,item_mana_draught=11.5,item_poor_mans_shield=9.8,item_essence_ring=8.7,item_crippling_crossbow=3.4},
                [3]={item_cloak_of_flames=22.7,item_gunpowder_gauntlets=20,item_serrated_shiv=13.2,item_psychic_headband=7,item_stormcrafter=5.8,item_partisans_brand=5.4},
                [4]={item_conjurers_catalyst=29.3,item_giant_maul=12.9,item_enchanters_bauble=12.7,item_prophets_pendulum=11.1,item_dandelion_amulet=9.3,item_rattlecage=5.3,item_idol_of_screeauk=4.2},
                [5]={item_dezun_bloodrite=31.7,item_fallen_sky=23.8,item_demonicon=7.9,item_minotaur_horn=7.9,item_desolator_2=6.3,item_spider_legs=6.3},
            },
            enhancement={
                [1]={item_enhancement_alert=55.8,item_enhancement_quickened=16.4,item_enhancement_mystical=14.7},
                [2]={item_enhancement_alert=61.1,item_enhancement_mystical=15,item_enhancement_quickened=13.7},
                [3]={item_enhancement_alert=55.4,item_enhancement_quickened=15.2,item_enhancement_mystical=15},
                [4]={item_enhancement_timeless=36.3,item_enhancement_alert=34.5,item_enhancement_quickened=22},
                [5]={item_enhancement_timeless=57.1,item_enhancement_fleetfooted=22.2,item_enhancement_evolved=12.7},
            },
        },
        pos_2={tier5Profile='tank',
            neutral={
                [1]={item_duelist_gloves=17.2,item_chipped_vest=15.1,item_possessed_mask=15.1,item_dormant_curio=13.2,item_weighted_dice=7.8,item_occult_bracelet=7.3,item_polliwog_charm=6.6},
                [2]={item_searing_signet=20.6,item_pogo_stick=18,item_defiant_shell=14.8,item_essence_ring=10.1,item_poor_mans_shield=7.6,item_mana_draught=7.5},
                [3]={item_gunpowder_gauntlets=23.8,item_cloak_of_flames=17.6,item_serrated_shiv=16.7,item_stormcrafter=5.2,item_partisans_brand=4.9},
                [4]={item_conjurers_catalyst=28.1,item_giant_maul=20.1,item_enchanters_bauble=13.1,item_prophets_pendulum=10,item_dandelion_amulet=5.3,item_flayers_bota=4.3,item_rattlecage=3.9},
                [5]={item_fallen_sky=33.3,item_demonicon=20.8,item_spider_legs=12.5,item_dezun_bloodrite=12.5,item_minotaur_horn=8.3,item_heavy_blade=4.2,item_divine_regalia=4.2},
            },
            enhancement={
                [1]={item_enhancement_alert=55.3,item_enhancement_quickened=21,item_enhancement_mystical=16.3},
                [2]={item_enhancement_alert=62,item_enhancement_mystical=16.9,item_enhancement_quickened=14},
                [3]={item_enhancement_alert=60.1,item_enhancement_quickened=15.8,item_enhancement_mystical=14.6},
                [4]={item_enhancement_alert=38.9,item_enhancement_timeless=37.8,item_enhancement_quickened=15.6},
                [5]={item_enhancement_timeless=62.5,item_enhancement_fleetfooted=20.8,item_enhancement_evolved=12.5},
            },
        },
    },
}
