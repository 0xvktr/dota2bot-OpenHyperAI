local bot
local X = {}
local J = require(GetScriptDirectory()..'/FunLib/jmz_func')

local ColdFeet
local IceVortex
local ChillingTouch
local IceBlast
local IceBlastRelease

-- The last Ice Blast cast: where the tracer started, where it is aimed, and when.
local IceBlastCast

local botTarget

function X.ConsiderStolenSpell(ability)
    bot = GetBot()
    local abilityName = ability:GetName()

    -- Release ignores silence, so it is checked before the generic can-cast gate; a missed release
    -- sends the tracer off the map.
    if abilityName == 'ancient_apparition_ice_blast_release'
    then
        IceBlastRelease = ability
        IceBlastReleaseDesire = X.ConsiderIceBlastRelease()
        if IceBlastReleaseDesire > 0
        and bot:IsAlive()
        and not bot:IsStunned()
        and not bot:IsHexed()
        and not bot:IsNightmared()
        and not bot:IsChanneling()
        then
            bot:Action_UseAbility(IceBlastRelease)
        end
        return
    end

    if J.CanNotUseAbility(bot) then return end

    botTarget = J.GetProperTarget(bot)

    if abilityName == 'ancient_apparition_ice_blast'
    then
        IceBlast = ability
        IceBlastDesire, IceBlastLocation = X.ConsiderIceBlast()
        if IceBlastDesire > 0
        then
            bot:Action_UseAbilityOnLocation(IceBlast, IceBlastLocation)
            IceBlastCast = { origin = bot:GetLocation(), target = IceBlastLocation, time = DotaTime() }
            return
        end
    end

    if abilityName == 'ancient_apparition_ice_vortex'
    then
        IceVortex = ability
        IceVortexDesire, IceVortextLocation = X.ConsiderIceVortex()
        if IceVortexDesire > 0
        then
            bot:Action_UseAbilityOnLocation(IceVortex, IceVortextLocation)
            return
        end
    end

    if abilityName == 'ancient_apparition_cold_feet'
    then
        ColdFeet = ability
        ColdFeetDesire, ColdFeetTarget = X.ConsiderColdFeet()
        if ColdFeetDesire > 0
        then
            -- Can't get AoE AA talent; so just entity
            bot:Action_UseAbilityOnEntity(ColdFeet, ColdFeetTarget)
            return
        end
    end

    if abilityName == 'ancient_apparition_chilling_touch'
    then
        ChillingTouch = ability
        ChillingTouchDesire, ChillingTouchTarget = X.ConsiderChillingTouch()
        if ChillingTouchDesire > 0
        then
            bot:Action_UseAbilityOnEntity(ChillingTouch, ChillingTouchTarget)
            return
        end
    end
end

