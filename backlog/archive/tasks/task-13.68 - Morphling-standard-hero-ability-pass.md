---
id: TASK-13.68
title: 'Morphling: standard hero ability pass'
status: Needs In-Game Test
assignee:
  - '@codex'
created_date: '2026-10-02 09:09'
updated_date: '2026-10-02 10:40'
labels:
  - hero
  - weak-hero
milestone: m-0
dependencies: []
references:
  - bots/BotLib/hero_morphling.lua
  - tests/morphling_ability_spec.lua
documentation:
  - backlog/docs/doc-2 - Hero-improvement-playbook.md
modified_files:
  - bots/BotLib/hero_morphling.lua
  - bots/FunLib/rubick_hero/morphling.lua
  - tests/morphling_ability_spec.lua
parent_task_id: TASK-13
priority: medium
ordinal: 108000
---

## Description

<!-- SECTION:DESCRIPTION:BEGIN -->
Morphling is part of the requested Ember Spirit through Pugna hero-file-order batch. Review actual spell decisions against current mechanics and human usage, fixing meaningful ability-use gaps while retaining the established D2PT build.
<!-- SECTION:DESCRIPTION:END -->

## Acceptance Criteria
<!-- AC:BEGIN -->
- [x] #1 Ability decisions and cast order are reviewed against Torte de Lini, dotacoach Strategy/Counter Strategy/full Matchup and pinned Valve definitions/localization; verified checklist and stale claims are recorded
- [x] #2 Identified meaningful behavior gaps are fixed, including applicable Rubick handling, with positive and negative offline regression scenarios
- [x] #3 Focused hero scenarios, Valve ability check and full build suite pass; lobby checklist and engine limitations are recorded for Needs In-Game Test handoff
<!-- AC:END -->

## Implementation Plan

<!-- SECTION:PLAN:BEGIN -->
- Correct independent spell ranges, unified Strike control, emergency Strength Shift, and stale native form assumptions.
<!-- SECTION:PLAN:END -->

## Implementation Notes

<!-- SECTION:NOTES:BEGIN -->
Source review and offline implementation for the Ember Spirit → Pugna batch (hero-file order).

Sources: Torte CLI tools/tdl/fetch.cjs morphling; https://dotacoach.gg/en/heroes/morphling and https://dotacoach.gg/en/heroes/counters/morphling (full Strategy, Counter Strategy and Matchup); Valve d2vpkr cf0d37a32c8df338a7832fd32a282747969e9a5f hero definitions plus English ability localization.

Verified ability checklist
- Read the full native file, full Torte guide, full Strategy and Counter Strategy cards, complete Matchup page, pinned Valve KV and localization.
- https://dotacoach.gg/en/heroes/morphling
- https://dotacoach.gg/en/heroes/counters/morphling
- Waveform 700–925 travel plus actual range bonuses, speed 1250, width 200, magical damage 75–300 and root restrictions. Strike 600–825 range, speed 1150, base damage 50–110, minimum 0.5 agility and maximum 1–2.5 agility at the 1.5 stat threshold; unified stun remains available.
- Attribute Shift runtime castable_while_stunned is 0 ordinarily and 1 with Shard. Ebb and Flow strength-to-range is 25%. Current Scepter Morph alt-cast creates a strong illusion and swaps into it.

Implemented behavior
- Prioritize unified Adaptive Strike channel interruption before attribute shifting or Waveform. Retreat control works at every attribute ratio, maximum damage includes the exact threshold, and Tormentor returns its target.
- Use real Lens, trained Supremacy and observed Ebb and Flow range bonuses. Clamp all native Waveform dispatch locations; decline rooted or Ruptured movement.
- Emergency Strength Shift is guarded against occupied actions and forbidden states, with only actual runtime Shard stun bypass.
- Correct the Morph slot predicate and limit the native form handler loop to one handler invocation per tick. Decline unsupported Scepter alt-cast initiation.
- Remove obsolete Accumulation stat multiplication, use named stat talents, correct the agility threshold ratio and protect denominators.
- Copied Waveform and Adaptive Strike work without absent linked spells or passives.

Rejected or stale source claims
- Reject obsolete Accumulation bonuses, old separate Strength Strike assumptions, and legacy Scepter stat-steal advice.
- Intermediate Strike damage is conservatively estimated at its verified minimum; no unverified interpolation was invented.

Item follow-up observations for TASK-21
- TASK21: Manta or BKB can protect shifting; Shard enables emergency shifting while stunned; current Scepter strong-illusion lifecycle needs the separate Morph deep dive.

Enemy counterplay observations for TASK-24
- TASK24: Silence and hex prevent reactive shifting; chain stuns matter unless actual Shard permits shifting; vessel and anti-heal reduce recovery; defensive shields and spell block can stop Adaptive Strike.

Lobby validation checklist
- Verify actual range bonus reporting and queued Strength Shift under Shard stuns.
- The full copied-form dispatch and Scepter illusion lifecycle remain a separate deep dive; this standard pass corrects the loop predicate and action repetition only.

Focused verification
- Fengari morphling_ability_spec passed five behavioral groups. No game launched. Parent owns full suite integration.

Framework integration
- Native X.UseStrengthShift and copied UseStrengthShift must run before the generic stun gate; all other forbidden states remain guarded.

Full integration/build verification passed. Builds, skill/talent preferences and draft weights are unchanged. No game launched; engine-dependent claims remain lobby checks.

Final integrated verification: node tests/run-builds.cjs, node tests/run-objectives.cjs, node tests/valve_ability_check.cjs and git diff --check passed. Build/skill/talent preference AST comparison passed for all 49 scoped heroes. Native and applicable copied regressions are registered in run-builds. Framework callbacks and unsupported-spell dispatch preservation are covered. No game launched; the recorded lobby checklist remains required.
<!-- SECTION:NOTES:END -->

## Final Summary

<!-- SECTION:FINAL_SUMMARY:BEGIN -->
Morphling standard ability pass completed offline. Native and copied behavior reviewed against Torte, full Dotacoach Strategy/Counter Strategy/Matchup and pinned Valve KV/localization. Meaningful behavior fixes and positive/negative regressions implemented; builds and flags preserved. Final integrated verification: node tests/run-builds.cjs, node tests/run-objectives.cjs, node tests/valve_ability_check.cjs and git diff --check passed. Build/skill/talent preference AST comparison passed for all 49 scoped heroes. Native and applicable copied regressions are registered in run-builds. Framework callbacks and unsupported-spell dispatch preservation are covered. No game launched; the recorded lobby checklist remains required.
<!-- SECTION:FINAL_SUMMARY:END -->
