-- Skipped roles use pos 1; forced cores omit wards.
return {
    patch='7.41f', updated='2026-09-30', defaultRole='pos_1',
    source='https://dota2protracker.com/hero/Ursa?section=builds',
    overviewWindow='last 8 days, 7000+', buildWindow='2026-09-16 to 2026-09-30', buildUpdated='2026-09-30',
    roles={
        pos_1={matches=2568,winRate=52.2,rating=58,weight=88,buildMatches=4630,buildWinRate=52.0,skillMatches=2126,openingMatches=1552,openingObserved=4628},
        pos_2={matches=78,winRate=48.7,skipped=true},
        pos_3={matches=114,winRate=56.1,skipped=true},
        pos_4={matches=4,winRate=0.0,skipped=true},
        pos_5={matches=10,winRate=20.0,skipped=true},
    },
    -- Current-tier picks only; sparse T5 uses reviewed suitability.
    neutrals={
        pos_1={tier5Profile='attack',
            neutral={
                [1]={item_possessed_mask=23.8,item_duelist_gloves=13.7,item_chipped_vest=13.6,item_weighted_dice=12.0,item_dormant_curio=7.7,item_occult_bracelet=6.3,item_stonefeather_satchel=6.0},
                [2]={item_pogo_stick=15.5,item_defiant_shell=14.8,item_mana_draught=10.7,item_poor_mans_shield=10.7,item_crippling_crossbow=10.7,item_medallion_of_courage=8.2},
                [3]={item_serrated_shiv=39.0,item_gunpowder_gauntlets=23.9,item_cloak_of_flames=9.4,item_unrelenting_eye=6.6,item_stormcrafter=3.0},
                [4]={item_giant_maul=33.3,item_flayers_bota=12.9,item_prophets_pendulum=11.2,item_enchanters_bauble=6.0,item_idol_of_screeauk=3.6},
                [5]={item_desolator_2=32.9,item_minotaur_horn=19.2,item_heavy_blade=15.1,item_divine_regalia=12.3,item_spider_legs=6.8,item_fallen_sky=5.5},
            },
            enhancement={
                [1]={item_enhancement_alert=51.8,item_enhancement_quickened=31.3,item_enhancement_brawny=10.7},
                [2]={item_enhancement_alert=55.7,item_enhancement_nimble=19.6,item_enhancement_quickened=14.4},
                [3]={item_enhancement_alert=59.5,item_enhancement_nimble=21.5,item_enhancement_quickened=9.5},
                [4]={item_enhancement_alert=75.6,item_enhancement_quickened=10.2,item_enhancement_nimble=8.1},
                [5]={item_enhancement_fleetfooted=32.9,item_enhancement_evolved=26.0,item_enhancement_audacious=20.5},
            },
        },
    },
}
