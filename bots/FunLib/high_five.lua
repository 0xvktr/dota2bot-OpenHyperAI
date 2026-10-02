-- Cosmetic interaction only. Never walk to a partner or queue an emote behind
-- gameplay actions. Native cosmetic handles still need live Bot API validation.
local H = {}
H.RANGE = 900 -- plus_high_five/high_five acknowledge_range in Valve KV
H.REPLY_INTERVAL = 10
H.CELEBRATE_INTERVAL = 90
H.EVENT_WINDOW = 15
H.ORDER_GRACE = 0.5

local names = {'plus_high_five', 'high_five'}

local function requesting(hero)
    return hero:HasModifier('modifier_plus_high_five_requested')
        or hero:HasModifier('modifier_high_five_requested')
end

local function realHero(hero, J)
    return J.IsValidHero(hero) and not hero:IsIllusion() and not J.IsSuspiciousIllusion(hero)
        and not J.IsMeepoClone(hero) and not hero:HasModifier('modifier_arc_warden_tempest_double')
end

function H.CanAct(bot, J)
    if not realHero(bot, J) or bot.isBear or not bot:IsAlive() or not bot:IsBot()
        or bot:IsInvisible() or J.CanNotUseAction(bot) or bot:NumQueuedActions() > 0
        or bot:IsChanneling() or bot:IsCastingAbility() or bot:IsUsingAbility()
        or bot:IsHexed() or bot:IsMuted() or bot:IsSilenced() or bot:IsStunned()
        or bot:HasModifier('modifier_teleporting') or bot:GetAttackTarget() ~= nil
        or J.IsGoingOnSomeone(bot) or J.IsRetreating(bot) or J.IsDefending(bot)
        or bot:GetActiveMode() == BOT_MODE_DEFEND_ALLY or J.GetHP(bot) < 0.5
        or bot:WasRecentlyDamagedByAnyHero(4) or bot:WasRecentlyDamagedByTower(4)
        or DotaTime() < (bot.ohaAbilityOrderTime or -math.huge) + H.ORDER_GRACE then return false end
    local action = bot:GetCurrentActionType()
    if action ~= BOT_ACTION_TYPE_NONE and action ~= BOT_ACTION_TYPE_IDLE
        and action ~= BOT_ACTION_TYPE_MOVE_TO and action ~= BOT_ACTION_TYPE_MOVE_TO_DIRECTLY then return false end
    return #J.GetEnemiesNearLoc(bot:GetLocation(), 1200) == 0
        and #J.GetLastSeenEnemiesNearLoc(bot:GetLocation(), 1200) == 0
end

local function observe(bot, s, now)
    local id = bot:GetPlayerID()
    local score = GetHeroKills(id) + GetHeroAssists(id)
    local rotation = bot.ohaLaneRotation
    local returned = rotation ~= nil and rotation == s.rotation and rotation.phase == 'return'
        and (s.phase == 'assist' or s.phase == 'push')
    if (s.score ~= nil and score > s.score) or returned then
        s.eventUntil = now + H.EVENT_WINDOW
        -- Roll once per event, not once per frame until the roll succeeds.
        s.celebrate = RandomInt(1, 4) == 1
    end
    s.score, s.rotation, s.phase = score, rotation, rotation and rotation.phase
    if not bot:IsAlive() then s.celebrate = false end
end

local function findAbility(bot, s, debugEnabled)
    local found, details = nil, {}
    for _, name in ipairs(names) do
        local ability = bot:GetAbilityByName(name)
        -- Also check cast shape/cost: this exception must never prepare stats
        -- or accidentally issue a normal gameplay ability.
        if ability and ability:GetName() == name and ability:GetManaCost() == 0
            and ability:GetCastPoint() == 0 and ability:IsFullyCastable() and not found then found = ability end
        if debugEnabled and not s.probed then
            details[#details + 1] = name..'='..(ability and
                ('handle, hidden='..tostring(ability:IsHidden())..', castable='..tostring(ability:IsFullyCastable())) or 'nil')
        end
    end
    if debugEnabled and not s.probed then
        print('[HighFive] '..bot:GetUnitName()..': '..table.concat(details, '; '))
        s.probed = true
    end
    return found
end

local function reserved(humans, target, now)
    for _, ally in ipairs(humans) do
        if ally:IsBot() and ally.ohaHighFiveTarget == target:GetPlayerID()
            and now < (ally.ohaHighFiveUntil or -math.huge) then return true end
    end
    return false
end

function H.Think(bot, J, settings)
    settings = settings or {}
    if settings.Enable ~= false and settings.Allow_High_Fives == false then
        bot.ohaHighFive = nil
        return false
    end
    if bot.isBear or bot:GetPlayerID() < 0 then return false end
    local now = DotaTime()
    local s = bot.ohaHighFive or {}
    bot.ohaHighFive = s
    observe(bot, s, now)
    if now < (s.nextThink or -math.huge) then return false end
    s.nextThink = now + 0.25
    s.requests = s.requests or setmetatable({}, {__mode = 'k'})
    -- Observe request endings even while busy/on cooldown, so a later request
    -- from the same player is eligible again.
    for human in pairs(s.requests) do
        if not J.IsValidHero(human) or not requesting(human) then s.requests[human] = nil end
    end
    if not H.CanAct(bot, J) or requesting(bot) then return false end
    local debugEnabled = settings.Enable ~= false and settings.Debug_High_Fives == true
    local ability = findAbility(bot, s, debugEnabled)
    if not ability or now < (s.lastAttempt or -math.huge) + H.REPLY_INTERVAL then return false end

    local nearby = J.GetAlliesNearLoc(bot:GetLocation(), H.RANGE)
    local reply, partner, replyDist, partnerDist = nil, nil, math.huge, math.huge
    for _, human in ipairs(nearby) do
        if human ~= bot and realHero(human, J) and not human:IsBot() and human:GetTeam() == bot:GetTeam() then
            local distance = GetUnitToUnitDistance(bot, human)
            if distance <= H.RANGE then
                if not requesting(human) and distance < partnerDist then partner, partnerDist = human, distance end
                if requesting(human) then
                    local record = s.requests[human] or {}
                    s.requests[human] = record
                    if not record.attempted and not reserved(nearby, human, now) and distance < replyDist then
                        reply, replyDist = human, distance
                    end
                end
            end
        end
    end
    local target, motive = reply, 'reply'
    if not target and s.celebrate and now < (s.eventUntil or -math.huge)
        and now >= (s.lastCelebration or -math.huge) + H.CELEBRATE_INTERVAL then
        target, motive = partner, 'celebrate'
    end
    if not target then return false end
    -- Final safety check and scoped hidden-ability permission. Always clear the
    -- permission, including when the engine action raises an error.
    if not H.CanAct(bot, J) then return false end
    s.lastAttempt = now
    s.celebrate = false
    if motive == 'reply' then s.requests[target].attempted = true end
    if motive == 'celebrate' then s.lastCelebration, s.celebrate = now, false end
    bot.ohaHighFiveAbility = ability
    local ok = pcall(function() bot:Action_UseAbility(ability) end)
    bot.ohaHighFiveAbility = nil
    if ok then
        bot.ohaHighFiveTarget, bot.ohaHighFiveUntil = target:GetPlayerID(), now + 1
    end
    if debugEnabled then
        print('[HighFive] '..bot:GetUnitName()..' '..motive..' for player '..target:GetPlayerID()
            ..': '..(ok and 'order issued (animation unverified)' or 'order failed'))
    end
    return ok
end

return H
