---
id: TASK-13.89
title: 'Ursa: standard hero ability pass'
status: Needs In-Game Test
assignee:
  - '@codex'
created_date: '2026-10-02 14:30'
updated_date: '2026-10-02 16:24'
labels:
  - hero
dependencies: []
references:
  - bots/BotLib/hero_ursa.lua
  - tests/ursa_ability_spec.lua
documentation:
  - backlog/docs/doc-2 - Hero-improvement-playbook.md
modified_files:
  - bots/BotLib/hero_ursa.lua
  - bots/FunLib/rubick_hero/ursa.lua
  - tests/ursa_ability_spec.lua
parent_task_id: TASK-13
priority: medium
ordinal: 129000
---

## Description

<!-- SECTION:DESCRIPTION:BEGIN -->
Ursa is part of the requested Queen of Pain through Zeus hero-file-order batch. Review actual spell decisions against current mechanics and human usage, fixing meaningful ability-use gaps while retaining the established D2PT build.
<!-- SECTION:DESCRIPTION:END -->

## Acceptance Criteria
<!-- AC:BEGIN -->
- [x] #1 Ability decisions and cast order are reviewed against Torte de Lini, dotacoach Strategy/Counter Strategy/full Matchup and pinned Valve definitions/localization; verified checklist and stale claims are recorded
- [x] #2 Identified meaningful behavior gaps are fixed, including applicable Rubick handling, with positive and negative offline regression scenarios
- [x] #3 Focused hero scenarios, Valve ability check and full build suite pass; lobby checklist and engine limitations are recorded for Needs In-Game Test handoff
<!-- AC:END -->

## Implementation Plan

<!-- SECTION:PLAN:BEGIN -->
- Use actual Earthshock landing geometry and magical damage, with mobility hazards and useful farming/objective opportunities.
- Prepare Overpower at useful approach range and preserve its remaining attacks.
- Use Enrage for actual damage and useful strong dispels; support a narrow current Scepter exception under observed stun or sleep.
- Mirror the three actives without assuming Fury Swipes or Maul passives.
<!-- SECTION:PLAN:END -->

## Implementation Notes

<!-- SECTION:NOTES:BEGIN -->
Source review and offline implementation for the Queen of Pain → Zeus batch (hero-file order).

Sources: Torte CLI tools/tdl/fetch.cjs ursa; https://dotacoach.gg/en/heroes/ursa and https://dotacoach.gg/en/heroes/counters/ursa (full Strategy, Counter Strategy and Matchup); Valve d2vpkr cf0d37a32c8df338a7832fd32a282747969e9a5f hero definitions plus English ability localization.

Verified ability checklist
- Read full native SkillsComplement and every consideration; fetched and read TDL guide 254615876 and complete Dotacoach Strategy, Counter Strategy and Matchup gameplay/item cards.
- Pinned Valve cf0d37a32c8df338a7832fd32a282747969e9a5f: Earthshock hops 250 over 0.25 seconds, has radius 385 plus its talent, magical nonpiercing damage 75/125/175/225 and mana cost 95. Its behavior lacks ROOT_DISABLES; rooted casts use a centered landing.
- Current Shard adds three Fury Swipes stacks to Earthshock hits. Old short Enrage upgrades are not used; copied Earthshock does not assume a missing Fury Swipes passive.
- Overpower has 3/4/5/6 attacks, 400 attack speed, 25% slow resistance, 20-second duration and cooldown 12/11/10/9. Misses still consume attacks; existing useful charges are preserved.
- Enrage is a strong dispel, gives 80% damage reduction and 50% status resistance for 4/4.5/5 seconds, costs zero mana and is not debuff immunity. Scepter cooldown becomes 30/24/18 and permits casting while disabled. The callback conservatively supports observed stun or sleep and preserves hex/silence and unrelated locks.
- Fury Swipes existing stack effects persist through Break, while new applications do not; current Maul scales from current HP. Neither passive is fabricated in copied decisions.

