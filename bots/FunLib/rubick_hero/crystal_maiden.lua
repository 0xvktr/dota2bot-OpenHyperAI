local X = {}
local bot = GetBot()
local J = require(GetScriptDirectory()..'/FunLib/jmz_func')
local abilityQ,abilityW,abilityR,CrystalClone

local cloneOrigin, cloneExpires = nil, 0

local function RememberClone()
    cloneOrigin = bot:GetLocation()
    cloneExpires = DotaTime() + CrystalClone:GetSpecialValueInt('clone_duration')
end

local function CastRange(ability)
    local range = ability:GetCastRange()
    if J.IsItemAvailable('item_aether_lens') ~= nil then range = range + 225 end
    local supremacy = bot:GetAbilityByName('rubick_arcane_supremacy')
    if supremacy ~= nil and supremacy:IsTrained() and not J.HasBreakModifier(bot) then
        range = range + supremacy:GetSpecialValueInt('cast_range')
    end
    return range
end

local function Enemy(unit)
    return J.IsValidHero(unit) and J.CanCastOnNonMagicImmune(unit)
end

local function FrostbiteTarget(unit)
    return J.IsValid(unit) and J.CanCastOnNonMagicImmune(unit)
        and J.IsInRange(bot, unit, CastRange(abilityW)) and J.CanCastOnTargetAdvanced(unit)
        and not unit:HasModifier('modifier_antimage_counterspell')
        and not unit:HasModifier('modifier_antimage_counterspell_ally')
        and not unit:HasModifier('modifier_crystal_maiden_frostbite')
end

function X.ConsiderW()
    if not J.CanCastAbility(abilityW) then return 0 end
    local enemies = J.GetNearbyHeroes(bot, math.min(CastRange(abilityW), 1600), true, BOT_MODE_NONE)
    local duration = abilityW:GetSpecialValueFloat('duration')
    local damage = abilityW:GetSpecialValueInt('damage_per_second') * duration
    for _, enemy in ipairs(enemies) do
        if FrostbiteTarget(enemy) then
            -- Frostbite is a root: it cancels teleports, not arbitrary spell channels.
            if enemy:IsChanneling() and enemy:HasModifier('modifier_teleporting') then
                return BOT_ACTION_DESIRE_HIGH, enemy
            end
            if J.WillMagicKillTarget(bot, enemy, damage, abilityW:GetCastPoint() + duration) then
                return BOT_ACTION_DESIRE_HIGH, enemy
            end
        end
    end
    local target = J.GetProperTarget(bot)
    if J.IsGoingOnSomeone(bot) and Enemy(target) and FrostbiteTarget(target) and not J.IsDisabled(target) then
        return BOT_ACTION_DESIRE_HIGH, target
    end
    local best, power = nil, 0
    for _, enemy in ipairs(enemies) do
        if FrostbiteTarget(enemy) and not J.IsDisabled(enemy) then
            if J.IsRetreating(bot) and bot:WasRecentlyDamagedByHero(enemy, 3) then
                return BOT_ACTION_DESIRE_HIGH, enemy
            end
            if J.IsInTeamFight(bot, 1200) then
                local value = enemy:GetEstimatedDamageToTarget(false, bot, 3, DAMAGE_TYPE_PHYSICAL)
                if value > power then best, power = enemy, value end
            end
        end
    end
    if best then return BOT_ACTION_DESIRE_HIGH, best end
    if J.IsFarming(bot) and #enemies == 0 and J.IsAllowedToSpam(bot, abilityW:GetManaCost()) then
        local strongest = nil
        for _, creep in ipairs(bot:GetNearbyNeutralCreeps(math.min(CastRange(abilityW), 1600))) do
            if FrostbiteTarget(creep) and not creep:IsAncientCreep() and not J.IsOtherAllysTarget(creep)
                and creep:GetHealth() > bot:GetAttackDamage() * 2
                and (strongest == nil or creep:GetHealth() > strongest:GetHealth()) then strongest = creep end
        end
        if strongest then return BOT_ACTION_DESIRE_HIGH, strongest end
    end
    -- Non-ancient summons take four times the hero DPS; do not exclude them with hero-only checks.
    if not J.IsRetreating(bot) then
        for _, creep in ipairs(bot:GetNearbyCreeps(math.min(CastRange(abilityW), 1600), true)) do
            if FrostbiteTarget(creep) and not creep:IsAncientCreep() and creep:IsDominated()
                and creep:GetHealth() > bot:GetAttackDamage() * 2 then return BOT_ACTION_DESIRE_HIGH, creep end
        end
    end
    return 0
end

