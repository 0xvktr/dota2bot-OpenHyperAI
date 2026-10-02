---
id: TASK-13.63
title: 'Mars: standard hero ability pass'
status: Needs In-Game Test
assignee:
  - '@codex'
created_date: '2026-10-02 09:09'
updated_date: '2026-10-02 10:40'
labels:
  - hero
dependencies: []
references:
  - bots/BotLib/hero_mars.lua
  - tests/mars_ability_spec.lua
documentation:
  - backlog/docs/doc-2 - Hero-improvement-playbook.md
modified_files:
  - bots/BotLib/hero_mars.lua
  - bots/FunLib/rubick_hero/mars.lua
  - tests/mars_ability_spec.lua
parent_task_id: TASK-13
priority: medium
ordinal: 103000
---

## Description

<!-- SECTION:DESCRIPTION:BEGIN -->
Mars is part of the requested Ember Spirit through Pugna hero-file-order batch. Review actual spell decisions against current mechanics and human usage, fixing meaningful ability-use gaps while retaining the established D2PT build.
<!-- SECTION:DESCRIPTION:END -->

## Acceptance Criteria
<!-- AC:BEGIN -->
- [x] #1 Ability decisions and cast order are reviewed against Torte de Lini, dotacoach Strategy/Counter Strategy/full Matchup and pinned Valve definitions/localization; verified checklist and stale claims are recorded
- [x] #2 Identified meaningful behavior gaps are fixed, including applicable Rubick handling, with positive and negative offline regression scenarios
- [x] #3 Focused hero scenarios, Valve ability check and full build suite pass; lobby checklist and engine limitations are recorded for Needs In-Game Test handoff
<!-- AC:END -->

## Implementation Plan

<!-- SECTION:PLAN:BEGIN -->
- Use current point-targeted Bulwark, prioritize Spear interrupts, and correct Arena centers, Rebuke damage and queued movement geometry.
<!-- SECTION:PLAN:END -->

## Implementation Notes

<!-- SECTION:NOTES:BEGIN -->
Source review and offline implementation for the Ember Spirit → Pugna batch (hero-file order).

Sources: Torte CLI tools/tdl/fetch.cjs mars; https://dotacoach.gg/en/heroes/mars and https://dotacoach.gg/en/heroes/counters/mars (full Strategy, Counter Strategy and Matchup); Valve d2vpkr cf0d37a32c8df338a7832fd32a282747969e9a5f hero definitions plus English ability localization.

Verified ability checklist
- Read the full native file, Torte guide 1674127743, complete Dotacoach Strategy, Counter Strategy and Matchup pages, and pinned Valve data and localization.
- Verified Spear travel 900–1200, speed 1400, damage 100–325 and width 125; Shard adds one target and a fire trail dealing 40 damage per second for ten seconds. Rebuke is a physical cone with radius 500, angle 140 degrees, critical multiplier 150–300% and hero bonus 5–20. Bulwark uses a point direction, redirects at range 900 with a 70% chance, protects nearby allies within 200 and applies an 18% movement penalty. Arena center range is 400, radius 550, duration 5.5 seconds plus Scepter one second, formation delay 0.1 seconds, and control does not pierce immunity.
- https://dotacoach.gg/en/heroes/mars
- https://dotacoach.gg/en/heroes/counters/mars

Implemented behavior
- Prioritize predicted Spear interruption before Blink, Arena or Rebuke. Lens does not extend its fixed projectile travel.
- Face ranged attackers with current point-targeted Bulwark when they threaten a nearby ally. Release it for attacks, retreat or absence of enemies, and remove obsolete Scepter soldier offense.
- Estimate Rebuke as physical damage with its actual hero bonus and reject disarmed casts. Keep farming recipients inside the real 500 radius.
- Clamp useful Arena centers to actual cast range and require valid nonimmune recipients. Use runtime duration instead of the old seven-second tree-pin estimate, and avoid a false active Arena from an initial zero timestamp.
- Use cast point plus 0.1 seconds for Blink → Spear positioning instead of dividing by cast point. Compute the endpoint from the future Blink position toward an ally within actual Spear travel.
- Provide focused copied decisions for all four active spells without assuming an innate, and prepare items using the actual Arena or Spear handle.
- Use GetSpecialValueFloat for fractional Arena formation timing, with a regression rejecting integer access.

Rejected or stale source claims
- Reject old Scepter Bulwark soldier mechanics; the current Arena reward gives 35% healing, mana and damage benefits.
- Resolve the one-versus-two Shard target discrepancy using Valve data: one original target plus one additional target.
- Reject old enemy Solar Crest casting and claims that Halberd’s disarm persists through BKB.

Item follow-up observations for TASK-21
- TASK21: BKB protects the combination. Eul setup needs actual arrival timing. Shard enables two-target pins and a fire trail. Refresher requires mana for Arena and Spear twice. Rebuke can interact with eligible attack and lifesteal effects, but a Basher proc is not guaranteed.

Enemy counterplay observations for TASK-24
- TASK24: Attack Mars from behind, use immunity against Arena and Spear control, cut pinning trees, use Break against passive damage block, and spread or cancel Blink initiation.

Lobby validation checklist
- Verify current point-targeted Bulwark activation, GetToggleState and facing semantics in the engine. No game was launched.
- Blink → Spear aims toward the allied side but does not guarantee a terrain pin. Verify Arena cast success tracking and actual pin terrain.

Focused verification
- Fengari mars_ability_spec passed four groups. The parent owns remaining integrated validation.
- Final owned-file audit passed: unknown spells defer, all 17 focused specifications pass, exact range helpers respect actual items and Break, and optional linked handles are guarded.

Full integration/build verification passed. Builds, skill/talent preferences and draft weights are unchanged. No game launched; engine-dependent claims remain lobby checks.

Final integrated verification: node tests/run-builds.cjs, node tests/run-objectives.cjs, node tests/valve_ability_check.cjs and git diff --check passed. Build/skill/talent preference AST comparison passed for all 49 scoped heroes. Native and applicable copied regressions are registered in run-builds. Framework callbacks and unsupported-spell dispatch preservation are covered. No game launched; the recorded lobby checklist remains required.
<!-- SECTION:NOTES:END -->

## Final Summary

<!-- SECTION:FINAL_SUMMARY:BEGIN -->
Mars standard ability pass completed offline. Native and copied behavior reviewed against Torte, full Dotacoach Strategy/Counter Strategy/Matchup and pinned Valve KV/localization. Meaningful behavior fixes and positive/negative regressions implemented; builds and flags preserved. Final integrated verification: node tests/run-builds.cjs, node tests/run-objectives.cjs, node tests/valve_ability_check.cjs and git diff --check passed. Build/skill/talent preference AST comparison passed for all 49 scoped heroes. Native and applicable copied regressions are registered in run-builds. Framework callbacks and unsupported-spell dispatch preservation are covered. No game launched; the recorded lobby checklist remains required.
<!-- SECTION:FINAL_SUMMARY:END -->
