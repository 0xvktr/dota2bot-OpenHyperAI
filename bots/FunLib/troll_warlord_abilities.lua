local M={}
local J=require(GetScriptDirectory()..'/FunLib/jmz_func')
local function valid(u,a)
    return J.IsValid(u) and not J.IsSuspiciousIllusion(u) and not J.IsRoshan(u)
        and (a:GetSpecialValueInt('pierces_magic_immunity')>0 and J.CanCastOnMagicImmune(u) or J.CanCastOnNonMagicImmune(u))
        and not u:HasModifier('modifier_abaddon_borrowed_time') and not u:HasModifier('modifier_necrolyte_reapers_scythe')
        and not u:HasModifier('modifier_item_blade_mail_reflect') and not u:HasModifier('modifier_nyx_assassin_spiked_carapace')
end
local function peel(bot,u)
    local ally=u:GetAttackTarget()
    return J.IsValidHero(ally) and ally:GetTeam()==bot:GetTeam() and ally:WasRecentlyDamagedByAnyHero(2)
end
local function useful(bot,u)
    return J.IsGoingOnSomeone(bot) and u==J.GetProperTarget(bot) or J.IsInTeamFight(bot,1200)
        or J.IsRetreating(bot) and u:GetAttackTarget()==bot or peel(bot,u)
end
function M.Stance(bot,a,native)
    if not J.CanCastAbility(a) then return 0 end
    local melee=a:GetToggleState();local delta=a:GetSpecialValueInt('bonus_range')
    local meleeRange=math.max(0,bot:GetAttackRange()-(melee and 0 or delta))
    local rangedRange=bot:GetAttackRange()+(melee and delta or 0)
    local target=bot:GetAttackTarget() or J.GetProperTarget(bot)
    if J.IsValid(target) and J.CanBeAttacked(target) then
        local distance=GetUnitToUnitDistance(bot,target)
        if not melee and distance<=meleeRange+35 then return BOT_ACTION_DESIRE_HIGH end
        if melee and distance>meleeRange+180 and distance<=rangedRange then return BOT_ACTION_DESIRE_HIGH end
    end
    local rage=bot:GetAbilityByName('troll_warlord_berserkers_rage')
    local speed=rage and not rage:IsNull() and rage:IsTrained() and not rage:IsHidden() and rage:IsActivated() and not J.HasBreakModifier(bot) and rage:GetSpecialValueInt('bonus_move_speed') or 0
    if not melee and speed>0 and not bot:IsRooted() and J.IsRetreating(bot) and bot:WasRecentlyDamagedByAnyHero(2) then return BOT_ACTION_DESIRE_HIGH end
    if native and not melee and (J.IsFarming(bot) or J.IsPushing(bot)) and J.IsValid(target)
        and not J.IsValidHero(target) and GetUnitToUnitDistance(bot,target)<=meleeRange+35 then return BOT_ACTION_DESIRE_HIGH end
    return 0
end
function M.UseStance(bot,native)
    local a=bot:GetAbilityByName('troll_warlord_switch_stance')
    if not J.CanCastAbility(a) or not bot:IsAlive() or bot:IsInvulnerable() or bot:IsStunned() or bot:IsHexed()
        or bot:IsNightmared() or bot:IsCastingAbility() or bot:IsUsingAbility() or bot:IsChanneling() or J.HasQueuedAction(bot)
        or bot:HasModifier('modifier_ringmaster_the_box_buff') or bot:HasModifier('modifier_doom_bringer_doom')
        or bot:HasModifier('modifier_item_forcestaff_active') then return false end
    if M.Stance(bot,a,native)>0 then bot:Action_UseAbility(a);return true end
    return false
end
local function rangedPoint(bot,a,u)
    local travel=a:GetSpecialValueInt('axe_range');local width=a:GetSpecialValueInt('axe_width')
    local delay=a:GetCastPoint()+GetUnitToUnitDistance(bot,u)/math.max(a:GetSpecialValueInt('axe_speed'),1)
    local point=u:GetExtrapolatedLocation(delay);local delta=point-bot:GetLocation();local distance=delta:Length2D()
    if distance>travel+width then return nil,delay end
    local cast=math.min(a:GetCastRange(),travel)
    if distance>cast then point=bot:GetLocation()+delta:Normalized()*cast end
    return point,delay
