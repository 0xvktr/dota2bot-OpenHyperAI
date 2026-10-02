local X             = {}
local bot           = GetBot()

local J             = require( GetScriptDirectory()..'/FunLib/jmz_func' )
local Minion        = dofile( GetScriptDirectory()..'/FunLib/aba_minion' )
local sTalentList   = J.Skill.GetTalentList( bot )
local sAbilityList  = J.Skill.GetAbilityList( bot )
local sRole   = J.Item.GetRoleItemsBuyList( bot )

-- D2PT 7.41f: offlane/supports; forced carry/mid use support without wards.
local BuildData = require(GetScriptDirectory()..'/BotLib/Builds/spirit_breaker')
X.buildMetadata = BuildData
X.neutralPreferences = BuildData.neutrals[sRole]
local offlane = sRole == 'pos_3'
local hardSupport = sRole == 'pos_5'
-- [1] Charge, [2] Bulldoze, [3] Greater Bash, [6] Nether Strike.
local nAbilityBuildList = offlane and {3,1,3,1,3,6,3,1,1,2,6,2,2,2,6}
    or {3,1,3,2,3,6,3,1,1,1,6,2,2,2,6}
local nTalentBuildList = J.Skill.GetTalentBuild({
    t10={0,10}, -- Night vision
    t15={10,0}, -- Charge speed
    t20=(offlane or hardSupport) and {0,10} or {10,0}, -- Haste / Bulldoze barrier
    t25=offlane and {0,10} or {10,0}, -- Bash damage / Charge cooldown
})
local defaultAbilityBuild, defaultTalentBuild = nAbilityBuildList, nTalentBuildList
X.sBuyList = offlane and {
    'item_quelling_blade','item_gauntlets','item_double_branches','item_circlet','item_tango',
    'item_bracer','item_magic_wand','item_phase_boots','item_invis_sword','item_yasha',
    'item_yasha_and_kaya','item_ultimate_scepter','item_cyclone','item_octarine_core',
    -- Bot policy: consumed Scepter, charge protection and natural upgrades.
    'item_ultimate_scepter_2','item_black_king_bar','item_wind_waker','item_silver_edge','item_aghanims_shard',
} or {
    'item_boots','item_blood_grenade','item_phase_boots','item_magic_wand','item_invis_sword','item_yasha',
}
if not offlane then
    if sRole == 'pos_4' then
        -- Bot policy: dispenser ward types are unresolved; buy a Sentry.
        table.insert(X.sBuyList,2,'item_ward_sentry')
    end
    if hardSupport then
        table.insert(X.sBuyList,2,'item_ward_sentry')
        for _, item in ipairs({'item_aghanims_shard','item_yasha_and_kaya','item_ultimate_scepter'}) do table.insert(X.sBuyList,item) end
    else
        table.insert(X.sBuyList,'item_ultimate_scepter')
        -- Bot policy: complete the observed Yasha into a movement/casting upgrade.
        table.insert(X.sBuyList,'item_yasha_and_kaya')
    end
    -- Bot policy: consumed Scepter, cooldown/escape utility and natural upgrades.
    for _, item in ipairs({'item_ultimate_scepter_2','item_octarine_core','item_cyclone',
        'item_black_king_bar','item_wind_waker','item_silver_edge'}) do table.insert(X.sBuyList,item) end
    if not hardSupport then table.insert(X.sBuyList,'item_aghanims_shard') end
end
X.sSellList = {'item_ultimate_scepter','item_magic_wand'}
if offlane then
    table.insert(X.sSellList,'item_invis_sword'); table.insert(X.sSellList,'item_quelling_blade')
    table.insert(X.sSellList,'item_yasha_and_kaya'); table.insert(X.sSellList,'item_bracer')
end

if J.Role.IsPvNMode() or J.Role.IsAllShadow() then X.sBuyList, X.sSellList = {'PvN_antimage'}, {} end
nAbilityBuildList, nTalentBuildList, X.sBuyList, X.sSellList = J.SetUserHeroInit(nAbilityBuildList, nTalentBuildList, X.sBuyList, X.sSellList)
X.sSkillList = J.Skill.GetSkillList(sAbilityList, nAbilityBuildList, sTalentList, nTalentBuildList)
-- Observed ability at 10, first talent at 11; preserve custom overrides.
if nAbilityBuildList == defaultAbilityBuild and nTalentBuildList == defaultTalentBuild then
    X.sSkillList[10], X.sSkillList[11] = X.sSkillList[11], X.sSkillList[10]
end

X['bDeafaultAbility'] = false
X['bDeafaultItem'] = false

function X.MinionThink(hMinionUnit)
	Minion.MinionThink(hMinionUnit)
end

local SpellDecisions = require(GetScriptDirectory()..'/FunLib/rubick_hero/spirit_breaker')

function X.SkillsComplement()
    SpellDecisions.UseNative()
end

X.UseChargeSupport = SpellDecisions.UseChargeSupport
X.IsCharging = SpellDecisions.IsCharging
X.ConsiderChargeOfDarkness = SpellDecisions.ConsiderChargeOfDarkness
X.ConsiderBulldoze = SpellDecisions.ConsiderBulldoze
X.ConsiderNetherStrike = SpellDecisions.ConsiderNetherStrike
X.ConsiderPlanarPocket = SpellDecisions.ConsiderPlanarPocket
return X
