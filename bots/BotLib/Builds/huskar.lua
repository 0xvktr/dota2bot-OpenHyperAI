-- D2PT 7.41f; counts sum to 2350, header 2353. Mid only; forced picks use mid.
return {
    patch='7.41f',
    updated='2026-09-30',
    defaultRole='pos_2',
    source='https://dota2protracker.com/hero/Huskar?section=builds',
    overviewWindow='last 8 days, 7000+',
    buildWindow='2026-09-15 to 2026-09-29',
    buildUpdated='2026-09-29',
    roles={
        pos_1={matches=79,winRate=45.6,skipped=true},
        pos_2={matches=1734,winRate=48.6,rating=44,weight=71,buildMatches=2841,buildWinRate=48,skillMatches=216,openingMatches=421,openingObserved=2840},
        pos_3={matches=406,winRate=39.9,skipped=true},
        pos_4={matches=65,winRate=58.5,skipped=true},
        pos_5={matches=66,winRate=36.4,skipped=true},
    },
    neutrals={
        pos_2={tier5Profile='attack',
            neutral={
                [1]={item_possessed_mask=24.8,item_ash_legion_shield=15.9,item_duelist_gloves=11.2,item_chipped_vest=9.1,item_dormant_curio=8.5,item_weighted_dice=7.9,item_stonefeather_satchel=6.8},
                [2]={item_essence_ring=25.7,item_poor_mans_shield=12.6,item_pogo_stick=10.8,item_crippling_crossbow=7.2,item_searing_signet=6.9,item_defiant_shell=6.8},
                [3]={item_serrated_shiv=27.8,item_cloak_of_flames=17.3,item_gunpowder_gauntlets=16.3,item_unrelenting_eye=7.5,item_partisans_brand=6.4},
                [4]={item_prophets_pendulum=26.1,item_giant_maul=13.2,item_rattlecage=11.9,item_idol_of_screeauk=10.7,item_conjurers_catalyst=8.8,item_flayers_bota=7.6,item_enchanters_bauble=7.5},
                [5]={item_minotaur_horn=23.3,item_desolator_2=20,item_fallen_sky=16.7,item_spider_legs=13.3,item_demonicon=10,item_divine_regalia=6.7,item_riftshadow_prism=6.7},
            },
            enhancement={
                [1]={item_enhancement_quickened=43.6,item_enhancement_brawny=32.7,item_enhancement_tough=18.6},
                [2]={item_enhancement_tough=42.6,item_enhancement_crude=30.4,item_enhancement_brawny=20.4},
                [3]={item_enhancement_tough=51.6,item_enhancement_crude=31.9,item_enhancement_brawny=13.4},
                [4]={item_enhancement_tough=39.3,item_enhancement_crude=31,item_enhancement_brawny=13.8},
                [5]={item_enhancement_evolved=63.3,item_enhancement_timeless=13.3,item_enhancement_hulking=13.3},
            },
        },
    },
}
