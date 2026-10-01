-- Ancient Apparition ability logic: Cold Feet -> Ice Vortex combo order, the level-25 AoE Cold Feet
-- talent (unit-targeted, special_bonus_unique_ancient_apparition_1), Ice Blast radius growth
-- (radius_min + radius_grow * seconds travelled), the low-HP shatter snipe, and Ice Blast Release
-- timing under throttled ability thinks.
local H = dofile('tests/hero_harness.lua')
local bot, J = H.bot, H.J

local Vec = {}
Vec.__index = Vec
local function V(x, y) return setmetatable({ x = x, y = y, z = 0 }, Vec) end
Vec.__add = function(a, b) return V(a.x + b.x, a.y + b.y) end
Vec.__sub = function(a, b) return V(a.x - b.x, a.y - b.y) end
Vec.__mul = function(a, k) return V(a.x * k, a.y * k) end
function Vec:Length2D() return math.sqrt(self.x * self.x + self.y * self.y) end
function Vec:Normalized() local l = self:Length2D(); return V(self.x / l, self.y / l) end
local function dist(a, b) return (a - b):Length2D() end

BOT_ACTION_DESIRE_HIGH = 1; BOT_ACTION_DESIRE_NONE = 0; BOT_MODE_NONE = 0
DAMAGE_TYPE_MAGICAL = 1; UNIT_LIST_ENEMY_HEROES = 1
local now = 100
function DotaTime() return now end
local projectiles = {}
function GetLinearProjectiles() return projectiles end

-- World ------------------------------------------------------------------------------------------
local enemies = {}
local function Enemy(x, y, hp, maxHp)
    local e = { loc = V(x, y), hp = hp or 1000, maxHp = maxHp or 1000, mods = {}, disabled = false }
    function e:GetUnitName() return self.unit or 'npc_dota_hero_axe' end
    function e:GetLocation() return self.loc end
    function e:GetExtrapolatedLocation() return self.loc end
    function e:HasModifier(name) return self.mods[name] == true end
    function e:GetHealth() return self.hp end
    function e:GetMaxHealth() return self.maxHp end
    function e:GetActualIncomingDamage(dmg) return dmg * 0.75 end
    table.insert(enemies, e)
    return e
end
function GetUnitList() return enemies end
function GetUnitToUnitDistance(a, b) return dist(a:GetLocation(), b:GetLocation()) end
function GetUnitToLocationDistance(a, v) return dist(a:GetLocation(), v) end

local actions = {}
bot.loc = V(0, 0)
function bot:GetLocation() return self.loc end
function bot:GetNearbyTowers() return {} end
local laneCreeps = {}
function bot:GetNearbyLaneCreeps() return laneCreeps end
local botStunned = false
function bot:IsAlive() return true end
function bot:IsStunned() return botStunned end
function bot:IsHexed() return false end
function bot:IsNightmared() return false end
function bot:IsChanneling() return false end
function bot:Action_UseAbilityOnEntity(ability, target) table.insert(actions, { 'entity', ability.name, target }) end
function bot:Action_UseAbilityOnLocation(ability, loc) table.insert(actions, { 'location', ability.name, loc }) end
function bot:Action_UseAbility(ability) table.insert(actions, { 'none', ability.name }) end

-- Abilities (7.41f values at max level) ------------------------------------------------------------
local requested, trained, castable, hidden = {}, {}, {}, {}
local values = {
    ancient_apparition_cold_feet = { area_of_effect = 0 },
    ancient_apparition_ice_vortex = { radius = 275 },
    ancient_apparition_chilling_touch = { attack_range_bonus = 150, damage = 125 },
    ancient_apparition_ice_blast = { radius_min = 300, radius_grow = 50, radius_max = 1000, speed = 1500,
        kill_pct = 14, damage_per_second = 36 },
}
bot.GetAbilityByName = function(_, name)
    requested[name] = true
    local v = values[name] or {}
    return { name = name,
        IsFullyCastable = function() return castable[name] == true end,
        IsTrained = function() return trained[name] == true end,
        IsHidden = function() return hidden[name] ~= false end,
        GetCastRange = function() return name == 'ancient_apparition_ice_vortex' and 1200 or 1000 end,
        GetCastPoint = function() return 0.01 end,
        GetDuration = function() return 4 end,
        GetAbilityDamage = function() return 400 end,
        GetSpecialValueInt = function(_, key) return v[key] or 0 end,
        GetSpecialValueFloat = function(_, key) return v[key] or 0 end }
