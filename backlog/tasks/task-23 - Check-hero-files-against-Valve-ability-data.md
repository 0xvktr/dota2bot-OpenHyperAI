---
id: TASK-23
title: Check hero files against Valve ability data
status: Needs In-Game Test
assignee:
  - '@claude'
created_date: '2026-09-30 13:58'
updated_date: '2026-09-30 14:34'
labels:
  - tooling
  - hero
dependencies: []
references:
  - bots/BotLib
  - 'https://github.com/dotabuff/d2vpkr/tree/master/dota/scripts/npc/heroes'
documentation:
  - backlog/docs/doc-2 - Hero-improvement-playbook.md
priority: high
type: task
ordinal: 26000
---

## Description

<!-- SECTION:DESCRIPTION:BEGIN -->
Wrong ability value keys and talent names fail silently: `GetSpecialValueInt` returns 0 for a key the ability does not have, and a misnamed talent never reports as trained. Ancient Apparition's AoE Cold Feet read the Chilling Touch range talent this way, and Codex fixed several such fields (Riki, Sand King, Tiny, Troll) during the D2PT migration. A prototype scan (2026-09-30, after commit c57d1bf) of all 127 hero files against d2vpkr's `scripts/npc/heroes/npc_dota_hero_<name>.txt` flagged 11 names and 17 value keys. At least one is a real bug: Juggernaut reads `damage` from Omnislash, whose key is `bonus_damage`, so its kill estimate uses 0.

Known false positives in the prototype: cross-hero references (Sniper reading Zeus's ult on a teammate, Doom's devoured creep abilities), commented-out code (Pangolier Lucky Shot), abilities defined outside the hero's main block (Primal Beast Rock Throw), and talents whose definitions live outside the hero file (Lion, Silencer). Flagged value keys still to triage: Abaddon MistCoil target_damage, Arc Warden SparkWraith spark_damage/activation_delay, Gyrocopter CallDown damage_first, Juggernaut W dam, Kez KazuraiKatana katana_bonus_damage, Lina Q AbilityDamage, Lion R splash_radius_scepter, Mirana R dam, Monkey King PrimalSpring max_distance, Muerta Q bounce_range, Outworld Destroyer Objurgation mana_pool_to_barrier_pct/barrier, Queen of Pain R damage_scepter. Flagged names to triage: Beastmaster raptor/razorback/summon_raptors, Dawnbreaker celestial hammer cast range talent, Morphling adaptive_strike_str, Rubick talent 8.

Part of the roster-wide sweep in the hero improvement playbook (doc-2). Twelve heroes were still pending D2PT migration (TASK-4) when this was created; coordinate before editing those files.
<!-- SECTION:DESCRIPTION:END -->

## Acceptance Criteria
<!-- AC:BEGIN -->
- [x] #1 A documented command checks the ability names, talent names and ability value keys used in every bots/BotLib/hero_*.lua against Valve ability data
- [x] #2 Cross-hero references, commented-out code and abilities or talents defined outside the hero block do not produce findings
- [x] #3 The check runs offline from a cached copy of the Valve files and can be refreshed after a patch
- [x] #4 Every finding from the first full run is fixed or recorded here as intentional
- [x] #5 node tests/run-builds.cjs passes after the fixes
<!-- AC:END -->

## Implementation Plan

