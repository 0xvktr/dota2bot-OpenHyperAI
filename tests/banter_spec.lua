local checks = 0
local function eq(actual, expected, label)
    checks = checks + 1
    assert(actual == expected, (label or 'assertion')..': expected '..tostring(expected)..', got '..tostring(actual))
end
function GetScriptDirectory() return 'bots' end
local settings = {Enable = true, Allow_Trash_Talk = true, Trash_Talk_Level = 2, Localization = 'en'}
package.loaded['bots.FunLib.custom_loader'] = settings
package.loaded['bots/FunLib/custom_loader'] = settings
local Localization = require('bots/FunLib/localization')
local B = require('bots/FunLib/banter')
local Lines = require('bots/FunLib/banter_lines')
local function first(low) return low end
local function snapshot(values)
    local v = {time = 100, hero = 'axe', kills = 0, deaths = 0, assists = 0,
        teamKills = 0, enemyKills = 0, captain = false, alive = true,
        health = 1, enemies = 0, damaged = false}
    for key, value in pairs(values or {}) do v[key] = value end
    return v
end
local function observed(initial)
    local s, v = {}, snapshot(initial)
    eq(B.Observe(s, v), nil, 'initial baseline')
    return s, function(changes)
        for key, value in pairs(changes) do v[key] = value end
        return B.Observe(s, v)
    end
end
local s, step = observed({kills = 4, deaths = 2, teamKills = 8})
eq(step({time = 102}), nil, 'reload does not invent kills')
eq(step({time = 104, kills = 5, teamKills = 9}), 'kill')
eq(step({time = 106, kills = 6, deaths = 3, alive = false, teamKills = 10}), 'death', 'simultaneous death wins')
eq(s.streak, 0)
eq(step({time = 108, alive = true}), nil, 'respawn alone is quiet')
eq(step({time = 110, hero = 'lina', kills = 7}), nil, 'hero swap resets')
eq(step({time = 1}), nil, 'clock reset')
eq(step({time = 2, kills = 0}), nil, 'score reset')

s, step = observed()
eq(step({time = 102, kills = 1, teamKills = 1}), 'first_blood')
eq(step({time = 104, kills = 2, teamKills = 2}), 'multi_kill')
s, step = observed({teamKills = 10})
eq(step({time = 102, kills = 1, teamKills = 11}), 'kill')
eq(step({time = 113, kills = 2, teamKills = 12}), 'kill', 'multikill expires after ten seconds')
eq(step({time = 135, kills = 3, teamKills = 13}), 'kill_streak')
eq(step({time = 137, deaths = 1, alive = false}), 'streak_ended')
s, step = observed({teamKills = 10})
eq(step({time = 102, assists = 1, teamKills = 13, enemyKills = 1}), 'team_fight')
eq(step({time = 104, assists = 2}), nil, 'fight consumed once')
s, step = observed({teamKills = 10})
eq(step({time = 102, teamKills = 12}), nil, 'bystander remains quiet')
eq(step({time = 123, assists = 1, teamKills = 13}), nil, 'old fight expires')
s, step = observed({teamKills = 3, enemyKills = 8, captain = true})
eq(step({time = 110, teamKills = 8}), 'comeback')
eq(step({time = 112}), nil, 'comeback only on crossing')
eq(step({time = 114, teamKills = 13}), 'lead')
eq(step({time = 116, teamKills = 14}), nil, 'lead threshold only')
s, step = observed({teamKills = 3, enemyKills = 8})
eq(step({time = 110, teamKills = 8}), nil, 'noncaptain does not announce comeback')
-- Captain momentum must survive an accompanying personal kill at default intensity.
for _, recoveredScore in ipairs({8, 9}) do
    s, step = observed({teamKills = 3, enemyKills = 8, captain = true})
    eq(step({time = 125, teamKills = 7}), nil)
    local event = step({time = 147, teamKills = recoveredScore, kills = recoveredScore - 7})
    eq(event, 'comeback', 'captain kill equalizes or overtakes from minus one')
    local levelOne = {Allow_Trash_Talk = true, Trash_Talk_Level = 1}
    eq(type(B.Select(s, event, 147, -1000, levelOne, 'en', first)), 'string', 'level one comeback remains eligible')
