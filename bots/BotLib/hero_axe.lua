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
local Minion = dofile( GetScriptDirectory()..'/FunLib/aba_minion' )
local sTalentList = J.Skill.GetTalentList( bot )
local sAbilityList = J.Skill.GetAbilityList( bot )
local sRole = J.Item.GetRoleItemsBuyList( bot )

-- Updated to 7.41f from D2PT, position 3 only; forced other roles use this fallback.
local BuildData = require(GetScriptDirectory()..'/BotLib/Builds/axe')
X.buildMetadata = BuildData
X.neutralPreferences = BuildData.neutrals[sRole]
local nAbilityBuildList = {2,3,3,1,3,6,3,1,1,1,6,2,2,2,6}
local nTalentBuildList = J.Skill.GetTalentBuild({
    t10={10,0}, -- Movement speed per active Battle Hunger
    t15={0,10}, -- Battle Hunger damage
    t20={10,0}, -- Counter Helix damage
    t25={0,10}, -- Berserker's Call radius
})
local defaultAbilityBuild, defaultTalentBuild = nAbilityBuildList, nTalentBuildList
X.sBuyList = {
    'item_quelling_blade', 'item_gauntlets', 'item_double_branches',
    'item_circlet', 'item_tango',
    'item_double_bracer', 'item_magic_wand', 'item_phase_boots',
    'item_blade_mail', 'item_blink', 'item_aghanims_shard',
    'item_black_king_bar', 'item_ultimate_scepter', 'item_shivas_guard',
    -- Late upgrades/slot policy beyond the displayed core progression.
    'item_ultimate_scepter_2', 'item_overwhelming_blink', 'item_lotus_orb',
    'item_travel_boots', 'item_travel_boots_2', 'item_moon_shard',
}
X.sSellList = {
    'item_blade_mail', 'item_quelling_blade',
    'item_blink', 'item_bracer', -- Repeated purchase ticks sell both Bracers.
    'item_ultimate_scepter', 'item_magic_wand',
    'item_travel_boots', 'item_phase_boots',
}

if J.Role.IsPvNMode() or J.Role.IsAllShadow() then X['sBuyList'], X['sSellList'] = { 'PvN_tank' }, {"item_heavens_halberd", 'item_quelling_blade'} end

nAbilityBuildList, nTalentBuildList, X['sBuyList'], X['sSellList'] = J.SetUserHeroInit( nAbilityBuildList, nTalentBuildList, X['sBuyList'], X['sSellList'] )

X['sSkillList'] = J.Skill.GetSkillList( sAbilityList, nAbilityBuildList, sTalentList, nTalentBuildList )
-- Finish Berserker's Call at 10; first talent at 11. Respect custom builds.
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

npc_dota_hero_axe

"Ability1"		"axe_berserkers_call"
"Ability2"		"axe_battle_hunger"
"Ability3"		"axe_counter_helix"
"Ability4"		"generic_hidden"
"Ability5"		"generic_hidden"
"Ability6"		"axe_culling_blade"

modifier_axe_berserkers_call
modifier_axe_berserkers_call_armor
modifier_axe_battle_hunger
modifier_axe_battle_hunger_self
modifier_axe_counter_helix
modifier_axe_culling_blade_boost


--]]

local abilityQ = bot:GetAbilityByName( sAbilityList[1] )
local abilityW = bot:GetAbilityByName( sAbilityList[2] )
local abilityE = bot:GetAbilityByName( sAbilityList[3] )
local abilityR = bot:GetAbilityByName( sAbilityList[6] )
local talent7 = bot:GetAbilityByName( sTalentList[7] )
-- 7.41f: Culling Blade damage is the level-25 left talent, not level 20.
local cullingDamageTalent = bot:GetAbilityByName( sTalentList[8] )

local castQDesire, castQTarget
local castWDesire, castWTarget
local castEDesire, castETarget
local castRDesire, castRTarget

local nKeepMana, nMP, nHP, nLV, hEnemyList, hAllyList, botTarget, sMotive
local aetherRange = 0


local function AbilityCastRange(ability)
    local range = ability:GetCastRange()
    if J.IsItemAvailable('item_aether_lens') ~= nil then range = range + 225 end
    return range
end

local function ValidEnemy(enemy)
    return J.IsValidHero(enemy) and enemy:CanBeSeen() and not enemy:IsInvulnerable()
        and not J.IsSuspiciousIllusion(enemy)
end

