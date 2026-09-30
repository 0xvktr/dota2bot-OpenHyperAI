local X = {}
local bot = GetBot()

local Utils = require( GetScriptDirectory()..'/FunLib/utils' )
local J = require( GetScriptDirectory()..'/FunLib/jmz_func' )
local Minion = dofile( GetScriptDirectory()..'/FunLib/aba_minion' )
local sTalentList = J.Skill.GetTalentList( bot )
local sAbilityList = J.Skill.GetAbilityList( bot )
local sRole = J.Item.GetRoleItemsBuyList( bot )

-- Updated to 7.41f from D2PT; forced skipped roles use carry.
local BuildData = require(GetScriptDirectory()..'/BotLib/Builds/lone_druid')
local BearItems = require(GetScriptDirectory()..'/FunLib/lone_druid_items')
X.buildMetadata = BuildData
X.neutralPreferences = BuildData.neutrals[sRole]
Utils.GetLoneDruid(bot).hero = bot
Utils.GetLoneDruid(bot).roleType = 'pos_1_w_bear'
-- [1] Entangle, [2] Spirit Link, [3] Savage Roar, [6] True Form; Spirit Bear is innate.
local nAbilityBuildList = {1,2,2,1,2,6,2,1,1,3,6,3,3,3,6}
local nTalentBuildList = J.Skill.GetTalentBuild({
    t10={10,0}, -- Entangle root damage
    t15={0,10}, -- Savage Roar cooldown
    t20={0,10}, -- Savage Roar radius
    t25={10,0}, -- Entangle root duration
})
local defaultAbilityBuild, defaultTalentBuild = nAbilityBuildList, nTalentBuildList
X.sBuyList = {
    'item_double_branches','item_double_branches','item_faerie_fire','item_blight_stone',
    'item_magic_wand','item_boots','item_power_treads','item_maelstrom','item_mjollnir',
    'item_ultimate_scepter','item_invis_sword','item_aghanims_shard','item_silver_edge',
    -- Bot policy: bear's six-slot finish, then Druid survival.
    'item_black_king_bar','item_butterfly','item_glimmer_cape',
}
X.sSellList = {}
local defaultItems = X.sBuyList

if J.Role.IsPvNMode() or J.Role.IsAllShadow() then X['sBuyList'], X['sSellList'] = { 'PvN_antimage' }, {} end

nAbilityBuildList, nTalentBuildList, X['sBuyList'], X['sSellList'] = J.SetUserHeroInit( nAbilityBuildList, nTalentBuildList, X['sBuyList'], X['sSellList'] )

X['sSkillList'] = J.Skill.GetSkillList( sAbilityList, nAbilityBuildList, sTalentList, nTalentBuildList )
if nAbilityBuildList == defaultAbilityBuild and nTalentBuildList == defaultTalentBuild then
    X.sSkillList[10], X.sSkillList[11] = X.sSkillList[11], X.sSkillList[10]
end
if X.sBuyList == defaultItems then X.itemOwnership = BuildData.itemOwnership end

X['bDeafaultAbility'] = false
X['bDeafaultItem'] = false

function X.MinionThink(hMinionUnit)
    if hMinionUnit and not hMinionUnit:IsNull() and hMinionUnit:IsAlive()
        and string.find(hMinionUnit:GetUnitName(), 'lone_druid_bear') and not hMinionUnit:IsIllusion() then
        Utils.GetLoneDruid(bot).bear = hMinionUnit
        hMinionUnit.isBear = true
        if BearItems.Transfer(bot, hMinionUnit, X.itemOwnership, J.Item, GetDroppedItemList()) then return end
        if BearItems.UseItems(hMinionUnit, J.GetProperTarget(bot), J.IsRetreating(bot)) then return end
    end
    Minion.MinionThink(hMinionUnit)
end

local SummonSpiritBear  = bot:GetAbilityByName('lone_druid_spirit_bear')
-- local SpiritLink        = bot:GetAbilityByName('lone_druid_spirit_link')
local SavageRoar        = bot:GetAbilityByName('lone_druid_savage_roar')
local TrueForm          = bot:GetAbilityByName('lone_druid_true_form')

local SummonSpiritBearDesire
local SavageRoarDesire
local TrueFormDesire

local botTarget

function X.SkillsComplement()
    if J.CanNotUseAbility(bot) then return end

    botTarget = J.GetProperTarget(bot)

    TrueFormDesire = X.ConsiderTrueForm()
    if TrueFormDesire > 0
    then
        bot:Action_UseAbility(TrueForm)
        return
    end

    SavageRoarDesire = X.ConsiderSavageRoar()
    if SavageRoarDesire > 0
    then
        bot:Action_UseAbility(SavageRoar)
        return
    end

    SummonSpiritBearDesire = X.ConsiderSummonSpiritBear()
    if SummonSpiritBearDesire > 0
    then
        bot:Action_UseAbility(SummonSpiritBear)
        return
    end
