---
id: TASK-13.39
title: 'Lifestealer: standard hero ability pass'
status: Needs In-Game Test
assignee:
  - '@codex'
created_date: '2026-10-02 08:59'
updated_date: '2026-10-02 10:40'
labels:
  - hero
dependencies: []
references:
  - bots/BotLib/hero_life_stealer.lua
  - tests/life_stealer_ability_spec.lua
documentation:
  - backlog/docs/doc-2 - Hero-improvement-playbook.md
modified_files:
  - bots/BotLib/hero_life_stealer.lua
  - bots/FunLib/rubick_hero/life_stealer.lua
  - tests/life_stealer_ability_spec.lua
parent_task_id: TASK-13
priority: medium
ordinal: 79000
---

## Description

<!-- SECTION:DESCRIPTION:BEGIN -->
Lifestealer is part of the requested Ember Spirit through Pugna hero-file-order batch. Review actual spell decisions against current mechanics and human usage, fixing meaningful ability-use gaps while retaining the established D2PT build.
<!-- SECTION:DESCRIPTION:END -->

## Acceptance Criteria
<!-- AC:BEGIN -->
- [x] #1 Ability decisions and cast order are reviewed against Torte de Lini, dotacoach Strategy/Counter Strategy/full Matchup and pinned Valve definitions/localization; verified checklist and stale claims are recorded
- [x] #2 Identified meaningful behavior gaps are fixed, including applicable Rubick handling, with positive and negative offline regression scenarios
- [x] #3 Focused hero scenarios, Valve ability check and full build suite pass; lobby checklist and engine limitations are recorded for Needs In-Game Test handoff
<!-- AC:END -->

## Implementation Plan

<!-- SECTION:PLAN:BEGIN -->
- Enable safe Infest saves and Scepter enemy sustain with actual ranges.
- Track host and time Consume correctly.
- Anticipate stun projectiles; sustain with Open Wounds on disabled attacked targets.
- Mirror copied handles safely and add regression scenarios.
<!-- SECTION:PLAN:END -->

## Implementation Notes

<!-- SECTION:NOTES:BEGIN -->
Source review and offline implementation for the Ember Spirit → Pugna batch (hero-file order).

Sources: Torte CLI tools/tdl/fetch.cjs life_stealer; https://dotacoach.gg/en/heroes/lifestealer and https://dotacoach.gg/en/heroes/counters/lifestealer (full Strategy, Counter Strategy and Matchup); Valve d2vpkr cf0d37a32c8df338a7832fd32a282747969e9a5f hero definitions plus English ability localization.

Verified ability checklist
- Read all native consideration functions, SkillsComplement and MinionThink, Torte guide 232367327, full Dotacoach Strategy, Counter Strategy and Matchup pages, and pinned Valve data and localization.
- Verified Rage gives 80% magic resistance and debuff immunity for three to six seconds; Open Wounds has range 300–600, duration seven seconds and 20–50% lifesteal; Infest has base range 150 plus 250 under Scepter, a four-second enemy-host duration and doubled self regeneration; its burst radius is 700 with 150/275/400 magical damage. Shard applies damage over time equal to 30% of consumed creep remaining health over three seconds.
- Reviewed allied carriers such as Axe, Batrider, Slardar, Spirit Breaker and Storm Spirit, including bonus-health saves.

Implemented behavior
- Re-enable Infest for critically threatened allied heroes, nearby retreat hosts, and low-health Scepter recovery inside enemy heroes, including immune hosts.
- Track the actual host for burst positioning and require a linked Consume handle when Infest is copied. Do not prematurely cancel enemy-host attacks.
- Use Rage against an approaching stun projectile before the initial damage lands.
- Respect actual Open Wounds range, skip its existing modifier, and support healing against the enemy currently being attacked even when it is disabled.
- Use the actual 700 Infest burst radius for minion Consume evaluation instead of 1200.
- Use spell-aware item preparation and focused copied decisions. Retain a pending host across the queued cast until entry is observed or the request expires.

Rejected or stale source claims
- Reject the old Shard claim that an Infest burst applies Open Wounds; the current upgrade adds Gorestorm from consuming a creep.
- Reject the old Ghoul Frenzy attack-slow claim; current passive movement and attack speed are handled by the engine.
- Reject the Matchup reference to Faceless Void using Time Lapse.
- Do not copy Nullifier passive-Break claims or obsolete talent and item statistics.

Item follow-up observations for TASK-21
- TASK21: Rage can protect a teleport only when enemies lack piercing interruption. Phase helps sustain attacks; Armlet needs careful management inside Infest. Nullifier removes eligible defensive buffs, and Manta can remove silence before Rage.

Enemy counterplay observations for TASK-24
- TASK24: Kite Rage and disable afterward. Piercing control such as Lasso, Fiend’s Grip and Black Hole still matters. Use armor and healing reduction, and account for allied Infest carriers and Scepter enemy hosts.

Lobby validation checklist
- Verify Infest bonus-health saves, actual base and Scepter ranges, immune enemy targeting, and the four-second automatic exit.
- Verify host identity and position, controlled-creep versus native Consume, Shard damage over time, and Rage reactions to approaching projectiles.

Focused verification
- Fengari tests/life_stealer_ability_spec.lua success: Lifestealer ability scenarios passed (6 scenario groups).
- No game launched; root integration checks pending.

Framework integration
- Invoke UseConsume before the invulnerability gate only with the actual Infest modifier, linked handles and a tracked live host. Preserve all channel, cast and queue restrictions.

Full integration/build verification passed. Builds, skill/talent preferences and draft weights are unchanged. No game launched; engine-dependent claims remain lobby checks.

Final integrated verification: node tests/run-builds.cjs, node tests/run-objectives.cjs, node tests/valve_ability_check.cjs and git diff --check passed. Build/skill/talent preference AST comparison passed for all 49 scoped heroes. Native and applicable copied regressions are registered in run-builds. Framework callbacks and unsupported-spell dispatch preservation are covered. No game launched; the recorded lobby checklist remains required.
<!-- SECTION:NOTES:END -->

## Final Summary

<!-- SECTION:FINAL_SUMMARY:BEGIN -->
Lifestealer standard ability pass completed offline. Native and copied behavior reviewed against Torte, full Dotacoach Strategy/Counter Strategy/Matchup and pinned Valve KV/localization. Meaningful behavior fixes and positive/negative regressions implemented; builds and flags preserved. Final integrated verification: node tests/run-builds.cjs, node tests/run-objectives.cjs, node tests/valve_ability_check.cjs and git diff --check passed. Build/skill/talent preference AST comparison passed for all 49 scoped heroes. Native and applicable copied regressions are registered in run-builds. Framework callbacks and unsupported-spell dispatch preservation are covered. No game launched; the recorded lobby checklist remains required.
<!-- SECTION:FINAL_SUMMARY:END -->
