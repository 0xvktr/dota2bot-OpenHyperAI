-- Heroes whose survivability leans on healing, lifesteal or regeneration from their own kit, so
-- healing prevention (Ice Blast's Frostbite, Spirit Vessel...) hurts them more than most.
-- Each entry is backed by a heal/lifesteal/regen value in Valve's 7.41f ability data
-- (tests/valve/abilities.json); the ability that qualifies it is named beside it.
local X = {}

X.Heroes = {
    npc_dota_hero_abaddon = true,           -- Mist Coil heal, Aphotic Shield regen
    npc_dota_hero_alchemist = true,         -- Chemical Rage regen
    npc_dota_hero_bloodseeker = true,       -- Blood Bath / Sanguivore heal
    npc_dota_hero_broodmother = true,       -- Insatiable Hunger lifesteal
    npc_dota_hero_chen = true,              -- Hand of God
    npc_dota_hero_dawnbreaker = true,       -- Luminosity, Solar Guardian
    npc_dota_hero_dazzle = true,            -- Shadow Wave, Shallow Grave heal
    npc_dota_hero_dragon_knight = true,     -- Dragon Blood regen
    npc_dota_hero_enchantress = true,       -- Nature's Attendants
    npc_dota_hero_huskar = true,            -- Inner Vitality, Berserker's Blood
    npc_dota_hero_juggernaut = true,        -- Healing Ward
    npc_dota_hero_legion_commander = true,  -- Press the Attack regen
    npc_dota_hero_life_stealer = true,      -- Open Wounds heal, Infest regen
    npc_dota_hero_necrolyte = true,         -- Death Pulse heal, Sadist regen
    npc_dota_hero_omniknight = true,        -- Purification
    npc_dota_hero_oracle = true,            -- Purifying Flames
    npc_dota_hero_phoenix = true,           -- Sun Ray heal
    npc_dota_hero_pugna = true,             -- Life Drain
    npc_dota_hero_shredder = true,          -- Reactive Armor regen
    npc_dota_hero_skeleton_king = true,     -- Vampiric Spirit
    npc_dota_hero_slark = true,             -- Shadow Dance regen
    npc_dota_hero_treant = true,            -- Leech Seed, Living Armor
    npc_dota_hero_troll_warlord = true,     -- Battle Trance lifesteal
    npc_dota_hero_undying = true,           -- Soul Rip, Tombstone heal
    npc_dota_hero_winter_wyvern = true,     -- Cold Embrace
    npc_dota_hero_wisp = true,              -- Tether heal, Overcharge regen
    npc_dota_hero_witch_doctor = true,      -- Voodoo Restoration
}

function X.Is(hUnit)
    return X.Heroes[hUnit:GetUnitName()] == true
end

return X