end
local function rayHits(bot,a,point,u)
    local direction=(point-bot:GetLocation()):Normalized();local delta=u:GetExtrapolatedLocation(a:GetCastPoint()+GetUnitToUnitDistance(bot,u)/math.max(a:GetSpecialValueInt('axe_speed'),1))-bot:GetLocation()
    -- The central axe is guaranteed; do not infer spread spacing from the KV angle alone.
    local along=delta.x*direction.x+delta.y*direction.y
    local cross=math.abs(delta.x*direction.y-delta.y*direction.x)
    return along>=0 and along<=a:GetSpecialValueInt('axe_range')+a:GetSpecialValueInt('axe_width')
        and cross<=a:GetSpecialValueInt('axe_width')
end
function M.Ranged(bot,a,native)
    if not J.CanCastAbility(a) then return 0 end
    for _,u in pairs(J.GetNearbyHeroes(bot,math.min(a:GetSpecialValueInt('axe_range')+a:GetSpecialValueInt('axe_width'),1600),true,BOT_MODE_NONE)) do
        if valid(u,a) then
            local point,delay=rangedPoint(bot,a,u)
            local dispel=bot:HasScepter() and (J.IsInEtherealForm(u) or u:HasModifier('modifier_windrunner_windrun') or u:HasModifier('modifier_flask_healing'))
            if point and (J.WillKillTarget(u,a:GetSpecialValueInt('axe_damage'),DAMAGE_TYPE_MAGICAL,delay) or dispel
                or useful(bot,u) and not u:HasModifier('modifier_troll_warlord_whirling_axes_slow')) then return BOT_ACTION_DESIRE_HIGH,point end
        end
    end
    if native and J.IsAllowedToSpam(bot,a:GetManaCost()) then
        local creeps=bot:GetNearbyLaneCreeps(math.min(a:GetSpecialValueInt('axe_range'),1600),true)
        if J.IsFarming(bot) and #creeps<3 then creeps=bot:GetNearbyNeutralCreeps(math.min(a:GetSpecialValueInt('axe_range'),1600)) end
        for _,u in pairs(creeps) do
            if valid(u,a) and not u:HasModifier('modifier_fountain_glyph') then
                local point,delay=rangedPoint(bot,a,u)
                if point then
                    if J.IsLaning(bot) and u:GetUnitName():find('ranged') and J.WillKillTarget(u,a:GetSpecialValueInt('axe_damage'),DAMAGE_TYPE_MAGICAL,delay) then return BOT_ACTION_DESIRE_HIGH,point end
                    local count=0;for _,c in pairs(creeps) do if valid(c,a) and rayHits(bot,a,point,c) then count=count+1 end end
                    if count>=3 and (J.IsFarming(bot) or J.IsPushing(bot) or J.IsDefending(bot)) then return BOT_ACTION_DESIRE_HIGH,point end
                end
            end
        end
        local u=J.GetProperTarget(bot)
        if J.IsDoingTormentor(bot) and J.IsTormentor(u) and valid(u,a) then local point=rangedPoint(bot,a,u);if point then return BOT_ACTION_DESIRE_HIGH,point end end
    end
    return 0
