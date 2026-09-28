-- D2PT 7.41f: https://dota2protracker.com/hero/Arc%20Warden?section=builds
-- Retrieved 2026-09-28. Overview: last 8 days; build: Sep 15-28, updated Sep 28.
return {
    patch='7.41f', updated='2026-09-28', defaultRole='pos_2',
    roles={
        pos_1={matches=101,winRate=46.5,skipped=true},
        -- Reviewed baseline 30 + D2PT mid rating 45.
        pos_2={matches=1941,winRate=51.7,rating=45,weight=75,buildMatches=2913},
        pos_3={matches=6,winRate=100.0,skipped=true},
        pos_4={matches=42,winRate=26.2,skipped=true},
        pos_5={matches=41,winRate=41.5,skipped=true},
    },
    neutrals={pos_2={tier5Profile='attack',
        neutral={
            [1]={item_possessed_mask=19.7,item_duelist_gloves=18.6,item_dormant_curio=13.9,item_weighted_dice=13.4,item_ash_legion_shield=6.8,item_chipped_vest=6.2,item_stonefeather_satchel=6.1},
            [2]={item_searing_signet=20.6,item_mana_draught=10.6,item_crippling_crossbow=10.5,item_pogo_stick=8.5,item_defiant_shell=8.4,item_essence_ring=6.6},
            [3]={item_serrated_shiv=37.0,item_gunpowder_gauntlets=25.9,item_partisans_brand=4.3,item_cloak_of_flames=3.7,item_stormcrafter=2.9},
            [4]={item_giant_maul=27.3,item_conjurers_catalyst=18.3,item_flayers_bota=11.8,item_enchanters_bauble=10.7,item_prophets_pendulum=7.1},
            -- Sparse observations rank suitable candidates; retained T4 Bauble is excluded.
            [5]={item_desolator_2=33.3,item_fallen_sky=11.8,item_divine_regalia=9.8,item_demonicon=7.8,item_riftshadow_prism=7.8,item_minotaur_horn=5.9},
        },
        enhancement={
            [1]={item_enhancement_alert=62.3,item_enhancement_quickened=24.2,item_enhancement_mystical=12.0},
            [2]={item_enhancement_alert=80.9,item_enhancement_quickened=10.2,item_enhancement_mystical=5.8},
            [3]={item_enhancement_alert=89.6,item_enhancement_quickened=5.6,item_enhancement_mystical=2.8},
            [4]={item_enhancement_alert=94.9,item_enhancement_timeless=2.7,item_enhancement_quickened=1.2},
            -- Manic remains recorded; the shared attack suitability profile filters it.
            [5]={item_enhancement_evolved=70.6,item_enhancement_manic=19.6,item_enhancement_fleetfooted=5.9},
        },
    }},
}
