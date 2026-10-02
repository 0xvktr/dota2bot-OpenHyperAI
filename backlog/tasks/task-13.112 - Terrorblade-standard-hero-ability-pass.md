---
id: TASK-13.112
title: 'Terrorblade: standard hero ability pass'
status: Needs In-Game Test
assignee:
  - '@codex'
created_date: '2026-10-02 15:24'
updated_date: '2026-10-02 16:24'
labels:
  - hero
dependencies: []
references:
  - bots/BotLib/hero_terrorblade.lua
  - tests/terrorblade_ability_spec.lua
documentation:
  - backlog/docs/doc-2 - Hero-improvement-playbook.md
modified_files:
  - bots/BotLib/hero_terrorblade.lua
  - bots/FunLib/rubick_hero/terrorblade.lua
  - tests/terrorblade_ability_spec.lua
parent_task_id: TASK-13
priority: medium
ordinal: 152000
---

## Description

<!-- SECTION:DESCRIPTION:BEGIN -->
Terrorblade is part of the requested Queen of Pain through Zeus hero-file-order batch. Review actual spell decisions against current mechanics and human usage, fixing meaningful ability-use gaps while retaining the established D2PT build.
<!-- SECTION:DESCRIPTION:END -->

## Acceptance Criteria
<!-- AC:BEGIN -->
- [x] #1 Ability decisions and cast order are reviewed against Torte de Lini, dotacoach Strategy/Counter Strategy/full Matchup and pinned Valve definitions/localization; verified checklist and stale claims are recorded
- [x] #2 Identified meaningful behavior gaps are fixed, including applicable Rubick handling, with positive and negative offline regression scenarios
- [x] #3 Focused hero scenarios, Valve ability check and full build suite pass; lobby checklist and engine limitations are recorded for Needs In-Game Test handoff
<!-- AC:END -->

## Implementation Plan

<!-- SECTION:PLAN:BEGIN -->
Legal percentage-aware Sunder, current non-Metamorphosis Zeal, full-radius timed Wave, committed Meta and sustainable illusions.
<!-- SECTION:PLAN:END -->

## Implementation Notes

<!-- SECTION:NOTES:BEGIN -->
Source review and offline implementation for the Queen of Pain → Zeus batch (hero-file order).

Sources: Torte CLI tools/tdl/fetch.cjs terrorblade; https://dotacoach.gg/en/heroes/terrorblade and https://dotacoach.gg/en/heroes/counters/terrorblade (full Strategy, Counter Strategy and Matchup); Valve d2vpkr cf0d37a32c8df338a7832fd32a282747969e9a5f hero definitions plus English ability localization.

Verified ability checklist
- Read every native decision, full Torte guide 222265746 and complete Dotacoach Strategy, Counter Strategy and Matchup synergy, gameplay and advanced item cards. Verify all mechanics against pinned Valve and localization.
- Sunder range 475, cast 0.35 and runtime minimum 35/30/25%; enemies with debuff immunity cannot have their health modified. Reflection range 700 and radius 400; Conjure lasts 34 seconds with mana 50/60/70/80 and runtime health-cost facet.
- Meta transforms after 0.35 seconds and adds 300/350/400/450 attack range for 35/40/45/50 seconds. Wave uses radius 1600, spawn 0.6, speed 1000, damage 200, fear two seconds and Meta 15 seconds.
- Current Zeal costs 20% current health, provides 25 seconds of attack/movement speed and 20 regeneration, cannot be cast in Meta and is removed by Meta. Current descriptions do not promise a dispel.

