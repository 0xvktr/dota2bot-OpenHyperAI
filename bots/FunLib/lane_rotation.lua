local J = require(GetScriptDirectory()..'/FunLib/jmz_func')
local EarlyDefense = require(GetScriptDirectory()..'/FunLib/early_lane_defense')
local R = {}

local function clear(bot)
    bot.ohaLaneRotation = nil
end

local function laneTower(lane, team)
    return GetTower(team, lane == LANE_TOP and TOWER_TOP_1 or lane == LANE_MID and TOWER_MID_1 or TOWER_BOT_1)
end

local function homeNeedsHelp(bot, r)
    if EarlyDefense.Active() and J.GetPosition(bot) >= 4 then return not EarlyDefense.HomeSafe(bot) end
    for i = 1, #GetTeamPlayers(GetTeam()) do
        local h = GetTeamMember(i)
        if h and h ~= bot and h:IsAlive() and J.IsCore(h) and h:GetAssignedLane() == r.home then
            if J.GetHP(h) < 0.5 or h:WasRecentlyDamagedByAnyHero(3) then return true end
        end
    end
    return false
end

local function pushOpportunity(bot)
    local best, distance = nil, 2500
    for _, lane in ipairs({ LANE_TOP, LANE_MID, LANE_BOT }) do
        local tower = laneTower(lane, GetOpposingTeam())
        if tower and tower:IsAlive() and not tower:IsInvulnerable() then
            local d = GetUnitToUnitDistance(bot, tower)
            if d < distance and #J.GetLastSeenEnemiesNearLoc(tower:GetLocation(), 1800) <= 1 then
                local healthy, creeps = 0, 0
                for _, h in ipairs(J.GetAlliesNearLoc(tower:GetLocation(), 2000)) do
                    if J.IsValidHero(h) and h:IsAlive() and not h:IsIllusion() and J.GetHP(h) >= 0.6 then
                        healthy = healthy + 1
                    end
                end
                for _, creep in ipairs(bot:GetNearbyLaneCreeps(1600, false)) do
                    if creep:IsAlive() and GetUnitToUnitDistance(creep, tower) < 1000 then creeps = creeps + 1 end
                end
                if healthy >= 3 and creeps >= 3 then best, distance = lane, d end
            end
        end
    end
    return best
end

function R.Get(bot)
    local r = bot.ohaLaneRotation
    if not r then return nil end
    if not bot:IsAlive() or not J.IsInLaningPhase() or DotaTime() - r.started > 150 then
        clear(bot); return nil
    end
    if r.phase == 'travel' then
        if GetUnitToLocationDistance(bot, r.destination) < 1600 then
            r.phase, r.lastCombat = 'assist', DotaTime()
        elseif DotaTime() - r.started > 15 then clear(bot) end
        return nil
    end
    if bot:WasRecentlyDamagedByAnyHero(3) or #J.GetEnemiesNearLoc(bot:GetLocation(), 1400) > 0 then
        r.lastCombat = DotaTime()
        return nil -- Fighting/retreating takes precedence over returning to lane.
    end
    if J.GetHP(bot) < 0.45 then return nil end
    if r.phase == 'assist' then
        if DotaTime() - r.lastCombat < 8 then return nil end
        local lane = not homeNeedsHelp(bot, r) and pushOpportunity(bot) or nil
        if lane then
            r.phase, r.lane, r.pushUntil = 'push', lane, DotaTime() + 20
        else r.phase = 'return' end
    end
    if r.phase == 'push' then
        local tower = laneTower(r.lane, GetOpposingTeam())
        if DotaTime() >= r.pushUntil or homeNeedsHelp(bot, r) or not tower or not tower:IsAlive()
            or pushOpportunity(bot) ~= r.lane then r.phase = 'return' end
    end
    if r.phase == 'return' then
        r.loc = GetLaneFrontLocation(GetTeam(), r.home, -600)
        -- Return behind our tower if the old lane itself is no longer safe.
        if #J.GetLastSeenEnemiesNearLoc(r.loc, 1400) > #J.GetAlliesNearLoc(r.loc, 1400) + 1 then
            local tower = laneTower(r.home, GetTeam())
            r.loc = tower and tower:IsAlive() and tower:GetLocation() or J.GetTeamFountain()
            r.loc = J.Utils.GetOffsetLocationTowardsTargetLocation(r.loc, J.GetTeamFountain(), 650)
        end
        if GetUnitToLocationDistance(bot, r.loc) < 1000 then clear(bot); return nil end
    end
    return r
end

function R.ReturnDesire(bot)
    local r = R.Get(bot)
    return r and r.phase == 'return' and 0.88 or 0
end

function R.ThinkReturn(bot)
    local r = R.Get(bot)
    if not r or r.phase ~= 'return' or J.CanNotUseAction(bot) then return false end
    -- Ordinary Bot API gate activation is currently unverified. Do not send a
    -- bot to a gate it cannot use. Item logic may choose an available safe TP.
    bot:Action_MoveToLocation(r.loc)
    return true
end

function R.PushDesire(bot, lane)
    local r = R.Get(bot)
    if not r then return nil end
    return r.phase == 'push' and r.lane == lane and 0.9 or 0
end

function R.ReturnTP(bot)
    local r = R.Get(bot)
    if not r or r.phase ~= 'return' or GetUnitToLocationDistance(bot, r.loc) < 4500 then return nil end
    local loc = J.GetNearbyLocationToTp(r.loc)
    if loc and J.GetDistance(loc, r.loc) < 1800 and GetUnitToLocationDistance(bot, loc) > 3500 then return loc end
end

function R.CapRoutineDesire(bot, desire)
    if desire < 1 and R.Get(bot) then return math.min(desire, 0.45) end
    return desire
end

return R
