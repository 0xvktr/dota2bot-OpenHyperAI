---
id: TASK-13.113
title: 'Tidehunter: standard hero ability pass'
status: Needs In-Game Test
assignee:
  - '@codex'
created_date: '2026-10-02 15:25'
updated_date: '2026-10-02 16:24'
labels:
  - hero
dependencies: []
references:
  - bots/BotLib/hero_tidehunter.lua
  - tests/tidehunter_ability_spec.lua
documentation:
  - backlog/docs/doc-2 - Hero-improvement-playbook.md
modified_files:
  - bots/BotLib/hero_tidehunter.lua
  - bots/FunLib/rubick_hero/tidehunter.lua
  - tests/tidehunter_ability_spec.lua
parent_task_id: TASK-13
priority: medium
ordinal: 153000
---

## Description

<!-- SECTION:DESCRIPTION:BEGIN -->
Tidehunter is part of the requested Queen of Pain through Zeus hero-file-order batch. Review actual spell decisions against current mechanics and human usage, fixing meaningful ability-use gaps while retaining the established D2PT build.
<!-- SECTION:DESCRIPTION:END -->

## Acceptance Criteria
<!-- AC:BEGIN -->
- [x] #1 Ability decisions and cast order are reviewed against Torte de Lini, dotacoach Strategy/Counter Strategy/full Matchup and pinned Valve definitions/localization; verified checklist and stale claims are recorded
- [x] #2 Identified meaningful behavior gaps are fixed, including applicable Rubick handling, with positive and negative offline regression scenarios
- [x] #3 Focused hero scenarios, Valve ability check and full build suite pass; lobby checklist and engine limitations are recorded for Needs In-Game Test handoff
<!-- AC:END -->

## Implementation Plan

<!-- SECTION:PLAN:BEGIN -->
Use current Gush shapes and ranges, actual attack-based Anchor Smash, timed follow-up Ravage, legal Shard leash and physical-threat Kraken Shell.
<!-- SECTION:PLAN:END -->

## Implementation Notes

<!-- SECTION:NOTES:BEGIN -->
Source review and offline implementation for the Queen of Pain → Zeus batch (hero-file order).

Sources: Torte CLI tools/tdl/fetch.cjs tidehunter; https://dotacoach.gg/en/heroes/tidehunter and https://dotacoach.gg/en/heroes/counters/tidehunter (full Strategy, Counter Strategy and Matchup); Valve d2vpkr cf0d37a32c8df338a7832fd32a282747969e9a5f hero definitions plus English ability localization.

Verified ability checklist
- Read full native decisions, full Torte guide 128912519 and complete Dotacoach Strategy, Counter Strategy and Matchup gameplay, synergy and advanced item cards. Verify mechanics against pinned Valve and localization.
- Normal Gush range 700, projectile speed 2500 and damage 100/160/220/280 plus runtime talent. Current Scepter point wave range 2200, width 260, speed 1500 and cooldown seven seconds.
- Anchor Smash radius equals actual attack range plus runtime 225; attack bonus 50/100/150/200, physical damage and no Roshan hit. Runtime building talent allows buildings at 50% damage.
- Ravage radius 1250, cast 0.3, wave speed 725, damage 275/375/475 and stun 2/2.2/2.4 seconds. Kraken active doubles actual block for four seconds at 40% movement penalty; Break suppresses passive block.
- Current Shard Dead in the Water range 350, cast 0.3, projectile speed 1000, duration ten seconds and four attacks to destroy the anchor.

Implemented behavior
- Gush uses exact actual range with current Lens and unbroken Supremacy. Native and copied casts switch between legal unit and current Scepter point shapes; wave casts do not assume unit spell shields apply. Regeneration-aware kills include actual projectile travel.
- Scepter farming aims a real predicted line and counts only valid nonglyph creeps within the current width. Normal ranged-creep last hits preserve Ravage mana and avoid spending when one attack already suffices.
- Anchor Smash uses actual attack range and predicted coverage, physical attackability, human ally threat follow-up, meaningful creep groups and available Ravage reserve. Building opportunity requires the actual runtime talent and rejects Glyph; no invented full building lethal amount or Roshan damage is promised.
- Ravage considers wave arrival for kills and channels, rejects teleport interrupts arriving too late, magic-immune/protected/reflected targets and existing disable overlap, and requires actual nearby damage follow-up for normal commitments.
- Kraken Shell activates against actual physical attacks or projectiles when holding ground or unable to escape, while ordinary retreat preserves movement. Repeat buffs and Break decline; boss use requires actual attack and low health.
- Dead in the Water uses exact actual range, runtime handle readiness, real shields, fresh leash and human ally attack threats.
- Legacy Arm is considered only when the engine supplies a positive actual cast range and visible active handle with a trained linked Ravage. Missing linked or zero-range state declines without inventing an endpoint. Unknown copied dispatch returns nil first.

