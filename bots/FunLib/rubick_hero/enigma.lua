local X={}
local bot=GetBot()
local J=require(GetScriptDirectory()..'/FunLib/jmz_func')
local E=require(GetScriptDirectory()..'/FunLib/enigma_abilities')
function X.ConsiderStolenSpell(ability)
    local spellName = ability:GetName()
    if not ({enigma_black_hole=true, enigma_midnight_pulse=true, enigma_malefice=true, enigma_demonic_conversion=true})[spellName] then return nil end
    if J.CanNotUseAbility(bot) or not J.CanCastAbility(ability) then return false end
    local name=ability:GetName()
    local desire,point=0,nil
    if name=='enigma_black_hole' then desire,point=E.Hole(bot,ability)
    elseif name=='enigma_midnight_pulse' then desire,point=E.Pulse(bot,ability)
    elseif name=='enigma_malefice' then
        local target=J.GetProperTarget(bot)
        local damage=ability:GetSpecialValueInt('damage')*ability:GetSpecialValueInt('stun_instances')
        for _,enemy in pairs(J.GetNearbyHeroes(bot,E.CastRange(bot,ability),true,BOT_MODE_NONE)) do
            if J.IsValidHero(enemy) and J.CanCastOnNonMagicImmune(enemy) and J.CanCastOnTargetAdvanced(enemy)
                and (enemy:IsChanneling() or J.CanKillTarget(enemy,damage,DAMAGE_TYPE_MAGICAL)
                    or enemy==target and J.IsGoingOnSomeone(bot) and not J.IsDisabled(enemy)
                    or J.IsRetreating(bot) and J.IsChasingTarget(enemy,bot)) then
                bot:Action_UseAbilityOnEntity(ability,enemy); return true
            end
        end
    elseif name=='enigma_demonic_conversion' then
        local cost=75+25*(ability:GetLevel()-1)
        if bot:GetHealth()-cost < bot:GetMaxHealth()*0.5 then return false end
        if J.IsGoingOnSomeone(bot) or J.IsPushing(bot) or J.IsDefending(bot)
            or J.IsFarming(bot) and #bot:GetNearbyNeutralCreeps(600)>=2 then
            desire,point=BOT_ACTION_DESIRE_HIGH,bot:GetLocation()
        end
    end
    if desire>0 then bot:Action_UseAbilityOnLocation(ability,point); return true end
    return false
end
return X
