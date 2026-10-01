local X             = {}
local bot           = GetBot()

local J             = require( GetScriptDirectory()..'/FunLib/jmz_func' )
local Minion        = dofile( GetScriptDirectory()..'/FunLib/aba_minion' )
local sTalentList   = J.Skill.GetTalentList( bot )
local sAbilityList  = J.Skill.GetAbilityList( bot )
local sRole   = J.Item.GetRoleItemsBuyList( bot )

-- Updated to 7.41f from D2PT: offlane and reviewed carry; forced other roles use offlane.
local BuildData = require(GetScriptDirectory()..'/BotLib/Builds/doom_bringer')
X.buildMetadata = BuildData
X.neutralPreferences = BuildData.neutrals[sRole]
-- [1] Devour, [2] Scorched Earth, [3] Infernal Blade, [6] Doom.
local nAbilityBuildList = {3,2,2,1,2,6,2,1,1,1,6,3,3,3,6}
local nTalentBuildList = J.Skill.GetTalentBuild({
    t10={0,10}, -- +10% magic resistance
    t15={10,0}, -- +1.5% Infernal Blade max-health damage
    t20={10,0}, -- +66 damage
    t25={0,10}, -- Doom applies mute
})
local defaultAbilityBuild, defaultTalentBuild = nAbilityBuildList, nTalentBuildList
if sRole == 'pos_1' then
    X.sBuyList = {
        'item_quelling_blade', 'item_gauntlets', 'item_double_branches', 'item_circlet', 'item_tango',
        'item_bracer', 'item_magic_wand', 'item_phase_boots', 'item_radiance',
        'item_aghanims_shard', 'item_blink', 'item_black_king_bar',
        -- Bot policy: late Scepter/Blessing and natural upgrades.
        'item_shivas_guard', 'item_ultimate_scepter', 'item_ultimate_scepter_2',
        'item_overwhelming_blink', 'item_refresher', 'item_travel_boots',
    }
    X.sSellList = {'item_black_king_bar','item_magic_wand','item_shivas_guard','item_bracer'}
else
    X.sBuyList = {
        'item_double_gauntlets', 'item_double_branches', 'item_magic_stick',
        -- Condense the observed double Bracer to one; inventory upkeep clears the spare Gauntlets.
        'item_bracer', 'item_magic_wand', 'item_phase_boots', 'item_ancient_janggo',
        'item_blink', 'item_aghanims_shard', 'item_black_king_bar', 'item_shivas_guard',
        -- Bot policy: Scepter/Blessing and late Refresher/Travel Boots.
        'item_ultimate_scepter', 'item_ultimate_scepter_2', 'item_overwhelming_blink',
        'item_refresher', 'item_travel_boots',
    }
    X.sSellList = {'item_black_king_bar','item_magic_wand','item_shivas_guard','item_bracer'}
end

if J.Role.IsPvNMode() or J.Role.IsAllShadow() then X['sBuyList'], X['sSellList'] = { 'PvN_antimage' }, {} end

nAbilityBuildList, nTalentBuildList, X['sBuyList'], X['sSellList'] = J.SetUserHeroInit( nAbilityBuildList, nTalentBuildList, X['sBuyList'], X['sSellList'] )
X['sSkillList'] = J.Skill.GetSkillList( sAbilityList, nAbilityBuildList, sTalentList, nTalentBuildList )
-- Fourth Devour point at level 10, then the first talent at 11. Preserve custom progressions.
if nAbilityBuildList == defaultAbilityBuild and nTalentBuildList == defaultTalentBuild then
    X.sSkillList[10], X.sSkillList[11] = X.sSkillList[11], X.sSkillList[10]
end
X['bDeafaultAbility'] = false
X['bDeafaultItem'] = false

function X.MinionThink(hMinionUnit)
    Minion.MinionThink(hMinionUnit)
end

local Devour = bot:GetAbilityByName('doom_bringer_devour')
local ScorchedEarth = bot:GetAbilityByName('doom_bringer_scorched_earth')
local InfernalBlade = bot:GetAbilityByName('doom_bringer_infernal_blade')
local Doom = bot:GetAbilityByName('doom_bringer_doom')

