local X={}
local J=require(GetScriptDirectory()..'/FunLib/jmz_func')
local bot,abilityQ,abilityW,abilityE,abilityR
local function Refresh()
 bot=GetBot();abilityQ=bot:GetAbilityByName('phantom_lancer_spirit_lance');abilityW=bot:GetAbilityByName('phantom_lancer_doppelwalk')
 abilityE=bot:GetAbilityByName('phantom_lancer_phantom_edge');abilityR=bot:GetAbilityByName('phantom_lancer_juxtapose')
end
local function ActualRange(ability)
    local range=ability:GetCastRange()
    for slot=0,5 do local item=bot:GetItemInSlot(slot);if item~=nil and item:GetName()=='item_aether_lens' then range=range+item:GetSpecialValueInt('cast_range_bonus');break end end
    local supremacy=bot:GetAbilityByName('rubick_arcane_supremacy')
    if supremacy~=nil and supremacy:IsTrained() and not J.HasBreakModifier(bot) then range=range+supremacy:GetSpecialValueInt('cast_range') end
    return range
end
local function MobilityBlocked()
    return bot:IsRooted() or bot:HasModifier('modifier_slark_pounce_leash') or bot:HasModifier('modifier_puck_coiled')
        or bot:HasModifier('modifier_grimstroke_soul_chain') or bot:HasModifier('modifier_bloodseeker_rupture')
end
local function SafePoint(point,scatter)
    if not IsLocationPassable(point) then return false end
    for _,offset in ipairs({Vector(0,0),Vector(scatter,0),Vector(-scatter,0),Vector(0,scatter),Vector(0,-scatter)}) do
        local p=point+offset
        if J.IsLocationInChrono(p) or J.IsLocationInBlackHole(p) or J.IsLocHaveTower(700,true,p) then return false end
    end
    return true
end
local function PointToward(location,range)
    local delta=location-bot:GetLocation()
    if delta:Length2D()==0 then return bot:GetLocation() end
    return bot:GetLocation()+delta:Normalized()*math.min(range,delta:Length2D())
end
function X.ConsiderW()
    if not J.CanCastAbility(abilityW) or MobilityBlocked() then return 0 end
    local incoming=J.IsUnitTargetProjectileIncoming(bot,600) or J.GetAttackProjectileDamageByRange(bot,1000)>=bot:GetHealth()
    local dispel=bot:HasModifier('modifier_item_dustofappearance') or bot:HasModifier('modifier_item_spirit_vessel_damage')
        or bot:HasModifier('modifier_silence') or bot:HasModifier('modifier_item_orchid_malevolence_debuff')
        or bot:HasModifier('modifier_item_bloodthorn_debuff') or bot:HasModifier('modifier_life_stealer_open_wounds')
    if incoming or dispel or (J.IsRetreating(bot) and bot:WasRecentlyDamagedByAnyHero(2)) then
        local range=ActualRange(abilityW)
        local scatter=abilityW:GetSpecialValueInt('target_aoe')
        for _,distance in ipairs({range,range*0.65,range*0.3,0}) do
            local point=PointToward(J.GetEscapeLoc(),distance)
            if SafePoint(point,scatter) then return BOT_ACTION_DESIRE_HIGH,point end
        end
    end
    return 0
