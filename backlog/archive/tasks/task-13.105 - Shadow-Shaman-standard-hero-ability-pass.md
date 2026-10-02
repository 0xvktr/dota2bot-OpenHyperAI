---
id: TASK-13.105
title: 'Shadow Shaman: standard hero ability pass'
status: Needs In-Game Test
assignee:
  - '@codex'
created_date: '2026-10-02 15:12'
updated_date: '2026-10-02 16:24'
labels:
  - hero
dependencies: []
references:
  - bots/BotLib/hero_shadow_shaman.lua
  - tests/shadow_shaman_ability_spec.lua
documentation:
  - backlog/docs/doc-2 - Hero-improvement-playbook.md
modified_files:
  - bots/BotLib/hero_shadow_shaman.lua
  - bots/FunLib/rubick_hero/shadow_shaman.lua
  - tests/shadow_shaman_ability_spec.lua
  - bots/FunLib/shadow_shaman_abilities.lua
parent_task_id: TASK-13
priority: medium
ordinal: 145000
---

## Description

<!-- SECTION:DESCRIPTION:BEGIN -->
Shadow Shaman is part of the requested Queen of Pain through Zeus hero-file-order batch. Review actual spell decisions against current mechanics and human usage, fixing meaningful ability-use gaps while retaining the established D2PT build.
<!-- SECTION:DESCRIPTION:END -->

## Acceptance Criteria
<!-- AC:BEGIN -->
- [x] #1 Ability decisions and cast order are reviewed against Torte de Lini, dotacoach Strategy/Counter Strategy/full Matchup and pinned Valve definitions/localization; verified checklist and stale claims are recorded
- [x] #2 Identified meaningful behavior gaps are fixed, including applicable Rubick handling, with positive and negative offline regression scenarios
- [x] #3 Focused hero scenarios, Valve ability check and full build suite pass; lobby checklist and engine limitations are recorded for Needs In-Game Test handoff
<!-- AC:END -->

## Implementation Plan

<!-- SECTION:PLAN:BEGIN -->
Correct instant control and channel sequencing, real range and damage checks, and current Scepter and Shard decisions in native and copied spells while retaining siege and farming.
<!-- SECTION:PLAN:END -->

## Implementation Notes

<!-- SECTION:NOTES:BEGIN -->
Source review and offline implementation for the Queen of Pain → Zeus batch (hero-file order).

Sources: Torte CLI tools/tdl/fetch.cjs shadow_shaman; https://dotacoach.gg/en/heroes/shadow-shaman and https://dotacoach.gg/en/heroes/counters/shadow-shaman (full Strategy, Counter Strategy and Matchup); Valve d2vpkr cf0d37a32c8df338a7832fd32a282747969e9a5f hero definitions plus English ability localization.

Verified ability checklist
- Fully read Torte guide 129085778 and the intended Dotacoach Strategy, Counter Strategy and all Matchup synergy, gameplay and advanced item cards; ran the guide fetch CLI and checked canonical page identity.
- Pinned Valve KV and localization: Ether Shock 600 primary range, 320 damage and 0.3 cast point; Hex 550 range and zero cast point, up to 2.9 second duration; Shackles live base 450 range, Scepter adds 150, up to 4.2 seconds and 280 total channel damage with matching healing.
- Scepter Shackles uses the actual alt_cast_on_allies flag, 600 radial Ether Shock area, 0.9 second interval and 2000 friendly break range. Requires an actual trained visible active Ether Shock sibling before choosing a friendly radial channel.
- Mass Serpent Ward point cast is 550, with 10 wards, 150 spawn circle, 45 second duration and 120 physical attack damage at level three. Actual ward units have 650 base attack range. No magical burst or immediate full ward volley is assumed.
- Urnaconda is the actual current Shard ability: 650 point cast, 0.3 cast point, 1000 projectile speed, 225 impact area, 275 impact, 140 mana, 50-second cooldown and a 15-second mega ward with four times the base ward damage and health. Impact lethal checks use the live engine GetDamageType rather than guessing a missing KV damage type.
- Valve July 1, 2026 update confirms stolen Urnaconda spawning was repaired; code accepts an actual usable copied Urnaconda without fabricating a Ward sibling.
- Focused special-value fixtures now truncate the integer API and preserve the float API; fractional timing audit found no production misuse in this pass.

