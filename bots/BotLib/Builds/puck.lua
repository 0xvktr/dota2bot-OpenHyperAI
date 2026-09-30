-- Skipped roles use mid; Parasma consumes Witch Blade.
return {
    patch='7.41f', updated='2026-09-30', defaultRole='pos_2',
    source='https://dota2protracker.com/hero/Puck?section=builds',
    overviewWindow='last 8 days, 7000+', buildWindow='2026-09-16 to 2026-09-30', buildUpdated='2026-09-30',
    roles={
        pos_1={matches=9,winRate=44.4,skipped=true},
        pos_2={matches=2870,winRate=51.5,rating=60,weight=90,buildMatches=5291,buildWinRate=51.0,skillMatches=4227,openingMatches=2205,openingObserved=5289},
        pos_3={matches=15,winRate=40.0,skipped=true},
        pos_4={matches=14,winRate=35.7,skipped=true},
        pos_5={matches=11,winRate=27.3,skipped=true},
    },
    -- Current-tier observations only; sparse T5 picks use reviewed suitability.
    neutrals={
        pos_2={tier5Profile='caster',
            neutral={
                [1]={item_duelist_gloves=23.7,item_dormant_curio=16.8,item_possessed_mask=14.0,item_weighted_dice=11.3,item_occult_bracelet=8.7,item_polliwog_charm=7.9,item_ash_legion_shield=5.8},
                [2]={item_searing_signet=36.9,item_mana_draught=18.4,item_essence_ring=14.0,item_crippling_crossbow=7.3,item_pogo_stick=5.7},
                [3]={item_gunpowder_gauntlets=29.9,item_serrated_shiv=16.0,item_partisans_brand=15.0,item_stormcrafter=7.3,item_psychic_headband=4.9,item_cloak_of_flames=4.6},
                [4]={item_conjurers_catalyst=41.1,item_giant_maul=14.5,item_enchanters_bauble=12.1,item_prophets_pendulum=5.4,item_dandelion_amulet=4.4,item_flayers_bota=3.7},
                [5]={item_desolator_2=31.5,item_fallen_sky=13.0,item_minotaur_horn=9.3,item_dezun_bloodrite=9.3,item_demonicon=5.6},
            },
            enhancement={
                [1]={item_enhancement_mystical=71.8,item_enhancement_tough=21.6,item_enhancement_quickened=5.2},
                [2]={item_enhancement_mystical=69.5,item_enhancement_tough=16.3,item_enhancement_keen_eyed=8.8},
                [3]={item_enhancement_mystical=56.8,item_enhancement_tough=28.0,item_enhancement_keen_eyed=11.0},
                [4]={item_enhancement_timeless=74.6,item_enhancement_tough=13.1,item_enhancement_keen_eyed=5.3},
                [5]={item_enhancement_timeless=51.9,item_enhancement_feverish=37.0,item_enhancement_fleetfooted=7.4},
            },
        },
    },
}
