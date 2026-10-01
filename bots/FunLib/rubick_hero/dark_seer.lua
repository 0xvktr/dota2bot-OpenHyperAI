local bot = GetBot()
local X = {}
local J = require(GetScriptDirectory()..'/FunLib/jmz_func')
local Vacuum = bot:GetAbilityByName('dark_seer_vacuum')
local IonShell = bot:GetAbilityByName('dark_seer_ion_shell')
local Surge = bot:GetAbilityByName('dark_seer_surge')
local WallOfReplica = bot:GetAbilityByName('dark_seer_wall_of_replica')

local function CastRange(ability)
    local range = ability:GetCastRange()
    for slot = 0, 5 do
        local item = bot:GetItemInSlot(slot)
        if item ~= nil and item:GetName() == 'item_aether_lens' then
            range = range + item:GetSpecialValueInt('cast_range_bonus')
            break
        end
    end
    local supremacy = bot:GetAbilityByName('rubick_arcane_supremacy')
    if supremacy ~= nil and supremacy:IsTrained() and not J.HasBreakModifier(bot) then
        range = range + supremacy:GetSpecialValueInt('cast_range')
    end
    return range
end

local function Enemy(unit)
    return J.IsValidHero(unit) and J.CanCastOnNonMagicImmune(unit)
        and not unit:HasModifier('modifier_enigma_black_hole_pull')
        and not unit:HasModifier('modifier_faceless_void_chronosphere_freeze')
        and not unit:HasModifier('modifier_legion_commander_duel')
        and not unit:HasModifier('modifier_necrolyte_reapers_scythe')
end

local function Bound(location, range)
    local offset = location - bot:GetLocation()
    if offset:Length2D() > range then return bot:GetLocation() + offset:Normalized() * range end
    return location
end

local function PullLocation(unit)
    if not Enemy(unit) then return nil end
    local predicted = J.GetCorrectLoc(unit, Vacuum:GetCastPoint())
    local location = Bound(predicted, CastRange(Vacuum))
    if (predicted - location):Length2D() <= Vacuum:GetSpecialValueInt('radius') then return location end
    return nil
end

local function PullCount(location, delay)
    local count = 0
    for _, enemy in pairs(J.GetNearbyHeroes(bot, 1600, true, BOT_MODE_NONE)) do
        if Enemy(enemy) and (J.GetCorrectLoc(enemy, delay) - location):Length2D()
            <= Vacuum:GetSpecialValueInt('radius') then count = count + 1 end
    end
    return count
end

function X.ConsiderVacuum()
    if not J.CanCastAbility(Vacuum) then return BOT_ACTION_DESIRE_NONE end
    for _, enemy in pairs(J.GetNearbyHeroes(bot, 1600, true, BOT_MODE_NONE)) do
        local location = PullLocation(enemy)
        if location ~= nil then
            if enemy:IsChanneling() or J.IsCastingUltimateAbility(enemy) then
                return BOT_ACTION_DESIRE_HIGH, location, 'interrupt'
            end
            if not J.CannotBeKilled(bot, enemy)
                and J.WillKillTarget(enemy, Vacuum:GetSpecialValueInt('damage'), DAMAGE_TYPE_MAGICAL,
                    Vacuum:GetCastPoint() + Vacuum:GetSpecialValueFloat('duration')) then
                return BOT_ACTION_DESIRE_HIGH, location, 'lethal'
            end
        end
    end
    if J.IsInTeamFight(bot, 1200) then
        local aoe = bot:FindAoELocation(true, true, bot:GetLocation(), CastRange(Vacuum),
            Vacuum:GetSpecialValueInt('radius'), Vacuum:GetCastPoint(), 0)
        local location = Bound(aoe.targetloc, CastRange(Vacuum))
        if PullCount(location, Vacuum:GetCastPoint()) >= 2 then
            return BOT_ACTION_DESIRE_HIGH, location, 'cluster'
        end
    end
    local target = J.GetProperTarget(bot)
    if J.IsGoingOnSomeone(bot) and Enemy(target) and not J.IsDisabled(target) then
        local location = PullLocation(target)
        if location ~= nil then return BOT_ACTION_DESIRE_HIGH, location, 'catch' end
    end
    if J.IsRetreating(bot) and bot:WasRecentlyDamagedByAnyHero(2) then
        for _, enemy in pairs(J.GetNearbyHeroes(bot, 1000, true, BOT_MODE_NONE)) do
            if Enemy(enemy) and not J.IsDisabled(enemy) and J.IsChasingTarget(enemy, bot) then
                local location = PullLocation(enemy)
                if location ~= nil then return BOT_ACTION_DESIRE_HIGH, location, 'retreat' end
            end
        end
    end
    return BOT_ACTION_DESIRE_NONE
