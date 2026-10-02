----------------------------------------------------------------------------------------------------
--- The Creation Come From: BOT EXPERIMENT Credit:FURIOUSPUPPY
--- BOT EXPERIMENT Author: Arizona Fauzie 2018.11.21
--- Link:http://steamcommunity.com/sharedfiles/filedetails/?id=837040016
--- Refactor: 决明子 Email: dota2jmz@163.com 微博@Dota2_决明子
--- Link:http://steamcommunity.com/sharedfiles/filedetails/?id=1573671599
--- Link:http://steamcommunity.com/sharedfiles/filedetails/?id=1627071163
----------------------------------------------------------------------------------------------------
local X = {}
local bot = GetBot()

local J = require( GetScriptDirectory()..'/FunLib/jmz_func' )
local Minion = dofile( GetScriptDirectory()..'/FunLib/aba_minion' )
local sTalentList = J.Skill.GetTalentList( bot )
local sAbilityList = J.Skill.GetAbilityList( bot )
local sRole = J.Item.GetRoleItemsBuyList( bot )

-- Updated to 7.41f from D2PT: physical carry and spell mid; forced other roles use carry.
local BuildData = require(GetScriptDirectory()..'/BotLib/Builds/nevermore')
X.buildMetadata = BuildData
X.neutralPreferences = BuildData.neutrals[sRole]
local isMid = sRole=='pos_2'
-- [1] linked Shadowrazes, [4] Feast of Souls, [5] Presence, [6] Requiem.
local nAbilityBuildList = {1,5,1,5,1,6,1,5,5,4,6,4,4,4,6}
local nTalentBuildList = J.Skill.GetTalentBuild({
    t10=isMid and {0,10} or {10,0}, -- Raze stack damage / Feast attack speed
    t15={0,10}, -- Presence armor reduction
    t20={0,10}, -- +5 Necromastery max souls
    t25=isMid and {0,10} or {10,0}, -- Feast cast speed / Raze attacks
})
local defaultAbilityBuild, defaultTalentBuild = nAbilityBuildList, nTalentBuildList
local sRoleItemsBuyList = {}
sRoleItemsBuyList.pos_1 = {
    'item_magic_wand','item_faerie_fire','item_faerie_fire',
    'item_power_treads','item_falcon_blade','item_lifesteal','item_mask_of_madness',
    'item_yasha','item_dragon_lance','item_manta','item_hurricane_pike',
    'item_black_king_bar','item_lesser_crit','item_greater_crit','item_satanic',
    -- Bot policy: replace Mask of Madness, then consumable/boots upgrades.
    'item_aghanims_shard','item_moon_shard','item_travel_boots','item_travel_boots_2',
}
sRoleItemsBuyList.pos_2 = {
    -- Observed starting ward omitted: core bots do not place it.
    'item_double_branches','item_tango','item_enchanted_mango','item_enchanted_mango','item_faerie_fire',
    'item_bottle','item_magic_wand','item_power_treads','item_yasha','item_yasha_and_kaya',
    'item_blink','item_black_king_bar','item_ultimate_scepter',
    -- Bot policy: consume Scepter to fit Refresher and Hex; natural Blink/boots upgrades.
    'item_ultimate_scepter_2','item_refresher','item_sheepstick','item_aghanims_shard',
    'item_swift_blink','item_moon_shard','item_travel_boots','item_travel_boots_2',
}
sRoleItemsBuyList.pos_3 = sRoleItemsBuyList.pos_1
sRoleItemsBuyList.pos_4 = sRoleItemsBuyList.pos_1
sRoleItemsBuyList.pos_5 = sRoleItemsBuyList.pos_1
X.sBuyList = sRoleItemsBuyList[sRole]
X.sSellList = {
    'item_dragon_lance','item_magic_wand','item_black_king_bar','item_falcon_blade',
    'item_satanic','item_mask_of_madness','item_blink','item_bottle',
    'item_ultimate_scepter','item_magic_wand','item_travel_boots','item_power_treads',
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

	if Minion.IsValidUnit( hMinionUnit )
	then
		Minion.IllusionThink( hMinionUnit )
	end

end


local abilityZ = bot:GetAbilityByName( sAbilityList[1] )
local abilityX = bot:GetAbilityByName( sAbilityList[2] )
local abilityC = bot:GetAbilityByName( sAbilityList[3] )
local FeastOfSouls = bot:GetAbilityByName('nevermore_frenzy')
local abilityR = bot:GetAbilityByName( sAbilityList[6] )

local castZDesire
local castXDesire
local castCDesire
local FeastOfSoulsDesire
local castRDesire

local nKeepMana, nMP, nHP, nLV, nInRangeEnemy, botTarget

function X.SkillsComplement()
	if bot.invisUltCombo then return end

	J.ConsiderTarget()
	if J.CanNotUseAbility(bot) or bot:IsChanneling() then return end

	nKeepMana = 340
	nLV = bot:GetLevel()
	nMP = bot:GetMana() / bot:GetMaxMana()
	nHP = bot:GetHealth() / bot:GetMaxHealth()
	nInRangeEnemy = J.GetNearbyHeroes(bot, 1600, true, BOT_MODE_NONE)
	botTarget = J.GetProperTarget(bot)

	castRDesire = X.ConsiderR()
	if castRDesire > 0
	then

		J.SetQueuePtToINT( bot, false )

		bot:ActionQueue_UseAbility ( abilityR )
		return

	end

	-- invis ult can be a good combo, dont use other spells yet.
	if abilityR:IsFullyCastable()
	and J.Utils.IsTruelyInvisible(bot)
	then return end

	-- this one is more important
	castXDesire = X.Consider( abilityX, 450 )
	if castXDesire > 0
	then

		J.SetQueuePtToINT( bot, true )

		bot:ActionQueue_UseAbility( abilityX )
		return
	end

	castCDesire = X.Consider( abilityC, 700 )
	if castCDesire > 0
	then

		J.SetQueuePtToINT( bot, true )

		bot:ActionQueue_UseAbility( abilityC )
		return
	end

	castZDesire = X.Consider( abilityZ, 200 )
	if castZDesire > 0
	then

		J.SetQueuePtToINT( bot, true )

		bot:ActionQueue_UseAbility( abilityZ )
		return

	end
	
	FeastOfSoulsDesire = X.ConsiderFeastOfSouls()
	if FeastOfSoulsDesire > 0
	then
		J.SetQueuePtToINT(bot, false)
		bot:ActionQueue_UseAbility(FeastOfSouls)
		return
	end
end

local function Souls()
    local index = bot:GetModifierByName('modifier_nevermore_necromastery')
    return index >= 0 and bot:GetModifierStackCount(index) or 0
end

local function Enemy(enemy)
    return J.IsValidHero(enemy) and not J.IsSuspiciousIllusion(enemy)
        and J.CanCastOnNonMagicImmune(enemy)
end

function X.ConsiderR()
    if not J.CanCastAbility(abilityR) or Souls() == 0 then return 0 end
    local radius = abilityR:GetSpecialValueInt('requiem_radius')
    local delay = abilityR:GetCastPoint()
    local near, total = 0, 0
    for _, enemy in ipairs(J.GetNearbyHeroes(bot, math.min(radius, 1600), true, BOT_MODE_NONE)) do
        local cyclone = J.GetModifierTime(enemy, 'modifier_eul_cyclone')
        if cyclone == 0 then cyclone = J.GetModifierTime(enemy, 'modifier_brewmaster_storm_cyclone') end
        if J.IsValidHero(enemy) and not J.IsSuspiciousIllusion(enemy) and not enemy:IsMagicImmune()
            and cyclone > 0 and cyclone <= delay and J.IsInRange(bot, enemy, 350) then return BOT_ACTION_DESIRE_HIGH end
        if Enemy(enemy) and GetUnitToLocationDistance(bot, J.GetCorrectLoc(enemy, delay)) <= radius then
            total = total + 1
            if J.IsInRange(bot, enemy, 350) then
                near = near + 1
                if J.IsGoingOnSomeone(bot) and (J.IsDisabled(enemy) or J.Utils.IsTruelyInvisible(bot)
                    or bot:IsMagicImmune()) then return BOT_ACTION_DESIRE_HIGH end
            end
        end
    end
    if near > 0 and J.IsRetreating(bot) and bot:WasRecentlyDamagedByAnyHero(2)
        and J.GetHP(bot) < 0.5 and (bot:IsMagicImmune() or near == 1) then return BOT_ACTION_DESIRE_HIGH end
    if (J.IsInTeamFight(bot, 1000) or J.IsGoingOnSomeone(bot)) and Souls() >= 10
        and (total >= 3 or near >= 1 and total >= 2) then return BOT_ACTION_DESIRE_HIGH end
    return 0
end

function X.IsUnitNearLoc(unit, location, radius, delay)
    return GetUnitToLocationDistance(unit, location) <= radius + unit:GetCurrentMovementSpeed() * delay
        and J.GetLocationToLocationDistance(J.GetCorrectLoc(unit, delay), location) <= radius
end

function X.IsUnitCanBeKill(unit, damage, bonus, delay, ability)
    local total = damage + J.GetModifierCount(unit, 'modifier_nevermore_shadowraze_debuff') * bonus
    if ability ~= nil then total = total + Souls() * ability:GetSpecialValueInt('damage_per_soul') end
    return J.WillKillTarget(unit, total, DAMAGE_TYPE_MAGICAL, delay)
end

function X.Consider(ability)
    if not J.CanCastAbility(ability) then return 0 end
    local radius = ability:GetSpecialValueInt('shadowraze_radius')
    -- Razes are facing-based ground blasts: cast-range items cannot move their center.
    local distance = ability:GetSpecialValueInt('shadowraze_range')
    local location = J.GetFaceTowardDistanceLocation(bot, distance)
    local delay = ability:GetCastPoint()
    local damage, bonus = ability:GetSpecialValueInt('shadowraze_damage'), ability:GetSpecialValueInt('stack_bonus_damage')
    for _, enemy in ipairs(J.GetNearbyHeroes(bot, math.min(distance + radius + 200, 1600), true, BOT_MODE_NONE)) do
        if Enemy(enemy) and X.IsUnitNearLoc(enemy, location, radius, delay)
            and not J.CannotBeKilled(bot, enemy)
            and (X.IsUnitCanBeKill(enemy, damage, bonus, delay, ability)
                or (J.IsGoingOnSomeone(bot) or J.IsLaning(bot) or J.IsInTeamFight(bot, 1000))
                    and J.IsAllowedToSpam(bot, ability:GetManaCost())
                or J.IsRetreating(bot) and enemy:HasModifier('modifier_nevermore_shadowraze_debuff')
                    and ability:GetSpecialValueInt('movement_speed_debuff') > 0) then return BOT_ACTION_DESIRE_HIGH end
    end
    if not J.IsRetreating(bot) and J.IsAllowedToSpam(bot, ability:GetManaCost()) then
        local creeps, hit, kills, rangedKill = bot:GetNearbyCreeps(math.min(distance + radius, 1600), true), 0, 0, false
        for _, creep in ipairs(creeps) do
            if J.IsValid(creep) and J.CanCastOnNonMagicImmune(creep)
                and X.IsUnitNearLoc(creep, location, radius, delay) then
                hit = hit + 1
                if X.IsUnitCanBeKill(creep, damage, bonus, delay, ability) then
                    kills = kills + 1
                    if J.IsKeyWordUnit('ranged', creep) then rangedKill = true end
                end
            end
        end
        if kills >= 2 or J.IsLaning(bot) and rangedKill
            or (J.IsFarming(bot) or J.IsPushing(bot) or J.IsDefending(bot)) and hit >= 3 then return BOT_ACTION_DESIRE_HIGH end
    end
    return 0
end

function X.ConsiderFeastOfSouls()
    if not J.CanCastAbility(FeastOfSouls) or bot:HasModifier('modifier_nevermore_frenzy') then return 0 end
    local radius = FeastOfSouls:GetSpecialValueInt('soul_collection_radius')
    if J.IsRetreating(bot) and bot:WasRecentlyDamagedByAnyHero(2)
        and #J.GetNearbyHeroes(bot, math.min(radius, 1600), true, BOT_MODE_NONE) > 0 then return BOT_ACTION_DESIRE_HIGH end
    if J.IsGoingOnSomeone(bot) and J.IsValidHero(botTarget) and not J.IsSuspiciousIllusion(botTarget)
        and J.CanBeAttacked(botTarget) and not bot:IsDisarmed()
        and J.IsInRange(bot, botTarget, math.max(bot:GetAttackRange(), radius))
        and not J.CannotBeKilled(bot, botTarget) then return BOT_ACTION_DESIRE_HIGH end
    if (J.IsFarming(bot) or J.IsPushing(bot) or J.IsDefending(bot)) and J.IsAttacking(bot)
        and J.IsAllowedToSpam(bot, FeastOfSouls:GetManaCost()) then
        if #bot:GetNearbyCreeps(math.min(radius, 1600), true) >= 3
            or #bot:GetNearbyNeutralCreeps(math.min(radius, 1600)) >= 2 then return BOT_ACTION_DESIRE_HIGH end
        if J.IsValidBuilding(botTarget) and J.CanBeAttacked(botTarget)
            and J.IsInRange(bot, botTarget, bot:GetAttackRange()) then return BOT_ACTION_DESIRE_HIGH end
    end
    if J.IsValid(botTarget) and (J.IsRoshan(botTarget) or J.IsTormentor(botTarget))
        and J.IsInRange(bot, botTarget, bot:GetAttackRange()) and J.IsAttacking(bot) then return BOT_ACTION_DESIRE_HIGH end
    return 0
end

return X
