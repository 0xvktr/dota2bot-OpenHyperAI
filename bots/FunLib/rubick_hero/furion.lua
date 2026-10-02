local X={}
local bot=GetBot()
local J=require(GetScriptDirectory()..'/FunLib/jmz_func')
local F=require(GetScriptDirectory()..'/FunLib/furion_abilities')
local FightResponse=require(GetScriptDirectory()..'/FunLib/fight_response')
function X.ConsiderStolenSpell(ability)
    local spellName = ability:GetName()
    if not ({furion_sprout=true, furion_force_of_nature=true, furion_wrath_of_nature=true, furion_curse_of_the_forest=true, furion_teleportation=true})[spellName] then return nil end
    if J.CanNotUseAbility(bot) or not J.CanCastAbility(ability) then return false end
    local name=ability:GetName();local desire,point=0,nil
    if name=='furion_sprout' then desire,point=F.Sprout(bot,ability)
    elseif name=='furion_force_of_nature' then desire,point=F.Call(bot,ability)
    elseif name=='furion_wrath_of_nature' then
        desire,point=F.Wrath(bot,ability)
        if desire>0 then bot:Action_UseAbilityOnEntity(ability,point); return true end;return false
    elseif name=='furion_curse_of_the_forest' then desire=F.Curse(bot,ability)
    elseif name=='furion_teleportation' then
        if F.SourceTeleportSafe(bot) and bot.useProphetTP and bot.ProphetTPLocation
            and not J.IsStunProjectileIncoming(bot,1200)
            and F.TeleportSafe(bot,bot.ProphetTPLocation)
            and FightResponse.CanTeleportTo(bot,bot.ProphetTPLocation,bot.ProphetTPPurpose) then
            FightResponse.RecordTeleport(bot,bot.ProphetTPLocation,bot.ProphetTPPurpose)
            bot:Action_UseAbilityOnLocation(ability,bot.ProphetTPLocation);bot.useProphetTP=false; return true
        end
        return false
    end
    if desire>0 then
        if point then bot:Action_UseAbilityOnLocation(ability,point) else bot:Action_UseAbility(ability) end
        return true
    end
    return false
end
return X
