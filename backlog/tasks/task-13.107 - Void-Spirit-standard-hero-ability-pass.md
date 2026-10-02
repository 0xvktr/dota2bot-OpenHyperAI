---
id: TASK-13.107
title: 'Void Spirit: standard hero ability pass'
status: Needs In-Game Test
assignee:
  - '@codex'
created_date: '2026-10-02 15:14'
updated_date: '2026-10-02 16:24'
labels:
  - hero
  - weak-hero
milestone: m-0
dependencies: []
references:
  - bots/BotLib/hero_void_spirit.lua
  - tests/void_spirit_ability_spec.lua
documentation:
  - backlog/docs/doc-2 - Hero-improvement-playbook.md
modified_files:
  - bots/BotLib/hero_void_spirit.lua
  - bots/FunLib/rubick_hero/void_spirit.lua
  - tests/void_spirit_ability_spec.lua
parent_task_id: TASK-13
priority: medium
ordinal: 147000
---

## Description

<!-- SECTION:DESCRIPTION:BEGIN -->
Void Spirit is part of the requested Queen of Pain through Zeus hero-file-order batch. Review actual spell decisions against current mechanics and human usage, fixing meaningful ability-use gaps while retaining the established D2PT build.
<!-- SECTION:DESCRIPTION:END -->

## Acceptance Criteria
<!-- AC:BEGIN -->
- [x] #1 Ability decisions and cast order are reviewed against Torte de Lini, dotacoach Strategy/Counter Strategy/full Matchup and pinned Valve definitions/localization; verified checklist and stale claims are recorded
- [x] #2 Identified meaningful behavior gaps are fixed, including applicable Rubick handling, with positive and negative offline regression scenarios
- [x] #3 Focused hero scenarios, Valve ability check and full build suite pass; lobby checklist and engine limitations are recorded for Needs In-Game Test handoff
<!-- AC:END -->

## Implementation Plan

<!-- SECTION:PLAN:BEGIN -->
- Prevent native spell action overwrites and preserve ordinary action locks.
- Use current Pulse damage, physical barrier threats and Scepter silence/charges.
- Conserve Astral Step escape charges and respect displacement hazards and actual travel limits.
- Select Dissimilate destinations only during an observed own phase; keep Remnant vector orientation explicitly unverified.
<!-- SECTION:PLAN:END -->

## Implementation Notes

<!-- SECTION:NOTES:BEGIN -->
Source review and offline implementation for the Queen of Pain → Zeus batch (hero-file order).

Sources: Torte CLI tools/tdl/fetch.cjs void_spirit; https://dotacoach.gg/en/heroes/void-spirit and https://dotacoach.gg/en/heroes/counters/void-spirit (full Strategy, Counter Strategy and Matchup); Valve d2vpkr cf0d37a32c8df338a7832fd32a282747969e9a5f hero definitions plus English ability localization.

Verified ability checklist
- Read full native controller, TDL guide 1921549643 and full Dotacoach Strategy, Counter Strategy and complete Matchup synergy/gameplay/item cards. Refreshed TDL through the project fetch tool.
- Pinned Valve cf0d37a32c8df338a7832fd32a282747969e9a5f: Remnant is POINT plus VECTOR_TARGETING, range 850, projectile speed 900, activation 0.4, watch distance 450, watch radius 130, impact damage 90/140/190/240 and pull 1/1.2/1.4/1.6. Shard rotates watch paths, damages creeps along those paths and adds true sight without ward reveal.
- Dissimilate cast point 0.3, phase 1.1, current damage 105/185/265/345, portal ring offset 520, six portals per ring, damage radius 275 and optional outer-ring talent. Controller only values center damage until actual phase is observed.
- Astral Step has two charges, cost 90, restore 25/20/15, min travel 200, maximum 800/900/1000, width 170 and pop damage 130/230/330 after 1.25. It pierces debuff immunity, performs attacks along the path without cleave and does not justify invented Lens movement extension.
- Pulse radius 500, speed 1200, damage 60/110/160/210, physical base barrier 25/50/75/100 plus 50/70/90/110 per hero. Scepter supplies two charges and actual single-cast silence 1.75 seconds; no default magic barrier assumption.
- Intrinsic Edge improves damage from primary attributes by 15% and attack speed/health and mana regeneration from secondary attributes by 30%; it does not add armor or magic resistance. Copied spells do not assume absent innate/passive effects.