end
local removable={'modifier_rod_of_atos_debuff','modifier_item_gungir_root','modifier_crystal_maiden_frostbite','modifier_bounty_hunter_track','modifier_slardar_amplify_damage'}
function M.Melee(bot,a,native)
    if not J.CanCastAbility(a) then return 0 end
    if bot:HasScepter() then for _,name in ipairs(removable) do if bot:HasModifier(name) then return BOT_ACTION_DESIRE_HIGH end end end
    local radius=a:GetSpecialValueInt('max_range');local delay=a:GetCastPoint()+a:GetSpecialValueFloat('whirl_duration')
    for _,u in pairs(J.GetNearbyHeroes(bot,math.min(radius,1600),true,BOT_MODE_NONE)) do
        if valid(u,a) then
            local future=(u:GetExtrapolatedLocation(delay)-bot:GetExtrapolatedLocation(delay)):Length2D()
            if future<=radius and J.WillKillTarget(u,a:GetSpecialValueInt('damage'),DAMAGE_TYPE_MAGICAL,delay)
                or useful(bot,u) and not u:HasModifier('modifier_troll_warlord_whirling_axes_blind') then return BOT_ACTION_DESIRE_HIGH end
        end
    end
    if native and J.IsAllowedToSpam(bot,a:GetManaCost()) then
        local creeps=bot:GetNearbyLaneCreeps(math.min(radius,1600),true)
        if J.IsFarming(bot) and #creeps<3 then creeps=bot:GetNearbyNeutralCreeps(math.min(radius,1600)) end
        local count=0;for _,u in pairs(creeps) do if valid(u,a) and J.IsInRange(bot,u,radius) and not u:HasModifier('modifier_fountain_glyph') then count=count+1 end end
        if count>=3 and (J.IsFarming(bot) or J.IsPushing(bot) or J.IsDefending(bot)) then return BOT_ACTION_DESIRE_HIGH end
        local u=J.GetProperTarget(bot)
        if J.IsDoingTormentor(bot) and J.IsTormentor(u) and valid(u,a) and J.IsInRange(bot,u,radius) then return BOT_ACTION_DESIRE_HIGH end
    end
    return 0
end
local function physical(u)
    return J.IsValid(u) and u:CanBeSeen() and not u:IsInvulnerable() and J.CanBeAttacked(u)
        and not u:HasModifier('modifier_item_blade_mail_reflect') and not u:HasModifier('modifier_abaddon_borrowed_time')
        and not u:HasModifier('modifier_dazzle_shallow_grave') and not u:HasModifier('modifier_oracle_false_promise_timer')
end
function M.Trance(bot,a,native)
    if not J.CanCastAbility(a) or bot:HasModifier('modifier_troll_warlord_battle_trance') then return 0 end
    local first,closest,hero=nil,math.huge,false
    for _,u in pairs(GetUnitList(UNIT_LIST_ENEMIES)) do
        if J.IsValid(u) and u:CanBeSeen() and not u:IsInvulnerable() then
            local distance=GetUnitToUnitDistance(bot,u);local isHero=u:IsHero()
            if distance<=a:GetSpecialValueInt('range') and (isHero and not hero or isHero==hero and distance<closest) then first,closest,hero=u,distance,isHero end
            local active=u:GetCurrentActiveAbility()
            if u:IsCastingAbility() and active and not active:IsNull() and active:GetName()=='axe_culling_blade'
                and u:GetAttackTarget()==bot then return 0 end
        end
    end
    if J.GetHP(bot)<.3 and bot:WasRecentlyDamagedByAnyHero(2) and #J.GetNearbyHeroes(bot,900,true,BOT_MODE_NONE)>0 then return BOT_ACTION_DESIRE_HIGH end
    if first and physical(first) and not first:IsIllusion() and not bot:IsDisarmed() then
        if J.IsGoingOnSomeone(bot) and hero and (J.IsDisabled(first) or J.GetHP(bot)<.6)
            and closest<=bot:GetAttackRange()+150 then return BOT_ACTION_DESIRE_HIGH end
        if native and (J.IsDoingRoshan(bot) and J.IsRoshan(first) or J.IsDoingTormentor(bot) and J.IsTormentor(first))
            and J.GetHP(bot)<.55 and closest<=bot:GetAttackRange()+150 and not bot:HasModifier('modifier_ice_blast') then return BOT_ACTION_DESIRE_HIGH end
    end
    if a:GetSpecialValueInt('attack_speed_share_percent')>0 and not hero then
        local count=0
        for _,ally in pairs(GetUnitList(UNIT_LIST_ALLIED_HEROES)) do
            local u=ally:GetAttackTarget()
            if ally~=bot and J.IsValidHero(ally) and not ally:IsIllusion() and not ally:IsDisarmed() and J.IsAttacking(ally)
                and J.IsValidHero(u) and u:GetTeam()~=bot:GetTeam() and physical(u) then count=count+1 end
        end
        if count>=2 then return BOT_ACTION_DESIRE_HIGH end
    end
    return 0
end
function M.CastTrance(bot,a)
    if J.CheckBitfieldFlag(a:GetBehavior(),ABILITY_BEHAVIOR_UNIT_TARGET) then bot:Action_UseAbilityOnEntity(a,bot) else bot:Action_UseAbility(a) end
end
return M
