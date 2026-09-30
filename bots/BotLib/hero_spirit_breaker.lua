local X             = {}
local bot           = GetBot()

local J             = require( GetScriptDirectory()..'/FunLib/jmz_func' )
local Minion        = dofile( GetScriptDirectory()..'/FunLib/aba_minion' )
local sTalentList   = J.Skill.GetTalentList( bot )
local sAbilityList  = J.Skill.GetAbilityList( bot )
local sRole   = J.Item.GetRoleItemsBuyList( bot )

-- D2PT 7.41f: offlane/supports; forced carry/mid use support without wards.
local BuildData = require(GetScriptDirectory()..'/BotLib/Builds/spirit_breaker')
X.buildMetadata = BuildData
X.neutralPreferences = BuildData.neutrals[sRole]
local offlane = sRole == 'pos_3'
local hardSupport = sRole == 'pos_5'
-- [1] Charge, [2] Bulldoze, [3] Greater Bash, [6] Nether Strike.
local nAbilityBuildList = offlane and {3,1,3,1,3,6,3,1,1,2,6,2,2,2,6}
    or {3,1,3,2,3,6,3,1,1,1,6,2,2,2,6}
local nTalentBuildList = J.Skill.GetTalentBuild({
    t10={0,10}, -- Night vision
    t15={10,0}, -- Charge speed
    t20=(offlane or hardSupport) and {0,10} or {10,0}, -- Haste / Bulldoze barrier
    t25=offlane and {0,10} or {10,0}, -- Bash damage / Charge cooldown
})
local defaultAbilityBuild, defaultTalentBuild = nAbilityBuildList, nTalentBuildList
X.sBuyList = offlane and {
    'item_quelling_blade','item_gauntlets','item_double_branches','item_circlet','item_tango',
    'item_bracer','item_magic_wand','item_phase_boots','item_invis_sword','item_yasha',
    'item_yasha_and_kaya','item_ultimate_scepter','item_cyclone','item_octarine_core',
    -- Bot policy: consumed Scepter, charge protection and natural upgrades.
    'item_ultimate_scepter_2','item_black_king_bar','item_wind_waker','item_silver_edge','item_aghanims_shard',
} or {
    'item_boots','item_blood_grenade','item_phase_boots','item_magic_wand','item_invis_sword','item_yasha',
}
if not offlane then
    if sRole == 'pos_4' then
        -- Bot policy: dispenser ward types are unresolved; buy a Sentry.
        table.insert(X.sBuyList,2,'item_ward_sentry')
    end
    if hardSupport then
        table.insert(X.sBuyList,2,'item_ward_sentry')
        for _, item in ipairs({'item_aghanims_shard','item_yasha_and_kaya','item_ultimate_scepter'}) do table.insert(X.sBuyList,item) end
    else
        table.insert(X.sBuyList,'item_ultimate_scepter')
        -- Bot policy: complete the observed Yasha into a movement/casting upgrade.
        table.insert(X.sBuyList,'item_yasha_and_kaya')
    end
    -- Bot policy: consumed Scepter, cooldown/escape utility and natural upgrades.
    for _, item in ipairs({'item_ultimate_scepter_2','item_octarine_core','item_cyclone',
        'item_black_king_bar','item_wind_waker','item_silver_edge'}) do table.insert(X.sBuyList,item) end
    if not hardSupport then table.insert(X.sBuyList,'item_aghanims_shard') end
end
X.sSellList = {'item_ultimate_scepter','item_magic_wand'}
if offlane then
    table.insert(X.sSellList,'item_invis_sword'); table.insert(X.sSellList,'item_quelling_blade')
    table.insert(X.sSellList,'item_yasha_and_kaya'); table.insert(X.sSellList,'item_bracer')
end

if J.Role.IsPvNMode() or J.Role.IsAllShadow() then X.sBuyList, X.sSellList = {'PvN_antimage'}, {} end
nAbilityBuildList, nTalentBuildList, X.sBuyList, X.sSellList = J.SetUserHeroInit(nAbilityBuildList, nTalentBuildList, X.sBuyList, X.sSellList)
X.sSkillList = J.Skill.GetSkillList(sAbilityList, nAbilityBuildList, sTalentList, nTalentBuildList)
-- Observed ability at 10, first talent at 11; preserve custom overrides.
if nAbilityBuildList == defaultAbilityBuild and nTalentBuildList == defaultTalentBuild then
    X.sSkillList[10], X.sSkillList[11] = X.sSkillList[11], X.sSkillList[10]
