---
id: TASK-13.43
title: 'Lina: standard hero ability pass'
status: Needs In-Game Test
assignee:
  - '@codex'
created_date: '2026-10-02 09:07'
updated_date: '2026-10-02 15:48'
labels:
  - hero
dependencies: []
references:
  - bots/BotLib/hero_lina.lua
  - tests/lina_ability_spec.lua
documentation:
  - backlog/docs/doc-2 - Hero-improvement-playbook.md
modified_files:
  - bots/FunLib/rubick_hero/lina.lua
  - tests/lina_ability_spec.lua
parent_task_id: TASK-13
priority: medium
ordinal: 83000
---

## Description

<!-- SECTION:DESCRIPTION:BEGIN -->
Lina is part of the requested Ember Spirit through Pugna hero-file-order batch. Review actual spell decisions against current mechanics and human usage, fixing meaningful ability-use gaps while retaining the established D2PT build.
<!-- SECTION:DESCRIPTION:END -->

## Acceptance Criteria
<!-- AC:BEGIN -->
- [x] #1 Ability decisions and cast order are reviewed against Torte de Lini, dotacoach Strategy/Counter Strategy/full Matchup and pinned Valve definitions/localization; verified checklist and stale claims are recorded
- [x] #2 Identified meaningful behavior gaps are fixed, including applicable Rubick handling, with positive and negative offline regression scenarios
- [x] #3 Focused hero scenarios, Valve ability check and full build suite pass; lobby checklist and engine limitations are recorded for Needs In-Game Test handoff
<!-- AC:END -->

## Implementation Plan

<!-- SECTION:PLAN:BEGIN -->
- Correct Laguna immunity/damage/range and plausible kill estimate.
- Interrupt/set up with delayed LSA before Dragon; cloak for single-target spell burst.
- Respect fixed Dragon travel and genuine FierySoul for Shard opener; mirror copied spells.
- Offline positive/negative regression scenarios.
<!-- SECTION:PLAN:END -->

## Implementation Notes

<!-- SECTION:NOTES:BEGIN -->
Source review and offline implementation for the Ember Spirit → Pugna batch (hero-file order).

Sources: Torte CLI tools/tdl/fetch.cjs lina; https://dotacoach.gg/en/heroes/lina and https://dotacoach.gg/en/heroes/counters/lina (full Strategy, Counter Strategy and Matchup); Valve d2vpkr cf0d37a32c8df338a7832fd32a282747969e9a5f hero definitions plus English ability localization.

Verified ability checklist
- Read every native consideration and SkillsComplement, Torte guides 129067853 and 381725812, complete Dotacoach Strategy, Counter Strategy and Matchup pages, and pinned Valve data and localization.
- Verified Light Strike Array range 700, radius 250, cast point 0.45 seconds and delay 0.5 seconds; Dragon Slave travel 1075 at speed 1200; Laguna range 750, magical non-piercing damage 400/580/760 and delay of 0.3 plus 0.25 seconds; Flame Cloak provides 35% amplification and resistance for seven seconds; Shard grants 12 actual Fiery Soul stacks for five seconds.
- Reviewed allied stun and root setups and Pugna’s ethereal amplification without changing drafts.

Implemented behavior
- Remove obsolete pure, immunity-piercing Scepter Laguna assumptions and the fabricated 1.88 burst multiplier.
- Estimate Laguna using actual magical damage, delay and range; allow the Shard opener only with the real trained Fiery Soul passive.
- Prioritize Light Strike Array interrupts before routine damage or Flame Cloak, cast it before Dragon Slave, and share bounded delayed predictions with copied spells.
- Use Flame Cloak for a useful single-target spell burst, read the live Aether Lens bonus, and pass actual spells to item preparation.
- Bound Dragon Slave by real projectile travel and predict cast plus flight time. Copied abilities do not assume absent innate effects or Fiery Soul.

Rejected or stale source claims
- Reject older Shard damage-per-stack advice; the current upgrade gives Laguna Supercharge.
- Reject old Bloodstone charges, Aether Lens spell amplification and Arcane Boots disassembly advice.
- Do not use Matchup claims about removed Venomancer or Storm facets or obsolete Meepo upgrades.

Item follow-up observations for TASK-21
- TASK21: Eul can time Light Strike Array, Blink controls the cast angle, and Ethereal Blade can amplify magic damage or provide a physical save. BKB protects the combination, and Refresher needs actual Laguna mana in reserve.

Enemy counterplay observations for TASK-24
- TASK24: Evade delayed Light Strike Array, pressure fragile Lina, block or reflect Laguna, and use magic resistance or BKB. Account for innate burns and Fiery Soul stacks.

Lobby validation checklist
- Verify Light Strike Array near range edges and against moving targets, Slow Burn’s delayed damage, Shard opener timing when disables are available, and Flame Cloak stack behavior.

Focused verification
- Fengari tests/lina_ability_spec.lua: Lina ability scenarios passed, 6 scenario groups.
- Root full checks pending; no game started.

Full integration/build verification passed. Builds, skill/talent preferences and draft weights are unchanged. No game launched; engine-dependent claims remain lobby checks.

Final integrated verification: node tests/run-builds.cjs, node tests/run-objectives.cjs, node tests/valve_ability_check.cjs and git diff --check passed. Build/skill/talent preference AST comparison passed for all 49 scoped heroes. Native and applicable copied regressions are registered in run-builds. Framework callbacks and unsupported-spell dispatch preservation are covered. No game launched; the recorded lobby checklist remains required.

2026-10-02 integration API follow-up: replaced undocumented HasShard() calls with the existing modifier_item_aghanims_shard convention used by this repository. Fixtures use the actual modifier query, retaining shard state scenarios. Focused hero scenarios passed; builds and skill/talent preferences retained. Lobby verification remains required.
<!-- SECTION:NOTES:END -->

## Final Summary

<!-- SECTION:FINAL_SUMMARY:BEGIN -->
Lina standard ability pass completed offline. Native and copied behavior reviewed against Torte, full Dotacoach Strategy/Counter Strategy/Matchup and pinned Valve KV/localization. Meaningful behavior fixes and positive/negative regressions implemented; builds and flags preserved. Final integrated verification: node tests/run-builds.cjs, node tests/run-objectives.cjs, node tests/valve_ability_check.cjs and git diff --check passed. Build/skill/talent preference AST comparison passed for all 49 scoped heroes. Native and applicable copied regressions are registered in run-builds. Framework callbacks and unsupported-spell dispatch preservation are covered. No game launched; the recorded lobby checklist remains required.
<!-- SECTION:FINAL_SUMMARY:END -->
