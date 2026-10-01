local X = {}
local bot = GetBot()
local J = require(GetScriptDirectory()..'/FunLib/jmz_func')
local FrostArrows, Gust, Multishot, Glacier

local function Refresh()
    FrostArrows = bot:GetAbilityByName('drow_ranger_frost_arrows')
    Gust = bot:GetAbilityByName('drow_ranger_wave_of_silence')
    Multishot = bot:GetAbilityByName('drow_ranger_multishot')
    Glacier = bot:GetAbilityByName('drow_ranger_glacier')
end

local function SpellRange(ability)
    local range = ability:GetCastRange()
    local lens = J.IsItemAvailable('item_aether_lens')
    if lens ~= nil then range = range + lens:GetSpecialValueInt('cast_range_bonus') end
    local supremacy = bot:GetAbilityByName('rubick_arcane_supremacy')
    if supremacy ~= nil and supremacy:IsTrained() and not J.HasBreakModifier(bot) then
        range = range + supremacy:GetSpecialValueInt('cast_range')
    end
    return range
end

local function Enemy(unit, physical)
    return J.IsValidHero(unit) and not J.IsSuspiciousIllusion(unit)
        and (physical and J.CanCastOnMagicImmune(unit) and not unit:IsAttackImmune()
            and not J.IsInEtherealForm(unit)
            and not unit:HasModifier('modifier_omniknight_guardian_angel')
            and not unit:HasModifier('modifier_winter_wyvern_cold_embrace')
            or not physical and J.CanCastOnNonMagicImmune(unit))
end

