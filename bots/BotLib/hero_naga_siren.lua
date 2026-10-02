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

-- Updated to 7.41f from D2PT; forced skipped roles use pos 1.
local BuildData = require(GetScriptDirectory()..'/BotLib/Builds/naga_siren')
X.buildMetadata = BuildData
X.neutralPreferences = BuildData.neutrals[sRole]
-- [1] Mirror Image, [2] Ensnare, [3] Rip Tide, [6] Song of the Siren.
local nAbilityBuildList = {1,3,1,2,1,3,1,3,3,6,6,2,2,2,6}
local nTalentBuildList = J.Skill.GetTalentBuild({
    t10={10,0}, -- Rip Tide damage
    t15={0,10}, -- Mirror Image damage
    t20={10,0}, -- Additional Mirror Image illusion
    t25={0,10}, -- Mirror Image cooldown
})
local defaultAbilityBuild, defaultTalentBuild = nAbilityBuildList, nTalentBuildList
X.sBuyList = {
    'item_quelling_blade','item_slippers','item_double_branches','item_circlet','item_tango',
    'item_wraith_band','item_power_treads','item_yasha','item_manta','item_orchid',
    'item_heart','item_bloodthorn',
    -- Bot policy: late upgrades and continuation.
    'item_butterfly','item_skadi','item_aghanims_shard','item_ultimate_scepter','item_ultimate_scepter_2',
    'item_moon_shard',
}
X.sSellList = {'item_manta','item_quelling_blade','item_heart','item_wraith_band'}

if J.Role.IsPvNMode() or J.Role.IsAllShadow() then X['sBuyList'],X['sSellList'] = { 'PvN_PL' }, {"item_manta",'item_quelling_blade'} end

nAbilityBuildList,nTalentBuildList,X['sBuyList'],X['sSellList'] = J.SetUserHeroInit(nAbilityBuildList,nTalentBuildList,X['sBuyList'],X['sSellList']);

X['sSkillList'] = J.Skill.GetSkillList(sAbilityList, nAbilityBuildList, sTalentList, nTalentBuildList)
-- D2PT takes an ability at 10, then the first talent at 11.
if nAbilityBuildList == defaultAbilityBuild and nTalentBuildList == defaultTalentBuild then
    X.sSkillList[10], X.sSkillList[11] = X.sSkillList[11], X.sSkillList[10]
end

X['bDeafaultAbility'] = false
X['bDeafaultItem'] = false

function X.MinionThink(hMinionUnit)

	if Minion.IsValidUnit(hMinionUnit)
	then
		if hMinionUnit:IsIllusion() then hMinionUnit.isIllusion = true end
		Minion.IllusionThink(hMinionUnit)
	end

end

--[[


npc_dota_hero_naga_siren


"Ability1"		"naga_siren_mirror_image"
"Ability2"		"naga_siren_ensnare"
"Ability3"		"naga_siren_rip_tide"
"Ability4"		"generic_hidden"
"Ability5"		"generic_hidden"
"Ability6"		"naga_siren_song_of_the_siren"
"Ability7"		"naga_siren_song_of_the_siren_cancel"
"Ability10"		"special_bonus_movement_speed_20"
"Ability11"		"special_bonus_unique_naga_siren_4"
"Ability12"		"special_bonus_agility_10"
"Ability13"		"special_bonus_strength_13"
"Ability14"		"special_bonus_unique_naga_siren_2"
"Ability15"		"special_bonus_unique_naga_siren"
"Ability16"		"special_bonus_evasion_25"
"Ability17"		"special_bonus_unique_naga_siren_3"

modifier_naga_siren_mirror_image
modifier_naga_siren_ensnare
modifier_naga_siren_rip_tide_passive
modifier_naga_siren_rip_tide
modifier_naga_siren_song_of_the_siren_aura
modifier_naga_siren_song_of_the_siren
modifier_naga_siren_song_of_the_siren_ignore_me

--]]