Implemented behavior
- Instant Hex uses exact cast range, reacts to dangerous channels and allies under attack, and avoids overlapping existing controls. The blanket invisibility rejection is removed so an actual invisible initiation can occur. Human ally peel has the same eligibility as bot allies.
- Shackles waits for the observable tail of existing Hex before following up and preserves all normal channel and casting locks. It rejects an uncontrolled second enemy attacking the caster, while permitting a safe low-health enemy channel that can actually heal the caster. No fake attack damage is added to its magical damage.
- Friendly Scepter channels require actual upgraded flags, current range, a real Shock sibling and eligible human allies or actual source-owned serpent wards near enemies. Missing, hidden or deactivated siblings cannot manufacture the radial effect.
- Shock kill and creep decisions use cast-delayed regeneration-aware damage and exact primary range, preserving ranged last hits, clearing and objective casts.
- Ward deployment predicts a real bounded point, uses physical target usefulness, and scans actual living wards by unit name and actor ownership. Existing own wards avoid low-health solo waste; foreign wards do not suppress the cast, and real refreshed deployments remain possible for multiple enemies or structures. Siege placement respects actual ward attack range, spawn spread, glyph and backdoor protection.
- Added live-handle Urnaconda targeting, real projectile prediction and bounded impact coverage, useful standalone copied behavior, native wave clearing and structure pressure. No obsolete vector endpoint API is invented.
- Copied handler recognizes exactly the five current supported abilities before gates/lookups and returns canonical action/skip/unknown results.

Rejected or stale source claims
- Excluded removed Chicken Fingers, obsolete Shard Fowl Play upgrade advice and deprecated vector Serpentine behavior, old Scepter ward-only assumptions, fake Shackles attack damage, extra approach range and old Arcane Boots disassembly advice.

Item follow-up observations for TASK-21
- TASK-21 observations: actual Lens and Scepter extend different live ranges; BKB/Glimmer advice relates to channel protection, Refresher to another real Ward deployment, and current Shard grants Urnaconda. Existing builds and generic item behavior are unchanged.

Enemy counterplay observations for TASK-24
- TASK-24 observations: spell block and reflect matter for targeted control, debuff immunity prevents Hex/Shackles/Shock, and armor or ethereal protection affects actual ward attacks. Multiple attackers or ranged interrupts threaten Shackles. Urnaconda and Ward point casts have different cast shapes from the unit-target spells.

Lobby validation checklist
- Needs in-game checks of Hex-tail followups, Scepter friendly and owned-ward Shackles, current Ether Shock radial linkage after steal, interruptions and actual healing, real ward ownership and Refresher duplicate deployment.
- Verify stolen standalone Urnaconda spawning and current impact GetDamageType, live structure range and spawn spread, actual glyph/backdoor protection, and normal engine invisible initiation.

Focused verification
30 native and copied behavior scenarios passed under Fengari; all four files parsed with Lua 5.2 grammar and owned-file diff whitespace checks passed. Tests cover range, regeneration, spell block/reflect/immunity, human peel, real control tails, channel preservation, nil/hidden upgrade siblings, ownership, independent copied Urnaconda, farm and siege.

Full integration/build verification passed. Builds, skill/talent preferences and draft weights are unchanged. No game launched; engine-dependent claims remain lobby checks.

Final integrated verification: node tests/run-builds.cjs, node tests/run-objectives.cjs, node tests/valve_ability_check.cjs and git diff --check passed. Build/skill/talent preference AST comparison passed for all 43 scoped heroes. Native and applicable copied regressions are registered in run-builds. Framework callbacks and unsupported-spell dispatch preservation are covered. No game launched; the recorded lobby checklist remains required.
<!-- SECTION:NOTES:END -->

## Final Summary

<!-- SECTION:FINAL_SUMMARY:BEGIN -->
Shadow Shaman standard ability pass completed offline. Native and copied behavior reviewed against Torte and full Dotacoach Strategy/Counter Strategy/Matchup and pinned Valve KV/localization. Meaningful behavior fixes and positive/negative regressions implemented; builds and flags preserved. Final integrated verification: node tests/run-builds.cjs, node tests/run-objectives.cjs, node tests/valve_ability_check.cjs and git diff --check passed. Build/skill/talent preference AST comparison passed for all 43 scoped heroes. Native and applicable copied regressions are registered in run-builds. Framework callbacks and unsupported-spell dispatch preservation are covered. No game launched; the recorded lobby checklist remains required.
<!-- SECTION:FINAL_SUMMARY:END -->
