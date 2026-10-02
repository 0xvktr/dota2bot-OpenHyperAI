---
id: TASK-13.99
title: 'Viper: standard hero ability pass'
status: Needs In-Game Test
assignee:
  - '@codex'
created_date: '2026-10-02 14:52'
updated_date: '2026-10-02 16:24'
labels:
  - hero
dependencies: []
references:
  - bots/BotLib/hero_viper.lua
  - tests/viper_ability_spec.lua
documentation:
  - backlog/docs/doc-2 - Hero-improvement-playbook.md
modified_files:
  - bots/BotLib/hero_viper.lua
  - bots/FunLib/rubick_hero/viper.lua
  - tests/viper_ability_spec.lua
parent_task_id: TASK-13
priority: medium
ordinal: 139000
---

## Description

<!-- SECTION:DESCRIPTION:BEGIN -->
Viper is part of the requested Queen of Pain through Zeus hero-file-order batch. Review actual spell decisions against current mechanics and human usage, fixing meaningful ability-use gaps while retaining the established D2PT build.
<!-- SECTION:DESCRIPTION:END -->

## Acceptance Criteria
<!-- AC:BEGIN -->
- [x] #1 Ability decisions and cast order are reviewed against Torte de Lini, dotacoach Strategy/Counter Strategy/full Matchup and pinned Valve definitions/localization; verified checklist and stale claims are recorded
- [x] #2 Identified meaningful behavior gaps are fixed, including applicable Rubick handling, with positive and negative offline regression scenarios
- [x] #3 Focused hero scenarios, Valve ability check and full build suite pass; lobby checklist and engine limitations are recorded for Needs In-Game Test handoff
<!-- AC:END -->

## Implementation Plan

<!-- SECTION:PLAN:BEGIN -->
- Use safe attack-based Poison Attack and purposeful autocast state.
- Predict current Nethertoxin coverage and preserve useful mana reserves.
- Use piercing Strike for useful Break and physical attacker control.
- Use Nosedive only for useful safe real movement with observed linked effects.
<!-- SECTION:PLAN:END -->

## Implementation Notes

<!-- SECTION:NOTES:BEGIN -->
Source review and offline implementation for the Queen of Pain → Zeus batch (hero-file order).

Sources: Torte CLI tools/tdl/fetch.cjs viper; https://dotacoach.gg/en/heroes/viper and https://dotacoach.gg/en/heroes/counters/viper (full Strategy, Counter Strategy and Matchup); Valve d2vpkr cf0d37a32c8df338a7832fd32a282747969e9a5f hero definitions plus English ability localization.

Verified ability checklist
- Read full native controller and every consideration, fetched/read TDL guide 129400259 and complete Dotacoach Strategy, Counter Strategy, Matchup synergy and advanced item cards.
- Pinned Valve cf0d37a32c8df338a7832fd32a282747969e9a5f: Poison Attack has attack behavior, mana 20, bonus attack range 25, four-second DPS 4/8/12/16 and six stacks. Current Shard adds two stacks, armor reduction per stack and 40% damage against buildings. Lens/Supremacy do not fabricate attack reach.
- Current Nethertoxin has range 900, cast point 0.2, projectile speed 2400, radius 400, ramping damage over four seconds and attack slow 30/40/50/60. It does not apply Break and overlapping toxins do not stack.
- Strike has range 750, cast point 0.2, speed 1500, six-second DPS 70/110/150, undispellable Break and piercing slow. Decisions use a conservative next-tick damage estimate rather than guaranteed full-duration damage.
- Nosedive has range 700, radius 500, cast point 0.1, dive speed 700, ROOT_DISABLES and current 25-second cooldown. It applies Nethertoxin and Corrosive Skin; Corrosive Skin reflected damage cannot provide lifesteal.
- Verified current breakable Bristleback, Huskar Berserker Blood, Spectre Dispersion/Desolate, Phantom Assassin Immaterial/Coup and Dragon Knight Dragon Blood/Wyrm Wrath metadata for a narrow Break value preference.

