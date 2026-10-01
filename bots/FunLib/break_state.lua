-- Bot handles do not expose the server-only PassivesDisabled method.
-- These effects explicitly disable passives in the pinned Valve localization.
-- Conditional upgrades that reuse an ordinary debuff need separate source checks.
local modifiers = {
    'modifier_break',
    'modifier_silver_edge_debuff',
    'modifier_phantom_assassin_fan_of_knives',
    'modifier_viper_viper_strike_slow',
    'modifier_nyx_assassin_vendetta_break',
    'modifier_hoodwink_sharpshooter_debuff',
    'modifier_item_angels_demise_break',
}

return function(unit)
    for _, name in ipairs(modifiers) do
        if unit:HasModifier(name) then return true end
    end
    return false
end