local abilityQ = bot:GetAbilityByName( sAbilityList[1] )
local abilityW = bot:GetAbilityByName( sAbilityList[2] )
local abilityE = bot:GetAbilityByName( sAbilityList[3] )
local abilityR = bot:GetAbilityByName( sAbilityList[6] )
local abilitySR = bot:GetAbilityByName( 'naga_siren_song_of_the_siren_cancel' )
local ReelIn = bot:GetAbilityByName( 'naga_siren_reel_in' )

local castQDesire, castQTarget
local castWDesire, castWTarget
local castEDesire, castETarget
local castRDesire, castRTarget
local castSRDesire, castSRTarget
local ReelInDesire

local nKeepMana,nMP,nHP,nLV,hEnemyList,hAllyList,botTarget,sMotive;
local aetherRange = 0

function X.SkillsComplement()


	if J.CanNotUseAbility(bot) or bot:IsInvisible() or bot:IsChanneling() then return end
	
	
	nKeepMana = 400
	aetherRange = 0
	nLV = bot:GetLevel();
	nMP = bot:GetMana()/bot:GetMaxMana();
	nHP = bot:GetHealth()/bot:GetMaxHealth();
	botTarget = J.GetProperTarget(bot);
	hEnemyList = J.GetNearbyHeroes(bot,1600, true, BOT_MODE_NONE);
	hAllyList = J.GetAlliesNearLoc(bot:GetLocation(), 1600);
	
	
	local aether = J.IsItemAvailable("item_aether_lens");
	if aether ~= nil then aetherRange = aether:GetSpecialValueInt('cast_range_bonus') end
	
	
    -- Finish or begin an escape/reset before spending time on ordinary damage.
    castSRDesire = X.ConsiderSR()
    if castSRDesire > 0 then bot:Action_UseAbility(abilitySR); return end
    castRDesire = X.ConsiderR()
    if castRDesire > 0 then
        J.SetQueuePtToINT(bot, true)
        bot:ActionQueue_UseAbility(abilityR)
        return
    end

	castQDesire, castQTarget, sMotive = X.ConsiderQ();
	if ( castQDesire > 0 ) 
	then
		J.SetReportMotive(bDebugMode,sMotive);		
	
		J.SetQueuePtToINT(bot, false, abilityQ)
	
		bot:ActionQueue_UseAbility( abilityQ )
		return;
	end
	
	castWDesire, castWTarget, sMotive = X.ConsiderW();
	if ( castWDesire > 0 ) 
	then
		J.SetReportMotive(bDebugMode,sMotive);
	
		J.SetQueuePtToINT(bot, true)
	
		bot:ActionQueue_UseAbilityOnEntity( abilityW, castWTarget )
		return;
	end

	ReelInDesire = X.ConsiderReelIn()
	if (ReelInDesire > 0)
	then
		J.SetQueuePtToINT(bot, true)
		bot:Action_UseAbility(ReelIn)
		return;
	end
	

end


