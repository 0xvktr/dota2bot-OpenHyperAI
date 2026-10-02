local X = {}
local J = require(GetScriptDirectory()..'/FunLib/jmz_func')
local bot = GetBot()

function X.Range(ability)
    local range = ability:GetCastRange()
    local lens = J.IsItemAvailable('item_aether_lens')
    if lens ~= nil then range = range+lens:GetSpecialValueInt('cast_range_bonus') end
    local supremacy = bot:GetAbilityByName('rubick_arcane_supremacy')
    if supremacy ~= nil and not supremacy:IsNull() and supremacy:IsTrained() and not J.HasBreakModifier(bot) then
        range = range+supremacy:GetSpecialValueInt('cast_range')
    end
    return range
end
local function Enemy(unit)
    return J.IsValidHero(unit) and J.CanCastOnNonMagicImmune(unit) and not J.IsSuspiciousIllusion(unit)
        and not J.CannotBeKilled(bot, unit) and not unit:HasModifier('modifier_item_blade_mail_reflect')
        and not unit:HasModifier('modifier_nyx_assassin_spiked_carapace')
end
local function Clamp(point, range)
    if GetUnitToLocationDistance(bot, point) > range then return bot:GetLocation()+(point-bot:GetLocation()):Normalized()*range end
    return point
end
function X.ObserveShrapnel()
    local pending = bot.sniperShrapnelPending
    if pending == nil then return end
    local ability = pending.ability
    if ability == nil or ability:IsNull() then bot.sniperShrapnelPending=nil;return end
    if ability:GetCurrentCharges() < pending.charges then
        bot.sniperShrapnelZones = bot.sniperShrapnelZones or {}
        bot.sniperShrapnelZones[#bot.sniperShrapnelZones+1] = {point=pending.point, radius=pending.radius,
            expires=DotaTime()+ability:GetSpecialValueFloat('damage_delay')+ability:GetSpecialValueFloat('duration')}
        bot.sniperShrapnelPending=nil
    elseif DotaTime() > pending.requested+3 then bot.sniperShrapnelPending=nil end
