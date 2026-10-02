local X={}
local J=require(GetScriptDirectory()..'/FunLib/jmz_func')
local bot,Impale,Mindflare,SpikedCarapace,Burrow,UnBurrow,Vendetta
local function Refresh()
    bot=GetBot()
    Impale=bot:GetAbilityByName('nyx_assassin_impale');Mindflare=bot:GetAbilityByName('nyx_assassin_jolt')
    SpikedCarapace=bot:GetAbilityByName('nyx_assassin_spiked_carapace');Burrow=bot:GetAbilityByName('nyx_assassin_burrow')
    UnBurrow=bot:GetAbilityByName('nyx_assassin_unburrow');Vendetta=bot:GetAbilityByName('nyx_assassin_vendetta')
end
local function SpellRange(ability)
    local range = ability:GetCastRange()
    local lens = J.IsItemAvailable('item_aether_lens')
    if lens ~= nil then range = range + lens:GetSpecialValueInt('cast_range_bonus') end
    if bot:HasModifier('modifier_nyx_assassin_burrow') and Burrow~=nil
        and (ability==Impale or ability==Mindflare) then range=range+Burrow:GetSpecialValueInt('cast_range') end
    local supremacy=bot:GetAbilityByName('rubick_arcane_supremacy')
    if supremacy~=nil and supremacy:IsTrained() and not J.HasBreakModifier(bot) then range=range+supremacy:GetSpecialValueInt('cast_range') end
    return range
end
local function Enemy(enemy)
    return J.IsValidHero(enemy) and not J.IsSuspiciousIllusion(enemy) and J.CanCastOnNonMagicImmune(enemy)
end
local function ImpaleLocation(enemy)
    local range = SpellRange(Impale)
    local delay = Impale:GetCastPoint() + GetUnitToUnitDistance(bot, enemy) / Impale:GetSpecialValueInt('speed')
    local location = J.GetCorrectLoc(enemy, delay)
    if GetUnitToLocationDistance(bot, location) <= range then return location end
    return nil
end
local function LineHits(unit, location)
    local start = bot:GetLocation()
    local dx,dy = location.x-start.x,location.y-start.y
    local length = math.sqrt(dx*dx+dy*dy)
    if length == 0 then return false end
    local delay=Impale:GetCastPoint()+GetUnitToUnitDistance(bot,unit)/Impale:GetSpecialValueInt('speed')
    local p=J.GetCorrectLoc(unit,delay)
    local ux,uy=p.x-start.x,p.y-start.y
    local forward=(ux*dx+uy*dy)/length
    local side=math.abs(ux*dy-uy*dx)/length
    return forward>=0 and forward<=SpellRange(Impale) and side<=Impale:GetSpecialValueInt('width')
end
function X.ConsiderImpale()
    if not J.CanCastAbility(Impale) then return 0 end
    local enemies=J.GetNearbyHeroes(bot,math.min(SpellRange(Impale),1600),true,BOT_MODE_NONE)
    for _,enemy in ipairs(enemies) do
        if Enemy(enemy) and enemy:IsChanneling() then
            local location=ImpaleLocation(enemy)
            if location~=nil then return BOT_ACTION_DESIRE_HIGH,location end
        end
    end
    if bot:HasModifier('modifier_nyx_assassin_vendetta') then return 0 end
    for _,enemy in ipairs(enemies) do
        if Enemy(enemy) then
            local location=ImpaleLocation(enemy)
            if location~=nil and J.CanKillTarget(enemy,Impale:GetSpecialValueInt('impale_damage'),DAMAGE_TYPE_MAGICAL)
                and not J.CannotBeKilled(bot,enemy) then return BOT_ACTION_DESIRE_HIGH,location end
        end
    end
    if J.IsInTeamFight(bot,1200) then
        for _,enemy in ipairs(enemies) do
            if Enemy(enemy) then
                local location=ImpaleLocation(enemy)
                if location~=nil then
                    local hits=0
                    for _,other in ipairs(enemies) do if Enemy(other) and LineHits(other,location) then hits=hits+1 end end
                    if hits>=2 then return BOT_ACTION_DESIRE_HIGH,location end
                end
            end
        end
    end
    local target=J.GetProperTarget(bot)
    if J.IsGoingOnSomeone(bot) and Enemy(target) and not J.IsDisabled(target) then
        local location=ImpaleLocation(target)
        if location~=nil then return BOT_ACTION_DESIRE_HIGH,location end
    end
    for _,enemy in ipairs(enemies) do
        if Enemy(enemy) and not J.IsDisabled(enemy) and J.IsRetreating(bot)
            and bot:WasRecentlyDamagedByAnyHero(2) and J.IsChasingTarget(enemy,bot) then
            local location=ImpaleLocation(enemy)
            if location~=nil then return BOT_ACTION_DESIRE_HIGH,location end
        end
    end
    if (J.IsFarming(bot) or J.IsPushing(bot) or J.IsDefending(bot) or J.IsLaning(bot))
        and J.IsAllowedToSpam(bot,Impale:GetManaCost()) then
        local creeps=bot:GetNearbyCreeps(math.min(SpellRange(Impale),1600),true)
        for _,creep in ipairs(creeps) do
            if J.IsValid(creep) and J.CanCastOnNonMagicImmune(creep) then
                local location=ImpaleLocation(creep)
                if location~=nil then
                    local hit,kills=0,0
                    for _,other in ipairs(creeps) do
                        if J.IsValid(other) and J.CanCastOnNonMagicImmune(other) and LineHits(other,location) then
                            hit=hit+1
                            if J.CanKillTarget(other,Impale:GetSpecialValueInt('impale_damage'),DAMAGE_TYPE_MAGICAL) then kills=kills+1 end
                        end
                    end
                    if kills>=2 or not J.IsLaning(bot) and hit>=3 then return BOT_ACTION_DESIRE_HIGH,location end
                end
            end
        end
    end
    return 0
