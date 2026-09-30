-- Other positions deferred; forced picks use offlane.
return {
    patch='7.41f', updated='2026-09-30', defaultRole='pos_3',
    source='https://dota2protracker.com/hero/Night%20Stalker?section=builds',
    overviewWindow='last 8 days, 7000+', buildWindow='2026-09-16 to 2026-09-30', buildUpdated='2026-09-30',
    roles={
        pos_1={matches=34,winRate=52.9,skipped=true},
        pos_2={matches=181,winRate=53,skipped=true},
        pos_3={matches=6071,winRate=50.6,rating=79,weight=100,buildMatches=10544,buildWinRate=52,skillMatches=1648,openingMatches=1455,openingObserved=10542},
        pos_4={matches=42,winRate=47.6,skipped=true},
        pos_5={matches=13,winRate=30.8,skipped=true},
    },
    -- Current-tier picks only; sparse T5 data uses reviewed suitability.
    neutrals={
        pos_3={tier5Profile='attack',
            neutral={
                [1]={item_duelist_gloves=23.5,item_chipped_vest=18.7,item_possessed_mask=15,item_weighted_dice=8.2,item_dormant_curio=7.3,item_dagger_of_ristul=7.1,item_occult_bracelet=5.2},
                [2]={item_defiant_shell=20.1,item_medallion_of_courage=14,item_crippling_crossbow=13.8,item_poor_mans_shield=10.7,item_searing_signet=7.1,item_mana_draught=6.6},
                [3]={item_cloak_of_flames=28.8,item_serrated_shiv=25.8,item_gunpowder_gauntlets=24.3,item_unrelenting_eye=4,item_stormcrafter=3.5,item_jidi_pollen_bag=2.9},
                [4]={item_giant_maul=32.3,item_flayers_bota=14.4,item_rattlecage=9.2,item_prophets_pendulum=8.6},
                [5]={item_desolator_2=34.9,item_fallen_sky=23.6,item_minotaur_horn=14.2,item_demonicon=8.5,item_dezun_bloodrite=5.7,item_divine_regalia=5.7},
            },
            enhancement={
                [1]={item_enhancement_tough=59.8,item_enhancement_quickened=17,item_enhancement_brawny=16.2},
                [2]={item_enhancement_tough=75.1,item_enhancement_brawny=11,item_enhancement_quickened=8.1},
                [3]={item_enhancement_tough=78.3,item_enhancement_brawny=9.4,item_enhancement_crude=6.2},
                [4]={item_enhancement_tough=71.2,item_enhancement_quickened=10.9,item_enhancement_brawny=9.7},
                [5]={item_enhancement_evolved=77.4,item_enhancement_fleetfooted=12.3,item_enhancement_vampiric=10.4},
            },
        },
    },
}
