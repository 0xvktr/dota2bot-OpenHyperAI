---
id: TASK-13.64
title: 'Medusa: standard hero ability pass'
status: Needs In-Game Test
assignee:
  - '@codex'
created_date: '2026-10-02 09:09'
updated_date: '2026-10-02 10:40'
labels:
  - hero
dependencies: []
references:
  - bots/BotLib/hero_medusa.lua
  - tests/medusa_ability_spec.lua
documentation:
  - backlog/docs/doc-2 - Hero-improvement-playbook.md
modified_files:
  - bots/BotLib/hero_medusa.lua
  - bots/FunLib/rubick_hero/medusa.lua
  - tests/medusa_ability_spec.lua
parent_task_id: TASK-13
priority: medium
ordinal: 104000
---

## Description

<!-- SECTION:DESCRIPTION:BEGIN -->
Medusa is part of the requested Ember Spirit through Pugna hero-file-order batch. Review actual spell decisions against current mechanics and human usage, fixing meaningful ability-use gaps while retaining the established D2PT build.
<!-- SECTION:DESCRIPTION:END -->

## Acceptance Criteria
<!-- AC:BEGIN -->
- [x] #1 Ability decisions and cast order are reviewed against Torte de Lini, dotacoach Strategy/Counter Strategy/full Matchup and pinned Valve definitions/localization; verified checklist and stale claims are recorded
- [x] #2 Identified meaningful behavior gaps are fixed, including applicable Rubick handling, with positive and negative offline regression scenarios
- [x] #3 Focused hero scenarios, Valve ability check and full build suite pass; lobby checklist and engine limitations are recorded for Needs In-Game Test handoff
<!-- AC:END -->

## Implementation Plan

<!-- SECTION:PLAN:BEGIN -->
- Evaluate legal Snake chains and mana recovery, prioritize shield-aware Stone Gaze, predict delayed Grasp, and maintain Split Shot through its live silence and invisibility exceptions.
<!-- SECTION:PLAN:END -->

## Implementation Notes

<!-- SECTION:NOTES:BEGIN -->
Source review and offline implementation for the Ember Spirit → Pugna batch (hero-file order).

Sources: Torte CLI tools/tdl/fetch.cjs medusa; https://dotacoach.gg/en/heroes/medusa and https://dotacoach.gg/en/heroes/counters/medusa (full Strategy, Counter Strategy and Matchup); Valve d2vpkr cf0d37a32c8df338a7832fd32a282747969e9a5f hero definitions plus English ability localization.

Verified ability checklist
- Read the full native file, Torte guide 129403206, complete Dotacoach Strategy, Counter Strategy and Matchup pages, and pinned Valve data and localization.
- Verified Snake range 750, bounce radius 450, three to six recipients, damage 90–240, mana steal 15% of maximum mana and initial speed 800; Stone Gaze radius 1200, immunity-piercing facing requirement of two seconds, duration five to six seconds and movement bonus 50%; Grasp range 625, second-cursor delay one second plus volley interval 0.25 seconds, initial radius 150 plus growth 50, physical damage and root; Split Shot adds reach 150 and explicitly permits silence and invisibility, with current Scepter secondary attack effects.
- https://dotacoach.gg/en/heroes/medusa
- https://dotacoach.gg/en/heroes/counters/medusa

Implemented behavior
- Fix Snake returning nil for a direct hero target when no creep exists. Enforce actual first-target range and block or reflection checks, and score nearest unvisited recipients within 450 for useful mana and hero opportunities.
- Prioritize Stone Gaze during a committed threatened retreat before Snake. Use current mana when the actual native Mana Shield is trained, allow immunity-piercing Gaze, and require enemy facing inside its 1200 radius.
- Predict Grasp’s actual second volley and bound its center. Do not claim that root alone interrupts a channel.
- Maintain Split Shot before the ordinary gate only for its live silence and invisibility exceptions. Preserve every other forbidden state, queued action and channel restriction, with native and copied exports.
- Remove the incompatible older Split Shot decision to prevent oscillation, and remove the obsolete passive Mana Shield toggle.

Rejected or stale source claims
- Reject old Scepter Snake petrification and level 25 attack-modifier advice; the current Scepter affects Split Shot secondary attacks.
- Reject the claim that BKB prevents Stone Gaze and the ranged Empower cleave claim. Armor does not directly protect Mana Shield mana.
- Do not encode old Nyx Mana Burn or generic pure-damage claims from Matchup text.

Item follow-up observations for TASK-21
- TASK21: Mana replenishment supports native survival. Manta copies enabled Split Shot, and Scepter enables secondary effects. Use Gaze before Mask of Madness silence when needed, and use Pike to reposition against mana burn.

Enemy counterplay observations for TASK-24
- TASK24: Real mana burn threatens Medusa’s small health pool. Spread beyond Snake’s 450 bounce radius or block its first target. Turn away from Stone Gaze and disarm or kite Split Shot.

Lobby validation checklist
- Snake chain scoring estimates opportunities; engine bounce order and visibility do not guarantee lethal damage.
- Verify Split Shot through silence and invisibility before generic gates, and use Mana Shield assumptions only with its actual trained handle.
- Verify Grasp’s multiple-volley timing and runtime cursor placement; the estimate targets the second volley.

Focused verification
- Fengari medusa_ability_spec passed five groups, no game launched. The parent owns remaining integrated validation.

Framework integration
- Invoke native and copied UseSplitShot before ordinary silence and invisibility checks. The utility itself rejects all other forbidden states.

Full integration/build verification passed. Builds, skill/talent preferences and draft weights are unchanged. No game launched; engine-dependent claims remain lobby checks.

Final integrated verification: node tests/run-builds.cjs, node tests/run-objectives.cjs, node tests/valve_ability_check.cjs and git diff --check passed. Build/skill/talent preference AST comparison passed for all 49 scoped heroes. Native and applicable copied regressions are registered in run-builds. Framework callbacks and unsupported-spell dispatch preservation are covered. No game launched; the recorded lobby checklist remains required.
<!-- SECTION:NOTES:END -->

## Final Summary

<!-- SECTION:FINAL_SUMMARY:BEGIN -->
Medusa standard ability pass completed offline. Native and copied behavior reviewed against Torte, full Dotacoach Strategy/Counter Strategy/Matchup and pinned Valve KV/localization. Meaningful behavior fixes and positive/negative regressions implemented; builds and flags preserved. Final integrated verification: node tests/run-builds.cjs, node tests/run-objectives.cjs, node tests/valve_ability_check.cjs and git diff --check passed. Build/skill/talent preference AST comparison passed for all 49 scoped heroes. Native and applicable copied regressions are registered in run-builds. Framework callbacks and unsupported-spell dispatch preservation are covered. No game launched; the recorded lobby checklist remains required.
<!-- SECTION:FINAL_SUMMARY:END -->
