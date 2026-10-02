---
id: TASK-13.71
title: 'Ogre Magi: standard hero ability pass'
status: Needs In-Game Test
assignee:
  - '@codex'
created_date: '2026-10-02 09:09'
updated_date: '2026-10-02 10:40'
labels:
  - hero
dependencies: []
references:
  - bots/BotLib/hero_ogre_magi.lua
  - tests/ogre_magi_ability_spec.lua
documentation:
  - backlog/docs/doc-2 - Hero-improvement-playbook.md
modified_files:
  - bots/BotLib/hero_ogre_magi.lua
  - bots/FunLib/rubick_hero/ogre_magi.lua
  - tests/ogre_magi_ability_spec.lua
parent_task_id: TASK-13
priority: medium
ordinal: 111000
---

## Description

<!-- SECTION:DESCRIPTION:BEGIN -->
Ogre Magi is part of the requested Ember Spirit through Pugna hero-file-order batch. Review actual spell decisions against current mechanics and human usage, fixing meaningful ability-use gaps while retaining the established D2PT build.
<!-- SECTION:DESCRIPTION:END -->

## Acceptance Criteria
<!-- AC:BEGIN -->
- [x] #1 Ability decisions and cast order are reviewed against Torte de Lini, dotacoach Strategy/Counter Strategy/full Matchup and pinned Valve definitions/localization; verified checklist and stale claims are recorded
- [x] #2 Identified meaningful behavior gaps are fixed, including applicable Rubick handling, with positive and negative offline regression scenarios
- [x] #3 Focused hero scenarios, Valve ability check and full build suite pass; lobby checklist and engine limitations are recorded for Needs In-Game Test handoff
<!-- AC:END -->

## Implementation Plan

<!-- SECTION:PLAN:BEGIN -->
Actual-range single-hit stuns and Unrefined Strength scaling, sequential affordable casts, shield attack victims and useful Bloodlust priorities; mirror actives.
<!-- SECTION:PLAN:END -->

## Implementation Notes

<!-- SECTION:NOTES:BEGIN -->
Source review and offline implementation for the Ember Spirit → Pugna batch (hero-file order).

Sources: Torte CLI tools/tdl/fetch.cjs ogre_magi; https://dotacoach.gg/en/heroes/ogre-magi and https://dotacoach.gg/en/heroes/counters/ogre-magi (full Strategy, Counter Strategy and Matchup); Valve d2vpkr cf0d37a32c8df338a7832fd32a282747969e9a5f hero definitions plus English ability localization.

Verified ability checklist
- TDL guide 128866569 fetched/read; full Strategy/Counter/Matchup https://dotacoach.gg/en/heroes/ogre-magi and https://dotacoach.gg/en/heroes/counters/ogre-magi.
- Valve Fireblast 525/cast 0.45/single 70..250/stun 1.2; Scepter cast speed+25%, cooldown-1; no guaranteed multicasts.
- Unrefined named hidden handle 525, damage 150+1.5*Strength,currentmana 35%, stun 1.2.
- Ignite range 700..1000/projectile 1000/duration 5..8/dps 20..50; secondary random target and Multicast do not guarantee extra damage.
- Bloodlust 650/duration 30/attack 35..80/self 40..100; allied immunity allowed. Shield 600/three hero attacks 85%/duration 25/fireball 160.

Implemented behavior
- Removed 2.38 x random kill estimates and padded cast distances; deterministic kills/channel interrupts and strongest active fight threat.
- Correct named Unrefined slot and Strength keys; existing stun guard, fixed-cost basics before percentage mana and ready-stun reserve.
- Ignite long-range opener and Blink-equipped target preference; delayed burn kill estimates and safe meaningful creep packs.
- Bloodlust useful attacking/preparing cores and damaged retreat ally; legal-range tower and siege/Warlock summon targets.
- Shield enemy hero attack victims including human-controlled/immune attackers; buff/glyph guard, priority after urgent channel interrupt.
- New independent five-actives Rubick module, nil sibling safe.

Rejected or stale source claims
- TDL guide Lens from disassembled Arcane Boots and obsolete Veil path not adopted.
- Matchup unsupported Ignite reveals invisibility/Bloodlust attack-range increase/Stone Gaze channel claims rejected.

Item follow-up observations for TASK-21
- TASK 21: Lens for actual spell reach, Glimmer/Force for survival, Scepter second chained stun after basics; targeted Hex/utility may Multicast but no guaranteed proc. Builds unchanged.

Enemy counterplay observations for TASK-24
- TASK 24: magic resistance/barriers, debuff immunity, Lotus targeted reflection; illusion swarms divide single-target control.

Lobby validation checklist
- Multicast delayed extra hits versus next stun availability; exact dynamic Unrefined mana cost API and Refined cast-point metadata.
- Fire Shield team immunity/building behavior and Bloodlust multiple-target random selection.
- No live game or deep-dive validation was performed during this standard pass.

Focused verification
- Fengari tests/ogre_magi_ability_spec.lua passed; native/stolen/spec Lua 5.2 parse passed.

Full integration/build verification passed. Builds, skill/talent preferences and draft weights are unchanged. No game launched; engine-dependent claims remain lobby checks.

Final integrated verification: node tests/run-builds.cjs, node tests/run-objectives.cjs, node tests/valve_ability_check.cjs and git diff --check passed. Build/skill/talent preference AST comparison passed for all 49 scoped heroes. Native and applicable copied regressions are registered in run-builds. Framework callbacks and unsupported-spell dispatch preservation are covered. No game launched; the recorded lobby checklist remains required.
<!-- SECTION:NOTES:END -->

## Final Summary

<!-- SECTION:FINAL_SUMMARY:BEGIN -->
Ogre Magi standard ability pass completed offline. Native and copied behavior reviewed against Torte, full Dotacoach Strategy/Counter Strategy/Matchup and pinned Valve KV/localization. Meaningful behavior fixes and positive/negative regressions implemented; builds and flags preserved. Final integrated verification: node tests/run-builds.cjs, node tests/run-objectives.cjs, node tests/valve_ability_check.cjs and git diff --check passed. Build/skill/talent preference AST comparison passed for all 49 scoped heroes. Native and applicable copied regressions are registered in run-builds. Framework callbacks and unsupported-spell dispatch preservation are covered. No game launched; the recorded lobby checklist remains required.
<!-- SECTION:FINAL_SUMMARY:END -->
