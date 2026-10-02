---
id: TASK-13.60
title: 'Lycan: standard hero ability pass'
status: Needs In-Game Test
assignee:
  - '@codex'
created_date: '2026-10-02 09:09'
updated_date: '2026-10-02 10:40'
labels:
  - hero
dependencies: []
references:
  - bots/BotLib/hero_lycan.lua
  - tests/lycan_ability_spec.lua
documentation:
  - backlog/docs/doc-2 - Hero-improvement-playbook.md
modified_files:
  - bots/BotLib/hero_lycan.lua
  - bots/FunLib/rubick_hero/lycan.lua
  - tests/lycan_ability_spec.lua
parent_task_id: TASK-13
priority: medium
ordinal: 100000
---

## Description

<!-- SECTION:DESCRIPTION:BEGIN -->
Lycan is part of the requested Ember Spirit through Pugna hero-file-order batch. Review actual spell decisions against current mechanics and human usage, fixing meaningful ability-use gaps while retaining the established D2PT build.
<!-- SECTION:DESCRIPTION:END -->

## Acceptance Criteria
<!-- AC:BEGIN -->
- [x] #1 Ability decisions and cast order are reviewed against Torte de Lini, dotacoach Strategy/Counter Strategy/full Matchup and pinned Valve definitions/localization; verified checklist and stale claims are recorded
- [x] #2 Identified meaningful behavior gaps are fixed, including applicable Rubick handling, with positive and negative offline regression scenarios
- [x] #3 Focused hero scenarios, Valve ability check and full build suite pass; lobby checklist and engine limitations are recorded for Needs In-Game Test handoff
<!-- AC:END -->

## Implementation Plan

<!-- SECTION:PLAN:BEGIN -->
- Count owned wolves, evaluate Howl from real origins and actual night, improve Shapeshift retreat timing, and use Wolf Bite and Hightail safely.
<!-- SECTION:PLAN:END -->

## Implementation Notes

<!-- SECTION:NOTES:BEGIN -->
Source review and offline implementation for the Ember Spirit → Pugna batch (hero-file order).

Sources: Torte CLI tools/tdl/fetch.cjs lycan; https://dotacoach.gg/en/heroes/lycan and https://dotacoach.gg/en/heroes/counters/lycan (full Strategy, Counter Strategy and Matchup); Valve d2vpkr cf0d37a32c8df338a7832fd32a282747969e9a5f hero definitions plus English ability localization.

Verified ability checklist
- Read the full native file, Torte guides 128917369 and 286891439, complete Dotacoach Strategy, Counter Strategy and Matchup pages, and pinned Valve data and localization.
- Verified two summoned wolves plus one with Shard, replacing the current 50-second pack; Howl reaches 2000 from Lycan or wolves and is global at night, lasts eight seconds and does not pierce immunity; Shapeshift gives speed 550 after a 1.1-second transformation for 25 seconds and changes ranged attacks to melee; Wolf Bite range 300 and shared lifesteal 40% within 1200; Hightail lasts six seconds with 100% evasion, speed 550 and 20 attack speed.
- https://dotacoach.gg/en/heroes/lycan
- https://dotacoach.gg/en/heroes/counters/lycan

Implemented behavior
- Count the caster’s actual wolves rather than reject summons because any wolf exists globally. Require a meaningful creep or building target instead of casting on empty waves.
- Evaluate Howl from its actual 2000 radius and owned wolf origins. At night, evaluate a remote ally’s attack using that ally’s range. Skip immune enemies and existing debuffs.
- Use Shapeshift early against a chasing enemy during retreat, reject roots and an existing transformation, and conservatively decline copied offensive use on ranged casters.
- Use Wolf Bite on a reachable active melee ally. Avoid reducing a ranged ally’s attack range and require the actual linked Shapeshift handle.
- Use Shard Hightail on owned wolves in combat or under threat at low health, preserving generic minion behavior when no special action occurs.
- Pass the actual ability to item preparation.
- Use engine GetTimeOfDay so Howl respects artificial night. Route copied wolf Hightail before generic minion orders.

Rejected or stale source claims
- Reject old Shard automatic lane-wolf advice; the current upgrade adds a wolf and active Hightail.
- Reject Nullifier passive-Break claims. Passive and draft setup were not changed.
- Reject the claim that Shapeshift bypasses Overgrowth’s root.

Item follow-up observations for TASK-21
- TASK21: A suitable Overlord neutral can interrupt teleports. Shard wolves need actual Hightail activation. BKB protects against eligible stuns during Shapeshift, Nullifier removes escape buffs, and Wolf Bite benefits an active melee teammate.

Enemy counterplay observations for TASK-24
- TASK24: Armor and Crimson Guard reduce army damage. Kill vulnerable wolves and defend tower timings. Roots, hard control and Rupture still threaten a hasted Lycan.

Lobby validation checklist
- Verify wolf owner IDs and the live wolf_count value with Shard; replacing a partial pack also removes its remaining wolves.
- Verify Howl on buildings and from owned wolves, interruption during Shapeshift’s 1.1-second transformation, and copied Wolf Bite when its linked Shapeshift is absent.

Focused verification
- Fengari tests/lycan_ability_spec.lua passed five groups. No lobby launched. The parent owns remaining integrated validation.
- Added wrong-owner, non-wolf, queued/channel negatives; artificial-night global case passes despite daytime clock.

Full integration/build verification passed. Builds, skill/talent preferences and draft weights are unchanged. No game launched; engine-dependent claims remain lobby checks.

Final integrated verification: node tests/run-builds.cjs, node tests/run-objectives.cjs, node tests/valve_ability_check.cjs and git diff --check passed. Build/skill/talent preference AST comparison passed for all 49 scoped heroes. Native and applicable copied regressions are registered in run-builds. Framework callbacks and unsupported-spell dispatch preservation are covered. No game launched; the recorded lobby checklist remains required.
<!-- SECTION:NOTES:END -->

## Final Summary

<!-- SECTION:FINAL_SUMMARY:BEGIN -->
Lycan standard ability pass completed offline. Native and copied behavior reviewed against Torte, full Dotacoach Strategy/Counter Strategy/Matchup and pinned Valve KV/localization. Meaningful behavior fixes and positive/negative regressions implemented; builds and flags preserved. Final integrated verification: node tests/run-builds.cjs, node tests/run-objectives.cjs, node tests/valve_ability_check.cjs and git diff --check passed. Build/skill/talent preference AST comparison passed for all 49 scoped heroes. Native and applicable copied regressions are registered in run-builds. Framework callbacks and unsupported-spell dispatch preservation are covered. No game launched; the recorded lobby checklist remains required.
<!-- SECTION:FINAL_SUMMARY:END -->
