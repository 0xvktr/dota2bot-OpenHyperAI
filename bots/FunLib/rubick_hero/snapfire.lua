local X = {}
local J = require(GetScriptDirectory()..'/FunLib/jmz_func')
local bot = GetBot()

function X.Range(ability)
    local range = ability:GetCastRange()
    local lens = J.IsItemAvailable('item_aether_lens')
    if lens ~= nil then range = range + lens:GetSpecialValueInt('cast_range_bonus') end
    local talent = bot:GetAbilityByName('special_bonus_cast_range_125')
    if talent ~= nil and not talent:IsNull() and talent:IsTrained() then range = range + talent:GetSpecialValueInt('value') end
    local supremacy = bot:GetAbilityByName('rubick_arcane_supremacy')
    if supremacy ~= nil and not supremacy:IsNull() and supremacy:IsTrained() and not J.HasBreakModifier(bot) then
        range = range + supremacy:GetSpecialValueInt('cast_range')
    end
    return range
end

local function Enemy(unit)
    return J.IsValidHero(unit) and J.CanCastOnNonMagicImmune(unit) and not J.IsSuspiciousIllusion(unit)
        and not J.CannotBeKilled(bot, unit) and not unit:HasModifier('modifier_item_blade_mail_reflect')
        and not unit:HasModifier('modifier_nyx_assassin_spiked_carapace')
end

local function SafePoint(point)
    return IsLocationPassable(point) and not J.IsLocationInChrono(point) and not J.IsLocationInBlackHole(point)
        and not J.IsLocHaveTower(700, true, point)
end

local function Landing(unit, ability)
    local angle = math.rad(unit:GetFacing())
    return unit:GetLocation() + Vector(math.cos(angle), math.sin(angle), 0) * ability:GetSpecialValueInt('jump_horizontal_distance')
end

