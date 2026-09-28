local X = {}
local bot = GetBot()

local J = require( GetScriptDirectory()..'/FunLib/jmz_func' )
local Minion = dofile( GetScriptDirectory()..'/FunLib/aba_minion' )
local sTalentList = J.Skill.GetTalentList( bot )
local sAbilityList = J.Skill.GetAbilityList( bot )
local sRole = J.Item.GetRoleItemsBuyList( bot )

-- Updated to 7.41f from D2PT on 2026-09-27; see Builds/abaddon.lua for samples.
local BuildData = require(GetScriptDirectory()..'/BotLib/Builds/abaddon')
X.buildMetadata = BuildData
X.neutralPreferences = BuildData.neutrals[sRole]
local isSupport = sRole == 'pos_4' or sRole == 'pos_5'
local tTalentTreeList
local nAbilityBuildList
if isSupport then
    -- D2PT pos 4/5: Shield, then max Coil; Curse at level 10, first talent at 11.
    tTalentTreeList = { t10={10,0}, t15={10,0}, t20={0,10}, t25={10,0} }
    nAbilityBuildList = {2,1,1,2,1,6,1,2,2,3,6,3,3,3,6}
else
    -- D2PT pos 1/3: max Shield, then Curse. Levels after 10 are a legal continuation.
    tTalentTreeList = { t10={0,10}, t15={0,10}, t20={10,0}, t25={0,10} }
    nAbilityBuildList = {2,3,2,3,2,6,2,3,3,1,6,1,1,1,6}
end
local nTalentBuildList = J.Skill.GetTalentBuild(tTalentTreeList)
local defaultAbilityBuild = nAbilityBuildList
local defaultTalentBuild = nTalentBuildList
local sRoleItemsBuyList = {}

-- Updated to 7.41f: carry. Components are resolved by the game's recipe API.
sRoleItemsBuyList.pos_1 = {
    'item_tango', 'item_quelling_blade', 'item_branches', 'item_circlet', 'item_magic_stick',
    'item_null_talisman', 'item_magic_wand', 'item_phase_boots',
    'item_radiance', 'item_yasha', 'item_manta', 'item_blink', 'item_orchid', 'item_bloodthorn',
    -- Bot late-game continuation: slot-free upgrades, then finish existing equipment.
    'item_aghanims_shard', 'item_ultimate_scepter_2', 'item_overwhelming_blink',
    'item_basher', 'item_abyssal_blade', 'item_moon_shard',
}
-- Mid skipped: one match. Explicit player overrides use the carry fallback, not a validated mid build.
sRoleItemsBuyList.pos_2 = sRoleItemsBuyList.pos_1

-- Updated to 7.41f: offlane brings Blink forward between Yasha and Manta.
sRoleItemsBuyList.pos_3 = {
    'item_tango', 'item_quelling_blade', 'item_branches', 'item_circlet', 'item_magic_stick',
    'item_null_talisman', 'item_magic_wand', 'item_phase_boots',
    'item_radiance', 'item_yasha', 'item_blink', 'item_manta', 'item_orchid',
    -- Natural Orchid upgrade followed by bot late-game continuation.
    'item_bloodthorn', 'item_aghanims_shard', 'item_ultimate_scepter_2',
    'item_overwhelming_blink', 'item_basher', 'item_abyssal_blade', 'item_moon_shard',
}

-- Updated to 7.41f: most-played position 4 build, including Pavise -> Solar Crest.
sRoleItemsBuyList.pos_4 = {
    'item_tango', 'item_double_branches', 'item_magic_stick', 'item_ward_sentry', 'item_blood_grenade',
    'item_magic_wand', 'item_arcane_boots', 'item_pavise', 'item_holy_locket',
    'item_solar_crest', 'item_mekansm', 'item_guardian_greaves',
    -- Late-game continuation, not additional D2PT core items.
    'item_ultimate_scepter', 'item_aghanims_shard', 'item_ultimate_scepter_2',
    'item_blink', 'item_overwhelming_blink', 'item_moon_shard',
}