local function Enemies(physical)
    local result = {}
    for _, unit in pairs(GetUnitList(UNIT_LIST_ENEMY_HEROES)) do
        if Enemy(unit, physical) then result[#result + 1] = unit end
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

local function GustLocation(enemy)
    local reach = SpellRange(Gust)
    local delay = Gust:GetCastPoint() + GetUnitToUnitDistance(bot, enemy) / Gust:GetSpecialValueInt('wave_speed')
    local location = enemy:GetExtrapolatedLocation(delay)
    -- The wave uses directional aim. Avoid claiming radial AoE reach beyond its live travel length.
    if GetUnitToLocationDistance(bot, location) > reach then return nil end
    return location
end

function X.ConsiderGust()
    if not J.CanCastAbility(Gust) then return 0 end
    for _, enemy in ipairs(Enemies(false)) do
        local location = GustLocation(enemy)
        if location ~= nil and not enemy:IsSilenced() and enemy:IsChanneling()
            and not enemy:HasModifier('modifier_teleporting') then return BOT_ACTION_DESIRE_HIGH, location end
    end
    for _, enemy in ipairs(Enemies(false)) do
        local location = GustLocation(enemy)
        if location ~= nil and (SaveNeeded(enemy)
            or J.IsInRange(bot, enemy, 350) and (J.IsGoingOnSomeone(bot) or J.IsInTeamFight(bot, 1200))) then
            return BOT_ACTION_DESIRE_HIGH, location
        end
    end
    local target = J.GetProperTarget(bot)
    if Enemy(target, false) and not target:IsSilenced() and J.IsGoingOnSomeone(bot) then
        local location = GustLocation(target)
        if location ~= nil then return BOT_ACTION_DESIRE_HIGH, location end
    end
    if J.IsInTeamFight(bot, 1200) then
        local best, power = nil, 0
        for _, enemy in ipairs(Enemies(false)) do
            local location = GustLocation(enemy)
            if location ~= nil and not enemy:IsSilenced() then
                local value = enemy:GetEstimatedDamageToTarget(false, bot, 3, DAMAGE_TYPE_ALL)
                if value > power then best, power = location, value end
            end
        end
        if best ~= nil then return BOT_ACTION_DESIRE_HIGH, best end
    end
    return 0
end

function X.ConsiderGlacier(defensiveOnly)
    if not J.CanCastAbility(Glacier) then return 0 end
    for _, enemy in ipairs(Enemies(false)) do
        if J.IsInRange(bot, enemy, 300)
            and (bot:WasRecentlyDamagedByHero(enemy, 3) or J.IsChasingTarget(enemy, bot)) then
            return BOT_ACTION_DESIRE_HIGH
        end
    end
    if defensiveOnly or bot:IsDisarmed() then return 0 end
    local target = J.GetProperTarget(bot)
    local reach = bot:GetAttackRange() + Glacier:GetSpecialValueInt('attack_range_bonus')
    if Enemy(target, true) and J.IsGoingOnSomeone(bot) and J.IsInRange(bot, target, reach)
        and J.GetHP(bot) >= 0.35 then return BOT_ACTION_DESIRE_HIGH end
    if J.IsInTeamFight(bot, 1200) and not J.IsRetreating(bot) and J.GetHP(bot) >= 0.35 then
        for _, enemy in ipairs(Enemies(true)) do
            if J.IsInRange(bot, enemy, reach) then return BOT_ACTION_DESIRE_HIGH end
        end
    end
    if J.IsValidBuilding(target) and J.CanBeAttacked(target) and J.IsPushing(bot)
        and J.IsInRange(bot, target, reach) and #bot:GetNearbyLaneCreeps(800, false) > 0
        and #J.GetNearbyHeroes(bot, 1000, true, BOT_MODE_NONE) == 0 then return BOT_ACTION_DESIRE_HIGH end
    return 0
end

-- Current localization explicitly permits Glacier during Multishot, but not during other channels.
function X.UseGlacierDuringMultishot()
    bot = GetBot()
    if not bot:IsChanneling() or not bot:IsAlive() or bot:IsCastingAbility() or bot:NumQueuedActions() > 0
        or bot:IsSilenced() or bot:IsStunned() or bot:IsHexed() or bot:IsNightmared() then return false end
    local active = bot:GetCurrentActiveAbility()
    if active == nil or active:GetName() ~= 'drow_ranger_multishot' then return false end
    Glacier = bot:GetAbilityByName('drow_ranger_glacier')
    if X.ConsiderGlacier(true) > 0 then bot:Action_UseAbility(Glacier); return true end
    return false
end

local function MultishotRange()
    return bot:GetAttackRange() * Multishot:GetSpecialValueFloat('arrow_range_multiplier')
        + Multishot:GetSpecialValueInt('arrow_range_base')
end

local function MultiLocation(unit)
    local delay = Multishot:GetCastPoint() + GetUnitToUnitDistance(bot, unit) / Multishot:GetSpecialValueInt('arrow_speed')
    local location = unit:GetExtrapolatedLocation(delay)
    if GetUnitToLocationDistance(bot, location) > MultishotRange() then return nil end
    return location
end

local function MultiHits(unit, location)
    local start = bot:GetLocation()
    local dx, dy = location.x - start.x, location.y - start.y
    local length = math.sqrt(dx * dx + dy * dy)
    if length == 0 then return false end
    local predicted = unit:GetExtrapolatedLocation(Multishot:GetCastPoint()
        + GetUnitToUnitDistance(bot, unit) / Multishot:GetSpecialValueInt('arrow_speed'))
    local ux, uy = predicted.x - start.x, predicted.y - start.y
    local forward = (ux * dx + uy * dy) / length
    local side = math.abs(ux * dy - uy * dx) / length
    local width = Multishot:GetSpecialValueInt('arrow_width')
        + math.tan(math.rad(Multishot:GetSpecialValueInt('arrow_angle') / 2)) * forward
    return forward > 0 and forward <= MultishotRange() and side <= width
end

function X.ConsiderMultishot()
    if not J.CanCastAbility(Multishot) then return 0 end
    -- Preserve an escape window before committing to a channel under immediate pressure.
    if not bot:IsMagicImmune() then
        for _, enemy in ipairs(J.GetNearbyHeroes(bot, 300, true, BOT_MODE_NONE)) do
            if J.IsValidHero(enemy) and not J.IsSuspiciousIllusion(enemy) and not J.IsDisabled(enemy) then return 0 end
        end
    end
    if J.GetHP(bot) < 0.35 and bot:WasRecentlyDamagedByAnyHero(2) and not bot:IsMagicImmune() then return 0 end
    local target = J.GetProperTarget(bot)
    if Enemy(target, true) and J.IsGoingOnSomeone(bot) then
        local location = MultiLocation(target)
        if location ~= nil then return BOT_ACTION_DESIRE_HIGH, location end
    end
    if J.IsInTeamFight(bot, 1200) or J.IsDefending(bot) then
        local enemies = Enemies(true)
        for _, enemy in ipairs(enemies) do
            local location = MultiLocation(enemy)
            if location ~= nil then
                local count = 0
                for _, other in ipairs(enemies) do if MultiHits(other, location) then count = count + 1 end end
                if count >= 2 then return BOT_ACTION_DESIRE_HIGH, location end
            end
        end
    end
    if (J.IsFarming(bot) or J.IsPushing(bot) or J.IsDefending(bot)) and J.IsAllowedToSpam(bot, Multishot:GetManaCost())
        and #J.GetNearbyHeroes(bot, 1600, true, BOT_MODE_NONE) == 0 then
        local creeps, seen = {}, {}
        for _, group in ipairs({bot:GetNearbyCreeps(MultishotRange(), true), bot:GetNearbyNeutralCreeps(MultishotRange())}) do
            for _, creep in ipairs(group) do
                if not seen[creep] and J.IsValid(creep) and J.CanCastOnMagicImmune(creep)
                    and not creep:IsAttackImmune() and not J.IsInEtherealForm(creep) then
                    creeps[#creeps + 1] = creep; seen[creep] = true
                end
            end
        end
        for _, creep in ipairs(creeps) do
            local location = MultiLocation(creep)
            if location ~= nil then
                local count = 0
                for _, other in ipairs(creeps) do if MultiHits(other, location) then count = count + 1 end end
                if count >= 3 then return BOT_ACTION_DESIRE_HIGH, location end
            end
        end
    end
    -- Physical arrows pierce debuff immunity, but never score every arrow/wave as guaranteed burst.
    return 0
end

function X.ConsiderFrostArrows()
    if not J.CanCastAbility(FrostArrows) or bot:IsDisarmed() then return 0 end
    local function legal(unit)
        return J.IsValid(unit) and J.CanBeAttacked(unit) and J.CanCastOnNonMagicImmune(unit)
            and not J.IsInEtherealForm(unit) and J.IsInRange(bot, unit, bot:GetAttackRange())
    end
    local target = J.GetProperTarget(bot)
    local reserve = J.CanCastAbility(Gust) and Gust:GetManaCost() or 0
    local enoughMana = bot:GetMana() >= FrostArrows:GetManaCost() + reserve
    if legal(target) and J.IsValidHero(target) and not J.IsSuspiciousIllusion(target)
        and enoughMana and (J.IsGoingOnSomeone(bot) or J.IsLaning(bot) and J.IsAllowedToSpam(bot, FrostArrows:GetManaCost())) then
        return BOT_ACTION_DESIRE_HIGH, target
    end
    if J.IsLaning(bot) and enoughMana then
        for _, creep in ipairs(bot:GetNearbyLaneCreeps(bot:GetAttackRange(), true)) do
            if legal(creep) and creep:GetHealth() > bot:GetAttackDamage()
                and J.CanKillTarget(creep, bot:GetAttackDamage() + FrostArrows:GetSpecialValueInt('damage'), DAMAGE_TYPE_PHYSICAL) then
                return BOT_ACTION_DESIRE_HIGH, creep
            end
        end
    end
    if legal(target) and not J.IsValidHero(target) and bot:HasScepter() and enoughMana
        and (J.IsFarming(bot) or J.IsRoshan(target) or J.IsTormentor(target))
        and J.IsAllowedToSpam(bot, FrostArrows:GetManaCost()) then return BOT_ACTION_DESIRE_HIGH, target end
    -- This is an attack orb: actual attack reach/disarm apply, not Lens, Supremacy or spell reflection.
    return 0
end

function X.ConsiderStolenSpell(ability)
    bot = GetBot()
    local name = ability:GetName()
    if name ~= 'drow_ranger_frost_arrows' and name ~= 'drow_ranger_wave_of_silence'
        and name ~= 'drow_ranger_multishot' and name ~= 'drow_ranger_glacier' then return nil end
    if bot:IsChanneling() then
        if name == 'drow_ranger_glacier' then return X.UseGlacierDuringMultishot() end
        return false
    end
    if J.CanNotUseAbility(bot) then return false end
    Refresh()
    local desire, target
    if name == 'drow_ranger_frost_arrows' then FrostArrows = ability; desire, target = X.ConsiderFrostArrows()
    elseif name == 'drow_ranger_wave_of_silence' then Gust = ability; desire, target = X.ConsiderGust()
    elseif name == 'drow_ranger_multishot' then Multishot = ability; desire, target = X.ConsiderMultishot()
    else Glacier = ability; desire = X.ConsiderGlacier(false) end
    if desire > 0 then
        if name == 'drow_ranger_frost_arrows' then bot:Action_UseAbilityOnEntity(ability, target)
        elseif name == 'drow_ranger_glacier' then bot:Action_UseAbility(ability)
        else bot:Action_UseAbilityOnLocation(ability, target) end
        return true
    end
    return false
end

return X
