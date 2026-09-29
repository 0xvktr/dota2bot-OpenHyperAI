-- Retrieved 2026-09-30. Overview: last 8 days, 7000+; builds: Sep 15-29, updated Sep 29.
-- Role counts sum to 1700; overview reports 1703.
return {
    patch='7.41f', updated='2026-09-30', defaultRole='pos_1',
    source='https://dota2protracker.com/hero/Drow%20Ranger?section=builds&role=carry',
    roles={
        pos_1={matches=1674,winRate=46.5,rating=32,weight=59,buildMatches=3074,buildWinRate=46,skillMatches=571,openingMatches=603,openingObserved=3074},
        pos_2={matches=14,winRate=42.9,skipped=true},
        pos_3={matches=1,winRate=100,skipped=true},
        pos_4={matches=2,winRate=50,skipped=true},
        pos_5={matches=9,winRate=44.4,skipped=true},
    },
    -- Current-tier choices only; exclude lower-tier items retained in later inventories.
    -- Sparse T5 observations use the reviewed attack profile, never win-rate ranking.
    neutrals={
        pos_1={tier5Profile='attack',
            neutral={
                [1]={item_possessed_mask=25.7,item_duelist_gloves=16.3,item_weighted_dice=15.3,item_dormant_curio=10,item_polliwog_charm=8.5,item_occult_bracelet=5.5,item_stonefeather_satchel=4.7},
                [2]={item_mana_draught=28.3,item_pogo_stick=12.6,item_defiant_shell=10.5,item_poor_mans_shield=7.5,item_essence_ring=5.5},
                [3]={item_serrated_shiv=38.6,item_gunpowder_gauntlets=24.8,item_unrelenting_eye=4.4,item_psychic_headband=4.2,item_spellslinger=2.8},
                [4]={item_giant_maul=32.2,item_flayers_bota=19.3,item_enchanters_bauble=9.3,item_prophets_pendulum=7.1,item_conjurers_catalyst=3.9},
                [5]={item_desolator_2=32.2,item_divine_regalia=18.6,item_riftshadow_prism=16.9,item_spider_legs=10.2,item_fallen_sky=6.8,item_minotaur_horn=1.7},
            },
            enhancement={
                [1]={item_enhancement_alert=71.3,item_enhancement_quickened=15.7,item_enhancement_brawny=7.7},
                [2]={item_enhancement_alert=74.9,item_enhancement_nimble=13.7,item_enhancement_quickened=7.4},
                [3]={item_enhancement_alert=81.4,item_enhancement_nimble=11.4,item_enhancement_quickened=3.9},
                [4]={item_enhancement_alert=97.4,item_enhancement_quickened=1.2,item_enhancement_nimble=0.7},
                [5]={item_enhancement_evolved=44.1,item_enhancement_fleetfooted=32.2,item_enhancement_audacious=16.9},
            },
        },
    },
}
