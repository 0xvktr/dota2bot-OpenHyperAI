-- Header 3362; role rows 3353. Mid only; other roles deferred and forced picks use mid.
return {
    patch='7.41f', updated='2026-09-30', defaultRole='pos_2',
    source='https://dota2protracker.com/hero/Queen%20of%20Pain?section=builds',
    overviewWindow='last 8 days, 7000+', buildWindow='2026-09-16 to 2026-09-30', buildUpdated='2026-09-30',
    roles={
        pos_1={matches=44,winRate=45.5,skipped=true},
        pos_2={matches=2812,winRate=48.4,rating=38,weight=68,buildMatches=5135,buildWinRate=48.0,skillMatches=1543,openingMatches=2240,openingObserved=5135},
        pos_3={matches=190,winRate=43.2,rating=28,skipped=true},
        pos_4={matches=224,winRate=45.1,rating=26,skipped=true},
        pos_5={matches=83,winRate=50.6,rating=33,skipped=true},
    },
    -- Current-tier pick frequency; T5 uses reviewed suitability.
    neutrals={
        pos_2={tier5Profile='caster',
            neutral={
                [1]={item_dormant_curio=18.1,item_duelist_gloves=13.9,item_occult_bracelet=13.2,item_chipped_vest=11.5,item_polliwog_charm=9.2,item_possessed_mask=8.9,item_weighted_dice=8.2},
                [2]={item_searing_signet=36.3,item_mana_draught=21.7,item_essence_ring=17.8,item_pogo_stick=3.9,item_crippling_crossbow=3.6,item_poor_mans_shield=3.0},
                [3]={item_partisans_brand=19.1,item_cloak_of_flames=13.3,item_spellslinger=10.8,item_stormcrafter=9.1,item_gunpowder_gauntlets=9.1,item_serrated_shiv=3.3},
                [4]={item_conjurers_catalyst=42.5,item_enchanters_bauble=14.0,item_prophets_pendulum=12.0,item_dandelion_amulet=6.1,item_rattlecage=5.2},
                [5]={item_harmonizer=22.0,item_dezun_bloodrite=13.6,item_divine_regalia=11.9,item_fallen_sky=6.8,item_minotaur_horn=5.1,item_desolator_2=3.4},
            },
            enhancement={
                [1]={item_enhancement_mystical=85.8,item_enhancement_quickened=5.9,item_enhancement_tough=4.8},
                [2]={item_enhancement_mystical=78.1,item_enhancement_greedy=8.9,item_enhancement_keen_eyed=5.1},
                [3]={item_enhancement_mystical=69.4,item_enhancement_keen_eyed=10.9,item_enhancement_greedy=8.8},
                [4]={item_enhancement_timeless=68.4,item_enhancement_mystical=18.9,item_enhancement_keen_eyed=7.0},
                [5]={item_enhancement_timeless=79.7,item_enhancement_feverish=10.2,item_enhancement_vampiric=8.5},
            },
        },
    },
}
