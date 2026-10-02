local X = {}
local bot = GetBot()

local J = require( GetScriptDirectory()..'/FunLib/jmz_func' )
local ItemCastPolicy = require(GetScriptDirectory()..'/FunLib/item_cast_policy')
local PowerTreads = require(GetScriptDirectory()..'/FunLib/power_treads')
local Minion = dofile( GetScriptDirectory()..'/FunLib/aba_minion' )
local sTalentList = J.Skill.GetTalentList( bot )
local sAbilityList = J.Skill.GetAbilityList( bot )
local sRole = J.Item.GetRoleItemsBuyList( bot )

-- Updated to 7.41f from D2PT: mid only; forced other roles use mid.
local BuildData = require(GetScriptDirectory()..'/BotLib/Builds/obsidian_destroyer')
X.buildMetadata = BuildData
X.neutralPreferences = BuildData.neutrals[sRole]
-- [1] Arcane Orb, [2] Astral Imprisonment, [3] Objurgation, [6] Sanity's Eclipse.
local nAbilityBuildList = {2,1,2,3,2,6,2,1,1,1,6,3,3,3,6}
local nTalentBuildList = J.Skill.GetTalentBuild({
    t10={10,0}, -- +200 mana
    t15={10,0}, -- +0.8% current mana as movement speed
    t20={0,10}, -- -10s Objurgation cooldown
    t25={10,0}, -- -60s Sanity's Eclipse cooldown
})
local defaultAbilityBuild, defaultTalentBuild = nAbilityBuildList, nTalentBuildList
-- Omit the observed opening ward on the core build.
X.sBuyList = {
    'item_mantle','item_double_branches','item_circlet','item_tango','item_faerie_fire',
    'item_null_talisman','item_null_talisman','item_magic_wand','item_power_treads','item_witch_blade',
    'item_force_staff','item_blink','item_dragon_lance','item_hurricane_pike',
    'item_black_king_bar','item_ultimate_scepter',
    -- Bot policy: retain Witch Blade, consume Scepter and add late control within six slots.
    'item_ultimate_scepter_2','item_sheepstick',
    'item_aghanims_shard','item_arcane_blink','item_moon_shard',
}
X.sSellList = {'item_blink','item_null_talisman','item_hurricane_pike','item_null_talisman','item_black_king_bar','item_magic_wand'}

if J.Role.IsPvNMode() or J.Role.IsAllShadow() then X['sBuyList'], X['sSellList'] = { 'PvN_mid' }, {} end

nAbilityBuildList, nTalentBuildList, X['sBuyList'], X['sSellList'] = J.SetUserHeroInit( nAbilityBuildList, nTalentBuildList, X['sBuyList'], X['sSellList'] )

X['sSkillList'] = J.Skill.GetSkillList( sAbilityList, nAbilityBuildList, sTalentList, nTalentBuildList )
-- Fourth Arcane Orb point at 10, first talent at 11; preserve custom overrides.
if nAbilityBuildList == defaultAbilityBuild and nTalentBuildList == defaultTalentBuild then
    X.sSkillList[10], X.sSkillList[11] = X.sSkillList[11], X.sSkillList[10]
end

X['bDeafaultAbility'] = false
X['bDeafaultItem'] = false

function X.MinionThink(hMinionUnit)

	if Minion.IsValidUnit( hMinionUnit )
	then
		Minion.IllusionThink( hMinionUnit )
	end
end

local ArcaneOrb             = bot:GetAbilityByName('obsidian_destroyer_arcane_orb')
local AstralImprisonment    = bot:GetAbilityByName('obsidian_destroyer_astral_imprisonment')
local SanitysEclipse        = bot:GetAbilityByName('obsidian_destroyer_sanity_eclipse')
local Objurgation           = bot:GetAbilityByName('obsidian_destroyer_objurgation')

local ArcaneOrbDesire, ArcaneOrbTarget
local AstralImprisonmentDesire, AstralImprisonmentTarget
local SanitysEclipseDesire, SanitysEclipseLocation
local ObjurgationDesire

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

