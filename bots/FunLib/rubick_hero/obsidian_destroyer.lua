local X={}
local J=require(GetScriptDirectory()..'/FunLib/jmz_func')
local ItemCastPolicy=require(GetScriptDirectory()..'/FunLib/item_cast_policy')
local bot,ArcaneOrb,AstralImprisonment,SanitysEclipse,Objurgation
local function Refresh()
    bot=GetBot()
    ArcaneOrb=bot:GetAbilityByName('obsidian_destroyer_arcane_orb')
    AstralImprisonment=bot:GetAbilityByName('obsidian_destroyer_astral_imprisonment')
    SanitysEclipse=bot:GetAbilityByName('obsidian_destroyer_sanity_eclipse')
    Objurgation=bot:GetAbilityByName('obsidian_destroyer_objurgation')
end
function X.OrbManaReserve()
    local reserve = ItemCastPolicy.Ready(AstralImprisonment) and AstralImprisonment:GetManaCost() or 0
    if #J.GetNearbyHeroes(bot, 1600, true, BOT_MODE_NONE) > 0 then
        -- Preserve Astral plus the more expensive ready combat spell. Essence
        -- Flux (obsidian_destroyer_equilibrium) is random; no proc is promised.
        local eclipse = ItemCastPolicy.Ready(SanitysEclipse) and SanitysEclipse:GetManaCost() or 0
        local barrier = ItemCastPolicy.Ready(Objurgation) and Objurgation:GetManaCost() or 0
        reserve = reserve + math.max(eclipse, barrier)
    end
    return reserve
end

function X.CanSpendOrb(buffer)
    local cost = math.max(ArcaneOrb:GetManaCost(),
        bot:GetMana() * ArcaneOrb:GetSpecialValueInt('mana_cost_percentage') / 100)
    return ArcaneOrb:IsTrained() and bot:GetMana() - cost >= X.OrbManaReserve() + (buffer or 0)
end

local function SpellRange(ability)
    local range=ability:GetCastRange()
    local lens=J.IsItemAvailable('item_aether_lens')
    if lens~=nil then range=range+lens:GetSpecialValueInt('cast_range_bonus') end
    local supremacy=bot:GetAbilityByName('rubick_arcane_supremacy')
    if supremacy~=nil and supremacy:IsTrained() and not J.HasBreakModifier(bot) then range=range+supremacy:GetSpecialValueInt('cast_range') end
    return range
end
function X.ConsiderArcaneOrb()
    if bot:IsDisarmed() or not ArcaneOrb:IsFullyCastable()
    or ArcaneOrb:GetAutoCastState()
    or not X.CanSpendOrb()
    then
        return BOT_ACTION_DESIRE_NONE, nil
    end

    local nAttackRange = bot:GetAttackRange()
    local botTarget = J.GetProperTarget(bot)

    if J.IsGoingOnSomeone(bot)
	then
        local weakestTarget = J.GetVulnerableWeakestUnit(bot, true, true, nAttackRange)
        local nInRangeAlly = J.GetNearbyHeroes(bot,800, false, BOT_MODE_NONE)

		if J.IsValidTarget(weakestTarget)
        and J.CanBeAttacked(weakestTarget)
        and J.CanCastOnNonMagicImmune(weakestTarget)
        and J.IsInRange(bot, weakestTarget, nAttackRange)
        and not J.IsSuspiciousIllusion(weakestTarget)
        and not weakestTarget:HasModifier('modifier_abaddon_borrowed_time')
        and not weakestTarget:HasModifier('modifier_dazzle_shallow_grave')
        and not weakestTarget:HasModifier('modifier_necrolyte_reapers_scythe')
        and not weakestTarget:HasModifier('modifier_templar_assassin_refraction_absorb')
        and not weakestTarget:HasModifier('modifier_nyx_assassin_spiked_carapace')
        and not weakestTarget:HasModifier('modifier_item_blade_mail_reflect')
		then
            local nTargetInRangeAlly = J.GetNearbyHeroes(weakestTarget, 800, false, BOT_MODE_NONE)

            if nInRangeAlly ~= nil and nTargetInRangeAlly ~= nil
            and #nInRangeAlly >= #nTargetInRangeAlly
            then
                return BOT_ACTION_DESIRE_HIGH, weakestTarget
            end
		end
	end

    if J.IsDoingRoshan(bot)
    then
        if J.IsRoshan(botTarget)
        and J.CanCastOnNonMagicImmune(botTarget)
        and J.IsInRange(bot, botTarget, nAttackRange)
        and J.IsAttacking(bot)
        then
            return BOT_ACTION_DESIRE_HIGH, botTarget
        end
    end

    if J.IsDoingTormentor(bot)
    then
        if J.IsTormentor(botTarget)
        and J.IsInRange(bot, botTarget, nAttackRange)
        and J.IsAttacking(bot)
        then
            return BOT_ACTION_DESIRE_HIGH, botTarget
        end
    end

    return BOT_ACTION_DESIRE_NONE, nil
