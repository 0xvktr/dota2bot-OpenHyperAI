---
id: TASK-13.124
title: 'Treant Protector: standard hero ability pass'
status: Needs In-Game Test
assignee:
  - '@codex'
created_date: '2026-10-02 16:00'
updated_date: '2026-10-02 16:24'
labels:
  - hero
dependencies: []
references:
  - bots/BotLib/hero_treant.lua
  - tests/treant_ability_spec.lua
documentation:
  - backlog/docs/doc-2 - Hero-improvement-playbook.md
modified_files:
  - bots/BotLib/hero_treant.lua
  - bots/FunLib/rubick_hero/treant.lua
  - tests/treant_ability_spec.lua
parent_task_id: TASK-13
priority: medium
ordinal: 164000
---

## Description

<!-- SECTION:DESCRIPTION:BEGIN -->
Treant Protector is part of the requested Queen of Pain through Zeus hero-file-order batch. Review actual spell decisions against current mechanics and human usage, fixing meaningful ability-use gaps while retaining the established D2PT build.
<!-- SECTION:DESCRIPTION:END -->

## Acceptance Criteria
<!-- AC:BEGIN -->
- [x] #1 Ability decisions and cast order are reviewed against Torte de Lini, dotacoach Strategy/Counter Strategy/full Matchup and pinned Valve definitions/localization; verified checklist and stale claims are recorded
- [x] #2 Identified meaningful behavior gaps are fixed, including applicable Rubick handling, with positive and negative offline regression scenarios
- [x] #3 Focused hero scenarios, Valve ability check and full build suite pass; lobby checklist and engine limitations are recorded for Needs In-Game Test handoff
<!-- AC:END -->

## Implementation Plan

<!-- SECTION:PLAN:BEGIN -->
Repair current attack Leech Seed, global player-damage Living Armor priorities, sequential Grasp geometry, piercing Overgrowth, actual owned Eye vision and runtime active Guise/Super Bloom.
<!-- SECTION:PLAN:END -->

## Implementation Notes

<!-- SECTION:NOTES:BEGIN -->
Source review and offline implementation for the Queen of Pain → Zeus batch (hero-file order).

Sources: Torte CLI tools/tdl/fetch.cjs treant; https://dotacoach.gg/en/heroes/treant-protector and https://dotacoach.gg/en/heroes/counters/treant-protector (full Strategy, Counter Strategy and Matchup); Valve d2vpkr cf0d37a32c8df338a7832fd32a282747969e9a5f hero definitions plus English ability localization.

Verified ability checklist
- Read all native decision functions and blind Blink combo, full Torte guide 129107725 and correct treant-protector Dotacoach Strategy, Counter Strategy and entire Matchup synergy, gameplay and advanced item cards. Verify pinned hero KV, English localization and pinned npc_units.
- Current Leech Seed is a unit-target attack at range 150, costs 35 mana, roots/disarms for 0.75/1/1.25/1.5, deals 20/40/60/80 bonus magical damage and emits two healing pulses to up to five allies within 650 based on actual attack damage; current healing fraction is 10/15/20/25%.
- Living Armor is global, cast 0.3, 80 mana, lasts 12 seconds plus actual talent, heals 4/7/10/13 per second and blocks 60/80/100/120 damage from player-controlled sources, losing 20 block per qualifying hit and ignoring hits below ten.
- Grasp range 1500, cast 0.2, sequential creation interval 0.1, node spacing 175, initial latch delay 0.3 and latch range 135. Current damage is 35/50/65/80 per second, lifetime 9/10/11/12 and creep damage penalty 35%. No current extra-tree-damage field.
- Overgrowth radius 800, cast 0.5, root/disarm 3/4/5 seconds and magical damage 95 per second. It affects units already debuff immune; gaining immunity afterward removes it. Current Scepter reduces cooldown by 25 and supplies sixteen-second attack/Strength/movement bloom.
- Eyes is granted by Shard, tree-target range 350, cast 0.2, two charges restored in 135 seconds, duration 360 and vision 800. Pinned npc_dota_treant_eyes is stationary, cannot attack and has no ability slots. Guise static KV is passive but localization supports a runtime active invisible form while Tree Walking. Super Bloom exists as a separate current Scepter spell in KV; use only its real trained visible available handle.

