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
local H = require(GetScriptDirectory()..'/FunLib/huskar_abilities')
local Minion = dofile( GetScriptDirectory()..'/FunLib/aba_minion' )
local sTalentList = J.Skill.GetTalentList( bot )
local sAbilityList = J.Skill.GetAbilityList( bot )
local sRole = J.Item.GetRoleItemsBuyList( bot )

-- Updated to 7.41f from D2PT: mid only; forced other roles use mid.
local BuildData = require(GetScriptDirectory()..'/BotLib/Builds/huskar')
X.buildMetadata = BuildData
X.neutralPreferences = BuildData.neutrals[sRole]
-- [1] Inner Fire, [2] Burning Spear, [3] Berserker's Blood, [6] Life Break.
local nAbilityBuildList = {2,3,3,2,3,6,3,1,2,2,6,1,1,1,6}
local nTalentBuildList = J.Skill.GetTalentBuild({
    t10={0,10}, -- +0.75s Inner Fire duration
    t15={10,0}, -- +12% lifesteal
    t20={0,10}, -- +30% Berserker's Blood regeneration
    t25={10,0}, -- +22% Life Break damage
})
local defaultAbilityBuild, defaultTalentBuild = nAbilityBuildList, nTalentBuildList
X.sBuyList = {
    'item_double_gauntlets','item_gauntlets','item_tango','item_faerie_fire',
    'item_helm_of_iron_will','item_magic_wand','item_armlet','item_power_treads',
    'item_blink','item_black_king_bar','item_aghanims_shard','item_ultimate_scepter',
    -- Bot policy: consume Scepter, then reach/sustain and a natural Blink upgrade.
    'item_ultimate_scepter_2','item_dragon_lance','item_hurricane_pike','item_satanic',
    'item_overwhelming_blink','item_moon_shard',
}
X.sSellList = {'item_satanic','item_magic_wand'}

if J.Role.IsPvNMode() or J.Role.IsAllShadow() then X['sBuyList'], X['sSellList'] = { 'PvN_huskar' }, {} end

nAbilityBuildList, nTalentBuildList, X['sBuyList'], X['sSellList'] = J.SetUserHeroInit( nAbilityBuildList, nTalentBuildList, X['sBuyList'], X['sSellList'] )
X['sSkillList'] = J.Skill.GetSkillList( sAbilityList, nAbilityBuildList, sTalentList, nTalentBuildList )
-- Fourth Burning Spear point at 10, then the first talent at 11. Preserve custom progressions.
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

npc_dota_hero_huskar

"Ability1"		"huskar_inner_fire"
"Ability2"		"huskar_burning_spear"
"Ability3"		"huskar_berserkers_blood"
"Ability4"		"generic_hidden"
"Ability5"		"generic_hidden"
"Ability6"		"huskar_life_break"
"Ability10"		"special_bonus_hp_225"
"Ability11"		"special_bonus_attack_damage_15"
"Ability12"		"special_bonus_unique_huskar_2"
"Ability13"		"special_bonus_lifesteal_20"
"Ability14"		"special_bonus_strength_20"
"Ability15"		"special_bonus_unique_huskar"
"Ability16"		"special_bonus_attack_range_175"
"Ability17"		"special_bonus_unique_huskar_5"

modifier_huskar_inner_fire_knockback
modifier_huskar_inner_fire_disarm
modifier_huskar_inner_vitality
modifier_huskar_burning_spear_self
modifier_huskar_burning_spear_counter
modifier_huskar_burning_spear_debuff
modifier_huskar_berserkers_blood
modifier_huskar_life_break_charge
modifier_huskar_life_break_slow

--]]


local abilityQ = bot:GetAbilityByName('huskar_inner_fire')
local abilityW = bot:GetAbilityByName('huskar_burning_spear')
local abilityE = bot:GetAbilityByName('huskar_berserkers_blood')
local abilityR = bot:GetAbilityByName('huskar_life_break')
local talent6 = bot:GetAbilityByName( sTalentList[6] )
local abilityH = nil

local castQDesire
local castWDesire, castWTarget
local castRDesire, castRTarget
local castHWDesire, castHWTarget

local nKeepMana, nMP, nHP, nLV, hEnemyList, hAllyList, botTarget, sMotive
local aetherRange = 0
local talent6Range = 0


