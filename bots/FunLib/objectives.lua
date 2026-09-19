-- Team assignments shared through a real allied hero, like the existing rune state.
-- No server-side APIs or FretBots dependency. Humans count physically, never as
-- promised participants merely because they are alive.
local J = require(GetScriptDirectory()..'/FunLib/jmz_func')
local Locations = require(GetScriptDirectory()..'/FunLib/objective_locations')
local Settings = require(GetScriptDirectory()..'/FunLib/objective_settings')
local O = {}
O.Debug = false

local function realHero(h)
    return J.IsValidHero(h) and h:IsAlive() and not h:IsIllusion()
        and not J.IsMeepoClone(h) and not h:HasModifier('modifier_arc_warden_tempest_double')
end

local function members()
    local result = {}
    for i = 1, #GetTeamPlayers(GetTeam()) do
        local h = GetTeamMember(i)
        if realHero(h) then table.insert(result, h) end
    end
    return result
end

local function state()
    -- Use the same owner even while dead, so death does not discard assignments.
    for i = 1, #GetTeamPlayers(GetTeam()) do
        local h = GetTeamMember(i)
        if h ~= nil and not h:IsIllusion() then
            h.ohaObjectives = h.ohaObjectives or { collections = {}, cooldowns = {}, lastUpdate = -100 }
            return h.ohaObjectives
        end
    end
end

local function log(message)
    if O.Debug then print('[Objectives] '..message) end
end

function O.BaseThreatened()
    local ancient = GetAncient(GetTeam())
    if ancient and #J.GetLastSeenEnemiesNearLoc(ancient:GetLocation(), 3200) > 0 then return true end
    for _, id in ipairs({ TOWER_TOP_2, TOWER_MID_2, TOWER_BOT_2, TOWER_TOP_3, TOWER_MID_3, TOWER_BOT_3 }) do
        local tower = GetTower(GetTeam(), id)
        if tower and tower:IsAlive() and #J.GetLastSeenEnemiesNearLoc(tower:GetLocation(), 1400) >= 2 then
            return true
        end
    end
    return false
end

local function safe(h)
    return realHero(h) and J.GetHP(h) >= 0.55
        and not h:WasRecentlyDamagedByAnyHero(3)
        and not h:WasRecentlyDamagedByTower(2)
        and not J.IsInTeamFight(h, 1200)
end

local function bossReady(h, executing)
    return realHero(h) and J.GetHP(h) >= (executing and 0.35 or 0.75)
        and not h:WasRecentlyDamagedByAnyHero(4)
        and not h:WasRecentlyDamagedByTower(2)
        and #J.GetLastSeenEnemiesNearLoc(h:GetLocation(), 1400) == 0
end

local function planReady(h, p)
    if p.kind == 'roshan' or p.kind == 'tormentor' then return bossReady(h, p.phase == 'execute') end
    return safe(h)
end

local function safeLocation(h, loc, steal)
    local enemies = #J.GetLastSeenEnemiesNearLoc(loc, 1200)
    local allies = #J.GetAlliesNearLoc(loc, 1600)
    if steal then return enemies == 0 and J.GetHP(h) >= 0.75 end
    return enemies == 0 or (allies > enemies and J.GetHP(h) >= 0.7)
end

local function hasItemSpace(h)
    for slot = 0, 8 do
        if h:GetItemInSlot(slot) == nil then return true end
    end
    return false
end

local function lotusCount(h)
    local count = 0
    local values = { item_famango = 1, item_great_famango = 3, item_greater_famango = 6 }
    for slot = 0, 8 do
        local item = h:GetItemInSlot(slot)
        if item and values[item:GetName()] then
            count = count + values[item:GetName()] * math.max(1, item:GetCurrentCharges())
        end
    end
    return count
end

local function collection(s, key, period, loc, kind, lead, steal)
    local now = DotaTime()
    local cycle = math.floor((now + lead) / period)
    if cycle < 1 then return nil end
    local c = s.collections[key]
    if c == nil or c.cycle ~= cycle then
        c = { key = key, cycle = cycle, spawn = cycle * period, loc = loc, kind = kind, steal = steal }
        s.collections[key] = c
    end
    return c
end

