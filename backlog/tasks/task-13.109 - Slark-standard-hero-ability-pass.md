---
id: TASK-13.109
title: 'Slark: standard hero ability pass'
status: Needs In-Game Test
assignee:
  - '@codex'
created_date: '2026-10-02 15:18'
updated_date: '2026-10-02 16:24'
labels:
  - hero
dependencies: []
references:
  - bots/BotLib/hero_slark.lua
  - tests/slark_ability_spec.lua
documentation:
  - backlog/docs/doc-2 - Hero-improvement-playbook.md
modified_files:
  - bots/BotLib/hero_slark.lua
  - bots/FunLib/rubick_hero/slark.lua
  - tests/slark_ability_spec.lua
parent_task_id: TASK-13
priority: medium
ordinal: 149000
---

## Description

<!-- SECTION:DESCRIPTION:BEGIN -->
Slark is part of the requested Queen of Pain through Zeus hero-file-order batch. Review actual spell decisions against current mechanics and human usage, fixing meaningful ability-use gaps while retaining the established D2PT build.
<!-- SECTION:DESCRIPTION:END -->

## Acceptance Criteria
<!-- AC:BEGIN -->
- [x] #1 Ability decisions and cast order are reviewed against Torte de Lini, dotacoach Strategy/Counter Strategy/full Matchup and pinned Valve definitions/localization; verified checklist and stale claims are recorded
- [x] #2 Identified meaningful behavior gaps are fixed, including applicable Rubick handling, with positive and negative offline regression scenarios
- [x] #3 Focused hero scenarios, Valve ability check and full build suite pass; lobby checklist and engine limitations are recorded for Needs In-Game Test handoff
<!-- AC:END -->

## Implementation Plan

<!-- SECTION:PLAN:BEGIN -->
Use current fractional Pact delay/first-pulse damage, legal strong-dispel preparation and safe self-cost farming; correct facing/first-hero Pounce collision and Scepter escape reserve, exact Shiv attack reach, urgent Dance and real human/bot Shroud saves with actual source-owned concealment permission.
<!-- SECTION:PLAN:END -->

## Implementation Notes

<!-- SECTION:NOTES:BEGIN -->
Source review and offline implementation for the Queen of Pain → Zeus batch (hero-file order).

Sources: Torte CLI tools/tdl/fetch.cjs slark; https://dotacoach.gg/en/heroes/slark and https://dotacoach.gg/en/heroes/counters/slark (full Strategy, Counter Strategy and Matchup); Valve d2vpkr cf0d37a32c8df338a7832fd32a282747969e9a5f hero definitions plus English ability localization.

Verified ability checklist
- Read complete native controller, Torte guide 128956358 including every ability/item tip, full Dotacoach Strategy/Counter Strategy/Matchup gameplay/synergy/core and counter cards, pinned Valve KV and English localization.
- Dark Pact cast point 0.001 and delay 1.5, ten pulses over one second, radius 325, runtime total 75/150/225/300 plus actual talent, 65 mana and nonlethal self damage 30%. It strong-dispels each pulse but cannot be newly cast while silenced/stunned.
- Pounce is no-target/root-disabled, distance 700 or actual Scepter 900, speed 933.33 with acceleration 7000, radius 120, two Scepter charges, zero damage and real first-hero leash. Debuff immunity prevents leash; copied spell does not invent Essence Shift ownership or damage.
- Saltwater Shiv is an attack-based hero unit cast with attack range plus actual 50 buffer, 25/30/35/40 mana, independent 12-second stacks and current movement/regen/restoration steal; no invented magical nuke or Lens attack extension.
- Shadow Dance is immediate no-target with 100 mana, current duration 4/4.25/4.5 and regen 60/90/120; active attacks/spells do not reveal it. Depth Shroud is an actual optional Shard point spell, 400 range, 0.1 cast point, 225 radius, two seconds and 75 mana.

Implemented behavior
- Urgent Dance and actual Shroud ally saves precede offensive native casts. Shroud values a damaged, actually threatened human or bot ally independently of the caster HP, permits immune allies and clamps predicted anchor to real point range plus coverage; existing Dance suppresses duplicates.
- Pact uses floating-point delay and correct pulse geometry, conservative first-pulse kill/regen and actual magical self-cost for routine fighting/farming. Active Pact/pulses suppress repeats; incoming stuns or actual removable roots/marks create legal preparation. Pounce leash alone is not falsely treated as dispellable.
- Pounce projects current facing and predicted first real hero on the path, respects immunity/illusion collisions conservatively, exact current Scepter distance and last-charge escape reserve. Root, leash, Rupture, Coil, Soulbind, unpassable/tower/Chronosphere/Black Hole landing and local outnumbering block unsafe movement; escape avoids latching a pursuer.
- Shiv checks actual attack reach plus current buffer, disarm, physical attack eligibility, block/reflection and actual attack intent, with no guessed immediate damage or passive proc.
- Actual friendly-source Dance or Shroud modifier grants only the supported invisibility spell permission. Foreign/missing source and ordinary invisibility decline. Channel/queue/disable and other actor locks remain. Native and copied spells stay independent, nil-first unsupported dispatch preserved.

