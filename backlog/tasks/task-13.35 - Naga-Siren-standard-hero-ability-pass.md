---
id: TASK-13.35
title: 'Naga Siren: standard hero ability pass'
status: Needs In-Game Test
assignee:
  - '@codex'
created_date: '2026-10-02 08:49'
updated_date: '2026-10-02 10:40'
labels:
  - hero
dependencies: []
references:
  - bots/BotLib/hero_naga_siren.lua
  - tests/naga_siren_ability_spec.lua
documentation:
  - backlog/docs/doc-2 - Hero-improvement-playbook.md
modified_files:
  - bots/BotLib/hero_naga_siren.lua
  - bots/FunLib/rubick_hero/naga_siren.lua
  - tests/naga_siren_ability_spec.lua
parent_task_id: TASK-13
priority: medium
ordinal: 75000
---

## Description

<!-- SECTION:DESCRIPTION:BEGIN -->
Naga Siren is part of the requested Ember Spirit through Pugna hero-file-order batch. Review actual spell decisions against current mechanics and human usage, fixing meaningful ability-use gaps while retaining the established D2PT build.
<!-- SECTION:DESCRIPTION:END -->

## Acceptance Criteria
<!-- AC:BEGIN -->
- [x] #1 Ability decisions and cast order are reviewed against Torte de Lini, dotacoach Strategy/Counter Strategy/full Matchup and pinned Valve definitions/localization; verified checklist and stale claims are recorded
- [x] #2 Identified meaningful behavior gaps are fixed, including applicable Rubick handling, with positive and negative offline regression scenarios
- [x] #3 Focused hero scenarios, Valve ability check and full build suite pass; lobby checklist and engine limitations are recorded for Needs In-Game Test handoff
<!-- AC:END -->

## Implementation Plan

<!-- SECTION:PLAN:BEGIN -->
Prioritize escape Song and cancel; use live radii/ranges, net sleeping/channeling targets, preserve healing and safe owned-net Reel; Mirror basic dispel; native and stolen regressions.
<!-- SECTION:PLAN:END -->

## Implementation Notes

<!-- SECTION:NOTES:BEGIN -->
Source review and offline implementation for the Ember Spirit → Pugna batch (hero-file order).

Sources: Torte CLI tools/tdl/fetch.cjs naga_siren; https://dotacoach.gg/en/heroes/naga-siren and https://dotacoach.gg/en/heroes/counters/naga-siren (full Strategy, Counter Strategy and Matchup); Valve d2vpkr cf0d37a32c8df338a7832fd32a282747969e9a5f hero definitions plus English ability localization.

Verified ability checklist
- Sources: https://dotacoach.gg/en/heroes/naga-siren and https://dotacoach.gg/en/heroes/counters/naga-siren; TDL guide guide 129402805 fetched.
- Pinned Valve: Mirror 0.5-second invulnerability and basic dispel; Ensnare interrupts and targets Song victims; range 500/525/550/575 with a 50% Scepter range increase; Scepter adds debuff immunity and break.
- Song radius 900/1150/1400, invulnerable victims, follows caster, healing 1/2/3% plus 1% from Shard, and 4% mana restoration; Reel base channel 5 s/radius 1600/min distance 100; passive Rip Tide 6 hits retained.
- Full native abilities inspected; passive/build/minion policies untouched. Song save/setup and ally readiness implemented; complex timed team AoE coordination remains lobby follow-up.

Implemented behavior
- Escape/reset Song before damage; actual radius, debuff immunity, and ally-supported remote setup.
- Cancel on completed escape/no healing need or ready nearby team; preserve retreat/healing Song.
- Mirror basic dispels roots/Track/Amplify; Ensnare interrupts channels, targets Song, uses live range; Lens value no hardcoded 250.
- Reel is available without Scepter; source-owned nets only, radius 1600, no retreat/teamfight/channel.
- Added dedicated Rubick handler; no absent primary/linked/passive assumptions.

Rejected or stale source claims
- Some Reel advice emphasizes Scepter or immunity even though the base linked Reel ability is available without Scepter; current mechanics determine availability.
- Site says Rip Tide can be used while channeling despite current passive; ignored active-spell premise.

Item follow-up observations for TASK-21
- TASK 21: Manta as extra splitpush/dispel; Orchid/Bloodthorn then net for attack follow-up; Treads mana preparation preserved. Bloodthorn numeric 50 proc not encoded; verify item KV before shared change.

Enemy counterplay observations for TASK-24
- TASK 24: clear Mirror illusions with AoE/hex; avoid ordinary Ensnare/Song with BKB but Scepter net pierces; net reveals invisibility and is dispellable.

Lobby validation checklist
- Song ally coordination and cancellation including low-health regeneration and escape.
- Ensnare on Song invulnerability and Scepter targets.
- Reel net source API handle ownership and automatic availability without Scepter.
- Stolen Song linked cancel grant and Mirror minion control.
- No live game or deep-dive validation was performed during this standard pass.

Focused verification
- Fengari tests/naga_siren_ability_spec.lua passed.
- Lua 5.2 parse passed native/handler/spec; root to run Valve/full suite.

Full integration/build verification passed. Builds, skill/talent preferences and draft weights are unchanged. No game launched; engine-dependent claims remain lobby checks.

Final integrated verification: node tests/run-builds.cjs, node tests/run-objectives.cjs, node tests/valve_ability_check.cjs and git diff --check passed. Build/skill/talent preference AST comparison passed for all 49 scoped heroes. Native and applicable copied regressions are registered in run-builds. Framework callbacks and unsupported-spell dispatch preservation are covered. No game launched; the recorded lobby checklist remains required.
<!-- SECTION:NOTES:END -->

## Final Summary

<!-- SECTION:FINAL_SUMMARY:BEGIN -->
Naga Siren standard ability pass completed offline. Native and copied behavior reviewed against Torte, full Dotacoach Strategy/Counter Strategy/Matchup and pinned Valve KV/localization. Meaningful behavior fixes and positive/negative regressions implemented; builds and flags preserved. Final integrated verification: node tests/run-builds.cjs, node tests/run-objectives.cjs, node tests/valve_ability_check.cjs and git diff --check passed. Build/skill/talent preference AST comparison passed for all 49 scoped heroes. Native and applicable copied regressions are registered in run-builds. Framework callbacks and unsupported-spell dispatch preservation are covered. No game launched; the recorded lobby checklist remains required.
<!-- SECTION:FINAL_SUMMARY:END -->
