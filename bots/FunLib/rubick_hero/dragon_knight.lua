local X = {}
local bot = GetBot()
local J = require(GetScriptDirectory()..'/FunLib/jmz_func')
local BreatheFire, DragonTail, Fireball, DragonForm

local function Refresh()
    BreatheFire = bot:GetAbilityByName('dragon_knight_breathe_fire')
    DragonTail = bot:GetAbilityByName('dragon_knight_dragon_tail')
    Fireball = bot:GetAbilityByName('dragon_knight_fireball')
    DragonForm = bot:GetAbilityByName('dragon_knight_elder_dragon_form')
end

local function InDragonForm()
    return bot:HasModifier('modifier_dragon_knight_dragon_form')
end

local function CastRange(ability)
    local range = ability:GetCastRange()
    if InDragonForm() then
        -- Form extends all spells, not just Tail. A stolen basic may lack the Form handle.
        range = range + (DragonForm ~= nil and DragonForm:GetSpecialValueInt('bonus_ability_cast_range') or 350)
    end
    local lens = J.IsItemAvailable('item_aether_lens')
    if lens ~= nil then range = range + lens:GetSpecialValueInt('cast_range_bonus') end
    local supremacy = bot:GetAbilityByName('rubick_arcane_supremacy')
    if supremacy ~= nil and supremacy:IsTrained() and not J.HasBreakModifier(bot) then
        range = range + supremacy:GetSpecialValueInt('cast_range')
    end
    return range
end

local function Enemy(unit)
    return J.IsValidHero(unit) and J.CanCastOnNonMagicImmune(unit) and not J.IsSuspiciousIllusion(unit)
end

