local X={}
local bot=GetBot()
local J=require(GetScriptDirectory()..'/FunLib/jmz_func')
local nextBeat,lastBeat
function X.Range(a)
    local range=a:GetCastRange()
    for slot=0,5 do local item=bot:GetItemInSlot(slot)
        if item~=nil and item:GetName()=='item_aether_lens' then range=range+item:GetSpecialValueInt('cast_range_bonus');break end
    end
    local supremacy=bot:GetAbilityByName('rubick_arcane_supremacy')
    if supremacy~=nil and supremacy:IsTrained() and not J.HasBreakModifier(bot) then range=range+supremacy:GetSpecialValueInt('cast_range') end
    return range
end
local debuffs={'modifier_item_spirit_vessel_damage','modifier_item_urn_damage','modifier_orchid_malevolence_debuff',
    'modifier_bloodthorn_debuff','modifier_venomancer_venomous_gale','modifier_axe_battle_hunger',
    'modifier_warlock_fatal_bonds','modifier_bristleback_viscous_nasal_goo','modifier_item_diffusal_blade_slow'}
function X.LickTarget(a,urgent)
    if not J.CanCastAbility(a) then return nil end
    local range=X.Range(a)
    local allies=J.GetNearbyHeroes(bot,math.min(1600,range),false,BOT_MODE_NONE)
    allies[#allies+1]=bot
    for _,ally in pairs(allies) do
        if J.IsValidHero(ally) and not ally:IsInvulnerable() and not ally:IsIllusion() and not ally:IsChanneling() then
            for _,modifier in ipairs(debuffs) do if ally:HasModifier(modifier) then return ally end end
            if ally~=bot and J.GetHP(ally)<0.5 and ally:WasRecentlyDamagedByAnyHero(2) then
                local pull=math.min(a:GetSpecialValueInt('pull_distance_ally'),GetUnitToUnitDistance(bot,ally))
                local point=ally:GetLocation()+(bot:GetLocation()-ally:GetLocation()):Normalized()*pull
                local threats=J.GetEnemiesNearLoc(ally:GetLocation(),900)
                local safe=#threats>0
                for _,enemy in pairs(threats) do
                    if GetUnitToLocationDistance(enemy,point)<GetUnitToUnitDistance(enemy,ally)+150 then safe=false;break end
                end
                if safe then return ally end
            end
        end
    end
    if urgent then return nil end
    for _,u in pairs(J.GetNearbyHeroes(bot,math.min(1600,range),true,BOT_MODE_NONE)) do
        if J.IsValidHero(u) and J.CanCastOnNonMagicImmune(u) and J.CanCastOnTargetAdvanced(u)
            and not J.IsSuspiciousIllusion(u) and not J.CannotBeKilled(bot,u) then
            if J.WillKillTarget(u,a:GetSpecialValueInt('damage'),DAMAGE_TYPE_MAGICAL,a:GetCastPoint())
                or J.IsGoingOnSomeone(bot) and u==J.GetProperTarget(bot) then return u end
        end
    end
    if J.IsLaning(bot) and J.IsAllowedToSpam(bot,a:GetManaCost()) then
        for _,creep in pairs(bot:GetNearbyLaneCreeps(range,true)) do
            if J.IsValid(creep) and J.IsKeyWordUnit('ranged',creep) and J.CanCastOnNonMagicImmune(creep)
                and not J.IsOtherAllysTarget(creep) and J.WillKillTarget(creep,a:GetSpecialValueInt('damage'),DAMAGE_TYPE_MAGICAL,a:GetCastPoint()) then return creep end
        end
    end
    return nil
end
function X.StompPoint(a,urgent)
    if not J.CanCastAbility(a) then return nil end
    local range=X.Range(a)
    local radius=a:GetSpecialValueInt('radius')
    for _,u in pairs(J.GetNearbyHeroes(bot,math.min(1600,range+radius),true,BOT_MODE_NONE)) do
        if J.IsValidHero(u) and J.CanCastOnNonMagicImmune(u) and not J.IsSuspiciousIllusion(u)
            and (u:IsChanneling() or not urgent and (J.IsGoingOnSomeone(bot) and u==J.GetProperTarget(bot)
                or J.IsRetreating(bot) and J.IsChasingTarget(u,bot))) then
            local point=J.GetCorrectLoc(u,a:GetCastPoint()+a:GetSpecialValueFloat('delay'))
            local delta=point-bot:GetLocation()
            if delta:Length2D()>range then point=bot:GetLocation()+delta:Normalized()*range end
            if (J.GetCorrectLoc(u,a:GetCastPoint()+a:GetSpecialValueFloat('delay'))-point):Length2D()<=radius then return point end
        end
    end
    return nil
end
function X.CroakTarget(a)
    if not J.CanCastAbility(a) then return nil end
    local target,best=nil,0
    local allies=J.GetNearbyHeroes(bot,math.min(1600,X.Range(a)),false,BOT_MODE_NONE)
    for _,ally in pairs(allies) do
        if J.IsValidHero(ally) and not ally:IsIllusion() and not ally:IsSilenced() and not ally:IsInvulnerable()
            and not ally:HasModifier('modifier_largo_croak_of_genius_buff') and J.IsGoingOnSomeone(ally) then
            local victim=J.GetProperTarget(ally)
            if J.IsValidHero(victim) and J.CanCastOnNonMagicImmune(victim) and J.IsInRange(ally,victim,a:GetSpecialValueInt('max_distance')) then
                local damage=ally:GetEstimatedDamageToTarget(true,victim,5,DAMAGE_TYPE_MAGICAL)
                if damage>best then target,best=ally,damage end
            end
        end
    end
    if target~=nil then return target end
    if not bot:HasModifier('modifier_largo_croak_of_genius_buff') and J.IsGoingOnSomeone(bot) then
        local lick=bot:GetAbilityByName('largo_catchy_lick')
        local stomp=bot:GetAbilityByName('largo_frogstomp')
        if X.LickTarget(lick,false)~=nil or X.StompPoint(stomp,false)~=nil then return bot end
    end
    return nil
end
local function healable(u)
    return not u:HasModifier('modifier_ice_blast') and not u:HasModifier('modifier_doom_bringer_doom_aura_enemy')
        and not u:HasModifier('modifier_necrolyte_reapers_scythe')
end
function X.SelectSongs(a)
    local heal=bot:GetAbilityByName('largo_song_good_vibrations')
    local speed=bot:GetAbilityByName('largo_song_double_time')
    local fight=bot:GetAbilityByName('largo_song_fight_song')
    if heal==nil or speed==nil or fight==nil then return nil,nil end
    local healing,moving,damage=false,false,false
    local allies=J.GetNearbyHeroes(bot,math.min(1600,a:GetSpecialValueInt('radius')),false,BOT_MODE_NONE)
    allies[#allies+1]=bot
    for _,ally in pairs(allies) do
        if J.IsValidHero(ally) and not ally:IsIllusion() and not ally:IsInvulnerable() then
            if J.GetHP(ally)<0.65 and healable(ally) then healing=true end
            local victim=J.GetProperTarget(ally)
            if J.IsRetreating(ally) and ally:WasRecentlyDamagedByAnyHero(2)
                or J.IsGoingOnSomeone(ally) and J.IsValidHero(victim) and J.IsChasingTarget(ally,victim) then moving=true end
            if J.IsGoingOnSomeone(ally) and J.IsValidHero(J.GetProperTarget(ally)) then damage=true end
        end
    end
    local first=healing and heal or moving and speed or damage and fight or nil
    local second
    if first~=nil and a:GetSpecialValueInt('double_song')>0 then
        if healing and moving then second=speed elseif damage and first~=fight then second=fight end
    end
    return first,second
end
function X.UseRhapsodyOff()
    if not bot:HasModifier('modifier_largo_amphibian_rhapsody_self') then nextBeat,lastBeat=nil,nil;return false end
    local ultimate=bot:GetAbilityByName('largo_amphibian_rhapsody')
    if ultimate==nil or not J.CanCastAbility(ultimate) or not ultimate:GetToggleState() or not bot:IsAlive() or bot:IsStunned() or bot:IsHexed()
        or bot:IsNightmared() or bot:IsInvulnerable() or bot:IsChanneling() or bot:IsCastingAbility()
        or bot:IsUsingAbility() or J.HasQueuedAction(bot) or bot:HasModifier('modifier_ringmaster_the_box_buff')
        or bot:HasModifier('modifier_doom_bringer_doom') or bot:HasModifier('modifier_item_forcestaff_active') then return false end
    local first=X.SelectSongs(ultimate)
    -- The live toggle ignores silence; songs do not. Exit to recover the base toolkit.
    if bot:IsSilenced() or first==nil or bot:GetMana()<30 then
        bot:Action_UseAbility(ultimate);nextBeat,lastBeat=nil,nil;return true
    end
    return false
end
function X.PlaySongs(a)
    if not bot:HasModifier('modifier_largo_amphibian_rhapsody_self') or J.CanNotUseAbility(bot) then return false end
    local first,second=X.SelectSongs(a)
    if first==nil or not J.CanCastAbility(first) then return false end
    local now=DotaTime()
    local interval=a:GetSpecialValueFloat('rhythm_interval')
    if nextBeat==nil then nextBeat=now+interval end
    while now>nextBeat+a:GetSpecialValueFloat('rhythm_grace_period') do nextBeat=nextBeat+interval end
    if math.abs(now-nextBeat)>a:GetSpecialValueFloat('rhythm_grace_period') or lastBeat==nextBeat then return false end
    bot:ActionQueue_UseAbility(first)
    if second~=nil and J.CanCastAbility(second) and bot:GetMana()>=first:GetManaCost()+second:GetManaCost() then bot:ActionQueue_UseAbility(second) end
    lastBeat=nextBeat
    return true
end
function X.ShouldBegin(a)
    if not J.CanCastAbility(a) or a:GetToggleState() or bot:HasModifier('modifier_largo_amphibian_rhapsody_self') then return false end
    local first=X.SelectSongs(a)
    return first~=nil and bot:GetMana()>=first:GetManaCost()*3
end
function X.ConsiderStolenSpell(a)
    local name=a:GetName()
    if name~='largo_catchy_lick' and name~='largo_frogstomp' and name~='largo_croak_of_genius'
        and name~='largo_amphibian_rhapsody' and name~='largo_song_fight_song'
        and name~='largo_song_double_time' and name~='largo_song_good_vibrations' then return nil end
    if name=='largo_amphibian_rhapsody' then
        if X.UseRhapsodyOff() then return true end
        if J.CanNotUseAbility(bot) then return false end
        if bot:HasModifier('modifier_largo_amphibian_rhapsody_self') then return X.PlaySongs(a) end
        if not X.ShouldBegin(a) then return false end
        bot:Action_UseAbility(a);return true
    end
    if string.find(name,'largo_song_',1,true) then
        local ultimate=bot:GetAbilityByName('largo_amphibian_rhapsody')
        return ultimate~=nil and X.PlaySongs(ultimate) or false
    end
    if J.CanNotUseAbility(bot) then return false end
    local target
    if name=='largo_catchy_lick' then target=X.LickTarget(a,false)
    elseif name=='largo_croak_of_genius' then target=X.CroakTarget(a)
    else
        local point=X.StompPoint(a,false)
        if point==nil then return false end
        J.SetQueuePtToINT(bot,false,a);bot:ActionQueue_UseAbilityOnLocation(a,point);return true
    end
    if target==nil then return false end
    J.SetQueuePtToINT(bot,false,a);bot:ActionQueue_UseAbilityOnEntity(a,target);return true
end
return X
