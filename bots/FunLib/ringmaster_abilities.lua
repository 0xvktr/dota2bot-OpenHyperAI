local M={}
local J=require(GetScriptDirectory()..'/FunLib/jmz_func')
local whipIntent=nil
function M.Range(bot,ability)
    local bonus=0
    for slot=0,5 do local item=bot:GetItemInSlot(slot);if item and not item:IsNull() and item:GetName()=='item_aether_lens' then bonus=item:GetSpecialValueInt('cast_range_bonus');break end end
    local supremacy=bot:GetAbilityByName('rubick_arcane_supremacy')
    if supremacy and not supremacy:IsNull() and supremacy:IsTrained() and not J.HasBreakModifier(bot) then bonus=bonus+supremacy:GetSpecialValueInt('cast_range') end
    return ability:GetCastRange()+bonus
end
local function distance(a,b) return math.sqrt((a.x-b.x)^2+(a.y-b.y)^2) end
local function toward(bot,point,minimum,maximum)
    local origin=bot:GetLocation();local dx,dy=point.x-origin.x,point.y-origin.y;local length=math.sqrt(dx*dx+dy*dy)
    if length==0 then return nil end
    local step=math.min(math.max(length,minimum),maximum)
    return Vector(origin.x+dx*step/length,origin.y+dy*step/length,0)
end
local function enemy(unit)
    return J.IsValid(unit) and unit:CanBeSeen() and J.CanCastOnNonMagicImmune(unit)
        and not unit:HasModifier('modifier_abaddon_borrowed_time') and not unit:HasModifier('modifier_dazzle_shallow_grave')
        and not unit:HasModifier('modifier_nyx_assassin_spiked_carapace') and not unit:HasModifier('modifier_item_blade_mail_reflect')
end
local function attacked(bot,unit)
    for _,enemyUnit in pairs(J.GetNearbyHeroes(bot,1600,true,BOT_MODE_NONE)) do
        if J.IsValidHero(enemyUnit) and enemyUnit:GetAttackTarget()==unit then return true end
    end
    for _,tower in pairs(unit:GetNearbyTowers(900,true)) do if J.IsValid(tower) and tower:GetAttackTarget()==unit then return true end end
    return false
