---
id: TASK-13.102
title: 'Visage: standard hero ability pass'
status: Needs In-Game Test
assignee:
  - '@codex'
created_date: '2026-10-02 14:58'
updated_date: '2026-10-02 16:24'
labels:
  - hero
  - weak-hero
milestone: m-0
dependencies: []
references:
  - bots/BotLib/hero_visage.lua
  - tests/visage_ability_spec.lua
documentation:
  - backlog/docs/doc-2 - Hero-improvement-playbook.md
modified_files:
  - bots/BotLib/hero_visage.lua
  - bots/FunLib/rubick_hero/visage.lua
  - tests/visage_ability_spec.lua
  - bots/FunLib/minion_lib/familiars.lua
parent_task_id: TASK-13
priority: medium
ordinal: 142000
---

## Description

<!-- SECTION:DESCRIPTION:BEGIN -->
Visage is part of the requested Queen of Pain through Zeus hero-file-order batch. Review actual spell decisions against current mechanics and human usage, fixing meaningful ability-use gaps while retaining the established D2PT build.
<!-- SECTION:DESCRIPTION:END -->

## Acceptance Criteria
<!-- AC:BEGIN -->
- [x] #1 Ability decisions and cast order are reviewed against Torte de Lini, dotacoach Strategy/Counter Strategy/full Matchup and pinned Valve definitions/localization; verified checklist and stale claims are recorded
- [x] #2 Identified meaningful behavior gaps are fixed, including applicable Rubick handling, with positive and negative offline regression scenarios
- [x] #3 Focused hero scenarios, Valve ability check and full build suite pass; lobby checklist and engine limitations are recorded for Needs In-Game Test handoff
<!-- AC:END -->

## Implementation Plan

<!-- SECTION:PLAN:BEGIN -->
- Use current innate flight and meaningful Chill/Shard defensive opportunities.
- Use capped observed Soul Assumption charges and correct arrival/weakest-target decisions.
- Summon based on actual owned living Familiars, with request throttles only.
- Correct actual controlled Familiar Stone Form shape, ownership, timing and action locks while retaining movement.
<!-- SECTION:PLAN:END -->

## Implementation Notes

<!-- SECTION:NOTES:BEGIN -->
Source review and offline implementation for the Queen of Pain → Zeus batch (hero-file order).

Sources: Torte CLI tools/tdl/fetch.cjs visage; https://dotacoach.gg/en/heroes/visage and https://dotacoach.gg/en/heroes/counters/visage (full Strategy, Counter Strategy and Matchup); Valve d2vpkr cf0d37a32c8df338a7832fd32a282747969e9a5f hero definitions plus English ability localization.

Verified ability checklist
- Read full native controller and every consideration, Familiar companion, TDL guide 128903691 and complete Dotacoach Strategy, Counter Strategy, Matchup synergy/gameplay and advanced item cards.
- Pinned Valve cf0d37a32c8df338a7832fd32a282747969e9a5f: Grave Chill range 625, cast point 0.2, duration five seconds plus talent, movement drain 12/18/24/30%, attack drain 35/45/55/65 and shared Familiar radius 900.
- Soul Assumption range 1000, cast point 0.2, bolt speed 1000, base damage 20, damage per charge 70 plus talent, limit 3/4/5/6 and six-second charge duration. Only actual observed charges are valued; copied spells do not invent nearby damage collection.
- Cloak gives four layers, each 8/12/16/20% reduction, recovery 7/6/5/4 seconds and minimum damage 40. Break prevents new stacks while preserving existing bonuses. Current Shard adds a six-second invulnerable Stone Form with up to 25% healing and current 65-second cooldown/125 mana.
- Silent as the Grave is now an innate active: 20-second flying movement, 12% speed and 10% attack damage for two seconds after breaking flight. Scepter adds 12% speed, 10% damage, two seconds damage duration and ten seconds flight plus invisibility. It no longer requires Scepter to function.
- Summon is NO_TARGET/IMMEDIATE with current cooldown 120/110/100 and actual count two plus talent. Current Familiar HP is 450/600/750, attacks 25/50/75 and range 180. Familiar Stone Form is NO_TARGET, radius 375, delay 0.55, stun 0.8/1/1.2 and six-second invulnerable healing state.

