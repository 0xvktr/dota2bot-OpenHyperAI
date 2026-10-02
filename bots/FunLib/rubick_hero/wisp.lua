local X = {}
local J = require(GetScriptDirectory()..'/FunLib/jmz_func')
local pendingRelocate

local function Available(a)
    return a~=nil and not a:IsNull() and a:IsTrained() and not a:IsHidden() and a:IsActivated()
end
local function Ally(bot,u)
    return J.IsValidHero(u) and u~=bot and u:GetTeam()==bot:GetTeam()
        and u:CanBeSeen() and not u:IsIllusion() and not u:IsInvulnerable()
end
local function OwnedSource(bot,index,name)
    local source=bot:GetModifierSourceAbility(index)
    return source~=nil and not source:IsNull() and source:GetName()==name and source:GetCaster()==bot
end
local function Effect(bot,name)
    for i=0,bot:NumModifiers()-1 do
        if OwnedSource(bot,i,name) then return i end
    end
    return nil
end
local function Range(bot,a)
    local range=a:GetCastRange()
    for slot=0,5 do
        local item=bot:GetItemInSlot(slot)
        if item~=nil and not item:IsNull() and item:GetName()=='item_aether_lens' then range=range+item:GetSpecialValueInt('cast_range_bonus');break end
    end
    local sup=bot:GetAbilityByName('rubick_arcane_supremacy')
    if sup~=nil and not sup:IsNull() and sup:IsTrained() and not J.HasBreakModifier(bot) then range=range+sup:GetSpecialValueInt('cast_range') end
    return range
end
local function Threat(u)
    return u:WasRecentlyDamagedByAnyHero(2) or J.GetAttackProjectileDamageByRange(u,1200)>0
end
local function Attacking(u)
    local target=u:GetAttackTarget()
    return J.IsAttacking(u) and (J.IsValid(target) or J.IsValidBuilding(target)) and target:GetTeam()~=u:GetTeam()
        and J.CanBeAttacked(target) and GetUnitToUnitDistance(u,target)<=u:GetAttackRange()+150
end
local function Healing(u)
    return not u:HasModifier('modifier_ice_blast') and u:GetMaxHealth()-u:GetHealth()>=100
end
local function Safe(bot,point)
    return IsLocationPassable(point) and not J.IsLocationInChrono(point) and not J.IsLocationInBlackHole(point)
        and not J.IsLocHaveTower(700,true,point)
        and #J.GetEnemiesNearLoc(point,700)<=#J.GetAlliesNearLoc(point,700)+1
end
function X.ObserveTetherState()
    local bot=GetBot();bot.stateTetheredHero=nil
    local index=Effect(bot,'wisp_tether')
    if index==nil then return nil end
    for _,unit in pairs(bot:GetModifierAuxiliaryUnits(index) or {}) do
        if unit~=nil and not unit:IsNull() and unit:IsAlive() and unit:IsHero()
            and unit~=bot and unit:GetTeam()==bot:GetTeam() then bot.stateTetheredHero=unit;return unit end
    end
    return nil
end
function X.IsRelocating()
    local bot=GetBot();local a=bot:GetAbilityByName('wisp_relocate')
    if not bot:IsAlive() or bot:IsStunned() or bot:IsHexed() or bot:IsNightmared() or bot:IsSilenced() then pendingRelocate=nil;return false end
    if a~=nil and not a:IsNull() and a:IsInAbilityPhase() then return true end
    local index=bot:GetModifierByName('modifier_wisp_relocate_channel')
    if index>=0 and OwnedSource(bot,index,'wisp_relocate') then return true end
    if pendingRelocate~=nil then
        if pendingRelocate.bot~=bot or a~=pendingRelocate.ability or not Available(a) then pendingRelocate=nil
        else
            local now=DotaTime()
            if pendingRelocate.untilTime==nil and a:GetCooldownTimeRemaining()>pendingRelocate.cooldown+0.1 then
                pendingRelocate.untilTime=now+a:GetSpecialValueFloat('cast_delay')+0.1
            end
            if now<(pendingRelocate.untilTime or pendingRelocate.requested+0.4) then return true end
            pendingRelocate=nil
        end
    end
    return false
