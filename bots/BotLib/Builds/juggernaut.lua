-- D2PT 7.41f; role counts sum to 7417, header 7430. Current-tier picks; reviewed attack T5 profile.
return {
    patch='7.41f',
    updated='2026-09-30',
    defaultRole='pos_1',
    source='https://dota2protracker.com/hero/Juggernaut?section=builds',
    overviewWindow='last 8 days, 7000+',
    buildWindow='2026-09-15 to 2026-09-29',
    buildUpdated='2026-09-29',
    roles={
        pos_1={matches=7396,winRate=50.9,rating=64,weight=94,buildMatches=11859,buildWinRate=52,skillMatches=3202,openingMatches=4662,openingObserved=11853},
        pos_2={matches=6,winRate=16.7,skipped=true},
        pos_3={matches=8,winRate=25,skipped=true},
        pos_4={matches=3,winRate=100,skipped=true},
        pos_5={matches=4,winRate=25,skipped=true},
    },
    neutrals={
        pos_1={tier5Profile='attack',
            neutral={
                [1]={item_possessed_mask=21.7,item_duelist_gloves=17.8,item_weighted_dice=15.3,item_chipped_vest=14.6,item_dormant_curio=8.0,item_occult_bracelet=5.5,item_dagger_of_ristul=4.7},
                [2]={item_defiant_shell=23.8,item_poor_mans_shield=16.2,item_pogo_stick=10.9,item_medallion_of_courage=8.8,item_crippling_crossbow=6.0},
                [3]={item_serrated_shiv=40.4,item_gunpowder_gauntlets=25.8,item_cloak_of_flames=9.7,item_unrelenting_eye=3.3,item_stormcrafter=2.2},
                [4]={item_giant_maul=30.3,item_flayers_bota=22.6,item_prophets_pendulum=9.5,item_enchanters_bauble=8.7,item_idol_of_screeauk=1.9},
                [5]={item_desolator_2=37.8,item_divine_regalia=16.8,item_riftshadow_prism=9.2,item_minotaur_horn=8.4,item_heavy_blade=7.6,item_fallen_sky=5.0,item_spider_legs=4.2},
            },
            enhancement={
                [1]={item_enhancement_alert=73.7,item_enhancement_quickened=16.3,item_enhancement_brawny=7.6},
                [2]={item_enhancement_alert=77.1,item_enhancement_nimble=14.0,item_enhancement_quickened=5.5},
                [3]={item_enhancement_alert=84.2,item_enhancement_nimble=10.6,item_enhancement_brawny=2.7},
                [4]={item_enhancement_alert=94.3,item_enhancement_nimble=2.9,item_enhancement_quickened=2.0},
                [5]={item_enhancement_evolved=42.9,item_enhancement_audacious=37.0,item_enhancement_fleetfooted=14.3},
            },
        },
    },
}
