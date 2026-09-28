-- D2PT 7.41f: https://dota2protracker.com/hero/Anti-Mage
-- Retrieved 2026-09-28. Overview: last 8 days. Build: Sep 15-28 (13 days), updated Sep 28.
-- Role counts sum to 4182; overview reports 4188. Carry-only migration.
return {
    patch='7.41f', updated='2026-09-28', defaultRole='pos_1',
    roles={
        -- Same reviewed baseline: 30 + D2PT carry rating 64.
        pos_1={matches=3915,winRate=51.4,rating=64,weight=94,buildMatches=5923},
        pos_2={matches=141,winRate=48.2,skipped=true},
        pos_3={matches=91,winRate=54.9,skipped=true},
        pos_4={matches=20,winRate=35.0,skipped=true},
        pos_5={matches=15,winRate=20.0,skipped=true},
    },
    neutrals={pos_1={tier5Profile='attack',
        neutral={
            [1]={item_possessed_mask=26.6,item_chipped_vest=19.3,item_duelist_gloves=14.7,item_weighted_dice=12.7,item_polliwog_charm=8.1},
            -- Only current-tier rewards; retained Mask/Dice/Vest are excluded.
            [2]={item_poor_mans_shield=23.9,item_defiant_shell=22.1,item_essence_ring=9.5,item_crippling_crossbow=6.9},
            [3]={item_serrated_shiv=36.5,item_gunpowder_gauntlets=27.0,item_cloak_of_flames=13.3,item_unrelenting_eye=3.0},
            [4]={item_giant_maul=30.5,item_flayers_bota=18.5,item_prophets_pendulum=12.0,item_enchanters_bauble=6.6,item_rattlecage=3.5},
            [5]={item_desolator_2=37.6,item_divine_regalia=16.1,item_minotaur_horn=14.0,item_fallen_sky=12.9,item_riftshadow_prism=6.5,item_heavy_blade=4.3,item_spider_legs=3.2},
        },
        enhancement={
            [1]={item_enhancement_alert=66.1,item_enhancement_brawny=15.6,item_enhancement_vital=15.5},
            [2]={item_enhancement_alert=79.4,item_enhancement_brawny=17.3,item_enhancement_nimble=2.7},
            [3]={item_enhancement_alert=84.5,item_enhancement_brawny=12.4,item_enhancement_nimble=2.6},
            [4]={item_enhancement_alert=92.6,item_enhancement_brawny=3.7,item_enhancement_quickened=2.4},
            -- Vampiric is a retained lower-tier enchantment.
            [5]={item_enhancement_evolved=51.6,item_enhancement_audacious=31.2},
        },
    }},
}
