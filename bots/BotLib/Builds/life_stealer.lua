-- D2PT 7.41f; role counts sum to 8241, header 8250. Current-tier picks; reviewed attack T5 profile.
return {
    patch='7.41f',
    updated='2026-09-30',
    defaultRole='pos_1',
    source='https://dota2protracker.com/hero/Lifestealer?section=builds',
    overviewWindow='last 8 days, 7000+',
    buildWindow='2026-09-15 to 2026-09-29',
    buildUpdated='2026-09-29',
    roles={
        pos_1={matches=8163,winRate=49.7,rating=62,weight=92,buildMatches=13348,buildWinRate=51,skillMatches=5227,openingMatches=4376,openingObserved=13347},
        pos_2={matches=9,winRate=55.6,skipped=true},
        pos_3={matches=52,winRate=40.4,skipped=true},
        pos_4={matches=1,winRate=100,skipped=true},
        pos_5={matches=16,winRate=31.3,skipped=true},
    },
    neutrals={
        pos_1={tier5Profile='attack',
            neutral={
                [1]={item_chipped_vest=21.2,item_duelist_gloves=19.7,item_weighted_dice=16.0,item_possessed_mask=13.4,item_dagger_of_ristul=9.6,item_dormant_curio=8.3,item_stonefeather_satchel=4.0},
                [2]={item_defiant_shell=25.9,item_poor_mans_shield=13.3,item_crippling_crossbow=11.0,item_medallion_of_courage=10.8,item_pogo_stick=5.2},
                [3]={item_serrated_shiv=34.6,item_gunpowder_gauntlets=23.4,item_cloak_of_flames=22.6,item_unrelenting_eye=4.2,item_stormcrafter=2.0},
                [4]={item_giant_maul=32.5,item_flayers_bota=17.7,item_prophets_pendulum=12.7,item_rattlecage=5.8,item_enchanters_bauble=4.9},
                [5]={item_desolator_2=41.6,item_divine_regalia=15.1,item_fallen_sky=12.0,item_minotaur_horn=12.0,item_spider_legs=6.6,item_riftshadow_prism=3.0,item_heavy_blade=2.4},
            },
            enhancement={
                [1]={item_enhancement_tough=75.6,item_enhancement_quickened=17.1,item_enhancement_brawny=6.4},
                [2]={item_enhancement_tough=75.1,item_enhancement_quickened=11.6,item_enhancement_crude=9.7},
                [3]={item_enhancement_tough=76.9,item_enhancement_crude=13.0,item_enhancement_quickened=7.3},
                [4]={item_enhancement_tough=69.3,item_enhancement_crude=16.4,item_enhancement_quickened=11.3},
                [5]={item_enhancement_evolved=54.2,item_enhancement_fleetfooted=43.4,item_enhancement_vampiric=1.8},
            },
        },
    },
}