function X.ConsiderQ()


	if not J.CanCastAbility(abilityQ) then return 0 end
    -- Mirror Image provides a basic dispel even when there is no attack target.
    if bot:IsRooted() or bot:HasModifier('modifier_bounty_hunter_track')
        or bot:HasModifier('modifier_slardar_amplify_damage') then
        return BOT_ACTION_DESIRE_HIGH, bot, 'Mirror dispel'
    end
	
	local nSkillLV    = abilityQ:GetLevel(); 
	local nCastRange  = abilityQ:GetCastRange()
	local nCastPoint  = abilityQ:GetCastPoint()
	local nManaCost   = abilityQ:GetManaCost()
	local nDamage     = abilityQ:GetAbilityDamage()
	local nDamageType = DAMAGE_TYPE_MAGICAL
	local nInRangeEnemyList = J.GetAroundEnemyHeroList( 800 )
	local nInBonusEnemyList = J.GetAroundEnemyHeroList( 1200 )
	local hCastTarget = nil
	local sCastMotive = nil
	
	
	if J.IsInTeamFight( bot, 1000 )
	then
		if #nInBonusEnemyList >= 2
		then
			hCastTarget = nInBonusEnemyList[1]
			sCastMotive = 'Q-团战'..J.Chat.GetNormName( hCastTarget )
			return BOT_ACTION_DESIRE_HIGH, hCastTarget,sCastMotive	
		end
	end
	
	
	--攻击
	if J.IsGoingOnSomeone( bot )
	then
		if J.IsValidHero( botTarget )
			and J.IsInRange( bot, botTarget, 700 )
		then
			hCastTarget = botTarget
			sCastMotive = 'Q-攻击:'..J.Chat.GetNormName( hCastTarget )
			return BOT_ACTION_DESIRE_HIGH, hCastTarget,sCastMotive	
		end
	end
	
	
	--对线 
	if J.IsLaning( bot )
	then
		local attackTarget = bot:GetAttackTarget()
		if J.IsValidHero( attackTarget )
			and J.IsInRange( bot, attackTarget, 600 )
		then
			hCastTarget = attackTarget
			sCastMotive = 'Q-对线'
			return BOT_ACTION_DESIRE_HIGH, hCastTarget, sCastMotive		
		end	
		
		if bot:WasRecentlyDamagedByAnyHero( 1.0 )
			and #nInRangeEnemyList >= 1
			and nMP > 0.4
		then
			hCastTarget = bot
			sCastMotive = 'Q-对线防御伤害'
			return BOT_ACTION_DESIRE_HIGH, hCastTarget, sCastMotive	
		end		
	end
	
	
	--打钱
	if J.IsFarming( bot )
	then
		local targetCreep = bot:GetAttackTarget()
		if J.IsValid( targetCreep )
			and not targetCreep:HasModifier( 'modifier_fountain_glyph' )
			and J.IsInRange( bot, targetCreep, 500 )
		then
			return BOT_ACTION_DESIRE_HIGH, targetCreep, "Q-打钱"
		end
	end
	
	
	--推线推塔
	if ( J.IsPushing( bot ) or J.IsDefending( bot ) or J.IsFarming( bot ) )
	then
		local laneCreepList = bot:GetNearbyLaneCreeps( 800, true )
		local enemyTowerList = bot:GetNearbyTowers( 800, true )
		local enemyBarrackList = bot:GetNearbyBarracks( 800, true )
		if #laneCreepList >= 1 or #enemyTowerList >= 1 or #enemyBarrackList >= 1
		then
			if botTarget ~= nil
			then
				hCastTarget = botTarget
				sCastMotive = 'Q-推线推塔'
				return BOT_ACTION_DESIRE_HIGH, hCastTarget, sCastMotive
			end
		end
		
		local attackTarget = bot:GetAttackTarget()
		if J.IsValidBuilding( attackTarget )
			and attackTarget:GetTeam() ~= bot:GetTeam()
		then
			hCastTarget = attackTarget
			sCastMotive = 'Q-拆建筑'
			return BOT_ACTION_DESIRE_HIGH, hCastTarget, sCastMotive		
		end
	end
	
	
	
	--撤退时掩护
	if J.IsRetreating( bot ) 
		and #nInRangeEnemyList >= 1
	then
		for _, npcEnemy in pairs( nInRangeEnemyList )
		do
			if J.IsValid( npcEnemy )
				and J.CanCastOnMagicImmune( npcEnemy )
			then
				hCastTarget = npcEnemy
				sCastMotive = 'Q-撤退时掩护'..J.Chat.GetNormName( hCastTarget )
				return BOT_ACTION_DESIRE_HIGH, hCastTarget, sCastMotive
			end
		end
	end
	
	
	--通用的情况
	if nSkillLV >= 4
		and J.IsAllowedToSpam( bot, 80 )
	then
		local enemyCreepList = bot:GetNearbyCreeps(1600, true)
		local enemyTowerList = bot:GetNearbyTowers(1600, true)
		if #enemyCreepList >= 1
			or #enemyTowerList >= 1
			or #hEnemyList >= 1
		then
			hCastTarget = bot
			sCastMotive = 'Q-通用的情况'
			return BOT_ACTION_DESIRE_HIGH, hCastTarget, sCastMotive
		end
	end
	
	if J.IsDoingRoshan(bot)
	then
		if J.IsRoshan( botTarget )
		and J.IsInRange( botTarget, bot, 800 )
		and J.CanBeAttacked(botTarget)
		and J.IsAttacking(bot)
		then
			return BOT_ACTION_DESIRE_HIGH
		end
	end

    if J.IsDoingTormentor(bot)
	then
		if J.IsTormentor(botTarget)
        and J.IsInRange( botTarget, bot, 800 )
        and J.IsAttacking(bot)
		then
			return BOT_ACTION_DESIRE_HIGH
		end
	end
	
	return BOT_ACTION_DESIRE_NONE
	