local function CastRange(spell)
    local range = spell:GetCastRange()
    for slot = 0, 5 do
        local item = bot:GetItemInSlot(slot)
        if item ~= nil and item:GetName() == 'item_aether_lens' then
            range = range + item:GetSpecialValueInt('cast_range_bonus'); break
        end
    end
    local supremacy = bot:GetAbilityByName('rubick_arcane_supremacy')
    if supremacy ~= nil and supremacy:IsTrained() and not J.HasBreakModifier(bot) then
        range = range + supremacy:GetSpecialValueInt('cast_range')
    end
    return range
end

local function Enemy(unit, immune)
    return J.IsValidHero(unit) and unit:GetTeam() ~= bot:GetTeam()
        and not J.IsSuspiciousIllusion(unit)
        and (immune and J.CanCastOnMagicImmune(unit) or not immune and J.CanCastOnNonMagicImmune(unit))
        and not unit:HasModifier('modifier_necrolyte_reapers_scythe')
        and not unit:HasModifier('modifier_skeleton_king_reincarnation_scepter_active')
end

local function Targetable(unit, immune)
    return Enemy(unit, immune) and J.CanCastOnTargetAdvanced(unit)
        and not unit:HasModifier('modifier_antimage_counterspell')
        and not unit:HasModifier('modifier_antimage_counterspell_ally')
end

local function DoomCandidate(unit)
    return Enemy(unit, true) and not unit:HasModifier('modifier_doom_bringer_doom')
        and not unit:HasModifier('modifier_doom_bringer_doom_aura_self')
        and not unit:HasModifier('modifier_doom_bringer_doom_aura_enemy')
        and not unit:HasModifier('modifier_enigma_black_hole_pull')
        and not unit:HasModifier('modifier_faceless_void_chronosphere_freeze')
        and not unit:HasModifier('modifier_oracle_false_promise_timer')
        and not J.IsHaveAegis(unit)
end

local function Reserve()
    return Doom ~= nil and Doom:IsTrained() and Doom:GetManaCost() or 0
end

function X.ConsiderDevour()
    if not J.CanCastAbility(Devour) or J.IsRetreating(bot)
        or J.IsGoingOnSomeone(bot) or J.IsInTeamFight(bot, 1200) then return BOT_ACTION_DESIRE_NONE end
    local range, level = CastRange(Devour), Devour:GetSpecialValueInt('creep_level')
    local best, score
    for _, creep in pairs(bot:GetNearbyCreeps(math.min(range, 1600), true)) do
        if J.IsValid(creep) and creep:IsCreep() and not creep:IsHero() and not creep:IsIllusion()
            and not creep:IsInvulnerable() and not creep:IsMagicImmune()
            and creep:GetTeam() ~= bot:GetTeam() and creep:GetLevel() <= level
            and J.IsInRange(bot, creep, range) and not J.IsRoshan(creep) and not J.IsTormentor(creep)
            and (not creep:IsAncientCreep() or Devour:GetSpecialValueInt('can_target_ancient') == 1)
            and J.CanCastOnTargetAdvanced(creep)
            and not creep:HasModifier('modifier_antimage_counterspell')
            and not creep:HasModifier('modifier_antimage_counterspell_ally') then
            local value = creep:GetHealth()
            local name = creep:GetUnitName()
            if J.IsLaning(bot) and (J.IsKeyWordUnit('ranged', creep) or J.IsKeyWordUnit('siege', creep)) then value = value + 10000 end
            if name == 'npc_dota_neutral_centaur_khan' and not J.IsLaning(bot) then value = value + 8000 end
            if J.IsLaning(bot) and (name == 'npc_dota_neutral_satyr_hellcaller'
                or name == 'npc_dota_neutral_ogre_magi') then value = value + 5000 end
            if score == nil or value > score then best, score = creep, value end
        end
    end
    if best ~= nil then return BOT_ACTION_DESIRE_HIGH, best end
    return BOT_ACTION_DESIRE_NONE
end

