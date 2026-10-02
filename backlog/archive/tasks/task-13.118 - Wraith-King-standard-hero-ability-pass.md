---
id: TASK-13.118
title: 'Wraith King: standard hero ability pass'
status: Needs In-Game Test
assignee:
  - '@codex'
created_date: '2026-10-02 15:44'
updated_date: '2026-10-02 16:24'
labels:
  - hero
dependencies: []
references:
  - bots/BotLib/hero_skeleton_king.lua
  - tests/skeleton_king_ability_spec.lua
documentation:
  - backlog/docs/doc-2 - Hero-improvement-playbook.md
modified_files:
  - bots/BotLib/hero_skeleton_king.lua
  - bots/FunLib/rubick_hero/skeleton_king.lua
  - tests/skeleton_king_ability_spec.lua
  - bots/FunLib/skeleton_king_abilities.lua
parent_task_id: TASK-13
priority: medium
ordinal: 158000
---

## Description

<!-- SECTION:DESCRIPTION:BEGIN -->
Wraith King is part of the requested Queen of Pain through Zeus hero-file-order batch. Review actual spell decisions against current mechanics and human usage, fixing meaningful ability-use gaps while retaining the established D2PT build.
<!-- SECTION:DESCRIPTION:END -->

## Acceptance Criteria
<!-- AC:BEGIN -->
- [x] #1 Ability decisions and cast order are reviewed against Torte de Lini, dotacoach Strategy/Counter Strategy/full Matchup and pinned Valve definitions/localization; verified checklist and stale claims are recorded
- [x] #2 Identified meaningful behavior gaps are fixed, including applicable Rubick handling, with positive and negative offline regression scenarios
- [x] #3 Focused hero scenarios, Valve ability check and full build suite pass; lobby checklist and engine limitations are recorded for Needs In-Game Test handoff
<!-- AC:END -->

## Implementation Plan

<!-- SECTION:PLAN:BEGIN -->
Correct impact timing and real cast reach, observed skeleton charges and ordering, actual revive mana reserve and conservative active self-refresh.
<!-- SECTION:PLAN:END -->

## Implementation Notes

<!-- SECTION:NOTES:BEGIN -->
Source review and offline implementation for the Queen of Pain → Zeus batch (hero-file order).

Sources: Torte CLI tools/tdl/fetch.cjs skeleton_king; https://dotacoach.gg/en/heroes/wraith-king and https://dotacoach.gg/en/heroes/counters/wraith-king (full Strategy, Counter Strategy and Matchup); Valve d2vpkr cf0d37a32c8df338a7832fd32a282747969e9a5f hero definitions plus English ability localization.

Verified ability checklist
- Read all native decisions, complete Torte guide 128914193, canonical Wraith King Dotacoach Strategy, Counter Strategy and every Matchup synergy, gameplay and advanced item card; fetch CLI and hero identity checked.
- Pinned KV/localization: Wraithfire Blast 525 range, 0.35 cast point, 1200 projectile speed and 80/100/120/140 initial magical impact; subsequent 20/40/60/80 DPS over two seconds is separate delayed damage.
- Bone Guard costs 70/80/90/100, has 2/4/6/8 maximum charges, 40-second skeleton life, 0.25 spawn interval, one three-second respawn, 35 percent reduced building damage and 25 percent bonus hero damage. Actual minimum-spawn talent can supply five skeletons; Break stops gaining new charges, not existing charge use.
- Reincarnation is a friendly unit self-cast that kills the caster immediately and revives after three seconds with full health/mana. Mana is 220/110/0 and cooldown 180/150/120; actual Scepter reduces cooldown by ten seconds. Nearby death slow radius is 600 and automatic skeleton count is 2/3/4 per hero.
- Mortal Strike remains passive; Shard adds 75 percent of the initial attack as delayed pure damage after three seconds. Current innate Vampiric Spirit supplies lifesteal and death-delay Wraith form; Wraith form cannot Reincarnate. Deprecated Spectral Blade is not an active cast.
- Focused special-value fixtures now truncate the integer API and preserve the float API; fractional timing audit found no production misuse in this pass.

