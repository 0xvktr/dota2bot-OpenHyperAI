-- Skipped roles use pos 1; forced cores omit wards.
return {
    patch='7.41f', updated='2026-09-30', defaultRole='pos_1',
    source='https://dota2protracker.com/hero/Troll%20Warlord?section=builds',
    overviewWindow='last 8 days, 7000+', buildWindow='2026-09-16 to 2026-09-30', buildUpdated='2026-09-30',
    roles={
        pos_1={matches=760,winRate=52.1,rating=45,weight=58,buildMatches=1189,buildWinRate=54.0,skillMatches=185,openingMatches=339,openingObserved=1189},
        pos_2={matches=33,winRate=54.5,skipped=true},
        pos_3={matches=24,winRate=58.3,skipped=true},
        pos_4={matches=5,winRate=80.0,skipped=true},
        pos_5={matches=17,winRate=41.2,skipped=true},
    },
    -- Current-tier picks only; sparse T5 uses reviewed suitability.
    neutrals={
        pos_1={tier5Profile='attack',
            neutral={
                [1]={item_possessed_mask=25.0,item_duelist_gloves=14.8,item_weighted_dice=14.6,item_chipped_vest=12.2,item_dormant_curio=7.4,item_dagger_of_ristul=6.1,item_occult_bracelet=5.6},
                [2]={item_defiant_shell=17.3,item_poor_mans_shield=15.4,item_crippling_crossbow=11.5,item_pogo_stick=9.2,item_medallion_of_courage=7.2},
                [3]={item_serrated_shiv=40.2,item_gunpowder_gauntlets=21.9,item_cloak_of_flames=10.6,item_unrelenting_eye=6.4,item_stormcrafter=2.5},
                [4]={item_giant_maul=31.7,item_flayers_bota=13.7,item_prophets_pendulum=9.9,item_enchanters_bauble=6.9,item_rattlecage=4.7},
                [5]={item_minotaur_horn=45.5,item_desolator_2=36.4,item_heavy_blade=9.1,item_divine_regalia=9.1},
            },
            enhancement={
                [1]={item_enhancement_alert=62.4,item_enhancement_quickened=22.9,item_enhancement_brawny=10.3},
                [2]={item_enhancement_alert=62.2,item_enhancement_nimble=26.7,item_enhancement_quickened=7.0},
                [3]={item_enhancement_alert=66.1,item_enhancement_nimble=27.3,item_enhancement_brawny=3.9},
                [4]={item_enhancement_alert=87.2,item_enhancement_nimble=6.6,item_enhancement_quickened=3.5},
                [5]={item_enhancement_audacious=63.6,item_enhancement_fleetfooted=18.2,item_enhancement_vampiric=9.1},
            },
        },
    },
}
