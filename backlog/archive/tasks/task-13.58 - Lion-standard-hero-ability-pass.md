---
id: TASK-13.58
title: 'Lion: standard hero ability pass'
status: Needs In-Game Test
assignee:
  - '@codex'
created_date: '2026-10-02 09:09'
updated_date: '2026-10-02 10:40'
labels:
  - hero
dependencies: []
references:
  - bots/BotLib/hero_lion.lua
  - tests/lion_ability_spec.lua
documentation:
  - backlog/docs/doc-2 - Hero-improvement-playbook.md
modified_files:
  - bots/BotLib/hero_lion.lua
  - bots/FunLib/rubick_hero/lion.lua
  - tests/lion_ability_spec.lua
parent_task_id: TASK-13
priority: medium
ordinal: 98000
---

## Description

<!-- SECTION:DESCRIPTION:BEGIN -->
Lion is part of the requested Ember Spirit through Pugna hero-file-order batch. Review actual spell decisions against current mechanics and human usage, fixing meaningful ability-use gaps while retaining the established D2PT build.
<!-- SECTION:DESCRIPTION:END -->

## Acceptance Criteria
<!-- AC:BEGIN -->
- [x] #1 Ability decisions and cast order are reviewed against Torte de Lini, dotacoach Strategy/Counter Strategy/full Matchup and pinned Valve definitions/localization; verified checklist and stale claims are recorded
- [x] #2 Identified meaningful behavior gaps are fixed, including applicable Rubick handling, with positive and negative offline regression scenarios
- [x] #3 Focused hero scenarios, Valve ability check and full build suite pass; lobby checklist and engine limitations are recorded for Needs In-Game Test handoff
<!-- AC:END -->

## Implementation Plan

<!-- SECTION:PLAN:BEGIN -->
- Control before Mana Drain; correctly identify owned Drain channel.
- Hex unit-target with radius talent; Spike actual damage and directional reach.
- Finger dynamic damage, own stack/scepter values and actual range.
- Safe ally mana supply and copied spell decisions; offline scenarios.
<!-- SECTION:PLAN:END -->

## Implementation Notes

<!-- SECTION:NOTES:BEGIN -->
Source review and offline implementation for the Ember Spirit → Pugna batch (hero-file order).

Sources: Torte CLI tools/tdl/fetch.cjs lion; https://dotacoach.gg/en/heroes/lion and https://dotacoach.gg/en/heroes/counters/lion (full Strategy, Counter Strategy and Matchup); Valve d2vpkr cf0d37a32c8df338a7832fd32a282747969e9a5f hero definitions plus English ability localization.

Verified ability checklist
- Read the entire native SkillsComplement and consideration functions, Torte guide 128929132, complete Dotacoach Strategy, Counter Strategy and Matchup pages, and pinned Valve data and localization.
- Verified Earth Spike damage 105/170/235/300, range 650 plus a 600 talent bonus, length buffer 275, speed 2800 and width 140; Hex remains entity targeted with range 575–650 and an optional radius of 250; Mana Drain has range 850, channel duration 5.1 seconds, mana drain 20–120 per second and 50% allied transfer; Finger range 900, damage 600/725/850 plus runtime Scepter 100, 25 damage per owned kill plus talent 20, damage delay 0.25 seconds and splash radius 325.
- Reviewed Grimstroke double targeting, mana support for Medusa, Storm and Leshrac, and allied follow-up control without changing drafts.

Implemented behavior
- Prioritize Hex initiation and channel interruption before damage or Mana Drain. Keep its current entity targeting even with the area talent.
- Move Mana Drain after control and damage. Transfer mana to low-mana allies only without nearby enemies and with a sufficient personal reserve.
- Target verified basic illusions with explicit spell-block and reflection guards; decline uncertain strong Chaos Knight or Vengeful Spirit illusions.
- Use live Finger damage, the caster’s actual kill counter and damage delay, actual cast range, and useful Scepter clusters. Decline the alternative melee mode rather than estimate it as an ordinary ranged Finger.
- Predict directional Earth Spike using real speed, range and length buffer, clamp its native aim point, and replace the old zero GetAbilityDamage estimate.
- Cancel only the caster’s actual active Mana Drain during a threatened retreat. Add focused copied decisions without inferring ownership of unrelated channels.

Rejected or stale source claims
- Ground-targeted Earth Spike does not fit the claim that all spells reflect. The Troll survival ability is Battle Trance, not Berserker’s Rage.
- The guide’s support sequence is useful, but builds and talents were not changed.
- Runtime Scepter damage is read directly; its 100 bonus is not added twice.

Item follow-up observations for TASK-21
- TASK21: Blink enables immediate Hex. Glimmer can precede Mana Drain, Force Staff supports escape, and Ethereal Blade amplifies magic damage. Verify current Shard channel protection, including 60% magic resistance and debuff immunity.

Enemy counterplay observations for TASK-24
- TASK24: Fog can break Mana Drain. Pressure Lion, use block or reflection against entity spells, distinguish directional Earth Spike, and expect Blink Hex and accumulated Finger damage.

Lobby validation checklist
- Verify Hex targeting under the radius talent, Earth Spike’s cone talent and length buffer, allied mana transfer at 50%, and Shard multi-illusion behavior and channel protection.
- Verify ranged versus alternative melee Finger, actual kill-counter snapshots, and emergency cancellation during real Mana Drain channels.

Focused verification
- Fengari tests/lion_ability_spec.lua: Lion ability scenarios passed, 7 scenario groups.
- No game launched; root full checks pending.

Framework integration
- Invoke StopDrain before Rubick’s channel gate. Native SkillsComplement handles cancellation of its own active Mana Drain.

Full integration/build verification passed. Builds, skill/talent preferences and draft weights are unchanged. No game launched; engine-dependent claims remain lobby checks.

Final integrated verification: node tests/run-builds.cjs, node tests/run-objectives.cjs, node tests/valve_ability_check.cjs and git diff --check passed. Build/skill/talent preference AST comparison passed for all 49 scoped heroes. Native and applicable copied regressions are registered in run-builds. Framework callbacks and unsupported-spell dispatch preservation are covered. No game launched; the recorded lobby checklist remains required.
<!-- SECTION:NOTES:END -->

## Final Summary

<!-- SECTION:FINAL_SUMMARY:BEGIN -->
Lion standard ability pass completed offline. Native and copied behavior reviewed against Torte, full Dotacoach Strategy/Counter Strategy/Matchup and pinned Valve KV/localization. Meaningful behavior fixes and positive/negative regressions implemented; builds and flags preserved. Final integrated verification: node tests/run-builds.cjs, node tests/run-objectives.cjs, node tests/valve_ability_check.cjs and git diff --check passed. Build/skill/talent preference AST comparison passed for all 49 scoped heroes. Native and applicable copied regressions are registered in run-builds. Framework callbacks and unsupported-spell dispatch preservation are covered. No game launched; the recorded lobby checklist remains required.
<!-- SECTION:FINAL_SUMMARY:END -->