end

local function SafeBlink(location)
    return IsLocationPassable(location) and not J.IsLocationInChrono(location)
        and not J.IsLocationInBlackHole(location) and not J.IsLocationInArena(location, 600)
end

function X.ConsiderBlinkVacuum()
    if not J.CanCastAbility(Vacuum) or bot:IsRooted()
        or bot:HasModifier('modifier_bloodseeker_rupture')
        or not (J.IsGoingOnSomeone(bot) or J.IsInTeamFight(bot, 1600)) then return BOT_ACTION_DESIRE_NONE end
    local blink
    for slot = 0, 5 do
        local item = bot:GetItemInSlot(slot)
        if item ~= nil and item:IsFullyCastable() and (item:GetName() == 'item_blink'
            or item:GetName() == 'item_overwhelming_blink' or item:GetName() == 'item_arcane_blink'
            or item:GetName() == 'item_swift_blink') then blink = item; break end
    end
    if blink == nil or bot:GetMana() < Vacuum:GetManaCost() + blink:GetManaCost() then
        return BOT_ACTION_DESIRE_NONE
    end
    local aoe = bot:FindAoELocation(true, true, bot:GetLocation(),
        blink:GetSpecialValueInt('blink_range') + CastRange(Vacuum),
        Vacuum:GetSpecialValueInt('radius'), Vacuum:GetCastPoint() + 0.1, 0)
    local center = aoe.targetloc
    local distance = (center - bot:GetLocation()):Length2D()
    local blinkRange = blink:GetSpecialValueInt('blink_range') + CastRange(blink) - blink:GetCastRange()
    if distance <= CastRange(Vacuum) or distance > blinkRange + CastRange(Vacuum)
        or PullCount(center, Vacuum:GetCastPoint() + 0.1) < 2 then return BOT_ACTION_DESIRE_NONE end
    local landing = bot:GetLocation() + (center - bot:GetLocation()):Normalized()
        * math.min(blinkRange, math.max(0, distance - CastRange(Vacuum) + 50))
    if not SafeBlink(landing) then return BOT_ACTION_DESIRE_NONE end
    local allies, hasBot = 0, false
    for _, ally in pairs(J.GetAlliesNearLoc(center, 1000)) do
        if J.IsValidHero(ally) and not J.IsSuspiciousIllusion(ally) then
            allies = allies + 1
            if ally == bot then hasBot = true end
        end
    end
    if not hasBot then allies = allies + 1 end
    if allies < #J.GetEnemiesNearLoc(center, 1000) then return BOT_ACTION_DESIRE_NONE end
    return BOT_ACTION_DESIRE_HIGH, landing, center, blink
end

local function PointWallAvailable()
    -- The bot API exposes no verified pair of vector endpoints. Preserve point-mode compatibility only.
    return J.CanCastAbility(WallOfReplica)
        and bit.band(WallOfReplica:GetBehavior(), DOTA_ABILITY_BEHAVIOR_VECTOR_TARGETING or 1073741824) == 0
end

local function CanSurge(unit)
    return J.IsValidHero(unit) and not unit:IsInvulnerable() and not J.IsSuspiciousIllusion(unit)
        and J.IsInRange(bot, unit, CastRange(Surge)) and not unit:IsChanneling()
        and not unit:IsRooted() and not unit:IsStunned() and not unit:IsHexed() and not unit:IsNightmared()
        and not unit:HasModifier('modifier_bloodseeker_rupture')
        and not unit:HasModifier('modifier_dark_seer_surge')
        and not unit:HasModifier('modifier_necrolyte_reapers_scythe')
end

