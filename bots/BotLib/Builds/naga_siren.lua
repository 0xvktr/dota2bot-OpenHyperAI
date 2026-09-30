-- Carry only; other roles below threshold. Header 631; role rows 630.
return {
    patch='7.41f', updated='2026-09-30', defaultRole='pos_1',
    source='https://dota2protracker.com/hero/Naga%20Siren?section=builds',
    overviewWindow='last 8 days, 7000+', buildWindow='2026-09-16 to 2026-09-30', buildUpdated='2026-09-30',
    roles={
        pos_1={matches=587,winRate=54,rating=50,weight=57,buildMatches=1014,buildWinRate=54,skillMatches=95,openingMatches=254,openingObserved=1013},
        pos_2={matches=6,winRate=66.7,skipped=true},
        pos_3={matches=19,winRate=42.1,skipped=true},
        pos_4={matches=10,winRate=60,skipped=true},
        pos_5={matches=8,winRate=37.5,skipped=true},
    },
    -- Current-tier observations; T5 uses reviewed suitability.
    neutrals={
        pos_1={tier5Profile='attack',
            neutral={
                [1]={item_possessed_mask=23.9,item_weighted_dice=14.7,item_duelist_gloves=10.3,item_polliwog_charm=9.7,item_stonefeather_satchel=8.6,item_occult_bracelet=8.1,item_chipped_vest=7.3},
                [2]={item_mana_draught=29.2,item_searing_signet=14.9,item_poor_mans_shield=13.8,item_medallion_of_courage=7.7,item_defiant_shell=6.8,item_crippling_crossbow=4.3},
                [3]={item_cloak_of_flames=33.2,item_serrated_shiv=25.1,item_gunpowder_gauntlets=13.5,item_unrelenting_eye=5},
                [4]={item_giant_maul=21.9,item_prophets_pendulum=19.9,item_conjurers_catalyst=9.1,item_enchanters_bauble=6.8,item_flayers_bota=5.7,item_dandelion_amulet=5.7},
                [5]={item_desolator_2=50,item_divine_regalia=16.7,item_spider_legs=5.6,item_demonicon=5.6,item_fallen_sky=5.6,item_minotaur_horn=5.6,item_heavy_blade=5.6},
            },
            enhancement={
                [1]={item_enhancement_alert=63,item_enhancement_quickened=23.2,item_enhancement_vital=7.9},
                [2]={item_enhancement_alert=63,item_enhancement_nimble=14.9,item_enhancement_quickened=14.7},
                [3]={item_enhancement_alert=67.2,item_enhancement_nimble=13.6,item_enhancement_quickened=12},
                [4]={item_enhancement_alert=80.1,item_enhancement_quickened=10.8,item_enhancement_brawny=5.7},
                [5]={item_enhancement_fleetfooted=66.7,item_enhancement_evolved=33.3},
            },
        },
    },
}
