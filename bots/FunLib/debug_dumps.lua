-- One-off data dumps for offline analysis. Output goes to the in-game console; launch Dota with
-- -condebug to also get it in game/dota/console*.log. Grep for the "OHA_DUMP|" prefix.
local D = {}

-- aba_global_overrides silences print() unless Utils.DebugMode is on; use the original print it keeps.
local function out(line) (OhaRawPrint or print)(line) end

-- Toggle before a test game. Leave false in normal play.
D.NeutralSpawnersEnabled = false

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
local bNeutralSpawnersDumped = false
function D.DumpNeutralSpawners(bot)
    if not D.NeutralSpawnersEnabled or bNeutralSpawnersDumped then return end
    if bot ~= nil then
        for _, id in ipairs(GetTeamPlayers(GetTeam())) do
            if IsPlayerBot(id) then
                if bot:GetPlayerID() ~= id then return end
                break
            end
        end
    end
    local ok, result = pcall(dump)
    if not ok then
        bNeutralSpawnersDumped = true
        out('OHA_DUMP|error|'..tostring(result))
    elseif result then
        bNeutralSpawnersDumped = true
    end
end

return D
