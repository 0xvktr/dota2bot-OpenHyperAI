-- Updated to 7.41f from D2PT; forced offlane uses hard support.
--[[ Generated with https://github.com/TypeScriptToLua/TypeScriptToLua ]]
local jmz = require(GetScriptDirectory().."/FunLib/jmz_func")
local ____dota = require(GetScriptDirectory().."/ts_libs/dota/index")
local BotActionDesire = ____dota.BotActionDesire
local BotMode = ____dota.BotMode
local UnitType = ____dota.UnitType
local ____aba_buff = require(GetScriptDirectory().."/FunLib/aba_buff")
local hero_is_healing = ____aba_buff.hero_is_healing
local ____utils = require(GetScriptDirectory().."/FunLib/utils")
local GetTeamFountainTpPoint = ____utils.GetTeamFountainTpPoint
local HasAnyEffect = ____utils.HasAnyEffect
local IsValidHero = ____utils.IsValidHero
local bot = GetBot()
local minion = dofile(GetScriptDirectory().."/FunLib/aba_minion")
local role = jmz.Item.GetRoleItemsBuyList(bot)
local BuildData = require(GetScriptDirectory() .. "/BotLib/Builds/wisp")
local allAbilitiesList = jmz.Skill.GetAbilityList(bot)
local allTalentsList = jmz.Skill.GetTalentList(bot)
local roleSkillBuildList = {
    pos_1 = {
        2,
        1,
        2,
        3,
        2,
        6,
        2,
        3,
        3,
        3,
        6,
        1,
        1,
        1,
        6
    },
    pos_2 = {
        2,
        1,
        2,
        3,
        2,
        6,
        2,
        3,
        3,
        3,
        6,
        1,
        1,
        1,
        6
    },
    pos_3 = {
        1,
        3,
        3,
        1,
        3,
        6,
        3,
        1,
        1,
        2,
        6,
        2,
        2,
        2,
        6
    },
    pos_4 = {
        2,
        1,
        2,
        3,
        2,
        6,
        2,
        3,
        3,
        3,
        6,
        1,
        1,
        1,
        6
    },
    pos_5 = {
        1,
        3,
        3,
        1,
        3,
        6,
        3,
        1,
        1,
        2,
        6,
        2,
        2,
        2,
        6
    }
}
local roleTalentBuildList = {
    pos_1 = {t10 = {0, 10}, t15 = {10, 0}, t20 = {10, 0}, t25 = {0, 10}},
    pos_2 = {t10 = {0, 10}, t15 = {10, 0}, t20 = {10, 0}, t25 = {0, 10}},
    pos_3 = {t10 = {0, 10}, t15 = {0, 10}, t20 = {10, 0}, t25 = {0, 10}},
    pos_4 = {t10 = {0, 10}, t15 = {10, 0}, t20 = {10, 0}, t25 = {0, 10}},
    pos_5 = {t10 = {0, 10}, t15 = {0, 10}, t20 = {10, 0}, t25 = {0, 10}}
}
local roleItemBuyList = {
    pos_1 = {
        "item_gauntlets",
        "item_branches",
        "item_sobi_mask",
        "item_magic_stick",
        "item_helm_of_iron_will",
        "item_magic_wand",
        "item_helm_of_the_dominator",
        "item_soul_ring",
        "item_ultimate_scepter",
        "item_black_king_bar",
        "item_maelstrom",
        "item_mjollnir",
        "item_lifesteal",
        "item_ultimate_scepter_2",
        "item_lesser_crit",
        "item_greater_crit",
        "item_satanic",
        "item_helm_of_the_overlord",
        "item_heart",
        "item_aghanims_shard",
        "item_moon_shard"
    },
    pos_2 = {
        "item_double_branches",
        "item_double_branches",
        "item_branches",
        "item_tango",
        "item_bottle",
        "item_null_talisman",
        "item_magic_wand",
        "item_ultimate_scepter",
        "item_black_king_bar",
        "item_shivas_guard",
        "item_ultimate_scepter_2",
        "item_octarine_core",
        "item_aghanims_shard",
        "item_sheepstick",
        "item_cyclone",
        "item_wind_waker",
        "item_heart"
    },
    pos_3 = {
        "item_tango",
        "item_headdress",
        "item_blood_grenade",
        "item_magic_wand",
        "item_mekansm",
        "item_holy_locket",
        "item_glimmer_cape",
        "item_cyclone",
        "item_vladmir",
        "item_arcane_boots",
        "item_guardian_greaves",
        "item_sheepstick",
        "item_wind_waker",
        "item_aghanims_shard"
    },
    pos_4 = {
        "item_tango",
        "item_headdress",
        "item_blood_grenade",
        "item_magic_wand",
        "item_soul_ring",
        "item_mekansm",
        "item_holy_locket",
        "item_ultimate_scepter",
        "item_ultimate_scepter_2",
        "item_black_king_bar",
        "item_arcane_boots",
        "item_guardian_greaves",
        "item_glimmer_cape",
        "item_sheepstick",
        "item_lotus_orb",
        "item_aghanims_shard"
    },
    pos_5 = {
        "item_tango",
        "item_headdress",
        "item_blood_grenade",
        "item_magic_wand",
        "item_mekansm",
        "item_holy_locket",
        "item_glimmer_cape",
        "item_cyclone",
        "item_vladmir",
        "item_arcane_boots",
        "item_guardian_greaves",
        "item_sheepstick",
        "item_wind_waker",
        "item_aghanims_shard"
    }
}
local roleItemSellList = {
    pos_1 = {"item_maelstrom", "item_soul_ring", "item_lesser_crit", "item_magic_wand"},
    pos_2 = {
        "item_octarine_core",
        "item_bottle",
        "item_sheepstick",
        "item_null_talisman",
        "item_cyclone",
        "item_magic_wand"
    },
    pos_3 = {},
    pos_4 = {"item_glimmer_cape", "item_soul_ring"},
    pos_5 = {}
}
local skillBuildList = roleSkillBuildList[role]
local talentBuildList = jmz.Skill.GetTalentBuild(roleTalentBuildList[role])
local itemBuildList = roleItemBuyList[role]
local sellList = roleItemSellList[role]
local defaultAbilityBuild = skillBuildList
local defaultTalentBuild = talentBuildList
skillBuildList, talentBuildList, itemBuildList, sellList = jmz.SetUserHeroInit(skillBuildList, talentBuildList, itemBuildList, sellList)
local fullSkillBuildList = jmz.Skill.GetSkillList(allAbilitiesList, skillBuildList, allTalentsList, talentBuildList)
if BuildData.patch == "7.41f" and skillBuildList == defaultAbilityBuild and talentBuildList == defaultTalentBuild then
    if role == "pos_5" or role == "pos_3" then
        table.insert(fullSkillBuildList, 10, "special_bonus_attributes")
        local ____temp_0 = {fullSkillBuildList[13], fullSkillBuildList[12]}
        fullSkillBuildList[12] = ____temp_0[1]
        fullSkillBuildList[13] = ____temp_0[2]
        local ____temp_1 = {fullSkillBuildList[16], fullSkillBuildList[15]}
        fullSkillBuildList[15] = ____temp_1[1]
        fullSkillBuildList[16] = ____temp_1[2]
    else
        local ____temp_2 = {fullSkillBuildList[11], fullSkillBuildList[10]}
        fullSkillBuildList[10] = ____temp_2[1]
        fullSkillBuildList[11] = ____temp_2[2]
    end
end
local abilityTether = bot:GetAbilityByName(allAbilitiesList[1])
local abilitySpirits = bot:GetAbilityByName(allAbilitiesList[2])
local abilityOvercharge = bot:GetAbilityByName(allAbilitiesList[3])
local abilityRelocate = bot:GetAbilityByName(allAbilitiesList[6])
local abilityBreakTether = bot:GetAbilityByName("wisp_tether_break")
local nearbyEnemies = {}
local function HasHealingEffect(hero)
    return HasAnyEffect(
        hero,
        "modifier_tango_heal",
        unpack(hero_is_healing)
    )
end
bot.stateTetheredHero = bot.stateTetheredHero
local function ShouldUseOvercharge(ally)
    local isAttacking = GameTime() - ally:GetLastAttackTime() < 0.33
    local attackTarget = ally:GetAttackTarget()
    return jmz.IsGoingOnSomeone(ally) or attackTarget and attackTarget:GetTeam() == GetOpposingTeam() and isAttacking or #ally:GetNearbyCreeps(200, true) > 2
end
local function considerTether()
    if not bot:HasModifier("modifier_wisp_tether") then
        bot.stateTetheredHero = nil
    end
    if not abilityTether:IsFullyCastable() or not abilityBreakTether:IsHidden() then
        return BotActionDesire.None, nil
    end
    local castRange = abilityTether:GetCastRange()
    local allies = bot:GetNearbyHeroes(castRange, false, BotMode.None)
    for ____, ally in ipairs(allies) do
        do
            local __continue10
            repeat
                local canTargetAlly = ally ~= bot and ally:IsAlive() and not ally:IsMagicImmune()
                if not canTargetAlly then
                    __continue10 = true
                    break
                end
                if jmz.IsRetreating(bot) or jmz.GetHP(bot) < 0.25 then
                    if jmz.IsRetreating(ally) then
                        return BotActionDesire.High, ally
                    end
                    __continue10 = true
                    break
                end
                if jmz.GetHP(ally) < 0.75 or jmz.GetMP(bot) > 0.8 or HasHealingEffect(bot) or ShouldUseOvercharge(ally) then
                    return BotActionDesire.High, ally
                end
                __continue10 = true
            until true
            if not __continue10 then
                break
            end
        end
    end
    return BotActionDesire.None, nil
end
local function considerOvercharge()
    if not abilityOvercharge:IsFullyCastable() then
        return BotActionDesire.None
    end
    if bot:HasModifier("modifier_wisp_tether") and bot.stateTetheredHero ~= nil and ShouldUseOvercharge(bot.stateTetheredHero) then
        return BotActionDesire.High
    end
    return BotActionDesire.None
end
local function considerSpirits()
    if not abilitySpirits:IsFullyCastable() then
        return BotActionDesire.None
    end
    if #nearbyEnemies >= 1 then
        return BotActionDesire.High
    end
    return BotActionDesire.None
end
local function considerRelocate()
    if bot:HasModifier("modifier_wisp_tether") and bot.stateTetheredHero ~= nil and (jmz.GetHP(bot.stateTetheredHero) <= 0.2 or jmz.GetHP(bot) <= 0.2) then
        local allyNearbyEnemies = bot.stateTetheredHero:GetNearbyHeroes(1200, true, BotMode.None)
        if #allyNearbyEnemies >= 1 and jmz.GetHP(bot.stateTetheredHero) < jmz.GetHP(allyNearbyEnemies[1]) or #nearbyEnemies >= 1 and jmz.GetHP(bot) < jmz.GetHP(nearbyEnemies[1]) then
            return BotActionDesire.High, GetTeamFountainTpPoint()
        end
    end
    if not bot:HasModifier("modifier_wisp_tether") then
        if #nearbyEnemies >= 1 and jmz.GetHP(bot) < jmz.GetHP(nearbyEnemies[1]) then
            return BotActionDesire.High, GetTeamFountainTpPoint()
        end
    end
    for ____, ally in ipairs(GetUnitList(UnitType.AlliedHeroes)) do
        if IsValidHero(ally) and jmz.IsInTeamFight(ally, 1200) and GetUnitToUnitDistance(bot, ally) > 3000 and ally:WasRecentlyDamagedByAnyHero(2) then
            return BotActionDesire.High, ally:GetLocation()
        end
    end
    return BotActionDesire.None, nil
end
local function SkillsComplement()
    if jmz.CanNotUseAbility(bot) or bot:IsInvisible() then
        return
    end
    nearbyEnemies = bot:GetNearbyHeroes(1600, true, BotMode.None)
    local tetherDesire, tetherTarget = considerTether()
    if tetherDesire > 0 and tetherTarget then
        bot:Action_UseAbilityOnEntity(abilityTether, tetherTarget)
        bot.stateTetheredHero = tetherTarget
        return
    end
    local overchargeDesire = considerOvercharge()
    if overchargeDesire > 0 then
        bot:Action_UseAbility(abilityOvercharge)
        return
    end
    local spiritsDesire = considerSpirits()
    if spiritsDesire > 0 then
        bot:Action_UseAbility(abilitySpirits)
        return
    end
    local relocateDesire, relocateTarget = considerRelocate()
    if relocateDesire and relocateTarget ~= nil then
        bot:Action_UseAbilityOnLocation(abilityRelocate, relocateTarget)
    end
end
local function MinionThink(hMinionUnit)
    if minion.IsValidUnit(hMinionUnit) then
        minion.IllusionThink(hMinionUnit)
    end
end
local ____exports = {
    SkillsComplement = SkillsComplement,
    MinionThink = MinionThink,
    sSellList = sellList,
    sBuyList = itemBuildList,
    sSkillList = fullSkillBuildList,
    buildMetadata = BuildData,
    neutralPreferences = BuildData.neutrals[role]
}
return ____exports