function X.SkillsComplement()

	if J.CanNotUseAbility( bot ) or bot:IsInvisible() then return end

	nKeepMana = 400
	aetherRange = 0
	nLV = bot:GetLevel()
	nMP = bot:GetMana() / bot:GetMaxMana()
	nHP = bot:GetHealth() / bot:GetMaxHealth()
	botTarget = J.GetProperTarget( bot )
	hEnemyList = J.GetNearbyHeroes(bot, 1600, true, BOT_MODE_NONE )
	hAllyList = J.GetAlliesNearLoc( bot:GetLocation(), 1600 )


	--计算天赋可能带来的通用变化
	local aether = J.IsItemAvailable( "item_aether_lens" )
	if aether ~= nil then aetherRange = 225 end
	
	castRDesire, castRTarget, sMotive = X.ConsiderR()
	if castRDesire > 0
	then
		J.SetReportMotive( bDebugMode, sMotive )

		J.SetQueuePtToINT( bot, true )

		bot:ActionQueue_UseAbilityOnEntity( abilityR, castRTarget )
		return
	end
	

	castQDesire, sMotive = X.ConsiderQ()
	if castQDesire > 0
	then
		J.SetReportMotive( bDebugMode, sMotive )

		J.SetQueuePtToINT( bot, true )

		bot:ActionQueue_UseAbility( abilityQ )
		return
	end

	castWDesire, castWTarget, sMotive = X.ConsiderW()
	if castWDesire > 0
	then
		J.SetReportMotive( bDebugMode, sMotive )

		J.SetQueuePtToINT( bot, true )

		bot:ActionQueue_UseAbilityOnEntity( abilityW, castWTarget )
		return
	end

	

end


