-- Ward spots must stay out of our own neutral spawn boxes (a ward inside one blocks the camp), using the
-- live GetNeutralSpawners() boxes. Camp data: the 7.41f dump in tests/neutral_spawners_741f.lua.
package.path = './?.lua;'..package.path
function GetScriptDirectory() return 'bots' end
package.loaded['bots/FunLib/jmz_func'] = {}

local function V(x, y, z) return { x = x, y = y, z = z or 0 } end
Vector = V
TEAM_RADIANT, TEAM_DIRE = 2, 3
for i, name in ipairs({ 'TOP_1', 'MID_1', 'BOT_1', 'TOP_2', 'MID_2', 'BOT_2', 'TOP_3', 'MID_3', 'BOT_3' }) do
    _G['TOWER_'..name] = i
end

local team = TEAM_RADIANT
function GetTeam() return team end
local camps = {}
function GetNeutralSpawners() return camps end
local blocked = {}
function IsLocationPassable(v) return not blocked[v.x..','..v.y] end

local W = dofile('bots/FunLib/aba_ward_utility.lua')
local fixture = dofile('tests/neutral_spawners_741f.lua')(V)

local function insideOwnBox(v)
    for _, c in ipairs(fixture) do
        if c.team == team and v.x >= c.min.x and v.x <= c.max.x and v.y >= c.min.y and v.y <= c.max.y then return true end
    end
    return false
end

-- 1. Before pre-game the camp list is empty: spots pass through unchanged and nothing is cached.
local ancientSpot = V(-4245.5, 357.4) -- Radiant spot inside the Radiant ancient camp (7.41f)
assert(W.GetSpawnSafeLocation(ancientSpot) == ancientSpot, 'no camps known yet: unchanged')

-- 2. With the live boxes, the Radiant spots inside Radiant camps are moved just outside.
camps = fixture
for _, spot in ipairs({ ancientSpot, V(-682.9, -7909.4) }) do
    assert(insideOwnBox(spot), 'fixture: the spot starts inside a Radiant camp')
    local safe = W.GetSpawnSafeLocation(spot)
    assert(safe ~= nil and not insideOwnBox(safe), 'moved out of the spawn box')
    assert(math.abs(safe.x - spot.x) + math.abs(safe.y - spot.y) < 200, 'moved only as far as needed')
end

-- 3. Spots near enemy camps are left alone (blocking the enemy jungle is not our problem).
local nearDireCamp = V(3880.9, -879.2)
assert(W.GetSpawnSafeLocation(nearDireCamp) == nearDireCamp, 'enemy camps are not avoided')

-- 4. When no walkable exit exists, the spot is dropped from the lists.
local list = W.KeepOutOfOwnCamps({ { location = V(-682.9, -7909.4) }, { location = V(0, 0) } })
assert(#list == 2 and not insideOwnBox(list[1].location), 'list keeps both, the first one moved')
local trapped = V(3978.5, -5026.5) -- centre of Radiant's small camp
local s = W.GetSpawnSafeLocation(trapped)
blocked[s.x..','..s.y] = true
local stillSafe = W.GetSpawnSafeLocation(trapped)
assert(stillSafe ~= nil and not (stillSafe.x == s.x and stillSafe.y == s.y), 'falls back to the next nearest exit')
for _, side in ipairs({ { 3647.4 - 60, -5026.5 }, { 4442.9 + 60, -5026.5 }, { 3978.5, -5437.9 - 60 }, { 3978.5, -4648.1 + 60 } }) do
    blocked[side[1]..','..side[2]] = true
end
assert(#W.KeepOutOfOwnCamps({ { location = trapped } }) == 0, 'no walkable exit: dropped')
blocked = {}

-- 5. Dire uses its own camps: a Radiant camp is not avoided by Dire wards.
team = TEAM_DIRE
package.loaded['bots/FunLib/aba_ward_utility'] = nil
local WD = dofile('bots/FunLib/aba_ward_utility.lua')
local inRadiantCamp = V(-682.9, -7909.4)
assert(WD.GetSpawnSafeLocation(inRadiantCamp) == inRadiantCamp, 'Dire ignores Radiant camps')
local inDireCamp = V(-852.0, 4940.0) -- Dire medium camp centre
assert(not WD.GetSpawnSafeLocation(inDireCamp) or WD.GetSpawnSafeLocation(inDireCamp) ~= inDireCamp, 'Dire avoids its own camps')

print('Ward spawn box scenarios passed')
