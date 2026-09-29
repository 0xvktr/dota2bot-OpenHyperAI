-- D2PT 7.41f: https://dota2protracker.com/hero/Ancient%20Apparition
-- Retrieved 2026-09-28. Roles: last 8 days; build: Sep 15-27, updated Sep 27.
-- Role counts total 1813; header reports 1815. Pos 4 has real data but is outside
-- this migration's requested pos-5-only scope. Bot execution remains on WeakHeroes.
return {
    patch='7.41f', updated='2026-09-28', defaultRole='pos_5',
    roles={
        pos_1={matches=1,winRate=100,skipped=true},
        pos_2={matches=24,winRate=54.2,skipped=true},
        pos_3={matches=1,winRate=100,skipped=true},
        pos_4={matches=348,winRate=48.6,skipped=true},
        pos_5={matches=1439,winRate=49.9,rating=44,weight=67,buildMatches=1944},
    },
    neutrals={pos_5={tier5Profile='support',
        neutral={
            [1]={item_dormant_curio=17.3,item_polliwog_charm=14.7,item_kobold_cup=13.5,item_ash_legion_shield=12.8,item_foragers_kit=11.5},
            [2]={item_searing_signet=31.6,item_mana_draught=18.2,item_pogo_stick=14.5,item_essence_ring=14.3,item_crippling_crossbow=4.1},
            -- Retained T2 items omitted; only four eligible T3 choices are shown.
            [3]={item_partisans_brand=13.6,item_psychic_headband=10.7,item_spellslinger=10.2,item_gunpowder_gauntlets=5.5},
            [4]={item_conjurers_catalyst=39.8,item_enchanters_bauble=17.9,item_dandelion_amulet=10.0,item_prophets_pendulum=8.2,item_idol_of_screeauk=2.6},
            -- ~37 inventories: pick evidence only; T4 Catalyst/Bauble omitted.
            -- The support profile filters unsuitable damage-oriented choices.
            [5]={item_dezun_bloodrite=27.0,item_demonicon=18.9,item_fallen_sky=8.1,item_divine_regalia=8.1,item_desolator_2=5.4},
        },
        enhancement={
            [1]={item_enhancement_mystical=61.2,item_enhancement_quickened=35.5,item_enhancement_vital=2.5},
            [2]={item_enhancement_greedy=78.9,item_enhancement_mystical=12.7,item_enhancement_quickened=4.3},
            [3]={item_enhancement_greedy=78.4,item_enhancement_mystical=11.8,item_enhancement_keen_eyed=6.0},
            [4]={item_enhancement_timeless=75.7,item_enhancement_mystical=12.0,item_enhancement_keen_eyed=8.1},
            [5]={item_enhancement_timeless=83.8,item_enhancement_feverish=16.2},
        },
    }},
}
