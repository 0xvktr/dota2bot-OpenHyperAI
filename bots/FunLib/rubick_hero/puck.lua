local X={}
local J=require(GetScriptDirectory()..'/FunLib/jmz_func')
local bot,IllusoryOrb,WaningRift,PhaseShift,EtherealJaunt,DreamCoil
local function Refresh()
 bot=GetBot();IllusoryOrb=bot:GetAbilityByName('puck_illusory_orb');WaningRift=bot:GetAbilityByName('puck_waning_rift')
 PhaseShift=bot:GetAbilityByName('puck_phase_shift');EtherealJaunt=bot:GetAbilityByName('puck_ethereal_jaunt');DreamCoil=bot:GetAbilityByName('puck_dream_coil')
end
local function ActualRange(ability)
    local range=ability:GetCastRange()
    for slot=0,5 do local item=bot:GetItemInSlot(slot);if item~=nil and item:GetName()=='item_aether_lens' then range=range+item:GetSpecialValueInt('cast_range_bonus');break end end
    local supremacy=bot:GetAbilityByName('rubick_arcane_supremacy')
    if supremacy~=nil and supremacy:IsTrained() and not J.HasBreakModifier(bot) then range=range+supremacy:GetSpecialValueInt('cast_range') end
    return range
end
local function Enemy(target)
    return J.IsValid(target) and J.CanCastOnNonMagicImmune(target) and not J.CannotBeKilled(bot,target)
        and not target:HasModifier('modifier_item_blade_mail_reflect') and not target:HasModifier('modifier_nyx_assassin_spiked_carapace')
end
local function MobilityBlocked()
    return bot:IsRooted() or bot:HasModifier('modifier_bloodseeker_rupture') or bot:HasModifier('modifier_slark_pounce_leash')
        or bot:HasModifier('modifier_puck_coiled') or bot:HasModifier('modifier_grimstroke_soul_chain')
end
local function Toward(location,range)
    local delta=location-bot:GetLocation()
    return delta:Length2D()==0 and bot:GetLocation() or bot:GetLocation()+delta:Normalized()*math.min(range,delta:Length2D())
end
local function SafePoint(point)
    return IsLocationPassable(point) and not J.IsLocHaveTower(700,true,point) and not J.IsLocationInChrono(point) and not J.IsLocationInBlackHole(point)
end
local function OwnedOrb()
    if IllusoryOrb==nil then return nil end
    for _,projectile in ipairs(GetLinearProjectiles()) do
        if projectile.caster==bot and projectile.ability==IllusoryOrb and projectile.location~=nil then return projectile end
    end
    return nil
end
function X.ConsiderPhaseShift()
    if not J.CanCastAbility(PhaseShift) or bot:HasModifier('modifier_puck_phase_shift') then return 0 end
    if J.IsStunProjectileIncoming(bot,600) or J.IsUnitTargetProjectileIncoming(bot,400)
        or J.GetAttackProjectileDamageByRange(bot,700)>=bot:GetHealth()*0.3 then return BOT_ACTION_DESIRE_HIGH end
    if J.IsRetreating(bot) and bot:WasRecentlyDamagedByAnyHero(2) then
        for slot=0,5 do
            local item=bot:GetItemInSlot(slot)
            if item~=nil and (item:GetName()=='item_blink' or item:GetName()=='item_overwhelming_blink' or item:GetName()=='item_arcane_blink' or item:GetName()=='item_swift_blink')
                and item:GetCooldownTimeRemaining()>0 and item:GetCooldownTimeRemaining()<PhaseShift:GetSpecialValueFloat('duration') then return BOT_ACTION_DESIRE_HIGH end
        end
        if OwnedOrb()~=nil then return BOT_ACTION_DESIRE_HIGH end
    end
    return 0
end
function X.ConsiderEtherealJaunt()
    if not J.CanCastAbility(EtherealJaunt) or MobilityBlocked() then return 0 end
    local orb=OwnedOrb()
    if orb==nil or not SafePoint(orb.location) then return 0 end
    if J.IsRetreating(bot) or bot.puckEscapeOrb==true or J.IsStuck(bot) then
        if GetUnitToLocationDistance(bot,J.GetEscapeLoc())-(orb.location-J.GetEscapeLoc()):Length2D()>=400 then return BOT_ACTION_DESIRE_HIGH end
    end
    local target=J.GetProperTarget(bot)
    if J.IsGoingOnSomeone(bot) and J.IsValidHero(target) and Enemy(target)
        and GetUnitToLocationDistance(target,orb.location)<=bot:GetAttackRange()+150 and GetUnitToUnitDistance(bot,target)>bot:GetAttackRange()
        and #J.GetEnemiesNearLoc(orb.location,700)<=#J.GetAlliesNearLoc(orb.location,700)+1 then return BOT_ACTION_DESIRE_HIGH end
    return 0
