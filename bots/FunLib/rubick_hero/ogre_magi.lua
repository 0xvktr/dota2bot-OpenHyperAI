local X={}
local J=require(GetScriptDirectory()..'/FunLib/jmz_func')
local bot,abilityQ,abilityW,abilityE,abilityD,FireShield
local function Refresh()
    bot=GetBot()
    abilityQ=bot:GetAbilityByName('ogre_magi_fireblast');abilityW=bot:GetAbilityByName('ogre_magi_ignite')
    abilityE=bot:GetAbilityByName('ogre_magi_bloodlust');abilityD=bot:GetAbilityByName('ogre_magi_unrefined_fireblast')
    FireShield=bot:GetAbilityByName('ogre_magi_smash')
end
local function SpellRange(ability)
    local range=ability:GetCastRange()
    local lens=J.IsItemAvailable('item_aether_lens')
    if lens~=nil then range=range+lens:GetSpecialValueInt('cast_range_bonus') end
    local supremacy=bot:GetAbilityByName('rubick_arcane_supremacy')
    if supremacy~=nil and supremacy:IsTrained() and not J.HasBreakModifier(bot) then range=range+supremacy:GetSpecialValueInt('cast_range') end
    return range
end
local function Enemy(enemy,ability)
    return J.IsValidHero(enemy) and not J.IsSuspiciousIllusion(enemy)
        and J.CanCastOnNonMagicImmune(enemy) and J.CanCastOnTargetAdvanced(enemy)
        and J.IsInRange(bot,enemy,SpellRange(ability))
end
local function Blast(ability,damage)
    if not J.CanCastAbility(ability) then return 0 end
    local enemies=J.GetNearbyHeroes(bot,math.min(SpellRange(ability),1600),true,BOT_MODE_NONE)
    for _,enemy in ipairs(enemies) do
        if Enemy(enemy,ability) then
            if enemy:IsChanneling() then return BOT_ACTION_DESIRE_HIGH,enemy end
            if not J.CannotBeKilled(bot,enemy) and J.WillKillTarget(enemy,damage,DAMAGE_TYPE_MAGICAL,ability:GetCastPoint()) then return BOT_ACTION_DESIRE_HIGH,enemy end
        end
    end
    local target=J.GetProperTarget(bot)
    if J.IsGoingOnSomeone(bot) and Enemy(target,ability) and not J.IsDisabled(target) then return BOT_ACTION_DESIRE_HIGH,target end
    local best,power=nil,0
    for _,enemy in ipairs(enemies) do
        if Enemy(enemy,ability) and not J.IsDisabled(enemy) then
            if J.IsRetreating(bot) and bot:WasRecentlyDamagedByAnyHero(2) and J.IsChasingTarget(enemy,bot) then return BOT_ACTION_DESIRE_HIGH,enemy end
            local threat=enemy:GetEstimatedDamageToTarget(true,bot,3,DAMAGE_TYPE_ALL)
            if J.IsInTeamFight(bot,1200) and threat>power then best,power=enemy,threat end
        end
    end
    if best~=nil then return BOT_ACTION_DESIRE_HIGH,best end
    if J.IsLaning(bot) and J.IsAllowedToSpam(bot,ability:GetManaCost()) then
        for _,creep in ipairs(bot:GetNearbyLaneCreeps(math.min(SpellRange(ability),1600),true)) do
            if J.IsValid(creep) and J.CanCastOnNonMagicImmune(creep) and J.IsKeyWordUnit('ranged',creep)
                and J.IsInRange(bot,creep,SpellRange(ability)) and GetUnitToUnitDistance(bot,creep)>bot:GetAttackRange()+100
                and not J.IsOtherAllysTarget(creep) and J.WillKillTarget(creep,damage,DAMAGE_TYPE_MAGICAL,ability:GetCastPoint()) then return BOT_ACTION_DESIRE_HIGH,creep end
        end
    end
    if J.IsDoingRoshan(bot) and J.IsRoshan(target) and J.CanCastOnNonMagicImmune(target)
        and J.IsInRange(bot,target,SpellRange(ability)) and J.IsAttacking(bot)
        and J.IsAllowedToSpam(bot,ability:GetManaCost()) then return BOT_ACTION_DESIRE_HIGH,target end
    return 0
