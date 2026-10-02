---
id: TASK-13.100
title: 'Sand King: standard hero ability pass'
status: Needs In-Game Test
assignee:
  - '@codex'
created_date: '2026-10-02 14:54'
updated_date: '2026-10-02 16:24'
labels:
  - hero
dependencies: []
references:
  - bots/BotLib/hero_sand_king.lua
  - tests/sand_king_ability_spec.lua
documentation:
  - backlog/docs/doc-2 - Hero-improvement-playbook.md
modified_files:
  - bots/BotLib/hero_sand_king.lua
  - bots/FunLib/rubick_hero/sand_king.lua
  - tests/sand_king_ability_spec.lua
  - bots/FunLib/sand_king_abilities.lua
parent_task_id: TASK-13
priority: medium
ordinal: 140000
---

## Description

<!-- SECTION:DESCRIPTION:BEGIN -->
Sand King is part of the requested Queen of Pain through Zeus hero-file-order batch. Review actual spell decisions against current mechanics and human usage, fixing meaningful ability-use gaps while retaining the established D2PT build.
<!-- SECTION:DESCRIPTION:END -->

## Acceptance Criteria
<!-- AC:BEGIN -->
- [x] #1 Ability decisions and cast order are reviewed against Torte de Lini, dotacoach Strategy/Counter Strategy/full Matchup and pinned Valve definitions/localization; verified checklist and stale claims are recorded
- [x] #2 Identified meaningful behavior gaps are fixed, including applicable Rubick handling, with positive and negative offline regression scenarios
- [x] #3 Focused hero scenarios, Valve ability check and full build suite pass; lobby checklist and engine limitations are recorded for Needs In-Game Test handoff
<!-- AC:END -->

## Implementation Plan

<!-- SECTION:PLAN:BEGIN -->
Verify the current cast animation and physical attack mechanics, correct Burrowstrike geometry and Stinger range, then share source-safe native and copied decisions with focused regression scenarios.
<!-- SECTION:PLAN:END -->

## Implementation Notes

<!-- SECTION:NOTES:BEGIN -->
Source review and offline implementation for the Queen of Pain → Zeus batch (hero-file order).

Sources: Torte CLI tools/tdl/fetch.cjs sand_king; https://dotacoach.gg/en/heroes/sand-king and https://dotacoach.gg/en/heroes/counters/sand-king (full Strategy, Counter Strategy and Matchup); Valve d2vpkr cf0d37a32c8df338a7832fd32a282747969e9a5f hero definitions plus English ability localization.

Verified ability checklist
- Read the complete Torte guide 129100110, Dotacoach Strategy and Counter Strategy, and all current Matchup synergy, gameplay and advanced item cards; validated the Sand King page identity. Ran the Torte fetch CLI.
- Pinned Valve KV and English localization checked: Burrowstrike 775 maximum live base range, 150 line width, 2000 movement speed and 290 magical damage; Sand Storm 700 radius, 90 DPS and 0.7 second fade, with no channel behavior.
- Stinger uses a 200 point cast, 290 outer area, 125 inner area, an attack plus 125 physical bonus and 40 percent inner amplification. It is not blocked by enemy debuff immunity, but physical attack immunity and ethereal form prevent damage.
- Epicenter uses a two-second cast point rather than a channel, a 450 initial radius, 20 pulses of 80 damage and 13 radius growth. Scepter creates random Stinger areas; Shard supplies periodic pulses and does not increase pulse damage. No random proc damage is guaranteed in lethal checks.
- Active caster modifier name checked against the extracted engine modifier dump; actual source identity and cooldown are required before relocation. Blink items use their actual blink_range special, with no Lens displacement increase.
- Focused special-value fixtures now truncate the integer API and preserve the float API; fractional timing audit found no production misuse in this pass.

