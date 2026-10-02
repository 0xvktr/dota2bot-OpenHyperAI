---
id: TASK-13.54
title: 'Kez: standard hero ability pass'
status: Needs In-Game Test
assignee:
  - '@codex'
created_date: '2026-10-02 09:08'
updated_date: '2026-10-02 16:17'
labels:
  - hero
dependencies: []
references:
  - bots/BotLib/hero_kez.lua
  - tests/kez_ability_spec.lua
documentation:
  - backlog/docs/doc-2 - Hero-improvement-playbook.md
modified_files:
  - bots/BotLib/hero_kez.lua
  - bots/FunLib/kez_abilities.lua
parent_task_id: TASK-13
priority: medium
ordinal: 94000
---

## Description

<!-- SECTION:DESCRIPTION:BEGIN -->
Kez is part of the requested Ember Spirit through Pugna hero-file-order batch. Review actual spell decisions against current mechanics and human usage, fixing meaningful ability-use gaps while retaining the established D2PT build.
<!-- SECTION:DESCRIPTION:END -->

## Acceptance Criteria
<!-- AC:BEGIN -->
- [x] #1 Ability decisions and cast order are reviewed against Torte de Lini, dotacoach Strategy/Counter Strategy/full Matchup and pinned Valve definitions/localization; verified checklist and stale claims are recorded
- [x] #2 Identified meaningful behavior gaps are fixed, including applicable Rubick handling, with positive and negative offline regression scenarios
- [x] #3 Focused hero scenarios, Valve ability check and full build suite pass; lobby checklist and engine limitations are recorded for Needs In-Game Test handoff
<!-- AC:END -->

## Implementation Plan

<!-- SECTION:PLAN:BEGIN -->
Observe current weapon discipline and individual ability readiness, remove the speculative queued Scepter combo, correct current physical/pure spell contracts, and preserve useful native farming/objective behavior.
<!-- SECTION:PLAN:END -->

## Implementation Notes

<!-- SECTION:NOTES:BEGIN -->
Source review and offline implementation for the Ember Spirit → Pugna batch (hero-file order).

Sources: Torte CLI tools/tdl/fetch.cjs kez; https://dotacoach.gg/en/heroes/kez and https://dotacoach.gg/en/heroes/counters/kez (full Strategy, Counter Strategy and Matchup); Valve d2vpkr cf0d37a32c8df338a7832fd32a282747969e9a5f hero definitions plus English ability localization.

Verified ability checklist
- Switch Discipline: engine visibility/activation determines stance; cooldown 8 seconds minus level scaling. Scepter protects the first alternate cooldown within 3 seconds and refreshes Switch; no assumed scheduled rotation.
- Echo Slash: 800 directional reach, 200 radius, 70/80/90/100% attack plus 20/40/60/80 hero bonus; first hit kill only, later strike not guaranteed.
- Grappling Claw: unit/tree, 650/750/850/950 range, root forbidden; current lifesteal zero.
- Kazurai Katana: active attack/impale at 200 range, 0.5 second movement/turn lock, bleed stacks store original attacks so not treated as raw damage; Shard heal/behind stun is engine resolved.
- Raptor Dance: 1 second cast, 450 radius, 40/70/100 plus 2.5% each victim maximum health per pure slash, 4 strikes; 0.2 second invulnerability/basic dispel, current magic resistance zero.
- Falcon Rush: actual 525 rush range, no buildings, current buff observed; root, disarm, Rupture and leash guards.
- Talon Toss: fixed physical attack 60/120/180/240, unit 650/750/850/950, zero area radius, silence 2/2.25/2.5/2.75.
- Shodo Sai: directional point parry 1.5 seconds, actual attacker required; cancel requires observed parry and no reachable attackers.
- Raven’s Veil: 1500 mark/vision wave, basic dispel and invisibility/movement escape, live invisibility preserved; no invented direct damage.

