---
id: TASK-13.57
title: 'Legion Commander: standard hero ability pass'
status: Needs In-Game Test
assignee:
  - '@codex'
created_date: '2026-10-02 09:09'
updated_date: '2026-10-02 10:40'
labels:
  - hero
dependencies: []
references:
  - bots/BotLib/hero_legion_commander.lua
  - tests/legion_commander_ability_spec.lua
documentation:
  - backlog/docs/doc-2 - Hero-improvement-playbook.md
modified_files:
  - bots/BotLib/hero_legion_commander.lua
  - bots/FunLib/rubick_hero/legion_commander.lua
  - tests/legion_commander_ability_spec.lua
parent_task_id: TASK-13
priority: medium
ordinal: 97000
---

## Description

<!-- SECTION:DESCRIPTION:BEGIN -->
Legion Commander is part of the requested Ember Spirit through Pugna hero-file-order batch. Review actual spell decisions against current mechanics and human usage, fixing meaningful ability-use gaps while retaining the established D2PT build.
<!-- SECTION:DESCRIPTION:END -->

## Acceptance Criteria
<!-- AC:BEGIN -->
- [x] #1 Ability decisions and cast order are reviewed against Torte de Lini, dotacoach Strategy/Counter Strategy/full Matchup and pinned Valve definitions/localization; verified checklist and stale claims are recorded
- [x] #2 Identified meaningful behavior gaps are fixed, including applicable Rubick handling, with positive and negative offline regression scenarios
- [x] #3 Focused hero scenarios, Valve ability check and full build suite pass; lobby checklist and engine limitations are recorded for Needs In-Game Test handoff
<!-- AC:END -->

## Implementation Plan

<!-- SECTION:PLAN:BEGIN -->
Current Odds damage/radius, urgent Press saves, lawful piercing Duel and preserved queued preparation, normal spell use during Duel; independent copied actives.
<!-- SECTION:PLAN:END -->

## Implementation Notes

<!-- SECTION:NOTES:BEGIN -->
Source review and offline implementation for the Ember Spirit → Pugna batch (hero-file order).

Sources: Torte CLI tools/tdl/fetch.cjs legion_commander; https://dotacoach.gg/en/heroes/legion-commander and https://dotacoach.gg/en/heroes/counters/legion-commander (full Strategy, Counter Strategy and Matchup); Valve d2vpkr cf0d37a32c8df338a7832fd32a282747969e9a5f hero definitions plus English ability localization.

Verified ability checklist
- All native SkillsComplement, ConsiderQ/W/R and allied damage estimation reviewed; Torte guides203428541/203428546, full Dotacoach Strategy/Counter/Matchup including synergy and item cards read.
- Pinned cf0d37a Valve/localization: Odds no-target600+Shard100, magical40/70/100/130 plus same perhero and14/16/18/20 percreep; attack speed50/75/100/125, Shard hero-damage barrier.
- Press700 allied nonimmune strong dispel,5s regen24/36/48/60 and movement13/16/19/22; Scepter point500 radius always affects caster.
- Duel200 reach, piercing enemy immunity, float duration4/4.5/5 plus current talent; caster may use abilities but no items. Scepter auto-Press on victory, not immunity/duration.
- Moment current deterministic7/6/5/4 received attacks, not old25% chance; innate armor engine-owned, not assumed copied.

Implemented behavior
- Odds uses actual hero/creep damage and runtime radius, honest lethal estimate and ranged-creep lane opportunity, cast during observed Duel for attack speed.
- Press critical purge/heal priority before Duel, human/bot allies treated alike, current regen/movement semantics; existing Press buff does not suppress new strong dispel; point centers bounded to actual range.
- Duel human debuff-immune channel interruption, true cast range with genuine Lens/Supremacy, spell block/reflection/protection and conservative physical survival gates; float duration instead of truncated integer.
- Pre-Duel Press and Blade Mail remain in one action queue before Duel; cumulative mana reserved for ultimate. Old immediate Duel canceled queued preparation.
- During Duel spell casts use direct actions without illegal item preparation; ordinary queued/disabled/channel/invisible gates remain.
- Dedicated copied handler for Odds/Press/Duel without Moment/innate assumptions, unknown spells preserve dispatcher.

Rejected or stale source claims
- TDL Scepter duration/debuff immunity and old Shard damage claim rejected; current Scepter Press point upgrade/automatic victory cast and Shard Odds barrier.
- TDL and Matchup generic Nullifier passive-break / bloodthorn crit wording not encoded.
- Matchup Counterspell has no protection from Duel is not enough to bypass observed reflect/spell-block guards.
- Old code Odds damage*2 omitted real unit counts and stated movement instead of current attack speed; Press attack speed obsolete.

Item follow-up observations for TASK-21
- TASK-21: BKB/Blade Mail before Duel; Blink/Shadow Blade catch, Nullifier dispellable saves and Linkens breaking only with current item mechanics; Silver Edge attack before Duel if relevant passives; no build changes.

Enemy counterplay observations for TASK-24
- TASK-24: bait Blink Duel with nearby saves; Euls/Ghost/Linkens/ethereal/disarm/armor mitigate forced attacks; save allies with Astral/Disruption/Grave/False Promise/Cold Embrace. Space lanes against Odds and punish Press cooldown.

Lobby validation checklist
- Queued Press/Blade Mail/Duel against moving targets and actual cast point; verify item use never attempted during Duel.
- Actual Scepter point Press shape and always-self behavior, repeated strong dispel, immune ally eligibility.
- Caster normal spell eligibility during native/copied Duel, deterministic Moment and Shard barrier.
- Conservative attack estimates cannot guarantee ally spell followup or evasion/late save outcome.

Focused verification
- Fengari tests/legion_commander_ability_spec.lua passed6scenario groups; shared Valve check and49hero preference-integrity check passed.

Full integration/build verification passed. Builds, skill/talent preferences and draft weights are unchanged. No game launched; engine-dependent claims remain lobby checks.

Final integrated verification: node tests/run-builds.cjs, node tests/run-objectives.cjs, node tests/valve_ability_check.cjs and git diff --check passed. Build/skill/talent preference AST comparison passed for all 49 scoped heroes. Native and applicable copied regressions are registered in run-builds. Framework callbacks and unsupported-spell dispatch preservation are covered. No game launched; the recorded lobby checklist remains required.
<!-- SECTION:NOTES:END -->

## Final Summary

<!-- SECTION:FINAL_SUMMARY:BEGIN -->
Legion Commander standard ability pass completed offline. Native and copied behavior reviewed against Torte, full Dotacoach Strategy/Counter Strategy/Matchup and pinned Valve KV/localization. Meaningful behavior fixes and positive/negative regressions implemented; builds and flags preserved. Final integrated verification: node tests/run-builds.cjs, node tests/run-objectives.cjs, node tests/valve_ability_check.cjs and git diff --check passed. Build/skill/talent preference AST comparison passed for all 49 scoped heroes. Native and applicable copied regressions are registered in run-builds. Framework callbacks and unsupported-spell dispatch preservation are covered. No game launched; the recorded lobby checklist remains required.
<!-- SECTION:FINAL_SUMMARY:END -->
