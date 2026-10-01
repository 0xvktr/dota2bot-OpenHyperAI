local X             = {}
local bot           = GetBot()

local J             = require( GetScriptDirectory()..'/FunLib/jmz_func' )
local Minion        = dofile( GetScriptDirectory()..'/FunLib/aba_minion' )
local sTalentList   = J.Skill.GetTalentList( bot )
local sAbilityList  = J.Skill.GetAbilityList( bot )
local sRole   = J.Item.GetRoleItemsBuyList( bot )

-- Updated to 7.41f from D2PT: hard support, offlane and support; skipped roles use pos 5 without wards.
local BuildData = require(GetScriptDirectory()..'/BotLib/Builds/elder_titan')
X.buildMetadata = BuildData
X.neutralPreferences = BuildData.neutrals[sRole]
-- [1] Echo Stomp, [2] Astral Spirit, [3] Natural Order, [6] Earth Splitter.
local nAbilityBuildList, nTalentBuildList
if sRole == 'pos_3' then
    -- D2PT offlane delays Earth Splitter past level 10.
    nAbilityBuildList = {2,3,2,3,2,3,2,3,1,1,6,1,1,6,6}
    nTalentBuildList = J.Skill.GetTalentBuild({
        t10={0,10}, -- +2.5% Astral Spirit move speed per hero
        t15={10,0}, -- Momentum grants 20% attack speed
        t20={0,10}, -- +30 Astral Spirit hero attack damage
        t25={10,0}, -- 100% cleave
    })
else
    nAbilityBuildList = {2,3,2,1,1,6,1,1,3,3,6,3,2,2,6}
    nTalentBuildList = J.Skill.GetTalentBuild({
        t10={10,0}, -- +150 Echo Stomp wake damage threshold
        t15={0,10}, -- +75 Echo Stomp damage
        t20=sRole == 'pos_4' and {0,10} or {10,0}, -- +30 Spirit hero damage / +150 Natural Order radius
        t25=sRole == 'pos_4' and {10,0} or {0,10}, -- 100% cleave / -60s Earth Splitter cooldown
    })
end
local defaultAbilityBuild, defaultTalentBuild = nAbilityBuildList, nTalentBuildList
if sRole == 'pos_3' then
    X.sBuyList = {'item_quelling_blade', 'item_tango', 'item_enchanted_mango', 'item_blight_stone',
        'item_phase_boots', 'item_lifesteal', 'item_soul_ring', 'item_mask_of_madness',
        'item_ultimate_scepter', 'item_echo_sabre', 'item_aghanims_shard', 'item_lesser_crit',
        'item_harpoon', 'item_greater_crit',
        -- Bot policy: Blessing and late BKB/Nullifier.
        'item_ultimate_scepter_2', 'item_black_king_bar', 'item_nullifier'}
    X.sSellList = {'item_echo_sabre', 'item_quelling_blade', 'item_lesser_crit', 'item_blight_stone',
        'item_black_king_bar', 'item_soul_ring'}
elseif sRole == 'pos_4' then
    X.sBuyList = {'item_boots', 'item_ward_observer', 'item_ward_sentry', 'item_blood_grenade',
        'item_tranquil_boots', 'item_magic_wand', 'item_soul_ring', 'item_ancient_janggo',
        'item_cyclone', 'item_aghanims_shard', 'item_boots_of_bearing', 'item_ultimate_scepter',
        -- Bot policy: late positioning and natural upgrades.
        'item_force_staff', 'item_ultimate_scepter_2', 'item_wind_waker'}
    X.sSellList = {'item_force_staff', 'item_magic_wand'}
else
    X.sBuyList = {'item_boots', 'item_tango',
        'item_tranquil_boots', 'item_magic_wand', 'item_ancient_janggo', 'item_cyclone',
        'item_aghanims_shard', 'item_boots_of_bearing',
        -- Bot policy: Force Staff, Scepter and Wind Waker.
        'item_force_staff', 'item_ultimate_scepter', 'item_ultimate_scepter_2', 'item_wind_waker'}
    X.sSellList = {'item_ultimate_scepter', 'item_magic_wand'}
end

if J.Role.IsPvNMode() or J.Role.IsAllShadow() then X['sBuyList'], X['sSellList'] = { 'PvN_antimage' }, {} end

nAbilityBuildList, nTalentBuildList, X['sBuyList'], X['sSellList'] = J.SetUserHeroInit( nAbilityBuildList, nTalentBuildList, X['sBuyList'], X['sSellList'] )

X['sSkillList'] = J.Skill.GetSkillList( sAbilityList, nAbilityBuildList, sTalentList, nTalentBuildList )
-- D2PT spends level 10 on an ability; first talent comes at 11. Preserve custom overrides.
if nAbilityBuildList == defaultAbilityBuild and nTalentBuildList == defaultTalentBuild then
    X.sSkillList[10], X.sSkillList[11] = X.sSkillList[11], X.sSkillList[10]