end
function X.ConsiderR()
    if not J.CanCastAbility(abilityR) or abilityR:IsPassive() or bot:IsInvisible() then return 0 end
    if (J.IsRetreating(bot) and bot:WasRecentlyDamagedByAnyHero(2)) or J.IsUnitTargetProjectileIncoming(bot,600)
        or (J.GetHP(bot)<0.35 and #J.GetNearbyHeroes(bot,800,true,BOT_MODE_NONE)>0) then return BOT_ACTION_DESIRE_HIGH end
    local target=J.GetProperTarget(bot)
    if J.IsGoingOnSomeone(bot) and J.IsValidHero(target) and GetUnitToUnitDistance(bot,target)>600
        and GetUnitToUnitDistance(bot,target)<=1600 and #J.GetNearbyHeroes(bot,500,true,BOT_MODE_NONE)==0 then return BOT_ACTION_DESIRE_HIGH end
    return 0
end
function X.ConsiderQ()
    if not J.CanCastAbility(abilityQ) or bot:IsInvisible() then return 0 end
    local range=ActualRange(abilityQ)
    local damage=abilityQ:GetSpecialValueInt('lance_damage')
    local function legal(target) return J.IsValid(target) and J.CanCastOnNonMagicImmune(target) and J.CanCastOnTargetAdvanced(target)
        and GetUnitToUnitDistance(bot,target)<=range and not J.CannotBeKilled(bot,target)
        and not target:HasModifier('modifier_nyx_assassin_spiked_carapace') and not target:HasModifier('modifier_item_blade_mail_reflect') end
    local function lethal(target) return J.WillKillTarget(target,damage,DAMAGE_TYPE_MAGICAL,abilityQ:GetCastPoint()+GetUnitToUnitDistance(bot,target)/abilityQ:GetSpecialValueInt('lance_speed')) end
    for _,enemy in ipairs(J.GetNearbyHeroes(bot,math.min(range,1600),true,BOT_MODE_NONE)) do if legal(enemy) and lethal(enemy) then return BOT_ACTION_DESIRE_HIGH,enemy end end
    local target=J.GetProperTarget(bot)
    if J.IsGoingOnSomeone(bot) and J.IsValidHero(target) and legal(target) then return BOT_ACTION_DESIRE_HIGH,target end
    if J.IsRetreating(bot) and bot:WasRecentlyDamagedByAnyHero(2) then
        for _,enemy in ipairs(J.GetNearbyHeroes(bot,math.min(range,1600),true,BOT_MODE_NONE)) do if legal(enemy) and J.IsChasingTarget(enemy,bot) then return BOT_ACTION_DESIRE_HIGH,enemy end end
    end
    if J.IsLaning(bot) or J.IsFarming(bot) or J.IsPushing(bot) or J.IsDefending(bot) then
        if J.IsAllowedToSpam(bot,abilityQ:GetManaCost()+(J.CanCastAbility(abilityW) and abilityW:GetManaCost() or 0)) then
            for _,creep in ipairs(bot:GetNearbyLaneCreeps(range,true)) do
                if legal(creep) and not creep:HasModifier('modifier_fountain_glyph') and lethal(creep)
                    and GetUnitToUnitDistance(bot,creep)>bot:GetAttackRange()+100 then return BOT_ACTION_DESIRE_HIGH,creep end
            end
            if J.IsFarming(bot) and legal(target) and not J.IsValidHero(target) and target:GetHealth()>damage+bot:GetAttackDamage()
                and bot:GetMana()/bot:GetMaxMana()>0.65 then return BOT_ACTION_DESIRE_HIGH,target end
        end
    end
    return 0
end
function X.ConsiderRushToggle()
    if abilityE==nil or not abilityE:IsTrained() or bot:HasModifier('modifier_phantom_lancer_phantom_edge_boost') then return 0 end
    local disable=J.IsLaning(bot) or J.IsRetreating(bot) or MobilityBlocked()
    if disable~=abilityE:GetToggleState() then return BOT_ACTION_DESIRE_HIGH end
    return 0
end

function X.ConsiderStolenSpell(ability)
 local name=ability:GetName()
 if name~='phantom_lancer_spirit_lance' and name~='phantom_lancer_doppelwalk' and name~='phantom_lancer_juxtapose' and name~='phantom_lancer_phantom_edge' then return nil end
 Refresh()
 if J.CanNotUseAbility(bot) or (name~='phantom_lancer_phantom_edge' and not J.CanCastAbility(ability)) then return false end
 local choices={phantom_lancer_spirit_lance=X.ConsiderQ,phantom_lancer_doppelwalk=X.ConsiderW,phantom_lancer_juxtapose=X.ConsiderR,phantom_lancer_phantom_edge=X.ConsiderRushToggle}
 local desire,target=choices[name]()
 if desire<=0 then return false end
 if name=='phantom_lancer_spirit_lance' then bot:Action_UseAbilityOnEntity(ability,target)
 elseif name=='phantom_lancer_doppelwalk' then bot:Action_UseAbilityOnLocation(ability,target) else bot:Action_UseAbility(ability) end
 return true
end
return X
