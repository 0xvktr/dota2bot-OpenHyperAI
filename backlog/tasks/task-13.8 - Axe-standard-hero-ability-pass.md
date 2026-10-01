---
id: TASK-13.8
title: 'Axe: standard hero ability pass'
status: Needs In-Game Test
assignee:
  - '@codex'
created_date: '2026-10-01 14:21'
updated_date: '2026-10-01 14:54'
labels:
  - hero
dependencies: []
references:
  - bots/BotLib/hero_axe.lua
  - bots/FunLib/rubick_hero/axe.lua
documentation:
  - backlog/docs/doc-2 - Hero-improvement-playbook.md
parent_task_id: TASK-13
priority: medium
ordinal: 48000
---

## Description

<!-- SECTION:DESCRIPTION:BEGIN -->
Axe is in the next standard-pass batch after Abaddon/Underlord/Alchemist/Anti-Mage/Arc Warden. Review current spell decisions and combos against guide strategy and pinned Valve mechanics, including the dedicated Rubick copy. Scope is ability gameplay; existing builds and future role differentiation in TASK-37 remain separate.
<!-- SECTION:DESCRIPTION:END -->

## Acceptance Criteria
<!-- AC:BEGIN -->
- [x] #1 Spell decisions and cast order are reviewed against pinned Valve definitions/localization, Torte de Lini tips and dotacoach Strategy, Counter Strategy and full Matchup advice; source checklist and stale claims are recorded
- [x] #2 Identified ability-use gaps are fixed in the native hero and applicable Rubick copy, with meaningful offline behavior scenarios and preserved D2PT builds
- [x] #3 Hero regression spec, Valve check and shared build suite pass; lobby scenarios are recorded and the standard pass is ready for in-game testing
<!-- AC:END -->

## Implementation Plan

<!-- SECTION:PLAN:BEGIN -->
1. Verify Call immunity, Hunger debuff/Shard stacking and Culling damage against pinned Valve KV/localization, TDL 128726494 and both dotacoach pages. 2. Preserve builds; fix immune Call/retreat control, enemy Hunger debuff and lane removal awareness, current Culling damage and legal reach/reflection guards in native and stolen copies. 3. Add meaningful native/stolen scenarios, retain T8 talent regression, then run focused tests/Valve checks and document lobby cases.
<!-- SECTION:PLAN:END -->

## Implementation Notes

<!-- SECTION:NOTES:BEGIN -->
Source checklist: Torte de Lini guide128726494 (7.41f); https://dotacoach.gg/en/heroes/axe Strategy/Counter Strategy and full https://dotacoach.gg/en/heroes/counters/axe Matchup synergy, items and counters; Valve cf0d37a32c8df338a7832fd32a282747969e9a5f hero KV and abilities_english localization. Verified Call pierces debuff immunity and is non-dispellable; Hunger is PURE, lasts12s, is removed by a kill/building kill, and Shard enables stacking; Culling current damage275/375/475, pierces immunity, and its death is not prevented by Shallow Grave. Existing T8 damage talent mapping preserved. Do not adopt stale armor-scaling Hunger damage, legacy chance-based Helix or absolute guide claims that Crimson removes all damage; courier full-health Culling tip was not made an execution rule.

Implemented native/stolen Call immune-target and retreat/teamfight control, healthy stack farming; Hunger enemy-debuff/Shard checks and lane easy-last-hit avoidance, legal actual range and current Counterspell guard; Culling current damage, immunity/Grave eligibility, reflection/block/illusion guards, no blanket refusal to execute Anti-Mage. Removed full12s magical Hunger kill assumption and useless Tormentor Call. Builds/items/talents/skill order untouched. New tests/axe_ability_spec.lua marker: Axe ability scenarios passed. Focused native/stolen scenarios and prior T8 talent spec pass; Valve check passes; parent owns shared suite/status.

Lobby checklist: Blink/Blade Mail/Call into BKB core with allied follow-up; retreat Call; neutral stacks; Hunger lane support vs nearby last-hit creep and Shard multiple stacks; level3 Culling450HP and talent500HP targets; execute under Grave/BKB; avoid Counterspell/Lotus/Linkens/Aegis/Double. No lobby run yet; invisibility/reveal and exact execute protections remain engine verification cases.

Final integrated verification: node tests/run-builds.cjs passed (exit 0): Lua syntax336 files; Valve128 hero files/21 Rubick copies, zero allowlist findings;127 heroes/253 migrated roles;85 specialized Rubick spell dispatches;58 Rubick hero cases;272 purchase lists; all new hero, Split and Break scenarios. git diff --check passed. Sources and lobby checklist recorded; no game run.
<!-- SECTION:NOTES:END -->

## Final Summary

<!-- SECTION:FINAL_SUMMARY:BEGIN -->
Axe standard pass: immunity-piercing Call, current Hunger targeting and Culling threshold, native/Rubick fixes with behavior scenarios. Preserved builds. Full integrated offline suite passed; ready for lobby.
<!-- SECTION:FINAL_SUMMARY:END -->
