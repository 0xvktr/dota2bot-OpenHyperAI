-- One-off data dumps for offline analysis. Output goes to the in-game console; launch Dota with
-- -condebug to also get it in game/dota/console*.log. Grep for the "OHA_DUMP|" prefix.
local D = {}

-- aba_global_overrides silences print() unless Utils.DebugMode is on; use the original print it keeps.
local function out(line) (OhaRawPrint or print)(line) end

-- Toggle before a test game. Leave false in normal play.
D.NeutralSpawnersEnabled = false
-- Echo every ping of a human teammate (coordinates, time, nearest camp, lane fronts) to the log and team chat.
D.PingRecorderEnabled = true

if D.NeutralSpawnersEnabled then
    -- Marker: if this line is in the log but no spawner lines are, the dump failed; if neither is,
    -- bot script print output is not reaching the log.
    out('OHA_DUMP|loaded|team='..tostring(GetTeam()))
end

local function formatValue(v)
    local t = type(v)
    if t == 'userdata' or t == 'table' then
        local ok, x, y, z = pcall(function() return v.x, v.y, v.z end)
        if ok and type(x) == 'number' then
            return string.format('Vector(%.1f,%.1f,%.1f)', x, y or 0, z or 0)
        end
        if t == 'table' then
            local parts = {}
            for k, sub in pairs(v) do parts[#parts + 1] = tostring(k)..'='..formatValue(sub) end
            table.sort(parts)
            return '{'..table.concat(parts, ',')..'}'
        end
    end
    return tostring(v)
end

local nLastEmptyState = nil
local function dump()
    local spawners = GetNeutralSpawners()
    local team = GetTeam() == TEAM_RADIANT and 'radiant' or 'dire'
    local keys = {}
    for k in pairs(spawners or {}) do keys[#keys + 1] = k end

    -- The camps are not exposed during hero selection; retry every frame and note each state they are missing in.
    if #keys == 0 then
        if nLastEmptyState ~= GetGameState() then
            nLastEmptyState = GetGameState()
            out(string.format('OHA_DUMP|empty|team=%s|state=%s|time=%.1f', team, tostring(GetGameState()), DotaTime()))
        end
        return false
    end
    table.sort(keys, function(a, b) return tostring(a) < tostring(b) end)

    out(string.format('OHA_DUMP|spawners_begin|team=%s|state=%s|time=%.1f|count=%d',
        team, tostring(GetGameState()), DotaTime(), #keys))
    for _, k in ipairs(keys) do
        local fields = {}
        for field, v in pairs(spawners[k]) do fields[#fields + 1] = tostring(field)..'='..formatValue(v) end
        table.sort(fields)
        out('OHA_DUMP|spawner|team='..team..'|key='..tostring(k)..'|'..table.concat(fields, '|'))
    end
    out('OHA_DUMP|spawners_end|team='..team)
    return true
end

-- Prints every neutral spawner with all the fields the API returns: whether spawn-box bounds are exposed,
-- and the current camp positions. Called from hero_selection's UpdateLaneAssignments (team-level, before
-- the horn) and, as an in-game fallback, from item usage with `bot`, where only each team's first bot prints.
-- Only one bot per team reports, so output is not repeated per bot.
local function isFirstBot(bot)
    for _, id in ipairs(GetTeamPlayers(GetTeam())) do
        if IsPlayerBot(id) then return bot:GetPlayerID() == id end
    end
    return false
end

local bNeutralSpawnersDumped = false
function D.DumpNeutralSpawners(bot)
    if not D.NeutralSpawnersEnabled or bNeutralSpawnersDumped then return end
    if bot ~= nil and not isFirstBot(bot) then return end
    local ok, result = pcall(dump)
    if not ok then
        bNeutralSpawnersDumped = true
        out('OHA_DUMP|error|'..tostring(result))
    elseif result then
        bNeutralSpawnersDumped = true
    end
end

------------------------------------------------------------------------------------------
-- Ping recorder: walk the map in a lobby and ping spots (pull/stack positions, ward spots...).
-- Each new ping is logged as an OHA_DUMP|pin line and echoed in team chat.
------------------------------------------------------------------------------------------
local LANE_NAMES = { [LANE_TOP or 1] = 'top', [LANE_MID or 2] = 'mid', [LANE_BOT or 3] = 'bot' }

local function clock(t)
    local sign = t < 0 and '-' or ''
    t = math.abs(t)
    return string.format('%s%d:%04.1f', sign, math.floor(t / 60), t % 60)
end

-- Nearest neutral camp by distance to its spawn box (0 when inside).
local function nearestCamp(v)
    local best, bestDist, bestKey
    for k, camp in pairs(GetNeutralSpawners() or {}) do
        if camp.min ~= nil and camp.max ~= nil then
            local dx = math.max(camp.min.x - v.x, 0, v.x - camp.max.x)
            local dy = math.max(camp.min.y - v.y, 0, v.y - camp.max.y)
            local d = math.sqrt(dx * dx + dy * dy)
            if bestDist == nil or d < bestDist then best, bestDist, bestKey = camp, d, k end
        end
    end
    return best, bestDist, bestKey
end

local tLastPingTime = {}
local nPingCount = 0
local function recordPings(bot)
    local team = GetTeam()
    for i = 1, #GetTeamPlayers(team) do
        local member = GetTeamMember(i)
        if member ~= nil and not member:IsBot() then
            local ping = member:GetMostRecentPing()
            if ping ~= nil and ping.time ~= nil and ping.location ~= nil and ping.time ~= tLastPingTime[i] then
                local bFresh = GameTime() - ping.time < 3 -- skip a stale ping seen on the first check
                tLastPingTime[i] = ping.time
                if bFresh then
                    nPingCount = nPingCount + 1
                    local p, h = ping.location, member:GetLocation()
                    local fields = {
                        'pin', 'n='..nPingCount, 'time='..clock(DotaTime()),
                        string.format('ping=%.0f,%.0f', p.x, p.y), string.format('hero=%.0f,%.0f', h.x, h.y),
                        'danger='..tostring(ping.normal_ping == false),
                    }
                    local chat = string.format('PIN %d %s (%.0f, %.0f)', nPingCount, clock(DotaTime()), p.x, p.y)

                    local camp, dist, key = nearestCamp(p)
                    if camp ~= nil then
                        local side = camp.team == TEAM_RADIANT and 'radiant' or 'dire'
                        table.insert(fields, string.format('camp=%s|camp_type=%s|camp_team=%s|camp_box_dist=%.0f',
                            tostring(key), tostring(camp.type), side, dist))
                        chat = chat..string.format(' | camp %s %s %s %s', tostring(key), tostring(camp.type), side,
                            dist == 0 and 'IN BOX' or string.format('%.0f away', dist))
                    end

                    local fronts = {}
                    for lane, name in pairs(LANE_NAMES) do
                        table.insert(fronts, string.format('front_%s=%.3f', name, GetLaneFrontAmount(team, lane, false)))
                    end
                    table.sort(fronts)
                    for _, f in ipairs(fronts) do table.insert(fields, f) end

                    out('OHA_DUMP|'..table.concat(fields, '|'))
                    bot:ActionImmediate_Chat(chat, false)
                end
            end
        end
    end
end

-- Called every frame from ItemUsageThink; only the team's first bot records.
function D.RecordPings(bot)
    if not D.PingRecorderEnabled or not isFirstBot(bot) then return end
    local ok, err = pcall(recordPings, bot)
    if not ok then
        D.PingRecorderEnabled = false
        out('OHA_DUMP|error|ping recorder: '..tostring(err))
    end
end

return D