Rejected or stale source claims
- Rejected old learnable Essence Shift slot, instant/zero Dark Pact delay, magical Pounce damage, target range padded by 200, old Depth Shroud radius300 and caster-low-HP-only behavior, and generic invisibility blocking current Dance spells.
- Guide/matchup claims Dark Pact removes enemy Aphotic Shield, Nullifier disables passives, or Refresher makes Slark invulnerable are not current supported mechanics. Dance/Shroud do not grant immunity against AoE; Essence Shift does not remove enemy bonus armor directly.

Item follow-up observations for TASK-21
- TASK-21: actual Diffusal setup, Scepter attack/escape charges, Shard human ally saves, BKB versus AoE disable and silences, Treads/self-cost and observed Refresher mana need shared follow-up. Existing item/build policy remains.

Enemy counterplay observations for TASK-24
- TASK-24: bait the actual Pact delayed pulses, respect undispellable control, target AoE during Dance/Shroud, deny safe first-hero Pounce path/escape charges and avoid long actual stat-steal fights. Ward/deward inference from passive vision needs a separate observation policy, not fabricated vision knowledge.

Lobby validation checklist
- Validate actual Dance and Shroud modifier/source identities for invisibility permission; missing source conservatively declines until observed. Validate live targeting, immunity and protection from single-target damage without claiming AoE immunity.
- Validate current Pounce first hero and immune collision, acceleration, Scepter runtime 900 distance/charges, facing/landing, and copied Essence Shift dependency.
- Validate Pact first pulse timing/strong dispel/nonlethal self damage and Shiv current attack-range-plus-buffer including ranged copied casters. No game launched.

Focused verification
- Fengari tests/slark_ability_spec.lua passed 108 native/copied positive/negative cases plus unsupported dispatch, unavailable handles, independent Pact and actual-source concealment hook.
- Scenarios cover fractional impact/regeneration, non-instant damage, self-cost/active pulses/removable root vs nondispellable leash, first-hero/illusion/immune collisions, Scepter distance/charge reserve, unsafe escapes, exact Shiv/Lens/disarm/attack immunity/block, healthy-caster human immune ally saves/range/duplicate, urgent native defense, and real versus foreign/missing concealment source with channel/queue guards.
- All build/skill/talent preferences remain unchanged; final integration verification pending.
- Pinned localization3365 verifies modifier_puck_coiled; movement guard uses actual current name and focused scenarios pass.

Framework integration
- Native/copied UseShadowDanceSpells acts only inside actual friendly-source observed active Dance/Shroud concealment; preserves actor locks and considers only actual owned current Slark spell handles. Root routes it before normal local invisibility gates.

Full integration/build verification passed. Builds, skill/talent preferences and draft weights are unchanged. No game launched; engine-dependent claims remain lobby checks.

Final integrated verification: node tests/run-builds.cjs, node tests/run-objectives.cjs, node tests/valve_ability_check.cjs and git diff --check passed. Build/skill/talent preference AST comparison passed for all 43 scoped heroes. Native and applicable copied regressions are registered in run-builds. Framework callbacks and unsupported-spell dispatch preservation are covered. No game launched; the recorded lobby checklist remains required.
<!-- SECTION:NOTES:END -->

## Final Summary

<!-- SECTION:FINAL_SUMMARY:BEGIN -->
Slark standard ability pass completed offline. Native and copied behavior reviewed against Torte and full Dotacoach Strategy/Counter Strategy/Matchup and pinned Valve KV/localization. Meaningful behavior fixes and positive/negative regressions implemented; builds and flags preserved. Final integrated verification: node tests/run-builds.cjs, node tests/run-objectives.cjs, node tests/valve_ability_check.cjs and git diff --check passed. Build/skill/talent preference AST comparison passed for all 43 scoped heroes. Native and applicable copied regressions are registered in run-builds. Framework callbacks and unsupported-spell dispatch preservation are covered. No game launched; the recorded lobby checklist remains required.
<!-- SECTION:FINAL_SUMMARY:END -->
