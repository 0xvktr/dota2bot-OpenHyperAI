local J = require(GetScriptDirectory()..'/FunLib/jmz_func')
local EarlyDefense = require(GetScriptDirectory()..'/FunLib/early_lane_defense')
local F = {}

local function towerLane(id)
    if id == TOWER_TOP_1 or id == TOWER_TOP_2 or id == TOWER_TOP_3 then return LANE_TOP end
    if id == TOWER_MID_1 or id == TOWER_MID_2 or id == TOWER_MID_3 then return LANE_MID end
    return LANE_BOT
end

local function outerTowers()
    return { TOWER_TOP_1, TOWER_MID_1, TOWER_BOT_1, TOWER_TOP_2, TOWER_MID_2, TOWER_BOT_2 }
end

local function teamState()
    for i = 1, #GetTeamPlayers(GetTeam()) do
        local h = GetTeamMember(i)
        if h and not h:IsIllusion() then
            h.ohaDefenseState = h.ohaDefenseState or {}
            return h.ohaDefenseState
        end
    end
    return {}
end

local function situation(tower)
    local loc = tower:GetLocation()
    local defenders = {}
    for _, h in ipairs(J.GetAlliesNearLoc(loc, 1600)) do
        if J.IsValidHero(h) and h:IsAlive() and not h:IsIllusion() and J.GetHP(h) >= 0.4 then
            table.insert(defenders, h)
        end
    end
    local enemies = math.max(#J.GetEnemiesNearLoc(loc, 1800), #J.GetLastSeenEnemiesNearLoc(loc, 1800))
    return defenders, enemies
end

function F.CanDefendTower(bot, tower, id, arriving)
    if not tower or not tower:IsAlive() then return false end
    local defenders, enemies = situation(tower)
    local s = teamState()
    local record = s[id] or { defenders = {} }
    s[id] = record
    for _, h in ipairs(record.defenders) do
        if not h:IsAlive() and enemies >= 2 then record.lostUntil = DotaTime() + 35 end
    end
    record.defenders = defenders
    if enemies == 0 then return true end
    -- Do not count promised arrivals as survivors. A team already on site can
    -- re-establish a defense, but late individual TPs cannot erase a lost fight.
    if #defenders < enemies and DotaTime() < (record.lostUntil or 0) then return false end
    if J.GetHP(tower) < 0.3 then return false end
    if enemies >= 2 and J.GetNumOfAliveHeroes(false) <= 2 and #defenders < enemies then return false end
    local count, includesBot = #defenders, false
    for _, h in ipairs(defenders) do if h == bot then includesBot = true end end
    if not includesBot and arriving and J.GetHP(bot) >= 0.65 then count = count + 1 end
    if count < enemies then return false end
    if arriving then
        local incoming = 0
        for i = 1, #GetTeamPlayers(GetTeam()) do
            local h = GetTeamMember(i)
            local reservation = h and h.ohaDefenseTP
            if h ~= bot and h and h:IsAlive() and reservation and reservation.id == id
                and DotaTime() < reservation.expires
                and GetUnitToUnitDistance(h, tower) > 1600 then incoming = incoming + 1 end
        end
        if #defenders + incoming >= enemies + 1 then return false end
    end
    return true
end

function F.CanTeleportTo(bot, loc, purpose)
    if purpose == nil and EarlyDefense.Active() and EarlyDefense.IsDefenseMode(bot) then purpose = 'defense' end
    for _, id in ipairs(outerTowers()) do
        local tower = GetTower(GetTeam(), id)
        if tower and tower:IsAlive() and J.GetDistance(loc, tower:GetLocation()) < 1800 then
            local defensive = purpose == 'defense'
            if purpose == 'fight' then local _, enemies = situation(tower); defensive = enemies > 0 end
            if defensive and not EarlyDefense.Allow(bot, towerLane(id), tower:GetLocation()) then return false end
            return F.CanDefendTower(bot, tower, id, true)
        end
    end
    if purpose == 'defense' and EarlyDefense.Active() then
        -- An ally-save TP may target a creep, not a tower. Such a destination
        -- must not evade the early role gate. Home-lane and base returns stay
        -- available; foreign rescues require a live allied outer tower above.
        if J.GetDistance(loc, GetAncient(GetTeam()):GetLocation()) < 2500 then return true end
        for _, id in ipairs({TOWER_TOP_3, TOWER_MID_3, TOWER_BOT_3}) do
            local tower = GetTower(GetTeam(), id)
            if tower and tower:IsAlive() and J.GetDistance(loc, tower:GetLocation()) < 1800 then return true end
        end
        local lane = bot:GetAssignedLane()
        return lane ~= nil and lane ~= LANE_NONE and GetAmountAlongLane(lane, loc).distance < 1800
    end
    return true -- Base defense and safe farming destinations keep their own rules.
end

function F.RecordTeleport(bot, loc, purpose)
    bot.ohaDefenseTP = nil -- A later farming/base TP must not inherit an old defense.
    for _, id in ipairs(outerTowers()) do
        local tower = GetTower(GetTeam(), id)
        if tower and tower:IsAlive() and J.GetDistance(loc, tower:GetLocation()) < 1800 then
            local _, enemies = situation(tower)
            if enemies > 0 then
                if purpose == 'fight' then purpose = 'defense' end
                bot.ohaDefenseTP = { id = id, expires = DotaTime() + 8, purpose = purpose }
                if J.IsInLaningPhase() and not bot.ohaLaneRotation
                    and GetUnitToLocationDistance(bot, loc) > 3000 then
                    bot.ohaLaneRotation = { home = bot:GetAssignedLane(), destination = loc,
                        started = DotaTime(), phase = 'travel', lastCombat = DotaTime() }
                end
            end
            return
        end
    end
end

function F.CancelUnsafeTeleport(bot)
    local reservation = bot.ohaDefenseTP
    if not reservation or not bot:IsChanneling() then return false end
    local ability = bot:GetCurrentActiveAbility()
    if not ability or (ability:GetName() ~= 'item_tpscroll' and ability:GetName() ~= 'furion_teleportation') then return false end
    local tower = GetTower(GetTeam(), reservation.id)
    if not F.CanDefendTower(bot, tower, reservation.id, true)
        or (reservation.purpose == 'defense' and tower
            and not EarlyDefense.Allow(bot, towerLane(reservation.id), tower:GetLocation())) then
        bot:Action_ClearActions(true)
        bot.ohaDefenseTP, bot.ohaLaneRotation = nil, nil
        return true
    end
    return false
end

function F.DefendDesire(bot, lane, desire)
    local ids = lane == LANE_TOP and { TOWER_TOP_1, TOWER_TOP_2, TOWER_TOP_3 }
        or lane == LANE_MID and { TOWER_MID_1, TOWER_MID_2, TOWER_MID_3 }
        or { TOWER_BOT_1, TOWER_BOT_2, TOWER_BOT_3 }
    for index, id in ipairs(ids) do
        local tower = GetTower(GetTeam(), id)
        if tower and tower:IsAlive() then
            if index < 3 and GetUnitToUnitDistance(bot, tower) > 1800
                and not EarlyDefense.Allow(bot, lane, tower:GetLocation()) then return 0 end
            if index < 3 and not F.CanDefendTower(bot, tower, id, false) then return 0 end
            break
        end
    end
    return desire
end

function F.TeleportLocation(bot)
    if J.GetHP(bot) < 0.65 or J.GetMP(bot) < 0.3
        or bot:WasRecentlyDamagedByAnyHero(4)
        or #J.GetEnemiesNearLoc(bot:GetLocation(), 1600) > 0 then return nil end
    local best, bestScore = nil, -math.huge
    for _, id in ipairs({ TOWER_TOP_1, TOWER_MID_1, TOWER_BOT_1,
        TOWER_TOP_2, TOWER_MID_2, TOWER_BOT_2, TOWER_TOP_3, TOWER_MID_3, TOWER_BOT_3 }) do
        local tower = GetTower(GetTeam(), id)
        if tower and tower:IsAlive() and J.GetHP(tower) > 0.3
            and GetUnitToUnitDistance(bot, tower) > 3500 then
            local loc = tower:GetLocation()
            local enemies = #J.GetEnemiesNearLoc(loc, 1400)
            local allies, fighting = 0, 0
            for _, h in ipairs(J.GetAlliesNearLoc(loc, 1400)) do
                if J.IsValidHero(h) and h:IsAlive() and not h:IsIllusion() and J.GetHP(h) > 0.3 then
                    allies = allies + 1
                    if h:WasRecentlyDamagedByAnyHero(3) then fighting = fighting + 1 end
                end
            end
            -- Reinforce an actual fight, not an abandoned tower or a lost 1v5.
            local outer = id ~= TOWER_TOP_3 and id ~= TOWER_MID_3 and id ~= TOWER_BOT_3
            local minimum = outer and EarlyDefense.Active() and 1 or 2
            if enemies >= minimum and allies >= minimum and fighting > 0 and allies + 1 >= enemies then
                local ancient = GetAncient(GetTeam()):GetLocation()
                local direction = ancient - loc
                local landing = loc + direction:Normalized() * 450
                if #J.GetEnemiesNearLoc(landing, 700) == 0 then
                    local lane = towerLane(id)
                    local score = allies - enemies + fighting + EarlyDefense.Priority(bot, lane, loc)
                    if score > bestScore and F.CanTeleportTo(bot, landing, 'defense') then best, bestScore = landing, score end
                end
            end
        end
    end
    return best
end

return F