end


local function CanEnsnare(enemy)
    local sleeping = J.IsValidHero(enemy) and enemy:HasModifier('modifier_naga_siren_song_of_the_siren')
    return J.IsValidHero(enemy) and not J.IsSuspiciousIllusion(enemy)
        and (sleeping or J.CanCastOnTargetAdvanced(enemy))
        and (not enemy:IsInvulnerable() or sleeping)
        and (not enemy:IsMagicImmune() or bot:HasScepter())
        and not enemy:HasModifier('modifier_naga_siren_ensnare')
        and J.IsInRange(bot, enemy, abilityW:GetCastRange() + aetherRange)
end

function X.ConsiderW()
    if not J.CanCastAbility(abilityW) then return 0 end
    local enemies = J.GetNearbyHeroes(bot, math.min(abilityW:GetCastRange() + aetherRange, 1600), true, BOT_MODE_NONE)
    for _, enemy in ipairs(enemies) do
        if CanEnsnare(enemy) and enemy:IsChanneling() then
            return BOT_ACTION_DESIRE_HIGH, enemy, 'Ensnare interrupt'
        end
    end
    if J.IsGoingOnSomeone(bot) and CanEnsnare(botTarget)
        and (not J.IsDisabled(botTarget) or botTarget:HasModifier('modifier_naga_siren_song_of_the_siren')) then
        return BOT_ACTION_DESIRE_HIGH, botTarget, 'Ensnare follow-up'
    end
    if J.IsRetreating(bot) and bot:WasRecentlyDamagedByAnyHero(3) then
        for _, enemy in ipairs(enemies) do
            if CanEnsnare(enemy) and not J.IsDisabled(enemy) and J.IsChasingTarget(enemy, bot) then
                return BOT_ACTION_DESIRE_HIGH, enemy, 'Ensnare escape'
            end
        end
    end
    return 0
end

function X.ConsiderR()
    if not J.CanCastAbility(abilityR) then return 0 end
    local radius = abilityR:GetSpecialValueInt('radius')
    local enemies = J.GetNearbyHeroes(bot, math.min(radius, 1600), true, BOT_MODE_NONE)
    local affected = 0
    for _, enemy in ipairs(enemies) do
        if J.IsValidHero(enemy) and not J.IsSuspiciousIllusion(enemy)
            and J.CanCastOnNonMagicImmune(enemy) and J.IsInRange(bot, enemy, radius) then
            affected = affected + 1
        end
    end
    if affected == 0 then return 0 end
    if J.IsRetreating(bot) and bot:WasRecentlyDamagedByAnyHero(3)
        and (J.GetHP(bot) < 0.5 or affected >= 2) then return BOT_ACTION_DESIRE_HIGH end
    for _, ally in ipairs(J.GetNearbyHeroes(bot, math.min(radius, 1600), false, BOT_MODE_NONE)) do
        if J.IsValidHero(ally) and not ally:IsIllusion() and J.GetHP(ally) < 0.3
            and J.IsRetreating(ally) and ally:WasRecentlyDamagedByAnyHero(2)
            and not ally:HasModifier('modifier_ice_blast') then return BOT_ACTION_DESIRE_HIGH end
    end
    -- Song makes enemies invulnerable: only set up isolated, distant targets with a nearby ally.
    if J.IsGoingOnSomeone(bot) and J.IsValidHero(botTarget) and J.CanCastOnNonMagicImmune(botTarget)
        and J.IsInRange(bot, botTarget, radius) and not J.IsInRange(bot, botTarget, 800)
        and not botTarget:WasRecentlyDamagedByAnyHero(3) then
        local allies = J.GetNearbyHeroes(bot, math.min(radius, 1600), false, BOT_MODE_NONE)
        if #allies >= 1 and affected <= #allies + 1 then return BOT_ACTION_DESIRE_HIGH end
    end
    return 0
