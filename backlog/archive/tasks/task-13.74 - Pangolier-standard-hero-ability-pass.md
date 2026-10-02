---
id: TASK-13.74
title: 'Pangolier: standard hero ability pass'
status: Needs In-Game Test
assignee:
  - '@codex'
created_date: '2026-10-02 09:09'
updated_date: '2026-10-02 16:17'
labels:
  - hero
  - weak-hero
milestone: m-0
dependencies: []
references:
  - bots/BotLib/hero_pangolier.lua
  - tests/pangolier_ability_spec.lua
documentation:
  - backlog/docs/doc-2 - Hero-improvement-playbook.md
modified_files:
  - bots/BotLib/hero_pangolier.lua
  - bots/FunLib/rubick_hero/pangolier.lua
parent_task_id: TASK-13
priority: medium
ordinal: 114000
---

## Description

<!-- SECTION:DESCRIPTION:BEGIN -->
Pangolier is part of the requested Ember Spirit through Pugna hero-file-order batch. Review actual spell decisions against current mechanics and human usage, fixing meaningful ability-use gaps while retaining the established D2PT build.
<!-- SECTION:DESCRIPTION:END -->

## Acceptance Criteria
<!-- AC:BEGIN -->
- [x] #1 Ability decisions and cast order are reviewed against Torte de Lini, dotacoach Strategy/Counter Strategy/full Matchup and pinned Valve definitions/localization; verified checklist and stale claims are recorded
- [x] #2 Identified meaningful behavior gaps are fixed, including applicable Rubick handling, with positive and negative offline regression scenarios
- [x] #3 Focused hero scenarios, Valve ability check and full build suite pass; lobby checklist and engine limitations are recorded for Needs In-Game Test handoff
<!-- AC:END -->

## Implementation Plan

<!-- SECTION:PLAN:BEGIN -->
Conservative facing/dash Swash geometry, real physical Crash landing, safe roll transformations and release states, mobility constraints; independent stolen actives.
<!-- SECTION:PLAN:END -->

## Implementation Notes

<!-- SECTION:NOTES:BEGIN -->
Source review and offline implementation for the Ember Spirit → Pugna batch (hero-file order).

Sources: Torte CLI tools/tdl/fetch.cjs pangolier; https://dotacoach.gg/en/heroes/pangolier and https://dotacoach.gg/en/heroes/counters/pangolier (full Strategy, Counter Strategy and Matchup); Valve d2vpkr cf0d37a32c8df338a7832fd32a282747969e9a5f hero definitions plus English ability localization.

Verified ability checklist
- TDL guide 1187551178 fetched/read; full Strategy/Counter/Matchup https://dotacoach.gg/en/heroes/pangolier and https://dotacoach.gg/en/heroes/counters/pangolier.
- Valve Swash VECTOR POINT/root disables, dash 575..800/speed 2000, slash 850/width 155,3 strikes 35..125/interval 0.1, physical/piercing; no guaranteed Lucky Shot/Basher procs.
- Shield Crash NO_TARGET physical/nonpiercing 60..240/radius 500, jump 225/0.4 s or rolling 0.75 s, realhero barrier 60..240 for 6 s; Scepter 2 swipes/four directions 75%.
- Roll root-disabled/cast 1.2,physical damage 80% total attack, hitradius 150/stun 1.2/duration 10..12/debuff immunity/MR 80%; RollUp 2.25/stationary/MR 80%, linked stop handles optional.

Implemented behavior
- Swash point within real dash, facing projection/slash-width and target prediction, true local lane/farm counts, no random proc kill assumptions or bogus out-of-range neutral cast.
- Crash forward or rolling landing predicts nearby actual victims; correct physical damage and excludes debuff-immune victims/barrier illusions.
- Roll and Swash reject roots/leash/Rupture; active Roll stops for Rupture, escape roll retained when pursuers leave sight.
- RollUp prepares affordable vulnerable transform under enemy pressure/incoming control; EndRollUp checks actual modifier and safe aligned resume.
- Independent six-actives Rubick module with exact name gate and nil sibling guards.

Rejected or stale source claims
- TDL guide Heartpiercer/disarm LuckyShot/damage-reduction Shield wording old.
- Matchup magic-resistance/Raindrop Shield counters and Muerta takes Shield magic damage rejected; pinned Crash physical and barrier, no guaranteed immunity/proc.

Item follow-up observations for TASK-21
- TASK 21: Diffusal/Mage Slayer effects on Swash, Basher chance, Blink active-roll reposition, Scepter Crash swipes, Shard control-safe transform; no guaranteed proc math or item-build changes.

Enemy counterplay observations for TASK-24
- TASK 24: pressure after dash, spread/sharp turn from rolls, debuff-immunity versus nonpiercing control, root/leash and piercing stuns, Rupture stops movement; dispels remove barrier.

Lobby validation checklist
- Documented bot API exposes only one point for vector Swash; current-facing conservative geometry tested but actual slash vector direction needs engine validation.
- Crash landing during RollUp/Roll and cliff handling; rebounce aiming/Blink timing; stolen roll linked stop activation.
- No live game or deep-dive validation was performed during this standard pass.

Focused verification
- Fengari tests/pangolier_ability_spec.lua passed; native/stolen/spec Lua 5.2 parse passed.

Full integration/build verification passed. Builds, skill/talent preferences and draft weights are unchanged. No game launched; engine-dependent claims remain lobby checks.

Final integrated verification: node tests/run-builds.cjs, node tests/run-objectives.cjs, node tests/valve_ability_check.cjs and git diff --check passed. Build/skill/talent preference AST comparison passed for all 49 scoped heroes. Native and applicable copied regressions are registered in run-builds. Framework callbacks and unsupported-spell dispatch preservation are covered. No game launched; the recorded lobby checklist remains required.

2026-10-02 shared movement safety follow-up: pinned English localization explicitly names modifier_puck_coiled (Dream Coiled). Replaced inherited modifier_puck_dream_coil checks with the actual debuff name in this previously passed hero. This is a narrow API/mechanics correction; preference assignments remain intact. The final Queen of Pain → Zeus integrated suite covers these files; lobby movement validation remains required.
<!-- SECTION:NOTES:END -->

## Final Summary

<!-- SECTION:FINAL_SUMMARY:BEGIN -->
Pangolier standard ability pass completed offline. Native and copied behavior reviewed against Torte, full Dotacoach Strategy/Counter Strategy/Matchup and pinned Valve KV/localization. Meaningful behavior fixes and positive/negative regressions implemented; builds and flags preserved. Final integrated verification: node tests/run-builds.cjs, node tests/run-objectives.cjs, node tests/valve_ability_check.cjs and git diff --check passed. Build/skill/talent preference AST comparison passed for all 49 scoped heroes. Native and applicable copied regressions are registered in run-builds. Framework callbacks and unsupported-spell dispatch preservation are covered. No game launched; the recorded lobby checklist remains required.
<!-- SECTION:FINAL_SUMMARY:END -->
