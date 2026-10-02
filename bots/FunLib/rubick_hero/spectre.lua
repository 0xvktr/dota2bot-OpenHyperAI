local X = {}
local J = require(GetScriptDirectory()..'/FunLib/jmz_func')
local bot = GetBot()

function X.Range(ability)
    local range = ability:GetCastRange()
    local lens = J.IsItemAvailable('item_aether_lens')
    if lens ~= nil then range=range+lens:GetSpecialValueInt('cast_range_bonus') end
    local supremacy=bot:GetAbilityByName('rubick_arcane_supremacy')
    if supremacy ~= nil and not supremacy:IsNull() and supremacy:IsTrained() and not J.HasBreakModifier(bot) then range=range+supremacy:GetSpecialValueInt('cast_range') end
    return range
end
local function Enemy(unit, ignoreMagic)
    return J.IsValidHero(unit) and (ignoreMagic and J.CanCastOnMagicImmune(unit) or J.CanCastOnNonMagicImmune(unit))
        and not J.IsSuspiciousIllusion(unit) and not J.CannotBeKilled(bot, unit)
        and not unit:HasModifier('modifier_item_blade_mail_reflect') and not unit:HasModifier('modifier_nyx_assassin_spiked_carapace')
end
local function SafeJump(point)
    return IsLocationPassable(point) and not J.IsLocationInChrono(point) and not J.IsLocationInBlackHole(point)
        and not J.IsLocHaveTower(700, true, point)
        and #J.GetEnemiesNearLoc(point, 900) <= #J.GetAlliesNearLoc(point, 900)+1
end
local function CanJoin(enemy)
    return Enemy(enemy, true) and J.CanBeAttacked(enemy) and J.GetHP(bot) > 0.45
        and (not J.HasBreakModifier(bot) or J.GetHP(bot) > 0.7) and SafeJump(enemy:GetLocation())
end
local function AlliedAttack(enemy)
    for _, ally in pairs(GetUnitList(UNIT_LIST_ALLIED_HEROES)) do
        if J.IsValidHero(ally) and ally ~= bot and not ally:IsIllusion() and ally:GetAttackTarget() == enemy
            and GetUnitToUnitDistance(ally, enemy) < 1200 then return true end
    end
    return false
