-- Header 2667; role rows 2660. Other role samples too small; forced picks use mid.
return {
    patch='7.41f', updated='2026-09-30', defaultRole='pos_2',
    source='https://dota2protracker.com/hero/Tinker?section=builds',
    overviewWindow='last 8 days, 7000+', buildWindow='2026-09-16 to 2026-09-30', buildUpdated='2026-09-30',
    roles={
        pos_1={matches=46,winRate=56.5,skipped=true},
        pos_2={matches=2472,winRate=51.2,rating=65,weight=95,buildMatches=4355,buildWinRate=51.0,skillMatches=660,openingMatches=1360,openingObserved=4355},
        pos_3={matches=36,winRate=58.3,skipped=true},
        pos_4={matches=26,winRate=38.5,skipped=true},
        pos_5={matches=80,winRate=52.5,rating=34,skipped=true},
    },
    -- Current-tier pick frequencies; T5 uses reviewed suitability.
    neutrals={
        pos_2={tier5Profile='caster',
            neutral={
                [1]={item_dormant_curio=24.4,item_weighted_dice=17.0,item_stonefeather_satchel=12.2,item_occult_bracelet=11.5,item_ash_legion_shield=10.3,item_chipped_vest=8.0,item_kobold_cup=6.0},
                [2]={item_searing_signet=23.0,item_pogo_stick=19.8,item_mana_draught=15.5,item_essence_ring=11.4},
                [3]={item_spellslinger=24.7,item_partisans_brand=19.2,item_psychic_headband=7.3},
                [4]={item_conjurers_catalyst=39.6,item_enchanters_bauble=14.9,item_prophets_pendulum=10.5,item_dandelion_amulet=9.2},
                [5]={item_fallen_sky=15.4,item_harmonizer=13.8,item_demonicon=10.8,item_minotaur_horn=10.8,item_dezun_bloodrite=7.7},
            },
            enhancement={
                [1]={item_enhancement_mystical=64.3,item_enhancement_quickened=34.5,item_enhancement_vital=0.6},
                [2]={item_enhancement_greedy=69.2,item_enhancement_keen_eyed=24.8,item_enhancement_mystical=4.9},
                [3]={item_enhancement_greedy=55.1,item_enhancement_keen_eyed=39.8,item_enhancement_mystical=4.3},
                [4]={item_enhancement_keen_eyed=48.3,item_enhancement_timeless=35.9,item_enhancement_mystical=14.4},
                [5]={item_enhancement_timeless=87.7,item_enhancement_feverish=9.2,item_enhancement_vampiric=1.5},
            },
        },
    },
}
