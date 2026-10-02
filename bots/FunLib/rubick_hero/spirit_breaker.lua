local X={}
local J=require(GetScriptDirectory()..'/FunLib/jmz_func')
local bot=GetBot()
function X.Range(ability)
    local range=ability:GetCastRange()
    local lens=J.IsItemAvailable('item_aether_lens')
    if lens~=nil then range=range+lens:GetSpecialValueInt('cast_range_bonus') end
    local supremacy=bot:GetAbilityByName('rubick_arcane_supremacy')
    if supremacy~=nil and not supremacy:IsNull() and supremacy:IsTrained() and not J.HasBreakModifier(bot) then range=range+supremacy:GetSpecialValueInt('cast_range') end
    return range
end
local function MobilityBlocked()
    return bot:IsRooted() or bot:HasModifier('modifier_bloodseeker_rupture') or bot:HasModifier('modifier_puck_coiled')
end
local function Enemy(unit,immune)
    return J.IsValidHero(unit) and (immune and J.CanCastOnMagicImmune(unit) or J.CanCastOnNonMagicImmune(unit))
        and not J.IsSuspiciousIllusion(unit) and not J.CannotBeKilled(bot,unit)
        and J.CanCastOnTargetAdvanced(unit) and not unit:HasModifier('modifier_item_blade_mail_reflect')
        and not unit:HasModifier('modifier_nyx_assassin_spiked_carapace')
end
local function Safe(point)
    return not J.IsLocationInChrono(point) and not J.IsLocationInBlackHole(point) and not J.IsLocHaveTower(700,true,point)
        and #J.GetEnemiesNearLoc(point,1000)<=#J.GetAlliesNearLoc(point,1000)+1
end
local function Bash()
    local ability=bot:GetAbilityByName('spirit_breaker_greater_bash')
    if ability~=nil and not ability:IsNull() and ability:IsTrained() then return ability end
    return nil
end
function X.IsCharging()
    bot=GetBot()
    if bot:HasModifier('modifier_spirit_breaker_charge_of_darkness') then return true end
    local ability=bot:GetAbilityByName('spirit_breaker_charge_of_darkness')
    return ability~=nil and not ability:IsNull() and ability:IsInAbilityPhase()
end
function X.UseChargeSupport()
    bot=GetBot()
    if not bot:HasModifier('modifier_spirit_breaker_charge_of_darkness') then return false end
    local charge=bot:GetAbilityByName('spirit_breaker_charge_of_darkness')
    local index=bot:GetModifierByName('modifier_spirit_breaker_charge_of_darkness')
    local source=index>=0 and bot:GetModifierSourceAbility(index) or nil
    if charge==nil or charge:IsNull() or source~=charge or source:GetCaster()~=bot
        or not bot:IsAlive() or bot:IsStunned() or bot:IsHexed() or bot:IsNightmared() or bot:IsSilenced()
        or bot:IsInvulnerable() or bot:IsChanneling() or bot:IsCastingAbility() or J.HasQueuedAction(bot)
        or bot:HasModifier('modifier_ringmaster_the_box_buff') or bot:HasModifier('modifier_doom_bringer_doom')
        or bot:HasModifier('modifier_item_forcestaff_active') then return false end
    if bot.spiritBreakerEscapeStart~=nil and #J.GetNearbyHeroes(bot,900,true,BOT_MODE_NONE)==0
        and (bot:GetLocation()-bot.spiritBreakerEscapeStart):Length2D()>800
        and GetUnitToLocationDistance(bot,J.GetEscapeLoc())+600<(bot.spiritBreakerEscapeStart-J.GetEscapeLoc()):Length2D() then
        bot:Action_ClearActions(true);bot.spiritBreakerEscapeStart=nil;return true
    end
    local bulldoze=bot:GetAbilityByName('spirit_breaker_bulldoze')
    if J.CanCastAbility(bulldoze) and not bot:HasModifier('modifier_spirit_breaker_bulldoze') then
        bot:Action_UseAbility(bulldoze);return true
    end
    return false
end
function X.ConsiderBulldoze()
    local ability=bot:GetAbilityByName('spirit_breaker_bulldoze')
    if not J.CanCastAbility(ability) or bot:HasModifier('modifier_spirit_breaker_bulldoze') then return 0 end
    if bot:WasRecentlyDamagedByAnyHero(1.5) and #J.GetNearbyHeroes(bot,900,true,BOT_MODE_NONE)>0 then return BOT_ACTION_DESIRE_HIGH end
    for _, enemy in pairs(J.GetNearbyHeroes(bot,900,true,BOT_MODE_NONE)) do
        if J.IsValidHero(enemy) and not J.IsSuspiciousIllusion(enemy) and J.IsChasingTarget(enemy,bot) and J.IsRetreating(bot) then return BOT_ACTION_DESIRE_HIGH end
    end
    return 0