function X.ConsiderColdFeet()
    if not ColdFeet:IsFullyCastable()
    then
        return BOT_ACTION_DESIRE_NONE, nil
    end

    local nCastRange = J.GetProperCastRange(false, bot, ColdFeet:GetCastRange())

    -- Follow-up lockdown: a stunned/rooted/lifted enemy cannot walk out of the break distance, and
    -- the Cold Feet stun then chains onto the disable.
    if J.IsInTeamFight(bot, 1200) or J.IsGoingOnSomeone(bot)
    then
        for _, enemyHero in pairs(J.GetNearbyHeroes(bot, nCastRange, true, BOT_MODE_NONE))
        do
            if J.IsValidHero(enemyHero)
            and J.CanCastOnNonMagicImmune(enemyHero)
            and J.CanCastOnTargetAdvanced(enemyHero)
            and J.IsInRange(bot, enemyHero, nCastRange)
            and J.IsDisabled(enemyHero)
            and not J.IsSuspiciousIllusion(enemyHero)
            and not enemyHero:HasModifier('modifier_cold_feet')
            and not enemyHero:HasModifier('modifier_necrolyte_reapers_scythe')
            then
                return BOT_ACTION_DESIRE_HIGH, enemyHero
            end
        end
    end

    local nAllyHeroes = J.GetNearbyHeroes(bot,nCastRange + 150, false, BOT_MODE_NONE)
    for _, allyHero in pairs(nAllyHeroes)
    do
        local nAllyInRangeEnemy = J.GetNearbyHeroes(allyHero, 1200, true, BOT_MODE_NONE)

        if J.IsValidHero(allyHero)
        and J.IsRetreating(allyHero)
        and allyHero:WasRecentlyDamagedByAnyHero(1.5)
        and not allyHero:IsIllusion()
        then
            if nAllyInRangeEnemy ~= nil and #nAllyInRangeEnemy >= 1
            and J.IsValidHero(nAllyInRangeEnemy[1])
            and J.CanCastOnNonMagicImmune(nAllyInRangeEnemy[1])
            and J.CanCastOnTargetAdvanced(nAllyInRangeEnemy[1])
            and J.IsInRange(bot, nAllyInRangeEnemy[1], nCastRange)
            and J.IsChasingTarget(nAllyInRangeEnemy[1], allyHero)
            and not J.IsDisabled(nAllyInRangeEnemy[1])
            and not J.IsTaunted(nAllyInRangeEnemy[1])
            and not J.IsSuspiciousIllusion(nAllyInRangeEnemy[1])
            and not nAllyInRangeEnemy[1]:HasModifier('modifier_legion_commander_duel')
            and not nAllyInRangeEnemy[1]:HasModifier('modifier_enigma_black_hole_pull')
            and not nAllyInRangeEnemy[1]:HasModifier('modifier_faceless_void_chronosphere_freeze')
            and not nAllyInRangeEnemy[1]:HasModifier('modifier_necrolyte_reapers_scythe')
            then
                return BOT_ACTION_DESIRE_HIGH, nAllyInRangeEnemy[1]
            end
        end
    end

    if J.IsGoingOnSomeone(bot)
    then
        if J.IsValidTarget(botTarget)
        and J.CanCastOnNonMagicImmune(botTarget)
        and J.CanCastOnTargetAdvanced(botTarget)
        and J.IsInRange(bot, botTarget, nCastRange)
        and not J.IsSuspiciousIllusion(botTarget)
        and not J.IsDisabled(botTarget)
        and not botTarget:HasModifier('modifier_cold_feet')
        and not botTarget:HasModifier('modifier_necrolyte_reapers_scythe')
        then
            local nInRangeAlly = J.GetNearbyHeroes(botTarget, 1000, true, BOT_MODE_NONE)
            local nInRangeEnemy = J.GetNearbyHeroes(botTarget, 1000, false, BOT_MODE_NONE)

            if nInRangeAlly ~= nil and nInRangeEnemy ~= nil
            and #nInRangeAlly >= #nInRangeEnemy
            then
                return BOT_ACTION_DESIRE_HIGH, botTarget
            end
        end
    end

    if J.IsRetreating(bot)
    then
        local nInRangeAlly = J.GetNearbyHeroes(bot,1200, false, BOT_MODE_NONE)
        local nInRangeEnemy = J.GetNearbyHeroes(bot,1200, true, BOT_MODE_NONE)

        if nInRangeAlly ~= nil and nInRangeEnemy ~= nil
        then
            for _, enemyHero in pairs(nInRangeEnemy)
            do
                if (#nInRangeAlly > #nInRangeEnemy
                    or bot:WasRecentlyDamagedByHero(enemyHero, 1.5))
                and J.CanCastOnNonMagicImmune(enemyHero)
                and J.CanCastOnTargetAdvanced(enemyHero)
                and J.IsInRange(bot, enemyHero, nCastRange)
                and not J.IsSuspiciousIllusion(enemyHero)
                and not J.IsDisabled(enemyHero)
                and not enemyHero:HasModifier('modifier_cold_feet')
                and not enemyHero:HasModifier('modifier_ice_vortex')
                then
                    return BOT_ACTION_DESIRE_HIGH, enemyHero
                end
            end
        end
    end

    if J.IsDoingRoshan(bot)
    then
        if J.IsRoshan(botTarget)
        and J.CanCastOnNonMagicImmune(botTarget)
        and J.IsInRange(bot, botTarget, nCastRange)
        and J.IsAttacking(bot)
        and not botTarget:HasModifier('modifier_cold_feet')
        and not botTarget:HasModifier('modifier_ice_vortex')
        then
            return BOT_ACTION_DESIRE_HIGH, botTarget
        end
    end

    if J.IsDoingTormentor(bot)
    then
        if J.IsTormentor(botTarget)
        and J.IsInRange(bot, botTarget, nCastRange)
        and J.IsAttacking(bot)
        and not botTarget:HasModifier('modifier_cold_feet')
        and not botTarget:HasModifier('modifier_ice_vortex')
        then
            return BOT_ACTION_DESIRE_HIGH, botTarget
        end
    end

    return BOT_ACTION_DESIRE_NONE, nil