<!-- SECTION:PLAN:BEGIN -->
1. tests/valve/refresh.cjs downloads d2vpkr per-hero files for every bots/BotLib hero and writes a compact tests/valve/abilities.json (d2vpkr commit, header ability slots, each ability's value keys, behaviour, ultimate/innate flags, talent names). Only the JSON is committed, so checks run offline.
2. tests/valve_ability_check.cjs parses each hero file (comments stripped), resolves ability handles (literal GetAbilityByName names; sAbilityList[N] by simulating aba_skill.GetAbilityList for indices 1-3 and 6; sTalentList[N]) and reports literal names missing from Valve data and value keys missing from the resolved ability. Unresolved handles fall back to "key exists on any ability of the hero". Items, generic special_bonus talents and other heroes' abilities are skipped; talent 'value' is accepted (engine convention, unverifiable offline).
3. Intentional findings live in an allowlist with a reason each; the check runs from node tests/run-builds.cjs.
4. Triage the first run: fix real bugs in migrated heroes; for the 12 heroes still pending D2PT (TASK-4), record findings instead of editing their files.
5. Document the refresh step in docs/PATCH_UPDATE_GUIDE.md and the playbook (doc-2).
<!-- SECTION:PLAN:END -->

## Implementation Notes

<!-- SECTION:NOTES:BEGIN -->
2026-09-30: Built tests/valve/kv.cjs (KeyValues parser), tests/valve/refresh.cjs (pinned d2vpkr download -> tests/valve/abilities.json, 127 heroes at cf0d37a) and tests/valve_ability_check.cjs (luaparse AST; resolves handles from literal names, sAbilityList[1-3,6] via a GetAbilityList simulation, sTalentList[N]; reassigned handles pass if any target has the key; unresolved handles fall back to any ability of the hero; skips items, generic talents, other heroes' abilities; stale allowlist entries fail). Hooked into node tests/run-builds.cjs; documented in PATCH_UPDATE_GUIDE 1C-3, CLAUDE.md and doc-2.

First full run: 43 findings in 27 hero files, all fixed except one. Live bugs (values read as 0): Tidehunter Anchor Smash radius/cast range (now attack range + additional_range), Kez Katana range (read from kez_switch_weapons), Clinkz Burning Barrage radius (projectile_width), Monkey King Primal Spring distance (GetCastRange), Jakiro Macropyre radius (path_width / 2), Queen of Pain Sonic Wave damage with Scepter (removed damage_scepter override), Abaddon Mist Coil, Arc Warden Spark Wraith damage/delay, Enigma Malefice/Black Hole and both talent adds, Gyrocopter Rocket Barrage/Call Down, Lina Dragon Slave, Lion Scepter splash, Outworld Destroyer Objurgation barrier, Phoenix Fire Spirits duration, Techies Blast Off duration and Tazer radius, Terrorblade Demon Zeal cost, Enchantress Impetus, Dark Willow fear duration (Terrorize, not Bedlam), Elder Titan Earth Splitter range, KotL Will-O-Wisp duration, Nature's Prophet Sprout self-trap radius, Morphling Waveform damage. Dead names: Beastmaster summon_razorback/summon_raptor, Morphling Adaptive Strike STR (ability removed; code path deleted). Dead reads removed: Bane Nightmare, Juggernaut Healing Ward and Omnislash, Mirana Moonlight Shadow damage, Kez katana_bonus_damage.

Recorded as intentional (allowlist): Witch Doctor Death Ward reads bounce_range (key is bounce_radius, Scepter only). Witch Doctor is still pending D2PT migration (TASK-4); fix it then.

Needs lobby confirmation: Tidehunter Anchor Smash radius = attack range + additional_range (inferred from the key name and 7.41 data); talent GetSpecialValueInt('value') is accepted by the check as an engine convention but is not defined in 7.41 data for linked talents.

Validation: node tests/valve_ability_check.cjs passed (128 hero files, 1 allowlisted); node tests/run-builds.cjs passed; a deliberately broken AA key (kill_percent) was reported, then restored.
<!-- SECTION:NOTES:END -->

## Final Summary

<!-- SECTION:FINAL_SUMMARY:BEGIN -->
Added an offline check of hero ability names and value keys against Valve's d2vpkr data (tests/valve/*, tests/valve_ability_check.cjs, part of run-builds) and fixed 42 of its 43 first-run findings across 26 hero files. Several were live bugs where a value read as 0 (e.g. Tidehunter Anchor Smash range, Kez Katana range, Clinkz Barrage radius, Monkey King Primal Spring distance, Queen of Pain Scepter damage). Witch Doctor's finding is allowlisted until its D2PT migration. Verified with the check, the full run-builds suite and a deliberate regression; lobby checks listed in the notes.
<!-- SECTION:FINAL_SUMMARY:END -->
