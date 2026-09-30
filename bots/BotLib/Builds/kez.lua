-- Carry only by request; eligible mid deferred. Header 3351; role rows 3344.
return {
    patch='7.41f', updated='2026-09-30', defaultRole='pos_1',
    source='https://dota2protracker.com/hero/Kez?section=builds',
    overviewWindow='last 8 days, 7000+', buildWindow='2026-09-16 to 2026-09-30', buildUpdated='2026-09-30',
    roles={
        pos_1={matches=2394,winRate=45.2,rating=27,weight=57,buildMatches=3487,buildWinRate=48,skillMatches=1082,openingMatches=684,openingObserved=3483},
        pos_2={matches=833,winRate=48.6,skipped=true},
        pos_3={matches=102,winRate=45.1,skipped=true},
        pos_4={matches=8,winRate=50,skipped=true},
        pos_5={matches=7,winRate=14.3,skipped=true},
    },
    -- Current-tier observations; T5 uses reviewed suitability.
    neutrals={
        pos_1={tier5Profile='attack',
            neutral={
                [1]={item_possessed_mask=23,item_duelist_gloves=17.2,item_weighted_dice=16.3,item_chipped_vest=12.5,item_dormant_curio=7.7,item_occult_bracelet=5.3,item_dagger_of_ristul=5},
                [2]={item_mana_draught=26.4,item_defiant_shell=15,item_medallion_of_courage=10.9,item_poor_mans_shield=9.2,item_crippling_crossbow=8.1,item_pogo_stick=5.8,item_essence_ring=5.4},
                [3]={item_serrated_shiv=39,item_gunpowder_gauntlets=27.2,item_cloak_of_flames=9.2,item_partisans_brand=4.1,item_spellslinger=3.6,item_unrelenting_eye=2.8},
                [4]={item_giant_maul=33.2,item_flayers_bota=16.2,item_prophets_pendulum=10.4,item_conjurers_catalyst=10.2,item_enchanters_bauble=7.3},
                [5]={item_desolator_2=44.6,item_divine_regalia=20,item_minotaur_horn=7.7,item_spider_legs=6.2,item_demonicon=4.6,item_fallen_sky=4.6},
            },
            enhancement={
                [1]={item_enhancement_alert=64.6,item_enhancement_brawny=19.1,item_enhancement_quickened=11.5},
                [2]={item_enhancement_alert=70,item_enhancement_nimble=16.5,item_enhancement_brawny=9.5},
                [3]={item_enhancement_alert=77,item_enhancement_nimble=14.5,item_enhancement_brawny=5.9},
                [4]={item_enhancement_alert=89.3,item_enhancement_quickened=4.3,item_enhancement_nimble=3.8},
                [5]={item_enhancement_fleetfooted=33.8,item_enhancement_evolved=33.8,item_enhancement_audacious=27.7},
            },
        },
    },
}
