---
id: TASK-13.72
title: 'Omniknight: standard hero ability pass'
status: Needs In-Game Test
assignee:
  - '@codex'
created_date: '2026-10-02 09:09'
updated_date: '2026-10-02 10:40'
labels:
  - hero
dependencies: []
references:
  - bots/BotLib/hero_omniknight.lua
  - tests/omniknight_ability_spec.lua
documentation:
  - backlog/docs/doc-2 - Hero-improvement-playbook.md
modified_files:
  - bots/BotLib/hero_omniknight.lua
  - bots/FunLib/rubick_hero/omniknight.lua
  - tests/omniknight_ability_spec.lua
parent_task_id: TASK-13
priority: medium
ordinal: 112000
---

## Description

<!-- SECTION:DESCRIPTION:BEGIN -->
Omniknight is part of the requested Ember Spirit through Pugna hero-file-order batch. Review actual spell decisions against current mechanics and human usage, fixing meaningful ability-use gaps while retaining the established D2PT build.
<!-- SECTION:DESCRIPTION:END -->

## Acceptance Criteria
<!-- AC:BEGIN -->
- [x] #1 Ability decisions and cast order are reviewed against Torte de Lini, dotacoach Strategy/Counter Strategy/full Matchup and pinned Valve definitions/localization; verified checklist and stale claims are recorded
- [x] #2 Identified meaningful behavior gaps are fixed, including applicable Rubick handling, with positive and negative offline regression scenarios
- [x] #3 Focused hero scenarios, Valve ability check and full build suite pass; lobby checklist and engine limitations are recorded for Needs In-Game Test handoff
<!-- AC:END -->

## Implementation Plan

<!-- SECTION:PLAN:BEGIN -->
Actual legal Purification centers, magic/control Repel, physical/global-building Angel, correct attack Hammer plus guarded silence hook; stolen parity.
<!-- SECTION:PLAN:END -->

## Implementation Notes

<!-- SECTION:NOTES:BEGIN -->
Source review and offline implementation for the Ember Spirit → Pugna batch (hero-file order).

Sources: Torte CLI tools/tdl/fetch.cjs omniknight; https://dotacoach.gg/en/heroes/omniknight and https://dotacoach.gg/en/heroes/counters/omniknight (full Strategy, Counter Strategy and Matchup); Valve d2vpkr cf0d37a32c8df338a7832fd32a282747969e9a5f hero definitions plus English ability localization.

Verified ability checklist
- TDL guide 129130896/895968997 fetched/read, full Strategy/Counter/Matchup https://dotacoach.gg/en/heroes/omniknight and https://dotacoach.gg/en/heroes/counters/omniknight.
- Valve Purification 700/radius 260/heal 90..300,pure piercing; Shard 3 s repeat 65%, not immediate burst.
- Actual ability 2 omniknight_martyr:700,duration 5, regen 8..20,magicresist 60%; no Strength/debuff stacks. Legacy omniknight_repel unused slot data not assumed.
- Hammer ATTACK/AUTOCAST/IGNORE_SILENCE, mana 0, attackrange+75; bonus_damage 25..85 plus GetBaseDamage*base_damage 30..90%, healing 40%/4 s.
- Angel NO_TARGET nondispellable aura 700/no linger,duration 4/4.75/5.5; Scepter global/allied buildings/restoration+50%.

Implemented behavior
- Heal/kill/engage/farm center selection verifies range and local geometry, prioritizes urgent heal; blocked Ice Blast heal-only and predicted enemy presence, no phantom pack counts.
- Repel incoming control/projectiles and observed magic pressure, meaningful core engagement; existing immunity/buff guard.
- Angel actual physical threat rather than low health under magical pressure, remote Scepter hero/building defenses and glyph/active aura guard.
- Hammer correct special keys and base damage, real attack range independent of Lens, attack immunity/disarm/reflect guards, piercing kills and last hits.
- Narrow native/stolen silence-only Hammer hook protects channel, pending actions and all hard disables.
- Independent four-actives Rubick module.

Rejected or stale source claims
- TDL guide Heavenly Grace Strength/status-resistance/global-duration/Solar armor enemy advice obsolete.
- Matchup Strength Repel, dispellable Guardian Angel, Ice Blast negates physical immunity, or innate defensive effects unsupported; current pinned aura is nondispellable.

Item follow-up observations for TASK-21
- TASK 21: Locket/Greaves heal sustain, Lens safe saves, BKB keeps Repel for ally, Blink/Harpoon positioning; Scepter and Refresher building defense. Builds unchanged.

Enemy counterplay observations for TASK-24
- TASK 24: focus/disable caster, antiheal versus sustain, magical/pure damage bypass physical Angel, kite short attack Hammer; Nullifier targets dispellable Repel, not nondispellable Angel aura.

Lobby validation checklist
- Hammer IGNORE_SILENCE real fully-castable metadata and attack command under silence.
- Guardian moving aura/no linger, global buildings and restoration amplification; Purification Shard repeat 65% engine behavior.
- No live game or deep-dive validation was performed during this standard pass.

Focused verification
- Fengari tests/omniknight_ability_spec.lua passed; native/stolen/spec Lua 5.2 parse passed.

Full integration/build verification passed. Builds, skill/talent preferences and draft weights are unchanged. No game launched; engine-dependent claims remain lobby checks.

Final integrated verification: node tests/run-builds.cjs, node tests/run-objectives.cjs, node tests/valve_ability_check.cjs and git diff --check passed. Build/skill/talent preference AST comparison passed for all 49 scoped heroes. Native and applicable copied regressions are registered in run-builds. Framework callbacks and unsupported-spell dispatch preservation are covered. No game launched; the recorded lobby checklist remains required.
<!-- SECTION:NOTES:END -->

## Final Summary

<!-- SECTION:FINAL_SUMMARY:BEGIN -->
Omniknight standard ability pass completed offline. Native and copied behavior reviewed against Torte, full Dotacoach Strategy/Counter Strategy/Matchup and pinned Valve KV/localization. Meaningful behavior fixes and positive/negative regressions implemented; builds and flags preserved. Final integrated verification: node tests/run-builds.cjs, node tests/run-objectives.cjs, node tests/valve_ability_check.cjs and git diff --check passed. Build/skill/talent preference AST comparison passed for all 49 scoped heroes. Native and applicable copied regressions are registered in run-builds. Framework callbacks and unsupported-spell dispatch preservation are covered. No game launched; the recorded lobby checklist remains required.
<!-- SECTION:FINAL_SUMMARY:END -->