end
function X.ConsiderMindflare()
    if not J.CanCastAbility(Mindflare) or bot:HasModifier('modifier_nyx_assassin_vendetta') then return 0 end
    local range=SpellRange(Mindflare)
    for _,enemy in ipairs(J.GetNearbyHeroes(bot,math.min(range,1600),true,BOT_MODE_NONE)) do
        if Enemy(enemy) and J.IsInRange(bot,enemy,range) and J.CanCastOnTargetAdvanced(enemy)
            and not J.CannotBeKilled(bot,enemy) then
            local damage=enemy:GetMaxMana()*Mindflare:GetSpecialValueInt('max_mana_as_damage_pct')/100
            if J.CanKillTarget(enemy,damage,DAMAGE_TYPE_MAGICAL) then return BOT_ACTION_DESIRE_HIGH,enemy end
        end
    end
    local target=J.GetProperTarget(bot)
    if J.IsInTeamFight(bot,1200) and not Enemy(target) then
        local best,score=nil,0
        local radius=Mindflare:GetSpecialValueInt('aoe')
        local enemies=J.GetNearbyHeroes(bot,math.min(range+radius,1600),true,BOT_MODE_NONE)
        for _,enemy in ipairs(enemies) do
            if Enemy(enemy) and J.IsInRange(bot,enemy,range) and J.CanCastOnTargetAdvanced(enemy) then
                local value=enemy:GetMaxMana()
                for _,other in ipairs(enemies) do
                    if other~=enemy and Enemy(other) and J.IsInRange(enemy,other,radius) then value=value+other:GetMaxMana() end
                end
                if value>score then best,score=enemy,value end
            end
        end
        target=best
    end
    if (J.IsGoingOnSomeone(bot) or J.IsInTeamFight(bot,1200)) and Enemy(target)
        and J.IsInRange(bot,target,range) and J.CanCastOnTargetAdvanced(target)
        and not J.CannotBeKilled(bot,target) then
        -- Max-mana damage is safe to estimate. The echo needs source-attributed damage unavailable here.
        if J.CanCastAbility(Impale) and not J.IsDisabled(target) and ImpaleLocation(target)~=nil then return 0 end
        for i=1,5 do
            local item=J.IsItemAvailable(i==1 and 'item_dagon' or 'item_dagon_'..i)
            if item~=nil and item:IsFullyCastable() and J.IsDisabled(target) and J.IsInRange(bot,target,SpellRange(item)) then return 0 end
        end
        return BOT_ACTION_DESIRE_HIGH,target
    end
    return 0
end
function X.ConsiderSpikedCarapace()
    if not J.CanCastAbility(SpikedCarapace) or bot:HasModifier('modifier_nyx_assassin_spiked_carapace') then return 0 end
    if bot:HasModifier('modifier_nyx_assassin_burrow') and Burrow~=nil then
        local radius=Burrow:GetSpecialValueInt('carapace_radius')
        for _,enemy in ipairs(J.GetNearbyHeroes(bot,math.min(radius,1600),true,BOT_MODE_NONE)) do
            if Enemy(enemy) and J.IsInRange(bot,enemy,radius) and not J.IsDisabled(enemy) then return BOT_ACTION_DESIRE_HIGH end
        end
    end
    if J.IsUnitTargetProjectileIncoming(bot,400) or J.IsWillBeCastUnitTargetSpell(bot,1200)
        or bot:WasRecentlyDamagedByAnyHero(0.5) and #J.GetNearbyHeroes(bot,800,true,BOT_MODE_NONE)>0 then return BOT_ACTION_DESIRE_HIGH end
    return 0