end

function X.ConsiderSR()
    if not J.CanCastAbility(abilitySR) then return 0 end
    local radius = abilityR:GetSpecialValueInt('radius')
    local sleeping = {}
    for _, enemy in ipairs(J.GetNearbyHeroes(bot, math.min(radius, 1600), true, BOT_MODE_NONE)) do
        if J.IsValidHero(enemy) and enemy:HasModifier('modifier_naga_siren_song_of_the_siren') then
            sleeping[#sleeping + 1] = enemy
        end
    end
    -- Keep an escape Song running until its victims leave the aura.
    if #sleeping == 0 then
        if J.GetHP(bot) < 0.8 and not bot:HasModifier('modifier_ice_blast') then return 0 end
        for _, ally in ipairs(J.GetNearbyHeroes(bot, math.min(radius, 1600), false, BOT_MODE_NONE)) do
            if J.IsValidHero(ally) and not ally:IsIllusion() and J.GetHP(ally) < 0.8
                and not ally:HasModifier('modifier_ice_blast') then return 0 end
        end
        return BOT_ACTION_DESIRE_HIGH
    end
    if J.IsRetreating(bot) then return 0 end
    if J.IsGoingOnSomeone(bot) and J.IsValidHero(botTarget)
        and botTarget:HasModifier('modifier_naga_siren_song_of_the_siren')
        and J.IsInRange(bot, botTarget, 350) then
        local ready = 0
        for _, ally in ipairs(J.GetNearbyHeroes(bot, 600, false, BOT_MODE_NONE)) do
            if J.IsValidHero(ally) and not ally:IsIllusion() and J.IsInRange(ally, botTarget, 600) then ready = ready + 1 end
        end
        if ready >= #sleeping then return BOT_ACTION_DESIRE_HIGH end
    end
    return 0
end

function X.ConsiderReelIn()
    if not J.CanCastAbility(ReelIn) or J.IsRetreating(bot) or bot:IsChanneling()
        or J.IsInTeamFight(bot, 1400) then return 0 end
    local radius = ReelIn:GetSpecialValueInt('radius')
    local enemies = J.GetNearbyHeroes(bot, math.min(radius, 1600), true, BOT_MODE_NONE)
    local allies = J.GetNearbyHeroes(bot, math.min(radius, 1600), false, BOT_MODE_NONE)
    for _, enemy in ipairs(enemies) do
        if J.IsValidHero(enemy) and not J.IsSuspiciousIllusion(enemy)
            and (not enemy:IsMagicImmune() or bot:HasScepter())
            and J.IsInRange(bot, enemy, radius) and not J.IsInRange(bot, enemy, bot:GetAttackRange() + 150)
            and enemy:HasModifier('modifier_naga_siren_ensnare') and #allies + 1 >= #enemies then
            local index = enemy:GetModifierByName('modifier_naga_siren_ensnare')
            if abilityW ~= nil and index >= 0 and enemy:GetModifierSourceAbility(index) == abilityW then return BOT_ACTION_DESIRE_HIGH end
        end
    end
    return 0
end

return X