Implemented behavior
- Removed inconsistent eager autocast and nil-target action returns. Poison Attack now uses actual attack range plus its own bonus, respects disarm and ethereal defenses, preserves ready Strike mana and supports current Shard building attacks.
- Autocast follows actual useful attacks, turns off without requiring mana/cooldown readiness and never issues a nil entity cast. Manual retreat and ally peel remain available.
- Nethertoxin uses real predicted projectile landing and clamped AoE edges, actual local packs, objective attacks and existing toxin preservation.
- Strike works through debuff immunity, selects meaningful unbroken passive targets and physical attackers, offers human or bot retreat peel and rejects spell block/reflection, protected victims and existing Strike. Removed unconditional nearby ultimates and incorrect damage-plus-duration arithmetic.
- Nosedive uses real safe reachable landing or escape, rejects root/leash/Rupture/Coil, hazardous or outnumbered landings and low-health dives. Copied offensive dives require an actual learned linked effect; safe displacement still works without native passives.
- Copied handlers preserve unknown dispatch and optional handle state. Existing affordable Power Treads spell preparation is preserved.
- Protective ally peel now uses actual recent damage and observed pursuit without requiring a bot-only retreat mode; native and copied idle-mode human ally positives and no-threat negatives pass.
- API audit replaces undocumented HasShard calls with actual modifier_item_aghanims_shard state; current shard positive and negative fixtures pass.
- Dream Coil movement guards now use the pinned localized modifier_puck_coiled name.

Rejected or stale source claims
- Rejected Matchup claims that Nethertoxin applies Break, Corrosive Skin supplies spell lifesteal, BKB always defeats piercing Strike, old disassembled Arcane recipes and guaranteed full-duration damage.

Item follow-up observations for TASK-21
- TASK-21: Review current Shard building attacks, Dragon Lance/Pike attack reach, spell versus attack range distinction, safe Nosedive/Pike positioning, mana reserve and Scepter Corrosive Skin behavior. No builds or shared item policies changed.

Enemy counterplay observations for TASK-24
- TASK-24: Use applicable block/reflection against piercing Strike, avoid extended poison stacks and toxin zones, respect current Break and attack slow, and use magic resistance, disarm, displacement and illusion pressure.

Lobby validation checklist
- Validate actual attack-based manual orb reach with Dragon Lance/Pike and copies, engine autocast under temporary unavailable mana, one-tick Strike arrival timing and Nosedive subability provisioning/landing with Lens.
- No game or deep weak-hero validation was performed.

Focused verification
- Fengari tests/viper_ability_spec.lua passed: true attack reach without Lens padding, disarm and immunity, repeated autocast and low-mana toggle off, Shard buildings/glyph, toxin AoE edges and moving targets, local packs and mana reserves, piercing Strike/reflect, regeneration/next-tick damage and Break preference, Nosedive root/Rupture/hazard/range/HP, absent linked spells, Supremacy/Break, null/hidden/inactive handles and item preparation.
- Focused specification rerun after human ally parity follow-up passed.
- Cooldown toggle-only routing callback positive and hidden/channel negatives pass. Weaver uses documented ToggleAutoCast; Viper was already using it.
- Final fractional-value audit passed: focused fixtures now truncate GetSpecialValueInt and preserve GetSpecialValueFloat; all eleven completed focused specs reran with pass markers.
- Final owned batch audit passed: all twelve focused Fengari specs emitted pass markers and all thirty-eight native/copied/spec/companion Lua files parsed as Lua 5.2. No game validation claimed.
- Native and copied actual Coiled movement negatives pass; Ursa rooted stationary damage remains available under Coil, while Tusk Snowball/Buddies and Viper Nosedive movement decline.

Framework integration
- ConsiderStolenPoisonAutoCast: exact actual non-null trained visible activated autocast handle, normal J.CanNotUseAbility/queue locks preserved, toggle-only mutation through documented ToggleAutoCast. Root routes before readiness to permit safe cooldown-insensitive OFF; no manual cast or state-gate bypass.

Full integration/build verification passed. Builds, skill/talent preferences and draft weights are unchanged. No game launched; engine-dependent claims remain lobby checks.

Final integrated verification: node tests/run-builds.cjs, node tests/run-objectives.cjs, node tests/valve_ability_check.cjs and git diff --check passed. Build/skill/talent preference AST comparison passed for all 43 scoped heroes. Native and applicable copied regressions are registered in run-builds. Framework callbacks and unsupported-spell dispatch preservation are covered. No game launched; the recorded lobby checklist remains required.
<!-- SECTION:NOTES:END -->

## Final Summary

<!-- SECTION:FINAL_SUMMARY:BEGIN -->
Viper standard ability pass completed offline. Native and copied behavior reviewed against Torte and full Dotacoach Strategy/Counter Strategy/Matchup and pinned Valve KV/localization. Meaningful behavior fixes and positive/negative regressions implemented; builds and flags preserved. Final integrated verification: node tests/run-builds.cjs, node tests/run-objectives.cjs, node tests/valve_ability_check.cjs and git diff --check passed. Build/skill/talent preference AST comparison passed for all 43 scoped heroes. Native and applicable copied regressions are registered in run-builds. Framework callbacks and unsupported-spell dispatch preservation are covered. No game launched; the recorded lobby checklist remains required.
<!-- SECTION:FINAL_SUMMARY:END -->
