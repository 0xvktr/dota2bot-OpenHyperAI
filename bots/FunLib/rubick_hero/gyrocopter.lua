local X = {}
local bot = GetBot()
local J = require(GetScriptDirectory()..'/FunLib/jmz_func')
local G = require(GetScriptDirectory()..'/FunLib/gyrocopter_abilities')
function X.ConsiderStolenSpell(ability)
    local spellName = ability:GetName()
    if not ({gyrocopter_rocket_barrage=true, gyrocopter_homing_missile=true, gyrocopter_flak_cannon=true, gyrocopter_call_down=true})[spellName] then return nil end
    if J.CanNotUseAbility(bot) then return false end
    local name = ability:GetName()
    local consider = ({gyrocopter_rocket_barrage=G.Barrage, gyrocopter_homing_missile=G.Missile,
        gyrocopter_flak_cannon=G.Flak, gyrocopter_call_down=G.Call})[name]
    if not consider then return false end
    local desire, target = consider(bot, ability)
    if desire > 0 then
        if name == 'gyrocopter_homing_missile' then bot:Action_UseAbilityOnEntity(ability, target)
        elseif name == 'gyrocopter_call_down' then bot:Action_UseAbilityOnLocation(ability, target)
        else bot:Action_UseAbility(ability) end
        return true
    end
    return false
end
return X
