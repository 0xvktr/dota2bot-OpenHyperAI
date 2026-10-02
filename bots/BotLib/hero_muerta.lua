local X = {}
local bDebugMode = ( 1 == 10 )
local bot = GetBot()

local J = require( GetScriptDirectory()..'/FunLib/jmz_func' )
local SpellDecisions = require(GetScriptDirectory()..'/FunLib/rubick_hero/muerta')
X.UseGunslinger = SpellDecisions.UseGunslinger
local Minion = dofile( GetScriptDirectory()..'/FunLib/aba_minion' )

local sTalentList = J.Skill.GetTalentList( bot )
local sAbilityList = J.Skill.GetAbilityList( bot )
local sRole = J.Item.GetRoleItemsBuyList( bot )

-- Updated to 7.41f from D2PT; forced skipped roles use pos 1.
local BuildData = require(GetScriptDirectory()..'/BotLib/Builds/muerta')
X.buildMetadata = BuildData
X.neutralPreferences = BuildData.neutrals[sRole]
-- [1] Dead Shot, [2] The Calling, [3] Gunslinger, [6] Pierce the Veil.
local nAbilityBuildList = {1,2,1,3,1,6,1,3,3,3,6,2,2,2,6}
local nTalentBuildList = J.Skill.GetTalentBuild({
    t10={10,0}, -- Attack speed
    t15={10,0}, -- Intelligence
    t20={0,10}, -- Pierce the Veil duration
    t25={0,10}, -- Gunslinger chance
})
local defaultAbilityBuild, defaultTalentBuild = nAbilityBuildList, nTalentBuildList
X.sBuyList = {
    'item_magic_wand','item_faerie_fire','item_faerie_fire','item_falcon_blade','item_power_treads',
    'item_maelstrom','item_mjollnir','item_dragon_lance','item_hurricane_pike','item_black_king_bar',
    -- Bot policy: late upgrades and continuation.
    'item_lesser_crit','item_blink','item_greater_crit','item_swift_blink','item_aghanims_shard',
    'item_ultimate_scepter','item_ultimate_scepter_2','item_moon_shard',
}
X.sSellList = {'item_dragon_lance','item_magic_wand','item_black_king_bar','item_falcon_blade'}

if J.Role.IsPvNMode() or J.Role.IsAllShadow() then X['sBuyList'], X['sSellList'] = { 'PvN_mid' }, {} end

nAbilityBuildList, nTalentBuildList, X['sBuyList'], X['sSellList'] = J.SetUserHeroInit( nAbilityBuildList, nTalentBuildList, X['sBuyList'], X['sSellList'] )

X['sSkillList'] = J.Skill.GetSkillList( sAbilityList, nAbilityBuildList, sTalentList, nTalentBuildList )
-- D2PT takes an ability at 10, then the first talent at 11.
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

npc_dota_hero_muerta

Modifier or ability names not supported as of 5.5.2024

--]]

local abilityQ = bot:GetAbilityByName( 'muerta_dead_shot' )
local abilityW = bot:GetAbilityByName( 'muerta_the_calling' )
local abilityE = bot:GetAbilityByName( 'muerta_gunslinger' )
local abilityR = bot:GetAbilityByName( 'muerta_pierce_the_veil' )
local abilityAS = bot:GetAbilityByName( 'muerta_spectral_slug' )

local castQDesire, castQTarget
local castWDesire, castWLocation
local castEDesire, castRDesire
local castASDesire, castASTarget

local nKeepMana = 280
local botTarget = nil