end

-- jmz_func stubs -------------------------------------------------------------------------------------
local fight, going, teamFightLoc, botTarget = false, false, nil, nil
setmetatable(J, { __index = function() return function() return false end end })
J.GetProperCastRange = function(_, _, r) return r end
J.GetProperTarget = function() return botTarget end
J.IsValidHero = function(u) return u ~= nil end
J.IsValidTarget = J.IsValidHero
J.CanCastOnNonMagicImmune = function() return true end
J.CanCastOnMagicImmune = function() return true end
J.CanCastOnTargetAdvanced = function() return true end
J.IsDisabled = function(u) return u.disabled end
J.IsInRange = function(a, b, r) return GetUnitToUnitDistance(a, b) <= r end
J.IsInTeamFight = function() return fight end
J.IsGoingOnSomeone = function() return going end
J.GetTeamFightLocation = function() return teamFightLoc end
J.GetLocationToLocationDistance = dist
J.GetMP = function() return 1 end
J.GetNearbyHeroes = function(unit, r, bEnemy)
    local out = {}
    if unit == bot and bEnemy then
        for _, e in ipairs(enemies) do if GetUnitToUnitDistance(bot, e) <= r then table.insert(out, e) end end
    end
    return out
end
J.GetEnemiesNearLoc = function(v, r)
    local out = {}
    for _, e in ipairs(enemies) do if dist(e.loc, v) <= r then table.insert(out, e) end end
    return out
end

local AA = H.load('npc_dota_hero_ancient_apparition', 'pos_5')
local function reset()
    enemies, actions, trained = {}, {}, {}
    castable = { ancient_apparition_cold_feet = true, ancient_apparition_ice_vortex = true }
    fight, going, teamFightLoc, botTarget = false, false, nil, nil
end

-- 1. The AoE Cold Feet talent is _1; _7 is Chilling Touch attack range.
assert(requested['special_bonus_unique_ancient_apparition_1'], 'AoE Cold Feet talent is special_bonus_unique_ancient_apparition_1')
assert(not requested['special_bonus_unique_ancient_apparition_7'], 'the Chilling Touch range talent must not gate AoE Cold Feet')

-- 2. Gank: Cold Feet lands before Ice Vortex.
reset()
local target = Enemy(600, 0); going = true; botTarget = target
AA.SkillsComplement()
assert(actions[1][1] == 'entity' and actions[1][2] == 'ancient_apparition_cold_feet' and actions[1][3] == target,
    'Cold Feet opens the gank on the target')

-- 3. Next frame: Vortex follows up on the cursed target, pulled toward where it was cursed.
actions = {}; castable.ancient_apparition_cold_feet = false
target.mods.modifier_cold_feet = true; target.loc = V(800, 0)
AA.SkillsComplement()
assert(actions[1][2] == 'ancient_apparition_ice_vortex', 'Ice Vortex follows Cold Feet')
local vortex = actions[1][3]
assert(math.abs(vortex.x - 662.5) < 0.01 and vortex.y == 0, 'Vortex centred between the target and its Cold Feet origin')
assert(dist(vortex, target.loc) <= 275, 'the cursed target stays inside the Vortex')

-- 4. A disabled enemy is a Cold Feet follow-up target in a fight.
reset()
fight = true
local stunned = Enemy(500, 0); stunned.disabled = true
local desire, t = AA.ConsiderColdFeet()
assert(desire > 0 and t == stunned, 'Cold Feet chains onto an ally disable')

