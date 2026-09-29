-- Retrieved 2026-09-30. Overview: last 8 days, 7000+; builds: Sep 15-29, updated Sep 29.
-- Role counts sum to 4972; overview reports 4985. Carry (2.4%) is a reviewed exception.
-- Pos 4 is deferred: current bot casting does not use Devour's acquired support abilities.
return {
    patch='7.41f', updated='2026-09-30', defaultRole='pos_3',
    source='https://dota2protracker.com/hero/Doom?section=builds',
    roles={
        pos_1={matches=119,winRate=43.7,rating=32,weight=38,buildMatches=165,buildWinRate=45,skillMatches=50,openingMatches=11,openingObserved=165},
        pos_2={matches=69,winRate=37.7,skipped=true},
        pos_3={matches=4635,winRate=50.2,rating=56,weight=86,buildMatches=7721,buildWinRate=50,skillMatches=2290,openingMatches=727,openingObserved=7715},
        pos_4={matches=98,winRate=48.0,skipped=true},
        pos_5={matches=51,winRate=51.0,skipped=true},
    },
    -- Exclude retained lower-tier items; sparse T5 observations use the reviewed tank profile.
    neutrals={
        pos_1={tier5Profile='tank',
            neutral={
                [1]={item_chipped_vest=29.3,item_occult_bracelet=11.6,item_weighted_dice=10.4,item_dormant_curio=9.8,item_stonefeather_satchel=7.9,item_duelist_gloves=7.3,item_possessed_mask=6.7},
                [2]={item_mana_draught=19.9,item_pogo_stick=14.9,item_poor_mans_shield=11.8,item_defiant_shell=11.8,item_crippling_crossbow=8.7,item_searing_signet=8.7,item_essence_ring=5.6},
                [3]={item_cloak_of_flames=35.8,item_gunpowder_gauntlets=21.2,item_serrated_shiv=10.2,item_partisans_brand=9.5,item_unrelenting_eye=8.8,item_stormcrafter=4.4},
                [4]={item_conjurers_catalyst=25.4,item_prophets_pendulum=11.9,item_enchanters_bauble=11.9,item_rattlecage=10.4,item_giant_maul=10.4,item_flayers_bota=7.5},
                [5]={item_fallen_sky=66.7,item_minotaur_horn=33.3},
            },
            enhancement={
                [1]={item_enhancement_quickened=52.4,item_enhancement_brawny=21.3,item_enhancement_vital=14.6},
                [2]={item_enhancement_quickened=36,item_enhancement_brawny=24.8,item_enhancement_tough=22.4},
                [3]={item_enhancement_tough=46.7,item_enhancement_quickened=25.5,item_enhancement_brawny=18.2},
                [4]={item_enhancement_quickened=46.3,item_enhancement_tough=20.9,item_enhancement_timeless=17.9},
                [5]={item_enhancement_timeless=100},
            },
        },
        pos_3={tier5Profile='tank',
            neutral={
                [1]={item_chipped_vest=23.4,item_stonefeather_satchel=12.7,item_kobold_cup=11.2,item_polliwog_charm=8.7,item_dormant_curio=8.4,item_occult_bracelet=7.5,item_duelist_gloves=7.5},
                [2]={item_mana_draught=20.8,item_searing_signet=15,item_pogo_stick=13.4,item_poor_mans_shield=11,item_crippling_crossbow=10,item_essence_ring=8.4,item_defiant_shell=5.9},
                [3]={item_cloak_of_flames=37.2,item_gunpowder_gauntlets=16.2,item_partisans_brand=11,item_stormcrafter=7.7,item_unrelenting_eye=5.7,item_serrated_shiv=4.8,item_jidi_pollen_bag=4.1},
                [4]={item_conjurers_catalyst=30.5,item_prophets_pendulum=11.7,item_giant_maul=11.5,item_rattlecage=10.2,item_enchanters_bauble=7,item_idol_of_screeauk=6.5},
                [5]={item_dezun_bloodrite=29.8,item_fallen_sky=16.5,item_spider_legs=14.9,item_minotaur_horn=13.2,item_demonicon=11.6,item_harmonizer=3.3},
            },
            enhancement={
                [1]={item_enhancement_quickened=57.1,item_enhancement_brawny=27.6,item_enhancement_vital=12.8},
                [2]={item_enhancement_quickened=46,item_enhancement_brawny=25.4,item_enhancement_greedy=14.2},
                [3]={item_enhancement_quickened=40.4,item_enhancement_brawny=24.3,item_enhancement_tough=22.2},
                [4]={item_enhancement_quickened=45.6,item_enhancement_timeless=23.2,item_enhancement_brawny=17.9},
                [5]={item_enhancement_fleetfooted=41.3,item_enhancement_timeless=29.8,item_enhancement_evolved=22.3},
            },
        },
    },
}
