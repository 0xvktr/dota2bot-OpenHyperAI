-- Carry only by request; header 2660, role rows 2652. Forced picks use carry.
return {
    patch='7.41f', updated='2026-09-30', defaultRole='pos_1',
    source='https://dota2protracker.com/hero/Lone%20Druid?role=carry&section=builds',
    ownershipSource='https://dotacoach.gg/en/heroes/lone-druid/builds',
    overviewWindow='last 8 days, 7000+', buildWindow='2026-09-16 to 2026-09-30', buildUpdated='2026-09-30',
    roles={
        pos_1={matches=1956,winRate=49.9,rating=44,weight=74,buildMatches=3402,buildWinRate=51,skillMatches=483,openingMatches=421,openingObserved=3398},
        pos_2={matches=483,winRate=50.9,rating=38,skipped=true},
        pos_3={matches=174,winRate=47.7,rating=33,skipped=true},
        pos_4={matches=16,winRate=43.8,skipped=true},
        pos_5={matches=23,winRate=21.7,skipped=true},
    },
    -- D2PT combines inventories; DotaCoach labels the bear's progression.
    itemOwnership={
        bearItems={item_blight_stone=true,item_power_treads=true,item_maelstrom=true,item_mjollnir=true,item_ultimate_scepter=true,item_invis_sword=true,item_silver_edge=true,item_black_king_bar=true,item_butterfly=true},
        heroItems={item_branches=true,item_faerie_fire=true,item_magic_wand=true,item_boots=true,item_aghanims_shard=true,item_glimmer_cape=true},
    },
    -- Standard hero distributors; retained lower-tier picks excluded.
    neutrals={pos_1={tier5Profile='attack',
        neutral={
            [1]={item_duelist_gloves=19.8,item_weighted_dice=16.6,item_possessed_mask=15.5,item_chipped_vest=15.3,item_dagger_of_ristul=10.1,item_dormant_curio=8.7,item_stonefeather_satchel=5.2},
            [2]={item_defiant_shell=22.7,item_poor_mans_shield=12.1,item_crippling_crossbow=11.1,item_medallion_of_courage=9.9},
            [3]={item_serrated_shiv=34.4,item_gunpowder_gauntlets=26.6,item_cloak_of_flames=17.5,item_unrelenting_eye=4.1},
            [4]={item_giant_maul=30.3,item_flayers_bota=22.4,item_enchanters_bauble=8.9,item_prophets_pendulum=6.2,item_rattlecage=3.3},
            [5]={item_desolator_2=42.9,item_minotaur_horn=16.3,item_fallen_sky=10.2,item_divine_regalia=8.2,item_heavy_blade=6.1,item_demonicon=4.1,item_riftshadow_prism=4.1},
        },
        enhancement={
            [1]={item_enhancement_alert=81.5,item_enhancement_quickened=15.5,item_enhancement_brawny=2.8},
            [2]={item_enhancement_alert=80.3,item_enhancement_nimble=15.1,item_enhancement_quickened=3.2},
            [3]={item_enhancement_alert=85,item_enhancement_nimble=12.6,item_enhancement_quickened=2},
            [4]={item_enhancement_alert=96.7,item_enhancement_quickened=1.7,item_enhancement_nimble=1.5},
            [5]={item_enhancement_audacious=69.4,item_enhancement_evolved=26.5,item_enhancement_fleetfooted=4.1},
        },
    }},
}
