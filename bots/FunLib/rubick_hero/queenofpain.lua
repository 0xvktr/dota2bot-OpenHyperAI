local X={}
local bot=GetBot()
local J=require(GetScriptDirectory()..'/FunLib/jmz_func')
local Q=require(GetScriptDirectory()..'/FunLib/queenofpain_abilities')
function X.ConsiderStolenSpell(ability)
    local name=ability:GetName()
    local consider=({queenofpain_shadow_strike=Q.Strike,queenofpain_blink=Q.Blink,queenofpain_scream_of_pain=Q.Scream,queenofpain_sonic_wave=Q.Wave})[name]
    if not consider then return nil end
    if J.CanNotUseAbility(bot) then return false end
    local desire,target,shape=consider(bot,ability)
    if desire>0 then
        if shape=='unit' then bot:Action_UseAbilityOnEntity(ability,target)
        elseif name=='queenofpain_scream_of_pain' then bot:Action_UseAbility(ability)
        else bot:Action_UseAbilityOnLocation(ability,target) end
        return true
    end
    return false
end
return X
