local M={}
local J=require(GetScriptDirectory()..'/FunLib/jmz_func')
local function valid(u)
    return J.IsValidHero(u) and u:CanBeSeen() and not J.IsSuspiciousIllusion(u) and J.CanCastOnMagicImmune(u)
        and not u:HasModifier('modifier_abaddon_borrowed_time') and not u:HasModifier('modifier_necrolyte_reapers_scythe')
end
function M.Range(bot,a)
    local bonus=0
    for slot=0,5 do local item=bot:GetItemInSlot(slot);if item and not item:IsNull() and item:GetName()=='item_aether_lens' then bonus=item:GetSpecialValueInt('cast_range_bonus');break end end
    local s=bot:GetAbilityByName('rubick_arcane_supremacy')
    if s and not s:IsNull() and s:IsTrained() and not J.HasBreakModifier(bot) then bonus=bonus+s:GetSpecialValueInt('cast_range') end
    return a:GetCastRange()+bonus
end
local function peel(bot,u)
    local ally=u:GetAttackTarget()
    return J.IsValidHero(ally) and ally:GetTeam()==bot:GetTeam() and ally:WasRecentlyDamagedByAnyHero(2)
end
local function useful(bot,u)
    return J.IsGoingOnSomeone(bot) and u==J.GetProperTarget(bot) or J.IsInTeamFight(bot,1200)
        or J.IsRetreating(bot) and u:GetAttackTarget()==bot or peel(bot,u)
end
function M.Global(bot,a)
    if not J.CanCastAbility(a) then return 0 end
    local enemies=GetUnitList(UNIT_LIST_ENEMY_HEROES)
    for _,u in pairs(enemies) do
        if valid(u) and not u:IsSilenced() then
            local active=u:GetCurrentActiveAbility()
            if u:IsChanneling() and active and not active:IsNull() and active:GetName()~='item_tpscroll'
                and active:GetName()~='item_travel_boots' and active:GetName()~='item_travel_boots_2' then return BOT_ACTION_DESIRE_HIGH end
        end
    end
    local engaged=0
    local allies=GetUnitList(UNIT_LIST_ALLIED_HEROES)
    for _,u in pairs(enemies) do
        if valid(u) and not u:IsSilenced() then
            if peel(bot,u) then
                local ally=u:GetAttackTarget()
                if J.GetHP(ally)<.4 and (u:IsCastingAbility() or u:IsUsingAbility()) then return BOT_ACTION_DESIRE_HIGH end
                if u:IsCastingAbility() or u:IsUsingAbility() then engaged=engaged+1 end
            end
            for _,ally in pairs(allies) do
                local channel=J.IsValidHero(ally) and ally:GetCurrentActiveAbility()
                if channel and not channel:IsNull() and ally:IsChanneling()
                    and (channel:GetName()=='enigma_black_hole' or channel:GetName()=='witch_doctor_death_ward' or channel:GetName()=='crystal_maiden_freezing_field')
                    and GetUnitToUnitDistance(ally,u)<=900 then return BOT_ACTION_DESIRE_HIGH end
            end
        end
    end
    if engaged>=2 and J.IsInTeamFight(bot,1600) then return BOT_ACTION_DESIRE_HIGH end
    return 0
end
function M.Curse(bot,a,native)
    if not J.CanCastAbility(a) then return 0 end
    local range,radius,delay=M.Range(bot,a),a:GetSpecialValueInt('radius'),a:GetCastPoint()
    for _,u in pairs(GetUnitList(UNIT_LIST_ENEMY_HEROES)) do
        if valid(u) and J.CanCastOnNonMagicImmune(u) and not u:HasModifier('modifier_silencer_curse_of_the_silent') then
            local p=u:GetExtrapolatedLocation(delay);local distance=GetUnitToLocationDistance(bot,p)
            if distance<=range+radius then
                if distance>range then p=bot:GetLocation()+(p-bot:GetLocation())*(range/distance) end
                if J.WillKillTarget(u,a:GetSpecialValueInt('application_damage'),DAMAGE_TYPE_MAGICAL,delay) or useful(bot,u) then return BOT_ACTION_DESIRE_HIGH,p end
            end
        end
    end
    if native and J.IsAllowedToSpam(bot,a:GetManaCost()) then
        local creeps=J.IsFarming(bot) and bot:GetNearbyNeutralCreeps(math.min(range+radius,1600)) or bot:GetNearbyLaneCreeps(math.min(range+radius,1600),true)
        for _,u in pairs(creeps) do
            if J.IsValid(u) and J.CanCastOnNonMagicImmune(u) and J.IsInRange(bot,u,range) then
                local count=0;for _,c in pairs(creeps) do if J.IsValid(c) and GetUnitToUnitDistance(u,c)<=radius then count=count+1 end end
                if (J.IsFarming(bot) or J.IsPushing(bot) or J.IsDefending(bot)) and count>=3
                    or J.IsLaning(bot) and u:GetUnitName():find('ranged') and J.WillKillTarget(u,a:GetSpecialValueInt('application_damage'),DAMAGE_TYPE_MAGICAL,delay) then return BOT_ACTION_DESIRE_HIGH,u:GetLocation() end
            end
        end
    end
    return 0
