---
id: TASK-13.61
title: 'Magnus: standard hero ability pass'
status: Needs In-Game Test
assignee:
  - '@codex'
created_date: '2026-10-02 09:09'
updated_date: '2026-10-02 10:40'
labels:
  - hero
dependencies: []
references:
  - bots/BotLib/hero_magnataur.lua
  - tests/magnataur_ability_spec.lua
documentation:
  - backlog/docs/doc-2 - Hero-improvement-playbook.md
modified_files:
  - bots/BotLib/hero_magnataur.lua
  - bots/FunLib/rubick_hero/magnataur.lua
  - tests/magnataur_ability_spec.lua
parent_task_id: TASK-13
priority: medium
ordinal: 101000
---

## Description

<!-- SECTION:DESCRIPTION:BEGIN -->
Magnus is part of the requested Ember Spirit through Pugna hero-file-order batch. Review actual spell decisions against current mechanics and human usage, fixing meaningful ability-use gaps while retaining the established D2PT build.
<!-- SECTION:DESCRIPTION:END -->

## Acceptance Criteria
<!-- AC:BEGIN -->
- [x] #1 Ability decisions and cast order are reviewed against Torte de Lini, dotacoach Strategy/Counter Strategy/full Matchup and pinned Valve definitions/localization; verified checklist and stale claims are recorded
- [x] #2 Identified meaningful behavior gaps are fixed, including applicable Rubick handling, with positive and negative offline regression scenarios
- [x] #3 Focused hero scenarios, Valve ability check and full build suite pass; lobby checklist and engine limitations are recorded for Needs In-Game Test handoff
<!-- AC:END -->

## Implementation Plan

<!-- SECTION:PLAN:BEGIN -->
- Buff useful allies with Empower at actual range, prioritize immunity-piercing Reverse Polarity, and plan safe displacement geometry.
<!-- SECTION:PLAN:END -->

## Implementation Notes

<!-- SECTION:NOTES:BEGIN -->
Source review and offline implementation for the Ember Spirit → Pugna batch (hero-file order).

Sources: Torte CLI tools/tdl/fetch.cjs magnataur; https://dotacoach.gg/en/heroes/magnus and https://dotacoach.gg/en/heroes/counters/magnus (full Strategy, Counter Strategy and Matchup); Valve d2vpkr cf0d37a32c8df338a7832fd32a282747969e9a5f hero definitions plus English ability localization.

Verified ability checklist
- Read all native consideration functions, Torte guide 128945163, complete Dotacoach Strategy, Counter Strategy and Matchup pages, and pinned Valve data and localization.
- Verified Shockwave range 1200, speed 1200 and damage 75–300; Empower range 800 and no self cast because native self benefits are already provided; Skewer distance 1100 plus Shard 300, radius 145 and root restrictions; Reverse Polarity radius 430, immunity-piercing damage 100–300 and cast point 0.3 seconds; Horn Toss radius 325, cone 230 degrees, airborne duration 0.6 seconds and stun 0.75 seconds.
- https://dotacoach.gg/en/heroes/magnus
- https://dotacoach.gg/en/heroes/counters/magnus

Implemented behavior
- Prioritize Reverse Polarity against channeling immune enemies before Blink, and use it to support retreat without requiring lethal damage. Predict circle membership and filter real valid recipients.
- Use Empower on an attacking farming carry within actual range, skip self, illusions and existing buffs, and prioritize melee allies.
- Compute Blink → Reverse Polarity → Skewer endpoints from the future Blink position rather than the current position, with root and Reverse Polarity facet guards.
- Remove the unobserved Blink → Horn Toss sequence that immediately cast Toss and cancelled its queued Blink. Retain ordinary local Toss decisions.
- Use actual Shockwave range, remove a duplicated cast-point delay, bound dispatch locations, and add independent copied control decisions.

Rejected or stale source claims
- Reject the claim that Magnus cannot interrupt BKB-protected Black Hole; Reverse Polarity pierces immunity.
- Reject old Shockwave Shard advice; the current upgrade affects Skewer travel and collision.
- Reject obsolete enemy Solar Crest armor reduction and Arcane Boots disassembly tips. Item builds were not changed.

Item follow-up observations for TASK-21
- TASK21: Use BKB before an exposed initiation sequence. Blink positions Magnus before Reverse Polarity. Harpoon can set up Skewer toward the team, while Refresher needs mana for both ultimates and careful queue sequencing.

Enemy counterplay observations for TASK-24
- TASK24: Spread outside the 430 Reverse Polarity radius and scout or cancel Blink. Force Staff, Wind Waker and Aeon Disk can disrupt combinations. Immunity alone does not prevent Reverse Polarity.

Lobby validation checklist
- Verify facing and arrival precision for manual Horn Toss → Skewer. The unsafe scripted combination without observed arrival was removed.
- Verify Skewer destinations from planned Blink positions. The reversed Reverse Polarity facet suppresses the pull-then-Skewer combination.
- Verify live spell and item range bonuses and Shard travel distance.

Focused verification
- Fengari magnataur_ability_spec passes five scenario groups; no game launched. The parent owns remaining integrated validation.

Full integration/build verification passed. Builds, skill/talent preferences and draft weights are unchanged. No game launched; engine-dependent claims remain lobby checks.

Final integrated verification: node tests/run-builds.cjs, node tests/run-objectives.cjs, node tests/valve_ability_check.cjs and git diff --check passed. Build/skill/talent preference AST comparison passed for all 49 scoped heroes. Native and applicable copied regressions are registered in run-builds. Framework callbacks and unsupported-spell dispatch preservation are covered. No game launched; the recorded lobby checklist remains required.
<!-- SECTION:NOTES:END -->

## Final Summary

<!-- SECTION:FINAL_SUMMARY:BEGIN -->
Magnus standard ability pass completed offline. Native and copied behavior reviewed against Torte, full Dotacoach Strategy/Counter Strategy/Matchup and pinned Valve KV/localization. Meaningful behavior fixes and positive/negative regressions implemented; builds and flags preserved. Final integrated verification: node tests/run-builds.cjs, node tests/run-objectives.cjs, node tests/valve_ability_check.cjs and git diff --check passed. Build/skill/talent preference AST comparison passed for all 49 scoped heroes. Native and applicable copied regressions are registered in run-builds. Framework callbacks and unsupported-spell dispatch preservation are covered. No game launched; the recorded lobby checklist remains required.
<!-- SECTION:FINAL_SUMMARY:END -->
