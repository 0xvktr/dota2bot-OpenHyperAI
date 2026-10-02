local X             = {}
local bot           = GetBot()

local J             = require( GetScriptDirectory()..'/FunLib/jmz_func' )
local G = require(GetScriptDirectory()..'/FunLib/grimstroke_abilities')
local Minion        = dofile( GetScriptDirectory()..'/FunLib/aba_minion' )
local sTalentList   = J.Skill.GetTalentList( bot )
local sAbilityList  = J.Skill.GetAbilityList( bot )
local sRole   = J.Item.GetRoleItemsBuyList( bot )

-- Updated to 7.41f from D2PT: support/hard support; forced cores use pos 5 without wards.
local BuildData = require(GetScriptDirectory()..'/BotLib/Builds/grimstroke')
X.buildMetadata = BuildData
X.neutralPreferences = BuildData.neutrals[sRole]
-- [1] Stroke of Fate, [2] Phantom's Embrace, [3] Ink Swell, [6] Soulbind.
local nAbilityBuildList = {1,3,1,2,1,6,1,2,2,2,6,3,3,3,6}
local nTalentBuildList = J.Skill.GetTalentBuild({
    t10={0,10}, -- +65 Phantom's Embrace DPS
    t15={0,10}, -- +25% Soulbind reflected spell damage
    t20={0,10}, -- +80% Stroke of Fate damage
    t25={10,0}, -- +70% Stroke of Fate speed/range
})
local defaultAbilityBuild, defaultTalentBuild = nAbilityBuildList, nTalentBuildList
X.sBuyList = {'item_double_branches','item_magic_stick','item_tango'}
if sRole == 'pos_4' then table.insert(X.sBuyList,'item_ward_observer') end
if sRole == 'pos_4' or sRole == 'pos_5' then table.insert(X.sBuyList,'item_ward_sentry') end
local core = {'item_faerie_fire','item_blood_grenade','item_magic_wand','item_arcane_boots','item_blink',
    'item_glimmer_cape','item_aghanims_shard','item_ultimate_scepter','item_sheepstick',
    -- Bot policy: late cast range/cooldown utility and natural upgrades; six persistent slots.
    'item_aether_lens','item_ultimate_scepter_2','item_overwhelming_blink','item_octarine_core'}
for _, item in ipairs(core) do table.insert(X.sBuyList,item) end
X.sSellList = {'item_ultimate_scepter','item_magic_wand'}

if J.Role.IsPvNMode() or J.Role.IsAllShadow() then X['sBuyList'], X['sSellList'] = { 'PvN_antimage' }, {} end

nAbilityBuildList, nTalentBuildList, X['sBuyList'], X['sSellList'] = J.SetUserHeroInit( nAbilityBuildList, nTalentBuildList, X['sBuyList'], X['sSellList'] )
X['sSkillList'] = J.Skill.GetSkillList( sAbilityList, nAbilityBuildList, sTalentList, nTalentBuildList )
-- Fourth Phantom's Embrace point at 10, then the first talent at 11. Preserve custom progressions.
if nAbilityBuildList == defaultAbilityBuild and nTalentBuildList == defaultTalentBuild then
    X.sSkillList[10], X.sSkillList[11] = X.sSkillList[11], X.sSkillList[10]
end
X['bDeafaultAbility'] = false
X['bDeafaultItem'] = false

function X.MinionThink(hMinionUnit)
    Minion.MinionThink(hMinionUnit)
end

local StrokeOfFate      = bot:GetAbilityByName('grimstroke_dark_artistry')
local PhantomsEmbrace   = bot:GetAbilityByName('grimstroke_ink_creature')
local InkSwell          = bot:GetAbilityByName('grimstroke_spirit_walk')
local InkExplosion      = bot:GetAbilityByName('grimstroke_return')
local DarkPortrait      = bot:GetAbilityByName('grimstroke_dark_portrait')
local SoulBind          = bot:GetAbilityByName('grimstroke_soul_chain')

