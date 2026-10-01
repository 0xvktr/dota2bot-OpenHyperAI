-- Pos 5 creep pulls (FunLib/lane_pull.lua): the equilibrium trigger, timed departure, the hit, the commit while
-- a ranged attack is in flight, the drag and the abort cases. Tier 1 tower positions come from the map entity
-- file (docs/map/map_data.json).
package.path = './?.lua;'..package.path
function GetScriptDirectory() return 'bots' end

local function V(x, y, z) return { x = x, y = y, z = z or 0 } end
Vector = V
TEAM_RADIANT, TEAM_DIRE = 2, 3
LANE_TOP, LANE_MID, LANE_BOT = 1, 2, 3
TOWER_TOP_1, TOWER_BOT_1 = 0, 2
UNIT_LIST_ENEMY_HEROES, UNIT_LIST_ALLIED_HEROES = 1, 2

local team, now = TEAM_RADIANT, 0
function GetTeam() return team end
function GetOpposingTeam() return team == TEAM_RADIANT and TEAM_DIRE or TEAM_RADIANT end
function DotaTime() return now end
local towers = {
    [TEAM_RADIANT] = { [TOWER_BOT_1] = V(4860, -6379), [TOWER_TOP_1] = V(-6336, 1856) },
    [TEAM_DIRE] = { [TOWER_BOT_1] = V(6269, -2240), [TOWER_TOP_1] = V(-5275, 6036) },
}
function GetTower(t, id) local v = towers[t][id]; return v and { GetLocation = function() return v end } end
local front = V(0, 0)
function GetLaneFrontLocation() return front end
local enemies, allies = {}, {}
function GetUnitList(kind) return kind == UNIT_LIST_ENEMY_HEROES and enemies or allies end

local J = {
    IsValidHero = function(u) return u ~= nil end, IsValid = function(u) return u ~= nil end,
    IsSuspiciousIllusion = function(u) return u.illusion == true end,
    GetPosition = function(b) return b.pos end, IsRetreating = function() return false end,
    GetHP = function(b) return b.hp end, CanNotUseAction = function() return false end,
}
package.loaded['bots/FunLib/jmz_func'] = J

-- Units ------------------------------------------------------------------------------------------------
local function Hero(x, y, opts)
    local h = { loc = V(x, y), hurt = false, hp = 1 }
    for k, v in pairs(opts or {}) do h[k] = v end
    function h:GetLocation() return self.loc end
    function h:WasRecentlyDamagedByAnyHero() return self.hurt end
    function h:GetAttackTarget() return self.target end
    function h:IsHero() return true end
    function h:IsIllusion() return self.illusion == true end
    return h
end
local neutrals = {}
local function Neutral(x, y) local n = { loc = V(x, y) }
    function n:GetLocation() return self.loc end
    function n:IsAlive() return true end
    function n:GetAttackTarget() return self.target end
    return n
end
local kobold = Neutral(3980, -5030)

local orders = {}
local LANE_SPOT = V(4200, -6300)   -- in lane just below the camp: ~4 s walk to the hit spot
local PUSHED_SPOT = V(6044, -3978) -- where the bot stood in the 2026-10-01 test game: ~10 s walk
local bot = Hero(LANE_SPOT.x, LANE_SPOT.y, { pos = 5, lane = LANE_BOT, creepHit = false })
function bot:IsAlive() return true end
function bot:GetAssignedLane() return self.lane end
function bot:GetCurrentMovementSpeed() return 300 end
function bot:WasRecentlyDamagedByCreep() return self.creepHit end
function bot:GetNearbyNeutralCreeps() return neutrals end
function bot:Action_MoveToLocation(v) table.insert(orders, { 'move', v }) end
function bot:Action_AttackUnit(u) table.insert(orders, { 'attack', u }); self.target = u end
function bot:ActionImmediate_Chat(msg, all) table.insert(orders, { 'chat', msg, all }) end

