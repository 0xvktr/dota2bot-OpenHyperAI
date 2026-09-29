-- Header 4547; displayed role counts sum to 4535.
-- Mid and both supports are deferred; forced picks use offlane.
return {
    patch='7.41f', updated='2026-09-30', defaultRole='pos_3',
    source='https://dota2protracker.com/hero/Enigma?section=builds&role=offlane',
    overviewWindow='last 8 days, 7000+', buildWindow='2026-09-15 to 2026-09-29', buildUpdated='2026-09-29',
    roles={
        pos_1={matches=14,winRate=35.7,skipped=true},
        pos_2={matches=167,winRate=58.1,skipped=true},
        pos_3={matches=4065,winRate=57,rating=85,weight=100,buildMatches=6573,buildWinRate=57,skillMatches=3719,openingMatches=887,openingObserved=6567},
        pos_4={matches=179,winRate=45.8,skipped=true},
        pos_5={matches=110,winRate=50,skipped=true},
    },
    -- Current-tier observations only; sparse T5 picks use the reviewed caster profile.
    neutrals={pos_3={tier5Profile='caster',
        neutral={
            [1]={item_ash_legion_shield=22,item_kobold_cup=17.2,item_dormant_curio=15.8,item_stonefeather_satchel=9.6,item_polliwog_charm=8,item_duelist_gloves=5.7,item_weighted_dice=5.7},
            [2]={item_mana_draught=22.5,item_searing_signet=21.2,item_pogo_stick=16.3,item_essence_ring=9.6,item_medallion_of_courage=8.5,item_crippling_crossbow=7.1},
            [3]={item_partisans_brand=19.7,item_cloak_of_flames=18.5,item_spellslinger=10.2,item_stormcrafter=9.3,item_psychic_headband=5.7},
            [4]={item_conjurers_catalyst=42.5,item_enchanters_bauble=16.4,item_prophets_pendulum=12.4,item_dandelion_amulet=8,item_idol_of_screeauk=3.5,item_rattlecage=3.5},
            [5]={item_dezun_bloodrite=29.3,item_demonicon=15.9,item_fallen_sky=13.4,item_minotaur_horn=9.8,item_harmonizer=4.9},
        },
        enhancement={
            [1]={item_enhancement_mystical=46.7,item_enhancement_quickened=40.8,item_enhancement_alert=7.3},
            [2]={item_enhancement_greedy=77.3,item_enhancement_mystical=10.6,item_enhancement_quickened=9.3},
            [3]={item_enhancement_greedy=81.4,item_enhancement_quickened=8.8,item_enhancement_mystical=7.9},
            [4]={item_enhancement_timeless=82.1,item_enhancement_quickened=13.7,item_enhancement_mystical=3.7},
            [5]={item_enhancement_timeless=91.5,item_enhancement_fleetfooted=7.3,item_enhancement_manic=1.2},
        },
    }},
}
