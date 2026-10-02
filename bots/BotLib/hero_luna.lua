local X = {}
local bot = GetBot()

local J = require( GetScriptDirectory()..'/FunLib/jmz_func' )
local SpellDecisions=require(GetScriptDirectory()..'/FunLib/rubick_hero/luna')
local Minion = dofile( GetScriptDirectory()..'/FunLib/aba_minion' )
local sTalentList = J.Skill.GetTalentList( bot )
local sAbilityList = J.Skill.GetAbilityList( bot )
local sRole = J.Item.GetRoleItemsBuyList( bot )

-- Updated to 7.41f from D2PT: carry only; forced other roles use carry.
local BuildData = require(GetScriptDirectory()..'/BotLib/Builds/luna')
X.buildMetadata = BuildData
X.neutralPreferences = BuildData.neutrals[sRole]
-- [1] Lucent Beam, [2] Lunar Orbit, [3] Moon Glaives, [6] Eclipse.
local nAbilityBuildList = {1,3,1,3,1,6,1,3,3,2,6,2,2,2,6}
local nTalentBuildList = J.Skill.GetTalentBuild({
    t10={0,10}, -- -5% Moon Glaives damage reduction
    t15={0,10}, -- +1 Lunar Orbit glaive
    t20={10,0}, -- +1.5x Lunar Orbit damage/speed
    t25={0,10}, -- +25/+50 Lunar Blessing damage
})
local defaultAbilityBuild, defaultTalentBuild = nAbilityBuildList, nTalentBuildList
X.sBuyList = {
    'item_branches','item_magic_wand','item_faerie_fire',
    'item_power_treads','item_lifesteal','item_mask_of_madness','item_yasha','item_manta',
    'item_blink','item_butterfly','item_black_king_bar','item_aghanims_shard',
    -- Bot policy: upgrade Blink and replace Mask of Madness with late sustain.
    'item_swift_blink','item_satanic','item_moon_shard',
}
X.sSellList = {'item_butterfly','item_magic_wand','item_satanic','item_mask_of_madness'}

if J.Role.IsPvNMode() or J.Role.IsAllShadow() then X['sBuyList'], X['sSellList'] = { 'PvN_ranged_carry' }, {} end

nAbilityBuildList, nTalentBuildList, X['sBuyList'], X['sSellList'] = J.SetUserHeroInit( nAbilityBuildList, nTalentBuildList, X['sBuyList'], X['sSellList'] )

X['sSkillList'] = J.Skill.GetSkillList( sAbilityList, nAbilityBuildList, sTalentList, nTalentBuildList )
-- Observed ability at 10, first talent at 11; preserve custom overrides.
if nAbilityBuildList == defaultAbilityBuild and nTalentBuildList == defaultTalentBuild then
    X.sSkillList[10], X.sSkillList[11] = X.sSkillList[11], X.sSkillList[10]
end

X['bDeafaultAbility'] = false
X['bDeafaultItem'] = false

function X.MinionThink(hMinionUnit)
	Minion.MinionThink(hMinionUnit)
end

local LucentBeam 	= bot:GetAbilityByName('luna_lucent_beam')
-- local MoonGlaives 	= bot:GetAbilityByName('luna_moon_glaive')
local LunarOrbit    = bot:GetAbilityByName("luna_lunar_orbit")
-- local LunarBlessing = bot:GetAbilityByName('luna_lunar_blessing')
local Eclipse 		= bot:GetAbilityByName('luna_eclipse')

local LucentBeamDesire, LucentBeamTarget
local MoonGlaivesDesire
local LunarOrbitDesire
local EclipseDesire


local botTarget

function X.SkillsComplement()
	if J.CanNotUseAbility(bot) then return end

	botTarget = J.GetProperTarget(bot)
	J.ConsiderTarget()


	-- MoonGlaivesDesire = X.ConsiderMoonGlaives()
	-- if MoonGlaivesDesire > 0
	-- then
	-- 	bot:Action_UseAbility(MoonGlaives)
	-- 	return
	-- end
    if J.CanCastAbility(LucentBeam) then
        local lens=J.IsItemAvailable('item_aether_lens')
        local range=LucentBeam:GetCastRange()+(lens~=nil and lens:GetSpecialValueInt('cast_range_bonus') or 0)
        for _,enemy in pairs(J.GetNearbyHeroes(bot,math.min(1600,range),true,BOT_MODE_NONE)) do
            if J.IsValidHero(enemy) and enemy:IsChanneling() and J.CanCastOnNonMagicImmune(enemy)
                and J.CanCastOnTargetAdvanced(enemy) then
                J.SetQueuePtToINT(bot,true,LucentBeam)
                bot:ActionQueue_UseAbilityOnEntity(LucentBeam,enemy)
                return
            end
        end
    end
	LunarOrbitDesire = X.ConsiderLunarOrbit()
	if LunarOrbitDesire > 0
	then
		bot:Action_UseAbility(LunarOrbit)
		return
	end

    local eclipseLocation=SpellDecisions.EclipseLocation(Eclipse,LucentBeam)
    if eclipseLocation~=nil then
        J.SetQueuePtToINT(bot,true,Eclipse)
        if bot:HasScepter() then bot:ActionQueue_UseAbilityOnLocation(Eclipse,eclipseLocation)
        else bot:ActionQueue_UseAbility(Eclipse) end
        return
    end

	LucentBeamDesire, LucentBeamTarget = X.ConsiderLucentBeam()
	if LucentBeamDesire > 0
	then
		if J.HasPowerTreads(bot)
		then
			J.SetQueuePtToINT(bot, false, LucentBeam)
			bot:ActionQueue_UseAbilityOnEntity(LucentBeam, LucentBeamTarget)
		else
			bot:Action_UseAbilityOnEntity(LucentBeam, LucentBeamTarget)
		end

		return
	end