function X.ConsiderScorchedEarth()
    if not J.CanCastAbility(ScorchedEarth) then return BOT_ACTION_DESIRE_NONE end
    if ScorchedEarth:GetSpecialValueInt('is_permanent') == 1 then
        if not ScorchedEarth:GetToggleState() then return BOT_ACTION_DESIRE_HIGH end
        return BOT_ACTION_DESIRE_NONE
    end
    if bot:HasModifier('modifier_doom_bringer_scorched_earth') then return BOT_ACTION_DESIRE_NONE end
    local radius = ScorchedEarth:GetSpecialValueInt('radius')
    local target = J.GetProperTarget(bot)
    if J.IsGoingOnSomeone(bot) and Enemy(target, true) and J.IsInRange(bot, target, radius + 150) then
        return BOT_ACTION_DESIRE_HIGH
    end
    if J.IsRetreating(bot) and bot:WasRecentlyDamagedByAnyHero(2) then
        for _, enemy in pairs(J.GetNearbyHeroes(bot, radius + 250, true, BOT_MODE_NONE)) do
            if Enemy(enemy, true) and J.IsChasingTarget(enemy, bot) then return BOT_ACTION_DESIRE_HIGH end
        end
    end
    if J.GetHP(bot) < 0.6 and not bot:HasModifier('modifier_ice_blast')
        and not bot:HasModifier('modifier_doom_bringer_doom') and ScorchedEarth:GetSpecialValueFloat('bonus_health_regen') > 0
        and bot:GetMana() - ScorchedEarth:GetManaCost() >= Reserve() then return BOT_ACTION_DESIRE_HIGH end
    if bot:GetMana() - ScorchedEarth:GetManaCost() < Reserve() then return BOT_ACTION_DESIRE_NONE end
    if (J.IsFarming(bot) or J.IsPushing(bot) or J.IsDefending(bot)) and J.IsAttacking(bot) then
        local count = 0
        for _, creep in pairs(bot:GetNearbyCreeps(radius, true)) do
            if J.IsValid(creep) and not creep:IsMagicImmune() and J.CanBeAttacked(creep)
                and J.IsInRange(bot, creep, radius) then count = count + 1 end
        end
        if count >= 3 then return BOT_ACTION_DESIRE_HIGH end
    end
    if ((J.IsDoingRoshan(bot) and J.IsRoshan(target)) or (J.IsDoingTormentor(bot) and J.IsTormentor(target)))
        and J.IsValid(target) and not target:IsMagicImmune() and not target:IsInvulnerable()
        and J.IsAttacking(bot) and J.IsInRange(bot, target, radius) then return BOT_ACTION_DESIRE_HIGH end
    return BOT_ACTION_DESIRE_NONE
end

function X.ConsiderInfernalBlade()
    if not J.CanCastAbility(InfernalBlade) or bot:IsDisarmed() then return BOT_ACTION_DESIRE_NONE end
    -- Attack behavior uses live melee spell reach, never spell-cast range bonuses.
    local range = InfernalBlade:GetCastRange()
    for _, enemy in pairs(J.GetNearbyHeroes(bot, math.min(range, 1600), true, BOT_MODE_NONE)) do
        if Targetable(enemy, false) and J.CanBeAttacked(enemy) and J.IsInRange(bot, enemy, range) then
            if enemy:IsChanneling() then return BOT_ACTION_DESIRE_HIGH, enemy, 'interrupt' end
            local duration = InfernalBlade:GetSpecialValueFloat('burn_duration')
            local damage = (InfernalBlade:GetSpecialValueInt('burn_damage')
                + enemy:GetMaxHealth() * InfernalBlade:GetSpecialValueFloat('burn_damage_pct') / 100) * duration
            if not J.CannotBeKilled(bot, enemy)
                and J.WillKillTarget(enemy, damage, DAMAGE_TYPE_MAGICAL,
                    InfernalBlade:GetCastPoint() + bot:GetAttackPoint() + duration) then
                return BOT_ACTION_DESIRE_HIGH, enemy, 'lethal'
            end
        end
    end
    local target = J.GetProperTarget(bot)
    if J.IsGoingOnSomeone(bot) and Targetable(target, false) and J.CanBeAttacked(target)
        and J.IsInRange(bot, target, range) and not target:HasModifier('modifier_doom_bringer_infernal_blade_burn')
        and not target:HasModifier('modifier_enigma_black_hole_pull')
        and not target:HasModifier('modifier_faceless_void_chronosphere_freeze') then return BOT_ACTION_DESIRE_HIGH, target end
    if J.IsRetreating(bot) then
        for _, enemy in pairs(J.GetNearbyHeroes(bot, math.min(range, 1600), true, BOT_MODE_NONE)) do
            if Targetable(enemy, false) and J.CanBeAttacked(enemy) and J.IsInRange(bot, enemy, range)
                and not J.IsDisabled(enemy) and J.IsChasingTarget(enemy, bot) then return BOT_ACTION_DESIRE_HIGH, enemy end
        end
    end
    if (J.IsFarming(bot) or J.IsDoingRoshan(bot) or J.IsDoingTormentor(bot)) and J.IsAttacking(bot)
        and J.IsValid(target) and J.CanBeAttacked(target) and not target:IsMagicImmune()
        and not target:IsInvulnerable() and target:GetTeam() ~= bot:GetTeam()
        and J.IsInRange(bot, target, range) and bot:GetMana() - InfernalBlade:GetManaCost() >= Reserve()
        and not target:HasModifier('modifier_doom_bringer_infernal_blade_burn') then return BOT_ACTION_DESIRE_HIGH, target end
    return BOT_ACTION_DESIRE_NONE
