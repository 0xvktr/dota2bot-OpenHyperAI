local X={}
local J=require(GetScriptDirectory()..'/FunLib/jmz_func')
local bot=GetBot()
local function Interrupt(unit,eta)
    if not unit:IsChanneling() then return false end
    local index=unit:GetModifierByName('modifier_teleporting')
    return index<0 or unit:GetModifierRemainingDuration(index)>eta+0.05
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
local function Enemy(u,pierce)
    return J.IsValid(u) and not J.IsSuspiciousIllusion(u)
        and (pierce and J.CanCastOnMagicImmune(u) or not pierce and J.CanCastOnNonMagicImmune(u))
end
local function Threat(enemy)
    local victim=enemy:GetAttackTarget()
    return J.IsValidHero(victim) and victim:GetTeam()==bot:GetTeam() and not victim:IsIllusion()
        and victim:WasRecentlyDamagedByAnyHero(2)
end
local function Followup(enemy)
    if J.IsGoingOnSomeone(bot) and J.GetProperTarget(bot)==enemy then return true end
    for _,ally in pairs(J.GetAlliesNearLoc(enemy:GetLocation(),1000)) do
        if J.IsValidHero(ally) and not ally:IsIllusion() and not ally:IsDisarmed() and ally:GetAttackTarget()==enemy then return true end
    end
    return false
end
function X.ConsiderCrush()
    local a=bot:GetAbilityByName('slardar_slithereen_crush')
    if not J.CanCastAbility(a) then return 0 end
    local radius=a:GetSpecialValueInt('crush_radius');local eta=a:GetCastPoint()
    local count=0
    for _,enemy in pairs(J.GetNearbyHeroes(bot,math.min(radius+200,1600),true,BOT_MODE_NONE)) do
        if Enemy(enemy,false) and not J.CannotBeKilled(bot,enemy)
            and not enemy:HasModifier('modifier_item_blade_mail_reflect') and not enemy:HasModifier('modifier_nyx_assassin_spiked_carapace')
            and (J.GetCorrectLoc(enemy,eta)-bot:GetLocation()):Length2D()<=radius then
            if Interrupt(enemy,eta) or J.WillKillTarget(enemy,a:GetSpecialValueInt('crush_damage'),DAMAGE_TYPE_PHYSICAL,eta) then return BOT_ACTION_DESIRE_HIGH end
            if not J.IsDisabled(enemy) and (Followup(enemy) or Threat(enemy) or J.IsRetreating(bot) and enemy:GetAttackTarget()==bot) then return BOT_ACTION_DESIRE_HIGH end
            count=count+1
        end
    end
    if J.IsInTeamFight(bot,1200) and count>=2 then return BOT_ACTION_DESIRE_HIGH end
    if J.IsAllowedToSpam(bot,a:GetManaCost()) then
        local creeps=bot:GetNearbyLaneCreeps(radius,true)
        if J.IsLaning(bot) then
            for _,creep in pairs(creeps) do
                if Enemy(creep,false) and not creep:HasModifier('modifier_fountain_glyph')
                    and string.find(creep:GetUnitName(),'ranged',1,true) and GetUnitToUnitDistance(bot,creep)>bot:GetAttackRange()
                    and (J.GetCorrectLoc(creep,eta)-bot:GetLocation()):Length2D()<=radius
                    and J.WillKillTarget(creep,a:GetSpecialValueInt('crush_damage'),DAMAGE_TYPE_PHYSICAL,eta) then return BOT_ACTION_DESIRE_HIGH end
            end
        elseif J.IsFarming(bot) or J.IsPushing(bot) or J.IsDefending(bot) then
            if #creeps<3 then creeps=bot:GetNearbyNeutralCreeps(radius) end
            count=0
            for _,creep in pairs(creeps) do
                if Enemy(creep,false) and not creep:HasModifier('modifier_fountain_glyph')
                    and (J.GetCorrectLoc(creep,eta)-bot:GetLocation()):Length2D()<=radius then count=count+1 end
            end
            if count>=3 then return BOT_ACTION_DESIRE_HIGH end
        end
        local target=J.GetProperTarget(bot)
        if Enemy(target,false) and (J.IsDoingRoshan(bot) and J.IsRoshan(target) or J.IsDoingTormentor(bot) and J.IsTormentor(target))
            and GetUnitToUnitDistance(bot,target)<=radius and J.IsAttacking(bot) then return BOT_ACTION_DESIRE_HIGH end
    end
    return 0
