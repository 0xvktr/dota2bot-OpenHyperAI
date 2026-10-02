---
id: TASK-13.48
title: 'Gyrocopter: standard hero ability pass'
status: Needs In-Game Test
assignee:
  - '@codex'
created_date: '2026-10-02 09:08'
updated_date: '2026-10-02 10:40'
labels:
  - hero
dependencies: []
references:
  - bots/BotLib/hero_gyrocopter.lua
  - tests/gyrocopter_ability_spec.lua
documentation:
  - backlog/docs/doc-2 - Hero-improvement-playbook.md
modified_files:
  - bots/BotLib/hero_gyrocopter.lua
  - bots/FunLib/rubick_hero/gyrocopter.lua
  - tests/gyrocopter_ability_spec.lua
  - bots/FunLib/gyrocopter_abilities.lua
parent_task_id: TASK-13
priority: medium
ordinal: 88000
---

## Description

<!-- SECTION:DESCRIPTION:BEGIN -->
Gyrocopter is part of the requested Ember Spirit through Pugna hero-file-order batch. Review actual spell decisions against current mechanics and human usage, fixing meaningful ability-use gaps while retaining the established D2PT build.
<!-- SECTION:DESCRIPTION:END -->

## Acceptance Criteria
<!-- AC:BEGIN -->
- [x] #1 Ability decisions and cast order are reviewed against Torte de Lini, dotacoach Strategy/Counter Strategy/full Matchup and pinned Valve definitions/localization; verified checklist and stale claims are recorded
- [x] #2 Identified meaningful behavior gaps are fixed, including applicable Rubick handling, with positive and negative offline regression scenarios
- [x] #3 Focused hero scenarios, Valve ability check and full build suite pass; lobby checklist and engine limitations are recorded for Needs In-Game Test handoff
<!-- AC:END -->

## Implementation Plan

<!-- SECTION:PLAN:BEGIN -->
Range-safe physical Flak, isolated Barrage, delayed Missile setup and actual Call Down impact prediction.
<!-- SECTION:PLAN:END -->

## Implementation Notes

<!-- SECTION:NOTES:BEGIN -->
Source review and offline implementation for the Ember Spirit → Pugna batch (hero-file order).

Sources: Torte CLI tools/tdl/fetch.cjs gyrocopter; https://dotacoach.gg/en/heroes/gyrocopter and https://dotacoach.gg/en/heroes/counters/gyrocopter (full Strategy, Counter Strategy and Matchup); Valve d2vpkr cf0d37a32c8df338a7832fd32a282747969e9a5f hero definitions plus English ability localization.

Verified ability checklist
- Barrage: 400 radius, 10 rockets/s, 3 s, 8/14/20/26 magical damage; visible units only.
- Missile: 1050 range, 2.5 s pre-flight, 500 initial speed, 90/180/270/360 magical damage; attackable, immunity excluded. Shard fires current Barrage after 1 s within 700.
- Flak: physical immunity-piercing, 1250 secondary radius, 4/5/6/7 attacks over 12 s; primary range unchanged.
- Call Down: 1000 point range, 0.3 s cast point, 2 s first delay, 400 radius, three separated strikes 500 apart at 1 s spacing and 200/350/500 damage each.
- Scepter Side Gunner is a separate breakable passive: 700 range, 1.3 s interval. Afterburner is innate.

Implemented behavior
- Barrage checks actual proximity, excludes unseen/immune targets and divides its total output among units. Full lethal claim requires isolated disabled target. Preserved native farming/objective branches.
- Flak requires a valid nearby primary attack and actual secondary targets; respects disarm, live charges and ethereal/attack immunity while permitting debuff immune targets.
- Missile respects actual Lens/Supremacy range and block/reflection. Removed unsupported guaranteed kill and instant interruption assumptions for attackable delayed projectile.
- Call Down predicts the first impact at 2 s plus cast point and bounds the cast location. One-strike damage used, with useful single-target chase/follow-up.
- New native/copied shared companion does not assume Side Gunner, Afterburner or linked Barrage on copied Missile.

Rejected or stale source claims
- Torte claims Flak secondaries crit/proc Maelstrom; localization says only primary receives attack bonuses.
- Matchup claims Cold Embrace can be punished by Flak, BKB prevents Soulbind, or Break disables active Flak were rejected.
- Removed Chop Shop and unused hidden Lock On are not automated.

Item follow-up observations for TASK-21
- TASK-21: BKB/Satanic support actual primary attack uptime; offensive Flak cannot be justified by Side Gunner while disarmed.
- TASK-21: Force Staff on Homing Missile is a useful engine interaction for dedicated item work, not an assumed instant stun.

Enemy counterplay observations for TASK-24
- TASK-24: share Barrage with units, destroy delayed missiles, use physical armor/evasion against Flak and magic resistance against rockets.
- TASK-24: immunity and Lotus gate Missile; ethereal protects from Flak but is vulnerable to magical Barrage.

Lobby validation checklist
- Validate Call Down first-impact timing and three-strike path in engine.
- Validate copied Missile Shard when Barrage is absent, without assuming full linked spell damage.
- Validate primary hit-count objectives and secondary Flak behavior; no automatic close-range overextension.

Focused verification
- Native/copied Fengari suite passed; four files parsed as Lua 5.2.

Full integration/build verification passed. Builds, skill/talent preferences and draft weights are unchanged. No game launched; engine-dependent claims remain lobby checks.

Final integrated verification: node tests/run-builds.cjs, node tests/run-objectives.cjs, node tests/valve_ability_check.cjs and git diff --check passed. Build/skill/talent preference AST comparison passed for all 49 scoped heroes. Native and applicable copied regressions are registered in run-builds. Framework callbacks and unsupported-spell dispatch preservation are covered. No game launched; the recorded lobby checklist remains required.
<!-- SECTION:NOTES:END -->

## Final Summary

<!-- SECTION:FINAL_SUMMARY:BEGIN -->
Gyrocopter standard ability pass completed offline. Native and copied behavior reviewed against Torte, full Dotacoach Strategy/Counter Strategy/Matchup and pinned Valve KV/localization. Meaningful behavior fixes and positive/negative regressions implemented; builds and flags preserved. Final integrated verification: node tests/run-builds.cjs, node tests/run-objectives.cjs, node tests/valve_ability_check.cjs and git diff --check passed. Build/skill/talent preference AST comparison passed for all 49 scoped heroes. Native and applicable copied regressions are registered in run-builds. Framework callbacks and unsupported-spell dispatch preservation are covered. No game launched; the recorded lobby checklist remains required.
<!-- SECTION:FINAL_SUMMARY:END -->