-- was for fully takeover, but not used atm.
function X.Think()
	-- X.AbilityItemUsage = dofile( GetScriptDirectory()..'/ability_item_usage_generic')

	-- bot:Action_AttackMove(J.GetEnemyFountain())
    if X.TeamRoam == nil then
		X.TeamRoam = require(GetScriptDirectory() .. "/FunLib/mode_team_roam_generic_shared")
        -- X.FarmGeneric = dofile(GetScriptDirectory() .. "/FunLib/mode_farm_generic_shared")
    --     -- X.ItemPurchase = require(GetScriptDirectory() .. "/item_purchase_generic")
    --     -- X.TeamRoam = require(GetScriptDirectory() .. "/mode_team_roam_generic")
    --     -- X.AbilityItemUsage = require(GetScriptDirectory() .. "/ability_item_usage_generic")
    end

    -- -- X.ItemPurchase.ItemPurchaseThink()

    if X.TeamRoam.GetDesire() > 0 then
        X.TeamRoam.Think()
    end
    -- if X.FarmGeneric.GetDesire() > 0 then
    --     X.FarmGeneric.Think()
    -- end

    -- X.AbilityItemUsage.ItemUsageThink()
    -- X.AbilityItemUsage.AbilityUsageThink()
    -- X.AbilityItemUsage.BuybackUsageThink()
    -- X.AbilityItemUsage.AbilityLevelUpThink()

end

function X.SkillsComplement()
    if X.UseGunslinger() then return end
    if J.CanNotUseAbility(bot) or bot:IsInvisible() then return end
    X.ConsiderTarget()
    J.ConsiderForMkbDisassembleMask(bot)
    botTarget = J.GetProperTarget(bot)
    abilityQ = bot:GetAbilityByName('muerta_dead_shot')
    abilityW = bot:GetAbilityByName('muerta_the_calling')
    abilityR = bot:GetAbilityByName('muerta_pierce_the_veil')
    abilityAS = bot:GetAbilityByName('muerta_spectral_slug')
    -- Defense and a reachable magical attack window take priority over routine poke.
    if SpellDecisions.ShouldVeil(abilityR) then
        J.SetQueuePtToINT(bot, true, abilityR)
        bot:ActionQueue_UseAbility(abilityR)
        return
    end
    if abilityAS ~= nil and SpellDecisions.ConsiderStolenSpell(abilityAS) then return end
    if SpellDecisions.ConsiderStolenSpell(abilityQ) then return end
    SpellDecisions.ConsiderStolenSpell(abilityW)
end

function X.ConsiderTarget()
	if not J.IsRunning( bot )
		or bot:HasModifier( "modifier_item_hurricane_pike_range" )
	then return end

	local nAttackRange = math.min(1600, bot:GetAttackRange() + 60)
	local nInAttackRangeWeakestEnemyHero = J.GetAttackableWeakestUnit( bot, nAttackRange, true, true )

	local npcTarget = J.GetProperTarget( bot )
	local nTargetUint = nil

	if J.IsValidHero( npcTarget )
		and GetUnitToUnitDistance( npcTarget, bot ) > nAttackRange
		and J.IsValidHero( nInAttackRangeWeakestEnemyHero )
	then
		nTargetUint = nInAttackRangeWeakestEnemyHero
		bot:SetTarget( nTargetUint )
		return
	end

end

function X.ConsiderQ()
    local target=SpellDecisions.DeadShotTarget(abilityQ)
    return target~=nil and BOT_ACTION_DESIRE_HIGH or BOT_ACTION_DESIRE_NONE,target
end
function X.ConsiderW()
    local point=SpellDecisions.CallingPoint(abilityW)
    return point~=nil and BOT_ACTION_DESIRE_HIGH or BOT_ACTION_DESIRE_NONE,point
end
function X.ConsiderE()
    return BOT_ACTION_DESIRE_NONE -- Gunslinger is maintained by the guarded immediate utility.
end
function X.ConsiderR()
    return SpellDecisions.ShouldVeil(abilityR) and BOT_ACTION_DESIRE_HIGH or BOT_ACTION_DESIRE_NONE
end
function X.ConsiderAS()
    local target=SpellDecisions.SlugTarget(abilityAS)
    return target~=nil and BOT_ACTION_DESIRE_HIGH or BOT_ACTION_DESIRE_NONE,target
end
return X
