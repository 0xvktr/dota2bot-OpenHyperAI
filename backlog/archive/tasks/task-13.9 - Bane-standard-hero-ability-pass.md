---
id: TASK-13.9
title: 'Bane: standard hero ability pass'
status: Needs In-Game Test
assignee:
  - '@codex'
created_date: '2026-10-01 14:21'
updated_date: '2026-10-01 14:54'
labels:
  - hero
dependencies: []
references:
  - bots/BotLib/hero_bane.lua
  - bots/FunLib/rubick_hero/bane.lua
documentation:
  - backlog/docs/doc-2 - Hero-improvement-playbook.md
parent_task_id: TASK-13
priority: medium
ordinal: 49000
---

## Description

<!-- SECTION:DESCRIPTION:BEGIN -->
Bane is in the next standard-pass batch after Abaddon/Underlord/Alchemist/Anti-Mage/Arc Warden. Review current spell decisions and combos against guide strategy and pinned Valve mechanics, including the dedicated Rubick copy. Scope is ability gameplay; existing builds and future role differentiation in TASK-37 remain separate.
<!-- SECTION:DESCRIPTION:END -->

## Acceptance Criteria
<!-- AC:BEGIN -->
- [x] #1 Spell decisions and cast order are reviewed against pinned Valve definitions/localization, Torte de Lini tips and dotacoach Strategy, Counter Strategy and full Matchup advice; source checklist and stale claims are recorded
- [x] #2 Identified ability-use gaps are fixed in the native hero and applicable Rubick copy, with meaningful offline behavior scenarios and preserved D2PT builds
- [x] #3 Hero regression spec, Valve check and shared build suite pass; lobby scenarios are recorded and the standard pass is ready for in-game testing
<!-- AC:END -->

## Implementation Plan

<!-- SECTION:PLAN:BEGIN -->
1. Verify Sap pure damage/Shard targeting, Grip immunity/channel, Nightmare ally invulnerability and current sleepwalk behavior using Valve data/localization, TDL 128876778 and both dotacoach pages. 2. Preserve builds; fix control-first cast order, second-target sleep before Grip, pure immune-piercing Sap/Grip with legal range and reflection guards, emergency ally sleep/release, and Shard cluster selection in native/stolen copies. 3. Add behavioral scenarios, run focused specs and Valve checks; record source caveats and channel/save lobby cases.
<!-- SECTION:PLAN:END -->

## Implementation Notes

<!-- SECTION:NOTES:BEGIN -->
Source checklist: Torte de Lini guide128876778 (7.41f); https://dotacoach.gg/en/heroes/bane Strategy/Counter Strategy and full https://dotacoach.gg/en/heroes/counters/bane Matchup synergy/items/counters; Valve cf0d37a32c8df338a7832fd32a282747969e9a5f hero KV/localization. Verified Sap unit-target PURE90/160/230/300 and pierces enemy immunity; Shard550radius with30% secondary healing and3s cooldown reduction, not a point-target switch. Grip pierces immunity, strong-dispel only, level channel4.75/5.25/5.75s and Scepter two non-stacking channel illusions. Nightmare invulnerable1s, alt-cast stationary/current sleepwalk, End ends all sleepers. Rejected obsolete magical Sap, fixed6s Grip calculation, old Brain Sap target-type conversion and universal old facet advice; do not assume all Nightmares remain stationary.

Implemented matching native/stolen legal range and current Counterspell guards; native secondary Nightmare then Grip before ordinary Sap/Enfeeble; Sap pure/immunity kills, combat sustain and Shard cluster selection without waking secondary enemy; Grip immunity/control and real channel-time estimate; threatened lowHP allied projectile save with End release after invulnerability while preserving enemy sleeps; Enfeeble strongest eligible attacker. Native keeps existing Grip channel. Builds unchanged. New tests/bane_ability_spec.lua marker: Bane ability scenarios passed. Focused native/stolen scenarios, sequence/channel regression, six-file syntax and Valve check pass; parent owns shared suite/status.

Lobby checklist: secondary Nightmare then Grip carry (including BKB); Grip from maximum Lens range with follow-up; preserve normal channel and verify Scepter illusions (no forced channel cancel added); Sap through BKB and Shard twohero cluster; preserve sleeper from Sap splash; ally/self targeted projectile save then End after1s, including shared enemy sleeper; Nightmare unit/vector or alt-cast stationary dispatch and release during Grip. Offline unit-target API retained from existing implementation; sleepwalk orientation and projectile timing require engine testing. No lobby run yet.

Cast-order refinement: urgent allied Nightmare save/channel interrupt first; immediate Sap kill or emergency self-heal before a long Grip; ordinary secondary Nightmare, Grip, Sap, Enfeeble after that. Regression proves lethal Sap avoids unnecessary Grip while normal control-first two-target sequence is preserved.

Integration review fix: Nightmare End has no ignore-channel flag, so saved-ally release now waits while channeling, casting/using an ability or holding queued actions. Native and stolen regressions prove a pending wake cannot cancel Grip/current casts, then releases afterward; self-Nightmare wake still occurs before the normal inability gate. Focused Bane and Valve checks pass.

Save timing refinement: minimum End release includes Nightmare cast point as well as invulnerability duration, and actual nightmare_invulnerable modifier blocks wake-up even when an enqueue-based timer has expired. Native/stolen regressions cover delayed arrival and release only after real invulnerability ends; Bane/Valve checks pass.

Current localization Enfeeble modifier is modifier_bane_enfeeble_effect. Native/stolen refresh guard now uses this name; regression rejects an already-Enfeebled target and allows casting after the effect expires.

Final integrated verification: node tests/run-builds.cjs passed (exit 0): Lua syntax336 files; Valve128 hero files/21 Rubick copies, zero allowlist findings;127 heroes/253 migrated roles;85 specialized Rubick spell dispatches;58 Rubick hero cases;272 purchase lists; all new hero, Split and Break scenarios. git diff --check passed. Sources and lobby checklist recorded; no game run.
<!-- SECTION:NOTES:END -->

## Final Summary

<!-- SECTION:FINAL_SUMMARY:BEGIN -->
Bane standard pass: control-first targeting, secondary Nightmare before Grip, immunity-piercing pure Sap/Grip, Shard target selection and safe ally wake-up respecting channels/invulnerability. Native/Rubick scenarios and full offline suite passed; ready for lobby.
<!-- SECTION:FINAL_SUMMARY:END -->
