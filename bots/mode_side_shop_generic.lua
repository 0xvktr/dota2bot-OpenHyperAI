local bot = GetBot()
local J = require(GetScriptDirectory()..'/FunLib/jmz_func')
local Objectives = require(GetScriptDirectory()..'/FunLib/objectives')

function GetDesire()
    return Objectives.PlanDesire(bot, 'tormentor')
end

function Think()
    if J.CanNotUseAction(bot) then return end
    Objectives.PlanThink(bot, 'tormentor')
end
