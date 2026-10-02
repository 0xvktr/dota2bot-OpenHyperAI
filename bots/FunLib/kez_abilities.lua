local K={}
local J=require(GetScriptDirectory()..'/FunLib/jmz_func')
function K.Range(bot,ability)
    local bonus=0
    for slot=0,5 do local item=bot:GetItemInSlot(slot);if item and item:GetName()=='item_aether_lens' then bonus=item:GetSpecialValueInt('cast_range_bonus');break end end
    local supremacy=bot:GetAbilityByName('rubick_arcane_supremacy')
    if supremacy and supremacy:IsTrained() and not J.HasBreakModifier(bot) then bonus=bonus+supremacy:GetSpecialValueInt('cast_range') end
    return ability:GetCastRange()+bonus
end
local function safeDamage(enemy)
    return J.IsValidHero(enemy) and not J.IsSuspiciousIllusion(enemy)
        and not enemy:HasModifier('modifier_abaddon_borrowed_time') and not enemy:HasModifier('modifier_dazzle_shallow_grave')
        and not enemy:HasModifier('modifier_oracle_false_promise_timer') and not enemy:HasModifier('modifier_troll_warlord_battle_trance')
end
local function physical(enemy) return safeDamage(enemy) and J.CanBeAttacked(enemy) end
local function mobile(bot)
    return not bot:IsRooted() and not bot:HasModifier('modifier_bloodseeker_rupture')
        and not bot:HasModifier('modifier_slark_pounce_leash') and not bot:HasModifier('modifier_puck_coiled')
end
function K.Echo(bot,ability)
    if not J.CanCastAbility(ability) or bot:IsDisarmed() then return 0 end
    local range=ability:GetSpecialValueInt('katana_distance')
    local damage=bot:GetAttackDamage()*ability:GetSpecialValueInt('katana_echo_damage')/100+ability:GetSpecialValueInt('echo_hero_damage')
    for _,enemy in pairs(J.GetNearbyHeroes(bot,math.min(range,1600),true,BOT_MODE_NONE)) do
        local point=enemy:GetExtrapolatedLocation(ability:GetCastPoint())
        if physical(enemy) and GetUnitToLocationDistance(bot,point)<=range and bot:IsFacingLocation(point,12)
            and (J.CanKillTarget(enemy,damage,DAMAGE_TYPE_PHYSICAL)
                or J.IsGoingOnSomeone(bot) and enemy==J.GetProperTarget(bot)
                or J.IsInTeamFight(bot,1200)) then return BOT_ACTION_DESIRE_HIGH end
    end
    return 0
end
function K.Raptor(bot,ability)
    if not J.CanCastAbility(ability) then return 0 end
    local count=0;local heal=0
    for _,enemy in pairs(J.GetNearbyHeroes(bot,math.min(ability:GetSpecialValueInt('radius')+400,1600),true,BOT_MODE_NONE)) do
        if safeDamage(enemy) and J.CanCastOnMagicImmune(enemy)
            and GetUnitToLocationDistance(bot,enemy:GetExtrapolatedLocation(ability:GetCastPoint()))<=ability:GetSpecialValueInt('radius') then
            local damage=ability:GetSpecialValueInt('base_damage')+ability:GetSpecialValueFloat('max_health_damage_pct')*enemy:GetMaxHealth()/100
            count=count+1;heal=heal+damage
            -- Later slashes require the target to remain in the circle; the first hit is the reliable kill test.
            if J.CanKillTarget(enemy,damage,DAMAGE_TYPE_PURE) then return BOT_ACTION_DESIRE_HIGH end
        end
    end
    if count>=2 and J.IsInTeamFight(bot,1200) or count>0 and bot:IsRooted()
        or count>0 and (J.IsGoingOnSomeone(bot) or J.IsRetreating(bot)) and J.GetHP(bot)<0.6
            and not bot:HasModifier('modifier_ice_blast') and heal>0 then return BOT_ACTION_DESIRE_HIGH end
    return 0
end
function K.Katana(bot,ability)
    if not J.CanCastAbility(ability) or bot:IsDisarmed() then return 0,nil end
    for _,enemy in pairs(J.GetNearbyHeroes(bot,math.min(K.Range(bot,ability),1600),true,BOT_MODE_NONE)) do
        if physical(enemy) and J.CanCastOnMagicImmune(enemy) and J.CanCastOnTargetAdvanced(enemy)
            and not enemy:HasModifier('modifier_kez_katana_shard_debuff') then
            if enemy:IsChanneling() or J.IsGoingOnSomeone(bot) and enemy==J.GetProperTarget(bot)
                or J.IsRetreating(bot) and enemy:GetAttackTarget()==bot then return BOT_ACTION_DESIRE_HIGH,enemy end
        end
    end
    return 0,nil
end
function K.Toss(bot,ability)
    if not J.CanCastAbility(ability) or bot:IsDisarmed() then return 0,nil end
    for _,enemy in pairs(J.GetNearbyHeroes(bot,math.min(K.Range(bot,ability),1600),true,BOT_MODE_NONE)) do
        if physical(enemy) and J.CanCastOnNonMagicImmune(enemy) and J.CanCastOnTargetAdvanced(enemy)
            and (enemy:IsChanneling() or J.CanKillTarget(enemy,ability:GetSpecialValueInt('damage'),DAMAGE_TYPE_PHYSICAL)
                or not enemy:IsSilenced() and not J.IsDisabled(enemy)
                    and (J.IsGoingOnSomeone(bot) and enemy==J.GetProperTarget(bot)
                        or J.IsInTeamFight(bot,1200) or J.IsRetreating(bot) and enemy:GetAttackTarget()==bot)) then
            return BOT_ACTION_DESIRE_HIGH,enemy
        end
    end
    return 0,nil
