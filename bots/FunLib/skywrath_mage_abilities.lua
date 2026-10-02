local M={}
local J=require(GetScriptDirectory()..'/FunLib/jmz_func')
local function valid(u,pierce)
    return J.IsValidHero(u) and not J.IsSuspiciousIllusion(u)
        and (pierce and J.CanCastOnMagicImmune(u) or not pierce and J.CanCastOnNonMagicImmune(u))
        and not u:HasModifier('modifier_abaddon_borrowed_time') and not u:HasModifier('modifier_dazzle_shallow_grave')
        and not u:HasModifier('modifier_oracle_false_promise_timer') and not u:HasModifier('modifier_necrolyte_reapers_scythe')
        and not u:HasModifier('modifier_item_blade_mail_reflect') and not u:HasModifier('modifier_nyx_assassin_spiked_carapace')
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
local function allyMagic(bot,u)
    for _,ally in pairs(J.GetNearbyHeroes(bot,1600,false,BOT_MODE_NONE)) do
        local active=ally:GetCurrentActiveAbility()
        if J.IsValidHero(ally) and not ally:IsIllusion() and active and not active:IsNull()
            and (ally:IsCastingAbility() or ally:IsUsingAbility() or ally:IsChanneling())
            and active:GetDamageType()==DAMAGE_TYPE_MAGICAL and GetUnitToUnitDistance(ally,u)<=1000 then return true end
    end
    return false
end
function M.Seal(bot,a)
    if not J.CanCastAbility(a) then return 0 end
    local range=M.Range(bot,a)
    for _,u in pairs(GetUnitList(UNIT_LIST_ENEMY_HEROES)) do
        if valid(u,false) and J.IsInRange(bot,u,range) and J.CanCastOnTargetAdvanced(u)
            and not u:HasModifier('modifier_skywrath_mage_ancient_seal') then
            if u:IsChanneling() or peel(bot,u) and not u:IsSilenced() then return BOT_ACTION_DESIRE_HIGH,u end
            local follow=allyMagic(bot,u)
            for _,name in ipairs({'skywrath_mage_arcane_bolt','skywrath_mage_concussive_shot','skywrath_mage_mystic_flare'}) do
                local sibling=bot:GetAbilityByName(name)
                if J.CanCastAbility(sibling) and bot:GetMana()>=a:GetManaCost()+sibling:GetManaCost() then
                    if name=='skywrath_mage_arcane_bolt' and J.IsInRange(bot,u,M.Range(bot,sibling))
                        or name=='skywrath_mage_concussive_shot' and M.Concussive(bot,sibling)>0
                        or name=='skywrath_mage_mystic_flare' and M.Flare(bot,sibling)>0 then follow=true end
                end
            end
            if useful(bot,u) and (not u:IsSilenced() or follow) then return BOT_ACTION_DESIRE_HIGH,u end
        end
    end
    return 0