end
local function LiveGhostRecords()
    local live={}
    for _, record in ipairs(bot.spectreGhostRecords or {}) do
        if record.expires > DotaTime() and record.ability ~= nil and not record.ability:IsNull() then live[#live+1]=record end
    end
    bot.spectreGhostRecords=live
    return live
end
local function OwnedGhost(unit, records)
    if not J.IsValidHero(unit) or not unit:IsIllusion() or unit:GetTeam() ~= bot:GetTeam() then return false end
    -- Source identity distinguishes Haunt/Step from Manta and another player's illusions.
    for index=0,unit:NumModifiers()-1 do
        local source=unit:GetModifierSourceAbility(index)
        if source ~= nil and not source:IsNull() and source:GetCaster() == bot then
            for _, record in ipairs(records) do
                if source == record.ability then
                    if not record.observed then
                        record.observed=true
                        record.expires=DotaTime()+source:GetSpecialValueFloat('duration')
                    end
                    return true
                end
            end
        end
    end
    return false
end
function X.ConsiderReality()
    local ability=bot:GetAbilityByName('spectre_reality')
    if not J.CanCastAbility(ability) or bot:IsRooted() or bot:HasModifier('modifier_bloodseeker_rupture') or bot:HasModifier('modifier_puck_coiled') then return 0 end
    local records=LiveGhostRecords()
    if #records == 0 then return 0 end
    local best, score
    for _, illusion in pairs(GetUnitList(UNIT_LIST_ALLIED_HEROES)) do
        if OwnedGhost(illusion, records) and SafeJump(illusion:GetLocation()) then
            if J.IsRetreating(bot) or J.IsStuck(bot) then
                local escapeDistance=GetUnitToLocationDistance(illusion, J.GetEscapeLoc())
                if escapeDistance+400 < GetUnitToLocationDistance(bot, J.GetEscapeLoc()) and (score == nil or escapeDistance < score) then
                    best,score=illusion,escapeDistance
                end
            else
                local enemy=illusion:GetAttackTarget()
                if CanJoin(enemy) and GetUnitToUnitDistance(bot, enemy) > bot:GetAttackRange()+100
                    and (J.IsGoingOnSomeone(bot) and enemy == J.GetProperTarget(bot) or AlliedAttack(enemy)) then
                    local health=enemy:GetHealth()
                    if score == nil or health < score then best,score=illusion,health end
                end
            end
        end
    end
    if best ~= nil then return BOT_ACTION_DESIRE_HIGH,best:GetLocation() end
    return 0
end
function X.ConsiderShadowStep()
    local ability=bot:GetAbilityByName('spectre_shadow_step')
    if not J.CanCastAbility(ability) or J.IsRetreating(bot) then return 0 end
    for _, enemy in pairs(GetUnitList(UNIT_LIST_ENEMY_HEROES)) do
        if CanJoin(enemy) and GetUnitToUnitDistance(bot, enemy) > 600 and GetUnitToUnitDistance(bot, enemy) <= X.Range(ability)
            and J.CanCastOnTargetAdvanced(enemy)
            and (J.IsGoingOnSomeone(bot) and enemy == J.GetProperTarget(bot) or AlliedAttack(enemy)) then return BOT_ACTION_DESIRE_HIGH,enemy end
    end
    return 0
end
function X.ConsiderHaunt()
    local ability=bot:GetAbilityByName('spectre_haunt')
    if not J.CanCastAbility(ability) or J.IsRetreating(bot) or J.GetHP(bot) < 0.45 or #LiveGhostRecords() > 0 then return 0 end
    for _, enemy in pairs(GetUnitList(UNIT_LIST_ENEMY_HEROES)) do
        if CanJoin(enemy) and AlliedAttack(enemy) and (GetUnitToUnitDistance(bot, enemy) > 1300
            or #J.GetEnemiesNearLoc(enemy:GetLocation(), 1200) >= 2) then return BOT_ACTION_DESIRE_HIGH end
    end
    return 0
end
function X.ConsiderDispersion()
    local ability=bot:GetAbilityByName('spectre_dispersion')
    if not J.CanCastAbility(ability) or J.HasBreakModifier(bot) or bot:HasModifier('modifier_spectre_dispersion_boost') then return 0 end
    local radius=ability:GetSpecialValueInt('max_radius')
    if bot:WasRecentlyDamagedByAnyHero(1.5) and #J.GetNearbyHeroes(bot, math.min(1600,radius), true, BOT_MODE_NONE) > 0 then return BOT_ACTION_DESIRE_HIGH end
    local target=bot:GetAttackTarget()
    if J.IsValid(target) and (J.IsRoshan(target) or J.IsTormentor(target)) and GetUnitToUnitDistance(bot,target) <= radius
        and J.GetHP(bot) < 0.6 then return BOT_ACTION_DESIRE_HIGH end
    return 0
end
function X.ConsiderSpectralDagger()
    local ability=bot:GetAbilityByName('spectre_spectral_dagger')
    if not J.CanCastAbility(ability) then return 0 end
    local range,damage=X.Range(ability),ability:GetSpecialValueInt('damage')
    if (J.IsStuck(bot) or J.IsRetreating(bot) and bot:WasRecentlyDamagedByAnyHero(1.5))
        and not bot:IsRooted() and not bot:HasModifier('modifier_spectre_spectral_dagger_in_path') then
        local escape=J.GetEscapeLoc()
        return BOT_ACTION_DESIRE_HIGH,bot:GetLocation()+(escape-bot:GetLocation()):Normalized()*math.min(range,GetUnitToLocationDistance(bot,escape)),'loc'
    end
    for _, enemy in pairs(GetUnitList(UNIT_LIST_ENEMY_HEROES)) do
        if Enemy(enemy,false) and GetUnitToUnitDistance(bot,enemy) <= range then
            local delay=ability:GetCastPoint()+GetUnitToUnitDistance(bot,enemy)/ability:GetSpecialValueInt('speed')
            local point=J.GetCorrectLoc(enemy,delay)
            if J.IsInTeamFight(bot,1200) and GetUnitToLocationDistance(bot,point) <= range then
                local direction=(point-bot:GetLocation()):Normalized()
                local count=0
                for _, other in pairs(GetUnitList(UNIT_LIST_ENEMY_HEROES)) do
                    if Enemy(other,false) then
                        local offset=J.GetCorrectLoc(other,delay)-bot:GetLocation()
                        local along=offset.x*direction.x+offset.y*direction.y
                        local across=math.abs(offset.x*direction.y-offset.y*direction.x)
                        if along >= 0 and along <= GetUnitToLocationDistance(bot,point) and across <= ability:GetSpecialValueInt('dagger_radius') then count=count+1 end
                    end
                end
                if count >= 2 then return BOT_ACTION_DESIRE_HIGH,point,'loc' end
            end
            if J.WillKillTarget(enemy,damage,DAMAGE_TYPE_MAGICAL,delay)
                or J.IsGoingOnSomeone(bot) and enemy == J.GetProperTarget(bot)
                or J.IsRetreating(bot) and J.IsChasingTarget(enemy,bot) then return BOT_ACTION_DESIRE_HIGH,enemy,'unit' end
        end
    end
    local creeps=bot:GetNearbyLaneCreeps(math.min(range,1600),true)
    if J.IsFarming(bot) and #creeps < 3 then creeps=bot:GetNearbyNeutralCreeps(math.min(range,1600)) end
    for _, creep in pairs(creeps) do
        if J.IsValid(creep) then
            local delay=ability:GetCastPoint()+GetUnitToUnitDistance(bot,creep)/ability:GetSpecialValueInt('speed')
            local point=J.GetCorrectLoc(creep,delay)
            if GetUnitToLocationDistance(bot,point) <= range then
                if J.IsLaning(bot) and string.find(creep:GetUnitName(),'ranged',1,true)
                    and J.WillKillTarget(creep,damage,DAMAGE_TYPE_MAGICAL,delay) then return BOT_ACTION_DESIRE_HIGH,point,'loc' end
                if (J.IsFarming(bot) or J.IsPushing(bot) or J.IsDefending(bot)) and J.GetMP(bot) > 0.45 and #creeps >= 3 then
                    local direction=(point-bot:GetLocation()):Normalized()
                    local count=0
                    for _, other in pairs(creeps) do
                        local offset=J.GetCorrectLoc(other,delay)-bot:GetLocation()
                        local along=offset.x*direction.x+offset.y*direction.y
                        local across=math.abs(offset.x*direction.y-offset.y*direction.x)
                        if J.IsValid(other) and along >= 0 and along <= GetUnitToLocationDistance(bot,point)
                            and across <= ability:GetSpecialValueInt('dagger_radius') then count=count+1 end
                    end
                    if count >= 3 then return BOT_ACTION_DESIRE_HIGH,point,'loc' end
                end
            end
        end
    end
    return 0
end
local decisions={spectre_spectral_dagger=X.ConsiderSpectralDagger,spectre_dispersion=X.ConsiderDispersion,
    spectre_shadow_step=X.ConsiderShadowStep,spectre_haunt=X.ConsiderHaunt,spectre_reality=X.ConsiderReality}
local function Cast(ability,target,kind)
    local name=ability:GetName()
    J.SetQueuePtToINT(bot,true,ability)
    if name == 'spectre_haunt' or name == 'spectre_dispersion' then bot:ActionQueue_UseAbility(ability)
    elseif name == 'spectre_shadow_step' or name == 'spectre_spectral_dagger' and kind == 'unit' then bot:ActionQueue_UseAbilityOnEntity(ability,target)
    else bot:ActionQueue_UseAbilityOnLocation(ability,target) end
    if name == 'spectre_haunt' or name == 'spectre_shadow_step' then
        bot.spectreGhostRecords=LiveGhostRecords()
        bot.spectreGhostRecords[#bot.spectreGhostRecords+1]={ability=ability,expires=DotaTime()+ability:GetCastPoint()+ability:GetSpecialValueFloat('duration')+3}
    end
end
function X.ConsiderStolenSpell(ability)
    local name=ability:GetName()
    if decisions[name] == nil then return nil end
    bot=GetBot()
    if J.CanNotUseAbility(bot) or not J.CanCastAbility(ability) then return false end
    local desire,target,kind=decisions[name]()
    if desire <= 0 then return false end
    Cast(ability,target,kind);return true
end
function X.UseNative()
    bot=GetBot()
    if J.CanNotUseAbility(bot) then return false end
    for _, name in ipairs({'spectre_reality','spectre_dispersion','spectre_shadow_step','spectre_haunt','spectre_spectral_dagger'}) do
        local ability=bot:GetAbilityByName(name)
        if J.CanCastAbility(ability) then
            local desire,target,kind=decisions[name]()
            if desire > 0 then Cast(ability,target,kind);return true end
        end
    end
    return false
end
return X