function X.ConsiderSurge()
    if not J.CanCastAbility(Surge) then return BOT_ACTION_DESIRE_NONE end
    local units = J.GetNearbyHeroes(bot, math.min(CastRange(Surge), 1600), false, BOT_MODE_NONE)
    table.insert(units, bot)
    local best, health = nil, 2
    for _, ally in pairs(units) do
        if CanSurge(ally) and ally:WasRecentlyDamagedByAnyHero(2)
            and (J.IsRetreating(ally) or J.GetHP(ally) < 0.45) then
            for _, enemy in pairs(J.GetNearbyHeroes(ally, 800, true, BOT_MODE_NONE)) do
                if J.IsValidHero(enemy) and not J.IsSuspiciousIllusion(enemy) and not J.IsDisabled(enemy)
                    and J.IsChasingTarget(enemy, ally) and J.GetHP(ally) < health then
                    best, health = ally, J.GetHP(ally)
                end
            end
        end
    end
    if best ~= nil then return BOT_ACTION_DESIRE_HIGH, best, true end
    for _, ally in pairs(units) do
        local target = J.GetProperTarget(ally)
        if CanSurge(ally) and J.IsGoingOnSomeone(ally) and J.IsValidHero(target)
            and not target:IsInvulnerable() and not J.IsSuspiciousIllusion(target)
            and not J.IsDisabled(target) and J.IsChasingTarget(ally, target)
            and J.IsInRange(ally, target, 1200)
            and not J.IsInRange(ally, target, ally:GetAttackRange() + 150) then
            return BOT_ACTION_DESIRE_HIGH, ally, false
        end
    end
    local objective, level
    if J.IsDoingRoshan(bot) then objective, level = J.GetCurrentRoshanLocation(), 3
    elseif J.IsDoingTormentor(bot) then objective, level = J.GetTormentorLocation(GetTeam()), 2 end
    if objective ~= nil and CanSurge(bot) and Surge:GetLevel() >= level
        and GetUnitToLocationDistance(bot, objective) > 1600
        and #J.GetNearbyHeroes(bot, 1200, true, BOT_MODE_NONE) == 0 then
        local reserve = 0
        for _, spell in pairs({Vacuum, IonShell}) do
            if J.CanCastAbility(spell) then reserve = reserve + spell:GetManaCost() end
        end
        if PointWallAvailable() then reserve = reserve + WallOfReplica:GetManaCost() end
        if bot:GetMana() - Surge:GetManaCost() >= reserve then return BOT_ACTION_DESIRE_HIGH, bot, false end
    end
    return BOT_ACTION_DESIRE_NONE
end

local function ShellHost(unit, enemy)
    return J.IsValid(unit) and not unit:IsInvulnerable()
        and (not enemy or not unit:IsMagicImmune())
        and J.IsInRange(bot, unit, CastRange(IonShell)) and J.GetHP(unit) > 0.35
        and not unit:HasModifier('modifier_necrolyte_reapers_scythe')
        and (not unit:HasModifier('modifier_dark_seer_ion_shell')
            or J.GetModifierTime(unit, 'modifier_dark_seer_ion_shell') <= 2)
        and (not enemy or (J.CanCastOnTargetAdvanced(unit)
            and not unit:HasModifier('modifier_antimage_counterspell')
            and not unit:HasModifier('modifier_antimage_counterspell_ally')))
end

local function ShellHits(host, units, radius)
    local count = 0
    for _, unit in pairs(units) do
        if unit ~= host and J.IsValid(unit) and not unit:IsInvulnerable() and not unit:IsMagicImmune()
            and J.IsInRange(host, unit, radius) then count = count + 1 end
    end
    return count
end