Implemented behavior
- Each native spell decision returns after one action. Removed the incorrect Step command timer that pretended Remnant had cast.
- Pulse uses arrival and regeneration for lethals, actual attack projectile shield threats, useful real fight targets, conservative charge preservation against already silenced heroes, channel interrupts with actual Scepter, local wave/pack and objective opportunities.
- Astral Step enforces true travel distance, displacement hazards and safe predicted destinations. It reserves the last charge unless a lethal, urgent escape or affordable ready Dissimilate permits engagement; physical attacks and delayed magic pops are evaluated conservatively without fabricated proc damage.
- Dissimilate values center-portal predicted damage, dodge and threatened retreat; source-owned observed phase callbacks send a movement destination intent, preserving queues and unrelated disables. No portal orientation or exit success is inferred.
- Remnant retains a conservative point fallback only for visible channeling or usefully disabled targets, with projectile travel plus activation prediction. No guaranteed hit, interrupt or lethal is promised without a supported vector endpoint.
- Copied handlers preserve unknown-name nil first, real optional handles, Lens/Supremacy range where applicable and human ally parity based on recent damage and observed pursuit.

Rejected or stale source claims
- Rejected old Pulse 3.5-second single silence, Pulse blocking ordinary magic damage, Remnant piercing BKB/Blade Fury, full delayed-pop guaranteed kills, Soulbind doubling non-unit Remnant/Dissimilate, and invented default vector orientation.

Item follow-up observations for TASK-21
- TASK-21: Current Scepter charge staggering and Shard rotating watch paths are useful. Euls or Hex setup can support Remnant, but exact vector direction needs engine validation. Vessel, silence and attack-proc item follow-ups remain generic item-policy work; no build edits.

Enemy counterplay observations for TASK-24
- TASK-24: Respect root, leash, Rupture and Coil displacement punishment, reflection/Carapace, regeneration during delayed pops, physical versus magical barrier differences, and existing immunity/silence. Do not inspect enemy cooldowns.

Lobby validation checklist
- No game run. Validate actual phase modifier/source ability exposure, how ordinary movement selects portals while phased, timing and outer-ring portal geometry. Source-unavailable phases deliberately decline the hook.
- Remnant vector orientation remains an explicit bot API constraint; single-point casts cannot establish watch direction reliably and do not constitute a finished vector implementation or engine-validated interrupt.
- Validate Astral attack proc/talent mechanics and actual travel limit, Pulse barrier/modifier and Scepter charge lifecycle. This standard controller pass does not claim deep weak-hero lifecycle validation.

Focused verification
- Void Spirit native/copied Fengari focused scenarios passed: single action, actual range, immunity, regeneration, charge preservation, safe displacement, physical threat, silence, farm shield gate, Remnant fallback eligibility and phase source/queue/disable guards.
- Final fractional-value audit passed: focused fixtures now truncate GetSpecialValueInt and preserve GetSpecialValueFloat; all eleven completed focused specs reran with pass markers.
- Final owned batch audit passed: all twelve focused Fengari specs emitted pass markers and all thirty-eight native/copied/spec/companion Lua files parsed as Lua 5.2. No game validation claimed.

Framework integration
- Native ConsiderDissimilatePortal and copied ConsiderStolenDissimilatePortal: modifier_void_spirit_dissimilate_phase plus documented source ability void_spirit_dissimilate owned by GetBot required before Refresh. Alive/queue/disable/silence/Box/Doom/Force Staff and unrelated active action locks retained. Only ordinary movement selection intent during actual phase; root wires before invulnerability gate.

Full integration/build verification passed. Builds, skill/talent preferences and draft weights are unchanged. No game launched; engine-dependent claims remain lobby checks.

Final integrated verification: node tests/run-builds.cjs, node tests/run-objectives.cjs, node tests/valve_ability_check.cjs and git diff --check passed. Build/skill/talent preference AST comparison passed for all 43 scoped heroes. Native and applicable copied regressions are registered in run-builds. Framework callbacks and unsupported-spell dispatch preservation are covered. No game launched; the recorded lobby checklist remains required.
<!-- SECTION:NOTES:END -->

## Final Summary

<!-- SECTION:FINAL_SUMMARY:BEGIN -->
Void Spirit standard ability pass completed offline. Native and copied behavior reviewed against Torte and full Dotacoach Strategy/Counter Strategy/Matchup and pinned Valve KV/localization. Meaningful behavior fixes and positive/negative regressions implemented; builds and flags preserved. Final integrated verification: node tests/run-builds.cjs, node tests/run-objectives.cjs, node tests/valve_ability_check.cjs and git diff --check passed. Build/skill/talent preference AST comparison passed for all 43 scoped heroes. Native and applicable copied regressions are registered in run-builds. Framework callbacks and unsupported-spell dispatch preservation are covered. No game launched; the recorded lobby checklist remains required.
<!-- SECTION:FINAL_SUMMARY:END -->
