---
id: TASK-13
title: Improve hero ability logic across the roster
status: In Progress
assignee:
  - '@codex'
created_date: '2026-09-29 21:29'
updated_date: '2026-10-02 16:53'
labels:
  - hero
dependencies: []
references:
  - tests/ancient_apparition_combo_spec.lua
  - tools/tdl/fetch.cjs
  - tools/tdl/guides.json
  - tests/valve_ability_check.cjs
  - tests/hero_harness.lua
documentation:
  - backlog/docs/doc-2 - Hero-improvement-playbook.md
  - docs/HERO_PASS_TRACKER.md
  - docs/HERO_PASS_REPORT.md
modified_files:
  - bots/BotLib/hero_rubick.lua
  - bots/FunLib/rubick_utility.lua
  - bots/ability_item_usage_generic.lua
  - tests/run-builds.cjs
  - tests/rubick_hero_spec.lua
  - tests/rubick_stolen_spec.lua
  - tests/rubick_handlers_spec.lua
  - tests/rubick_unknown_handlers_spec.lua
  - tests/hero_cast_hooks_spec.lua
  - tests/underlord_ability_spec.lua
  - tests/od_item_policy_spec.lua
priority: medium
ordinal: 13000
---

## Description

<!-- SECTION:DESCRIPTION:BEGIN -->
Hero spell use and combos need source-backed reviews beyond their D2PT builds. Track roster progress in docs/HERO_PASS_TRACKER.md and detailed source reviews, offline evidence and lobby checklists in docs/HERO_PASS_REPORT.md. Follow the Hero improvement playbook (doc-2).

Current coverage: 124 of 127 heroes implemented and checked offline; all 124 need lobby validation. Invoker, Lone Druid (including Spirit Bear) and Rubick own passes remain explicitly deferred. The four active subtasks are the lobby campaign TASK-13.125 and those three deferred passes. The 124 historical hero records were archived without changing their Needs In-Game Test status; their research and pending checklists are preserved in the report.

Keep separate tasks only for independent bugs, substantial deep dives or broader work such as TASK-21 item usage, TASK-24 counterplay and TASK-37 role priorities. TASK-1 retains Ancient Apparition's known live release issue and exit decision. WeakHeroes flags stay in place until recorded deep-dive/lobby evidence supports changing them.
<!-- SECTION:DESCRIPTION:END -->

## Acceptance Criteria
<!-- AC:BEGIN -->
- [ ] #1 Each reviewed hero's ability logic is checked against its guide tips and verified against Valve's ability data
- [ ] #2 Bugs found are fixed with an offline spec where feasible
- [ ] #3 Roster tracking records required lobby validation and unresolved limitations, and the umbrella remains open while validation or the three deferred standard passes remain incomplete.
<!-- AC:END -->

## Implementation Plan

<!-- SECTION:PLAN:BEGIN -->
1. Preserve all 124 hero records and pending lobby checklists in a reference report and a 127-hero roster tracker.
2. Replace per-hero tracking with one validation campaign and the three explicitly deferred standard passes; retain independent bug/deep-dive tasks.
3. Update the playbook and umbrella task, then archive only migrated subtasks without marking them Done.
4. Verify record preservation, roster coverage, task relationships and links, then commit and push.
<!-- SECTION:PLAN:END -->

## Implementation Notes

<!-- SECTION:NOTES:BEGIN -->
2026-10-02 tracking consolidation: 124 historical records migrated losslessly to docs/HERO_PASS_REPORT.md and archived, with old-ID mapping and all 127 heroes in docs/HERO_PASS_TRACKER.md. Source reviews, acceptance criteria, offline verification and live limitations are preserved. No lobby validation occurred. Remaining work is TASK-13.125 plus TASK-13.126, TASK-13.127, TASK-13.128. The previous umbrella handoff history is preserved in the report. This tracking change does not change gameplay, build preferences, weak flags or completion evidence.

Consolidation verification passed: all 124 archived files match their original SHA-256 hashes; all original hero bodies and prior umbrella history are preserved in the report. Tracker has 127 unique rows, 124 offline passes pending lobby validation, 3 deferred passes and 18 retained weak flags. All 260 relative document/archive/anchor links resolve. Exactly four active child tasks remain with unchecked criteria; independent task scope, criteria and statuses are unchanged. Backlog doctor found no duplicate IDs or dependency cycles; independent migration review passed.
<!-- SECTION:NOTES:END -->
