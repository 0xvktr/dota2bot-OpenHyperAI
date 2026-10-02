----------------------------------------------------------------------------------------------------
--- The Creation Come From: BOT EXPERIMENT Credit:FURIOUSPUPPY
--- BOT EXPERIMENT Author: Arizona Fauzie 2018.11.21
--- Link:http://steamcommunity.com/sharedfiles/filedetails/?id=837040016
--- Refactor: 决明子 Email: dota2jmz@163.com 微博@Dota2_决明子
--- Link:http://steamcommunity.com/sharedfiles/filedetails/?id=1573671599
--- Link:http://steamcommunity.com/sharedfiles/filedetails/?id=1627071163
----------------------------------------------------------------------------------------------------
local X = {}
local bDebugMode = ( 1 == 10 )
local bot = GetBot()

local J = require( GetScriptDirectory()..'/FunLib/jmz_func' )
local K = require(GetScriptDirectory()..'/FunLib/jakiro_abilities')
local Minion = dofile( GetScriptDirectory()..'/FunLib/aba_minion' )
local sTalentList = J.Skill.GetTalentList( bot )
local sAbilityList = J.Skill.GetAbilityList( bot )
local sRole = J.Item.GetRoleItemsBuyList( bot )

-- Updated to 7.41f from D2PT: pos 5/4; forced other roles use pos 5.
local BuildData = require(GetScriptDirectory()..'/BotLib/Builds/jakiro')
X.buildMetadata = BuildData
X.neutralPreferences = BuildData.neutrals[sRole]
-- [1] Dual Breath, [2] Ice Path, [3] Liquid Fire (linked with Liquid Ice), [6] Macropyre.
local nAbilityBuildList = {3,1,3,2,3,6,3,2,2,2,6,1,1,1,6}
local nTalentBuildList = J.Skill.GetTalentBuild({
    t10={0,10}, -- +30 Liquid Fire attack-speed slow
    t15={0,10}, -- +175 attack range
    t20={10,0}, -- +25 Macropyre damage
    t25={0,10}, -- +100% Dual Breath damage/range
})
local defaultAbilityBuild, defaultTalentBuild = nAbilityBuildList, nTalentBuildList
X.sBuyList = {'item_double_branches','item_magic_stick','item_tango','item_blood_grenade'}
if sRole == 'pos_4' or sRole == 'pos_5' then
    table.insert(X.sBuyList,'item_ward_sentry')
    if sRole == 'pos_5' then table.insert(X.sBuyList,'item_ward_sentry') end
end
local utility = sRole == 'pos_4' and {'item_cyclone','item_glimmer_cape'} or {'item_glimmer_cape','item_cyclone'}
local core = {'item_magic_wand','item_arcane_boots'}
for _, item in ipairs(core) do table.insert(X.sBuyList,item) end
for _, item in ipairs(utility) do table.insert(X.sBuyList,item) end
local continuation = {'item_force_staff','item_aghanims_shard','item_ultimate_scepter',
    -- Bot policy: natural upgrades and late disables in six persistent slots.
    'item_ultimate_scepter_2','item_wind_waker','item_sheepstick','item_blink'}
for _, item in ipairs(continuation) do table.insert(X.sBuyList,item) end
X.sSellList = {'item_ultimate_scepter','item_magic_wand'}

if J.Role.IsPvNMode() or J.Role.IsAllShadow() then X['sBuyList'], X['sSellList'] = { 'PvN_mage' }, {} end

nAbilityBuildList, nTalentBuildList, X['sBuyList'], X['sSellList'] = J.SetUserHeroInit( nAbilityBuildList, nTalentBuildList, X['sBuyList'], X['sSellList'] )
X['sSkillList'] = J.Skill.GetSkillList( sAbilityList, nAbilityBuildList, sTalentList, nTalentBuildList )
-- Fourth Ice Path point at 10, then the first talent at 11. Preserve custom progressions.
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

--[[

npc_dota_hero_jakiro

"Ability1"		"jakiro_dual_breath"
"Ability2"		"jakiro_ice_path"
"Ability3"		"jakiro_liquid_fire"
"Ability4"		"generic_hidden"
"Ability5"		"generic_hidden"
"Ability6"		"jakiro_macropyre"
"Ability10"		"special_bonus_attack_range_300"
"Ability11"		"special_bonus_spell_amplify_8"
"Ability12"		"special_bonus_exp_boost_40"
"Ability13"		"special_bonus_unique_jakiro_2"
"Ability14"		"special_bonus_unique_jakiro_4"
"Ability15"		"special_bonus_gold_income_25"
"Ability16"		"special_bonus_unique_jakiro_3"
"Ability17"		"special_bonus_unique_jakiro"

modifier_jakiro_dual_breath
modifier_jakiro_dual_breath_slow
modifier_jakiro_dual_breath_burn
modifier_jakiro_ice_path_stun
modifier_jakiro_ice_path
modifier_jakiro_liquidfire
modifier_jakiro_liquid_fire_burn
modifier_jakiro_macropyre
modifier_jakiro_macropyre_burn

--]]

