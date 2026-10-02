local X={}
local J=require(GetScriptDirectory()..'/FunLib/jmz_func')
local bot=GetBot()
local function Enemy(u)
    return J.IsValidHero(u) and not J.IsSuspiciousIllusion(u) and J.CanCastOnNonMagicImmune(u)
        and not J.CannotBeKilled(bot,u) and not u:HasModifier('modifier_item_blade_mail_reflect')
        and not u:HasModifier('modifier_nyx_assassin_spiked_carapace')
end
local function Protected(u)
    return u:HasModifier('modifier_slark_shadow_dance')
end
local function Threat(u)
    for _,enemy in pairs(J.GetNearbyHeroes(u,1000,true,BOT_MODE_NONE)) do
        if J.IsValidHero(enemy) and not J.IsSuspiciousIllusion(enemy)
            and (enemy:GetAttackTarget()==u or J.IsChasingTarget(enemy,u) and u:WasRecentlyDamagedByAnyHero(2)) then return true end
    end
    return false
end
function X.ConsiderDance()
    local a=bot:GetAbilityByName('slark_shadow_dance')
    if not J.CanCastAbility(a) or Protected(bot) then return 0 end
    local incoming=J.GetAttackProjectileDamageByRange(bot,1200)
    if (J.GetHP(bot)<0.55 and bot:WasRecentlyDamagedByAnyHero(2) and Threat(bot))
        or incoming>bot:GetHealth()*0.3 or J.GetHP(bot)<0.7 and J.IsStunProjectileIncoming(bot,800) then return BOT_ACTION_DESIRE_HIGH end
    return 0
end
local function Range(a)
    local range=a:GetCastRange()
    for slot=0,5 do
        local item=bot:GetItemInSlot(slot)
        if item~=nil and not item:IsNull() and item:GetName()=='item_aether_lens' then range=range+item:GetSpecialValueInt('cast_range_bonus');break end
    end
    local supremacy=bot:GetAbilityByName('rubick_arcane_supremacy')
    if supremacy~=nil and not supremacy:IsNull() and supremacy:IsTrained() and not J.HasBreakModifier(bot) then range=range+supremacy:GetSpecialValueInt('cast_range') end
    return range
