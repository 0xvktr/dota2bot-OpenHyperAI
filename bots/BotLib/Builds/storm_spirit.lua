-- Skipped roles use mid; Parasma consumes Witch Blade.
return {
    patch='7.41f', updated='2026-09-30', defaultRole='pos_2',
    source='https://dota2protracker.com/hero/Storm%20Spirit?section=builds',
    overviewWindow='last 8 days, 7000+', buildWindow='2026-09-16 to 2026-09-30', buildUpdated='2026-09-30',
    roles={
        pos_1={matches=77,winRate=46.8,skipped=true},
        pos_2={matches=3371,winRate=47.6,rating=36,weight=66,buildMatches=6011,buildWinRate=48.0,skillMatches=1642,openingMatches=2740,openingObserved=6007},
        pos_3={matches=23,winRate=47.8,skipped=true},
        pos_4={matches=5,winRate=0.0,skipped=true},
        pos_5={matches=7,winRate=42.9,skipped=true},
    },
    -- Current-tier observations only; sparse T5 picks use reviewed suitability.
    neutrals={
        pos_2={tier5Profile='caster',
            neutral={
                [1]={item_occult_bracelet=19.1,item_duelist_gloves=18.8,item_dormant_curio=17.2,item_weighted_dice=9.5,item_polliwog_charm=8.7,item_possessed_mask=8.2,item_foragers_kit=4.6},
                [2]={item_mana_draught=35.6,item_searing_signet=29.6,item_essence_ring=11.4,item_crippling_crossbow=4.0,item_pogo_stick=2.7,item_defiant_shell=2.7},
                [3]={item_gunpowder_gauntlets=20.7,item_spellslinger=17.3,item_partisans_brand=12.0,item_serrated_shiv=9.9,item_stormcrafter=6.1},
                [4]={item_conjurers_catalyst=42.5,item_enchanters_bauble=14.6,item_giant_maul=9.0,item_prophets_pendulum=6.3,item_dandelion_amulet=4.9},
                [5]={item_desolator_2=20.3,item_divine_regalia=17.7,item_dezun_bloodrite=10.1,item_harmonizer=10.1,item_fallen_sky=7.6,item_minotaur_horn=5.1},
            },
            enhancement={
                [1]={item_enhancement_mystical=91.7,item_enhancement_quickened=3.8,item_enhancement_tough=2.3},
                [2]={item_enhancement_mystical=91.4,item_enhancement_quickened=3.3,item_enhancement_greedy=2.7},
                [3]={item_enhancement_mystical=91.1,item_enhancement_tough=4.1,item_enhancement_quickened=3.0},
                [4]={item_enhancement_mystical=76.0,item_enhancement_timeless=22.2,item_enhancement_quickened=1.0},
                [5]={item_enhancement_timeless=83.5,item_enhancement_evolved=11.4,item_enhancement_vampiric=3.8},
            },
        },
    },
}
