-- Offline match banter. Observe facts even when muted; never queue stale taunts.
local X = {}
local Lines = require(GetScriptDirectory()..'/FunLib/banter_lines')
local Localization = require(GetScriptDirectory()..'/FunLib/localization')
local Customize = require(GetScriptDirectory()..'/FunLib/custom_loader')

local function baseline(s, v)
    s.kills, s.deaths, s.assists = v.kills, v.deaths, v.assists
    s.teamKills, s.enemyKills = v.teamKills, v.enemyKills
    s.time, s.hero = v.time, v.hero
end

-- v is a snapshot of scoreboard facts and locally observed danger.
function X.Observe(s, v)
    if s.time == nil or v.time < s.time or s.hero ~= v.hero
        or v.kills < s.kills or v.deaths < s.deaths then
        for key in pairs(s) do s[key] = nil end
        baseline(s, v)
        s.streak, s.recentKills, s.fights = 0, {}, {}
        s.wasBehind = v.enemyKills - v.teamKills >= 5
        return nil
    end

    local kills, deaths = v.kills - s.kills, v.deaths - s.deaths
    local participated = kills > 0 or v.assists > s.assists
    local lead, oldLead = v.teamKills - v.enemyKills, s.teamKills - s.enemyKills
    local previousStreak = s.streak
    if deaths > 0 then
        s.streak, s.recentKills, s.dangerTime = 0, {}, nil
    elseif kills > 0 then
        s.streak = s.streak + kills
    end
    for i = #s.recentKills, 1, -1 do
        if v.time - s.recentKills[i] > 10 then table.remove(s.recentKills, i) end
    end
    if deaths == 0 then
        for _ = 1, kills do table.insert(s.recentKills, v.time) end
    end
    if v.teamKills > s.teamKills or v.enemyKills > s.enemyKills then
        table.insert(s.fights, {time = v.time, allies = v.teamKills - s.teamKills,
            enemies = v.enemyKills - s.enemyKills})
    end
    local won, lost = 0, 0
    for i = #s.fights, 1, -1 do
        local fight = s.fights[i]
        if v.time - fight.time > 20 then table.remove(s.fights, i)
        else won, lost = won + fight.allies, lost + fight.enemies end
    end

    local escaped = false
    if not v.alive then s.dangerTime = nil
    elseif v.enemies >= 2 and v.health <= 0.35 and v.damaged then
        s.dangerTime = v.time
    elseif s.dangerTime ~= nil then
        local elapsed = v.time - s.dangerTime
        if elapsed > 18 then s.dangerTime = nil
        elseif elapsed >= 6 and v.enemies == 0 and not v.damaged then
            escaped, s.dangerTime = true, nil
        end
    end

    local event
    if deaths > 0 then
        event = previousStreak >= 3 and 'streak_ended' or 'death'
    elseif v.alive then
        if kills > 0 and v.teamKills == 1 and v.enemyKills == 0
            and s.teamKills == 0 then event = 'first_blood'
        elseif v.captain and s.wasBehind and lead >= 0 and oldLead < 0 then event = 'comeback'
        elseif participated and won >= 3 and won - lost >= 2 then
            event, s.fights = 'team_fight', {}
        elseif v.captain and lead >= 5 and math.floor(lead / 5) > math.floor(oldLead / 5) then
            event = 'lead'
        elseif kills > 0 and #s.recentKills >= 2 then event = 'multi_kill'
        elseif kills > 0 and (previousStreak < 3 and s.streak >= 3
            or previousStreak < 5 and s.streak >= 5
            or previousStreak < 8 and s.streak >= 8
            or previousStreak < 10 and s.streak >= 10) then event = 'kill_streak'
        elseif kills > 0 then event = 'kill'
        elseif escaped then event = 'escape'
        end
    end
    if lead <= -5 then s.wasBehind = true
    elseif lead >= 0 then s.wasBehind = false end
    baseline(s, v)
    return event
