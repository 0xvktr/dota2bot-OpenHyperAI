-- Header 1700; role rows sum to 1699. Mid/offlane only; forced picks use offlane.
-- Both roles share the observed caster progression; omit the mid opening's ward.
return {
    patch='7.41f', updated='2026-09-30', defaultRole='pos_3',
    source='https://dota2protracker.com/hero/Kunkka?section=builds',
    overviewWindow='last 8 days, 7000+', buildWindow='2026-09-15 to 2026-09-29', buildUpdated='2026-09-29',
    roles={
        pos_1={matches=28,winRate=42.9,skipped=true},
        pos_2={matches=556,winRate=47.8,rating=33,weight=47,buildMatches=755,buildWinRate=52,skillMatches=228,openingMatches=44,openingObserved=755},
        pos_3={matches=1019,winRate=49.8,rating=39,weight=58,buildMatches=1756,buildWinRate=52,skillMatches=606,openingMatches=476,openingObserved=1756},
        pos_4={matches=53,winRate=39.6,skipped=true},
        pos_5={matches=43,winRate=55.8,skipped=true},
    },
    -- Current-tier observations only; sparse T5 picks use reviewed caster suitability.
    neutrals={
        pos_2={tier5Profile='caster',
            neutral={
                [1]={item_chipped_vest=18.5,item_dormant_curio=13.9,item_duelist_gloves=11.8,item_weighted_dice=10.3,item_polliwog_charm=7.8,item_possessed_mask=7.5,item_occult_bracelet=7.2},
                [2]={item_mana_draught=12.3,item_poor_mans_shield=11.8,item_pogo_stick=11.3,item_searing_signet=10.7,item_essence_ring=10.1,item_defiant_shell=8.5},
                [3]={item_cloak_of_flames=21.3,item_gunpowder_gauntlets=20.4,item_partisans_brand=13.1,item_serrated_shiv=9.8,item_jidi_pollen_bag=6.5,item_unrelenting_eye=4.8},
                [4]={item_conjurers_catalyst=27.1,item_giant_maul=16.3,item_prophets_pendulum=11.7,item_enchanters_bauble=9.7,item_rattlecage=8.9},
                [5]={item_desolator_2=25,item_demonicon=16.7,item_fallen_sky=16.7,item_dezun_bloodrite=16.7,item_heavy_blade=8.3},
            },
            enhancement={
                [1]={item_enhancement_tough=53.6,item_enhancement_quickened=21.2,item_enhancement_brawny=18},
                [2]={item_enhancement_tough=60.6,item_enhancement_brawny=19.2,item_enhancement_greedy=14.2},
                [3]={item_enhancement_tough=60.1,item_enhancement_brawny=18.5,item_enhancement_greedy=15.7},
                [4]={item_enhancement_timeless=43.7,item_enhancement_tough=40.3,item_enhancement_brawny=8.9},
                [5]={item_enhancement_timeless=50,item_enhancement_evolved=33.3,item_enhancement_fleetfooted=16.7},
            },
        },
        pos_3={tier5Profile='caster',
            neutral={
                [1]={item_chipped_vest=26.7,item_polliwog_charm=9.8,item_dormant_curio=9.3,item_duelist_gloves=9.2,item_possessed_mask=9,item_weighted_dice=9,item_ash_legion_shield=8.1},
                [2]={item_poor_mans_shield=13.2,item_essence_ring=12.3,item_searing_signet=11.3,item_mana_draught=10.3,item_pogo_stick=9.7,item_defiant_shell=9.5},
                [3]={item_cloak_of_flames=28.2,item_gunpowder_gauntlets=21,item_partisans_brand=11.2,item_stormcrafter=7,item_serrated_shiv=6.5,item_jidi_pollen_bag=6.4,item_unrelenting_eye=5.6},
                [4]={item_conjurers_catalyst=33.1,item_giant_maul=15.3,item_prophets_pendulum=15.3,item_rattlecage=8.5,item_enchanters_bauble=6.6,item_dandelion_amulet=6},
                [5]={item_dezun_bloodrite=33.3,item_fallen_sky=18.2,item_demonicon=12.1,item_divine_regalia=12.1,item_spider_legs=6.1,item_desolator_2=3},
            },
            enhancement={
                [1]={item_enhancement_tough=50,item_enhancement_brawny=18.6,item_enhancement_vital=16.8},
                [2]={item_enhancement_tough=53.7,item_enhancement_brawny=29.3,item_enhancement_quickened=11.4},
                [3]={item_enhancement_tough=53.7,item_enhancement_brawny=28.7,item_enhancement_quickened=10.8},
                [4]={item_enhancement_timeless=41.8,item_enhancement_tough=29.2,item_enhancement_brawny=16.8},
                [5]={item_enhancement_timeless=51.5,item_enhancement_evolved=36.4,item_enhancement_hulking=12.1},
            },
        },
    },
}