end
function X.ConsiderBurrow()
    if not J.CanCastAbility(Burrow) or bot:HasModifier('modifier_nyx_assassin_burrow')
        or bot:HasModifier('modifier_nyx_assassin_vendetta') or J.IsRetreating(bot)
        or not (J.IsInTeamFight(bot,1400) or J.IsDefending(bot)) then return 0 end
    if J.GetHP(bot)<0.4 or #J.GetNearbyHeroes(bot,350,true,BOT_MODE_NONE)>0 then return 0 end
    if not J.CanCastAbility(Impale) and not J.CanCastAbility(Mindflare) then return 0 end
    local range=J.CanCastAbility(Impale) and SpellRange(Impale) or SpellRange(Mindflare)
    range=range+Burrow:GetSpecialValueInt('cast_range')
    for _,enemy in ipairs(J.GetNearbyHeroes(bot,math.min(range,1600),true,BOT_MODE_NONE)) do
        if Enemy(enemy) and J.IsInRange(bot,enemy,range) then return BOT_ACTION_DESIRE_HIGH end
    end
    return 0
end
function X.ConsiderUnBurrow()
    if not J.CanCastAbility(UnBurrow) or not bot:HasModifier('modifier_nyx_assassin_burrow') then return 0 end
    if J.IsRetreating(bot) then return BOT_ACTION_DESIRE_HIGH end
    local range=0
    if Impale~=nil then range=math.max(range,SpellRange(Impale)) end
    if Mindflare~=nil then range=math.max(range,SpellRange(Mindflare)) end
    if #J.GetNearbyHeroes(bot,math.min(range,1600),true,BOT_MODE_NONE)==0 then return BOT_ACTION_DESIRE_HIGH end
    return 0
end
function X.ConsiderVendetta()
    if not J.CanCastAbility(Vendetta) or J.IsRealInvisible(bot) then return 0 end
    bot.canVendettaKill=false;bot.vendettaTarget=nil
    if J.IsRetreating(bot) and bot:WasRecentlyDamagedByAnyHero(3) then return BOT_ACTION_DESIRE_HIGH end
    if bot:IsDisarmed() then return 0 end
    local target=J.GetProperTarget(bot)
    if J.IsGoingOnSomeone(bot) and J.IsValidHero(target) and not J.IsSuspiciousIllusion(target)
        and J.CanBeAttacked(target) and J.IsInRange(bot,target,2200)
        and not J.CannotBeKilled(bot,target) then
        local pure=Vendetta:GetSpecialValueInt('bonus_damage')
        if J.CanKillTarget(target,pure,DAMAGE_TYPE_PURE) then bot.canVendettaKill=true;bot.vendettaTarget=target end
        return BOT_ACTION_DESIRE_HIGH
    end
    return 0
end

function X.ConsiderStolenSpell(ability)
    local name=ability:GetName()
    if name~='nyx_assassin_impale' and name~='nyx_assassin_jolt' and name~='nyx_assassin_spiked_carapace'
        and name~='nyx_assassin_burrow' and name~='nyx_assassin_unburrow' and name~='nyx_assassin_vendetta' then return nil end
    Refresh()
    if J.CanNotUseAbility(bot) or bot:IsChanneling() then return false end
    local desire,target
    if name=='nyx_assassin_impale' then Impale=ability;desire,target=X.ConsiderImpale()
    elseif name=='nyx_assassin_jolt' then Mindflare=ability;desire,target=X.ConsiderMindflare()
    elseif name=='nyx_assassin_spiked_carapace' then SpikedCarapace=ability;desire=X.ConsiderSpikedCarapace()
    elseif name=='nyx_assassin_burrow' then Burrow=ability;desire=X.ConsiderBurrow()
    elseif name=='nyx_assassin_unburrow' then UnBurrow=ability;desire=X.ConsiderUnBurrow()
    else Vendetta=ability;desire=X.ConsiderVendetta() end
    if desire>0 then
        if name=='nyx_assassin_impale' then bot:Action_UseAbilityOnLocation(ability,target)
        elseif name=='nyx_assassin_jolt' then bot:Action_UseAbilityOnEntity(ability,target)
        else bot:Action_UseAbility(ability) end
        return true
    end
    return false
end
return X
