---
id: TASK-13.86
title: 'Sniper: standard hero ability pass'
status: Needs In-Game Test
assignee:
  - '@codex'
created_date: '2026-10-02 14:23'
updated_date: '2026-10-02 16:24'
labels:
  - hero
dependencies: []
references:
  - bots/BotLib/hero_sniper.lua
  - tests/sniper_ability_spec.lua
documentation:
  - backlog/docs/doc-2 - Hero-improvement-playbook.md
modified_files:
  - bots/BotLib/hero_sniper.lua
  - bots/FunLib/rubick_hero/sniper.lua
  - tests/sniper_ability_spec.lua
parent_task_id: TASK-13
priority: medium
ordinal: 126000
---

## Description

<!-- SECTION:DESCRIPTION:BEGIN -->
Sniper is part of the requested Queen of Pain through Zeus hero-file-order batch. Review actual spell decisions against current mechanics and human usage, fixing meaningful ability-use gaps while retaining the established D2PT build.
<!-- SECTION:DESCRIPTION:END -->

## Acceptance Criteria
<!-- AC:BEGIN -->
- [x] #1 Ability decisions and cast order are reviewed against Torte de Lini, dotacoach Strategy/Counter Strategy/full Matchup and pinned Valve definitions/localization; verified checklist and stale claims are recorded
- [x] #2 Identified meaningful behavior gaps are fixed, including applicable Rubick handling, with positive and negative offline regression scenarios
- [x] #3 Focused hero scenarios, Valve ability check and full build suite pass; lobby checklist and engine limitations are recorded for Needs In-Game Test handoff
<!-- AC:END -->

## Implementation Plan

<!-- SECTION:PLAN:BEGIN -->
Repair charged Shrapnel zoning, improve Take Aim range and movement decisions, prioritize safe Concussive Grenade peel, and use actual Assassinate arrival timing and target protection. Add native and copied regressions.
<!-- SECTION:PLAN:END -->

## Implementation Notes

<!-- SECTION:NOTES:BEGIN -->
Source review and offline implementation for the Queen of Pain → Zeus batch (hero-file order).

Sources: Torte CLI tools/tdl/fetch.cjs sniper; https://dotacoach.gg/en/heroes/sniper and https://dotacoach.gg/en/heroes/counters/sniper (full Strategy, Counter Strategy and Matchup); Valve d2vpkr cf0d37a32c8df338a7832fd32a282747969e9a5f hero definitions plus English ability localization.

Verified ability checklist
- Read every native consideration, full Torte guide 319109248, complete Dotacoach Strategy and Counter Strategy, all Matchup synergy and gameplay cards, and all core and counter item cards. Verify mechanics against pinned Valve cf0d37a32c8df338a7832fd32a282747969e9a5f and English localization.
- Shrapnel has range 1800, three charges, delay 1.2, duration 10, radius 400/425/450/475 and damage 30/45/60/75 per tick. Runtime values support changed delay or duration; localization states it does not damage buildings.
- Take Aim grants passive range 160/240/320/400 and active range 75/150/225/300, Headshot chance 100%, movement slow 65%, vision and a frontal vision restriction. A copied Take Aim does not invent an absent Headshot passive.
- Assassinate has range 3000, normal aiming duration two seconds, Scepter aiming duration 0.5, projectile speed 2500, magical damage 300/400/500 and Scepter stun 0.8/1/1.2. KV attack_factor is zero while localization describes attack damage; kill checks conservatively use the verified magical component.
- Shard Concussive Grenade has range 600, radius 375, damage 200, knockback 475 over 0.4 seconds, and a three-second slow and disarm. Real ability readiness controls availability.
- Spell ranges use actual Lens 225 and trained, unbroken Rubick Supremacy 240. Ordinary occupied-state, silence, invisibility and queue gates are preserved.

Implemented behavior
- Track each queued Shrapnel request separately and promote its zone only after observing a charge decrement. Failed pending requests expire after three seconds; confirmed zones expire from observed cast time plus actual onset and duration. Multiple separate areas are possible and real live overlap remains suppressed.
- Removed the broken AoE count spelling and stale aiming offsets. Predict Shrapnel onset and clamp the point to actual range, verify target coverage, and conserve the final charge while farming.
- Take Aim can activate for targets in the extra active range and for farming or boss attacks. Avoid use while fleeing without attacking, during an existing buff, when disarmed, or against attack-immune or reflecting targets.
- Assassinate uses actual aim and projectile travel for regeneration-aware kills and teleport interruption. Advanced target protection prevents wasting a targeted cast on block or reflection. Observed ally support permits Scepter initiation.
- Concussive Grenade peels a pursuer or current attacker before damage spells. Reject a root or Rupture and test the self-knockback destination against terrain, towers, Chronosphere and Black Hole.
- Preserved native attack retargeting and the existing MKB item preparation callback, with the current target read before considering a replacement. The copied handler rejects unknown spells before any gate or linked lookup.
- Displacement rejects the actual Dream Coil modifier and Rupture on the unit that would move, including human ally Cookie and Toss recipients.