end
function X.ConsiderTether()
    local bot=GetBot();local a=bot:GetAbilityByName('wisp_tether')
    if not J.CanCastAbility(a) or Effect(bot,'wisp_tether')~=nil then return 0 end
    local best,score=nil,0
    for _,ally in pairs(GetUnitList(UNIT_LIST_ALLIED_HEROES)) do
        if Ally(bot,ally) and GetUnitToUnitDistance(bot,ally)<=Range(bot,a) then
            local distance=GetUnitToUnitDistance(bot,ally);local latch=distance>=a:GetSpecialValueInt('latch_distance')
            local blocked=bot:IsRooted() or bot:HasModifier('modifier_bloodseeker_rupture')
                or bot:HasModifier('modifier_slark_pounce_leash') or bot:HasModifier('modifier_puck_coiled')
            local point=J.GetCorrectLoc(ally,latch and math.max(0,distance-300)/a:GetSpecialValueInt('latch_speed') or 0)
            if not latch or not blocked and Safe(bot,point) then
                local overcharge=bot:GetAbilityByName('wisp_overcharge')
                local sustain=Healing(ally) and (bot:GetHealthRegen()>=2 or J.CanCastAbility(overcharge))
                local escape=Threat(bot) and J.GetHP(bot)<0.4 and Safe(bot,point)
                    and GetUnitToLocationDistance(ally,J.GetTeamFountain())+300<GetUnitToLocationDistance(bot,J.GetTeamFountain())
                local useful=Attacking(ally) or ally:IsUsingAbility() and Threat(ally)
                if sustain or useful or escape then
                    local value=(sustain and (1-J.GetHP(ally))*5 or 0)+(Threat(ally) and 2 or 0)+(useful and 1 or 0)+(escape and 6 or 0)
                    if value>score then best,score=ally,value end
                end
            end
        end
    end
    if best~=nil then return BOT_ACTION_DESIRE_HIGH,best end
    return 0
end
function X.ConsiderOvercharge()
    local bot=GetBot();local a=bot:GetAbilityByName('wisp_overcharge')
    if not J.CanCastAbility(a) or Effect(bot,'wisp_overcharge')~=nil then return 0 end
    local ally=X.ObserveTetherState()
    if Attacking(bot) or Healing(bot) and Threat(bot) or bot:IsUsingAbility() then return BOT_ACTION_DESIRE_HIGH end
    if ally~=nil and (Attacking(ally) or ally:IsUsingAbility() or Healing(ally) and Threat(ally)) then return BOT_ACTION_DESIRE_HIGH end
    return 0