end

X['bDeafaultAbility'] = false
X['bDeafaultItem'] = false

local Stomp, Astral, Move, Return, Splitter
local spirit, touched, observedAt, returning = nil, {}, 0, false

local function Refresh()
    Stomp = bot:GetAbilityByName('elder_titan_echo_stomp')
    Astral = bot:GetAbilityByName('elder_titan_ancestral_spirit')
    Move = bot:GetAbilityByName('elder_titan_move_spirit')
    Return = bot:GetAbilityByName('elder_titan_return_spirit')
    Splitter = bot:GetAbilityByName('elder_titan_earth_splitter')
end

local function OwnedSpirit(unit)
    return unit ~= nil and not unit:IsNull() and unit:IsAlive()
        and unit:GetTeam() == bot:GetTeam() and unit:GetPlayerID() == bot:GetPlayerID()
        and string.find(unit:GetUnitName(), 'elder_titan_ancestral_spirit', 1, true) ~= nil
end

local function ObserveSpirit(unit)
    if not OwnedSpirit(unit) then return false end
    if spirit ~= unit then spirit, touched, observedAt, returning = unit, {}, DotaTime(), false end
    return true
end

local function FindSpirit()
    if not OwnedSpirit(spirit) then spirit, touched = nil, {} end
    -- Linked handles must actually exist; stealing Stomp does not imply a spirit.
    if Astral == nil or Return == nil or Return:IsHidden() then spirit, touched = nil, {}; return end
    for _, unit in pairs(GetUnitList(UNIT_LIST_ALLIES)) do
        if ObserveSpirit(unit) then break end
    end
end

local function Enemy(unit, piercing)
    return J.IsValidHero(unit) and not J.IsSuspiciousIllusion(unit)
        and not unit:IsInvulnerable() and (piercing or J.CanCastOnNonMagicImmune(unit))
end

local function Sleeping(unit)
    return unit:HasModifier('modifier_elder_titan_echo_stomp')
end

local function Range(ability)
    local range = ability:GetCastRange()
    for slot = 0, 5 do
        local item = bot:GetItemInSlot(slot)
        if item ~= nil and item:GetName() == 'item_aether_lens' then
            range = range + item:GetSpecialValueInt('cast_range_bonus'); break
        end
    end
    local supremacy = bot:GetAbilityByName('rubick_arcane_supremacy')
    if supremacy ~= nil and supremacy:IsTrained() and not J.HasBreakModifier(bot) then
        range = range + supremacy:GetSpecialValueInt('cast_range')
    end
    return range
end

local function Bound(point, range)
    local offset = point - bot:GetLocation()
    return offset:Length2D() > range and bot:GetLocation() + offset:Normalized() * range or point
end

local function PhysicalDamage(unit, damage)
    if J.IsInEtherealForm(unit) or unit:HasModifier('modifier_omniknight_guardian_angel')
        or unit:HasModifier('modifier_winter_wyvern_cold_embrace') then return 0 end
    return unit:GetActualIncomingDamage(damage, DAMAGE_TYPE_PHYSICAL)
end

local function StompHits(unit)
    local point = J.GetCorrectLoc(unit, Stomp:GetCastPoint() + Stomp:GetChannelTime())
    local physical = GetUnitToLocationDistance(bot, point) <= Stomp:GetSpecialValueInt('radius')
    -- A copied spirit needs its own actual Stomp handle before contributing damage/control.
    local echo = spirit ~= nil and spirit:GetAbilityByName('elder_titan_echo_stomp_spirit') or nil
    local magical = echo ~= nil and echo:IsTrained()
        and GetUnitToLocationDistance(spirit, point) <= echo:GetSpecialValueInt('radius')
    return physical, magical, echo
end

