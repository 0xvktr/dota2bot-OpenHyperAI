-- Pos 5 creep pulls: when the safe-lane wave has pushed past equilibrium (closer to the enemy tier 1 than to
-- ours), the support drags the small camp next to our tier 1 onto the allied wave; the neutrals trade with
-- the wave and the lane resets toward our tower.
--
-- Runs as a short window inside mode_roam_generic (like support_last_hits), so Valve's default laning stays in
-- charge the rest of the time. Spots and seconds were measured in 7.41f lobbies with the ping recorder
-- (FunLib/debug_dumps.lua, TASK-32) and the route map (docs/map): where the hero stood when hitting the camp
-- and where the neutrals met the wave.
--
-- The support walks straight to the hit spot with the engine's pathfinding (from a pushed lane that is the gap
-- north of the camp), timed to arrive at the pull second, hits a neutral, and drags it to the lane.
local J = require(GetScriptDirectory()..'/FunLib/jmz_func')
local P = {}

P.Spots = {
    -- Radiant: small camp by the bottom tier 1 (spawner key 1 in tests/neutral_spawners_741f.lua).
    [TEAM_RADIANT] = { lane = LANE_BOT, camp = Vector(3978, -5026, 0),
        hit = Vector(4150, -5300, 0), drag = Vector(3950, -6220, 0), seconds = { 17, 47 } },
    -- Dire: small camp by the top tier 1 (key 26). The camp is closer to the lane, so the pull is a second later.
    [TEAM_DIRE] = { lane = LANE_TOP, camp = Vector(-3911, 4829, 0),
        hit = Vector(-4040, 5200, 0), drag = Vector(-3840, 5930, 0), seconds = { 18, 48 } },
}

P.PULL_UNTIL = 600      -- pulls are worth it through the laning phase, up to 10:00
P.MAX_LEAD = 25         -- never leave the lane earlier than this before the pull second
P.PATH_FACTOR = 1.25    -- real paths bend around trees: walking time = straight distance * this / speed
P.START_SLACK = 1       -- leave (and keep walking) while the walk would arrive at most this early
P.LATE_LIMIT = 1        -- do not start a pull that would arrive later than this after the pull second
P.HIT_LEAD = 0.3        -- attack this long before the pull second at the earliest
P.AGGRO_WINDOW = 2.5    -- without an attack issued by this long after the pull second, give up
P.COMMIT = 3            -- after attacking, wait this long for the camp to turn on the support (projectile flight)
P.ARRIVE_RADIUS = 150   -- close enough to a spot (trees make exact points unreachable)
P.DRAG_TIMEOUT = 8      -- give up holding the drag spot this long after the camp aggroed
P.DANGER_RADIUS = 1200  -- a visible real enemy hero this close to the camp (or to the support at the camp) cancels
P.PARTNER_SAFE_HP = 0.7 -- a lane partner above this HP who is not dropping fast is not "in a fight"
P.PARTNER_DROP = 0.15   -- losing this share of max HP within ~3 s counts as dropping fast

local SAFE_LANE_TOWER = { [LANE_BOT] = TOWER_BOT_1, [LANE_TOP] = TOWER_TOP_1 }

local function dist(a, b) return math.sqrt((a.x - b.x) ^ 2 + (a.y - b.y) ^ 2) end

function P.GetSpot(team) return P.Spots[team] end

-- Seconds the support needs to walk to `loc`.
function P.WalkTime(bot, loc)
    return dist(bot:GetLocation(), loc) * P.PATH_FACTOR / math.max(bot:GetCurrentMovementSpeed(), 100)
end

-- Seconds until the next pull second (0..60).
function P.SecondsToNextPull(spot, now)
    local sec = now % 60
    local best = nil
    for _, s in ipairs(spot.seconds) do
        local d = (s - sec) % 60
        if best == nil or d < best then best = d end
    end
    return best
end

-- The lane is past equilibrium when our wave front is closer to the enemy tier 1 than to ours.
function P.IsLanePushed(team, spot)
    local towerId = SAFE_LANE_TOWER[spot.lane]
    local ours, theirs = GetTower(team, towerId), GetTower(GetOpposingTeam(), towerId)
    if ours == nil or theirs == nil then return false end
    local front = GetLaneFrontLocation(team, spot.lane, 0)
    return dist(front, theirs:GetLocation()) < dist(front, ours:GetLocation())
end

-- Real (non-illusion) enemy heroes only: an illusion poking the lane is not a reason to stay.
local function enemyNear(loc)
    for _, enemy in pairs(GetUnitList(UNIT_LIST_ENEMY_HEROES)) do
        if J.IsValidHero(enemy) and not J.IsSuspiciousIllusion(enemy)
            and dist(enemy:GetLocation(), loc) <= P.DANGER_RADIUS then return true end
    end
    return false
end

-- HP samples per allied hero, refreshed every ~3 s, to spot a fast drop.
local tHpSample = {}
local function droppingFast(ally, now)
    local hp, sample = J.GetHP(ally), tHpSample[ally]
    if sample == nil or now - sample.time > 3 then
        tHpSample[ally] = { time = now, hp = hp }
        return sample ~= nil and now - sample.time <= 3.5 and sample.hp - hp >= P.PARTNER_DROP
    end
    return sample.hp - hp >= P.PARTNER_DROP
end

-- The lane partner needs the support: low and being hit by heroes, or losing HP fast. Ordinary harass on a
-- healthy partner is not a fight.
local function partnerInTrouble(bot, now)
    for _, ally in pairs(GetUnitList(UNIT_LIST_ALLIED_HEROES)) do
        if ally ~= bot and J.IsValidHero(ally) and not ally:IsIllusion()
            and dist(ally:GetLocation(), bot:GetLocation()) <= 1600 then
            local dropping = droppingFast(ally, now)
            if dropping or (J.GetHP(ally) < P.PARTNER_SAFE_HP and ally:WasRecentlyDamagedByAnyHero(2)) then
                return true
            end
        end
    end
    return false
