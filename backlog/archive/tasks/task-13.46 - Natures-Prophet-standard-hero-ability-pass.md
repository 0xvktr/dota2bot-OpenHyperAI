---
id: TASK-13.46
title: 'Nature''s Prophet: standard hero ability pass'
status: Needs In-Game Test
assignee:
  - '@codex'
created_date: '2026-10-02 09:08'
updated_date: '2026-10-02 10:40'
labels:
  - hero
dependencies: []
references:
  - bots/BotLib/hero_furion.lua
  - tests/furion_ability_spec.lua
documentation:
  - backlog/docs/doc-2 - Hero-improvement-playbook.md
modified_files:
  - bots/BotLib/hero_furion.lua
  - bots/FunLib/rubick_hero/furion.lua
  - tests/furion_ability_spec.lua
  - bots/FunLib/furion_abilities.lua
parent_task_id: TASK-13
priority: medium
ordinal: 86000
---

## Description

<!-- SECTION:DESCRIPTION:BEGIN -->
Nature's Prophet is part of the requested Ember Spirit through Pugna hero-file-order batch. Review actual spell decisions against current mechanics and human usage, fixing meaningful ability-use gaps while retaining the established D2PT build.
<!-- SECTION:DESCRIPTION:END -->

## Acceptance Criteria
<!-- AC:BEGIN -->
- [x] #1 Ability decisions and cast order are reviewed against Torte de Lini, dotacoach Strategy/Counter Strategy/full Matchup and pinned Valve definitions/localization; verified checklist and stale claims are recorded
- [x] #2 Identified meaningful behavior gaps are fixed, including applicable Rubick handling, with positive and negative offline regression scenarios
- [x] #3 Focused hero scenarios, Valve ability check and full build suite pass; lobby checklist and engine limitations are recorded for Needs In-Game Test handoff
<!-- AC:END -->

## Implementation Plan

<!-- SECTION:PLAN:BEGIN -->
Actual ground Sprout and observed-tree Call, escape mana, safe allies and Teleport source/arrival; single target tree-supported Curse and global guaranteed first-bounce Wrath.
<!-- SECTION:PLAN:END -->

## Implementation Notes

<!-- SECTION:NOTES:BEGIN -->
Source review and offline implementation for the Ember Spirit → Pugna batch (hero-file order).

Sources: Torte CLI tools/tdl/fetch.cjs furion; https://dotacoach.gg/en/heroes/natures-prophet and https://dotacoach.gg/en/heroes/counters/natures-prophet (full Strategy, Counter Strategy and Matchup); Valve d2vpkr cf0d37a32c8df338a7832fd32a282747969e9a5f hero definitions plus English ability localization.

Verified ability checklist
- Sprout targets a unit or ground point on either team at 625/700/775/850 range, with a 0.35-second cast point. Its tree obstacle lasts 2.5/3/3.5/4 seconds, deals 70/130/190/250 damage with 240 added by the current talent, and has 275 damage radius.
- Teleportation is a global point spell with a three-second cast point and root restriction. It gives a 70/130/190/250 barrier for 15 seconds; the old damage buff is excluded.
- Nature’s Call is a point spell at 750 range, converts trees within 150/225/300/375 radius, summons at most 2/3/4/5 Treants lasting 50 seconds, and requires actual trees.
- Wrath is a global unit or point spell. Its first hit deals 100/140/180 base damage, plus the current 25-damage talent. It has at most 16 bounces, 10% added damage per hit and 0.15 seconds between jumps. Scepter roots for 1.5–3 seconds rather than spawning Treants.
- Shard Curse is a no-target spell with 900 reach and 250 tree radius. Each tree supplies 15 DPS and 7% slow for seven seconds. Treants count as trees, and fog reveal is handled by the engine.
- Greater Sprout, Summon Fey, Hedgerow and Arboreal Might are not default hero slots. Only real trained and active variant handles can be exposed.
- Read the full Torte guide and Nature’s Prophet Strategy, Counter Strategy and Matchup cards. Verified the natures-prophet URL and checked pinned Valve KV and localization.

