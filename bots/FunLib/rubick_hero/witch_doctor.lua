local X = {}
local J = require(GetScriptDirectory()..'/FunLib/jmz_func')
local bot = GetBot()

local function Interrupt(unit,eta)
    if not unit:IsChanneling() then return false end
    local index=unit:GetModifierByName('modifier_teleporting')
    return index<0 or unit:GetModifierRemainingDuration(index)>eta+0.05
end
local function Range(ability)
    local range = ability:GetCastRange()
    for slot=0,5 do
        local item=bot:GetItemInSlot(slot)
        if item ~= nil and not item:IsNull() and item:GetName()=='item_aether_lens' then
            range=range+item:GetSpecialValueInt('cast_range_bonus');break
        end
    end
    local supremacy=bot:GetAbilityByName('rubick_arcane_supremacy')
    if supremacy ~= nil and not supremacy:IsNull() and supremacy:IsTrained() and not J.HasBreakModifier(bot) then
        range=range+supremacy:GetSpecialValueInt('cast_range')
    end
    return range
end
local function Enemy(unit, pierce)
    return J.IsValidHero(unit) and not J.IsSuspiciousIllusion(unit)
        and (pierce and J.CanCastOnMagicImmune(unit) or not pierce and J.CanCastOnNonMagicImmune(unit))
        and not J.CannotBeKilled(bot,unit)
end
local function MagicEnemy(unit)
    return Enemy(unit,false) and not unit:HasModifier('modifier_item_blade_mail_reflect')
        and not unit:HasModifier('modifier_nyx_assassin_spiked_carapace')
end
local function Point(unit, ability, radius)
    local predicted=J.GetCorrectLoc(unit,ability:GetCastPoint())
    local delta=predicted-bot:GetLocation();local range=Range(ability)
    if delta:Length2D()>range+radius then return nil end
    if delta:Length2D()>range then predicted=bot:GetLocation()+delta:Normalized()*range end
    return predicted
end
local function AllyEngaged(enemy)
    for _,ally in pairs(J.GetAlliesNearLoc(enemy:GetLocation(),700)) do
        if J.IsValidHero(ally) and not ally:IsIllusion() and ally:GetAttackTarget()==enemy then return true end
    end
    return false
end
local function BouncePartners(target,ability)
    local count=0
    for _,unit in pairs(GetUnitList(UNIT_LIST_ENEMIES)) do
        if unit ~= target and J.IsValid(unit) and unit:CanBeSeen() and not unit:IsBuilding()
            and J.CanCastOnNonMagicImmune(unit)
            and GetUnitToUnitDistance(target,unit)<=ability:GetSpecialValueInt('bounce_range') then count=count+1 end
    end
    return count