end
function X.IsShrapnelHere(point, radius)
    X.ObserveShrapnel()
    local live = {}
    local covered = false
    for _, zone in ipairs(bot.sniperShrapnelZones or {}) do
        if zone.expires > DotaTime() then
            live[#live+1] = zone
            if (zone.point-point):Length2D() < math.min(zone.radius, radius) then covered = true end
        end
    end
    bot.sniperShrapnelZones = live
    return covered
end
function X.ConsiderShrapnel()
    X.ObserveShrapnel()
    local ability = bot:GetAbilityByName('sniper_shrapnel')
    if not J.CanCastAbility(ability) or ability:GetCurrentCharges() <= 0 or bot.sniperShrapnelPending ~= nil then return 0 end
    local range, radius = X.Range(ability), ability:GetSpecialValueInt('radius')
    local delay = ability:GetCastPoint()+ability:GetSpecialValueFloat('damage_delay')
    for _, enemy in pairs(GetUnitList(UNIT_LIST_ENEMY_HEROES)) do
        if Enemy(enemy) and GetUnitToUnitDistance(bot, enemy) <= range+radius then
            local point = Clamp(J.GetCorrectLoc(enemy, delay), range)
            if (J.GetCorrectLoc(enemy, delay)-point):Length2D() <= radius and not X.IsShrapnelHere(point, radius)
                and (J.IsGoingOnSomeone(bot) and enemy == J.GetProperTarget(bot)
                    or J.IsRetreating(bot) and J.IsChasingTarget(enemy, bot)
                    or J.IsInTeamFight(bot, 1600) and #J.GetEnemiesNearLoc(point, radius) >= 2) then return BOT_ACTION_DESIRE_HIGH, point end
        end
    end
    if (J.IsFarming(bot) or J.IsPushing(bot) or J.IsDefending(bot)) and ability:GetCurrentCharges() >= 2 and J.GetMP(bot) > 0.4 then
        local creeps = bot:GetNearbyLaneCreeps(math.min(1600, range), true)
        if #creeps < 3 and J.IsFarming(bot) then creeps = bot:GetNearbyNeutralCreeps(math.min(1600, range)) end
        if #creeps >= 3 then
            local point = Clamp(J.GetCenterOfUnits(creeps), range)
            local count = 0
            for _, creep in pairs(creeps) do if J.IsValid(creep) and GetUnitToLocationDistance(creep, point) <= radius then count=count+1 end end
            if count >= 3 and not X.IsShrapnelHere(point, radius) then return BOT_ACTION_DESIRE_HIGH, point end
        end
    end
    local target = bot:GetAttackTarget()
    if J.IsValid(target) and J.IsRoshan(target) and GetUnitToUnitDistance(bot, target) <= range and J.GetMP(bot) > 0.4
        and not X.IsShrapnelHere(target:GetLocation(), radius) then return BOT_ACTION_DESIRE_HIGH, target:GetLocation() end
    return 0
end
function X.ConsiderTakeAim()
    local ability = bot:GetAbilityByName('sniper_take_aim')
    if not J.CanCastAbility(ability) or bot:IsDisarmed() or bot:HasModifier('modifier_sniper_take_aim_bonus') then return 0 end
    local target = bot:GetAttackTarget()
    if target == nil then target = J.GetProperTarget(bot) end
    if not J.IsValid(target) or not J.CanBeAttacked(target) or J.CannotBeKilled(bot, target) then return 0 end
    if GetUnitToUnitDistance(bot, target) > bot:GetAttackRange()+ability:GetSpecialValueInt('active_attack_range_bonus') then return 0 end
    if J.IsRetreating(bot) and not J.IsAttacking(bot) then return 0 end
    if J.IsValidHero(target) and (J.IsGoingOnSomeone(bot) or J.IsAttacking(bot))
        and not target:HasModifier('modifier_item_blade_mail_reflect') and not target:HasModifier('modifier_nyx_assassin_spiked_carapace') then return BOT_ACTION_DESIRE_HIGH end
    if J.IsAttacking(bot) and (J.IsFarming(bot) or J.IsDoingRoshan(bot) or J.IsDoingTormentor(bot)) then return BOT_ACTION_DESIRE_HIGH end
    return 0
end
function X.ConsiderAssassinate()
    local ability = bot:GetAbilityByName('sniper_assassinate')
    if not J.CanCastAbility(ability) then return 0 end
    local range = X.Range(ability)
    local aim = bot:HasScepter() and ability:GetSpecialValueFloat('scepter_cast_point') or ability:GetCastPoint()
    -- KV attack_factor is zero while the tooltip describes an attack. Do not invent proc damage.
    local damage = ability:GetSpecialValueInt('damage')
    local best, bestHealth
    for _, enemy in pairs(GetUnitList(UNIT_LIST_ENEMY_HEROES)) do
        if Enemy(enemy) and GetUnitToUnitDistance(bot, enemy) <= range and J.CanCastOnTargetAdvanced(enemy) then
            local arrival = aim+GetUnitToUnitDistance(bot, enemy)/ability:GetSpecialValueInt('projectile_speed')
            local channel = enemy:IsChanneling()
            if channel and enemy:HasModifier('modifier_teleporting') then
                local index = enemy:GetModifierByName('modifier_teleporting')
                channel = index >= 0 and enemy:GetModifierRemainingDuration(index) > arrival
            end
            if channel then return BOT_ACTION_DESIRE_HIGH, enemy end
            if J.WillKillTarget(enemy, damage, DAMAGE_TYPE_MAGICAL, arrival)
                and (bestHealth == nil or enemy:GetHealth() < bestHealth) then best, bestHealth=enemy, enemy:GetHealth() end
            if bot:HasScepter() and J.IsGoingOnSomeone(bot) and enemy == J.GetProperTarget(bot) and not J.IsDisabled(enemy)
                and #J.GetAlliesNearLoc(enemy:GetLocation(), 700) > 0 then return BOT_ACTION_DESIRE_HIGH, enemy end
        end
    end
    if best ~= nil then return BOT_ACTION_DESIRE_HIGH, best end
    return 0
end
function X.ConsiderGrenade()
    local ability = bot:GetAbilityByName('sniper_concussive_grenade')
    if not J.CanCastAbility(ability) or bot:IsRooted() or bot:HasModifier('modifier_bloodseeker_rupture') or bot:HasModifier('modifier_puck_coiled') then return 0 end
    local range, radius = X.Range(ability), ability:GetSpecialValueInt('radius')
    for _, enemy in pairs(J.GetNearbyHeroes(bot, math.min(1600, range+radius), true, BOT_MODE_NONE)) do
        if Enemy(enemy) and (enemy:IsChanneling() or J.IsChasingTarget(enemy, bot)
            or enemy:GetAttackTarget() == bot and not enemy:IsDisarmed()) then
            local point = Clamp(J.GetCorrectLoc(enemy, ability:GetCastPoint()), range)
            if GetUnitToLocationDistance(bot, point) > 0 and GetUnitToLocationDistance(enemy, point) <= radius then
                local landing = bot:GetLocation()-(point-bot:GetLocation()):Normalized()*ability:GetSpecialValueInt('knockback_distance')
                if IsLocationPassable(landing) and not J.IsLocationInChrono(landing) and not J.IsLocationInBlackHole(landing)
                    and not J.IsLocHaveTower(700, true, landing) then return BOT_ACTION_DESIRE_HIGH, point end
            end
        end
    end
    return 0
end
local decisions = {sniper_shrapnel=X.ConsiderShrapnel, sniper_take_aim=X.ConsiderTakeAim, sniper_assassinate=X.ConsiderAssassinate, sniper_concussive_grenade=X.ConsiderGrenade}
local function Cast(ability, target)
    J.SetQueuePtToINT(bot, true, ability)
    local name = ability:GetName()
    if name == 'sniper_take_aim' then bot:ActionQueue_UseAbility(ability)
    elseif name == 'sniper_assassinate' then bot:ActionQueue_UseAbilityOnEntity(ability, target)
    else
        bot:ActionQueue_UseAbilityOnLocation(ability, target)
        if name == 'sniper_shrapnel' then
            bot.sniperShrapnelPending = {point=target, radius=ability:GetSpecialValueInt('radius'),
                ability=ability, charges=ability:GetCurrentCharges(), requested=DotaTime()}
        end
    end
end
function X.ConsiderStolenSpell(ability)
    local name = ability:GetName()
    if decisions[name] == nil then return nil end
    bot = GetBot()
    X.ObserveShrapnel()
    if J.CanNotUseAbility(bot) or bot:IsInvisible() or not J.CanCastAbility(ability) then return false end
    local desire, target = decisions[name]()
    if desire <= 0 then return false end
    Cast(ability, target);return true
end
function X.UseNative()
    bot = GetBot()
    X.ObserveShrapnel()
    if J.CanNotUseAbility(bot) or bot:IsInvisible() then return false end
    for _, name in ipairs({'sniper_concussive_grenade', 'sniper_assassinate', 'sniper_take_aim', 'sniper_shrapnel'}) do
        local ability = bot:GetAbilityByName(name)
        if J.CanCastAbility(ability) then
            local desire, target = decisions[name]()
            if desire > 0 then Cast(ability, target);return true end
        end
    end
    return false
end
return X
