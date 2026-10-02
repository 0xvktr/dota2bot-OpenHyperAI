local X = {}
local bot = GetBot()

local J = require( GetScriptDirectory()..'/FunLib/jmz_func' )
local SpellDecisions = require(GetScriptDirectory()..'/FunLib/rubick_hero/magnataur')
local Minion = dofile( GetScriptDirectory()..'/FunLib/aba_minion' )
local sTalentList = J.Skill.GetTalentList( bot )
local sAbilityList = J.Skill.GetAbilityList( bot )
local sRole = J.Item.GetRoleItemsBuyList( bot )

-- Updated to 7.41f from D2PT: offlane and mid; forced other roles use offlane.
local BuildData = require(GetScriptDirectory()..'/BotLib/Builds/magnataur')
X.buildMetadata = BuildData
X.neutralPreferences = BuildData.neutrals[sRole]
-- [1] Shockwave, [2] Empower, [3] Skewer, [6] Reverse Polarity.
local nAbilityBuildList = {1,3,1,3,1,6,1,3,3,2,6,2,2,2,6}
local nTalentBuildList = J.Skill.GetTalentBuild({
    t10={10,0}, -- +1.25s Skewer slow duration
    t15=sRole=='pos_2' and {0,10} or {10,0}, -- RP attributes / -5s Skewer cooldown
    t20={0,10}, -- +125 Shockwave damage
    t25={10,0}, -- +0.8s Reverse Polarity duration
})
local defaultAbilityBuild, defaultTalentBuild = nAbilityBuildList, nTalentBuildList
local opening = sRole=='pos_2'
    and {'item_double_branches','item_double_branches','item_tango','item_faerie_fire','item_bottle'}
    or {'item_double_branches','item_branches','item_double_circlet','item_tango','item_double_bracer'}
X.sBuyList = opening
for _,item in ipairs({
    'item_magic_wand','item_power_treads','item_blink','item_echo_sabre','item_harpoon',
    'item_black_king_bar','item_ultimate_scepter','item_aghanims_shard',
    -- Bot policy: consume Scepter, then add cooldown and initiation upgrades.
    'item_ultimate_scepter_2','item_refresher','item_shivas_guard','item_overwhelming_blink','item_moon_shard',
}) do table.insert(X.sBuyList,item) end
X.sSellList = {
    'item_blink','item_bracer','item_harpoon','item_bracer',
    'item_black_king_bar','item_magic_wand','item_echo_sabre','item_bottle',
}

if J.Role.IsPvNMode() or J.Role.IsAllShadow() then X['sBuyList'], X['sSellList'] = { 'PvN_mid' }, {} end

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

local Shockwave         = bot:GetAbilityByName('magnataur_shockwave')
local Empower           = bot:GetAbilityByName('magnataur_empower')
local Skewer            = bot:GetAbilityByName('magnataur_skewer')
local HornToss          = bot:GetAbilityByName('magnataur_horn_toss')
local ReversePolarity   = bot:GetAbilityByName('magnataur_reverse_polarity')

local ShockwaveDesire, ShockwaveLocation
local EmpowerDesire, EmpowerTarget
local SkewerDesire, SkewerLocation
local HornTossDesire
local ReversePolarityDesire

local Blink
local BlinkLocation

local BlinkRPDesire

local BlinkSkewerDesire
local BlinkRPSkewerDesire

if bot.shouldBlink == nil then bot.shouldBlink = false end

