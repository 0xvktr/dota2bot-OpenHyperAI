local X             = {}
local bot           = GetBot()

local J             = require( GetScriptDirectory()..'/FunLib/jmz_func' )
local Minion        = dofile( GetScriptDirectory()..'/FunLib/aba_minion' )
local sTalentList   = J.Skill.GetTalentList( bot )
local sAbilityList  = J.Skill.GetAbilityList( bot )
local sRole   = J.Item.GetRoleItemsBuyList( bot )

-- Updated to 7.41f from D2PT: positions 2 and 3; forced other roles use pos 3.
local BuildData = require(GetScriptDirectory()..'/BotLib/Builds/batrider')
X.buildMetadata = BuildData
X.neutralPreferences = BuildData.neutrals[sRole]
local nAbilityBuildList = {1,2,1,3,1,6,1,3,3,3,6,2,2,2,6}
local nTalentBuildList = J.Skill.GetTalentBuild({
    t10={0,10}, -- Firefly max movement speed
    t15={0,10}, -- Firefly damage per second
    t20={0,10}, -- Attacks apply Sticky Napalm
    t25={10,0}, -- Flamebreak applies Sticky Napalm stacks
})
local defaultAbilityBuild, defaultTalentBuild = nAbilityBuildList, nTalentBuildList
if sRole == 'pos_2' then
    X.sBuyList = {
        'item_tango', 'item_double_branches', 'item_double_branches', 'item_faerie_fire',
        'item_bottle', 'item_magic_wand', 'item_travel_boots', 'item_blink',
        'item_black_king_bar', 'item_force_staff', 'item_shivas_guard',
        'item_aghanims_shard', 'item_sheepstick',
        -- Reviewed late upgrades after D2PT progression; Blessing needs no seventh slot.
        'item_hurricane_pike', 'item_overwhelming_blink', 'item_ultimate_scepter_2',
        'item_travel_boots_2', 'item_moon_shard',
    }
else
    X.sBuyList = {
        'item_double_branches', 'item_circlet', 'item_circlet', 'item_tango', 'item_faerie_fire',
        'item_null_talisman', 'item_bracer', 'item_magic_wand', 'item_tranquil_boots',
        'item_ancient_janggo', 'item_boots_of_bearing', 'item_blink', 'item_black_king_bar',
        -- Force Staff is a common utility branch (34.5%) and appears in late inventories.
        'item_force_staff', 'item_shivas_guard', 'item_aghanims_shard', 'item_ultimate_scepter',
        -- Consume Scepter before adding a sixth permanent item.
        'item_ultimate_scepter_2', 'item_octarine_core', 'item_hurricane_pike',
        'item_overwhelming_blink', 'item_moon_shard',
    }
end
-- Purchase/sale pairs free early inventory slots as the main build arrives.
X.sSellList = {
    'item_force_staff', 'item_magic_wand',
    'item_shivas_guard', 'item_bottle',
    'item_black_king_bar', 'item_bracer',
    'item_shivas_guard', 'item_null_talisman',
}

if J.Role.IsPvNMode() or J.Role.IsAllShadow() then X['sBuyList'], X['sSellList'] = { 'PvN_antimage' }, {} end

nAbilityBuildList, nTalentBuildList, X['sBuyList'], X['sSellList'] = J.SetUserHeroInit( nAbilityBuildList, nTalentBuildList, X['sBuyList'], X['sSellList'] )

X['sSkillList'] = J.Skill.GetSkillList( sAbilityList, nAbilityBuildList, sTalentList, nTalentBuildList )
-- Both popular sequences max Firefly at 10 and take the first talent at 11.
if nAbilityBuildList == defaultAbilityBuild and nTalentBuildList == defaultTalentBuild then
    X.sSkillList[10], X.sSkillList[11] = X.sSkillList[11], X.sSkillList[10]
end

X['bDeafaultAbility'] = false
X['bDeafaultItem'] = false

function X.MinionThink(hMinionUnit)
	Minion.MinionThink(hMinionUnit)
end

local StickyNapalm = bot:GetAbilityByName('batrider_sticky_napalm')
local Flamebreak = bot:GetAbilityByName('batrider_flamebreak')
local Firefly = bot:GetAbilityByName('batrider_firefly')
local FlamingLasso = bot:GetAbilityByName('batrider_flaming_lasso')
local Blink, BlinkLocation, BlackKingBar

