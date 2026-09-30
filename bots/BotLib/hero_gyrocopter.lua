local X = {}
local bot = GetBot()

local J = require( GetScriptDirectory()..'/FunLib/jmz_func' )
local Minion = dofile( GetScriptDirectory()..'/FunLib/aba_minion' )
local sTalentList = J.Skill.GetTalentList( bot )
local sAbilityList = J.Skill.GetAbilityList( bot )
local sRole = J.Item.GetRoleItemsBuyList( bot )

-- Updated to 7.41f from D2PT: carry/support/hard support; other picks use carry.
local BuildData = require(GetScriptDirectory()..'/BotLib/Builds/gyrocopter')
X.buildMetadata = BuildData
X.neutralPreferences = BuildData.neutrals[sRole]
-- [1] Rocket Barrage, [2] Homing Missile, [3] Flak Cannon, [6] Call Down.
local isSupport = sRole == 'pos_4' or sRole == 'pos_5'
local nAbilityBuildList = isSupport and {1,2,1,2,1,6,1,2,2,3,6,3,3,3,6}
    or {3,2,3,2,3,6,3,2,2,1,6,1,1,1,6}
local nTalentBuildList = J.Skill.GetTalentBuild(isSupport and {
    t10={0,10}, -- +25% Homing Missile damage
    t15={0,10}, -- +0.3s Homing Missile stun
    t20={10,0}, -- +14 Rocket Barrage damage
    t25={10,0}, -- -40s Call Down cooldown
} or {
    t10={10,0}, -- +150 Health
    t15={10,0}, -- +25 Flak Cannon damage
    t20={0,10}, -- +3 Flak Cannon attacks
    t25={0,10}, -- -6s Flak Cannon cooldown
})
local defaultAbilityBuild, defaultTalentBuild = nAbilityBuildList, nTalentBuildList
if sRole == 'pos_4' then
    X.sBuyList = {'item_boots','item_ward_observer','item_ward_sentry','item_blood_grenade',
        'item_magic_wand','item_urn_of_shadows','item_tranquil_boots','item_essence_distiller',
        'item_aghanims_shard','item_glimmer_cape','item_blink','item_force_staff','item_cyclone',
        -- Bot policy: natural boot/Blink/Euls upgrades keep six persistent slots.
        'item_ancient_janggo','item_boots_of_bearing','item_overwhelming_blink','item_wind_waker'}
    -- Distiller consumes Urn; avoid buying the mutually exclusive Vessel path.
    X.sSellList = {'item_blink','item_magic_wand'}
elseif sRole == 'pos_5' then
    X.sBuyList = {'item_double_branches','item_magic_stick','item_tango','item_ward_observer',
        'item_ward_sentry','item_ward_sentry','item_blood_grenade','item_magic_wand','item_tranquil_boots',
        'item_aghanims_shard','item_glimmer_cape','item_force_staff','item_cyclone','item_blink',
        -- Bot policy: team mobility, cast range and natural upgrades; six persistent slots.
        'item_ancient_janggo','item_boots_of_bearing','item_aether_lens','item_overwhelming_blink','item_wind_waker'}
    X.sSellList = {'item_blink','item_magic_wand'}
else
    X.sBuyList = {'item_magic_wand','item_faerie_fire','item_faerie_fire','item_falcon_blade',
        'item_power_treads','item_lesser_crit','item_ultimate_scepter','item_lifesteal',
        'item_black_king_bar','item_greater_crit','item_satanic',
        -- Bot policy: consume Scepter before observed Blink/Butterfly, then upgrade Blink.
        'item_ultimate_scepter_2','item_blink','item_butterfly','item_swift_blink','item_moon_shard'}
    X.sSellList = {'item_black_king_bar','item_magic_wand','item_butterfly','item_falcon_blade'}
end

if J.Role.IsPvNMode() or J.Role.IsAllShadow() then X['sBuyList'], X['sSellList'] = { 'PvN_antimage' }, {} end

nAbilityBuildList, nTalentBuildList, X['sBuyList'], X['sSellList'] = J.SetUserHeroInit( nAbilityBuildList, nTalentBuildList, X['sBuyList'], X['sSellList'] )
X['sSkillList'] = J.Skill.GetSkillList( sAbilityList, nAbilityBuildList, sTalentList, nTalentBuildList )
-- D2PT: attributes at 10, talents at 11/15; preserve custom builds.
if nAbilityBuildList == defaultAbilityBuild and nTalentBuildList == defaultTalentBuild then
    table.insert(X.sSkillList,10,'special_bonus_attributes')
    X.sSkillList[12], X.sSkillList[13] = X.sSkillList[13], X.sSkillList[12]
    X.sSkillList[15], X.sSkillList[16] = X.sSkillList[16], X.sSkillList[15]
