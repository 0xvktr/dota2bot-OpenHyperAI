local X             = {}
local bot           = GetBot()

local J             = require( GetScriptDirectory()..'/FunLib/jmz_func' )
local Minion        = dofile( GetScriptDirectory()..'/FunLib/aba_minion' )
local sTalentList   = J.Skill.GetTalentList( bot )
local sAbilityList  = J.Skill.GetAbilityList( bot )
local sRole   = J.Item.GetRoleItemsBuyList( bot )

-- Updated to 7.41f from D2PT: positions 3 (offlane) and 2 (mid, a reviewed exception); forced other roles use pos 3.
local BuildData = require(GetScriptDirectory()..'/BotLib/Builds/dawnbreaker')
X.buildMetadata = BuildData
X.neutralPreferences = BuildData.neutrals[sRole]
-- Learnable abilities: [1] Starbreaker, [2] Celestial Hammer, [3] Luminosity, [6] Solar Guardian.
-- Both roles share D2PT's most popular first ten levels; later levels are a legal continuation.
local nAbilityBuildList = {2,1,2,3,2,6,2,1,1,1,6,3,3,3,6}
local nTalentBuildList = J.Skill.GetTalentBuild({
    t10={0,10}, -- +25% Luminosity critical damage
    t15={10,0}, -- -20s Solar Guardian cooldown
    t20={10,0}, -- -1 Luminosity attacks required
    -- Offlane: +80% Celestial Hammer cast range/speed; mid: -4s Starbreaker cooldown.
    t25=(sRole == 'pos_2') and {0,10} or {10,0},
})
local defaultAbilityBuild, defaultTalentBuild = nAbilityBuildList, nTalentBuildList
if sRole == 'pos_2' then
    X.sBuyList = {
        'item_tango', 'item_double_branches', 'item_faerie_fire',
        'item_bottle', 'item_magic_wand', 'item_soul_ring', 'item_phase_boots', 'item_desolator',
        'item_echo_sabre', 'item_aghanims_shard', 'item_harpoon', 'item_blink', 'item_black_king_bar',
        -- Late upgrades/slot policy beyond the displayed core progression.
        'item_abyssal_blade', 'item_overwhelming_blink', 'item_moon_shard',
    }
    X.sSellList = {
        'item_blink', 'item_bottle',
        'item_black_king_bar', 'item_magic_wand',
        'item_abyssal_blade', 'item_soul_ring',
    }
else
    X.sBuyList = {
        'item_tango', 'item_quelling_blade', 'item_double_gauntlets', 'item_double_branches',
        'item_double_bracer', 'item_soul_ring', 'item_magic_wand', 'item_phase_boots', 'item_echo_sabre',
        'item_aghanims_shard', 'item_harpoon', 'item_black_king_bar', 'item_assault',
        -- Late upgrades/slot policy beyond the displayed core progression.
        'item_abyssal_blade', 'item_overwhelming_blink', 'item_moon_shard',
    }
    X.sSellList = {
        'item_harpoon', 'item_quelling_blade',
        'item_black_king_bar', 'item_bracer', -- Repeated purchase ticks sell both Bracers.
        'item_assault', 'item_magic_wand',
        'item_overwhelming_blink', 'item_soul_ring',
    }
end

if J.Role.IsPvNMode() or J.Role.IsAllShadow() then X['sBuyList'], X['sSellList'] = { 'PvN_antimage' }, {} end

nAbilityBuildList, nTalentBuildList, X['sBuyList'], X['sSellList'] = J.SetUserHeroInit( nAbilityBuildList, nTalentBuildList, X['sBuyList'], X['sSellList'] )

X['sSkillList'] = J.Skill.GetSkillList( sAbilityList, nAbilityBuildList, sTalentList, nTalentBuildList )
-- Starbreaker takes level 10, so the first talent comes at 11. Respect custom builds.
if nAbilityBuildList == defaultAbilityBuild and nTalentBuildList == defaultTalentBuild then
    X.sSkillList[10], X.sSkillList[11] = X.sSkillList[11], X.sSkillList[10]
end

X['bDeafaultAbility'] = false
X['bDeafaultItem'] = false

function X.MinionThink(hMinionUnit)
	Minion.MinionThink(hMinionUnit)
end

local Starbreaker, CelestialHammer, Converge, SolarGuardian
local hammerFlight

local function Refresh()
    bot = GetBot()
    Starbreaker = bot:GetAbilityByName('dawnbreaker_fire_wreath')
    CelestialHammer = bot:GetAbilityByName('dawnbreaker_celestial_hammer')
    Converge = bot:GetAbilityByName('dawnbreaker_converge')
    SolarGuardian = bot:GetAbilityByName('dawnbreaker_solar_guardian')
