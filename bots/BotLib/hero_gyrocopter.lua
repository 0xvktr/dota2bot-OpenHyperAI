local X = {}
local bot = GetBot()

local J = require( GetScriptDirectory()..'/FunLib/jmz_func' )
local G = require(GetScriptDirectory()..'/FunLib/gyrocopter_abilities')
local Minion = dofile( GetScriptDirectory()..'/FunLib/aba_minion' )
local sTalentList = J.Skill.GetTalentList( bot )
local sAbilityList = J.Skill.GetAbilityList( bot )
local sRole = J.Item.GetRoleItemsBuyList( bot )

-- Updated to 7.41f from D2PT: carry/support/hard support; other picks use carry.
local BuildData = require(GetScriptDirectory()..'/BotLib/Builds/gyrocopter')
X.buildMetadata = BuildData
X.neutralPreferences = BuildData.neutrals[sRole]
-- [1] Rocket Barrage, [2] Homing Missile, [3] Flak Cannon, [6] Call Down.
local isSupport = sRole == 'pos_4' or sRole == 'pos_5'
local nAbilityBuildList = isSupport and {1,2,1,2,1,6,1,2,2,3,6,3,3,3,6}
    or {3,2,3,2,3,6,3,2,2,1,6,1,1,1,6}
local nTalentBuildList = J.Skill.GetTalentBuild(isSupport and {
    t10={0,10}, -- +25% Homing Missile damage
    t15={0,10}, -- +0.3s Homing Missile stun
    t20={10,0}, -- +14 Rocket Barrage damage
    t25={10,0}, -- -40s Call Down cooldown
} or {
    t10={10,0}, -- +150 Health
    t15={10,0}, -- +25 Flak Cannon damage
    t20={0,10}, -- +3 Flak Cannon attacks
    t25={0,10}, -- -6s Flak Cannon cooldown
})
local defaultAbilityBuild, defaultTalentBuild = nAbilityBuildList, nTalentBuildList
if sRole == 'pos_4' then
    X.sBuyList = {'item_boots','item_ward_observer','item_ward_sentry','item_blood_grenade',
        'item_magic_wand','item_urn_of_shadows','item_tranquil_boots','item_essence_distiller',
        'item_aghanims_shard','item_glimmer_cape','item_blink','item_force_staff','item_cyclone',
        -- Bot policy: natural boot/Blink/Euls upgrades keep six persistent slots.
        'item_ancient_janggo','item_boots_of_bearing','item_overwhelming_blink','item_wind_waker'}
    -- Distiller consumes Urn; avoid buying the mutually exclusive Vessel path.
    X.sSellList = {'item_blink','item_magic_wand'}
elseif sRole == 'pos_5' then
    X.sBuyList = {'item_double_branches','item_magic_stick','item_tango','item_ward_observer',
        'item_ward_sentry','item_ward_sentry','item_blood_grenade','item_magic_wand','item_tranquil_boots',
        'item_aghanims_shard','item_glimmer_cape','item_force_staff','item_cyclone','item_blink',
        -- Bot policy: team mobility, cast range and natural upgrades; six persistent slots.
        'item_ancient_janggo','item_boots_of_bearing','item_aether_lens','item_overwhelming_blink','item_wind_waker'}
    X.sSellList = {'item_blink','item_magic_wand'}
else
    X.sBuyList = {'item_magic_wand','item_faerie_fire','item_faerie_fire','item_falcon_blade',
        'item_power_treads','item_lesser_crit','item_ultimate_scepter','item_lifesteal',
        'item_black_king_bar','item_greater_crit','item_satanic',
        -- Bot policy: consume Scepter before observed Blink/Butterfly, then upgrade Blink.
        'item_ultimate_scepter_2','item_blink','item_butterfly','item_swift_blink','item_moon_shard'}
    X.sSellList = {'item_black_king_bar','item_magic_wand','item_butterfly','item_falcon_blade'}
end

if J.Role.IsPvNMode() or J.Role.IsAllShadow() then X['sBuyList'], X['sSellList'] = { 'PvN_antimage' }, {} end

