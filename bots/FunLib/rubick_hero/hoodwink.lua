local X = {}
local bot = GetBot()
local J = require(GetScriptDirectory()..'/FunLib/jmz_func')
local H = require(GetScriptDirectory()..'/FunLib/hoodwink_abilities')
local startedShot
function X.UseSharpshooterRelease()
    return H.Release(bot, bot:GetAbilityByName('hoodwink_sharpshooter'), bot:GetAbilityByName('hoodwink_sharpshooter_release'), startedShot)
end
function X.ConsiderStolenSpell(ability)
    local spellName = ability:GetName()
    if not ({hoodwink_acorn_shot=true, hoodwink_bushwhack=true, hoodwink_scurry=true, hoodwink_hunters_boomerang=true, hoodwink_decoy=true, hoodwink_sharpshooter=true})[spellName] then return nil end
    if X.UseSharpshooterRelease() then return true end
    if J.CanNotUseAbility(bot) or bot:HasModifier('modifier_hoodwink_sharpshooter_windup') then return false end
    local name = ability:GetName()
    local consider = ({hoodwink_acorn_shot=H.Acorn, hoodwink_bushwhack=H.Bush, hoodwink_scurry=H.Scurry,
        hoodwink_hunters_boomerang=H.Boomerang, hoodwink_decoy=H.Decoy, hoodwink_sharpshooter=H.Sharpshooter})[name]
    if not consider then return false end
    local desire, target, point = consider(bot, ability)
    if desire > 0 then
        if name == 'hoodwink_scurry' or name == 'hoodwink_decoy' then bot:Action_UseAbility(ability)
        elseif name == 'hoodwink_acorn_shot' and not point then
            if ability:GetAutoCastState() then ability:ToggleAutoCast() end
            bot:Action_UseAbilityOnEntity(ability, target)
        else
            if name == 'hoodwink_sharpshooter' then startedShot = DotaTime() end
            bot:Action_UseAbilityOnLocation(ability, target)
        end
        return true
    end
    return false
end
return X
