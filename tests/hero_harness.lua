-- Offline harness that loads a hero's BotLib file with the engine stubbed out.
-- Ability and talent names are generic (A1..A6, T1..T8) so checks stay hero-agnostic:
-- A1-A3 are the basic abilities, A4/A5 the innate/hidden slots and A6 the ultimate;
-- T(2k-1) and T(2k) are the two talents of tier k (levels 10, 15, 20, 25).
package.path = './?.lua;'..package.path
local realDofile = dofile

local H = { realDofile = realDofile }
local state = { role = 'pos_1', custom = false, unit = 'npc_dota_hero_abaddon' }

function GetScriptDirectory() return 'bots' end

local bot = {}
function bot.GetAbilityByName() return {} end
function bot.GetUnitName() return state.unit end
function bot.GetPlayerID() return 0 end
function GetBot() return bot end
H.bot = bot

package.loaded['bots/FunLib/utils'] = {}
local Skill = realDofile('bots/FunLib/aba_skill.lua')
local DEFAULT_ABILITIES = { 'A1', 'A2', 'A3', 'A4', 'A5', 'A6' }
-- Heroes whose real GetAbilityList order differs from the default: each entry maps a list index to
-- the generic role at that index, so a build that levels the real ultimate still levels A6.
local ABILITY_LAYOUTS = {
    -- Bedlam (the ultimate, linked with Terrorize) sits at index 4, Pixie Dust (innate) at 5, Terrorize at 6.
    npc_dota_hero_dark_willow = { 'A1', 'A2', 'A3', 'A6', 'A5', 'A4' },
}
H.abilities = DEFAULT_ABILITIES
H.talents = { 'T1', 'T2', 'T3', 'T4', 'T5', 'T6', 'T7', 'T8' }
Skill.GetAbilityList = function() return H.abilities end
Skill.GetTalentList = function() return H.talents end

local J = {
    Skill = Skill,
    Item = { GetRoleItemsBuyList = function() return state.role end },
    Role = { IsPvNMode = function() return false end, IsAllShadow = function() return false end },
    Utils = { GameStates = {} }, -- Dazzle keeps per-player Nothl Projection state here at load time.
    -- `custom` mimics a user-supplied ability build: same order, but a different table
    -- object, which is how the hero files detect (and must preserve) user progressions.
    SetUserHeroInit = function(abilities, talents, items, sells)
        if state.custom then
            local copy = {}
            for i, v in ipairs(abilities) do copy[i] = v end
            return copy, talents, items, sells
        end
        return abilities, talents, items, sells
    end,
}
H.J = J
package.loaded['bots/FunLib/jmz_func'] = J

dofile = function(path)
    if path == 'bots/FunLib/aba_minion' then return {} end
    return realDofile(path)
end

-- Load `unit`'s hero file as `role` ('pos_1'..'pos_5'); opts.custom simulates a user ability build.
function H.load(unit, role, opts)
    state.unit, state.role = unit, role
    state.custom = opts ~= nil and opts.custom == true
    H.abilities = ABILITY_LAYOUTS[unit] or DEFAULT_ABILITIES
    local file = 'bots/BotLib/hero_'..unit:gsub('^npc_dota_hero_', '')..'.lua'
    local ok, result = pcall(realDofile, file)
    state.custom = false
    if not ok then
        error(file..' failed to load in the offline harness for '..role..': '..tostring(result), 0)
    end
    return result
end

return H