end

function X.ConsiderIceVortex()
    if not IceVortex:IsFullyCastable()
    then
        return BOT_ACTION_DESIRE_NONE, 0
    end

    local nCastRange = J.GetProperCastRange(false, bot, IceVortex:GetCastRange())
    local nRadius = IceVortex:GetSpecialValueInt('radius')
    local nCastPoint = IceVortex:GetCastPoint()

    if J.IsInTeamFight(bot, 1200)
    then
        local nLocationAoE = bot:FindAoELocation(true, true, bot:GetLocation(), nCastRange, nRadius, 0, 0)
        local nInRangeEnemy = J.GetEnemiesNearLoc(nLocationAoE.targetloc, nRadius)

        if nInRangeEnemy ~= nil and #nInRangeEnemy >= 1
        then
            return BOT_ACTION_DESIRE_HIGH, nLocationAoE.targetloc
        end
    end

    if J.IsGoingOnSomeone(bot)
    then
        if J.IsValidTarget(botTarget)
        and J.CanCastOnNonMagicImmune(botTarget)
        and J.IsInRange(bot, botTarget, nCastRange)
        and not J.IsSuspiciousIllusion(botTarget)
        and not J.IsDisabled(botTarget)
        and not botTarget:HasModifier('modifier_ice_vortex')
        then
            local nInRangeAlly = J.GetNearbyHeroes(botTarget, 1000, true, BOT_MODE_NONE)
            local nInRangeEnemy = J.GetNearbyHeroes(botTarget, 1000, false, BOT_MODE_NONE)

            if nInRangeAlly ~= nil and nInRangeEnemy ~= nil
            and #nInRangeAlly >= #nInRangeEnemy
            then
                return BOT_ACTION_DESIRE_HIGH, botTarget:GetExtrapolatedLocation(nCastPoint)
            end
        end
    end

    if J.IsRetreating(bot)
    then
        local nInRangeAlly = J.GetNearbyHeroes(bot,1200, false, BOT_MODE_NONE)
        local nInRangeEnemy = J.GetNearbyHeroes(bot,1200, true, BOT_MODE_NONE)

        if nInRangeAlly ~= nil and nInRangeEnemy ~= nil
        then
            for _, enemyHero in pairs(nInRangeEnemy)
            do
                if (#nInRangeAlly > #nInRangeEnemy
                    or bot:WasRecentlyDamagedByHero(enemyHero, 1.5))
                and J.CanCastOnNonMagicImmune(enemyHero)
                and J.IsInRange(bot, enemyHero, nCastRange)
                and not J.IsSuspiciousIllusion(enemyHero)
                and not J.IsDisabled(enemyHero)
                and not enemyHero:HasModifier('modifier_cold_feet')
                and not enemyHero:HasModifier('modifier_ice_vortex')
                then
                    return BOT_ACTION_DESIRE_HIGH, enemyHero:GetExtrapolatedLocation(nCastPoint)
                end
            end
        end
    end

    if (J.IsDefending(bot) or J.IsPushing(bot))
    and not J.IsThereNonSelfCoreNearby(1000)
	then
		local nEnemyLanecreeps = bot:GetNearbyLaneCreeps(nCastRange, true)
		local nLocationAoE = bot:FindAoELocation(true, false, bot:GetLocation(), nCastRange, nRadius, nCastPoint, 0)

		if nEnemyLanecreeps ~= nil and #nEnemyLanecreeps >= 4
        and nLocationAoE.count >= 4
		then
			return BOT_ACTION_DESIRE_HIGH, nLocationAoE.targetloc
		end

        nLocationAoE = bot:FindAoELocation(true, true, bot:GetLocation(), nCastRange, nRadius, nCastPoint, 0)
        if nLocationAoE.count >= 2
        then
            return BOT_ACTION_DESIRE_HIGH, nLocationAoE.targetloc
        end
	end

    if J.IsDoingRoshan(bot)
    then
        if J.IsRoshan(botTarget)
        and J.CanCastOnNonMagicImmune(botTarget)
        and J.IsInRange(bot, botTarget, nCastRange)
        and J.IsAttacking(bot)
        then
            return BOT_ACTION_DESIRE_HIGH, botTarget:GetLocation()
        end
    end

    if J.IsDoingTormentor(bot)
    then
        if J.IsTormentor(botTarget)
        and J.IsInRange(bot, botTarget, nCastRange)
        and J.IsAttacking(bot)
        then
            return BOT_ACTION_DESIRE_HIGH, botTarget:GetLocation()
        end
    end

    return BOT_ACTION_DESIRE_NONE, 0