end
function X.ConsiderShroud()
    local a=bot:GetAbilityByName('slark_depth_shroud')
    if not J.CanCastAbility(a) then return 0 end
    local radius=a:GetSpecialValueInt('radius');local range=Range(a)
    local candidates=J.GetAlliesNearLoc(bot:GetLocation(),range+radius);candidates[#candidates+1]=bot
    local best,score=nil,-1
    for _,ally in pairs(candidates) do
        if J.IsValidHero(ally) and not ally:IsIllusion() and not ally:IsInvulnerable() and not Protected(ally)
            and (ally:HasModifier('modifier_legion_commander_duel') or ally:HasModifier('modifier_bane_fiends_grip')
                or J.GetHP(ally)<0.45 and ally:WasRecentlyDamagedByAnyHero(2) and Threat(ally)) then
            local predicted=J.GetCorrectLoc(ally,a:GetCastPoint());local delta=predicted-bot:GetLocation()
            if delta:Length2D()<=range+radius then
                local point=delta:Length2D()>range and bot:GetLocation()+delta:Normalized()*range or predicted
                local value=1-J.GetHP(ally)+(ally~=bot and 1 or 0)
                if value>score then best,score=point,value end
            end
        end
    end
    if best~=nil then return BOT_ACTION_DESIRE_HIGH,best end
    return 0
end
function X.ConsiderPact()
    local a=bot:GetAbilityByName('slark_dark_pact')
    if not J.CanCastAbility(a) or bot:HasModifier('modifier_slark_dark_pact') or bot:HasModifier('modifier_slark_dark_pact_pulses') then return 0 end
    if bot:IsRooted() or bot:HasModifier('modifier_bounty_hunter_track')
        or bot:HasModifier('modifier_slardar_amplify_damage') or J.IsStunProjectileIncoming(bot,800) then return BOT_ACTION_DESIRE_HIGH end
    local delay=a:GetCastPoint()+a:GetSpecialValueFloat('delay');local radius=a:GetSpecialValueInt('radius')
    local center=J.GetCorrectLoc(bot,delay);local heroes=J.GetNearbyHeroes(bot,math.min(radius+500,1600),true,BOT_MODE_NONE)
    for _,enemy in pairs(heroes) do
        if J.IsValidHero(enemy) and (J.GetCorrectLoc(enemy,delay)-center):Length2D()<=radius
            and (enemy:HasModifier('modifier_nyx_assassin_spiked_carapace') or enemy:HasModifier('modifier_item_blade_mail_reflect')) then return 0 end
    end
    local selfDamage=bot:GetActualIncomingDamage(a:GetSpecialValueInt('total_damage')*a:GetSpecialValueInt('self_damage_pct')/100,DAMAGE_TYPE_MAGICAL)
    if bot:GetHealth()-selfDamage<bot:GetMaxHealth()*0.3 then return 0 end
    for _,enemy in pairs(heroes) do
        if Enemy(enemy) and (J.GetCorrectLoc(enemy,delay)-center):Length2D()<=radius then
            -- Only the first pulse is guaranteed by this geometry; do not predict ten hits as instant damage.
            if J.WillKillTarget(enemy,a:GetSpecialValueInt('total_damage')/a:GetSpecialValueInt('total_pulses'),DAMAGE_TYPE_MAGICAL,delay)
                or J.IsGoingOnSomeone(bot) and J.GetProperTarget(bot)==enemy or Threat(bot) then return BOT_ACTION_DESIRE_HIGH end
        end
    end
    if (J.IsFarming(bot) or J.IsPushing(bot) or J.IsDefending(bot)) and J.IsAllowedToSpam(bot,a:GetManaCost()) then
        local creeps=bot:GetNearbyLaneCreeps(radius+200,true)
        if #creeps<3 and J.IsFarming(bot) then creeps=bot:GetNearbyNeutralCreeps(radius+200) end
        local count=0
        for _,creep in pairs(creeps) do
            if J.IsValid(creep) and J.CanCastOnNonMagicImmune(creep) and not creep:HasModifier('modifier_fountain_glyph')
                and (J.GetCorrectLoc(creep,delay)-center):Length2D()<=radius then count=count+1 end
        end
        if count>=3 then return BOT_ACTION_DESIRE_HIGH end
    end
    return 0
end
local function Safe(point)
    return IsLocationPassable(point) and not J.IsLocationInChrono(point) and not J.IsLocationInBlackHole(point)
        and not J.IsLocHaveTower(800,true,point)
end
local function FirstHero(a,distance,endpoint)
    local direction=(endpoint-bot:GetLocation()):Normalized();local first,closest=nil,math.huge
    for _,enemy in pairs(J.GetNearbyHeroes(bot,math.min(distance+a:GetSpecialValueInt('pounce_radius')+200,1600),true,BOT_MODE_NONE)) do
        if J.IsValidHero(enemy) and not J.IsSuspiciousIllusion(enemy) then
            local eta=a:GetCastPoint()+J.GetETAWithAcceleration(GetUnitToUnitDistance(bot,enemy),a:GetSpecialValueFloat('pounce_speed'),a:GetSpecialValueFloat('pounce_acceleration'))
            local delta=J.GetCorrectLoc(enemy,eta)-bot:GetLocation();local along=delta.x*direction.x+delta.y*direction.y
            if along>=0 and along<=distance+a:GetSpecialValueInt('pounce_radius')
                and (delta-direction*along):Length2D()<=a:GetSpecialValueInt('pounce_radius') and along<closest then first,closest=enemy,along end
        end
    end
    return first
end
function X.ConsiderPounce()
    local a=bot:GetAbilityByName('slark_pounce')
    if not J.CanCastAbility(a) or bot:IsRooted() or bot:HasModifier('modifier_slark_pounce')
        or bot:HasModifier('modifier_bloodseeker_rupture') or bot:HasModifier('modifier_puck_coiled')
        or bot:HasModifier('modifier_slark_pounce_leash') or bot:HasModifier('modifier_grimstroke_soul_chain') then return 0 end
    local distance=a:GetSpecialValueInt('pounce_distance')
    if bot:HasScepter() then distance=math.max(distance,a:GetSpecialValueInt('pounce_distance_scepter')) end
    local endpoint=J.GetFaceTowardDistanceLocation(bot,distance)
    if not Safe(endpoint) then return 0 end
    local first=FirstHero(a,distance,endpoint)
    if (J.IsRetreating(bot) and bot:WasRecentlyDamagedByAnyHero(2) or J.IsStuck(bot))
        and bot:IsFacingLocation(J.GetEscapeLoc(),25) and first==nil then return BOT_ACTION_DESIRE_HIGH end
    local target=J.GetProperTarget(bot)
    if Enemy(target) and first==target and not target:HasModifier('modifier_slark_pounce_leash')
        and J.IsGoingOnSomeone(bot) and not J.IsDisabled(target)
        and #J.GetEnemiesNearLoc(endpoint,1000)<=#J.GetAlliesNearLoc(endpoint,1000)+1 then
        local escape=bot:GetAbilityByName('slark_shadow_dance')
        if not bot:HasScepter() or a:GetCurrentCharges()>1 or J.CanCastAbility(escape) or Protected(bot) then return BOT_ACTION_DESIRE_HIGH end
    end
    return 0
end
function X.ConsiderShiv()
    local a=bot:GetAbilityByName('slark_saltwater_shiv')
    if not J.CanCastAbility(a) or bot:IsDisarmed() then return 0 end
    local target=bot:GetAttackTarget() or J.GetProperTarget(bot)
    if Enemy(target) and J.CanBeAttacked(target) and J.CanCastOnTargetAdvanced(target)
        and GetUnitToUnitDistance(bot,target)<=bot:GetAttackRange()+a:GetSpecialValueInt('melee_range_buffer')
        and (J.IsGoingOnSomeone(bot) or J.IsLaning(bot) and J.IsAllowedToSpam(bot,a:GetManaCost())) then return BOT_ACTION_DESIRE_HIGH,target end
    return 0
end
local function ShadowState()
    local index=bot:GetModifierByName('modifier_slark_shadow_dance')
    if index<0 then return false end
    local source=bot:GetModifierSourceAbility(index)
    if source==nil or source:IsNull() then return false end
    local caster=source:GetCaster()
    return caster~=nil and caster:GetTeam()==bot:GetTeam()
        and (source:GetName()=='slark_shadow_dance' and caster==bot or source:GetName()=='slark_depth_shroud')
end
local decisions={slark_dark_pact=X.ConsiderPact,slark_pounce=X.ConsiderPounce,slark_saltwater_shiv=X.ConsiderShiv,
    slark_shadow_dance=X.ConsiderDance,slark_depth_shroud=X.ConsiderShroud}
local function Cast(a,target,queue)
    local name=a:GetName()
    if queue and name=='slark_dark_pact' then J.SetQueuePtToINT(bot,true,a) end
    if name=='slark_depth_shroud' then bot:Action_UseAbilityOnLocation(a,target)
    elseif name=='slark_saltwater_shiv' then bot:Action_UseAbilityOnEntity(a,target)
    elseif queue and name=='slark_dark_pact' then bot:ActionQueue_UseAbility(a)
    else bot:Action_UseAbility(a) end
end
local function Choose(queue)
    for _,name in ipairs({'slark_shadow_dance','slark_depth_shroud','slark_dark_pact','slark_pounce','slark_saltwater_shiv'}) do
        local desire,target=decisions[name]()
        if desire>0 then Cast(bot:GetAbilityByName(name),target,queue);return true end
    end
    return false
end
function X.UseShadowDanceSpells()
    bot=GetBot()
    if not bot:IsInvisible() or not ShadowState() or J.CanNotUseAbility(bot) then return false end
    return Choose(false)
end
function X.ConsiderStolenSpell(a)
    local decide=decisions[a:GetName()];if decide==nil then return nil end
    bot=GetBot()
    if J.CanNotUseAbility(bot) or bot:IsInvisible() and not ShadowState() or not J.CanCastAbility(a) then return false end
    local desire,target=decide();if desire<=0 then return false end
    Cast(a,target,false);return true
end
function X.UseNative()
    bot=GetBot()
    if J.CanNotUseAbility(bot) or bot:IsInvisible() and not ShadowState() then return false end
    return Choose(true)
end
return X
