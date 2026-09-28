-- Wiring of the two neutral-item distributors to hero_build_preferences.
-- The selection rules themselves are validated on real hero data in build_validator.lua; here the
-- preferences module is a spy, so this stays independent of any hero's data.
package.path = './?.lua;'..package.path
local realDofile = dofile
function GetScriptDirectory() return 'bots' end

local calls, answer = {}, function() return nil end
package.loaded['bots.FunLib.hero_build_preferences'] = {
    Select = function(bot, kind, tier, candidates, useDefaultRole)
        calls[#calls + 1] = { bot = bot, kind = kind, tier = tier, candidates = candidates, useDefaultRole = useDefaultRole }
        return answer(kind, tier, candidates)
    end,
}
local function lastCall() return calls[#calls] end
local function last(list) return list[#list] end

------------------------------------------------------------------------------------------
-- FretBots: offered candidates in, preferred candidate out; legacy scoring as the fallback.
------------------------------------------------------------------------------------------
package.loaded['bots.FretBots.Debug'] = true
package.loaded['bots.FretBots.Settings'] = true
package.loaded['bots.FretBots.Utilities'] = true
package.loaded['bots.FretBots.Flags'] = true
Debug = { IsDebug = function() return false end }
dofile = function(path)
    if path == 'bots.FretBots.SettingsNeutralItemTable' then return realDofile('bots/FretBots/SettingsNeutralItemTable.lua') end
    return realDofile(path)
end
NeutralItems = nil
realDofile('bots/FretBots/NeutralItems.lua')

local bot = { GetUnitName = function() return 'npc_dota_hero_axe' end, stats = { role = 5, isMelee = true } }
local weak = { name = 'item_polliwog_charm', tier = 1, melee = 1, roles = { 1, 1, 1, 1, 1 } }
local strong = { name = 'item_possessed_mask', tier = 1, melee = 3, roles = { 4, 4, 4, 4, 4 } }
local offered = { weak, strong }

answer = function() return weak end
assert(NeutralItems:ChooseItem(bot, 1, offered) == weak, 'FretBots must use the preferred item over legacy scoring')
assert(lastCall().kind == 'neutral' and lastCall().tier == 1 and lastCall().candidates == offered and lastCall().bot == bot)
answer = function() return nil end
assert(NeutralItems:ChooseItem(bot, 1, offered) == strong, 'FretBots falls back to legacy scoring without a preference')

answer = function(_, _, candidates) return last(candidates) end
for tier = 1, 5 do
    local chosen = NeutralItems:GetRandomEnhancementByTier(tier, bot)
    assert(chosen and chosen.tier == tier, 'enhancement must come from tier '..tier)
    assert(lastCall().kind == 'enhancement' and lastCall().tier == tier)
    assert(chosen == last(lastCall().candidates), 'FretBots must use the preferred enhancement')
    for _, candidate in ipairs(lastCall().candidates) do assert(candidate.tier == tier, 'only same-tier enhancements are offered') end
end
answer = function() return nil end
local fallback = NeutralItems:GetRandomEnhancementByTier(2, bot)
assert(fallback and fallback.tier == 2, 'FretBots falls back to a random same-tier enhancement')
assert(NeutralItems:GetRandomEnhancementByTier(99, bot) == nil, 'unknown tier has no enhancement')

------------------------------------------------------------------------------------------
-- Buff: the allowed pool goes to the preferences (with the primary-role fallback enabled).
------------------------------------------------------------------------------------------
NeutralItems = nil
realDofile('bots/Buff/NeutralItems.lua')
local given = {}
function CreateItem(name) return { name = name, SetPurchaseTime = function() end } end
local hero = {
    GetUnitName = function() return 'npc_dota_hero_axe' end,
    GetItemInSlot = function() return nil end,
    HasRoomForItem = function() return true end,
    AddItem = function(_, item) given[#given + 1] = item.name end,
}

answer = function(kind, _, candidates)
    if kind == 'neutral' then return 'item_preferred_neutral' end
    return last(candidates)
end
for tier = 1, 5 do
    given = {}
    NeutralItems.GiveItem('item_legacy_pick', hero, false, tier)
    assert(given[1] == 'item_preferred_neutral', 'Buff must award the preferred neutral at tier '..tier)
    local neutralCall
    for _, call in ipairs(calls) do if call.kind == 'neutral' then neutralCall = call end end
    assert(neutralCall.tier == tier and neutralCall.useDefaultRole == true, 'Buff has no role allocator: it must allow the default role')
    assert(#neutralCall.candidates > 0 and type(neutralCall.candidates[1]) == 'string', 'Buff offers its allowed pool')
    assert(given[2] and given[2]:match('^item_enhancement_'), 'Buff also awards an enhancement')
    assert(given[2] == last(lastCall().candidates).name, 'Buff must award the preferred enhancement')
    assert(lastCall().kind == 'enhancement' and lastCall().useDefaultRole == true)
end

answer = function() return nil end
given = {}
NeutralItems.GiveItem('item_legacy_pick', hero, false, 1)
assert(given[1] == 'item_legacy_pick', 'Buff keeps its random pick without a preference')
assert(given[2] and given[2]:match('^item_enhancement_'), 'Buff falls back to a random enhancement')

print('Neutral consumer wiring passed')