end

X['bDeafaultAbility'] = false
X['bDeafaultItem'] = false

function X.MinionThink(hMinionUnit)
	Minion.MinionThink(hMinionUnit)
end

local ChargeOfDarkness  = bot:GetAbilityByName('spirit_breaker_charge_of_darkness')
local Bulldoze          = bot:GetAbilityByName('spirit_breaker_bulldoze')
local GreaterBash       = bot:GetAbilityByName('spirit_breaker_greater_bash')
local PlanarPocket      = bot:GetAbilityByName('spirit_breaker_planar_pocket')
local NetherStrike      = bot:GetAbilityByName('spirit_breaker_nether_strike')

local ChargeOfDarknessDesire, ChargeOfDarknessTarget
local BulldozeDesire
local PlanarPocketDesire
local NetherStrikeDesire, NetherStrikeTarget
local nInRangeEnemy

if bot.chargeRetreat == nil then bot.chargeRetreat = false end

function X.SkillsComplement()
	if J.CanNotUseAbility(bot) then return end

    nInRangeEnemy = J.GetNearbyHeroes(bot, 1600, true, BOT_MODE_NONE)

    if bot:HasModifier('modifier_spirit_breaker_charge_of_darkness') or ChargeOfDarkness:IsInAbilityPhase() then
        if bot.chargeRetreat and #nInRangeEnemy == 0
        then
            bot:Action_MoveToLocation(bot:GetLocation() + RandomVector(150))
            bot.chargeRetreat = false
        end

        return
    end

    ChargeOfDarknessDesire, ChargeOfDarknessTarget = X.ConsiderChargeOfDarkness()
    if ChargeOfDarknessDesire > 0
    then
        if ChargeOfDarkness:GetLevel() >= 3
        and Bulldoze:IsTrained()
        and Bulldoze:IsFullyCastable()
        then
            bot:Action_UseAbility(Bulldoze)
        end

        bot:Action_UseAbilityOnEntity(ChargeOfDarkness, ChargeOfDarknessTarget)
        return
    end

    BulldozeDesire = X.ConsiderBulldoze()
    if BulldozeDesire > 0
    then
        bot:Action_UseAbility(Bulldoze)
        return
    end

    PlanarPocketDesire = X.ConsiderPlanarPocket()
    if PlanarPocketDesire > 0
    then
        bot:Action_UseAbilityOnEntity(PlanarPocket, bot)
        return
    end

    NetherStrikeDesire, NetherStrikeTarget = X.ConsiderNetherStrike()
    if NetherStrikeDesire > 0
    then
        bot:Action_UseAbilityOnEntity(NetherStrike, NetherStrikeTarget)
        return
    end
end

