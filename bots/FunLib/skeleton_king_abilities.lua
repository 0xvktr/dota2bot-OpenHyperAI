local M={}
local J=require(GetScriptDirectory()..'/FunLib/jmz_func')
local function valid(u)
    return J.IsValidHero(u) and not J.IsSuspiciousIllusion(u) and J.CanCastOnNonMagicImmune(u)
        and not u:HasModifier('modifier_abaddon_borrowed_time') and not u:HasModifier('modifier_necrolyte_reapers_scythe')
        and not u:HasModifier('modifier_dazzle_shallow_grave') and not u:HasModifier('modifier_oracle_false_promise_timer')
end
function M.Range(bot,a)
    local bonus=0
    for slot=0,5 do local item=bot:GetItemInSlot(slot);if item and not item:IsNull() and item:GetName()=='item_aether_lens' then bonus=item:GetSpecialValueInt('cast_range_bonus');break end end
    local s=bot:GetAbilityByName('rubick_arcane_supremacy')
    if s and not s:IsNull() and s:IsTrained() and not J.HasBreakModifier(bot) then bonus=bonus+s:GetSpecialValueInt('cast_range') end
    return a:GetCastRange()+bonus
end
local function reserve(bot,a)
    local r=bot:GetAbilityByName('skeleton_king_reincarnation')
    return J.CanCastAbility(r) and r:GetManaCost()>0 and not bot:HasModifier('modifier_skeleton_king_reincarnation_scepter_active')
        and bot:GetMana()-a:GetManaCost()<r:GetManaCost() and #J.GetNearbyHeroes(bot,1200,true,BOT_MODE_NONE)>0
end
local function peel(bot,u)
    local ally=u:GetAttackTarget()
    return J.IsValidHero(ally) and ally:GetTeam()==bot:GetTeam() and ally:WasRecentlyDamagedByAnyHero(2)
end
function M.Blast(bot,a,urgent)
    if not J.CanCastAbility(a) then return 0 end
    local range=M.Range(bot,a)
    for _,u in pairs(J.GetNearbyHeroes(bot,math.min(range,1600),true,BOT_MODE_NONE)) do
        if valid(u) and J.CanCastOnTargetAdvanced(u) and J.IsInRange(bot,u,range) then
            local delay=a:GetCastPoint()+GetUnitToUnitDistance(bot,u)/math.max(a:GetSpecialValueInt('blast_speed'),1)
            if u:IsChanneling() or J.WillKillTarget(u,a:GetSpecialValueInt('damage'),DAMAGE_TYPE_MAGICAL,delay)
                or peel(bot,u) and not J.IsDisabled(u) then return BOT_ACTION_DESIRE_HIGH,u end
            if not urgent and not reserve(bot,a) and not J.IsDisabled(u)
                and (J.IsGoingOnSomeone(bot) and u==J.GetProperTarget(bot) or J.IsInTeamFight(bot,1200)
                    or J.IsRetreating(bot) and u:GetAttackTarget()==bot) then return BOT_ACTION_DESIRE_HIGH,u end
        end
    end
    if not urgent and not reserve(bot,a) then
        local u=J.GetProperTarget(bot)
        if (J.IsDoingRoshan(bot) and J.IsRoshan(u) or J.IsDoingTormentor(bot) and J.IsTormentor(u))
            and J.IsValid(u) and J.CanCastOnNonMagicImmune(u) and J.CanCastOnTargetAdvanced(u) and J.IsInRange(bot,u,range)
            and J.GetMP(bot)>.5 then return BOT_ACTION_DESIRE_HIGH,u end
    end
    return 0
end
function M.Guard(bot,a,native)
    if not J.CanCastAbility(a) or reserve(bot,a) then return 0 end
    local index=bot:GetModifierByName('modifier_skeleton_king_bone_guard')
    local charges=index>=0 and bot:GetModifierSourceAbility(index)==a and bot:GetModifierStackCount(index) or 0
    local minimum=a:GetSpecialValueInt('min_skeleton_spawn')
    if charges<=0 and minimum<=0 then return 0 end
    local count=math.max(charges,minimum)
    local u=J.GetProperTarget(bot)
    if J.IsValidHero(u) and J.CanBeAttacked(u) and not J.IsSuspiciousIllusion(u) and J.IsInRange(bot,u,700)
        and (J.IsGoingOnSomeone(bot) or J.IsInTeamFight(bot,1200)) and count>=2 then return BOT_ACTION_DESIRE_HIGH end
    for _,enemy in pairs(J.GetNearbyHeroes(bot,650,true,BOT_MODE_NONE)) do
        if J.IsValidHero(enemy) and J.CanBeAttacked(enemy) and not J.IsSuspiciousIllusion(enemy) and peel(bot,enemy)
            and count>=2 then return BOT_ACTION_DESIRE_HIGH end
    end
    if native and J.IsAllowedToSpam(bot,a:GetManaCost()) then
        if J.IsFarming(bot) or J.IsPushing(bot) or J.IsDefending(bot) then
            local max=a:GetSpecialValueInt('max_skeleton_charges')
            if count>=math.min(5,max) then
                local creeps=bot:GetNearbyLaneCreeps(700,true);local neutrals=bot:GetNearbyNeutralCreeps(700)
                if #creeps>=2 or #neutrals>=2 then return BOT_ACTION_DESIRE_HIGH end
                if J.IsPushing(bot) then
                    for _,tower in pairs(bot:GetNearbyTowers(700,true)) do
                        if J.IsValidBuilding(tower) and J.CanBeAttacked(tower) and not tower:HasModifier('modifier_fountain_glyph')
                            and not tower:HasModifier('modifier_backdoor_protection_active') then return BOT_ACTION_DESIRE_HIGH end
                    end
                end
            end
        end
        if (J.IsDoingRoshan(bot) and J.IsRoshan(u) or J.IsDoingTormentor(bot) and J.IsTormentor(u))
            and J.IsValid(u) and J.CanBeAttacked(u) and J.IsInRange(bot,u,700) and count>=2 then return BOT_ACTION_DESIRE_HIGH end
    end
    return 0
end
function M.Reincarnate(bot,a)
    if not J.CanCastAbility(a) or bot:HasModifier('modifier_skeleton_king_reincarnation_scepter_active')
        or bot:HasModifier('modifier_dazzle_shallow_grave') or bot:HasModifier('modifier_oracle_false_promise_timer')
        or bot:HasModifier('modifier_abaddon_borrowed_time') or J.GetHP(bot)>=.12
        or not bot:WasRecentlyDamagedByAnyHero(2) or bot:GetMana()>a:GetManaCost()+100 then return 0 end
    local allies=0
    for _,u in pairs(J.GetNearbyHeroes(bot,650,false,BOT_MODE_NONE)) do
        if u~=bot and J.IsValidHero(u) and not u:IsIllusion() then allies=allies+1 end
    end
    if allies==0 then return 0 end
    local enemies=J.GetNearbyHeroes(bot,650,true,BOT_MODE_NONE);local pressure=false
    for _,u in pairs(enemies) do
        if J.IsValidHero(u) and not J.IsSuspiciousIllusion(u) and u:GetAttackTarget()==bot then pressure=true end
    end
    if pressure and #enemies<=allies+1 then return BOT_ACTION_DESIRE_HIGH,bot end
    return 0
end
return M