end
function X.ConsiderPhaseJaunt()
    if not bot:HasModifier('modifier_puck_phase_shift') or not bot:IsChanneling() then return false end
    local active=bot:GetCurrentActiveAbility()
    if active==nil or active:GetName()~='puck_phase_shift' or not bot:IsAlive() or bot:IsStunned() or bot:IsHexed()
        or bot:IsNightmared() or bot:IsSilenced() or bot:IsCastingAbility() or J.HasQueuedAction(bot)
        or bot:HasModifier('modifier_ringmaster_the_box_buff') or bot:HasModifier('modifier_doom_bringer_doom') or bot:HasModifier('modifier_item_forcestaff_active') then return false end
    if X.ConsiderEtherealJaunt()>0 then bot:Action_UseAbility(EtherealJaunt);bot.puckEscapeOrb=false;return true end
    return false
end
function X.ConsiderIllusoryOrb()
    if not J.CanCastAbility(IllusoryOrb) or bot:HasModifier('modifier_puck_phase_shift') then return 0 end
    local range=IllusoryOrb:GetSpecialValueInt('max_distance')
    if (J.IsRetreating(bot) and bot:WasRecentlyDamagedByAnyHero(2)) or J.IsStuck(bot) then
        bot.puckEscapeOrb=true;return BOT_ACTION_DESIRE_HIGH,Toward(J.GetEscapeLoc(),range)
    end
    local function pointFor(target)
        local eta=IllusoryOrb:GetCastPoint()+GetUnitToUnitDistance(bot,target)/IllusoryOrb:GetSpecialValueInt('orb_speed')
        local predicted=J.GetCorrectLoc(target,eta)
        if GetUnitToLocationDistance(bot,predicted)>range+IllusoryOrb:GetSpecialValueInt('radius') then return nil end
        return Toward(predicted,range),eta
    end
    for _,enemy in ipairs(J.GetNearbyHeroes(bot,1600,true,BOT_MODE_NONE)) do
        if Enemy(enemy) then
            local point,eta=pointFor(enemy)
            if point~=nil and J.WillKillTarget(enemy,IllusoryOrb:GetSpecialValueInt('damage'),DAMAGE_TYPE_MAGICAL,eta) then bot.puckEscapeOrb=false;return BOT_ACTION_DESIRE_HIGH,point end
        end
    end
    local target=J.GetProperTarget(bot)
    if J.IsGoingOnSomeone(bot) and J.IsValidHero(target) and Enemy(target) then
        local point=pointFor(target)
        if point~=nil then bot.puckEscapeOrb=false;return BOT_ACTION_DESIRE_HIGH,point end
    end
    if (J.IsLaning(bot) or J.IsFarming(bot) or J.IsPushing(bot) or J.IsDefending(bot)) and J.IsAllowedToSpam(bot,IllusoryOrb:GetManaCost()) then
        local creeps=bot:GetNearbyCreeps(1600,true)
        for _,creep in ipairs(creeps) do
            if Enemy(creep) then
                local point,eta=pointFor(creep)
                if point~=nil and J.WillKillTarget(creep,IllusoryOrb:GetSpecialValueInt('damage'),DAMAGE_TYPE_MAGICAL,eta)
                    and GetUnitToUnitDistance(bot,creep)>bot:GetAttackRange()+100 then bot.puckEscapeOrb=false;return BOT_ACTION_DESIRE_HIGH,point end
                if point~=nil and not J.IsLaning(bot) then
                    local count=0
                    for _,other in ipairs(creeps) do
                        if Enemy(other) and (J.GetCorrectLoc(other,eta)-point):Length2D()<=IllusoryOrb:GetSpecialValueInt('radius') then count=count+1 end
                    end
                    if count>=3 then bot.puckEscapeOrb=false;return BOT_ACTION_DESIRE_HIGH,point end
                end
            end
        end
    end
    return 0