function X.ConsiderFiresnapCookie()
    local ability = bot:GetAbilityByName('snapfire_firesnap_cookie')
    if not J.CanCastAbility(ability) then return 0 end
    local range, radius = X.Range(ability), ability:GetSpecialValueInt('impact_radius')
    local candidates = {bot}
    for _, ally in pairs(J.GetNearbyHeroes(bot, math.min(1600, range), false, BOT_MODE_NONE)) do candidates[#candidates+1] = ally end
    for _, creep in pairs(bot:GetNearbyLaneCreeps(math.min(1600, range), false)) do candidates[#candidates+1] = creep end
    for _, ally in ipairs(candidates) do
        if J.IsValid(ally) and ally:GetTeam() == bot:GetTeam() and not ally:IsIllusion() and not ally:IsInvulnerable()
            and not ally:IsChanneling() and not ally:IsRooted() and not ally:HasModifier('modifier_bloodseeker_rupture')
            and not ally:HasModifier('modifier_puck_coiled') and GetUnitToUnitDistance(bot, ally) <= range then
            local landing = Landing(ally, ability)
            if SafePoint(landing) then
                local isHero = J.IsValidHero(ally)
                if isHero and (J.IsStuck(ally) or ally:WasRecentlyDamagedByAnyHero(1.5) and J.GetHP(ally) < 0.65)
                    and GetUnitToLocationDistance(ally, J.GetEscapeLoc()) > (landing-J.GetEscapeLoc()):Length2D() + 150
                    and not ally:HasModifier('modifier_ice_blast') then return BOT_ACTION_DESIRE_HIGH, ally end
                if isHero and J.HasAghanimsShard(bot) and ability:GetSpecialValueInt('target_heal') > 0
                    and ally:GetMaxHealth()-ally:GetHealth() >= ability:GetSpecialValueInt('target_heal')
                    and J.GetHP(ally) < 0.5 and not ally:HasModifier('modifier_ice_blast')
                    and #J.GetEnemiesNearLoc(landing, 600) == 0 then return BOT_ACTION_DESIRE_HIGH, ally end
                local delay = ability:GetCastPoint() + ability:GetSpecialValueFloat('jump_duration')
                    + (ally == bot and ability:GetSpecialValueFloat('self_cast_delay') or GetUnitToUnitDistance(bot, ally)/ability:GetSpecialValueInt('projectile_speed'))
                for _, enemy in pairs(J.GetNearbyHeroes(bot, 1600, true, BOT_MODE_NONE)) do
                    if Enemy(enemy) and (enemy:IsChanneling() or J.IsGoingOnSomeone(bot) and enemy == J.GetProperTarget(bot))
                        and not J.IsDisabled(enemy) and (J.GetCorrectLoc(enemy, delay)-landing):Length2D() <= radius
                        and #J.GetEnemiesNearLoc(landing, 900) <= #J.GetNearbyHeroes(bot, 900, false, BOT_MODE_NONE)+1 then
                        return BOT_ACTION_DESIRE_HIGH, ally
                    end
                end
            end
        end
    end
    return 0
end

function X.ConsiderScatterBlast()
    local ability = bot:GetAbilityByName('snapfire_scatterblast')
    if not J.CanCastAbility(ability) then return 0 end
    -- The projectile has its own length; cast-range items do not prove a longer cone.
    local reach = ability:GetCastRange()
    local function Shot(unit)
        local delay = ability:GetCastPoint()+GetUnitToUnitDistance(bot, unit)/ability:GetSpecialValueInt('blast_speed')
        local point = J.GetCorrectLoc(unit, delay)
        if GetUnitToLocationDistance(bot, point) > reach then return nil end
        local distance = GetUnitToLocationDistance(bot, point)
        local bonus = ability:GetSpecialValueInt('bonus_applies_at_long_range') == 1
            and distance > ability:GetSpecialValueInt('point_blank_range')
            or ability:GetSpecialValueInt('bonus_applies_at_long_range') == 0 and distance <= ability:GetSpecialValueInt('point_blank_range')
        local damage = ability:GetSpecialValueInt('damage') * (bonus and 1+ability:GetSpecialValueInt('point_blank_dmg_bonus_pct')/100 or 1)
        return point, damage, delay
    end
    for _, enemy in pairs(J.GetNearbyHeroes(bot, math.min(1600, reach), true, BOT_MODE_NONE)) do
        if Enemy(enemy) then
            local point, damage, delay = Shot(enemy)
            if point ~= nil and (J.WillKillTarget(enemy, damage, DAMAGE_TYPE_MAGICAL, delay)
                or J.IsGoingOnSomeone(bot) and enemy == J.GetProperTarget(bot)
                or J.IsRetreating(bot) and J.IsChasingTarget(enemy, bot)
                or J.IsInTeamFight(bot, 1200) and #J.GetEnemiesNearLoc(point, ability:GetSpecialValueInt('blast_width_end')) >= 2) then
                return BOT_ACTION_DESIRE_HIGH, point
            end
        end
    end
    local creeps = bot:GetNearbyLaneCreeps(math.min(1600, reach), true)
    if J.IsLaning(bot) then
        for _, creep in pairs(creeps) do
            if J.IsValid(creep) and string.find(creep:GetUnitName(), 'ranged', 1, true) then
                local point, damage, delay = Shot(creep)
                if point ~= nil and J.WillKillTarget(creep, damage, DAMAGE_TYPE_MAGICAL, delay) then return BOT_ACTION_DESIRE_HIGH, point end
            end
        end
    end
    if (J.IsFarming(bot) or J.IsPushing(bot) or J.IsDefending(bot)) and J.IsAttacking(bot) and J.GetMP(bot) > 0.35 then
        if #creeps < 3 then creeps = bot:GetNearbyNeutralCreeps(math.min(1600, reach)) end
        if #creeps >= 3 then
            local point = J.GetCenterOfUnits(creeps)
            if GetUnitToLocationDistance(bot, point) <= reach then return BOT_ACTION_DESIRE_HIGH, point end
        end
    end
    local target = J.GetProperTarget(bot)
    if J.IsValid(target) and (J.IsRoshan(target) or J.IsTormentor(target)) and J.IsAttacking(bot) then
        local point = Shot(target)
        if point ~= nil then return BOT_ACTION_DESIRE_HIGH, point end
    end
    return 0
end

function X.ConsiderLilShredder()
    local ability = bot:GetAbilityByName('snapfire_lil_shredder')
    if not J.CanCastAbility(ability) or bot:IsDisarmed() or bot:HasModifier('modifier_snapfire_lil_shredder_buff') then return 0 end
    local target = bot:GetAttackTarget()
    if target ~= nil and J.CanBeAttacked(target) and not target:HasModifier('modifier_fountain_glyph')
        and GetUnitToUnitDistance(bot, target) <= bot:GetAttackRange()+ability:GetSpecialValueInt('attack_range_bonus') then
        if target:IsBuilding() or not target:IsHero() or J.IsGoingOnSomeone(bot) then return BOT_ACTION_DESIRE_HIGH end
    end
    return 0
end

function X.ConsiderMortimerKisses()
    local ability = bot:GetAbilityByName('snapfire_mortimer_kisses')
    if not J.CanCastAbility(ability) or not (J.IsGoingOnSomeone(bot) or J.IsInTeamFight(bot, 1600)) then return 0 end
    -- A nearby attacker can immediately punish the stationary barrage.
    for _, enemy in pairs(J.GetNearbyHeroes(bot, 600, true, BOT_MODE_NONE)) do
        if J.IsValidHero(enemy) and not J.IsSuspiciousIllusion(enemy) and not J.IsDisabled(enemy) then return 0 end
    end
    local range = X.Range(ability)
    for _, enemy in pairs(GetUnitList(UNIT_LIST_ENEMY_HEROES)) do
        if Enemy(enemy) then
            local distance = GetUnitToUnitDistance(bot, enemy)
            local travel = math.max(ability:GetSpecialValueFloat('min_lob_travel_time'), math.min(ability:GetSpecialValueFloat('max_lob_travel_time'), distance/ability:GetSpecialValueInt('projectile_speed')))
            local point = J.GetCorrectLoc(enemy, ability:GetCastPoint()+travel)
            local predicted = GetUnitToLocationDistance(bot, point)
            if predicted >= ability:GetSpecialValueInt('min_range') and predicted <= range
                and (J.IsDisabled(enemy) or J.IsLocationInChrono(enemy:GetLocation()) or J.IsLocationInBlackHole(enemy:GetLocation())
                    or #J.GetEnemiesNearLoc(point, ability:GetSpecialValueInt('impact_radius')) >= 2
                    or J.WillKillTarget(enemy, ability:GetSpecialValueInt('damage_per_impact'), DAMAGE_TYPE_MAGICAL, ability:GetCastPoint()+travel)) then
                return BOT_ACTION_DESIRE_HIGH, point
            end
        end
    end
    return 0
end

function X.ConsiderGobbleUp()
    local ability = bot:GetAbilityByName('snapfire_gobble_up')
    local spit = bot:GetAbilityByName('snapfire_spit_creep')
    if not bot:HasScepter() or not J.CanCastAbility(ability) or spit == nil or spit:IsNull() or not spit:IsTrained()
        or bot:HasModifier('modifier_snapfire_gobble_up_belly_has_unit') then return 0 end
    local range = X.Range(ability)
    for _, ally in pairs(J.GetNearbyHeroes(bot, math.min(1600, range), false, BOT_MODE_NONE)) do
        if J.IsValidHero(ally) and not ally:IsIllusion() and not ally:IsInvulnerable() and not ally:IsChanneling()
            and GetUnitToUnitDistance(bot, ally) <= range and J.GetHP(ally) < 0.4 and ally:WasRecentlyDamagedByAnyHero(1.5) then
            return BOT_ACTION_DESIRE_HIGH, ally, 'hero'
        end
    end
    local target = J.GetProperTarget(bot)
    if Enemy(target) and J.IsGoingOnSomeone(bot) and GetUnitToUnitDistance(bot, target) > 600
        and GetUnitToUnitDistance(bot, target) <= X.Range(spit) then
        for _, creep in pairs(bot:GetNearbyCreeps(math.min(1600, range), true)) do
            if J.IsValid(creep) and not creep:IsAncientCreep() and not creep:IsHero() and not creep:IsInvulnerable()
                and GetUnitToUnitDistance(bot, creep) <= range then return BOT_ACTION_DESIRE_HIGH, creep, 'creep' end
        end
    end
    return 0
end

function X.ConsiderSpitOut()
    local ability = bot:GetAbilityByName('snapfire_spit_creep')
    if not J.CanCastAbility(ability) or not bot:HasModifier('modifier_snapfire_gobble_up_belly_has_unit') then return 0 end
    local range = X.Range(ability)
    if bot.snapfireSwallowedKind == 'creep' then
        local target = J.GetProperTarget(bot)
        if Enemy(target) then
            local delay = ability:GetCastPoint()+math.max(ability:GetSpecialValueFloat('min_lob_travel_time'), math.min(ability:GetSpecialValueFloat('max_lob_travel_time'), GetUnitToUnitDistance(bot, target)/ability:GetSpecialValueInt('projectile_speed')))
            local point = J.GetCorrectLoc(target, delay)
            if GetUnitToLocationDistance(bot, point) <= range then return BOT_ACTION_DESIRE_HIGH, point end
        end
    end
    local escape = J.GetEscapeLoc()
    local point = bot:GetLocation()+(escape-bot:GetLocation()):Normalized()*math.min(1000, range, GetUnitToLocationDistance(bot, escape))
    if SafePoint(point) then return BOT_ACTION_DESIRE_HIGH, point end
    if SafePoint(bot:GetLocation()) then return BOT_ACTION_DESIRE_HIGH, bot:GetLocation() end
    return 0
end

local decisions = {
    snapfire_scatterblast=X.ConsiderScatterBlast, snapfire_firesnap_cookie=X.ConsiderFiresnapCookie,
    snapfire_lil_shredder=X.ConsiderLilShredder, snapfire_mortimer_kisses=X.ConsiderMortimerKisses,
    snapfire_gobble_up=X.ConsiderGobbleUp, snapfire_spit_creep=X.ConsiderSpitOut,
}
local function Cast(ability, target, kind)
    local name = ability:GetName()
    J.SetQueuePtToINT(bot, true, ability)
    if name == 'snapfire_lil_shredder' then bot:ActionQueue_UseAbility(ability)
    elseif name == 'snapfire_firesnap_cookie' or name == 'snapfire_gobble_up' then
        bot:ActionQueue_UseAbilityOnEntity(ability, target)
        if name == 'snapfire_gobble_up' then bot.snapfireSwallowedKind, bot.snapfireSwallowedTarget = kind, target end
    else bot:ActionQueue_UseAbilityOnLocation(ability, target) end
end

function X.ConsiderStolenSpell(ability)
    local name = ability:GetName()
    if decisions[name] == nil then return nil end
    bot = GetBot()
    if J.CanNotUseAbility(bot) or bot:HasModifier('modifier_snapfire_mortimer_kisses') or not J.CanCastAbility(ability) then return false end
    local desire, target, kind = decisions[name]()
    if desire <= 0 then return false end
    Cast(ability, target, kind)
    return true
end

function X.UseNative()
    bot = GetBot()
    if J.CanNotUseAbility(bot) or bot:HasModifier('modifier_snapfire_mortimer_kisses') then return false end
    local order = {'snapfire_spit_creep', 'snapfire_gobble_up', 'snapfire_firesnap_cookie', 'snapfire_lil_shredder', 'snapfire_scatterblast', 'snapfire_mortimer_kisses'}
    for _, name in ipairs(order) do
        local ability = bot:GetAbilityByName(name)
        if J.CanCastAbility(ability) then
            local desire, target, kind = decisions[name]()
            if desire > 0 then Cast(ability, target, kind); return true end
        end
    end
    return false
end
return X
