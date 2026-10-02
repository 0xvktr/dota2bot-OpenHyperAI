---
id: TASK-13.78
title: 'Primal Beast: standard hero ability pass'
status: Needs In-Game Test
assignee:
  - '@codex'
created_date: '2026-10-02 09:09'
updated_date: '2026-10-02 16:17'
labels:
  - hero
  - weak-hero
milestone: m-0
dependencies: []
references:
  - bots/BotLib/hero_primal_beast.lua
  - tests/primal_beast_ability_spec.lua
documentation:
  - backlog/docs/doc-2 - Hero-improvement-playbook.md
modified_files:
  - bots/BotLib/hero_primal_beast.lua
  - bots/FunLib/rubick_hero/primal_beast.lua
parent_task_id: TASK-13
priority: medium
ordinal: 118000
---

## Description

<!-- SECTION:DESCRIPTION:BEGIN -->
Primal Beast is part of the requested Ember Spirit through Pugna hero-file-order batch. Review actual spell decisions against current mechanics and human usage, fixing meaningful ability-use gaps while retaining the established D2PT build.
<!-- SECTION:DESCRIPTION:END -->

## Acceptance Criteria
<!-- AC:BEGIN -->
- [x] #1 Ability decisions and cast order are reviewed against Torte de Lini, dotacoach Strategy/Counter Strategy/full Matchup and pinned Valve definitions/localization; verified checklist and stale claims are recorded
- [x] #2 Identified meaningful behavior gaps are fixed, including applicable Rubick handling, with positive and negative offline regression scenarios
- [x] #3 Focused hero scenarios, Valve ability check and full build suite pass; lobby checklist and engine limitations are recorded for Needs In-Game Test handoff
<!-- AC:END -->

## Implementation Plan

<!-- SECTION:PLAN:BEGIN -->
Use observed Onslaught windup, release and movement continuation, movement-step Trample damage, real Uproar stacks during channels, actual Pulverize range and current Rock Throw geometry.
<!-- SECTION:PLAN:END -->

## Implementation Notes

<!-- SECTION:NOTES:BEGIN -->
Source review and offline implementation for the Ember Spirit → Pugna batch (hero-file order).

Sources: Torte CLI tools/tdl/fetch.cjs primal_beast; https://dotacoach.gg/en/heroes/primal-beast and https://dotacoach.gg/en/heroes/counters/primal-beast (full Strategy, Counter Strategy and Matchup); Valve d2vpkr cf0d37a32c8df338a7832fd32a282747969e9a5f hero definitions plus English ability localization.

Verified ability checklist
- Fetched and read TDL guide 2762905224 and full Strategy, Counter Strategy and Matchup: https://dotacoach.gg/en/heroes/primal-beast and https://dotacoach.gg/en/heroes/counters/primal-beast.
- Valve Onslaught deals physical, nonpiercing damage 75/170/265/360 plus its talent. Maximum distance is 2000, movement speed 1200, maximum charge 1.7 seconds, windup limit 2.2 seconds and collision radius 190. Roots prevent casting; release supports IGNORE_CHANNEL.
- Trample deals magical, nonpiercing damage for every 140 units traveled, within 200 radius for 5.5 seconds. Damage is 15/30/45/60 plus 35% total attack damage and the talent. It is not a damage-per-second spell. Uproar has up to six stacks, radius 900 and seven-second buffs.
- Pulverize has actual cast range 200, channel duration 2.3 seconds, interval 0.75, damage 100/150/200/250 plus 20/40/60 consecutive-hit bonus, and splash radius 575. Current KV and ability metadata support piercing control; blanket immunity-counter advice is stale.
- Shard Rock Throw deals 325 physical, nonpiercing damage, has cast range 1800, minimum target distance 550, impact radius 225, travel time 0.65 to 1.75 seconds and stun 1.4 seconds. Fragments travel 525 with radius 185; three fragment hits are not guaranteed.

