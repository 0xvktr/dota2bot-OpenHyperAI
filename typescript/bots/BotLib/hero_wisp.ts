import * as jmz from "bots/FunLib/jmz_func";
import { BotSetup, BotRole, ItemBuilds, SkillBuilds, TalentBuilds } from "bots/ts_libs/bots";
import { BotActionDesire, BotMode, Location, Talent, Unit, UnitType } from "bots/ts_libs/dota";
import { hero_is_healing } from "bots/FunLib/aba_buff";
import { GetTeamFountainTpPoint, HasAnyEffect, IsValidHero } from "bots/FunLib/utils";

const bot = GetBot();
// @ts-ignore
const minion = dofile("bots/FunLib/aba_minion");

const role: BotRole = jmz.Item.GetRoleItemsBuyList(bot);

// Updated to 7.41f from D2PT; forced offlane uses hard support.
const BuildData = require(GetScriptDirectory() + "/BotLib/Builds/wisp") as { patch: string; neutrals: Partial<Record<BotRole, unknown>> };
// [1] Tether, [2] Spirits, [3] Overcharge, [6] Relocate.
const allAbilitiesList: string[] = jmz.Skill.GetAbilityList(bot);
const allTalentsList: Talent[] = jmz.Skill.GetTalentList(bot);
const roleSkillBuildList: SkillBuilds = {
    pos_1: [2,1,2,3,2,6,2,3,3,3,6,1,1,1,6],
    pos_2: [2,1,2,3,2,6,2,3,3,3,6,1,1,1,6],
    pos_3: [1,3,3,1,3,6,3,1,1,2,6,2,2,2,6],
    pos_4: [2,1,2,3,2,6,2,3,3,3,6,1,1,1,6],
    pos_5: [1,3,3,1,3,6,3,1,1,2,6,2,2,2,6],
};
const roleTalentBuildList: TalentBuilds = {
    pos_1: {
        t10: [0,10], // Overcharge duration
        t15: [10,0], // Spirits damage
        t20: [10,0], // Relocate cooldown
        t25: [0,10], // Relocate cast delay
    },
    pos_2: {
        t10: [0,10], // Overcharge duration
        t15: [10,0], // Spirits damage
        t20: [10,0], // Relocate cooldown
        t25: [0,10], // Relocate cast delay
    },
    pos_3: {
        t10: [0,10], // Overcharge duration
        t15: [0,10], // Tether movement speed
        t20: [10,0], // Relocate cooldown
        t25: [0,10], // Relocate cast delay
    },
    pos_4: {
        t10: [0,10], // Overcharge duration
        t15: [10,0], // Spirits damage
        t20: [10,0], // Relocate cooldown
        t25: [0,10], // Relocate cast delay
    },
    pos_5: {
        t10: [0,10], // Overcharge duration
        t15: [0,10], // Tether movement speed
        t20: [10,0], // Relocate cooldown
        t25: [0,10], // Relocate cast delay
    },
};
const roleItemBuyList: ItemBuilds = {
    pos_1: [
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
        // Bot policy: selected situational items and late upgrades.
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
        "item_moon_shard",
    ],
    pos_2: [
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
        // Bot policy: selected situational items and late upgrades.
        "item_ultimate_scepter_2",
        "item_octarine_core",
        "item_aghanims_shard",
        "item_sheepstick",
        "item_cyclone",
        "item_wind_waker",
        "item_heart",
    ],
    pos_3: [
        "item_tango",
        "item_headdress",
        "item_blood_grenade",
        "item_magic_wand",
        "item_mekansm",
        "item_holy_locket",
        // Bot policy: selected situational items and late upgrades.
        "item_glimmer_cape",
        "item_cyclone",
        "item_vladmir",
        "item_arcane_boots",
        "item_guardian_greaves",
        "item_sheepstick",
        "item_wind_waker",
        "item_aghanims_shard",
    ],
    pos_4: [
        "item_tango",
        "item_headdress",
        "item_blood_grenade",
        "item_magic_wand",
        "item_soul_ring",
        "item_mekansm",
        "item_holy_locket",
        // Bot policy: selected situational items and late upgrades.
        "item_ultimate_scepter",
        "item_ultimate_scepter_2",
        "item_black_king_bar",
        "item_arcane_boots",
        "item_guardian_greaves",
        "item_glimmer_cape",
        "item_sheepstick",
        "item_lotus_orb",
        "item_aghanims_shard",
    ],
    pos_5: [
        "item_tango",
        "item_headdress",
        "item_blood_grenade",
        "item_magic_wand",
        "item_mekansm",
        "item_holy_locket",
        // Bot policy: selected situational items and late upgrades.
        "item_glimmer_cape",
        "item_cyclone",
        "item_vladmir",
        "item_arcane_boots",
        "item_guardian_greaves",
        "item_sheepstick",
        "item_wind_waker",
        "item_aghanims_shard",
    ],
};
const roleItemSellList: ItemBuilds = {
    pos_1: ["item_maelstrom","item_soul_ring","item_lesser_crit","item_magic_wand"],
    pos_2: ["item_octarine_core","item_bottle","item_sheepstick","item_null_talisman","item_cyclone","item_magic_wand"],
    pos_3: [],
    pos_4: ["item_glimmer_cape","item_soul_ring"],
    pos_5: [],
};
let skillBuildList = roleSkillBuildList[role];
let talentBuildList = jmz.Skill.GetTalentBuild(roleTalentBuildList[role]);
let itemBuildList = roleItemBuyList[role];
let sellList = roleItemSellList[role];
const defaultAbilityBuild = skillBuildList, defaultTalentBuild = talentBuildList;
[skillBuildList, talentBuildList, itemBuildList, sellList] = jmz.SetUserHeroInit(skillBuildList, talentBuildList, itemBuildList, sellList);
const fullSkillBuildList = jmz.Skill.GetSkillList(allAbilitiesList, skillBuildList, allTalentsList, talentBuildList);
if (BuildData.patch === "7.41f" && skillBuildList === defaultAbilityBuild && talentBuildList === defaultTalentBuild) {
    if (role === "pos_5" || role === "pos_3") {
        // D2PT: attributes at 10, talents at 11/15.
        table.insert(fullSkillBuildList, 10, "special_bonus_attributes");
        [fullSkillBuildList[11], fullSkillBuildList[12]] = [fullSkillBuildList[12], fullSkillBuildList[11]];
        [fullSkillBuildList[14], fullSkillBuildList[15]] = [fullSkillBuildList[15], fullSkillBuildList[14]];
    } else {
        // D2PT takes an ability at 10, then the first talent at 11.
        [fullSkillBuildList[9], fullSkillBuildList[10]] = [fullSkillBuildList[10], fullSkillBuildList[9]];
    }
}