end

local function Distance(a, b)
    local dx, dy = a.x - b.x, a.y - b.y
    return math.sqrt(dx * dx + dy * dy)
end

local function Towards(origin, destination, maximum)
    local distance = Distance(origin, destination)
    if distance <= maximum or distance == 0 then return destination end
    local fraction = maximum / distance
    return Vector(origin.x + (destination.x - origin.x) * fraction,
        origin.y + (destination.y - origin.y) * fraction, origin.z)
end

local function SafeLanding(location)
    return IsLocationPassable(location) and not J.IsLocationInChrono(location)
        and not J.IsLocationInBlackHole(location)
end

local function Enemy(unit)
    return J.IsValidHero(unit) and unit:GetTeam() ~= bot:GetTeam()
        and not J.IsSuspiciousIllusion(unit)
end

local function PhysicalTarget(unit)
    return J.IsValid(unit) and not unit:IsAttackImmune()
        and not unit:HasModifier('modifier_omniknight_guardian_angel')
        and not unit:HasModifier('modifier_winter_wyvern_cold_embrace')
end

local function HammerRange()
    -- Special values already include the current range/speed talent.
    local range = CelestialHammer:GetSpecialValueInt('range')
    local lens = J.IsItemAvailable('item_aether_lens')
    if lens ~= nil then range = range + lens:GetSpecialValueInt('cast_range_bonus') end
    local supremacy = bot:GetAbilityByName('rubick_arcane_supremacy')
    if supremacy ~= nil and supremacy:IsTrained() and not J.HasBreakModifier(bot) then
        range = range + supremacy:GetSpecialValueInt('cast_range')
    end
    return range
end

local function FarmMana(ability)
    local reserve = SolarGuardian ~= nil and SolarGuardian:IsTrained() and SolarGuardian:GetManaCost() or 0
    return bot:GetMana() - ability:GetManaCost() >= math.max(reserve, bot:GetMaxMana() * 0.25)
end

local function PredictHammer(unit)
    local speed = math.max(1, CelestialHammer:GetSpecialValueInt('projectile_speed'))
    local delay = CelestialHammer:GetCastPoint() + GetUnitToUnitDistance(bot, unit) / speed
    local location
    for _ = 1, 3 do
        location = unit:GetExtrapolatedLocation(delay)
        delay = CelestialHammer:GetCastPoint() + Distance(bot:GetLocation(), location) / speed
    end
    if Distance(bot:GetLocation(), location) <= HammerRange() then return location, delay end
    return nil, delay
end

local function LineDistance(location, origin, destination)
    local dx, dy = destination.x - origin.x, destination.y - origin.y
    local length = dx * dx + dy * dy
    if length == 0 then return Distance(location, origin) end
    local t = math.max(0, math.min(1, ((location.x - origin.x) * dx + (location.y - origin.y) * dy) / length))
    return Distance(location, Vector(origin.x + dx * t, origin.y + dy * t, origin.z))
end

