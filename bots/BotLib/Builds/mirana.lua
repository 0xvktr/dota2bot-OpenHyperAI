-- Support/hard support; other roles below threshold. Header 10319; role rows 10291.
return {
    patch='7.41f', updated='2026-09-30', defaultRole='pos_4',
    source='https://dota2protracker.com/hero/Mirana?section=builds',
    overviewWindow='last 8 days, 7000+', buildWindow='2026-09-16 to 2026-09-30', buildUpdated='2026-09-30',
    roles={
        pos_1={matches=43,winRate=32.6,skipped=true},
        pos_2={matches=166,winRate=44,skipped=true},
        pos_3={matches=77,winRate=40.3,skipped=true},
        pos_4={matches=5611,winRate=50.6,rating=65,weight=95,buildMatches=10039,buildWinRate=49,skillMatches=2010,openingMatches=798,openingObserved=10032},
        pos_5={matches=4394,winRate=48.6,rating=50,weight=80,buildMatches=7804,buildWinRate=50,skillMatches=1260,openingMatches=540,openingObserved=7799},
    },
    -- Current-tier observations; T5 uses reviewed suitability.
    neutrals={
        pos_4={tier5Profile='support',
            neutral={
                [1]={item_ash_legion_shield=16.2,item_dormant_curio=15.2,item_polliwog_charm=13.3,item_duelist_gloves=10.3,item_kobold_cup=9.4,item_foragers_kit=9.3,item_stonefeather_satchel=7.9},
                [2]={item_searing_signet=31.2,item_mana_draught=18.1,item_essence_ring=15.6,item_pogo_stick=10,item_crippling_crossbow=6.6,item_medallion_of_courage=4.7},
                [3]={item_partisans_brand=18.3,item_gunpowder_gauntlets=9.1,item_psychic_headband=9,item_stormcrafter=8.6,item_serrated_shiv=5.7},
                [4]={item_conjurers_catalyst=41.2,item_enchanters_bauble=15.3,item_dandelion_amulet=10.3,item_prophets_pendulum=9,item_giant_maul=4.4},
                [5]={item_demonicon=19.4,item_fallen_sky=10.5,item_harmonizer=8.1,item_divine_regalia=7.3,item_desolator_2=5.6},
            },
            enhancement={
                [1]={item_enhancement_brawny=40.9,item_enhancement_quickened=35.3,item_enhancement_alert=16.7},
                [2]={item_enhancement_greedy=64.5,item_enhancement_brawny=12.4,item_enhancement_alert=10.9},
                [3]={item_enhancement_greedy=64.5,item_enhancement_brawny=12.2,item_enhancement_alert=12.2},
                [4]={item_enhancement_timeless=76.5,item_enhancement_quickened=9.3,item_enhancement_alert=8.7},
                [5]={item_enhancement_timeless=86.3,item_enhancement_evolved=5.6,item_enhancement_audacious=4},
            },
        },
        pos_5={tier5Profile='support',
            neutral={
                [1]={item_ash_legion_shield=16.8,item_dormant_curio=14.6,item_polliwog_charm=14.3,item_kobold_cup=9.9,item_duelist_gloves=9.6,item_foragers_kit=9.5,item_stonefeather_satchel=8},
                [2]={item_searing_signet=30.7,item_mana_draught=18.2,item_essence_ring=15.5,item_pogo_stick=10,item_crippling_crossbow=6.8,item_medallion_of_courage=6.1},
                [3]={item_partisans_brand=17.9,item_gunpowder_gauntlets=9.2,item_psychic_headband=9,item_stormcrafter=8.1,item_serrated_shiv=5.8,item_spellslinger=5.3},
                [4]={item_conjurers_catalyst=43,item_enchanters_bauble=12.8,item_dandelion_amulet=11.7,item_prophets_pendulum=8.3,item_giant_maul=4.5},
                [5]={item_demonicon=24.1,item_fallen_sky=11.5,item_harmonizer=9.2,item_desolator_2=8,item_dezun_bloodrite=5.7},
            },
            enhancement={
                [1]={item_enhancement_brawny=42.9,item_enhancement_quickened=34.4,item_enhancement_alert=15.9},
                [2]={item_enhancement_greedy=67.8,item_enhancement_brawny=12,item_enhancement_quickened=9.3},
                [3]={item_enhancement_greedy=67.4,item_enhancement_brawny=11.7,item_enhancement_alert=11.5},
                [4]={item_enhancement_timeless=77,item_enhancement_quickened=9.9,item_enhancement_alert=7.6},
                [5]={item_enhancement_timeless=90.8,item_enhancement_fleetfooted=3.4,item_enhancement_evolved=3.4},
            },
        },
    },
}