local StrokeOfFateDesire, StrokeOfFateLocation
local PhantomsEmbraceDesire, PhantomsEmbraceTarget
local InkSwellDesire, InkSwellTarget
local InkExplosionDesire
local DarkPortraitDesire, DarkPortraitTarget
local SoulBindDesire, SoulBindTarget

local InkSwellCastTime = -1

local botTarget

function X.SkillsComplement()
	if J.CanNotUseAbility(bot) then return end

    botTarget = J.GetProperTarget(bot)
    local interruptDesire, interruptTarget = G.Phantom(bot, PhantomsEmbrace, true)
    if interruptDesire > 0 then bot:Action_UseAbilityOnEntity(PhantomsEmbrace, interruptTarget); return end

    InkSwellDesire, InkSwellTarget = X.ConsiderInkSwell()
    if InkSwellDesire > 0
    then
        bot:Action_UseAbilityOnEntity(InkSwell, InkSwellTarget)
        InkSwellCastTime = DotaTime()
        return
    end

    InkExplosionDesire = X.ConsiderInkExplosion()
    if InkExplosionDesire > 0
    then
        bot:Action_UseAbility(InkExplosion)
        return
    end

    SoulBindDesire, SoulBindTarget = X.ConsiderSoulBind()
    if SoulBindDesire > 0
    then
        bot:Action_UseAbilityOnEntity(SoulBind, SoulBindTarget)
        return
    end

    PhantomsEmbraceDesire, PhantomsEmbraceTarget = X.ConsiderPhantomsEmbrace()
    if PhantomsEmbraceDesire > 0
    then
        bot:Action_UseAbilityOnEntity(PhantomsEmbrace, PhantomsEmbraceTarget)
        return
    end

    StrokeOfFateDesire, StrokeOfFateLocation = X.ConsiderStrokeOfFate()
    if StrokeOfFateDesire > 0
    then
        bot:Action_UseAbilityOnLocation(StrokeOfFate, StrokeOfFateLocation)
        return
    end

    DarkPortraitDesire, DarkPortraitTarget = X.ConsiderDarkPortrait()
    if DarkPortraitDesire > 0
    then
        bot:Action_UseAbilityOnEntity(DarkPortrait, DarkPortraitTarget)
        return
    end
end