function X.UpdateOrbAutocast()
    if not ArcaneOrb:IsTrained() then return end
    local target = bot:GetAttackTarget()
    local current = ArcaneOrb:GetAutoCastState()
    -- IsValidTarget is hero-only in this repository; IsValid also accepts
    -- creeps so the reserve policy does not silently disable farm autocast.
    local useful = not bot:IsDisarmed() and J.IsValid(target) and J.CanBeAttacked(target)
        and J.CanCastOnNonMagicImmune(target)
        and J.IsInRange(bot, target, bot:GetAttackRange() + 50)
        and not J.IsSuspiciousIllusion(target)
        and not target:HasModifier('modifier_abaddon_borrowed_time')
        and not target:HasModifier('modifier_dazzle_shallow_grave')
        and not target:HasModifier('modifier_templar_assassin_refraction_absorb')
        and not target:HasModifier('modifier_nyx_assassin_spiked_carapace')
        and not target:HasModifier('modifier_item_blade_mail_reflect')
        and (target:IsHero() or target:GetHealth() > bot:GetAttackDamage())
    -- Leave cheap last hits to ordinary attacks; allow healthy farm targets.
    -- A small restart buffer prevents toggling at the reserve boundary.
    local desired = useful == true and X.CanSpendOrb(current and 0 or bot:GetMaxMana() * 0.05)
    if current ~= desired then ArcaneOrb:ToggleAutoCast() end
end

local function SpellRange(ability)
    local range=ability:GetCastRange()
    local lens=J.IsItemAvailable('item_aether_lens')
    if lens~=nil then range=range+lens:GetSpecialValueInt('cast_range_bonus') end
    local supremacy=bot:GetAbilityByName('rubick_arcane_supremacy')
    if supremacy~=nil and supremacy:IsTrained() and not J.HasBreakModifier(bot) then range=range+supremacy:GetSpecialValueInt('cast_range') end
    return range
end
local function castOrRequest(ability, target, kind, consider)
    if ability:IsFullyCastable() then
        ItemCastPolicy.Clear(bot)
        if kind == 'unit' then bot:Action_UseAbilityOnEntity(ability, target)
        elseif kind == 'ground' then bot:Action_UseAbilityOnLocation(ability, target)
        else bot:Action_UseAbility(ability) end
        return true
    end
    return ItemCastPolicy.Request(bot, ability, target, kind, function()
        local desire, freshTarget = consider()
        if desire <= 0 then return false end
        if kind == 'ground' then
            return freshTarget ~= nil and GetUnitToLocationDistance(bot, freshTarget) <= SpellRange(ability)
                and (freshTarget - target):Length2D() < 50
        end
        return kind == 'none' or freshTarget == target
    end, J)
end

function X.SkillsComplement()
    ItemCastPolicy.Clear(bot)
    if PowerTreads.ActionLocked(bot) or J.CanNotUseAbility(bot) then return end
    X.UpdateOrbAutocast()

    local saveDesire,saveTarget=X.ConsiderAstralSave()
    if saveDesire>0 and castOrRequest(AstralImprisonment,saveTarget,'unit',X.ConsiderAstralSave) then return end

    ObjurgationDesire = X.ConsiderObjurgation()
    if ObjurgationDesire > 0 and castOrRequest(Objurgation, nil, 'none', X.ConsiderObjurgation)
    then
        return
    end

    SanitysEclipseDesire, SanitysEclipseLocation = X.ConsiderSanitysEclipse()
    if SanitysEclipseDesire > 0 and castOrRequest(SanitysEclipse, SanitysEclipseLocation, 'ground', X.ConsiderSanitysEclipse)
    then
        return
    end

    AstralImprisonmentDesire, AstralImprisonmentTarget = X.ConsiderAstralImprisonment()
    if AstralImprisonmentDesire > 0 and castOrRequest(AstralImprisonment, AstralImprisonmentTarget, 'unit', X.ConsiderAstralImprisonment)
    then
        return
    end

    ArcaneOrbDesire, ArcaneOrbTarget = X.ConsiderArcaneOrb()
    if ArcaneOrbDesire > 0
    then
        bot:Action_UseAbilityOnEntity(ArcaneOrb, ArcaneOrbTarget)
        return
    end
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
    if not ItemCastPolicy.CanConsider(bot,AstralImprisonment) then return 0 end
    for _,ally in ipairs(J.GetNearbyHeroes(bot,math.min(SpellRange(AstralImprisonment),1600),false,BOT_MODE_NONE)) do
        if SaveTarget(ally) then return BOT_ACTION_DESIRE_HIGH,ally end
    end
    if SaveTarget(bot) then return BOT_ACTION_DESIRE_HIGH,bot end
    return 0
end
function X.ConsiderAstralImprisonment()
    if not ItemCastPolicy.CanConsider(bot,AstralImprisonment) then return 0 end
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
    if not ItemCastPolicy.CanConsider(bot,SanitysEclipse) then return 0 end
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
    if not ItemCastPolicy.CanConsider(bot,Objurgation) then return 0 end
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

return X
