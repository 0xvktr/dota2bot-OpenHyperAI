local J = require(GetScriptDirectory()..'/FunLib/jmz_func')
local S = {}

local function eligible(bot)
    return bot:IsHero() and bot:IsAlive() and not bot:IsIllusion()
        and J.GetPosition(bot) >= 4 and J.IsInLaningPhase()
        and not J.IsRetreating(bot) and not J.IsPushing(bot)
        and not bot:WasRecentlyDamagedByAnyHero(2)
        and not bot:WasRecentlyDamagedByTower(2)
end

function S.ReservedForCore(bot, creep)
    if not creep or creep:IsNull() or not creep:IsAlive() then return nil end
    local name = creep:GetUnitName()
    if creep:GetTeam() == bot:GetTeam()
        or (not string.find(name, 'npc_dota_creep_goodguys', 1, true)
            and not string.find(name, 'npc_dota_creep_badguys', 1, true)) then return nil end
    if not eligible(bot) then return nil end
    for _, core in ipairs(J.GetAlliesNearLoc(creep:GetLocation(), 1000)) do
        if core ~= bot and J.IsValidHero(core) and core:IsAlive() and not core:IsIllusion()
            and J.IsCore(core) and not core:IsDisarmed() and not core:IsStunned()
            and not core:IsChanneling() and not J.IsRetreating(core)
            and GetUnitToUnitDistance(core, creep) <= math.min(1000, core:GetAttackRange() + 250)
            and creep:GetHealth() <= math.max(bot:GetAttackDamage(), core:GetAttackDamage()) * 2.2 + 20 then
            return core
        end
    end
end

function S.Window(bot)
    if not eligible(bot) or J.CanNotUseAction(bot) then return nil end
    local target = bot:GetAttackTarget()
    if target and J.IsValidHero(target) then return nil end
    for _, creep in ipairs(bot:GetNearbyLaneCreeps(1000, true)) do
        if GetUnitToUnitDistance(bot, creep) <= bot:GetAttackRange() + 250 then
            local core = S.ReservedForCore(bot, creep)
            if core then return core end
        end
    end
end

function S.Think(bot)
    local core = S.Window(bot)
    if not core then return false end
    -- Keep denies available; never reset an existing deny attack every frame.
    for _, creep in ipairs(bot:GetNearbyLaneCreeps(1000, false)) do
        if J.IsValid(creep) and J.CanBeAttacked(creep) and J.GetHP(creep) < 0.49
            and GetUnitToUnitDistance(bot, creep) <= bot:GetAttackRange()
            and creep:GetHealth() <= creep:GetActualIncomingDamage(bot:GetAttackDamage(), DAMAGE_TYPE_PHYSICAL) then
            if bot:GetAttackTarget() ~= creep then bot:Action_AttackUnit(creep, true) end
            return true
        end
    end
    -- Briefly replace native last-hit micro, without replacing native laning.
    bot:SetTarget(nil)
    local loc = J.Utils.GetOffsetLocationTowardsTargetLocation(core:GetLocation(), J.GetTeamFountain(), 250)
    if GetUnitToLocationDistance(bot, loc) > 150 then bot:Action_MoveToLocation(loc)
    else bot:Action_MoveToLocation(bot:GetLocation()) end
    return true
end

return S