function X.ConsiderStrokeOfFate()
    if not J.CanCastAbility(StrokeOfFate)
    then
        return BOT_ACTION_DESIRE_NONE, 0
    end

    local combatDesire, combatPoint = G.Stroke(bot, StrokeOfFate)
    if combatDesire > 0 then return combatDesire, combatPoint end
	local nCastRange = G.Range(bot, StrokeOfFate)
	local nCastPoint = StrokeOfFate:GetCastPoint()
	local nRadius = StrokeOfFate:GetSpecialValueInt('end_radius')
	local nSpeed = StrokeOfFate:GetSpecialValueInt('projectile_speed')
    local nDamage = StrokeOfFate:GetSpecialValueInt('damage')
    local nAbilityLevel = StrokeOfFate:GetLevel()

	local nEnemyHeroes = bot:GetNearbyHeroes(nCastRange, true, BOT_MODE_NONE)
	if (J.IsPushing(bot) or J.IsDefending(bot))
    and J.GetManaAfter(StrokeOfFate:GetManaCost()) > 0.4
    and nAbilityLevel >= 3
	then
		local nLocationAoE = bot:FindAoELocation(true, true, bot:GetLocation(), nCastRange, nRadius, nCastPoint, 0)
		if nLocationAoE.count >= 2
        then
            local weakTarget = J.GetVulnerableUnitNearLoc(bot, true, true, nCastRange, nRadius, nLocationAoE.targetloc)
            if weakTarget ~= nil
            then
                local nDelay = (GetUnitToUnitDistance(bot, weakTarget) / nSpeed) + nCastPoint
                return BOT_ACTION_DESIRE_HIGH, weakTarget:GetExtrapolatedLocation(nDelay)
            end
		end

        local nEnemyLaneCreeps = bot:GetNearbyLaneCreeps(nCastRange, true)
		if nEnemyLaneCreeps ~= nil and #nEnemyLaneCreeps >= 3
        and J.CanBeAttacked(nEnemyLaneCreeps[1])
        and nEnemyHeroes ~= nil and #nEnemyHeroes == 0
        and not J.IsRunning(nEnemyLaneCreeps[1])
        and not J.IsThereNonSelfCoreNearby(1000)
        then
			return BOT_ACTION_DESIRE_HIGH, J.GetCenterOfUnits(nEnemyLaneCreeps)
		end
	end

    local nAllyHeroes = bot:GetNearbyHeroes(nCastRange, false, BOT_MODE_NONE)
    for _, allyHero in pairs(nAllyHeroes)
    do
        local nAllyInRangeEnemy = allyHero:GetNearbyHeroes(1600, true, BOT_MODE_NONE)

        if J.IsValidHero(allyHero)
        and J.IsRetreating(allyHero)
        and allyHero:GetActiveModeDesire() >= 0.5
        and not allyHero:IsIllusion()
        then
            if J.IsValidHero(nAllyInRangeEnemy[1])
            and J.CanCastOnNonMagicImmune(nAllyInRangeEnemy[1])
            and J.IsInRange(bot, nAllyInRangeEnemy[1], nCastRange)
            and J.IsChasingTarget(nAllyInRangeEnemy[1], allyHero)
            and not J.IsChasingTarget(nAllyInRangeEnemy[1], bot)
            and not J.IsDisabled(nAllyInRangeEnemy[1])
            and not J.IsTaunted(nAllyInRangeEnemy[1])
            and not J.IsSuspiciousIllusion(nAllyInRangeEnemy[1])
            and not nAllyInRangeEnemy[1]:HasModifier('modifier_enigma_black_hole_pull')
            and not nAllyInRangeEnemy[1]:HasModifier('modifier_faceless_void_chronosphere_freeze')
            and not nAllyInRangeEnemy[1]:HasModifier('modifier_necrolyte_reapers_scythe')
            then
                local nDelay = (GetUnitToUnitDistance(bot, nAllyInRangeEnemy[1]) / nSpeed) + nCastPoint
                return BOT_ACTION_DESIRE_HIGH, nAllyInRangeEnemy[1]:GetExtrapolatedLocation(nDelay)
            end
        end
    end

    if J.IsDoingRoshan(bot)
    then
        if J.IsRoshan(botTarget)
        and J.CanCastOnNonMagicImmune(botTarget)
        and J.IsInRange(bot, botTarget, bot:GetAttackRange())
        and J.IsAttacking(bot)
        then
            return BOT_ACTION_DESIRE_HIGH, botTarget:GetLocation()
        end
    end

    if J.IsDoingTormentor(bot)
    then
        if J.IsTormentor(botTarget)
        and J.IsInRange(bot, botTarget, bot:GetAttackRange())
        and J.GetHP(botTarget) < 0.5
        and J.IsAttacking(bot)
        then
            return BOT_ACTION_DESIRE_HIGH, botTarget:GetLocation()
        end
    end

    return BOT_ACTION_DESIRE_NONE, 0
end

function X.ConsiderPhantomsEmbrace()
    return G.Phantom(bot, PhantomsEmbrace)
end
function X.ConsiderInkSwell()
    return G.Swell(bot, InkSwell)
end
function X.ConsiderInkExplosion()
    -- Current Ink Swell cannot end early (can_end_early = 0).
    return BOT_ACTION_DESIRE_NONE
end
function X.ConsiderSoulBind()
    return G.Bind(bot, SoulBind)
end
function X.ConsiderDarkPortrait()
    return G.Portrait(bot, DarkPortrait)
end
return X
