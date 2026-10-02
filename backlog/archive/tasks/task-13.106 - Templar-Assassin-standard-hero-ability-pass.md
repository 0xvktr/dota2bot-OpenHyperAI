---
id: TASK-13.106
title: 'Templar Assassin: standard hero ability pass'
status: Needs In-Game Test
assignee:
  - '@codex'
created_date: '2026-10-02 15:12'
updated_date: '2026-10-02 16:24'
labels:
  - hero
dependencies: []
references:
  - bots/BotLib/hero_templar_assassin.lua
  - tests/templar_assassin_ability_spec.lua
documentation:
  - backlog/docs/doc-2 - Hero-improvement-playbook.md
modified_files:
  - bots/BotLib/hero_templar_assassin.lua
  - bots/FunLib/rubick_hero/templar_assassin.lua
  - tests/templar_assassin_ability_spec.lua
parent_task_id: TASK-13
priority: medium
ordinal: 146000
---

## Description

<!-- SECTION:DESCRIPTION:BEGIN -->
Templar Assassin is part of the requested Queen of Pain through Zeus hero-file-order batch. Review actual spell decisions against current mechanics and human usage, fixing meaningful ability-use gaps while retaining the established D2PT build.
<!-- SECTION:DESCRIPTION:END -->

## Acceptance Criteria
<!-- AC:BEGIN -->
- [x] #1 Ability decisions and cast order are reviewed against Torte de Lini, dotacoach Strategy/Counter Strategy/full Matchup and pinned Valve definitions/localization; verified checklist and stale claims are recorded
- [x] #2 Identified meaningful behavior gaps are fixed, including applicable Rubick handling, with positive and negative offline regression scenarios
- [x] #3 Focused hero scenarios, Valve ability check and full build suite pass; lobby checklist and engine limitations are recorded for Needs In-Game Test handoff
<!-- AC:END -->

## Implementation Plan

<!-- SECTION:PLAN:BEGIN -->
Repair separate Refraction stacks and disabled Shard cast, meaningful Meld attacks, owned trap detonation and safe Projection.
<!-- SECTION:PLAN:END -->

## Implementation Notes

<!-- SECTION:NOTES:BEGIN -->
Source review and offline implementation for the Queen of Pain → Zeus batch (hero-file order).

Sources: Torte CLI tools/tdl/fetch.cjs templar_assassin; https://dotacoach.gg/en/heroes/templar-assassin and https://dotacoach.gg/en/heroes/counters/templar-assassin (full Strategy, Counter Strategy and Matchup); Valve d2vpkr cf0d37a32c8df338a7832fd32a282747969e9a5f hero definitions plus English ability localization.

Verified ability checklist
- Read every native decision, full Torte guide 128748151 and complete Dotacoach Strategy, Counter Strategy, synergy, gameplay and advanced item cards. Verify current pinned Valve values and localization.
- Refraction has six 30-point barriers and separate offensive stacks; current Shard adds 30 damage and enables cast_while_disabled. Meld adds physical damage and armor reduction; runtime attack_range_bonus supplies the talent range.
- Trap range 1800, radius 400, full charge 3.5 seconds, full damage 200/300/400 over five seconds and maximum 5/8/11. Current Scepter supplies trap silence and two-second Projection; current Shard belongs to Refraction.

Implemented behavior
- Refraction handles missing defense or offense independently, real projectile threats and actual attack range. The precise Shard callback bypasses only stun, hex or nightmare while retaining every other forbidden state.
- Meld requires an actual attack opportunity with current talent range and queues the required attack, while defensive Meld preserves concealment. Fixed undefined native retarget variable.
- Trap placement uses exact Lens and unbroken Supremacy range, predicts actual engagement, supports human ally attacks and avoids real owned coverage or bounded pending requests. Rune vision uses engine rune locations.
- Detonation proves actual team and player ownership, chooses only the nearest trap for ordinary owner detonation and routes individual trap abilities for distant useful targets. Full-charge lethal decisions require a conservative observed minimum age and five-second regeneration allowance.
- Projection requires a safe real owned trap, actual channel arrival coverage or meaningful retreat progress, and rejects roots, Rupture, Coil and immediate channel threats. Projection during Meld skips item preparation that would break concealment.
- Copied unknown dispatch returns nil before gates or sibling lookups; unavailable runtime siblings decline safely.
- Owned stationary traps remain claimed when idle, locked or their detonation handle is unavailable, preventing shared minion fallback from issuing movement or attack orders.

