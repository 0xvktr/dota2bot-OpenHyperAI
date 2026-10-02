local X={}
local bot=GetBot()
local J=require(GetScriptDirectory()..'/FunLib/jmz_func')
local F=require(GetScriptDirectory()..'/FunLib/faceless_void_abilities')
local state={}
function X.ConsiderStolenSpell(ability)
    local spellName = ability:GetName()
    if not ({faceless_void_time_walk=true, faceless_void_time_walk_reverse=true, faceless_void_time_dilation=true, faceless_void_chronosphere=true})[spellName] then return nil end
    if J.CanNotUseAbility(bot) then return false end
    local walk=bot:GetAbilityByName('faceless_void_time_walk')
    F.Observe(bot,walk,state)
    local name=ability:GetName()
    local desire,point=0,nil
    if name=='faceless_void_time_walk' then desire,point=F.Walk(bot,ability,state)
    elseif name=='faceless_void_time_walk_reverse' then desire=F.Reverse(bot,ability,state)
    elseif name=='faceless_void_time_dilation' then desire=F.Dilation(bot,ability)
    elseif name=='faceless_void_chronosphere' then desire,point=F.Chrono(bot,ability)
    end
    if desire>0 then
        if point then
            if name=='faceless_void_time_walk' then F.RecordWalk(bot,ability,point,state) end
            bot:Action_UseAbilityOnLocation(ability,point)
        else bot:Action_UseAbility(ability) end
        return true
    end
    return false
end
return X
