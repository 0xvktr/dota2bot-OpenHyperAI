local X = {}
local bDebugMode = ( 1 == 10 )
local bot = GetBot()

local J = require( GetScriptDirectory()..'/FunLib/jmz_func' )
local Minion = dofile( GetScriptDirectory()..'/FunLib/aba_minion' )
local sTalentList = J.Skill.GetTalentList( bot )
local sAbilityList = J.Skill.GetAbilityList( bot )
local sRole = J.Item.GetRoleItemsBuyList( bot )

-- Updated to 7.41f from D2PT; forced skipped roles use pos 4.
local BuildData = require(GetScriptDirectory()..'/BotLib/Builds/zuus')
X.buildMetadata = BuildData
X.neutralPreferences = BuildData.neutrals[sRole]
-- [1] Arc Lightning, [2] Lightning Bolt, [3] Heavenly Jump, [6] Thundergod's Wrath.
local roleAbilityBuilds, roleTalentTrees = {}, {}
roleAbilityBuilds.pos_2 = {1,3,1,2,1,6,1,2,2,2,6,3,3,3,6}
roleTalentTrees.pos_2 = {
    t10={10,0}, -- Health
    t15={0,10}, -- Thundergod's Wrath damage
    t20={10,0}, -- Lightning Bolt stun
    t25={10,0}, -- Heavenly Jump charges
}
roleAbilityBuilds.pos_4 = {2,3,2,1,2,6,2,1,1,1,6,3,3,3,6}
roleTalentTrees.pos_4 = {
    t10={10,0}, -- Health
    t15={0,10}, -- Thundergod's Wrath damage
    t20={10,0}, -- Lightning Bolt stun
    t25={10,0}, -- Heavenly Jump charges
}
roleAbilityBuilds.pos_5 = {2,3,2,1,2,6,2,1,1,1,6,3,3,3,6}
roleTalentTrees.pos_5 = {
    t10={10,0}, -- Health
    t15={0,10}, -- Thundergod's Wrath damage
    t20={10,0}, -- Lightning Bolt stun
    t25={10,0}, -- Heavenly Jump charges
}
local nAbilityBuildList = roleAbilityBuilds[sRole] or roleAbilityBuilds.pos_4
local nTalentBuildList = J.Skill.GetTalentBuild(roleTalentTrees[sRole] or roleTalentTrees.pos_4)
local defaultAbilityBuild, defaultTalentBuild = nAbilityBuildList, nTalentBuildList
local sRoleItemsBuyList, sRoleItemsSellList = {}, {}
sRoleItemsBuyList.pos_2 = {
        'item_double_branches','item_double_branches','item_tango','item_faerie_fire','item_bottle',
        'item_magic_wand','item_arcane_boots','item_kaya','item_aghanims_shard','item_ultimate_scepter',
        'item_refresher',
        -- Bot policy: selected situational items and late upgrades.
        'item_ultimate_scepter_2','item_yasha_and_kaya','item_octarine_core','item_sheepstick','item_blink',
        'item_arcane_blink',
}
sRoleItemsSellList.pos_2 = {'item_refresher','item_bottle','item_octarine_core','item_magic_wand'}
sRoleItemsBuyList.pos_4 = {
        'item_branches','item_magic_stick','item_tango','item_enchanted_mango','item_enchanted_mango',
        'item_ward_observer','item_ward_sentry','item_blood_grenade','item_magic_wand','item_arcane_boots',
        'item_aghanims_shard','item_ultimate_scepter','item_kaya','item_refresher',
        -- Bot policy: selected situational items and late upgrades.
        'item_ultimate_scepter_2','item_yasha_and_kaya','item_octarine_core','item_sheepstick','item_glimmer_cape',
}
sRoleItemsSellList.pos_4 = {'item_sheepstick','item_magic_wand'}
sRoleItemsBuyList.pos_5 = {
        'item_branches','item_magic_stick','item_tango','item_enchanted_mango','item_enchanted_mango',
        'item_ward_observer','item_ward_sentry','item_blood_grenade','item_magic_wand','item_arcane_boots',
        'item_aghanims_shard','item_ultimate_scepter',
        -- Bot policy: selected situational items and late upgrades.
        'item_kaya','item_refresher','item_ultimate_scepter_2','item_yasha_and_kaya','item_octarine_core',
        'item_sheepstick','item_glimmer_cape',
}
sRoleItemsSellList.pos_5 = {'item_sheepstick','item_magic_wand'}
sRoleItemsBuyList.pos_1 = sRoleItemsBuyList.pos_4
sRoleItemsSellList.pos_1 = sRoleItemsSellList.pos_4
sRoleItemsBuyList.pos_3 = sRoleItemsBuyList.pos_4
sRoleItemsSellList.pos_3 = sRoleItemsSellList.pos_4
X.sBuyList = sRoleItemsBuyList[sRole]
X.sSellList = sRoleItemsSellList[sRole]
-- Core bots omit observed starting wards.
if sRole == 'pos_1' or sRole == 'pos_2' or sRole == 'pos_3' then
    local coreBuyList = {}
    for _, item in ipairs(X.sBuyList) do
        if item ~= 'item_ward_observer' and item ~= 'item_ward_sentry' then table.insert(coreBuyList, item) end
    end
    X.sBuyList = coreBuyList
end

if J.Role.IsPvNMode() or J.Role.IsAllShadow() then X['sBuyList'], X['sSellList'] = { 'PvN_mage' }, {} end

nAbilityBuildList, nTalentBuildList, X['sBuyList'], X['sSellList'] = J.SetUserHeroInit( nAbilityBuildList, nTalentBuildList, X['sBuyList'], X['sSellList'] )

X['sSkillList'] = J.Skill.GetSkillList( sAbilityList, nAbilityBuildList, sTalentList, nTalentBuildList )
-- D2PT takes an ability at 10, then the first talent at 11.
if nAbilityBuildList == defaultAbilityBuild and nTalentBuildList == defaultTalentBuild then
    X.sSkillList[10], X.sSkillList[11] = X.sSkillList[11], X.sSkillList[10]
end

X['bDeafaultAbility'] = false
X['bDeafaultItem'] = true

function X.MinionThink(hMinionUnit)

	if Minion.IsValidUnit( hMinionUnit )
		and hMinionUnit:GetUnitName() ~= 'npc_dota_zeus_cloud'
	then
		Minion.IllusionThink( hMinionUnit )
	end

end

local Abilities = require(GetScriptDirectory()..'/FunLib/rubick_hero/zuus')
function X.UseLightningHands() return Abilities.UseLightningHands() end
function X.SkillsComplement() Abilities.UseNative() end
return X