function X.ConsiderChargeOfDarkness()
    if not ChargeOfDarkness:IsFullyCastable()
    or bot:HasModifier('modifier_spirit_breaker_charge_of_darkness')
    then
        return BOT_ACTION_DESIRE_NONE, nil
    end

    if not J.IsRetreating(bot) then
        bot.chargeRetreat = false
    end

    local nRadius = ChargeOfDarkness:GetSpecialValueInt('bash_radius')
    local botTarget = J.GetProperTarget(bot)

    for _, enemyHero in pairs(nInRangeEnemy)
    do
        if J.IsValidHero(enemyHero)
        and J.CanCastOnNonMagicImmune(enemyHero)
        and not J.IsSuspiciousIllusion(enemyHero)
        and not J.IsLocationInChrono(enemyHero:GetLocation())
        then
            local nInRangeAlly = J.GetNearbyHeroes(enemyHero, 1600, true, BOT_MODE_NONE)

            if nInRangeAlly ~= nil and nInRangeEnemy
            and #nInRangeAlly >= #nInRangeEnemy
            then
                if enemyHero:IsChanneling()
                then
                    return BOT_ACTION_DESIRE_HIGH, enemyHero
                end
            end
        end
    end

    local nTeamFightLocation = J.GetTeamFightLocation(bot)
    if nTeamFightLocation ~= nil
    and GetUnitToLocationDistance(bot, nTeamFightLocation) > 1600
    and not J.IsInLaningPhase()
    then
        if nInRangeEnemy ~= nil and #nInRangeEnemy >= 1
        and not J.IsLocationInChrono(nTeamFightLocation)
        then
            return BOT_ACTION_DESIRE_HIGH, nInRangeEnemy[1]
        end
    end

	if J.IsGoingOnSomeone(bot)
	then
        local target = nil
        local dmg = 0

        for _, enemyHero in pairs(nInRangeEnemy)
        do
            if J.IsValidHero(enemyHero)
            and J.CanCastOnNonMagicImmune(enemyHero)
            and J.CanCastOnTargetAdvanced(enemyHero)
            and not J.IsSuspiciousIllusion(enemyHero)
            and not J.IsDisabled(enemyHero)
            and not J.IsLocationInChrono(enemyHero:GetLocation())
            and not enemyHero:HasModifier('modifier_legion_commander_duel')
            and not enemyHero:HasModifier('modifier_necrolyte_reapers_scythe')
            then
                local nInRangeAlly = J.GetNearbyHeroes(enemyHero, 1200, true, BOT_MODE_NONE)
                local nTargetInRangeAlly = J.GetNearbyHeroes(enemyHero, 1200, false, BOT_MODE_NONE)
                local currDmg = enemyHero:GetEstimatedDamageToTarget(true, bot, 5, DAMAGE_TYPE_ALL)

                if nInRangeAlly ~= nil and nTargetInRangeAlly
                and #nInRangeAlly >= #nTargetInRangeAlly
                and currDmg > dmg
                then
                    dmg = currDmg
                    target = enemyHero
                end
            end
        end

        if target ~= nil
        then
            return BOT_ACTION_DESIRE_HIGH, target
        end
	end

	if J.IsRetreating(bot)
    and J.GetHP(bot) < 0.5
    and J.IsValidHero(nInRangeEnemy[1])
    and J.IsInRange(bot, nInRangeEnemy[1], 500)
	then
		for _, creep in pairs(GetUnitList(UNIT_LIST_ENEMY_CREEPS))
		do
			if J.IsValid(creep)
            and GetUnitToUnitDistance(creep, bot) > 1600
            then
                bot.chargeRetreat = true
                return BOT_ACTION_DESIRE_HIGH, creep
			end
		end

        for _, creep in pairs(GetUnitList(UNIT_LIST_NEUTRAL_CREEPS))
		do
			if J.IsValid(creep)
            and GetUnitToUnitDistance(creep, bot) > 1600
            then
                bot.chargeRetreat = true
                return BOT_ACTION_DESIRE_HIGH, creep
			end
		end
	end

    if J.IsPushing(bot)
    then
        local nLocationAoE = bot:FindAoELocation(true, false, bot:GetLocation(), bot:GetCurrentVisionRange(), nRadius, 0, 0)
        local nEnemyLaneCreeps = bot:GetNearbyLaneCreeps(nRadius, true)

        if nEnemyLaneCreeps ~= nil and #nEnemyLaneCreeps >= 4
        and nLocationAoE.count >= 4
        then
            return BOT_ACTION_DESIRE_HIGH, nEnemyLaneCreeps[4]
        end
    end

    if J.IsFarming(bot)
    then
        local nLocationAoE = bot:FindAoELocation(true, false, bot:GetLocation(), bot:GetCurrentVisionRange(), nRadius, 0, 0)

        if J.IsAttacking(bot)
        and J.GetMP(bot) > 0.25
        then
            local nNeutralCreeps = bot:GetNearbyNeutralCreeps(nRadius)
            if nNeutralCreeps ~= nil
            and ((#nNeutralCreeps >= 3 and nLocationAoE.count >= 3)
                or (#nNeutralCreeps >= 2 and nNeutralCreeps[1]:IsAncientCreep() and nLocationAoE.count >= 2))
            then
                if J.CanBeAttacked(nNeutralCreeps[1])
                then
                    return BOT_ACTION_DESIRE_HIGH, nNeutralCreeps[2]
                end
            end

            local nEnemyLaneCreeps = bot:GetNearbyLaneCreeps(nRadius, true)
            if nEnemyLaneCreeps ~= nil and #nEnemyLaneCreeps >= 3
            and nLocationAoE.count >= 3
            then
                if J.CanBeAttacked(nEnemyLaneCreeps[1])
                then
                    return BOT_ACTION_DESIRE_HIGH, nNeutralCreeps[3]
                end
            end
        end
    end

    if J.IsLaning(bot)
	then
        local canKill = 0
        local creepList = {}
		local nEnemyLaneCreeps = bot:GetNearbyLaneCreeps(1000, true)

		for _, creep in pairs(nEnemyLaneCreeps)
		do
            if J.IsValid(creep)
            and J.GetHP(creep) <= 0.33
            then
                local nEnemyTowers = creep:GetNearbyTowers(700, false)

                if nEnemyTowers ~= nil and #nEnemyTowers == 0
                then
                    canKill = canKill + 1
                    table.insert(creepList, creep)
                end
            end
		end

        if canKill >= 2
        and J.GetMP(bot) > 0.25
        and J.CanBeAttacked(creepList[1])
        and nInRangeEnemy ~= nil and #nInRangeEnemy == 0
        and GreaterBash:IsTrained() and GreaterBash:GetLevel() >= 2
        then
            return BOT_ACTION_DESIRE_HIGH, creepList[2]
        end
	end

    if J.IsDoingRoshan(bot)
    then
        if J.IsRoshan(botTarget)
        and J.IsInRange(bot, botTarget, 500)
        and J.IsAttacking(bot)
        then
            return BOT_ACTION_DESIRE_HIGH, botTarget
        end
    end

    if J.IsDoingTormentor(bot)
    then
        if J.IsTormentor(botTarget)
        and J.IsInRange(bot, botTarget, 500)
        and J.IsAttacking(bot)
        then
            return BOT_ACTION_DESIRE_HIGH, botTarget
        end
    end

    for _, allyHero in pairs(GetUnitList(UNIT_LIST_ALLIED_HEROES))
    do
        if J.IsValidHero(allyHero)
        and J.IsGoingOnSomeone(allyHero)
        and not J.IsMeepoClone(allyHero)
        and not allyHero:IsIllusion()
        and not allyHero:HasModifier('modifier_arc_warden_tempest_double')
        then
            local allyTarget = allyHero:GetAttackTarget()
            if J.IsValidTarget(allyTarget)
            and J.CanCastOnNonMagicImmune(allyTarget)
            and not J.IsSuspiciousIllusion(allyTarget)
            and not J.IsLocationInChrono(allyTarget:GetLocation())
            then
                local distance = GetUnitToUnitDistance(bot, allyTarget)
                if (J.IsChasingTarget(allyHero, allyTarget) or J.IsAttacking(allyHero))
                and distance > 600
                and distance < 1900
                then
                    return BOT_ACTION_DESIRE_HIGH, botTarget
                end
            end
        end
    end

    return BOT_ACTION_DESIRE_NONE, nil
end

function X.ConsiderBulldoze()
    if not Bulldoze:IsFullyCastable()
    then
        return BOT_ACTION_DESIRE_NONE
    end

    local botTarget = J.GetProperTarget(bot)

    if bot:HasModifier('modifier_spirit_breaker_charge_of_darkness')
    then
        return BOT_ACTION_DESIRE_HIGH
    end

    if J.IsGoingOnSomeone(bot)
	then
		if J.IsValidTarget(botTarget)
        and J.CanCastOnNonMagicImmune(botTarget)
        and J.IsInRange(bot, botTarget, 600)
        and bot:WasRecentlyDamagedByAnyHero(1)
        and not J.IsSuspiciousIllusion(botTarget)
        and not J.IsDisabled(botTarget)
		then
            return BOT_ACTION_DESIRE_HIGH
		end
	end

    if J.IsRetreating(bot)
	then
        if J.IsValidHero(nInRangeEnemy[1])
        and J.IsInRange(bot, nInRangeEnemy[1], 600)
        and J.IsChasingTarget(nInRangeEnemy[1], bot)
        and not J.IsSuspiciousIllusion(nInRangeEnemy[1])
        and not J.IsDisabled(nInRangeEnemy[1])
        then
            return BOT_ACTION_DESIRE_HIGH
        end
    end

    return BOT_ACTION_DESIRE_NONE
end

function X.ConsiderNetherStrike()
    if not NetherStrike:IsFullyCastable()
    or bot:HasModifier('modifier_spirit_breaker_charge_of_darkness')
    then
        return BOT_ACTION_DESIRE_NONE, nil
    end

    local nCastRange = NetherStrike:GetCastRange()
	local nDamage = NetherStrike:GetAbilityDamage()

    for _, enemyHero in pairs(nInRangeEnemy)
    do
        if J.IsValidHero(enemyHero)
        and J.IsInRange(bot, enemyHero, nCastRange)
        and J.CanCastOnNonMagicImmune(enemyHero)
        and not J.IsSuspiciousIllusion(enemyHero)
        and not J.IsLocationInChrono(enemyHero:GetLocation())
        then
            if enemyHero:IsChanneling()
            then
                return BOT_ACTION_DESIRE_HIGH, enemyHero
            end

            if J.CanKillTarget(enemyHero, nDamage, DAMAGE_TYPE_MAGICAL)
            and not J.IsSuspiciousIllusion(enemyHero)
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

	if J.IsGoingOnSomeone(bot)
	then
        local target = nil
        local dmg = 0

        for _, enemyHero in pairs(nInRangeEnemy)
        do
            if J.IsValidHero(enemyHero)
            and J.IsInRange(bot, enemyHero, nCastRange)
            and J.CanCastOnMagicImmune(enemyHero)
            and not J.IsSuspiciousIllusion(enemyHero)
            and not J.IsDisabled(enemyHero)
            and not J.IsLocationInChrono(enemyHero:GetLocation())
            and not enemyHero:HasModifier('modifier_legion_commander_duel')
            and not enemyHero:HasModifier('modifier_necrolyte_reapers_scythe')
            then
                local nInRangeAlly = J.GetNearbyHeroes(enemyHero, 1200, true, BOT_MODE_NONE)
                local nTargetInRangeAlly = J.GetNearbyHeroes(enemyHero, 1200, false, BOT_MODE_NONE)
                local currDmg = enemyHero:GetEstimatedDamageToTarget(true, bot, 5, DAMAGE_TYPE_ALL)

                if nInRangeAlly ~= nil and nTargetInRangeAlly
                and #nInRangeAlly >= #nTargetInRangeAlly
                and currDmg > dmg
                then
                    dmg = currDmg
                    target = enemyHero
                end
            end
        end

        if target ~= nil
        then
            return BOT_ACTION_DESIRE_HIGH, target
        end
	end

    return BOT_ACTION_DESIRE_NONE, nil
end

function X.ConsiderPlanarPocket()
    if not PlanarPocket:IsTrained()
    or not PlanarPocket:IsFullyCastable()
    or bot:HasModifier('modifier_spirit_breaker_charge_of_darkness')
    then
        return BOT_ACTION_DESIRE_NONE
    end

    local nRadius = PlanarPocket:GetSpecialValueInt('radius')
    local botTarget = J.GetProperTarget(bot)

    if J.IsInTeamFight(bot, 1200)
	then
        local nInRangeEnemy = J.GetEnemiesNearLoc(bot:GetLocation(), nRadius)

		if nInRangeEnemy ~= nil and #nInRangeEnemy >= 2
        and bot:WasRecentlyDamagedByAnyHero(1)
		then
			return BOT_ACTION_DESIRE_HIGH
		end
	end

    if J.IsGoingOnSomeone(bot)
	then
		if J.IsValidTarget(botTarget)
        and J.CanCastOnNonMagicImmune(botTarget)
        and J.IsInRange(bot, botTarget, 600)
        and bot:WasRecentlyDamagedByAnyHero(1)
        and not J.IsChasingTarget(bot, botTarget)
        and not J.IsSuspiciousIllusion(botTarget)
        and not J.IsDisabled(botTarget)
		then
            return BOT_ACTION_DESIRE_HIGH
		end
	end

    if J.IsRetreating(bot)
	then
        local nInRangeAlly = J.GetNearbyHeroes(bot,1200, false, BOT_MODE_NONE)

        if nInRangeAlly ~= nil and nInRangeEnemy ~= nil
        and J.IsValidHero(nInRangeEnemy[1])
        and J.IsInRange(bot, nInRangeEnemy[1], 600)
        and J.IsChasingTarget(nInRangeEnemy[1], bot)
        and not J.IsSuspiciousIllusion(nInRangeEnemy[1])
        and not J.IsDisabled(nInRangeEnemy[1])
        then
            local nTargetInRangeAlly = J.GetNearbyHeroes(nInRangeEnemy[1], 1200, false, BOT_MODE_NONE)

            if nTargetInRangeAlly ~= nil
            and ((#nTargetInRangeAlly > #nInRangeAlly)
                or (bot:WasRecentlyDamagedByAnyHero(1)))
            then
		        return BOT_ACTION_DESIRE_HIGH
            end
        end
    end

    return BOT_ACTION_DESIRE_NONE
end

return X