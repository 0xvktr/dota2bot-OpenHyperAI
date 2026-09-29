-- Invoker skill order (7.41b): Invoke grants bonus orb points at levels 6, 12 and 18, orbs max at 8.
-- Points are spent in list order, so each talent must follow exactly the orb points available before it.
package.path = './?.lua;'..package.path
function GetScriptDirectory() return 'bots' end
function GetBot() return { GetUnitName = function() return 'npc_dota_hero_invoker' end } end
package.loaded['bots/FunLib/utils'] = {}
local Skill = dofile('bots/FunLib/aba_skill.lua')

local abilities = { 'invoker_quas', 'invoker_wex', 'invoker_exort' }
local talents = { 'T1', 'T2', 'T3', 'T4', 'T5', 'T6', 'T7', 'T8' }
local build = { 2,1,2,1,3,1,2,1,2,2,3,3,3,3,3,3,2,2,1,1,1,2,1,3 }
local list = Skill.GetSkillList(abilities, build, talents, { 1, 3, 5, 7, 2, 4, 6, 8 })

assert(#list == 32, 'expected 24 orb points + 8 talents, got '..#list)
-- Simulate spending points: one per level, plus the bonus at 6, 12 and 18.
local index, levels = 0, {}
for level = 1, 30 do
    local points = (level == 6 or level == 12 or level == 18) and 2 or 1
    for _ = 1, points do
        index = index + 1
        if list[index] and list[index]:match('^T') then levels[list[index]] = level end
    end
end
assert(levels.T1 == 10 and levels.T3 == 15 and levels.T5 == 20 and levels.T7 == 25,
    'talents must land on levels 10/15/20/25, got '..tostring(levels.T1)..'/'..tostring(levels.T3)..'/'..tostring(levels.T5)..'/'..tostring(levels.T7))
local counts = {}
for _, name in ipairs(list) do counts[name] = (counts[name] or 0) + 1 end
assert(counts.invoker_quas == 8 and counts.invoker_wex == 8 and counts.invoker_exort == 8, 'each orb reaches its max level of 8')
print('Invoker skill order scenarios passed')
