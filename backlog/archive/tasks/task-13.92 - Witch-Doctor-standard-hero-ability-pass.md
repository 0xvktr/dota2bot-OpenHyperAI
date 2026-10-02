---
id: TASK-13.92
title: 'Witch Doctor: standard hero ability pass'
status: Needs In-Game Test
assignee:
  - '@codex'
created_date: '2026-10-02 14:36'
updated_date: '2026-10-02 16:24'
labels:
  - hero
dependencies: []
references:
  - bots/BotLib/hero_witch_doctor.lua
  - tests/witch_doctor_ability_spec.lua
documentation:
  - backlog/docs/doc-2 - Hero-improvement-playbook.md
modified_files:
  - bots/BotLib/hero_witch_doctor.lua
  - bots/FunLib/rubick_hero/witch_doctor.lua
  - tests/witch_doctor_ability_spec.lua
parent_task_id: TASK-13
priority: medium
ordinal: 132000
---

## Description

<!-- SECTION:DESCRIPTION:BEGIN -->
Witch Doctor is part of the requested Queen of Pain through Zeus hero-file-order batch. Review actual spell decisions against current mechanics and human usage, fixing meaningful ability-use gaps while retaining the established D2PT build.
<!-- SECTION:DESCRIPTION:END -->

## Acceptance Criteria
<!-- AC:BEGIN -->
- [x] #1 Ability decisions and cast order are reviewed against Torte de Lini, dotacoach Strategy/Counter Strategy/full Matchup and pinned Valve definitions/localization; verified checklist and stale claims are recorded
- [x] #2 Identified meaningful behavior gaps are fixed, including applicable Rubick handling, with positive and negative offline regression scenarios
- [x] #3 Focused hero scenarios, Valve ability check and full build suite pass; lobby checklist and engine limitations are recorded for Needs In-Game Test handoff
<!-- AC:END -->

## Implementation Plan

<!-- SECTION:PLAN:BEGIN -->
- Use true Cask damage, travel and bounce opportunities; predicted bounded Maledict before useful Death Ward.
- Use actual pure piercing Death Ward and owned minion targeting, safe placements and active channel preservation.
- Use real Restoration healing and resource-aware toggles, including the legal observed Ward/teleport channel exception.
- Use actual Switcheroo availability for urgent survival and attack support; mirror five independent copied spells and preserve builds.
<!-- SECTION:PLAN:END -->

## Implementation Notes

<!-- SECTION:NOTES:BEGIN -->
Source review and offline implementation for the Queen of Pain → Zeus batch (hero-file order).

Sources: Torte CLI tools/tdl/fetch.cjs witch_doctor; https://dotacoach.gg/en/heroes/witch-doctor and https://dotacoach.gg/en/heroes/counters/witch-doctor (full Strategy, Counter Strategy and Matchup); Valve d2vpkr cf0d37a32c8df338a7832fd32a282747969e9a5f hero definitions plus English ability localization.

Verified ability checklist
- Read the entire native SkillsComplement and every Consider/Combo branch; full Torte guide 129191918, all Dotacoach Strategy/Counter Strategy and full Matchup gameplay/core/counter item cards. Read pinned Valve cf0d37a32c8df338a7832fd32a282747969e9a5f raw hero AbilityDefinitions and English localization.
- Cask range 600, cast point0.2, projectile1200, base damage55/70/85/100, bounce range575,3/4/5/6 bounces with20 extra damage per bounce; creep multiplier100%. Reliable kill checks use only initial impact with health regeneration.
- Restoration toggle has IGNORE_CHANNEL, initial cost25, upkeep9/12/15/18, radius650 and heal20/30/40/50. Live does_heal_all_allies controls recipients; allied immunity does not prevent healing. Off toggles need a valid trained active handle, not enough mana to turn on.
- Maledict range600, radius200, castpoint0.35, base damage18/22/26/30 and loss-based bursts every4 seconds over12 seconds. Bursts depend on actual future health loss; they are not guaranteed immediate damage.
- Death Ward is an8-second point channel, range500, attack range600/625/650, pure damage60/90/120 and0.22 attack interval, with50% bonus accuracy. It pierces debuff immunity but its attack target flags exclude attack-immune/invisible/unseen victims. Scepter bounce radius575 is not a guaranteed full-channel damage multiplier.
- Switcheroo is actual Shard-granted active,0.1 castpoint,2.5-second hide/ward state and45% attack-speed reduction,200 mana. Optional independent copied handles determine availability; no linked ultimate is presumed.
- Ward targeting uses the documented controllable minion attack command, exact death-ward unit name and caster player ID/team. A successful request is not proof of damage or survival.