local function eligibleCollector(h, c)
    if not safe(h) or not h:IsBot() or not safeLocation(h, c.loc, c.steal) then return false end
    if c.kind == 'lotus' and not hasItemSpace(h) then return false end
    if c.kind == 'wisdom' and h:GetLevel() >= 30 then return false end
    local distance = GetUnitToLocationDistance(h, c.loc)
    -- After the spawn window, only inspect pools we are already passing.
    if c.kind == 'lotus' and DotaTime() > c.spawn + 35 and distance > 500 then return false end
    local limit = c.kind == 'lotus' and 2400 or (c.steal and 2000 or 6500)
    if distance > limit then return false end
    if c.kind == 'wisdom' and J.GetPosition(h) <= 3 and distance > 1800 then return false end
    -- Start travel just early enough; never idle at a pool for most of a minute.
    local travel = distance / math.max(200, h:GetCurrentMovementSpeed()) + 4
    return DotaTime() >= c.spawn - math.min(c.kind == 'lotus' and 12 or 30, travel)
end

local function assignCollector(c)
    if c.serviced or (c.retryAt and DotaTime() < c.retryAt) then return end
    if c.owner and DotaTime() >= c.expires then
        c.owner, c.arrived = nil, nil
        c.retryAt = DotaTime() + 15
        return
    end
    -- Respect a human actually collecting, not a human farming 2000 units away.
    for _, h in ipairs(members()) do
        if not h:IsBot() and GetUnitToLocationDistance(h, c.loc) < 250 then
            c.owner, c.arrived = nil, nil
            return
        end
    end
    if c.owner and eligibleCollector(c.owner, c) and DotaTime() < c.expires then return end
    c.owner, c.arrived, c.lastThink = nil, nil, nil
    local best = math.huge
    for _, h in ipairs(members()) do
        if eligibleCollector(h, c) then
            local score = GetUnitToLocationDistance(h, c.loc)
            if J.GetPosition(h) <= 3 then score = score + (c.kind == 'wisdom' and 10000 or 600) end
            score = score + h:GetPlayerID() * 0.001
            if score < best then c.owner, best = h, score end
        end
    end
    if c.owner then
        c.expires = math.max(DotaTime(), c.spawn) + 45
        log(c.key..' assigned to '..c.owner:GetUnitName())
    end
end

function O.CollectionDesire(bot)
    bot.ohaCollection = nil
    if not safe(bot) or O.BaseThreatened() then return 0 end
    local s = state()
    if not s or O.GetPlan(bot) then return 0 end
    local candidates = {}
    local own = collection(s, 'wisdom-own', 420, Locations.wisdom[GetTeam()], 'wisdom', 30, false)
    if own then table.insert(candidates, own) end
    -- Stealing is opportunistic and never replaces securing our own shrine.
    if own and own.serviced then
        table.insert(candidates, collection(s, 'wisdom-enemy', 420, Locations.wisdom[GetOpposingTeam()], 'wisdom', 0, true))
    end
    for _, key in ipairs({ 'top', 'bot' }) do
        local c = collection(s, 'lotus-'..key, 180, Locations.lotus[key], 'lotus', 12, false)
        if c then table.insert(candidates, c) end
    end
    for _, c in ipairs(candidates) do
        assignCollector(c)
        if not c.serviced and c.owner == bot then
            bot.ohaCollection = c
            return c.kind == 'wisdom' and 0.96 or (J.GetPosition(bot) > 3 and 0.94 or 0.86)
        end
    end
    return 0
end

function O.CollectionThink(bot)
    local c = bot.ohaCollection
    if not c or c.serviced or c.owner ~= bot then return false end
    local now = DotaTime()
    if not safe(bot) or O.BaseThreatened() or not safeLocation(bot, c.loc, c.steal) then
        c.owner, c.arrived = nil, nil
        c.retryAt = now + 5
        return false
    end
    if c.lastThink and now - c.lastThink > 1 then c.arrived = nil end
    c.lastThink = now
    if GetUnitToLocationDistance(bot, c.loc) > 180 then
        c.arrived = nil
        bot:Action_MoveToLocation(c.loc)
        return true
    end
    -- Opponents reverse the timer: never count contested time as collection.
    if now < c.spawn or #J.GetEnemiesNearLoc(c.loc, 350) > 0 then
        c.arrived = nil
        bot:Action_ClearActions(false)
        return true
    end
    local count = c.kind == 'lotus' and lotusCount(bot) or 0
    if not c.arrived then c.arrived, c.count, c.lastPickup = now, count, now end
    if count > c.count then c.lastPickup, c.count = now, count end
    -- There is no reliable stock API. A bounded uncontested inspection avoids
    -- camping an empty pool; a new spawn always permits another visit.
    local done = c.kind == 'wisdom' and now - c.arrived >= 4
        or c.kind == 'lotus' and (now - c.lastPickup >= 3 or now - c.arrived >= 10 or not hasItemSpace(bot))
    if done then
        c.serviced, c.owner = true, nil
        bot.ohaCollection = nil
        log(c.key..' serviced (collection/empty inspection)')
        return false
    end
    bot:Action_ClearActions(false)
    return true
