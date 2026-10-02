---
id: TASK-13.33
title: 'Ember Spirit: standard hero ability pass'
status: Needs In-Game Test
assignee:
  - '@codex'
created_date: '2026-10-02 08:49'
updated_date: '2026-10-02 10:40'
labels:
  - hero
  - weak-hero
milestone: m-0
dependencies: []
references:
  - bots/BotLib/hero_ember_spirit.lua
  - tests/ember_spirit_ability_spec.lua
documentation:
  - backlog/docs/doc-2 - Hero-improvement-playbook.md
modified_files:
  - bots/BotLib/hero_ember_spirit.lua
  - bots/FunLib/rubick_hero/ember_spirit.lua
  - tests/ember_spirit_ability_spec.lua
parent_task_id: TASK-13
priority: medium
ordinal: 73000
---

## Description

<!-- SECTION:DESCRIPTION:BEGIN -->
Ember Spirit is part of the requested Ember Spirit through Pugna hero-file-order batch. Review actual spell decisions against current mechanics and human usage, fixing meaningful ability-use gaps while retaining the established D2PT build.
<!-- SECTION:DESCRIPTION:END -->

## Acceptance Criteria
<!-- AC:BEGIN -->
- [x] #1 Ability decisions and cast order are reviewed against Torte de Lini, dotacoach Strategy/Counter Strategy/full Matchup and pinned Valve definitions/localization; verified checklist and stale claims are recorded
- [x] #2 Identified meaningful behavior gaps are fixed, including applicable Rubick handling, with positive and negative offline regression scenarios
- [x] #3 Focused hero scenarios, Valve ability check and full build suite pass; lobby checklist and engine limitations are recorded for Needs In-Game Test handoff
<!-- AC:END -->

## Implementation Plan

<!-- SECTION:PLAN:BEGIN -->
Validate physical Sleight, random Chains and magic Guard/Remnants; replace blind combo queue with observed-state Chains, fix first-remnant deployment and safe owned escape activation, and mirror independent copied basics.
<!-- SECTION:PLAN:END -->

## Implementation Notes

<!-- SECTION:NOTES:BEGIN -->
Source review and offline implementation for the Ember Spirit → Pugna batch (hero-file order).

Sources: Torte CLI tools/tdl/fetch.cjs ember_spirit; https://dotacoach.gg/en/heroes/ember-spirit and https://dotacoach.gg/en/heroes/counters/ember-spirit (full Strategy, Counter Strategy and Matchup); Valve d2vpkr cf0d37a32c8df338a7832fd32a282747969e9a5f hero definitions plus English ability localization.

Verified ability checklist
- Pinned cf0d37a: Chains no-target 400 radius, 2 random visible nonimmune units, 100 DPS x 1.25/1.75/2.25/2.75 s; isolated-target requirement before kill/combo.
- Sleight point physical attack, root-disabled, 650 range, bonus damage 40/80/120/160, radius 250/350/450/550; charges dynamic talent.
- Guard no-target, 500 radius, 70% barrier, 12/14/16/18 duration; already-active modifier guarded.
- Remnant 3 charges, zero placement mana, 1400 range and 250% movespeed. Scepter 5 charges/3000 reach/doubled initial speed; Activate root-disabled point 100/125/150 mana, 75 with Scepter.
- Immolation passive/Break; Shard extends damage/radius and remnant aura, death/kill charge behavior engine-owned.
- Read both Torte physical/magic guides and full dotacoach Strategy, Counter Strategy, gameplay synergy/matchups and advanced item cards; localization confirms cast during Sleight and random targeting.

Implemented behavior
- Sleight kill damage uses physical; disarm/root/ethereal/attack-immunity guards.
- Chains computes full duration and does not promise kill amidst excess random targets; excludes invisible and immunity, removes irrelevant spell reflection check.
- Replaced blind queued Chains with a helper that requires the observed Sleight caster modifier. It rejects casting animations, queues, silence, disables and forbidden states while permitting only the actual mid-Sleight action.
- Remnant placement no longer deadlocks against hidden Activate; Scepter reach/speed, spare-charge chase reserve.
- Owned remnant selection only; retreat activation precedes combo and requires meaningful safer baseward destination; activation root gate.
- Guard avoids refreshing live modifier and corrects retreat condition grouping.
- Added independent Rubick Chains/Sleight/Guard handling without assumed linked/passive spells.

Rejected or stale source claims
- Torte True Strike and 15% spell-amplification talent cards absent from current talent slots.
- TP during Sleight cannot be treated as a guaranteed protected channel; excluded.
- Facets/double-Sleight behavior values are zero in pinned KV; excluded.

Item follow-up observations for TASK-21
- TASK-21: Phase Boots before Remnant improves initial speed; BKB/dispel tools preserve escape availability; Mage Slayer attack debuff spreads via Sleight; Shiva follows actor during attacks; do not infer old Veil active or outdated build requirements.

Enemy counterplay observations for TASK-24
- TASK-24: break/dispel Guard, control sustain runes, spread versus Sleight/Chains, root/silence mobility; Chains does not reveal invisibility.

Lobby validation checklist
- Observe engine callback during 0.25 s Sleight hits and Chains timing; helper rejects blind pre-Sleight queue.
- Verify owned remnant player IDs, moving remnant position and landing safety; activation consumes ALL owned remnants, so escaping consumes prior anchors.
- Test Scepter speed/range and charge reserve, Shard replenishment, base-return/rune-anchor route planning remains separate from ability pass.

Focused verification
- Fengari Ember Spirit native+copied spec passed: physical immunity/ethereal, root/disarm, random creep dilution, full Chains duration, live Guard, hidden-first-Remnant, safe owned escape, last-charge reserve, actual observed-Sleight and busy-state negatives.

Full integration/build verification passed. Builds, skill/talent preferences and draft weights are unchanged. No game launched; engine-dependent claims remain lobby checks.

Final integrated verification: node tests/run-builds.cjs, node tests/run-objectives.cjs, node tests/valve_ability_check.cjs and git diff --check passed. Build/skill/talent preference AST comparison passed for all 49 scoped heroes. Native and applicable copied regressions are registered in run-builds. Framework callbacks and unsupported-spell dispatch preservation are covered. No game launched; the recorded lobby checklist remains required.
<!-- SECTION:NOTES:END -->

## Final Summary

<!-- SECTION:FINAL_SUMMARY:BEGIN -->
Ember Spirit standard ability pass completed offline. Native and copied behavior reviewed against Torte, full Dotacoach Strategy/Counter Strategy/Matchup and pinned Valve KV/localization. Meaningful behavior fixes and positive/negative regressions implemented; builds and flags preserved. Final integrated verification: node tests/run-builds.cjs, node tests/run-objectives.cjs, node tests/valve_ability_check.cjs and git diff --check passed. Build/skill/talent preference AST comparison passed for all 49 scoped heroes. Native and applicable copied regressions are registered in run-builds. Framework callbacks and unsupported-spell dispatch preservation are covered. No game launched; the recorded lobby checklist remains required.
<!-- SECTION:FINAL_SUMMARY:END -->