Implemented behavior
- Leech Seed casts only its actual enemy unit attack shape, checks exact range, disarm, Break, physical and debuff immunity, shields and reflection. It supports actual human victims and actual injured allies near a creep attack. Removed ground targeting, obsolete continuous damage and fake long-range boss self-casts.
- Living Armor scans actual global human heroes and buildings, prioritizes current player danger and critical health over ordinary healing, supports threatened towers and self protection, avoids duplicates/fountain healing and reserves actual Overgrowth mana for ordinary heal casts. Ice Blast forbids heal-only casts, while current incoming player damage can still justify the diminishing block. Runtime point-only shape remains legal.
- Grasp predicts sequential vine arrival and the real caster-to-point line, extends toward a fleeing target only inside actual point range and rejects targets leaving its latch coverage. Useful real ally support and line-aligned creep groups preserve actual ultimate mana. No full-duration lethal or obsolete tree bonus is promised.
- Overgrowth checks actual predicted coverage from caster and living same-team, same-player named Eye entities; missing linked Eye spell does not invent entities. It interrupts channels, saves actual human attack victims and controls relevant fights including enemies already debuff immune. Existing roots and redundant disabled windows decline. Removed blind Blink plus fixed delayed ultimate queues.
- Eyes selects safe nearby actual tree IDs with useful fresh coverage, current charges and mana reserve. Coverage comes from actual living allied Eye entities; a cast request adds a bounded three-second pending lock and canceled requests expire. Foreign-team, dead and unrelated entities do not prove allied vision; remote root coverage requires actual same-player ownership.
- Guise requires an actual active no-target runtime shape and the ordinary trained, visible, activated, nonpassive ready handle; static passive data cannot bypass gates. Native ordinary spells remain usable during Guise invisibility, which ends on attack or leaving trees. Super Bloom uses only an available runtime active spell and useful attack or threatened retreat, without assuming a linked ultimate. Unknown copied dispatch returns nil before any gates or lookups.
- Eyes vision placement also respects actual living allied teammate Eyes, because their vision is shared; remote Overgrowth still requires same-player ownership. Unknown player ownership can prevent redundant vision but never prove remote root coverage.

Rejected or stale source claims
- Removed obsolete ground Leech Seed/sapling targeting, old Living Armor numeric armor claims and Scepter Eyes ownership. Current Eyes comes from Shard. Dotacoach Grasp tree amplification and Shard invisibility/detection prose describe older mechanics.
- Older guide Solar Crest enemy armor debuff, Medallion progression and amplified innate healing are not encoded as current mechanics.

Item follow-up observations for TASK-21
- TASK-21: Arcane sustain, Lens cast reach, Blink positioning, current Solar Crest ally barrier, Shard vision, current Scepter attack upgrade and Refresher can support Treant. Preserve all purchases and shared item policy; no blind Blink/Overgrowth or enemy dispel cooldown assumption.

Enemy counterplay observations for TASK-24
- TASK-24: tree destruction and detection expose Guise and remove Eyes; direct player attacks consume Living Armor block. New BKB, Manta, Lotus and other dispels can remove Overgrowth, but existing debuff immunity does not prevent it. Silence, roots, channel danger, reflection and physical immunity constrain actual attack Seed decisions.

Lobby validation checklist
- No game was launched. Verify current Guise runtime IsPassive/IsActivated/NO_TARGET transitions near trees and Grasp vines. If the engine exposes only the passive form, the conservative handler declines instead of loosening shared gates.
- Verify actual Eye GetPlayerID ownership exposure and remote Overgrowth application. Unknown or negative player ownership declines. Coverage never persists for the nominal 360 seconds from a request alone; dead/destroyed actual Eyes disappear from current coverage.
- Verify current runtime Super Bloom visibility versus the bloom already granted by Overgrowth; unavailable hidden/deactivated variants decline. Verify Grasp sequential spawn geometry and attack Seed healing pulses; tests make no unverified full-duration damage/heal promise.

Focused verification
- Treant native/copied focused Fengari scenarios passed for exact ranges and Break, current Seed unit/attack shape and both immunity types, missing linked spells, human creep healing, critical global allies and towers, player block under Ice Blast, ordinary mana reserves, real line geometry/moving targets, current debuff-immune Overgrowth and predicted escape, actual own/foreign/dead Eyes, canceled pending casts, charges, runtime Guise/Bloom shapes, queue/channel locks and nil-first unknown dispatch. Integer getters truncate toward zero and float getters preserve fractional timings.
- Valve ability check passed at 128 native heroes and 123 copied modules with zero findings. Owned whitespace is clean. Shared registration and full suite are root-owned.
- Added allied teammate/unknown-owner vision coverage versus foreign-team distinction; focused scenarios pass.

Full integration/build verification passed. Builds, skill/talent preferences and draft weights are unchanged. No game launched; engine-dependent claims remain lobby checks.

Final integrated verification: node tests/run-builds.cjs, node tests/run-objectives.cjs, node tests/valve_ability_check.cjs and git diff --check passed. Build/skill/talent preference AST comparison passed for all 43 scoped heroes. Native and applicable copied regressions are registered in run-builds. Framework callbacks and unsupported-spell dispatch preservation are covered. No game launched; the recorded lobby checklist remains required.
<!-- SECTION:NOTES:END -->

## Final Summary

<!-- SECTION:FINAL_SUMMARY:BEGIN -->
Treant Protector standard ability pass completed offline. Native and copied behavior reviewed against Torte and full Dotacoach Strategy/Counter Strategy/Matchup and pinned Valve KV/localization. Meaningful behavior fixes and positive/negative regressions implemented; builds and flags preserved. Final integrated verification: node tests/run-builds.cjs, node tests/run-objectives.cjs, node tests/valve_ability_check.cjs and git diff --check passed. Build/skill/talent preference AST comparison passed for all 43 scoped heroes. Native and applicable copied regressions are registered in run-builds. Framework callbacks and unsupported-spell dispatch preservation are covered. No game launched; the recorded lobby checklist remains required.
<!-- SECTION:FINAL_SUMMARY:END -->
