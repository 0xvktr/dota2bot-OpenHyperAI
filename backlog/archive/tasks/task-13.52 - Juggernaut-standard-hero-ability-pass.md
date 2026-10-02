---
id: TASK-13.52
title: 'Juggernaut: standard hero ability pass'
status: Needs In-Game Test
assignee:
  - '@codex'
created_date: '2026-10-02 09:08'
updated_date: '2026-10-02 10:40'
labels:
  - hero
dependencies: []
references:
  - bots/BotLib/hero_juggernaut.lua
  - tests/juggernaut_ability_spec.lua
documentation:
  - backlog/docs/doc-2 - Hero-improvement-playbook.md
modified_files:
  - bots/BotLib/hero_juggernaut.lua
  - bots/FunLib/rubick_hero/juggernaut.lua
  - tests/juggernaut_ability_spec.lua
  - bots/FunLib/juggernaut_abilities.lua
parent_task_id: TASK-13
priority: medium
ordinal: 92000
---

## Description

<!-- SECTION:DESCRIPTION:BEGIN -->
Juggernaut is part of the requested Ember Spirit through Pugna hero-file-order batch. Review actual spell decisions against current mechanics and human usage, fixing meaningful ability-use gaps while retaining the established D2PT build.
<!-- SECTION:DESCRIPTION:END -->

## Acceptance Criteria
<!-- AC:BEGIN -->
- [x] #1 Ability decisions and cast order are reviewed against Torte de Lini, dotacoach Strategy/Counter Strategy/full Matchup and pinned Valve definitions/localization; verified checklist and stale claims are recorded
- [x] #2 Identified meaningful behavior gaps are fixed, including applicable Rubick handling, with positive and negative offline regression scenarios
- [x] #3 Focused hero scenarios, Valve ability check and full build suite pass; lobby checklist and engine limitations are recorded for Needs In-Game Test handoff
<!-- AC:END -->

## Implementation Plan

<!-- SECTION:PLAN:BEGIN -->
Isolated physical Slash, safe Ward placement/current Shard and defensive spin priority with copied parity.
<!-- SECTION:PLAN:END -->

## Implementation Notes

<!-- SECTION:NOTES:BEGIN -->
Source review and offline implementation for the Ember Spirit → Pugna batch (hero-file order).

Sources: Torte CLI tools/tdl/fetch.cjs juggernaut; https://dotacoach.gg/en/heroes/juggernaut and https://dotacoach.gg/en/heroes/counters/juggernaut (full Strategy, Counter Strategy and Matchup); Valve d2vpkr cf0d37a32c8df338a7832fd32a282747969e9a5f hero definitions plus English ability localization.

Verified ability checklist
- Fury: 260 radius, 85/115/145/175 magical DPS for 5 s, 80% magic resistance, strong dispel at end; current Shard does not upgrade it.
- Ward: point 350 range, 400 aura, 18/20/22/24 s duration, 2/3/4/5% max-health healing; Shard adds 1.5% healing and one hit durability.
- Omnislash: physical immunity-piercing unit cast, 450 range, 425 bounce radius, 1.4 attack-rate multiplier, 25/30/35 bonus damage, 40 bonus speed, 3/3.25/3.5 duration.
- Swift: Scepter independent unit ability, 450 range, 1 s duration, 25 s cooldown.
- Blade Dance/Bladeform passives not presumed on copied spells; deprecated unassigned Trinity and Vaulted Strike excluded.

Implemented behavior
- Slash validates real cast range, physical vulnerability, blocking/reflection, disarm and root displacement restrictions. Nearby heroes/creeps dilute conservative attack damage; no automatic full ultimate into a wave.
- Defensive Fury comes before offense; offensive spin compares magical DPS to actual attack DPS and still works when disarmed or attacking ethereal targets. Native farming spin retained.
- Ward covers actual wounded allies/self, avoids Ice Blast and an owned live ward, places behind the patient within real cast range and aura while avoiding enemy attack reach.
- Native/copy UseHealingWardDuringSlash callback permits precisely observed invulnerable Slash state and forbids silence/stun/hex/nightmare/channel/casting/queue/Doom/Box/Force Staff.
- Copied spells independently use real handles, no presumed crit passives or linked Omnislash for Swift; canonical dispatcher returns and unknown guards tested.

Rejected or stale source claims
- Old spin Shard attacks/movement removed; Shard currently improves Healing Ward.
- Dotacoach duration NaN replaced with Valve 18/20/22/24; one-hit ward counter advice depends on Shard.
- Broad claims Slash ignores armor/passive mitigation or can be freely used from root not imported; no guaranteed total bounce damage.

Item follow-up observations for TASK-21
- TASK-21: Swift Blink improves actual Slash attack throughput; direct spell logic waits for item policy instead of unobserved queued blink.
- TASK-21: spin TP still needs immunity-piercing interrupt awareness; no unconditional safe TP claim.

Enemy counterplay observations for TASK-24
- TASK-24: nearby creeps/illusions split Slashes; invisibility/ethereal and Lotus threaten value.
- TASK-24: destroy Ward early and use immunity-piercing control against spin escapes.

Lobby validation checklist
- Validate native/copied Ward callback while invulnerable without interrupting Slash and existing Ward micro ownership.
- Validate Slash root restrictions and copied Swift damage without linked passive.
- Validate spin crit interaction: current Fury can_crit special is zero despite broad description; no assumed passive damage bonus.

Focused verification
- Native/copied Fengari suite passed; four files parse as Lua 5.2.

Full integration/build verification passed. Builds, skill/talent preferences and draft weights are unchanged. No game launched; engine-dependent claims remain lobby checks.

Final integrated verification: node tests/run-builds.cjs, node tests/run-objectives.cjs, node tests/valve_ability_check.cjs and git diff --check passed. Build/skill/talent preference AST comparison passed for all 49 scoped heroes. Native and applicable copied regressions are registered in run-builds. Framework callbacks and unsupported-spell dispatch preservation are covered. No game launched; the recorded lobby checklist remains required.
<!-- SECTION:NOTES:END -->

## Final Summary

<!-- SECTION:FINAL_SUMMARY:BEGIN -->
Juggernaut standard ability pass completed offline. Native and copied behavior reviewed against Torte, full Dotacoach Strategy/Counter Strategy/Matchup and pinned Valve KV/localization. Meaningful behavior fixes and positive/negative regressions implemented; builds and flags preserved. Final integrated verification: node tests/run-builds.cjs, node tests/run-objectives.cjs, node tests/valve_ability_check.cjs and git diff --check passed. Build/skill/talent preference AST comparison passed for all 49 scoped heroes. Native and applicable copied regressions are registered in run-builds. Framework callbacks and unsupported-spell dispatch preservation are covered. No game launched; the recorded lobby checklist remains required.
<!-- SECTION:FINAL_SUMMARY:END -->