end

local function cancel(s, reason, cooldown)
    if s.plan then
        log(s.plan.kind..' ended: '..reason)
        s.cooldowns[s.plan.kind] = DotaTime() + (cooldown or 45)
        s.plan = nil
    end
end

local function healthyTeam()
    local result, cores = {}, 0
    for _, h in ipairs(members()) do
        if safe(h) then
            table.insert(result, h)
            if J.IsCore(h) then cores = cores + 1 end
        end
    end
    return result, cores
end

local function chooseLane(heroes)
    local bestLane, bestScore = LANE_MID, math.huge
    for _, lane in ipairs({ LANE_MID, LANE_TOP, LANE_BOT }) do
        local front = GetLaneFrontLocation(GetTeam(), lane, 0)
        local score = 0
        for _, h in ipairs(heroes) do score = score + GetUnitToLocationDistance(h, front) end
        score = score / math.max(1, #heroes)
        score = score + #J.GetLastSeenEnemiesNearLoc(front, 1800) * 1200
        if score < bestScore then bestLane, bestScore = lane, score end
    end
    return bestLane
end

local function newPlan(s, kind, loc, heroes, needed, lane, powerplay)
    local participants, leader, coreCount = {}, nil, 0
    for _, h in ipairs(heroes) do
        if h:IsBot() or GetUnitToLocationDistance(h, loc) < 2500 then
            participants[h:GetPlayerID()] = true
            if J.IsCore(h) then coreCount = coreCount + 1 end
            if h:IsBot() and (not leader or h:GetPlayerID() < leader:GetPlayerID()) then leader = h end
        end
    end
    local count = 0
    for _ in pairs(participants) do count = count + 1 end
    if count < needed or not leader then return end
    if (kind == 'roshan' or kind == 'tormentor') and coreCount < 2 then return end
    s.plan = { kind = kind, loc = loc, lane = lane, participants = participants,
        needed = needed, leader = leader, started = DotaTime(), expires = DotaTime() + 60,
        powerplay = powerplay, preferred = math.min(5, count), phase = 'assemble' }
    log(kind..' assembly started')
end

function O.GetPlan(bot)
    local s = state()
    if not s then return nil end
    local now = DotaTime()
    if now - s.lastUpdate >= 0.5 then
        s.lastUpdate = now
        local heroes, cores = healthyTeam()
        local allies, enemies = J.GetNumOfAliveHeroes(false), J.GetNumOfAliveHeroes(true)
        local threat = O.BaseThreatened()
        local p = s.plan
        if p then
            if p.kind == 'regroup' and realHero(p.anchor) then p.loc = p.anchor:GetLocation() end
            local available = 0
            for _, h in ipairs(members()) do
                if p.participants[h:GetPlayerID()] and planReady(h, p) then available = available + 1 end
            end
            if threat or now > p.expires or available < p.needed or allies < enemies
                or (p.kind == 'regroup' and not safe(p.anchor))
                or (p.powerplay and allies - enemies < 2)
                or (p.kind == 'roshan' and (not J.IsRoshanAlive()
                    or J.GetDistance(p.loc, J.GetCurrentRoshanLocation()) > 3000))
                or (p.kind == 'tormentor' and J.GetDistance(p.loc, J.GetTormentorLocation(GetTeam())) > 3000) then
                cancel(s, 'expired, unsafe, or opportunity ended')
            elseif (p.kind == 'roshan' or p.kind == 'tormentor') and #J.GetLastSeenEnemiesNearLoc(p.loc, 1800) > 0 then
                cancel(s, 'boss area contested')
            end
        elseif not threat and now >= 12 * 60 and #heroes >= 3 and cores >= 1 and allies >= enemies then
            local powerplay = enemies <= 3 and allies - enemies >= 2
            local ready = function(kind) return now >= (s.cooldowns[kind] or 0) end
            if powerplay and ready('push') then
                local lane = chooseLane(heroes)
                newPlan(s, 'push', GetLaneFrontLocation(GetTeam(), lane, -700), heroes, math.min(3, #heroes), lane, true)
            elseif ready('tormentor') and now >= (J.IsModeTurbo() and 10 or 20) * 60
                and #heroes >= 4 and cores >= 2 and now >= (s.tormentorNext or 0) then
                local loc = J.GetTormentorLocation(GetTeam())
                local eligible = {}
                for _, h in ipairs(heroes) do
                    if bossReady(h, false) and h:GetLevel() >= (J.IsCore(h) and 12 or 8) and GetUnitToLocationDistance(h, loc) < 7000 then
                        table.insert(eligible, h)
                    end
                end
                if #J.GetLastSeenEnemiesNearLoc(loc, 1800) == 0 then newPlan(s, 'tormentor', loc, eligible, 4) end
            end
            local roshanTime = Settings.RoshanMinTime
            if Settings.AllowEarlyRoshan then
                for _, h in ipairs(heroes) do
                    if Settings.EarlyRoshanHeroes[h:GetUnitName()] and bossReady(h, false)
                        and GetUnitToLocationDistance(h, J.GetCurrentRoshanLocation()) < (h:IsBot() and 6500 or 2500) then
                        roshanTime = Settings.EarlyRoshanMinTime
                    end
                end
            end
            if not s.plan and ready('roshan') and now >= roshanTime and cores >= 2
                and J.IsRoshanAlive() and not J.IsRoshanCloseToChangingSides() then
                local loc, eligible = J.GetCurrentRoshanLocation(), {}
                for _, h in ipairs(heroes) do
                    if bossReady(h, false) and (h:IsBot() or GetUnitToLocationDistance(h, loc) < 2500)
                        and GetUnitToLocationDistance(h, loc) < 6500 then table.insert(eligible, h) end
                end
                if #eligible >= 3 and J.HasEnoughDPSForRoshan(eligible)
                    and #J.GetLastSeenEnemiesNearLoc(loc, 1800) == 0 then newPlan(s, 'roshan', loc, eligible, 3) end
            end
            if not s.plan and ready('push') and now >= 20 * 60 and #heroes >= 4 then
                local ourGold, theirGold = J.GetInventoryNetworth()
                if J.DoesTeamHaveAegis() or ourGold > theirGold * 1.15 then
                    local lane = chooseLane(heroes)
                    newPlan(s, 'push', GetLaneFrontLocation(GetTeam(), lane, -700), heroes, 3, lane, false)
                end
            end
            if not s.plan and ready('regroup') and now >= 20 * 60 then
                local anchor
                for _, h in ipairs(heroes) do
                    if J.IsCore(h) and GetUnitToLocationDistance(h, GetAncient(GetTeam()):GetLocation()) > 3000
                        and (not anchor or J.GetPosition(h) < J.GetPosition(anchor)) then anchor = h end
                end
                if anchor and #J.GetAlliesNearLoc(anchor:GetLocation(), 1400) < 3
                    and safeLocation(anchor, anchor:GetLocation(), false) then
                    local nearby = {}
                    for _, h in ipairs(heroes) do
                        if GetUnitToUnitDistance(h, anchor) < 6500 then table.insert(nearby, h) end
                    end
                    newPlan(s, 'regroup', anchor:GetLocation(), nearby, 3)
                    if s.plan then
                        s.plan.anchor, s.plan.expires = anchor, now + 25
                    end
                end
            end
        end
    end
    local p = s.plan
    if p and p.participants[bot:GetPlayerID()] and planReady(bot, p) and bot ~= p.anchor then return p end
    return nil
end

function O.PlanDesire(bot, kind, lane)
    local p = O.GetPlan(bot)
    if not p or p.kind ~= kind or (lane and p.lane ~= lane) then return 0 end
    return 0.92
end

function O.CapRoutineDesire(bot, desire)
    -- Only suppress routine activity, never an emergency/dodge or ongoing fight.
    if desire >= 1 then return desire end
    if O.GetPlan(bot) then return math.min(desire, 0.45) end
    return desire
end

function O.PlanThink(bot, kind)
    local p = O.GetPlan(bot)
    if not p or p.kind ~= kind then return false end
    local s = state()
    -- Recheck threats without the shared half-second cache before issuing chat
    -- or actions. A chased participant must not call teammates into a boss.
    if kind == 'roshan' or kind == 'tormentor' then
        for _, h in ipairs(members()) do
            if p.participants[h:GetPlayerID()] and (h:WasRecentlyDamagedByAnyHero(4)
                or #J.GetLastSeenEnemiesNearLoc(h:GetLocation(), 1400) > 0) then
                cancel(s, 'participant under attack', 45)
                return false
            end
        end
    end
    local nearby, nearbyCores = 0, 0
    for _, h in ipairs(members()) do
        if planReady(h, p) and GetUnitToLocationDistance(h, p.loc) < 1000 then
            nearby = nearby + 1
            if J.IsCore(h) then nearbyCores = nearbyCores + 1 end
        end
    end
    if not p.announced and bot == p.leader then
        p.announced = true
        J.ModeAnnounce(bot, kind == 'roshan' and 'say_roshan' or 'say_assemble', 60)
        bot:ActionImmediate_Ping(p.loc.x, p.loc.y, true)
    end
    if kind == 'regroup' then
        if nearby >= p.needed then cancel(s, 'group assembled', 30); return true end
    elseif kind == 'push' then
        if p.phase == 'assemble' and nearby >= p.needed then p.phase = 'execute' end
        if p.phase == 'execute' then
            -- Regroup on an allied participant if we were left behind; do not
            -- turn a team push into five independent walks up high ground.
            local group, closest, distance = 0, nil, math.huge
            for _, h in ipairs(members()) do
                if p.participants[h:GetPlayerID()] then
                    local d = GetUnitToUnitDistance(bot, h)
                    if d < 1600 then group = group + 1 end
                    if h ~= bot and d < distance then closest, distance = h, d end
                end
            end
            if group < p.needed and closest then
                bot:Action_MoveToLocation(closest:GetLocation())
                return true
            end
            bot.laneToPush = p.lane
            return false -- Existing push micro handles creeps, backdoor, towers and barracks.
        end
    else
        local target
        for _, unit in ipairs(bot:GetNearbyNeutralCreeps(1600)) do
            if J.IsValid(unit) and ((kind == 'roshan' and J.IsRoshan(unit))
                or (kind == 'tormentor' and J.IsTormentor(unit))) then target = unit; break end
        end
        if target then
            p.loc, p.target = target:GetLocation(), target
            p.seen = true
        elseif (p.target and (p.target:IsNull() or not p.target:IsAlive()))
            or (GetUnitToLocationDistance(bot, p.loc) < 300 and IsLocationVisible(p.loc)) then
            if kind == 'tormentor' then
                s.tormentorNext = DotaTime() + (p.seen and (J.IsModeTurbo() and 300 or 600) or 60)
            end
            cancel(s, 'boss killed or pit empty', 60)
            return true
        end
        local preferredReady = kind ~= 'tormentor' or nearby >= p.preferred
            or DotaTime() - p.started >= 20 or p.phase == 'execute'
        if target and nearby >= p.needed and nearbyCores >= 2 and preferredReady then
            if p.phase ~= 'execute' then
                p.phase, p.expires = 'execute', DotaTime() + 90
            end
            bot:SetTarget(target)
            -- Preserve attack windups and the hero/item callbacks' spell casts.
            if not J.CanNotUseAction(bot) and bot:GetAttackTarget() ~= target then
                bot:Action_AttackUnit(target, false)
            end
            return true
        end
        if p.phase == 'execute' then
            cancel(s, 'combat quorum lost', 60)
            return false
        end
    end
    if GetUnitToLocationDistance(bot, p.loc) > 350 then
        bot:Action_MoveToLocation(p.loc)
    else
        bot:Action_ClearActions(false)
    end
    return true
end

return O
