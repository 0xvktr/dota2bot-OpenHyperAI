local FightResponse = require(GetScriptDirectory()..'/FunLib/fight_response')
local Defend = require( GetScriptDirectory()..'/FunLib/aba_defend')

local bot = GetBot()
local botName = bot:GetUnitName()

if bot:IsInvulnerable() or not bot:IsHero() or not string.find(botName, "hero") or bot:IsIllusion() then
	return
end

function GetDesire()
    if FightResponse.DefendDesire(bot, LANE_TOP, 1) == 0 then return 0 end
    return Defend.GetDefendDesire(bot, LANE_TOP)
end
function Think()
    if FightResponse.DefendDesire(bot, LANE_TOP, 1) == 0 then return end
    Defend.DefendThink(bot, LANE_TOP)
end