Implemented behavior
- Removed manual weapon counter and blind Raven/Switch/Claw/Echo queue; each action returns immediately.
- Prioritized useful retreat Veil, actual attack parry, Raptor heal/dispel and Toss channel interruption.
- Shared native/copied combat helpers use actual physical/pure gates, real ranges, immunity/block/reflect and live buff checks.
- Safe retreat Claw tests each current tree/creep, correct radians, baseward direction, real range/passability and no stronger enemy arrival cluster.
- Preserved Echo farm/laning/objective and Falcon farm/objective branches; removed Falcon building casts; corrected Toss lane last-hit damage type.
- New copied module covers independent real actives and AD aliases without Switch/linked passives. Unknown spells return nil before any gate; recognized paths return action boolean.

Rejected or stale source claims
- Dotacoach counter advice about Raptor high magic resistance conflicts with current KV magic_resist=0 and current patch note; excluded.
- Torte claims Falcon works on towers; current description says no buildings, excluded.
- Torte and some Matchup Desolator Raptor amplification contradicted by pure damage; excluded.
- Old Claw healing, Toss 1200 range and splash targeting, Katana caster-stack damage, passive marks/evasion talent assumptions excluded.

Item follow-up observations for TASK-21
- TASK-21: retain selected builds; current ability handles now passed to queued preparation for Echo/Raptor/Toss. Direct emergency parry/Veil/Claw avoids preparation displacing the action.
- Desolator/Daedalus benefit physical attacks/Echo; Raptor pure damage has no attack factor. Scepter combos now depend on observed readiness, not guessed delays. BKB and Nullifier need item policy/lobby validation.

Enemy counterplay observations for TASK-24
- TASK-24: root/leash/Rupture deny dangerous movement, ethereal/disarm deny physical attacks, Toss and Claw respect block/reflect and debuff immunity, Ice Blast suppresses healing-only Raptor.
- Support setup from root/slow/area control is reflected in real delayed prediction; Raptor cannot guarantee all four slashes or survive enemy interruption.

Lobby validation checklist
- Validate actual native weapon visibility/activation transitions and AD/copied handles in engine.
- Validate first Echo direction/attack modifiers and Katana behind-target Shard stun/stack burst without synthetic stack damage.
- Validate Raptor 1 second interruption and 0.2 second invulnerability, physical versus magic immunity gates, and Scepter alternate-cooldown resets.
- Validate tree grapple landing and actual Shodo cancellation/mark source ownership.

Focused verification
Kez paired native/copied Fengari scenarios passed; four files parse under Lua 5.2; targeted diff check clean. Tests cover current pure damage and prediction, antiheal/root, zero-radius physical Toss, block/reflect/range, active Katana, first-hit Echo, live buffs, parry/cancel, safe tree geometry, observed stance and no speculative Scepter queue.

Full integration/build verification passed. Builds, skill/talent preferences and draft weights are unchanged. No game launched; engine-dependent claims remain lobby checks.

Final integrated verification: node tests/run-builds.cjs, node tests/run-objectives.cjs, node tests/valve_ability_check.cjs and git diff --check passed. Build/skill/talent preference AST comparison passed for all 49 scoped heroes. Native and applicable copied regressions are registered in run-builds. Framework callbacks and unsupported-spell dispatch preservation are covered. No game launched; the recorded lobby checklist remains required.

2026-10-02 shared movement safety follow-up: pinned English localization explicitly names modifier_puck_coiled (Dream Coiled). Replaced inherited modifier_puck_dream_coil checks with the actual debuff name in this previously passed hero. This is a narrow API/mechanics correction; preference assignments remain intact. The final Queen of Pain → Zeus integrated suite covers these files; lobby movement validation remains required.
<!-- SECTION:NOTES:END -->

## Final Summary

<!-- SECTION:FINAL_SUMMARY:BEGIN -->
Kez standard ability pass completed offline. Native and copied behavior reviewed against Torte, full Dotacoach Strategy/Counter Strategy/Matchup and pinned Valve KV/localization. Meaningful behavior fixes and positive/negative regressions implemented; builds and flags preserved. Final integrated verification: node tests/run-builds.cjs, node tests/run-objectives.cjs, node tests/valve_ability_check.cjs and git diff --check passed. Build/skill/talent preference AST comparison passed for all 49 scoped heroes. Native and applicable copied regressions are registered in run-builds. Framework callbacks and unsupported-spell dispatch preservation are covered. No game launched; the recorded lobby checklist remains required.
<!-- SECTION:FINAL_SUMMARY:END -->
