---
id: TASK-13.116
title: 'Tinker: standard hero ability pass'
status: Needs In-Game Test
assignee:
  - '@codex'
created_date: '2026-10-02 15:37'
updated_date: '2026-10-02 16:24'
labels:
  - hero
  - weak-hero
milestone: m-0
dependencies: []
references:
  - bots/BotLib/hero_tinker.lua
  - tests/tinker_ability_spec.lua
documentation:
  - backlog/docs/doc-2 - Hero-improvement-playbook.md
modified_files:
  - bots/BotLib/hero_tinker.lua
  - bots/FunLib/rubick_hero/tinker.lua
  - tests/tinker_ability_spec.lua
parent_task_id: TASK-13
priority: medium
ordinal: 156000
---

## Description

<!-- SECTION:DESCRIPTION:BEGIN -->
Tinker is part of the requested Queen of Pain through Zeus hero-file-order batch. Review actual spell decisions against current mechanics and human usage, fixing meaningful ability-use gaps while retaining the established D2PT build.
<!-- SECTION:DESCRIPTION:END -->

## Acceptance Criteria
<!-- AC:BEGIN -->
- [x] #1 Ability decisions and cast order are reviewed against Torte de Lini, dotacoach Strategy/Counter Strategy/full Matchup and pinned Valve definitions/localization; verified checklist and stale claims are recorded
- [x] #2 Identified meaningful behavior gaps are fixed, including applicable Rubick handling, with positive and negative offline regression scenarios
- [x] #3 Focused hero scenarios, Valve ability check and full build suite pass; lobby checklist and engine limitations are recorded for Needs In-Game Test handoff
<!-- AC:END -->

## Implementation Plan

<!-- SECTION:PLAN:BEGIN -->
Repair current Laser, observed March zones, safe Turret knockback, legal Warp Flare, useful ability-only Rearm and real transport anchors.
<!-- SECTION:PLAN:END -->

## Implementation Notes

<!-- SECTION:NOTES:BEGIN -->
Source review and offline implementation for the Queen of Pain → Zeus batch (hero-file order).

Sources: Torte CLI tools/tdl/fetch.cjs tinker; https://dotacoach.gg/en/heroes/tinker and https://dotacoach.gg/en/heroes/counters/tinker (full Strategy, Counter Strategy and Matchup); Valve d2vpkr cf0d37a32c8df338a7832fd32a282747969e9a5f hero definitions plus English ability localization.

Verified ability checklist
- Read every native decision and inactive combo helper, full Torte guide 129157199, and full Dotacoach Strategy, Counter Strategy and Matchup gameplay, synergy and item cards. Verify current pinned Valve and localization.
- Laser range 600, cast 0.4, pure damage 75/150/225/300 and runtime talent AoE 250. Scepter removes 13% current/max health but no longer bounces or adds range.
- March range 300, cast 0.53, radius 900, machines speed 400, lifetime six seconds and individual robot damage 13/22/31/40. Current Scepter applies nonstacking 35-per-second heal for four seconds.
- Deploy Turrets range 600, cast 0.1, drop delay 0.5, impact radius 250, damage 40/80/120/160 and caster knockback 400 plus actual talent. Turrets seek heroes within 650/700/750/800; missile speed 1350 and lifetime 4.5 seconds.
- Warp range 700, cast 0.2, magical damage 150 and push scales from 60% cast range down to zero at max range. Rearm channel 2.75/2/1.25 and mana 100/150/200; affects_items is zero. Keen channel three seconds and requires friendly structures at level one, creeps at two or heroes at three.

Implemented behavior
- Laser respects actual range, pure damage timing, shields and reflection, chooses real physical attack threats and current AoE last hits. It does not invent Scepter bounce or percentage lethal damage.
- March aims inside the actual point range and checks real coverage, useful creep groups and human ally Scepter healing. Removed damage-times-duration lethal promises. Requests create only a bounded pending lock; an observed own cooldown increase confirms a coverage zone, while canceled requests expire.
- Current Turrets use actual impact and hero missile acquisition ranges and delay. Removed tower, creep-only and boss missile spam. Retreat can use actual caster knockback with root, Rupture, Coil and safe landing guards; close offensive drops preserve caster safety. No full missile volley is promised as lethal.
- Warp requires actual legal shields, fresh control and relevant pursuit, low-health human ally danger or a verified magical kill. It avoids pushing already disabled targets out of existing control.
- Rearm requires an actual available trained Tinker spell with cooldown longer than its channel, sufficient mana for an ensuing spell and teleport reserve, useful context and no nearby enemy, recent damage or incoming projectile. Missing copied siblings decline safely and item cooldowns cannot justify Rearm.
- Keen chooses a living actual allied anchor for its level, predicts arrival safety and supports low-resource recovery, lane return and an actual human ally fight. It rejects roots, Rupture, Coil, X Mark and imminent channel interruption, and uses the engine runtime point/unit shape.
- Native and copied paths preserve observed Rearm/TP phases and modifiers before ordinary casts; queue and channel locks remain intact. Unknown copied dispatch returns nil before lookups. Removed obsolete Matrix point fallback and unreachable missing-Missile combo functions.
- March cooldown confirmation requires the exact requesting ability handle; replacing or losing a copied spell discards pending coverage rather than attributing another handle cooldown to a canceled cast.

