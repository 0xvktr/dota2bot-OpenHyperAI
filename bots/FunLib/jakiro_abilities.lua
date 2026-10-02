local K = {}
local J = require(GetScriptDirectory()..'/FunLib/jmz_func')
function K.Range(bot, ability)
    local bonus = 0
    for slot = 0, 5 do local item=bot:GetItemInSlot(slot);if item and item:GetName()=='item_aether_lens' then bonus=item:GetSpecialValueInt('cast_range_bonus');break end end
    local supremacy=bot:GetAbilityByName('rubick_arcane_supremacy')
    if supremacy and supremacy:IsTrained() and not J.HasBreakModifier(bot) then bonus=bonus+supremacy:GetSpecialValueInt('cast_range') end
    return ability:GetCastRange()+bonus
end
local function hit(bot, point, unit, width, delay)
    local origin=bot:GetLocation();local p=unit:GetExtrapolatedLocation(delay)
    local dx,dy=point.x-origin.x,point.y-origin.y;local length2=dx*dx+dy*dy
    if length2==0 then return false end
    local t=((p.x-origin.x)*dx+(p.y-origin.y)*dy)/length2
    if t<0 or t>1 then return false end
    return (p.x-origin.x-t*dx)^2+(p.y-origin.y-t*dy)^2<=width*width
end
function K.Line(bot, ability, kind)
    if not J.CanCastAbility(ability) then return 0,nil end
    local range=K.Range(bot,ability);local delay=ability:GetCastPoint()
    if kind=='ice' then delay=delay+ability:GetSpecialValueFloat('path_delay') end
    local width=kind=='ice' and ability:GetSpecialValueInt('path_radius') or kind=='macro' and ability:GetSpecialValueInt('path_width')/2 or ability:GetSpecialValueInt('end_radius')
    local pierces=kind=='macro' and ability:GetSpecialValueInt('pierces_magic_immunity')>0
    local damage=ability:GetSpecialValueInt(kind=='breath' and 'burn_damage' or 'damage')
    if kind=='breath' then damage=damage*ability:GetDuration() end
    local damageType=kind=='macro' and ability:GetSpecialValueInt('pure_damage_type')>0 and DAMAGE_TYPE_PURE or DAMAGE_TYPE_MAGICAL
    local heroes=J.GetNearbyHeroes(bot,math.min(1600,range),true,BOT_MODE_NONE)
    for _,enemy in pairs(heroes) do
        if J.IsValidHero(enemy) and (pierces and J.CanCastOnMagicImmune(enemy) or J.CanCastOnNonMagicImmune(enemy)) then
            local predict=delay
            if kind=='breath' then predict=predict+GetUnitToUnitDistance(bot,enemy)/ability:GetSpecialValueInt('speed') end
            local point=enemy:GetExtrapolatedLocation(predict)
            if GetUnitToLocationDistance(bot,point)<=range then
                local direction=point-bot:GetLocation()
                local endpoint=bot:GetLocation()+direction:Normalized()*range
                local count=0
                for _,other in pairs(heroes) do
                    if J.IsValidHero(other) and (pierces and J.CanCastOnMagicImmune(other) or J.CanCastOnNonMagicImmune(other))
                        and hit(bot,endpoint,other,width,predict) then count=count+1 end
                end
                local useful=kind=='ice' and enemy:IsChanneling() or J.IsRetreating(bot) and J.IsChasingTarget(enemy,bot)
                    or J.IsGoingOnSomeone(bot) and enemy==J.GetProperTarget(bot)
                    or J.IsInTeamFight(bot,1200) and count>=2
                    or kind~='macro' and J.CanKillTarget(enemy,damage,damageType)
                if useful and (kind~='macro' or J.IsDisabled(enemy) or count>=2)
                    and not enemy:HasModifier(kind=='ice' and 'modifier_jakiro_ice_path_stun' or kind=='macro' and 'modifier_jakiro_macropyre_burn' or 'modifier_jakiro_dual_breath_burn') then
                    return BOT_ACTION_DESIRE_HIGH,point
                end
            end
        end
    end
    return 0,nil
end
function K.Liquid(bot, ability, ice)
    if not J.CanCastAbility(ability) or bot:IsDisarmed() then return 0,nil end
    local target=J.GetProperTarget(bot);local attack=bot:GetAttackTarget()
    if not J.IsValid(target) then target=attack end
    if J.IsValid(target) and J.CanBeAttacked(target) and J.IsInRange(bot,target,ability:GetCastRange())
        and not target:HasModifier(ice and 'modifier_jakiro_liquid_ice_debuff' or 'modifier_jakiro_liquid_fire_burn') then
        if J.IsValidBuilding(target) then
            if not ice and not target:HasModifier('modifier_fountain_glyph') and not target:HasModifier('modifier_backdoor_protection_active') then
                return BOT_ACTION_DESIRE_HIGH,target
            end
        elseif J.CanCastOnNonMagicImmune(target) and (J.IsGoingOnSomeone(bot) or J.IsInTeamFight(bot,1200)
            or J.IsLaning(bot) or J.IsPushing(bot) or J.IsDefending(bot) or J.IsDoingRoshan(bot) or J.IsDoingTormentor(bot)) then
            return BOT_ACTION_DESIRE_HIGH,target
        end
    end
    return 0,nil
end
return K