end
function X.ConsiderQ()
    if not J.CanCastAbility(abilityQ) then return 0 end
    return Blast(abilityQ,abilityQ:GetSpecialValueInt('fireblast_damage'))
end
function X.ConsiderD()
    if not J.CanCastAbility(abilityD) then return 0 end
    local damage=abilityD:GetSpecialValueInt('base_damage')+bot:GetAttributeValue(ATTRIBUTE_STRENGTH)*abilityD:GetSpecialValueFloat('str_multiplier')
    local desire,target=Blast(abilityD,damage)
    if desire<=0 then return 0 end
    if target:IsHero() and (target:IsChanneling() or J.WillKillTarget(target,damage,DAMAGE_TYPE_MAGICAL,abilityD:GetCastPoint()) and not J.CannotBeKilled(bot,target)) then return desire,target end
    if J.IsDisabled(target) then return 0 end
    -- Spend fixed-cost basics first. Keep enough mana for the ready short stun after the percentage-cost blast.
    if J.CanCastAbility(abilityQ) and Enemy(target,abilityQ) then return 0 end
    if J.CanCastAbility(abilityW) and Enemy(target,abilityW) and not target:HasModifier('modifier_ogre_magi_ignite') then return 0 end
    local cost=bot:GetMana()*abilityD:GetSpecialValueInt('scepter_mana')/100
    if abilityQ~=nil and abilityQ:IsTrained() and bot:GetMana()-cost<abilityQ:GetManaCost() and not J.IsRetreating(bot) then return 0 end
    return desire,target
end
function X.ConsiderW()
    if not J.CanCastAbility(abilityW) then return 0 end
    local enemies=J.GetNearbyHeroes(bot,math.min(SpellRange(abilityW),1600),true,BOT_MODE_NONE)
    local damage=abilityW:GetSpecialValueInt('duration')*abilityW:GetSpecialValueInt('burn_damage')
    local best,score=nil,-1
    for _,enemy in ipairs(enemies) do
        if Enemy(enemy,abilityW) then
            local delay=abilityW:GetCastPoint()+GetUnitToUnitDistance(bot,enemy)/abilityW:GetSpecialValueInt('projectile_speed')+abilityW:GetSpecialValueInt('duration')
            if not J.CannotBeKilled(bot,enemy) and J.WillKillTarget(enemy,damage,DAMAGE_TYPE_MAGICAL,delay) then return BOT_ACTION_DESIRE_HIGH,enemy end
            if J.IsRetreating(bot) and bot:WasRecentlyDamagedByAnyHero(2) and J.IsChasingTarget(enemy,bot) then return BOT_ACTION_DESIRE_HIGH,enemy end
            if not enemy:HasModifier('modifier_ogre_magi_ignite') and (J.IsInTeamFight(bot,1200) or J.IsGoingOnSomeone(bot)
                or J.IsLaning(bot) and J.IsAllowedToSpam(bot,abilityW:GetManaCost())) then
                local value=enemy:GetHealth()+(enemy==J.GetProperTarget(bot) and 1000 or 0)
                for i=0,5 do
                    local item=enemy:GetItemInSlot(i)
                    if item~=nil and string.find(item:GetName(),'blink') then value=value+2000;break end
                end
                if value>score then best,score=enemy,value end
            end
        end
    end
    if best~=nil then return BOT_ACTION_DESIRE_HIGH,best end
    if (J.IsFarming(bot) or J.IsPushing(bot) or J.IsDefending(bot)) and J.IsAllowedToSpam(bot,abilityW:GetManaCost()) then
        local creeps=bot:GetNearbyCreeps(math.min(SpellRange(abilityW),1600),true)
        if #creeps>=3 then
            for _,creep in ipairs(creeps) do
                if J.IsValid(creep) and J.CanCastOnNonMagicImmune(creep) and not creep:HasModifier('modifier_ogre_magi_ignite')
                    and J.IsInRange(bot,creep,SpellRange(abilityW)) and creep:GetHealth()>bot:GetAttackDamage()*2 then return BOT_ACTION_DESIRE_HIGH,creep end
            end
        end
    end
    return 0
