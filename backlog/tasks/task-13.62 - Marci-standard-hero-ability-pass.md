---
id: TASK-13.62
title: 'Marci: standard hero ability pass'
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
  - bots/BotLib/hero_marci.lua
  - tests/marci_ability_spec.lua
documentation:
  - backlog/docs/doc-2 - Hero-improvement-playbook.md
modified_files:
  - bots/BotLib/hero_marci.lua
  - bots/FunLib/rubick_hero/marci.lua
  - tests/marci_ability_spec.lua
parent_task_id: TASK-13
priority: medium
ordinal: 102000
---

## Description

<!-- SECTION:DESCRIPTION:BEGIN -->
Marci is part of the requested Ember Spirit through Pugna hero-file-order batch. Review actual spell decisions against current mechanics and human usage, fixing meaningful ability-use gaps while retaining the established D2PT build.
<!-- SECTION:DESCRIPTION:END -->

## Acceptance Criteria
<!-- AC:BEGIN -->
- [x] #1 Ability decisions and cast order are reviewed against Torte de Lini, dotacoach Strategy/Counter Strategy/full Matchup and pinned Valve definitions/localization; verified checklist and stale claims are recorded
- [x] #2 Identified meaningful behavior gaps are fixed, including applicable Rubick handling, with positive and negative offline regression scenarios
- [x] #3 Focused hero scenarios, Valve ability check and full build suite pass; lobby checklist and engine limitations are recorded for Needs In-Game Test handoff
<!-- AC:END -->

## Implementation Plan

<!-- SECTION:PLAN:BEGIN -->
- Use actual Bodyguard barriers for saves, make Dispose displacement safe, require reachable Unleash attacks, and bound native Rebound decisions.
<!-- SECTION:PLAN:END -->

## Implementation Notes

<!-- SECTION:NOTES:BEGIN -->
Source review and offline implementation for the Ember Spirit → Pugna batch (hero-file order).

Sources: Torte CLI tools/tdl/fetch.cjs marci; https://dotacoach.gg/en/heroes/marci and https://dotacoach.gg/en/heroes/counters/marci (full Strategy, Counter Strategy and Matchup); Valve d2vpkr cf0d37a32c8df338a7832fd32a282747969e9a5f hero definitions plus English ability localization.

Verified ability checklist
- Read the full native file, Torte guide 2639555824, complete Dotacoach Strategy, Counter Strategy and Matchup pages, and pinned Valve data and localization.
- Verified Dispose range 175, landing 250 behind Marci, airborne duration 0.5 seconds and damage 60/150/240/330; Bodyguard range 600, barrier 90/160/230/300, duration seven seconds and runtime strong-dispel behavior; Unleash lasts 16 seconds with five strikes; Rebound is allied vector targeting with range 450–750 and an alternative carry mode. Attack intervals must be read from live values; the earlier draft’s tentative 0.1-second interval was not a verified mechanic.
- https://dotacoach.gg/en/heroes/marci
- https://dotacoach.gg/en/heroes/counters/marci

Implemented behavior
- Prioritize urgent Bodyguard before Unleash, evaluate incoming threat and actual trained strong-dispel behavior, and avoid duplicating modifier_marci_bodyguarded.
- Use Dispose for enemy channel interruption or to save a low-health ally only when landing behind Marci increases the distance from every visible chasing threat by at least 150. Do not move channeling allies.
- Use Unleash only against a reachable, attackable target, rejecting disarm, Blade Mail, an existing Unleash buff and protected targets.
- Use Bodyguard or legacy Sidekick on active fighting or farming allies at actual range. Copied spells do not assume absent passives.
- Respect native Rebound’s real ally reach, correct the target-versus-center condition, and reject unplanned carry mode, roots and Rupture. Conservatively decline copied vector casts.
- Pass the actual spell to item preparation.

Rejected or stale source claims
- Reject old Sidekick self-double-tap and enemy-targeted Rebound Shard advice; current Rebound uses an allied vector endpoint and Shard adds 20% damage.
- Reject Nullifier passive-Break claims; Bodyguard is an actual dispellable barrier buff.
- Distinguish Dispose displacement, which can interrupt, from its slow, which is not itself a hard stun.

Item follow-up observations for TASK-21
- TASK21: BKB protects Unleash attacks. Rapid strikes provide opportunities for Basher procs, while Nullifier removes eligible escape buffs or barriers. Blink can reach a better attack target.

Enemy counterplay observations for TASK-24
- TASK24: Disarm, ethereal protection, invisibility and kiting can waste the 16-second Unleash window. Healing reduction counters lifesteal, while armor and damage block reduce rapid attacks. Roots and Rupture still constrain Rebound.

Lobby validation checklist
- The retained scalar Rebound command cannot guarantee its vector landing. Verify the real endpoint in the separate deep dive; no unsupported API was invented.
- Verify Bodyguard’s current strong-dispel specials, copied passive availability, and Dispose facing and landing orientation.

Focused verification
- Fengari marci_ability_spec passed five groups; no game launched. Root shared checks pending.

Full integration/build verification passed. Builds, skill/talent preferences and draft weights are unchanged. No game launched; engine-dependent claims remain lobby checks.

Final integrated verification: node tests/run-builds.cjs, node tests/run-objectives.cjs, node tests/valve_ability_check.cjs and git diff --check passed. Build/skill/talent preference AST comparison passed for all 49 scoped heroes. Native and applicable copied regressions are registered in run-builds. Framework callbacks and unsupported-spell dispatch preservation are covered. No game launched; the recorded lobby checklist remains required.
<!-- SECTION:NOTES:END -->

## Final Summary

<!-- SECTION:FINAL_SUMMARY:BEGIN -->
Marci standard ability pass completed offline. Native and copied behavior reviewed against Torte, full Dotacoach Strategy/Counter Strategy/Matchup and pinned Valve KV/localization. Meaningful behavior fixes and positive/negative regressions implemented; builds and flags preserved. Final integrated verification: node tests/run-builds.cjs, node tests/run-objectives.cjs, node tests/valve_ability_check.cjs and git diff --check passed. Build/skill/talent preference AST comparison passed for all 49 scoped heroes. Native and applicable copied regressions are registered in run-builds. Framework callbacks and unsupported-spell dispatch preservation are covered. No game launched; the recorded lobby checklist remains required.
<!-- SECTION:FINAL_SUMMARY:END -->