Rejected or stale source claims
- Old Shrapnel overlap state never expired and suppressed new casts near a previously used location indefinitely.
- The guide includes outdated talent and item comments. They do not change the retained D2PT builds. Attack procs, Keen Scope and Headshot are not assumed in copied Assassinate damage, and the KV versus tooltip attack component remains an explicit engine verification item.

Item follow-up observations for TASK-21
- TASK-21 follow-up: Pike, Force Staff, Blink and Shard create space against gap closers. Take Aim before Mask of Madness can preserve spell access, while Scepter improves long-range control. Mjollnir, Satanic, BKB, Phylactery and Khanda depend on build and opposing threats; no item lists or shared item policies changed.

Enemy counterplay observations for TASK-24
- TASK-24 follow-up: Respect Lotus, block, Blade Mail, Carapace, magic and attack immunity, disarm and undying effects. Storm, Spectre, Spirit Breaker, Pudge and other observed gap closers threaten Sniper positioning. Allied frontliners, saves, Cogs and Arena provide safe attack opportunities. Smoke and movement can disrupt enemy attempts to finish a marked target; no enemy cooldown API is used.

Lobby validation checklist
- No game was launched. Verify Shrapnel charge consumption and restoration around queued item preparation. The confirmation path uses an observed charge decrement; a simultaneous recharge that masks the decrement can conservatively miss confirmation. Failed pending requests expire after three seconds, and confirmed zones use their observed cast time.
- Verify Take Aim extended-range attack acquisition and vision restriction for native and copied spells, Concussive Grenade self displacement and terrain safety, and Assassinate Scepter aim duration.
- Measure actual Assassinate attack damage and procs because pinned KV attack_factor contradicts localization. Current kill decisions deliberately rely on the independently verified magic damage component.

Focused verification
- Focused Sniper native/copied ability scenarios passed under Fengari.
- Valve ability check passed: 128 native hero files, 86 copied modules, zero findings. Owned diff whitespace check passed.
- Scenarios cover multiple zone records and expiration, exact spell range and radius coverage, prediction, farming charge reserve, Take Aim active range and movement/disarm/buff gates, Assassinate regeneration, Scepter timing, teleport arrival, block/reflection, Grenade peel priority and unsafe landings, invisibility, channel, queues, unavailable handles and copied nil-first unknown contract.
- Full integration and build suite remain root-owned.
- Added canceled-queue versus observed-charge regression: no live zone before consumption, pending request expires when canceled, and actual consumption promotes one zone with expiry relative to confirmation. Updated focused Sniper spec passed.
- Audited fractional special values against pinned data. Focused fixtures truncate integer getters toward zero and preserve float getters; all existing timing and moving-target scenarios pass with these engine semantics.
- Verified real pinned Dream Coil modifier modifier_puck_coiled with a focused displacement refusal regression.

Full integration/build verification passed. Builds, skill/talent preferences and draft weights are unchanged. No game launched; engine-dependent claims remain lobby checks.

Final integrated verification: node tests/run-builds.cjs, node tests/run-objectives.cjs, node tests/valve_ability_check.cjs and git diff --check passed. Build/skill/talent preference AST comparison passed for all 43 scoped heroes. Native and applicable copied regressions are registered in run-builds. Framework callbacks and unsupported-spell dispatch preservation are covered. No game launched; the recorded lobby checklist remains required.
<!-- SECTION:NOTES:END -->

## Final Summary

<!-- SECTION:FINAL_SUMMARY:BEGIN -->
Sniper standard ability pass completed offline. Native and copied behavior reviewed against Torte and full Dotacoach Strategy/Counter Strategy/Matchup and pinned Valve KV/localization. Meaningful behavior fixes and positive/negative regressions implemented; builds and flags preserved. Final integrated verification: node tests/run-builds.cjs, node tests/run-objectives.cjs, node tests/valve_ability_check.cjs and git diff --check passed. Build/skill/talent preference AST comparison passed for all 43 scoped heroes. Native and applicable copied regressions are registered in run-builds. Framework callbacks and unsupported-spell dispatch preservation are covered. No game launched; the recorded lobby checklist remains required.
<!-- SECTION:FINAL_SUMMARY:END -->
