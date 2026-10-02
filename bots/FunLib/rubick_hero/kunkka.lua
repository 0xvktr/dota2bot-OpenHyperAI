local X={}
local bot=GetBot()
local J=require(GetScriptDirectory()..'/FunLib/jmz_func')
local K=require(GetScriptDirectory()..'/FunLib/kunkka_abilities')
local mark={}
function X.ConsiderStolenSpell(ability)
    local name=ability:GetName()
    local consider=({kunkka_torrent=K.Torrent,kunkka_x_marks_the_spot=K.X,kunkka_return=K.Return,
        kunkka_ghostship=K.Ship,kunkka_tidal_wave=K.Wave,kunkka_tidebringer=K.Tide})[name]
    if not consider then return nil end
    if J.CanNotUseAbility(bot) then return false end
    K.Observe(bot,mark)
    local desire,target=consider(bot,ability,mark)
    if desire>0 then
        if name=='kunkka_x_marks_the_spot' or name=='kunkka_tidebringer' then bot:Action_UseAbilityOnEntity(ability,target)
        elseif name=='kunkka_return' then bot:Action_UseAbility(ability);mark.target=nil
        else bot:Action_UseAbilityOnLocation(ability,target);K.RecordSpell(mark,ability) end
        if name=='kunkka_x_marks_the_spot' then K.RecordX(mark,ability,target) end
        return true
    end
    return false
end
return X