end
function M.Box(bot,ability)
    if not J.CanCastAbility(ability) then return 0,nil end
    local allies={bot};for _,ally in pairs(J.GetNearbyHeroes(bot,math.min(M.Range(bot,ability),1600),false,BOT_MODE_NONE)) do if ally~=bot then allies[#allies+1]=ally end end
    local best,score=nil,-1
    for _,unit in pairs(allies) do
        if J.IsValidHero(unit) and not unit:IsIllusion() and J.IsInRange(bot,unit,M.Range(bot,ability))
            and not unit:HasModifier('modifier_ringmaster_the_box_buff') and not unit:HasModifier('modifier_shadow_demon_disruption')
            and not unit:HasModifier('modifier_obsidian_destroyer_astral_imprisonment_prison') then
            local danger=unit:HasModifier('modifier_legion_commander_duel') or unit:HasModifier('modifier_enigma_black_hole_pull')
                or unit:HasModifier('modifier_faceless_void_chronosphere_freeze') or unit:HasModifier('modifier_necrolyte_reapers_scythe')
            local underAttack=attacked(bot,unit)
            if danger or J.GetHP(unit)<.45 and unit:WasRecentlyDamagedByAnyHero(2) and underAttack
                and not unit:IsChanneling() and not unit:HasModifier('modifier_teleporting')
                and not unit:HasModifier('modifier_abaddon_borrowed_time') and not unit:HasModifier('modifier_dazzle_shallow_grave') then
                local value=(danger and 2 or 0)+1-J.GetHP(unit)
                if value>score then best=unit;score=value end
            end
        end
    end
    if best then return BOT_ACTION_DESIRE_HIGH,best,'unit' end
    return 0,nil
end
function M.Whip(bot,ability,native)
    if not J.CanCastAbility(ability) then return 0,nil end
    local range=M.Range(bot,ability);local radius=ability:GetSpecialValueInt('end_width')
    for _,unit in pairs(J.GetNearbyHeroes(bot,math.min(range+radius,1600),true,BOT_MODE_NONE)) do
        if enemy(unit) and not J.IsSuspiciousIllusion(unit) then
            local delay=unit:IsChanneling() and 0 or ability:GetChannelTime()
            local predicted=unit:GetExtrapolatedLocation(delay)
            local point=toward(bot,predicted,0,range)
            if point and distance(point,predicted)<=radius and (unit:IsChanneling() or J.IsGoingOnSomeone(bot) and unit==J.GetProperTarget(bot)
                or J.IsInTeamFight(bot,1200) or J.IsRetreating(bot) and unit:GetAttackTarget()==bot
                or J.WillKillTarget(unit,ability:GetSpecialValueInt('damage_max'),DAMAGE_TYPE_MAGICAL,ability:GetChannelTime()+ability:GetSpecialValueFloat('crack_duration'))) then return BOT_ACTION_DESIRE_HIGH,point end
        end
    end
    if native and J.IsAllowedToSpam(bot,ability:GetManaCost()) then
        local creeps=bot:GetNearbyCreeps(math.min(range+radius,1600),true)
        if #creeps>=3 or J.IsLaning(bot) and #creeps>0 and string.find(creeps[1]:GetUnitName(),'ranged') then
            if enemy(creeps[1]) and not creeps[1]:HasModifier('modifier_fountain_glyph') then local point=toward(bot,creeps[1]:GetLocation(),0,range);if point and distance(point,creeps[1]:GetLocation())<=radius then return BOT_ACTION_DESIRE_HIGH,point end end
        end
        local target=J.GetProperTarget(bot)
        if (J.IsDoingRoshan(bot) and J.IsRoshan(target) or J.IsDoingTormentor(bot) and J.IsTormentor(target)) and enemy(target) and J.IsInRange(bot,target,range) then return BOT_ACTION_DESIRE_HIGH,target:GetLocation() end
    end
    return 0,nil
end
function M.RecordWhip(bot,source,point)
    whipIntent={bot=bot,source=source,point=point,time=DotaTime()}
end
function M.Crack(bot,ability)
    if not J.CanCastAbility(ability) or not whipIntent or whipIntent.bot~=bot or DotaTime()-whipIntent.time>3 then return 0 end
    local source=bot:GetAbilityByName('ringmaster_tame_the_beasts')
    if not source or source:IsNull() or not source:IsTrained() or source:IsHidden() or not source:IsActivated()
        or source~=whipIntent.source or not bot:IsChanneling() or bot:GetCurrentActiveAbility()~=source then return 0 end
    for _,unit in pairs(J.GetNearbyHeroes(bot,1600,true,BOT_MODE_NONE)) do
        if enemy(unit) and GetUnitToLocationDistance(unit,whipIntent.point)<=source:GetSpecialValueInt('end_width')
            and (unit:IsChanneling() or J.GetHP(bot)<.25 and unit:GetAttackTarget()==bot) then return BOT_ACTION_DESIRE_HIGH end
    end
    return 0
end
function M.ReleaseWhip(bot)
    if not bot:IsAlive() or bot:IsCastingAbility() or bot:NumQueuedActions()>0 or bot:IsSilenced() or bot:IsStunned()
        or bot:IsHexed() or bot:IsNightmared() or bot:HasModifier('modifier_ringmaster_the_box_buff')
        or bot:HasModifier('modifier_doom_bringer_doom') or bot:HasModifier('modifier_item_forcestaff_active') then return false end
    local ability=bot:GetAbilityByName('ringmaster_tame_the_beasts_crack')
    if M.Crack(bot,ability)<=0 then return false end
    bot:Action_UseAbility(ability);whipIntent=nil;return true
end
local function clearDagger(bot,ability,target,point)
    local origin=bot:GetLocation();local dx,dy=point.x-origin.x,point.y-origin.y;local length=math.sqrt(dx*dx+dy*dy)
    if length==0 then return false end
    dx,dy=dx/length,dy/length;local blockers=0
    for _,kind in pairs({UNIT_LIST_ENEMIES,UNIT_LIST_NEUTRAL_CREEPS}) do
        for _,unit in pairs(GetUnitList(kind)) do
            if unit~=target and unit and not unit:IsNull() and unit:IsAlive() and unit:CanBeSeen() and not unit:IsBuilding() and not string.find(unit:GetUnitName(),'ward') then
                local p=unit:GetExtrapolatedLocation(ability:GetCastPoint()+GetUnitToUnitDistance(bot,unit)/ability:GetSpecialValueInt('dagger_speed'))
                local x,y=p.x-origin.x,p.y-origin.y;local along=x*dx+y*dy
                if along>0 and along<length and math.abs(x*dy-y*dx)<=ability:GetSpecialValueInt('dagger_width')+unit:GetBoundingRadius() then blockers=blockers+1 end
            end
        end
    end
    return blockers<=ability:GetSpecialValueInt('dagger_pass_through')
end
function M.Dagger(bot,ability,native)
    if not J.CanCastAbility(ability) or ability:GetCurrentCharges()<=0 then return 0,nil end
    local range=M.Range(bot,ability)
    for _,unit in pairs(GetUnitList(UNIT_LIST_ENEMY_HEROES)) do
        if enemy(unit) and not J.IsSuspiciousIllusion(unit) and J.IsInRange(bot,unit,range) then
            local delay=ability:GetCastPoint()+GetUnitToUnitDistance(bot,unit)/ability:GetSpecialValueInt('dagger_speed')
            local point=unit:GetExtrapolatedLocation(delay)
            if GetUnitToLocationDistance(bot,point)<=range and clearDagger(bot,ability,unit,point)
                and (J.WillKillTarget(unit,ability:GetSpecialValueInt('damage_impact'),DAMAGE_TYPE_MAGICAL,delay)
                    or not unit:HasModifier('modifier_ringmaster_impalement_bleed') and (J.IsGoingOnSomeone(bot) and unit==J.GetProperTarget(bot)
                        or J.IsLaning(bot) and J.IsAllowedToSpam(bot,ability:GetManaCost()) or J.IsRetreating(bot) and unit:GetAttackTarget()==bot)) then return BOT_ACTION_DESIRE_HIGH,point end
        end
    end
    if native and J.IsAllowedToSpam(bot,ability:GetManaCost()) then
        for _,unit in pairs(bot:GetNearbyLaneCreeps(1600,true)) do
            if enemy(unit) and not unit:HasModifier('modifier_fountain_glyph') and string.find(unit:GetUnitName(),'ranged')
                and J.WillKillTarget(unit,ability:GetSpecialValueInt('damage_impact'),DAMAGE_TYPE_MAGICAL,ability:GetCastPoint()+GetUnitToUnitDistance(bot,unit)/ability:GetSpecialValueInt('dagger_speed'))
                and clearDagger(bot,ability,unit,unit:GetLocation()) then return BOT_ACTION_DESIRE_HIGH,unit:GetLocation() end
        end
    end
    if native then
        local target=J.GetProperTarget(bot)
        if (J.IsDoingRoshan(bot) and J.IsRoshan(target) or J.IsDoingTormentor(bot) and J.IsTormentor(target))
            and enemy(target) and J.IsInRange(bot,target,range) and not target:HasModifier('modifier_ringmaster_impalement_bleed')
            and clearDagger(bot,ability,target,target:GetLocation()) then return BOT_ACTION_DESIRE_HIGH,target:GetLocation() end
    end
    return 0,nil
end
function M.Wheel(bot,ability)
    if not J.CanCastAbility(ability) then return 0,nil end
    for _,unit in pairs(J.GetNearbyHeroes(bot,1600,true,BOT_MODE_NONE)) do
        if enemy(unit) and not J.IsSuspiciousIllusion(unit) then
            local delay=ability:GetCastPoint()+GetUnitToUnitDistance(bot,unit)/ability:GetSpecialValueInt('projectile_speed')
            local predicted=unit:GetExtrapolatedLocation(delay);local point=toward(bot,predicted,ability:GetSpecialValueInt('min_range'),M.Range(bot,ability))
            if point and distance(point,predicted)<=ability:GetSpecialValueInt('mesmerize_radius') then
                local count=0
                for _,other in pairs(J.GetEnemiesNearLoc(point,ability:GetSpecialValueInt('mesmerize_radius'))) do if J.IsValidHero(other) and not J.IsSuspiciousIllusion(other) and enemy(other) then count=count+1 end end
                if J.IsInTeamFight(bot,1600) and count>=2 or J.IsGoingOnSomeone(bot) and unit==J.GetProperTarget(bot) and J.IsDisabled(unit) then return BOT_ACTION_DESIRE_HIGH,point end
            end
        end
    end
    return 0,nil
end
function M.Spotlight(bot,ability)
    if not J.CanCastAbility(ability) then return 0,nil end
    for _,unit in pairs(J.GetNearbyHeroes(bot,math.min(M.Range(bot,ability),1600),true,BOT_MODE_NONE)) do
        if enemy(unit) and (unit:IsIllusion() or J.IsInTeamFight(bot,1200) or attacked(bot,bot)) then
            local point=unit:GetExtrapolatedLocation(ability:GetCastPoint())
            if GetUnitToLocationDistance(bot,point)<=M.Range(bot,ability) then return BOT_ACTION_DESIRE_HIGH,point end
        end
    end
    return 0,nil
end
local souvenirNames={'ringmaster_funhouse_mirror','ringmaster_strongman_tonic','ringmaster_whoopee_cushion','ringmaster_summon_unicycle','ringmaster_weighted_pie','ringmaster_crystal_ball'}
function M.Souvenir(bot,ability)
    if not J.CanCastAbility(ability) or ability:GetCurrentCharges()<=0 then return 0,nil end
    local name=ability:GetName()
    if name=='ringmaster_funhouse_mirror' and (J.IsStunProjectileIncoming(bot,350) or J.GetHP(bot)<.4 and attacked(bot,bot)) then return BOT_ACTION_DESIRE_HIGH end
    if name=='ringmaster_strongman_tonic' then
        local allies={bot};for _,ally in pairs(J.GetNearbyHeroes(bot,math.min(M.Range(bot,ability),1600),false,BOT_MODE_NONE)) do if ally~=bot then allies[#allies+1]=ally end end
        for _,unit in pairs(allies) do if J.IsValidHero(unit) and not unit:IsIllusion() and J.IsInRange(bot,unit,M.Range(bot,ability))
            and J.GetHP(unit)<.5 and attacked(bot,unit) and not unit:HasModifier('modifier_ringmaster_strongman_tonic_buff') then return BOT_ACTION_DESIRE_HIGH,unit,'unit' end end
    end
    if name=='ringmaster_whoopee_cushion' or name=='ringmaster_summon_unicycle' then
        if name=='ringmaster_summon_unicycle' and bot:HasModifier('modifier_ringmaster_unicycle_movement') then return 0 end
        if bot:IsRooted() or bot:HasModifier('modifier_bloodseeker_rupture') or bot:HasModifier('modifier_slark_pounce_leash')
            or bot:HasModifier('modifier_puck_coiled') or bot:HasModifier('modifier_grimstroke_soul_chain') then return 0 end
        if J.IsRetreating(bot) and bot:WasRecentlyDamagedByAnyHero(2) and attacked(bot,bot) and bot:IsFacingLocation(J.GetEscapeLoc(),30) then return BOT_ACTION_DESIRE_HIGH end
    end
    if name=='ringmaster_weighted_pie' then
        for _,unit in pairs(J.GetNearbyHeroes(bot,math.min(M.Range(bot,ability),1600),true,BOT_MODE_NONE)) do if enemy(unit) and J.CanCastOnTargetAdvanced(unit) and J.IsRetreating(bot) and unit:GetAttackTarget()==bot then return BOT_ACTION_DESIRE_HIGH,unit,'unit' end end
    end
    return 0,nil
end
function M.UseSouvenir(bot,silenceOnly)
    if silenceOnly and not bot:IsSilenced() then return false end
    if not bot:IsAlive() or bot:IsMuted() or bot:IsInvulnerable() or bot:IsStunned() or bot:IsHexed() or bot:IsNightmared()
        or bot:IsCastingAbility() or bot:IsUsingAbility() or bot:IsChanneling() or bot:NumQueuedActions()>0
        or bot:HasModifier('modifier_ringmaster_the_box_buff') or bot:HasModifier('modifier_doom_bringer_doom') or bot:HasModifier('modifier_item_forcestaff_active') then return false end
    for _,name in pairs(souvenirNames) do
        local ability=bot:GetAbilityByName(name);local desire,target,shape=M.Souvenir(bot,ability)
        if desire>0 then if shape=='unit' then bot:Action_UseAbilityOnEntity(ability,target) else bot:Action_UseAbility(ability) end;return true end
    end
    return false
end
return M