end

function X.ConsiderChillingTouch()
    if not ChillingTouch:IsFullyCastable()
    then
        return BOT_ACTION_DESIRE_NONE, nil
    end

    local nCastRange = J.GetProperCastRange(false, bot, ChillingTouch:GetCastRange()) + ChillingTouch:GetSpecialValueInt('attack_range_bonus')
    local nDamage = ChillingTouch:GetSpecialValueInt('damage')

    local nEnemyHeroes = J.GetNearbyHeroes(bot,nCastRange + 150, true, BOT_MODE_NONE)
    for _, enemyHero in pairs(nEnemyHeroes)
    do
        if J.IsValidHero(enemyHero)
        and J.CanCastOnNonMagicImmune(enemyHero)
        and J.CanCastOnTargetAdvanced(enemyHero)
        and J.CanKillTarget(enemyHero, nDamage, DAMAGE_TYPE_MAGICAL)
        and not J.IsSuspiciousIllusion(enemyHero)
        and not enemyHero:HasModifier('modifier_abaddon_borrowed_time')
        and not enemyHero:HasModifier('modifier_dazzle_shallow_grave')
        and not enemyHero:HasModifier('modifier_oracle_false_promise_timer')
        and not enemyHero:HasModifier('modifier_templar_assassin_refraction_absorb')
        then
            return BOT_ACTION_DESIRE_HIGH, enemyHero
        end
    end

    local nAllyHeroes = J.GetNearbyHeroes(bot,nCastRange + 150, false, BOT_MODE_NONE)
    for _, allyHero in pairs(nAllyHeroes)
    do
        local nAllyInRangeEnemy = J.GetNearbyHeroes(allyHero, 1200, true, BOT_MODE_NONE)

        if J.IsValidHero(allyHero)
        and J.IsRetreating(allyHero)
        and allyHero:WasRecentlyDamagedByAnyHero(1.5)
        and not allyHero:IsIllusion()
        then
            if nAllyInRangeEnemy ~= nil and #nAllyInRangeEnemy >= 1
            and J.IsValidHero(nAllyInRangeEnemy[1])
            and J.CanCastOnNonMagicImmune(nAllyInRangeEnemy[1])
            and J.CanCastOnTargetAdvanced(nAllyInRangeEnemy[1])
            and J.IsInRange(bot, nAllyInRangeEnemy[1], nCastRange)
            and J.IsChasingTarget(nAllyInRangeEnemy[1], allyHero)
            and not J.IsDisabled(nAllyInRangeEnemy[1])
            and not J.IsTaunted(nAllyInRangeEnemy[1])
            and not J.IsSuspiciousIllusion(nAllyInRangeEnemy[1])
            and not nAllyInRangeEnemy[1]:HasModifier('modifier_legion_commander_duel')
            and not nAllyInRangeEnemy[1]:HasModifier('modifier_enigma_black_hole_pull')
            and not nAllyInRangeEnemy[1]:HasModifier('modifier_faceless_void_chronosphere_freeze')
            and not nAllyInRangeEnemy[1]:HasModifier('modifier_necrolyte_reapers_scythe')
            then
                return BOT_ACTION_DESIRE_HIGH, nAllyInRangeEnemy[1]
            end
        end
    end

    if J.IsGoingOnSomeone(bot)
    then
        if J.IsValidTarget(botTarget)
        and J.CanCastOnNonMagicImmune(botTarget)
        and J.CanCastOnTargetAdvanced(botTarget)
        and J.IsInRange(bot, botTarget, nCastRange)
        and not J.IsSuspiciousIllusion(botTarget)
        and not J.IsDisabled(botTarget)
        and not botTarget:HasModifier('modifier_abaddon_borrowed_time')
        and not botTarget:HasModifier('modifier_dazzle_shallow_grave')
        and not botTarget:HasModifier('modifier_necrolyte_reapers_scythe')
        and not botTarget:HasModifier('modifier_oracle_false_promise_timer')
        and not botTarget:HasModifier('modifier_templar_assassin_refraction_absorb')
        then
            local nInRangeAlly = J.GetNearbyHeroes(botTarget, 1200, true, BOT_MODE_NONE)
            local nInRangeEnemy = J.GetNearbyHeroes(botTarget, 1200, false, BOT_MODE_NONE)

            if nInRangeAlly ~= nil and nInRangeEnemy ~= nil
            and #nInRangeAlly >= #nInRangeEnemy
            then
                return BOT_ACTION_DESIRE_HIGH, botTarget
            end
        end
    end

    if J.IsRetreating(bot)
    then
        local nInRangeAlly = J.GetNearbyHeroes(bot,1200, false, BOT_MODE_NONE)
        local nInRangeEnemy = J.GetNearbyHeroes(bot,1200, true, BOT_MODE_NONE)

        if nInRangeAlly ~= nil and nInRangeEnemy ~= nil
        then
            for _, enemyHero in pairs(nInRangeEnemy)
            do
                if (#nInRangeAlly > #nInRangeEnemy
                    or bot:WasRecentlyDamagedByHero(enemyHero, 1.2))
                and J.CanCastOnNonMagicImmune(enemyHero)
                and J.CanCastOnTargetAdvanced(enemyHero)
                and J.IsInRange(bot, enemyHero, nCastRange)
                and not J.IsSuspiciousIllusion(enemyHero)
                and not J.IsDisabled(enemyHero)
                then
                    return BOT_ACTION_DESIRE_HIGH, enemyHero
                end
            end
        end
    end

    if J.IsDoingRoshan(bot)
    then
        if J.IsRoshan(botTarget)
        and J.CanCastOnNonMagicImmune(botTarget)
        and J.IsInRange(bot, botTarget, nCastRange)
        and J.IsAttacking(bot)
        then
            return BOT_ACTION_DESIRE_HIGH, botTarget
        end
    end

    if J.IsDoingTormentor(bot)
    then
        if J.IsTormentor(botTarget)
        and J.IsInRange(bot, botTarget, nCastRange)
        and J.IsAttacking(bot)
        then
            return BOT_ACTION_DESIRE_HIGH, botTarget
        end
    end

    return BOT_ACTION_DESIRE_NONE, nil