end

-- A pull needs a healthy support to start; once the camp is hitting it, it only gives up when low.
local function eligible(bot, spot, bStarting)
    local now = DotaTime()
    return spot ~= nil and bot:IsAlive() and not bot:IsIllusion()
        and J.GetPosition(bot) == 5 and now >= 60 and now < P.PULL_UNTIL
        and bot:GetAssignedLane() == spot.lane
        and not J.IsRetreating(bot) and J.GetHP(bot) > (bStarting and 0.5 or 0.3)
end

local function cancel(bot) bot.ohaPull = nil end

-- Called from roam GetDesire every frame. Starts a pull when its conditions hold and keeps it alive until it
-- finishes or is aborted. Returns true while the support should be pulling.
function P.Window(bot)
    local team = GetTeam()
    local spot = P.GetSpot(team)
    local pull = bot.ohaPull
    if not eligible(bot, spot, pull == nil) or J.CanNotUseAction(bot) then cancel(bot); return false end
    local now = DotaTime()

    if pull ~= nil then
        local expired
        if pull.phase == 'drag' then
            expired = now > pull.aggroTime + P.DRAG_TIMEOUT
        elseif pull.attackTime ~= nil then
            expired = now > pull.attackTime + P.COMMIT -- attacked, but the camp never turned on the support
        else
            expired = now > pull.second + P.AGGRO_WINDOW
        end
        -- Walking out of the lane, only the camp matters; at the camp, enemies around the support do too.
        local atCamp = dist(bot:GetLocation(), spot.camp) <= 900
        local danger = enemyNear(spot.camp)
            or (atCamp and (enemyNear(bot:GetLocation()) or bot:WasRecentlyDamagedByAnyHero(2)))
        -- Before the hit, a lane partner in trouble takes priority; after it the pull is committed.
        local trouble = pull.attackTime == nil and pull.phase ~= 'drag' and partnerInTrouble(bot, now)
        if expired or danger or trouble then cancel(bot); return false end
        return true
    end

    local untilPull = P.SecondsToNextPull(spot, now)
    if untilPull > P.MAX_LEAD then return false end
    -- Leave as late as possible: the walk should end at the hit spot around the pull second.
    local walk = P.WalkTime(bot, spot.hit)
    if untilPull > walk + P.START_SLACK or untilPull < walk - P.LATE_LIMIT then return false end
    if not P.IsLanePushed(team, spot) then return false end
    if partnerInTrouble(bot, now) or enemyNear(spot.camp) then return false end

    bot.ohaPull = { phase = 'approach', second = now + untilPull, announced = false }
    return true
end

-- The neutral to hit: the nearest visible one around the pull camp.
local function campNeutral(bot, spot)
    local best, bestDist
    for _, creep in pairs(bot:GetNearbyNeutralCreeps(1200)) do
        if J.IsValid(creep) and creep:IsAlive() and dist(creep:GetLocation(), spot.camp) <= 600 then
            local d = dist(creep:GetLocation(), bot:GetLocation())
            if bestDist == nil or d < bestDist then best, bestDist = creep, d end
        end
    end
    return best
end

local function neutralsOnMe(bot)
    if bot:WasRecentlyDamagedByCreep(0.5) then return true end
    for _, creep in pairs(bot:GetNearbyNeutralCreeps(1200)) do
        if J.IsValid(creep) and creep:GetAttackTarget() == bot then return true end
    end
    return false
end

-- Called from roam Think while P.Window holds. Returns true when it issued an order.
function P.Think(bot)
    local pull, spot = bot.ohaPull, P.GetSpot(GetTeam())
    if pull == nil or spot == nil then return false end
    local now = DotaTime()

    if not pull.announced then
        pull.announced = true
        bot:ActionImmediate_Chat('Going to pull', false)
    end

    if pull.phase == 'approach' then
        if neutralsOnMe(bot) then
            -- Walking in can aggro the camp by itself; that is a hit all the same.
            pull.phase, pull.aggroTime = 'drag', now
        elseif now >= pull.second - P.HIT_LEAD then
            local neutral = campNeutral(bot, spot)
            if neutral ~= nil then
                if pull.attackTime == nil then pull.attackTime = now end
                if bot:GetAttackTarget() ~= neutral then bot:Action_AttackUnit(neutral, true) end
                return true
            end
            -- Nothing in sight (trees): walk to the hit spot to see the camp. Empty only if nothing is there.
            if dist(bot:GetLocation(), spot.hit) > P.ARRIVE_RADIUS then
                bot:Action_MoveToLocation(spot.hit)
                return true
            end
            cancel(bot)
            return false
        else
            -- Not yet time: head for the hit spot, but do not arrive early and stand in the camp.
            local remaining = pull.second - now
            if dist(bot:GetLocation(), spot.hit) > P.ARRIVE_RADIUS and P.WalkTime(bot, spot.hit) >= remaining - P.START_SLACK then
                bot:Action_MoveToLocation(spot.hit)
            else
                bot:Action_MoveToLocation(bot:GetLocation())
            end
            return true
        end
    end

    if pull.phase == 'drag' then
        if dist(bot:GetLocation(), spot.drag) > P.ARRIVE_RADIUS then
            bot:Action_MoveToLocation(spot.drag)
            return true
        end
        -- At the drag spot: done once the neutrals switch to the allied wave.
        if not neutralsOnMe(bot) then cancel(bot); return false end
        bot:Action_MoveToLocation(spot.drag)
        return true
    end
    return false
end

return P