function X.SkillsComplement()
    if J.CanNotUseAbility(bot) or bot:IsInvisible() then return end
    botTarget = J.GetProperTarget(bot)
    nLV = bot:GetLevel()
    nHP = J.GetHP(bot)
    hEnemyList = J.GetNearbyHeroes(bot, 1600, true, BOT_MODE_NONE)
    hAllyList = J.GetAlliesNearLoc(bot:GetLocation(), 1600)
    -- Spear autocast is updated even when current health makes an attack uncastable.
    H.Spears(bot, abilityW)
    if X.ConsiderBlood() > 0 then bot:Action_UseAbility(abilityE); return end
    if X.ConsiderQ() > 0 then bot:Action_UseAbility(abilityQ); return end
    local desire, target = X.ConsiderR()
    if desire > 0 then bot:Action_UseAbilityOnEntity(abilityR, target); return end
    desire, target = X.ConsiderW()
    if desire > 0 then bot:Action_UseAbilityOnEntity(abilityW, target) end
end
function X.ConsiderHW()
    -- Item policy owns Pike; never queue four health-cost attacks before observing its buff.
    return 0
end
function X.ConsiderBlood() return H.Cauterize(bot, abilityE) end

function X.ConsiderQ()
    if not J.CanCastAbility(abilityQ) or bot:GetHealth()-abilityQ:GetSpecialValueInt('health_cost') < bot:GetMaxHealth()*0.15 then return 0 end
    local combat = H.Fire(bot, abilityQ)
    if combat > 0 then return combat end
    local nSkillLV = abilityQ:GetLevel()
    local nCastPoint = abilityQ:GetCastPoint()
    local nManaCost = abilityQ:GetManaCost()
    local nDamage = abilityQ:GetSpecialValueInt('damage')
    local nRadius = abilityQ:GetSpecialValueInt('radius')
    local nDamageType = DAMAGE_TYPE_MAGICAL
	--对线
	if J.IsLaning( bot )
	then
		local nLaneCreepList = bot:GetNearbyLaneCreeps( nRadius, true )
		local nCanKillCount = 0
		for _, creep in pairs( nLaneCreepList )
		do
			if J.IsValid( creep )
				and not creep:HasModifier( 'modifier_fountain_glyph' )
				and J.WillKillTarget( creep, nDamage, nDamageType, nCastPoint )
			then
				nCanKillCount = nCanKillCount + 1
			end
		end
		if nCanKillCount >= 2
		then
			return BOT_ACTION_DESIRE_HIGH, "Q对线补刀:"..nCanKillCount
		end
	end


	--打钱
	if J.IsFarming( bot ) and nLV >= 8
		and J.IsAllowedToSpam( bot, nManaCost )
	then
		local nCreepList = bot:GetNearbyNeutralCreeps( nRadius )
		local targetCreep = nCreepList[1]
		if #nCreepList >= 2
			and J.IsValid( targetCreep )
			and not J.CanKillTarget( targetCreep, bot:GetAttackDamage() * 2.2, DAMAGE_TYPE_PHYSICAL )
		then
			return BOT_ACTION_DESIRE_HIGH, "Q打钱:"..#nCreepList
		end
	end


	--带线
	if #hEnemyList == 0 and #hAllyList <= 2 and nSkillLV >= 3 and nLV >= 8
		and J.IsAllowedToSpam( bot, nManaCost )
		and ( J.IsPushing( bot ) or J.IsDefending( bot ) or J.IsFarming( bot ) )
	then
		local nLaneCreepList = bot:GetNearbyLaneCreeps( nRadius, true )
		local nCanKillCount = 0
		local nCanHurtCount = 0
		for _, creep in pairs( nLaneCreepList )
		do
			if J.IsValid( creep )
				and not creep:HasModifier( 'modifier_fountain_glyph' )
			then
				nCanHurtCount = nCanHurtCount + 1

				if J.WillKillTarget( creep, nDamage, nDamageType, nCastPoint )
				then
					nCanKillCount = nCanKillCount + 1
				end
			end
		end

		if nCanKillCount >= 2
		then
			return BOT_ACTION_DESIRE_HIGH, "Q带线补兵:"..nCanKillCount
		end
		if nCanHurtCount >= 4
		then
			return BOT_ACTION_DESIRE_HIGH, "Q带线清兵:"..nCanHurtCount
		end

	end

	--肉山
	if J.IsDoingRoshan( bot )
	then
		if J.IsRoshan( botTarget )
			and J.IsInRange( bot, botTarget, nRadius)
			and J.GetHP( botTarget ) > 0.3
            and J.GetHP(bot) > 0.45
            and J.IsAttacking(bot)
		then
			return BOT_ACTION_DESIRE_HIGH
		end
	end

    if J.IsDoingTormentor( bot )
	then
		if J.IsTormentor( botTarget )
			and J.IsInRange( bot, botTarget, nRadius)
            and J.GetHP(bot) > 0.45
            and J.IsAttacking(bot)
		then
			return BOT_ACTION_DESIRE_HIGH
		end
	end


	return BOT_ACTION_DESIRE_NONE


end


function X.ConsiderW() return H.Spears(bot, abilityW) end
function X.ConsiderR() return H.Break(bot, abilityR) end
return X