end
function X.ConsiderCask()
    local a=bot:GetAbilityByName('witch_doctor_paralyzing_cask')
    if not J.CanCastAbility(a) then return 0 end
    local range=Range(a);local best,score=nil,-1
    for _,enemy in pairs(J.GetNearbyHeroes(bot,math.min(range,1600),true,BOT_MODE_NONE)) do
        if MagicEnemy(enemy) and GetUnitToUnitDistance(bot,enemy)<=range and J.CanCastOnTargetAdvanced(enemy) then
            local eta=a:GetCastPoint()+GetUnitToUnitDistance(bot,enemy)/a:GetSpecialValueInt('speed')
            if Interrupt(enemy,eta) or J.WillKillTarget(enemy,a:GetSpecialValueInt('base_damage'),DAMAGE_TYPE_MAGICAL,eta) then return BOT_ACTION_DESIRE_HIGH,enemy end
            local peel=enemy:GetAttackTarget()~=nil and J.IsValidHero(enemy:GetAttackTarget())
                and enemy:GetAttackTarget():GetTeam()==bot:GetTeam() and enemy:GetAttackTarget():WasRecentlyDamagedByAnyHero(2)
            if not J.IsDisabled(enemy) and (J.IsGoingOnSomeone(bot) and enemy==J.GetProperTarget(bot)
                or J.IsRetreating(bot) and enemy:GetAttackTarget()==bot or peel
                or J.IsInTeamFight(bot,1200)) then
                local value=BouncePartners(enemy,a)+(peel and 3 or 0)
                if value>score then best,score=enemy,value end
            end
        end
    end
    if best ~= nil then return BOT_ACTION_DESIRE_HIGH,best end
    if J.IsAllowedToSpam(bot,a:GetManaCost()) then
        local creeps=bot:GetNearbyLaneCreeps(math.min(range,1600),true)
        if J.IsLaning(bot) then
            for _,creep in pairs(creeps) do
                if J.IsValid(creep) and J.CanCastOnNonMagicImmune(creep) and not creep:HasModifier('modifier_fountain_glyph')
                    and string.find(creep:GetUnitName(),'ranged',1,true) and GetUnitToUnitDistance(bot,creep)<=range
                    and J.WillKillTarget(creep,a:GetSpecialValueInt('base_damage')*a:GetSpecialValueInt('creep_damage_pct')/100,DAMAGE_TYPE_MAGICAL,
                        a:GetCastPoint()+GetUnitToUnitDistance(bot,creep)/a:GetSpecialValueInt('speed')) then return BOT_ACTION_DESIRE_HIGH,creep end
            end
        elseif J.IsFarming(bot) or J.IsPushing(bot) or J.IsDefending(bot) then
            if #creeps<3 then creeps=bot:GetNearbyNeutralCreeps(math.min(range,1600)) end
            for _,creep in pairs(creeps) do
                if J.IsValid(creep) and J.CanCastOnNonMagicImmune(creep) and not creep:HasModifier('modifier_fountain_glyph')
                    and GetUnitToUnitDistance(bot,creep)<=range and BouncePartners(creep,a)>=2 then return BOT_ACTION_DESIRE_HIGH,creep end
            end
        end
    end
    return 0
end
function X.ConsiderMaledict()
    local a=bot:GetAbilityByName('witch_doctor_maledict')
    if not J.CanCastAbility(a) then return 0 end
    local radius=a:GetSpecialValueInt('radius')
    for _,enemy in pairs(J.GetNearbyHeroes(bot,math.min(Range(a)+radius,1600),true,BOT_MODE_NONE)) do
        if MagicEnemy(enemy) and not enemy:HasModifier('modifier_maledict') then
            local point=Point(enemy,a,radius)
            if point ~= nil and (J.IsGoingOnSomeone(bot) and enemy==J.GetProperTarget(bot)
                or AllyEngaged(enemy) or J.IsInTeamFight(bot,1200)) then return BOT_ACTION_DESIRE_HIGH,point end
        end
    end
    return 0
end
local function ToggleAvailable(a)
    return a ~= nil and not a:IsNull() and a:IsTrained() and not a:IsHidden() and a:IsActivated()
