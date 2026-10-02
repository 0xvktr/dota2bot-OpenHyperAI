---
id: TASK-13.37
title: 'Necrophos: standard hero ability pass'
status: Needs In-Game Test
assignee:
  - '@codex'
created_date: '2026-10-02 08:53'
updated_date: '2026-10-02 10:40'
labels:
  - hero
dependencies: []
references:
  - bots/BotLib/hero_necrolyte.lua
  - tests/necrolyte_ability_spec.lua
documentation:
  - backlog/docs/doc-2 - Hero-improvement-playbook.md
modified_files:
  - bots/BotLib/hero_necrolyte.lua
  - bots/FunLib/rubick_hero/necrolyte.lua
  - tests/necrolyte_ability_spec.lua
parent_task_id: TASK-13
priority: medium
ordinal: 77000
---

## Description

<!-- SECTION:DESCRIPTION:BEGIN -->
Necrophos is part of the requested Ember Spirit through Pugna hero-file-order batch. Review actual spell decisions against current mechanics and human usage, fixing meaningful ability-use gaps while retaining the established D2PT build.
<!-- SECTION:DESCRIPTION:END -->

## Acceptance Criteria
<!-- AC:BEGIN -->
- [x] #1 Ability decisions and cast order are reviewed against Torte de Lini, dotacoach Strategy/Counter Strategy/full Matchup and pinned Valve definitions/localization; verified checklist and stale claims are recorded
- [x] #2 Identified meaningful behavior gaps are fixed, including applicable Rubick handling, with positive and negative offline regression scenarios
- [x] #3 Focused hero scenarios, Valve ability check and full build suite pass; lobby checklist and engine limitations are recorded for Needs In-Game Test handoff
<!-- AC:END -->

## Implementation Plan

<!-- SECTION:PLAN:BEGIN -->
Use verified missing-health Scythe with feasible Pulse; improve Ghost physical/healing safety, meaningful single-target Pulse healing and root-safe allied Death Seeker escapes; mirror stolen spells without passive assumptions.
<!-- SECTION:PLAN:END -->

## Implementation Notes

<!-- SECTION:NOTES:BEGIN -->
Source review and offline implementation for the Ember Spirit → Pugna batch (hero-file order).

Sources: Torte CLI tools/tdl/fetch.cjs necrolyte; https://dotacoach.gg/en/heroes/necrophos and https://dotacoach.gg/en/heroes/counters/necrophos (full Strategy, Counter Strategy and Matchup); Valve d2vpkr cf0d37a32c8df338a7832fd32a282747969e9a5f hero definitions plus English ability localization.

Verified ability checklist
- TDL guide 129193377; full Strategy/Counter and Matchup: https://dotacoach.gg/en/heroes/necrophos and https://dotacoach.gg/en/heroes/counters/necrophos.
- Valve: Pulse radius 500/damage 100/160/220/280/heal 70/90/110/130/projectile 400; Shroud restore 45/55/65/75 and extra magic 20%; Scythe coeff 0.7/0.8/0.9, stun 1.5, range 600; Seeker unit enemy/friendly,600, root disabled, mana 160 and 19 s cooldown.
- Scepter now converts health regen into Heartstopper damage 50%; current innate Sadist has bonus_aoe 0, no Profane Potency scaling is assumed.
- Every native consideration reviewed; passive/draft/builds unchanged.

Implemented behavior
- Removed speculative Scythe level/ally/old Scepter damage; forecast actual missing HP with regen and mana/radius/travel-safe Pulse follow-up; refuse protection and outside actual range.
- Ghost Shroud against physical threat/projectiles and before affordable healing; avoid heal-only Ice Blast and magic-heavy aggression.
- Pulse heals one wounded ally/self meaningfully and follows pending Scythe; farming spam is mana aware.
- Death Seeker named/root/castability guards, real range, safer allied escape/heal and offensive follow-up.
- New dedicated Rubick handler for all four actives independent of innate/passive.

Rejected or stale source claims
- TDL guide Scepter changes Ghost Shroud cooldown/aura during Shroud is old; current Scepter is regen-to-Heartstopper damage.
- Matchup Profane Potency and Arc Warden Barracuda references are stale; current Sadist bonus_aoe 0.
- No fixed 60% Scythe kill threshold used: mitigation, healing and rank matter.

Item follow-up observations for TASK-21
- TASK 21: trigger Wand after Shroud when available; Dagon before delayed Scythe finish; defensive magic resistance and dispels; numeric item claims require separate KV check.

Enemy counterplay observations for TASK-24
- TASK 24: magic burst during Shroud, healing reduction/Ice Blast, dispel Shroud, save Scythe victims with banish/magic immunity; avoid static HP thresholds.

Lobby validation checklist
- Pulse projectile arrival during Scythe stun, regen prediction and item cast preparation.
- Shroud magic-vs-physical pressure and Wand priority.
- Death Seeker allied path danger and disjoint timing, linked spell when stolen.
- No live game or deep-dive validation was performed during this standard pass.

Focused verification
- Fengari tests/necrolyte_ability_spec.lua passed; native/Rubick/spec Lua 5.2 parsed.

Full integration/build verification passed. Builds, skill/talent preferences and draft weights are unchanged. No game launched; engine-dependent claims remain lobby checks.

Final integrated verification: node tests/run-builds.cjs, node tests/run-objectives.cjs, node tests/valve_ability_check.cjs and git diff --check passed. Build/skill/talent preference AST comparison passed for all 49 scoped heroes. Native and applicable copied regressions are registered in run-builds. Framework callbacks and unsupported-spell dispatch preservation are covered. No game launched; the recorded lobby checklist remains required.
<!-- SECTION:NOTES:END -->

## Final Summary

<!-- SECTION:FINAL_SUMMARY:BEGIN -->
Necrophos standard ability pass completed offline. Native and copied behavior reviewed against Torte, full Dotacoach Strategy/Counter Strategy/Matchup and pinned Valve KV/localization. Meaningful behavior fixes and positive/negative regressions implemented; builds and flags preserved. Final integrated verification: node tests/run-builds.cjs, node tests/run-objectives.cjs, node tests/valve_ability_check.cjs and git diff --check passed. Build/skill/talent preference AST comparison passed for all 49 scoped heroes. Native and applicable copied regressions are registered in run-builds. Framework callbacks and unsupported-spell dispatch preservation are covered. No game launched; the recorded lobby checklist remains required.
<!-- SECTION:FINAL_SUMMARY:END -->
