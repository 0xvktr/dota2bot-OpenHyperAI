local X = {}
local bot = GetBot()

local J = require( GetScriptDirectory()..'/FunLib/jmz_func' )
local SpellDecisions = require(GetScriptDirectory()..'/FunLib/rubick_hero/meepo')
local Minion = dofile( GetScriptDirectory()..'/FunLib/aba_minion' )
local sTalentList = J.Skill.GetTalentList( bot )
local sAbilityList = J.Skill.GetAbilityList( bot )
local sRole = J.Item.GetRoleItemsBuyList( bot )

-- Updated to 7.41f from D2PT; forced skipped roles use pos 2.
local BuildData = require(GetScriptDirectory()..'/BotLib/Builds/meepo')
X.buildMetadata = BuildData
X.neutralPreferences = BuildData.neutrals[sRole]
-- [1] Earthbind, [2] Poof, [3] Ransack, [6] Divided We Stand (3/10/17/24).
local nAbilityBuildList = {3,1,6,2,2,2,2,3,3,6,3,1,1,1,6,6}
local nTalentBuildList = J.Skill.GetTalentBuild({
    t10={0,10}, -- Strength
    t15={10,0}, -- Poof damage
    t20={0,10}, -- Earthbind True Strike
    t25={10,0}, -- Poof cast duration
})
if sRole == 'pos_1' then
    X.sBuyList = {
        'item_quelling_blade','item_slippers','item_double_branches','item_circlet','item_tango',
        'item_wraith_band','item_power_treads','item_yasha','item_sange_and_yasha','item_skadi',
        'item_aghanims_shard','item_ultimate_scepter','item_blink',
        -- Bot policy: late upgrades and continuation.
        'item_ultimate_scepter_2','item_diffusal_blade','item_disperser','item_swift_blink','item_butterfly',
        'item_moon_shard',
    }
    X.sSellList = {'item_skadi','item_quelling_blade','item_blink','item_wraith_band'}
else
    -- Observed mid opening ward omitted.
    X.sBuyList = {
        'item_quelling_blade','item_slippers','item_double_branches','item_circlet','item_tango',
        'item_wraith_band','item_power_treads','item_yasha','item_sange_and_yasha','item_skadi',
        'item_aghanims_shard','item_ultimate_scepter','item_blink',
        -- Bot policy: late upgrades and continuation.
        'item_ultimate_scepter_2','item_sheepstick','item_swift_blink','item_butterfly','item_moon_shard',
    }
    X.sSellList = {'item_skadi','item_quelling_blade','item_blink','item_wraith_band'}
end

if J.Role.IsPvNMode() or J.Role.IsAllShadow() then X['sBuyList'], X['sSellList'] = { 'PvN_mid' }, {} end

nAbilityBuildList, nTalentBuildList, X['sBuyList'], X['sSellList'] = J.SetUserHeroInit( nAbilityBuildList, nTalentBuildList, X['sBuyList'], X['sSellList'] )

X['sSkillList'] = J.Skill.GetSkillList( sAbilityList, nAbilityBuildList, sTalentList, nTalentBuildList )

X['bDeafaultAbility'] = false
X['bDeafaultItem'] = false

function X.MinionThink(hMinionUnit)
    Minion.MinionThink(hMinionUnit)
end

----------------------------------------------
-- EarthBind deduplication across clones
----------------------------------------------
local function RecordEarthBindCast(location)
    bot.earth_bind_cast = {
        time = GameTime(),
        flight = bot:GetAbilityByName('meepo_earthbind'):GetCastPoint() + GetUnitToLocationDistance(bot, location) / bot:GetAbilityByName('meepo_earthbind'):GetSpecialValueInt('speed'),
        location = location,
    }
end

----------------------------------------------
-- Ability handles (re-fetched in SkillsComplement)
----------------------------------------------
local EarthBind         = bot:GetAbilityByName('meepo_earthbind')
local Poof              = bot:GetAbilityByName('meepo_poof')
local Dig               = bot:GetAbilityByName('meepo_petrify')
local MegaMeepo         = bot:GetAbilityByName('meepo_megameepo')
local MegaMeepoFling    = bot:GetAbilityByName('meepo_megameepo_fling')