Rejected or stale source claims
- The old native Scepter Gush hardcoded 1400 instead of current 2200 and Lens hardcoded 250. Old Shard Tendrils guide prose predates current Dead in the Water.
- Older Blubber innate and Solar Crest enemy armor prose are stale. Current Kraken Shell owns the physical damage threshold dispel; this pass does not bypass controls to invent an active strong dispel.

Item follow-up observations for TASK-21
- TASK-21: Blink initiation needs nearby follow-up, Shard adds shorter-cooldown leash, Scepter enables ranged wave clearing, Refresher requires mana for two Ravages, and Vladmir/Mage Slayer/armor effects can benefit actual Anchor attacks. Preserve current builds and shared item actions.

Enemy counterplay observations for TASK-24
- TASK-24: debuff immunity and strong dispels counter Ravage, Break removes Kraken protection and pure/magic damage bypasses physical block. Do not waste the long ultimate on already disabled or unsupported targets; current human ally attacks establish actual follow-up.

Lobby validation checklist
- No game was launched. Verify Scepter Gush runtime cast range and line shape, Anchor attack-range growth and building talent, and real Ravage wave arrival.
- Verify Kraken active modifier and Break interaction. Automatic fish pickup remains outside the ability pass because no documented bot pickup action was found; no movement orders or speculative fish entity names are introduced.
- Legacy Arm is conservatively unavailable when runtime cast range remains zero, even if obsolete KV advertises a scaled projectile; verify any current visible engine handle before broadening this path.

Focused verification
- Focused native/copied Fengari scenarios passed for exact normal/Scepter/Lens/Supremacy ranges, magic versus physical immunity, delayed projectile kills and teleport windows, current line farming, dynamic Smash/building/Glyph/Roshan restrictions, human support, actual follow-up, Kraken retreat/Break locks, Shard shields, missing legacy links, queues and nil-first unknown dispatch.
- Valve ability and owned whitespace checks passed; shared registration and integrated suite are root-owned.
- Audited fractional special values against pinned data. Focused fixtures truncate integer getters toward zero and preserve float getters; all existing timing and moving-target scenarios pass with these engine semantics.

Full integration/build verification passed. Builds, skill/talent preferences and draft weights are unchanged. No game launched; engine-dependent claims remain lobby checks.

Final integrated verification: node tests/run-builds.cjs, node tests/run-objectives.cjs, node tests/valve_ability_check.cjs and git diff --check passed. Build/skill/talent preference AST comparison passed for all 43 scoped heroes. Native and applicable copied regressions are registered in run-builds. Framework callbacks and unsupported-spell dispatch preservation are covered. No game launched; the recorded lobby checklist remains required.
<!-- SECTION:NOTES:END -->

## Final Summary

<!-- SECTION:FINAL_SUMMARY:BEGIN -->
Tidehunter standard ability pass completed offline. Native and copied behavior reviewed against Torte and full Dotacoach Strategy/Counter Strategy/Matchup and pinned Valve KV/localization. Meaningful behavior fixes and positive/negative regressions implemented; builds and flags preserved. Final integrated verification: node tests/run-builds.cjs, node tests/run-objectives.cjs, node tests/valve_ability_check.cjs and git diff --check passed. Build/skill/talent preference AST comparison passed for all 43 scoped heroes. Native and applicable copied regressions are registered in run-builds. Framework callbacks and unsupported-spell dispatch preservation are covered. No game launched; the recorded lobby checklist remains required.
<!-- SECTION:FINAL_SUMMARY:END -->