const abilityTether = bot.GetAbilityByName(allAbilitiesList[0]);
const abilitySpirits = bot.GetAbilityByName(allAbilitiesList[1]);
const abilityOvercharge = bot.GetAbilityByName(allAbilitiesList[2]);
const abilityRelocate = bot.GetAbilityByName(allAbilitiesList[5]);
const abilityBreakTether = bot.GetAbilityByName("wisp_tether_break");

let nearbyEnemies: Unit[] = [];

function HasHealingEffect(hero: Unit) {
    return HasAnyEffect(hero, "modifier_tango_heal", ...hero_is_healing);
}

bot.stateTetheredHero = bot.stateTetheredHero;

function ShouldUseOvercharge(ally: Unit) {
    const isAttacking = GameTime() - ally.GetLastAttackTime() < 0.33;
    const attackTarget = ally.GetAttackTarget();
    return jmz.IsGoingOnSomeone(ally) || (attackTarget && attackTarget.GetTeam() === GetOpposingTeam() && isAttacking) || ally.GetNearbyCreeps(200, true).length > 2;
}

function considerTether(): LuaMultiReturn<[number, Unit | null]> {
    if (!bot.HasModifier("modifier_wisp_tether")) {
        bot.stateTetheredHero = null;
    }
    if (!abilityTether.IsFullyCastable() || !abilityBreakTether.IsHidden()) {
        return $multi(BotActionDesire.None, null);
    }
    const castRange = abilityTether.GetCastRange();
    const allies = bot.GetNearbyHeroes(castRange, false, BotMode.None);

    for (const ally of allies) {
        const canTargetAlly = ally != bot && ally.IsAlive() && !ally.IsMagicImmune();
        if (!canTargetAlly) {
            continue;
        }
        if (jmz.IsRetreating(bot) || jmz.GetHP(bot) < 0.25) {
            if (jmz.IsRetreating(ally)) {
                return $multi(BotActionDesire.High, ally);
            }
            continue;
        }
        if (jmz.GetHP(ally) < 0.75 || jmz.GetMP(bot) > 0.8 || HasHealingEffect(bot) || ShouldUseOvercharge(ally)) {
            return $multi(BotActionDesire.High, ally);
        }
    }

    return $multi(BotActionDesire.None, null);
}

