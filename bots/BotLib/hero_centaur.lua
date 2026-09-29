local X             = {}
local bot           = GetBot()

local J             = require( GetScriptDirectory()..'/FunLib/jmz_func' )
local Minion        = dofile( GetScriptDirectory()..'/FunLib/aba_minion' )
local sTalentList   = J.Skill.GetTalentList( bot )
local sAbilityList  = J.Skill.GetAbilityList( bot )
local sRole   = J.Item.GetRoleItemsBuyList( bot )

-- Updated to 7.41f from D2PT, position 3 only; forced other roles use this fallback.
local BuildData = require(GetScriptDirectory()..'/BotLib/Builds/centaur')
X.buildMetadata = BuildData
X.neutralPreferences = BuildData.neutrals[sRole]
-- Learnable abilities: [1] Hoof Stomp, [2] Double Edge, [3] Retaliate, [6] Stampede.
-- D2PT shows only the first ten levels; later levels are a legal continuation.
local nAbilityBuildList = {1,2,3,3,3,6,3,1,1,1,6,2,2,2,6}
local nTalentBuildList = J.Skill.GetTalentBuild({
    t10={10,0}, -- +15 movement speed
    t15={0,10}, -- +10 Strength
    t20={10,0}, -- -25s Stampede cooldown
    t25={10,0}, -- +1s Hoof Stomp duration
})
local defaultAbilityBuild, defaultTalentBuild = nAbilityBuildList, nTalentBuildList
-- D2PT buys no boots: Horsepower converts Strength into movement speed.
X.sBuyList = {
    'item_tango', 'item_ring_of_protection', 'item_double_gauntlets', 'item_branches',
    'item_helm_of_the_dominator', 'item_magic_wand',
    'item_heart', 'item_blink', 'item_aghanims_shard', 'item_lotus_orb',
    'item_shivas_guard', 'item_black_king_bar',
    -- Late upgrades/slot policy beyond the displayed core progression.
    'item_ultimate_scepter_2', 'item_overwhelming_blink', 'item_moon_shard',
}
X.sSellList = {
    'item_lotus_orb', 'item_magic_wand',
}

if J.Role.IsPvNMode() or J.Role.IsAllShadow() then X['sBuyList'], X['sSellList'] = { 'PvN_antimage' }, {} end

nAbilityBuildList, nTalentBuildList, X['sBuyList'], X['sSellList'] = J.SetUserHeroInit( nAbilityBuildList, nTalentBuildList, X['sBuyList'], X['sSellList'] )

X['sSkillList'] = J.Skill.GetSkillList( sAbilityList, nAbilityBuildList, sTalentList, nTalentBuildList )
-- Hoof Stomp takes level 10, so the first talent comes at 11. Respect custom builds.
if nAbilityBuildList == defaultAbilityBuild and nTalentBuildList == defaultTalentBuild then
    X.sSkillList[10], X.sSkillList[11] = X.sSkillList[11], X.sSkillList[10]
end

X['bDeafaultAbility'] = false
X['bDeafaultItem'] = false

function X.MinionThink(hMinionUnit)
	Minion.MinionThink(hMinionUnit)
end

local HoofStomp     = bot:GetAbilityByName('centaur_hoof_stomp')
local DoubleEdge    = bot:GetAbilityByName('centaur_double_edge')
-- local Retaliate     = bot:GetAbilityByName('centaur_return')
local WorkHorse     = bot:GetAbilityByName('centaur_work_horse')
local HitchARide    = bot:GetAbilityByName('centaur_mount')
local Stampede      = bot:GetAbilityByName('centaur_stampede')

local HoofStompDesire
local DoubleEdgeDesire, DoubleEdgeTarget
local WorkHorseDesire
local HitchARideDesire, HitchARideTarget
local StampedeDesire

function X.SkillsComplement()
	if J.CanNotUseAbility(bot) then return end

    HitchARideDesire, HitchARideTarget = X.ConsiderHitchARide()
    if HitchARideDesire > 0
    then
        bot:Action_UseAbilityOnEntity(HitchARide, HitchARideTarget)
        return
    end

    WorkHorseDesire, HitchARideTarget = X.ConsiderWorkHorse()
    if WorkHorseDesire > 0
    then
        bot:Action_UseAbility(WorkHorse)
        return
    end

    StampedeDesire = X.ConsiderStampede()
    if StampedeDesire > 0
    then
        bot:Action_UseAbility(Stampede)
        return
    end

    HoofStompDesire = X.ConsiderHoofStomp()
    if HoofStompDesire > 0
    then
        bot:Action_UseAbility(HoofStomp)
        return
    end

    DoubleEdgeDesire, DoubleEdgeTarget = X.ConsiderDoubleEdge()
    if DoubleEdgeDesire > 0
    then
        bot:Action_UseAbilityOnEntity(DoubleEdge, DoubleEdgeTarget)
        return
    end
