---
id: TASK-13.34
title: 'Leshrac: standard hero ability pass'
status: Needs In-Game Test
assignee:
  - '@codex'
created_date: '2026-10-02 08:49'
updated_date: '2026-10-02 10:40'
labels:
  - hero
dependencies: []
references:
  - bots/BotLib/hero_leshrac.lua
  - tests/leshrac_ability_spec.lua
documentation:
  - backlog/docs/doc-2 - Hero-improvement-playbook.md
modified_files:
  - bots/BotLib/hero_leshrac.lua
  - bots/FunLib/rubick_hero/leshrac.lua
  - tests/leshrac_ability_spec.lua
parent_task_id: TASK-13
priority: medium
ordinal: 74000
---

## Description

<!-- SECTION:DESCRIPTION:BEGIN -->
Leshrac is part of the requested Ember Spirit through Pugna hero-file-order batch. Review actual spell decisions against current mechanics and human usage, fixing meaningful ability-use gaps while retaining the established D2PT build.
<!-- SECTION:DESCRIPTION:END -->

## Acceptance Criteria
<!-- AC:BEGIN -->
- [x] #1 Ability decisions and cast order are reviewed against Torte de Lini, dotacoach Strategy/Counter Strategy/full Matchup and pinned Valve definitions/localization; verified checklist and stale claims are recorded
- [x] #2 Identified meaningful behavior gaps are fixed, including applicable Rubick handling, with positive and negative offline regression scenarios
- [x] #3 Focused hero scenarios, Valve ability check and full build suite pass; lobby checklist and engine limitations are recorded for Needs In-Game Test handoff
<!-- AC:END -->

## Implementation Plan

<!-- SECTION:PLAN:BEGIN -->
- Prioritize channel interrupts, keep Lightning setup, fix farm targets.
- Use pure Edict through immunity inside actual radius.
- Control Pulse Nova without activation-cost lock or low-mana cycling.
- Add offensive Nihilism, mirror stolen spells, verify scenarios.
<!-- SECTION:PLAN:END -->

## Implementation Notes

<!-- SECTION:NOTES:BEGIN -->
Source review and offline implementation for the Ember Spirit → Pugna batch (hero-file order).

Sources: Torte CLI tools/tdl/fetch.cjs leshrac; https://dotacoach.gg/en/heroes/leshrac and https://dotacoach.gg/en/heroes/counters/leshrac (full Strategy, Counter Strategy and Matchup); Valve d2vpkr cf0d37a32c8df338a7832fd32a282747969e9a5f hero definitions plus English ability localization.

Verified ability checklist
- Read every native consideration and SkillsComplement, Torte guide 319085962, and the full Dotacoach Strategy, Counter Strategy, and Matchup pages.
- Pinned Valve revision cf0d37a32c8df338a7832fd32a282747969e9a5f verifies Split Earth range 650, cast point 0.7 seconds and delay 0.35 seconds; pure, immunity-piercing Edict within radius 450; Lightning range 600, jump distance 450 and 75% slow; Pulse Nova radius 500 and mana drain 20/40/60; Nihilism radius 500, duration four seconds and 30% amplification.
- Reviewed allied stun and root setups and Io mana support for positioning. Drafting was not changed.

Implemented behavior
- Prioritize Split Earth channel interrupts over routine damage and use creep-centered farming locations.
- Correct Edict immunity handling and its actual tower reach.
- Keep Pulse Nova active for useful farming pairs, permit shutdown below activation mana, and use separate activation and shutdown thresholds.
- Use Nihilism offensively with active damage, apply advanced target checks to Lightning Storm, and pass actual abilities to item preparation.
- Copied decisions predict Split Earth and respect immunity, spell block, reflection, queues, and actual cast ranges.

Rejected or stale source claims
- Reject the Matchup claim of 20% damage reduction at level 20; the pinned data gives 10% at level 15.
- Reject obsolete Kaya-to-Bloodstone recipes, Arcane Boots disassembly, and mana-regeneration Bloodstone advice. Item recipes were not changed.
- Treat old Keeper of the Light facet references and the claim that Leshrac lacks hard control cautiously; Split Earth provides a stun.

Item follow-up observations for TASK-21
- TASK21: Blink and Eul can set up delayed Split Earth. BKB protects sustained damage, while Shiva and Force Staff help control positioning. Verify the current Bloodstone active separately.

Enemy counterplay observations for TASK-24
- TASK24: Dodge delayed Split Earth, leave Pulse Nova and Edict range, exploit low mana and healing reduction, and avoid isolated fights inside Edict.

Lobby validation checklist
- Verify Lightning slow into Split Earth at different levels, predictions near cast-range edges, and Edict against isolated towers versus towers surrounded by creeps.
- Verify Pulse Nova shutdown and restart thresholds, objective channel safety, and Nihilism physical immunity and offensive amplification.

Focused verification
- Fengari tests/leshrac_ability_spec.lua success marker: Leshrac ability scenarios passed.
- No live game launched. Root handles full integrated checks.

Framework integration
- Register the copied handler and invoke UsePulseNovaOff before generic readiness checks so an active toggle can be stopped below its activation cost.

Full integration/build verification passed. Builds, skill/talent preferences and draft weights are unchanged. No game launched; engine-dependent claims remain lobby checks.

Final integrated verification: node tests/run-builds.cjs, node tests/run-objectives.cjs, node tests/valve_ability_check.cjs and git diff --check passed. Build/skill/talent preference AST comparison passed for all 49 scoped heroes. Native and applicable copied regressions are registered in run-builds. Framework callbacks and unsupported-spell dispatch preservation are covered. No game launched; the recorded lobby checklist remains required.
<!-- SECTION:NOTES:END -->

## Final Summary

<!-- SECTION:FINAL_SUMMARY:BEGIN -->
Leshrac standard ability pass completed offline. Native and copied behavior reviewed against Torte, full Dotacoach Strategy/Counter Strategy/Matchup and pinned Valve KV/localization. Meaningful behavior fixes and positive/negative regressions implemented; builds and flags preserved. Final integrated verification: node tests/run-builds.cjs, node tests/run-objectives.cjs, node tests/valve_ability_check.cjs and git diff --check passed. Build/skill/talent preference AST comparison passed for all 49 scoped heroes. Native and applicable copied regressions are registered in run-builds. Framework callbacks and unsupported-spell dispatch preservation are covered. No game launched; the recorded lobby checklist remains required.
<!-- SECTION:FINAL_SUMMARY:END -->