function X.SkillsComplement()
    if J.CanNotUseAbility(bot) then return end
    local desire, target = X.ConsiderFlamingLasso()
    if desire > 0 then
        -- Interrupt channels immediately; ordinary grabs can prepare an affordable Firefly.
        if not target:IsChanneling() and Firefly:IsFullyCastable() and not bot:HasModifier('modifier_batrider_firefly')
            and bot:GetMana() >= FlamingLasso:GetManaCost() + Firefly:GetManaCost() then
            bot:Action_ClearActions(false)
            bot:ActionQueue_UseAbility(Firefly)
            bot:ActionQueue_UseAbilityOnEntity(FlamingLasso, target)
        else bot:Action_UseAbilityOnEntity(FlamingLasso, target) end
        return
    end
    desire, target = X.ConsiderBlinkLasso()
    if desire > 0 then
        bot:Action_ClearActions(false)
        local mana = bot:GetMana() - FlamingLasso:GetManaCost() - Blink:GetManaCost()
        if X.CanBKB() and not bot:IsMagicImmune() and mana >= BlackKingBar:GetManaCost() then
            bot:ActionQueue_UseAbility(BlackKingBar)
            mana = mana - BlackKingBar:GetManaCost()
        end
        if Firefly:IsFullyCastable() and not bot:HasModifier('modifier_batrider_firefly') and mana >= Firefly:GetManaCost() then
            bot:ActionQueue_UseAbility(Firefly)
        end
        bot:ActionQueue_UseAbilityOnLocation(Blink, BlinkLocation)
        bot:ActionQueue_Delay(0.1)
        bot:ActionQueue_UseAbilityOnEntity(FlamingLasso, target)
        return
    end
    if X.ConsiderFirefly() > 0 then bot:Action_UseAbility(Firefly); return end
    desire, target = X.ConsiderFlamebreak()
    if desire > 0 then bot:Action_UseAbilityOnLocation(Flamebreak, target); return end
    desire, target = X.ConsiderStickyNapalm()
    if desire > 0 then bot:Action_UseAbilityOnLocation(StickyNapalm, target) end
end

local function CastRange(ability)
    local range = ability:GetCastRange()
    local lens = J.IsItemAvailable('item_aether_lens')
    if lens ~= nil then range = range + lens:GetSpecialValueInt('cast_range_bonus') end
    local supremacy = bot:GetAbilityByName('rubick_arcane_supremacy')
    if supremacy ~= nil and supremacy:IsTrained() and not J.HasBreakModifier(bot) then
        range = range + supremacy:GetSpecialValueInt('cast_range')
    end
    return range
end

local function ClampLocation(location, range)
    local delta = location - bot:GetLocation()
    if delta:Length2D() > range then return bot:GetLocation() + delta:Normalized() * range end
    return location
end

local function CanAffect(enemy)
    return J.IsValidHero(enemy) and J.CanCastOnNonMagicImmune(enemy)
        and not J.IsSuspiciousIllusion(enemy)
        and not enemy:HasModifier('modifier_abaddon_borrowed_time')
end

local function KeepControl(enemy)
    return enemy:HasModifier('modifier_batrider_flaming_lasso')
        or enemy:HasModifier('modifier_enigma_black_hole_pull')
        or enemy:HasModifier('modifier_faceless_void_chronosphere_freeze')
        or enemy:HasModifier('modifier_legion_commander_duel')
        or enemy:HasModifier('modifier_necrolyte_reapers_scythe')
end

local function CanLasso(enemy)
    return J.IsValidHero(enemy) and J.CanCastOnMagicImmune(enemy)
        and J.CanCastOnTargetAdvanced(enemy) and not J.IsSuspiciousIllusion(enemy)
        and not enemy:HasModifier('modifier_antimage_counterspell')
        and not enemy:HasModifier('modifier_antimage_counterspell_ally')
        and not enemy:HasModifier('modifier_abaddon_borrowed_time')
        and not KeepControl(enemy) and not J.IsTaunted(enemy)
end

local function HaveBackup(enemy, radius)
    return #J.GetNearbyHeroes(bot, radius, false, BOT_MODE_NONE)
        >= #J.GetNearbyHeroes(enemy, radius, false, BOT_MODE_NONE)
end