end
function X.ConsiderChargeOfDarkness()
    local ability=bot:GetAbilityByName('spirit_breaker_charge_of_darkness')
    if not J.CanCastAbility(ability) or X.IsCharging() or MobilityBlocked() then return 0 end
    if J.IsRetreating(bot) and J.GetHP(bot)<0.5 and #J.GetNearbyHeroes(bot,600,true,BOT_MODE_NONE)>0 then
        local best,distance
        for _, kind in ipairs({UNIT_LIST_ENEMY_CREEPS,UNIT_LIST_NEUTRAL_CREEPS}) do
            for _, creep in pairs(GetUnitList(kind)) do
                if J.IsValid(creep) and J.CanCastOnNonMagicImmune(creep) and GetUnitToUnitDistance(bot,creep)>1600 and Safe(creep:GetLocation()) then
                    local escape=GetUnitToLocationDistance(creep,J.GetEscapeLoc())
                    if escape+1000<GetUnitToLocationDistance(bot,J.GetEscapeLoc()) and (distance==nil or escape<distance) then best,distance=creep,escape end
                end
            end
        end
        if best~=nil then return BOT_ACTION_DESIRE_HIGH,best,true end
    end
    local best,score
    for _, enemy in pairs(GetUnitList(UNIT_LIST_ENEMY_HEROES)) do
        if Enemy(enemy,false) and Safe(enemy:GetLocation()) then
            local supported=false
            for _, ally in pairs(GetUnitList(UNIT_LIST_ALLIED_HEROES)) do
                if ally~=bot and J.IsValidHero(ally) and not ally:IsIllusion() and ally:GetAttackTarget()==enemy
                    and GetUnitToUnitDistance(ally,enemy)<1200 then supported=true;break end
            end
            local interrupt=enemy:IsChanneling()
            if interrupt and enemy:HasModifier('modifier_teleporting') then
                local index=enemy:GetModifierByName('modifier_teleporting')
                local arrival=ability:GetCastPoint()+ability:GetSpecialValueFloat('windup_time')
                    +GetUnitToUnitDistance(bot,enemy)/(bot:GetCurrentMovementSpeed()+ability:GetSpecialValueInt('movement_speed'))
                interrupt=index>=0 and enemy:GetModifierRemainingDuration(index)>arrival
            end
            if interrupt or supported or J.IsGoingOnSomeone(bot) and enemy==J.GetProperTarget(bot) and GetUnitToUnitDistance(bot,enemy)>250 then
                local line=0
                local direction=(enemy:GetLocation()-bot:GetLocation()):Normalized()
                if Bash()~=nil then
                    for _, other in pairs(GetUnitList(UNIT_LIST_ENEMY_HEROES)) do
                        if Enemy(other,false) then
                            local offset=other:GetLocation()-bot:GetLocation()
                            local along=offset.x*direction.x+offset.y*direction.y
                            if along>=0 and along<=GetUnitToUnitDistance(bot,enemy)
                                and math.abs(offset.x*direction.y-offset.y*direction.x)<=ability:GetSpecialValueInt('bash_radius') then line=line+1 end
                        end
                    end
                end
                local value=(interrupt and 10000 or 0)+(supported and 1000 or 0)+line*100+GetUnitToUnitDistance(bot,enemy)/100
                if score==nil or value>score then best,score=enemy,value end
            end
        end
    end
    if best~=nil then return BOT_ACTION_DESIRE_HIGH,best,false end
    if (J.IsFarming(bot) or J.IsPushing(bot) or J.IsDefending(bot)) and J.GetMP(bot)>0.35 and Bash()~=nil then
        local creeps=bot:GetNearbyLaneCreeps(1600,true)
        if #creeps<3 and J.IsFarming(bot) then creeps=bot:GetNearbyNeutralCreeps(1600) end
        local farthest,reach
        for _, creep in pairs(creeps) do
            if J.IsValid(creep) and J.CanCastOnNonMagicImmune(creep) and Safe(creep:GetLocation()) then
                local distance=GetUnitToUnitDistance(bot,creep)
                local direction=(creep:GetLocation()-bot:GetLocation()):Normalized()
                local hits=0
                for _, other in pairs(creeps) do
                    local offset=other:GetLocation()-bot:GetLocation()
                    local along=offset.x*direction.x+offset.y*direction.y
                    if J.IsValid(other) and along>=0 and along<=distance and math.abs(offset.x*direction.y-offset.y*direction.x)<=ability:GetSpecialValueInt('bash_radius') then hits=hits+1 end
                end
                if hits>=3 and (reach==nil or distance>reach) then farthest,reach=creep,distance end
            end
        end
        if farthest~=nil then return BOT_ACTION_DESIRE_HIGH,farthest,false end
    end
    return 0
