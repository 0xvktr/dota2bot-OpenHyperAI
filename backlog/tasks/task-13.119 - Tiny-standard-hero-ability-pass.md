---
id: TASK-13.119
title: 'Tiny: standard hero ability pass'
status: Needs In-Game Test
assignee:
  - '@codex'
created_date: '2026-10-02 15:47'
updated_date: '2026-10-02 16:24'
labels:
  - hero
dependencies: []
references:
  - bots/BotLib/hero_tiny.lua
  - tests/tiny_ability_spec.lua
documentation:
  - backlog/docs/doc-2 - Hero-improvement-playbook.md
modified_files:
  - bots/BotLib/hero_tiny.lua
  - bots/FunLib/rubick_hero/tiny.lua
  - tests/tiny_ability_spec.lua
parent_task_id: TASK-13
priority: medium
ordinal: 159000
---

## Description

<!-- SECTION:DESCRIPTION:BEGIN -->
Tiny is part of the requested Queen of Pain through Zeus hero-file-order batch. Review actual spell decisions against current mechanics and human usage, fixing meaningful ability-use gaps while retaining the established D2PT build.
<!-- SECTION:DESCRIPTION:END -->

## Acceptance Criteria
<!-- AC:BEGIN -->
- [x] #1 Ability decisions and cast order are reviewed against Torte de Lini, dotacoach Strategy/Counter Strategy/full Matchup and pinned Valve definitions/localization; verified checklist and stale claims are recorded
- [x] #2 Identified meaningful behavior gaps are fixed, including applicable Rubick handling, with positive and negative offline regression scenarios
- [x] #3 Focused hero scenarios, Valve ability check and full build suite pass; lobby checklist and engine limitations are recorded for Needs In-Game Test handoff
<!-- AC:END -->

## Implementation Plan

<!-- SECTION:PLAN:BEGIN -->
Repair nearest-passenger Toss safety, serial current Avalanche/Toss decisions, exact tree casts and legal current Tree Volley opportunities.
<!-- SECTION:PLAN:END -->

## Implementation Notes

<!-- SECTION:NOTES:BEGIN -->
Source review and offline implementation for the Queen of Pain → Zeus batch (hero-file order).

Sources: Torte CLI tools/tdl/fetch.cjs tiny; https://dotacoach.gg/en/heroes/tiny and https://dotacoach.gg/en/heroes/counters/tiny (full Strategy, Counter Strategy and Matchup); Valve d2vpkr cf0d37a32c8df338a7832fd32a282747969e9a5f hero definitions plus English ability localization.

Verified ability checklist
- Read the entire native SkillsComplement and every Consider and inactive combo, full Torte guide 161358226 and intended Tiny Dotacoach Strategy, Counter Strategy and complete Matchup synergy, matchup and advanced item cards. Verify pinned Valve and English localization.
- Avalanche range 600 plus actual runtime talent, radius 325/340/355/370, projectile speed 1200 and damage 90/180/270/360 over 1.5 seconds. Toss grabs the nearest eligible unit within 300, casts toward a unit within 800/900/1000/1100, flight lasts 1.1 seconds and damage is 90/180/270/360 plus an actual trained Grow bonus of 50/200/350.
- Tree Grab uses an actual tree within 200 and grants five/eight attacks by level, plus actual talent. Tree Throw range 1000, speed 900 and physical damage; it does not pierce debuff immunity. Runtime Shard changes splash and damage, rather than granting infinite held-tree attacks.
- Current Tree Volley is granted by Scepter, range 1200, channel 2.5, tree collection radius 700, interval 0.5 and projectile speed 1000. It deals physical damage and pierces debuff immunity. Current data does not establish the old Avalanche/Toss damage amplification.

