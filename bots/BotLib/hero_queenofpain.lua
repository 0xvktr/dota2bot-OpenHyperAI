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

local J = require( GetScriptDirectory()..'/FunLib/jmz_func')
local Minion = dofile( GetScriptDirectory()..'/FunLib/aba_minion')
local sTalentList = J.Skill.GetTalentList(bot)
local sAbilityList = J.Skill.GetAbilityList(bot)
local sRole = J.Item.GetRoleItemsBuyList(bot)

-- Updated to 7.41f from D2PT: mid; forced other roles use the mid build.
local BuildData = require(GetScriptDirectory()..'/BotLib/Builds/queenofpain')
X.buildMetadata = BuildData
X.neutralPreferences = BuildData.neutrals[sRole]
-- [1] Shadow Strike, [2] Blink, [3] Scream of Pain, [6] Sonic Wave.
local nAbilityBuildList = {3,2,3,2,3,6,3,2,2,1,6,1,1,1,6}
local nTalentBuildList = J.Skill.GetTalentBuild({
    t10={10,0}, -- +7 strength
    t15={0,10}, -- -1s Shadow Strike damage interval
    t20={0,10}, -- +115 Scream of Pain damage
    t25={0,10}, -- -2s Blink cooldown
})
local defaultAbilityBuild, defaultTalentBuild = nAbilityBuildList, nTalentBuildList
X.sBuyList = {
    'item_double_branches','item_double_branches','item_tango','item_faerie_fire',
    'item_bottle','item_null_talisman','item_magic_wand','item_power_treads','item_kaya',
    'item_kaya_and_sange','item_ultimate_scepter','item_aghanims_shard','item_black_king_bar',
    -- Bot policy: consume Scepter; Shiva's, Octarine and Refresher complete six slots.
    'item_ultimate_scepter_2','item_shivas_guard','item_octarine_core','item_refresher',
}
X.sSellList = {'item_kaya_and_sange','item_null_talisman','item_ultimate_scepter','item_magic_wand',
    'item_black_king_bar','item_bottle'}

if J.Role.IsPvNMode() or J.Role.IsAllShadow() then X['sBuyList'],X['sSellList'] = { 'PvN_mage' }, {} end

nAbilityBuildList,nTalentBuildList,X['sBuyList'],X['sSellList'] = J.SetUserHeroInit(nAbilityBuildList,nTalentBuildList,X['sBuyList'],X['sSellList']);

X['sSkillList'] = J.Skill.GetSkillList(sAbilityList, nAbilityBuildList, sTalentList, nTalentBuildList)

-- Observed ability at 10, first talent at 11; preserve custom overrides.
if nAbilityBuildList == defaultAbilityBuild and nTalentBuildList == defaultTalentBuild then
    X.sSkillList[10], X.sSkillList[11] = X.sSkillList[11], X.sSkillList[10]
end

X['bDeafaultAbility'] = false
X['bDeafaultItem'] = true

function X.MinionThink(hMinionUnit)

	if Minion.IsValidUnit(hMinionUnit) 
	then
		Minion.IllusionThink(hMinionUnit)	
	end

end

--[[

npc_dota_hero_queenofpain

"Ability1"		"queenofpain_shadow_strike"
"Ability2"		"queenofpain_blink"
"Ability3"		"queenofpain_scream_of_pain"
"Ability4"		"generic_hidden"
"Ability5"		"generic_hidden"
"Ability6"		"queenofpain_sonic_wave"
"Ability10"		"special_bonus_attack_damage_20"
"Ability11"		"special_bonus_strength_8"
"Ability12"		"special_bonus_cooldown_reduction_10"
"Ability13"		"special_bonus_attack_speed_30"
"Ability14"		"special_bonus_spell_lifesteal_25"
"Ability15"		"special_bonus_unique_queen_of_pain"
"Ability16"		"special_bonus_unique_queen_of_pain_2"
"Ability17"		"special_bonus_spell_block_18"

modifier_queenofpain_shadow_strike
modifier_queenofpain_scream_of_pain_fear

--]]

local Q = require(GetScriptDirectory()..'/FunLib/queenofpain_abilities')
local abilityQ = bot:GetAbilityByName('queenofpain_shadow_strike')
local abilityW = bot:GetAbilityByName('queenofpain_blink')
local abilityE = bot:GetAbilityByName('queenofpain_scream_of_pain')
local abilityR = bot:GetAbilityByName('queenofpain_sonic_wave')
local talent6 = bot:GetAbilityByName( sTalentList[6] )