local function Enemies()
    local result = {}
    for _, unit in pairs(GetUnitList(UNIT_LIST_ENEMY_HEROES)) do
        if Enemy(unit) then result[#result + 1] = unit end
    end
    return result
end

local function Creeps(range)
    local result, seen = {}, {}
    for _, group in ipairs({bot:GetNearbyCreeps(range, true), bot:GetNearbyNeutralCreeps(range)}) do
        for _, creep in ipairs(group) do
            if not seen[creep] and J.IsValid(creep) and J.CanCastOnNonMagicImmune(creep)
                and J.IsInRange(bot, creep, range) then
                result[#result + 1] = creep; seen[creep] = true
            end
        end
    end
    return result
end

local function SaveNeeded(enemy)
    if J.IsRetreating(bot) and bot:WasRecentlyDamagedByHero(enemy, 3) then return true end
    for _, ally in ipairs(J.GetNearbyHeroes(bot, 1200, false, BOT_MODE_NONE)) do
        if J.IsValidHero(ally) and not ally:IsIllusion() and J.IsRetreating(ally)
            and ally:WasRecentlyDamagedByAnyHero(3) and J.IsChasingTarget(enemy, ally) then return true end
    end
    return false
end

local function MagicLethal(enemy, damage, delay)
    return not J.CannotBeKilled(bot, enemy)
        and enemy:GetActualIncomingDamage(damage, DAMAGE_TYPE_MAGICAL)
            >= enemy:GetHealth() + enemy:GetHealthRegen() * delay
end

local function TailLegal(enemy)
    return Enemy(enemy) and J.IsInRange(bot, enemy, CastRange(DragonTail))
        and J.CanCastOnTargetAdvanced(enemy)
        and not enemy:HasModifier('modifier_antimage_counterspell')
        and not enemy:HasModifier('modifier_antimage_counterspell_ally')
end

function X.ConsiderDragonTail(urgentOnly)
    if not J.CanCastAbility(DragonTail) then return 0 end
    for _, enemy in ipairs(Enemies()) do
        if TailLegal(enemy) then
            local delay = DragonTail:GetCastPoint()
            if InDragonForm() then delay = delay + GetUnitToUnitDistance(bot, enemy) / DragonTail:GetSpecialValueInt('projectile_speed') end
            if enemy:IsChanneling() and (not enemy:HasModifier('modifier_teleporting')
                or J.GetModifierTime(enemy, 'modifier_teleporting') > delay)
                or MagicLethal(enemy, DragonTail:GetSpecialValueInt('damage'), delay) then
                return BOT_ACTION_DESIRE_HIGH, enemy
            end
        end
    end
    if urgentOnly then return 0 end
    local target = J.GetProperTarget(bot)
    if TailLegal(target) and J.IsGoingOnSomeone(bot) and not J.IsDisabled(target) then
        return BOT_ACTION_DESIRE_HIGH, target
    end
    local best, power = nil, 0
    for _, enemy in ipairs(Enemies()) do
        if TailLegal(enemy) and not J.IsDisabled(enemy) then
            if SaveNeeded(enemy) then return BOT_ACTION_DESIRE_HIGH, enemy end
            if J.IsInTeamFight(bot, 1200) then
                local value = enemy:GetEstimatedDamageToTarget(false, bot, 3, DAMAGE_TYPE_ALL)
                if value > power then best, power = enemy, value end
            end
        end
    end
    if best ~= nil then return BOT_ACTION_DESIRE_HIGH, best end
    return 0
end

local function BreathLocation(unit)
    local range = CastRange(BreatheFire)
    local delay = BreatheFire:GetCastPoint() + GetUnitToUnitDistance(bot, unit) / BreatheFire:GetSpecialValueInt('speed')
    local location = unit:GetExtrapolatedLocation(delay)
    if GetUnitToLocationDistance(bot, location) > range then return nil end
    return location
end

local function BreathHits(unit, location)
    local start = bot:GetLocation()
    local dx, dy = location.x - start.x, location.y - start.y
    local length = math.sqrt(dx * dx + dy * dy)
    if length == 0 then return false end
    local predicted = unit:GetExtrapolatedLocation(BreatheFire:GetCastPoint()
        + GetUnitToUnitDistance(bot, unit) / BreatheFire:GetSpecialValueInt('speed'))
    local ux, uy = predicted.x - start.x, predicted.y - start.y
    local forward = (ux * dx + uy * dy) / length
    local side = math.abs(ux * dy - uy * dx) / length
    local range = CastRange(BreatheFire)
    local width = BreatheFire:GetSpecialValueInt('start_radius')
        + (BreatheFire:GetSpecialValueInt('end_radius') - BreatheFire:GetSpecialValueInt('start_radius')) * forward / range
    return forward >= 0 and forward <= range and side <= width
end

function X.ConsiderBreatheFire()
    if not J.CanCastAbility(BreatheFire) then return 0 end
    local damage = BreatheFire:GetSpecialValueInt('damage')
    for _, enemy in ipairs(Enemies()) do
        local location = BreathLocation(enemy)
        local delay = BreatheFire:GetCastPoint() + GetUnitToUnitDistance(bot, enemy) / BreatheFire:GetSpecialValueInt('speed')
        if location ~= nil and MagicLethal(enemy, damage, delay) then return BOT_ACTION_DESIRE_HIGH, location end
    end
    local target = J.GetProperTarget(bot)
    if Enemy(target) and J.IsGoingOnSomeone(bot) then
        local location = BreathLocation(target)
        if location ~= nil then return BOT_ACTION_DESIRE_HIGH, location end
    end
    for _, enemy in ipairs(Enemies()) do
        local location = BreathLocation(enemy)
        if location ~= nil then
            if SaveNeeded(enemy) and not enemy:HasModifier('modifier_dragonknight_breathefire_reduction') then
                return BOT_ACTION_DESIRE_HIGH, location
            end
            if J.IsInTeamFight(bot, 1200) then
                local count = 0
                for _, other in ipairs(Enemies()) do if BreathHits(other, location) then count = count + 1 end end
                if count >= 2 then return BOT_ACTION_DESIRE_HIGH, location end
            elseif J.IsLaning(bot) and J.IsAllowedToSpam(bot, BreatheFire:GetManaCost()) then
                return BOT_ACTION_DESIRE_HIGH, location
            end
        end
    end
    if J.IsAllowedToSpam(bot, BreatheFire:GetManaCost()) and (J.IsFarming(bot) or J.IsPushing(bot) or J.IsDefending(bot) or J.IsLaning(bot)) then
        local creeps = Creeps(CastRange(BreatheFire))
        for _, creep in ipairs(creeps) do
            local location = BreathLocation(creep)
            if location ~= nil then
                local count = 0
                for _, other in ipairs(creeps) do if BreathHits(other, location) then count = count + 1 end end
                local lastHit = J.IsLaning(bot) and creep:GetHealth() > bot:GetAttackDamage()
                    and J.CanKillTarget(creep, damage, DAMAGE_TYPE_MAGICAL)
                    and not J.IsInRange(bot, creep, bot:GetAttackRange())
                if count >= 3 or lastHit then return BOT_ACTION_DESIRE_HIGH, location end
            end
        end
    end
    if J.IsValid(target) and (J.IsRoshan(target) or J.IsTormentor(target))
        and J.CanCastOnNonMagicImmune(target) and J.IsAllowedToSpam(bot, BreatheFire:GetManaCost()) then
        local location = BreathLocation(target)
        if location ~= nil then return BOT_ACTION_DESIRE_HIGH, location end
    end
    -- Point casting intentionally bypasses spell block/reflect; Fire is not a unit-target nuke.
    return 0
end

local function FireLocation(unit)
    local location = unit:GetExtrapolatedLocation(Fireball:GetCastPoint())
    local range = CastRange(Fireball)
    if GetUnitToLocationDistance(bot, location) > range then
        local edge = J.GetLocationTowardDistanceLocation(bot, location, range)
        if J.GetLocationToLocationDistance(location, edge) > Fireball:GetSpecialValueInt('radius') then return nil end
        location = edge
    end
    return location
end

function X.ConsiderFireball()
    if not J.CanCastAbility(Fireball) then return 0 end
    local target = J.GetProperTarget(bot)
    if Enemy(target) and J.IsGoingOnSomeone(bot) and not target:HasModifier('modifier_dragon_knight_fireball_burn') then
        local location = FireLocation(target)
        if location ~= nil and (J.IsDisabled(target) or J.IsInRange(bot, target, bot:GetAttackRange())) then
            return BOT_ACTION_DESIRE_HIGH, location
        end
    end
    local candidates = Enemies()
    local farming = (J.IsFarming(bot) or J.IsPushing(bot) or J.IsDefending(bot))
        and #J.GetNearbyHeroes(bot, 1600, true, BOT_MODE_NONE) == 0
        and J.IsAllowedToSpam(bot, Fireball:GetManaCost())
    if farming then candidates = Creeps(CastRange(Fireball) + Fireball:GetSpecialValueInt('radius')) end
    if farming or J.IsInTeamFight(bot, 1200) or J.IsDefending(bot) then
        for _, unit in ipairs(candidates) do
            local location = FireLocation(unit)
            if location ~= nil then
                local count = 0
                for _, other in ipairs(candidates) do
                    if not other:HasModifier('modifier_dragon_knight_fireball_burn')
                        and J.GetLocationToLocationDistance(other:GetExtrapolatedLocation(Fireball:GetCastPoint()), location)
                            <= Fireball:GetSpecialValueInt('radius') then count = count + 1 end
                end
                if count >= (farming and 3 or 2) then return BOT_ACTION_DESIRE_HIGH, location end
            end
        end
    end
    if J.IsValid(target) and (J.IsRoshan(target) or J.IsTormentor(target)) and J.CanCastOnNonMagicImmune(target)
        and J.IsAllowedToSpam(bot, Fireball:GetManaCost()) then
        local location = FireLocation(target)
        if location ~= nil then return BOT_ACTION_DESIRE_HIGH, location end
    end
    -- Damage is per second over a persistent zone; do not score it as immediate full-duration burst.
    return 0
end

function X.ConsiderDragonForm()
    if not J.CanCastAbility(DragonForm) or InDragonForm() or bot:IsDisarmed() then return 0 end
    local target = J.GetProperTarget(bot)
    local attackReach = bot:GetAttackRange() + DragonForm:GetSpecialValueInt('bonus_attack_range')
    local spellReach = DragonTail ~= nil and CastRange(DragonTail) + DragonForm:GetSpecialValueInt('bonus_ability_cast_range') or attackReach
    if J.IsGoingOnSomeone(bot) and J.IsValidHero(target) and J.CanBeAttacked(target)
        and not J.IsSuspiciousIllusion(target) and J.IsInRange(bot, target, math.max(attackReach, spellReach))
        and (J.GetHP(bot) >= 0.3 or bot:IsMagicImmune()) then return BOT_ACTION_DESIRE_HIGH end
    if J.IsInTeamFight(bot, 1200) and J.GetHP(bot) >= 0.3
        and #J.GetNearbyHeroes(bot, attackReach, true, BOT_MODE_NONE) > 0 then return BOT_ACTION_DESIRE_HIGH end
    if (J.IsValid(target) or J.IsValidBuilding(target)) and J.CanBeAttacked(target) and J.IsInRange(bot, target, attackReach)
        and (J.IsRoshan(target) or J.IsTormentor(target)
            or target:IsBuilding() and (J.IsPushing(bot) or J.IsDefending(bot))
                and #bot:GetNearbyLaneCreeps(800, false) > 0) then return BOT_ACTION_DESIRE_HIGH end
    if (J.IsFarming(bot) or J.IsPushing(bot) or J.IsDefending(bot)) and DragonForm:GetLevel() >= 2
        and #J.GetNearbyHeroes(bot, 1600, true, BOT_MODE_NONE) == 0
        and J.IsAllowedToSpam(bot, DragonForm:GetManaCost()) and #Creeps(attackReach) >= 3 then
        return BOT_ACTION_DESIRE_HIGH
    end
    return 0
end

function X.ConsiderStolenSpell(ability)
    bot = GetBot()
    local name = ability:GetName()
    if name ~= 'dragon_knight_breathe_fire' and name ~= 'dragon_knight_dragon_tail'
        and name ~= 'dragon_knight_fireball' and name ~= 'dragon_knight_elder_dragon_form' then return nil end
    if J.CanNotUseAbility(bot) then return false end
    Refresh()
    local desire, target
    if name == 'dragon_knight_breathe_fire' then BreatheFire = ability; desire, target = X.ConsiderBreatheFire()
    elseif name == 'dragon_knight_dragon_tail' then DragonTail = ability; desire, target = X.ConsiderDragonTail(false)
    elseif name == 'dragon_knight_fireball' then Fireball = ability; desire, target = X.ConsiderFireball()
    else DragonForm = ability; desire = X.ConsiderDragonForm() end
    if desire > 0 then
        if name == 'dragon_knight_dragon_tail' then bot:Action_UseAbilityOnEntity(ability, target)
        elseif name == 'dragon_knight_elder_dragon_form' then bot:Action_UseAbility(ability)
        else bot:Action_UseAbilityOnLocation(ability, target) end
        return true
    end
    return false
end

return X