end
X['bDeafaultAbility'] = false
X['bDeafaultItem'] = false

function X.MinionThink(hMinionUnit)
    Minion.MinionThink(hMinionUnit)
end

local RocketBarrage = bot:GetAbilityByName('gyrocopter_rocket_barrage')
local HomingMissile = bot:GetAbilityByName('gyrocopter_homing_missile')
local FlakCannon    = bot:GetAbilityByName('gyrocopter_flak_cannon')
local CallDown      = bot:GetAbilityByName('gyrocopter_call_down')

local RocketBarrageDesire
local HomingMissileDesire, HomingMissileTarget
local FlakCannonDesire
local CallDownDesire, CallDownLocation

function X.SkillsComplement()
    if J.CanNotUseAbility( bot ) then return end

    HomingMissileDesire, HomingMissileTarget = X.ConsiderHomingMissile()
    if HomingMissileDesire > 0
    then
        J.SetQueuePtToINT(bot, false)
        bot:Action_UseAbilityOnEntity(HomingMissile, HomingMissileTarget)
        return
    end

    FlakCannonDesire = X.ConsiderFlakCannon()
    if FlakCannonDesire > 0
    then
        J.SetQueuePtToINT(bot, false)
        bot:Action_UseAbility(FlakCannon)
        return
    end

    CallDownDesire, CallDownLocation = X.ConsiderCallDown()
    if CallDownDesire > 0
    then
        bot:Action_UseAbilityOnLocation(CallDown, CallDownLocation)
        return
    end

    RocketBarrageDesire = X.ConsiderRocketBarrage()
    if RocketBarrageDesire > 0
    then
        J.SetQueuePtToINT(bot, false)
        bot:Action_UseAbility(RocketBarrage)
        return
    end
end

