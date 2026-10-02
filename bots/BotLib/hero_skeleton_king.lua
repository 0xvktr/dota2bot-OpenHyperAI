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

-- D2PT 7.41f: carry/offlane; forced other roles use offlane.
local BuildData = require(GetScriptDirectory()..'/BotLib/Builds/skeleton_king')
X.buildMetadata = BuildData
X.neutralPreferences = BuildData.neutrals[sRole]
-- [1] Wraithfire Blast, [2] Bone Guard, [3] Mortal Strike, [6] Reincarnation.
local nAbilityBuildList = {1,2,2,3,2,6,2,3,3,3,6,1,1,1,6}
local nTalentBuildList = J.Skill.GetTalentBuild({
    t10={10,0}, -- +2s Wraithfire Blast slow
    t15={10,0}, -- +300 health
    t20={0,10}, -- +50 attack speed
    t25={0,10}, -- -2s Mortal Strike cooldown
})
local defaultAbilityBuild, defaultTalentBuild = nAbilityBuildList, nTalentBuildList
local carry = sRole == 'pos_1'
X.sBuyList = carry and {
    'item_quelling_blade','item_double_branches','item_magic_stick','item_tango','item_faerie_fire',
    'item_magic_wand','item_phase_boots','item_radiance','item_blink','item_orchid',
    'item_aghanims_shard','item_black_king_bar',
    -- Bot policy: consume Scepter before AC/Bloodthorn; upgrade Blink within six slots.
    'item_ultimate_scepter','item_ultimate_scepter_2','item_assault','item_bloodthorn','item_swift_blink',
} or {
    'item_quelling_blade','item_gauntlets','item_double_branches','item_circlet','item_tango',
    'item_bracer','item_magic_wand','item_phase_boots','item_radiance','item_blink','item_aghanims_shard',
    'item_black_king_bar','item_assault',
    -- Bot policy: consumed Scepter, late silence and a natural Blink upgrade.
    'item_ultimate_scepter','item_ultimate_scepter_2','item_orchid','item_bloodthorn','item_overwhelming_blink',
}
X.sSellList = {'item_assault','item_magic_wand','item_assault','item_bracer','item_blink','item_quelling_blade'}

if J.Role.IsPvNMode() or J.Role.IsAllShadow() then X['sBuyList'], X['sSellList'] = { 'PvN_tank' }, {"item_heavens_halberd", 'item_quelling_blade'} end

nAbilityBuildList, nTalentBuildList, X['sBuyList'], X['sSellList'] = J.SetUserHeroInit( nAbilityBuildList, nTalentBuildList, X['sBuyList'], X['sSellList'] )

X['sSkillList'] = J.Skill.GetSkillList( sAbilityList, nAbilityBuildList, sTalentList, nTalentBuildList )


-- Observed ability at 10, first talent at 11; preserve custom overrides.
if nAbilityBuildList == defaultAbilityBuild and nTalentBuildList == defaultTalentBuild then
    X.sSkillList[10], X.sSkillList[11] = X.sSkillList[11], X.sSkillList[10]
end

X['bDeafaultAbility'] = true
X['bDeafaultItem'] = false

function X.MinionThink(hMinionUnit)

	if Minion.IsValidUnit( hMinionUnit )
		and hMinionUnit:GetUnitName() ~= "npc_dota_wraith_king_skeleton_warrior"
	then
		Minion.IllusionThink( hMinionUnit )
	end

end

local M=require(GetScriptDirectory()..'/FunLib/skeleton_king_abilities')
local function cast(a,desire,target)
    if desire<=0 then return false end
    J.SetQueuePtToINT(bot,false)
    if a:GetName()=='skeleton_king_bone_guard' then bot:ActionQueue_UseAbility(a) else bot:ActionQueue_UseAbilityOnEntity(a,target) end
    return true
end
function X.SkillsComplement()
    if J.CanNotUseAbility(bot) then return end
    local q=bot:GetAbilityByName('skeleton_king_hellfire_blast')
    local desire,target=M.Blast(bot,q,true);if cast(q,desire,target) then return end
    local r=bot:GetAbilityByName('skeleton_king_reincarnation')
    desire,target=M.Reincarnate(bot,r);if cast(r,desire,target) then return end
    local w=bot:GetAbilityByName('skeleton_king_bone_guard')
    desire=M.Guard(bot,w,true);if cast(w,desire) then return end
    desire,target=M.Blast(bot,q,false);cast(q,desire,target)
end
return X
