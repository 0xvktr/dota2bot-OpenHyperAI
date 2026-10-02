---
id: TASK-13.117
title: 'Windranger: standard hero ability pass'
status: Needs In-Game Test
assignee:
  - '@codex'
created_date: '2026-10-02 15:41'
updated_date: '2026-10-02 16:24'
labels:
  - hero
dependencies: []
references:
  - bots/BotLib/hero_windrunner.lua
  - tests/windrunner_ability_spec.lua
documentation:
  - backlog/docs/doc-2 - Hero-improvement-playbook.md
modified_files:
  - bots/BotLib/hero_windrunner.lua
  - bots/FunLib/rubick_hero/windrunner.lua
  - tests/windrunner_ability_spec.lua
parent_task_id: TASK-13
priority: medium
ordinal: 157000
---

## Description

<!-- SECTION:DESCRIPTION:BEGIN -->
Windranger is part of the requested Queen of Pain through Zeus hero-file-order batch. Review actual spell decisions against current mechanics and human usage, fixing meaningful ability-use gaps while retaining the established D2PT build.
<!-- SECTION:DESCRIPTION:END -->

## Acceptance Criteria
<!-- AC:BEGIN -->
- [x] #1 Ability decisions and cast order are reviewed against Torte de Lini, dotacoach Strategy/Counter Strategy/full Matchup and pinned Valve definitions/localization; verified checklist and stale claims are recorded
- [x] #2 Identified meaningful behavior gaps are fixed, including applicable Rubick handling, with positive and negative offline regression scenarios
- [x] #3 Focused hero scenarios, Valve ability check and full build suite pass; lobby checklist and engine limitations are recorded for Needs In-Game Test handoff
<!-- AC:END -->

## Implementation Plan

<!-- SECTION:PLAN:BEGIN -->
- Choose Shackleshot using actual behind-target anchors, including legal creep primaries and urgent fail-stun interrupts.
- Predict full-charge Powershot lines and conservative damage reduction, and use Windrun for actual physical threats or safe chase.
- Use current non-channeling Focus Fire and actual cancellation state; decline unverified Gale vector casts.
<!-- SECTION:PLAN:END -->

## Implementation Notes

<!-- SECTION:NOTES:BEGIN -->
Source review and offline implementation for the Queen of Pain → Zeus batch (hero-file order).

Sources: Torte CLI tools/tdl/fetch.cjs windrunner; https://dotacoach.gg/en/heroes/windranger and https://dotacoach.gg/en/heroes/counters/windranger (full Strategy, Counter Strategy and Matchup); Valve d2vpkr cf0d37a32c8df338a7832fd32a282747969e9a5f hero definitions plus English ability localization.

Verified ability checklist
- Read the full native controller, TDL guide 434659379, complete Dotacoach Strategy/Counter Strategy and Matchup hero, synergy and advanced-item cards. Refreshed TDL through tools/tdl/fetch.cjs windrunner.
- Pinned Valve: Shackleshot range 800, cast point 0.15, projectile speed 1650, behind distance 575 and cone 23 degrees; successful duration 1.75/2.25/2.75/3.25 versus failure 0.6 seconds.
- Powershot channels one second, has projectile range 3000, speed 3000 and width 125; full damage 170/270/370/470 and 15% reduction per enemy. Lens cannot extend the separate projectile travel cap.
- Windrun grants physical evasion and movement for 3/4/5/6 seconds. Current Scepter improves Tailwind attack stacks; it does not grant invisible or undispellable Windrun.
- Focus Fire is immunity-piercing unit-target with range 600 and duration 20; it is not a channel. Gale Force is vector-target, radius 900 and cast range 1200. No documented bot vector endpoint is available.