end
s, step = observed({teamKills = 9, enemyKills = 5, captain = true})
eq(step({time = 122, teamKills = 10, kills = 1}), 'lead', 'lead supersedes generic kill')

s, step = observed()
eq(step({time = 102, health = 0.2, enemies = 2, damaged = true}), nil)
eq(step({time = 106, enemies = 0, damaged = false}), nil, 'escape needs six seconds')
eq(step({time = 108}), 'escape')
eq(step({time = 110}), nil, 'escape consumed once')
s, step = observed()
eq(step({time = 102, health = 0.2, enemies = 1, damaged = true}), nil)
eq(step({time = 110, enemies = 0, damaged = false}), nil, 'one enemy is not a gank escape')
s, step = observed()
step({time = 102, health = 0.2, enemies = 2, damaged = true})
step({time = 104, deaths = 1, alive = false})
eq(step({time = 112, alive = true, enemies = 0, damaged = false}), nil, 'death cancels escape')
s, step = observed()
step({time = 102, health = 0.2, enemies = 2, damaged = true})
eq(step({time = 121, enemies = 0, damaged = false}), nil, 'expired danger is quiet')

for _, locale in ipairs({'en', 'zh', 'ru', 'ja'}) do
    for _, event in ipairs({'first_blood', 'kill', 'multi_kill', 'kill_streak', 'death', 'streak_ended', 'escape', 'team_fight', 'comeback', 'lead'}) do
        local line = B.GetLine(event, locale, nil, first)
        eq(type(line), 'string', locale..' '..event)
        assert(#line > 0)
        eq(B.GetLine(event, locale, line, first) ~= line, true, 'avoid immediate repeat')
    end
end
eq(B.GetLine('kill', 'missing', nil, first), Lines.en.kill[1], 'locale fallback')
local saved = Lines.ru.kill
Lines.ru.kill = nil
eq(B.GetLine('kill', 'ru', nil, first), Lines.en.kill[1], 'event fallback')
Lines.ru.kill = saved
eq(B.GetLine('unknown_event', 'en', nil, first), nil)

local function select(state, event, now, teamLast, random)
    return B.Select(state, event, now or 100, teamLast or -1000, settings, 'en', random or first)
end
s = {}
settings.Allow_Trash_Talk = false
eq(select(s, 'first_blood'), nil, 'master mute')
settings.Allow_Trash_Talk = true
settings.Trash_Talk_Level = 0
eq(select(s, 'first_blood'), nil, 'level zero mute')
settings.Trash_Talk_Level = 1
for _, event in ipairs({'kill', 'multi_kill', 'kill_streak'}) do eq(select(s, event), nil, 'level one kill suppression') end
settings.Trash_Talk_Level = 2
eq(select(s, 'kill', 100, 95), nil, 'team cooldown')
eq(select(s, 'kill', 100, -1000, function(_, high) return high end), nil, 'chance rejects')
eq(type(select(s, 'kill')), 'string')
eq(select(s, 'death', 144), nil, 'personal cooldown')
eq(type(select(s, 'death', 145)), 'string')
eq(select(s, 'kill', 219), nil, 'event cooldown')
eq(type(select(s, 'kill', 220)), 'string')

-- Exercise the engine adapter with the actual selector and phrase pools.
GAME_STATE_GAME_IN_PROGRESS, BOT_MODE_NONE = 5, 0
local now, gameState, scoreReads = 100, 5, 0
local scores, messages, nearby = {}, {}, {}
local bot = {alive = true, illusion = false, double = false, hp = 1000}
function bot:IsIllusion() return self.illusion end
function bot:HasModifier(name) return name == 'modifier_arc_warden_tempest_double' and self.double end
function bot:GetTeam() return 2 end
function bot:GetPlayerID() return 0 end
function bot:GetUnitName() return self.hero or 'npc_dota_hero_axe' end
function bot:IsAlive() return self.alive end
function bot:GetHealth() return self.hp end
function bot:GetMaxHealth() return 1000 end
function bot:WasRecentlyDamagedByAnyHero() return false end
function bot:GetNearbyHeroes() return nearby end
function bot:ActionImmediate_Chat(text, allChat) table.insert(messages, {text = text, allChat = allChat}) end
function DotaTime() return now end
function GetGameState() return gameState end
function GetTeamPlayers(team) return team == 2 and {0, 1} or {5} end
local ally = {}
local canonical = bot
function GetTeamMember(index) return index == 1 and canonical or ally end
function GetOpposingTeam() return 3 end
function GetHeroKills(id) scoreReads = scoreReads + 1; return (scores[id] or {}).kills or 0 end
function GetHeroDeaths(id) return (scores[id] or {}).deaths or 0 end
function GetHeroAssists(id) return (scores[id] or {}).assists or 0 end
RandomInt = first
B.Think(bot, true)
eq(#messages, 0)
local reads = scoreReads
now = 100.5
B.Think(bot, true)
eq(scoreReads, reads, 'sample throttle')
now, scores[0] = 102, {kills = 1}
B.Think(bot, true)
eq(#messages, 1)
eq(messages[1].allChat, true, 'banter is all chat')
eq(bot.banterSpokeAt, now, 'speech timestamp')
now, scores[0], settings.Allow_Trash_Talk = 230, {kills = 2}, false
B.Think(bot, true)
eq(#messages, 1, 'muted fresh event suppressed')
now, settings.Allow_Trash_Talk = 232, true
B.Think(bot, true)
eq(#messages, 1, 'no stale event after unmute')
now, scores[0], ally.banterSpokeAt = 360, {kills = 3}, 355
B.Think(bot, true)
eq(#messages, 1, 'teammate speech suppresses')
now, ally.banterSpokeAt = 380, nil
B.Think(bot, true)
eq(#messages, 1, 'suppressed event never queued')
for _, excluded in ipairs({'illusion', 'double', 'pregame'}) do
    reads = scoreReads
    bot.illusion, bot.double = excluded == 'illusion', excluded == 'double'
    gameState = excluded == 'pregame' and 4 or 5
    now = now + 5
    B.Think(bot, true)
    eq(scoreReads, reads, excluded..' not sampled')
end
bot.illusion, bot.double, gameState = false, false, 5
-- Canonical Meepo speaks while alive or dead; clones sharing his ID never do.
bot.hero = 'npc_dota_hero_meepo'
local clone = setmetatable({hero = bot.hero}, {__index = bot})
for _, alive in ipairs({true, false}) do
    bot.alive, clone.alive = alive, alive
    eq(B.IsSecondaryUnit(bot), false, 'canonical Meepo survives clone guard')
    eq(B.IsSecondaryUnit(clone), true, 'same player ID does not identify main Meepo')
    reads = scoreReads
    B.Think(clone, true)
    eq(scoreReads, reads, 'clone not sampled alive or dead')
end
bot.alive, bot.hero = true, nil
-- Future timestamps left behind by a clock reset must not suppress new events.
now, scores, bot.banterSpokeAt, ally.banterSpokeAt = 10, {}, 1000, 1000
B.Think(bot, true)
local beforeResetKill = #messages
now, scores[0] = 12, {kills = 1}
B.Think(bot, true)
eq(#messages, beforeResetKill + 1, 'clock reset ignores future team speech')

-- Language parsing handles exact commands and preserves the locale on bad input.
eq(Localization.HandleChatCommand('  !SPEAK CN  '), true)
eq(Localization.GetLocale(), 'zh')
for _, text in ipairs({'!sp', '!speak xx', '!sp en extra'}) do
    eq(Localization.HandleChatCommand(text), true, 'consume malformed language command')
    eq(Localization.GetLocale(), 'zh')
end
for _, text in ipairs({'hello !sp en', '!sprint en', '', '!speaker ru'}) do eq(Localization.HandleChatCommand(text), false) end
eq(Localization.HandleChatCommand(nil), false)
eq(Localization.SetLocale(' RU '), true)
eq(Localization.GetLocale(), 'ru')
eq(Localization.SetLocale(nil), false)

-- Actual chat integration: human commands, delayed replies and budget exhaustion.
local callback, callbacks, replies = nil, 0, 0
function InstallChatCallback(fn) callback = fn; callbacks = callbacks + 1 end
function IsPlayerBot(id) return id == 0 or id == 1 end
local J = {Role = {}, Chat = {}}
function J.Role.GetReplyMemberID() return 0 end
function J.Role.IsAllyMemberID(id) return id < 5 end
function J.Role.IsEnemyMemberID(id) return id >= 5 end
function J.Role.SetLastChatString() end
function J.Chat.GetReplyString() replies = replies + 1; return 'reply' end
function J.Chat.GetStopReplyString() return 'last reply' end
local thinkCount, recorded = 0, 0
local StubBanter = {
    IsSecondaryUnit = B.IsSecondaryUnit,
    Think = function(_, captain) eq(captain, true); thinkCount = thinkCount + 1 end,
    RecordSpeech = function() recorded = recorded + 1 end,
}
local makeChat = dofile(arg[1])
local beforeCloneMessages = #messages
for _, alive in ipairs({true, false}) do
    clone.alive = alive
    makeChat(clone, J, StubBanter, Localization).SetTalkMessage()
end
eq(callbacks, 0, 'clone never installs callback')
eq(thinkCount, 0, 'clone never reaches banter or reply logic')
eq(#messages, beforeCloneMessages, 'clone never speaks')
local chat = makeChat(bot, J, StubBanter, Localization)
now = 500
chat.SetTalkMessage()
eq(callbacks, 1)
callback({player_id = 2, string = '!sp en', team_only = true})
eq(Localization.GetLocale(), 'en', 'human language command')
callback({player_id = 1, string = '!sp ja', team_only = true})
eq(Localization.GetLocale(), 'en', 'bot cannot set locale')
for index = 1, 8 do
    callback({player_id = 2, string = 'hello', team_only = true})
    now = now + 10
    chat.SetTalkMessage()
end
eq(replies, 6, 'reply budget still enforced')
eq(recorded, 6, 'replies reserve banter cooldown')
eq(messages[#messages].allChat, false, 'team reply stays private')
callback({player_id = 2, string = '!speak ja', team_only = true})
eq(Localization.GetLocale(), 'ja', 'commands survive exhausted reply budget')
eq(callbacks, 1, 'callback installed once')
eq(thinkCount, 9, 'banter runs after reply budget')
-- Draft phase shares language parsing while retaining compound draft commands.
GAME_STATE_HERO_SELECTION, gameState = 3, 3
local dispatched, shorthand = {}, nil
local draft = dofile(arg[2])(Localization,
    function(text) return text:sub(1, 1) == '!' end,
    function(text, player, teamOnly) table.insert(dispatched, {text = text, player = player, teamOnly = teamOnly}) end,
    function(locale) shorthand = locale; Localization.SetLocale(locale) end)
for _, command in ipairs({'!sp', '!speak'}) do
    draft(2, command, true)
    eq(Localization.GetLocale(), 'ja', 'bare draft command preserves locale')
end
eq(#dispatched, 0, 'bare locale commands never enter draft command parser')
draft(2, '!SPEAK RU', true)
eq(Localization.GetLocale(), 'ru')
draft(1, '!sp en', true)
eq(Localization.GetLocale(), 'ru', 'bot cannot change draft locale')
draft(1, '!pick axe; !sp en', true)
eq(#dispatched, 0, 'bot cannot dispatch compound commands')
draft(2, '!pick axe; !sp en', true)
eq(#dispatched, 1, 'compound draft command dispatched')
eq(dispatched[1].text, '!pick axe; !sp en')
eq(dispatched[1].player, 2)
eq(dispatched[1].teamOnly, true)
draft(2, 'zh', true)
eq(shorthand, 'zh', 'two-letter language shorthand retained')
eq(Localization.GetLocale(), 'zh')
print('Banter scenarios passed ('..checks..' assertions)')
