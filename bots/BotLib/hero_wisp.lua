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
local Abilities = require(GetScriptDirectory()..'/FunLib/rubick_hero/wisp')
local function SkillsComplement()
    Abilities.UseNative()
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