function X.ConsiderStomp()
    if not J.CanCastAbility(Stomp) then return BOT_ACTION_DESIRE_NONE end
    -- Shard alt-cast swaps location; do not issue an unverified teleport command.
    if bot:HasShard() and Stomp:GetAutoCastState() then return BOT_ACTION_DESIRE_NONE end
    local count = 0
    local target = J.GetProperTarget(bot)
    local heroes = J.GetNearbyHeroes(bot, 1600, true, BOT_MODE_NONE)
    if spirit ~= nil then
        local seen = {};for _, enemy in pairs(heroes) do seen[enemy] = true end
        for _, enemy in pairs(J.GetNearbyHeroes(spirit, 1600, true, BOT_MODE_NONE)) do
            if not seen[enemy] then heroes[#heroes+1] = enemy;seen[enemy] = true end
        end
    end
    for _, enemy in pairs(heroes) do
        if Enemy(enemy, false) and not Sleeping(enemy) then
            local physical, magical, echo = StompHits(enemy)
            if physical or magical then
                count = count + 1
                local damage = physical and PhysicalDamage(enemy, Stomp:GetSpecialValueInt('stomp_damage')) or 0
                if magical then damage = damage + enemy:GetActualIncomingDamage(
                    echo:GetSpecialValueInt('stomp_damage'), DAMAGE_TYPE_MAGICAL) end
                local delay = Stomp:GetCastPoint() + Stomp:GetChannelTime()
                local interrupt = enemy:IsChanneling() and (not enemy:HasModifier('modifier_teleporting')
                    or J.GetModifierTime(enemy, 'modifier_teleporting') >= delay)
                if interrupt or (not J.CannotBeKilled(bot, enemy)
                    and damage >= enemy:GetHealth() + enemy:GetHealthRegen() * delay)
                    or (J.IsGoingOnSomeone(bot) and enemy == target)
                    or (J.IsRetreating(bot) and J.IsChasingTarget(enemy, bot)) then
                    return BOT_ACTION_DESIRE_HIGH
                end
            end
        end
    end
    if count >= 2 and J.IsInTeamFight(bot, 1200) then return BOT_ACTION_DESIRE_HIGH end
    return BOT_ACTION_DESIRE_NONE
end

local function SplitterHit(unit, point, delay)
    local offset = J.GetCorrectLoc(unit, delay) - bot:GetLocation()
    local direction = (point - bot:GetLocation()):Normalized()
    local along = offset.x * direction.x + offset.y * direction.y
    return along >= 0 and along <= Splitter:GetSpecialValueInt('crack_distance')
        and math.abs(offset.x * direction.y - offset.y * direction.x)
            <= Splitter:GetSpecialValueInt('crack_width') / 2
end

function X.ConsiderSplitter()
    if not J.CanCastAbility(Splitter) then return BOT_ACTION_DESIRE_NONE end
    local delay = Splitter:GetCastPoint() + Splitter:GetSpecialValueFloat('crack_time')
    local heroes = J.GetNearbyHeroes(bot, 1600, true, BOT_MODE_NONE)
    for _, enemy in pairs(heroes) do
        if Enemy(enemy, true) then
            local point = Bound(J.GetCorrectLoc(enemy, delay), Range(Splitter))
            if GetUnitToLocationDistance(bot, point) > 0 and SplitterHit(enemy, point, delay) then
                local half = enemy:GetMaxHealth() * Splitter:GetSpecialValueInt('damage_pct') / 200
                local damage = PhysicalDamage(enemy, half)
                    + enemy:GetActualIncomingDamage(half, DAMAGE_TYPE_MAGICAL)
                if not J.CannotBeKilled(bot, enemy) and damage >= enemy:GetHealth() + enemy:GetHealthRegen() * delay then
                    return BOT_ACTION_DESIRE_HIGH, point
                end
                for _, modifier in ipairs({'modifier_elder_titan_echo_stomp',
                    'modifier_faceless_void_chronosphere_freeze', 'modifier_enigma_black_hole_pull'}) do
                    if enemy:HasModifier(modifier) and J.GetModifierTime(enemy, modifier) >= delay then
                        return BOT_ACTION_DESIRE_HIGH, point
                    end
                end
                local count = 0
                for _, other in pairs(heroes) do
                    if Enemy(other, true) and SplitterHit(other, point, delay) then count = count + 1 end
                end
                if count >= 2 and J.IsInTeamFight(bot, 1200) then return BOT_ACTION_DESIRE_HIGH, point end
            end
        end
    end
    return BOT_ACTION_DESIRE_NONE
end

function X.ConsiderAstral()
    if not J.CanCastAbility(Astral) or spirit ~= nil then return BOT_ACTION_DESIRE_NONE end
    local reserve = Stomp ~= nil and Stomp:IsTrained() and Stomp:GetManaCost() or 0
    if Splitter ~= nil and Splitter:IsTrained() then reserve = reserve + Splitter:GetManaCost() end
    local target = J.GetProperTarget(bot)
    if Enemy(target, true) and not Sleeping(target)
        and (J.IsGoingOnSomeone(bot) or J.IsInTeamFight(bot, 1200)) then
        local point = Bound(J.GetCorrectLoc(target, Astral:GetCastPoint()), Range(Astral))
        if GetUnitToLocationDistance(target, point) <= Astral:GetSpecialValueInt('radius') then
            return BOT_ACTION_DESIRE_HIGH, point
        end
    end
    if J.IsLaning(bot) or J.IsFarming(bot) or J.IsPushing(bot) or J.IsDefending(bot) then
        if bot:GetMana() < Astral:GetManaCost() + reserve or not J.IsAllowedToSpam(bot, Astral:GetManaCost()) then
            return BOT_ACTION_DESIRE_NONE
        end
        local creeps = bot:GetNearbyLaneCreeps(1600, true)
        if J.IsFarming(bot) then
            for _, creep in pairs(bot:GetNearbyNeutralCreeps(1600)) do table.insert(creeps, creep) end
        end
        for _, creep in pairs(creeps) do
            if J.IsValid(creep) and not creep:IsInvulnerable() then
                local point, count = Bound(creep:GetLocation(), Range(Astral)), 0
                for _, other in pairs(creeps) do
                    if J.IsValid(other) and GetUnitToLocationDistance(other, point) <= Astral:GetSpecialValueInt('radius') then count = count + 1 end
                end
                if count >= 3 then return BOT_ACTION_DESIRE_HIGH, point end
            end
        end
    end
    return BOT_ACTION_DESIRE_NONE
end

function X.ConsiderSpiritControl()
    if spirit == nil or Astral == nil or returning or spirit:IsChanneling()
        or spirit:IsUsingAbility() or spirit:IsCastingAbility() then return BOT_ACTION_DESIRE_NONE end
    local heroes = J.GetNearbyHeroes(spirit, 1600, true, BOT_MODE_NONE)
    local radius = Astral:GetSpecialValueInt('radius')
    local useful, nextTarget = next(touched) ~= nil, nil
    for _, enemy in pairs(heroes) do
        if Enemy(enemy, true) then
            if GetUnitToUnitDistance(spirit, enemy) <= radius then touched[enemy] = true end
            if touched[enemy] then useful = true end
            if not Sleeping(enemy) and not touched[enemy] and (nextTarget == nil
                or GetUnitToUnitDistance(spirit, enemy) < GetUnitToUnitDistance(spirit, nextTarget)) then nextTarget = enemy end
        end
    end
    if J.IsLaning(bot) or J.IsFarming(bot) or J.IsPushing(bot) or J.IsDefending(bot) then
        local creeps = spirit:GetNearbyLaneCreeps(1600, true)
        if J.IsFarming(bot) then
            for _, creep in pairs(spirit:GetNearbyNeutralCreeps(1600)) do table.insert(creeps, creep) end
        end
        for _, creep in pairs(creeps) do
            if J.IsValid(creep) and not creep:IsInvulnerable() then
                if GetUnitToUnitDistance(spirit, creep) <= radius then touched[creep] = true end
                if touched[creep] then useful = true end
                if nextTarget == nil and not touched[creep] then nextTarget = creep end
            end
        end
    end
    -- Return accumulated damage/movement before fighting; leave sleep setup intact.
    if J.CanCastAbility(Return) and ((useful and nextTarget == nil)
        or (useful and J.IsRetreating(bot)) or DotaTime() - observedAt >= Astral:GetSpecialValueFloat('spirit_duration') - 1) then
        return BOT_ACTION_DESIRE_HIGH, nil, Return
    end
    if nextTarget ~= nil and J.CanCastAbility(Move) then
        return BOT_ACTION_DESIRE_HIGH, J.GetCorrectLoc(nextTarget,
            GetUnitToUnitDistance(spirit, nextTarget) / math.max(spirit:GetCurrentMovementSpeed(), 1)), Move
    end
    return BOT_ACTION_DESIRE_NONE
end

function X.HandleAstralSpiritMinion(unit)
    Refresh()
    if not ObserveSpirit(unit) then return false end
    -- Do not let generic minion orders overwrite synchronized Stomp, or cancel a hero channel.
    return true
end

function X.UseAstralSpirit()
    Refresh(); FindSpirit()
    if J.CanNotUseAbility(bot) or bot:IsChanneling() or bot:IsCastingAbility() or bot:IsUsingAbility() then return false end
    if X.ConsiderStomp() > 0 or X.ConsiderSplitter() > 0 then return false end
    local desire, point, ability = X.ConsiderSpiritControl()
    if desire <= 0 then return false end
    if point ~= nil then bot:Action_UseAbilityOnLocation(ability, point) else bot:Action_UseAbility(ability); returning = true end
    return true
end

function X.MinionThink(unit)
    if X.HandleAstralSpiritMinion(unit) then return end
    Minion.MinionThink(unit)
end

function X.SkillsComplement()
    Refresh(); FindSpirit()
    if J.CanNotUseAbility(bot) or bot:IsChanneling() or bot:IsCastingAbility() or bot:IsUsingAbility() then return end
    local desire, point = X.ConsiderSplitter()
    if desire > 0 then bot:Action_UseAbilityOnLocation(Splitter, point); return end
    desire = X.ConsiderStomp()
    if desire > 0 then bot:Action_UseAbility(Stomp); return end
    desire, point = X.ConsiderAstral()
    if desire > 0 then bot:Action_UseAbilityOnLocation(Astral, point); return end
    X.UseAstralSpirit()
end

return X
