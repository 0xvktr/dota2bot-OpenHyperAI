local M={}
local J=require(GetScriptDirectory()..'/FunLib/jmz_func')
local poisonIntent=nil
function M.Range(bot,ability)
    local bonus=0
    for slot=0,5 do local item=bot:GetItemInSlot(slot);if item and not item:IsNull() and item:GetName()=='item_aether_lens' then bonus=item:GetSpecialValueInt('cast_range_bonus');break end end
    local supremacy=bot:GetAbilityByName('rubick_arcane_supremacy')
    if supremacy and not supremacy:IsNull() and supremacy:IsTrained() and not J.HasBreakModifier(bot) then bonus=bonus+supremacy:GetSpecialValueInt('cast_range') end
    return ability:GetCastRange()+bonus
end
local function handle(ability) return ability and not ability:IsNull() and ability:IsTrained() and not ability:IsHidden() and ability:IsActivated() end
local function banished(unit)
    if not unit or unit:IsNull() or not unit:IsAlive() then return false end
    local index=unit:GetModifierByName('modifier_shadow_demon_disruption')
    if index<0 then return false end
    local source=unit:GetModifierSourceAbility(index)
    return source and not source:IsNull() and source:GetName()=='shadow_demon_disruption'
end
local function live(unit) return J.IsValid(unit) or banished(unit) end
local function enemy(unit,immune)
    if not live(unit) or not unit:CanBeSeen() or J.IsSuspiciousIllusion(unit) then return false end
    if banished(unit) then return (immune or not unit:IsMagicImmune()) and not unit:HasModifier('modifier_abaddon_borrowed_time') and not unit:HasModifier('modifier_dazzle_shallow_grave') end
    return (immune and J.CanCastOnMagicImmune(unit) or not immune and J.CanCastOnNonMagicImmune(unit))
        and not unit:HasModifier('modifier_abaddon_borrowed_time') and not unit:HasModifier('modifier_dazzle_shallow_grave')
