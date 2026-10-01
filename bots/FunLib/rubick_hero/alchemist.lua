local bot
local X = {}
local J = require(GetScriptDirectory()..'/FunLib/jmz_func')

local botTarget

local AcidSpray
local UnstableConcoction
local UnstableConcoctionThrow
local ChemicalRage
local BerserkPotion
local ChemicalRageDesire, UnstableConcoctionDesire
local UnstableConcoctionThrowDesire, UnstableConcoctionThrowTarget
local AcidSprayDesire, AcidSprayLocation
local BerserkPotionDesire, BerserkPotionTarget

local ConcoctionThrowTime = nil

local function WantsBasicDispel(unit)
    -- These effects can be removed by a basic dispel; stuns/hexes need a strong dispel.
    return (unit:IsSilenced() and not unit:HasModifier('modifier_item_mask_of_madness_berserk')
        and not unit:HasModifier('modifier_doom_bringer_doom')
        and not unit:HasModifier('modifier_riki_smoke_screen')
        and not unit:HasModifier('modifier_disruptor_static_storm'))
        or unit:HasModifier('modifier_item_spirit_vessel_damage')
        or unit:HasModifier('modifier_item_urn_damage')
        or unit:HasModifier('modifier_crystal_maiden_frostbite')
        or unit:HasModifier('modifier_dark_troll_warlord_ensnare')
        or unit:HasModifier('modifier_rod_of_atos_debuff')
        or unit:HasModifier('modifier_meepo_earthbind')
        or unit:HasModifier('modifier_medusa_gorgon_grasp_root')
        or unit:HasModifier('modifier_dazzle_poison_touch')
        or unit:HasModifier('modifier_phoenix_fire_spirit_burn')
end

local function AbilityCastRange(ability)
    local range = ability:GetCastRange()
    if J.IsItemAvailable('item_aether_lens') ~= nil then range = range + 225 end
    local supremacy = bot:GetAbilityByName('rubick_arcane_supremacy')
    if supremacy ~= nil and supremacy:IsTrained() and not J.HasBreakModifier(bot) then
        range = range + supremacy:GetSpecialValueInt('cast_range')
    end
    return range
end

function X.ConsiderStolenSpell(ability)
    bot = GetBot()
    local abilityName = ability:GetName()
    if abilityName ~= 'alchemist_chemical_rage'
    and abilityName ~= 'alchemist_unstable_concoction_throw'
    and abilityName ~= 'alchemist_unstable_concoction'
    and abilityName ~= 'alchemist_acid_spray'
    and abilityName ~= 'alchemist_berserk_potion' then return nil end

    if J.CanNotUseAbility(bot) then return false end

    botTarget = J.GetProperTarget(bot)

    if abilityName == 'alchemist_chemical_rage'
    then
        ChemicalRage = ability
        ChemicalRageDesire = X.ConsiderChemicalRage()
        if ChemicalRageDesire > 0
        then
            bot:Action_UseAbility(ChemicalRage)
            return true
        end
    end

    if abilityName == 'alchemist_unstable_concoction_throw'
    then
        UnstableConcoctionThrow = ability
        UnstableConcoctionThrowDesire, UnstableConcoctionThrowTarget = X.ConsiderUnstableConcoctionThrow()
        if UnstableConcoctionThrowDesire > 0
        then
            bot:Action_UseAbilityOnEntity(UnstableConcoctionThrow, UnstableConcoctionThrowTarget)
            return true
        end
    end

    if abilityName == 'alchemist_unstable_concoction'
    then
        UnstableConcoction = ability
        UnstableConcoctionDesire = X.ConsiderUnstableConcoction()
        if UnstableConcoctionDesire > 0
        then
            bot:Action_UseAbility(UnstableConcoction)
            ConcoctionThrowTime = DotaTime()
            return true
        end
    end

    if abilityName == 'alchemist_acid_spray'
    then
        AcidSpray = ability
        AcidSprayDesire, AcidSprayLocation = X.ConsiderAcidSpray()
        if AcidSprayDesire > 0
        then
            J.SetQueuePtToINT(bot, false)
            bot:Action_UseAbilityOnLocation(AcidSpray, AcidSprayLocation)
            return true
        end
    end

    if abilityName == 'alchemist_berserk_potion'
    then
        BerserkPotion = ability
        BerserkPotionDesire, BerserkPotionTarget = X.ConsiderBerserkPotion()
        if BerserkPotionDesire > 0
        then
            bot:Action_UseAbilityOnEntity(BerserkPotion, BerserkPotionTarget)
            return true
        end
    end
    return false
