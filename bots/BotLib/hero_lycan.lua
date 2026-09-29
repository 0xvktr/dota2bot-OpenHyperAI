local X = {}
local bot = GetBot()

local J = require( GetScriptDirectory()..'/FunLib/jmz_func' )
local Minion = dofile( GetScriptDirectory()..'/FunLib/aba_minion' )
local sTalentList = J.Skill.GetTalentList( bot )
local sAbilityList = J.Skill.GetAbilityList( bot )
local sRole = J.Item.GetRoleItemsBuyList( bot )

-- Updated to 7.41f from D2PT: offlane only; forced other roles use offlane.
local BuildData = require(GetScriptDirectory()..'/BotLib/Builds/lycan')
X.buildMetadata = BuildData
X.neutralPreferences = BuildData.neutrals[sRole]
-- [1] Summon Wolves, [2] Howl, [3] Feral Impulse, [6] Shapeshift.
local nAbilityBuildList = {1,3,1,2,1,6,1,3,3,3,6,2,2,2,6}
local nTalentBuildList = J.Skill.GetTalentBuild({
    t10={10,0}, -- +14 Wolves damage
    t15={10,0}, -- -15s Shapeshift cooldown
    t20={10,0}, -- +25% Feral Impulse damage
    t25={0,10}, -- Howl reduces total attack damage
})
local defaultAbilityBuild, defaultTalentBuild = nAbilityBuildList, nTalentBuildList
X.sBuyList = {
    'item_quelling_blade','item_double_branches','item_sobi_mask','item_magic_stick',
    'item_helm_of_iron_will','item_helm_of_the_dominator','item_magic_wand',
    'item_helm_of_the_overlord','item_aghanims_shard','item_assault',
    'item_black_king_bar','item_nullifier',
    -- Bot policy: late mobility, consumed Scepter and a disable within six slots.
    'item_travel_boots','item_ultimate_scepter','item_ultimate_scepter_2','item_sheepstick',
}
X.sSellList = {
    'item_helm_of_the_dominator','item_quelling_blade',
    'item_assault','item_sobi_mask',
    'item_ultimate_scepter','item_magic_wand',
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

local SummonWolves  = bot:GetAbilityByName('lycan_summon_wolves')
local Howl          = bot:GetAbilityByName('lycan_howl')
local FeralImpulse  = bot:GetAbilityByName('lycan_feral_impulse')
local WoflBite      = bot:GetAbilityByName('lycan_wolf_bite')
local ShapeShift    = bot:GetAbilityByName('lycan_shapeshift')

local SummonWolvesDesire
local HowlDesire
local WoflBiteDesire, WoflBiteTarget
local ShapeShiftDesire

function X.SkillsComplement()
    if J.CanNotUseAbility(bot) then return end

    ShapeShiftDesire = X.ConsiderShapeShift()
    if ShapeShiftDesire > 0
    then
        bot:Action_UseAbility(ShapeShift)
        return
    end

    HowlDesire = X.ConsiderHowl()
    if HowlDesire > 0
    then
        bot:Action_UseAbility(Howl)
        return
    end

    SummonWolvesDesire = X.ConsiderSummonWolves()
    if SummonWolvesDesire > 0
    then
        bot:Action_UseAbility(SummonWolves)
        return
    end

    -- WoflBiteDesire, WoflBiteTarget = X.ConsiderWoflBite()
end

function X.ConsiderSummonWolves()
    if not SummonWolves:IsFullyCastable()
    then
        return BOT_ACTION_DESIRE_NONE
    end

    for _, unit in pairs(GetUnitList(UNIT_LIST_ALLIES))
    do
        if J.IsValid(unit)
        and string.find( unit:GetUnitName(), "npc_dota_lycan_wolf" )
        then
            return BOT_ACTION_DESIRE_NONE
        end
    end

    local botTarget = J.GetProperTarget(bot)

    if J.IsGoingOnSomeone(bot)
	then
        local nInRangeAlly = J.GetNearbyHeroes(bot,1200, false, BOT_MODE_NONE)
        local nInRangeEnemy = J.GetNearbyHeroes(bot,1200, true, BOT_MODE_NONE)

		if J.IsValidTarget(botTarget)
        and J.IsInRange(bot, botTarget, 800)
        and not J.IsSuspiciousIllusion(botTarget)
        and nInRangeAlly ~= nil and nInRangeEnemy
        and #nInRangeAlly >= #nInRangeEnemy
		then
			return BOT_ACTION_DESIRE_HIGH
		end
	end

    if (J.IsPushing(bot) or J.IsDefending(bot) or J.IsLaning(bot))
	then
		local nEnemyLaneCreeps = bot:GetNearbyLaneCreeps(800, true)

        if J.IsAttacking(bot)
        then
            if nEnemyLaneCreeps ~= nil and #nEnemyLaneCreeps >= 0
            then
                return BOT_ACTION_DESIRE_HIGH
            end

            local nEnemyTowers = bot:GetNearbyTowers(600, true)
            if nEnemyTowers ~= nil and #nEnemyTowers >= 1
            and J.CanBeAttacked(nEnemyTowers[1])
            then
                return BOT_ACTION_DESIRE_HIGH
            end
        end
	end

    if J.IsFarming(bot)
    then
        local nNeutralCreeps = bot:GetNearbyNeutralCreeps(600)
        local nEnemyLaneCreeps = bot:GetNearbyLaneCreeps(600, true)

        if J.IsAttacking(bot)
        then
            if (nNeutralCreeps ~= nil and #nNeutralCreeps >= 2)
            or (nEnemyLaneCreeps ~= nil and #nEnemyLaneCreeps >= 3)
            then
                return BOT_ACTION_DESIRE_HIGH
            end
        end
    end

    if J.IsDoingRoshan(bot)
    then
        if J.IsRoshan(botTarget)
        and J.IsInRange(bot, botTarget, 400)
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

function X.ConsiderHowl()
    if not Howl:IsFullyCastable()
    then
        return BOT_ACTION_DESIRE_NONE
    end

    local timeOfDay = J.CheckTimeOfDay()
    local botTarget = J.GetProperTarget(bot)

    if timeOfDay == 'night'
    then
        for _, allyHero in pairs(GetUnitList(UNIT_LIST_ALLIED_HEROES))
        do
            if J.IsValidHero(allyHero)
            and not allyHero:IsIllusion()
            then
                if J.IsCore(allyHero)
                and J.IsGoingOnSomeone(allyHero)
                then
                    local allyTarget = allyHero:GetAttackTarget()

                    if J.IsValidTarget(allyTarget)
                    and J.IsInRange(bot, allyTarget, allyHero:GetAttackRange())
                    and allyHero:IsFacingLocation(allyTarget:GetLocation(), 30)
                    and J.IsAttacking(allyHero)
                    and not J.IsSuspiciousIllusion(allyTarget)
                    then
                        return BOT_ACTION_DESIRE_HIGH
                    end
                end
            end
        end

        local nTeamFightLocation = J.GetTeamFightLocation(bot)

        if nTeamFightLocation ~= nil
        then
            if GetUnitToLocationDistance(bot, nTeamFightLocation) > 1600
            then
                return BOT_ACTION_DESIRE_HIGH
            end
        end
    end

    if J.IsGoingOnSomeone(bot)
	then
        local nInRangeAlly = J.GetNearbyHeroes(bot,1200, false, BOT_MODE_NONE)
        local nInRangeEnemy = J.GetNearbyHeroes(bot,1200, true, BOT_MODE_NONE)

		if J.IsValidTarget(botTarget)
        and J.IsInRange(bot, botTarget, 800)
        and not J.IsSuspiciousIllusion(botTarget)
        and nInRangeAlly ~= nil and nInRangeEnemy
        and #nInRangeAlly >= #nInRangeEnemy
		then
			return BOT_ACTION_DESIRE_HIGH
		end
	end

	if J.IsRetreating(bot)
	then
        local nInRangeAlly = J.GetNearbyHeroes(bot,800, false, BOT_MODE_NONE)
        local nInRangeEnemy = J.GetNearbyHeroes(bot,800, true, BOT_MODE_NONE)

		if nInRangeAlly ~= nil and nInRangeEnemy ~= nil
        and ((#nInRangeEnemy > #nInRangeAlly)
            or (J.GetHP(bot) < 0.75 and bot:WasRecentlyDamagedByAnyHero(1.7)))
        and J.IsValidHero(nInRangeEnemy[1])
        and J.IsInRange(bot, nInRangeEnemy[1], 450)
        and bot:IsFacingLocation(J.GetEscapeLoc(), 30)
        and nInRangeEnemy[1]:IsFacingLocation(bot:GetLocation(), 30)
        and not J.IsSuspiciousIllusion(nInRangeEnemy[1])
        and not J.IsDisabled(nInRangeEnemy[1])
		then
			return BOT_ACTION_DESIRE_HIGH
		end
	end

	if (J.IsPushing(bot) or J.IsDefending(bot))
	then
		local nEnemyLaneCreeps = bot:GetNearbyCreeps(600, true)

        if J.IsAttacking(bot)
        then
            if nEnemyLaneCreeps ~= nil and #nEnemyLaneCreeps >= 4
            then
                return BOT_ACTION_DESIRE_HIGH
            end

            local nEnemyTowers = bot:GetNearbyTowers(600, true)
            if nEnemyTowers ~= nil and #nEnemyTowers >= 1
            and J.CanBeAttacked(nEnemyTowers[1])
            then
                return BOT_ACTION_DESIRE_HIGH
            end
        end
	end

    if J.IsFarming(bot)
    then
        local nNeutralCreeps = bot:GetNearbyNeutralCreeps(300)
        local nEnemyLaneCreeps = bot:GetNearbyLaneCreeps(600, true)

        if J.IsAttacking(bot)
        then
            if (nNeutralCreeps ~= nil and #nNeutralCreeps >= 2)
            or (nEnemyLaneCreeps ~= nil and #nEnemyLaneCreeps >= 3)
            then
                return BOT_ACTION_DESIRE_HIGH
            end
        end
    end

    if J.IsDoingRoshan(bot)
    then
        if J.IsRoshan(botTarget)
        and J.IsInRange(bot, botTarget, 400)
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

function X.ConsiderShapeShift()
    if not ShapeShift:IsFullyCastable()
    then
        return BOT_ACTION_DESIRE_NONE
    end

    if J.IsInTeamFight(bot, 1000)
    then
        return BOT_ACTION_DESIRE_HIGH
    end

    if J.IsGoingOnSomeone(bot) then
        local botTarget = J.GetProperTarget(bot)
        local nInRangeAlly = J.GetNearbyHeroes(bot,1200, false, BOT_MODE_NONE)
        local nInRangeEnemy = J.GetNearbyHeroes(bot,1200, true, BOT_MODE_NONE)

		if J.IsValidTarget(botTarget)
        and J.IsInRange(bot, botTarget, 800)
        and not J.IsSuspiciousIllusion(botTarget)
        and nInRangeAlly ~= nil and nInRangeEnemy
        and #nInRangeAlly >= #nInRangeEnemy
		then
			return BOT_ACTION_DESIRE_HIGH
		end
    end

    return BOT_ACTION_DESIRE_NONE
end

return X