function X.ConsiderQ()
    if not J.CanCastAbility(abilityQ) then return 0 end
    local range, radius = CastRange(abilityQ), abilityQ:GetSpecialValueInt('radius')
    local delay, damage = abilityQ:GetCastPoint(), abilityQ:GetSpecialValueInt('nova_damage')
    local enemies = J.GetNearbyHeroes(bot, math.min(range + radius, 1600), true, BOT_MODE_NONE)
    if cloneOrigin ~= nil and DotaTime() < cloneExpires and CrystalClone ~= nil
        and damage >= CrystalClone:GetSpecialValueInt('clone_health')
        and GetUnitToLocationDistance(bot, cloneOrigin) <= range then
        for _, enemy in ipairs(enemies) do
            if Enemy(enemy) and GetUnitToLocationDistance(enemy, cloneOrigin) <= CrystalClone:GetSpecialValueInt('frostbite_radius') then
                return BOT_ACTION_DESIRE_HIGH, cloneOrigin
            end
        end
    end
    local function location(enemy)
        if not Enemy(enemy) then return nil end
        local loc = enemy:GetExtrapolatedLocation(delay)
        local distance = GetUnitToLocationDistance(bot, loc)
        if distance > range + radius then return nil end
        if distance > range then loc = J.GetLocationTowardDistanceLocation(bot, loc, range) end
        return loc
    end
    for _, enemy in ipairs(enemies) do
        local loc = location(enemy)
        if loc and J.WillMagicKillTarget(bot, enemy, damage, delay) then return BOT_ACTION_DESIRE_HIGH, loc end
    end
    if J.IsGoingOnSomeone(bot) then
        local loc = location(J.GetProperTarget(bot))
        if loc then return BOT_ACTION_DESIRE_HIGH, loc end
    end
    if J.IsRetreating(bot) then
        for _, enemy in ipairs(enemies) do
            local loc = location(enemy)
            if loc and bot:WasRecentlyDamagedByHero(enemy, 3) then return BOT_ACTION_DESIRE_HIGH, loc end
        end
    end
    if J.IsInTeamFight(bot, 1200) or bot:GetActiveMode() == BOT_MODE_LANING then
        local best, bestCount = nil, 1
        for _, enemy in ipairs(enemies) do
            local loc = location(enemy)
            if loc then
                local count = 0
                for _, other in ipairs(enemies) do
                    if Enemy(other) and GetUnitToLocationDistance(other, loc) <= radius then count = count + 1 end
                end
                if count > bestCount then best, bestCount = loc, count end
            end
        end
        if best and J.IsAllowedToSpam(bot, abilityQ:GetManaCost()) then return BOT_ACTION_DESIRE_HIGH, best end
    end
    if not J.IsAllowedToSpam(bot, abilityQ:GetManaCost()) then return 0 end
    if bot:GetActiveMode() == BOT_MODE_LANING then
        for _, creep in ipairs(bot:GetNearbyLaneCreeps(math.min(range + radius, 1600), true)) do
            if J.IsValid(creep) and J.IsKeyWordUnit('ranged', creep)
                and not creep:HasModifier('modifier_fountain_glyph')
                and J.WillMagicKillTarget(bot, creep, damage, delay)
                and GetUnitToLocationDistance(bot, creep:GetLocation()) <= range then
                for _, enemy in ipairs(enemies) do
                    if Enemy(enemy) and GetUnitToLocationDistance(enemy, creep:GetLocation()) <= radius then
                        return BOT_ACTION_DESIRE_HIGH, creep:GetLocation()
                    end
                end
            end
        end
    end
    if (J.IsFarming(bot) or J.IsPushing(bot) or J.IsDefending(bot)) and #enemies == 0 then
        local aoe = bot:FindAoELocation(true, false, bot:GetLocation(), range, radius, delay, damage)
        if aoe.count >= 3 and GetUnitToLocationDistance(bot, aoe.targetloc) <= range then
            return BOT_ACTION_DESIRE_HIGH, aoe.targetloc
        end
    end
    return 0
end

function X.ConsiderR()
    if not J.CanCastAbility(abilityR) or bot:DistanceFromFountain() < 500 then return 0 end
    local radius = abilityR:GetSpecialValueInt('radius')
    local count, controlled = 0, 0
    local target = J.GetProperTarget(bot)
    for _, enemy in ipairs(J.GetNearbyHeroes(bot, radius, true, BOT_MODE_NONE)) do
        if Enemy(enemy) and GetUnitToLocationDistance(bot, enemy:GetExtrapolatedLocation(1)) <= radius then
            count = count + 1
            if J.IsDisabled(enemy) then controlled = controlled + 1 end
        end
    end
    local protected = bot:IsMagicImmune() or bot:IsInvisible()
        or bot:HasModifier('modifier_item_glimmer_cape_fade') or bot:HasModifier('modifier_item_glimmer_cape')
    if bot:GetHealth() / bot:GetMaxHealth() < 0.35 and not protected then return 0 end
    if J.IsRetreating(bot) and not protected then return 0 end
    local allies = J.GetNearbyHeroes(bot, 1200, false, BOT_MODE_NONE)
    local supported = false
    for _, ally in ipairs(allies) do if ally ~= bot and J.IsValidHero(ally) then supported = true end end
    if count >= 2 and (protected or supported and (controlled > 0 or not bot:WasRecentlyDamagedByAnyHero(2))) then
        return BOT_ACTION_DESIRE_HIGH
    end
    if J.IsGoingOnSomeone(bot) and Enemy(target) and J.IsDisabled(target)
        and J.IsInRange(bot, target, radius) and target:GetHealth() > 300 and (protected or supported) then
        return BOT_ACTION_DESIRE_HIGH
    end
    return 0