end
local function Spirits(bot)
    local index=Effect(bot,'wisp_spirits');local units={}
    if index~=nil then
        for _,u in pairs(bot:GetModifierAuxiliaryUnits(index) or {}) do
            if J.IsValid(u) and u~=bot and not u:IsHero() and not u:IsBuilding()
                and u:GetTeam()==bot:GetTeam() and u:GetPlayerID()==bot:GetPlayerID() then units[#units+1]=u end
        end
    end
    return index,units
end
function X.ConsiderSpirits()
    local bot=GetBot();local a=bot:GetAbilityByName('wisp_spirits')
    if not J.CanCastAbility(a) then return 0 end
    local index,spirits=Spirits(bot)
    if bot:HasScepter() then
        -- Passive spawning is not proof that any current orb will hit.
        for _,orb in pairs(spirits) do
            for _,enemy in pairs(J.GetEnemiesNearLoc(orb:GetLocation(),a:GetSpecialValueInt('explode_radius'))) do
                if J.CanCastOnNonMagicImmune(enemy) and not enemy:HasModifier('modifier_item_blade_mail_reflect')
                    and not enemy:HasModifier('modifier_nyx_assassin_spiked_carapace') then return BOT_ACTION_DESIRE_HIGH end
            end
        end
        return 0
    end
    if index~=nil then return 0 end
    for _,enemy in pairs(J.GetNearbyHeroes(bot,math.min(a:GetSpecialValueInt('max_range')+a:GetSpecialValueInt('hero_hit_radius'),1600),true,BOT_MODE_NONE)) do
        if J.CanCastOnNonMagicImmune(enemy) and not enemy:HasModifier('modifier_item_blade_mail_reflect')
            and not enemy:HasModifier('modifier_nyx_assassin_spiked_carapace')
            and (enemy==J.GetProperTarget(bot) and J.IsGoingOnSomeone(bot) or Threat(bot) or enemy:GetAttackTarget()==bot.stateTetheredHero and bot.stateTetheredHero~=nil) then return BOT_ACTION_DESIRE_HIGH end
    end
    if J.IsAllowedToSpam(bot,a:GetManaCost()) and (J.IsFarming(bot) or J.IsPushing(bot) or J.IsDefending(bot)) then
        if #bot:GetNearbyNeutralCreeps(a:GetSpecialValueInt('max_range'))>=3
            or #bot:GetNearbyLaneCreeps(a:GetSpecialValueInt('max_range'),true)>=3 then return BOT_ACTION_DESIRE_HIGH end
    end
    return 0
end
function X.ConsiderSpiritControl(a)
    local bot=GetBot();if not J.CanCastAbility(a) then return 0 end
    local _,spirits=Spirits(bot);local spell=bot:GetAbilityByName('wisp_spirits');local target=J.GetProperTarget(bot)
    if #spirits==0 or not Available(spell) or not J.IsValidHero(target) or not J.CanCastOnNonMagicImmune(target) then
        return a:GetToggleState() and BOT_ACTION_DESIRE_HIGH or 0
    end
    local radius=0;for _,u in pairs(spirits) do radius=radius+GetUnitToUnitDistance(bot,u) end;radius=radius/#spirits
    local desired=math.min(spell:GetSpecialValueInt('max_range'),math.max(spell:GetSpecialValueInt('min_range'),GetUnitToUnitDistance(bot,target)))
    local wanted=a:GetName()=='wisp_spirits_in' and radius>desired+60 or a:GetName()=='wisp_spirits_out' and radius<desired-60
    return a:GetToggleState()~=wanted and BOT_ACTION_DESIRE_HIGH or 0
end
local function ChannelSafe(bot,a)
    if bot:IsRooted() or bot:HasModifier('modifier_bloodseeker_rupture') or bot:HasModifier('modifier_kunkka_x_marks_the_spot') then return false end
    if J.GetAttackProjectileDamageByRange(bot,1600)>=bot:GetHealth()*0.5 then return false end
    for _,enemy in pairs(J.GetNearbyHeroes(bot,600,true,BOT_MODE_NONE)) do
        if J.IsValidHero(enemy) and not J.IsDisabled(enemy) then return false end
    end
    return a:GetSpecialValueFloat('cast_delay')>0
end
function X.ConsiderRelocate()
    local bot=GetBot();local a=bot:GetAbilityByName('wisp_relocate')
    if not J.CanCastAbility(a) or Effect(bot,'wisp_relocate')~=nil or not ChannelSafe(bot,a) then return 0 end
    local ally=X.ObserveTetherState()
    if Effect(bot,'wisp_tether')~=nil and ally==nil then return 0 end
    if ally~=nil and (ally:HasModifier('modifier_kunkka_x_marks_the_spot')
        or ally:HasModifier('modifier_legion_commander_duel')
        or J.GetAttackProjectileDamageByRange(ally,1600)>=ally:GetHealth()) then return 0 end
    local selfDanger=J.GetHP(bot)<0.3 and Threat(bot)
    local allyDanger=ally~=nil and J.GetHP(ally)<0.3 and Threat(ally)
    if (selfDanger or allyDanger) and (ally==nil or not ally:IsChanneling() or allyDanger)
        and (not selfDanger or ally==nil or allyDanger or J.GetHP(ally)<0.5) then return BOT_ACTION_DESIRE_HIGH,J.GetTeamFountain() end
    if ally==nil or J.GetHP(bot)<0.65 or J.GetHP(ally)<0.65 or ally:IsChanneling()
        or J.IsDisabled(ally) or ally:GetMana()<ally:GetMaxMana()*0.2
        or not (Attacking(ally) and J.IsValidHero(ally:GetAttackTarget()) or ally:IsUsingAbility() and Threat(ally)) then return 0 end
    for _,friend in pairs(GetUnitList(UNIT_LIST_ALLIED_HEROES)) do
        if Ally(bot,friend) and GetUnitToUnitDistance(bot,friend)>3000 and Threat(friend)
            and #J.GetAlliesNearLoc(friend:GetLocation(),800)>=2 and #J.GetEnemiesNearLoc(friend:GetLocation(),800)>0 then
            local point=J.GetCorrectLoc(friend,a:GetSpecialValueFloat('cast_delay'))
            if Safe(bot,point) then return BOT_ACTION_DESIRE_HIGH,point end
        end
    end
    return 0
end
function X.ConsiderBreakTether()
    local bot=GetBot();local a=bot:GetAbilityByName('wisp_tether_break');local ally=X.ObserveTetherState()
    if not J.CanCastAbility(a) or ally==nil or Effect(bot,'wisp_relocate')~=nil then return 0 end
    local r=bot:GetAbilityByName('wisp_relocate')
    if J.CanCastAbility(r) and J.GetHP(bot)<0.2 and Threat(bot) and J.GetHP(ally)>0.6 and not Threat(ally)
        and ChannelSafe(bot,r) then return BOT_ACTION_DESIRE_HIGH end
    return 0
end
local decisions={wisp_tether=X.ConsiderTether,wisp_overcharge=X.ConsiderOvercharge,wisp_spirits=X.ConsiderSpirits,
    wisp_relocate=X.ConsiderRelocate,wisp_tether_break=X.ConsiderBreakTether,
    wisp_spirits_in=X.ConsiderSpiritControl,wisp_spirits_out=X.ConsiderSpiritControl}
local function Cast(bot,a,target)
    if a:GetName()=='wisp_relocate' then
        pendingRelocate={bot=bot,ability=a,cooldown=a:GetCooldownTimeRemaining(),requested=DotaTime()}
        bot:Action_UseAbilityOnLocation(a,target)
    elseif a:GetName()=='wisp_tether' then bot:Action_UseAbilityOnEntity(a,target)
    else bot:Action_UseAbility(a) end
end
function X.ConsiderStolenSpell(a)
    local name=a:GetName();local consider=decisions[name];if consider==nil then return nil end
    local bot=GetBot();X.ObserveTetherState()
    local relocating=X.IsRelocating()
    if J.CanNotUseAbility(bot) or J.IsRealInvisible(bot) or relocating then return false end
    local desire,target=consider(a)
    if desire>0 then Cast(bot,a,target);return true end
    return false
end
function X.UseNative()
    local bot=GetBot();X.ObserveTetherState()
    local relocating=X.IsRelocating()
    if J.CanNotUseAbility(bot) or J.IsRealInvisible(bot) or relocating then return false end
    for _,name in ipairs({'wisp_tether_break','wisp_relocate','wisp_tether','wisp_overcharge','wisp_spirits_in','wisp_spirits_out','wisp_spirits'}) do
        local a=bot:GetAbilityByName(name)
        if Available(a) then
            local desire,target=decisions[name](a)
            if desire>0 then Cast(bot,a,target);return true end
        end
    end
    return false
end
return X