end

function X.ConsiderIceBlast()
    if not IceBlast:IsFullyCastable()
    then
        return BOT_ACTION_DESIRE_NONE, 0
    end

    -- Global: a fight anywhere on the map, Rubick's own included. Aim at the enemy whose surroundings
    -- the blast covers best; Frostbite stops their healing for the rest of the fight.
    local nTeamFightLocation = J.GetTeamFightLocation(bot)
    if nTeamFightLocation ~= nil
    then
        local vBest, nBestCount = X.GetBestIceBlastLocation(J.GetEnemiesNearLoc(nTeamFightLocation, 1400))
        if vBest ~= nil and nBestCount >= 1
        then
            return BOT_ACTION_DESIRE_HIGH, vBest
        end
    end

    -- Snipe: a visible enemy the initial hit drops below the shatter threshold.
    local nDamage = IceBlast:GetAbilityDamage()
    local nKillPct = IceBlast:GetSpecialValueInt('kill_pct') / 100
    local nDamagePerSecond = IceBlast:GetSpecialValueInt('damage_per_second')
    for _, enemyHero in pairs(GetUnitList(UNIT_LIST_ENEMY_HEROES))
    do
        if J.IsValidHero(enemyHero)
        and J.CanCastOnMagicImmune(enemyHero)
        and GetUnitToUnitDistance(bot, enemyHero) <= 4000
        and not J.IsSuspiciousIllusion(enemyHero)
        and not enemyHero:HasModifier('modifier_ice_blast')
        and not enemyHero:HasModifier('modifier_abaddon_borrowed_time')
        and not enemyHero:HasModifier('modifier_dazzle_shallow_grave')
        and not enemyHero:HasModifier('modifier_oracle_false_promise_timer')
        then
            local nHealthAfter = enemyHero:GetHealth()
                - enemyHero:GetActualIncomingDamage(nDamage + nDamagePerSecond, DAMAGE_TYPE_MAGICAL)
            if nHealthAfter <= enemyHero:GetMaxHealth() * nKillPct
            then
                local nTravel = GetUnitToUnitDistance(bot, enemyHero) / X.GetIceBlastSpeed()
                return BOT_ACTION_DESIRE_HIGH, enemyHero:GetExtrapolatedLocation(nTravel)
            end
        end
    end

    return BOT_ACTION_DESIRE_NONE, 0
