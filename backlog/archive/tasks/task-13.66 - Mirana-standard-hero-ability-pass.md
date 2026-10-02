---
id: TASK-13.66
title: 'Mirana: standard hero ability pass'
status: Needs In-Game Test
assignee:
  - '@codex'
created_date: '2026-10-02 09:09'
updated_date: '2026-10-02 10:40'
labels:
  - hero
dependencies: []
references:
  - bots/BotLib/hero_mirana.lua
  - tests/mirana_ability_spec.lua
documentation:
  - backlog/docs/doc-2 - Hero-improvement-playbook.md
modified_files:
  - bots/BotLib/hero_mirana.lua
  - bots/FunLib/rubick_hero/mirana.lua
  - tests/mirana_ability_spec.lua
parent_task_id: TASK-13
priority: medium
ordinal: 106000
---

## Description

<!-- SECTION:DESCRIPTION:BEGIN -->
Mirana is part of the requested Ember Spirit through Pugna hero-file-order batch. Review actual spell decisions against current mechanics and human usage, fixing meaningful ability-use gaps while retaining the established D2PT build.
<!-- SECTION:DESCRIPTION:END -->

## Acceptance Criteria
<!-- AC:BEGIN -->
- [x] #1 Ability decisions and cast order are reviewed against Torte de Lini, dotacoach Strategy/Counter Strategy/full Matchup and pinned Valve definitions/localization; verified checklist and stale claims are recorded
- [x] #2 Identified meaningful behavior gaps are fixed, including applicable Rubick handling, with positive and negative offline regression scenarios
- [x] #3 Focused hero scenarios, Valve ability check and full build suite pass; lobby checklist and engine limitations are recorded for Needs In-Game Test handoff
<!-- AC:END -->

## Implementation Plan

<!-- SECTION:PLAN:BEGIN -->
- Account for Arrow blockers and disable setups, identify Starstorm’s nearest recipient, make Leap facing and charge decisions safe, and use global Moonlight saves.
<!-- SECTION:PLAN:END -->

## Implementation Notes

<!-- SECTION:NOTES:BEGIN -->
Source review and offline implementation for the Ember Spirit → Pugna batch (hero-file order).

Sources: Torte CLI tools/tdl/fetch.cjs mirana; https://dotacoach.gg/en/heroes/mirana and https://dotacoach.gg/en/heroes/counters/mirana (full Strategy, Counter Strategy and Matchup); Valve d2vpkr cf0d37a32c8df338a7832fd32a282747969e9a5f hero definitions plus English ability localization.

Verified ability checklist
- Read the full native file, Torte guide 129381491, complete Dotacoach Strategy, Counter Strategy and Matchup pages, and pinned Valve data and localization.
- Verified Arrow travel 3000, speed 900 and width 115, with first-unit collision and no immunity piercing; Starstorm radius 675, damage 75–300 and an 80% second meteor; Leap distance 650 plus talent 150 and current Shard extra charge, with root restrictions; Moonlight Shadow lasts 18 seconds globally with fade times 2.5/2/1.5 seconds.
- https://dotacoach.gg/en/heroes/mirana
- https://dotacoach.gg/en/heroes/counters/mirana

Implemented behavior
- Prioritize Arrow interrupts before Starstorm. Query visible heroes globally, reject paths blocked by another hero, neutral or creep, predict ordinary movement, and time known banishment exits.
- Read live Starstorm damage and grant the 80% second meteor only to the nearest eligible hero or creep. Exclude invisible recipients.
- Project Leap from actual facing, reserve the last charge during offense, require retreat landings to increase distance from every visible chasing threat, and reject roots or Rupture.
- Use Moonlight for a remotely threatened ally before routine damage, and preserve grouped gank-approach opportunities without querying a zero-radius neighborhood.
- Use explicit ability names for the current innate layout, prepare items with real spell handles, and avoid copied innate assumptions.

Rejected or stale source claims
- Reject old Shard Sagan line and slow advice; the current Quiver gives temporary charges and an extra Leap. Copied Quiver was not invented.
- Do not guarantee Arrow behavior against dominated creeps from incomplete Matchup advice. Ancient neutrals are not assumed to die in one hit.
- Do not assume linked Scepter Starstorm effects when their actual handle is absent in copied use.

Item follow-up observations for TASK-21
- TASK21: Eul, Atos and allied Bane, Shadow Demon or Outworld Destroyer can provide Arrow timing. BKB protects eligible Leap windows. Scepter path effects require real linked behavior. Moonlight fade and detection matter, and Shard charges support escape.

Enemy counterplay observations for TASK-24
- TASK24: Creeps and other heroes can block Arrow. Detection counters Moonlight. Roots, leashes and Rupture constrain Leap, while immunity avoids Arrow and Starstorm damage or control as applicable.

Lobby validation checklist
- Arrow blocker movement and collision are approximate. Known banishment timing must fall within 0.15 seconds of predicted arrival; a hit is not guaranteed.
- If the nearest Starstorm recipient dies before the second meteor, the engine can select another recipient, so the extra-damage estimate remains conditional. Verify Leap terrain and landing passability in the engine.

Focused verification
- Fengari mirana_ability_spec passed five groups; no game launched. The parent owns remaining integrated validation.

Full integration/build verification passed. Builds, skill/talent preferences and draft weights are unchanged. No game launched; engine-dependent claims remain lobby checks.

Final integrated verification: node tests/run-builds.cjs, node tests/run-objectives.cjs, node tests/valve_ability_check.cjs and git diff --check passed. Build/skill/talent preference AST comparison passed for all 49 scoped heroes. Native and applicable copied regressions are registered in run-builds. Framework callbacks and unsupported-spell dispatch preservation are covered. No game launched; the recorded lobby checklist remains required.
<!-- SECTION:NOTES:END -->

## Final Summary

<!-- SECTION:FINAL_SUMMARY:BEGIN -->
Mirana standard ability pass completed offline. Native and copied behavior reviewed against Torte, full Dotacoach Strategy/Counter Strategy/Matchup and pinned Valve KV/localization. Meaningful behavior fixes and positive/negative regressions implemented; builds and flags preserved. Final integrated verification: node tests/run-builds.cjs, node tests/run-objectives.cjs, node tests/valve_ability_check.cjs and git diff --check passed. Build/skill/talent preference AST comparison passed for all 49 scoped heroes. Native and applicable copied regressions are registered in run-builds. Framework callbacks and unsupported-spell dispatch preservation are covered. No game launched; the recorded lobby checklist remains required.
<!-- SECTION:FINAL_SUMMARY:END -->