function X.ConsiderStarBreaker()
    if not J.CanCastAbility(Starbreaker) or bot:IsDisarmed() and not (J.IsRetreating(bot) and bot:HasShard())
        or J.IsRetreating(bot) and bot:HasModifier('modifier_bloodseeker_rupture') then return BOT_ACTION_DESIRE_NONE, nil end
    local radius = Starbreaker:GetSpecialValueInt('swipe_radius')
    local duration = Starbreaker:GetSpecialValueFloat('duration')
    local reach = radius + Starbreaker:GetSpecialValueInt('movement_speed') * duration
    local firstHit = bot:GetAttackDamage() + Starbreaker:GetSpecialValueInt('swipe_damage')
    local fullCombo = Starbreaker:GetSpecialValueInt('total_attacks') * bot:GetAttackDamage()
        + (Starbreaker:GetSpecialValueInt('total_attacks') - 1) * Starbreaker:GetSpecialValueInt('swipe_damage')
        + Starbreaker:GetSpecialValueInt('smash_damage')
    local enemies = J.GetNearbyHeroes(bot, math.min(1600, reach + 100), true, BOT_MODE_NONE)
    for _, enemy in pairs(enemies) do
        if Enemy(enemy) and PhysicalTarget(enemy) then
            local location = enemy:GetExtrapolatedLocation(Starbreaker:GetCastPoint())
            local distance = Distance(bot:GetLocation(), location)
            if distance <= radius and (enemy:IsChanneling()
                or J.WillKillTarget(enemy, firstHit, DAMAGE_TYPE_PHYSICAL, Starbreaker:GetCastPoint())
                or enemy:IsStunned() and J.GetRemainStunTime(enemy) >= duration + Starbreaker:GetCastPoint()
                    and J.WillKillTarget(enemy, fullCombo, DAMAGE_TYPE_PHYSICAL, duration + Starbreaker:GetCastPoint())) then
                return BOT_ACTION_DESIRE_HIGH, location
            end
        end
    end
    if J.IsInTeamFight(bot, 900) then
        for _, enemy in pairs(enemies) do
            if Enemy(enemy) and PhysicalTarget(enemy) and GetUnitToUnitDistance(bot, enemy) <= radius then
                local location = enemy:GetExtrapolatedLocation(Starbreaker:GetCastPoint())
                local count = 0
                for _, other in pairs(enemies) do
                    if Enemy(other) and PhysicalTarget(other) and GetUnitToUnitDistance(bot, other) <= radius
                        and Distance(location, other:GetExtrapolatedLocation(Starbreaker:GetCastPoint())) <= radius then count = count + 1 end
                end
                if count >= 2 then return BOT_ACTION_DESIRE_HIGH, location end
            end
        end
    end
    local target = J.GetProperTarget(bot)
    if J.IsGoingOnSomeone(bot) and Enemy(target) and PhysicalTarget(target) then
        local location = target:GetExtrapolatedLocation(Starbreaker:GetCastPoint() + duration / 2)
        if Distance(bot:GetLocation(), location) <= reach - 50 then return BOT_ACTION_DESIRE_HIGH, location end
    end
    if J.IsRetreating(bot) then
        -- Shard supplies immunity during the combo; no invented free-movement orders.
        if bot:HasShard() and bot:WasRecentlyDamagedByAnyHero(2) and #enemies > 0 and not bot:IsRooted()
            and not bot:HasModifier('modifier_bloodseeker_rupture') then
            local escape = Towards(bot:GetLocation(), J.GetEscapeLoc(), reach)
            if SafeLanding(Towards(bot:GetLocation(), escape, reach - radius)) then
                return BOT_ACTION_DESIRE_HIGH, escape
            end
        end
        for _, enemy in pairs(enemies) do
            if Enemy(enemy) and PhysicalTarget(enemy) and J.IsChasingTarget(enemy, bot)
                and GetUnitToUnitDistance(bot, enemy) <= radius then
                return BOT_ACTION_DESIRE_HIGH, enemy:GetLocation()
            end
        end
    end
    if FarmMana(Starbreaker) and (J.IsFarming(bot) or J.IsPushing(bot) or J.IsDefending(bot) or J.IsLaning(bot)) then
        local creeps = J.IsFarming(bot) and bot:GetNearbyNeutralCreeps(reach) or bot:GetNearbyLaneCreeps(reach, true)
        for _, creep in pairs(creeps) do
            if PhysicalTarget(creep) and GetUnitToUnitDistance(bot, creep) <= radius then
                local count = 0
                for _, other in pairs(creeps) do
                    if PhysicalTarget(other) and GetUnitToUnitDistance(creep, other) <= radius * 0.7
                        and GetUnitToUnitDistance(bot, other) <= radius then count = count + 1 end
                end
                if count >= 3 or J.IsFarming(bot) and count >= 2 and creep:IsAncientCreep()
                    or J.IsLaning(bot) and J.WillKillTarget(creep, firstHit, DAMAGE_TYPE_PHYSICAL, Starbreaker:GetCastPoint()) then
                    return BOT_ACTION_DESIRE_HIGH, creep:GetLocation()
                end
            end
        end
    end
    return BOT_ACTION_DESIRE_NONE, nil
end