end
local function NeedsHaze(u)
    local index=u:GetModifierByName('modifier_slardar_amplify_damage')
    return index<0 or u:GetModifierRemainingDuration(index)<2
end
function X.ConsiderHaze()
    local a=bot:GetAbilityByName('slardar_amplify_damage')
    if not J.CanCastAbility(a) then return 0 end
    local range=Range(a);local best,score=nil,-1
    for _,enemy in pairs(J.GetNearbyHeroes(bot,math.min(range,1600),true,BOT_MODE_NONE)) do
        if Enemy(enemy,true) and GetUnitToUnitDistance(bot,enemy)<=range and J.CanCastOnTargetAdvanced(enemy) and NeedsHaze(enemy) then
            if Followup(enemy) or Threat(enemy) or enemy:IsInvisible() then
                local value=enemy==J.GetProperTarget(bot) and 2 or 1
                for _,ally in pairs(J.GetAlliesNearLoc(enemy:GetLocation(),1000)) do
                    if J.IsValidHero(ally) and not ally:IsIllusion() and not ally:IsDisarmed() and ally:GetAttackTarget()==enemy then value=value+2 end
                end
                if value>score then best,score=enemy,value end
            end
        end
    end
    if best~=nil then return BOT_ACTION_DESIRE_HIGH,best end
    local target=bot:GetAttackTarget()
    if Enemy(target,true) and GetUnitToUnitDistance(bot,target)<=range and NeedsHaze(target) and J.CanCastOnTargetAdvanced(target)
        and (J.IsDoingRoshan(bot) and J.IsRoshan(target) or J.IsDoingTormentor(bot) and J.IsTormentor(target)
            or J.IsFarming(bot) and not J.IsValidHero(target) and target:GetHealth()>bot:GetAttackDamage()*3)
        and J.IsAllowedToSpam(bot,a:GetManaCost()) then return BOT_ACTION_DESIRE_HIGH,target end
    return 0
end
function X.ConsiderSprint()
    local a=bot:GetAbilityByName('slardar_sprint')
    if not J.CanCastAbility(a) or bot:IsRooted() or bot:HasModifier('modifier_slardar_sprint') then return 0 end
    local target=J.GetProperTarget(bot)
    if Enemy(target,true) and J.IsGoingOnSomeone(bot) and GetUnitToUnitDistance(bot,target)>bot:GetAttackRange()+100
        and GetUnitToUnitDistance(bot,target)<=1600 then return BOT_ACTION_DESIRE_HIGH end
    if J.IsRetreating(bot) and bot:WasRecentlyDamagedByAnyHero(2) and #J.GetNearbyHeroes(bot,1200,true,BOT_MODE_NONE)>0 then return BOT_ACTION_DESIRE_HIGH end
    if J.IsStuck(bot) then return BOT_ACTION_DESIRE_HIGH end
    return 0
end
local decisions={slardar_sprint=X.ConsiderSprint,slardar_slithereen_crush=X.ConsiderCrush,slardar_amplify_damage=X.ConsiderHaze}
local function Cast(a,target,queue)
    if queue then J.SetQueuePtToINT(bot,a:GetName()=='slardar_slithereen_crush',a) end
    if a:GetName()=='slardar_amplify_damage' then
        if queue then bot:ActionQueue_UseAbilityOnEntity(a,target) else bot:Action_UseAbilityOnEntity(a,target) end
    elseif queue then bot:ActionQueue_UseAbility(a) else bot:Action_UseAbility(a) end
end
function X.ConsiderStolenSpell(a)
    local decide=decisions[a:GetName()];if decide==nil then return nil end
    bot=GetBot()
    if J.CanNotUseAbility(bot) or bot:IsInvisible() or not J.CanCastAbility(a) then return false end
    local desire,target=decide();if desire<=0 then return false end
    Cast(a,target,false);return true
end
function X.UseNative()
    bot=GetBot();if J.CanNotUseAbility(bot) or bot:IsInvisible() then return false end
    for _,name in ipairs({'slardar_slithereen_crush','slardar_amplify_damage','slardar_sprint'}) do
        local desire,target=decisions[name]()
        if desire>0 then Cast(bot:GetAbilityByName(name),target,true);return true end
    end
    return false
end
return X