Implemented behavior
- Ground Sprout uses actual range and prediction, avoids targeted spell block or reflection, and uses tree obstacles against immune enemies. It protects self and allied heroes from accidental traps.
- Sprout–Call uses one bounded destination and waits for observed trees. Removed the blind self-Sprout and distant Call queue. Natural trees do not require another Sprout casting cost.
- Call selects the densest actual tree cluster in range and reserves current Teleportation mana.
- A guaranteed first-hit Wrath kill or useful Scepter root precedes routine summons. No maximum-bounce damage or obsolete Scepter Treants are assumed.
- Curse can be useful against one enemy with nearby trees or actual Treants. It rejects zero-tree, immune and already-cursed targets.
- Teleportation preserves the FightResponse transport contract and adds root, incoming-projectile, source-proximity, supported-destination and passability gates.
- Native and copied spells share Prophet-specific decisions. Copied Call does not assume Sprout, and copied Curse does not assume a Treant army.

Rejected or stale source claims
- The Ironwood Treant facet mentioned by several Matchup cards is deprecated and is not the current default.
- Old Scepter Treants-on-hit advice is excluded; current Wrath applies a root.
- Old intelligence talents and Sprout healing facets are excluded.
- A global target cannot be promised all 16 bounces. Only the direct first hit is treated as guaranteed damage.

Item follow-up observations for TASK-21
- TASK-21: Orchid and Sprout follow actual arrival. Mjollnir can shield a durable ally, while Treant auras and Drums support pushes. Shadow Blade may preserve invisibility during Teleportation; the current Solar Crest is not an enemy-target active.

Enemy counterplay observations for TASK-24
- TASK-24: Quelling Blade, Tango and Force Staff can overcome Sprout obstacles. Teleportation’s three-second cast can be interrupted. Tree vision and response to split pushes matter; area damage should clear Treants without feeding Echo Slam.

Lobby validation checklist
- Validate that Sprout-created trees become observable before Call. Failed casts and timeouts must discard the pending sequence, and tree clusters must use the same actual point.
- Validate native and copied global Wrath’s direct target, Scepter root duration and bounce visibility. A root is not assumed to interrupt an ordinary channel.
- Validate Teleportation’s cast phase versus channel callbacks, invisible casting, and FightResponse source and destination safety.
- Validate the live Curse modifier, fog behavior and Treant counting, including whether enemy Treants contribute.

Focused verification
- The native and copied Nature’s Prophet Fengari scenarios passed. All four files parsed as Lua 5.2, and the global Valve check passed.

Full integration/build verification passed. Builds, skill/talent preferences and draft weights are unchanged. No game launched; engine-dependent claims remain lobby checks.

Final integrated verification: node tests/run-builds.cjs, node tests/run-objectives.cjs, node tests/valve_ability_check.cjs and git diff --check passed. Build/skill/talent preference AST comparison passed for all 49 scoped heroes. Native and applicable copied regressions are registered in run-builds. Framework callbacks and unsupported-spell dispatch preservation are covered. No game launched; the recorded lobby checklist remains required.
<!-- SECTION:NOTES:END -->

## Final Summary

<!-- SECTION:FINAL_SUMMARY:BEGIN -->
Natures Prophet standard ability pass completed offline. Native and copied behavior reviewed against Torte, full Dotacoach Strategy/Counter Strategy/Matchup and pinned Valve KV/localization. Meaningful behavior fixes and positive/negative regressions implemented; builds and flags preserved. Final integrated verification: node tests/run-builds.cjs, node tests/run-objectives.cjs, node tests/valve_ability_check.cjs and git diff --check passed. Build/skill/talent preference AST comparison passed for all 49 scoped heroes. Native and applicable copied regressions are registered in run-builds. Framework callbacks and unsupported-spell dispatch preservation are covered. No game launched; the recorded lobby checklist remains required.
<!-- SECTION:FINAL_SUMMARY:END -->