function X.ConsiderRocketBarrage()
    if not RocketBarrage:IsFullyCastable()
    then
        return BOT_ACTION_DESIRE_NONE
    end

	local nRadius = RocketBarrage:GetSpecialValueInt('radius')
    local nDamage = RocketBarrage:GetSpecialValueInt('rocket_damage')
    local nRocketsPerSecond = RocketBarrage:GetSpecialValueInt('rockets_per_second')
    local nDuration = 3
    local nAbilityLevel = RocketBarrage:GetLevel()
    local nMana = bot:GetMana() / bot:GetMaxMana()
    local botTarget = J.GetProperTarget(bot)

    local nEnemyHeroes = J.GetNearbyHeroes(bot,nRadius, true, BOT_MODE_NONE)
    for _, enemyHero in pairs(nEnemyHeroes)
    do
        local nCreeps = bot:GetNearbyCreeps(nRadius, true)

        if J.IsValidHero(enemyHero)
        and J.CanCastOnNonMagicImmune(enemyHero)
        and J.CanKillTarget(enemyHero, nDamage * nRocketsPerSecond * nDuration, DAMAGE_TYPE_MAGICAL)
        and not J.IsSuspiciousIllusion(enemyHero)
        and not enemyHero:HasModifier('modifier_abaddon_borrowed_time')
        and not enemyHero:HasModifier('modifier_dazzle_shallow_grave')
        and not enemyHero:HasModifier('modifier_oracle_false_promise_timer')
        and not enemyHero:HasModifier('modifier_templar_assassin_refraction_absorb')
        and nCreeps ~= nil and #nCreeps <= 1
        then
            bot:SetTarget(enemyHero)
            return BOT_ACTION_DESIRE_HIGH
        end
    end

    if J.IsInTeamFight(bot, 1200)
	then
		local nInRangeEnemy = J.GetNearbyHeroes(bot,nRadius - 75, true, BOT_MODE_NONE)

		if nInRangeEnemy ~= nil and #nInRangeEnemy >= 1
        then
			return BOT_ACTION_DESIRE_HIGH
		end
	end

	if J.IsGoingOnSomeone(bot)
	then
        local nCreeps = bot:GetNearbyCreeps(nRadius, true)
        local nInRangeAlly = J.GetNearbyHeroes(bot,nRadius + 150, false, BOT_MODE_NONE)
        local nInRangeEnemy = J.GetNearbyHeroes(bot,nRadius - 75, true, BOT_MODE_NONE)

		if J.IsValidTarget(botTarget)
        and J.CanCastOnNonMagicImmune(botTarget)
        and not J.IsSuspiciousIllusion(botTarget)
        and not botTarget:HasModifier('modifier_abaddon_borrowed_time')
        and not botTarget:HasModifier('modifier_dazzle_shallow_grave')
        and not botTarget:HasModifier('modifier_templar_assassin_refraction_absorb')
        and nInRangeAlly ~= nil and nInRangeEnemy
        and #nInRangeAlly >= #nInRangeEnemy
        and nCreeps ~= nil and #nCreeps <= 1
		then
            bot:SetTarget(botTarget)
			return BOT_ACTION_DESIRE_HIGH
		end
	end

	if J.IsRetreating(bot)
	then
		local nInRangeAlly = J.GetNearbyHeroes(bot,nRadius + 200, false, BOT_MODE_NONE)
        local nInRangeEnemy = J.GetNearbyHeroes(bot,nRadius - 25, true, BOT_MODE_NONE)

        if nInRangeAlly ~= nil and nInRangeEnemy
        and ((#nInRangeEnemy > #nInRangeAlly)
            or (J.GetHP(bot) < 0.7 and bot:WasRecentlyDamagedByAnyHero(2)))
        and J.IsValidHero(nInRangeEnemy[1])
        and J.CanCastOnNonMagicImmune(nInRangeEnemy[1])
        and J.IsInRange(bot, nInRangeEnemy[1], nRadius)
        and not J.IsSuspiciousIllusion(nInRangeEnemy[1])
		then
			return BOT_ACTION_DESIRE_HIGH
		end
	end

    if J.IsFarming(bot)
    and nMana > 0.5
    and nAbilityLevel >= 2
    then
        local nNeutralCreeps = bot:GetNearbyNeutralCreeps(nRadius)

        if nNeutralCreeps ~= nil and #nNeutralCreeps >= 2
        then
            return BOT_ACTION_DESIRE_HIGH
        end
    end

	if J.IsDoingRoshan(bot)
	then
		if J.IsRoshan(botTarget)
        and J.CanCastOnNonMagicImmune(botTarget)
        and J.IsInRange(bot, botTarget, nRadius)
        and J.IsAttacking(bot)
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

function X.ConsiderHomingMissile()
    if not HomingMissile:IsFullyCastable()
    then
        return BOT_ACTION_DESIRE_NONE, nil
    end

	local nCastRange = HomingMissile:GetCastRange()
    local nLaunchDelay = HomingMissile:GetSpecialValueFloat('pre_flight_time')
	local nDamage = HomingMissile:GetAbilityDamage()
    local nMana = bot:GetMana() / bot:GetMaxMana()
    local botTarget = J.GetProperTarget(bot)

    local nEnemyHeroes = J.GetNearbyHeroes(bot,nCastRange, true, BOT_MODE_NONE)
    for _, enemyHero in pairs(nEnemyHeroes)
    do
        if J.IsValidHero(enemyHero)
        and J.CanCastOnNonMagicImmune(enemyHero)
        and J.WillKillTarget(enemyHero, nDamage, DAMAGE_TYPE_MAGICAL, nLaunchDelay)
        and not J.IsSuspiciousIllusion(enemyHero)
        and not enemyHero:HasModifier('modifier_abaddon_borrowed_time')
        and not enemyHero:HasModifier('modifier_dazzle_shallow_grave')
        and not enemyHero:HasModifier('modifier_oracle_false_promise_timer')
        and not enemyHero:HasModifier('modifier_templar_assassin_refraction_absorb')
        then
            return BOT_ACTION_DESIRE_HIGH, enemyHero
        end
    end

	if J.IsInTeamFight(bot, 1200)
	then
        local strongestEnemy = J.GetStrongestUnit(nCastRange, bot, true, false, 5)

        if strongestEnemy ~= nil
        and J.IsValidHero(strongestEnemy)
        and J.IsInRange(bot, strongestEnemy, nCastRange)
        and not J.IsSuspiciousIllusion(strongestEnemy)
        and not J.IsDisabled(strongestEnemy)
        and not J.IsTaunted(strongestEnemy)
        and not strongestEnemy:HasModifier('modifier_faceless_void_chronosphere_freeze')
        and not strongestEnemy:HasModifier('modifier_enigma_black_hole_pull')
        then
            return BOT_ACTION_DESIRE_HIGH, strongestEnemy
        end
	end

	if J.IsGoingOnSomeone(bot)
	then
        local nInRangeAlly = J.GetNearbyHeroes(bot,nCastRange + 200, false, BOT_MODE_NONE)
        local nInRangeEnemy = J.GetNearbyHeroes(bot,nCastRange, true, BOT_MODE_NONE)

        if J.IsValidHero(botTarget)
        and J.CanCastOnNonMagicImmune(botTarget)
        and not J.IsSuspiciousIllusion(botTarget)
        and not J.IsDisabled(botTarget)
        and not J.IsTaunted(botTarget)
        and not botTarget:HasModifier('modifier_faceless_void_chronosphere_freeze')
        and not botTarget:HasModifier('modifier_enigma_black_hole_pull')
        and nInRangeAlly ~= nil and nInRangeEnemy ~= nil
        and #nInRangeAlly >= #nInRangeEnemy
        then
            return BOT_ACTION_DESIRE_HIGH, botTarget
        end
	end

	if J.IsRetreating(bot)
	then
		local nInRangeAlly = J.GetNearbyHeroes(bot,nCastRange + 200, false, BOT_MODE_NONE)
        local nInRangeEnemy = J.GetNearbyHeroes(bot,nCastRange, true, BOT_MODE_NONE)

        if nInRangeAlly ~= nil and nInRangeEnemy
        and ((#nInRangeEnemy > #nInRangeAlly)
            or (J.GetHP(bot) < 0.6 and bot:WasRecentlyDamagedByAnyHero(2)))
        and J.IsValidHero(nInRangeEnemy[1])
        and J.CanCastOnNonMagicImmune(nInRangeEnemy[1])
        and not J.IsSuspiciousIllusion(nInRangeEnemy[1])
        and not J.IsDisabled(nInRangeEnemy[1])
        and not J.IsTaunted(nInRangeEnemy[1])
		then
			return BOT_ACTION_DESIRE_HIGH, nInRangeEnemy[1]
		end
	end

    if J.IsLaning(bot)
    and nMana > 0.45
	then
		local nEnemyLaneCreeps = bot:GetNearbyLaneCreeps(nCastRange, true)

		for _, creep in pairs(nEnemyLaneCreeps)
		do
			if J.IsValid(creep)
			and (J.IsKeyWordUnit('ranged', creep) or J.IsKeyWordUnit('siege', creep))
			and creep:GetHealth() <= nDamage
			then
				local nInRangeEnemy = J.GetNearbyHeroes(bot,1600, true, BOT_MODE_NONE)

				if nInRangeEnemy ~= nil and #nInRangeEnemy >= 1
				and GetUnitToUnitDistance(creep, nInRangeEnemy[1]) <= 500
				then
					return BOT_ACTION_DESIRE_HIGH, creep
				end
			end
		end
	end

    local nAllyHeroes  = J.GetNearbyHeroes(bot,nCastRange, false, BOT_MODE_NONE)
    for _, allyHero in pairs(nAllyHeroes)
    do
        local nAllyInRangeEnemy = J.GetNearbyHeroes(allyHero, nCastRange, true, BOT_MODE_NONE)

        if J.IsValidHero(allyHero)
        and J.IsRetreating(allyHero)
        and not allyHero:IsIllusion()
        then
            if nAllyInRangeEnemy ~= nil and #nAllyInRangeEnemy >= 1
            and J.IsValidHero(nAllyInRangeEnemy[1])
            and J.CanCastOnNonMagicImmune(nAllyInRangeEnemy[1])
            and J.IsInRange(bot, nAllyInRangeEnemy[1], nCastRange)
            and not J.IsSuspiciousIllusion(nAllyInRangeEnemy[1])
            and not J.IsDisabled(nAllyInRangeEnemy[1])
            and not J.IsTaunted(nAllyInRangeEnemy[1])
            and nMana > 0.4
            then
                return BOT_ACTION_DESIRE_HIGH, nAllyInRangeEnemy[1]
            end
        end
    end

    return BOT_ACTION_DESIRE_NONE, nil
end

function X.ConsiderFlakCannon()
    if not FlakCannon:IsFullyCastable()
    then
        return BOT_ACTION_DESIRE_NONE
    end

	local nRadius = FlakCannon:GetSpecialValueInt('radius')
    local nMana = bot:GetMana() / bot:GetMaxMana()
    local nAbilityLevel = FlakCannon:GetLevel()
    local botTarget = J.GetProperTarget(bot)
    local nEnemyHeroes = J.GetNearbyHeroes(bot,nRadius, true, BOT_MODE_NONE)

	if J.IsInTeamFight(bot, 1200)
	then
		if nEnemyHeroes ~= nil and #nEnemyHeroes >= 2
        then
			return BOT_ACTION_DESIRE_HIGH
		end
	end

    if J.IsGoingOnSomeone(bot)
	then
        local nInRangeAlly = J.GetNearbyHeroes(bot,nRadius + 100, false, BOT_MODE_NONE)
        local nInRangeEnemy = J.GetNearbyHeroes(bot,nRadius, true, BOT_MODE_NONE)

		if J.IsValidTarget(botTarget)
        and J.CanCastOnNonMagicImmune(botTarget)
        and not J.IsSuspiciousIllusion(botTarget)
        and not botTarget:HasModifier('modifier_abaddon_borrowed_time')
        and not botTarget:HasModifier('modifier_dazzle_shallow_grave')
        and not botTarget:HasModifier('modifier_templar_assassin_refraction_absorb')
        and nInRangeAlly ~= nil and nInRangeEnemy
        and #nInRangeAlly >= #nInRangeEnemy
		then
            if #nInRangeEnemy == 1
            then
                return BOT_ACTION_DESIRE_LOW
            else
                return BOT_ACTION_DESIRE_HIGH
            end
		end
	end

    if (J.IsPushing(bot) or J.IsDefending(bot))
    and nAbilityLevel >= 2
    then
        local nEnemyLaneCreeps = bot:GetNearbyLaneCreeps(nRadius, true)

        if nEnemyLaneCreeps ~= nil and #nEnemyLaneCreeps >= 4
        then
            return BOT_ACTION_DESIRE_HIGH
        end
    end

    if J.IsFarming(bot)
    and nAbilityLevel >= 2
    and nMana > 0.35
    then
        local nNeutralCreeps = bot:GetNearbyNeutralCreeps(nRadius)
        nEnemyHeroes = J.GetNearbyHeroes(bot,600, true, BOT_MODE_NONE)

        if nNeutralCreeps ~= nil
        and (#nNeutralCreeps >= 3
            or (#nNeutralCreeps >= 2 and nNeutralCreeps[1]:IsAncientCreep()))
        and nEnemyHeroes ~= nil and #nEnemyHeroes == 0
        then
            return BOT_ACTION_DESIRE_HIGH
        end
    end

    return BOT_ACTION_DESIRE_NONE
end

function X.ConsiderCallDown()
    if not CallDown:IsFullyCastable()
    then
        return BOT_ACTION_DESIRE_NONE, 0
    end

	local nCastRange = CallDown:GetCastRange()
	local nCastPoint = CallDown:GetCastPoint()
	local nRadius = CallDown:GetSpecialValueInt('radius')
    local nDamage = CallDown:GetSpecialValueInt('damage')

	if J.IsInTeamFight(bot, 1200)
	then
		local nLocationAoE = bot:FindAoELocation(true, true, bot:GetLocation(), nCastRange, nRadius / 2, nCastPoint, 0)

		if nLocationAoE.count >= 2
		then
            local realEnemyCount = J.GetEnemiesNearLoc(nLocationAoE.targetloc, nRadius)

            if realEnemyCount ~= nil and #realEnemyCount >= 2
            then
                return BOT_ACTION_DESIRE_HIGH, nLocationAoE.targetloc
            end
		end
	end

    local nEnemyHeroes = J.GetNearbyHeroes(bot,nCastRange, true, BOT_MODE_NONE)
    for _, enemyHero in pairs(nEnemyHeroes)
    do
        local nInRangeAlly = J.GetNearbyHeroes(bot,nCastRange + 200, false, BOT_MODE_NONE)

        if J.IsValidHero(enemyHero)
        and J.CanCastOnNonMagicImmune(enemyHero)
        and J.IsInRange(bot, enemyHero, nCastRange)
        and J.CanKillTarget(enemyHero, nDamage, DAMAGE_TYPE_MAGICAL)
        and not J.IsSuspiciousIllusion(enemyHero)
        and not enemyHero:HasModifier('modifier_abaddon_borrowed_time')
        and not enemyHero:HasModifier('modifier_dazzle_shallow_grave')
        and not enemyHero:HasModifier('modifier_oracle_false_promise_timer')
        and not enemyHero:HasModifier('modifier_templar_assassin_refraction_absorb')
        and nInRangeAlly ~= nil and nEnemyHeroes ~= nil
        and #nInRangeAlly <= 2 and #nEnemyHeroes <= 2
        then
            return BOT_ACTION_DESIRE_HIGH, enemyHero:GetExtrapolatedLocation(1 + nCastPoint)
        end
    end

    return BOT_ACTION_DESIRE_NONE, 0
end

return X