end

function X.GetIceBlastSpeed()
    local nSpeed = IceBlast:GetSpecialValueInt('speed')
    return nSpeed > 0 and nSpeed or 1500
end

-- The tracer starts at the caster and the blast radius grows with its travel time:
-- radius_min + radius_grow * seconds travelled, capped at radius_max.
function X.GetIceBlastRadius(vLocation)
    local nTravel = GetUnitToLocationDistance(bot, vLocation) / X.GetIceBlastSpeed()
    return math.min(IceBlast:GetSpecialValueInt('radius_min') + IceBlast:GetSpecialValueFloat('radius_grow') * nTravel,
                    IceBlast:GetSpecialValueInt('radius_max'))
end

function X.GetBestIceBlastLocation(tEnemies)
    local vBest, nBestCount = nil, 0
    for _, enemyHero in pairs(tEnemies)
    do
        if J.IsValidHero(enemyHero)
        and J.CanCastOnMagicImmune(enemyHero)
        and not enemyHero:HasModifier('modifier_ice_blast')
        then
            local vLocation = enemyHero:GetLocation()
            local nCount = #J.GetEnemiesNearLoc(vLocation, X.GetIceBlastRadius(vLocation))
            if nCount > nBestCount
            then
                vBest, nBestCount = vLocation, nCount
            end
        end
    end

    return vBest, nBestCount
end

-- Ability thinks are throttled (~0.12-0.2s), so the tracer moves 180-300 units between checks; waiting
-- for it to be within a few units of the target can step right over that window. Release once the
-- tracer is within half a think step of the target, or as soon as possible after it has passed it.
local ICE_BLAST_RELEASE_LEAD = 150

function X.ConsiderIceBlastRelease()
    if IceBlastRelease:IsHidden()
    or not IceBlastRelease:IsFullyCastable()
    or IceBlastCast == nil
    or IceBlast == nil
    then
        return BOT_ACTION_DESIRE_NONE
    end

    local nTargetDistance = J.GetLocationToLocationDistance(IceBlastCast.origin, IceBlastCast.target)
    -- Without a visible tracer, estimate its progress from the flight time.
    local nTravelled = (DotaTime() - IceBlastCast.time) * X.GetIceBlastSpeed()
    for _, p in pairs(GetLinearProjectiles())
    do
        if p ~= nil and p.ability ~= nil and p.location ~= nil
        and (p.caster == nil or p.caster == bot)
        and p.ability:GetName() == 'ancient_apparition_ice_blast'
        then
            nTravelled = J.GetLocationToLocationDistance(IceBlastCast.origin, p.location)
            break
        end
    end

    if nTravelled >= nTargetDistance - ICE_BLAST_RELEASE_LEAD
    then
        return BOT_ACTION_DESIRE_HIGH
    end

    return BOT_ACTION_DESIRE_NONE
end

return X