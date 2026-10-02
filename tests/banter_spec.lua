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

-- Enemy scoreboard deltas name a victim or killer only when exactly one enemy moved with us.
local function foes(lina, zeus, axe)
    local function foe(name, score, human)
        return {name = name, kills = score[1] or 0, deaths = score[2] or 0, alive = score[3] ~= false, human = human}
    end
    return {[5] = foe('Lina', lina or {}, true), [6] = foe('Zeus', zeus or {}, false), [7] = foe('Axe', axe or {}, false)}
end
s, step = observed({teamKills = 10, enemyKills = 10, foes = foes()})
local event, context = step({time = 102, kills = 1, teamKills = 11, foes = foes({0, 1})})
eq(event, 'kill')
eq(context.victim, 'Lina', 'single enemy death names the victim')
eq(context.human, true, 'victim is a human player')
event, context = step({time = 110, deaths = 1, alive = false, enemyKills = 11, foes = foes({1, 1})})
eq(event, 'death')
eq(context.killer, 'Lina', 'single enemy kill names the killer')
eq(context.victim, nil)
eq(step({time = 150, alive = true}), nil)
event, context = step({time = 152, kills = 2, teamKills = 12, foes = foes({1, 2})})
eq(event, 'revenge', 'killing the last killer')
eq(context.victim, 'Lina')
event, context = step({time = 200, kills = 3, teamKills = 14, foes = foes({1, 3}, {0, 1})})
eq(event, 'kill')
eq(context, nil, 'two enemy deaths leave the victim unnamed')
eq(step({time = 210, enemyKills = 14, foes = foes({1, 3}, {3, 1})}), nil, 'enemy streak builds quietly')
event, context = step({time = 250, kills = 4, teamKills = 15, foes = foes({1, 3}, {3, 2})})
eq(event, 'shutdown', 'ending an enemy streak outranks our own milestone')
eq(context.victim, 'Zeus')
eq(context.human, false)
event, context = step({time = 300, kills = 5, teamKills = 16, foes = foes({1, 4}, {3, 2})})
eq(event, 'kill', 'second attributed repeat is not yet dominating')
event, context = step({time = 340, kills = 6, teamKills = 17, foes = foes({1, 5}, {3, 2})})
eq(event, 'dominating', 'third kill on a hero since it last killed us')
eq(context.victim, 'Lina')
eq(step({time = 380, kills = 7, teamKills = 18, foes = foes({1, 6}, {3, 2})}), 'kill', 'fourth repeat is ordinary')
s, step = observed({teamKills = 10, foes = foes()})
event, context = step({time = 102, deaths = 1, alive = false, enemyKills = 2, foes = foes({1}, {1})})
eq(event, 'death')
eq(context, nil, 'two enemy kills leave the killer unnamed')
eq(s.nemesis, nil)

s, step = observed({teamKills = 10, foes = foes()})
eq(step({time = 102, assists = 1, teamKills = 11, foes = foes({0, 1, false})}), nil)
eq(step({time = 104, kills = 1, teamKills = 13, foes = foes({0, 1, false}, {0, 1, false}, {0, 1, false})}), 'team_wipe')
eq(step({time = 106}), nil, 'wipe announced once')
eq(step({time = 108, assists = 2}), nil, 'wipe consumes the fight')
s, step = observed({teamKills = 10, foes = foes()})
eq(step({time = 102, teamKills = 13, foes = foes({0, 1, false}, {0, 1, false}, {0, 1, false})}), nil, 'bystander stays quiet on a wipe')
s, step = observed({teamKills = 10, captain = true, foes = foes()})
eq(step({time = 102, teamKills = 13, foes = foes({0, 1, false}, {0, 1, false}, {0, 1, false})}), 'team_wipe', 'captain may announce a wipe')
s, step = observed({teamKills = 10, captain = true, foes = foes()})
eq(step({time = 102, foes = foes({0, 0, false}, {0, 0, false}, {0, 0, false})}), nil, 'no wipe without a fresh kill')
s, step = observed({teamKills = 10, captain = true, foes = {[5] = foes()[5]}})
eq(step({time = 102, kills = 1, teamKills = 11, foes = {[5] = foes({0, 1, false})[5]}}), 'kill', 'too few enemies for a wipe')

