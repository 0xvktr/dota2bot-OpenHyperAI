local X = {}
local bot = GetBot()
local J = require(GetScriptDirectory()..'/FunLib/jmz_func')

local function Range(ability)
    local range = ability:GetCastRange()
    local lens = J.IsItemAvailable('item_aether_lens')
    if lens ~= nil then range = range + lens:GetSpecialValueInt('cast_range_bonus') end
    local supremacy = bot:GetAbilityByName('rubick_arcane_supremacy')
    if supremacy ~= nil and supremacy:IsTrained() and not J.HasBreakModifier(bot) then
        range = range + supremacy:GetSpecialValueInt('cast_range')
    end
    return range
end

function X.UsePulseNovaOff()
    local nova = bot:GetAbilityByName('leshrac_pulse_nova')
    if nova == nil or not nova:IsTrained() or nova:IsHidden() or not nova:IsActivated()
        or not nova:GetToggleState() or J.CanNotUseAbility(bot)
        or bot:IsChanneling() or bot:IsCastingAbility() or bot:IsUsingAbility() then return false end
    local useful = false
    for _, enemy in pairs(J.GetNearbyHeroes(bot,nova:GetSpecialValueInt('radius'),true,BOT_MODE_NONE)) do
        if J.IsValidHero(enemy) and J.CanCastOnNonMagicImmune(enemy)
            and not J.CannotBeKilled(bot,enemy) then useful=true;break end
    end
    if not useful or J.GetMP(bot)<0.2 then bot:Action_UseAbility(nova);return true end
    return false
end

function X.ConsiderStolenSpell(ability)
    local name = ability:GetName()
    if name ~= 'leshrac_split_earth' and name ~= 'leshrac_lightning_storm'
        and name ~= 'leshrac_diabolic_edict' and name ~= 'leshrac_pulse_nova'
        and name ~= 'leshrac_greater_lightning_storm' then return nil end
    if J.CanNotUseAbility(bot) then return false end
    local pulse = name == 'leshrac_pulse_nova'
    if pulse and ability:GetToggleState() then
        local useful = false
        for _, enemy in pairs(J.GetNearbyHeroes(bot, ability:GetSpecialValueInt('radius'), true, BOT_MODE_NONE)) do
            if J.IsValidHero(enemy) and J.CanCastOnNonMagicImmune(enemy)
                and not J.CannotBeKilled(bot, enemy) then useful = true; break end
        end
        if not useful or J.GetMP(bot) < 0.2 then bot:Action_UseAbility(ability); return true end
        return false
    end
    if not J.CanCastAbility(ability) then return false end
    local range = (name == 'leshrac_split_earth' or name == 'leshrac_lightning_storm')
        and Range(ability) or ability:GetSpecialValueInt('radius')
    local target = J.GetProperTarget(bot)
    for _, enemy in pairs(J.GetNearbyHeroes(bot, math.min(1600, range), true, BOT_MODE_NONE)) do
        local piercing = name == 'leshrac_diabolic_edict'
        if J.IsValidHero(enemy) and not J.IsSuspiciousIllusion(enemy)
            and (piercing and J.CanCastOnMagicImmune(enemy) or not piercing and J.CanCastOnNonMagicImmune(enemy)) then
            local interrupt = name == 'leshrac_split_earth' and enemy:IsChanneling()
            local wanted = interrupt or J.IsGoingOnSomeone(bot) and enemy == target
                or J.IsRetreating(bot) and J.IsChasingTarget(enemy, bot)
                or J.IsInTeamFight(bot, 1200)
            if wanted and not J.CannotBeKilled(bot, enemy) then
                if name == 'leshrac_lightning_storm' then
                    if J.CanCastOnTargetAdvanced(enemy) then
                        J.SetQueuePtToINT(bot, true, ability)
                        bot:ActionQueue_UseAbilityOnEntity(ability, enemy); return true
                    end
                elseif name == 'leshrac_split_earth' then
                    local point = J.GetCorrectLoc(enemy, ability:GetCastPoint() + ability:GetSpecialValueFloat('delay'))
                    if GetUnitToLocationDistance(bot, point) <= range then
                        J.SetQueuePtToINT(bot, true, ability)
                        bot:ActionQueue_UseAbilityOnLocation(ability, point); return true
                    end
                elseif pulse then
                    if J.GetMP(bot) >= 0.3 and bot:GetMana() >= ability:GetManaCost()
                        + ability:GetSpecialValueInt('mana_cost_per_second') * 2 then
                        bot:Action_UseAbility(ability); return true
                    end
                elseif name == 'leshrac_diabolic_edict' or name == 'leshrac_greater_lightning_storm' then
                    J.SetQueuePtToINT(bot, true, ability)
                    bot:ActionQueue_UseAbility(ability); return true
                end
            end
        end
    end
    if name == 'leshrac_diabolic_edict' and J.IsPushing(bot) then
        for _, tower in pairs(bot:GetNearbyTowers(range, true)) do
            if J.IsValidBuilding(tower) and not tower:IsInvulnerable()
                and #bot:GetNearbyLaneCreeps(range, true) <= 2 then
                J.SetQueuePtToINT(bot, true, ability)
                bot:ActionQueue_UseAbility(ability); return true
            end
        end
    end
    return false
end
return X