end
function X.ConsiderRestoration()
    local a=bot:GetAbilityByName('witch_doctor_voodoo_restoration')
    if not ToggleAvailable(a) then return 0 end
    local need=false;local allies=J.GetAlliesNearLoc(bot:GetLocation(),a:GetSpecialValueInt('radius'))
    allies[#allies+1]=bot
    for _,ally in pairs(allies) do
        if J.IsValidHero(ally) and not ally:IsIllusion() and not ally:IsInvulnerable()
            and not ally:HasModifier('modifier_ice_blast') and GetUnitToUnitDistance(bot,ally)<=a:GetSpecialValueInt('radius')
            and (a:GetSpecialValueInt('does_heal_all_allies')==1 or ally==bot and a:GetSpecialValueInt('self_only_heal_percentage')>0)
            and ally:GetMaxHealth()-ally:GetHealth()>=math.max(50,a:GetSpecialValueInt('heal'))
            and (J.GetHP(ally)<0.8 or ally:WasRecentlyDamagedByAnyHero(2)) then need=true end
    end
    local upkeep=a:GetSpecialValueInt('mana_per_second')
    local reserve=upkeep*3
    local ward=bot:GetAbilityByName('witch_doctor_death_ward')
    if J.CanCastAbility(ward) and not bot:IsChanneling() then reserve=reserve+ward:GetManaCost() end
    if a:GetToggleState() then
        if not need or bot:GetMana()<upkeep*2 then return BOT_ACTION_DESIRE_HIGH end
    elseif need and J.CanCastAbility(a) and bot:GetMana()>=a:GetManaCost()+reserve then return BOT_ACTION_DESIRE_HIGH end
    return 0
end
local function ActionLocked()
    return not bot:IsAlive() or bot:IsInvulnerable() or bot:IsStunned() or bot:IsHexed() or bot:IsNightmared()
        or bot:IsSilenced() or bot:IsCastingAbility() or J.HasQueuedAction(bot)
        or bot:HasModifier('modifier_ringmaster_the_box_buff') or bot:HasModifier('modifier_doom_bringer_doom')
        or bot:HasModifier('modifier_item_forcestaff_active')
end
function X.UseRestorationDuringChannel()
    bot=GetBot()
    if not bot:IsChanneling() or ActionLocked() then return false end
    local active=bot:GetCurrentActiveAbility()
    if active==nil or active:IsNull() then return false end
    local name=active:GetName()
    if name~='witch_doctor_death_ward' and name~='item_tpscroll' then return false end
    if name=='witch_doctor_death_ward' and active~=bot:GetAbilityByName(name) then return false end
    local a=bot:GetAbilityByName('witch_doctor_voodoo_restoration')
    if X.ConsiderRestoration()>0 then bot:Action_UseAbility(a);return true end
    return false
end
local function SafeWard(point)
    if not IsLocationPassable(point) or J.IsLocationInChrono(point) or J.IsLocationInBlackHole(point) then return false end
    if J.IsStunProjectileIncoming(bot,600) then return false end
    for _,enemy in pairs(J.GetNearbyHeroes(bot,1600,true,BOT_MODE_NONE)) do
        if J.IsValidHero(enemy) and not J.IsDisabled(enemy) and not enemy:IsDisarmed()
            and (enemy:GetAttackTarget()==bot or J.GetHP(bot)<0.45 and GetUnitToUnitDistance(bot,enemy)<=enemy:GetAttackRange()+100) then return false end
    end
    return true
end
function X.ConsiderWard()
    local a=bot:GetAbilityByName('witch_doctor_death_ward')
    if not J.CanCastAbility(a) then return 0 end
    local attackRange=a:GetSpecialValueInt('attack_range_tooltip')
    for _,enemy in pairs(J.GetNearbyHeroes(bot,math.min(Range(a)+attackRange,1600),true,BOT_MODE_NONE)) do
        if Enemy(enemy,true) and J.CanBeAttacked(enemy) and (J.IsGoingOnSomeone(bot) or J.IsInTeamFight(bot,1200) or AllyEngaged(enemy)) then
            local point=Point(enemy,a,attackRange)
            if point ~= nil and SafeWard(point) and (J.IsDisabled(enemy) or enemy:HasModifier('modifier_maledict') or AllyEngaged(enemy)) then
                return BOT_ACTION_DESIRE_HIGH,point
            end
        end
    end
    return 0
end
function X.ConsiderSwitcheroo()
    local a=bot:GetAbilityByName('witch_doctor_voodoo_switcheroo')
    if not J.CanCastAbility(a) then return 0 end
    if J.IsStunProjectileIncoming(bot,700) or bot:WasRecentlyDamagedByAnyHero(2) and J.GetHP(bot)<0.35
        and #J.GetNearbyHeroes(bot,900,true,BOT_MODE_NONE)>0 then return BOT_ACTION_DESIRE_HIGH end
    local ward=bot:GetAbilityByName('witch_doctor_death_ward')
    if not J.CanCastAbility(ward) then
        for _,enemy in pairs(J.GetNearbyHeroes(bot,600,true,BOT_MODE_NONE)) do
            if Enemy(enemy,true) and J.CanBeAttacked(enemy) and J.IsGoingOnSomeone(bot)
                and (J.IsDisabled(enemy) or enemy:HasModifier('modifier_maledict')) then return BOT_ACTION_DESIRE_HIGH end
        end
    end
    return 0
end
function X.HandleDeathWard(unit)
    bot=GetBot()
    if unit==nil or unit:IsNull() or not unit:IsAlive() or unit:GetUnitName()~='npc_dota_witch_doctor_death_ward'
        or unit:GetPlayerID()~=bot:GetPlayerID() or unit:GetTeam()~=bot:GetTeam() then return false end
    -- Own this tick even when idle or locked: generic ward control uses its owner's range.
    if unit:IsChanneling() or unit:IsUsingAbility() or unit:IsCastingAbility() or unit:NumQueuedActions()>0 then return true end
    local best=J.GetProperTarget(bot)
    if not Enemy(best,true) or not J.CanBeAttacked(best) or GetUnitToUnitDistance(unit,best)>unit:GetAttackRange() then best=nil end
    if best==nil then
        for _,enemy in pairs(J.GetEnemiesNearLoc(unit:GetLocation(),unit:GetAttackRange())) do
            if Enemy(enemy,true) and J.CanBeAttacked(enemy) and (best==nil or enemy:GetHealth()<best:GetHealth()) then best=enemy end
        end
    end
    if best ~= nil then
        if unit:GetAttackTarget()~=best then unit:Action_AttackUnit(best,true) end
        return true
    end
    return true
end
local decisions={
    witch_doctor_paralyzing_cask=X.ConsiderCask,witch_doctor_maledict=X.ConsiderMaledict,
    witch_doctor_voodoo_restoration=X.ConsiderRestoration,witch_doctor_death_ward=X.ConsiderWard,
    witch_doctor_voodoo_switcheroo=X.ConsiderSwitcheroo,
}
local function Cast(a,target,queue)
    local name=a:GetName()
    if name=='witch_doctor_voodoo_restoration' or name=='witch_doctor_voodoo_switcheroo' then
        bot:Action_UseAbility(a)
    else
        if queue then J.SetQueuePtToINT(bot,true,a) end
        if name=='witch_doctor_paralyzing_cask' then
            if queue then bot:ActionQueue_UseAbilityOnEntity(a,target) else bot:Action_UseAbilityOnEntity(a,target) end
        else
            if queue then bot:ActionQueue_UseAbilityOnLocation(a,target) else bot:Action_UseAbilityOnLocation(a,target) end
        end
    end
end
function X.ConsiderStolenSpell(a)
    local decide=decisions[a:GetName()]
    if decide==nil then return nil end
    bot=GetBot()
    if X.UseRestorationDuringChannel() then return true end
    if J.CanNotUseAbility(bot) or bot:IsInvisible() then return false end
    if a:GetName()=='witch_doctor_voodoo_restoration' then
        if not ToggleAvailable(a) then return false end
    elseif not J.CanCastAbility(a) then return false end
    local desire,target=decide()
    if desire<=0 then return false end
    Cast(a,target,false);return true
end
function X.UseNative()
    bot=GetBot()
    if X.UseRestorationDuringChannel() then return true end
    if J.CanNotUseAbility(bot) or bot:IsInvisible() then return false end
    for _,name in ipairs({'witch_doctor_voodoo_switcheroo','witch_doctor_paralyzing_cask','witch_doctor_maledict','witch_doctor_voodoo_restoration','witch_doctor_death_ward'}) do
        local a=bot:GetAbilityByName(name)
        local desire,target=decisions[name]()
        if desire>0 then Cast(a,target,true);return true end
    end
    return false
end
return X