-- 5. AoE talent: still unit-targeted, on the enemy with the most heroes around it.
reset()
trained['special_bonus_unique_ancient_apparition_1'] = true
values.ancient_apparition_cold_feet.area_of_effect = 450
local lone = Enemy(600, 0); local pairA = Enemy(300, 700); Enemy(500, 800)
going = true; botTarget = lone
AA.SkillsComplement()
assert(actions[1][1] == 'entity' and actions[1][3] == pairA, 'AoE Cold Feet curses the clustered pair via a unit target')
values.ancient_apparition_cold_feet.area_of_effect = 0

-- 6. Ice Blast radius grows with travel time, not raw distance.
reset()
assert(math.abs(AA.GetIceBlastRadius(V(3000, 0)) - 400) < 0.01, '3000 units at 1500 speed -> 300 + 50 * 2')
assert(AA.GetIceBlastRadius(V(30000, 0)) == 1000, 'radius caps at radius_max')

-- 7. Global fight: aim at enemies the real radius covers.
teamFightLoc = V(3000, 0)
Enemy(3000, 0); Enemy(3300, 0)
local loc, count = AA.GetBestIceBlastLocation(J.GetEnemiesNearLoc(teamFightLoc, 1400))
assert(count == 2 and dist(loc, V(3000, 0)) <= 300, 'blast covers both enemies 300 apart')
reset()
Enemy(3000, 0); Enemy(3900, 0)
loc, count = AA.GetBestIceBlastLocation(J.GetEnemiesNearLoc(V(3000, 0), 1400))
assert(count == 1, 'enemies 900 apart are not both inside a ~400 radius blast')

-- 8. Snipe a visible enemy the initial hit drops below the shatter threshold.
reset()
castable.ancient_apparition_ice_blast = true
local fleeing = Enemy(2000, 0, 450, 2000)
desire, loc = AA.ConsiderIceBlast()
assert(desire > 0 and loc == fleeing.loc, 'Ice Blast snipes an enemy it will shatter')
fleeing.hp = 1200
desire = AA.ConsiderIceBlast()
assert(desire == 0, 'no snipe on a healthy enemy')

-- 9. Release timing. Ability thinks are throttled, so the tracer moves up to ~300 units per check.
local function Tracer(x) projectiles = { { location = V(x, 0), caster = bot, ability = { GetName = function() return 'ancient_apparition_ice_blast' end } } } end
reset()
castable.ancient_apparition_ice_blast = true
Enemy(3000, 0); Enemy(3100, 0); teamFightLoc = V(3000, 0)
AA.SkillsComplement()
assert(actions[1][2] == 'ancient_apparition_ice_blast', 'Ice Blast launched at the fight')
castable.ancient_apparition_ice_blast = false
castable.ancient_apparition_ice_blast_release = true; hidden.ancient_apparition_ice_blast_release = false
Tracer(2500)
assert(AA.ConsiderIceBlastRelease() == 0, 'no release while the tracer is 500 short')
Tracer(2880)
assert(AA.ConsiderIceBlastRelease() > 0, 'release within half a think step of the target')
Tracer(3250)
assert(AA.ConsiderIceBlastRelease() > 0, 'a tracer that stepped past the target is still released')
-- Enemy tracers with the same ability name are ignored.
projectiles = { { location = V(3000, 0), caster = {}, ability = { GetName = function() return 'ancient_apparition_ice_blast' end } } }
now = 100.5
assert(AA.ConsiderIceBlastRelease() == 0, 'an enemy Ice Blast tracer does not trigger our release')
-- No visible tracer: flight time estimates progress (3000 units at 1500/s = 2s).
projectiles = {}; now = 102
assert(AA.ConsiderIceBlastRelease() > 0, 'release by flight time without a visible tracer')
-- Silence does not block Release (it ignores silence); the generic can-cast gate is bypassed.
actions = {}; J.CanNotUseAbility = function() return true end
AA.SkillsComplement()
assert(actions[1] and actions[1][2] == 'ancient_apparition_ice_blast_release', 'Release fires while silenced')
botStunned = true; actions = {}
AA.SkillsComplement()
assert(actions[1] == nil, 'no Release order while stunned')
botStunned = false; J.CanNotUseAbility = nil; now = 100
castable.ancient_apparition_ice_blast_release = nil; hidden.ancient_apparition_ice_blast_release = nil; projectiles = {}