end

function X.ConsiderCrystalClone()
    if not J.CanCastAbility(CrystalClone) then return 0 end
    local distance = CrystalClone:GetSpecialValueInt('hop_distance')
    local radius = CrystalClone:GetSpecialValueInt('frostbite_radius')
    local field = bot:HasModifier('modifier_crystal_maiden_freezing_field')
    if J.IsUnitTargetProjectileIncoming(bot, 800) or J.IsRetreating(bot) and bot:WasRecentlyDamagedByAnyHero(2) then
        return BOT_ACTION_DESIRE_HIGH, J.GetLocationTowardDistanceLocation(bot, J.GetTeamFountain(), distance)
    end
    local target = J.GetProperTarget(bot)
    if field and Enemy(target) and not J.IsInRange(bot, target, abilityR ~= nil and abilityR:GetSpecialValueInt('radius') * 0.75 or 600)
        and J.IsInRange(bot, target, 1000) then
        return BOT_ACTION_DESIRE_HIGH, J.GetLocationTowardDistanceLocation(bot, target:GetLocation(), distance)
    end
    if not field and J.IsGoingOnSomeone(bot) and Enemy(target) and J.IsInRange(bot, target, radius)
        and not J.IsDisabled(target) and J.CanCastAbility(bot:GetAbilityByName('crystal_maiden_crystal_nova')) then
        return BOT_ACTION_DESIRE_HIGH, J.GetLocationTowardDistanceLocation(bot, J.GetTeamFountain(), distance)
    end
    return 0
end

local function FieldCanCast()
    if bot:IsChanneling() then
        local active = bot:GetCurrentActiveAbility()
        if active == nil or active:GetName() ~= 'crystal_maiden_freezing_field' then return false end
    end
    return bot:HasModifier('modifier_crystal_maiden_freezing_field') and bot:IsAlive()
        and not bot:IsStunned() and not bot:IsHexed() and not bot:IsSilenced() and not bot:IsNightmared()
end

function X.ConsiderStolenSpell(ability)
    bot = GetBot()
    local name=ability:GetName()
    if name ~= 'crystal_maiden_crystal_nova' and name ~= 'crystal_maiden_frostbite'
        and name ~= 'crystal_maiden_freezing_field' and name ~= 'crystal_maiden_crystal_clone' then return nil end
    local field=FieldCanCast()
    if bot:IsCastingAbility() or bot:NumQueuedActions() > 0 then return false end
    if J.CanNotUseAbility(bot) and not field then return false end
    if field and name ~= 'crystal_maiden_crystal_clone' and not bot:HasScepter() then return false end
    local desire,target
    if name=='crystal_maiden_crystal_clone' then CrystalClone=ability; desire,target=X.ConsiderCrystalClone()
    elseif name=='crystal_maiden_crystal_nova' then abilityQ=ability; desire,target=X.ConsiderCrystalNova()
    elseif name=='crystal_maiden_frostbite' then abilityW=ability; desire,target=X.ConsiderFrostbite()
    else
        if field then return false end
        abilityR=ability; desire=X.ConsiderFreezingField()
        if desire > 0 then bot:Action_UseAbility(ability); return true end
    end
    if desire > 0 then
        if name=='crystal_maiden_frostbite' then bot:Action_UseAbilityOnEntity(ability,target)
        else
            if name=='crystal_maiden_crystal_clone' then RememberClone() end
            bot:Action_UseAbilityOnLocation(ability,target)
        end
        return true
    end
    return false
end

-- Called before Rubick's generic channel gate; only the observed Field grants these permissions.
function X.UseFreezingFieldSpell()
    bot = GetBot()
    if not FieldCanCast() or bot:IsCastingAbility() or bot:NumQueuedActions() > 0 then return false end
    for _, name in ipairs({'crystal_maiden_crystal_clone', 'crystal_maiden_frostbite', 'crystal_maiden_crystal_nova'}) do
        local ability = bot:GetAbilityByName(name)
        if J.CanCastAbility(ability) and X.ConsiderStolenSpell(ability) then return true end
    end
    return false
end

function X.ConsiderCombo() return false end
X.ConsiderCrystalNova=X.ConsiderQ
X.ConsiderFrostbite=X.ConsiderW
X.ConsiderFreezingField=X.ConsiderR
return X