Implemented behavior
- Replaced pre-hop radius checks and physical lane kill estimates with predicted actual landing and magical damage. Rooted casts remain centered, while moving Rupture/leash/Coil hops and hazardous destinations are rejected.
- Added real local farming groups, ranged creep last hits and close attacking objective opportunities without speculative passive damage.
- Overpower prepares before a useful approach, supports actual attacking farm, structures and bosses, and refuses disarm, ethereal victims or useful existing attacks.
- Enrage now reacts to incoming attacks, real damage, trapped states and close low-health objective fighting even while debuff immune. Removed undefined botHP and bAttacking dependencies.
- Added native ConsiderDisabledEnrage and copied ConsiderStolenDisabledEnrage with current Scepter and exact supported disabled-state gates.
- Added three independent copied actives with unknown-name preservation and nil/null/hidden/deactivated handle protection.
- Dream Coil movement guards now use the pinned localized modifier_puck_coiled name.

Rejected or stale source claims
- Rejected old Shard short-Enrage advice and stale ability-draft Enrage dependency text, current Shard adds Fury Swipes stacks.
- Rejected Nullifier disabling passives, guaranteed Basher procs, Enrage restoring stolen attributes or automatically negating lifesteal, and unverified item stat claims.

Item follow-up observations for TASK-21
- TASK-21: Review pre-cast Overpower before Blink, movement and anti-kiting items, BKB for silence/hex prevention, Scepter disabled-state Enrage, current Shard stacks, Battle Fury farming and Satanic sustain. No builds or generic item policy changes.

Enemy counterplay observations for TASK-24
- TASK-24: Kite short Enrage, use suitable displacement/banish, disarm or ethereal defenses to waste Overpower, watch early Roshan and Tormentor, and exploit silence/hex. Illusions divide Fury Swipes focus.

Lobby validation checklist
- Validate rooted Earthshock landing and leap/cliff behavior, actual two-charge talent, and copied Shard behavior without native passives.
- Validate Overpower remaining-attack modifier metadata and current Scepter Enrage castability during supported stun/nightmare, including silence and hex restrictions.
- No game or deep weak-hero validation was performed.

Focused verification
- Fengari tests/ursa_ability_spec.lua passed: landing boundaries, centered rooted cast, Rupture, immunity, magical last hits and regeneration, local packs, active attack preservation, disarm, objective attacks, debuff-immune defense, Scepter disable exception, queue/silence/hex/channel/Doom locks and optional handle safety.
- Final fractional-value audit passed: focused fixtures now truncate GetSpecialValueInt and preserve GetSpecialValueFloat; all eleven completed focused specs reran with pass markers.
- Final owned batch audit passed: all twelve focused Fengari specs emitted pass markers and all thirty-eight native/copied/spec/companion Lua files parsed as Lua 5.2. No game validation claimed.
- Native and copied actual Coiled movement negatives pass; Ursa rooted stationary damage remains available under Coil, while Tusk Snowball/Buddies and Viper Nosedive movement decline.

Framework integration
- Native X.ConsiderDisabledEnrage and copied X.ConsiderStolenDisabledEnrage. Before the normal disable gate, require Scepter and actual stun or nightmare. Preserve alive, hex, silence, invulnerability, channel, using, casting, queue, Box, Doom and Force Staff locks; cast only a ready actual Enrage with no existing Enrage buff.

Full integration/build verification passed. Builds, skill/talent preferences and draft weights are unchanged. No game launched; engine-dependent claims remain lobby checks.

Final integrated verification: node tests/run-builds.cjs, node tests/run-objectives.cjs, node tests/valve_ability_check.cjs and git diff --check passed. Build/skill/talent preference AST comparison passed for all 43 scoped heroes. Native and applicable copied regressions are registered in run-builds. Framework callbacks and unsupported-spell dispatch preservation are covered. No game launched; the recorded lobby checklist remains required.
<!-- SECTION:NOTES:END -->

## Final Summary

<!-- SECTION:FINAL_SUMMARY:BEGIN -->
Ursa standard ability pass completed offline. Native and copied behavior reviewed against Torte and full Dotacoach Strategy/Counter Strategy/Matchup and pinned Valve KV/localization. Meaningful behavior fixes and positive/negative regressions implemented; builds and flags preserved. Final integrated verification: node tests/run-builds.cjs, node tests/run-objectives.cjs, node tests/valve_ability_check.cjs and git diff --check passed. Build/skill/talent preference AST comparison passed for all 43 scoped heroes. Native and applicable copied regressions are registered in run-builds. Framework callbacks and unsupported-spell dispatch preservation are covered. No game launched; the recorded lobby checklist remains required.
<!-- SECTION:FINAL_SUMMARY:END -->