Rejected or stale source claims
- The old logic guessed linked trap availability and full charged damage, used outdated Shard trap silence and arbitrary cast padding. Current Scepter supplies silence, and Refraction is the current Shard upgrade.

Item follow-up observations for TASK-21
- TASK-21: Lens extends actual trap placement; Blink and attack-range items enable Meld positioning, while Desolator and armor reduction support physical spill. Preserve current builds and shared item policy.

Enemy counterplay observations for TASK-24
- TASK-24: damage over time consumes Refraction barriers, HP removal bypasses them, detection exposes Meld and dispels remove trap slow. Respect enemy debuff immunity and reflected or protected targets without guessing cooldowns.

Lobby validation checklist
- No game was launched. Verify individual trap GetPlayerID ownership and runtime self-trap availability for native and copied traps. Unknown ownership is conservatively ignored.
- Trap age is the minimum time since observation, not guessed creation time. Full damage can be delayed for newly observed old traps; early useful slows remain available.
- Verify Shard casts during actual stun, hex and nightmare, Meld attack queuing and item-free Projection concealment. Alternate trap targeting is conservatively declined because no documented mouse endpoint is available.

Focused verification
- Focused native and copied Fengari scenarios passed, including disabled state guards, separate stacks, exact ranges, human allies, trap ownership and age, closest-trap semantics, safe channel arrival, Meld preparation and unknown dispatch.
- Valve check passed at 128 native heroes and 107 copied modules with zero findings; owned whitespace is clean. Shared callback wiring and integration checks are root-owned.
- Audited fractional special values against pinned data. Focused fixtures truncate integer getters toward zero and preserve float getters; all existing timing and moving-target scenarios pass with these engine semantics.
- Verified real pinned Dream Coil modifier modifier_puck_coiled with a focused displacement refusal regression.

Framework integration
- UseDisabledRefraction: call before shared stun/hex/nightmare gate; requires actual runtime cast_while_disabled and all other forbidden states clear.
- UseTrapMinion: returns true for actual valid owned named stationary traps, including idle or occupied states; false permits fallback only for unrelated, invalid or foreign minions.

Full integration/build verification passed. Builds, skill/talent preferences and draft weights are unchanged. No game launched; engine-dependent claims remain lobby checks.

Final integrated verification: node tests/run-builds.cjs, node tests/run-objectives.cjs, node tests/valve_ability_check.cjs and git diff --check passed. Build/skill/talent preference AST comparison passed for all 43 scoped heroes. Native and applicable copied regressions are registered in run-builds. Framework callbacks and unsupported-spell dispatch preservation are covered. No game launched; the recorded lobby checklist remains required.
<!-- SECTION:NOTES:END -->

## Final Summary

<!-- SECTION:FINAL_SUMMARY:BEGIN -->
Templar Assassin standard ability pass completed offline. Native and copied behavior reviewed against Torte and full Dotacoach Strategy/Counter Strategy/Matchup and pinned Valve KV/localization. Meaningful behavior fixes and positive/negative regressions implemented; builds and flags preserved. Final integrated verification: node tests/run-builds.cjs, node tests/run-objectives.cjs, node tests/valve_ability_check.cjs and git diff --check passed. Build/skill/talent preference AST comparison passed for all 43 scoped heroes. Native and applicable copied regressions are registered in run-builds. Framework callbacks and unsupported-spell dispatch preservation are covered. No game launched; the recorded lobby checklist remains required.
<!-- SECTION:FINAL_SUMMARY:END -->
