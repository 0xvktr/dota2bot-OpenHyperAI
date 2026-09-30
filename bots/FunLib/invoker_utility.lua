local X = {}

-- 7.41f: channel only when safe, or into a disable known to outlast the impact.
-- Keep this hero-specific until other Meteor Hammer builds have been reviewed.
function X.TryMeteorHammer(bot, J)
    if bot:IsChanneling() or bot:IsUsingAbility() or bot:IsMuted()
        or bot:NumQueuedActions() > 0 or bot:IsInvisible()
        or bot:WasRecentlyDamagedByAnyHero(2) or J.GetHP(bot) < 0.6 then return false end
    local item
    for slot = 0, 5 do
        local candidate = bot:GetItemInSlot(slot)
        if candidate and candidate:GetName() == 'item_meteor_hammer' then item = candidate break end
    end
    if not item or not item:IsFullyCastable() then return false end
    local range = item:GetCastRange()
    local delay = item:GetChannelTime() + item:GetCastPoint() + item:GetSpecialValueFloat('land_time')
    local enemies = J.GetNearbyHeroes(bot, 900, true)
    local target = J.GetProperTarget(bot)
    if J.IsGoingOnSomeone(bot) and J.IsValidHero(target)
        and J.CanCastOnNonMagicImmune(target) and not J.IsSuspiciousIllusion(target)
        and J.IsInRange(bot, target, range) and #enemies <= 1 then
        for _, modifier in ipairs({'modifier_bane_fiends_grip', 'modifier_enigma_black_hole_pull',
            'modifier_legion_commander_duel', 'modifier_crystal_maiden_frostbite', 'modifier_shadow_shaman_shackles'}) do
            if target:HasModifier(modifier) and J.GetModifierTime(target, modifier) >= delay + 0.2 then
                bot:Action_UseAbilityOnLocation(item, target:GetLocation())
                return true
            end
        end
    end
    if #enemies > 0 or bot:GetMana() < item:GetManaCost() + 280 then return false end
    if J.IsPushing(bot) then
        for _, tower in ipairs(bot:GetNearbyTowers(range, true)) do
            if not tower:IsInvulnerable() and tower:GetAttackTarget() ~= bot then
                bot:Action_UseAbilityOnLocation(item, tower:GetLocation())
                return true
            end
        end
    end
    if J.IsFarming(bot) or J.IsPushing(bot) or J.IsDefending(bot) then
        local aoe = bot:FindAoELocation(true, false, bot:GetLocation(), range,
            item:GetSpecialValueInt('impact_radius'), delay, 0)
        if aoe.count >= 3 then
            bot:Action_UseAbilityOnLocation(item, aoe.targetloc)
            return true
        end
    end
    return false
end

return X
