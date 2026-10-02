local X={}
local J=require(GetScriptDirectory()..'/FunLib/jmz_func')
local bot=GetBot()
function X.Range(a)
    local range=a:GetCastRange()
    local lens=J.IsItemAvailable('item_aether_lens')
    if lens~=nil then range=range+lens:GetSpecialValueInt('cast_range_bonus') end
    local supremacy=bot:GetAbilityByName('rubick_arcane_supremacy')
    if supremacy~=nil and not supremacy:IsNull() and supremacy:IsTrained() and not J.HasBreakModifier(bot) then range=range+supremacy:GetSpecialValueInt('cast_range') end
    return range
end
local function Enemy(u,unit)
    return J.IsValidHero(u) and J.CanCastOnNonMagicImmune(u) and not J.IsSuspiciousIllusion(u) and not J.CannotBeKilled(bot,u)
        and (not unit or J.CanCastOnTargetAdvanced(u)) and not u:HasModifier('modifier_nyx_assassin_spiked_carapace')
end
local function Safe(p)
    return IsLocationPassable(p) and not J.IsLocationInChrono(p) and not J.IsLocationInBlackHole(p)
        and not J.IsLocHaveTower(700,true,p) and #J.GetEnemiesNearLoc(p,1000)<=#J.GetAlliesNearLoc(p,1000)+1
end
local function PointRemnant(a)
    return J.CheckBitfieldFlag(a:GetBehavior(),ABILITY_BEHAVIOR_POINT) or a:GetSpecialValueInt('is_point_targeted')>0
end
function X.ConsiderStaticRemnant()
    local a=bot:GetAbilityByName('storm_spirit_static_remnant')
    if not J.CanCastAbility(a) then return 0 end
    local point=PointRemnant(a)
    local radius=a:GetSpecialValueInt('static_remnant_radius')
    local range=point and X.Range(a) or 0
    for _,u in pairs(J.GetNearbyHeroes(bot,math.min(1600,range+radius),true,BOT_MODE_NONE)) do
        if Enemy(u,false) then
            local delay=a:GetCastPoint()+a:GetSpecialValueFloat('static_remnant_delay')
            if point then delay=delay+GetUnitToUnitDistance(bot,u)/a:GetSpecialValueInt('static_remnant_travel_speed') end
            local predicted=J.GetCorrectLoc(u,delay)
            local p=point and predicted or bot:GetLocation()
            if point and GetUnitToLocationDistance(bot,p)>range then p=bot:GetLocation()+(p-bot:GetLocation()):Normalized()*range end
            if (predicted-p):Length2D()<=radius
                and (J.WillKillTarget(u,a:GetSpecialValueInt('static_remnant_damage'),DAMAGE_TYPE_MAGICAL,delay)
                    or J.IsGoingOnSomeone(bot) and u==J.GetProperTarget(bot)
                    or J.IsRetreating(bot) and J.IsChasingTarget(u,bot)) then return BOT_ACTION_DESIRE_HIGH,p,point end
        end
    end
    if (J.IsFarming(bot) or J.IsPushing(bot) or J.IsDefending(bot)) and J.GetMP(bot)>0.3 then
        local creeps=bot:GetNearbyLaneCreeps(math.min(1600,range+radius),true)
        if #creeps<2 and J.IsFarming(bot) then creeps=bot:GetNearbyNeutralCreeps(math.min(1600,range+radius)) end
        for _,u in ipairs(creeps) do
            if J.IsValid(u) and J.CanCastOnNonMagicImmune(u) then
                local p=point and u:GetLocation() or bot:GetLocation()
                if GetUnitToLocationDistance(bot,p)<=range then
                    local hits=0
                    for _,other in ipairs(creeps) do if J.IsValid(other) and J.CanCastOnNonMagicImmune(other) and GetUnitToLocationDistance(other,p)<=radius then hits=hits+1 end end
                    if hits>=2 or hits==1 and u:IsAncientCreep() then return BOT_ACTION_DESIRE_HIGH,p,point end
                end
            end
        end
    end
    local target=J.GetProperTarget(bot)
    if (J.IsDoingRoshan(bot) or J.IsDoingTormentor(bot)) and J.IsValid(target) and J.CanBeAttacked(target)
        and GetUnitToUnitDistance(bot,target)<=range+radius then
        local p=point and target:GetLocation() or bot:GetLocation()
        if GetUnitToLocationDistance(bot,p)>range then p=bot:GetLocation()+(p-bot:GetLocation()):Normalized()*range end
        return BOT_ACTION_DESIRE_HIGH,p,point
    end
    return 0
