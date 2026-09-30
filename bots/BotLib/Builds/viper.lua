-- Header 2600; role rows 2595. Other roles below 5%; forced picks use mid.
return {
    patch='7.41f', updated='2026-09-30', defaultRole='pos_2',
    source='https://dota2protracker.com/hero/Viper?section=builds',
    overviewWindow='last 8 days, 7000+', buildWindow='2026-09-16 to 2026-09-30', buildUpdated='2026-09-30',
    roles={
        pos_1={matches=115,winRate=52.2,rating=34,skipped=true},
        pos_2={matches=1334,winRate=49.3,rating=37,weight=60,buildMatches=2250,buildWinRate=49.0,skillMatches=191,openingMatches=512,openingObserved=2247},
        pos_3={matches=936,winRate=45.9,rating=23,weight=46,buildMatches=1502,buildWinRate=46.0,skillMatches=158,openingMatches=391,openingObserved=1500},
        pos_4={matches=97,winRate=45.4,rating=30,skipped=true},
        pos_5={matches=113,winRate=54.0,rating=35,skipped=true},
    },
    -- Current-tier pick frequencies; T5 uses reviewed suitability.
    neutrals={
        pos_2={tier5Profile='attack',
            neutral={
                [1]={item_duelist_gloves=16.7,item_chipped_vest=14.2,item_possessed_mask=12.6,item_dormant_curio=10.9,item_ash_legion_shield=8.2,item_polliwog_charm=7.7,item_stonefeather_satchel=7.6},
                [2]={item_searing_signet=17.5,item_essence_ring=17.2,item_mana_draught=13.4,item_pogo_stick=9.4,item_crippling_crossbow=9.0,item_poor_mans_shield=8.6,item_defiant_shell=6.5},
                [3]={item_serrated_shiv=25.8,item_cloak_of_flames=17.7,item_gunpowder_gauntlets=17.5,item_partisans_brand=9.9,item_stormcrafter=4.6,item_unrelenting_eye=4.4,item_jidi_pollen_bag=3.0},
                [4]={item_conjurers_catalyst=23.6,item_giant_maul=16.3,item_prophets_pendulum=12.7,item_rattlecage=8.0,item_enchanters_bauble=6.3,item_idol_of_screeauk=6.1},
                [5]={item_fallen_sky=26.9,item_desolator_2=23.1,item_demonicon=11.5,item_minotaur_horn=7.7,item_heavy_blade=7.7,item_dezun_bloodrite=7.7},
            },
            enhancement={
                [1]={item_enhancement_quickened=35.1,item_enhancement_alert=32.9,item_enhancement_brawny=24.2},
                [2]={item_enhancement_alert=47.9,item_enhancement_brawny=25.2,item_enhancement_quickened=16.7},
                [3]={item_enhancement_alert=56.3,item_enhancement_brawny=21.7,item_enhancement_quickened=11.1},
                [4]={item_enhancement_alert=68.4,item_enhancement_timeless=11.8,item_enhancement_quickened=10.8},
                [5]={item_enhancement_audacious=30.8,item_enhancement_timeless=26.9,item_enhancement_evolved=19.2},
            },
        },
        pos_3={tier5Profile='attack',
            neutral={
                [1]={item_chipped_vest=17.9,item_duelist_gloves=13.9,item_possessed_mask=13.7,item_polliwog_charm=8.9,item_dormant_curio=8.6,item_ash_legion_shield=8.3,item_weighted_dice=7.7},
                [2]={item_searing_signet=18.3,item_mana_draught=13.9,item_essence_ring=13.5,item_poor_mans_shield=12.6,item_pogo_stick=9.8,item_crippling_crossbow=6.6,item_defiant_shell=4.4},
                [3]={item_serrated_shiv=23.1,item_cloak_of_flames=21.8,item_gunpowder_gauntlets=13.7,item_partisans_brand=11.3,item_stormcrafter=5.8,item_unrelenting_eye=3.9,item_jidi_pollen_bag=3.8},
                [4]={item_conjurers_catalyst=26.0,item_giant_maul=14.8,item_rattlecage=12.1,item_prophets_pendulum=10.5,item_enchanters_bauble=7.3,item_dandelion_amulet=6.3},
                [5]={item_fallen_sky=26.9,item_desolator_2=19.2,item_spider_legs=15.4,item_minotaur_horn=15.4,item_heavy_blade=7.7,item_demonicon=3.8,item_dezun_bloodrite=3.8},
            },
            enhancement={
                [1]={item_enhancement_alert=32.6,item_enhancement_quickened=27.1,item_enhancement_brawny=25.4},
                [2]={item_enhancement_alert=46.6,item_enhancement_brawny=29.3,item_enhancement_quickened=13.3},
                [3]={item_enhancement_alert=51.7,item_enhancement_brawny=28.8,item_enhancement_quickened=9.8},
                [4]={item_enhancement_alert=60.6,item_enhancement_quickened=14.4,item_enhancement_brawny=12.6},
                [5]={item_enhancement_audacious=30.8,item_enhancement_timeless=23.1,item_enhancement_evolved=19.2},
            },
        },
    },
}