Implemented behavior
- Soul Assumption now chooses a real weaker eligible target instead of the impossible 20000<HP comparison, uses true Lens/Supremacy range, capped observed charges, regeneration and projectile arrival, and spends useful charges nearing expiration.
- Grave Chill values actual physical attack threat, allows lane/farm/objective use and peels retreating human or bot allies.
- Current innate flight supports approach, retreat and stuck escape; observed flight approach is preserved until useful engagement or a lethal nuke opportunity. Shard defense gets priority under real threat and avoids ineffective idle healing during Ice Blast.
- Summon immediately replenishes missing owned living birds, ignores foreign birds and protected healing stones, and only considers replacing a full set when all are genuinely endangered. A short attempt throttle records requests without fabricating summon success.
- Approved Familiar companion verifies actual owner/name/liveness/action queue, uses no-target Stone Form, predicts landing coverage and checks actual current stuns. Nearby requests are staggered conservatively and healing stones are left alone. Existing movement, retreat and attack structure remains, with safe eligible attack targets.
- Independent copied spells and actual Familiar forwarding preserve unknown spell dispatch, optional handles and real owned minion state.
- Protective ally peel now uses actual recent damage and observed pursuit without requiring a bot-only retreat mode; native and copied idle-mode human ally positives and no-threat negatives pass.

Rejected or stale source claims
- Rejected old 7.36 toggle-only Summon assumptions, Scepter-only flight, Break removing existing Cloak bonuses, Familiar attacks bypassing Ghost Shroud, Soul Assumption inherently being AoE without its talent, and Nullifier disabling passives.

Item follow-up observations for TASK-21
- TASK-21: Review current Shard survival, innate versus Scepter flight/invisibility, Bearing/Vladmir/Assault auras for actual owned birds, appropriate Hex/Orchid follow-up and true Lens range. No build or generic item policy changes.

Enemy counterplay observations for TASK-24
- TASK-24: Protect and focus high-bounty birds, respect Cloak threshold and existing layers under Break, armor/damage block versus Familiar attacks, applicable reflection/block versus hero nukes, and detection after current Scepter timing.

Lobby validation checklist
- Validate actual flight modifier identity, charge-duration metadata and copied charge generation, hero/familiar command handles and Alt-cast recall, controllability after current retired facets, and real summon/cooldown response.
- Standard pass fixes supported observed controller behavior; full weak-hero Familiar lifecycle, hero command/recall and engine control acceptance still need lobby validation. No game was launched.

Focused verification
- Fengari tests/visage_ability_spec.lua passed: actual range and arrival regeneration, capped/missing/expiring charges, correct target selection, immunity/block/reflection, useful Chill farm and threat, innate flight preservation and lethal exceptions, active/passive Shard and Ice Blast, owned versus foreign/missing birds, request throttles, copied unknown/hidden/null/absent handles and Lens/Supremacy/Break.
- Actual Familiar scenarios cover no-target Stone Form, delayed coverage, nearby request staggering, queue, foreign ownership, healing stones and null ability. Four changed Lua files passed Lua 5.2 parsing.
- Focused specification rerun after human ally parity follow-up passed.
- Final fractional-value audit passed: focused fixtures now truncate GetSpecialValueInt and preserve GetSpecialValueFloat; all eleven completed focused specs reran with pass markers.
- Final owned batch audit passed: all twelve focused Fengari specs emitted pass markers and all thirty-eight native/copied/spec/companion Lua files parsed as Lua 5.2. No game validation claimed.

Framework integration
- Copied X.ConsiderStolenFamiliarMinion(unit) forwards to Familiar.Think(GetBot(),unit). Returns false for invalid, unrelated or foreign units and true for actual owned named Familiars, including idle and locked states. Preserves observed action/queue/healing state and issues no unsupported Alt-cast endpoint.

Full integration/build verification passed. Builds, skill/talent preferences and draft weights are unchanged. No game launched; engine-dependent claims remain lobby checks.

Final integrated verification: node tests/run-builds.cjs, node tests/run-objectives.cjs, node tests/valve_ability_check.cjs and git diff --check passed. Build/skill/talent preference AST comparison passed for all 43 scoped heroes. Native and applicable copied regressions are registered in run-builds. Framework callbacks and unsupported-spell dispatch preservation are covered. No game launched; the recorded lobby checklist remains required.
<!-- SECTION:NOTES:END -->

## Final Summary

<!-- SECTION:FINAL_SUMMARY:BEGIN -->
Visage standard ability pass completed offline. Native and copied behavior reviewed against Torte and full Dotacoach Strategy/Counter Strategy/Matchup and pinned Valve KV/localization. Meaningful behavior fixes and positive/negative regressions implemented; builds and flags preserved. Final integrated verification: node tests/run-builds.cjs, node tests/run-objectives.cjs, node tests/valve_ability_check.cjs and git diff --check passed. Build/skill/talent preference AST comparison passed for all 43 scoped heroes. Native and applicable copied regressions are registered in run-builds. Framework callbacks and unsupported-spell dispatch preservation are covered. No game launched; the recorded lobby checklist remains required.
<!-- SECTION:FINAL_SUMMARY:END -->