function X.ConsiderIonShell()
    if not J.CanCastAbility(IonShell) then return BOT_ACTION_DESIRE_NONE end
    local radius = IonShell:GetSpecialValueInt('radius')
    local heroes = J.GetNearbyHeroes(bot, 1600, true, BOT_MODE_NONE)
    local hosts = J.GetNearbyHeroes(bot, math.min(CastRange(IonShell), 1600), false, BOT_MODE_NONE)
    table.insert(hosts, bot)
    local enemyCreeps = bot:GetNearbyLaneCreeps(math.min(CastRange(IonShell), 1600), true)
    local allyCreeps = bot:GetNearbyLaneCreeps(math.min(CastRange(IonShell), 1600), false)
    for _, unit in pairs(allyCreeps) do table.insert(hosts, unit) end
    local best, score = nil, 0
    for _, host in pairs(hosts) do
        if ShellHost(host, false) then
            local hits = ShellHits(host, heroes, radius)
            if hits == 0 and J.IsValidHero(host) and not J.IsSuspiciousIllusion(host)
                and host:GetAttackRange() <= 326 and J.IsGoingOnSomeone(host) then
                local target = J.GetProperTarget(host)
                if J.IsValidHero(target) and J.CanCastOnNonMagicImmune(target)
                    and J.IsChasingTarget(host, target) and J.IsInRange(host, target, radius + 350) then hits = 0.5 end
            end
            if hits > score then best, score = host, hits end
        end
    end
    if best ~= nil and (J.IsGoingOnSomeone(bot) or J.IsInTeamFight(bot, 1200)
        or J.IsLaning(bot) or J.IsRetreating(bot)) then return BOT_ACTION_DESIRE_HIGH, best end
    local target = J.GetProperTarget(bot)
    if ((J.IsDoingRoshan(bot) and J.IsRoshan(target))
        or (J.IsDoingTormentor(bot) and J.IsTormentor(target)))
        and ShellHost(bot, false) and J.IsAttacking(bot) and J.IsInRange(bot, target, radius)
        and not target:IsMagicImmune() then return BOT_ACTION_DESIRE_HIGH, bot end
    local reserve = Surge ~= nil and Surge:IsTrained() and Surge:GetManaCost() or 0
    if bot:GetMana() - IonShell:GetManaCost() < reserve then return BOT_ACTION_DESIRE_NONE end
    if not (J.IsLaning(bot) or J.IsFarming(bot) or J.IsPushing(bot) or J.IsDefending(bot))
        or not J.IsAllowedToSpam(bot, IonShell:GetManaCost()) then return BOT_ACTION_DESIRE_NONE end
    local creeps = enemyCreeps
    if J.IsFarming(bot) then
        for _, unit in pairs(bot:GetNearbyNeutralCreeps(1000)) do table.insert(creeps, unit) end
    end
    for _, host in pairs(enemyCreeps) do table.insert(hosts, host) end
    best, score = nil, 1
    for _, host in pairs(hosts) do
        local isEnemy = host:GetTeam() ~= bot:GetTeam()
        if ShellHost(host, isEnemy) and (host == bot or host:GetAttackRange() <= 326)
            and (host == bot or not host:WasRecentlyDamagedByAnyHero(1)) then
            local hits = ShellHits(host, creeps, radius)
            if hits > score then best, score = host, hits end
        end
    end
    if best ~= nil then return BOT_ACTION_DESIRE_HIGH, best end
    return BOT_ACTION_DESIRE_NONE
end

function X.ConsiderWallOfReplica()
    if not PointWallAvailable() then return BOT_ACTION_DESIRE_NONE end
    for _, enemy in pairs(J.GetNearbyHeroes(bot, math.min(CastRange(WallOfReplica), 1600), true, BOT_MODE_NONE)) do
        if J.IsValidHero(enemy) and J.CanCastOnMagicImmune(enemy)
            and J.IsDisabled(enemy) and J.IsCore(enemy) and J.IsInRange(bot, enemy, CastRange(WallOfReplica)) then
            return BOT_ACTION_DESIRE_HIGH, J.GetCorrectLoc(enemy, WallOfReplica:GetCastPoint())
        end
    end
    return BOT_ACTION_DESIRE_NONE
end

function X.ConsiderStolenSpell(ability)
    bot = GetBot()
    local name = ability:GetName()
    if name ~= 'dark_seer_vacuum' and name ~= 'dark_seer_ion_shell'
        and name ~= 'dark_seer_surge' and name ~= 'dark_seer_wall_of_replica' then return nil end
    Vacuum = bot:GetAbilityByName('dark_seer_vacuum')
    IonShell = bot:GetAbilityByName('dark_seer_ion_shell')
    Surge = bot:GetAbilityByName('dark_seer_surge')
    WallOfReplica = bot:GetAbilityByName('dark_seer_wall_of_replica')
    if J.CanNotUseAbility(bot) then return false end
    local desire, target
    if name == 'dark_seer_vacuum' then
        Vacuum = ability
        local reason
        desire, target, reason = X.ConsiderVacuum()
        if desire > 0 and (reason == 'interrupt' or reason == 'lethal') then
            bot:Action_UseAbilityOnLocation(ability, target); return true
        end
        local blinkDesire, landing, center, blink = X.ConsiderBlinkVacuum()
        if blinkDesire > 0 then
            bot:Action_ClearActions(false)
            bot:ActionQueue_UseAbilityOnLocation(blink, landing)
            bot:ActionQueue_UseAbilityOnLocation(ability, center)
            return true
        end
        if desire > 0 then bot:Action_UseAbilityOnLocation(ability, target); return true end
    elseif name == 'dark_seer_ion_shell' then
        IonShell = ability
        desire, target = X.ConsiderIonShell()
        if desire > 0 then bot:Action_UseAbilityOnEntity(ability, target); return true end
    elseif name == 'dark_seer_surge' then
        Surge = ability
        desire, target = X.ConsiderSurge()
        if desire > 0 then bot:Action_UseAbilityOnEntity(ability, target); return true end
    else
        WallOfReplica = ability
        desire, target = X.ConsiderWallOfReplica()
        if desire > 0 then bot:Action_UseAbilityOnLocation(ability, target); return true end
    end
    return false
end

return X