end
function M.Word(bot,a)
    if not J.CanCastAbility(a) then return 0 end
    local range=M.Range(bot,a);local point=J.CheckBitfieldFlag(a:GetBehavior(),ABILITY_BEHAVIOR_POINT)
    for _,u in pairs(GetUnitList(UNIT_LIST_ENEMY_HEROES)) do
        if valid(u) and J.CanCastOnNonMagicImmune(u) and (point or J.CanCastOnTargetAdvanced(u))
            and J.IsInRange(bot,u,range) and not u:HasModifier('modifier_silencer_last_word') then
            local damage=a:GetSpecialValueInt('damage')+math.max(0,bot:GetAttributeValue(ATTRIBUTE_INTELLECT)-u:GetAttributeValue(ATTRIBUTE_INTELLECT))*a:GetSpecialValueFloat('int_multiplier')
            local delay=a:GetCastPoint()+a:GetSpecialValueFloat('debuff_duration')
            if J.WillKillTarget(u,damage,DAMAGE_TYPE_MAGICAL,delay) or useful(bot,u) then
                local target=u
                if point then
                    target=u:GetExtrapolatedLocation(a:GetCastPoint());local distance=GetUnitToLocationDistance(bot,target)
                    if distance>range+a:GetSpecialValueInt('radius') then target=nil
                    elseif distance>range then target=bot:GetLocation()+(target-bot:GetLocation())*(range/distance) end
                end
                if target then return BOT_ACTION_DESIRE_HIGH,target,point end
            end
        end
    end
    return 0
end
function M.Glaives(bot,a,native)
    if not J.CanCastAbility(a) or bot:IsDisarmed() then return 0 end
    local range=bot:GetAttackRange();local bonus=bot:GetAttributeValue(ATTRIBUTE_INTELLECT)*a:GetSpecialValueFloat('intellect_damage_pct')/100
    local function kill(u) return J.WillMixedDamageKillTarget(u,bot:GetAttackDamage(),bonus,0,J.GetAttackProDelayTime(bot,u)) end
    for _,u in pairs(J.GetNearbyHeroes(bot,math.min(range,1600),true,BOT_MODE_NONE)) do
        if valid(u) and J.IsInRange(bot,u,range) and J.CanBeAttacked(u) and J.CanCastOnNonMagicImmune(u)
            and (kill(u) or useful(bot,u) or J.IsLaning(bot) and J.GetMP(bot)>.5) then return BOT_ACTION_DESIRE_HIGH,u end
    end
    if native then
        for _,u in pairs(bot:GetNearbyLaneCreeps(math.min(range,1600),true)) do
            if J.IsValid(u) and J.CanBeAttacked(u) and J.IsInRange(bot,u,range) and kill(u) then return BOT_ACTION_DESIRE_HIGH,u end
        end
        local u=J.GetProperTarget(bot)
        if (J.IsDoingRoshan(bot) and J.IsRoshan(u) or J.IsDoingTormentor(bot) and J.IsTormentor(u))
            and J.IsValid(u) and J.CanBeAttacked(u) and J.CanCastOnNonMagicImmune(u) and J.IsInRange(bot,u,range) and J.GetMP(bot)>.4 then return BOT_ACTION_DESIRE_HIGH,u end
    end
    return 0
end
return M
