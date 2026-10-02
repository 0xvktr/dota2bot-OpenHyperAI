---
id: TASK-13.80
title: 'Pudge: standard hero ability pass'
status: Needs In-Game Test
assignee:
  - '@codex'
created_date: '2026-10-02 09:10'
updated_date: '2026-10-02 10:40'
labels:
  - hero
dependencies: []
references:
  - bots/BotLib/hero_pudge.lua
  - tests/pudge_ability_spec.lua
documentation:
  - backlog/docs/doc-2 - Hero-improvement-playbook.md
modified_files:
  - bots/BotLib/hero_pudge.lua
  - bots/FunLib/rubick_hero/pudge.lua
  - tests/pudge_ability_spec.lua
parent_task_id: TASK-13
priority: medium
ordinal: 120000
---

## Description

<!-- SECTION:DESCRIPTION:BEGIN -->
Pudge is part of the requested Ember Spirit through Pugna hero-file-order batch. Review actual spell decisions against current mechanics and human usage, fixing meaningful ability-use gaps while retaining the established D2PT build.
<!-- SECTION:DESCRIPTION:END -->

## Acceptance Criteria
<!-- AC:BEGIN -->
- [x] #1 Ability decisions and cast order are reviewed against Torte de Lini, dotacoach Strategy/Counter Strategy/full Matchup and pinned Valve definitions/localization; verified checklist and stale claims are recorded
- [x] #2 Identified meaningful behavior gaps are fixed, including applicable Rubick handling, with positive and negative offline regression scenarios
- [x] #3 Focused hero scenarios, Valve ability check and full build suite pass; lobby checklist and engine limitations are recorded for Needs In-Game Test handoff
<!-- AC:END -->

## Implementation Plan

<!-- SECTION:PLAN:BEGIN -->
- Predict Hook targets and blockers with actual range and travel time; prioritize urgent ally rescues.
- Keep Rot active for useful farm or nearby vulnerable enemies, and stop it when no useful target remains or health becomes low.
- Use current Meat Shield and Strength-based Dismember mechanics, with a precise support callback during the observed Dismember channel.
- Mirror the four current stolen abilities without assuming missing sibling spells or legacy ally swallowing.
<!-- SECTION:PLAN:END -->

## Implementation Notes

<!-- SECTION:NOTES:BEGIN -->
Source review and offline implementation for the Ember Spirit → Pugna batch (hero-file order).

Sources: Torte CLI tools/tdl/fetch.cjs pudge; https://dotacoach.gg/en/heroes/pudge and https://dotacoach.gg/en/heroes/counters/pudge (full Strategy, Counter Strategy and Matchup); Valve d2vpkr cf0d37a32c8df338a7832fd32a282747969e9a5f hero definitions plus English ability localization.

Verified ability checklist
- Read TDL guide 128906539 and full dotacoach Strategy, Counter Strategy and Matchup sections: https://dotacoach.gg/en/heroes/pudge and https://dotacoach.gg/en/heroes/counters/pudge.
- Verified Valve Hook cast range 1300, speed 1600, width 100, cast point 0.3, pure damage 150/220/290/360, non-ancient creep instant kill, debuff immunity piercing, and pass-through for buildings, wards, ancient creeps and Roshan.
- Verified Rot magical damage does not pierce immunity, radius 250 with Scepter upgrade, nonlethal self damage, silence preventing toggle-off, and IGNORE_CHANNEL behavior.
- Verified Meat Shield blocks damage per instance, lasts 4/5/6/7 seconds, and supports IGNORE_CHANNEL; it is not a passive regeneration spell.
- Verified Dismember cast range 200, cast point 0.3, magical DPS 80/100/120 plus Strength times 0.3/0.6/0.9, piercing control, channel ticks and self healing. Kill estimates use one half-second tick, not an uninterrupted full channel.
- Verified current Shard improves Hook. Legacy allied swallowing/Eject behavior is not assumed from stale source suggestions.
- Read the entire native SkillsComplement and every consideration function. Native and copied decisions preserve actual Lens and unbroken Arcane Supremacy range.

Implemented behavior
- Added predicted line blockers and actual-range Hook casts, with urgent Chronosphere/Black Hole ally saves before offense.
- Removed HP thresholds from distant non-ancient creep Hook kills, while preserving mana permission.
- Stopped Rot farm oscillation and added low-health, empty-area and immunity toggle-off decisions.
- Added meaningful Meat Shield decisions for Rot damage, recent hero damage and incoming attacks.
- Reworked Dismember interrupts, close combat and safe neutral healing using current Strength scaling and actual cast range.
- Added native ConsiderDismemberSupport and copied ConsiderStolenDismemberSupport callbacks. They require an actual Dismember channel and active ability, retain other action locks, and permit only Rot or Meat Shield during that channel.
- Added copied handlers for all four current actives, preserving unknown-spell dispatch and independent stolen spells.

Rejected or stale source claims
- No guaranteed full Dismember kill or heal is claimed.
- Rejected legacy Shard ally-swallow assumptions and source advice tied to deprecated facets.

Item follow-up observations for TASK-21
- TASK-21: Assess Scepter Rot amplification and anti-heal opportunity, Shard Hook value, and Blink/BKB/Aether Lens positioning policy in a separate item pass. Standard pass uses actual owned range items and preserves generic item policy.

Enemy counterplay observations for TASK-24
- TASK-24: Track Hook body blockers, vision and high-mobility dodges; magic resistance against Rot and Dismember damage; interrupt and displacement risks during Dismember; Blade Mail and Spiked Carapace reflection.

Lobby validation checklist
- Validate first-unit Hook collision and moving blocker prediction in an actual lobby.
- Validate Rot and Meat Shield IGNORE_CHANNEL casts preserve Dismember, and current toggle-off restrictions under silence.
- Validate the current Shard Hook behavior and ensure no legacy ally swallowing is expected.
- No game or deep-dive validation was performed.

Focused verification
- Fengari tests/pudge_ability_spec.lua passed: range, immunity, blockers, urgent save priority, creep instant kills, farm toggle state, low health, neutral healing, channel support locks, unknown dispatch and independent stolen spell cases. Hidden, deactivated and null Rot handles are rejected while cooldown toggle-off remains allowed; null linked Rot does not prevent independent Meat Shield.

Full integration/build verification passed. Builds, skill/talent preferences and draft weights are unchanged. No game launched; engine-dependent claims remain lobby checks.

Final integrated verification: node tests/run-builds.cjs, node tests/run-objectives.cjs, node tests/valve_ability_check.cjs and git diff --check passed. Build/skill/talent preference AST comparison passed for all 49 scoped heroes. Native and applicable copied regressions are registered in run-builds. Framework callbacks and unsupported-spell dispatch preservation are covered. No game launched; the recorded lobby checklist remains required.
<!-- SECTION:NOTES:END -->

## Final Summary

<!-- SECTION:FINAL_SUMMARY:BEGIN -->
Pudge standard ability pass completed offline. Native and copied behavior reviewed against Torte, full Dotacoach Strategy/Counter Strategy/Matchup and pinned Valve KV/localization. Meaningful behavior fixes and positive/negative regressions implemented; builds and flags preserved. Final integrated verification: node tests/run-builds.cjs, node tests/run-objectives.cjs, node tests/valve_ability_check.cjs and git diff --check passed. Build/skill/talent preference AST comparison passed for all 49 scoped heroes. Native and applicable copied regressions are registered in run-builds. Framework callbacks and unsupported-spell dispatch preservation are covered. No game launched; the recorded lobby checklist remains required.
<!-- SECTION:FINAL_SUMMARY:END -->