end

function X.ConsiderDoom(reach)
    if not J.CanCastAbility(Doom) then return BOT_ACTION_DESIRE_NONE end
    local range = reach or CastRange(Doom)
    local aura = Doom:GetSpecialValueInt('scepter_aura_radius')
    if bot:HasScepter() and aura > 0 and reach == nil
        and (J.IsGoingOnSomeone(bot) or J.IsInTeamFight(bot, 1200))
        and not bot:HasModifier('modifier_doom_bringer_doom')
        and not bot:HasModifier('modifier_doom_bringer_doom_aura_self') then
        local count = 0
        for _, enemy in pairs(J.GetNearbyHeroes(bot, aura, true, BOT_MODE_NONE)) do
            if DoomCandidate(enemy) and GetUnitToLocationDistance(bot, J.GetCorrectLoc(enemy, Doom:GetCastPoint())) <= aura then count = count + 1 end
        end
        if count >= 2 then return BOT_ACTION_DESIRE_HIGH, bot end
    end
    local best, bestScore
    for _, enemy in pairs(J.GetNearbyHeroes(bot, math.min(range, 1600), true, BOT_MODE_NONE)) do
        if DoomCandidate(enemy) and Targetable(enemy, true) and J.IsInRange(bot, enemy, range) then
            local purpose = J.IsGoingOnSomeone(bot) or J.IsInTeamFight(bot, 1200)
                or (J.IsRetreating(bot) and bot:WasRecentlyDamagedByAnyHero(2) and J.IsChasingTarget(enemy, bot))
            if purpose then
                local score = enemy:GetEstimatedDamageToTarget(false, bot, 3, DAMAGE_TYPE_ALL)
                    + (J.IsCore(enemy) and 1000 or 0) + enemy:GetMaxMana() * 0.25
                    + (enemy == J.GetProperTarget(bot) and 250 or 0)
                if bestScore == nil or score > bestScore then best, bestScore = enemy, score end
            end
        end
    end
    if best ~= nil then return BOT_ACTION_DESIRE_HIGH, best end
    return BOT_ACTION_DESIRE_NONE
end

function X.ConsiderBlinkDoom()
    if not J.CanCastAbility(Doom) or bot:IsRooted() or bot:HasModifier('modifier_bloodseeker_rupture')
        or not (J.IsGoingOnSomeone(bot) or J.IsInTeamFight(bot, 1200)) then return BOT_ACTION_DESIRE_NONE end
    local blink
    for slot = 0, 5 do
        local item = bot:GetItemInSlot(slot)
        if item ~= nil and item:IsFullyCastable() and (item:GetName() == 'item_blink'
            or item:GetName() == 'item_overwhelming_blink' or item:GetName() == 'item_arcane_blink'
            or item:GetName() == 'item_swift_blink') then blink = item; break end
    end
    if blink == nil or bot:GetMana() < Doom:GetManaCost() + blink:GetManaCost() then return BOT_ACTION_DESIRE_NONE end
    local distance = blink:GetSpecialValueInt('blink_range')
    local desire, target = X.ConsiderDoom(math.min(1600, distance + CastRange(Doom)))
    if desire == 0 or J.IsInRange(bot, target, CastRange(Doom)) then return BOT_ACTION_DESIRE_NONE end
    local center = J.GetCorrectLoc(target, 0.1 + Doom:GetCastPoint())
    local offset = center - bot:GetLocation()
    local travel = math.max(0, offset:Length2D() - CastRange(Doom) + 75)
    if travel > distance then return BOT_ACTION_DESIRE_NONE end
    local landing = bot:GetLocation() + offset:Normalized() * travel
    if not IsLocationPassable(landing) or J.IsLocationInChrono(landing)
        or J.IsLocationInBlackHole(landing) or J.IsLocationInArena(landing, 600) then return BOT_ACTION_DESIRE_NONE end
    local count, seen = 1, {[bot] = true}
    for _, ally in pairs(J.GetAlliesNearLoc(landing, 1000)) do
        if not seen[ally] and J.IsValidHero(ally) and not J.IsSuspiciousIllusion(ally) then count=count+1;seen[ally]=true end
    end
    if #J.GetEnemiesNearLoc(landing, 1000) > count then return BOT_ACTION_DESIRE_NONE end
    return BOT_ACTION_DESIRE_HIGH, landing, target, blink
