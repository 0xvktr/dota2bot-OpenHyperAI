---
id: TASK-13.111
title: 'Timbersaw: standard hero ability pass'
status: Needs In-Game Test
assignee:
  - '@codex'
created_date: '2026-10-02 15:22'
updated_date: '2026-10-02 16:24'
labels:
  - hero
dependencies: []
references:
  - bots/BotLib/hero_shredder.lua
  - tests/shredder_ability_spec.lua
documentation:
  - backlog/docs/doc-2 - Hero-improvement-playbook.md
modified_files:
  - bots/BotLib/hero_shredder.lua
  - bots/FunLib/rubick_hero/shredder.lua
  - tests/shredder_ability_spec.lua
  - bots/FunLib/shredder_abilities.lua
parent_task_id: TASK-13
priority: medium
ordinal: 151000
---

## Description

<!-- SECTION:DESCRIPTION:BEGIN -->
Timbersaw is part of the requested Queen of Pain through Zeus hero-file-order batch. Review actual spell decisions against current mechanics and human usage, fixing meaningful ability-use gaps while retaining the established D2PT build.
<!-- SECTION:DESCRIPTION:END -->

## Acceptance Criteria
<!-- AC:BEGIN -->
- [x] #1 Ability decisions and cast order are reviewed against Torte de Lini, dotacoach Strategy/Counter Strategy/full Matchup and pinned Valve definitions/localization; verified checklist and stale claims are recorded
- [x] #2 Identified meaningful behavior gaps are fixed, including applicable Rubick handling, with positive and negative offline regression scenarios
- [x] #3 Focused hero scenarios, Valve ability check and full build suite pass; lobby checklist and engine limitations are recorded for Needs In-Game Test handoff
<!-- AC:END -->

## Implementation Plan

<!-- SECTION:PLAN:BEGIN -->
Correct real tree latch and damage geometry, observed Chakram deployment/return ownership, current upgrades and narrowly immediate casts during actual Timber Chain movement.
<!-- SECTION:PLAN:END -->

## Implementation Notes

<!-- SECTION:NOTES:BEGIN -->
Source review and offline implementation for the Queen of Pain → Zeus batch (hero-file order).

Sources: Torte CLI tools/tdl/fetch.cjs shredder; https://dotacoach.gg/en/heroes/timbersaw and https://dotacoach.gg/en/heroes/counters/timbersaw (full Strategy, Counter Strategy and Matchup); Valve d2vpkr cf0d37a32c8df338a7832fd32a282747969e9a5f hero definitions plus English ability localization.

Verified ability checklist
- Read all native decision functions, the full Torte guide 129105276, canonical Timbersaw Dotacoach Strategy and Counter Strategy, and all Matchup synergy, gameplay and advanced item cards. Ran the guide fetch CLI and validated page identity.
- Pinned KV and localization: Whirling Death 325 radius, 240 pure base damage and 30 per actual tree; attribute loss and Exposure Therapy are separate effects, not automatic instant kill damage.
- Timber Chain has a 90 first-tree latch width and a separate 225 damage radius, 1200 base range, 2800 speed and 225 pure damage, with 0.3 cast point; actual trained talent can increase its runtime range and speed by 75 percent. Root disable and real first-tree collision remain mandatory.
- Chakram has 1200 range, 0.15 cast point, 900 speed, 200 area, 225 pass damage, 100 DPS, 20 mana per second and 2000 break distance. Copied modules use real current handles and exact source/caster observations.
- Reactive Armor Scepter activates maximum stacks and a 150 initial barrier that grows up to 800, then explodes after eight seconds; no immediate maximum explosion is assumed. Break prevents new passive stacks, not existing bonuses.
- Flamethrower is an actual Shard handle, immediate no-target, 400 forward length, 275 width, 70 magical DPS for eight seconds, 40 percent slow and 50 percent building damage. Its current KV does not pierce hero debuff immunity.
- Current localization identifies Timber Chain, Chakram Disarm and Reactive Armor Bomb modifier names. Documented bot APIs provide current tree IDs, linear projectiles and avoidance zones with source ability and caster handles.
- Focused special-value fixtures now truncate the integer API and preserve the float API; fractional timing audit found no production misuse in this pass.

