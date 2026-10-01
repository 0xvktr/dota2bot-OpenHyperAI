-- Load the complete generated site module with only its engine imports stubbed.
function GetScriptDirectory() return 'bots' end
function GetTeam() return 2 end
function Vector(x, y, z) return {x = x, y = y, z = z} end
function GetUnitList() return {} end
package.loaded['bots/ts_libs/dota/index'] = dofile('bots/ts_libs/dota/enums.lua')
package.loaded['bots/FunLib/utils'] = {}
local Site = dofile('bots/FunLib/aba_site.lua')
local count = 0
local camps = {}
for _, team in ipairs({2, 3}) do
    for _, kind in ipairs({'small', 'medium', 'large', 'ancient'}) do
        camps[#camps + 1] = {idx = #camps + 1, team = team, type = kind, location = {distance = 100}}
    end
end
function GetNeutralSpawners() return camps end
local members = {}
function GetTeamPlayers() return #members > 0 and {1} or {} end
function GetTeamMember(id) return members[id] end
function GetUnitToLocationDistance(_, loc) return loc.distance end
local function bot(level, damage)
    return {GetLevel = function() return level end, GetAttackDamage = function() return damage end}
end
local function check(level, damage, allowed)
    local farmer = bot(level, damage)
    local available, size = Site.RefreshCamp(farmer)
    assert(size == 8 and #available == 8, 'refresh must retain camps other heroes can farm')
    local seen = {}
    for _, entry in ipairs(available) do
        local camp = entry.cattr
        local key = camp.team .. ':' .. camp.type
        assert(entry.idx == camp.idx, 'camp wrapper must preserve spawn identity')
        seen[key] = true
        assert(Site.CanFarmCamp(farmer, camp) == (allowed[key] == true), 'eligibility mismatch: ' .. key)
        -- Even the only/nearest camp must be refused when ineligible. This
        -- exercises the same wrapped entries as the farm mode's registry.
        assert((Site.GetClosestNeutralSpwan(farmer, {entry}) ~= nil) == (allowed[key] == true),
            'selection mismatch at level ' .. level .. ', damage ' .. damage .. ': ' .. key)
    end
    assert(seen['2:ancient'] and seen['3:large'])
    count = count + 1
end
local early = {['2:small'] = true, ['2:medium'] = true}
local regular = {['2:small'] = true, ['2:medium'] = true, ['2:large'] = true}
local own = {['2:small'] = true, ['2:medium'] = true, ['2:large'] = true, ['2:ancient'] = true}
local all = {}
for _, c in ipairs(camps) do all[c.team .. ':' .. c.type] = true end
check(1, 120, early)
check(7, 120, early)
check(8, 80, early)
check(8, 81, regular)
check(10, 120, regular)
check(11, 120, regular)
check(12, 120, own)
check(14, 120, own)
check(15, 120, all)
check(25, 80, early)
check(25, 81, all)

-- A low-level refresh cannot hide camps from a stronger farmer using the same list.
local shared = Site.RefreshCamp(bot(3, 60))
local ancient = {idx = 20, cattr = {team = 2, type = 'ancient', location = {distance = 20}}}
shared[#shared + 1] = ancient
assert(Site.GetClosestNeutralSpwan(bot(12, 120), shared) == ancient)
assert(Site.GetClosestNeutralSpwan(bot(3, 60), shared) ~= ancient)
assert(#shared == 9, 'selection must not mutate team availability')
count = count + 1

-- Enemy distance weighting reads cattr, not the wrapper's nonexistent team field.
local allied = {idx = 21, cattr = {team = 2, type = 'large', location = {distance = 100}}}
local enemy = {idx = 22, cattr = {team = 3, type = 'large', location = {distance = 80}}}
assert(Site.GetClosestNeutralSpwan(bot(15, 120), {enemy, allied}) == allied)
enemy.cattr.location.distance = 60
assert(Site.GetClosestNeutralSpwan(bot(15, 120), {enemy, allied}) == enemy)
count = count + 1
assert(Site.GetClosestNeutralSpwan(bot(5, 60), {}) == nil)
assert(Site.GetClosestNeutralSpwan(bot(5, 60), {ancient, enemy}) == nil)
count = count + 1

-- Existing farm-ownership checks still apply to eligible camps.
members[1] = {IsAlive = function() return true end,
    GetActiveMode = function() return package.loaded['bots/ts_libs/dota/index'].BotMode.Farm end}
function GetUnitToLocationDistance(unit, loc) return unit == members[1] and 1 or loc.distance end
assert(Site.GetClosestNeutralSpwan(bot(15, 120), {allied}) == nil)
count = count + 1
print(count .. ' camp filter scenarios passed')