end
function X.ConsiderWaningRift()
    if not J.CanCastAbility(WaningRift) or bot:HasModifier('modifier_puck_phase_shift') then return 0 end
    local range=MobilityBlocked() and 0 or WaningRift:GetSpecialValueInt('max_distance')
    local radius=WaningRift:GetSpecialValueInt('radius')
    if range>0 and J.IsRetreating(bot) and bot:WasRecentlyDamagedByAnyHero(2) then
        local point=Toward(J.GetEscapeLoc(),range)
        if SafePoint(point) then return BOT_ACTION_DESIRE_HIGH,point end
    end
    for _,enemy in ipairs(J.GetNearbyHeroes(bot,math.min(range+radius,1600),true,BOT_MODE_NONE)) do
        if Enemy(enemy) then
            local predicted=J.GetCorrectLoc(enemy,WaningRift:GetCastPoint())
            local point=Toward(predicted,range)
            if (point-predicted):Length2D()<=radius and SafePoint(point)
                and (enemy:IsChanneling() or J.WillKillTarget(enemy,WaningRift:GetSpecialValueInt('damage'),DAMAGE_TYPE_MAGICAL,WaningRift:GetCastPoint())
                    or (J.IsGoingOnSomeone(bot) and enemy==J.GetProperTarget(bot))) then return BOT_ACTION_DESIRE_HIGH,point end
        end
    end
    if (J.IsFarming(bot) or J.IsPushing(bot) or J.IsDefending(bot)) and J.IsAllowedToSpam(bot,WaningRift:GetManaCost()) then
        local count=0
        for _,creep in ipairs(bot:GetNearbyCreeps(radius,true)) do if Enemy(creep) then count=count+1 end end
        if count>=3 and SafePoint(bot:GetLocation()) then return BOT_ACTION_DESIRE_HIGH,bot:GetLocation() end
    end
    return 0
end
function X.ConsiderDreamCoil()
    if not J.CanCastAbility(DreamCoil) or bot:HasModifier('modifier_puck_phase_shift') then return 0 end
    local range=ActualRange(DreamCoil)
    local radius=DreamCoil:GetSpecialValueInt('coil_radius')
    local enemies=J.GetNearbyHeroes(bot,math.min(range+radius,1600),true,BOT_MODE_NONE)
    for _,enemy in ipairs(enemies) do
        if Enemy(enemy) and not enemy:HasModifier('modifier_puck_coiled') then
            local predicted=J.GetCorrectLoc(enemy,DreamCoil:GetCastPoint())
            local point=Toward(predicted,range)
            if (point-predicted):Length2D()<=radius then
                local count=0
                for _,other in ipairs(enemies) do
                    if Enemy(other) and not other:HasModifier('modifier_puck_coiled') and (J.GetCorrectLoc(other,DreamCoil:GetCastPoint())-point):Length2D()<=radius then count=count+1 end
                end
                if enemy:IsChanneling() or J.WillKillTarget(enemy,DreamCoil:GetSpecialValueInt('coil_initial_damage'),DAMAGE_TYPE_MAGICAL,DreamCoil:GetCastPoint())
                    or (J.IsInTeamFight(bot,1200) and count>=2) or (J.IsGoingOnSomeone(bot) and enemy==J.GetProperTarget(bot) and not J.IsDisabled(enemy))
                    or (J.IsRetreating(bot) and bot:WasRecentlyDamagedByAnyHero(2) and count>=2) then return BOT_ACTION_DESIRE_HIGH,point end
            end
        end
    end
    return 0
end

function X.ConsiderStolenPhaseJaunt()
 local caster=GetBot()
 if not caster:HasModifier('modifier_puck_phase_shift') or not caster:IsChanneling() then return false end
 local active=caster:GetCurrentActiveAbility()
 if active==nil or active:GetName()~='puck_phase_shift' then return false end
 Refresh();return X.ConsiderPhaseJaunt()
end
function X.ConsiderStolenSpell(ability)
 local name=ability:GetName()
 local names={puck_illusory_orb=true,puck_waning_rift=true,puck_phase_shift=true,puck_ethereal_jaunt=true,puck_dream_coil=true}
 if not names[name] then return nil end
 Refresh()
 if J.CanNotUseAbility(bot) or not J.CanCastAbility(ability) then return false end
 local choices={puck_illusory_orb=X.ConsiderIllusoryOrb,puck_waning_rift=X.ConsiderWaningRift,puck_phase_shift=X.ConsiderPhaseShift,puck_ethereal_jaunt=X.ConsiderEtherealJaunt,puck_dream_coil=X.ConsiderDreamCoil}
 local desire,point=choices[name]()
 if desire<=0 then return false end
 if name=='puck_phase_shift' or name=='puck_ethereal_jaunt' then bot:Action_UseAbility(ability) else bot:Action_UseAbilityOnLocation(ability,point) end
 return true
end
return X
