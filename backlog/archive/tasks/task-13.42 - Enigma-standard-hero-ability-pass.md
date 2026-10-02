---
id: TASK-13.42
title: 'Enigma: standard hero ability pass'
status: Needs In-Game Test
assignee:
  - '@codex'
created_date: '2026-10-02 09:07'
updated_date: '2026-10-02 10:40'
labels:
  - hero
dependencies: []
references:
  - bots/BotLib/hero_enigma.lua
  - tests/enigma_ability_spec.lua
documentation:
  - backlog/docs/doc-2 - Hero-improvement-playbook.md
modified_files:
  - bots/BotLib/hero_enigma.lua
  - bots/FunLib/rubick_hero/enigma.lua
  - tests/enigma_ability_spec.lua
  - bots/FunLib/enigma_abilities.lua
parent_task_id: TASK-13
priority: medium
ordinal: 82000
---

## Description

<!-- SECTION:DESCRIPTION:BEGIN -->
Enigma is part of the requested Ember Spirit through Pugna hero-file-order batch. Review actual spell decisions against current mechanics and human usage, fixing meaningful ability-use gaps while retaining the established D2PT build.
<!-- SECTION:DESCRIPTION:END -->

## Acceptance Criteria
<!-- AC:BEGIN -->
- [x] #1 Ability decisions and cast order are reviewed against Torte de Lini, dotacoach Strategy/Counter Strategy/full Matchup and pinned Valve definitions/localization; verified checklist and stale claims are recorded
- [x] #2 Identified meaningful behavior gaps are fixed, including applicable Rubick handling, with positive and negative offline regression scenarios
- [x] #3 Focused hero scenarios, Valve ability check and full build suite pass; lobby checklist and engine limitations are recorded for Needs In-Game Test handoff
<!-- AC:END -->

## Implementation Plan

<!-- SECTION:PLAN:BEGIN -->
Restore current Blink initiation, real Hole geometry, immediate interrupts and held-target-only Pulse setup; immunity-piercing Pulse, live specials and summon health budget; copied independent cast parity.
<!-- SECTION:PLAN:END -->

## Implementation Notes

<!-- SECTION:NOTES:BEGIN -->
Source review and offline implementation for the Ember Spirit → Pugna batch (hero-file order).

Sources: Torte CLI tools/tdl/fetch.cjs enigma; https://dotacoach.gg/en/heroes/enigma and https://dotacoach.gg/en/heroes/counters/enigma (full Strategy, Counter Strategy and Matchup); Valve d2vpkr cf0d37a32c8df338a7832fd32a282747969e9a5f hero definitions plus English ability localization.

Verified ability checklist
- Malefice targets an enemy unit at 450/500/550/600 range. It has three instances dealing 100 damage at maximum level. The talent adds four instances; Shard adds 0.3 seconds of stun and an Eidolon each tick.
- Demonic Summoning is a point spell, rather than creep conversion, at 400 range. It costs 75/100/125/150 health and summons three Eidolons, which multiply after six attacks. The 3% current-health special improves summon health; it is not an additional casting cost.
- Midnight Pulse has a 700 cast range and 600 radius, with 200 added by the current radius talent. It deals magical damage that pierces debuff immunity: 5/10/15/20 base damage plus 4/6/8/10% of current health.
- Black Hole channels for four seconds at 275 cast range with a 420 disabling radius and 100/150/200 pure DPS. Scepter adds 4% maximum-health damage and a nondisabling pull over 1000 range at 150 speed.
- Event Horizon and Gravity Well passives are not assumed on copied spells. Obsolete facet and passive definitions are excluded.
- Read the full Torte guide, Strategy, Counter Strategy and Matchup cards, then checked pinned Valve KV and localization.

Implemented behavior
- Native initiation discovers a ready Blink each tick and clears stale handles. Malefice channel interruption precedes initiation.
- Black Hole predicts real caught heroes within 420 radius and bounds the center by its actual 275 cast range plus Lens or Supremacy. Scepter’s 1000-range outer pull does not count as an immediate disable.
- Unheld targets receive an immediate Blink–Black Hole attempt. Extra Pulse setup is allowed only when the target is already held; a direct Hole opportunity precedes independent Pulse.
- Removed the early return caused by an unrelated nearby Black Hole. The generic gate continues to protect the actor’s own channel.
- Pulse uses its current radius and immunity-piercing magical damage. Removed the incorrect manual addition from the Black Hole DPS talent.
- Malefice uses current instance specials without manually counting talent damage twice. Its interrupt checks use actual reach and corrected allied and enemy counts.
- All summon branches preserve a health budget after the actual flat casting cost.
- Native and copied spells share Enigma-specific decisions without assuming missing passives or linked abilities.

Rejected or stale source claims
- The current Pulse radius talent is _9; the old _6 reference belongs to Black Hole DPS.
- Old claims that Pulse deals pure or maximum-health damage are excluded. Current Pulse damage is magical and uses current health.
- Scepter’s outer pull does not interrupt channels and cannot count as a hero caught in the 420 disabling radius.
- Old creep-sacrifice conversion and obsolete facet behavior are excluded.

Item follow-up observations for TASK-21
- TASK-21: BKB before Blink/Black Hole; Refresher requires mana for two ultimates plus reset. Drums/Bearing assist Eidolon army; Soul Ring health cost must fit Summoning health budget.

Enemy counterplay observations for TASK-24
- TASK-24: separate in chokes, kill Eidolons before six attacks, exploit Hole cooldown; reserve BKB-piercing interrupt/save outside actual 420 radius. Magic-resist items do not mitigate pure Hole.

Lobby validation checklist
- Validate interrupted Blink, Pulse and Black Hole sequences, the 0.3-second cast point against moving targets, and BKB timing against piercing interrupters.
- Validate Scepter’s outer 1000-range pull separately. It may bring enemies into the hole later but does not guarantee an initial catch.
- Validate Shard Eidolon spawns from Malefice, talent-resolved specials and minion splitting after six attacks.

Focused verification
- The native and copied Enigma Fengari scenarios passed. All four files parsed as Lua 5.2, and the global Valve check passed.

Full integration/build verification passed. Builds, skill/talent preferences and draft weights are unchanged. No game launched; engine-dependent claims remain lobby checks.

Final integrated verification: node tests/run-builds.cjs, node tests/run-objectives.cjs, node tests/valve_ability_check.cjs and git diff --check passed. Build/skill/talent preference AST comparison passed for all 49 scoped heroes. Native and applicable copied regressions are registered in run-builds. Framework callbacks and unsupported-spell dispatch preservation are covered. No game launched; the recorded lobby checklist remains required.
<!-- SECTION:NOTES:END -->

## Final Summary

<!-- SECTION:FINAL_SUMMARY:BEGIN -->
Enigma standard ability pass completed offline. Native and copied behavior reviewed against Torte, full Dotacoach Strategy/Counter Strategy/Matchup and pinned Valve KV/localization. Meaningful behavior fixes and positive/negative regressions implemented; builds and flags preserved. Final integrated verification: node tests/run-builds.cjs, node tests/run-objectives.cjs, node tests/valve_ability_check.cjs and git diff --check passed. Build/skill/talent preference AST comparison passed for all 49 scoped heroes. Native and applicable copied regressions are registered in run-builds. Framework callbacks and unsupported-spell dispatch preservation are covered. No game launched; the recorded lobby checklist remains required.
<!-- SECTION:FINAL_SUMMARY:END -->