local abilityQ = bot:GetAbilityByName('jakiro_dual_breath')
local abilityW = bot:GetAbilityByName('jakiro_ice_path')
local abilityE = bot:GetAbilityByName('jakiro_liquid_fire')
local abilityAS = bot:GetAbilityByName('jakiro_liquid_ice')
local abilityR = bot:GetAbilityByName('jakiro_macropyre')

local castQDesire, castQTarget
local castWDesire, castWLocation
local castEDesire, castETarget
local castASDesire, castASTarget
local castRDesire, castRLocation

function X.SkillsComplement()
	if J.CanNotUseAbility( bot ) then return end

	castWDesire, castWLocation = X.ConsiderW()
	if ( castWDesire > 0 )
	then

		J.SetQueuePtToINT( bot, true )

		bot:ActionQueue_UseAbilityOnLocation( abilityW, castWLocation )
		return
	end


	castASDesire, castASTarget = X.ConsiderAS()
	if ( castASDesire > 0 )
	then

		J.SetQueuePtToINT( bot, true )

		bot:ActionQueue_UseAbilityOnEntity( abilityAS, castASTarget )
		return
	end
	castRDesire, castRLocation = X.ConsiderR()
	if ( castRDesire > 0 )
	then

		J.SetQueuePtToINT( bot, true )

		bot:ActionQueue_UseAbilityOnLocation( abilityR, castRLocation )
		return
	end

	castQDesire, castQTarget = X.ConsiderQ()
	if ( castQDesire > 0 )
	then

		J.SetQueuePtToINT( bot, true )

		bot:ActionQueue_UseAbilityOnLocation( abilityQ, castQTarget )
		return
	end

	castEDesire, castETarget = X.ConsiderE()
	if ( castEDesire > 0 )
	then

		J.SetQueuePtToINT( bot, true )

		bot:ActionQueue_UseAbilityOnEntity( abilityE, castETarget )
		return
	end




end

function X.ConsiderQ()
    if not J.CanCastAbility(abilityQ) then return 0 end
    local combat, point = K.Line(bot, abilityQ, 'breath')
    if combat > 0 then return combat, point end
    local nCastRange = K.Range(bot, abilityQ)
    local manaCost = abilityQ:GetManaCost()
    local botTarget = J.GetProperTarget(bot)
	local tEnemyLaneCreeps = bot:GetNearbyLaneCreeps(nCastRange, true)

	if J.IsPushing(bot)
	and J.GetManaAfter(manaCost) >= 0.5
	and not J.IsThereCoreNearby(1400)
	then
		if #tEnemyLaneCreeps > 3
		and J.CanBeAttacked(tEnemyLaneCreeps[1])
		then
			return BOT_ACTION_DESIRE_HIGH, J.GetCenterOfUnits(tEnemyLaneCreeps)
		end
	end

	if J.IsDefending(bot)
	and J.GetManaAfter(manaCost) >= 0.35
	then
		if #tEnemyLaneCreeps > 3
		and J.CanBeAttacked(tEnemyLaneCreeps[1])
		then
			return BOT_ACTION_DESIRE_HIGH, J.GetCenterOfUnits(tEnemyLaneCreeps)
		end
	end

	if J.IsFarming(bot)
	and J.GetManaAfter(manaCost) >= 0.4
	then
		local tCreeps = bot:GetNearbyCreeps(nCastRange, true)
		if #tCreeps > 2
		and J.CanBeAttacked(tCreeps[1])
		then
			return BOT_ACTION_DESIRE_HIGH, J.GetCenterOfUnits(tCreeps)
		end
	end

	if J.IsDoingRoshan(bot)
	then
		if  J.IsRoshan(botTarget)
        and J.CanCastOnNonMagicImmune(botTarget)
        and J.IsInRange(bot, botTarget, nCastRange)
        and J.IsAttacking(bot)
		then
			return BOT_ACTION_DESIRE_HIGH, botTarget:GetLocation()
		end
	end

    if J.IsDoingTormentor(bot)
	then
		if  J.IsTormentor(botTarget)
        and J.IsInRange(bot, botTarget, nCastRange)
        and J.IsAttacking(bot)
		then
			return BOT_ACTION_DESIRE_HIGH, botTarget:GetLocation()
		end
	end

	return BOT_ACTION_DESIRE_NONE, 0

end

function X.ConsiderW() return K.Line(bot, abilityW, 'ice') end
function X.ConsiderE() return K.Liquid(bot, abilityE, false) end
function X.ConsiderAS() return K.Liquid(bot, abilityAS, true) end
function X.ConsiderR() return K.Line(bot, abilityR, 'macro') end
return X