end

function X.GetLine(event, locale, previous, random)
    local bank = Lines[locale] or Lines.en
    local pool = bank[event] or Lines.en[event]
    if pool == nil or #pool == 0 then return nil end
    local index = random(1, #pool)
    if #pool > 1 and pool[index] == previous then index = index % #pool + 1 end
    return pool[index]
end

local killTaunts = {kill = true, multi_kill = true, kill_streak = true}
function X.Select(s, event, now, teamLast, settings, locale, random)
    local level = settings.Trash_Talk_Level or 1
    if event == nil or not settings.Allow_Trash_Talk or level < 1
        or (level < 2 and killTaunts[event]) then return nil end
    if now - (s.spokeAt or -1000) < 45 or now - teamLast < 12 then return nil end
    s.eventTimes = s.eventTimes or {}
    if now - (s.eventTimes[event] or -1000) < 120 then return nil end
    local chance = (event == 'first_blood' or event == 'comeback') and 80 or 45
    if random(1, 100) > chance then return nil end
    s.lastLines = s.lastLines or {}
    local line = X.GetLine(event, locale, s.lastLines[event], random)
    if line ~= nil then
        s.spokeAt, s.eventTimes[event], s.lastLines[event] = now, now, line
    end
    return line
end

function X.RecordSpeech(bot)
    bot.banterSpokeAt = DotaTime()
end

function X.IsSecondaryUnit(bot)
    if bot:IsIllusion() or bot:HasModifier('modifier_arc_warden_tempest_double') then return true end
    if bot:GetUnitName() == 'npc_dota_hero_meepo' then
        -- The canonical roster hero works while dead and without inventory heuristics.
        for index, id in ipairs(GetTeamPlayers(bot:GetTeam())) do
            if id == bot:GetPlayerID() then return GetTeamMember(index) ~= bot end
        end
        return true
    end
    return false
end

function X.Think(bot, captain)
    if GetGameState() ~= GAME_STATE_GAME_IN_PROGRESS or X.IsSecondaryUnit(bot) then return end
    local now = DotaTime()
    local s = bot.banterState
    if s == nil then s = {}; bot.banterState = s end
    if s.time ~= nil and now >= s.time and now - s.time < 1 then return end
    local teamKills, enemyKills, teamLast = 0, 0, -1000
    for index, id in ipairs(GetTeamPlayers(bot:GetTeam())) do
        teamKills = teamKills + GetHeroKills(id)
        local member = GetTeamMember(index)
        if member ~= nil and member.banterSpokeAt ~= nil and member.banterSpokeAt <= now then
            teamLast = math.max(teamLast, member.banterSpokeAt)
        end
    end
    for _, id in ipairs(GetTeamPlayers(GetOpposingTeam())) do
        enemyKills = enemyKills + GetHeroKills(id)
    end
    local enemies = 0
    if bot:IsAlive() then
        for _, enemy in ipairs(bot:GetNearbyHeroes(1200, true, BOT_MODE_NONE)) do
            if enemy:IsAlive() and not enemy:IsIllusion() then enemies = enemies + 1 end
        end
    end
    local id = bot:GetPlayerID()
    local event = X.Observe(s, {time = now, hero = bot:GetUnitName(),
        kills = GetHeroKills(id), deaths = GetHeroDeaths(id), assists = GetHeroAssists(id),
        teamKills = teamKills, enemyKills = enemyKills, captain = captain,
        alive = bot:IsAlive(), health = bot:GetHealth() / math.max(1, bot:GetMaxHealth()),
        enemies = enemies, damaged = bot:WasRecentlyDamagedByAnyHero(5)})
    local line = X.Select(s, event, now, teamLast, Customize, Localization.GetLocale(), RandomInt)
    if line ~= nil then
        bot:ActionImmediate_Chat(line, true)
        X.RecordSpeech(bot)
    end
end

return X
