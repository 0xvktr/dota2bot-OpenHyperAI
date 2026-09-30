-- Mid/offlane; other roles below 5%. Header 3569; role rows 3559.
return {
    patch='7.41f', updated='2026-09-30', defaultRole='pos_2',
    source='https://dota2protracker.com/hero/Void%20Spirit?section=builds',
    overviewWindow='last 8 days, 7000+', buildWindow='2026-09-16 to 2026-09-30', buildUpdated='2026-09-30',
    roles={
        pos_1={matches=101,winRate=46.5,rating=32,skipped=true},
        pos_2={matches=2920,winRate=47.2,rating=36,weight=66,buildMatches=5088,buildWinRate=48,skillMatches=835,openingMatches=1103,openingObserved=5085},
        pos_3={matches=464,winRate=51.9,rating=38,weight=48,buildMatches=788,buildWinRate=50,skillMatches=95,openingMatches=118,openingObserved=787},
        pos_4={matches=62,winRate=37.1,rating=29,skipped=true},
        pos_5={matches=12,winRate=50,skipped=true},
    },
    -- Current-tier pick frequencies; T5 uses reviewed suitability.
    neutrals={
        pos_2={tier5Profile='caster',
            neutral={
                [1]={item_duelist_gloves=18.8,item_dormant_curio=15.1,item_chipped_vest=13,item_possessed_mask=11.8,item_occult_bracelet=9.8,item_weighted_dice=8.7,item_ash_legion_shield=5.5},
                [2]={item_searing_signet=31,item_mana_draught=17,item_essence_ring=12.1,item_crippling_crossbow=8.5,item_defiant_shell=8.1,item_poor_mans_shield=4.8},
                [3]={item_gunpowder_gauntlets=25.4,item_cloak_of_flames=21.1,item_serrated_shiv=18.1,item_partisans_brand=12.6,item_stormcrafter=6,item_jidi_pollen_bag=3.3},
                [4]={item_conjurers_catalyst=35.8,item_giant_maul=20.3,item_enchanters_bauble=9.3,item_prophets_pendulum=8.5,item_dandelion_amulet=4.4,item_flayers_bota=4.1,item_rattlecage=3.7},
                [5]={item_desolator_2=18.9,item_fallen_sky=17,item_divine_regalia=17,item_dezun_bloodrite=11.3,item_minotaur_horn=7.5,item_harmonizer=7.5},
            },
            enhancement={
                [1]={item_enhancement_alert=43.1,item_enhancement_mystical=35.3,item_enhancement_quickened=18.4},
                [2]={item_enhancement_mystical=45.2,item_enhancement_alert=38.5,item_enhancement_quickened=10.2},
                [3]={item_enhancement_alert=45.1,item_enhancement_mystical=38.7,item_enhancement_quickened=7.6},
                [4]={item_enhancement_timeless=44.8,item_enhancement_alert=36.9,item_enhancement_mystical=6.7},
                [5]={item_enhancement_timeless=50.9,item_enhancement_evolved=41.5,item_enhancement_fleetfooted=5.7},
            },
        },
        pos_3={tier5Profile='caster',
            neutral={
                [1]={item_duelist_gloves=17.7,item_chipped_vest=16,item_dormant_curio=12.5,item_possessed_mask=12.2,item_weighted_dice=10.2,item_occult_bracelet=9.5,item_ash_legion_shield=6},
                [2]={item_searing_signet=31.9,item_mana_draught=17.1,item_crippling_crossbow=11.7,item_essence_ring=8.2,item_poor_mans_shield=6.9,item_defiant_shell=6.4},
                [3]={item_gunpowder_gauntlets=24.5,item_cloak_of_flames=21.8,item_serrated_shiv=18.5,item_partisans_brand=12.9,item_stormcrafter=5.6,item_jidi_pollen_bag=2.7},
                [4]={item_conjurers_catalyst=34.9,item_giant_maul=13.5,item_enchanters_bauble=10,item_prophets_pendulum=8.9,item_rattlecage=6,item_dandelion_amulet=5.3,item_flayers_bota=4.3},
                [5]={item_desolator_2=33.3,item_fallen_sky=33.3,item_demonicon=16.7,item_heavy_blade=8.3},
            },
            enhancement={
                [1]={item_enhancement_mystical=44.6,item_enhancement_alert=35.7,item_enhancement_quickened=14.2},
                [2]={item_enhancement_mystical=53.6,item_enhancement_alert=32.6,item_enhancement_quickened=7.2},
                [3]={item_enhancement_mystical=43.9,item_enhancement_alert=36.8,item_enhancement_quickened=8.9},
                [4]={item_enhancement_timeless=35.9,item_enhancement_alert=35.6,item_enhancement_mystical=12.8},
                [5]={item_enhancement_evolved=75,item_enhancement_timeless=25},
            },
        },
    },
}
