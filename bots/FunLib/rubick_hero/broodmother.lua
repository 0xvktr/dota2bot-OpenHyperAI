local bot = GetBot()
local X = {}
local J = require(GetScriptDirectory()..'/FunLib/jmz_func')
local InsatiableHunger, SpinWeb, SpawnSpiderlings

local LastWebTime = -math.huge

local function Castable(ability)
    return ability ~= nil and ability:IsFullyCastable() and not ability:IsHidden()
end

local function CastRange(ability)
    local range = ability:GetCastRange()
    local lens = J.IsItemAvailable('item_aether_lens')
    if lens ~= nil then range = range + lens:GetSpecialValueInt('cast_range_bonus') end
    local supremacy = bot:GetAbilityByName('rubick_arcane_supremacy')
    if supremacy ~= nil and supremacy:IsTrained() and not J.HasBreakModifier(bot) then
        range = range + supremacy:GetSpecialValueInt('cast_range')
    end
    return range
end

local function OwnWebs()
    local webs = {}
    for _, unit in pairs(GetUnitList(UNIT_LIST_ALLIES)) do
        if J.IsValid(unit) and unit:GetUnitName() == 'npc_dota_broodmother_web'
            and unit:GetPlayerID() == bot:GetPlayerID() then table.insert(webs, unit) end
    end
    return webs
end

function X.DoesLocationHaveWeb(location, radius)
    for _, web in pairs(OwnWebs()) do
        if GetUnitToLocationDistance(web, location) <= radius then return true end
    end
    return false
end

local function WebLocation(location)
    local radius = SpinWeb:GetSpecialValueInt('radius')
    -- A nearby web only suppresses a cast if the desired area is well inside it.
    -- Edge overlap is useful for extending a connected travel/farming corridor.
    if X.DoesLocationHaveWeb(location, radius * 0.65)
        or J.IsLocationInChrono(location) or J.IsLocationInBlackHole(location) then return nil end
    if GetUnitToLocationDistance(bot, location) <= CastRange(SpinWeb)
        or X.DoesLocationHaveWeb(location, radius * 2 - 50) then return location end
    return nil
end

local function CanSpawn(target)
    return J.IsValid(target) and J.CanCastOnNonMagicImmune(target)
        and J.CanCastOnTargetAdvanced(target)
        and not target:HasModifier('modifier_antimage_counterspell')
        and not target:HasModifier('modifier_antimage_counterspell_ally')
        and J.IsInRange(bot, target, CastRange(SpawnSpiderlings))
end

local function Protected(target)
    return target:HasModifier('modifier_abaddon_borrowed_time')
        or target:HasModifier('modifier_dazzle_shallow_grave')
        or target:HasModifier('modifier_oracle_false_promise_timer')
        or target:HasModifier('modifier_necrolyte_reapers_scythe')
        or target:HasModifier('modifier_templar_assassin_refraction_absorb')
end

local function FarmMana(ability)
    local hunger = bot:GetAbilityByName('broodmother_insatiable_hunger')
    local reserve = hunger ~= nil and hunger:IsTrained() and hunger:GetManaCost() or 0
    return bot:GetMana() - ability:GetManaCost() >= reserve
        and (bot:GetMana() - ability:GetManaCost()) / bot:GetMaxMana() >= 0.25
end

