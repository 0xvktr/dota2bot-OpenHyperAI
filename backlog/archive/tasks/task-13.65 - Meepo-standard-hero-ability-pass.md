---
id: TASK-13.65
title: 'Meepo: standard hero ability pass'
status: Needs In-Game Test
assignee:
  - '@codex'
created_date: '2026-10-02 09:09'
updated_date: '2026-10-02 10:40'
labels:
  - hero
dependencies: []
references:
  - bots/BotLib/hero_meepo.lua
  - tests/meepo_ability_spec.lua
documentation:
  - backlog/docs/doc-2 - Hero-improvement-playbook.md
modified_files:
  - bots/BotLib/hero_meepo.lua
  - bots/FunLib/rubick_hero/meepo.lua
  - tests/meepo_ability_spec.lua
parent_task_id: TASK-13
priority: medium
ordinal: 105000
---

## Description

<!-- SECTION:DESCRIPTION:BEGIN -->
Meepo is part of the requested Ember Spirit through Pugna hero-file-order batch. Review actual spell decisions against current mechanics and human usage, fixing meaningful ability-use gaps while retaining the established D2PT build.
<!-- SECTION:DESCRIPTION:END -->

## Acceptance Criteria
<!-- AC:BEGIN -->
- [x] #1 Ability decisions and cast order are reviewed against Torte de Lini, dotacoach Strategy/Counter Strategy/full Matchup and pinned Valve definitions/localization; verified checklist and stale claims are recorded
- [x] #2 Identified meaningful behavior gaps are fixed, including applicable Rubick handling, with positive and negative offline regression scenarios
- [x] #3 Focused hero scenarios, Valve ability check and full build suite pass; lobby checklist and engine limitations are recorded for Needs In-Game Test handoff
<!-- AC:END -->

## Implementation Plan

<!-- SECTION:PLAN:BEGIN -->
- Prioritize survival before Poof, require safe owned clones, estimate actual damage and Net arrival, and use Fling only when justified.
<!-- SECTION:PLAN:END -->

## Implementation Notes

<!-- SECTION:NOTES:BEGIN -->
Source review and offline implementation for the Ember Spirit → Pugna batch (hero-file order).

Sources: Torte CLI tools/tdl/fetch.cjs meepo; https://dotacoach.gg/en/heroes/meepo and https://dotacoach.gg/en/heroes/counters/meepo (full Strategy, Counter Strategy and Matchup); Valve d2vpkr cf0d37a32c8df338a7832fd32a282747969e9a5f hero definitions plus English ability localization.

Verified ability checklist
- Read the full native file, Torte guide 129402256, complete Dotacoach Strategy, Counter Strategy and Matchup pages, and pinned Valve data and localization.
- Verified Earthbind range 750–1200, speed 1200, radius 220 and duration two seconds, without immunity piercing; Poof cast duration 1.5 seconds or 0.75 with talent, radius 400 and damage 50–140 plus a live 40 talent at both locations, with root restrictions; Dig lasts three seconds and heals 25%, also with root restrictions; MegaMeepo radius 600, duration 20 seconds and 40% clone statistics; Fling range 900, damage 225, no immunity piercing and no spell reflection.
- https://dotacoach.gg/en/heroes/meepo
- https://dotacoach.gg/en/heroes/counters/meepo

Implemented behavior
- Prioritize Dig or MegaMeepo for one endangered owned clone before the long Poof cast. Do not require attack mode or two endangered clones, and enforce actual root restrictions.
- Escape with Poof only to a healthy owned clone near the fountain without nearby enemies. Remove unsafe farthest-clone escapes and reject approaching stuns or alternative mass-pull mode.
- Use offensive Poof only when the root lasts through its cast and the destination clone is safe. Preserve useful local farming and both departure and arrival damage for last hits.
- Coordinate Earthbind using actual flight time, root expiry and owned-clone cast records. Predict within real center range plus the 220 radius and avoid counting cast point twice.
- Use Fling at its actual 900 range against a useful nonimmune hero without spell block. Do not automatically throw a vulnerable clone at a creep.
- Copied decisions do not assume absent clones or innate effects.

Rejected or stale source claims
- Reject the old 50% clone-experience claim. Current shared item and experience behavior was reviewed, while builds stayed unchanged.
- The old Shard paragraph confused it with Scepter; Dig is the current Shard ability.
- Reject Nullifier passive-Break advice. Pinned Valve data gives Ransack pure, immunity-piercing damage.

Item follow-up observations for TASK-21
- TASK21: Clone item cooldowns are shared except teleport scrolls, so do not assume repeated Blink or Hex casts. Dig protects individual clones, MegaMeepo can gather an endangered clone, and current statistic penalties matter.

Enemy counterplay observations for TASK-24
- TASK24: Focus a single clone, use area damage and curse interactions, consider armor and barriers, and reduce Ransack healing. Roots prevent Poof and Dig; immunity avoids Earthbind.

Lobby validation checklist
- Verify Poof departure and arrival damage and copied self-target compatibility. Copied decisions do not assume player-owned clones for Rubick.
- Verify Earthbind records during queued casts, request expiry and cast failures. No live game was launched.
- Verify MegaMeepo behavior when a candidate clone is rooted or banished.

Focused verification
- Fengari meepo_ability_spec passed six groups. The parent owns remaining integrated validation.

Full integration/build verification passed. Builds, skill/talent preferences and draft weights are unchanged. No game launched; engine-dependent claims remain lobby checks.

Final integrated verification: node tests/run-builds.cjs, node tests/run-objectives.cjs, node tests/valve_ability_check.cjs and git diff --check passed. Build/skill/talent preference AST comparison passed for all 49 scoped heroes. Native and applicable copied regressions are registered in run-builds. Framework callbacks and unsupported-spell dispatch preservation are covered. No game launched; the recorded lobby checklist remains required.
<!-- SECTION:NOTES:END -->

## Final Summary

<!-- SECTION:FINAL_SUMMARY:BEGIN -->
Meepo standard ability pass completed offline. Native and copied behavior reviewed against Torte, full Dotacoach Strategy/Counter Strategy/Matchup and pinned Valve KV/localization. Meaningful behavior fixes and positive/negative regressions implemented; builds and flags preserved. Final integrated verification: node tests/run-builds.cjs, node tests/run-objectives.cjs, node tests/valve_ability_check.cjs and git diff --check passed. Build/skill/talent preference AST comparison passed for all 49 scoped heroes. Native and applicable copied regressions are registered in run-builds. Framework callbacks and unsupported-spell dispatch preservation are covered. No game launched; the recorded lobby checklist remains required.
<!-- SECTION:FINAL_SUMMARY:END -->