function X.ConsiderQ()
    if not abilityQ:IsFullyCastable() then return BOT_ACTION_DESIRE_NONE end
    local radius = abilityQ:GetSpecialValueInt('radius')
    if talent7:IsTrained() then radius = radius + talent7:GetSpecialValueInt('value') end
    local enemies = J.GetAroundEnemyHeroList(radius)
    for _, enemy in pairs(enemies) do
        if ValidEnemy(enemy) and enemy:IsChanneling() then return BOT_ACTION_DESIRE_HIGH end
    end
    if J.IsGoingOnSomeone(bot) and ValidEnemy(botTarget)
        and J.IsInRange(bot, botTarget, radius - 30) and not J.IsDisabled(botTarget) then
        -- Call pierces debuff immunity and has no unit-target reflection check.
        return BOT_ACTION_DESIRE_HIGH
    end
    if J.IsInTeamFight(bot, 1200) or J.IsRetreating(bot) then
        for _, enemy in pairs(enemies) do
            if ValidEnemy(enemy) and not J.IsDisabled(enemy)
                and (not J.IsRetreating(bot) or bot:WasRecentlyDamagedByAnyHero(3)) then
                return BOT_ACTION_DESIRE_HIGH
            end
        end
    end
    if (J.IsFarming(bot) or J.IsPushing(bot) or J.IsDefending(bot))
        and #hEnemyList == 0 and J.GetHP(bot) > 0.5
        and J.IsAllowedToSpam(bot, abilityQ:GetManaCost()) then
        local lanes = bot:GetNearbyLaneCreeps(radius, true)
        local neutrals = bot:GetNearbyNeutralCreeps(radius)
        if (#lanes >= 4 and not lanes[1]:HasModifier('modifier_fountain_glyph'))
            or (J.IsFarming(bot) and #neutrals >= 3) then return BOT_ACTION_DESIRE_HIGH end
    end
    if J.IsDoingRoshan(bot) and J.IsRoshan(botTarget)
        and J.IsInRange(bot, botTarget, radius) and J.IsAttacking(bot) then
        return BOT_ACTION_DESIRE_HIGH
    end
    return BOT_ACTION_DESIRE_NONE
end

function X.ConsiderW()
    if not abilityW:IsFullyCastable() then return BOT_ACTION_DESIRE_NONE end
    local range = AbilityCastRange(abilityW)
    local function CanHunger(enemy)
        return ValidEnemy(enemy) and J.IsInRange(bot, enemy, range)
            and J.CanCastOnNonMagicImmune(enemy) and J.CanCastOnTargetAdvanced(enemy)
            and not enemy:HasModifier('modifier_antimage_counterspell')
            and (abilityW:GetSpecialValueInt('should_stack') > 0
                or not enemy:HasModifier('modifier_axe_battle_hunger'))
    end
    if J.IsGoingOnSomeone(bot) and CanHunger(botTarget) then
        return BOT_ACTION_DESIRE_HIGH, botTarget
    end
    local enemies = J.GetAroundEnemyHeroList(range)
    if J.IsRetreating(bot) and bot:WasRecentlyDamagedByAnyHero(3) then
        for _, enemy in pairs(enemies) do
            if CanHunger(enemy) and not J.IsDisabled(enemy) then return BOT_ACTION_DESIRE_HIGH, enemy end
        end
    end
    if J.IsInTeamFight(bot, 1200) then
        local weakest
        for _, enemy in pairs(enemies) do
            if CanHunger(enemy) and (weakest == nil or enemy:GetHealth() < weakest:GetHealth()) then weakest = enemy end
        end
        if weakest ~= nil then return BOT_ACTION_DESIRE_HIGH, weakest end
    end
    if J.IsLaning(bot) and nMP > 0.5 then
        for _, enemy in pairs(enemies) do
            if CanHunger(enemy) then
                -- A nearby easy last hit would remove Hunger immediately.
                local easyKill = false
                for _, creep in pairs(bot:GetNearbyLaneCreeps(1600, false)) do
                    if J.IsValid(creep) and J.IsInRange(enemy, creep, enemy:GetAttackRange() + 100)
                        and creep:GetHealth() <= enemy:GetAttackDamage() * 1.2 then easyKill = true; break end
                end
                if not easyKill then return BOT_ACTION_DESIRE_HIGH, enemy end
            end
        end
    end
    if J.IsFarming(bot) and abilityW:GetLevel() >= 2
        and J.IsAllowedToSpam(bot, abilityW:GetManaCost()) then
        local creep = J.GetMostHpUnit(bot:GetNearbyNeutralCreeps(range))
        if J.IsValid(creep) and J.IsInRange(bot, creep, range)
            and J.CanCastOnNonMagicImmune(creep) and not J.IsRoshan(creep)
            and not creep:HasModifier('modifier_axe_battle_hunger')
            and not J.CanKillTarget(creep, bot:GetAttackDamage() * 2.88, DAMAGE_TYPE_PHYSICAL) then
            return BOT_ACTION_DESIRE_HIGH, creep
        end
    end
    if (J.IsDoingRoshan(bot) or J.IsDoingTormentor(bot)) and J.IsValid(botTarget)
        and J.IsInRange(bot, botTarget, range) and J.IsAttacking(bot)
        and J.CanCastOnNonMagicImmune(botTarget) and J.CanCastOnTargetAdvanced(botTarget)
        and not botTarget:HasModifier('modifier_axe_battle_hunger') then
        return BOT_ACTION_DESIRE_HIGH, botTarget
    end
    return BOT_ACTION_DESIRE_NONE
end

function X.ConsiderR()


	if not abilityR:IsFullyCastable() then return 0 end

	local nSkillLV = abilityR:GetLevel()
	local nCastRange = AbilityCastRange(abilityR)
	local nRadius = 600
	local nCastPoint = abilityR:GetCastPoint()
	local nManaCost = abilityR:GetManaCost()
	
	local nKillDamage = abilityR:GetSpecialValueInt('damage')
	if cullingDamageTalent:IsTrained() then nKillDamage = nKillDamage + cullingDamageTalent:GetSpecialValueInt( 'value' ) end
	
	local nDamageType = DAMAGE_TYPE_PURE
	local nInRangeEnemyList = J.GetAroundEnemyHeroList( nCastRange )
	local nInBonusEnemyList = J.GetAroundEnemyHeroList( nCastRange )
	local hCastTarget = nil
	local sCastMotive = nil
	
	
	--直接斩杀血量低于斩杀线的敌人
	for _, npcEnemy in pairs( nInBonusEnemyList )
	do 
		if J.IsValidHero( npcEnemy )
			and npcEnemy:CanBeSeen()
			and npcEnemy:GetHealth() + npcEnemy:GetHealthRegen() * 0.8 < nKillDamage
			and not J.IsHaveAegis( npcEnemy )
			and not npcEnemy:IsInvulnerable()
			and not X.HasSpecialModifier( npcEnemy )
		then
			hCastTarget = npcEnemy
			sCastMotive = 'R-击杀'..J.Chat.GetNormName( hCastTarget )
			return BOT_ACTION_DESIRE_HIGH, hCastTarget, sCastMotive			
		end
	end


	return BOT_ACTION_DESIRE_NONE


end


function X.HasSpecialModifier( npcEnemy )

	if npcEnemy:HasModifier( 'modifier_winter_wyvern_winters_curse' )
		or npcEnemy:HasModifier( 'modifier_winter_wyvern_winters_curse_aura' )
		or npcEnemy:HasModifier( 'modifier_antimage_counterspell' )
		or npcEnemy:HasModifier( 'modifier_item_lotus_orb_active' )
		or npcEnemy:HasModifier( 'modifier_item_aeon_disk_buff' )
		or npcEnemy:HasModifier( 'modifier_item_sphere_target' )
		or npcEnemy:HasModifier( 'modifier_illusion' )
		or npcEnemy:HasModifier( 'modifier_arc_warden_tempest_double' )
	then
		return true
	else
		return false	
	end

end



return X
-- dota2jmz@163.com QQ:2462331592..