end

function X.ConsiderLucentBeam()
	if not J.CanCastAbility(LucentBeam)
	then
		return BOT_ACTION_DESIRE_NONE, nil
	end

	local lens=J.IsItemAvailable('item_aether_lens')
    local nCastRange=LucentBeam:GetCastRange()+(lens~=nil and lens:GetSpecialValueInt('cast_range_bonus') or 0)
	local nAbilityLevel = LucentBeam:GetLevel()
	local nDamage = LucentBeam:GetSpecialValueInt('beam_damage')

	local nEnemyHeroes = J.GetNearbyHeroes(bot,nCastRange, true, BOT_MODE_NONE)
	for _, enemyHero in pairs(nEnemyHeroes)
	do
		if J.IsValidHero(enemyHero)
		and J.CanCastOnNonMagicImmune(enemyHero)
		and J.CanCastOnTargetAdvanced(enemyHero)
		and not J.IsSuspiciousIllusion(enemyHero)
		then
			if enemyHero:IsChanneling() or J.IsCastingUltimateAbility(enemyHero)
			then
				return BOT_ACTION_DESIRE_HIGH, enemyHero
			end

			if J.CanKillTarget(enemyHero, nDamage, DAMAGE_TYPE_MAGICAL)
			and not enemyHero:HasModifier('modifier_abaddon_borrowed_time')
			and not enemyHero:HasModifier('modifier_dazzle_shallow_grave')
			and not enemyHero:HasModifier('modifier_necrolyte_reapers_scythe')
			and not enemyHero:HasModifier('modifier_oracle_false_promise_timer')
			and not enemyHero:HasModifier('modifier_templar_assassin_refraction_absorb')
			then
				return BOT_ACTION_DESIRE_HIGH, enemyHero
			end

		end
	end

	if J.IsInTeamFight(bot, 1200)
	then
		local npcWeakestEnemy = nil
		local npcWeakestEnemyHealth = 10000

		for _, enemyHero in pairs(nEnemyHeroes)
		do
			if J.IsValidHero(enemyHero)
			and J.CanCastOnNonMagicImmune(enemyHero)
			and J.CanCastOnTargetAdvanced(enemyHero)
			and not J.IsSuspiciousIllusion(enemyHero)
			and not enemyHero:HasModifier('modifier_abaddon_borrowed_time')
			and not enemyHero:HasModifier('modifier_necrolyte_reapers_scythe')
			and not enemyHero:HasModifier('modifier_oracle_false_promise_timer')
			then
				local npcEnemyHealth = enemyHero:GetHealth()
				if npcEnemyHealth < npcWeakestEnemyHealth
				then
					npcWeakestEnemyHealth = npcEnemyHealth
					npcWeakestEnemy = enemyHero
				end
			end
		end

		if npcWeakestEnemy ~= nil
		then
			return BOT_ACTION_DESIRE_HIGH, npcWeakestEnemy
		end
	end

	if J.IsGoingOnSomeone(bot)
	then
		if J.IsValidTarget(botTarget)
		and J.CanCastOnNonMagicImmune(botTarget)
		and J.CanCastOnTargetAdvanced(botTarget)
		and J.IsInRange(bot, botTarget, nCastRange)
		and not botTarget:HasModifier('modifier_abaddon_borrowed_time')
		and not botTarget:HasModifier('modifier_necrolyte_reapers_scythe')
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
	and bot:GetActiveModeDesire() > 0.5
    then
        local nInRangeEnemy = J.GetNearbyHeroes(bot,nCastRange, true, BOT_MODE_NONE)
        for _, enemyHero in pairs(nInRangeEnemy)
        do
            if J.IsValidHero(enemyHero)
            and J.CanCastOnNonMagicImmune(enemyHero)
			and J.CanCastOnTargetAdvanced(enemyHero)
            and J.IsChasingTarget(enemyHero, bot)
            and not J.IsSuspiciousIllusion(enemyHero)
            and not J.IsDisabled(enemyHero)
			and not J.IsRealInvisible(bot)
            then
                local nInRangeAlly = J.GetNearbyHeroes(enemyHero, 1200, true, BOT_MODE_NONE)
                local nTargetInRangeAlly = J.GetNearbyHeroes(enemyHero, 1200, false, BOT_MODE_NONE)

                if nInRangeAlly ~= nil and nTargetInRangeAlly ~= nil
                and ((#nTargetInRangeAlly > #nInRangeAlly)
                    or bot:WasRecentlyDamagedByAnyHero(2))
                then
                    return BOT_ACTION_DESIRE_HIGH, enemyHero
                end
            end
        end
    end

	if J.IsLaning(bot)
	then
		local nEnemyLaneCreeps = bot:GetNearbyLaneCreeps(nCastRange, true)
		for _, creep in pairs(nEnemyLaneCreeps)
		do
			if J.IsValid(creep)
			and J.CanBeAttacked(creep)
			and (J.IsKeyWordUnit('ranged', creep) or J.IsKeyWordUnit('siege', creep) or J.IsKeyWordUnit('flagbearer', creep))
			and J.CanKillTarget(creep, nDamage, DAMAGE_TYPE_MAGICAL)
			and not J.IsInRange(bot, creep, bot:GetAttackRange() + 80)
			then
				return BOT_ACTION_DESIRE_HIGH, creep
			end
		end

		if nAbilityLevel >= 2
		or J.GetMP(bot) > 0.9
		then
			for _, creep in pairs(nEnemyLaneCreeps)
			do
				if J.IsValid(creep)
				and J.CanBeAttacked(creep)
				and J.IsKeyWordUnit('melee', creep)
				and J.CanKillTarget(creep, nDamage, DAMAGE_TYPE_MAGICAL)
				and not J.IsInRange(bot, creep, bot:GetAttackRange() + 80)
				then
					return BOT_ACTION_DESIRE_HIGH, creep
				end
			end
		end
	end

	if J.IsFarming(bot)
	then
		local nNeutralCreeps = bot:GetNearbyNeutralCreeps(nCastRange + 100)
		local targetCreep = J.GetMostHpUnit(nNeutralCreeps)

		if J.IsValid(targetCreep)
		and (#nNeutralCreeps >= 2 or GetUnitToUnitDistance(targetCreep, bot) <= 400)
		and not J.IsRoshan(targetCreep)
		and not J.CanKillTarget(targetCreep, bot:GetAttackDamage() * 1.68, DAMAGE_TYPE_PHYSICAL)
		and not J.CanKillTarget(targetCreep, nDamage - 10, DAMAGE_TYPE_MAGICAL)
		and J.GetManaAfter(LucentBeam:GetManaCost()) * bot:GetMana() > Eclipse:GetManaCost() * 2
		then
			return BOT_ACTION_DESIRE_HIGH, targetCreep
		end
	end

	if J.IsDoingRoshan(bot)
    then
		-- Remove Spell Block
        if J.IsRoshan(botTarget)
        and J.CanCastOnNonMagicImmune(botTarget)
        and J.IsInRange(bot, botTarget, nCastRange)
		and J.IsAttacking(bot)
        and not J.IsDisabled(botTarget)
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

	local nAllyHeroes = J.GetNearbyHeroes(bot,nCastRange, false, BOT_MODE_NONE)
    for _, allyHero in pairs(nAllyHeroes)
    do
        local nAllyInRangeEnemy = J.GetNearbyHeroes(allyHero, 1200, true, BOT_MODE_NONE)

        if J.IsValidHero(allyHero)
        and J.IsRetreating(allyHero)
        and J.IsCore(allyHero)
        and allyHero:WasRecentlyDamagedByAnyHero(2)
        and allyHero:GetActiveModeDesire() >= 0.5
        and not allyHero:IsIllusion()
        then
            if nAllyInRangeEnemy ~= nil and #nAllyInRangeEnemy >= 1
            and J.IsValidHero(nAllyInRangeEnemy[1])
            and J.CanCastOnNonMagicImmune(nAllyInRangeEnemy[1])
            and J.CanCastOnTargetAdvanced(nAllyInRangeEnemy[1])
            and J.IsInRange(bot, nAllyInRangeEnemy[1], nCastRange)
            and J.IsChasingTarget(nAllyInRangeEnemy[1], allyHero)
            and not J.IsChasingTarget(nAllyInRangeEnemy[1], bot)
            and not J.IsDisabled(nAllyInRangeEnemy[1])
            and not J.IsTaunted(nAllyInRangeEnemy[1])
            and not J.IsSuspiciousIllusion(nAllyInRangeEnemy[1])
            and not nAllyInRangeEnemy[1]:HasModifier('modifier_necrolyte_reapers_scythe')
            then
                return BOT_ACTION_DESIRE_HIGH, nAllyInRangeEnemy[1]
            end
        end
    end

	return BOT_ACTION_DESIRE_NONE, nil
end
function X.ConsiderLunarOrbit()
    return SpellDecisions.OrbitUseful(LunarOrbit) and BOT_ACTION_DESIRE_HIGH or BOT_ACTION_DESIRE_NONE
end

function X.ConsiderEclipse()
    return SpellDecisions.EclipseLocation(Eclipse,LucentBeam)~=nil and BOT_ACTION_DESIRE_HIGH or BOT_ACTION_DESIRE_NONE
end

return X
