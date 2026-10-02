local X={}
local J=require(GetScriptDirectory()..'/FunLib/jmz_func')
local M=require(GetScriptDirectory()..'/FunLib/sand_king_abilities')
local considers={sandking_burrowstrike=M.Burrow,sandking_sand_storm=M.Storm,sandking_scorpion_strike=M.Stinger,sandking_epicenter=M.Epicenter}
function X.ConsiderStolenSpell(ability)
    local name=ability:GetName();local consider=considers[name]
    if not consider then return nil end
    local bot=GetBot()
    if J.CanNotUseAbility(bot) then return false end
    if M.RelocateEpicenter(bot) then return true end
    local desire,target=consider(bot,ability)
    if desire<=0 then return false end
    if name=='sandking_epicenter' or name=='sandking_sand_storm' then bot:Action_UseAbility(ability) else bot:Action_UseAbilityOnLocation(ability,target) end
    if name=='sandking_epicenter' then M.RecordEpicenter(bot,ability,target) end
    return true
end
return X