function X.ConsiderInsatiableHunger()
    if not Castable(InsatiableHunger) or bot:HasModifier('modifier_broodmother_insatiable_hunger')
        or bot:IsDisarmed() then return BOT_ACTION_DESIRE_NONE end
    local target = J.GetProperTarget(bot)
    local attackRange = bot:GetAttackRange()
    if J.IsValidHero(target) and J.CanBeAttacked(target) and not J.IsSuspiciousIllusion(target)
        and not Protected(target) and J.IsInRange(bot, target, attackRange + 150)
        and (J.IsGoingOnSomeone(bot) or J.IsInTeamFight(bot, 1200)) then
        -- Controlled targets remain good attack opportunities, including Roar/Arena setup.
        return BOT_ACTION_DESIRE_HIGH
    end
    if not J.IsAttacking(bot) or not J.IsValid(target) or not J.CanBeAttacked(target)
        or not J.IsInRange(bot, target, attackRange + 100) then return BOT_ACTION_DESIRE_NONE end
    if ((J.IsDoingRoshan(bot) and J.IsRoshan(target))
        or (J.IsDoingTormentor(bot) and J.IsTormentor(target))) then return BOT_ACTION_DESIRE_HIGH end
    if J.IsPushing(bot) and J.IsKeyWordUnit('tower', target) then return BOT_ACTION_DESIRE_HIGH end
    if (J.IsLaning(bot) or J.IsFarming(bot) or J.IsPushing(bot) or J.IsDefending(bot))
        and J.GetHP(bot) < 0.65 and not J.IsKeyWordUnit('tower', target) then
        return BOT_ACTION_DESIRE_HIGH
    end
    return BOT_ACTION_DESIRE_NONE
end

function X.ConsiderSpinWeb()
    if not Castable(SpinWeb) or DotaTime() - LastWebTime < 1 then return BOT_ACTION_DESIRE_NONE, nil end
    local target = J.GetProperTarget(bot)
    if J.IsStuck(bot) then
        local location = WebLocation(bot:GetLocation())
        if location ~= nil then return BOT_ACTION_DESIRE_HIGH, location end
    end
    if J.IsRetreating(bot) and bot:WasRecentlyDamagedByAnyHero(2) then
        local location = WebLocation(J.Site.GetXUnitsTowardsLocation(bot, J.GetTeamFountain(), 600))
        if location ~= nil then return BOT_ACTION_DESIRE_HIGH, location end
    end
    if J.IsGoingOnSomeone(bot) and J.IsValidHero(target) and not J.IsSuspiciousIllusion(target)
        and not Protected(target) and J.IsInRange(bot, target, 1600) then
        local location = WebLocation(target:GetExtrapolatedLocation(SpinWeb:GetCastPoint()))
        if location ~= nil then return BOT_ACTION_DESIRE_HIGH, location end
    end
    if J.IsInTeamFight(bot, 1200) then
        local aoe = bot:FindAoELocation(true, true, bot:GetLocation(), CastRange(SpinWeb),
            SpinWeb:GetSpecialValueInt('radius') * 0.65, SpinWeb:GetCastPoint(), 0)
        if aoe.count >= 2 then
            local location = WebLocation(aoe.targetloc)
            if location ~= nil then return BOT_ACTION_DESIRE_HIGH, location end
        end
    end
    if (J.IsLaning(bot) or J.IsFarming(bot) or J.IsPushing(bot) or J.IsDefending(bot))
        and FarmMana(SpinWeb) then
        local creeps = bot:GetNearbyLaneCreeps(1200, true)
        if J.IsFarming(bot) and #creeps == 0 then creeps = bot:GetNearbyNeutralCreeps(1000) end
        if #creeps > 0 then
            local location = WebLocation(J.GetCenterOfUnits(creeps))
            if location ~= nil then return BOT_ACTION_DESIRE_HIGH, location end
        end
        if J.IsPushing(bot) and J.IsValid(target) and J.IsKeyWordUnit('tower', target) then
            local location = WebLocation(target:GetLocation())
            if location ~= nil then return BOT_ACTION_DESIRE_HIGH, location end
        end
    end
    if ((J.IsDoingRoshan(bot) and J.IsRoshan(target))
        or (J.IsDoingTormentor(bot) and J.IsTormentor(target))) and J.IsAttacking(bot) then
        local location = WebLocation(target:GetLocation())
        if location ~= nil then return BOT_ACTION_DESIRE_HIGH, location end
    end
    return BOT_ACTION_DESIRE_NONE, nil
