-- D2PT 7.41f: https://dota2protracker.com/hero/Alchemist, retrieved 2026-09-28.
-- Role overview: last 8 days; selected build: Sep 15-27, updated Sep 27.
-- Role counts sum to 723 versus 725 in the header. Carry-only scope is deliberate:
-- other roles have samples, but support/jungle gifting strategies are not implemented.
return {
    patch='7.41f', updated='2026-09-28', defaultRole='pos_1',
    roles={
        pos_1={matches=381,winRate=45.9,rating=31,weight=44,buildMatches=466},
        pos_2={matches=95,winRate=36.8,skipped=true},
        pos_3={matches=83,winRate=32.5,skipped=true},
        pos_4={matches=85,winRate=41.2,skipped=true},
        pos_5={matches=79,winRate=50.6,skipped=true},
    },
    neutrals={pos_1={tier5Profile="attack", -- Pick percentages; retained lower-tier items excluded.
        neutral={
            [1]={item_chipped_vest=25.1,item_weighted_dice=13.9,item_duelist_gloves=12.0,item_possessed_mask=10.3,item_occult_bracelet=9.0},
            [2]={item_defiant_shell=18.4,item_poor_mans_shield=15.0,item_medallion_of_courage=11.1,item_mana_draught=8.9,item_crippling_crossbow=8.2},
            [3]={item_serrated_shiv=29.6,item_cloak_of_flames=26.4,item_gunpowder_gauntlets=20.7,item_unrelenting_eye=5.4,item_stormcrafter=2.2},
            [4]={item_giant_maul=28.9,item_flayers_bota=17.3,item_prophets_pendulum=11.6,item_rattlecage=6.9,item_idol_of_screeauk=5.2},
            -- About six inventories: keep weak pick evidence, ignore win rates.
            [5]={item_desolator_2=33.3,item_fallen_sky=16.7,item_heavy_blade=16.7,item_dezun_bloodrite=16.7,item_divine_regalia=16.7},
        },
        enhancement={
            [1]={item_enhancement_tough=53.4,item_enhancement_quickened=21.0,item_enhancement_brawny=16.3},
            [2]={item_enhancement_tough=61.8,item_enhancement_quickened=14.8,item_enhancement_crude=12.4},
            [3]={item_enhancement_tough=67.1,item_enhancement_crude=19.8,item_enhancement_brawny=7.3},
            [4]={item_enhancement_tough=53.2,item_enhancement_crude=24.3,item_enhancement_quickened=16.8},
            [5]={item_enhancement_fleetfooted=50,item_enhancement_evolved=50},
        },
    }},
}
