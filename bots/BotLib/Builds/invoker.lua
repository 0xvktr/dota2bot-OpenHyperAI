-- D2PT 7.41f, retrieved 2026-09-30. Mid only at the user's request, including skipped support samples.
-- Most-played Quas-Exort build: 13601 games versus 524 for Quas-Wex.
return {
    patch='7.41f', updated='2026-09-30', defaultRole='pos_2',
    source='https://dota2protracker.com/hero/Invoker?section=builds&role=mid',
    overviewWindow='last 8 days, 7000+', buildWindow='2026-09-16 to 2026-09-30', buildUpdated='2026-09-30',
    roles={
        pos_1={matches=11,winRate=36.4,skipped=true},
        pos_2={matches=8029,winRate=52.7,rating=79,weight=100,buildMatches=13601,skillMatches=4460,openingMatches=1598},
        pos_3={matches=48,winRate=45.8,skipped=true},
        pos_4={matches=946,winRate=49.7,skipped=true},
        pos_5={matches=317,winRate=49.8,skipped=true},
    },
    -- Observed upgrade choices, NOT automated: the bot API has no verified upgrade-selection action.
    -- Leave Shard/Scepter/Blessing out of purchases until selection can be implemented and lobby-tested.
    upgradeChoices={scepter='exort',scepterPickRate=69,shard='wex',shardPickRate=93},
    neutrals={
        pos_2={tier5Profile='caster',
            -- Exclude retained Curio/Signet/Brand/Catalyst/Bauble from later tiers.
            neutral={
                [1]={item_dormant_curio=23.7,item_duelist_gloves=15,item_occult_bracelet=11.9,item_weighted_dice=9.6,item_stonefeather_satchel=8.8,item_kobold_cup=6.9,item_ash_legion_shield=6.7},
                [2]={item_searing_signet=37.2,item_mana_draught=20,item_pogo_stick=11.9,item_essence_ring=9.1,item_crippling_crossbow=4,item_medallion_of_courage=1.4},
                [3]={item_partisans_brand=20.8,item_spellslinger=8.8,item_cloak_of_flames=7.8,item_stormcrafter=6,item_gunpowder_gauntlets=5.5},
                [4]={item_conjurers_catalyst=44.5,item_enchanters_bauble=16.9,item_prophets_pendulum=8.4,item_dandelion_amulet=7.2,item_rattlecage=2.7},
                [5]={item_dezun_bloodrite=15.1,item_harmonizer=14,item_demonicon=10.2,item_divine_regalia=9.1,item_fallen_sky=8.1},
            },
            enhancement={
                [1]={item_enhancement_mystical=64.7,item_enhancement_quickened=33,item_enhancement_tough=1.5},
                [2]={item_enhancement_mystical=42.8,item_enhancement_quickened=27,item_enhancement_greedy=19},
                [3]={item_enhancement_mystical=36.9,item_enhancement_quickened=25.5,item_enhancement_greedy=21.2},
                [4]={item_enhancement_timeless=82.2,item_enhancement_quickened=6,item_enhancement_keen_eyed=5.7},
                [5]={item_enhancement_timeless=77.4,item_enhancement_feverish=20.4,item_enhancement_fleetfooted=1.6},
            },
        },
    },
}