-- Updated to 7.41f: position 5. Greaves consolidates the existing boots and Mek.
sRoleItemsBuyList.pos_5 = {
    'item_tango', 'item_double_branches', 'item_magic_stick', 'item_ward_sentry', 'item_blood_grenade',
    'item_magic_wand', 'item_arcane_boots', 'item_holy_locket', 'item_mekansm',
    'item_blink', 'item_ultimate_scepter',
    -- Natural upgrades / bot late-game continuation.
    'item_guardian_greaves', 'item_aghanims_shard', 'item_ultimate_scepter_2',
    'item_overwhelming_blink', 'item_moon_shard',
}
X.sBuyList = sRoleItemsBuyList[sRole] or sRoleItemsBuyList.pos_3
X.sSellList = {
    'item_radiance', 'item_quelling_blade',
    'item_manta', 'item_null_talisman',
    'item_bloodthorn', 'item_magic_wand',
}

if J.Role.IsPvNMode() or J.Role.IsAllShadow() then X['sBuyList'], X['sSellList'] = { 'PvN_antimage' }, {} end

nAbilityBuildList, nTalentBuildList, X['sBuyList'], X['sSellList'] = J.SetUserHeroInit( nAbilityBuildList, nTalentBuildList, X['sBuyList'], X['sSellList'] )

X['sSkillList'] = J.Skill.GetSkillList( sAbilityList, nAbilityBuildList, sTalentList, nTalentBuildList )
-- Preserve user-provided skill builds. The default support build delays its first talent.
if isSupport and nAbilityBuildList == defaultAbilityBuild and nTalentBuildList == defaultTalentBuild then
    X.sSkillList[10], X.sSkillList[11] = X.sSkillList[11], X.sSkillList[10]
end


X['bDeafaultAbility'] = false
X['bDeafaultItem'] = false

function X.MinionThink(hMinionUnit)
	if Minion.IsValidUnit( hMinionUnit )
	then
		if J.IsValidHero(hMinionUnit) and hMinionUnit:IsIllusion()
		then
			Minion.IllusionThink( hMinionUnit )
		end
	end
end

local MistCoil          = bot:GetAbilityByName( 'abaddon_death_coil' )
local AphoticShield     = bot:GetAbilityByName( 'abaddon_aphotic_shield' )
-- local CurseOfAvernus    = bot:GetAbilityByName( 'abaddon_frostmourne' )
-- local BorrowedTimelocal = bot:GetAbilityByName( 'abaddon_borrowed_time' )

local MistCoilDesire, MistCoilTarget
local AphoticShieldDesire, AphoticShieldTarget

function X.SkillsComplement()
	if J.CanNotUseAbility(bot) then return end

    AphoticShieldDesire, AphoticShieldTarget = X.ConsiderAphoticShield()
    if AphoticShieldDesire > 0
    then
        bot:Action_UseAbilityOnEntity(AphoticShield, AphoticShieldTarget)
        return
    end

    MistCoilDesire, MistCoilTarget = X.ConsiderMistCoil()
    if MistCoilDesire > 0 and MistCoilTarget
    then
        bot:Action_UseAbilityOnEntity(MistCoil, MistCoilTarget)
        return
    end
end

