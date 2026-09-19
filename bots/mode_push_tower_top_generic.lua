local Objectives = require(GetScriptDirectory()..'/FunLib/objectives')
local J = require(GetScriptDirectory()..'/FunLib/jmz_func')
local Push = require( GetScriptDirectory()..'/FunLib/aba_push')
local bot = GetBot()
local botName = bot:GetUnitName()
if bot == nil or bot:IsInvulnerable() or not bot:IsHero() or not bot:IsAlive() or not string.find(botName, "hero") or bot:IsIllusion() then return end
if bot.PushLaneDesire == nil then bot.PushLaneDesire = {0, 0, 0} end

function GetDesire()
    local plan = Objectives.GetPlan(bot)
    if plan then
        bot.PushLaneDesire[LANE_TOP] = Objectives.PlanDesire(bot, 'push', LANE_TOP)
    else
        bot.PushLaneDesire[LANE_TOP] = Push.GetPushDesire(bot, LANE_TOP)
    end
    return bot.PushLaneDesire[LANE_TOP]
end
function Think()
    if J.CanNotUseAction(bot) then return end
    if Objectives.PlanThink(bot, 'push') then return end
    Push.PushThink(bot, LANE_TOP)
end