local EarthBindDesire, EarthBindLocation
local PoofDesire, PoofTarget
local DigDesire
local MegaMeepoDesire
local MegaMeepoFlingDesire, MegaMeepoFlingFlingTarget

local Meepos = {}

-- Cached per-tick variables
local botTarget
local botHP
local nAllyHeroes
local nEnemyHeroes
local bAttacking

function X.SkillsComplement()
    if J.CanNotUseAbility(bot) then return end

    -- Re-fetch ability handles each tick for safety
    EarthBind      = bot:GetAbilityByName('meepo_earthbind')
    Poof           = bot:GetAbilityByName('meepo_poof')
    Dig            = bot:GetAbilityByName('meepo_petrify')
    MegaMeepo      = bot:GetAbilityByName('meepo_megameepo')
    MegaMeepoFling = bot:GetAbilityByName('meepo_megameepo_fling')

    -- Cache per-tick variables
    Meepos       = J.GetMeepos()
    botTarget    = J.GetProperTarget(bot)
    botHP        = J.GetHP(bot)
    nAllyHeroes  = J.GetNearbyHeroes(bot, 1200, false, BOT_MODE_NONE)
    nEnemyHeroes = J.GetNearbyHeroes(bot, 1200, true, BOT_MODE_NONE)
    bAttacking   = J.IsAttacking(bot)

    if SpellDecisions.MegaUseful(MegaMeepo) then
        bot:Action_UseAbility(MegaMeepo)
        return
    end
    if SpellDecisions.DigUseful(Dig) then
        bot:Action_UseAbility(Dig)
        return
    end
    local interrupt = SpellDecisions.NetPoint(EarthBind, true)
    if interrupt ~= nil then
        J.SetQueuePtToINT(bot, false, EarthBind)
        bot:ActionQueue_UseAbilityOnLocation(EarthBind, interrupt)
        RecordEarthBindCast(interrupt)
        return
    end
    PoofDesire, PoofTarget = X.ConsiderPoof()
    if PoofDesire > 0 then
        J.SetQueuePtToINT(bot, false, Poof)
        bot:ActionQueue_UseAbilityOnEntity(Poof, PoofTarget)
        return
    end
    EarthBindDesire, EarthBindLocation = X.ConsiderEarthBind()
    if EarthBindDesire > 0
    then
        J.SetQueuePtToINT(bot, false, EarthBind)
        bot:ActionQueue_UseAbilityOnLocation(EarthBind, EarthBindLocation)
        RecordEarthBindCast(EarthBindLocation)
        return
    end

    MegaMeepoFlingDesire, MegaMeepoFlingFlingTarget = X.ConsiderMegaMeepoFling()
    if MegaMeepoFlingDesire > 0
    then
        bot:ActionQueue_UseAbilityOnEntity(MegaMeepoFling, MegaMeepoFlingFlingTarget)
        return
    end
end

function X.ConsiderEarthBind()
    local point = SpellDecisions.NetPoint(EarthBind, false)
    return point ~= nil and BOT_ACTION_DESIRE_HIGH or BOT_ACTION_DESIRE_NONE, point
end
function X.ConsiderPoof()
    local target = SpellDecisions.PoofTarget(Poof)
    return target ~= nil and BOT_ACTION_DESIRE_HIGH or BOT_ACTION_DESIRE_NONE, target
end
function X.ConsiderDig()
    return SpellDecisions.DigUseful(Dig) and BOT_ACTION_DESIRE_HIGH or BOT_ACTION_DESIRE_NONE
end
function X.ConsiderMegaMeepo()
    return SpellDecisions.MegaUseful(MegaMeepo) and BOT_ACTION_DESIRE_HIGH or BOT_ACTION_DESIRE_NONE
end
function X.ConsiderMegaMeepoFling()
    local target = SpellDecisions.FlingTarget(MegaMeepoFling)
    return target ~= nil and BOT_ACTION_DESIRE_HIGH or BOT_ACTION_DESIRE_NONE, target
end
return X
