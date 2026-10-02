---
id: TASK-13.36
title: 'Lich: standard hero ability pass'
status: Needs In-Game Test
assignee:
  - '@codex'
created_date: '2026-10-02 08:53'
updated_date: '2026-10-02 10:40'
labels:
  - hero
dependencies: []
references:
  - bots/BotLib/hero_lich.lua
  - tests/lich_ability_spec.lua
documentation:
  - backlog/docs/doc-2 - Hero-improvement-playbook.md
modified_files:
  - bots/BotLib/hero_lich.lua
  - bots/FunLib/rubick_hero/lich.lua
  - tests/lich_ability_spec.lua
parent_task_id: TASK-13
priority: medium
ordinal: 76000
---

## Description

<!-- SECTION:DESCRIPTION:BEGIN -->
Lich is part of the requested Ember Spirit through Pugna hero-file-order batch. Review actual spell decisions against current mechanics and human usage, fixing meaningful ability-use gaps while retaining the established D2PT build.
<!-- SECTION:DESCRIPTION:END -->

## Acceptance Criteria
<!-- AC:BEGIN -->
- [x] #1 Ability decisions and cast order are reviewed against Torte de Lini, dotacoach Strategy/Counter Strategy/full Matchup and pinned Valve definitions/localization; verified checklist and stale claims are recorded
- [x] #2 Identified meaningful behavior gaps are fixed, including applicable Rubick handling, with positive and negative offline regression scenarios
- [x] #3 Focused hero scenarios, Valve ability check and full build suite pass; lobby checklist and engine limitations are recorded for Needs In-Game Test handoff
<!-- AC:END -->

## Implementation Plan

<!-- SECTION:PLAN:BEGIN -->
- Prioritize threatened ally Shield and interrupt Gaze.
- Fix actual Frost Blast damage/ranges/talent and Chain Frost bounce opportunity.
- Implement Scepter channel spell exception, Shard Spire and native Sacrifice.
- Mirror copied decisions and verify scenarios.
<!-- SECTION:PLAN:END -->

## Implementation Notes

<!-- SECTION:NOTES:BEGIN -->
Source review and offline implementation for the Ember Spirit → Pugna batch (hero-file order).

Sources: Torte CLI tools/tdl/fetch.cjs lich; https://dotacoach.gg/en/heroes/lich and https://dotacoach.gg/en/heroes/counters/lich (full Strategy, Counter Strategy and Matchup); Valve d2vpkr cf0d37a32c8df338a7832fd32a282747969e9a5f hero definitions plus English ability localization.

Verified ability checklist
- Read the complete native SkillsComplement and consideration functions, Torte guide 128882317, the full Dotacoach Strategy, Counter Strategy, and Matchup pages, and pinned Valve data and localization.
- Verified Frost Blast direct damage 40/80/120/160 plus area damage 80/120/160/200, with the level 10 talent adding 125 area damage; Frost Shield radius 600 and attack reduction 45–60%; Scepter Gaze point radius 400 and its spell-use exception; Chain Frost jump distance 550, initial speed 1050 and later speed 850; Sacrifice two charges with 120-second replenishment and health-to-mana conversion of 42% plus 3% per level; Ice Spire aura radius 550.
- Reviewed Shield on frontliners such as Axe, Magnus and Tidehunter, grouped control setups, and Grimstroke synergy without changing drafts.

Implemented behavior
- Prioritize Shield on an attacked ally or self before routine damage and avoid redundant refreshes.
- Use Gaze to interrupt channels at actual cast range, with entity targeting ordinarily and point targeting under Scepter.
- Correct Frost Blast damage and live talent handling, remove artificial range padding from dispatch, and fix precedence in the area-damage core condition.
- Evaluate native and copied Chain Frost using actual other enemy heroes, creeps, and real Ice Spires within 550 units.
- Use native Sacrifice on a healthy allied lane creep when mana is low, a charge is available, and combat is absent. Read the current Spire aura special value.
- Add focused copied decisions and guarded direct Shield or Chain casts during an actual Scepter Gaze channel.

Rejected or stale source claims
- Reject obsolete Frost Armor and Arcane Boots disassembly advice.
- Reject the old claim that Lich cannot gain mana from Clarities; the current innate is active Sacrifice.
- Reject the Matchup text that incorrectly assigns Oracle’s Fortune’s End and False Promise to Shadow Demon.
- Do not treat every ability as a reflected entity cast: Scepter Gaze and Ice Spire use point targeting.

Item follow-up observations for TASK-21
- TASK21: Glimmer, Force Staff and Solar Crest can complement Shield. Refresher requires mana for two Chain Frost casts. Blink can enter Gaze range safely, and Scepter allows items during Gaze.

Enemy counterplay observations for TASK-24
- TASK24: Spread beyond the 550 bounce distance, divert Chain Frost into creeps, dispel Shield, use immunity against control, and account for Sacrifice changing lane balance.

Lobby validation checklist
- Verify that direct Scepter casts preserve Gaze, copied Gaze uses the current Scepter shape, and real Ice Spires are visible to bounce evaluation.
- Verify Shield on heroes and buildings, initial Sacrifice charges and cooldowns, and Chain Frost’s lingering return-bounce behavior.

Focused verification
- Fengari tests/lich_ability_spec.lua: Lich ability scenarios passed; 7 native/copied positive-negative scenario groups.
- Root integrated Valve/build verification pending; no game started.

Framework integration
- Invoke UseDuringGaze before Rubick’s channel gate only for the observed, active Lich Gaze with Scepter. Native SkillsComplement handles the same exception.

Full integration/build verification passed. Builds, skill/talent preferences and draft weights are unchanged. No game launched; engine-dependent claims remain lobby checks.

Final integrated verification: node tests/run-builds.cjs, node tests/run-objectives.cjs, node tests/valve_ability_check.cjs and git diff --check passed. Build/skill/talent preference AST comparison passed for all 49 scoped heroes. Native and applicable copied regressions are registered in run-builds. Framework callbacks and unsupported-spell dispatch preservation are covered. No game launched; the recorded lobby checklist remains required.
<!-- SECTION:NOTES:END -->

## Final Summary

<!-- SECTION:FINAL_SUMMARY:BEGIN -->
Lich standard ability pass completed offline. Native and copied behavior reviewed against Torte, full Dotacoach Strategy/Counter Strategy/Matchup and pinned Valve KV/localization. Meaningful behavior fixes and positive/negative regressions implemented; builds and flags preserved. Final integrated verification: node tests/run-builds.cjs, node tests/run-objectives.cjs, node tests/valve_ability_check.cjs and git diff --check passed. Build/skill/talent preference AST comparison passed for all 49 scoped heroes. Native and applicable copied regressions are registered in run-builds. Framework callbacks and unsupported-spell dispatch preservation are covered. No game launched; the recorded lobby checklist remains required.
<!-- SECTION:FINAL_SUMMARY:END -->
