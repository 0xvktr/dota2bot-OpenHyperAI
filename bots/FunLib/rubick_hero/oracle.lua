local X={}
local J=require(GetScriptDirectory()..'/FunLib/jmz_func')
local bot,abilityQ,abilityW,abilityE,abilityR,abilityD
local function Refresh()
    bot=GetBot();abilityQ=bot:GetAbilityByName('oracle_fortunes_end');abilityW=bot:GetAbilityByName('oracle_fates_edict')
    abilityE=bot:GetAbilityByName('oracle_purifying_flames');abilityR=bot:GetAbilityByName('oracle_false_promise')
    abilityD=bot:GetAbilityByName('oracle_rain_of_destiny')
end
local function SpellRange(ability)
    local range=ability:GetCastRange()
    local lens=J.IsItemAvailable('item_aether_lens')
    if lens~=nil then range=range+lens:GetSpecialValueInt('cast_range_bonus') end
    local supremacy=bot:GetAbilityByName('rubick_arcane_supremacy')
    if supremacy~=nil and supremacy:IsTrained() and not J.HasBreakModifier(bot) then range=range+supremacy:GetSpecialValueInt('cast_range') end
    return range
end
local function Allies(ability)
    local allies=J.GetNearbyHeroes(bot,math.min(SpellRange(ability),1600),false,BOT_MODE_NONE)
    allies[#allies+1]=bot;return allies
end
local function Ally(ally,ability)
    return J.IsValidHero(ally) and ally:GetTeam()==bot:GetTeam() and not ally:IsIllusion()
        and not ally:IsInvulnerable() and J.IsInRange(bot,ally,SpellRange(ability))
end
local function Enemy(enemy,ability)
    return J.IsValidHero(enemy) and not J.IsSuspiciousIllusion(enemy) and J.CanCastOnNonMagicImmune(enemy)
        and J.CanCastOnTargetAdvanced(enemy) and J.IsInRange(bot,enemy,SpellRange(ability))
end
local promise='modifier_oracle_false_promise_timer'
local flames='modifier_oracle_purifying_flames'
local edict='modifier_oracle_fates_edict'
function X.ConsiderR()
    if not J.CanCastAbility(abilityR) then return 0 end
    local best,score=nil,0
    for _,ally in ipairs(Allies(abilityR)) do
        if Ally(ally,abilityR) and not ally:HasModifier(promise) and not ally:HasModifier('modifier_abaddon_borrowed_time') then
            local threat=0
            for _,enemy in ipairs(J.GetNearbyHeroes(ally,1000,true,BOT_MODE_NONE)) do
                if J.IsValidHero(enemy) then threat=threat+enemy:GetEstimatedDamageToTarget(true,ally,2,DAMAGE_TYPE_ALL) end
            end
            local underAttack=ally:WasRecentlyDamagedByAnyHero(1.5) or J.IsUnitTargetProjectileIncoming(ally,500)
            if underAttack and (J.GetHP(ally)<0.35 or threat>=ally:GetHealth()*0.8)
                or J.IsDisabled(ally) and threat>=ally:GetHealth()*0.5 then
                local value=(1-J.GetHP(ally))*1000+threat+(J.IsCore(ally) and 200 or 0)
                if value>score then best,score=ally,value end
            end
        end
    end
    if best~=nil then return BOT_ACTION_DESIRE_HIGH,best end
    return 0
end
function X.ConsiderW()
    if not J.CanCastAbility(abilityW) then return 0 end
    local best,score=nil,0
    for _,ally in ipairs(Allies(abilityW)) do
        if Ally(ally,abilityW) and not ally:IsMagicImmune() and not ally:HasModifier(edict) then
            local magic=0
            for _,enemy in ipairs(J.GetNearbyHeroes(ally,1000,true,BOT_MODE_NONE)) do
                if J.IsValidHero(enemy) then
                    magic=magic+enemy:GetEstimatedDamageToTarget(true,ally,2,DAMAGE_TYPE_MAGICAL)
                end
            end
            if ally:HasModifier('modifier_necrolyte_reapers_scythe')
                or magic>=ally:GetHealth()*0.5 and (ally:WasRecentlyDamagedByAnyHero(1.5) or J.IsUnitTargetProjectileIncoming(ally,500)) then return BOT_ACTION_DESIRE_HIGH,ally end
            if J.CanCastAbility(abilityE) and J.IsInRange(bot,ally,SpellRange(abilityE))
                and bot:GetMana()>=abilityW:GetManaCost()+abilityE:GetManaCost()
                and not ally:HasModifier('modifier_ice_blast')
                and (ally:GetMaxHealth()-ally:GetHealth()>=abilityE:GetSpecialValueInt('total_heal_tooltip')*0.65 or ally:HasModifier(promise))
                and not J.IsAttacking(ally) and not ally:HasModifier(flames) then
                local value=ally:GetMaxHealth()-ally:GetHealth()+(ally:HasModifier(promise) and 1000 or 0)
                if value>score then best,score=ally,value end
            end
        end
    end
    if best~=nil then return BOT_ACTION_DESIRE_HIGH,best end
    for _,enemy in ipairs(J.GetNearbyHeroes(bot,math.min(SpellRange(abilityW),1600),true,BOT_MODE_NONE)) do
        if Enemy(enemy,abilityW) and not enemy:IsDisarmed() and not J.IsDisabled(enemy)
            and J.IsAttacking(enemy) and J.IsValidHero(enemy:GetAttackTarget())
            and enemy:GetAttackTarget():GetTeam()==bot:GetTeam() then
            local victim=enemy:GetAttackTarget()
            if J.GetHP(victim)<0.55 or J.IsRetreating(victim) then return BOT_ACTION_DESIRE_HIGH,enemy end
        end
    end
    return 0
end
function X.ConsiderQ()
    if not J.CanCastAbility(abilityQ) then return 0 end
    for _,ally in ipairs(Allies(abilityQ)) do
        if Ally(ally,abilityQ) and (ally:IsSilenced() or ally:IsRooted()
            or ally:HasModifier('modifier_item_spirit_vessel_damage')
            or ally:HasModifier('modifier_orchid_malevolence_debuff')
            or ally:HasModifier('modifier_bloodthorn_debuff')) then return BOT_ACTION_DESIRE_HIGH,ally,true end
    end
    for _,enemy in ipairs(J.GetNearbyHeroes(bot,math.min(SpellRange(abilityQ),1600),true,BOT_MODE_NONE)) do
        if Enemy(enemy,abilityQ) then
            if enemy:HasModifier(flames) or enemy:HasModifier('modifier_ember_spirit_flame_guard')
                or enemy:HasModifier('modifier_dark_seer_surge') or enemy:HasModifier('modifier_necrolyte_ghost_shroud') then return BOT_ACTION_DESIRE_HIGH,enemy,true end
            local travel=GetUnitToUnitDistance(bot,enemy)/abilityQ:GetSpecialValueInt('bolt_speed')
            if not J.CannotBeKilled(bot,enemy) and J.WillKillTarget(enemy,abilityQ:GetSpecialValueInt('damage'),DAMAGE_TYPE_MAGICAL,travel) then return BOT_ACTION_DESIRE_HIGH,enemy,true end
        end
    end
    local target=J.GetProperTarget(bot)
    if Enemy(target,abilityQ) and not J.IsDisabled(target) and (J.IsGoingOnSomeone(bot)
        or J.IsRetreating(bot) and J.IsChasingTarget(target,bot)) then return BOT_ACTION_DESIRE_HIGH,target,false end
    return 0
end
function X.ConsiderE()
    if not J.CanCastAbility(abilityE) then return 0 end
    local damage=abilityE:GetSpecialValueInt('damage')*abilityE:GetSpecialValueFloat('damage_modifier')
    for _,enemy in ipairs(J.GetNearbyHeroes(bot,math.min(SpellRange(abilityE),1600),true,BOT_MODE_NONE)) do
        if Enemy(enemy,abilityE) and not enemy:HasModifier(edict) and not J.CannotBeKilled(bot,enemy)
            and J.WillKillTarget(enemy,damage,DAMAGE_TYPE_MAGICAL,abilityE:GetCastPoint()) then return BOT_ACTION_DESIRE_HIGH,enemy end
    end
    local best,score=nil,0
    for _,ally in ipairs(Allies(abilityE)) do
        if Ally(ally,abilityE) and not ally:IsMagicImmune() and not ally:HasModifier('modifier_ice_blast') then
            local safe=ally:HasModifier(edict)
            local time=ally:HasModifier(promise) and J.GetModifierTime(ally,promise) or 0
            -- Heal only what can arrive before Promise settles; never assume ten future seconds at its end.
            local incoming=ally:GetActualIncomingDamage(abilityE:GetSpecialValueInt('damage'),DAMAGE_TYPE_MAGICAL)
            local netPromise=abilityE:GetSpecialValueInt('heal_per_second')*math.max(0,time-abilityE:GetCastPoint())*2-(safe and 0 or incoming)
            local missing=ally:GetMaxHealth()-ally:GetHealth()
            if (safe and (missing>=abilityE:GetSpecialValueInt('total_heal_tooltip')*0.65 or time>0.5)
                or time>0 and netPromise>=abilityE:GetSpecialValueInt('damage')*0.25) then
                local value=missing+(time>0 and 1000 or 0)
                if value>score then best,score=ally,value end
            end
        end
    end
    if best~=nil then return BOT_ACTION_DESIRE_HIGH,best end
    local target=J.GetProperTarget(bot)
    if J.IsGoingOnSomeone(bot) and Enemy(target,abilityE) and not target:HasModifier(edict)
        and not J.CannotBeKilled(bot,target) then
        local purge=not target:HasModifier(flames) and J.CanCastAbility(abilityQ) and J.IsInRange(bot,target,SpellRange(abilityQ))
            and bot:GetMana()>=abilityE:GetManaCost()+abilityQ:GetManaCost()
        for _,projectile in ipairs(target:GetIncomingTrackingProjectiles()) do
            if not projectile.is_attack and projectile.ability~=nil and projectile.ability:GetName()=='oracle_fortunes_end'
                and GetUnitToLocationDistance(target,projectile.location)/projectile.ability:GetSpecialValueInt('bolt_speed')>abilityE:GetCastPoint()+0.1 then purge=true end
        end
        if purge then return BOT_ACTION_DESIRE_HIGH,target end
    end
    if (J.IsLaning(bot) or J.IsFarming(bot) or J.IsPushing(bot) or J.IsDefending(bot))
        and J.IsAllowedToSpam(bot,abilityE:GetManaCost()) then
        for _,creep in ipairs(bot:GetNearbyLaneCreeps(math.min(SpellRange(abilityE),1600),true)) do
            if J.IsValid(creep) and J.CanCastOnNonMagicImmune(creep) and J.IsInRange(bot,creep,SpellRange(abilityE))
                and not creep:HasModifier('modifier_fountain_glyph') and not J.IsOtherAllysTarget(creep)
                and J.WillKillTarget(creep,damage,DAMAGE_TYPE_MAGICAL,abilityE:GetCastPoint()) then return BOT_ACTION_DESIRE_HIGH,creep end
        end
    end
    return 0
end
function X.ConsiderD()
    if not J.CanCastAbility(abilityD) then return 0 end
    local range,radius=SpellRange(abilityD),abilityD:GetSpecialValueInt('radius')
    local heroes=J.GetNearbyHeroes(bot,math.min(range+radius,1600),false,BOT_MODE_NONE)
    heroes[#heroes+1]=bot
    for _,enemy in ipairs(J.GetNearbyHeroes(bot,math.min(range+radius,1600),true,BOT_MODE_NONE)) do heroes[#heroes+1]=enemy end
    local best,score=nil,0
    for _,hero in ipairs(heroes) do
        if J.IsValidHero(hero) then
            local p=J.GetCorrectLoc(hero,abilityD:GetCastPoint())
            local delta=p-bot:GetLocation()
            if delta:Length2D()>range then p=bot:GetLocation()+delta:Normalized()*range end
            local value=0
            for _,other in ipairs(heroes) do
                if J.IsValidHero(other) and GetUnitToLocationDistance(other,p)<=radius then
                    if other:GetTeam()==bot:GetTeam() then
                        if not other:HasModifier('modifier_ice_blast') and (other:HasModifier(promise) or J.GetHP(other)<0.65) then value=value+1 end
                    elseif J.CanCastOnNonMagicImmune(other) and not J.IsSuspiciousIllusion(other) then value=value+1 end
                end
            end
            if value>score then best,score=p,value end
        end
    end
    if score>=2 and (J.IsInTeamFight(bot,1400) or J.IsGoingOnSomeone(bot)) then return BOT_ACTION_DESIRE_HIGH,best end
    return 0
end
function X.ConsiderFortuneRelease()
    if not bot:IsChanneling() then bot.oracleFortuneChannelStart=nil;return false end
    local active=bot:GetCurrentActiveAbility()
    if active==nil or active:GetName()~='oracle_fortunes_end' or bot:NumQueuedActions()>0 then return false end
    if bot.oracleFortuneTarget==nil then return false end
    if bot.oracleFortuneChannelStart==nil then bot.oracleFortuneChannelStart=DotaTime() end
    local elapsed=DotaTime()-bot.oracleFortuneChannelStart
    local save=X.ConsiderR()
    if save>0 or elapsed>=(bot.oracleFortuneInstant and 0.05 or active:GetSpecialValueFloat('channel_time')*0.5) then
        bot:Action_ClearActions(false);bot.oracleFortuneChannelStart=nil;bot.oracleFortuneTarget=nil;return true
    end
    return false
end

function X.ConsiderStolenFortuneRelease()
    local caster=GetBot()
    if not caster:IsChanneling() then return false end
    local active=caster:GetCurrentActiveAbility()
    if active==nil or active:GetName()~='oracle_fortunes_end' then return false end
    Refresh();return X.ConsiderFortuneRelease()
end
function X.ConsiderStolenSpell(ability)
    local name=ability:GetName()
    if name~='oracle_fortunes_end' and name~='oracle_fates_edict' and name~='oracle_purifying_flames'
        and name~='oracle_false_promise' and name~='oracle_rain_of_destiny' then return nil end
    Refresh()
    if X.ConsiderFortuneRelease() then return true end
    if J.CanNotUseAbility(bot) or not J.CanCastAbility(ability) then return false end
    local choices={oracle_fortunes_end=X.ConsiderQ,oracle_fates_edict=X.ConsiderW,
        oracle_purifying_flames=X.ConsiderE,oracle_false_promise=X.ConsiderR,oracle_rain_of_destiny=X.ConsiderD}
    local desire,target,instant=choices[name]()
    if desire<=0 then return false end
    if name=='oracle_rain_of_destiny' then bot:Action_UseAbilityOnLocation(ability,target)
    else
        if name=='oracle_fortunes_end' then bot.oracleFortuneTarget=target;bot.oracleFortuneInstant=instant;bot.oracleFortuneChannelStart=nil end
        bot:Action_UseAbilityOnEntity(ability,target)
    end
    return true
end
return X