end
function M.Bolt(bot,a,native)
    if not J.CanCastAbility(a) then return 0 end
    local range=M.Range(bot,a);local damage=a:GetSpecialValueInt('bolt_damage')+bot:GetAttributeValue(ATTRIBUTE_INTELLECT)*a:GetSpecialValueFloat('int_multiplier')
    local function lethal(u) return J.WillKillTarget(u,damage,DAMAGE_TYPE_MAGICAL,a:GetCastPoint()+GetUnitToUnitDistance(bot,u)/math.max(a:GetSpecialValueInt('bolt_speed'),1)) end
    for _,u in pairs(GetUnitList(UNIT_LIST_ENEMY_HEROES)) do
        if valid(u,a:GetSpecialValueInt('pierce_spell_immunity')>0) and J.CanCastOnTargetAdvanced(u) and J.IsInRange(bot,u,range)
            and (lethal(u) or useful(bot,u) or J.IsLaning(bot) and J.GetMP(bot)>.6) then return BOT_ACTION_DESIRE_HIGH,u end
    end
    if native and J.IsAllowedToSpam(bot,a:GetManaCost()) then
        local creeps=bot:GetNearbyLaneCreeps(math.min(range,1600),true)
        if J.IsFarming(bot) and #creeps<3 then creeps=bot:GetNearbyNeutralCreeps(math.min(range,1600)) end
        for _,u in pairs(creeps) do
            if J.IsValid(u) and J.CanCastOnNonMagicImmune(u) and J.CanCastOnTargetAdvanced(u) and J.IsInRange(bot,u,range)
                and not u:HasModifier('modifier_fountain_glyph')
                and ((J.IsLaning(bot) or J.IsDefending(bot)) and u:GetUnitName():find('ranged') and lethal(u)
                    or J.IsFarming(bot) and #creeps>=3) then return BOT_ACTION_DESIRE_HIGH,u end
        end
        local u=J.GetProperTarget(bot)
        if (J.IsDoingRoshan(bot) and J.IsRoshan(u) or J.IsDoingTormentor(bot) and J.IsTormentor(u))
            and J.IsValid(u) and J.CanCastOnNonMagicImmune(u) and J.CanCastOnTargetAdvanced(u) and J.IsInRange(bot,u,range)
            and J.GetMP(bot)>.4 then return BOT_ACTION_DESIRE_HIGH,u end
    end
    return 0
end
function M.Concussive(bot,a,native)
    if not J.CanCastAbility(a) then return 0 end
    local range=a:GetSpecialValueInt('launch_global')>0 and math.huge or a:GetSpecialValueInt('launch_radius')
    local closest,distance=nil,math.huge
    for _,u in pairs(GetUnitList(UNIT_LIST_ENEMIES)) do
        if J.IsValid(u) and u:CanBeSeen() and not u:IsInvulnerable()
            and (u:IsHero() or u:GetUnitName():find('lone_druid_bear')) then
            local d=GetUnitToUnitDistance(bot,u);if d<=range and d<distance then closest=u;distance=d end
        end
    end
    if closest then
        if J.CanCastOnNonMagicImmune(closest) and not J.IsSuspiciousIllusion(closest)
            and not closest:HasModifier('modifier_item_blade_mail_reflect') and not closest:HasModifier('modifier_nyx_assassin_spiked_carapace') then
            local delay=a:GetCastPoint()+distance/math.max(a:GetSpecialValueInt('speed'),1)
            if J.WillKillTarget(closest,a:GetSpecialValueInt('damage'),DAMAGE_TYPE_MAGICAL,delay) or useful(bot,closest) then return BOT_ACTION_DESIRE_HIGH end
            local impact=closest:GetExtrapolatedLocation(delay)
            for _,u in pairs(GetUnitList(UNIT_LIST_ENEMY_HEROES)) do
                if valid(u,false) and useful(bot,u) and GetUnitToLocationDistance(u,impact)<=a:GetSpecialValueInt('slow_radius') then return BOT_ACTION_DESIRE_HIGH end
            end
        end
        return 0
    end
    if native and (J.IsFarming(bot) or J.IsPushing(bot) or J.IsDefending(bot)) and J.IsAllowedToSpam(bot,a:GetManaCost()) then
        for _,u in pairs(GetUnitList(UNIT_LIST_ENEMIES)) do
            if J.IsValid(u) and u:CanBeSeen() and not u:IsBuilding() and not u:IsHero() and J.CanCastOnNonMagicImmune(u) then
                local d=GetUnitToUnitDistance(bot,u);if d<=range and d<distance then closest=u;distance=d end
            end
        end
        if closest then
            local count=0
            for _,u in pairs(GetUnitList(UNIT_LIST_ENEMIES)) do
                if J.IsValid(u) and not u:IsHero() and not u:IsBuilding() and J.CanCastOnNonMagicImmune(u)
                    and GetUnitToUnitDistance(u,closest)<=a:GetSpecialValueInt('slow_radius') then count=count+1 end
            end
            if count>=3 then return BOT_ACTION_DESIRE_HIGH end
        end
    end
    return 0
end
local holds={'modifier_stunned','modifier_bashed','modifier_rod_of_atos_debuff','modifier_item_gungir_root',
    'modifier_shadow_shaman_shackles','modifier_shadow_shaman_voodoo','modifier_lion_voodoo','modifier_crystal_maiden_frostbite',
    'modifier_enigma_black_hole_pull','modifier_faceless_void_chronosphere_freeze','modifier_legion_commander_duel'}
local function hold(u)
    local time=0;for _,name in ipairs(holds) do if u:HasModifier(name) then time=math.max(time,J.GetModifierTime(u,name)) end end
    return time
end
function M.Flare(bot,a)
    if not J.CanCastAbility(a) then return 0 end
    local range,radius,cast=M.Range(bot,a),a:GetSpecialValueInt('radius'),a:GetCastPoint()
    local enemies=GetUnitList(UNIT_LIST_ENEMY_HEROES)
    for _,u in pairs(enemies) do
        if valid(u,false) and u:GetUnitName():find('lone_druid_bear')==nil then
            local point=u:GetExtrapolatedLocation(cast);local distance=GetUnitToLocationDistance(bot,point)
            if distance<=range+radius then
                if distance>range then point=bot:GetLocation()+(point-bot:GetLocation())*(range/distance) end
                local count,safe=0,true
                for _,other in pairs(enemies) do
                    if J.IsValidHero(other) and other:CanBeSeen() and not other:IsIllusion() and not other:IsInvulnerable()
                        and not other:GetUnitName():find('lone_druid_bear')
                        and (other:GetExtrapolatedLocation(cast)-point):Length2D()<=radius then
                        count=count+1
                        if other:HasModifier('modifier_item_blade_mail_reflect') or other:HasModifier('modifier_nyx_assassin_spiked_carapace') then safe=false end
                    end
                end
                local dwell=math.min(a:GetSpecialValueFloat('duration'),math.max(.1,hold(u)-cast))
                local damage=a:GetSpecialValueInt('damage')*dwell/math.max(a:GetSpecialValueFloat('duration'),.1)/math.max(count,1)
                if safe and count>0 and (J.WillKillTarget(u,damage,DAMAGE_TYPE_MAGICAL,cast+dwell)
                    or hold(u)>=cast+.75 and (useful(bot,u) or allyMagic(bot,u))) then return BOT_ACTION_DESIRE_HIGH,point end
            end
        end
    end
    if J.IsInTeamFight(bot,1200) then
        for _,u in pairs(enemies) do
            if J.IsValidHero(u) and u:CanBeSeen() and u:IsIllusion() and not u:IsInvulnerable() and not u:IsMagicImmune() then
                local point=u:GetExtrapolatedLocation(cast);local distance=GetUnitToLocationDistance(bot,point)
                if distance<=range+radius then
                    if distance>range then point=bot:GetLocation()+(point-bot:GetLocation())*(range/distance) end
                    local count=0
                    for _,other in pairs(enemies) do
                        if J.IsValidHero(other) and other:CanBeSeen() and other:IsIllusion() and not other:IsInvulnerable()
                            and not other:IsMagicImmune() and (other:GetExtrapolatedLocation(cast)-point):Length2D()<=radius then count=count+1 end
                    end
                    if count>=4 then return BOT_ACTION_DESIRE_HIGH,point end
                end
            end
        end
    end
    return 0
end
return M
