---
id: TASK-13.47
title: 'Grimstroke: standard hero ability pass'
status: Needs In-Game Test
assignee:
  - '@codex'
created_date: '2026-10-02 09:08'
updated_date: '2026-10-02 15:48'
labels:
  - hero
dependencies: []
references:
  - bots/BotLib/hero_grimstroke.lua
  - tests/grimstroke_ability_spec.lua
documentation:
  - backlog/docs/doc-2 - Hero-improvement-playbook.md
modified_files:
  - bots/FunLib/grimstroke_abilities.lua
  - tests/grimstroke_ability_spec.lua
parent_task_id: TASK-13
priority: medium
ordinal: 87000
---

## Description

<!-- SECTION:DESCRIPTION:BEGIN -->
Grimstroke is part of the requested Ember Spirit through Pugna hero-file-order batch. Review actual spell decisions against current mechanics and human usage, fixing meaningful ability-use gaps while retaining the established D2PT build.
<!-- SECTION:DESCRIPTION:END -->

## Acceptance Criteria
<!-- AC:BEGIN -->
- [x] #1 Ability decisions and cast order are reviewed against Torte de Lini, dotacoach Strategy/Counter Strategy/full Matchup and pinned Valve definitions/localization; verified checklist and stale claims are recorded
- [x] #2 Identified meaningful behavior gaps are fixed, including applicable Rubick handling, with positive and negative offline regression scenarios
- [x] #3 Focused hero scenarios, Valve ability check and full build suite pass; lobby checklist and engine limitations are recorded for Needs In-Game Test handoff
<!-- AC:END -->

## Implementation Plan

<!-- SECTION:PLAN:BEGIN -->
Correct cast shapes, magical Phantom damage, immediate silence priority, useful Ink Swell carriers and Shard dispels, range-safe Soulbind and Portrait, with shared independent copied decisions.
<!-- SECTION:PLAN:END -->

## Implementation Notes

<!-- SECTION:NOTES:BEGIN -->
Source review and offline implementation for the Ember Spirit → Pugna batch (hero-file order).

Sources: Torte CLI tools/tdl/fetch.cjs grimstroke; https://dotacoach.gg/en/heroes/grimstroke and https://dotacoach.gg/en/heroes/counters/grimstroke (full Strategy, Counter Strategy and Matchup); Valve d2vpkr cf0d37a32c8df338a7832fd32a282747969e9a5f hero definitions plus English ability localization.

Verified ability checklist
- Stroke is point/alt-castable magical, 1400 range, 2000 speed and 0.6 s cast point; no vector endpoint API exists in supported bot API.
- Phantom is magical: 5 s latch, 10/20/30/40 DPS, 120/200/280/360 rend and 1150 projectile speed; hero attacks count three.
- Ink Swell has a 3 s buff, 375 radius, 2.5 s maximum charge threshold; can_end_early is zero. Shard gives a basic dispel on cast and 40% extra damage/healing.
- Soulbind pierces immunity, actual 700/800/900 range, 600 partner radius, 6/7/8 s duration.
- Portrait is Scepter, 1200 range, 25 s, 125% outgoing, 275% incoming and 90% magic resistance; Ink Trail is passive and breakable.

Implemented behavior
- Phantom channels have first priority, with short arrival distance; guaranteed lethal evaluation uses one magical tick rather than assuming the attackable phantom survives to rend.
- Ink Swell picks the nearest engaged carrier including self, avoids live buffs, and uses Shard immediately for root/silence dispels. Removed nonexistent early-detonation automation.
- Soulbind requires a real second hero and respects actual cast range, blocking/reflection and existing binding; it can catch immune heroes. Portrait scores actual physical output and no longer excludes a stunned or immune carry.
- Stroke combat prediction is bounded by real range; retained farming and ally-peel routes. Native and copied spells share decisions and do not assume linked missing spells.

Rejected or stale source claims
- Deprecated Inkstigate/Fine Art facets and unused old Ink Over definition excluded.
- Counter-page claims of silence through Vendetta or invisibility, and a fictitious Grimstroke channel, do not match current Phantom or supported mechanics.
- Old Arcane Boots disassembly advice and dispelling hard stuns with Lotus are not imported.

Item follow-up observations for TASK-21
- TASK-21: Soulbind should precede useful targeted Hex/Portrait and similar unit spells; preserve range safety and avoid exhausting required spell mana. Shard dispel currently works without speculative blink setup.
- TASK-21: Lens actual cast_range_bonus is read from active inventory; copied Supremacy contributes only while not broken.

Enemy counterplay observations for TASK-24
- TASK-24: attackable Phantom, dispels, Linkens/Lotus and immunity reduce setup reliability; never count its complete rend as guaranteed.
- TASK-24: avoid clustering around a bound mobile core; Swell needs enemy contact to charge its stun.

Lobby validation checklist
- Validate engine Soulbind double-cast interactions and copied ownership.
- Validate current Stroke default curved path versus alt-cast state; no unsupported vector command added.
- Validate Shard basic dispel and the absence of current early explosion control; no forced manual detonation.

Focused verification
- Native/copied Fengari scenario suite passed; four files parse as Lua 5.2.

Full integration/build verification passed. Builds, skill/talent preferences and draft weights are unchanged. No game launched; engine-dependent claims remain lobby checks.

Final integrated verification: node tests/run-builds.cjs, node tests/run-objectives.cjs, node tests/valve_ability_check.cjs and git diff --check passed. Build/skill/talent preference AST comparison passed for all 49 scoped heroes. Native and applicable copied regressions are registered in run-builds. Framework callbacks and unsupported-spell dispatch preservation are covered. No game launched; the recorded lobby checklist remains required.

2026-10-02 integration API follow-up: replaced undocumented HasShard() calls with the existing modifier_item_aghanims_shard convention used by this repository. Fixtures use the actual modifier query, retaining shard state scenarios. Focused hero scenarios passed; builds and skill/talent preferences retained. Lobby verification remains required.
<!-- SECTION:NOTES:END -->

## Final Summary

<!-- SECTION:FINAL_SUMMARY:BEGIN -->
Grimstroke standard ability pass completed offline. Native and copied behavior reviewed against Torte, full Dotacoach Strategy/Counter Strategy/Matchup and pinned Valve KV/localization. Meaningful behavior fixes and positive/negative regressions implemented; builds and flags preserved. Final integrated verification: node tests/run-builds.cjs, node tests/run-objectives.cjs, node tests/valve_ability_check.cjs and git diff --check passed. Build/skill/talent preference AST comparison passed for all 49 scoped heroes. Native and applicable copied regressions are registered in run-builds. Framework callbacks and unsupported-spell dispatch preservation are covered. No game launched; the recorded lobby checklist remains required.
<!-- SECTION:FINAL_SUMMARY:END -->