end

-- Only reviewed acquired spells: metadata alone does not establish safe spell intent.
function X.ConsiderDevourAbility(spell)
    if not J.CanCastAbility(spell) then return BOT_ACTION_DESIRE_NONE end
    local name = spell:GetName()
    if name == 'centaur_khan_war_stomp' then
        local radius = spell:GetSpecialValueInt('radius')
        for _, enemy in pairs(J.GetNearbyHeroes(bot, radius, true, BOT_MODE_NONE)) do
            if Enemy(enemy, false) and J.IsInRange(bot, enemy, radius)
                and GetUnitToLocationDistance(bot, J.GetCorrectLoc(enemy, spell:GetCastPoint())) <= radius
                and (enemy:IsChanneling() or not J.IsDisabled(enemy)
                    and (J.IsGoingOnSomeone(bot) or J.IsRetreating(bot))) then
                return BOT_ACTION_DESIRE_HIGH, nil, 'none', enemy:IsChanneling() and 'interrupt' or nil
            end
        end
    elseif name == 'satyr_trickster_purge' or name == 'harpy_storm_chain_lightning' then
        local range = CastRange(spell)
        local target = J.GetProperTarget(bot)
        if Targetable(target, false) and J.IsInRange(bot, target, range) then
            if name == 'satyr_trickster_purge' then
                if target:HasModifier('modifier_necrolyte_ghost_shroud_active')
                    or not J.IsDisabled(target) and (J.IsGoingOnSomeone(bot) or J.IsRetreating(bot)) then
                    return BOT_ACTION_DESIRE_HIGH, target, 'unit'
                end
            elseif not J.CannotBeKilled(bot, target)
                and J.WillKillTarget(target, spell:GetSpecialValueInt('initial_damage'), DAMAGE_TYPE_MAGICAL, spell:GetCastPoint())
                or (J.IsGoingOnSomeone(bot) or J.IsLaning(bot)) and bot:GetMana() - spell:GetManaCost() >= Reserve() then
                return BOT_ACTION_DESIRE_HIGH, target, 'unit'
            end
        end
    end
    return BOT_ACTION_DESIRE_NONE
end

local function UseAcquiredSpell(urgent)
    for slot = 3, 4 do
        local spell = bot:GetAbilityInSlot(slot)
        local desire, target, shape, reason = X.ConsiderDevourAbility(spell)
        if desire > 0 and (not urgent or reason == 'interrupt') then
            if shape == 'unit' then bot:Action_UseAbilityOnEntity(spell, target)
            else bot:Action_UseAbility(spell) end
            return true
        end
    end
    return false
end

function X.SkillsComplement()
    bot.shouldBlink = false
    if J.CanNotUseAbility(bot) then return end
    local bladeDesire, bladeTarget, reason = X.ConsiderInfernalBlade()
    if bladeDesire > 0 and (reason == 'interrupt' or reason == 'lethal') then
        bot:Action_UseAbilityOnEntity(InfernalBlade, bladeTarget); return
    end
    if UseAcquiredSpell(true) then return end
    local desire, target = X.ConsiderDoom()
    if desire > 0 then bot:Action_UseAbilityOnEntity(Doom, target); return end
    local blinkDesire, landing, doomTarget, blink = X.ConsiderBlinkDoom()
    if blinkDesire > 0 then
        bot.shouldBlink = true
        bot:Action_ClearActions(false)
        bot:ActionQueue_UseAbilityOnLocation(blink, landing)
        bot:ActionQueue_UseAbilityOnEntity(Doom, doomTarget)
        return
    end
    if UseAcquiredSpell() then return end
    if bladeDesire > 0 then bot:Action_UseAbilityOnEntity(InfernalBlade, bladeTarget); return end
    if X.ConsiderScorchedEarth() > 0 then bot:Action_UseAbility(ScorchedEarth); return end
    desire, target = X.ConsiderDevour()
    if desire > 0 then bot:Action_UseAbilityOnEntity(Devour, target) end
end

return X