for _, locale in ipairs({'en', 'zh', 'ru', 'ja'}) do
    for _, event in ipairs({'first_blood', 'kill', 'multi_kill', 'kill_streak', 'death', 'streak_ended', 'escape', 'team_fight', 'comeback', 'lead',
        'revenge', 'shutdown', 'dominating', 'team_wipe'}) do
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
eq(B.GetLine('revenge', 'ru', nil, first), Lines.ru.kill[1], 'missing pool reuses the locale kill pool')
eq(B.GetLine('team_wipe', 'zh', nil, first), Lines.zh.team_fight[1], 'missing pool reuses the locale fight pool')
-- Named lines need a known hero; every English pool keeps unnamed lines.
local function last(_, high) return high end
for event, pool in pairs(Lines.en) do
    local unnamed = 0
    for _, line in ipairs(pool) do
        for key in line:gmatch('{(%w+)}') do eq(key == 'victim' or key == 'killer', true, event..' placeholder') end
        if not line:find('{', 1, true) then unnamed = unnamed + 1 end
    end
    eq(unnamed >= 6, true, event..' has unnamed lines')
    eq(B.GetLine(event, 'en', nil, last):find('{', 1, true), nil, event..' never leaks a placeholder')
end
eq(B.GetLine('kill', 'en', nil, last, {victim = 'Lina'}), 'See you in a bit, Lina. Take your time.')
eq(B.GetLine('death', 'en', nil, last, {killer = 'Lina'}), "Lina, I'll remember that.")
eq(B.GetLine('death', 'en', nil, last, {victim = 'Lina'}):find('Lina', 1, true), nil, 'victim does not fill killer lines')
local text, template = B.GetLine('kill', 'en', nil, last, {victim = 'Lina'})
eq(template, Lines.en.kill[#Lines.en.kill], 'template returned for repeat tracking')
eq(B.GetLine('kill', 'en', nil, first, nil, {Lines.en.kill[1]}), Lines.en.kill[2], 'skip lines the team just used')
eq(B.GetLine('kill', 'ja', Lines.ja.kill[1], first, nil, Lines.ja.kill) ~= nil, true, 'exhausted pool still speaks')

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
-- Rare events and kills involving a human are likelier to be voiced.
local function roll(value) return function(low, high) return high == 100 and value or low end end
for _, case in ipairs({{'kill', nil, 46, nil}, {'kill', {human = true}, 65, 'string'}, {'kill', {human = true}, 66, nil},
    {'revenge', {human = false}, 80, 'string'}, {'team_wipe', nil, 80, 'string'}, {'shutdown', nil, 81, nil}}) do
    local line = B.Select({}, case[1], 1000, -1000, settings, 'en', roll(case[3]), case[2])
    eq(line and type(line), case[4], case[1]..' chance '..case[3])
end
settings.Trash_Talk_Level = 1
for _, event in ipairs({'revenge', 'shutdown', 'dominating'}) do eq(select({}, event), nil, 'level one suppresses '..event) end
eq(type(select({}, 'team_wipe')), 'string', 'level one keeps team wipes')
settings.Trash_Talk_Level = 2
-- Allied bots do not reuse a line one of them said recently.
local shared = {}
for index = 1, 6 do
    local line = B.Select({}, 'escape', 2000 + index, -1000, settings, 'en', first)
    eq(shared[line], nil, 'team line repeated')
    shared[line] = true
end

-- Exercise the engine adapter with the actual selector and phrase pools.
GAME_STATE_PRE_GAME, GAME_STATE_GAME_IN_PROGRESS, BOT_MODE_NONE = 4, 5, 0
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
function IsHeroAlive(id) return (scores[id] or {}).dead ~= true end
function GetSelectedHeroName(id) return id == 5 and 'npc_dota_hero_lina' or 'npc_dota_hero_axe' end
function IsPlayerBot(id) return id ~= 5 end
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
for _, excluded in ipairs({'illusion', 'double', 'draft'}) do
    reads = scoreReads
    bot.illusion, bot.double = excluded == 'illusion', excluded == 'double'
    gameState = excluded == 'draft' and 3 or 5
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
-- Fights before the horn count, and the adapter names the enemy hero.
now, gameState, scores = -30, 4, {}
B.Think(bot, true)
now, scores[0], scores[5] = -20, {kills = 1}, {deaths = 1, dead = true}
RandomInt = function(low, high) return high == 100 and low or high end
B.Think(bot, true)
eq(messages[#messages].text, 'First blood on Lina. Bold of you to volunteer.', 'pre-horn first blood names the victim')
RandomInt, gameState = first, 5

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