end

function X.ConsiderHoofStomp()
    if not HoofStomp:IsFullyCastable()
    then
        return BOT_ACTION_DESIRE_NONE
    end

	local nRadius = HoofStomp:GetSpecialValueInt('radius')
	local nDamage = HoofStomp:GetSpecialValueInt('stomp_damage')
    local botTarget = J.GetProperTarget(bot)

    local nEnemyHeroes = J.GetNearbyHeroes(bot,nRadius, true, BOT_MODE_NONE)
    for _, enemyHero in pairs(nEnemyHeroes)
    do
        if J.IsValidHero(enemyHero)
        and J.CanCastOnNonMagicImmune(enemyHero)
        and not J.IsSuspiciousIllusion(enemyHero)
        then
            if enemyHero:IsChanneling() or J.IsCastingUltimateAbility(enemyHero)
            then
                return BOT_ACTION_DESIRE_HIGH
            end

            if J.CanKillTarget(enemyHero, nDamage, DAMAGE_TYPE_MAGICAL)
            and not enemyHero:HasModifier('modifier_abaddon_borrowed_time')
            and not enemyHero:HasModifier('modifier_dazzle_shallow_grave')
            and not enemyHero:HasModifier('modifier_necrolyte_reapers_scythe')
            and not enemyHero:HasModifier('modifier_oracle_false_promise_timer')
            and not enemyHero:HasModifier('modifier_templar_assassin_refraction_absorb')
            then
                return BOT_ACTION_DESIRE_HIGH
            end
        end
    end

    if J.IsGoingOnSomeone(bot)
	then
		if J.IsValidTarget(botTarget)
        and J.CanCastOnNonMagicImmune(botTarget)
        and J.IsInRange(bot, botTarget, nRadius - 100)
        and not J.IsSuspiciousIllusion(botTarget)
        and not J.IsDisabled(botTarget)
        and not botTarget:HasModifier('modifier_necrolyte_reapers_scythe')
		then
            local nInRangeAlly = J.GetNearbyHeroes(botTarget, 1200, true, BOT_MODE_NONE)
            local nInRangeEnemy = J.GetNearbyHeroes(botTarget, 1200, false, BOT_MODE_NONE)

            if nInRangeAlly ~= nil and nInRangeEnemy ~= nil
            and #nInRangeAlly >= #nInRangeEnemy
            then
                if Stampede:IsTrained()
                and Stampede:IsFullyCastable()
                then
                    if bot:GetMana() - HoofStomp:GetManaCost() > Stampede:GetManaCost()
                    then
                        return BOT_ACTION_DESIRE_HIGH
                    end
                else
                    return BOT_ACTION_DESIRE_HIGH
                end
            end
		end
	end

    if J.IsRetreating(bot)
	then
        local nInRangeAlly = J.GetNearbyHeroes(bot,1200, false, BOT_MODE_NONE)
        local nInRangeEnemy = J.GetNearbyHeroes(bot,1200, true, BOT_MODE_NONE)

        if nInRangeAlly ~= nil and nInRangeEnemy ~= nil
        and J.IsValidHero(nInRangeEnemy[1])
        and J.CanCastOnNonMagicImmune(nInRangeEnemy[1])
        and J.IsInRange(bot, nInRangeEnemy[1], nRadius)
        and J.IsChasingTarget(nInRangeEnemy[1], bot)
        and not J.IsSuspiciousIllusion(nInRangeEnemy[1])
        and not J.IsDisabled(nInRangeEnemy[1])
        and not nInRangeEnemy[1]:HasModifier('modifier_necrolyte_reapers_scythe')
        then
            local nTargetInRangeAlly = J.GetNearbyHeroes(nInRangeEnemy[1], 1200, false, BOT_MODE_NONE)

            if nTargetInRangeAlly ~= nil
            and ((#nTargetInRangeAlly > #nInRangeAlly)
                or (bot:WasRecentlyDamagedByAnyHero(1.5)))
            then
		        return BOT_ACTION_DESIRE_HIGH
            end
        end
    end

    if J.IsDoingRoshan(bot)
	then
		if J.IsRoshan(botTarget)
        and J.CanCastOnNonMagicImmune(botTarget)
        and J.IsInRange(bot, botTarget, nRadius)
        and J.IsAttacking(bot)
        and not J.IsDisabled(botTarget)
		then
			return BOT_ACTION_DESIRE_HIGH
		end
	end

    if J.IsDoingTormentor(bot)
    then
        if J.IsTormentor(botTarget)
        and J.IsInRange(bot, botTarget, nRadius)
        and J.IsAttacking(bot)
        then
            return BOT_ACTION_DESIRE_HIGH
        end
    end

    return BOT_ACTION_DESIRE_NONE
end

function X.ConsiderDoubleEdge()
	if not DoubleEdge:IsFullyCastable()
    then
		return BOT_ACTION_DESIRE_NONE, 0
	end

    local nStrength = bot:GetAttributeValue(ATTRIBUTE_STRENGTH)
	local nCastRange = DoubleEdge:GetCastRange()
    local nAttackRange = bot:GetAttackRange()
    local nStrengthDamageMul = DoubleEdge:GetSpecialValueInt("strength_damage") / 100
	local nDamage = DoubleEdge:GetSpecialValueInt("edge_damage") + (nStrength * nStrengthDamageMul)
	local botTarget = J.GetProperTarget(bot)

    local nEnemyHeroes = J.GetNearbyHeroes(bot,nCastRange + nAttackRange, true, BOT_MODE_NONE)
    for _, enemyHero in pairs(nEnemyHeroes)
    do
        if J.IsValidHero(enemyHero)
        and J.CanCastOnNonMagicImmune(enemyHero)
        and J.CanKillTarget(enemyHero, nDamage, DAMAGE_TYPE_MAGICAL)
        and not J.IsSuspiciousIllusion(enemyHero)
        and not enemyHero:HasModifier('modifier_abaddon_borrowed_time')
        and not enemyHero:HasModifier('modifier_dazzle_shallow_grave')
        and not enemyHero:HasModifier('modifier_necrolyte_reapers_scythe')
        and not enemyHero:HasModifier('modifier_oracle_false_promise_timer')
        and not enemyHero:HasModifier('modifier_templar_assassin_refraction_absorb')
        and bot:GetHealth() > nDamage * 1.2
        then
            return BOT_ACTION_DESIRE_HIGH, enemyHero
        end
    end

    if J.IsGoingOnSomeone(bot)
	then
		if J.IsValidTarget(botTarget)
        and J.CanCastOnNonMagicImmune(botTarget)
        and J.IsInRange(bot, botTarget, nCastRange * 2)
        and not J.IsSuspiciousIllusion(botTarget)
        and not botTarget:HasModifier('modifier_abaddon_borrowed_time')
        and not botTarget:HasModifier('modifier_dazzle_shallow_grave')
        and not botTarget:HasModifier('modifier_necrolyte_reapers_scythe')
        and not botTarget:HasModifier('modifier_oracle_false_promise_timer')
        and not botTarget:HasModifier('modifier_templar_assassin_refraction_absorb')
        and bot:GetHealth() > nDamage * 1.5
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

    if (J.IsPushing(bot) or J.IsDefending(bot))
    then
        local nEnemyLaneCreeps = bot:GetNearbyLaneCreeps(nCastRange * 2, true)

        if nEnemyLaneCreeps ~= nil and #nEnemyLaneCreeps >= 3
        and J.CanBeAttacked(nEnemyLaneCreeps[1])
        and J.IsAttacking(bot)
        and bot:GetHealth() > nDamage * 1.5
        and (bot:GetHealth() - nDamage) / bot:GetMaxHealth() > 0.5
        and J.GetHP(nEnemyLaneCreeps[1]) > 0.33
        then
            return BOT_ACTION_DESIRE_HIGH, nEnemyLaneCreeps[1]
        end
    end

    if J.IsFarming(bot)
    then
        if J.IsAttacking(bot)
        and J.GetHP(bot) > 0.3
        and bot:GetHealth() > nDamage * 1.5
        and (bot:GetHealth() - nDamage) / bot:GetMaxHealth() > 0.3
        then
            local nNeutralCreeps = bot:GetNearbyNeutralCreeps(nCastRange * 2)
            if nNeutralCreeps ~= nil and #nNeutralCreeps >= 1
            and J.GetHP(nNeutralCreeps[1]) > 0.33
            then
                return BOT_ACTION_DESIRE_HIGH, nNeutralCreeps[1]
            end

            local nEnemyLaneCreeps = bot:GetNearbyLaneCreeps(nCastRange * 2, true)
            if nEnemyLaneCreeps ~= nil and #nEnemyLaneCreeps >= 3
            and J.CanBeAttacked(nEnemyLaneCreeps[1])
            and J.GetHP(nEnemyLaneCreeps[1]) > 0.33
            then
                return BOT_ACTION_DESIRE_HIGH, nEnemyLaneCreeps[1]
            end
        end
    end

    if J.IsLaning(bot)
	then
        local canKill = 0
        local creepList = {}
		local nEnemyLaneCreeps = bot:GetNearbyLaneCreeps(nCastRange * 2, true)

		for _, creep in pairs(nEnemyLaneCreeps)
		do
			-- if J.IsValid(creep)
			-- and (J.IsKeyWordUnit('ranged', creep) or J.IsKeyWordUnit('siege', creep) or J.IsKeyWordUnit('flagbearer', creep))
			-- and creep:GetHealth() <= nDamage
			-- then
			-- 	local nCreepInRangeHero = creep:GetNearbyHeroes(500, false, BOT_MODE_NONE)

			-- 	if nCreepInRangeHero ~= nil and #nCreepInRangeHero >= 1
            --     and J.CanBeAttacked(creep)
            --     and J.GetHP(bot) > 0.3
            --     and bot:GetHealth() > nDamage * 1.5
            --     and (bot:GetHealth() - nDamage) / bot:GetMaxHealth() > 0.3
			-- 	then
			-- 		return BOT_ACTION_DESIRE_HIGH, creep
			-- 	end
			-- end

            if J.IsValid(creep)
            and creep:GetHealth() <= nDamage
            then
                canKill = canKill + 1
                table.insert(creepList, creep)
            end
		end

        if canKill >= 2
        and J.CanBeAttacked(creepList[1])
        and J.GetHP(bot) > 0.3
        and bot:GetHealth() > nDamage * 1.5
        and (bot:GetHealth() - nDamage) / bot:GetMaxHealth() > 0.3
        then
            return BOT_ACTION_DESIRE_HIGH, creepList[1]
        end

        local nInRangeEnemy = J.GetEnemiesNearLoc(bot:GetLocation(), nCastRange + 75)
        if nInRangeEnemy ~= nil and #nInRangeEnemy >= 1
        and J.IsValidTarget(nInRangeEnemy[1])
        and (bot:GetHealth() - nDamage) / bot:GetMaxHealth() > 0.65
        then
            return BOT_ACTION_DESIRE_HIGH, nInRangeEnemy[1]
        end
	end

    if J.IsDoingRoshan(bot)
	then
		if J.IsRoshan(botTarget)
        and J.CanCastOnNonMagicImmune(botTarget)
        and J.IsInRange(bot, botTarget, nCastRange * 2)
        and J.IsAttacking(bot)
        and bot:GetHealth() > nDamage * 1.5
		then
			return BOT_ACTION_DESIRE_HIGH
		end
	end

    if J.IsDoingTormentor(bot)
    then
        if J.IsTormentor(botTarget)
        and J.IsInRange(bot, botTarget, nCastRange * 2)
        and J.IsAttacking(bot)
        and bot:GetHealth() > nDamage * 1.5
        and (bot:GetHealth() - nDamage) / bot:GetMaxHealth() > 0.45
        then
            return BOT_ACTION_DESIRE_HIGH
        end
    end

	return BOT_ACTION_DESIRE_NONE, 0
end

function X.ConsiderStampede()
	if not Stampede:IsFullyCastable()
    or bot:HasModifier('modifier_centaur_cart')
    or bot:HasModifier('modifier_centaur_stampede')
    then
		return BOT_ACTION_DESIRE_NONE
	end

    if J.IsInTeamFight(bot, 1200)
	then
        local nTeamFightLocation = J.GetTeamFightLocation(bot)
        local nInRangeEnemy = J.GetEnemiesNearLoc(bot:GetLocation(), 1200)

        if nInRangeEnemy ~= nil and #nInRangeEnemy >= 2
        and nTeamFightLocation ~= nil
        then
            if J.GetLocationToLocationDistance(bot:GetLocation(), nTeamFightLocation) < 600
            then
                return BOT_ACTION_DESIRE_HIGH
            end
        end
	end

    if J.IsRetreating(bot)
	then
        local nInRangeAlly = J.GetNearbyHeroes(bot,1200, false, BOT_MODE_NONE)
        local nInRangeEnemy = J.GetNearbyHeroes(bot,1200, true, BOT_MODE_NONE)

        if nInRangeAlly ~= nil and nInRangeEnemy ~= nil
        and J.IsValidHero(nInRangeEnemy[1])
        and J.IsInRange(bot, nInRangeEnemy[1], 600)
        and J.IsChasingTarget(nInRangeEnemy[1], bot)
        and not J.IsSuspiciousIllusion(nInRangeEnemy[1])
        and not J.IsDisabled(nInRangeEnemy[1])
        then
            local nTargetInRangeAlly = J.GetNearbyHeroes(nInRangeEnemy[1], 1200, false, BOT_MODE_NONE)

            if nTargetInRangeAlly ~= nil
            and #nTargetInRangeAlly > #nInRangeAlly
            and #nTargetInRangeAlly >= 2
            and #nInRangeAlly <= 1
            and J.GetHP(bot) < 0.5
            then
		        return BOT_ACTION_DESIRE_HIGH
            end
        end
    end

	return BOT_ACTION_DESIRE_NONE
end

function X.ConsiderWorkHorse()
    if not WorkHorse:IsTrained()
    or not WorkHorse:IsFullyCastable()
    or bot:HasModifier('modifier_centaur_stampede')
    then
        return BOT_ACTION_DESIRE_NONE, nil
    end

    if J.IsInTeamFight(bot, 1200)
	then
        local nTeamFightLocation = J.GetTeamFightLocation(bot)
        local nInRangeEnemy = J.GetEnemiesNearLoc(bot:GetLocation(), 1200)

        if nInRangeEnemy ~= nil and #nInRangeEnemy >= 2
        and nTeamFightLocation ~= nil
        then
            if J.GetLocationToLocationDistance(bot:GetLocation(), nTeamFightLocation) < 600
            then
                return BOT_ACTION_DESIRE_HIGH
            end
        end
	end

    if J.IsRetreating(bot)
	then
        local nInRangeAlly = J.GetNearbyHeroes(bot,1200, false, BOT_MODE_NONE)
        local nInRangeEnemy = J.GetNearbyHeroes(bot,1200, true, BOT_MODE_NONE)

        if nInRangeAlly ~= nil and nInRangeEnemy ~= nil
        and J.IsValidHero(nInRangeEnemy[1])
        and J.IsInRange(bot, nInRangeEnemy[1], 600)
        and J.IsChasingTarget(nInRangeEnemy[1], bot)
        and not J.IsSuspiciousIllusion(nInRangeEnemy[1])
        and not J.IsDisabled(nInRangeEnemy[1])
        then
            local nTargetInRangeAlly = J.GetNearbyHeroes(nInRangeEnemy[1], 1200, false, BOT_MODE_NONE)

            if nTargetInRangeAlly ~= nil
            and #nTargetInRangeAlly > #nInRangeAlly
            and #nTargetInRangeAlly >= 2
            and #nInRangeAlly <= 1
            and J.GetHP(bot) < 0.5
            then
		        return BOT_ACTION_DESIRE_HIGH
            end
        end
    end

    return BOT_ACTION_DESIRE_NONE, nil
end

function X.ConsiderHitchARide()
    if HitchARide:IsHidden()
    or not HitchARide:IsFullyCastable()
    then
        return BOT_ACTION_DESIRE_NONE, nil
    end

    local nCastRange = HitchARide:GetCastRange()

    if J.IsGoingOnSomeone(bot)
    or J.IsInTeamFight(bot, 1200)
    then
        local nInRangeAlly = J.GetAlliesNearLoc(bot:GetLocation(), nCastRange)
        for _, allyHero in pairs(nInRangeAlly)
        do
            if J.IsValidHero(allyHero)
            and allyHero:WasRecentlyDamagedByAnyHero(1.1)
            and J.GetHP(allyHero) < 0.5
            and not allyHero:IsIllusion()
            and not allyHero:HasModifier('modifier_arc_warden_tempest_double')
            then
                return BOT_ACTION_DESIRE_HIGH, allyHero
            end
        end
    end

    if J.IsRetreating(bot)
    then
        local nInRangeAlly = J.GetAlliesNearLoc(bot:GetLocation(), nCastRange)
        for _, allyHero in pairs(nInRangeAlly)
        do
            if J.IsValidHero(allyHero)
            and J.IsRetreating(allyHero)
            and allyHero:WasRecentlyDamagedByAnyHero(1.1)
            and not allyHero:IsIllusion()
            and not allyHero:HasModifier('modifier_arc_warden_tempest_double')
            then
                return BOT_ACTION_DESIRE_HIGH, allyHero
            end
        end
    end

    return BOT_ACTION_DESIRE_NONE, nil
end

return X