end

function X.ConsiderSpawnSpiderlings()
    if not Castable(SpawnSpiderlings) then return BOT_ACTION_DESIRE_NONE, nil end
    local range, damage = CastRange(SpawnSpiderlings), SpawnSpiderlings:GetSpecialValueInt('damage')
    local enemies = J.GetNearbyHeroes(bot, math.min(range, 1600), true, BOT_MODE_NONE)
    for _, enemy in pairs(enemies) do
        if CanSpawn(enemy) and not J.IsSuspiciousIllusion(enemy) and not Protected(enemy)
            and J.CanKillTarget(enemy, damage, DAMAGE_TYPE_MAGICAL) then
            return BOT_ACTION_DESIRE_HIGH, enemy
        end
    end
    if J.IsRetreating(bot) and bot:WasRecentlyDamagedByAnyHero(2) then
        for _, enemy in pairs(enemies) do
            if CanSpawn(enemy) and not J.IsSuspiciousIllusion(enemy) and not J.IsDisabled(enemy)
                and J.IsChasingTarget(enemy, bot)
                and not enemy:HasModifier('modifier_broodmother_spawn_spiderlings_slow') then
                return BOT_ACTION_DESIRE_HIGH, enemy
            end
        end
    end
    local target = J.GetProperTarget(bot)
    if J.IsGoingOnSomeone(bot) and J.IsValidHero(target) and CanSpawn(target)
        and not J.IsSuspiciousIllusion(target) and not Protected(target)
        and not target:HasModifier('modifier_broodmother_spawn_spiderlings_slow') then
        return BOT_ACTION_DESIRE_HIGH, target
    end
    if not J.IsRetreating(bot) and FarmMana(SpawnSpiderlings) then
        local creeps = bot:GetNearbyLaneCreeps(math.min(range, 1600), true)
        if J.IsFarming(bot) then
            for _, creep in pairs(bot:GetNearbyNeutralCreeps(math.min(range, 1600))) do table.insert(creeps, creep) end
        end
        for _, creep in pairs(creeps) do
            if CanSpawn(creep) and J.CanBeAttacked(creep)
                and (J.CanKillTarget(creep, damage, DAMAGE_TYPE_MAGICAL)
                    or J.IsFarming(bot) and J.IsAttacking(bot) and creep == target
                        and not creep:HasModifier('modifier_broodmother_spawn_spiderlings')
                        and creep:GetHealth() <= creep:GetActualIncomingDamage(damage, DAMAGE_TYPE_MAGICAL)
                            + creep:GetActualIncomingDamage(bot:GetAttackDamage() * 2, DAMAGE_TYPE_PHYSICAL)) then
                return BOT_ACTION_DESIRE_HIGH, creep
            end
        end
    end
    return BOT_ACTION_DESIRE_NONE, nil
end

function X.ConsiderStolenSpell(ability)
    bot = GetBot()
    local name = ability:GetName()
    if name ~= 'broodmother_spawn_spiderlings' and name ~= 'broodmother_spin_web'
        and name ~= 'broodmother_insatiable_hunger' then return nil end
    if J.CanNotUseAbility(bot) then return false end
    if name == 'broodmother_spawn_spiderlings' then
        SpawnSpiderlings = ability
        local desire, target = X.ConsiderSpawnSpiderlings()
        if desire > 0 then bot:Action_UseAbilityOnEntity(ability, target); return true end
    elseif name == 'broodmother_spin_web' then
        SpinWeb = ability
        local desire, location = X.ConsiderSpinWeb()
        if desire > 0 then
            bot:Action_UseAbilityOnLocation(ability, location)
            LastWebTime = DotaTime()
            return true
        end
    else
        InsatiableHunger = ability
        if X.ConsiderInsatiableHunger() > 0 then bot:Action_UseAbility(ability); return true end
    end
    return false
end

return X
