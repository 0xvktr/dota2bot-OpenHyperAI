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

-- D2PT 7.41f: mid and both supports; forced other roles use support without wards.
local BuildData = require(GetScriptDirectory()..'/BotLib/Builds/skywrath_mage')
X.buildMetadata = BuildData
X.neutralPreferences = BuildData.neutrals[sRole]
local mid = sRole == 'pos_2'
-- [1] Arcane Bolt, [2] Concussive Shot, [3] Ancient Seal, [6] Mystic Flare.
local nAbilityBuildList = mid and {2,1,1,2,1,6,1,3,2,2,6,3,3,3,6}
    or {2,1,1,3,1,6,1,3,3,3,6,2,2,2,6}
local nTalentBuildList = J.Skill.GetTalentBuild({
    t10={10,0}, -- +125 Arcane Bolt cast range
    t15={0,10}, -- -6s Ancient Seal cooldown
    t20={10,0}, -- +10% Ancient Seal magic damage amplification
    t25=mid and {0,10} or {10,0}, -- Arcane Bolt INT multiplier / Mystic Flare damage
})
local defaultAbilityBuild, defaultTalentBuild = nAbilityBuildList, nTalentBuildList
local roleItems = {}
roleItems.pos_2 = {
    'item_double_mantle','item_mantle','item_circlet',
    'item_null_talisman','item_null_talisman','item_null_talisman',
    'item_rod_of_atos','item_kaya','item_aghanims_shard','item_travel_boots','item_blink',
    'item_kaya_and_sange','item_sheepstick',
    -- Bot policy: consume Scepter before the observed late Ethereal Blade; six final slots.
    'item_ultimate_scepter','item_ultimate_scepter_2','item_ethereal_blade',
}
roleItems.pos_4 = {
    'item_mantle','item_double_branches','item_circlet','item_ward_sentry','item_tango','item_blood_grenade',
    'item_null_talisman','item_null_talisman','item_null_talisman','item_magic_wand','item_arcane_boots',
    'item_aghanims_shard','item_kaya','item_rod_of_atos','item_blink','item_ultimate_scepter',
    -- Bot policy: upgrade Kaya, consume Scepter, then late control and team escape.
    'item_kaya_and_sange','item_ultimate_scepter_2','item_sheepstick','item_glimmer_cape',
}
roleItems.pos_5 = {
    'item_mantle','item_double_branches','item_circlet','item_ward_sentry','item_tango','item_blood_grenade',
    'item_null_talisman','item_null_talisman','item_magic_wand','item_arcane_boots',
    'item_rod_of_atos','item_aghanims_shard','item_kaya','item_blink','item_ultimate_scepter',
    -- Bot policy: consume Scepter and upgrade Kaya before late control/team escape.
    'item_ultimate_scepter_2','item_kaya_and_sange','item_sheepstick','item_glimmer_cape',
}
for _,r in ipairs({'pos_1','pos_3'}) do
    roleItems[r] = {}
    for _,item in ipairs(roleItems.pos_4) do
        if item ~= 'item_ward_sentry' then table.insert(roleItems[r],item) end
    end
end
X.sBuyList = roleItems[sRole]
X.sSellList = {'item_blink','item_null_talisman','item_blink','item_null_talisman',
    'item_blink','item_null_talisman','item_sheepstick','item_magic_wand'}

if J.Role.IsPvNMode() or J.Role.IsAllShadow() then X['sBuyList'], X['sSellList'] = { 'PvN_mage' }, {} end

nAbilityBuildList, nTalentBuildList, X['sBuyList'], X['sSellList'] = J.SetUserHeroInit( nAbilityBuildList, nTalentBuildList, X['sBuyList'], X['sSellList'] )

X['sSkillList'] = J.Skill.GetSkillList( sAbilityList, nAbilityBuildList, sTalentList, nTalentBuildList )

-- Observed ability at 10, first talent at 11; preserve custom overrides.
if nAbilityBuildList == defaultAbilityBuild and nTalentBuildList == defaultTalentBuild then
    X.sSkillList[10], X.sSkillList[11] = X.sSkillList[11], X.sSkillList[10]
end

X['bDeafaultAbility'] = false
X['bDeafaultItem'] = true

function X.MinionThink(hMinionUnit)

	if Minion.IsValidUnit( hMinionUnit )
	then
		Minion.IllusionThink( hMinionUnit )
	end

end

--[[

npc_dota_hero_skywrath_mage

"Ability1"		"skywrath_mage_arcane_bolt"
"Ability2"		"skywrath_mage_concussive_shot"
"Ability3"		"skywrath_mage_ancient_seal"
"Ability4"		"generic_hidden"
"Ability5"		"generic_hidden"
"Ability6"		"skywrath_mage_mystic_flare"
"Ability10"		"special_bonus_movement_speed_20"
"Ability11"		"special_bonus_intelligence_8"
"Ability12"		"special_bonus_unique_skywrath"
"Ability13"		"special_bonus_unique_skywrath_2"
"Ability14"		"special_bonus_unique_skywrath_4"
"Ability15"		"special_bonus_unique_skywrath_3"
"Ability16"		"special_bonus_gold_income_50"
"Ability17"		"special_bonus_unique_skywrath_5"

modifier_skywrath_mage_concussive_shot_slow
modifier_skywrath_mage_ancient_seal
modifier_skywrath_mage_mystic_flare
modifier_skywrath_mystic_flare_aura_effect


--]]

local M=require(GetScriptDirectory()..'/FunLib/skywrath_mage_abilities')
local decisions={{'skywrath_mage_ancient_seal',M.Seal,'unit'},{'skywrath_mage_mystic_flare',M.Flare,'point'},{'skywrath_mage_concussive_shot',M.Concussive,'none'},{'skywrath_mage_arcane_bolt',M.Bolt,'unit'}}
function X.SkillsComplement()
    if J.CanNotUseAbility(bot) then return end
    for _,entry in ipairs(decisions) do
        local a=bot:GetAbilityByName(entry[1]);local desire,target=entry[2](bot,a,true)
        if desire>0 then
            J.SetQueuePtToINT(bot,false)
            if entry[3]=='none' then bot:ActionQueue_UseAbility(a)
            elseif entry[3]=='point' then bot:ActionQueue_UseAbilityOnLocation(a,target)
            else bot:ActionQueue_UseAbilityOnEntity(a,target) end
            return
        end
    end
end
return X