function X.ConsiderStickyNapalm()
    if not StickyNapalm:IsFullyCastable() then return BOT_ACTION_DESIRE_NONE, nil end
    local range, radius = CastRange(StickyNapalm), StickyNapalm:GetSpecialValueInt('radius')
    local target = J.GetProperTarget(bot)
    if (J.IsGoingOnSomeone(bot) or J.IsLaning(bot)) and CanAffect(target)
        and J.IsInRange(bot, target, range + radius)
        and (not J.IsLaning(bot) or J.GetMP(bot) > 0.3)
    then
        return BOT_ACTION_DESIRE_HIGH, ClampLocation(target:GetLocation(), range)
    end
    if (J.IsLaning(bot) and J.GetMP(bot) > 0.3) or J.IsDefending(bot) then
        for _, enemy in ipairs(J.GetNearbyHeroes(bot, math.min(range + radius, 1600), true, BOT_MODE_NONE)) do
            if CanAffect(enemy) then return BOT_ACTION_DESIRE_HIGH, ClampLocation(enemy:GetLocation(), range) end
        end
    end
    if J.IsRetreating(bot) and bot:WasRecentlyDamagedByAnyHero(3) then
        for _, enemy in ipairs(J.GetNearbyHeroes(bot, math.min(range + radius, 1600), true, BOT_MODE_NONE)) do
            if CanAffect(enemy) and J.IsRunning(enemy) and enemy:IsFacingLocation(bot:GetLocation(), 30) then
                return BOT_ACTION_DESIRE_HIGH, ClampLocation(enemy:GetLocation(), range)
            end
        end
    end
    if (J.IsPushing(bot) or J.IsDefending(bot) or J.IsFarming(bot) or (J.IsLaning(bot) and J.GetMP(bot) > 0.5))
        and J.GetMP(bot) > 0.35 then
        local creeps = bot:GetNearbyLaneCreeps(math.min(range + radius, 1600), true)
        local neutrals = bot:GetNearbyNeutralCreeps(math.min(range + radius, 1600))
        local units = #creeps >= 3 and creeps or neutrals
        if #units >= 2 then
            for _, unit in ipairs(units) do
                local location, count = ClampLocation(unit:GetLocation(), range), 0
                for _, other in ipairs(units) do
                    if J.IsValid(other) and GetUnitToLocationDistance(other, location) <= radius then count = count + 1 end
                end
                if count >= (#creeps >= 3 and 3 or 2) then return BOT_ACTION_DESIRE_HIGH, location end
            end
        end
    end
    if J.IsPushing(bot) and StickyNapalm:GetSpecialValueInt('building_damage_pct') > 0
        and J.IsValid(target) and target:IsBuilding() and J.IsInRange(bot, target, range + radius)
        and not target:HasModifier('modifier_fountain_glyph')
    then
        return BOT_ACTION_DESIRE_HIGH, ClampLocation(target:GetLocation(), range)
    end
    if (J.IsDoingRoshan(bot) or J.IsDoingTormentor(bot)) and J.IsValid(target)
        and J.CanCastOnNonMagicImmune(target) and J.IsInRange(bot, target, range + radius) and J.IsAttacking(bot)
    then
        return BOT_ACTION_DESIRE_HIGH, ClampLocation(target:GetLocation(), range)
    end
    return BOT_ACTION_DESIRE_NONE, nil
end

local function FlameLocation(enemy, pullCloser)
    local delay = Flamebreak:GetCastPoint() + GetUnitToUnitDistance(bot, enemy) / Flamebreak:GetSpecialValueInt('speed')
    local predicted = J.IsDisabled(enemy) and enemy:GetLocation() or enemy:GetExtrapolatedLocation(delay)
    local direction = predicted - bot:GetLocation()
    local offset = math.min(100, Flamebreak:GetSpecialValueInt('explosion_radius') / 2)
    -- Explosions behind a chased target push toward us; between a pursuer and us push away.
    local location = predicted + direction:Normalized() * (pullCloser and offset or -offset)
    location = ClampLocation(location, CastRange(Flamebreak))
    if (predicted - location):Length2D() <= Flamebreak:GetSpecialValueInt('explosion_radius') then return location end
    return nil
end

function X.ConsiderFlamebreak()
    if not Flamebreak:IsFullyCastable() then return BOT_ACTION_DESIRE_NONE, nil end
    local range, radius = CastRange(Flamebreak), Flamebreak:GetSpecialValueInt('explosion_radius')
    local target = J.GetProperTarget(bot)
    for _, enemy in ipairs(J.GetNearbyHeroes(bot, math.min(range + radius, 1600), true, BOT_MODE_NONE)) do
        if CanAffect(enemy) and not KeepControl(enemy)
            and not enemy:HasModifier('modifier_dazzle_shallow_grave')
            and not enemy:HasModifier('modifier_oracle_false_promise_timer')
            and not enemy:HasModifier('modifier_templar_assassin_refraction_absorb')
            and J.CanKillTarget(enemy, Flamebreak:GetSpecialValueInt('damage_impact'), DAMAGE_TYPE_MAGICAL)
        then
            local location = FlameLocation(enemy, true)
            if location then return BOT_ACTION_DESIRE_HIGH, location end
        end
    end
    if J.IsGoingOnSomeone(bot) and CanAffect(target) and not KeepControl(target)
        and J.IsInRange(bot, target, range + radius) and HaveBackup(target, 800)
    then
        local location = FlameLocation(target, true)
        if location then return BOT_ACTION_DESIRE_HIGH, location end
    end
    if J.IsRetreating(bot) and bot:WasRecentlyDamagedByAnyHero(3) then
        for _, enemy in ipairs(J.GetNearbyHeroes(bot, 700, true, BOT_MODE_NONE)) do
            if CanAffect(enemy) and not KeepControl(enemy) and enemy:IsFacingLocation(bot:GetLocation(), 30) then
                local location = FlameLocation(enemy, false)
                if location then return BOT_ACTION_DESIRE_HIGH, location end
            end
        end
    end
    if J.IsDefending(bot) then
        for _, enemy in ipairs(J.GetNearbyHeroes(bot, math.min(range + radius, 1600), true, BOT_MODE_NONE)) do
            if CanAffect(enemy) and not KeepControl(enemy) then
                local location = FlameLocation(enemy, false)
                if location then return BOT_ACTION_DESIRE_HIGH, location end
            end
        end
    end
    if J.IsLaning(bot) and J.GetMP(bot) > 0.39 then
        local creeps = bot:GetNearbyLaneCreeps(math.min(range + radius, 1600), true)
        for _, creep in ipairs(creeps) do
            if J.IsValid(creep) then
                local location, kills = ClampLocation(creep:GetLocation(), range), 0
                for _, other in ipairs(creeps) do
                    if J.IsValid(other) and GetUnitToLocationDistance(other, location) <= radius
                        and not other:HasModifier('modifier_fountain_glyph')
                        and J.CanKillTarget(other, Flamebreak:GetSpecialValueInt('damage_impact'), DAMAGE_TYPE_MAGICAL)
                    then kills = kills + 1 end
                end
                if kills >= 2 then return BOT_ACTION_DESIRE_HIGH, location end
            end
        end
    end
    for _, ally in ipairs(J.GetNearbyHeroes(bot, math.min(range, 1600), false, BOT_MODE_NONE)) do
        if not J.IsSuspiciousIllusion(ally) and J.IsRetreating(ally) and ally:WasRecentlyDamagedByAnyHero(3) then
            for _, enemy in ipairs(J.GetNearbyHeroes(ally, 400, true, BOT_MODE_NONE)) do
                if CanAffect(enemy) and not KeepControl(enemy) and J.IsInRange(bot, enemy, range + radius) then
                    local delay = Flamebreak:GetCastPoint() + GetUnitToUnitDistance(bot, enemy) / Flamebreak:GetSpecialValueInt('speed')
                    local predicted = enemy:GetExtrapolatedLocation(delay)
                    local direction = predicted - ally:GetLocation()
                    local location = ClampLocation(predicted - direction:Normalized() * 100, range)
                    if (predicted - location):Length2D() <= radius then return BOT_ACTION_DESIRE_HIGH, location end
                end
            end
        end
    end
    return BOT_ACTION_DESIRE_NONE, nil
end

function X.ConsiderFirefly()
    if Firefly == nil or Firefly:IsHidden() or not Firefly:IsFullyCastable()
        or bot:HasModifier('modifier_batrider_firefly') then return BOT_ACTION_DESIRE_NONE end
    if J.IsStuck(bot) or bot:HasModifier('modifier_batrider_flaming_lasso_self') then return BOT_ACTION_DESIRE_HIGH end
    local target = J.GetProperTarget(bot)
    if J.IsGoingOnSomeone(bot) and CanAffect(target) and J.IsInRange(bot, target, 800) and HaveBackup(target, 800) then
        return BOT_ACTION_DESIRE_HIGH
    end
    if J.IsRetreating(bot) and bot:WasRecentlyDamagedByAnyHero(3)
        and #J.GetNearbyHeroes(bot, 700, true, BOT_MODE_NONE) > 0 then return BOT_ACTION_DESIRE_HIGH end
    if (J.IsFarming(bot) or J.IsPushing(bot) or J.IsDefending(bot)) and Firefly:GetLevel() >= 2
        and J.GetMP(bot) > 0.4 and #J.GetNearbyHeroes(bot, 1000, true, BOT_MODE_NONE) == 0
        and (#bot:GetNearbyLaneCreeps(600, true) >= 3 or #bot:GetNearbyNeutralCreeps(600) >= 3)
    then return BOT_ACTION_DESIRE_HIGH end
    return BOT_ACTION_DESIRE_NONE
end

function X.ConsiderFlamingLasso()
    if not FlamingLasso:IsFullyCastable() or bot:HasModifier('modifier_batrider_flaming_lasso_self') then
        return BOT_ACTION_DESIRE_NONE, nil
    end
    local range = CastRange(FlamingLasso)
    local enemies = J.GetNearbyHeroes(bot, range, true, BOT_MODE_NONE)
    for _, enemy in ipairs(enemies) do
        if CanLasso(enemy) and J.IsInRange(bot, enemy, range) and enemy:IsChanneling() then
            return BOT_ACTION_DESIRE_HIGH, enemy
        end
    end
    local target = J.GetProperTarget(bot)
    if J.IsGoingOnSomeone(bot) and CanLasso(target) and J.IsInRange(bot, target, range) and HaveBackup(target, 800) then
        return BOT_ACTION_DESIRE_HIGH, target
    end
    if J.IsGoingOnSomeone(bot) or (J.IsRetreating(bot) and bot:WasRecentlyDamagedByAnyHero(3)) then
        for _, enemy in ipairs(enemies) do
            if CanLasso(enemy) and J.IsInRange(bot, enemy, range)
                and (J.IsRetreating(bot) or HaveBackup(enemy, 800)) then return BOT_ACTION_DESIRE_HIGH, enemy end
        end
    end
    return BOT_ACTION_DESIRE_NONE, nil
end

function X.HasBlink()
    Blink = nil
    for slot = 0, 5 do
        local item = bot:GetItemInSlot(slot)
        if item ~= nil and (item:GetName() == 'item_blink' or item:GetName() == 'item_overwhelming_blink'
            or item:GetName() == 'item_arcane_blink' or item:GetName() == 'item_swift_blink')
            and item:IsFullyCastable() then Blink = item; return true end
    end
    return false
end

function X.CanBKB()
    BlackKingBar = nil
    for slot = 0, 5 do
        local item = bot:GetItemInSlot(slot)
        if item ~= nil and item:GetName() == 'item_black_king_bar' and item:IsFullyCastable() then
            BlackKingBar = item; return true
        end
    end
    return false
end

function X.ConsiderBlinkLasso()
    bot.shouldBlink = false
    if not FlamingLasso:IsFullyCastable() or not X.HasBlink() or bot:IsRooted()
        or bot:HasModifier('modifier_bloodseeker_rupture') or bot:HasModifier('modifier_batrider_flaming_lasso_self')
        or not J.IsGoingOnSomeone(bot) then return BOT_ACTION_DESIRE_NONE, nil end
    -- A direct disable must not wait for Blink or spend mobility unnecessarily.
    if X.ConsiderFlamingLasso() > 0 then return BOT_ACTION_DESIRE_NONE, nil end
    local range = Blink:GetSpecialValueInt('blink_range') - 1
    local target = J.GetProperTarget(bot)
    if not CanLasso(target) or not J.IsInRange(bot, target, range) then
        target = J.GetStrongestUnit(range, bot, true, true, FlamingLasso:GetSpecialValueFloat('duration'))
    end
    if CanLasso(target) and J.IsInRange(bot, target, range) and HaveBackup(target, 1200) then
        local location = target:GetExtrapolatedLocation(FlamingLasso:GetCastPoint() + 0.1)
        location = ClampLocation(location, range)
        if (location - target:GetExtrapolatedLocation(FlamingLasso:GetCastPoint() + 0.1)):Length2D() <= CastRange(FlamingLasso)
            and IsLocationPassable(location) and not J.IsLocationInChrono(location)
            and not J.IsLocationInBlackHole(location) and not J.IsLocationInArena(location, 600)
            and bot:GetMana() >= FlamingLasso:GetManaCost() + Blink:GetManaCost()
        then
            BlinkLocation = location
            bot.shouldBlink = true
            return BOT_ACTION_DESIRE_HIGH, target
        end
    end
    return BOT_ACTION_DESIRE_NONE, nil
end

return X
