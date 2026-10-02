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

-- D2PT 7.41f: carry/mid; forced other roles use carry.
local BuildData = require(GetScriptDirectory()..'/BotLib/Builds/templar_assassin')
X.buildMetadata = BuildData
X.neutralPreferences = BuildData.neutrals[sRole]
local mid = sRole == 'pos_2'
-- [1] Refraction, [2] Meld, [3] Psi Blades, [6] Psionic Trap.
local nAbilityBuildList = {2,3,2,3,2,6,2,3,3,1,6,1,1,1,6}
local nTalentBuildList = J.Skill.GetTalentBuild({
    t10=mid and {10,0} or {0,10}, -- Trap slow / Meld debuff duration
    t15={0,10}, -- +225 Meld attack range
    t20={10,0}, -- +4 Meld armor reduction
    t25={0,10}, -- 0.8s Meld hit bash
})
local defaultAbilityBuild, defaultTalentBuild = nAbilityBuildList, nTalentBuildList
X.sBuyList = mid and {
    'item_double_branches','item_double_branches','item_tango','item_faerie_fire',
    'item_bottle','item_magic_wand','item_power_treads','item_desolator','item_blink','item_dragon_lance',
    'item_lesser_crit','item_hurricane_pike','item_greater_crit','item_aghanims_shard','item_black_king_bar',
    -- Bot policy: mobility upgrade; avoid a seventh permanent damage item.
    'item_swift_blink',
} or {
    'item_magic_wand','item_faerie_fire','item_faerie_fire',
    'item_power_treads','item_falcon_blade','item_desolator','item_dragon_lance','item_blink',
    'item_lesser_crit','item_hurricane_pike','item_greater_crit','item_black_king_bar','item_aghanims_shard',
    -- Bot policy: mobility upgrade within six persistent slots.
    'item_swift_blink',
}
X.sSellList = {'item_desolator','item_magic_wand','item_blink',mid and 'item_bottle' or 'item_falcon_blade'}

if J.Role.IsPvNMode() or J.Role.IsAllShadow() then X['sBuyList'], X['sSellList'] = { 'PvN_TA' }, {} end

nAbilityBuildList, nTalentBuildList, X['sBuyList'], X['sSellList'] = J.SetUserHeroInit( nAbilityBuildList, nTalentBuildList, X['sBuyList'], X['sSellList'] )

X['sSkillList'] = J.Skill.GetSkillList( sAbilityList, nAbilityBuildList, sTalentList, nTalentBuildList )

-- Observed ability at 10, first talent at 11; preserve custom overrides.
if nAbilityBuildList == defaultAbilityBuild and nTalentBuildList == defaultTalentBuild then
    X.sSkillList[10], X.sSkillList[11] = X.sSkillList[11], X.sSkillList[10]
end

X['bDeafaultAbility'] = false
X['bDeafaultItem'] = false

local SpellDecisions = require(GetScriptDirectory()..'/FunLib/rubick_hero/templar_assassin')
X.UseDisabledRefraction = SpellDecisions.UseDisabledRefraction
X.UseTrapMinion = SpellDecisions.UseTrapMinion
X.ConsiderQ = SpellDecisions.ConsiderQ
X.ConsiderW = SpellDecisions.ConsiderW
X.ConsiderR = SpellDecisions.ConsiderR
X.ConsiderProjection = SpellDecisions.ConsiderProjection
function X.MinionThink(unit)
    if Minion.IsValidUnit(unit) then
        if unit:GetUnitName()=='npc_dota_templar_assassin_psionic_trap' then SpellDecisions.UseTrapMinion(unit)
        else Minion.IllusionThink(unit) end
    end
end
function X.SkillsComplement()
    if not J.CanNotUseAbility(bot) and not bot:HasModifier('modifier_templar_assassin_meld') then X.TAConsiderTarget() end
    SpellDecisions.UseNative()
end

function X.TAConsiderTarget()

	local bot = GetBot()

	if not J.IsRunning( bot )
		or bot:HasModifier( "modifier_item_hurricane_pike_range" )
	then return end

	local npcTarget = bot:GetAttackTarget()
	if not J.IsValidHero( npcTarget ) then return end

	local nAttackRange = bot:GetAttackRange() + 40
	if nAttackRange > 1600 then nAttackRange = 1600 end
	local nEnemyHeroInRange = J.GetNearbyHeroes(bot, nAttackRange, true, BOT_MODE_NONE )

	local nInAttackRangeNearestEnemyHero = nEnemyHeroInRange[1]

	if J.IsValidHero( nInAttackRangeNearestEnemyHero )
		and J.CanBeAttacked( nInAttackRangeNearestEnemyHero )
		and ( GetUnitToUnitDistance( npcTarget, bot ) > nAttackRange or J.HasForbiddenModifier( npcTarget ) )
	then
		bot:SetTarget( nInAttackRangeNearestEnemyHero )
		return
	end

end


return X
-- dota2jmz@163.com QQ:2462331592..
