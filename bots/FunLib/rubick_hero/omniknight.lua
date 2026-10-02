local X={}
local J=require(GetScriptDirectory()..'/FunLib/jmz_func')
local bot,abilityQ,abilityW,abilityE,abilityR
local function Refresh()
    bot=GetBot();abilityQ=bot:GetAbilityByName('omniknight_purification')
    abilityW=bot:GetAbilityByName('omniknight_martyr');abilityE=bot:GetAbilityByName('omniknight_hammer_of_purity')
    abilityR=bot:GetAbilityByName('omniknight_guardian_angel')
end
local function SpellRange(ability)
    local range=ability:GetCastRange()
    local lens=J.IsItemAvailable('item_aether_lens')
    if lens~=nil then range=range+lens:GetSpecialValueInt('cast_range_bonus') end
    local supremacy=bot:GetAbilityByName('rubick_arcane_supremacy')
    if supremacy~=nil and supremacy:IsTrained() and not J.HasBreakModifier(bot) then range=range+supremacy:GetSpecialValueInt('cast_range') end
    return range
end
local function Ally(ally,ability)
    return J.IsValid(ally) and ally:GetTeam()==bot:GetTeam() and not ally:IsIllusion()
        and not ally:IsInvulnerable() and J.IsInRange(bot,ally,SpellRange(ability))