Implemented behavior
- Onslaught now tracks the real windup, goal and elapsed charge, releases toward useful destinations and continues only through observed movement states. Escape, safe approach and close physical kills use current mechanics.
- Trample requires useful movement and reachable nonimmune victims or real local creep packs. Existing roam status fields are preserved; activation during an actual forward Onslaught is supported.
- Uproar uses actual available stacks during Trample or Pulverize. IGNORE_CHANNEL activation does not require Scepter.
- Pulverize uses actual cast range plus Lens and unbroken Supremacy, interrupts channels and estimates one reliable hit. Existing BKB preparation is preserved.
- Rock Throw enforces its minimum point distance, predicts travel and clamps area casts. It respects physical mitigation, regeneration, immunity and real creep packs without assuming all fragments hit.
- Added six independent copied actives with native ConsiderPrimalContinuation and copied ConsiderStolenPrimalContinuation callbacks for exact observed states.

Rejected or stale source claims
- Rejected Strength-only Trample damage, guaranteed full movement damage, old Arcane Boots disassembly and Halberd remaining effective through immunity.
- Rejected armor reduction amplifying Trample or Sun Ray, Nether Ward ignoring physical spells, guaranteed charge-collision victories and blanket immunity blocking Pulverize control.

Item follow-up observations for TASK-21
- TASK-21: Movement speed adds Trample steps; Blink sets up Pulverize or escape; BKB preparation protects the channel; Scepter adds Uproar break projectiles during channels; Shard adds Rock Throw setup. Other Soul Ring, ethereal, Shiva and Vessel policies remain for the item pass.

Enemy counterplay observations for TASK-24
- TASK-24: Dodge the charge, kite Trample movement, use roots, leash or Rupture against mobility, interrupt Pulverize with suitable control, and respect reflection. Debuff immunity does not deny current Pulverize control.

Lobby validation checklist
- Validate Onslaught using/channel flags, charge power and distance, facing and release callback, stolen linked release availability, Uproar during native or stolen Pulverize, Rock Throw minimum impact area and fragments, and Trample movement steps. No live game validation was performed.

Focused verification
- Fengari tests/primal_beast_ability_spec.lua passed; native, copied handler and spec parsed as Lua 5.2.

Full integration/build verification passed. Builds, skill/talent preferences and draft weights are unchanged. No game launched; engine-dependent claims remain lobby checks.

Final integrated verification: node tests/run-builds.cjs, node tests/run-objectives.cjs, node tests/valve_ability_check.cjs and git diff --check passed. Build/skill/talent preference AST comparison passed for all 49 scoped heroes. Native and applicable copied regressions are registered in run-builds. Framework callbacks and unsupported-spell dispatch preservation are covered. No game launched; the recorded lobby checklist remains required.

2026-10-02 shared movement safety follow-up: pinned English localization explicitly names modifier_puck_coiled (Dream Coiled). Replaced inherited modifier_puck_dream_coil checks with the actual debuff name in this previously passed hero. This is a narrow API/mechanics correction; preference assignments remain intact. The final Queen of Pain → Zeus integrated suite covers these files; lobby movement validation remains required.
<!-- SECTION:NOTES:END -->

## Final Summary

<!-- SECTION:FINAL_SUMMARY:BEGIN -->
Primal Beast standard ability pass completed offline. Native and copied behavior reviewed against Torte, full Dotacoach Strategy/Counter Strategy/Matchup and pinned Valve KV/localization. Meaningful behavior fixes and positive/negative regressions implemented; builds and flags preserved. Final integrated verification: node tests/run-builds.cjs, node tests/run-objectives.cjs, node tests/valve_ability_check.cjs and git diff --check passed. Build/skill/talent preference AST comparison passed for all 49 scoped heroes. Native and applicable copied regressions are registered in run-builds. Framework callbacks and unsupported-spell dispatch preservation are covered. No game launched; the recorded lobby checklist remains required.
<!-- SECTION:FINAL_SUMMARY:END -->