end
function X.ConsiderElectricVortex()
    local a=bot:GetAbilityByName('storm_spirit_electric_vortex')
    if not J.CanCastAbility(a) then return 0 end
    local aoe=bot:HasScepter()
    local range=aoe and a:GetSpecialValueInt('radius_scepter') or X.Range(a)
    local count=0
    for _,u in pairs(J.GetNearbyHeroes(bot,math.min(1600,range),true,BOT_MODE_NONE)) do
        if Enemy(u,not aoe) and GetUnitToUnitDistance(bot,u)<=range then
            count=count+1
            local interrupt=u:IsChanneling()
            if interrupt and u:HasModifier('modifier_teleporting') then
                local i=u:GetModifierByName('modifier_teleporting');interrupt=i>=0 and u:GetModifierRemainingDuration(i)>a:GetCastPoint()
            end
            if interrupt or J.IsGoingOnSomeone(bot) and u==J.GetProperTarget(bot) and not J.IsDisabled(u)
                or J.IsRetreating(bot) and J.IsChasingTarget(u,bot) then return BOT_ACTION_DESIRE_HIGH,u,aoe end
        end
    end
    if aoe and count>=2 then return BOT_ACTION_DESIRE_HIGH,nil,true end
    return 0
end
function X.ConsiderOverload(a)
    a=a or bot:GetAbilityByName('storm_spirit_electric_rave')
    if not J.CanCastAbility(a) or J.HasBreakModifier(bot) or bot:HasModifier('modifier_storm_spirit_electric_rave') then return 0 end
    local radius=a:GetSpecialValueInt(a:GetName()=='storm_spirit_electric_rave' and 'radius' or 'shard_activation_radius')
    local candidates={bot}
    for _,ally in pairs(J.GetNearbyHeroes(bot,math.min(1600,radius),false,BOT_MODE_NONE)) do candidates[#candidates+1]=ally end
    for _,ally in ipairs(candidates) do
        local target=ally:GetAttackTarget()
        if J.IsValidHero(ally) and not ally:IsIllusion() and not ally:IsDisarmed() and Enemy(target,false) and J.CanBeAttacked(target)
            and GetUnitToUnitDistance(ally,target)<=ally:GetAttackRange()+100
            and not ally:HasModifier('modifier_storm_spirit_electric_rave') then return BOT_ACTION_DESIRE_HIGH end
    end
    return 0
end
function X.BallCost(a,distance)
    return a:GetSpecialValueInt('ball_lightning_initial_mana_base')+a:GetSpecialValueFloat('ball_lightning_initial_mana_percentage')*bot:GetMaxMana()/100
        +(a:GetSpecialValueInt('ball_lightning_travel_cost_base')+a:GetSpecialValueFloat('ball_lightning_travel_cost_percent')*bot:GetMaxMana()/100)*distance/100
end
function X.ConsiderBallLightning()
    local a=bot:GetAbilityByName('storm_spirit_ball_lightning')
    if not J.CanCastAbility(a) or bot:IsRooted() or bot:HasModifier('modifier_storm_spirit_ball_lightning') or a:IsInAbilityPhase()
        or bot:HasModifier('modifier_puck_coiled') then return 0 end
    if J.IsStuck(bot) or J.IsRetreating(bot) and #J.GetNearbyHeroes(bot,600,true,BOT_MODE_NONE)>0 and bot:WasRecentlyDamagedByAnyHero(3) then
        local p=bot:GetLocation()+(J.GetEscapeLoc()-bot:GetLocation()):Normalized()*700
        if Safe(p) and bot:GetMana()>=X.BallCost(a,700) then return BOT_ACTION_DESIRE_HIGH,p end
    end
    local target=J.GetProperTarget(bot)
    if J.IsGoingOnSomeone(bot) and Enemy(target,false) and J.CanBeAttacked(target) and GetUnitToUnitDistance(bot,target)<=1400 then
        local distance=GetUnitToUnitDistance(bot,target)
        if distance>bot:GetAttackRange() or not bot:HasModifier('modifier_storm_spirit_overload') then
            local p=J.GetCorrectLoc(target,a:GetCastPoint()+distance/a:GetSpecialValueInt('ball_lightning_move_speed'))
            local vortex=bot:GetAbilityByName('storm_spirit_electric_vortex')
            local remnant=bot:GetAbilityByName('storm_spirit_static_remnant')
            local reserve=X.BallCost(a,600)
            if J.CanCastAbility(vortex) then reserve=reserve+vortex:GetManaCost() end
            if J.CanCastAbility(remnant) then reserve=reserve+remnant:GetManaCost() end
            if Safe(p) and GetUnitToLocationDistance(bot,p)<=1400 and bot:GetMana()>=X.BallCost(a,GetUnitToLocationDistance(bot,p))+reserve then return BOT_ACTION_DESIRE_HIGH,p end
        end
    end
    return 0
end
local decisions={storm_spirit_static_remnant=X.ConsiderStaticRemnant,storm_spirit_electric_vortex=X.ConsiderElectricVortex,
    storm_spirit_ball_lightning=X.ConsiderBallLightning,storm_spirit_electric_rave=X.ConsiderOverload,storm_spirit_overload=X.ConsiderOverload}
local function Cast(a,target,shape)
    J.SetQueuePtToINT(bot,true,a)
    if a:GetName()=='storm_spirit_electric_vortex' and not shape then bot:ActionQueue_UseAbilityOnEntity(a,target)
    elseif a:GetName()=='storm_spirit_ball_lightning' or a:GetName()=='storm_spirit_static_remnant' and shape then bot:ActionQueue_UseAbilityOnLocation(a,target)
    else bot:ActionQueue_UseAbility(a) end
end
function X.UseBallFlightSpells()
    bot=GetBot()
    if not bot:HasModifier('modifier_storm_spirit_ball_lightning') then return false end
    local ball=bot:GetAbilityByName('storm_spirit_ball_lightning')
    local index=bot:GetModifierByName('modifier_storm_spirit_ball_lightning')
    local source=index>=0 and bot:GetModifierSourceAbility(index) or nil
    if ball==nil or ball:IsNull() or source~=ball or source:GetCaster()~=bot
        or not bot:IsAlive() or bot:IsStunned() or bot:IsHexed() or bot:IsNightmared() or bot:IsSilenced()
        or bot:IsChanneling() or bot:IsCastingAbility() or J.HasQueuedAction(bot)
        or bot:HasModifier('modifier_ringmaster_the_box_buff') or bot:HasModifier('modifier_doom_bringer_doom')
        or bot:HasModifier('modifier_item_forcestaff_active') then return false end
    for _,name in ipairs({'storm_spirit_electric_vortex','storm_spirit_electric_rave','storm_spirit_static_remnant','storm_spirit_overload'}) do
        local a=bot:GetAbilityByName(name)
        if J.CanCastAbility(a) then
            local desire,target,shape=decisions[name](a)
            if desire>0 then
                if name=='storm_spirit_electric_vortex' and not shape then bot:Action_UseAbilityOnEntity(a,target)
                elseif name=='storm_spirit_static_remnant' and shape then bot:Action_UseAbilityOnLocation(a,target)
                else bot:Action_UseAbility(a) end
                return true
            end
        end
    end
    return false
end
function X.ConsiderStolenSpell(a)
    local consider=decisions[a:GetName()]
    if consider==nil then return nil end
    bot=GetBot()
    if J.CanNotUseAbility(bot) or bot:HasModifier('modifier_storm_spirit_ball_lightning') or not J.CanCastAbility(a) then return false end
    local desire,target,shape=consider(a)
    if desire<=0 then return false end
    Cast(a,target,shape);return true
end
function X.UseNative()
    bot=GetBot()
    if X.UseBallFlightSpells() then return true end
    if J.CanNotUseAbility(bot) or bot:HasModifier('modifier_storm_spirit_ball_lightning') then return false end
    for _,name in ipairs({'storm_spirit_electric_vortex','storm_spirit_electric_rave','storm_spirit_static_remnant','storm_spirit_ball_lightning','storm_spirit_overload'}) do
        local a=bot:GetAbilityByName(name)
        if J.CanCastAbility(a) then
            local desire,target,shape=decisions[name](a)
            if desire>0 then Cast(a,target,shape);return true end
        end
    end
    return false
end
return X
