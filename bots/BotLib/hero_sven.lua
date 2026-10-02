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
local ItemCastPolicy = require(GetScriptDirectory()..'/FunLib/item_cast_policy')
local PowerTreads = require(GetScriptDirectory()..'/FunLib/power_treads')
local Minion = dofile( GetScriptDirectory()..'/FunLib/aba_minion' )
local sTalentList = J.Skill.GetTalentList( bot )
local sAbilityList = J.Skill.GetAbilityList( bot )
local sRole = J.Item.GetRoleItemsBuyList( bot )

-- D2PT 7.41f: carry only; forced other roles use carry.
local BuildData = require(GetScriptDirectory()..'/BotLib/Builds/sven')
X.buildMetadata = BuildData
X.neutralPreferences = BuildData.neutrals[sRole]
-- [1] Storm Hammer, [2] Great Cleave, [3] Warcry, [6] God's Strength.
local nAbilityBuildList = {1,3,2,2,2,6,2,1,1,1,6,3,3,3,6}
local nTalentBuildList = J.Skill.GetTalentBuild({
    t10={0,10}, -- Warcry duration
    t15={0,10}, -- God's Strength cooldown
    t20={10,0}, -- Warcry armor
    t25={0,10}, -- God's Strength damage
})
local defaultAbilityBuild, defaultTalentBuild = nAbilityBuildList, nTalentBuildList
X.sBuyList = {
    'item_quelling_blade','item_double_branches','item_magic_stick','item_tango','item_faerie_fire',
    'item_bracer','item_magic_wand','item_power_treads','item_lifesteal','item_mask_of_madness',
    'item_echo_sabre','item_blink','item_black_king_bar','item_lesser_crit','item_greater_crit',
    'item_harpoon','item_swift_blink','item_satanic','item_aghanims_shard',
    -- Bot policy: consumed attack speed; retain the six-item carry inventory.
    'item_moon_shard',
}
X.sSellList = {
    'item_echo_sabre','item_quelling_blade',
    'item_greater_crit','item_magic_wand',
    'item_harpoon','item_bracer',
    'item_satanic','item_mask_of_madness',
    'item_satanic','item_broadsword',
}

if J.Role.IsPvNMode() or J.Role.IsAllShadow() then X.sBuyList, X.sSellList = {'PvN_str_carry'}, {'item_power_treads','item_quelling_blade'} end
nAbilityBuildList, nTalentBuildList, X.sBuyList, X.sSellList = J.SetUserHeroInit(nAbilityBuildList, nTalentBuildList, X.sBuyList, X.sSellList)
X.sSkillList = J.Skill.GetSkillList(sAbilityList, nAbilityBuildList, sTalentList, nTalentBuildList)
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




local abilityQ = bot:GetAbilityByName( sAbilityList[1] )
local abilityE = bot:GetAbilityByName( sAbilityList[3] )
local abilityR = bot:GetAbilityByName( sAbilityList[6] )


local castQDesire, castQTarget
local castEDesire
local castRDesire

local nKeepMana, nMP, nHP, nLV, hEnemyHeroList
local botTarget

function X.SkillsComplement()
    ItemCastPolicy.Clear(bot)
    if PowerTreads.ActionLocked(bot) or J.CanNotUseAbility(bot) or bot:IsInvisible() then return end

	J.ConsiderForMkbDisassembleMask( bot )
	X.SvenConsiderTarget()


	if J.CanNotUseAbility( bot ) or bot:IsInvisible() then return end

	botTarget = J.GetProperTarget( bot )
	nKeepMana = 400
	nLV = bot:GetLevel()
	nMP = bot:GetMana()/bot:GetMaxMana()
	nHP = bot:GetHealth()/bot:GetMaxHealth()
	hEnemyHeroList = J.GetNearbyHeroes(bot, 1600, true, BOT_MODE_NONE )


	castRDesire = X.ConsiderR()
	if ( castRDesire > 0 )
	then

		J.SetQueuePtToINT( bot, true, abilityR )

		bot:ActionQueue_UseAbility( abilityR )
		return

	end

	castQDesire, castQTarget = X.ConsiderQ()
	if ( castQDesire > 0 )
	then
        if not abilityQ:IsFullyCastable() then
            local waiting = ItemCastPolicy.Request(bot, abilityQ, castQTarget, 'unit', function()
                local desire, target = X.ConsiderQ()
                return desire > 0 and target == castQTarget
            end, J)
            if waiting then return end
        else
            J.SetQueuePtToINT(bot, true, abilityQ)
            bot:ActionQueue_UseAbilityOnEntity(abilityQ, castQTarget)
            return
        end

	end

	castEDesire = X.ConsiderE()
	if ( castEDesire > 0 )
	then
        ItemCastPolicy.Clear(bot)

		J.SetQueuePtToINT( bot, false, abilityE )

		bot:ActionQueue_UseAbility( abilityE )
		return

	end

end

local SpellDecisions = require(GetScriptDirectory()..'/FunLib/rubick_hero/sven')
function X.ConsiderQ() return SpellDecisions.ConsiderQ(abilityQ) end
function X.ConsiderE() return SpellDecisions.ConsiderE(abilityE) end
function X.ConsiderR() return SpellDecisions.ConsiderR(abilityR) end

function X.SvenConsiderTarget()

	local bot = GetBot()
    botTarget = J.GetProperTarget(bot)

	if not J.IsRunning( bot )
	then return end

	if not J.IsValidHero( botTarget ) then return end

	local nAttackRange = bot:GetAttackRange() + 50
	local nEnemyHeroInRange = J.GetNearbyHeroes(bot, nAttackRange, true, BOT_MODE_NONE )

	local nInAttackRangeNearestEnemyHero = nEnemyHeroInRange[1]

	if J.IsValidHero( nInAttackRangeNearestEnemyHero )
		and J.CanBeAttacked( nInAttackRangeNearestEnemyHero )
		and ( GetUnitToUnitDistance( botTarget, bot ) >  350 or J.HasForbiddenModifier( botTarget ) )
	then
		--更改目标为
		bot:SetTarget( nInAttackRangeNearestEnemyHero )
		return
	end

end

return X
-- dota2jmz@163.com QQ:2462331592..