end
function X.ConsiderNetherStrike()
    local ability=bot:GetAbilityByName('spirit_breaker_nether_strike')
    if not J.CanCastAbility(ability) or MobilityBlocked() then return 0 end
    local bash=Bash()
    local damage=ability:GetSpecialValueInt('damage')+(bash~=nil and bot:GetCurrentMovementSpeed()*bash:GetSpecialValueInt('damage')/100 or 0)
    for _, enemy in pairs(J.GetNearbyHeroes(bot,math.min(1600,X.Range(ability)),true,BOT_MODE_NONE)) do
        if Enemy(enemy,true) and GetUnitToUnitDistance(bot,enemy)<=X.Range(ability) and Safe(enemy:GetLocation()) then
            local interrupt=enemy:IsChanneling() and bash~=nil
            if interrupt and enemy:HasModifier('modifier_teleporting') then
                local index=enemy:GetModifierByName('modifier_teleporting')
                interrupt=index>=0 and enemy:GetModifierRemainingDuration(index)>ability:GetCastPoint()
            end
            if interrupt or J.WillKillTarget(enemy,damage,DAMAGE_TYPE_MAGICAL,ability:GetCastPoint())
                or J.IsGoingOnSomeone(bot) and enemy==J.GetProperTarget(bot) and not J.IsDisabled(enemy) then return BOT_ACTION_DESIRE_HIGH,enemy end
        end
    end
    return 0
end
function X.ConsiderPlanarPocket()
    local ability=bot:GetAbilityByName('spirit_breaker_planar_pocket')
    if not J.CanCastAbility(ability) or J.GetHP(bot)<0.55 or bot:HasModifier('modifier_spirit_breaker_planar_pocket') then return 0 end
    local candidates={bot}
    for _, ally in pairs(J.GetNearbyHeroes(bot,math.min(1600,X.Range(ability)),false,BOT_MODE_NONE)) do candidates[#candidates+1]=ally end
    for _, ally in ipairs(candidates) do
        if J.IsValidHero(ally) and not ally:IsIllusion() and not ally:IsInvulnerable() and not ally:HasModifier('modifier_spirit_breaker_planar_pocket_aura')
            and GetUnitToUnitDistance(bot,ally)<=X.Range(ability)
            and GetUnitToUnitDistance(bot,ally)<=ability:GetSpecialValueInt('break_distance')
            and (J.IsUnitTargetProjectileIncoming(ally,800) or J.GetHP(ally)<0.5 and ally:WasRecentlyDamagedByAnyHero(1.5)
                and #J.GetNearbyHeroes(ally,900,true,BOT_MODE_NONE)>0) then return BOT_ACTION_DESIRE_HIGH,ally end
    end
    return 0
end
local decisions={spirit_breaker_charge_of_darkness=X.ConsiderChargeOfDarkness,spirit_breaker_bulldoze=X.ConsiderBulldoze,
    spirit_breaker_nether_strike=X.ConsiderNetherStrike,spirit_breaker_planar_pocket=X.ConsiderPlanarPocket}
local function Cast(ability,target,escape)
    J.SetQueuePtToINT(bot,true,ability)
    if ability:GetName()=='spirit_breaker_bulldoze' then bot:ActionQueue_UseAbility(ability)
    else bot:ActionQueue_UseAbilityOnEntity(ability,target) end
    if ability:GetName()=='spirit_breaker_charge_of_darkness' then bot.spiritBreakerEscapeStart=escape and bot:GetLocation() or nil end
end
function X.ConsiderStolenSpell(ability)
    local name=ability:GetName()
    if decisions[name]==nil then return nil end
    bot=GetBot()
    if J.CanNotUseAbility(bot) or X.IsCharging() or not J.CanCastAbility(ability) then return false end
    local desire,target,escape=decisions[name]()
    if desire<=0 then return false end
    Cast(ability,target,escape);return true
end
function X.UseNative()
    bot=GetBot()
    if X.UseChargeSupport() then return true end
    if J.CanNotUseAbility(bot) or X.IsCharging() then return false end
    for _, name in ipairs({'spirit_breaker_planar_pocket','spirit_breaker_nether_strike','spirit_breaker_bulldoze','spirit_breaker_charge_of_darkness'}) do
        local ability=bot:GetAbilityByName(name)
        if J.CanCastAbility(ability) then
            local desire,target,escape=decisions[name]()
            if desire>0 then
                if name=='spirit_breaker_charge_of_darkness' then
                    local bulldoze=bot:GetAbilityByName('spirit_breaker_bulldoze')
                    if J.CanCastAbility(bulldoze) and not bot:HasModifier('modifier_spirit_breaker_bulldoze')
                        and bot:GetMana()>=ability:GetManaCost()+bulldoze:GetManaCost() then Cast(bulldoze);return true end
                end
                Cast(ability,target,escape);return true
            end
        end
    end
    return false
end
return X