Implemented behavior
- Burrowstrike predicts travel and tests a line with a bounded physical endpoint, uses only its actual magical impact for kills, and peels threatening enemies from endangered human or bot allies. Point targeting does not impose inappropriate Linken or Lotus unit-spell checks.
- Burrow movement respects root, leash, Rupture, passability, local numbers and tower exposure. Retreat moves toward the allied ancient; lane, farm and Roshan casts retain meaningful geometry.
- Sand Storm checks its real radius and existing caster effect, avoids redundant refreshes, and preserves useful projectile defense and creep clearing. Removed undefined old return variables.
- Stinger predicts the actual cast point, clamps the real point cast with actual Lens and unbroken Supremacy, distinguishes inner and outer physical damage, handles debuff immune enemies, and has no required Burrowstrike or Storm sibling. Native creep and objective policies are retained.
- Epicenter gets initiation priority before Burrowstrike. It starts only around a real multi-hero opportunity and an available movement option or close protected position. The issued command records intent only. Relocation requires the same current Epicenter handle, its actual caster modifier source and a running cooldown after all cast and queue locks end, then issues one actual Blink or Burrow action.
- The copied handler recognizes exactly four current abilities before lookups and returns nil for unknown, false for recognized skips and true only for actions.
- Movement guards use the actual pinned English modifier_puck_coiled, replacing an inherited nonexistent Dream Coil modifier name; native and copied negative coverage was rerun.

Rejected or stale source claims
- Excluded legacy Epicenter channel and shift-queue assumptions, old Scepter Sand Storm stuns, old Caustic leveling and damage formulas, Shard pulse damage increases, deprecated facets and obsolete item recipes or disassembly instructions.

Item follow-up observations for TASK-21
- TASK-21 observation: real ready Blink and its upgrades support post-cast relocation; Arcane Blink has its own 1400 range rather than the ordinary 1200. This pass reads existing items and does not change purchases. BKB and armor recommendations remain observations for the item policy task.

Enemy counterplay observations for TASK-24
- TASK-24 observation: detection removes the practical protection of Storm invisibility; displacement breaks its original area. Debuff immunity prevents Burrowstrike, Storm and Epicenter damage while Stinger remains a physical attack. Armor, ethereal form, movement leashes and Rupture affect the appropriate portions of the kit.

Lobby validation checklist
- Needs in-game verification of the current Epicenter caster modifier and GetModifierSourceAbility identity, interruption during its two-second cast, a successful cast followed by a ready Blink or Burrowstrike, damage-disabled Blink and actual target movement. No queued command is treated as a successful cast.
- Verify current Burrowstrike endpoint treatment with cast-range bonuses, terrain, Caustic application, Stinger inner attack amplification and real Scepter random spines and Shard pulses. The policy conservatively leaves Burrow displacement at its live base range.

Focused verification
31 native and copied behavioral scenarios passed under Fengari. All four changed Lua files parsed with Lua 5.2 grammar; owned-file diff whitespace check passed. Scenarios cover canceled and foreign Epicenter effects, cast and actor locks, missing siblings, range and prediction boundaries, regeneration, physical immunity, human ally peel and native farming/objectives.

Full integration/build verification passed. Builds, skill/talent preferences and draft weights are unchanged. No game launched; engine-dependent claims remain lobby checks.

Final integrated verification: node tests/run-builds.cjs, node tests/run-objectives.cjs, node tests/valve_ability_check.cjs and git diff --check passed. Build/skill/talent preference AST comparison passed for all 43 scoped heroes. Native and applicable copied regressions are registered in run-builds. Framework callbacks and unsupported-spell dispatch preservation are covered. No game launched; the recorded lobby checklist remains required.
<!-- SECTION:NOTES:END -->

## Final Summary

<!-- SECTION:FINAL_SUMMARY:BEGIN -->
Sand King standard ability pass completed offline. Native and copied behavior reviewed against Torte and full Dotacoach Strategy/Counter Strategy/Matchup and pinned Valve KV/localization. Meaningful behavior fixes and positive/negative regressions implemented; builds and flags preserved. Final integrated verification: node tests/run-builds.cjs, node tests/run-objectives.cjs, node tests/valve_ability_check.cjs and git diff --check passed. Build/skill/talent preference AST comparison passed for all 43 scoped heroes. Native and applicable copied regressions are registered in run-builds. Framework callbacks and unsupported-spell dispatch preservation are covered. No game launched; the recorded lobby checklist remains required.
<!-- SECTION:FINAL_SUMMARY:END -->