end
local function Buffable(ally,ability,modifier)
    return (J.IsValidHero(ally) or J.IsValidBuilding(ally) or J.IsValid(ally))
        and ally:GetTeam()==bot:GetTeam() and not ally:IsIllusion()
        and J.IsInRange(bot,ally,SpellRange(ability)) and not ally:HasModifier(modifier)
end
function X.ConsiderE()
    if not J.CanCastAbility(abilityE) then return 0 end
    local candidates=J.GetNearbyHeroes(bot,math.min(SpellRange(abilityE),1600),false,BOT_MODE_NONE)
    candidates[#candidates+1]=bot
    local best,score=nil,0
    local nearbyEnemy=#J.GetNearbyHeroes(bot,1600,true,BOT_MODE_NONE)>0
    for _,ally in ipairs(candidates) do
        if Buffable(ally,abilityE,'modifier_ogre_magi_bloodlust') then
            if J.IsRetreating(ally) and ally:WasRecentlyDamagedByAnyHero(2) and nearbyEnemy then return BOT_ACTION_DESIRE_HIGH,ally end
            local useful=J.IsAttacking(ally) or nearbyEnemy and J.IsCore(ally)
            if useful and (nearbyEnemy or J.IsAllowedToSpam(bot,abilityE:GetManaCost())) then
                local value=ally:GetAttackDamage()+(J.IsCore(ally) and 1000 or 0)
                if value>score then best,score=ally,value end
            end
        end
    end
    if best~=nil then return BOT_ACTION_DESIRE_HIGH,best end
    for _,tower in ipairs(bot:GetNearbyTowers(math.min(SpellRange(abilityE),1600),false)) do
        if Buffable(tower,abilityE,'modifier_ogre_magi_bloodlust') and tower:GetAttackTarget()~=nil and nearbyEnemy then return BOT_ACTION_DESIRE_HIGH,tower end
    end
    for _,creep in ipairs(bot:GetNearbyCreeps(math.min(SpellRange(abilityE),1600),false)) do
        if Buffable(creep,abilityE,'modifier_ogre_magi_bloodlust') and creep:GetAttackTarget()~=nil
            and (J.IsKeyWordUnit('siege',creep) or J.IsKeyWordUnit('warlock',creep))
            and J.IsAllowedToSpam(bot,abilityE:GetManaCost()) then return BOT_ACTION_DESIRE_HIGH,creep end
    end
    return 0
end
function X.ConsiderFireShield()
    if not J.CanCastAbility(FireShield) then return 0 end
    local best,score=nil,0
    for _,enemy in ipairs(J.GetNearbyHeroes(bot,1600,true,BOT_MODE_NONE)) do
        if J.IsValidHero(enemy) and not J.IsSuspiciousIllusion(enemy) then
            local target=enemy:GetAttackTarget()
            if Buffable(target,FireShield,'modifier_ogre_magi_smash_buff') and not target:HasModifier('modifier_fountain_glyph')
                and (target:IsHero() or target:IsTower()) then
                local value=enemy:GetAttackDamage()+(1-J.GetHP(target))*200+(J.IsCore(target) and 100 or 0)
                if value>score then best,score=target,value end
            end
        end
    end
    if best~=nil then return BOT_ACTION_DESIRE_HIGH,best end
    return 0
end

function X.ConsiderStolenSpell(ability)
    local spellName=ability:GetName()
    if spellName~='ogre_magi_fireblast' and spellName~='ogre_magi_ignite' and spellName~='ogre_magi_bloodlust' and spellName~='ogre_magi_unrefined_fireblast' and spellName~='ogre_magi_smash' then return nil end
    Refresh()
    if J.CanNotUseAbility(bot) or not J.CanCastAbility(ability) then return false end
    local choices={ogre_magi_fireblast=X.ConsiderQ,ogre_magi_ignite=X.ConsiderW,
        ogre_magi_bloodlust=X.ConsiderE,ogre_magi_unrefined_fireblast=X.ConsiderD,ogre_magi_smash=X.ConsiderFireShield}
    local consider=choices[ability:GetName()]
    if consider==nil then return false end
    local desire,target=consider()
    if desire<=0 then return false end
    bot:Action_UseAbilityOnEntity(ability,target);return true
end
return X