Implemented behavior
- Blast uses true live range with real Lens/Supremacy bonuses and actual projectile flight plus regeneration. It cannot claim the full damage-over-time effect as initial impact. Actual channels, lethal impact and endangered human allies take priority over summons and normal reserve policy.
- Bone Guard requires an observed charge modifier belonging to the current actual source or actual live minimum-spawn value. It does not fabricate a copied charge passive or blocked sibling. Existing charges remain usable under Break; meaningful native camp, lane, siege and objective summons remain. Ordinary combat summons precede Blast focus; urgent Blast goes first.
- Mana reserve applies only to an actual trained ready affordable positive-cost Reincarnation near enemies, with urgent interrupt, lethal and ally-save exceptions. Untrained, missing, unavailable and zero-cost level-three ultimates cannot suppress ordinary spells.
- Active Reincarnation is correctly self-targeted. A conservative resource refresh requires below 12 percent health, recent observed attack pressure, mana near the actual revive cost, nearby real allies and adequate local numbers. Existing Wraith form, Grave, False Promise, Borrowed Time, unrelated channel/cast/queue and all normal actor locks decline. No queued death or revive is treated as successful.
- Native default flags and build choices are preserved. Copied handler recognizes only Blast, Guard and Reincarnation before actor lookup and returns true exactly for an issued action.

Rejected or stale source claims
- Excluded obsolete mana-free Reincarnation Shard, learnable Vampiric Spirit, optional Spectral Blade facet casts, padded Blast reach, imaginary immediate full damage, untrained blanket revive reserve, stale Radiance disassembly and inferred copied lifesteal/critical passive.

Item follow-up observations for TASK-21
- TASK-21: actual Wand and mana burn affect positive-cost early Reincarnation reserve; level three costs zero and Shard does not solve revive mana. Existing Blink, BKB, Radiance, consumed Scepter and item builds remain unchanged.

Enemy counterplay observations for TASK-24
- TASK-24: damage immunity and physical protection affect summons, dispels/stun overlap constrain Blast, and mana denial matters before zero-cost Reincarnation. Current Break stops new Bone Guard stacks and passive critical/lifesteal benefits; it is not assumed to disable Reincarnation.

Lobby validation checklist
- Verify exact charge modifier ownership on native and copied Guard, minimum-spawn talent without stacks, actual summon spawn/focus ordering, independent nil siblings and use of accumulated charges under Break.
- Verify conservative critical-health active self-cast with nearby allies under mana burn, immediate death and three-second full resource revive; no gameplay was launched. Existing Wraith form/save effects and channel locks must preserve the first life. Also check actual projectile impact, slow/DoT and zero-cost level-three behavior.

Focused verification
59 native/copied focused scenarios passed under Fengari; four files parsed as Lua 5.2 and owned diff whitespace checks passed. Tests include actual range/bonuses, impact versus DoT, regeneration, channel/ally priority, own/foreign/missing charges, Break, actual minimum spawn, mana reserve and untrained/zero-cost exceptions, self-target shape, safe refresh negatives, native farm/setup and canonical unknown dispatch.

Full integration/build verification passed. Builds, skill/talent preferences and draft weights are unchanged. No game launched; engine-dependent claims remain lobby checks.

Final integrated verification: node tests/run-builds.cjs, node tests/run-objectives.cjs, node tests/valve_ability_check.cjs and git diff --check passed. Build/skill/talent preference AST comparison passed for all 43 scoped heroes. Native and applicable copied regressions are registered in run-builds. Framework callbacks and unsupported-spell dispatch preservation are covered. No game launched; the recorded lobby checklist remains required.
<!-- SECTION:NOTES:END -->

## Final Summary

<!-- SECTION:FINAL_SUMMARY:BEGIN -->
Wraith King standard ability pass completed offline. Native and copied behavior reviewed against Torte and full Dotacoach Strategy/Counter Strategy/Matchup and pinned Valve KV/localization. Meaningful behavior fixes and positive/negative regressions implemented; builds and flags preserved. Final integrated verification: node tests/run-builds.cjs, node tests/run-objectives.cjs, node tests/valve_ability_check.cjs and git diff --check passed. Build/skill/talent preference AST comparison passed for all 43 scoped heroes. Native and applicable copied regressions are registered in run-builds. Framework callbacks and unsupported-spell dispatch preservation are covered. No game launched; the recorded lobby checklist remains required.
<!-- SECTION:FINAL_SUMMARY:END -->