Implemented behavior
- Whirling Death includes only actual current nearby trees in its pure impact estimate, avoids inventing attribute-loss damage, and preserves native last hits, farm and objectives. Endangered human allies receive the same nearby damage peel opportunities as bot allies.
- Timber Chain requires an actual tree, predicts against the first intervening latch rather than an imagined endpoint, distinguishes 90 latch width from 225 damage reach, and bounds physical travel at live range. Root, leash, Rupture, terrain, tower exposure and local numbers constrain movement; retreat selects a real tree toward safety. No Whirling sibling is presumed.
- Chakram casts predict real flight at actual range, use only one pass for lethal checks and honor regeneration. Native wave and ranged-creep use remain. Deprecated second and twisted blades are considered only when actual trained visible active handles exist; no curved trajectory is converted into a guaranteed straight-line kill.
- Return checks exact own source/caster projectile travel, exact own persistent zones, or an actual source-owned disarm plus hidden source and completed flight time after recorded intent. Canceled intent and another caster projectile cannot assert deployment. Actual heroes occupying a blade preserve it even without creeps; empty blades, escape mana reserve and break distance trigger return.
- Reactive Armor requires an actual active upgraded source and avoids duplicate observed barrier effects. Flamethrower uses real forward geometry, live upgrade guards, creep clearing and current reduced building damage opportunities while respecting structure protection.
- Native and copied UseSpellsDuringTimberChain directly issue immediate Whirl or Flame only with an observed Timber Chain caster modifier applied by the exact current Chain handle. It rejects unrelated active handles, cast animations, channels, queues, disables, Box, Doom and Force Staff. The exception uses no item preparation and returns true only for an action.
- Copied handler recognizes nine actual supported source names before lookup and uses canonical unknown/skip/action return values.
- Movement guards use the actual pinned English modifier_puck_coiled, replacing an inherited nonexistent Dream Coil modifier name; native and copied negative coverage was rerun.

Rejected or stale source claims
- Excluded old second-Chakram Scepter assumptions, passive or missing upgrade handle casts, name-only foreign projectile checks, instant full-duration Chakram damage, guaranteed attribute-loss damage, unchanged reactive stacks under Break assumptions, obsolete facet prerequisites and old item/disassembly advice. Matchup claims that silence prevents attacks or that all Flame damage bypasses immunity are not adopted.

Item follow-up observations for TASK-21
- TASK-21 observations: existing mana items determine how long actual deployed Chakram can remain while preserving ready Chain mana. Actual Scepter barrier and Shard Flame opportunities are now read from runtime sources. BKB/Lotus/dispel recommendations remain observations; purchases and generic item logic are unchanged.

Enemy counterplay observations for TASK-24
- TASK-24 observations: root, leash and Rupture constrain Chain travel; tree removal changes the actual first latch and Whirl damage. Pure damage does not imply piercing debuff immunity. Break stops gaining armor stacks, healing reduction limits sustain, and dispels can remove the actual Scepter barrier.

Lobby validation checklist
- Needs in-game verification of actual Tree Chain projectile latch and arrival, source identity during movement, direct immediate Whirl/Flame while IsUsingAbility, canceled casts and unrelated active handles. No cast animation is deliberately interrupted.
- Verify exact Chakram source/caster observations in GetLinearProjectiles/GetAvoidanceZones, current hidden/disarm source fallback, second-blade identity, enemy hero occupancy without creeps, mana drain and return distance. Also verify live tree bonuses, Scepter barrier/explosion, Flame width and current building reduction.

Focused verification
36 meaningful native/copied scenarios passed under Fengari; all four files parsed as Lua 5.2 and owned-file diff whitespace checks passed. Tests cover real/absent/intervening trees, separate latch and damage widths, movement restrictions, null siblings, cast bonuses, regeneration, own/foreign/canceled deployment, hero occupancy, channel and queue locks, actual upgrades, human peel and native farm/siege.

Framework integration
- UseSpellsDuringTimberChain

Full integration/build verification passed. Builds, skill/talent preferences and draft weights are unchanged. No game launched; engine-dependent claims remain lobby checks.

Final integrated verification: node tests/run-builds.cjs, node tests/run-objectives.cjs, node tests/valve_ability_check.cjs and git diff --check passed. Build/skill/talent preference AST comparison passed for all 43 scoped heroes. Native and applicable copied regressions are registered in run-builds. Framework callbacks and unsupported-spell dispatch preservation are covered. No game launched; the recorded lobby checklist remains required.
<!-- SECTION:NOTES:END -->

## Final Summary

<!-- SECTION:FINAL_SUMMARY:BEGIN -->
Timbersaw standard ability pass completed offline. Native and copied behavior reviewed against Torte and full Dotacoach Strategy/Counter Strategy/Matchup and pinned Valve KV/localization. Meaningful behavior fixes and positive/negative regressions implemented; builds and flags preserved. Final integrated verification: node tests/run-builds.cjs, node tests/run-objectives.cjs, node tests/valve_ability_check.cjs and git diff --check passed. Build/skill/talent preference AST comparison passed for all 43 scoped heroes. Native and applicable copied regressions are registered in run-builds. Framework callbacks and unsupported-spell dispatch preservation are covered. No game launched; the recorded lobby checklist remains required.
<!-- SECTION:FINAL_SUMMARY:END -->