local P = dofile('bots/FunLib/lane_pull.lua')
local radiant = P.GetSpot(TEAM_RADIANT)
-- Scenario times are relative to the first pull second after 1:00, so tuning the seconds does not break them.
local S = 60 + radiant.seconds[1]
local DS = 60 + P.GetSpot(TEAM_DIRE).seconds[1]
local function last() return orders[#orders] end
local function near(v, w, r) return math.abs(v.x - w.x) <= (r or 1) and math.abs(v.y - w.y) <= (r or 1) end
local function reset(t, loc)
    bot.ohaPull, bot.target, orders = nil, nil, {}
    kobold.target = nil
    now = t
    if loc then bot.loc = V(loc.x, loc.y) end
end
-- Start a pull from the lane spot 5 s before the pull second.
local function start(loc) reset(S - 5, loc or LANE_SPOT); assert(P.Window(bot), 'pull should start'); end

-- 1. Pull seconds: Radiant pulls at xx:17 and xx:47, Dire at xx:18 and xx:48.
assert(P.SecondsToNextPull(radiant, 70) == 7 and P.SecondsToNextPull(radiant, 110) == 27, 'Radiant timing')
assert(P.SecondsToNextPull(P.GetSpot(TEAM_DIRE), 70) == 8, 'Dire pulls a second later')

-- 2. Equilibrium: closer to the enemy tier 1 than to ours.
reset(S - 5); front = V(6270, -5000) -- on the bottom lane, still closer to our tier 1
assert(not P.Window(bot), 'even lane: no pull')
front = V(6225, -4282) -- the user's equilibrium ping: ~460 past the midpoint between the tier 1 towers
assert(P.IsLanePushed(TEAM_RADIANT, radiant), 'the pinged equilibrium line counts as pushed')
front = V(6300, -3600)

-- 3. Timed departure: leave so the walk ends at the hit spot around the pull second, and walk straight there.
start()
assert(bot.ohaPull.phase == 'approach' and bot.ohaPull.second == S, 'pull for the next pull second')
assert(P.Think(bot) and orders[1][1] == 'chat' and orders[1][2] == 'Going to pull' and orders[1][3] == false, 'team chat once')
assert(last()[1] == 'move' and near(last()[2], radiant.hit), 'heads for the hit spot')
reset(S - 14, LANE_SPOT); assert(not P.Window(bot), 'a 4 s walk does not leave 14 s early')
local left
for t = S - 26, S, 0.25 do reset(t, PUSHED_SPOT); if P.Window(bot) then left = t; break end end
assert(left and left >= S - 13 and left <= S - 10, 'from the pushed lane it leaves ~11 s before the pull')
P.Think(bot)
assert(last()[1] == 'move' and near(last()[2], radiant.hit), 'straight to the hit spot: the engine finds the path')
reset(S - 2, PUSHED_SPOT); assert(not P.Window(bot), 'too far to make this pull: wait for the next one')

-- 4. Only pos 5, in its own lane, healthy, before 10:00, and never into enemies at the camp.
local function blocked(setup, undo, why) reset(S - 5, LANE_SPOT); setup(); assert(not P.Window(bot), why); undo() end
blocked(function() bot.pos = 4 end, function() bot.pos = 5 end, 'pos 4 does not pull')
blocked(function() bot.lane = LANE_MID end, function() bot.lane = LANE_BOT end, 'only from the safe lane')
blocked(function() bot.hp = 0.4 end, function() bot.hp = 1 end, 'not below half HP')
blocked(function() enemies = { Hero(4300, -5600) } end, function() enemies = {} end, 'not with an enemy hero at the camp')
reset(611, LANE_SPOT); assert(not P.Window(bot), 'no pulls after 10:00')
reset(480 + S - 5, LANE_SPOT); assert(P.Window(bot), 'still pulling after 9:00')

-- 5. Lane partner: ordinary harass is not a fight; being low and hit, or dropping fast, is.
local carry = Hero(4600, -6200, { hurt = true, hp = 0.9 }); allies = { bot, carry }
start()
carry.hp = 0.6; reset(S - 5, LANE_SPOT); assert(not P.Window(bot), 'partner under 70% and being hit: stay')
carry.hp, carry.hurt = 0.95, false
start(); carry.hp = 0.75; now = S - 3.5
assert(not P.Window(bot) and bot.ohaPull == nil, 'partner dropping 20% in 1.5 s: abort before the hit')
allies = {}

-- 6. Illusions and enemies in the lane do not stop the pull.
enemies = { Hero(4300, -5600, { illusion = true }) }; start()
enemies = { Hero(4300, -7600) }; start() -- an enemy laner 1300 from the support, far from the camp
enemies = {}

-- 7. Well ahead of schedule: hold instead of walking into the camp early; then go in.
start(); bot.loc = V(4150, -5700) -- 1.7 s from the hit spot with 5 s left
P.Think(bot)
assert(near(last()[2], bot.loc), 'ahead of schedule: hold')
now = S - 2.4; P.Think(bot)
assert(near(last()[2], radiant.hit), '2.4 s left: walk in')

-- 8. Ranged hit: attack at the pull second, stay committed while the projectile flies, then drag.
neutrals = { kobold }
start(); bot.loc = V(radiant.hit.x, radiant.hit.y)
now = S - 0.6; P.Think(bot); assert(last()[1] == 'move', 'no hit earlier than 0.3 s before the pull second')
now = S - 0.2; assert(P.Window(bot)); P.Think(bot)
assert(last()[1] == 'attack' and last()[2] == kobold and bot.ohaPull.attackTime == S - 0.2, 'hits the camp at the pull second')
now = S + 2.2; assert(P.Window(bot), 'attack in flight past the old 1.5 s window: still committed')
kobold.target = bot; P.Think(bot)
assert(bot.ohaPull.phase == 'drag' and near(last()[2], radiant.drag), 'camp turned: drag to the lane')
bot.loc = V(radiant.drag.x, radiant.drag.y); now = S + 6; assert(P.Window(bot)); P.Think(bot)
assert(bot.ohaPull ~= nil and near(last()[2], radiant.drag), 'holds the drag spot while the camp still hits the support')
kobold.target = {} -- the neutrals switched to the allied wave
assert(P.Think(bot) == false and bot.ohaPull == nil, 'pull done')

-- 9. Attacked but the camp never turned: give up after the commit time.
start(); bot.loc = V(radiant.hit.x, radiant.hit.y); now = S; assert(P.Window(bot)); P.Think(bot)
now = S + 2.9; assert(P.Window(bot)); now = S + 3.2
assert(not P.Window(bot) and bot.ohaPull == nil, 'no aggro 3 s after the attack: abort')

-- 10. Walking in aggroed the camp by itself: that counts as the hit.
start(); kobold.target = bot; now = S - 2; assert(P.Window(bot)); P.Think(bot)
assert(bot.ohaPull.phase == 'drag' and near(last()[2], radiant.drag), 'early aggro: drag straight away')

-- 11. Trees hide the camp: walk to the hit spot to look; empty only when nothing is there.
neutrals = {}
start(); now = S + 0.1; assert(P.Window(bot)); P.Think(bot)
assert(bot.ohaPull ~= nil and near(last()[2], radiant.hit), 'no neutral in sight: walk to the hit spot')
bot.loc = V(radiant.hit.x, radiant.hit.y); P.Think(bot)
assert(bot.ohaPull == nil, 'at the hit spot and still nothing: the camp is empty')

-- 12. Never got a hit off: abort after the window.
start(); now = S + 2.4; assert(P.Window(bot)); now = S + 2.6
assert(not P.Window(bot) and bot.ohaPull == nil, 'missed window: abort')

-- 13. Dire pulls from the top-lane camp at its own pull second.
team, bot.lane = TEAM_DIRE, LANE_TOP
front = V(-4000, 6300)
reset(DS - 5, V(-3800, 6000)); assert(not P.Window(bot), 'Dire wave near its own tier 1: no pull')
front = V(-6200, 3500) -- pushed toward the Radiant top tier 1
reset(DS - 3.5, V(-3800, 6000)); assert(P.Window(bot) and bot.ohaPull.second == DS, 'Dire pull at its pull second')
P.Think(bot); assert(near(last()[2], P.GetSpot(TEAM_DIRE).hit), 'Dire heads for its hit spot')

print('Lane pull scenarios passed')