end

function X.ConsiderSummonSpiritBear()
    if not SummonSpiritBear:IsFullyCastable() or Utils.GetLoneDruid(bot).roleType ~= 'pos_1_w_bear'
    then
        return BOT_ACTION_DESIRE_NONE
    end

	if Utils.GetLoneDruid(bot).bear == nil or not Utils.GetLoneDruid(bot).bear:IsAlive()
    then
		return BOT_ACTION_DESIRE_HIGH
	end

    return BOT_ACTION_DESIRE_NONE
end

function X.ConsiderSavageRoar()
    if not SavageRoar:IsFullyCastable()
    then
        return BOT_ACTION_DESIRE_NONE
    end

    local nRadius = SavageRoar:GetSpecialValueInt('radius')
    local nInRangeEnemy = J.GetNearbyHeroes(bot, nRadius, true, BOT_MODE_NONE)

    for _, enemyHero in pairs(nInRangeEnemy) do
		if J.IsValidTarget(enemyHero)
        -- and J.IsInRange(bot, enemyHero, nRadius)
        and (J.IsChasingTarget(enemyHero, bot)
            or J.IsAttacking(enemyHero)
            or J.IsMoving(enemyHero)
            or enemyHero:IsChanneling()
            or enemyHero:IsUsingAbility())
        and not J.IsSuspiciousIllusion(enemyHero)
        and not J.IsDisabled(enemyHero)
        and J.CanCastOnNonMagicImmune( enemyHero )
        and J.CanCastOnTargetAdvanced( enemyHero )
		then
            return BOT_ACTION_DESIRE_HIGH
		end
    end

    if J.IsGoingOnSomeone(bot)
	then
		if J.IsValidTarget(botTarget)
        and J.IsInRange(bot, botTarget, nRadius)
        and not J.IsSuspiciousIllusion(botTarget)
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
        and J.IsInRange(bot, botTarget, 500)
        and J.IsAttacking(bot)
        then
            return BOT_ACTION_DESIRE_HIGH
        end
    end

    return BOT_ACTION_DESIRE_NONE
end

function X.ConsiderTrueForm()
    if TrueForm:IsHidden()
    or not TrueForm:IsFullyCastable()
    then
        return BOT_ACTION_DESIRE_NONE
    end

    if J.IsGoingOnSomeone(bot)
	then
		if J.IsValidTarget(botTarget)
        and J.IsInRange(bot, botTarget, bot:GetCurrentVisionRange())
        and not J.IsSuspiciousIllusion(botTarget)
        and not botTarget:HasModifier('modifier_faceless_void_chronosphere_freeze')
        and not botTarget:HasModifier('modifier_necrolyte_reapers_scythe')
		then
            local nInRangeAlly = J.GetNearbyHeroes(botTarget, 1200, true, BOT_MODE_NONE)
            local nInRangeEnemy = J.GetNearbyHeroes(botTarget, 1200, false, BOT_MODE_NONE)

            if nInRangeAlly ~= nil and nInRangeEnemy ~= nil
            and #nInRangeAlly >= #nInRangeEnemy
            and J.GetHP(bot) < 0.85
            then
                return BOT_ACTION_DESIRE_HIGH
            end
		end
	end

    if J.IsInTeamFight(bot, 1200) and J.GetHP(bot) < 0.85 then
        return BOT_ACTION_DESIRE_HIGH
    end

    if J.IsRetreating(bot)
	then
        local nInRangeEnemy = J.GetEnemiesNearLoc(bot:GetLocation(), 1000)
        for _, enemyHero in pairs(nInRangeEnemy)
        do
            if J.IsValidHero(enemyHero)
            and J.IsChasingTarget(enemyHero, bot)
            and J.GetHP(bot) < 0.45
            and not J.IsSuspiciousIllusion(enemyHero)
            and not J.IsDisabled(enemyHero)
            then
                local nInRangeAlly = J.GetNearbyHeroes(enemyHero, 1200, true, BOT_MODE_NONE)
                local nTargetInRangeAlly = J.GetNearbyHeroes(enemyHero, 1200, false, BOT_MODE_NONE)

                if nInRangeAlly ~= nil and nTargetInRangeAlly ~= nil
                and ((#nTargetInRangeAlly > #nInRangeAlly)
                    or bot:WasRecentlyDamagedByAnyHero(1.5))
                then
                    return BOT_ACTION_DESIRE_HIGH
                end
            end
        end
	end

    return BOT_ACTION_DESIRE_NONE
end

return X
