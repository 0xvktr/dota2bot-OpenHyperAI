---
id: TASK-13.88
title: 'Spectre: standard hero ability pass'
status: Needs In-Game Test
assignee:
  - '@codex'
created_date: '2026-10-02 14:28'
updated_date: '2026-10-02 16:24'
labels:
  - hero
dependencies: []
references:
  - bots/BotLib/hero_spectre.lua
  - tests/spectre_ability_spec.lua
documentation:
  - backlog/docs/doc-2 - Hero-improvement-playbook.md
modified_files:
  - bots/BotLib/hero_spectre.lua
  - bots/FunLib/rubick_hero/spectre.lua
  - tests/spectre_ability_spec.lua
parent_task_id: TASK-13
priority: medium
ordinal: 128000
---

## Description

<!-- SECTION:DESCRIPTION:BEGIN -->
Spectre is part of the requested Queen of Pain through Zeus hero-file-order batch. Review actual spell decisions against current mechanics and human usage, fixing meaningful ability-use gaps while retaining the established D2PT build.
<!-- SECTION:DESCRIPTION:END -->

## Acceptance Criteria
<!-- AC:BEGIN -->
- [x] #1 Ability decisions and cast order are reviewed against Torte de Lini, dotacoach Strategy/Counter Strategy/full Matchup and pinned Valve definitions/localization; verified checklist and stale claims are recorded
- [x] #2 Identified meaningful behavior gaps are fixed, including applicable Rubick handling, with positive and negative offline regression scenarios
- [x] #3 Focused hero scenarios, Valve ability check and full build suite pass; lobby checklist and engine limitations are recorded for Needs In-Game Test handoff
<!-- AC:END -->

## Implementation Plan

<!-- SECTION:PLAN:BEGIN -->
Repair Dagger cast shape and damage, validate Reality against actual owned spell-created illusions, and improve safe global support and runtime Dispersion activation without changing builds.
<!-- SECTION:PLAN:END -->

## Implementation Notes

<!-- SECTION:NOTES:BEGIN -->
Source review and offline implementation for the Queen of Pain → Zeus batch (hero-file order).

Sources: Torte CLI tools/tdl/fetch.cjs spectre; https://dotacoach.gg/en/heroes/spectre and https://dotacoach.gg/en/heroes/counters/spectre (full Strategy, Counter Strategy and Matchup); Valve d2vpkr cf0d37a32c8df338a7832fd32a282747969e9a5f hero definitions plus English ability localization.

Verified ability checklist
- Read all native ability decisions, the full Torte guide 129400942, complete Dotacoach Strategy and Counter Strategy and all Matchup gameplay, synergy, advanced core and counter item cards. Verify mechanics using pinned Valve cf0d37a32c8df338a7832fd32a282747969e9a5f and localization.
- Dagger is a point or enemy-hero cast, range 1800, magical damage 80/120/160/200, projectile speed 800, dagger radius 125 and path radius 175. It grants movement through terrain and localization explicitly exempts spell block and reflect. Current applies_desolate is zero.
- Shadow Step has range 1000 and duration 3.5/4/4.5/5 seconds, creates an attacking illusion and links Reality. Haunt is a six-second global illusion spell. Reality is a point cast, costs 25, is disabled by roots, and destroys its selected illusion. Scepter improves Haunt cooldown and first-Reality fear; no extra linked damage is invented.
- Dispersion is a breakable passive until its actual runtime active upgrade becomes available. Shard boosts absorption and reflection by 50% of base for five seconds with 25-second cooldown and 50 mana. Desolate is pure damage on isolated attacks and is not folded into Dagger.
- Documented NumModifiers, GetModifierSourceAbility and ability GetCaster allow conservative actual-source validation. Lens 225 and trained unbroken Supremacy 240 are the only manually added item/passive cast bonuses.

Implemented behavior
- Removed Dagger kill logic that classified it as pure damage and sometimes returned a travel-time number as a point. Magical kills account for regeneration and projectile arrival. Targeted Dagger respects its explicit block/reflect exemption.
- Dagger can draw a line through multiple enemy heroes or creeps, secure ranged creeps, and create an escape trail through terrain. Farm decisions measure line coverage rather than an unrelated circular AoE.
- Record requested Haunt and Shadow Step handles through a bounded pending window. Reality requires a living allied illusion with a modifier source matching that recorded actual ability and actual caster, then starts the lifetime from observed spawn. Manta, foreign illusions, absent sources and expired records are rejected.
- Reality evaluates all valid escape destinations before selecting the closest one, rather than resetting its nearest-distance value per iteration. Offensive jumps require safe terrain, no tower/Chronosphere/Black Hole, acceptable numbers, attackable target and sufficient health, with extra caution under Break.
- Shadow Step uses exact range and follows actual human or bot ally attacks without requiring an ally bot mode. Haunt follows distant ally engagements and avoids redundant live requests. Neither copied ability assumes an absent Reality, Dagger, Desolate or Dispersion handle.
- Runtime active Dispersion reacts to real nearby damage or a low-health boss attack, rejects Break and existing boost, and retains the passive/hidden/deactivated handle gate. Native and copied paths share the tested decisions.
- Displacement rejects the actual Dream Coil modifier and Rupture on the unit that would move, including human ally Cookie and Toss recipients.

