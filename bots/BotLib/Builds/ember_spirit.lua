-- Header 7882; displayed role counts sum to 7863.
-- Mid only; forced picks use mid. Omit the observed core ward.
return {
    patch='7.41f', updated='2026-09-30', defaultRole='pos_2',
    source='https://dota2protracker.com/hero/Ember%20Spirit?section=builds&role=mid',
    overviewWindow='last 8 days, 7000+', buildWindow='2026-09-15 to 2026-09-29', buildUpdated='2026-09-29',
    roles={
        pos_1={matches=54,winRate=40.7,skipped=true},
        pos_2={matches=7652,winRate=50.9,rating=70,weight=100,buildMatches=13429,buildWinRate=51,skillMatches=4835,openingMatches=6266,openingObserved=13423},
        pos_3={matches=91,winRate=48.4,skipped=true},
        pos_4={matches=37,winRate=29.7,skipped=true},
        pos_5={matches=29,winRate=58.6,skipped=true},
    },
    -- Current-tier observations only; sparse T5 picks use reviewed caster suitability.
    neutrals={pos_2={tier5Profile='caster',
        neutral={
            [1]={item_chipped_vest=21.4,item_dormant_curio=12.9,item_duelist_gloves=11.6,item_occult_bracelet=10.8,item_ash_legion_shield=9,item_possessed_mask=8.6,item_weighted_dice=7.2},
            [2]={item_searing_signet=27.4,item_mana_draught=19.8,item_essence_ring=14.6,item_crippling_crossbow=9.5,item_poor_mans_shield=9.2,item_pogo_stick=4.2},
            [3]={item_cloak_of_flames=40,item_gunpowder_gauntlets=16.8,item_partisans_brand=13.3,item_serrated_shiv=6.9,item_stormcrafter=6.5,item_jidi_pollen_bag=5},
            [4]={item_conjurers_catalyst=40.9,item_giant_maul=8.8,item_prophets_pendulum=8.7,item_enchanters_bauble=7.6,item_rattlecage=5.3,item_dandelion_amulet=4.6},
            [5]={item_desolator_2=22.9,item_fallen_sky=18.5,item_divine_regalia=8.9,item_harmonizer=7.6,item_demonicon=7,item_dezun_bloodrite=7},
        },
        enhancement={
            [1]={item_enhancement_brawny=50.5,item_enhancement_quickened=26.3,item_enhancement_alert=19},
            [2]={item_enhancement_brawny=42.8,item_enhancement_quickened=24.9,item_enhancement_alert=17.3},
            [3]={item_enhancement_brawny=43.5,item_enhancement_quickened=22.5,item_enhancement_alert=17.9},
            [4]={item_enhancement_timeless=70.6,item_enhancement_quickened=11,item_enhancement_brawny=8.6},
            [5]={item_enhancement_timeless=73.9,item_enhancement_fleetfooted=10.2,item_enhancement_evolved=8.9},
        },
    }},
}