Rejected or stale source claims
- The Torte guide and many Matchup cards still describe removed Defense Matrix, Heat-Seeking Missile, repair facet and Rearm item refresh. Current data supplies Turrets, Scepter March healing and ability-only Rearm.
- Scepter Laser bounce and bonus-range prose is obsolete in 7.41; health reduction remains current.

Item follow-up observations for TASK-21
- TASK-21: Lens extends actual cast range, Blink supports positioning, BKB prevents channel disruption, Shard supplies Warp and Scepter upgrades current basic spells. Rearm does not refresh Blink, Hex, Dagon or other item cooldowns. Preserve builds and shared item policy.

Enemy counterplay observations for TASK-24
- TASK-24: silence, forced movement, X Mark and ranged initiation interrupt Rearm/TP; vision exposes tree-line positioning. Respect Linken/Lotus, Blade Mail, Carapace and debuff immunity. No enemy cooldown knowledge or permanent item disable loop is assumed.

Lobby validation checklist
- No game was launched. Verify March observed cooldown promotion and actual zone geometry, spawn travel and healing. A confirmed cast is not a guaranteed number of robot collisions; no robot lethal total is inferred.
- Verify actual Turret caster knockback direction, hero-only missile acquisition, moving transport anchors and runtime Keen shape. Threat-free anchors are deliberately conservative; broader map teleport selection remains separate map-awareness work.
- Copied Rearm is conservative and considers actual visible trained Tinker siblings only, rather than guessing that every unrelated native/copied spell can be refreshed. Verify engine refresh scope before broadening this.

Focused verification
- Focused native/copied Fengari scenarios passed for exact ranges and Break, pure damage/regeneration/shields, actual AoE, canceled versus observed March casts, human Scepter healing, Turret acquisition and self-knockback safety, legal Warp support, actual cooldown/channel/mana Rearm decisions, item-only refusal, real anchors and level restrictions, observed busy locks and nil-first unknown dispatch.
- Valve check passed at 128 native heroes and 115 copied modules with zero findings; owned whitespace is clean. Shared registration and full suite are root-owned.
- Audited fractional special values against pinned data. Focused fixtures truncate integer getters toward zero and preserve float getters; all existing timing and moving-target scenarios pass with these engine semantics.
- Added replacement-handle pending-cast regression; the focused suite passes.

Full integration/build verification passed. Builds, skill/talent preferences and draft weights are unchanged. No game launched; engine-dependent claims remain lobby checks.

Final integrated verification: node tests/run-builds.cjs, node tests/run-objectives.cjs, node tests/valve_ability_check.cjs and git diff --check passed. Build/skill/talent preference AST comparison passed for all 43 scoped heroes. Native and applicable copied regressions are registered in run-builds. Framework callbacks and unsupported-spell dispatch preservation are covered. No game launched; the recorded lobby checklist remains required.
<!-- SECTION:NOTES:END -->

## Final Summary

<!-- SECTION:FINAL_SUMMARY:BEGIN -->
Tinker standard ability pass completed offline. Native and copied behavior reviewed against Torte and full Dotacoach Strategy/Counter Strategy/Matchup and pinned Valve KV/localization. Meaningful behavior fixes and positive/negative regressions implemented; builds and flags preserved. Final integrated verification: node tests/run-builds.cjs, node tests/run-objectives.cjs, node tests/valve_ability_check.cjs and git diff --check passed. Build/skill/talent preference AST comparison passed for all 43 scoped heroes. Native and applicable copied regressions are registered in run-builds. Framework callbacks and unsupported-spell dispatch preservation are covered. No game launched; the recorded lobby checklist remains required.
<!-- SECTION:FINAL_SUMMARY:END -->
