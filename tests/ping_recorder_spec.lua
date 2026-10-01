-- The ping recorder in FunLib/debug_dumps.lua: each new human ping is logged once (OHA_DUMP|pin) and echoed in
-- team chat, with the nearest camp from the 7.41f fixture and the lane fronts.
local function V(x, y, z) return { x = x, y = y, z = z or 0 } end
TEAM_RADIANT, TEAM_DIRE = 2, 3
LANE_TOP, LANE_MID, LANE_BOT = 1, 2, 3

local lines, chats = {}, {}
OhaRawPrint = function(line) table.insert(lines, line) end
function GetTeam() return TEAM_RADIANT end
function GetTeamPlayers() return { 0, 1, 2, 3, 4 } end
function IsPlayerBot(id) return id ~= 0 end
local now = 100
function GameTime() return now end
function DotaTime() return now - 60 end
local camps = dofile('tests/neutral_spawners_741f.lua')(V)
function GetNeutralSpawners() return camps end
function GetLaneFrontAmount(_, lane) return ({ 0.25, 0.5, 0.75 })[lane] end

local ping = { time = 40, location = V(0, 0), normal_ping = true } -- stale: made before the recorder ran
local human = { IsBot = function() return false end, GetLocation = function() return V(3900, -5100) end,
    GetMostRecentPing = function() return ping end }
local function Bot(id) return { IsBot = function() return true end, GetPlayerID = function() return id end,
    ActionImmediate_Chat = function(_, msg, allChat) table.insert(chats, { msg, allChat }) end } end
local firstBot, otherBot = Bot(1), Bot(2)
function GetTeamMember(i) return i == 1 and human or Bot(i - 1) end

local D = dofile('bots/FunLib/debug_dumps.lua')

-- 1. A ping that already existed when recording started is not reported.
D.RecordPings(firstBot)
assert(#lines == 0 and #chats == 0, 'stale ping ignored')

-- 2. A new ping inside Radiant's small camp box is logged once, with camp and lane-front context.
ping = { time = 99.5, location = V(3978, -5026), normal_ping = true }
D.RecordPings(otherBot)
assert(#lines == 0, 'only the first bot records')
D.RecordPings(firstBot)
D.RecordPings(firstBot)
assert(#lines == 1 and #chats == 1, 'each ping is reported exactly once')
local line = lines[1]
for _, part in ipairs({ 'OHA_DUMP|pin|n=1|time=0:40.0', 'ping=3978,-5026', 'hero=3900,-5100', 'danger=false',
        'camp_type=small', 'camp_team=radiant', 'camp_box_dist=0', 'front_bot=0.750', 'front_mid=0.500', 'front_top=0.250' }) do
    assert(line:find(part, 1, true), 'log line has '..part..': '..line)
end
assert(chats[1][2] == false, 'echo goes to team chat')
assert(chats[1][1]:find('PIN 1 0:40.0 (3978, -5026)', 1, true) and chats[1][1]:find('IN BOX', 1, true), chats[1][1])

-- 3. The next ping gets the next index; a spot outside every box reports its distance.
now = 130
ping = { time = 129.8, location = V(3978, -4400), normal_ping = false }
D.RecordPings(firstBot)
assert(#lines == 2 and lines[2]:find('n=2', 1, true) and lines[2]:find('danger=true', 1, true), lines[2])
assert(chats[2][1]:find('248 away', 1, true), chats[2][1])

-- 4. Errors switch the recorder off instead of breaking item usage every frame.
GetLaneFrontAmount = function() error('boom') end
now = 140; ping = { time = 139.9, location = V(0, 0) }
D.RecordPings(firstBot)
assert(D.PingRecorderEnabled == false and lines[#lines]:find('OHA_DUMP|error|ping recorder', 1, true), 'error reported once')
local n = #lines
now = 150; ping = { time = 149.9, location = V(1, 1) }
D.RecordPings(firstBot)
assert(#lines == n, 'disabled after an error')

print('Ping recorder scenarios passed')