end
function K.Falcon(bot,ability)
    if not J.CanCastAbility(ability) or bot:IsDisarmed() or not mobile(bot)
        or bot:HasModifier('modifier_kez_falcon_rush') then return 0 end
    local target=J.GetProperTarget(bot)
    if physical(target) and J.IsGoingOnSomeone(bot) and J.IsInRange(bot,target,ability:GetSpecialValueInt('rush_range'))
        and not J.IsEnemyBlackHoleInLocation(target:GetLocation()) and not J.IsEnemyChronosphereInLocation(target:GetLocation()) then return BOT_ACTION_DESIRE_HIGH end
    return 0
end
function K.Parry(bot,ability)
    if not J.CanCastAbility(ability) or bot:HasModifier('modifier_kez_shodo_sai_parry') or J.IsRealInvisible(bot) then return 0,nil end
    for _,enemy in pairs(J.GetNearbyHeroes(bot,1200,true,BOT_MODE_NONE)) do
        if J.IsValidHero(enemy) and not J.IsSuspiciousIllusion(enemy) and not J.IsDisabled(enemy) and not enemy:IsDisarmed()
            and enemy:GetAttackTarget()==bot and J.IsInRange(bot,enemy,enemy:GetAttackRange()+100) then return BOT_ACTION_DESIRE_HIGH,enemy:GetLocation() end
    end
    return 0,nil
end
function K.Cancel(bot,ability)
    if not J.CanCastAbility(ability) or not bot:HasModifier('modifier_kez_shodo_sai_parry') or not J.IsRetreating(bot) then return 0 end
    for _,enemy in pairs(J.GetNearbyHeroes(bot,1200,true,BOT_MODE_NONE)) do
        if J.IsValidHero(enemy) and not J.IsDisabled(enemy) and enemy:GetAttackTarget()==bot
            and J.IsInRange(bot,enemy,enemy:GetAttackRange()+100) then return 0 end
    end
    return BOT_ACTION_DESIRE_HIGH
end
function K.Veil(bot,ability,defensiveOnly)
    if not J.CanCastAbility(ability) or bot:HasModifier('modifier_kez_ravens_veil_buff') or J.IsRealInvisible(bot) then return 0 end
    local enemies=J.GetNearbyHeroes(bot,math.min(ability:GetSpecialValueInt('blast_radius'),1600),true,BOT_MODE_NONE)
    if #enemies>0 and J.IsRetreating(bot) and (bot:WasRecentlyDamagedByAnyHero(3) or bot:IsRooted()) then return BOT_ACTION_DESIRE_HIGH end
    if defensiveOnly then return 0 end
    local count=0
    for _,enemy in pairs(enemies) do
        if safeDamage(enemy) and not enemy:HasModifier('modifier_kez_shodo_sai_mark') then
            count=count+1
            if J.IsGoingOnSomeone(bot) and enemy==J.GetProperTarget(bot) and J.IsInRange(bot,enemy,600) then return BOT_ACTION_DESIRE_HIGH end
        end
    end
    if count>=2 and J.IsInTeamFight(bot,1200) then return BOT_ACTION_DESIRE_HIGH end
    return 0
end
function K.Claw(bot,ability)
    if not J.CanCastAbility(ability) or not mobile(bot) or bot:IsDisarmed() then return 0,nil,nil end
    local range=K.Range(bot,ability)
    if J.IsRetreating(bot) and not J.IsRealInvisible(bot) and bot:WasRecentlyDamagedByAnyHero(3) then
        local target,kind=K.RetreatTarget(bot,range)
        if target then return BOT_ACTION_DESIRE_HIGH,target,kind end
    end
    local target=J.GetProperTarget(bot)
    if physical(target) and J.CanCastOnNonMagicImmune(target) and J.CanCastOnTargetAdvanced(target)
        and J.IsGoingOnSomeone(bot) and J.IsInRange(bot,target,range) and not J.IsInRange(bot,target,250)
        and not J.IsEnemyChronosphereInLocation(target:GetLocation()) and not J.IsEnemyBlackHoleInLocation(target:GetLocation()) then
        return BOT_ACTION_DESIRE_HIGH,target,'unit'
    end
    return 0,nil,nil
end
function K.RetreatTarget(bot,range)
    local origin=bot:GetLocation();local fountain=J.GetTeamFountain()
    local fx,fy=fountain.x-origin.x,fountain.y-origin.y;local fl=math.sqrt(fx*fx+fy*fy)
    if fl==0 then return nil,nil end
    local best,kind,bestDistance=nil,nil,0
    local oldThreats=#J.GetEnemiesNearLoc(origin,700)
    local function candidate(handle,point,shape)
        local dx,dy=point.x-origin.x,point.y-origin.y;local length=math.sqrt(dx*dx+dy*dy)
        if length>range*0.4 and length<=range and length>bestDistance and (dx*fx+dy*fy)/(length*fl)>=math.cos(math.rad(45))
            and IsLocationPassable(point) and not J.IsEnemyChronosphereInLocation(point) and not J.IsEnemyBlackHoleInLocation(point)
            and #J.GetEnemiesNearLoc(point,700)<=oldThreats then best=handle;kind=shape;bestDistance=length end
    end
    for _,tree in pairs(bot:GetNearbyTrees(math.min(range,1600))) do candidate(tree,GetTreeLocation(tree),'tree') end
    for _,creep in pairs(bot:GetNearbyCreeps(math.min(range,1600),true)) do
        if J.IsValid(creep) and J.CanCastOnNonMagicImmune(creep) and J.CanCastOnTargetAdvanced(creep) then candidate(creep,creep:GetLocation(),'unit') end
    end
    return best,kind
end
return K
