-- Credit goes to Furious Puppy for Bot Experiment

local X = {}
local bot = GetBot()

local J = require( GetScriptDirectory()..'/FunLib/jmz_func' )
local Minion = dofile( GetScriptDirectory()..'/FunLib/aba_minion' )
local sTalentList = J.Skill.GetTalentList( bot )
local sAbilityList = J.Skill.GetAbilityList( bot )
local sRole = J.Item.GetRoleItemsBuyList( bot )

-- Updated to 7.41f from D2PT: offlane and mid; forced other roles use offlane.
local BuildData = require(GetScriptDirectory()..'/BotLib/Builds/shredder')
X.buildMetadata = BuildData
X.neutralPreferences = BuildData.neutrals[sRole]
-- [1] Whirling Death, [2] Timber Chain, [3] Reactive Armor, [6] Chakram.
local nAbilityBuildList = {1,3,1,2,1,6,1,2,2,2,6,3,3,3,6}
local nTalentBuildList = J.Skill.GetTalentBuild({
    t10={10,0}, -- +1.5 mana regen
    t15={0,10}, -- +2% Whirling Death stat loss
    t20={10,0}, -- +6% Chakram slow
    t25={10,0}, -- +75% Timber Chain range/projectile speed
})
local defaultAbilityBuild, defaultTalentBuild = nAbilityBuildList, nTalentBuildList
local sRoleItemsBuyList = {}
sRoleItemsBuyList.pos_3 = {
    'item_double_gauntlets','item_double_branches','item_magic_stick',
    'item_bracer','item_magic_wand','item_soul_ring',
    -- Bot policy: Power Treads from the most-picked boot option.
    'item_power_treads','item_kaya','item_kaya_and_sange','item_blink','item_black_king_bar',
    'item_shivas_guard','item_aghanims_shard','item_ultimate_scepter',
    -- Bot policy: consume Scepter before optional Lotus; upgrade the existing Blink.
    'item_ultimate_scepter_2','item_lotus_orb','item_overwhelming_blink',
}
sRoleItemsBuyList.pos_2 = {
    -- Observed starting ward omitted: core bots do not place it.
    'item_double_branches','item_double_branches','item_tango','item_faerie_fire',
    'item_bottle','item_magic_wand','item_soul_ring','item_power_treads','item_kaya','item_blink',
    'item_kaya_and_sange','item_black_king_bar','item_shivas_guard',
    -- Bot policy: Shard and consumed Scepter, then optional Lotus and Blink upgrade.
    'item_aghanims_shard','item_ultimate_scepter','item_ultimate_scepter_2',
    'item_lotus_orb','item_overwhelming_blink',
}
sRoleItemsBuyList.pos_1 = sRoleItemsBuyList.pos_3
sRoleItemsBuyList.pos_4 = sRoleItemsBuyList.pos_3
sRoleItemsBuyList.pos_5 = sRoleItemsBuyList.pos_3
X.sBuyList = sRoleItemsBuyList[sRole]
X.sSellList = {'item_kaya_and_sange','item_bracer','item_black_king_bar','item_magic_wand','item_shivas_guard','item_soul_ring','item_shivas_guard','item_bottle'}

if J.Role.IsPvNMode() or J.Role.IsAllShadow() then X.sBuyList, X.sSellList = {'PvN_mid'}, {} end

nAbilityBuildList, nTalentBuildList, X.sBuyList, X.sSellList = J.SetUserHeroInit(nAbilityBuildList, nTalentBuildList, X.sBuyList, X.sSellList)
X.sSkillList = J.Skill.GetSkillList(sAbilityList, nAbilityBuildList, sTalentList, nTalentBuildList)
-- Observed ability at 10, first talent at 11; preserve custom overrides.
if nAbilityBuildList == defaultAbilityBuild and nTalentBuildList == defaultTalentBuild then
    X.sSkillList[10], X.sSkillList[11] = X.sSkillList[11], X.sSkillList[10]
end

X.bDeafaultAbility = false
X.bDeafaultItem = false

function X.MinionThink(hMinionUnit)

	if Minion.IsValidUnit( hMinionUnit )
	then
		Minion.IllusionThink( hMinionUnit )
	end
end

local M=require(GetScriptDirectory()..'/FunLib/shredder_abilities')
function X.UseSpellsDuringTimberChain() return M.UseDuringChain(bot,true) end
local considers={
    {'shredder_return_chakram',M.Return,'none'},
    {'shredder_return_chakram_2',M.Return,'none'},
    {'shredder_reactive_armor',M.Armor,'none'},
    {'shredder_whirling_death',M.Whirl,'none'},
    {'shredder_chakram',M.Chakram,'point'},
    {'shredder_chakram_2',M.Chakram,'point'},
    {'shredder_twisted_chakram',M.Chakram,'point'},
    {'shredder_timber_chain',M.Chain,'point'},
    {'shredder_flamethrower',M.Flame,'none'},
}
function X.SkillsComplement()
    if X.UseSpellsDuringTimberChain() then return end
    if J.CanNotUseAbility(bot) then return end
    for _,entry in ipairs(considers) do
        local ability=bot:GetAbilityByName(entry[1]);local desire,target=entry[2](bot,ability,true)
        if desire>0 then
            if entry[3]=='point' then bot:Action_UseAbilityOnLocation(ability,target)
                if entry[1]=='shredder_chakram' or entry[1]=='shredder_chakram_2' then M.RecordChakram(bot,ability,target) end
            else bot:Action_UseAbility(ability) end
            return
        end
    end
end
return X
