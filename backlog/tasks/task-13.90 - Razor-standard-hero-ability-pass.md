---
id: TASK-13.90
title: 'Razor: standard hero ability pass'
status: Needs In-Game Test
assignee:
  - '@codex'
created_date: '2026-10-02 14:33'
updated_date: '2026-10-02 16:24'
labels:
  - hero
dependencies: []
references:
  - bots/BotLib/hero_razor.lua
  - tests/razor_ability_spec.lua
documentation:
  - backlog/docs/doc-2 - Hero-improvement-playbook.md
modified_files:
  - bots/BotLib/hero_razor.lua
  - bots/FunLib/rubick_hero/razor.lua
  - tests/razor_ability_spec.lua
  - bots/FunLib/razor_abilities.lua
parent_task_id: TASK-13
priority: medium
ordinal: 130000
---

## Description

<!-- SECTION:DESCRIPTION:BEGIN -->
Razor is part of the requested Queen of Pain through Zeus hero-file-order batch. Review actual spell decisions against current mechanics and human usage, fixing meaningful ability-use gaps while retaining the established D2PT build.
<!-- SECTION:DESCRIPTION:END -->

## Acceptance Criteria
<!-- AC:BEGIN -->
- [x] #1 Ability decisions and cast order are reviewed against Torte de Lini, dotacoach Strategy/Counter Strategy/full Matchup and pinned Valve definitions/localization; verified checklist and stale claims are recorded
- [x] #2 Identified meaningful behavior gaps are fixed, including applicable Rubick handling, with positive and negative offline regression scenarios
- [x] #3 Focused hero scenarios, Valve ability check and full build suite pass; lobby checklist and engine limitations are recorded for Needs In-Game Test handoff
<!-- AC:END -->

## Implementation Plan

<!-- SECTION:PLAN:BEGIN -->
Correct Static Link immunity and real cast range, prioritize physical threats, model Plasma outward impact and current physical Eye behavior including Refresher and Scepter. Preserve native farming and ability-aware preparation.
<!-- SECTION:PLAN:END -->

## Implementation Notes

<!-- SECTION:NOTES:BEGIN -->
Source review and offline implementation for the Queen of Pain → Zeus batch (hero-file order).

Sources: Torte CLI tools/tdl/fetch.cjs razor; https://dotacoach.gg/en/heroes/razor and https://dotacoach.gg/en/heroes/counters/razor (full Strategy, Counter Strategy and Matchup); Valve d2vpkr cf0d37a32c8df338a7832fd32a282747969e9a5f hero definitions plus English ability localization.

Verified ability checklist
- Full Torte guide 128756420, intended Razor Strategy and Counter Strategy, and all Matchup synergy, gameplay and item cards were read and compared to pinned KV and localization.
- Plasma Field: nonimmune magic, 700 radius, 50 to 185 damage per pass, total expansion/contraction time 2.2 seconds. Current talent creates a delayed second field; no extra instant damage is assumed.
- Static Link: unit target enemy hero, debuff-immunity piercing, 550 base range, 65 mana and 0.3 cast point; drains 24 damage per second for 10 seconds and stolen/lost damage persists up to 18 seconds. Real source ownership is checked on an existing target debuff.
- Storm Surge is breakable reflected damage with 20 percent trigger and 2.5 second internal cooldown. Current Shard enhances Surge during Eye, rather than pulling Static Link targets. Unstable Current is a breakable movement innate.
- Eye of the Storm: physical, pierces debuff immunity, 500 radius, 30 seconds, 90 damage per strike and 0.5 second level-three interval. Real repeated casts stack; Scepter strikes an extra target and eligible structures.
- Focused special-value fixtures now truncate the integer API and preserve the float API; fractional timing audit found no production misuse in this pass.

Implemented behavior
- Added shared decisions and a canonical copied handler for Plasma, Link and Eye; missing linked passives are never presumed.
- Removed invented Link range padding, used actual Lens and unbroken Supremacy, selected the highest physical damage threat and added threatened human/bot ally protection.
- Skipped duplicate same-source Link debuffs while permitting foreign-source targets and a Refresher second Link on a different enemy.
- Plasma lethal decisions count only the outward hit with actual distance scaling, predicted movement and regeneration at impact. Rejected magic-immune and reflected damage targets.
- Eye uses its real physical immunity rules and radius, permits useful Refresher stacking and Scepter structure pressure, and adds native stack/ancient and objective decisions.
- Preserved native lane and farm Plasma use with real range and first-hit damage; passed actual ability handles to item preparation.

Rejected or stale source claims
- Excluded old Static Link Shard pulls, old spell-lifesteal talent, universal invulnerable Link targeting, Arcane Boots/Vanguard disassembly advice, and reflected Storm Surge lifesteal claims. Matchup assertions that creeps block Plasma or Attribute Shift automatically breaks Link were not adopted.

Item follow-up observations for TASK-21
- TASK-21: BKB, mobility and dispels help sustain Link; Refresher allows independent Eye instances and another Link. Current Surge reflected damage provides no lifesteal, so old Bloodstone/Shard sustain assumptions require revision outside this pass. No build/item changes.

Enemy counterplay observations for TASK-24
- TASK-24: Force Staff/Pike distance, Linken and Lotus affect Link; magic immunity blocks Plasma, while ethereal and attack immunity suppress physical Eye. Rupture punishes chase. No generic counterplay changes.

Lobby validation checklist
- Confirm expansion/contraction timing under live AoE modifiers; outward-only lethal prediction is deliberately conservative when targets can leave before the returning ring.
- Confirm source attribution and duration of lingering Link debuffs with two Razor sources, copied spells and Refresher.
- Confirm Scepter structure eligibility, active repeated Eye instances and random/linked target priority with Shard Surge triggers.

Focused verification
- Fengari: 27 meaningful native/copied scenarios passed.
- Lua 5.2 native/copied/companion/spec parsing and owned whitespace check passed.

Full integration/build verification passed. Builds, skill/talent preferences and draft weights are unchanged. No game launched; engine-dependent claims remain lobby checks.

Final integrated verification: node tests/run-builds.cjs, node tests/run-objectives.cjs, node tests/valve_ability_check.cjs and git diff --check passed. Build/skill/talent preference AST comparison passed for all 43 scoped heroes. Native and applicable copied regressions are registered in run-builds. Framework callbacks and unsupported-spell dispatch preservation are covered. No game launched; the recorded lobby checklist remains required.
<!-- SECTION:NOTES:END -->

## Final Summary

<!-- SECTION:FINAL_SUMMARY:BEGIN -->
Razor standard ability pass completed offline. Native and copied behavior reviewed against Torte and full Dotacoach Strategy/Counter Strategy/Matchup and pinned Valve KV/localization. Meaningful behavior fixes and positive/negative regressions implemented; builds and flags preserved. Final integrated verification: node tests/run-builds.cjs, node tests/run-objectives.cjs, node tests/valve_ability_check.cjs and git diff --check passed. Build/skill/talent preference AST comparison passed for all 43 scoped heroes. Native and applicable copied regressions are registered in run-builds. Framework callbacks and unsupported-spell dispatch preservation are covered. No game launched; the recorded lobby checklist remains required.
<!-- SECTION:FINAL_SUMMARY:END -->