function X.ConsiderCelestialHammer()
    if not J.CanCastAbility(CelestialHammer) then return BOT_ACTION_DESIRE_NONE, nil end
    local range = HammerRange()
    local enemies = J.GetNearbyHeroes(bot, math.min(1600, range), true, BOT_MODE_NONE)
    for _, enemy in pairs(enemies) do
        if Enemy(enemy) and J.CanCastOnNonMagicImmune(enemy) then
            local location, delay = PredictHammer(enemy)
            -- Only the outgoing strike is guaranteed; return damage and burns are conditional.
            if location ~= nil and J.WillKillTarget(enemy, CelestialHammer:GetSpecialValueInt('hammer_damage'), DAMAGE_TYPE_MAGICAL, delay) then
                return BOT_ACTION_DESIRE_HIGH, location
            end
        end
    end
    if J.IsRetreating(bot) and bot:WasRecentlyDamagedByAnyHero(2) and #enemies > 0
        and not bot:IsRooted() and not bot:HasModifier('modifier_bloodseeker_rupture') then
        local escape = Towards(bot:GetLocation(), J.GetEscapeLoc(), range)
        if SafeLanding(Towards(bot:GetLocation(), escape, Distance(bot:GetLocation(), escape) / 2)) then
            return BOT_ACTION_DESIRE_HIGH, escape
        end
    end
    local target = J.GetProperTarget(bot)
    if J.IsGoingOnSomeone(bot) and Enemy(target) and J.CanCastOnNonMagicImmune(target) then
        local location = PredictHammer(target)
        if location ~= nil then return BOT_ACTION_DESIRE_HIGH, location end
    end
    if FarmMana(CelestialHammer) and (J.IsFarming(bot) or J.IsPushing(bot) or J.IsDefending(bot) or J.IsLaning(bot)) then
        local creeps = J.IsFarming(bot) and bot:GetNearbyNeutralCreeps(range) or bot:GetNearbyLaneCreeps(range, true)
        for _, creep in pairs(creeps) do
            if J.IsValid(creep) and J.CanCastOnNonMagicImmune(creep) then
                local location, delay = PredictHammer(creep)
                if location ~= nil then
                    local count = 0
                    for _, other in pairs(creeps) do
                        if J.IsValid(other) and J.CanCastOnNonMagicImmune(other)
                            and LineDistance(other:GetExtrapolatedLocation(delay), bot:GetLocation(), location)
                                <= CelestialHammer:GetSpecialValueInt('projectile_radius') then count = count + 1 end
                    end
                    if count >= 3 or J.IsFarming(bot) and count >= 2 and creep:IsAncientCreep()
                        or J.IsLaning(bot) and J.WillKillTarget(creep, CelestialHammer:GetSpecialValueInt('hammer_damage'), DAMAGE_TYPE_MAGICAL, delay) then
                        return BOT_ACTION_DESIRE_HIGH, location
                    end
                end
            end
        end
    end
    return BOT_ACTION_DESIRE_NONE, nil
end

local function CastHammer(location)
    local speed = math.max(1, CelestialHammer:GetSpecialValueInt('projectile_speed'))
    local travel = Distance(bot:GetLocation(), location) / speed
    hammerFlight = {location = location, arrival = DotaTime() + CelestialHammer:GetCastPoint() + travel,
        -- The stationary destination ceases to be reliable when automatic return starts.
        expiry = DotaTime() + CelestialHammer:GetCastPoint() + travel + CelestialHammer:GetSpecialValueFloat('pause_duration'),
        escaping = J.IsRetreating(bot)}
    bot:Action_UseAbilityOnLocation(CelestialHammer, location)
end

function X.ConsiderConverge()
    if hammerFlight == nil then return BOT_ACTION_DESIRE_NONE end
    if DotaTime() > hammerFlight.expiry then hammerFlight = nil; return BOT_ACTION_DESIRE_NONE end
    if Converge == nil or Converge:IsNull() or Converge:IsHidden() or not Converge:IsFullyCastable()
        or CelestialHammer == nil or CelestialHammer:IsNull() or DotaTime() < hammerFlight.arrival
        or bot:IsRooted() or bot:HasModifier('modifier_bloodseeker_rupture') then return BOT_ACTION_DESIRE_NONE end
    local origin = bot:GetLocation()
    local landing = Towards(origin, hammerFlight.location, Distance(origin, hammerFlight.location) / 2)
    if not SafeLanding(landing) then return BOT_ACTION_DESIRE_NONE end
    if hammerFlight.escaping and J.IsRetreating(bot) then
        if Distance(landing, J.GetEscapeLoc()) + 150 < Distance(origin, J.GetEscapeLoc()) then return BOT_ACTION_DESIRE_HIGH end
    elseif J.IsGoingOnSomeone(bot) then
        local target = J.GetProperTarget(bot)
        if Enemy(target) and Distance(landing, target:GetLocation()) + 150 < GetUnitToUnitDistance(bot, target)
            and #J.GetNearbyHeroes(target, 900, false, BOT_MODE_NONE) <= #J.GetNearbyHeroes(target, 900, true, BOT_MODE_NONE) + 1 then
            return BOT_ACTION_DESIRE_HIGH
        end
    end
    return BOT_ACTION_DESIRE_NONE
end