function X.SkillsComplement()
    if J.CanNotUseAbility(bot) then return end
    if SpellDecisions.RPUseful(ReversePolarity, true) then
        J.SetQueuePtToINT(bot, true, ReversePolarity)
        bot:ActionQueue_UseAbility(ReversePolarity)
        return
    end

    BlinkRPSkewerDesire = X.ConsiderBlinkRPSkewer()
    if BlinkRPSkewerDesire > 0
    then
        bot:Action_ClearActions(false)

        if CanBKB()
        then
            bot:ActionQueue_UseAbility(BlackKingBar)
        end

        bot:ActionQueue_UseAbilityOnLocation(Blink, BlinkLocation)
        bot:ActionQueue_Delay(0.1)
        bot:ActionQueue_UseAbility(ReversePolarity)
        bot:ActionQueue_Delay(0.3)

        SkewerLocation = SpellDecisions.SkewerFrom(Skewer, BlinkLocation)
        SkewerDesire = SkewerLocation ~= nil and BOT_ACTION_DESIRE_HIGH or BOT_ACTION_DESIRE_NONE
        if SkewerDesire > 0
        then
            bot:ActionQueue_UseAbilityOnLocation(Skewer, SkewerLocation)
        end

        return
    end

    BlinkSkewerDesire = X.ConsiderBlinkForSkewer()
    if BlinkSkewerDesire > 0
    then
        bot:Action_ClearActions(false)

        if CanBKB()
        then
            bot:ActionQueue_UseAbility(BlackKingBar)
        end

        bot:ActionQueue_UseAbilityOnLocation(Blink, BlinkLocation)
        bot:ActionQueue_Delay(0.1)

        SkewerLocation = SpellDecisions.SkewerFrom(Skewer, BlinkLocation)
        SkewerDesire = SkewerLocation ~= nil and BOT_ACTION_DESIRE_HIGH or BOT_ACTION_DESIRE_NONE
        if SkewerDesire > 0
        then
            bot:ActionQueue_UseAbilityOnLocation(Skewer, SkewerLocation)
        end

        return
    end

    BlinkRPDesire = X.ConsiderBlinkRP()
    if BlinkRPDesire > 0
    then
        bot:Action_ClearActions(false)

        if CanBKB()
        then
            bot:ActionQueue_UseAbility(BlackKingBar)
        end

        bot:ActionQueue_UseAbilityOnLocation(Blink, BlinkLocation)
        bot:ActionQueue_Delay(0.1)
        bot:ActionQueue_UseAbility(ReversePolarity)
        return
    end

    ReversePolarityDesire = X.ConsiderReversePolarity()
    if ReversePolarityDesire > 0
    then
        bot:Action_UseAbility(ReversePolarity)
        return
    end

    HornTossDesire = X.ConsiderHornToss()
    if HornTossDesire > 0
    then
        bot:Action_UseAbility(HornToss)
        return
    end

    SkewerDesire, SkewerLocation = X.ConsiderSkewer()
    if SkewerDesire > 0
    then
        bot:Action_UseAbilityOnLocation(Skewer, SkewerLocation)
        return
    end

    ShockwaveDesire, ShockwaveLocation = X.ConsiderShockwave()
    if ShockwaveDesire > 0
    then
        if GetUnitToLocationDistance(bot, ShockwaveLocation) > SpellDecisions.Range(Shockwave) then return end
        J.SetQueuePtToINT(bot, true, Shockwave)
        bot:ActionQueue_UseAbilityOnLocation(Shockwave, ShockwaveLocation)
        return
    end

    EmpowerDesire, EmpowerTarget = X.ConsiderEmpower()
    if EmpowerDesire > 0
    then
        bot:Action_UseAbilityOnEntity(Empower, EmpowerTarget)
        return
    end
end