-- 10. Rubick's stolen copy shares the Ice Blast radius and snipe logic.
local Rubick = dofile('bots/FunLib/rubick_hero/ancient_apparition.lua')
reset()
castable.ancient_apparition_ice_blast = true
local stolen = bot:GetAbilityByName('ancient_apparition_ice_blast')
stolen.GetName = function() return 'ancient_apparition_ice_blast' end
local runner = Enemy(2000, 0, 450, 2000)
Rubick.ConsiderStolenSpell(stolen)
assert(actions[1] and actions[1][1] == 'location' and actions[1][3] == runner.loc, 'stolen Ice Blast snipes a shatterable enemy')
assert(math.abs(Rubick.GetIceBlastRadius(V(3000, 0)) - 400) < 0.01, 'stolen Ice Blast uses the travel-time radius')
-- The tracer stepped past the target while Rubick is silenced: Release still fires.
castable.ancient_apparition_ice_blast_release = true; hidden.ancient_apparition_ice_blast_release = false
local release = bot:GetAbilityByName('ancient_apparition_ice_blast_release')
release.GetName = function() return 'ancient_apparition_ice_blast_release' end
Tracer(2150); actions = {}; J.CanNotUseAbility = function() return true end
Rubick.ConsiderStolenSpell(release)
assert(actions[1] and actions[1][2] == 'ancient_apparition_ice_blast_release', 'stolen Release fires past the target while silenced')
J.CanNotUseAbility = nil

-- 11. Ice Blast target priority: heal-reliant heroes and large health pools decide equal or
-- near-equal blasts, but an extra hero still outweighs one priority target.
reset()
Enemy(3000, 0); Enemy(3200, 0)
local huskar = Enemy(0, 3000); huskar.unit = 'npc_dota_hero_huskar'; Enemy(200, 3000)
loc, count = AA.GetBestIceBlastLocation(enemies)
assert(count == 2 and dist(loc, huskar.loc) <= 300, 'equal counts: the blast with the heal-reliant hero wins')
reset()
Enemy(3000, 0); Enemy(3200, 0); Enemy(3100, 150)
huskar = Enemy(0, 3000); huskar.unit = 'npc_dota_hero_huskar'
loc, count = AA.GetBestIceBlastLocation(enemies)
assert(count == 3, 'three heroes outweigh a lone heal-reliant hero')
reset()
Enemy(3000, 0); local tank = Enemy(0, 3000, 4000, 4000)
loc = AA.GetBestIceBlastLocation(enemies)
assert(loc == tank.loc, 'a large health pool breaks a one-on-one tie')
loc = Rubick.GetBestIceBlastLocation(enemies)
assert(loc == tank.loc, 'stolen Ice Blast shares the target priority')

-- 12. Aghanim's Shard: the explosion stuns, so a close Cold Feet target is worth more.
reset()
local far = Enemy(0, 3000)
local cursed = Enemy(800, 0); cursed.mods.modifier_cold_feet = true
loc = AA.GetBestIceBlastLocation(enemies)
assert(loc == far.loc, 'without the Shard equal single targets keep the first candidate')
values.ancient_apparition_ice_blast.cold_feet_stun_duration_pct = 50
loc = AA.GetBestIceBlastLocation(enemies)
assert(loc == cursed.loc, 'with the Shard the close cursed enemy is preferred')
values.ancient_apparition_ice_blast.cold_feet_stun_duration_pct = nil

-- 13. Lane harass: skipped while an enemy lane creep is within aggro range of AA.
reset()
castable.ancient_apparition_chilling_touch = true
J.IsLaning = function() return true end
local laner = Enemy(700, 0)
desire, t = AA.ConsiderChillingTouch()
assert(desire > 0 and t == laner, 'Chilling Touch harasses a laner with no creeps near AA')
laneCreeps = { {} }
desire = AA.ConsiderChillingTouch()
assert(desire == 0, 'no harass when it would draw lane-creep aggro')
laneCreeps = {}; J.IsLaning = nil

print('Ancient Apparition combo scenarios passed')
