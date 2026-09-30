-- Carry only; other roles below threshold. Header 2794; role rows 2790.
return {
    patch='7.41f', updated='2026-09-30', defaultRole='pos_1',
    source='https://dota2protracker.com/hero/Morphling?section=builds',
    overviewWindow='last 8 days, 7000+', buildWindow='2026-09-16 to 2026-09-30', buildUpdated='2026-09-30',
    roles={
        pos_1={matches=2745,winRate=46.8,rating=31,weight=61,buildMatches=5118,buildWinRate=49,skillMatches=244,openingMatches=1384,openingObserved=5118},
        pos_2={matches=31,winRate=48.4,skipped=true},
        pos_3={matches=4,winRate=25,skipped=true},
        pos_4={matches=5,winRate=40,skipped=true},
        pos_5={matches=5,winRate=0,skipped=true},
    },
    -- Current-tier observations; T5 uses reviewed suitability.
    neutrals={
        pos_1={tier5Profile='attack',
            neutral={
                [1]={item_possessed_mask=25.1,item_weighted_dice=17.9,item_duelist_gloves=13.3,item_dormant_curio=9.2,item_occult_bracelet=9.2,item_chipped_vest=8.2,item_stonefeather_satchel=4.8},
                [2]={item_mana_draught=26.5,item_defiant_shell=15.9,item_poor_mans_shield=7.7,item_crippling_crossbow=6.5,item_pogo_stick=6},
                [3]={item_serrated_shiv=37.6,item_gunpowder_gauntlets=26.6,item_cloak_of_flames=6.1,item_unrelenting_eye=3.9},
                [4]={item_giant_maul=30.5,item_flayers_bota=22.9,item_prophets_pendulum=10,item_enchanters_bauble=9.8,item_dandelion_amulet=3},
                [5]={item_desolator_2=22.2,item_minotaur_horn=18.5,item_fallen_sky=16.7,item_riftshadow_prism=16.7,item_divine_regalia=11.1,item_heavy_blade=3.7},
            },
            enhancement={
                [1]={item_enhancement_alert=60.5,item_enhancement_brawny=23.5,item_enhancement_quickened=12.7},
                [2]={item_enhancement_alert=67.6,item_enhancement_nimble=18,item_enhancement_brawny=7.5},
                [3]={item_enhancement_alert=76.4,item_enhancement_nimble=15.1,item_enhancement_brawny=4.4},
                [4]={item_enhancement_alert=94.1,item_enhancement_nimble=2.8,item_enhancement_quickened=2.2},
                [5]={item_enhancement_evolved=44.4,item_enhancement_audacious=38.9,item_enhancement_vampiric=11.1},
            },
        },
    },
}
