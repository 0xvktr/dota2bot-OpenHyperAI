-- Header 2437; displayed role counts sum to 2434.
-- Carry only; forced picks use carry.
return {
    patch='7.41f', updated='2026-09-30', defaultRole='pos_1',
    source='https://dota2protracker.com/hero/Faceless%20Void?section=builds&role=carry',
    overviewWindow='last 8 days, 7000+', buildWindow='2026-09-15 to 2026-09-29', buildUpdated='2026-09-29',
    roles={
        pos_1={matches=2301,winRate=50.4,rating=42,weight=72,buildMatches=2801,buildWinRate=53,skillMatches=525,openingMatches=710,openingObserved=2800},
        pos_2={matches=22,winRate=45.5,skipped=true},
        pos_3={matches=58,winRate=46.6,skipped=true},
        pos_4={matches=30,winRate=33.3,skipped=true},
        pos_5={matches=23,winRate=39.1,skipped=true},
    },
    -- Current-tier observations only; sparse T5 picks use reviewed attack suitability.
    neutrals={pos_1={tier5Profile='attack',
        neutral={
            [1]={item_possessed_mask=26,item_duelist_gloves=16.4,item_chipped_vest=16.1,item_weighted_dice=14,item_dormant_curio=8.5,item_dagger_of_ristul=5.3,item_polliwog_charm=4.7},
            [2]={item_defiant_shell=25.4,item_poor_mans_shield=18.8,item_medallion_of_courage=7.3,item_essence_ring=6.8},
            [3]={item_serrated_shiv=37.5,item_gunpowder_gauntlets=28,item_cloak_of_flames=12.5,item_unrelenting_eye=3.1,item_stormcrafter=1.8},
            [4]={item_giant_maul=30.7,item_flayers_bota=18,item_prophets_pendulum=11.3,item_enchanters_bauble=7.3,item_idol_of_screeauk=2.4},
            [5]={item_desolator_2=26.7,item_divine_regalia=23.3,item_minotaur_horn=13.3,item_riftshadow_prism=10,item_demonicon=6.7,item_fallen_sky=6.7,item_spider_legs=3.3},
        },
        enhancement={
            [1]={item_enhancement_alert=83.2,item_enhancement_brawny=9,item_enhancement_vital=5.4},
            [2]={item_enhancement_alert=88.9,item_enhancement_brawny=5.9,item_enhancement_nimble=4.1},
            [3]={item_enhancement_alert=91.6,item_enhancement_nimble=4,item_enhancement_brawny=3.9},
            [4]={item_enhancement_alert=96.1,item_enhancement_nimble=1.8,item_enhancement_quickened=1},
            [5]={item_enhancement_audacious=53.3,item_enhancement_evolved=36.7,item_enhancement_fleetfooted=3.3},
        },
    }},
}