end
local function allies(bot,range)
    local list={bot};for _,unit in pairs(GetUnitList(UNIT_LIST_ALLIES)) do if unit~=bot and not unit:IsNull() and J.IsInRange(bot,unit,range) and (unit:IsHero() or string.find(unit:GetUnitName(),'lone_druid_bear')) then list[#list+1]=unit end end
    return list
end
local function attacked(bot,unit)
    for _,foe in pairs(J.GetNearbyHeroes(bot,1600,true,BOT_MODE_NONE)) do if J.IsValidHero(foe) and foe:GetAttackTarget()==unit then return true end end
    for _,tower in pairs(unit:GetNearbyTowers(900,true)) do if J.IsValid(tower) and tower:GetAttackTarget()==unit then return true end end
    return false
end
local function activeSourceEffect(unit,ability)
    for index=0,unit:NumModifiers()-1 do if unit:GetModifierSourceAbility(index)==ability and unit:GetModifierRemainingDuration(index)>1 then return true end end
    return false
end
local function ownEffect(unit,name,ability)
    local index=unit:GetModifierByName(name)
    return index>=0 and unit:GetModifierSourceAbility(index)==ability,index
end
function M.Disruption(bot,ability,saveOnly)
    if not J.CanCastAbility(ability) then return 0,nil end
    local range=M.Range(bot,ability)
    for _,unit in pairs(allies(bot,range)) do
        if J.IsValid(unit) and not unit:IsIllusion() and not unit:IsMagicImmune() and not unit:HasModifier('modifier_shadow_demon_disruption')
            and not unit:HasModifier('modifier_ringmaster_the_box_buff') and not unit:HasModifier('modifier_obsidian_destroyer_astral_imprisonment_prison') then
            local danger=unit:HasModifier('modifier_legion_commander_duel') or unit:HasModifier('modifier_enigma_black_hole_pull')
                or unit:HasModifier('modifier_faceless_void_chronosphere_freeze') or unit:HasModifier('modifier_necrolyte_reapers_scythe')
                or J.IsDoingTormentor(bot) and J.IsTormentor(J.GetProperTarget(bot)) and J.GetHP(unit)<.2
            if danger or J.GetHP(unit)<.35 and unit:WasRecentlyDamagedByAnyHero(2) and attacked(bot,unit) and not unit:IsChanneling()
                and not unit:HasModifier('modifier_teleporting') and not unit:HasModifier('modifier_abaddon_borrowed_time') and not unit:HasModifier('modifier_dazzle_shallow_grave') then return BOT_ACTION_DESIRE_HIGH,unit end
        end
    end
    if saveOnly then return 0,nil end
    for _,unit in pairs(J.GetNearbyHeroes(bot,math.min(range,1600),true,BOT_MODE_NONE)) do
        if enemy(unit) and not banished(unit) and J.CanCastOnTargetAdvanced(unit) and (unit:IsChanneling() or J.IsCastingUltimateAbility(unit)
            or not J.IsDisabled(unit) and (J.IsInTeamFight(bot,1200) and unit:GetAttackTarget()~=nil
                or J.IsRetreating(bot) and unit:GetAttackTarget()==bot)) then return BOT_ACTION_DESIRE_HIGH,unit end
    end
    return 0,nil
end
function M.Cleanse(bot,ability)
    if not J.CanCastAbility(ability) then return 0,nil end
    local range=M.Range(bot,ability)
    for _,unit in pairs(allies(bot,range)) do
        if live(unit) and not unit:IsIllusion() and not activeSourceEffect(unit,ability) and not unit:HasModifier('modifier_doom_bringer_doom') then
            local dispel=(unit:IsSilenced() or unit:IsRooted()) and not unit:IsHexed() and not unit:HasModifier('modifier_slark_pounce_leash') and not unit:HasModifier('modifier_grimstroke_soul_chain')
            local heal=J.GetHP(unit)<.5 and attacked(bot,unit) and not unit:HasModifier('modifier_abaddon_borrowed_time') and not unit:HasModifier('modifier_dazzle_shallow_grave')
            if dispel or heal then return BOT_ACTION_DESIRE_HIGH,unit end
        end
    end
    return 0,nil
end
function M.Purge(bot,ability)
    if not J.CanCastAbility(ability) then return 0,nil end
    local range=M.Range(bot,ability)
    for _,unit in pairs(GetUnitList(UNIT_LIST_ENEMY_HEROES)) do
        if enemy(unit,true) and J.IsInRange(bot,unit,range) and J.CanCastOnTargetAdvanced(unit) and not ownEffect(unit,'modifier_shadow_demon_purge_slow',ability) then
            if J.IsGoingOnSomeone(bot) and unit==J.GetProperTarget(bot) or J.IsInTeamFight(bot,1200)
                or J.IsRetreating(bot) and unit:GetAttackTarget()==bot
                or J.WillKillTarget(unit,ability:GetSpecialValueInt('purge_damage'),DAMAGE_TYPE_MAGICAL,ability:GetCastPoint()+ability:GetDuration()) then return BOT_ACTION_DESIRE_HIGH,unit end
        end
    end
    return 0,nil
end
function M.Disseminate(bot,ability)
    if not J.CanCastAbility(ability) then return 0,nil end
    local range=M.Range(bot,ability);local radius=ability:GetSpecialValueInt('radius')
    for _,unit in pairs(allies(bot,range)) do
        if J.IsValid(unit) and not unit:IsIllusion() and not unit:HasModifier('modifier_shadow_demon_disseminate') and attacked(bot,unit) then
            local count=0;for _,foe in pairs(J.GetEnemiesNearLoc(unit:GetLocation(),radius)) do if enemy(foe) and J.IsValidHero(foe) then count=count+1 end end
            if count>=2 then return BOT_ACTION_DESIRE_HIGH,unit end
        end
    end
    local target=J.GetProperTarget(bot)
    if enemy(target) and J.IsInRange(bot,target,range) and J.CanCastOnTargetAdvanced(target) and not target:HasModifier('modifier_shadow_demon_disseminate') then
        local count=0;for _,foe in pairs(J.GetEnemiesNearLoc(target:GetLocation(),radius)) do if enemy(foe) and J.IsValidHero(foe) then count=count+1 end end
        if count>=2 and (J.IsGoingOnSomeone(bot) or J.IsInTeamFight(bot,1200)) then return BOT_ACTION_DESIRE_HIGH,target end
    end
    return 0,nil
end
function M.Poison(bot,ability,native)
    if not J.CanCastAbility(ability) then return 0,nil end
    local range=M.Range(bot,ability)
    for _,unit in pairs(GetUnitList(UNIT_LIST_ENEMY_HEROES)) do
        if enemy(unit) and J.IsInRange(bot,unit,range) then
            local delay=ability:GetCastPoint()+GetUnitToUnitDistance(bot,unit)/ability:GetSpecialValueInt('speed')
            local point=unit:GetExtrapolatedLocation(delay)
            if banished(unit) then point=unit:GetLocation() end
            if GetUnitToLocationDistance(bot,point)<=range and (J.IsGoingOnSomeone(bot) and unit==J.GetProperTarget(bot)
                or J.IsLaning(bot) and J.GetMP(bot)>.65 and J.IsAllowedToSpam(bot,ability:GetManaCost())
                or J.IsInTeamFight(bot,1200) or J.WillKillTarget(unit,ability:GetSpecialValueInt('hit_damage'),DAMAGE_TYPE_MAGICAL,delay)) then return BOT_ACTION_DESIRE_HIGH,point end
        end
    end
    if native and J.IsAllowedToSpam(bot,ability:GetManaCost()) then
        local creeps=bot:GetNearbyCreeps(math.min(range,1600),true)
        if #creeps>=3 and (J.IsDefending(bot) or J.IsPushing(bot) or J.IsFarming(bot)) and enemy(creeps[1]) and not creeps[1]:HasModifier('modifier_fountain_glyph') then return BOT_ACTION_DESIRE_HIGH,creeps[1]:GetLocation() end
        local target=J.GetProperTarget(bot)
        if (J.IsDoingRoshan(bot) and J.IsRoshan(target) or J.IsDoingTormentor(bot) and J.IsTormentor(target)) and enemy(target) and J.IsInRange(bot,target,range) then return BOT_ACTION_DESIRE_HIGH,target:GetLocation() end
    end
    return 0,nil
end
function M.RecordPoison(bot,ability,point)
    poisonIntent={bot=bot,source=ability,point=point,origin=bot:GetLocation(),time=DotaTime()}
end
local function pending(bot,source,unit)
    local intent=poisonIntent
    if not intent or intent.bot~=bot or intent.source~=source or source:GetCooldownTimeRemaining()<=0 then return false end
    local origin=intent.origin;local point=intent.point;local dx,dy=point.x-origin.x,point.y-origin.y;local length=math.sqrt(dx*dx+dy*dy)
    if length==0 then return false end
    dx,dy=dx/length,dy/length;local location=unit:GetLocation();local x,y=location.x-origin.x,location.y-origin.y;local along=x*dx+y*dy
    return along>0 and along<=length+source:GetSpecialValueInt('radius') and math.abs(x*dy-y*dx)<=source:GetSpecialValueInt('radius')
        and DotaTime()<intent.time+source:GetCastPoint()+along/source:GetSpecialValueInt('speed')
end
function M.Release(bot,ability,native)
    if not J.CanCastAbility(ability) then return 0 end
    local source=bot:GetAbilityByName('shadow_demon_shadow_poison')
    if not handle(source) then return 0 end
    local units={};for _,unit in pairs(GetUnitList(UNIT_LIST_ENEMY_HEROES)) do units[#units+1]=unit end
    if native and (J.IsFarming(bot) or J.IsPushing(bot) or J.IsDefending(bot)) then for _,unit in pairs(bot:GetNearbyCreeps(1600,true)) do units[#units+1]=unit end end
    for _,unit in pairs(units) do
        if enemy(unit) then local own,index=ownEffect(unit,'modifier_shadow_demon_shadow_poison',source)
            if own then
                local stacks=unit:GetModifierStackCount(index);local max=source:GetSpecialValueInt('max_multiply_stacks')
                if stacks>0 then
                    local damage=source:GetSpecialValueInt('stack_damage')*2^(math.min(stacks,max)-1)+math.max(0,stacks-max)*source:GetSpecialValueInt('bonus_stack_damage')
                    local expires=unit:GetModifierRemainingDuration(index)<=ability:GetCastPoint()+.25
                    if J.WillKillTarget(unit,damage,DAMAGE_TYPE_MAGICAL,ability:GetCastPoint()) or expires
                        or stacks>=max and not pending(bot,source,unit) then return BOT_ACTION_DESIRE_HIGH end
                end
            end
        end
    end
    return 0
end
return M