Implemented behavior
- Shackleshot predicts legal primary and secondary positions, tests actual behind geometry against units or trees, permits a creep primary to bind an otherwise out-of-range hero, and avoids overlapping useful remaining stuns. Urgent channel interruption and human ally peel can use the actual short failure stun.
- Powershot scores actual visible lines, includes channel and projectile travel in prediction/regen, and conservatively reduces damage for intervening units. Farm decisions use real local lane and neutral units rather than unrelated pack counts.
- Windrun responds to observed attack projectiles and enemies actually attacking within physical reach, or safe chase. Movement decisions respect root, leash, Rupture and Coil.
- Focus Fire uses a legal useful enemy, objective or building within real cast and practical attack reach; it rejects disarm, reflection, Carapace and glyph. Cancel uses the actual visible active cancellation handle and current Focus Fire state.
- Copied behavior preserves unknown spell dispatch, absent siblings, normal queue/channel locks and actual Lens/unbroken Supremacy. A precise Powershot channel safety export cancels only observed dangerous physical threat.

Rejected or stale source claims
- Rejected old Scepter invisible Windrun, treating Focus Fire as a channel, primary-only guaranteed Shackleshot without an anchor, circular Powershot hit counts and blind Gale point casts.

Item follow-up observations for TASK-21
- TASK-21: True Lens range helps Shackleshot and Focus Fire but cannot extend Powershot arrow range. Blink can create a behind-target shackle angle; BKB and defensive positioning protect a full Powershot channel. Current attack-proc and Scepter Tailwind interactions remain engine checks; no item/build changes.

Enemy counterplay observations for TASK-24
- TASK-24: Avoid reflection and Carapace; physical immunity/disarm suppress attack-oriented Focus Fire. Scatter behind-target anchors to weaken Shackleshot, use blockers against Powershot and magic damage against Windrun. Curse-like damage protection and pending stuns must be observed.

Lobby validation checklist
- No game run. Validate actual Shackleshot unit/tree binding and predicted creep primaries, Powershot travel and compound attenuation, Focus Fire cancel behavior and partial channel release. Gale orientation remains explicitly unverified and inactive until a documented vector path exists.

Focused verification
- Native/copied Fengari scenarios passed: real range/Lens/Supremacy/Break, successful and failed shackle geometry, trees/creep anchors/human peel/stun overlap, Powershot travel cap/regen/blockers/farm/prediction, physical Windrun threats and movement hazards, Focus Fire cast/attack reach/immunity/buildings/glyph/disarm/reflection, cancellation/queue/hidden handles, unknown dispatch and exact channel safety.
- Final fractional-value audit passed: focused fixtures now truncate GetSpecialValueInt and preserve GetSpecialValueFloat; all eleven completed focused specs reran with pass markers.
- Final owned batch audit passed: all twelve focused Fengari specs emitted pass markers and all thirty-eight native/copied/spec/companion Lua files parsed as Lua 5.2. No game validation claimed.

Framework integration
- Native ConsiderPowershotSafety and copied ConsiderStolenPowershotSafety first verify actual current Powershot channel. They retain alive, queue, disable, silence, Box/Doom/Force Staff locks; only dangerous actual attack projectiles or low-health recent damage cancel and request escape movement. No global invulnerability bypass.

Full integration/build verification passed. Builds, skill/talent preferences and draft weights are unchanged. No game launched; engine-dependent claims remain lobby checks.

Final integrated verification: node tests/run-builds.cjs, node tests/run-objectives.cjs, node tests/valve_ability_check.cjs and git diff --check passed. Build/skill/talent preference AST comparison passed for all 43 scoped heroes. Native and applicable copied regressions are registered in run-builds. Framework callbacks and unsupported-spell dispatch preservation are covered. No game launched; the recorded lobby checklist remains required.
<!-- SECTION:NOTES:END -->

## Final Summary

<!-- SECTION:FINAL_SUMMARY:BEGIN -->
Windranger standard ability pass completed offline. Native and copied behavior reviewed against Torte and full Dotacoach Strategy/Counter Strategy/Matchup and pinned Valve KV/localization. Meaningful behavior fixes and positive/negative regressions implemented; builds and flags preserved. Final integrated verification: node tests/run-builds.cjs, node tests/run-objectives.cjs, node tests/valve_ability_check.cjs and git diff --check passed. Build/skill/talent preference AST comparison passed for all 43 scoped heroes. Native and applicable copied regressions are registered in run-builds. Framework callbacks and unsupported-spell dispatch preservation are covered. No game launched; the recorded lobby checklist remains required.
<!-- SECTION:FINAL_SUMMARY:END -->