Implemented behavior
- Replaced inflated Cask damage and extra cast-range padding with initial impact and actual range plus Lens/unbroken Supremacy; added ally peel, visible bounce-partner scoring and ranged last hits/useful packs.
- Maledict predicts and bounds its actual point while preserving existing infection; useful allied attack support includes human allies. It precedes the Ward without promising unobserved burst damage.
- Ward uses actual rank attack reach for bounded point placement, rejects attack-immune targets and Chronosphere/Black Hole placement, and avoids observed incoming disable or attack threat to its caster. Immunity-compatible target choice and actual controllable Ward retargeting are supported.
- Restoration heals self and human/bot allies including debuff-immune allies, respects Ice Blast and mana reserve, and turns off when no eligible recipient or insufficient upkeep even if the ability is not fully castable.
- A precise channel callback toggles Restoration only during actual owned Death Ward or active teleport-scroll channel. It retains disable, silence, queue, casting, Box/Doom/Force Staff and invulnerability locks and emits one direct legal toggle.
- Switcheroo prioritizes actual incoming stun or urgent survival, uses available active handle and supports useful local pressure without assuming a present Death Ward.
- Native Glimmer/Amulet channel protection is confined to the actual owned Ward channel; queued setup and unrelated channels cannot trigger it. Builds, talent/skill order, item preference and default flags are unchanged.
- Five independently copied spell handlers preserve unknown-name fallback before any linked lookup, recognized skip returns false, and true means exactly one spell request. Owned Ward minions bypass generic conflicting orders.
- The owned Death Ward minion handler claims idle and locked states as handled, preventing generic minion orders from ignoring its actual attack reach or overwriting its channel-related state.
- Channel interrupts use actual observed teleport modifier remaining duration versus cast/projectile arrival, avoiding interrupt-only requests that are already too late.

Rejected or stale source claims
- Rejected physical Death Ward descriptions, Slardar armor amplification of Ward damage, and blanket magic resistance reducing its pure attacks. Muerta attack immunity still blocks attack targeting.
- Rejected old extra creep Cask damage, Static Link being a cancelable channel, current Facet2 Restoration damage purchases and Arcane Boots disassembly advice.
- No assumed full eight-second Ward damage, guaranteed multiple Cask hits, guessed Maledict bursts, copied Gris-Gris or innate healing reduction.

Item follow-up observations for TASK-21
- TASK-21: Keep Glimmer/Amulet use during the actual Ward channel; review Blink/cliff positioning, BKB preparation, Shard disjoint, Scepter bounce opportunities, mana reserve and healing amplification without altering this batch item builds.

Enemy counterplay observations for TASK-24
- TASK-24: Separate Cask bounce partners, disrupt the caster channel, escape Ward reach, use attack immunity/invisibility or repositioning, and heal before Maledict bursts. Armor and ordinary magic barriers do not reduce current pure Ward damage.

Lobby validation checklist
- Validate actual Death Ward minion player ID and attack command, rank attack reach, immunity and attack-immune/invisible target filtering.
- Validate Restoration toggle during Death Ward and teleport, queued Glimmer/Amulet channel preservation and live healing recipient/talent values.
- Validate Switcheroo disjoint/hidden state and Ward immunity, exact projectile timings and movement predictions. No game launched.

Focused verification
- Fengari tests/witch_doctor_ability_spec.lua passed 98 native/copied positive and negative cases plus independent missing-sibling, foreign active-channel source, Box/Doom/Force, owned minion and Ward protection assertions.
- Build/skill/talent preference AST comparison passed for43 scoped heroes. Full integration and Valve/build checks remain pending.
- Final peer timing regression: actual modifier index/duration query rejects interrupt-only casts when teleport remaining0.1s is shorter than real spell arrival; remaining2s channel interrupt passes. Focused suite now 98 scenarios.

Framework integration
- Native/copied UseRestorationDuringChannel: exact observed owned Death Ward or teleport-scroll active channel, no global invulnerability bypass.
- Native/copied HandleDeathWard(unit): exact owned named Ward with legal action state and actual target attack reach; root forwards before generic Rubick minion orders.

Full integration/build verification passed. Builds, skill/talent preferences and draft weights are unchanged. No game launched; engine-dependent claims remain lobby checks.

Final integrated verification: node tests/run-builds.cjs, node tests/run-objectives.cjs, node tests/valve_ability_check.cjs and git diff --check passed. Build/skill/talent preference AST comparison passed for all 43 scoped heroes. Native and applicable copied regressions are registered in run-builds. Framework callbacks and unsupported-spell dispatch preservation are covered. No game launched; the recorded lobby checklist remains required.
<!-- SECTION:NOTES:END -->

## Final Summary

<!-- SECTION:FINAL_SUMMARY:BEGIN -->
Witch Doctor standard ability pass completed offline. Native and copied behavior reviewed against Torte and full Dotacoach Strategy/Counter Strategy/Matchup and pinned Valve KV/localization. Meaningful behavior fixes and positive/negative regressions implemented; builds and flags preserved. Final integrated verification: node tests/run-builds.cjs, node tests/run-objectives.cjs, node tests/valve_ability_check.cjs and git diff --check passed. Build/skill/talent preference AST comparison passed for all 43 scoped heroes. Native and applicable copied regressions are registered in run-builds. Framework callbacks and unsupported-spell dispatch preservation are covered. No game launched; the recorded lobby checklist remains required.
<!-- SECTION:FINAL_SUMMARY:END -->
