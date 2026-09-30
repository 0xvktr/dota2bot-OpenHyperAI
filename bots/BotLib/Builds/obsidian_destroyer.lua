-- Header 9502; role rows 9481. Mid only; forced picks use mid.
return {
    patch='7.41f', updated='2026-09-30', defaultRole='pos_2',
    source='https://dota2protracker.com/hero/Outworld%20Destroyer?section=builds',
    overviewWindow='last 8 days, 7000+', buildWindow='2026-09-16 to 2026-09-30', buildUpdated='2026-09-30',
    roles={
        pos_1={matches=180,winRate=48.9,skipped=true},
        pos_2={matches=8985,winRate=53.7,rating=97,weight=100,buildMatches=14906,buildWinRate=54,skillMatches=6546,openingMatches=2027,openingObserved=14900},
        pos_3={matches=195,winRate=56.4,skipped=true},
        pos_4={matches=74,winRate=37.8,skipped=true},
        pos_5={matches=47,winRate=46.8,skipped=true},
    },
    -- Current-tier observations; T5 uses reviewed suitability.
    neutrals={
        pos_2={tier5Profile='attack',
            neutral={
                [1]={item_duelist_gloves=23,item_dormant_curio=14.9,item_possessed_mask=10.8,item_polliwog_charm=10.5,item_stonefeather_satchel=9.6,item_ash_legion_shield=7.8,item_kobold_cup=7.8},
                [2]={item_essence_ring=23.7,item_pogo_stick=21.7,item_searing_signet=17.3,item_defiant_shell=7.2,item_crippling_crossbow=6.2},
                [3]={item_gunpowder_gauntlets=23.8,item_serrated_shiv=19.7,item_partisans_brand=15.9,item_psychic_headband=5.9,item_stormcrafter=4.7},
                [4]={item_conjurers_catalyst=32,item_giant_maul=13.7,item_enchanters_bauble=12.6,item_prophets_pendulum=9.8,item_dandelion_amulet=6.7,item_flayers_bota=6.1,item_idol_of_screeauk=4},
                [5]={item_divine_regalia=23.8,item_spider_legs=14.3,item_minotaur_horn=13.2,item_desolator_2=11.6,item_fallen_sky=11.6,item_heavy_blade=6.9},
            },
            enhancement={
                [1]={item_enhancement_quickened=88.6,item_enhancement_vital=9.2,item_enhancement_tough=1.5},
                [2]={item_enhancement_quickened=81.5,item_enhancement_greedy=13.2,item_enhancement_mystical=3},
                [3]={item_enhancement_quickened=82.3,item_enhancement_greedy=11.3,item_enhancement_tough=3},
                [4]={item_enhancement_quickened=76.8,item_enhancement_timeless=20,item_enhancement_mystical=1.8},
                [5]={item_enhancement_evolved=34.4,item_enhancement_timeless=31.7,item_enhancement_fleetfooted=23.3},
            },
        },
    },
}
