local X={}
local J=require(GetScriptDirectory()..'/FunLib/jmz_func')
local M=require(GetScriptDirectory()..'/FunLib/ringmaster_abilities')
local considers={ringmaster_the_box=M.Box,ringmaster_wheel=M.Wheel,ringmaster_tame_the_beasts=M.Whip,ringmaster_impalement=M.Dagger,ringmaster_spotlight=M.Spotlight}
function X.UseTameTheBeastsCrack() return M.ReleaseWhip(GetBot()) end
function X.UseCarnivalSouvenir() return M.UseSouvenir(GetBot(),true) end
function X.ConsiderStolenSpell(ability)
    local name=ability:GetName();local consider=considers[name]
    if name=='ringmaster_tame_the_beasts_crack' then return X.UseTameTheBeastsCrack() end
    if not consider then return nil end
    local bot=GetBot()
    if J.CanNotUseAbility(bot) then return false end
    local desire,target,shape=consider(bot,ability)
    if desire<=0 then return false end
    if shape=='unit' then bot:Action_UseAbilityOnEntity(ability,target) else bot:Action_UseAbilityOnLocation(ability,target) end
    if name=='ringmaster_tame_the_beasts' then M.RecordWhip(bot,ability,target) end
    return true
end
return X
