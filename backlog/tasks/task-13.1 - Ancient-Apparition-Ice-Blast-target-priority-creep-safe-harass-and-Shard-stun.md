---
id: TASK-13.1
title: >-
  Ancient Apparition: Ice Blast target priority, creep-safe harass and Shard
  stun
status: Needs In-Game Test
assignee:
  - '@claude'
created_date: '2026-09-30 13:59'
updated_date: '2026-10-01 10:12'
labels:
  - hero
  - weak-hero
milestone: m-0
dependencies: []
references:
  - bots/BotLib/hero_ancient_apparition.lua
  - tests/ancient_apparition_combo_spec.lua
  - 'https://dotacoach.gg/en/heroes/ancient-apparition'
  - 'https://dotacoach.gg/en/heroes/counters/ancient-apparition'
documentation:
  - backlog/docs/doc-2 - Hero-improvement-playbook.md
parent_task_id: TASK-13
priority: medium
type: enhancement
ordinal: 28000
---

## Description

<!-- SECTION:DESCRIPTION:BEGIN -->
Deep-dive follow-up to the AA rework (TASK-1). A second review against dotacoach's hero and counters pages and a video on Ice Blast mechanics (2026-09-30) found three gaps. Fights are aimed only by how many heroes the blast hits, but its main value is healing prevention and the shatter threshold, which matter most against heroes that rely on healing or have large HP pools (Huskar, Alchemist, Necrophos, Io, Bristleback, Morphling, Leshrac, Troll). The lane harass added in the rework avoids enemy towers but can still draw lane-creep aggro. With Aghanim's Shard, Ice Blast's explosion stuns for 50% of Cold Feet's stun, which the fight logic does not value yet (Cold Feet already follows onto stunned enemies).

Some source claims are doubtful and must be checked against Valve data before use: dotacoach says Wind Waker dispels Ice Blast (Valve marks it not dispellable) and that Abaddon can die during Borrowed Time under Ice Blast.
<!-- SECTION:DESCRIPTION:END -->

## Acceptance Criteria
<!-- AC:BEGIN -->
- [x] #1 In fights, Ice Blast prefers heroes that rely on healing or have large HP pools when the number of heroes hit is equal or close
- [x] #2 Chilling Touch lane harass is skipped when the attack would draw enemy lane-creep aggro
- [x] #3 With Aghanim's Shard, Ice Blast is valued as an AoE stun in close fights and Cold Feet follows on the stunned enemies
- [x] #4 Source claims used by the new logic are confirmed against Valve ability data
- [x] #5 Offline specs cover the new decisions
<!-- AC:END -->

## Implementation Plan

<!-- SECTION:PLAN:BEGIN -->
1. bots/FunLib/heal_reliant_heroes.lua: heroes whose own kit heals, lifesteals or regenerates, each confirmed by a heal/lifesteal/regen value key in tests/valve/abilities.json (Morphling is left out: its Strength-shift interaction is not visible in Valve's ability data).
2. Ice Blast fight aiming scores each enemy in the blast instead of counting: 1 per hero, +0.6 heal-reliant, +0.3 for a large HP pool (max HP >= 3000). Bonuses stay below 1 so an extra hero still outweighs one priority target, but priority decides equal or near-equal counts.
3. Shard: detected from Ice Blast's own cold_feet_stun_duration_pct (0 without Shard, Valve key). Enemies within 1600 add +0.3 (the stun lands before they react) and +0.4 more when already cursed by Cold Feet (the stun holds them inside the break distance). Cold Feet already follows onto stunned enemies.
4. Chilling Touch lane harass is skipped when an enemy lane creep is within 500 of AA (creep AttackAcquisitionRange 500 in d2vpkr npc_units.txt).
5. Mirror the target scoring (not the Shard part) in FunLib/rubick_hero/ancient_apparition.lua.
6. Extend tests/ancient_apparition_combo_spec.lua; run the Valve check and run-builds.
Source claims: Ice Blast not dispellable (SpellDispellableType NO) so the Wind Waker claim is not used; the Borrowed Time/Shallow Grave/False Promise snipe exclusions stay as conservative guards and are not confirmable from ability data.
<!-- SECTION:PLAN:END -->

## Implementation Notes

<!-- SECTION:NOTES:BEGIN -->
2026-10-01: Added bots/FunLib/heal_reliant_heroes.lua (27 heroes, each backed by a heal/lifesteal/regen value key in tests/valve/abilities.json; Morphling excluded because its Strength-shift interaction is not in ability data). Ice Blast fight aiming now sums a per-enemy weight (1, +0.6 heal-reliant, +0.3 max HP >= 3000) instead of counting heroes; mirrored in FunLib/rubick_hero/ancient_apparition.lua. Shard is detected from Ice Blast's cold_feet_stun_duration_pct (Valve key, 0 without Shard): enemies within 1600 add +0.3, and +0.4 more when cursed by Cold Feet. Chilling Touch lane harass now also requires no enemy lane creep within 500 of AA (creep AttackAcquisitionRange 500 in d2vpkr npc_units.txt).

Source claims: Ice Blast is not dispellable in Valve data, so dotacoach's Wind Waker claim is not used. The snipe's Borrowed Time / Shallow Grave / False Promise exclusions are unchanged conservative guards; ability data cannot confirm or refute the Abaddon claim.

Validation: tests/ancient_apparition_combo_spec.lua scenarios 11-13 (priority on equal counts, three heroes beat one priority target, large HP tie-break, Rubick copy, Shard stun weight, creep-aggro guard) pass; node tests/valve_ability_check.cjs and node tests/run-builds.cjs pass.

To watch in a lobby: Ice Blasts landing on heal-reliant enemies in split fights; lane harass frequency (the creep guard may make it rare against melee-heavy creep waves); with Shard, Ice Blast then Cold Feet on stunned enemies. Not done (untracked ideas): Ice Vortex for vision or wave farming, Cold Feet timed on enemy last hits, tracer scouting, hidden units dodging Ice Blast.
<!-- SECTION:NOTES:END -->

## Final Summary

<!-- SECTION:FINAL_SUMMARY:BEGIN -->
Ice Blast now aims by target value instead of hero count (heal-reliant heroes and large HP pools, backed by a Valve-checked hero list in FunLib/heal_reliant_heroes.lua), values the Shard stun on close and Cold Feet targets, and Chilling Touch lane harass no longer draws lane-creep aggro. Rubick's copy shares the target priority. Verified with three new spec scenarios, the Valve ability check and run-builds; in-game behaviour still to confirm.
<!-- SECTION:FINAL_SUMMARY:END -->
