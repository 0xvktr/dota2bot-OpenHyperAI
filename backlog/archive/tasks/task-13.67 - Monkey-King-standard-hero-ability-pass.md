---
id: TASK-13.67
title: 'Monkey King: standard hero ability pass'
status: Needs In-Game Test
assignee:
  - '@codex'
created_date: '2026-10-02 09:09'
updated_date: '2026-10-02 10:40'
labels:
  - hero
dependencies: []
references:
  - bots/BotLib/hero_monkey_king.lua
  - tests/monkey_king_ability_spec.lua
documentation:
  - backlog/docs/doc-2 - Hero-improvement-playbook.md
modified_files:
  - bots/BotLib/hero_monkey_king.lua
  - bots/FunLib/rubick_hero/monkey_king.lua
  - tests/monkey_king_ability_spec.lua
parent_task_id: TASK-13
priority: medium
ordinal: 107000
---

## Description

<!-- SECTION:DESCRIPTION:BEGIN -->
Monkey King is part of the requested Ember Spirit through Pugna hero-file-order batch. Review actual spell decisions against current mechanics and human usage, fixing meaningful ability-use gaps while retaining the established D2PT build.
<!-- SECTION:DESCRIPTION:END -->

## Acceptance Criteria
<!-- AC:BEGIN -->
- [x] #1 Ability decisions and cast order are reviewed against Torte de Lini, dotacoach Strategy/Counter Strategy/full Matchup and pinned Valve definitions/localization; verified checklist and stale claims are recorded
- [x] #2 Identified meaningful behavior gaps are fixed, including applicable Rubick handling, with positive and negative offline regression scenarios
- [x] #3 Focused hero scenarios, Valve ability check and full build suite pass; lobby checklist and engine limitations are recorded for Needs In-Game Test handoff
<!-- AC:END -->

## Implementation Plan

<!-- SECTION:PLAN:BEGIN -->
- Improve physical Boundless Strike, committed Wukong formations, defensive Changing of the Guard, and observed Mischief projectile timing.
<!-- SECTION:PLAN:END -->

## Implementation Notes

<!-- SECTION:NOTES:BEGIN -->
Source review and offline implementation for the Ember Spirit → Pugna batch (hero-file order).

Sources: Torte CLI tools/tdl/fetch.cjs monkey_king; https://dotacoach.gg/en/heroes/monkey-king and https://dotacoach.gg/en/heroes/counters/monkey-king (full Strategy, Counter Strategy and Matchup); Valve d2vpkr cf0d37a32c8df338a7832fd32a282747969e9a5f hero definitions plus English ability localization.

Verified ability checklist
- Read the complete native file, Torte guide 817387228, full Strategy and Counter Strategy cards, full Matchup page, pinned Valve KV, and localization.
- https://dotacoach.gg/en/heroes/monkey-king
- https://dotacoach.gg/en/heroes/counters/monkey-king
- Verified Strike 1100 travel, physical critical damage and flat damage; Tree Dance and Spring root restrictions; Wukong 625 cast distance and 750 outer radius; Changing of the Guard point behavior; Mischief 0.1 second damage immunity.

Implemented behavior
- Prioritize channel interruption with Boundless Strike before the lengthy Wukong formation, correct physical damage estimates, and respect actual travel bounds.
- Use Wukong on committed disabled targets or real clusters while keeping the bot inside the ring. Copied abilities do not assume Jingu Mastery.
- Use Changing of the Guard for imminent projectiles or recent damage at low health only with the live ring modifier, recorded ring center, and trained linked Wukong ability.
- Prevent Tree Dance and Spring from cancelling the active ring and enforce roots and actual dispatch ranges.
- Estimate closing projectile velocity across observed frames for the brief Mischief damage window, and cast immediately without prematurely forcing Revert.
- Decline copied Tree Dance and Spring until linked perch availability is verified.

Rejected or stale source claims
- Mischief damage immunity does not prevent debuffs; a fixed 600 distance is not a guaranteed stun dodge.
- Copied spells cannot assume Jingu Mastery.
- Reject obsolete enemy Solar Crest and Nullifier passive claims.

Item follow-up observations for TASK-21
- TASK21: BKB protects formation and attacks; Skadi and Diffusal help keep targets inside the ring; verify current soldier item inheritance before implementing item policy.

Enemy counterplay observations for TASK-24
- TASK24: Force Monkey King outside Wukong; magic and pure damage bypass its armor; cut perched trees; distinguish blocked new Jingu charges under Break from existing buffs.

Lobby validation checklist
- Guard requires the actual ring modifier after a queued formation.
- Verify nearest valid Wukong soldier selection and exclusion of Scepter soldiers.
- Mischief estimates projectile velocity per source and only protects a brief damage window.
- Copied perch availability and Shard Strike movement remain live checks.

Focused verification
- Fengari monkey_king_ability_spec passed four behavioral groups. No game launched. Parent owns full suite integration.

Full integration/build verification passed. Builds, skill/talent preferences and draft weights are unchanged. No game launched; engine-dependent claims remain lobby checks.

Final integrated verification: node tests/run-builds.cjs, node tests/run-objectives.cjs, node tests/valve_ability_check.cjs and git diff --check passed. Build/skill/talent preference AST comparison passed for all 49 scoped heroes. Native and applicable copied regressions are registered in run-builds. Framework callbacks and unsupported-spell dispatch preservation are covered. No game launched; the recorded lobby checklist remains required.
<!-- SECTION:NOTES:END -->

## Final Summary

<!-- SECTION:FINAL_SUMMARY:BEGIN -->
Monkey King standard ability pass completed offline. Native and copied behavior reviewed against Torte, full Dotacoach Strategy/Counter Strategy/Matchup and pinned Valve KV/localization. Meaningful behavior fixes and positive/negative regressions implemented; builds and flags preserved. Final integrated verification: node tests/run-builds.cjs, node tests/run-objectives.cjs, node tests/valve_ability_check.cjs and git diff --check passed. Build/skill/talent preference AST comparison passed for all 49 scoped heroes. Native and applicable copied regressions are registered in run-builds. Framework callbacks and unsupported-spell dispatch preservation are covered. No game launched; the recorded lobby checklist remains required.
<!-- SECTION:FINAL_SUMMARY:END -->
