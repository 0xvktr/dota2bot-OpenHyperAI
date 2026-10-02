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

-- D2PT 7.41f: mid only; forced other roles use mid.
local BuildData = require(GetScriptDirectory()..'/BotLib/Builds/sniper')
X.buildMetadata = BuildData
X.neutralPreferences = BuildData.neutrals[sRole]
-- [1] Shrapnel, [2] Headshot, [3] Take Aim, [6] Assassinate.
local nAbilityBuildList = {1,2,1,3,1,6,1,2,2,2,6,3,3,3,6}
local nTalentBuildList = J.Skill.GetTalentBuild({
    t10={10,0}, -- +30 Headshot damage
    t15={0,10}, -- +45 attack speed during Take Aim
    t20={0,10}, -- +2s Take Aim duration
    t25={10,0}, -- +50 max Headshot knockback distance
})
local defaultAbilityBuild, defaultTalentBuild = nAbilityBuildList, nTalentBuildList
X.sBuyList = {
    -- Observed starting ward omitted: core bots do not place it.
    'item_slippers','item_double_branches','item_circlet','item_tango','item_faerie_fire',
    'item_wraith_band','item_wraith_band','item_power_treads','item_maelstrom','item_dragon_lance',
    'item_mjollnir','item_force_staff','item_hurricane_pike','item_aghanims_shard',
    -- Bot policy: observed critical strike/lifesteal, then protection within six slots.
    'item_lesser_crit','item_greater_crit','item_lifesteal','item_satanic','item_black_king_bar',
    'item_moon_shard',
}
X.sSellList = {'item_black_king_bar','item_wraith_band','item_black_king_bar','item_wraith_band'}

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



local SpellDecisions = require(GetScriptDirectory()..'/FunLib/rubick_hero/sniper')

function X.SkillsComplement()
    SpellDecisions.ObserveShrapnel()
    if J.CanNotUseAbility(bot) or bot:IsInvisible() then return end
    X.ConsiderTarget()
    J.ConsiderForMkbDisassembleMask(bot)
    SpellDecisions.UseNative()
end

function X.ConsiderTarget()
    if not J.IsRunning(bot) or bot:HasModifier('modifier_item_hurricane_pike_range') then return end
    local target = J.GetProperTarget(bot)
    local range = math.min(1600, bot:GetAttackRange()+60)
    if J.IsValidHero(target) and GetUnitToUnitDistance(bot, target) > range then
        local reachable = J.GetAttackableWeakestUnit(bot, range, true, true)
        if J.IsValidHero(reachable) then bot:SetTarget(reachable) end
    end
end

X.ConsiderQ = SpellDecisions.ConsiderShrapnel
X.ConsiderE = SpellDecisions.ConsiderTakeAim
X.ConsiderR = SpellDecisions.ConsiderAssassinate
X.ConsiderAS = SpellDecisions.ConsiderGrenade
X.IsAbiltyQCastedHere = SpellDecisions.IsShrapnelHere
return X