Implemented behavior
- Sunder requires exact actual range, legal nonimmune targets and real block/reflect checks, selects the largest meaningful health improvement and considers player-owned illusions. Emergency real ally exchanges require actual danger and explicit post-swap safety; normal farming never drains teammates.
- Reflection predicts the point and covers human ally attack opportunities, useful retreat slow or actual multihero fights while avoiding existing debuffs.
- Conjure preserves available trained Sunder mana and adequate health, including the runtime health-cost variant. Actual attack, farm, siege and retreat contexts supply opportunity.
- Meta waits for actual attack commitment or disable and predicts transformation coverage. Meaningful building attacks respect Glyph and disarm; removed premature distance-only use.
- Zeal works outside Meta, independently of a missing copied Meta sibling, checks current health cost and incoming projectiles and rejects repeat buffs.
- Wave predicts actual wave arrival for regeneration-aware kills and retreat fear, reaches its full 1600 radius and remains available during Meta for useful fear. It avoids redundant single-target Meta refresh and does not assume a missing linked Meta range.
- Native and copied decisions share actual availability gates and nil-first unknown dispatch. Emergency Sunder issues one direct action without a preceding item toggle.

Rejected or stale source claims
- Old native Zeal required Metamorphosis, directly contradicting current localization. Old Wave used attack range instead of its real 1600 radius.
- Guide fear duration 3.75, Demon Zeal dispel, obsolete talents and Nullifier mute claims are stale; current pinned data supplies fear two seconds and no Zeal dispel promise.

Item follow-up observations for TASK-21
- TASK-21: BKB and Manta enable Sunder by preventing or removing control; Lens affects actual spell range, Pike preserves distance, Scepter supplies Wave, Shard supplies current Zeal and Refresher supports a second committed Meta. Preserve builds and shared item policy.

Enemy counterplay observations for TASK-24
- TASK-24: magic burst threatens the low health pool; silence prevents Sunder, and Linken/Lotus/debuff immunity obstruct enemy exchanges. Hex and AoE clear illusions, disarm and kiting waste Meta, and forced friendly attacks can punish illusion grouping. No enemy cooldown or speculative dispel is assumed.

Lobby validation checklist
- No game was launched. Verify Sunder percentage exchange, runtime talent minimum and player ownership of donated illusions. Ally emergency exchanges conservatively require immediate danger and a safe remaining caster health floor.
- Verify Meta commitment and Wave timing, Zeal availability and health payment, and Conjure runtime health-cost variant. Far-map illusion scouting and split-push micro remain existing minion work outside this standard ability pass.

Focused verification
- Focused native/copied Fengari scenarios passed: legal enemies and owned illusion donors, safe human ally cases, exact ranges and Break, delayed Wave regeneration and moving targets, separate missing siblings, health and mana reserves, Meta/Zeal exclusivity, human Reflection support, queues and unavailable handles, nil-first unknown dispatch.
- Valve ability check and owned whitespace checks passed; shared registration and full integration suite are root-owned.
- Audited fractional special values against pinned data. Focused fixtures truncate integer getters toward zero and preserve float getters; all existing timing and moving-target scenarios pass with these engine semantics.

Full integration/build verification passed. Builds, skill/talent preferences and draft weights are unchanged. No game launched; engine-dependent claims remain lobby checks.

Final integrated verification: node tests/run-builds.cjs, node tests/run-objectives.cjs, node tests/valve_ability_check.cjs and git diff --check passed. Build/skill/talent preference AST comparison passed for all 43 scoped heroes. Native and applicable copied regressions are registered in run-builds. Framework callbacks and unsupported-spell dispatch preservation are covered. No game launched; the recorded lobby checklist remains required.
<!-- SECTION:NOTES:END -->

## Final Summary

<!-- SECTION:FINAL_SUMMARY:BEGIN -->
Terrorblade standard ability pass completed offline. Native and copied behavior reviewed against Torte and full Dotacoach Strategy/Counter Strategy/Matchup and pinned Valve KV/localization. Meaningful behavior fixes and positive/negative regressions implemented; builds and flags preserved. Final integrated verification: node tests/run-builds.cjs, node tests/run-objectives.cjs, node tests/valve_ability_check.cjs and git diff --check passed. Build/skill/talent preference AST comparison passed for all 43 scoped heroes. Native and applicable copied regressions are registered in run-builds. Framework callbacks and unsupported-spell dispatch preservation are covered. No game launched; the recorded lobby checklist remains required.
<!-- SECTION:FINAL_SUMMARY:END -->
