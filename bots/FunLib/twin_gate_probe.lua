-- Isolated engine experiment, not production routing. Disabled by default.
local Settings = require(GetScriptDirectory()..'/FunLib/objective_settings')
local P = {}
local remainingMethods = { 'ability_none', 'ability_location', 'ability_exit' }
local function metadata(ability, method)
    local ok, value = pcall(function() return ability[method](ability) end)
    return ok and tostring(value) or 'unavailable'
end
-- Installed map build 25329722, default_ents.vents (September 17 extraction).
local locations = { Vector(-6457.690918, 7599.036621, 256), Vector(6425.52832, -7313.782715, 256) }

local function flushChat(bot)
    local s = bot.ohaGateProbe
    if not s or not s.chat or #s.chat == 0 or DotaTime() < (s.nextChat or 0) then return end
    bot:ActionImmediate_Chat('[GateProbe] '..table.remove(s.chat, 1), true)
    s.nextChat = DotaTime() + 2
end

local function log(bot, message)
    print('[GateProbe '..bot:GetPlayerID()..'] '..message)
    local s = bot.ohaGateProbe
    if s then
        s.chat = s.chat or {}
        table.insert(s.chat, string.sub(message, 1, 180))
        flushChat(bot)
    end
end

function P.Active(bot)
    return bot.ohaGateProbe ~= nil and not bot.ohaGateProbe.done
end

function P.Desire(bot)
    -- Drain even after completion so the terminal result is not lost to chat
    -- rate limits or an immediate return to normal gameplay.
    flushChat(bot)
    local config = Settings.TwinGateProbe
    if not config.Enabled or GetTeam() ~= config.Team or not bot:IsAlive() or bot:IsIllusion() then return 0 end
    if not bot.ohaGateProbe then
        if DotaTime() < 20 then return 0 end
        local selected
        for i = 1, #GetTeamPlayers(GetTeam()) do
            local h = GetTeamMember(i)
            if h and h:IsBot() and not h:IsIllusion()
                and (not selected or h:GetPlayerID() < selected:GetPlayerID()) then selected = h end
        end
        if bot ~= selected then return 0 end
        local index = GetUnitToLocationDistance(bot, locations[1]) < GetUnitToLocationDistance(bot, locations[2]) and 1 or 2
        bot.ohaGateProbe = { source = locations[index], destination = locations[3-index],
            started = DotaTime(), lastScan = -100, method = config.Method }
        if config.Method == 'remaining_forms' then
            bot.ohaGateProbe.step = 1
            bot.ohaGateProbe.method = remainingMethods[1]
        end
        log(bot, 'started '..config.Method..'; bot='..bot:GetUnitName()..'; source='..tostring(locations[index]))
    end
    return P.Active(bot) and 1.5 or 0
end

local function finish(bot, result)
    bot.ohaGateProbe.done = true
    bot:Action_ClearActions(true)
    log(bot, result)
end

function P.Think(bot)
    flushChat(bot)
    if not P.Active(bot) then return false end
    local s, now = bot.ohaGateProbe, DotaTime()
    if not bot:IsAlive() then s.done = true; log(bot, 'aborted: bot died'); return true end
    if bot:WasRecentlyDamagedByAnyHero(3) or bot:GetHealth() / bot:GetMaxHealth() < 0.6 then
        finish(bot, 'aborted: unsafe, result inconclusive'); return true
    end
    if now - s.started > (s.step and 120 or 90) then finish(bot, 'timed out reaching/testing gate; inconclusive'); return true end
    if s.issued and GetUnitToLocationDistance(bot, s.destination) < 700 then
        finish(bot, 'ARRIVAL observed at opposite gate; channel observed='..tostring(s.sawChannel or false))
        return true
    end
    local channel = bot:IsChanneling() or bot:HasModifier('modifier_twin_gate_warp_channel')
    if channel ~= s.channel then
        log(bot, 'channel='..tostring(channel)..'; location='..tostring(bot:GetLocation()))
        s.channel = channel
    end
    if s.issued then
        if channel then s.sawChannel = true end
        -- Never reissue the order or clear an active channel during observation.
        if now - s.issued > 12 and not channel then
            local result = 'no opposite-gate arrival after '..s.method..'; channel observed='..tostring(s.sawChannel or false)
            if s.step and remainingMethods[s.step + 1] then
                log(bot, result)
                s.step = s.step + 1
                s.method = remainingMethods[s.step]
                s.issued, s.sawChannel = nil, nil
            else finish(bot, result..'; test complete') end
        end
        return true
    end
    if channel or bot:IsUsingAbility() or bot:IsCastingAbility() then return true end
    if now - s.lastScan >= 1 then
        s.lastScan = now
        local count = 0
        for _, unit in pairs(GetUnitList(UNIT_LIST_ALL)) do
            if unit and not unit:IsNull() and unit:GetUnitName() == 'npc_dota_unit_twin_gate' then
                count = count + 1
                if GetUnitToLocationDistance(unit, s.source) < 700 then s.gate = unit end
                if GetUnitToLocationDistance(unit, s.destination) < 700 then s.exitGate = unit end
            end
        end
        if count ~= s.count then log(bot, 'GetUnitList(ALL) gate handles='..count); s.count = count end
    end
    if GetUnitToLocationDistance(bot, s.source) > 190 then
        bot:Action_MoveToLocation(s.source); return true
    end
    s.arrived = s.arrived or now
    local ability = bot:GetAbilityByName('twin_gate_portal_warp')
    if not s.reported then
        log(bot, 'at gate; hero warp handle='..tostring(ability ~= nil)..'; mana='..bot:GetMana())
        if ability then
            log(bot, 'warp castable='..tostring(ability:IsFullyCastable())
                ..'; hidden='..tostring(ability:IsHidden())..'; level='..ability:GetLevel()
                ..'; cooldown='..ability:GetCooldownTimeRemaining())
            log(bot, 'warp behavior='..metadata(ability, 'GetBehavior')
                ..'; targetTeam='..metadata(ability, 'GetTargetTeam')
                ..'; targetType='..metadata(ability, 'GetTargetType')
                ..'; castRange='..metadata(ability, 'GetCastRange'))
        end
        s.reported = true
    end
    if not s.gate or s.gate:IsNull() then
        if now - s.arrived >= 3 then finish(bot, 'no source gate handle in GetUnitList(ALL), even nearby; order not tested') end
        return true
    end
    s.issued = now
    local ok, err = pcall(function()
        bot:Action_ClearActions(true)
        if s.method == 'attack' then bot:Action_AttackUnit(s.gate, false)
        elseif s.method == 'ability_entity' and ability then bot:Action_UseAbilityOnEntity(ability, s.gate)
        elseif s.method == 'ability_none' and ability then bot:Action_UseAbility(ability)
        elseif s.method == 'ability_location' and ability then bot:Action_UseAbilityOnLocation(ability, s.gate:GetLocation())
        elseif s.method == 'ability_exit' and ability and s.exitGate and not s.exitGate:IsNull() then
            bot:Action_UseAbilityOnEntity(ability, s.exitGate)
        else error('unsupported method or missing hero warp handle') end
    end)
    if not ok then finish(bot, 'order error: '..tostring(err))
    else log(bot, 'issued ONE '..s.method..' order; observing without item/ability interference') end
    return true
end

return P
