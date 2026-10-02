---
id: TASK-13.70
title: 'Outworld Destroyer: standard hero ability pass'
status: Needs In-Game Test
assignee:
  - '@codex'
created_date: '2026-10-02 09:09'
updated_date: '2026-10-02 10:40'
labels:
  - hero
dependencies: []
references:
  - bots/BotLib/hero_obsidian_destroyer.lua
  - tests/obsidian_destroyer_ability_spec.lua
documentation:
  - backlog/docs/doc-2 - Hero-improvement-playbook.md
modified_files:
  - bots/BotLib/hero_obsidian_destroyer.lua
  - bots/FunLib/rubick_hero/obsidian_destroyer.lua
  - tests/obsidian_destroyer_ability_spec.lua
  - tests/od_item_policy_spec.lua
parent_task_id: TASK-13
priority: medium
ordinal: 110000
---

## Description

<!-- SECTION:DESCRIPTION:BEGIN -->
Outworld Destroyer is part of the requested Ember Spirit through Pugna hero-file-order batch. Review actual spell decisions against current mechanics and human usage, fixing meaningful ability-use gaps while retaining the established D2PT build.
<!-- SECTION:DESCRIPTION:END -->

## Acceptance Criteria
<!-- AC:BEGIN -->
- [x] #1 Ability decisions and cast order are reviewed against Torte de Lini, dotacoach Strategy/Counter Strategy/full Matchup and pinned Valve definitions/localization; verified checklist and stale claims are recorded
- [x] #2 Identified meaningful behavior gaps are fixed, including applicable Rubick handling, with positive and negative offline regression scenarios
- [x] #3 Focused hero scenarios, Valve ability check and full build suite pass; lobby checklist and engine limitations are recorded for Needs In-Game Test handoff
<!-- AC:END -->

## Implementation Plan

<!-- SECTION:PLAN:BEGIN -->
Preserve Orb reserves and mana item preparation; prioritize actual-range Astral saves, correct max-mana Eclipse/AoE, useful guarded barrier; independent stolen actives.
<!-- SECTION:PLAN:END -->

## Implementation Notes

<!-- SECTION:NOTES:BEGIN -->
Source review and offline implementation for the Ember Spirit → Pugna batch (hero-file order).

Sources: Torte CLI tools/tdl/fetch.cjs obsidian_destroyer; https://dotacoach.gg/en/heroes/outworld-devourer and https://dotacoach.gg/en/heroes/counters/outworld-devourer (full Strategy, Counter Strategy and Matchup); Valve d2vpkr cf0d37a32c8df338a7832fd32a282747969e9a5f hero definitions plus English ability localization.

Verified ability checklist
- Fetched and read TDL guide 129332786, full Strategy, Counter Strategy and Matchup: https://dotacoach.gg/en/heroes/outworld-devourer and https://dotacoach.gg/en/heroes/counters/outworld-devourer. Corrected full source TXT caches replace the empty outworld-destroyer slug.
- Valve Orb costs 20% current mana, pure 10/11/12/13% remaining mana after cost; random Essence Flux never guaranteed.
- Astral 650, cast 0.3, fractional prison 1.75/2.5/3.25/4, damage 90/180/270/360; cannot target debuff-immune allies. Shard movement 70%, AoE 300.
- Eclipse 700/radius 500/525/550, base 200/300/400+positive max-mana difference*0.4; explicitly hits Astral prisoners.
- Objurgation barrier 150/200/250/300+maximum mana 12%, Scepter adds 4%; automatic threshold 20%/80 s strong dispel is separate passive.

Implemented behavior
- Urgent ally/self Astral before damage/barrier; proper legal range, channels and fractional-duration kill prediction; avoid already disabled attack victims.
- Eclipse maximum mana formula, delayed kill prediction and combat clusters; clamped point centers reach enemies outside direct cast range; observed Astral-only invulnerability exception.
- Barrier incoming projectiles/estimated damage, max-mana value and positive-duration source-ability guard exclude intrinsic modifier.
- Disarm and reflection guards for Orb; preserve reserves, independent autocast hysteresis and item requests.
- Four-actives Rubick module and focused native/stolen regression scenarios.

Rejected or stale source claims
- TDL guide legacy intelligence/Essence Aura advice rejected.
- Matchup outdated Shadow Demon Soul Catcher/OD charge and lifesteal talent claims ignored; broad magical damage bypassing Astral is false.

Item follow-up observations for TASK-21
- TASK 21: mana/intelligence improve damage and barrier; Treads INT, Witch Blade attacks, Force/Pike reposition, BKB before disables, Blink initiation and Hex follow-up; item build unchanged.

Enemy counterplay observations for TASK-24
- TASK 24: debuff immunity/ethereal/disarm suppress Orb; jump/silence save caster; mana capacity reduces Eclipse difference. Reflection hazards guarded.

Lobby validation checklist
- Astral prisoner visibility/location and GetActualIncomingDamage versus Eclipse exception.
- Objurgation barrier source-ability/duration attribution, automatic Scepter barrier stacking.
- Astral release followed by Arrow/Hex and Shard movement, native/stolen real range including Lens.
- No live game or deep-dive validation was performed during this standard pass.

Focused verification
- Fengari tests/obsidian_destroyer_ability_spec.lua passed; native/stolen/spec Lua 5.2 parse passed.
- node tests/item_cast_policy_spec.cjs passed preserving restoration and Orb reserve fixtures.

Full integration/build verification passed. Builds, skill/talent preferences and draft weights are unchanged. No game launched; engine-dependent claims remain lobby checks.

Final integrated verification: node tests/run-builds.cjs, node tests/run-objectives.cjs, node tests/valve_ability_check.cjs and git diff --check passed. Build/skill/talent preference AST comparison passed for all 49 scoped heroes. Native and applicable copied regressions are registered in run-builds. Framework callbacks and unsupported-spell dispatch preservation are covered. No game launched; the recorded lobby checklist remains required.
<!-- SECTION:NOTES:END -->

## Final Summary

<!-- SECTION:FINAL_SUMMARY:BEGIN -->
Outworld Destroyer standard ability pass completed offline. Native and copied behavior reviewed against Torte, full Dotacoach Strategy/Counter Strategy/Matchup and pinned Valve KV/localization. Meaningful behavior fixes and positive/negative regressions implemented; builds and flags preserved. Final integrated verification: node tests/run-builds.cjs, node tests/run-objectives.cjs, node tests/valve_ability_check.cjs and git diff --check passed. Build/skill/talent preference AST comparison passed for all 49 scoped heroes. Native and applicable copied regressions are registered in run-builds. Framework callbacks and unsupported-spell dispatch preservation are covered. No game launched; the recorded lobby checklist remains required.
<!-- SECTION:FINAL_SUMMARY:END -->