Rejected or stale source claims
- Current Dagger does magical damage and applies_desolate is zero; the removed pure-damage fallback was invalid.
- Some guide and Matchup prose calls Shadow Step global. Pinned current range is 1000; Haunt provides global presence.
- The guide includes unrelated Lance, Phylactery and other item prose. These are recorded as stale source content and do not change builds or introduce fabricated spell effects.
- Reality localization mentions a Shard Dagger while the pinned cast_dagger_on_target values remain zero. This pass does not assume linked damage from that inconsistent description.

Item follow-up observations for TASK-21
- TASK-21 follow-up: Radiance and Manta improve farming and illusion pressure; Skadi, Butterfly and Abyssal improve extended fights and pursuit. Manta/BKB help against disables and Break according to actual dispel eligibility. Shard improves Dispersion burst response and Scepter improves Haunt access/fear. Preserve current purchases and shared item policy.

Enemy counterplay observations for TASK-24
- TASK-24 follow-up: Break disables Desolate and Dispersion; sustain, roots, attack immunity and early pressure restrict safe jumps. Healing allies can extend Spectre fights, while actual allied attacks and global follow-up create entry opportunities. Respect reflected damage, Carapace, protected targets and unsafe tower or AoE-control destinations.

Lobby validation checklist
- No game was launched. Verify that actual Haunt and Shadow Step illusions expose their creating spell in GetModifierSourceAbility; if they do not, the conservative Reality policy declines rather than guessing ownership from an illusion name.
- Verify queued cast-to-spawn timing and duration, missing copied Reality, root and Rupture behavior, target death and illusion destruction, global ally support, and first-Reality Scepter fear.
- Verify Dagger point length with range items, line coverage, unobstructed escape movement and actual targeted block/reflect exemption. Verify upgraded Dispersion runtime behavior flags and absorption during Break.

Focused verification
- Focused native/copied Spectre ability scenarios passed under Fengari.
- Valve ability check passed: 128 native heroes, 88 copied modules, zero findings; owned diff whitespace clean.
- Regressions cover magical kill timing, exact ranges and Lens, unit versus valid point casts, line clear and ranged creep secure, escape paths, ally attack parity, no-spawn-to-observed owned illusion, wrong source/caster/team, no source, expiry, root/unsafe landing, nearest escape across multiple candidates, missing linked spells, passive and unavailable handles, Break, occupied queues and nil-first copied unknown dispatch.
- Full integration and build suite remain root-owned.
- Audited fractional special values against pinned data. Focused fixtures truncate integer getters toward zero and preserve float getters; all existing timing and moving-target scenarios pass with these engine semantics.
- Verified real pinned Dream Coil modifier modifier_puck_coiled with a focused displacement refusal regression.

Full integration/build verification passed. Builds, skill/talent preferences and draft weights are unchanged. No game launched; engine-dependent claims remain lobby checks.

Final integrated verification: node tests/run-builds.cjs, node tests/run-objectives.cjs, node tests/valve_ability_check.cjs and git diff --check passed. Build/skill/talent preference AST comparison passed for all 43 scoped heroes. Native and applicable copied regressions are registered in run-builds. Framework callbacks and unsupported-spell dispatch preservation are covered. No game launched; the recorded lobby checklist remains required.
<!-- SECTION:NOTES:END -->

## Final Summary

<!-- SECTION:FINAL_SUMMARY:BEGIN -->
Spectre standard ability pass completed offline. Native and copied behavior reviewed against Torte and full Dotacoach Strategy/Counter Strategy/Matchup and pinned Valve KV/localization. Meaningful behavior fixes and positive/negative regressions implemented; builds and flags preserved. Final integrated verification: node tests/run-builds.cjs, node tests/run-objectives.cjs, node tests/valve_ability_check.cjs and git diff --check passed. Build/skill/talent preference AST comparison passed for all 43 scoped heroes. Native and applicable copied regressions are registered in run-builds. Framework callbacks and unsupported-spell dispatch preservation are covered. No game launched; the recorded lobby checklist remains required.
<!-- SECTION:FINAL_SUMMARY:END -->