local castQDesire, castQTarget
local castWDesire, castWTarget
local castEDesire, castETarget
local castRDesire, castRTarget


local nKeepMana,nMP,nHP,nLV,hEnemyList,hAllyList,botTarget,sMotive;



function X.SkillsComplement()
    if J.CanNotUseAbility(bot) or bot:IsInvisible() then return end
    nKeepMana=400;nLV=bot:GetLevel();nMP=J.GetMP(bot);nHP=J.GetHP(bot)
    botTarget=J.GetProperTarget(bot);hEnemyList=J.GetNearbyHeroes(bot,1600,true,BOT_MODE_NONE);hAllyList=J.GetAlliesNearLoc(bot:GetLocation(),1600)
    local desire,point=Q.Blink(bot,abilityW,true)
    if desire>0 then bot:Action_UseAbilityOnLocation(abilityW,point);return end
    desire,point=Q.Wave(bot,abilityR)
    if desire>0 then J.SetQueuePtToINT(bot,true,abilityR);bot:ActionQueue_UseAbilityOnLocation(abilityR,point);return end
    if Q.Scream(bot,abilityE)>0 then J.SetQueuePtToINT(bot,true,abilityE);bot:ActionQueue_UseAbility(abilityE);return end
    local target,shape
    desire,target,shape=Q.Strike(bot,abilityQ)
    if desire>0 then
        J.SetQueuePtToINT(bot,true,abilityQ)
        if shape=='point' then bot:ActionQueue_UseAbilityOnLocation(abilityQ,target) else bot:ActionQueue_UseAbilityOnEntity(abilityQ,target) end
        return
    end
    desire,target=X.ConsiderQ()
    if desire>0 then
        J.SetQueuePtToINT(bot,true,abilityQ)
        if abilityQ:GetSpecialValueInt('aoe_radius')>0 then bot:ActionQueue_UseAbilityOnLocation(abilityQ,target:GetLocation()) else bot:ActionQueue_UseAbilityOnEntity(abilityQ,target) end
        return
    end
    if X.ConsiderE()>0 then J.SetQueuePtToINT(bot,true,abilityE);bot:ActionQueue_UseAbility(abilityE);return end
    desire,point=Q.Blink(bot,abilityW)
    if desire>0 then bot:Action_UseAbilityOnLocation(abilityW,point) end
end

function X.ConsiderQ()
    if not J.CanCastAbility(abilityQ) then return 0 end
    local nManaCost=abilityQ:GetManaCost();local nCastRange=Q.Range(bot,abilityQ)
    local hCastTarget,sCastMotive
	if J.IsFarming( bot )
		-- and DotaTime() > 4 * 60
		and J.IsAllowedToSpam( bot, nManaCost )
	then
		local creepList = bot:GetNearbyNeutralCreeps( nCastRange )

		local targetCreep = J.GetMostHpUnit( creepList )

		if J.IsValid( targetCreep )
			and #creepList >= 2 
			and not J.IsOtherAllysTarget( targetCreep )
			and J.CanCastOnNonMagicImmune(targetCreep)
			and targetCreep:GetMagicResist() < 0.4
			and not J.CanKillTarget( targetCreep, bot:GetAttackDamage() * 5, DAMAGE_TYPE_PHYSICAL )
		then
			hCastTarget = targetCreep
			sCastMotive = 'Q-打野:'..J.Chat.GetNormName( hCastTarget )
			return BOT_ACTION_DESIRE_HIGH, hCastTarget, sCastMotive
		end
	end
	
	if J.IsDoingRoshan(bot)
	then
		if J.IsRoshan( botTarget )
		and J.IsInRange( botTarget, bot, nCastRange )
		and J.CanCastOnNonMagicImmune(botTarget)
		and J.IsAttacking(bot)
		and not botTarget:HasModifier('modifier_roshan_spell_block')
		then
			return BOT_ACTION_DESIRE_HIGH, botTarget, ''
		end
	end

    if J.IsDoingTormentor(bot)
	then
		if J.IsTormentor(botTarget)
        and J.IsInRange( botTarget, bot, nCastRange )
        and J.CanCastOnNonMagicImmune(botTarget)
        and J.IsAttacking(bot)
		then
			return BOT_ACTION_DESIRE_HIGH, botTarget, ''
		end
	end
	
	return BOT_ACTION_DESIRE_NONE;
	
	
end

function X.ConsiderW() return Q.Blink(bot,abilityW) end