nAbilityBuildList, nTalentBuildList, X['sBuyList'], X['sSellList'] = J.SetUserHeroInit( nAbilityBuildList, nTalentBuildList, X['sBuyList'], X['sSellList'] )
X['sSkillList'] = J.Skill.GetSkillList( sAbilityList, nAbilityBuildList, sTalentList, nTalentBuildList )
-- D2PT: attributes at 10, talents at 11/15; preserve custom builds.
if nAbilityBuildList == defaultAbilityBuild and nTalentBuildList == defaultTalentBuild then
    table.insert(X.sSkillList,10,'special_bonus_attributes')
    X.sSkillList[12], X.sSkillList[13] = X.sSkillList[13], X.sSkillList[12]
    X.sSkillList[15], X.sSkillList[16] = X.sSkillList[16], X.sSkillList[15]
end
X['bDeafaultAbility'] = false
X['bDeafaultItem'] = false

function X.MinionThink(hMinionUnit)
    Minion.MinionThink(hMinionUnit)
end

local RocketBarrage = bot:GetAbilityByName('gyrocopter_rocket_barrage')
local HomingMissile = bot:GetAbilityByName('gyrocopter_homing_missile')
local FlakCannon    = bot:GetAbilityByName('gyrocopter_flak_cannon')
local CallDown      = bot:GetAbilityByName('gyrocopter_call_down')

local RocketBarrageDesire
local HomingMissileDesire, HomingMissileTarget
local FlakCannonDesire
local CallDownDesire, CallDownLocation

function X.SkillsComplement()
    if J.CanNotUseAbility( bot ) then return end

    HomingMissileDesire, HomingMissileTarget = X.ConsiderHomingMissile()
    if HomingMissileDesire > 0
    then
        J.SetQueuePtToINT(bot, false)
        bot:Action_UseAbilityOnEntity(HomingMissile, HomingMissileTarget)
        return
    end

    CallDownDesire, CallDownLocation = X.ConsiderCallDown()
    if CallDownDesire > 0
    then
        bot:Action_UseAbilityOnLocation(CallDown, CallDownLocation)
        return
    end

    FlakCannonDesire = X.ConsiderFlakCannon()
    if FlakCannonDesire > 0
    then
        J.SetQueuePtToINT(bot, false)
        bot:Action_UseAbility(FlakCannon)
        return
    end

    RocketBarrageDesire = X.ConsiderRocketBarrage()
    if RocketBarrageDesire > 0
    then
        J.SetQueuePtToINT(bot, false)
        bot:Action_UseAbility(RocketBarrage)
        return
    end
end

function X.ConsiderRocketBarrage()
    if not J.CanCastAbility(RocketBarrage) or bot:HasModifier('modifier_gyrocopter_rocket_barrage') then return 0 end
    local combat = G.Barrage(bot, RocketBarrage)
    if combat > 0 then return combat end
    local nRadius = RocketBarrage:GetSpecialValueInt('radius')
    local nAbilityLevel = RocketBarrage:GetLevel()
    local nMana = J.GetMP(bot)
    local botTarget = J.GetProperTarget(bot)
    if J.IsFarming(bot)
    and nMana > 0.5
    and nAbilityLevel >= 2
    then
        local nNeutralCreeps = bot:GetNearbyNeutralCreeps(nRadius)

        if nNeutralCreeps ~= nil and #nNeutralCreeps >= 2
        then
            return BOT_ACTION_DESIRE_HIGH
        end
    end

	if J.IsDoingRoshan(bot)
	then
		if J.IsRoshan(botTarget)
        and J.CanCastOnNonMagicImmune(botTarget)
        and J.IsInRange(bot, botTarget, nRadius)
        and J.IsAttacking(bot)
		then
			return BOT_ACTION_DESIRE_HIGH
		end
	end

    if J.IsDoingTormentor(bot)
	then
		if J.IsTormentor(botTarget)
        and J.IsInRange(bot, botTarget, nRadius)
        and J.IsAttacking(bot)
		then
			return BOT_ACTION_DESIRE_HIGH
		end
	end


    return BOT_ACTION_DESIRE_NONE
end

function X.ConsiderHomingMissile()
    return G.Missile(bot, HomingMissile)
end
function X.ConsiderFlakCannon()
    return G.Flak(bot, FlakCannon)
end
function X.ConsiderCallDown()
    return G.Call(bot, CallDown)
end
return X
