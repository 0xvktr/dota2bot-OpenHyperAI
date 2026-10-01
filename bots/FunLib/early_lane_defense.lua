-- Early defensive rotations use assigned positions, never a hero's possible
-- support classification. Ganks/rune rotations are a separate policy.
local J = require(GetScriptDirectory()..'/FunLib/jmz_func')
local D = {}
D.NORMAL_UNTIL = 600
D.TURBO_UNTIL = 480
D.HOME_HP = 0.7
D.HOME_DROP = 0.15
D.TOWER_RADIUS = 1600

function D.Active()
    return DotaTime() < (J.IsModeTurbo() and D.TURBO_UNTIL or D.NORMAL_UNTIL)
end

function D.IsDefenseMode(bot)
    local mode = bot:GetActiveMode()
    return mode == BOT_MODE_DEFEND_ALLY or mode == BOT_MODE_DEFEND_TOWER_TOP
        or mode == BOT_MODE_DEFEND_TOWER_MID or mode == BOT_MODE_DEFEND_TOWER_BOT
end

local function realHero(h)
    return J.IsValidHero(h) and h:IsAlive() and not h:IsIllusion()
        and not J.IsSuspiciousIllusion(h)
end

local function enemyCount(loc, radius)
    local function count(list)
        local n = 0
        for _, h in ipairs(list) do if realHero(h) then n = n + 1 end end
        return n
    end
    -- The last-seen helper returns real player IDs, not unit handles. Its
    -- entries already exclude dead heroes and sightings older than 5 seconds.
    return math.max(count(J.GetEnemiesNearLoc(loc, radius)), #J.GetLastSeenEnemiesNearLoc(loc, radius))
end

-- Match lane_pull's rapid-loss heuristic. A healthy partner taking an ordinary
-- poke is not in trouble; losing 15% of max HP in about 3 seconds is different.
local hpSamples = setmetatable({}, {__mode = 'k'})
local function droppingFast(core)
    local now, hp, sample = DotaTime(), J.GetHP(core), hpSamples[core]
    if sample == nil or now - sample.time > 3 then
        hpSamples[core] = {time = now, hp = hp}
        return sample ~= nil and now - sample.time <= 3.5 and sample.hp - hp >= D.HOME_DROP
    end
    return sample.hp - hp >= D.HOME_DROP
end

-- Be conservative about an unseen/missing/dead partner: that is not evidence
-- that their lane can be left. Both supports use the same safety conditions.
function D.HomeSafe(bot)
    local found = false
    for i = 1, #GetTeamPlayers(GetTeam()) do
        local core = GetTeamMember(i)
        if J.IsValidHero(core) and core ~= bot and not core:IsIllusion()
            and J.GetPosition(core) <= 3 and core:GetAssignedLane() == bot:GetAssignedLane() then
            found = true
            local dropping = droppingFast(core)
            if not core:IsAlive() or J.GetHP(core) < D.HOME_HP or dropping
                or core:WasRecentlyDamagedByTower(4)
                or J.IsRetreating(core) then return false end
            local defenders = 0
            for _, ally in ipairs(J.GetAlliesNearLoc(core:GetLocation(), 1200)) do
                if ally ~= bot and realHero(ally) and J.GetHP(ally) >= 0.5 then defenders = defenders + 1 end
            end
            -- Evaluate the lane after our departure, including last-seen
            -- opponents. A healthy core alone into two nearby heroes is unsafe.
            if enemyCount(core:GetLocation(), 1000) > defenders then return false end
        end
    end
    return found
end

function D.Pressured(core, loc)
    if not realHero(core) or J.GetPosition(core) > 3
        or GetUnitToLocationDistance(core, loc) > D.TOWER_RADIUS then return false end
    local enemies = enemyCount(core:GetLocation(), 1200)
    if enemies == 0 then return false end
    return (core:WasRecentlyDamagedByAnyHero(3) and (J.GetHP(core) < 0.65 or enemies >= 2))
        or J.GetHP(core) < 0.4
end

-- Return a named core to rescue and its priority. Pos 4 covers a foreign
-- carry lane; pos 5 covers a foreign offlane. Supports can counter a mid dive,
-- below carry priority, without adding mid gank/rotation behavior.
function D.RescueTarget(bot, lane, loc, requested)
    local role, best, score = J.GetPosition(bot), nil, -1
    local function consider(core)
        if not D.Pressured(core, loc) then return end
        local position = J.GetPosition(core)
        if lane ~= bot:GetAssignedLane()
            and ((position == 1 and role ~= 4) or (position == 3 and role ~= 5)) then return end
        local priority = position == 1 and 300 or position == 2 and 200 or 100
        if priority > score then best, score = core, priority end
    end
    if requested then consider(requested)
    else for i = 1, #GetTeamPlayers(GetTeam()) do consider(GetTeamMember(i)) end end
    return best, score
end

function D.Allow(bot, lane, loc, target)
    if not D.Active() or lane == bot:GetAssignedLane() then return true end
    local role = J.GetPosition(bot)
    if role ~= 4 and role ~= 5 then return false end
    if not D.HomeSafe(bot) then return false end
    return D.RescueTarget(bot, lane, loc, target) ~= nil
end

function D.Priority(bot, lane, loc)
    if not D.Active() then return 0 end
    local _, score = D.RescueTarget(bot, lane, loc)
    return math.max(0, score)
end

return D