Implemented behavior
- Toss proves the nearest eligible passenger using both teams of heroes and creeps and nearby neutrals, rejects uncertain ties, and never throws a healthy nearby human ally into an offensive destination. Human ally saves require actual recent damage, low health and a legal friendly destination substantially closer to escape with safe landing. Channeling and protected allied control states decline.
- Enemy channel interruption and retreat Toss have priority. Ordinary Avalanche and Toss execute one spell per tick from current observed positions; removed blind Blink, action clearing and fixed delayed multi-spell queues. Runtime no-target Toss shape is supported only for a verified enemy passenger; copied missing Grow does not invent bonus damage.
- Avalanche predicts projectile arrival and actual point range, supports real human allies under attack, uses complete damage duration and regeneration for lethal decisions, and preserves actual Toss mana on useful creep groups.
- Tree Grab uses actual nearby tree IDs inside actual range. Tree Throw requires the actual owned held-tree modifier source and caster, respects physical immunity and shields, includes travel time, and preserves remaining held attacks at close range. It uses current attack damage as a conservative lethal lower bound to avoid adding an already applied tree bonus twice.
- Tree Volley now accepts its actual available runtime Scepter spell, checks at least two nearby trees and an uninterrupted safe channel, and supports useful distant targets including debuff-immune but physically vulnerable enemies. It does not promise an unverified full-volley lethal total. Unknown copied dispatch returns nil before any gates or lookups.
- Displacement rejects the actual Dream Coil modifier and Rupture on the unit that would move, including human ally Cookie and Toss recipients.
- Emergency unit-target Toss respects its actual destination shield and reflection gate; runtime no-target pickup remains independent of unit spell shields.

Rejected or stale source claims
- Removed inverted Scepter Tree Volley refusal and obsolete large-range Tree Grab queries. Guide references to older Avalanche/Toss amplification and permanent Shard tree attacks are not encoded as current mechanics.

Item follow-up observations for TASK-21
- TASK-21: Blink, Echo Sabre and crit items help positioning and attacks; shared item preparation remains in charge of items. No blind Blink/Toss or inferred full crit/echo volley total. Lens and actual unbroken Supremacy extend legal cast ranges. Preserve all builds.

Enemy counterplay observations for TASK-24
- TASK-24: nearby heroes and creeps can change the actual Toss passenger. Debuff immunity prevents grabbing an enemy but can still permit destination targeting; ordinary offensive decisions remain conservative. Shields, reflection, Blade Mail, Carapace, physical immunity and unsafe landings are respected.

Lobby validation checklist
- No game was launched. Verify runtime no-target Toss behavior and exact pickup eligibility, observed held-tree modifier source exposure and enemy Toss destinations. Ancient creeps and uncertain ties deliberately decline.
- Tree Throw lethal checks omit unverified additional current Shard/Grow attack interactions; Volley does not assume every collected tree hits. Broader item-assisted Toss displacement remains item policy work.

Focused verification
- Tiny native/copied focused Fengari scenarios passed for nearest-unit interference and ties, actual human saves and prohibited channel states, missing Grow and linked tree handles, exact ranges and Break, fractional 1.1/1.5 timing with regeneration, physical/debuff immunity distinctions, available Scepter Volley, runtime cast shapes, unavailable handles and queue/channel locks. Integer fixtures truncate toward zero and float getters preserve fractions.
- Valve ability check passed at 128 heroes and 119 copied modules with zero findings. Shared registration and full suite are root-owned.
- Verified real pinned Dream Coil modifier modifier_puck_coiled with a focused displacement refusal regression.

Full integration/build verification passed. Builds, skill/talent preferences and draft weights are unchanged. No game launched; engine-dependent claims remain lobby checks.

Final integrated verification: node tests/run-builds.cjs, node tests/run-objectives.cjs, node tests/valve_ability_check.cjs and git diff --check passed. Build/skill/talent preference AST comparison passed for all 43 scoped heroes. Native and applicable copied regressions are registered in run-builds. Framework callbacks and unsupported-spell dispatch preservation are covered. No game launched; the recorded lobby checklist remains required.
<!-- SECTION:NOTES:END -->

## Final Summary

<!-- SECTION:FINAL_SUMMARY:BEGIN -->
Tiny standard ability pass completed offline. Native and copied behavior reviewed against Torte and full Dotacoach Strategy/Counter Strategy/Matchup and pinned Valve KV/localization. Meaningful behavior fixes and positive/negative regressions implemented; builds and flags preserved. Final integrated verification: node tests/run-builds.cjs, node tests/run-objectives.cjs, node tests/valve_ability_check.cjs and git diff --check passed. Build/skill/talent preference AST comparison passed for all 43 scoped heroes. Native and applicable copied regressions are registered in run-builds. Framework callbacks and unsupported-spell dispatch preservation are covered. No game launched; the recorded lobby checklist remains required.
<!-- SECTION:FINAL_SUMMARY:END -->
