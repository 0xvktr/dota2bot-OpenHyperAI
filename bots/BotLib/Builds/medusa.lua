-- Carry only; other roles below threshold.
return {
    patch='7.41f', updated='2026-09-30', defaultRole='pos_1',
    source='https://dota2protracker.com/hero/Medusa?section=builds',
    overviewWindow='last 8 days, 7000+', buildWindow='2026-09-16 to 2026-09-30', buildUpdated='2026-09-30',
    roles={
        pos_1={matches=651,winRate=46.7,rating=32,weight=48,buildMatches=1191,buildWinRate=46,skillMatches=332,openingMatches=316,openingObserved=1190},
        pos_2={matches=15,winRate=33.3,skipped=true},
        pos_3={matches=9,winRate=55.6,skipped=true},
        pos_4={matches=1,winRate=0,skipped=true},
        pos_5={matches=6,winRate=50,skipped=true},
    },
    -- Current-tier observations; T5 uses reviewed suitability.
    neutrals={
        pos_1={tier5Profile='attack',
            neutral={
                [1]={item_weighted_dice=20.5,item_occult_bracelet=18.6,item_duelist_gloves=14.8,item_dormant_curio=12.4,item_stonefeather_satchel=9.2,item_dagger_of_ristul=7.6,item_chipped_vest=7.1},
                [2]={item_mana_draught=27,item_pogo_stick=12,item_defiant_shell=11.6,item_searing_signet=5.1},
                [3]={item_serrated_shiv=36.8,item_gunpowder_gauntlets=24.1,item_cloak_of_flames=4,item_unrelenting_eye=3.6,item_stormcrafter=3.3},
                [4]={item_giant_maul=26.6,item_flayers_bota=22.5,item_enchanters_bauble=12.1,item_conjurers_catalyst=5.1,item_idol_of_screeauk=3.7},
                [5]={item_desolator_2=51.5,item_divine_regalia=24.2,item_spider_legs=9.1,item_fallen_sky=3,item_minotaur_horn=3,item_riftshadow_prism=3},
            },
            enhancement={
                [1]={item_enhancement_alert=62.4,item_enhancement_quickened=36.4,item_enhancement_brawny=1.2},
                [2]={item_enhancement_alert=53.8,item_enhancement_quickened=27.3,item_enhancement_nimble=18.6},
                [3]={item_enhancement_alert=61.2,item_enhancement_quickened=20.6,item_enhancement_nimble=18.2},
                [4]={item_enhancement_alert=86.7,item_enhancement_quickened=10.8,item_enhancement_nimble=2.2},
                [5]={item_enhancement_audacious=54.5,item_enhancement_fleetfooted=33.3,item_enhancement_evolved=12.1},
            },
        },
    },
}