function X.ConsiderE()
    if not J.CanCastAbility(abilityE) then return 0 end
    local nRadius=abilityE:GetSpecialValueInt('area_of_effect');local nManaCost=abilityE:GetManaCost()
    local nDamage=abilityE:GetSpecialValueInt('damage');local nDamageType=DAMAGE_TYPE_MAGICAL;local nCastPoint=abilityE:GetCastPoint()
    local nInRangeEnemyList=J.GetNearbyHeroes(bot,nRadius,true,BOT_MODE_NONE)
    -- Combat and its current reflected-health budget are handled before farm decisions.
    if #nInRangeEnemyList>0 then return 0 end
    local hCastTarget,sCastMotive
	if J.IsLaning( bot ) and J.IsAllowedToSpam(bot, nManaCost)
	then
		local nCanKillMeleeCount = 0
		local nCanKillRangedCount = 0
		local hLaneCreepList = bot:GetNearbyLaneCreeps( nRadius, true )
		for _, creep in pairs( hLaneCreepList )
		do
			if J.IsValid( creep )
				and not creep:HasModifier( "modifier_fountain_glyph" )
				and not J.IsOtherAllysTarget( creep )
			then
				local lastHitDamage = nDamage
				local nDelay = nCastPoint + GetUnitToUnitDistance( bot, creep )/900
						
				if J.WillKillTarget( creep, lastHitDamage, nDamageType, nDelay )
				then
					if J.IsKeyWordUnit( 'ranged', creep )
					then
						nCanKillRangedCount = nCanKillRangedCount + 1
					end

					if J.IsKeyWordUnit( 'melee', creep )
					then
						nCanKillMeleeCount = nCanKillMeleeCount + 1
					end

				end
			end
		end

		if nCanKillMeleeCount + nCanKillRangedCount >= 3
		then
			return BOT_ACTION_DESIRE_HIGH, bot, 'E对线1'
		end

		if nCanKillRangedCount >= 1 and nCanKillMeleeCount >= 1
		then
			return BOT_ACTION_DESIRE_HIGH, bot, 'E对线2'
		end

		if #hLaneCreepList == 0
			and J.IsValidHero( nInRangeEnemyList[1] )
			and J.CanCastOnNonMagicImmune( nInRangeEnemyList[1] )
			and nMP > 0.5
		then
			return BOT_ACTION_DESIRE_HIGH, bot, 'E消耗'	
		end
	end
	

	if ( J.IsPushing( bot ) or J.IsDefending( bot ) )
		and J.IsAllowedToSpam( bot, nManaCost * 0.32 )
		and #hAllyList <= 3
	then
		local laneCreepList = bot:GetNearbyLaneCreeps( nRadius , true )
		if ( #laneCreepList >= 4 or ( #laneCreepList >= 3 and nMP > 0.82 ) )
			and not laneCreepList[1]:HasModifier( "modifier_fountain_glyph" )
		then			
			hCastTarget = botTarget
			sCastMotive = 'E-带线AOE'..(#laneCreepList)
			return BOT_ACTION_DESIRE_HIGH, hCastTarget, sCastMotive
		end
	end
	
	

	if J.IsFarming( bot )
	and J.IsAllowedToSpam( bot, nManaCost * 0.25 )
	then
		local creepList = bot:GetNearbyNeutralCreeps( nRadius )

		if #creepList >= 2
			and J.IsValid( botTarget )
		then
			hCastTarget = botTarget
			sCastMotive = 'E-打野AOE'..(#creepList)
			return BOT_ACTION_DESIRE_HIGH, hCastTarget, sCastMotive
	    end
	end
	
	if J.IsDoingRoshan(bot)
	then
		if J.IsRoshan( botTarget )
		and J.IsInRange( botTarget, bot, nRadius )
		and J.CanCastOnNonMagicImmune(botTarget)
		and J.IsAttacking(bot)
		then
			return BOT_ACTION_DESIRE_HIGH
		end
	end

    if J.IsDoingTormentor(bot)
	then
		if J.IsTormentor(botTarget)
        and J.IsInRange( botTarget, bot, nRadius )
        and J.CanCastOnNonMagicImmune(botTarget)
        and J.IsAttacking(bot)
		then
			return BOT_ACTION_DESIRE_HIGH
		end
	end

	return BOT_ACTION_DESIRE_NONE;
	
	
end

function X.ConsiderR() return Q.Wave(bot,abilityR) end
return X