function X.ConsiderShockwave()
    if not Shockwave:IsFullyCastable()
    then
        return BOT_ACTION_DESIRE_NONE, 0
    end

	local nCastRange = SpellDecisions.Range(Shockwave)
	local nCastPoint = Shockwave:GetCastPoint()
    local nRadius = Shockwave:GetSpecialValueInt('shock_width')
	local nDamage = Shockwave:GetSpecialValueInt('shock_damage')
	local nSpeed = Shockwave:GetSpecialValueInt('shock_speed')
    local nMana = bot:GetMana() / bot:GetMaxMana()
    local botTarget = J.GetProperTarget(bot)

    local nEnemyHeroes = J.GetNearbyHeroes(bot,nCastRange, true, BOT_MODE_NONE)
    for _, enemyHero in pairs(nEnemyHeroes)
    do
        if J.IsValidHero(enemyHero)
        and J.CanCastOnNonMagicImmune(enemyHero)
        and J.IsInRange(bot, enemyHero, nCastRange)
        and J.CanKillTarget(enemyHero, nDamage, DAMAGE_TYPE_MAGICAL)
        and not J.IsSuspiciousIllusion(enemyHero)
        and not enemyHero:HasModifier('modifier_abaddon_borrowed_time')
        and not enemyHero:HasModifier('modifier_dazzle_shallow_grave')
        and not enemyHero:HasModifier('modifier_oracle_false_promise_timer')
        and not enemyHero:HasModifier('modifier_templar_assassin_refraction_absorb')
        then
            local nDelay = (GetUnitToUnitDistance(bot, enemyHero) / nSpeed) + nCastPoint
            return BOT_ACTION_DESIRE_HIGH, enemyHero:GetExtrapolatedLocation(nDelay)
        end
    end

	if J.IsGoingOnSomeone(bot)
	then
        local nInRangeAlly = J.GetNearbyHeroes(bot,1000, false, BOT_MODE_NONE)
        local nInRangeEnemy = J.GetNearbyHeroes(bot,800, true, BOT_MODE_NONE)

        if J.IsValidTarget(botTarget)
        and J.CanCastOnNonMagicImmune(botTarget)
        and J.IsInRange(bot, botTarget, nCastRange - 200)
        and not J.IsSuspiciousIllusion(botTarget)
        and not J.IsDisabled(botTarget)
        and not J.IsTaunted(botTarget)
        and not botTarget:HasModifier('modifier_enigma_black_hole_pull')
        and not botTarget:HasModifier('modifier_faceless_void_chronosphere_freeze')
        and nInRangeAlly ~= nil and nInRangeEnemy
        and #nInRangeAlly >= #nInRangeEnemy
        then
            local nDelay = (GetUnitToUnitDistance(bot, botTarget) / nSpeed) + nCastPoint
            return BOT_ACTION_DESIRE_HIGH, botTarget:GetExtrapolatedLocation(nDelay)
        end
	end

	if (J.IsDefending(bot) or J.IsPushing(bot))
	then
		local nEnemyLanecreeps = bot:GetNearbyLaneCreeps(nCastRange - 200, true)
		local nLocationAoE = bot:FindAoELocation(true, false, bot:GetLocation(), nCastRange - 200, nRadius, 0, 0)

		if nEnemyLanecreeps ~= nil and #nEnemyLanecreeps >= 4
        and nLocationAoE.count >= 4
		then
			return BOT_ACTION_DESIRE_HIGH, nLocationAoE.targetloc
		end

        nLocationAoE = bot:FindAoELocation(true, true, bot:GetLocation(), nCastRange - 200, nRadius, 0, 0)
        if nLocationAoE.count >= 1
        then
            return BOT_ACTION_DESIRE_HIGH, nLocationAoE.targetloc
        end
	end

    if J.IsFarming(bot)
    then
        local nEnemyLanecreeps = bot:GetNearbyLaneCreeps(800, true)
		local nLocationAoE = bot:FindAoELocation(true, false, bot:GetLocation(), 800, nRadius, 0, 0)

        if J.IsAttacking(bot)
        then
            if nEnemyLanecreeps ~= nil and #nEnemyLanecreeps >= 3
            and nLocationAoE.count >= 3
            then
                return BOT_ACTION_DESIRE_HIGH, nLocationAoE.targetloc
            end

            local nNeutralCreeps = bot:GetNearbyNeutralCreeps(600)
            if nNeutralCreeps ~= nil
            and ((#nNeutralCreeps >= 3 and nLocationAoE.count >= 3)
                or (#nNeutralCreeps >= 2 and nLocationAoE.count >= 2 and nNeutralCreeps[1]:IsAncientCreep()))
            and nMana > 0.27
            then
                return BOT_ACTION_DESIRE_HIGH, nLocationAoE.targetloc
            end
        end
    end

    if J.IsLaning(bot)
    and nMana > 0.39
	then
		local nEnemyLaneCreeps = bot:GetNearbyLaneCreeps(nCastRange, true)

		for _, creep in pairs(nEnemyLaneCreeps)
		do
			if J.IsValid(creep)
			and (J.IsKeyWordUnit('ranged', creep) or J.IsKeyWordUnit('siege', creep) or J.IsKeyWordUnit('flagbearer', creep))
			and creep:GetHealth() <= nDamage
			then
				local nInRangeEnemy = J.GetNearbyHeroes(bot,1600, true, BOT_MODE_NONE)

				if nInRangeEnemy ~= nil and #nInRangeEnemy >= 1
				and GetUnitToUnitDistance(creep, nInRangeEnemy[1]) <= 500
				then
					return BOT_ACTION_DESIRE_HIGH, creep:GetLocation()
				end
			end
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

    local nAllyHeroes = J.GetNearbyHeroes(bot,nCastRange, false, BOT_MODE_NONE)
    for _, allyHero in pairs(nAllyHeroes)
    do
        local nAllyInRangeEnemy = J.GetNearbyHeroes(allyHero, nCastRange, true, BOT_MODE_NONE)

        if J.IsRetreating(allyHero)
        and allyHero:WasRecentlyDamagedByAnyHero(2.1)
        and not allyHero:IsIllusion()
        and nMana > 0.48
        then
            if nAllyInRangeEnemy ~= nil and #nAllyInRangeEnemy >= 1
            and J.IsValidHero(nAllyInRangeEnemy[1])
            and J.CanCastOnNonMagicImmune(nAllyInRangeEnemy[1])
            and J.IsInRange(allyHero, nAllyInRangeEnemy[1], 400)
            and J.IsInRange(bot, nAllyInRangeEnemy[1], nCastRange)
            and J.IsRunning(allyHero)
            and nAllyInRangeEnemy[1]:IsFacingLocation(allyHero:GetLocation(), 30)
            and not J.IsDisabled(nAllyInRangeEnemy[1])
            and not J.IsTaunted(nAllyInRangeEnemy[1])
            and not J.IsSuspiciousIllusion(nAllyInRangeEnemy[1])
            and not nAllyInRangeEnemy[1]:HasModifier('modifier_enigma_black_hole_pull')
            and not nAllyInRangeEnemy[1]:HasModifier('modifier_faceless_void_chronosphere_freeze')
            then
                local nDelay = (GetUnitToUnitDistance(bot, nAllyInRangeEnemy[1]) / nSpeed) + nCastPoint
                return BOT_ACTION_DESIRE_HIGH, nAllyInRangeEnemy[1]:GetExtrapolatedLocation(nDelay)
            end
        end
    end

    return BOT_ACTION_DESIRE_NONE, 0
end

function X.ConsiderEmpower()
    local target = SpellDecisions.EmpowerTarget(Empower)
    return target ~= nil and BOT_ACTION_DESIRE_HIGH or BOT_ACTION_DESIRE_NONE, target
end

function X.ConsiderSkewer()
    if bot:IsRooted() or not Skewer:IsFullyCastable()
    then
        return BOT_ACTION_DESIRE_NONE, 0
    end

    local nDist = Skewer:GetSpecialValueInt('range')
	local nCastPoint = Skewer:GetCastPoint()
	local nSpeed = Skewer:GetSpecialValueInt('skewer_speed')
    local nRadius = Skewer:GetSpecialValueInt('skewer_radius')
    local botTarget = J.GetProperTarget(bot)

	if J.IsStuck(bot)
	then
		local loc = J.GetEscapeLoc()
		return BOT_ACTION_DESIRE_HIGH, J.Site.GetXUnitsTowardsLocation(bot, loc, nDist)
	end

	if J.IsGoingOnSomeone(bot)
    and (not CanDoBlinkSkewer() or not CanDoBlinkRPSkewer() or not CanDoBlinkHornTossSkewer())
	then
        local nInRangeAlly = J.GetNearbyHeroes(bot,1000, false, BOT_MODE_NONE)
        local nInRangeEnemy = J.GetNearbyHeroes(bot,1000, true, BOT_MODE_NONE)

        if J.IsValidTarget(botTarget)
        and J.CanCastOnNonMagicImmune(botTarget)
        and not J.IsSuspiciousIllusion(botTarget)
        and not botTarget:HasModifier('modifier_enigma_black_hole_pull')
        and not botTarget:HasModifier('modifier_faceless_void_chronosphere_freeze')
        and nInRangeAlly ~= nil and nInRangeEnemy
        and #nInRangeAlly >= #nInRangeEnemy
        then
            if J.IsEnemyBetweenMeAndLocation(bot, J.GetEscapeLoc(), nDist)
            and J.IsInRange(bot, botTarget, nRadius)
            then
                if #nInRangeAlly >= 1
                then
                    return BOT_ACTION_DESIRE_HIGH, J.Site.GetXUnitsTowardsLocation(bot, nInRangeAlly[#nInRangeAlly]:GetLocation(), nDist)
                else
                    return BOT_ACTION_DESIRE_HIGH, J.Site.GetXUnitsTowardsLocation(bot, J.GetEscapeLoc(), nDist)
                end
            end

            if J.IsRunning(bot)
            and J.IsRunning(botTarget)
            and J.IsInRange(bot, botTarget, nDist)
            and bot:IsFacingLocation(botTarget:GetLocation(), 30)
            and not botTarget:IsFacingLocation(bot:GetLocation(), 30)
            then
                local nDelay = (GetUnitToUnitDistance(bot, botTarget) / nSpeed) + nCastPoint
                return BOT_ACTION_DESIRE_HIGH, botTarget:GetExtrapolatedLocation(nDelay)
            end
        end
	end

	if J.IsRetreating(bot)
	then
        local nInRangeAlly = J.GetNearbyHeroes(bot,800, false, BOT_MODE_NONE)
        local nInRangeEnemy = J.GetNearbyHeroes(bot,600, true, BOT_MODE_NONE)

        if nInRangeAlly ~= nil and nInRangeEnemy
        and ((#nInRangeEnemy > #nInRangeAlly)
            or (J.GetHP(bot) < 0.68 and bot:WasRecentlyDamagedByAnyHero(1.9)))
        and J.IsValidHero(nInRangeEnemy[1])
        and J.IsInRange(bot, nInRangeEnemy[1], 575)
        and not J.IsSuspiciousIllusion(nInRangeEnemy[1])
        and not J.IsDisabled(nInRangeEnemy[1])
        and not J.IsTaunted(nInRangeEnemy[1])
        then
            local loc = J.GetEscapeLoc()
            return BOT_ACTION_DESIRE_HIGH, J.Site.GetXUnitsTowardsLocation(bot, loc, nDist)
        end
	end

    return BOT_ACTION_DESIRE_NONE, 0
end

function X.ConsiderReversePolarity()
    return SpellDecisions.RPUseful(ReversePolarity, false) and BOT_ACTION_DESIRE_HIGH or BOT_ACTION_DESIRE_NONE
end

function X.ConsiderHornToss()
    if not HornToss:IsTrained()
    or not HornToss:IsFullyCastable()
    then
        return BOT_ACTION_DESIRE_NONE
    end

    local nRadius = HornToss:GetSpecialValueInt('radius')
    local botTarget = J.GetProperTarget(bot)

    if J.IsGoingOnSomeone(bot)
    and not CanDoBlinkHornTossSkewer()
    then
        local nInRangeAlly = J.GetNearbyHeroes(bot,800, false, BOT_MODE_NONE)
        local nInRangeEnemy = J.GetNearbyHeroes(bot,800, true, BOT_MODE_NONE)

        if J.IsValidTarget(botTarget)
        and J.CanCastOnNonMagicImmune(botTarget)
        and J.IsInRange(bot, botTarget, nRadius)
        and bot:IsFacingLocation(botTarget:GetLocation(), 15)
        and not J.IsSuspiciousIllusion(botTarget)
        and not botTarget:HasModifier('modifier_enigma_black_hole_pull')
        and not botTarget:HasModifier('modifier_faceless_void_chronosphere_freeze')
        and not botTarget:HasModifier('modifier_legion_commander_duel')
        and nInRangeAlly ~= nil and nInRangeEnemy
        and #nInRangeAlly >= #nInRangeEnemy
        then
            return BOT_ACTION_DESIRE_HIGH
        end
    end

    if J.IsRetreating(bot)
	then
        local nInRangeAlly = J.GetNearbyHeroes(bot,nRadius + 200, false, BOT_MODE_NONE)
        local nInRangeEnemy = J.GetNearbyHeroes(bot,nRadius, true, BOT_MODE_NONE)

        if nInRangeAlly ~= nil and nInRangeEnemy
        and ((#nInRangeEnemy > #nInRangeAlly)
            or (J.GetHP(bot) < 0.61 and bot:WasRecentlyDamagedByAnyHero(2)))
        then
            for _, enemyHero in pairs(nInRangeEnemy)
            do
                if J.IsValidHero(enemyHero)
                and J.CanCastOnNonMagicImmune(enemyHero)
                and J.IsInRange(bot, enemyHero, nRadius)
                and J.IsEnemyBetweenMeAndLocation(bot, J.GetEscapeLoc(), nRadius)
                and not J.IsSuspiciousIllusion(enemyHero)
                then
                    return BOT_ACTION_DESIRE_HIGH
                end
            end
        end
	end

    return BOT_ACTION_DESIRE_NONE
end

function X.ConsiderBlinkRP()
    if CanDoBlinkRP()
    then
        local nCastRange = 1199
        local nCastPoint = Skewer:GetCastPoint() + ReversePolarity:GetCastPoint()
        local nRadius = ReversePolarity:GetSpecialValueInt('pull_radius')

        if J.IsInTeamFight(bot, 1200)
        then
            local nLocationAoE = bot:FindAoELocation(true, true, bot:GetLocation(), nCastRange, nRadius, nCastPoint, 0)

            if nLocationAoE.count >= 2
            then
                local realEnemyCount = J.GetEnemiesNearLoc(nLocationAoE.targetloc, nRadius)

                if realEnemyCount ~= nil and #realEnemyCount >= 2
                and not J.IsLocationInChrono(nLocationAoE.targetloc)
                and not J.IsLocationInBlackHole(nLocationAoE.targetloc)
                then
                    BlinkLocation = nLocationAoE.targetloc
                    return BOT_ACTION_DESIRE_HIGH
                end
            end
        end
    end

    return BOT_ACTION_DESIRE_NONE
end

function CanDoBlinkRP()
    if ReversePolarity:IsFullyCastable()
    and HasBlink()
    then
        local nManaCost = ReversePolarity:GetManaCost()

        if bot:GetMana() >= nManaCost
        then
            bot.shouldBlink = true
            return true
        end
    end

    bot.shouldBlink = false
    return false
end

function X.ConsiderBlinkForSkewer()
    if CanDoBlinkSkewer()
    then
        local botTarget = J.GetProperTarget(bot)

        if J.IsGoingOnSomeone(bot)
        then
            local nInRangeAlly = J.GetNearbyHeroes(bot,1000, false, BOT_MODE_NONE)
            local nInRangeEnemy = J.GetNearbyHeroes(bot,800, true, BOT_MODE_NONE)

            if J.IsValidTarget(botTarget)
            and J.CanCastOnNonMagicImmune(botTarget)
            and J.IsInRange(bot, botTarget, 1199)
            and not J.IsSuspiciousIllusion(botTarget)
            and not botTarget:HasModifier('modifier_enigma_black_hole_pull')
            and not botTarget:HasModifier('modifier_faceless_void_chronosphere_freeze')
            and nInRangeAlly ~= nil and nInRangeEnemy
            and #nInRangeAlly >= #nInRangeEnemy
            then
                BlinkLocation = botTarget:GetLocation()
                return BOT_ACTION_DESIRE_HIGH
            end
        end
    end

    return BOT_ACTION_DESIRE_NONE
end

function X.ConsiderSkewer2()
    local nRadius = Skewer:GetSpecialValueInt('skewer_radius')
    local nDist = Skewer:GetSpecialValueInt('range')

    local nInRangeAlly = J.GetNearbyHeroes(bot,800, false, BOT_MODE_NONE)
    local nInRangeEnemy = J.GetNearbyHeroes(bot,800, true, BOT_MODE_NONE)
    local nInRangeEnemy2 = J.GetNearbyHeroes(bot,nRadius, true, BOT_MODE_NONE)

    for _, enemyHero in pairs(nInRangeEnemy2)
    do
        if J.IsValidHero(enemyHero)
        and J.CanCastOnNonMagicImmune(enemyHero)
        and not J.IsSuspiciousIllusion(enemyHero)
        and not enemyHero:HasModifier('modifier_enigma_black_hole_pull')
        and not enemyHero:HasModifier('modifier_faceless_void_chronosphere_freeze')
        and nInRangeAlly ~= nil and nInRangeEnemy
        and #nInRangeAlly >= #nInRangeEnemy
        then
            if J.IsEnemyBetweenMeAndLocation(bot, J.GetEscapeLoc(), nDist)
            and J.IsInRange(bot, enemyHero, nRadius)
            then
                if #nInRangeAlly >= 1
                then
                    return BOT_ACTION_DESIRE_HIGH, J.Site.GetXUnitsTowardsLocation(bot, nInRangeAlly[#nInRangeAlly]:GetLocation(), nDist)
                else
                    return BOT_ACTION_DESIRE_HIGH, J.Site.GetXUnitsTowardsLocation(bot, J.GetEscapeLoc(), nDist)
                end
            end
        end
    end

    return BOT_ACTION_DESIRE_NONE
end

function CanDoBlinkSkewer()
    if Skewer:IsFullyCastable()
    and HasBlink()
    then
        local nManaCost = Skewer:GetManaCost()

        if bot:GetMana() >= nManaCost
        then
            bot.shouldBlink = true
            return true
        end
    end

    bot.shouldBlink = false
    return false
end

function X.ConsiderBlinkRPSkewer()
    if CanDoBlinkRPSkewer()
    then
        local nCastRange = 1199
        local nCastPoint = Skewer:GetCastPoint() + ReversePolarity:GetCastPoint()
        local nRPRadius = ReversePolarity:GetSpecialValueInt('pull_radius')

        if J.IsInTeamFight(bot, 1200)
        then
            local nLocationAoE = bot:FindAoELocation(true, true, bot:GetLocation(), nCastRange, nRPRadius, nCastPoint, 0)

            if nLocationAoE.count >= 2
            then
                BlinkLocation = nLocationAoE.targetloc
                local realEnemyCount = J.GetEnemiesNearLoc(nLocationAoE.targetloc, nRPRadius)

                if realEnemyCount ~= nil and #realEnemyCount >= 2
                and not J.IsLocationInChrono(nLocationAoE.targetloc)
                and not J.IsLocationInBlackHole(nLocationAoE.targetloc)
                then
                    return BOT_ACTION_DESIRE_HIGH
                end
            end
        end
    end

    return BOT_ACTION_DESIRE_NONE
end

function CanDoBlinkRPSkewer()
    if Skewer:IsFullyCastable()
    and ReversePolarity:IsFullyCastable()
    and ReversePolarity:GetSpecialValueInt('pull_radius') > 0
    and not bot:IsRooted()
    and HasBlink()
    then
        local nManaCost = Skewer:GetManaCost() + ReversePolarity:GetManaCost()

        if bot:GetMana() >= nManaCost
        then
            bot.shouldBlink = true
            return true
        end
    end

    bot.shouldBlink = false
    return false
end

function X.ConsiderBlinkForHornTossSkewer()
    if CanDoBlinkHornTossSkewer()
    then
        local botTarget = J.GetProperTarget(bot)

        if J.IsGoingOnSomeone(bot)
        then
            local nInRangeAlly = J.GetNearbyHeroes(bot,800, false, BOT_MODE_NONE)
            local nInRangeEnemy = J.GetNearbyHeroes(bot,800, true, BOT_MODE_NONE)

            if J.IsValidTarget(botTarget)
            and J.CanCastOnNonMagicImmune(botTarget)
            and J.IsInRange(bot, botTarget, 1199)
            and not J.IsSuspiciousIllusion(botTarget)
            and not botTarget:HasModifier('modifier_enigma_black_hole_pull')
            and not botTarget:HasModifier('modifier_faceless_void_chronosphere_freeze')
            and not botTarget:HasModifier('modifier_legion_commander_duel')
            and nInRangeAlly ~= nil and nInRangeEnemy
            and #nInRangeAlly >= #nInRangeEnemy
            then
                BlinkLocation = botTarget:GetLocation()
                return BOT_ACTION_DESIRE_HIGH
            end
        end
    end

    return BOT_ACTION_DESIRE_NONE
end

function CanDoBlinkHornTossSkewer()
    if (HornToss:IsTrained() and HornToss:IsFullyCastable())
    and Skewer:IsFullyCastable()
    and ReversePolarity:IsFullyCastable()
    and HasBlink()
    then
        local nManaCost = Skewer:GetManaCost() + ReversePolarity:GetManaCost() + HornToss:GetManaCost()

        if bot:GetMana() >= nManaCost
        then
            bot.shouldBlink = true
            return true
        end
    end

    bot.shouldBlink = false
    return false
end

function HasBlink()
    local blink = nil

    for i = 0, 5
    do
		local item = bot:GetItemInSlot(i)

		if item ~= nil
        and (item:GetName() == "item_blink" or item:GetName() == "item_overwhelming_blink" or item:GetName() == "item_arcane_blink" or item:GetName() == "item_swift_blink")
        then
			blink = item
			break
		end
	end

    if blink ~= nil
    and blink:IsFullyCastable()
	then
        Blink = blink
        return true
	end

    return false
end

function CanBKB()
    local bkb = nil

    for i = 0, 5
    do
		local item = bot:GetItemInSlot(i)

		if item ~= nil
        and item:GetName() == "item_black_king_bar"
        then
			bkb = item
			break
		end
	end

    if bkb ~= nil
    and bkb:IsFullyCastable()
    and bot:GetMana() >= 75
	then
        BlackKingBar = bkb
        return true
	end

    return false
end

return X