local function Ally(unit)
    return unit ~= nil and not unit:IsNull() and unit:IsAlive() and unit:IsHero()
        and unit:GetTeam() == bot:GetTeam() and not unit:IsIllusion() and unit ~= bot
end

local function BKB()
    local item = J.IsItemAvailable('item_black_king_bar')
    if item ~= nil and item:IsFullyCastable() and bot:GetMana() >= item:GetManaCost() + SolarGuardian:GetManaCost() then return item end
    return nil
end

function X.ConsiderSolarGuardian()
    if not J.CanCastAbility(SolarGuardian) then return BOT_ACTION_DESIRE_NONE, nil end
    local radius = SolarGuardian:GetSpecialValueInt('radius')
    local delay = SolarGuardian:GetCastPoint() + SolarGuardian:GetChannelTime() + SolarGuardian:GetSpecialValueFloat('airtime_duration')
    local offset = SolarGuardian:GetSpecialValueInt('max_offset_distance')
    local localEnemies = J.GetNearbyHeroes(bot, 900, true, BOT_MODE_NONE)
    local protect = not bot:IsMagicImmune() and (#localEnemies >= 2
        or #localEnemies >= 1 and bot:WasRecentlyDamagedByAnyHero(2))
    if protect and BKB() == nil then return BOT_ACTION_DESIRE_NONE, nil end
    local best, score = nil, 0
    for _, ally in pairs(GetUnitList(UNIT_LIST_ALLIED_HEROES)) do
        if Ally(ally) then
            local location = Towards(ally:GetLocation(), ally:GetExtrapolatedLocation(delay), offset)
            local enemies, enemyCount = J.GetNearbyHeroes(ally, radius + offset, true, BOT_MODE_NONE), 0
            for _, enemy in pairs(enemies) do
                if Enemy(enemy) and Distance(enemy:GetExtrapolatedLocation(delay), location) <= radius then enemyCount = enemyCount + 1 end
            end
            local allyCount = 1
            for _, friend in pairs(J.GetNearbyHeroes(ally, radius + offset, false, BOT_MODE_NONE)) do
                if Ally(friend) and friend ~= ally then allyCount = allyCount + 1 end
            end
            local healable = not ally:HasModifier('modifier_ice_blast') and not ally:HasModifier('modifier_doom_bringer_doom')
            local save = healable and J.GetHP(ally) < 0.55 and ally:WasRecentlyDamagedByAnyHero(3) and #enemies > 0
            local setup = enemyCount >= 2 or enemyCount >= 1 and (J.IsDisabled(ally) or ally:HasModifier('modifier_legion_commander_duel'))
            local remoteFight = GetUnitToUnitDistance(bot, ally) > radius * 2 and enemyCount >= 1
                and (save or setup or J.IsGoingOnSomeone(ally))
            local escape = J.IsRetreating(bot) and J.GetHP(bot) < 0.4 and #localEnemies >= 2
                and GetUnitToUnitDistance(bot, ally) > 2500 and #enemies == 0 and (bot:IsMagicImmune() or BKB() ~= nil)
            if SafeLanding(location) and (escape or enemyCount <= allyCount + 1 and (save or setup or remoteFight)) then
                local value = (save and 5 or 0) + enemyCount * 2 + (setup and 2 or 0) + (escape and 4 or 0)
                if value > score then best, score = location, value end
            end
        end
    end
    if best ~= nil then return BOT_ACTION_DESIRE_HIGH, best, protect end
    return BOT_ACTION_DESIRE_NONE, nil
end

local function CastSolar(location, protect)
    hammerFlight = nil -- Solar Guardian recalls Hammer immediately.
    local item = protect and BKB() or nil
    if item ~= nil then
        bot:ActionQueue_UseAbility(item)
        bot:ActionQueue_UseAbilityOnLocation(SolarGuardian, location)
    else
        bot:Action_UseAbilityOnLocation(SolarGuardian, location)
    end
end

function X.SkillsComplement()
    Refresh()
    if J.CanNotUseAbility(bot) then return end
    local desire, location, protect = X.ConsiderSolarGuardian()
    if desire > 0 then CastSolar(location, protect); return end
    if X.ConsiderConverge() > 0 then
        bot:Action_UseAbility(Converge); hammerFlight = nil; return
    end
    desire, location = X.ConsiderStarBreaker()
    if desire > 0 then bot:Action_UseAbilityOnLocation(Starbreaker, location); return end
    desire, location = X.ConsiderCelestialHammer()
    if desire > 0 then CastHammer(location); return end
end

Refresh()
return X
