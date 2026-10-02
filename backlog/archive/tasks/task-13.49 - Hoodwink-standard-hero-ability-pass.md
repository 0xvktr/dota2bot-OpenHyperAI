---
id: TASK-13.49
title: 'Hoodwink: standard hero ability pass'
status: Needs In-Game Test
assignee:
  - '@codex'
created_date: '2026-10-02 09:08'
updated_date: '2026-10-02 10:40'
labels:
  - hero
  - weak-hero
milestone: m-0
dependencies: []
references:
  - bots/BotLib/hero_hoodwink.lua
  - tests/hoodwink_ability_spec.lua
documentation:
  - backlog/docs/doc-2 - Hero-improvement-playbook.md
modified_files:
  - bots/BotLib/hero_hoodwink.lua
  - bots/FunLib/rubick_hero/hoodwink.lua
  - tests/hoodwink_ability_spec.lua
  - bots/FunLib/hoodwink_abilities.lua
parent_task_id: TASK-13
priority: medium
ordinal: 89000
---

## Description

<!-- SECTION:DESCRIPTION:BEGIN -->
Hoodwink is part of the requested Ember Spirit through Pugna hero-file-order batch. Review actual spell decisions against current mechanics and human usage, fixing meaningful ability-use gaps while retaining the established D2PT build.
<!-- SECTION:DESCRIPTION:END -->

## Acceptance Criteria
<!-- AC:BEGIN -->
- [x] #1 Ability decisions and cast order are reviewed against Torte de Lini, dotacoach Strategy/Counter Strategy/full Matchup and pinned Valve definitions/localization; verified checklist and stale claims are recorded
- [x] #2 Identified meaningful behavior gaps are fixed, including applicable Rubick handling, with positive and negative offline regression scenarios
- [x] #3 Focused hero scenarios, Valve ability check and full build suite pass; lobby checklist and engine limitations are recorded for Needs In-Game Test handoff
<!-- AC:END -->

## Implementation Plan

<!-- SECTION:PLAN:BEGIN -->
Correct direct Acorn damage and tree combos, natural-tree Bushwhack priority, escape priorities, independent upgrades and actual Sharpshooter charge/release.
<!-- SECTION:PLAN:END -->

## Implementation Notes

<!-- SECTION:NOTES:BEGIN -->
Source review and offline implementation for the Ember Spirit → Pugna batch (hero-file order).

Sources: Torte CLI tools/tdl/fetch.cjs hoodwink; https://dotacoach.gg/en/heroes/hoodwink and https://dotacoach.gg/en/heroes/counters/hoodwink (full Strategy, Counter Strategy and Matchup); Valve d2vpkr cf0d37a32c8df338a7832fd32a282747969e9a5f hero definitions plus English ability localization.

Verified ability checklist
- Acorn: 675/700/725/750 range, 80% attack plus 45/90/135/180 bonus physical damage, 2200 speed, 525 bounce range; current immunity excludes.
- Bushwhack: 1100 range, 1300 projectile speed, 265 trap radius, 1.5/1.7/1.9/2.1 stun; tree needed at impact, no invisible targets.
- Scurry: two base charges, 35 mana, phased treewalking and movement; doubles innate redirect, not all evasion or cast range.
- Sharpshooter: actual 3000 projectile range, 3 s maximum charge, auto fire 5 s, 2200 speed and 350 recoil; windup modifier roots/disarms caster.
- Shard grants Boomerang: 1100 range, 200 magical damage, 20% incoming spell amplification for 6 s. Scepter Decoy: 6 s invisibility/illusion and 60% Sharpshooter damage.

Implemented behavior
- Fixed massive Acorn damage multiplication to additive bonus plus 80% attack; normal direct unit casts preserve initial guaranteed hit, tree point cast only when real ready affordable Bushwhack needs a tree.
- Natural-tree Bushwhack precedes Acorn; trap checks observed trees around predicted impact point and actual range. No blind queued combo. Restored shared waveclear with direct Acorn when useful.
- Scurry and Decoy escape decisions precede offense, Scurry avoids rooted movement waste and reserves last charge for offensive chase.
- Boomerang point cast applies useful slow/amplification before burst; upgrade castability guards respect hidden/unavailable abilities.
- Sharpshooter predicts 3 s charge plus flight, avoids point-blank self-rooting, Blade Mail and intervening heroes. Safe release hook fires at full observed charge only with actual windup and disabling-state guards. Native/copy share logic; absent linked spells are not presumed. Release also requires the linked source shot handle to exist, avoiding dereferencing a missing copied ability.

Rejected or stale source claims
- Old Scurry cast range, all-source evasion or invisibility talent advice rejected. Deprecated Treebounce/Quickdraw facets and unused innate variants excluded.
- Old Arcane disassembly and offensive Solar Crest advice not imported.
- No unsupported vector aim endpoints or fake channel cancellation API introduced.

Item follow-up observations for TASK-21
- TASK-21: Hex/Atos setups can prepare a real tree trap and safe charged shot; Euls interaction while winding up requires engine verification.
- TASK-21: Acorn attack modifiers and Lens ranges are respected, but tree point trades away initial bounce damage.

Enemy counterplay observations for TASK-24
- TASK-24: Quelling cuts the trap tree; predicted-impact checks still require engine tree ownership/timing.
- TASK-24: true strike counters redirect; Blade Mail and early hero interception change Sharpshooter value.

Lobby validation checklist
- Validate full-charge release hook in generic framework and mode behavior for native/copy windup.
- Validate Acorn tree appears before Bushwhack and cutting invalidates it.
- Validate direct Acorn current immunity behavior, point Boomerang and copied upgrade grant.

Focused verification
- Native/copied Fengari suite passed; four files parse as Lua 5.2.

Full integration/build verification passed. Builds, skill/talent preferences and draft weights are unchanged. No game launched; engine-dependent claims remain lobby checks.

Final integrated verification: node tests/run-builds.cjs, node tests/run-objectives.cjs, node tests/valve_ability_check.cjs and git diff --check passed. Build/skill/talent preference AST comparison passed for all 49 scoped heroes. Native and applicable copied regressions are registered in run-builds. Framework callbacks and unsupported-spell dispatch preservation are covered. No game launched; the recorded lobby checklist remains required.
<!-- SECTION:NOTES:END -->

## Final Summary

<!-- SECTION:FINAL_SUMMARY:BEGIN -->
Hoodwink standard ability pass completed offline. Native and copied behavior reviewed against Torte, full Dotacoach Strategy/Counter Strategy/Matchup and pinned Valve KV/localization. Meaningful behavior fixes and positive/negative regressions implemented; builds and flags preserved. Final integrated verification: node tests/run-builds.cjs, node tests/run-objectives.cjs, node tests/valve_ability_check.cjs and git diff --check passed. Build/skill/talent preference AST comparison passed for all 49 scoped heroes. Native and applicable copied regressions are registered in run-builds. Framework callbacks and unsupported-spell dispatch preservation are covered. No game launched; the recorded lobby checklist remains required.
<!-- SECTION:FINAL_SUMMARY:END -->