end
local function Allies(range)
    local allies=J.GetNearbyHeroes(bot,math.min(range,1600),false,BOT_MODE_NONE)
    allies[#allies+1]=bot
    return allies
end
function X.ConsiderQ()
    if not J.CanCastAbility(abilityQ) then return 0 end
    local range,radius=SpellRange(abilityQ),abilityQ:GetSpecialValueInt('radius')
    local heal=abilityQ:GetSpecialValueInt('heal')
    local candidates=Allies(range)
    for _,creep in ipairs(bot:GetNearbyCreeps(math.min(range,1600),false)) do candidates[#candidates+1]=creep end
    local best,score=nil,0
    for _,ally in ipairs(candidates) do
        if Ally(ally,abilityQ) then
            local healing=not ally:HasModifier('modifier_ice_blast') and not ally:HasModifier('modifier_fountain_aura')
                and math.min(heal,ally:GetMaxHealth()-ally:GetHealth()) or 0
            if ally:IsHero() and healing>0 and J.GetHP(ally)<0.3
                and (ally:WasRecentlyDamagedByAnyHero(2) or J.GetHP(ally)<0.15) then return BOT_ACTION_DESIRE_HIGH,ally end
            local hit=0
            for _,enemy in ipairs(J.GetNearbyHeroes(ally,radius,true,BOT_MODE_NONE)) do
                if J.IsValidHero(enemy) and J.CanCastOnMagicImmune(enemy) and not J.IsSuspiciousIllusion(enemy)
                    and not J.CannotBeKilled(bot,enemy)
                    and (J.GetCorrectLoc(enemy,abilityQ:GetCastPoint())-J.GetCorrectLoc(ally,abilityQ:GetCastPoint())):Length2D()<=radius then
                    if J.WillKillTarget(enemy,heal,DAMAGE_TYPE_PURE,abilityQ:GetCastPoint()) then return BOT_ACTION_DESIRE_HIGH,ally end
                    hit=hit+1
                end
            end
            local creepKills=0
            if J.IsLaning(bot) or J.IsFarming(bot) or J.IsPushing(bot) or J.IsDefending(bot) then
                for _,creep in ipairs(bot:GetNearbyLaneCreeps(math.min(range+radius,1600),true)) do
                    if J.IsValid(creep) and J.CanCastOnMagicImmune(creep) and J.IsInRange(ally,creep,radius)
                        and not creep:HasModifier('modifier_fountain_glyph')
                        and J.WillKillTarget(creep,heal,DAMAGE_TYPE_PURE,abilityQ:GetCastPoint())
                        and (not J.IsLaning(bot) or J.IsKeyWordUnit('ranged',creep) and not J.IsOtherAllysTarget(creep)) then creepKills=creepKills+1 end
                end
            end
            local useful=healing>=heal*0.65 and (hit>0 or J.IsRetreating(bot) or not J.IsLaning(bot))
                or hit>=2 and (J.IsInTeamFight(bot,1200) or J.IsGoingOnSomeone(bot))
                or creepKills>=(J.IsLaning(bot) and 1 or 3) and J.IsAllowedToSpam(bot,abilityQ:GetManaCost())
            if useful then
                local value=healing+hit*heal+creepKills*50
                if value>score then best,score=ally,value end
            end
        end
    end
    if best~=nil then return BOT_ACTION_DESIRE_HIGH,best end
    if J.IsFarming(bot) and J.IsAllowedToSpam(bot,abilityQ:GetManaCost()) then
        local count=0
        for _,creep in ipairs(bot:GetNearbyNeutralCreeps(radius)) do
            if J.IsValid(creep) and J.CanCastOnMagicImmune(creep) then count=count+1 end
        end
        if count>=3 then return BOT_ACTION_DESIRE_HIGH,bot end
    end
    return 0
end
function X.ConsiderW()
    if not J.CanCastAbility(abilityW) then return 0 end
    local best,score=nil,0
    for _,ally in ipairs(Allies(SpellRange(abilityW))) do
        if Ally(ally,abilityW) and ally:IsHero() and not ally:IsMagicImmune()
            and not ally:HasModifier('modifier_omniknight_martyr') then
            if J.IsUnitTargetProjectileIncoming(ally,400) or J.IsWillBeCastUnitTargetSpell(ally,1200)
                or (ally:IsRooted() or ally:IsSilenced()) and #J.GetNearbyHeroes(ally,900,true,BOT_MODE_NONE)>0 then return BOT_ACTION_DESIRE_HIGH,ally end
            local magic=0
            for _,enemy in ipairs(J.GetNearbyHeroes(ally,1000,true,BOT_MODE_NONE)) do
                if J.IsValidHero(enemy) then
                    local all=enemy:GetEstimatedDamageToTarget(true,ally,2,DAMAGE_TYPE_ALL)
                    local physical=enemy:GetEstimatedDamageToTarget(true,ally,2,DAMAGE_TYPE_PHYSICAL)
                    magic=magic+math.max(0,all-physical)
                end
            end
            local engage=J.IsGoingOnSomeone(ally) and J.IsValidHero(J.GetProperTarget(ally))
                and J.IsInRange(ally,J.GetProperTarget(ally),700)
            local useful=magic>ally:GetHealth()*0.2 and (ally:WasRecentlyDamagedByAnyHero(2) or engage)
            if useful then
                local value=magic+(J.IsCore(ally) and 200 or 0)
                if value>score then best,score=ally,value end
            end
        end
    end
    if best~=nil then return BOT_ACTION_DESIRE_HIGH,best end
    return 0
end
local function HammerTarget(target)
    return J.IsValid(target) and J.CanBeAttacked(target) and J.CanCastOnMagicImmune(target)
        and not J.IsSuspiciousIllusion(target) and J.CanCastOnTargetAdvanced(target)
        and J.IsInRange(bot,target,bot:GetAttackRange()+abilityE:GetSpecialValueInt('attack_range_bonus'))
        and not J.CannotBeKilled(bot,target) and not target:HasModifier('modifier_item_blade_mail_reflect')
        and not target:HasModifier('modifier_nyx_assassin_spiked_carapace')
end
function X.ConsiderE()
    if not J.CanCastAbility(abilityE) or bot:IsDisarmed() then return 0 end
    local damage=abilityE:GetSpecialValueInt('bonus_damage')+bot:GetBaseDamage()*abilityE:GetSpecialValueFloat('base_damage')/100
    local range=bot:GetAttackRange()+abilityE:GetSpecialValueInt('attack_range_bonus')
    for _,enemy in ipairs(J.GetNearbyHeroes(bot,math.min(range,1600),true,BOT_MODE_NONE)) do
        if HammerTarget(enemy) and J.WillKillTarget(enemy,damage,DAMAGE_TYPE_PURE,bot:GetAttackPoint()) then return BOT_ACTION_DESIRE_HIGH,enemy end
    end
    local target=J.GetProperTarget(bot)
    if HammerTarget(target) and (J.IsGoingOnSomeone(bot) or J.IsRetreating(bot) and J.IsChasingTarget(target,bot)) then return BOT_ACTION_DESIRE_HIGH,target end
    if J.IsLaning(bot) then
        for _,creep in ipairs(bot:GetNearbyLaneCreeps(math.min(range,1600),true)) do
            if HammerTarget(creep) and J.IsKeyWordUnit('ranged',creep) and not J.IsOtherAllysTarget(creep)
                and J.WillKillTarget(creep,damage,DAMAGE_TYPE_PURE,bot:GetAttackPoint()) then return BOT_ACTION_DESIRE_HIGH,creep end
        end
    end
    target=bot:GetAttackTarget()
    if HammerTarget(target) and J.IsAttacking(bot) and (J.IsFarming(bot) or J.IsDoingRoshan(bot) or J.IsDoingTormentor(bot)) then return BOT_ACTION_DESIRE_HIGH,target end
    return 0
end
function X.ConsiderR()
    if not J.CanCastAbility(abilityR) or bot:HasModifier('modifier_omniknight_guardian_angel') then return 0 end
    local global=bot:HasScepter()
    local heroes=GetUnitList(UNIT_LIST_ALLIED_HEROES)
    local threatened=0
    for _,ally in ipairs(heroes) do
        if J.IsValidHero(ally) and not ally:IsIllusion() and not ally:IsInvulnerable()
            and (global or J.IsInRange(bot,ally,abilityR:GetSpecialValueInt('radius')))
            and not ally:HasModifier('modifier_omniknight_guardian_angel') then
            local physical=0
            for _,enemy in ipairs(J.GetNearbyHeroes(ally,1200,true,BOT_MODE_NONE)) do
                if J.IsValidHero(enemy) and not enemy:IsDisarmed() then physical=physical+enemy:GetEstimatedDamageToTarget(true,ally,2,DAMAGE_TYPE_PHYSICAL) end
            end
            if physical>=ally:GetHealth()*0.45 and (ally:WasRecentlyDamagedByAnyHero(2) or ally:HasModifier('modifier_legion_commander_duel')) then return BOT_ACTION_DESIRE_HIGH end
            if physical>=ally:GetHealth()*0.25 and ally:WasRecentlyDamagedByAnyHero(2) then threatened=threatened+1 end
        end
    end
    if threatened>=2 then return BOT_ACTION_DESIRE_HIGH end
    if global then
        for _,building in ipairs(GetUnitList(UNIT_LIST_ALLIED_BUILDINGS)) do
            if J.IsValidBuilding(building) and not building:HasModifier('modifier_fountain_glyph') and J.GetHP(building)<0.65 then
                for _,enemy in ipairs(J.GetNearbyHeroes(building,1000,true,BOT_MODE_NONE)) do
                    if J.IsValidHero(enemy) and enemy:GetAttackTarget()==building and not enemy:IsDisarmed() then return BOT_ACTION_DESIRE_HIGH end
                end
            end
        end
    end
    return 0
end
function X.ConsiderSilencedHammer()
    if not bot:IsAlive() or not bot:IsSilenced() or bot:IsChanneling() or bot:IsCastingAbility() or bot:IsUsingAbility()
        or bot:NumQueuedActions()>0 or bot:IsStunned() or bot:IsHexed() or bot:IsNightmared() or bot:IsInvulnerable() or bot:IsInvisible()
        or bot:HasModifier('modifier_ringmaster_the_box_buff') or bot:HasModifier('modifier_doom_bringer_doom')
        or bot:HasModifier('modifier_item_forcestaff_active') then return false end
    local desire,target=X.ConsiderE()
    if desire>0 then bot:Action_UseAbilityOnEntity(abilityE,target);return true end
    return false
end

function X.ConsiderSilencedSpell(ability)
    if ability:GetName()~='omniknight_hammer_of_purity' then return false end
    Refresh();return X.ConsiderSilencedHammer()
end
function X.ConsiderStolenSpell(ability)
    local spellName=ability:GetName()
    if spellName~='omniknight_purification' and spellName~='omniknight_martyr' and spellName~='omniknight_hammer_of_purity' and spellName~='omniknight_guardian_angel' then return nil end
    Refresh()
    if X.ConsiderSilencedSpell(ability) then return true end
    if J.CanNotUseAbility(bot) or not J.CanCastAbility(ability) then return false end
    local choices={omniknight_purification=X.ConsiderQ,omniknight_martyr=X.ConsiderW,
        omniknight_hammer_of_purity=X.ConsiderE,omniknight_guardian_angel=X.ConsiderR}
    local consider=choices[ability:GetName()]
    if consider==nil then return false end
    local desire,target=consider()
    if desire<=0 then return false end
    if ability:GetName()=='omniknight_guardian_angel' then bot:Action_UseAbility(ability)
    else bot:Action_UseAbilityOnEntity(ability,target) end
    return true
end
return X