end

local prison='modifier_obsidian_destroyer_astral_imprisonment_prison'
local function Enemy(enemy)
    return J.IsValidHero(enemy) and not J.IsSuspiciousIllusion(enemy)
        and J.CanCastOnNonMagicImmune(enemy)
end
local function SaveTarget(ally)
    return J.IsValidHero(ally) and not ally:IsIllusion() and not ally:IsMagicImmune()
        and not ally:IsInvulnerable() and not ally:HasModifier(prison)
        and J.IsInRange(bot,ally,SpellRange(AstralImprisonment)) and not ally:IsChanneling()
        and (ally:HasModifier('modifier_legion_commander_duel')
            or ally:HasModifier('modifier_enigma_black_hole_pull')
            or ally:HasModifier('modifier_faceless_void_chronosphere_freeze')
            or ally:HasModifier('modifier_necrolyte_reapers_scythe')
            or J.GetHP(ally)<0.3 and (ally:WasRecentlyDamagedByAnyHero(1)
                or J.IsUnitTargetProjectileIncoming(ally,400)))
end
function X.ConsiderAstralSave()
    if not J.CanCastAbility(AstralImprisonment) then return 0 end
    for _,ally in ipairs(J.GetNearbyHeroes(bot,math.min(SpellRange(AstralImprisonment),1600),false,BOT_MODE_NONE)) do
        if SaveTarget(ally) then return BOT_ACTION_DESIRE_HIGH,ally end
    end
    if SaveTarget(bot) then return BOT_ACTION_DESIRE_HIGH,bot end
    return 0