function considerOvercharge(): number {
    if (!abilityOvercharge.IsFullyCastable()) {
        return BotActionDesire.None;
    }
    if (bot.HasModifier("modifier_wisp_tether") && bot.stateTetheredHero !== null && ShouldUseOvercharge(bot.stateTetheredHero)) {
        return BotActionDesire.High;
    }
    return BotActionDesire.None;
}

function considerSpirits(): number {
    if (!abilitySpirits.IsFullyCastable()) {
        return BotActionDesire.None;
    }
    if (nearbyEnemies.length >= 1) {
        return BotActionDesire.High;
    }
    return BotActionDesire.None;
}

function considerRelocate(): LuaMultiReturn<[number, Location | null]> {
    if (bot.HasModifier("modifier_wisp_tether") && bot.stateTetheredHero !== null && (jmz.GetHP(bot.stateTetheredHero) <= 0.2 || jmz.GetHP(bot) <= 0.2)) {
        const allyNearbyEnemies = bot.stateTetheredHero.GetNearbyHeroes(1200, true, BotMode.None);
        if (
            (allyNearbyEnemies.length >= 1 && jmz.GetHP(bot.stateTetheredHero) < jmz.GetHP(allyNearbyEnemies[0])) ||
            (nearbyEnemies.length >= 1 && jmz.GetHP(bot) < jmz.GetHP(nearbyEnemies[0]))
        ) {
            return $multi(BotActionDesire.High, GetTeamFountainTpPoint());
        }
    }
    if (!bot.HasModifier("modifier_wisp_tether")) {
        if (nearbyEnemies.length >= 1 && jmz.GetHP(bot) < jmz.GetHP(nearbyEnemies[0])) {
            return $multi(BotActionDesire.High, GetTeamFountainTpPoint());
        }
    }

    for (const ally of GetUnitList(UnitType.AlliedHeroes)) {
        if (IsValidHero(ally) && jmz.IsInTeamFight(ally, 1200) && GetUnitToUnitDistance(bot, ally) > 3000 && ally.WasRecentlyDamagedByAnyHero(2)) {
            return $multi(BotActionDesire.High, ally.GetLocation());
        }
    }

    return $multi(BotActionDesire.None, null);
}

function SkillsComplement() {
    if (jmz.CanNotUseAbility(bot) || bot.IsInvisible()) {
        return;
    }

    nearbyEnemies = bot.GetNearbyHeroes(1600, true, BotMode.None);

    const [tetherDesire, tetherTarget] = considerTether();
    if (tetherDesire > 0 && tetherTarget) {
        bot.Action_UseAbilityOnEntity(abilityTether, tetherTarget);
        bot.stateTetheredHero = tetherTarget;
        return;
    }

    const overchargeDesire = considerOvercharge();
    if (overchargeDesire > 0) {
        bot.Action_UseAbility(abilityOvercharge);
        return;
    }
    const spiritsDesire = considerSpirits();
    if (spiritsDesire > 0) {
        bot.Action_UseAbility(abilitySpirits);
        return;
    }
    const [relocateDesire, relocateTarget] = considerRelocate();
    if (relocateDesire && relocateTarget !== null) {
        bot.Action_UseAbilityOnLocation(abilityRelocate, relocateTarget);
    }
}

function MinionThink(hMinionUnit: any) {
    if (minion.IsValidUnit(hMinionUnit)) {
        minion.IllusionThink(hMinionUnit);
    }
}

export = {
    SkillsComplement: SkillsComplement,
    MinionThink: MinionThink,
    sSellList: sellList,
    sBuyList: itemBuildList,
    sSkillList: fullSkillBuildList,
    buildMetadata: BuildData,
    neutralPreferences: BuildData.neutrals[role],
} satisfies BotSetup & { buildMetadata: typeof BuildData; neutralPreferences: unknown };