end

function X.ConsiderAcidSpray()
	if not AcidSpray:IsFullyCastable()
	then
		return BOT_ACTION_DESIRE_NONE, 0
	end

	local nCastRange = AbilityCastRange(AcidSpray)
	local nCastPoint = AcidSpray:GetCastPoint()
	local nRadius = AcidSpray:GetSpecialValueInt('radius')
    local botTarget = J.GetProperTarget(bot)

	if J.IsInTeamFight(bot, 1200)
	then
		local nLocationAoE = bot:FindAoELocation(true, true, bot:GetLocation(), nCastRange, nRadius, nCastPoint, 0)
		if nLocationAoE.count >= 2
		then
			local realEnemyCount = J.GetEnemiesNearLoc(nLocationAoE.targetloc, nRadius)
            if realEnemyCount ~= nil and #realEnemyCount >= 2
            then
                return BOT_ACTION_DESIRE_HIGH, nLocationAoE.targetloc
            end
		end
	end

    if J.IsGoingOnSomeone(bot) and J.IsValidTarget(botTarget)
    and J.CanCastOnNonMagicImmune(botTarget) and J.IsInRange(bot, botTarget, nCastRange)
    and not J.IsSuspiciousIllusion(botTarget) and not J.CannotBeKilled(bot, botTarget) then
        return BOT_ACTION_DESIRE_HIGH, botTarget:GetExtrapolatedLocation(nCastPoint)
    end

	if J.IsRetreating(bot)
	then
		local nInRangeAlly = J.GetNearbyHeroes(bot,1000, false, BOT_MODE_NONE)
        local nInRangeEnemy = J.GetNearbyHeroes(bot,1000, true, BOT_MODE_NONE)

        if nInRangeAlly ~= nil and nInRangeEnemy
        and J.IsValidHero(nInRangeEnemy[1])
        and J.CanCastOnNonMagicImmune(nInRangeEnemy[1])
        and J.IsInRange(bot, nInRangeEnemy[1], 600)
        and J.IsRunning(nInRangeEnemy[1])
        and nInRangeEnemy[1]:IsFacingLocation(bot:GetLocation(), 30)
        and not J.IsSuspiciousIllusion(nInRangeEnemy[1])
		and not J.IsDisabled(nInRangeEnemy[1])
        then
            local nTargetInRangeAlly = J.GetNearbyHeroes(nInRangeEnemy[1], 800, false, BOT_MODE_NONE)

            if nTargetInRangeAlly ~= nil
            and ((#nTargetInRangeAlly > #nInRangeAlly)
                or (J.GetHP(bot) < 0.45 and bot:WasRecentlyDamagedByAnyHero(2.5)))
            then
                return BOT_ACTION_DESIRE_HIGH, bot:GetLocation()
            end
        end
	end

	if (J.IsDefending(bot) or J.IsPushing(bot))
	then
		local nEnemyLaneCreeps = bot:GetNearbyLaneCreeps(nCastRange, true)
		local nLocationAoE = bot:FindAoELocation(true, false, bot:GetLocation(), nCastRange, nRadius, 0, 0)
		local nTeamLaneFrontLoc = GetLaneFrontLocation(GetTeam(), bot:GetAssignedLane(), 0)
		local nEnemyLaneFrontLoc = GetLaneFrontLocation(GetOpposingTeam(), bot:GetAssignedLane(), 0)

		if nEnemyLaneCreeps ~= nil and #nEnemyLaneCreeps >= 5
		and nLocationAoE.count >= 5
		and J.GetLocationToLocationDistance(nTeamLaneFrontLoc, nEnemyLaneFrontLoc) < 150
		then
			return BOT_ACTION_DESIRE_MODERATE, nLocationAoE.targetloc
		end
	end

	if J.IsFarming(bot)
	then
		local nLocationAoE = bot:FindAoELocation(true, false, bot:GetLocation(), nCastRange, nRadius, 0, 0)
		local nNeutralCreeps = bot:GetNearbyNeutralCreeps(600)
		local nEnemyLaneCreeps = bot:GetNearbyLaneCreeps(600, true)

		if J.IsAttacking(bot)
		and J.GetMP(bot) > 0.33
		then
			if nNeutralCreeps ~= nil
			and ((#nNeutralCreeps >= 3 and nLocationAoE.count >= 3)
				or (#nNeutralCreeps >= 2 and nLocationAoE.count >= 2 and nNeutralCreeps[1]:IsAncientCreep()))
			then
				return BOT_ACTION_DESIRE_HIGH, nLocationAoE.targetloc
			end

			if nEnemyLaneCreeps ~= nil and #nEnemyLaneCreeps >= 4
			and nLocationAoE.count >= 4
			then
				return BOT_ACTION_DESIRE_HIGH, nLocationAoE.targetloc
			end
		end
	end

	if J.IsLaning(bot)
	then
		local nEnemyLaneCreeps = bot:GetNearbyLaneCreeps(600, true)
		local nLocationAoE = bot:FindAoELocation(true, false, bot:GetLocation(), nCastRange, nRadius, 0, 0)

		if J.IsAttacking(bot)
		and J.GetMP(bot) > 0.65
		then
			if nEnemyLaneCreeps ~= nil and #nEnemyLaneCreeps >= 4
			and nLocationAoE.count >= 4
			then
				return BOT_ACTION_DESIRE_HIGH, nLocationAoE.targetloc
			end
		end
	end

    if J.IsDoingRoshan(bot)
    then
        if J.IsRoshan(botTarget)
        and J.CanCastOnNonMagicImmune(botTarget)
        and J.IsInRange(bot, botTarget, 500)
        and J.IsAttacking(bot)
        then
            return BOT_ACTION_DESIRE_HIGH, botTarget:GetLocation()
        end
    end

    if J.IsDoingTormentor(bot)
    then
        if J.IsTormentor(botTarget)
        and J.IsInRange(bot, botTarget, 400)
        and J.IsAttacking(bot)
        then
            return BOT_ACTION_DESIRE_HIGH, botTarget:GetLocation()
        end
    end

	return BOT_ACTION_DESIRE_NONE, 0
end

function X.ConsiderUnstableConcoction()
	if UnstableConcoction:IsHidden()
    or bot:HasModifier('modifier_alchemist_unstable_concoction')
    or not UnstableConcoction:IsFullyCastable()
	then
		return BOT_ACTION_DESIRE_NONE
	end

	local nCastRange = AbilityCastRange(UnstableConcoction)
	local nDamage = UnstableConcoction:GetSpecialValueInt('max_damage')

	local nEnemyHeroes = J.GetNearbyHeroes(bot,nCastRange, true, BOT_MODE_NONE)
	for _, enemyHero in pairs(nEnemyHeroes)
	do
		if J.IsValidHero(enemyHero)
		and J.CanCastOnNonMagicImmune(enemyHero)
            and not enemyHero:HasModifier('modifier_antimage_counterspell')
            and J.CanCastOnTargetAdvanced(enemyHero)
		and J.IsInRange(bot, enemyHero, nCastRange - 200)
		and not J.IsSuspiciousIllusion(enemyHero)
		then
			if enemyHero:IsChanneling()
			then
				return BOT_ACTION_DESIRE_HIGH
			end

			if J.CanKillTarget(enemyHero, nDamage, DAMAGE_TYPE_PHYSICAL)
			and not enemyHero:HasModifier('modifier_abaddon_borrowed_time')
			and not enemyHero:HasModifier('modifier_abaddon_aphotic_shield')
			and not enemyHero:HasModifier('modifier_dazzle_shallow_grave')
			and not enemyHero:HasModifier('modifier_enigma_black_hole_pull')
			and not enemyHero:HasModifier('modifier_faceless_void_chronosphere_freeze')
			and not enemyHero:HasModifier('modifier_oracle_false_promise_timer')
			and not enemyHero:HasModifier('modifier_item_solar_crest_armor_addition')
			then
				return BOT_ACTION_DESIRE_HIGH
			end
		end
	end

	if J.IsGoingOnSomeone(bot)
	then
		local nInRangeAlly = J.GetNearbyHeroes(bot,1000, false, BOT_MODE_NONE)
		local nInRangeEnemy = J.GetNearbyHeroes(bot,nCastRange - 175, true, BOT_MODE_NONE)

		for _, enemyHero in pairs(nInRangeEnemy)
		do
			if J.IsValidTarget(enemyHero)
			and J.CanCastOnNonMagicImmune(enemyHero)
            and not enemyHero:HasModifier('modifier_antimage_counterspell')
            and J.CanCastOnTargetAdvanced(enemyHero)
            and J.IsInRange(bot, enemyHero, nCastRange)
			and not J.IsSuspiciousIllusion(enemyHero)
			and not J.IsDisabled(enemyHero)
			and not enemyHero:HasModifier('modifier_enigma_black_hole_pull')
			and not enemyHero:HasModifier('modifier_faceless_void_chronosphere_freeze')
			and not enemyHero:HasModifier('modifier_legion_commander_duel')
			and not enemyHero:HasModifier('modifier_necrolyte_reapers_scythe')
			then
				local nTargetInRangeAlly = J.GetNearbyHeroes(enemyHero, 1000, false, BOT_MODE_NONE)

				if nInRangeAlly ~= nil and nTargetInRangeAlly ~= nil
				and #nInRangeAlly >= #nTargetInRangeAlly
				then
					return BOT_ACTION_DESIRE_HIGH, enemyHero
				end
			end
		end
	end

	if J.IsRetreating(bot)
	then
		local nInRangeAlly = J.GetNearbyHeroes(bot,nCastRange + 175, false, BOT_MODE_NONE)
		local nInRangeEnemy = J.GetNearbyHeroes(bot,nCastRange, true, BOT_MODE_NONE)

		if nInRangeAlly ~= nil and nInRangeEnemy ~= nil
		and J.IsValidHero(nInRangeEnemy[1])
		and J.CanCastOnNonMagicImmune(nInRangeEnemy[1])
        and not nInRangeEnemy[1]:HasModifier('modifier_antimage_counterspell')
        and J.CanCastOnTargetAdvanced(nInRangeEnemy[1])
		and J.IsInRange(bot, nInRangeEnemy[1], nCastRange - 175)
		and J.IsRunning(nInRangeEnemy[1])
        and nInRangeEnemy[1]:IsFacingLocation(bot:GetLocation(), 30)
		and not J.IsSuspiciousIllusion(nInRangeEnemy[1])
		and not J.IsDisabled(nInRangeEnemy[1])
		and not nInRangeEnemy[1]:HasModifier('modifier_enigma_black_hole_pull')
		and not nInRangeEnemy[1]:HasModifier('modifier_faceless_void_chronosphere_freeze')
		and not nInRangeEnemy[1]:HasModifier('modifier_necrolyte_reapers_scythe')
		then
			local nTargetInRangeAlly = J.GetNearbyHeroes(nInRangeEnemy[1], 800, false, BOT_MODE_NONE)

            if nTargetInRangeAlly ~= nil
            and ((#nTargetInRangeAlly > #nInRangeAlly)
                or (J.GetHP(bot) < 0.6 and bot:WasRecentlyDamagedByAnyHero(2.2)))
            then
                return BOT_ACTION_DESIRE_HIGH
            end
		end
	end

	return BOT_ACTION_DESIRE_NONE
end

function X.ConsiderUnstableConcoctionThrow()
    if UnstableConcoctionThrow == nil or UnstableConcoctionThrow:IsHidden()
    or not UnstableConcoctionThrow:IsFullyCastable() then
        ConcoctionThrowTime = nil
        return BOT_ACTION_DESIRE_NONE, nil
    end
    local range = AbilityCastRange(UnstableConcoctionThrow)
    local brew = UnstableConcoctionThrow:GetSpecialValueFloat('brew_time')
    -- The base spell owns the self-explosion timer; Throw's KV has a different timer.
    local base = bot:GetAbilityByName('alchemist_unstable_concoction')
    local explosion = base ~= nil and base:GetSpecialValueFloat('brew_explosion') or brew + 0.5
    if explosion <= 0 then explosion = brew + 0.5 end
    local remaining = J.GetModifierTime(bot, 'modifier_alchemist_unstable_concoction')
    local elapsed = ConcoctionThrowTime ~= nil and math.max(0, DotaTime() - ConcoctionThrowTime)
        or (remaining > 0 and math.max(0, explosion - remaining) or 0)
    local maxDamage = UnstableConcoctionThrow:GetSpecialValueInt('max_damage')
    local damage = maxDamage * math.min(1, elapsed / brew)
    local deadline = explosion - UnstableConcoctionThrow:GetCastPoint() - 0.3
    local best, score = nil, -1
    for _, enemy in pairs(J.GetNearbyHeroes(bot, range, true, BOT_MODE_NONE)) do
        if J.IsValidHero(enemy) and J.IsInRange(bot, enemy, range)
        and J.CanCastOnNonMagicImmune(enemy)
        and not enemy:HasModifier('modifier_antimage_counterspell')
        and (J.CanCastOnTargetAdvanced(enemy)
            or (elapsed >= deadline and enemy:HasModifier('modifier_item_sphere_target')
                and not enemy:HasModifier('modifier_item_lotus_orb_active')
                and not enemy:HasModifier('modifier_antimage_spell_shield')))
        and not J.IsSuspiciousIllusion(enemy)
        and not enemy:HasModifier('modifier_enigma_black_hole_pull')
        and not enemy:HasModifier('modifier_faceless_void_chronosphere_freeze') then
            if elapsed >= 0.25 and enemy:IsChanneling() then return BOT_ACTION_DESIRE_HIGH, enemy end
            if J.CanKillTarget(enemy, damage, DAMAGE_TYPE_PHYSICAL)
            and not J.CannotBeKilled(bot, enemy)
            and not enemy:HasModifier('modifier_abaddon_aphotic_shield')
            and not enemy:HasModifier('modifier_item_solar_crest_armor_addition')
            and not enemy:HasModifier('modifier_templar_assassin_refraction_absorb') then return BOT_ACTION_DESIRE_HIGH, enemy end
            local priority = (enemy == J.GetProperTarget(bot) and 2 or 1)
                + (not J.CannotBeKilled(bot, enemy) and 3 or 0)
            if priority > score then best, score = enemy, priority end
        end
    end
    if best ~= nil and (elapsed >= math.min(brew, deadline)
        or (elapsed >= 2 and J.IsRetreating(bot))
        or (elapsed >= 1 and not J.IsInRange(bot, best, range - 125))) then
        return BOT_ACTION_DESIRE_HIGH, best
    end
    return BOT_ACTION_DESIRE_NONE, nil
end

function X.ConsiderChemicalRage()
	if not ChemicalRage:IsFullyCastable()
	then
		return BOT_ACTION_DESIRE_NONE
	end

    local botTarget = J.GetProperTarget(bot)
    local healBlocked = bot:HasModifier('modifier_ice_blast') or bot:HasModifier('modifier_doom_bringer_doom')
    if not healBlocked and bot:WasRecentlyDamagedByAnyHero(2) and J.GetHP(bot) < 0.5 then
        return BOT_ACTION_DESIRE_HIGH
    end
    if WantsBasicDispel(bot) then
        return BOT_ACTION_DESIRE_HIGH
    end

	if J.IsInTeamFight(bot, 1200)
	then
		local nRealInRangeEnemy = J.GetEnemiesNearLoc(bot:GetLocation(), 700)
		if nRealInRangeEnemy ~= nil and #nRealInRangeEnemy >= 2
		then
			return BOT_ACTION_DESIRE_HIGH
		end
	end

	if J.IsGoingOnSomeone(bot)
	then
		local nInRangeAlly = J.GetNearbyHeroes(bot,1000, false, BOT_MODE_NONE)

		if J.IsValidTarget(botTarget)
		and J.IsInRange(bot, botTarget, 800)
		and not J.IsSuspiciousIllusion(botTarget)
		and not botTarget:HasModifier('modifier_enigma_black_hole_pull')
		and not botTarget:HasModifier('modifier_faceless_void_chronosphere_freeze')
		and not botTarget:HasModifier('modifier_necrolyte_reapers_scythe')
		then
            local nTargetInRangeAlly = J.GetNearbyHeroes(botTarget, 1000, false, BOT_MODE_NONE)

            if nInRangeAlly ~= nil and nTargetInRangeAlly ~= nil
            and #nInRangeAlly >= #nTargetInRangeAlly
            then
                return BOT_ACTION_DESIRE_HIGH
            end
		end
	end

	if J.IsRetreating(bot)
	then
		local nInRangeAlly = J.GetNearbyHeroes(bot,800, false, BOT_MODE_NONE)
		local nInRangeEnemy = J.GetNearbyHeroes(bot,800, true, BOT_MODE_NONE)

		if nInRangeAlly ~= nil and nInRangeEnemy ~= nil
		and J.IsValidHero(nInRangeEnemy[1])
		and J.IsRunning(nInRangeEnemy[1])
        and nInRangeEnemy[1]:IsFacingLocation(bot:GetLocation(), 30)
		and not J.IsSuspiciousIllusion(nInRangeEnemy[1])
		and not J.IsDisabled(nInRangeEnemy[1])
		and not nInRangeEnemy[1]:HasModifier('modifier_enigma_black_hole_pull')
		and not nInRangeEnemy[1]:HasModifier('modifier_faceless_void_chronosphere_freeze')
		and not nInRangeEnemy[1]:HasModifier('modifier_necrolyte_reapers_scythe')
		then
			local nTargetInRangeAlly = J.GetNearbyHeroes(nInRangeEnemy[1], 800, false, BOT_MODE_NONE)

            if nTargetInRangeAlly ~= nil
            and ((#nTargetInRangeAlly > #nInRangeAlly)
                or (J.GetHP(bot) < 0.35 and bot:WasRecentlyDamagedByAnyHero(1.5)))
            then
                return BOT_ACTION_DESIRE_HIGH
            end
		end
	end

	if J.IsFarming(bot)
	then
		if J.IsAttacking(bot)
		and J.IsValid(botTarget)
		and botTarget:IsCreep()
		and not healBlocked
        and (J.GetHP(bot) < 0.75 or (#bot:GetNearbyNeutralCreeps(600) >= 3 and J.GetMP(bot) > 0.4))
		then
			return BOT_ACTION_DESIRE_HIGH
		end
	end

	if J.IsDoingRoshan(bot)
    then
        if J.IsRoshan(botTarget)
        and J.IsInRange(bot, botTarget, 500)
        and J.IsAttacking(bot)
        then
            return BOT_ACTION_DESIRE_HIGH
        end
    end

    if J.IsDoingTormentor(bot)
    then
        if J.IsTormentor(botTarget)
        and J.IsInRange(bot, botTarget, 400)
        and J.IsAttacking(bot)
        then
            return BOT_ACTION_DESIRE_HIGH
        end
    end

	return BOT_ACTION_DESIRE_NONE
end

function X.ConsiderBerserkPotion()
    if not BerserkPotion:IsTrained() or BerserkPotion:IsHidden()
    or not BerserkPotion:IsFullyCastable() then return BOT_ACTION_DESIRE_NONE, nil end
    local range = AbilityCastRange(BerserkPotion)
    local candidates = { bot }
    for _, ally in pairs(J.GetNearbyHeroes(bot, range, false, BOT_MODE_NONE)) do
        if ally ~= bot then candidates[#candidates + 1] = ally end
    end
    local best, bestScore = nil, -1
    for _, ally in pairs(candidates) do
        if J.IsValidHero(ally) and J.IsInRange(bot, ally, range) and ally:CanBeSeen()
        and not ally:IsInvulnerable() and not ally:IsIllusion()
        and not ally:HasModifier('modifier_alchemist_berserk_potion') then
            if WantsBasicDispel(ally) then return BOT_ACTION_DESIRE_HIGH, ally, true end
            local target = J.GetProperTarget(ally)
            local fighting = J.IsGoingOnSomeone(ally) and J.IsValidHero(target)
                and J.IsInRange(ally, target, ally:GetAttackRange() + 150)
            local healing = J.GetHP(ally) < 0.65
                and not ally:HasModifier('modifier_ice_blast') and not ally:HasModifier('modifier_doom_bringer_doom')
                and ally:WasRecentlyDamagedByAnyHero(2.5)
            local score = (fighting and 2 or 0) + (healing and 1 - J.GetHP(ally) or 0)
            if score > 0 and score > bestScore then best, bestScore = ally, score end
        end
    end
    if best ~= nil then return BOT_ACTION_DESIRE_HIGH, best, false end
    return BOT_ACTION_DESIRE_NONE, nil, false
end

return X