function X.ConsiderMistCoil()
    if not MistCoil:IsFullyCastable()
    then
		return BOT_ACTION_DESIRE_NONE, nil
	end

	local nCastRange = MistCoil:GetCastRange()
	local nDamage = MistCoil:GetSpecialValueInt('target_damage')
	local nSelfDamage = MistCoil:GetSpecialValueInt('self_damage')
    local nDamageType = DAMAGE_TYPE_MAGICAL
    local botTarget = J.GetProperTarget(bot)
    local nEnemyHeroes = J.GetNearbyHeroes(bot,nCastRange, true, BOT_MODE_NONE)

    if J.HasAghanimsShard(bot)
    then
        nDamage = bot:GetAttackDamage()
        nDamageType = DAMAGE_TYPE_PURE
    end

    if J.IsGoingOnSomeone(bot) then
        if J.IsValidHero(botTarget)
        and J.CanCastOnMagicImmune(botTarget) then
            return BOT_ACTION_DESIRE_HIGH, botTarget
        end
    end

    local nAllyHeroes = J.GetNearbyHeroes(bot,nCastRange, false, BOT_MODE_NONE)
	for _, allyHero in pairs(nAllyHeroes)
	do
        if J.IsValidHero(allyHero)
        and not allyHero:IsInvulnerable()
        and not allyHero:IsIllusion()
        and (allyHero:HasModifier('modifier_faceless_void_chronosphere_freeze')
            or allyHero:HasModifier('modifier_enigma_black_hole_pull'))
        then
            return BOT_ACTION_DESIRE_HIGH, allyHero
        end

		if J.IsValidHero(allyHero)
		and J.IsInRange(bot, allyHero, nCastRange)
		and not allyHero:HasModifier('modifier_legion_commander_press_the_attack')
		and not allyHero:IsMagicImmune()
		and not allyHero:IsInvulnerable()
        and not allyHero:IsIllusion()
		and allyHero:CanBeSeen()
		then
			if J.IsRetreating(allyHero)
            and J.GetHP(allyHero) < 0.6
			then
				return BOT_ACTION_DESIRE_HIGH, allyHero
			end

			if J.IsGoingOnSomeone(allyHero)
			then
                local allyTarget = allyHero:GetAttackTarget()

				if J.IsValidHero(allyTarget)
				and allyHero:IsFacingLocation(allyTarget:GetLocation(), 30)
				and J.IsInRange(allyHero, allyTarget, 300)
                and J.GetHP(allyHero) < 0.8
                and J.GetHP(bot) > 0.2
				then
					return BOT_ACTION_DESIRE_HIGH, allyHero
				end
			end
		end
	end

    if not J.IsRetreating(bot)
    and nEnemyHeroes ~= nil
    and J.IsValidHero(nEnemyHeroes[1])
    and J.IsInRange(bot, nEnemyHeroes[1], nCastRange)
    and J.GetMP(bot) > 0.25
	then
        local nInRangeAlly = J.GetNearbyHeroes(bot,nCastRange + 200, false, BOT_MODE_NONE)
        local nInRangeEnemy = J.GetNearbyHeroes(bot,nCastRange, true, BOT_MODE_NONE)

        if nInRangeAlly ~= nil and nInRangeEnemy ~= nil
        and ((#nInRangeAlly == 0 and #nInRangeEnemy >= 1)
            or (#nInRangeAlly >= 1
                and J.GetHP(bot) < 0.25
                and bot:WasRecentlyDamagedByAnyHero(1)
                and not bot:HasModifier('modifier_abaddon_borrowed_time')))
        and J.IsValidHero(nInRangeEnemy[1])
        and not J.IsSuspiciousIllusion(nInRangeEnemy[1])
        and not J.IsDisabled(nInRangeEnemy[1])
        then
            return BOT_ACTION_DESIRE_HIGH, nInRangeEnemy[1]
        end
	end

    if J.IsDoingRoshan(bot)
    then
        if J.IsRoshan(botTarget)
        and J.CanCastOnNonMagicImmune(botTarget)
        and J.IsInRange(bot, botTarget, 500)
        and J.IsAttacking(bot)
        then
            return BOT_ACTION_DESIRE_HIGH, botTarget
        end
    end

    if J.IsDoingTormentor(bot)
    then
        if J.IsTormentor(botTarget)
        and J.IsInRange(bot, botTarget, 400)
        and J.IsAttacking(bot)
        then
            return BOT_ACTION_DESIRE_HIGH, botTarget
        end
    end

    for _, enemyHero in pairs(nEnemyHeroes)
    do
        if J.IsValidHero(enemyHero)
        and J.CanCastOnMagicImmune(enemyHero)
        and not J.IsSuspiciousIllusion(enemyHero)
        and J.CanKillTarget(enemyHero, nDamage, nDamageType)
        and not enemyHero:HasModifier('modifier_dazzle_shallow_grave')
        and not enemyHero:HasModifier('modifier_oracle_false_promise_timer')
        and not enemyHero:HasModifier('modifier_templar_assassin_refraction_absorb')
        then
            return BOT_ACTION_DESIRE_HIGH, enemyHero
        end
    end

	return BOT_ACTION_DESIRE_NONE, nil
end

function X.ConsiderAphoticShield()
    if not AphoticShield:IsFullyCastable()
    then
		return BOT_ACTION_DESIRE_NONE, nil
	end

	local nCastRange  = AphoticShield:GetCastRange()
    local botTarget = J.GetProperTarget(bot)

    local nAllyHeroes = J.GetNearbyHeroes(bot,nCastRange, false, BOT_MODE_NONE)
    for _, allyHero in pairs(nAllyHeroes)
	do
        if J.IsValidHero(allyHero)
        and not allyHero:IsInvulnerable()
        and not allyHero:IsIllusion()
        and (allyHero:HasModifier('modifier_faceless_void_chronosphere_freeze')
            or allyHero:HasModifier('modifier_enigma_black_hole_pull')
            or allyHero:HasModifier('modifier_legion_commander_duel'))
        then
            return BOT_ACTION_DESIRE_HIGH, allyHero
        end

        if J.IsValidHero(allyHero)
        and J.IsDisabled(allyHero)
        and not allyHero:IsMagicImmune()
		and not allyHero:IsInvulnerable()
        and not allyHero:IsIllusion()
        then
            return BOT_ACTION_DESIRE_HIGH, allyHero
        end

		if J.IsValidHero(allyHero)
        and not allyHero:HasModifier('modifier_abaddon_aphotic_shield')
        and not allyHero:HasModifier('modifier_item_solar_crest_armor_addition')
		and not allyHero:IsMagicImmune()
		and not allyHero:IsInvulnerable()
        and not allyHero:IsIllusion()
        and J.IsNotSelf(bot, allyHero)
		then
            local nAllyInRangeEnemy = J.GetNearbyHeroes(allyHero, 800, true, BOT_MODE_NONE)

            if J.IsRetreating(allyHero)
            and allyHero:WasRecentlyDamagedByAnyHero(1.6)
            and not allyHero:IsIllusion()
            then
                if nAllyInRangeEnemy ~= nil and #nAllyInRangeEnemy >= 1
                and J.IsValidHero(nAllyInRangeEnemy[1])
                and J.IsInRange(allyHero, nAllyInRangeEnemy[1], 400)
                and J.IsInRange(bot, nAllyInRangeEnemy[1], nCastRange)
                and J.IsRunning(allyHero)
                and nAllyInRangeEnemy[1]:IsFacingLocation(allyHero:GetLocation(), 30)
                and not J.IsDisabled(nAllyInRangeEnemy[1])
                and not J.IsTaunted(nAllyInRangeEnemy[1])
                and not J.IsSuspiciousIllusion(nAllyInRangeEnemy[1])
                and not nAllyInRangeEnemy[1]:HasModifier('modifier_legion_commander_duel')
                and not nAllyInRangeEnemy[1]:HasModifier('modifier_enigma_black_hole_pull')
                and not nAllyInRangeEnemy[1]:HasModifier('modifier_faceless_void_chronosphere_freeze')
                and not nAllyInRangeEnemy[1]:HasModifier('modifier_necrolyte_reapers_scythe')
                then
                    return BOT_ACTION_DESIRE_HIGH, allyHero
                end
            end

			if J.IsGoingOnSomeone(allyHero)
			then
				local allyTarget = allyHero:GetAttackTarget()

				if J.IsValidHero(allyTarget)
				and J.IsInRange(allyHero, allyTarget, allyHero:GetAttackRange())
                and not J.IsSuspiciousIllusion(allyTarget)
                and not allyTarget:HasModifier('modifier_faceless_void_chronosphere_freeze')
                and not allyTarget:HasModifier('modifier_enigma_black_hole_pull')
                and not allyTarget:HasModifier('modifier_necrolyte_reapers_scythe')
				then
                    local nAllInRangeAlly = J.GetNearbyHeroes(allyHero, 800, false, BOT_MODE_NONE)
                    local nTargetInRangeAlly = J.GetNearbyHeroes(allyTarget, 800, false, BOT_MODE_NONE)

                    if nAllInRangeAlly ~= nil and  nTargetInRangeAlly ~= nil
                    and #nAllInRangeAlly >= #nTargetInRangeAlly
                    then
                        return BOT_ACTION_DESIRE_HIGH, allyHero
                    end
				end
			end
		end
	end

	if J.IsGoingOnSomeone(bot)
    then
		local nInRangeAlly = J.GetNearbyHeroes(bot,1000, false, BOT_MODE_NONE)
        local nInRangeEnemy = J.GetNearbyHeroes(bot,1000, true, BOT_MODE_NONE)

		if J.IsValidTarget(botTarget)
        and J.IsInRange(bot, botTarget, nCastRange)
        and not J.IsSuspiciousIllusion(botTarget)
        and not J.IsDisabled(botTarget)
        and not botTarget:HasModifier('modifier_faceless_void_chronosphere_freeze')
        and not botTarget:HasModifier('modifier_enigma_black_hole_pull')
        then
            local nTargetInRangeAlly = J.GetNearbyHeroes(botTarget, 800, false, BOT_MODE_NONE)

            if nInRangeAlly ~= nil and nTargetInRangeAlly ~= nil
            and #nInRangeAlly >= #nTargetInRangeAlly
            then
                if J.IsValidHero(nInRangeAlly[1])
                and J.IsInRange(bot, nInRangeAlly[1], nCastRange)
                and J.IsCore(nInRangeAlly[1])
                and not nInRangeAlly[1]:HasModifier('modifier_abaddon_aphotic_shield')
                and not nInRangeAlly[1]:IsMagicImmune()
                and not nInRangeAlly[1]:IsInvulnerable()
                and not nInRangeAlly[1]:IsIllusion()
                then
                    return BOT_ACTION_DESIRE_HIGH, nInRangeAlly[1]
                end

                if not bot:HasModifier('modifier_abaddon_aphotic_shield')
                and not bot:HasModifier("modifier_abaddon_borrowed_time")
                then
                    return BOT_ACTION_DESIRE_MODERATE, bot
                end
            end
	    end

        if nInRangeAlly ~= nil and nInRangeEnemy ~= nil
        and #nInRangeAlly == 0 and #nInRangeEnemy >= 1
        and J.IsValidHero(nInRangeEnemy[1])
        and J.IsInRange(bot, nInRangeEnemy[1], 500)
        and not J.IsSuspiciousIllusion(nInRangeEnemy[1])
        and not J.IsDisabled(nInRangeEnemy[1])
        and not bot:HasModifier('modifier_abaddon_aphotic_shield')
        and not bot:HasModifier("modifier_abaddon_borrowed_time")
        then
            return BOT_ACTION_DESIRE_MODERATE, bot
        end
    end

    if J.IsRetreating(bot)
    then
        local nInRangeAlly = J.GetNearbyHeroes(bot,800, false, BOT_MODE_NONE)
        local nInRangeEnemy = J.GetNearbyHeroes(bot,800, true, BOT_MODE_NONE)

        if nInRangeAlly ~= nil and nInRangeEnemy
        and J.IsValidHero(nInRangeEnemy[1])
        and J.CanCastOnNonMagicImmune(nInRangeEnemy[1])
        and J.IsInRange(bot, nInRangeEnemy[1], nCastRange)
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
                or (J.GetHP(bot) < 0.55 and bot:WasRecentlyDamagedByAnyHero(2)))
            then
                return BOT_ACTION_DESIRE_HIGH, bot
            end
        end
    end

    if J.IsDoingRoshan(bot)
    then
        if J.IsRoshan(botTarget)
        and J.IsInRange(bot, botTarget, 500)
        and J.IsAttacking(bot)
        then
            local weakestAlly = J.GetAttackableWeakestUnit(bot, nCastRange, true, false)

            if weakestAlly ~= nil
            and not weakestAlly:HasModifier('modifier_abaddon_aphotic_shield')
            then
                return BOT_ACTION_DESIRE_HIGH, weakestAlly
            end
        end
    end

    if J.IsDoingTormentor(bot)
    then
        if J.IsTormentor(botTarget)
        and J.IsInRange(bot, botTarget, 400)
        and J.IsAttacking(bot)
        then
            local weakestAlly = J.GetAttackableWeakestUnit(bot, nCastRange, true, false)

            if weakestAlly ~= nil
            and not weakestAlly:HasModifier('modifier_abaddon_aphotic_shield')
            then
                return BOT_ACTION_DESIRE_HIGH, weakestAlly
            end
        end
    end

	return BOT_ACTION_DESIRE_NONE, nil
end

return X