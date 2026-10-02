local J = require(GetScriptDirectory()..'/FunLib/jmz_func')
local R = {}

-- Only cores receive this sacrifice: a transferred sleep must not bounce among
-- supports. Source attribution also preserves an allied Bane's intentional save.
function R.WakeCore(bot)
    if J.IsCore(bot) or J.CanNotUseAction(bot) or bot:IsHexed()
        or bot:IsDisarmed() then return false end
    local best, score
    for _, ally in ipairs(J.GetNearbyHeroes(bot, math.min(1600, bot:GetAttackRange() + 250), false, BOT_MODE_NONE)) do
        if ally ~= bot and J.IsValidHero(ally) and not ally:IsIllusion() and J.IsCore(ally)
            and ally:HasModifier('modifier_bane_nightmare') and not ally:IsInvulnerable()
            and not ally:IsAttackImmune() and not J.IsInEtherealForm(ally) then
            local index = ally:GetModifierByName('modifier_bane_nightmare')
            local source = index >= 0 and ally:GetModifierSourceAbility(index) or nil
            local caster = source and not source:IsNull() and source:GetCaster() or nil
            local distance = GetUnitToUnitDistance(bot, ally)
            local remaining = J.GetModifierTime(ally, 'modifier_bane_nightmare')
            local reachTime = math.max(0, distance - bot:GetAttackRange()) / math.max(1, bot:GetCurrentMovementSpeed())
            if caster and not caster:IsNull() and caster:GetTeam() ~= bot:GetTeam()
                and remaining > reachTime + 0.4 then
                local value = (4 - J.GetPosition(ally)) * 1000 - distance
                if not score or value > score then best, score = ally, value end
            end
        end
    end
    if best then bot:Action_AttackUnit(best, true); return true end
    return false
end

-- Cast shapes and arrival times are explicit: a slow, silence or conditional
-- stun (e.g. Shackleshot/Spear) is not automatically a reliable TP interrupt.
local interrupts = {
    lion_voodoo = {shape='unit'}, shadow_shaman_voodoo = {shape='unit'},
    ogre_magi_fireblast = {shape='unit'}, ogre_magi_unrefined_fireblast = {shape='unit'},
    dragon_knight_dragon_tail = {shape='unit', speed='projectile_speed'},
    vengefulspirit_magic_missile = {shape='unit', speed='magic_missile_speed'},
    sven_storm_bolt = {shape='unit', speed='bolt_speed'},
    skeleton_king_hellfire_blast = {shape='unit', speed='blast_speed'},
    chaos_knight_chaos_bolt = {shape='unit', speed='chaos_bolt_speed'},
    earthshaker_fissure = {shape='point'}, lion_impale = {shape='point', speed='speed'},
    nyx_assassin_impale = {shape='point', speed='speed'},
    sandking_burrowstrike = {shape='point', speed='burrow_speed'},
    lina_light_strike_array = {shape='point', delay='light_strike_array_delay_time'},
    leshrac_split_earth = {shape='point', delay='delay'},
    jakiro_ice_path = {shape='point', delay='path_delay'},
    tiny_avalanche = {shape='point'},
    centaur_hoof_stomp = {shape='none', radius='radius'},
    slardar_slithereen_crush = {shape='none', radius='crush_radius'},
    axe_berserkers_call = {shape='none', radius='radius', pierces=true},
    tidehunter_ravage = {shape='none', radius='radius', speed='speed'},
    magnataur_reverse_polarity = {shape='none', radius='pull_radius', pierces=true},
    bane_nightmare = {shape='unit'}, bane_fiends_grip = {shape='unit', pierces=true},
    shadow_shaman_shackles = {shape='unit'}, enigma_malefice = {shape='unit'},
    rubick_telekinesis = {shape='unit'}, lich_sinister_gaze = {shape='unit', scepterPoint=true},
    shadow_demon_disruption = {shape='unit'}, obsidian_destroyer_astral_imprisonment = {shape='unit'},
    primal_beast_pulverize = {shape='unit', pierces=true},
    beastmaster_primal_roar = {shape='unit', pierces=true},
    legion_commander_duel = {shape='unit', pierces=true},
    batrider_flaming_lasso = {shape='unit', pierces=true},
    pudge_dismember = {shape='unit', pierces=true},
    spirit_breaker_nether_strike = {shape='unit', pierces=true},
    vengefulspirit_nether_swap = {shape='unit', pierces=true},
}

local function castRange(bot, ability)
    local bonus = 0
    for slot = 0, 5 do
        local item = bot:GetItemInSlot(slot)
        if item and item:GetName() == 'item_aether_lens' then
            bonus = item:GetSpecialValueInt('cast_range_bonus'); break
        end
    end
    local supremacy = bot:GetAbilityByName('rubick_arcane_supremacy')
    if supremacy and supremacy:IsTrained() and not J.HasBreakModifier(bot) then
        bonus = bonus + supremacy:GetSpecialValueInt('cast_range')
    end
    return ability:GetCastRange() + bonus
end

function R.InterruptTeleport(bot)
    if J.CanNotUseAbility(bot) then return false end
    local best, target, spec, bestCost
    for _, enemy in ipairs(J.GetNearbyHeroes(bot, 1600, true, BOT_MODE_NONE)) do
        if J.IsValidHero(enemy) and enemy:CanBeSeen() and not J.IsSuspiciousIllusion(enemy)
            and enemy:IsChanneling() and enemy:HasModifier('modifier_teleporting')
            and not enemy:IsInvulnerable() then
            local remaining = J.GetModifierTime(enemy, 'modifier_teleporting')
            local distance = GetUnitToUnitDistance(bot, enemy)
            for slot = 0, 23 do
                local ability = bot:GetAbilityInSlot(slot)
                local info = ability and interrupts[ability:GetName()] or nil
                local shape = info and info.shape
                if info and info.scepterPoint and bot:HasScepter() then shape = 'point' end
                if info and J.CanCastAbility(ability)
                    and (info.pierces and J.CanCastOnMagicImmune(enemy) or not info.pierces and J.CanCastOnNonMagicImmune(enemy))
                    and (shape ~= 'unit' or J.CanCastOnTargetAdvanced(enemy)) then
                    local range = shape == 'none' and ability:GetSpecialValueInt(info.radius) or castRange(bot, ability)
                    local delay = ability:GetCastPoint() + 0.1
                    if info.delay then delay = delay + ability:GetSpecialValueFloat(info.delay) end
                    local speed = info.speed and ability:GetSpecialValueInt(info.speed) or 0
                    if speed > 0 then delay = delay + distance / speed end
                    if distance <= range and remaining > delay then
                        -- Prefer a basic disable over a long-cooldown ultimate.
                        local cost = (ability:IsUltimate() and 10000 or 0) + ability:GetManaCost() + delay * 100
                        if not bestCost or cost < bestCost then best, target, spec, bestCost = ability, enemy, shape, cost end
                    end
                end
            end
        end
    end
    if not best then return false end
    if spec == 'unit' then bot:Action_UseAbilityOnEntity(best, target)
    elseif spec == 'point' then bot:Action_UseAbilityOnLocation(best, target:GetLocation())
    else bot:Action_UseAbility(best) end
    return true
end

return R