end
function X.ConsiderAstralImprisonment()
    if not J.CanCastAbility(AstralImprisonment) then return 0 end
    local desire,target=X.ConsiderAstralSave()
    if desire>0 then return desire,target end
    local range=SpellRange(AstralImprisonment)
    local enemies=J.GetNearbyHeroes(bot,math.min(range,1600),true,BOT_MODE_NONE)
    for _,enemy in ipairs(enemies) do
        if Enemy(enemy) and J.IsInRange(bot,enemy,range) and J.CanCastOnTargetAdvanced(enemy) then
            if enemy:IsChanneling() or J.IsCastingUltimateAbility(enemy) then return BOT_ACTION_DESIRE_HIGH,enemy end
            local delay=AstralImprisonment:GetCastPoint()+AstralImprisonment:GetSpecialValueFloat('prison_duration')
            if not J.CannotBeKilled(bot,enemy) and J.WillKillTarget(enemy,AstralImprisonment:GetSpecialValueInt('damage'),DAMAGE_TYPE_MAGICAL,delay)
                and #J.GetNearbyHeroes(bot,800,false,BOT_MODE_NONE)<=1 then return BOT_ACTION_DESIRE_HIGH,enemy end
            if J.IsRetreating(bot) and bot:WasRecentlyDamagedByAnyHero(2)
                and J.IsChasingTarget(enemy,bot) and not J.IsDisabled(enemy) then return BOT_ACTION_DESIRE_HIGH,enemy end
        end
    end
    target=J.GetProperTarget(bot)
    if Enemy(target) and J.IsInRange(bot,target,range) and J.CanCastOnTargetAdvanced(target)
        and not J.IsDisabled(target) and not J.IsTaunted(target) then
        -- Do not remove an already held victim from allied attacks.
        if J.IsGoingOnSomeone(bot) and (J.IsChasingTarget(bot,target)
            or #J.GetNearbyHeroes(bot,800,false,BOT_MODE_NONE)<=1) then return BOT_ACTION_DESIRE_HIGH,target end
        if J.IsLaning(bot) and J.IsAllowedToSpam(bot,AstralImprisonment:GetManaCost())
            and J.IsAttacking(target) and not target:IsDisarmed() then
            for _,creep in ipairs(bot:GetNearbyLaneCreeps(800,true)) do
                if J.IsValid(creep) and creep:GetHealth()<bot:GetAttackDamage()*2
                    and J.IsInRange(target,creep,target:GetAttackRange()+100) then return BOT_ACTION_DESIRE_HIGH,target end
            end
        end
    end
    return 0
end
local function EclipseEnemy(enemy)
    if enemy==nil or enemy:IsNull() or not enemy:IsAlive() or not enemy:IsHero()
        or J.IsSuspiciousIllusion(enemy) or enemy:IsMagicImmune() or J.CannotBeKilled(bot,enemy)
        or enemy:HasModifier('modifier_nyx_assassin_spiked_carapace')
        or enemy:HasModifier('modifier_item_blade_mail_reflect') then return false end
    -- Astral is the explicitly supported invulnerability exception.
    return Enemy(enemy) or enemy:HasModifier(prison)
end
local function EclipsePoint(enemy)
    local location=enemy:HasModifier(prison) and enemy:GetLocation() or J.GetCorrectLoc(enemy,SanitysEclipse:GetCastPoint())
    local delta=location-bot:GetLocation()
    if delta:Length2D()>SpellRange(SanitysEclipse) then location=bot:GetLocation()+delta:Normalized()*SpellRange(SanitysEclipse) end
    local predicted=enemy:HasModifier(prison) and enemy:GetLocation() or J.GetCorrectLoc(enemy,SanitysEclipse:GetCastPoint())
    if (predicted-location):Length2D()>SanitysEclipse:GetSpecialValueInt('radius') then return nil end
    return location
end
function X.ConsiderSanitysEclipse()
    if not J.CanCastAbility(SanitysEclipse) then return 0 end
    local range,radius=SpellRange(SanitysEclipse),SanitysEclipse:GetSpecialValueInt('radius')
    local enemies=GetUnitList(UNIT_LIST_ENEMY_HEROES)
    local best,count=nil,0
    for _,enemy in ipairs(enemies) do
        if EclipseEnemy(enemy) and GetUnitToUnitDistance(bot,enemy)<=range+radius then
            local point=EclipsePoint(enemy)
            if point~=nil then
                local damage=SanitysEclipse:GetSpecialValueInt('base_damage')
                    +math.max(0,bot:GetMaxMana()-enemy:GetMaxMana())*SanitysEclipse:GetSpecialValueFloat('damage_multiplier')
                if J.WillKillTarget(enemy,damage,DAMAGE_TYPE_MAGICAL,SanitysEclipse:GetCastPoint()) then return BOT_ACTION_DESIRE_HIGH,point end
                local hits=0
                for _,other in ipairs(enemies) do
                    if EclipseEnemy(other) then
                        local predicted=other:HasModifier(prison) and other:GetLocation() or J.GetCorrectLoc(other,SanitysEclipse:GetCastPoint())
                        if (predicted-point):Length2D()<=radius then hits=hits+1 end
                    end
                end
                if hits>count then best,count=point,hits end
            end
        end
    end
    if count>=2 and (J.IsInTeamFight(bot,1200) or J.IsGoingOnSomeone(bot)) then return BOT_ACTION_DESIRE_HIGH,best end
    return 0
end
function X.ConsiderObjurgation()
    if not J.CanCastAbility(Objurgation) then return 0 end
    for i=0,bot:NumModifiers()-1 do
        if bot:GetModifierSourceAbility(i)==Objurgation and bot:GetModifierRemainingDuration(i)>0 then return 0 end
    end
    local barrier=Objurgation:GetSpecialValueInt('barrier_flat')+bot:GetMaxMana()*Objurgation:GetSpecialValueFloat('mana_to_barrier')/100
    if J.IsUnitTargetProjectileIncoming(bot,400) then return BOT_ACTION_DESIRE_HIGH end
    local enemies=J.GetNearbyHeroes(bot,800,true,BOT_MODE_NONE)
    local damage=0
    for _,enemy in ipairs(enemies) do
        if Enemy(enemy) then damage=damage+enemy:GetEstimatedDamageToTarget(true,bot,2,DAMAGE_TYPE_ALL) end
    end
    if bot:WasRecentlyDamagedByAnyHero(1) and damage>=math.min(barrier*0.5,bot:GetHealth()*0.3) then return BOT_ACTION_DESIRE_HIGH end
    if #enemies>=2 and J.IsInTeamFight(bot,1200) and damage>=barrier then return BOT_ACTION_DESIRE_HIGH end
    return 0
end

function X.ConsiderStolenSpell(ability)
    local spellName=ability:GetName()
    if spellName~='obsidian_destroyer_arcane_orb' and spellName~='obsidian_destroyer_astral_imprisonment' and spellName~='obsidian_destroyer_sanity_eclipse' and spellName~='obsidian_destroyer_objurgation' then return nil end
    Refresh()
    if J.CanNotUseAbility(bot) or not J.CanCastAbility(ability) then return false end
    local name=ability:GetName()
    local desire,target=0,nil
    if name=='obsidian_destroyer_arcane_orb' then desire,target=X.ConsiderArcaneOrb()
    elseif name=='obsidian_destroyer_astral_imprisonment' then desire,target=X.ConsiderAstralImprisonment()
    elseif name=='obsidian_destroyer_sanity_eclipse' then desire,target=X.ConsiderSanitysEclipse()
    elseif name=='obsidian_destroyer_objurgation' then desire=X.ConsiderObjurgation() end
    if desire==nil or desire<=0 then return false end
    if name=='obsidian_destroyer_sanity_eclipse' then bot:Action_UseAbilityOnLocation(ability,target)
    elseif name=='obsidian_destroyer_objurgation' then bot:Action_UseAbility(ability)
    else bot:Action_UseAbilityOnEntity(ability,target) end
    return true
end
return X
