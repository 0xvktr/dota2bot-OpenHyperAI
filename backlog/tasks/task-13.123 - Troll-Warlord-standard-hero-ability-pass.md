---
id: TASK-13.123
title: 'Troll Warlord: standard hero ability pass'
status: Needs In-Game Test
assignee:
  - '@codex'
created_date: '2026-10-02 15:58'
updated_date: '2026-10-02 16:24'
labels:
  - hero
dependencies: []
references:
  - bots/BotLib/hero_troll_warlord.lua
  - tests/troll_warlord_ability_spec.lua
documentation:
  - backlog/docs/doc-2 - Hero-improvement-playbook.md
modified_files:
  - bots/BotLib/hero_troll_warlord.lua
  - bots/FunLib/rubick_hero/troll_warlord.lua
  - tests/troll_warlord_ability_spec.lua
  - bots/FunLib/troll_warlord_abilities.lua
parent_task_id: TASK-13
priority: medium
ordinal: 163000
---

## Description

<!-- SECTION:DESCRIPTION:BEGIN -->
Troll Warlord is part of the requested Queen of Pain through Zeus hero-file-order batch. Review actual spell decisions against current mechanics and human usage, fixing meaningful ability-use gaps while retaining the established D2PT build.
<!-- SECTION:DESCRIPTION:END -->

## Acceptance Criteria
<!-- AC:BEGIN -->
- [x] #1 Ability decisions and cast order are reviewed against Torte de Lini, dotacoach Strategy/Counter Strategy/full Matchup and pinned Valve definitions/localization; verified checklist and stale claims are recorded
- [x] #2 Identified meaningful behavior gaps are fixed, including applicable Rubick handling, with positive and negative offline regression scenarios
- [x] #3 Focused hero scenarios, Valve ability check and full build suite pass; lobby checklist and engine limitations are recorded for Needs In-Game Test handoff
<!-- AC:END -->

## Implementation Plan

<!-- SECTION:PLAN:BEGIN -->
Separate actual stance from passive Rage, support narrowly legal silence/invisibility switching, correct axe geometry/timing/upgrades and value current forced-target Trance.
<!-- SECTION:PLAN:END -->

## Implementation Notes

<!-- SECTION:NOTES:BEGIN -->
Source review and offline implementation for the Queen of Pain → Zeus batch (hero-file order).

Sources: Torte CLI tools/tdl/fetch.cjs troll_warlord; https://dotacoach.gg/en/heroes/troll-warlord and https://dotacoach.gg/en/heroes/counters/troll-warlord (full Strategy, Counter Strategy and Matchup); Valve d2vpkr cf0d37a32c8df338a7832fd32a282747969e9a5f hero definitions plus English ability localization.

Verified ability checklist
- Read the entire native controller, complete Torte guide 128753951, canonical Troll Warlord Dotacoach Strategy/Counter Strategy and every Matchup synergy, gameplay and advanced item card. Guide CLI ran and page identity matched.
- Pinned KV/localization: Battle Stance is the actual innate toggle, immediate with IGNORE_SILENCE and IGNORE_INVISIBLE, 350 range difference and 1.4 melee BAT. Passive Berserker Rage separately supplies 15/25/35/45 movement, 20 percent ensnare or ranged Maim, and current armor comes from one per 30 bonus attack speed.
- Ranged axes: point/unit aim, 950 physical flight, 0.2 cast point, 1500 speed, width 100, five axes and raw spread value 25, 60/80/100/120 single impact, four-second maximum slow, 50 mana and nine-second cooldown. Travel does not expand with Lens. Localization explicitly excludes Roshan and spell block/reflection.
- Melee axes: immediate no-target, maximum 450 radius, 75/120/165/210 damage once, three-second whirl, five-second 60 percent blind, 50 mana and nine-second cooldown. Scepter gives enemy ranged/self melee basic dispels and reduces actual costs/cooldowns. Only actual pierce special permits damage/debuff eligibility under immunity.
- Trance is immediate self effect, actual 900 automatic acquisition prioritizing heroes, 6.5-second duration, 40/60/80 lifesteal, 140/170/200 attack speed, 35 percent move/slow resistance and 150 mana. It applies a basic dispel, does not prevent Axe Culling Blade, and still allows spells/items. Current talent shares attack speed and another upgrades dispel. Shard belongs to passive Fervor with 16 plus three percent proc chance per stack, not obsolete Rampage.

Implemented behavior
- Stance uses actual attack reach and hysteresis to avoid oscillating and retain ranged attacks on fleeing enemies, while close attacks/farming benefit from melee BAT. Escape movement requires an actual trained visible active Rage source and no Break; copied modules do not fabricate it.
- Native/copied UseBattleStance is a narrow pre-gate callback only under observed silence or invisibility and with an actual current legal stance handle. It preserves casts, channels, using animations, queues, disables, Box, Doom and Force Staff, and issues only a direct immediate toggle. Ordinary native Trance emergency decisions retain priority over normal stance switching.
- Ranged axe primary placement predicts true projectile flight and bounds actual physical travel; lethal estimates count one impact and regeneration. Native farm geometry uses the guaranteed central axe rather than guessing whether raw spread denotes inter-axe or whole-fan angle. Actual point casts do not consume unit spell block/reflection gates.
- Melee axe lethal estimates wait conservatively for the full real whirl and require predicted relative proximity; blind opportunities protect threatened human/bot allies. Actual Scepter handles can cleanse known basic-dispellable self effects or purge observed enemy Ghost/Windrun; silence never permits casting the ordinary axe spell.
- Both axes preserve independent optional siblings and native lane/farm/Tormentor opportunities when eligible, and explicitly skip Roshan. Current immunity-pierce specials and source readiness/visibility drive eligibility.
- Trance evaluates the actual forced nearest hero, physical protection and late controlled/low-health commitments. Actual recent critical pressure permits the survival effect without inventing guaranteed lifesteal; observed existing Trance prevents duplication. Native Roshan/Tormentor healing needs actual attack reach and absence of Ice Blast. Real attack-speed-share talent supports remote actively fighting human/bot allies; obsolete Rampage is not fabricated.
- Trance follows live unit behavior by self-targeting only when that flag actually exists, otherwise no-target; Scepter is never presumed to provide ally targeting. Copied unknown names return nil before lookups, recognized skips false, actions true.

Rejected or stale source claims
- Excluded learnable toggle in passive Rage slot, old flat melee armor, ignored silence/invisibility stance flags, instant full melee damage, fivefold ranged damage, Lens-extended flight, Roshan axe casts, Scepter ally Trance and obsolete Rampage Shard, root from ranged axes and spellcasting prevented by Trance. Unverified Nullifier/passive/disassembly and lifesteal item claims remain outside the pass.

Item follow-up observations for TASK-21
- TASK-21: actual BKB/Satanic and anti-kiting items remain usable during Trance, but no item use is assumed to have succeeded. Actual Scepter dispels differ between ranged and melee axes; generic purchases/preparation/builds remain unchanged.

Enemy counterplay observations for TASK-24
- TASK-24: Trance can be kited, disarmed and controlled; damage cannot normally kill during it, but Culling Blade still can. Ice Blast denies lifesteal healing, physical protection changes the forced target value, Break prevents new Fervor/Rage benefits and Shard procs, and basic dispel does not remove every root or disable.

Lobby validation checklist
- Verify exact stance toggle behavior under silence/invisibility and no visibility break, actual range/BAT changes on copied casters, Break/sibling availability, and direct immediate toggles with all unrelated state locks.
- Verify axe physical end-cap, raw spread spacing, first melee contact/whirl timing, current Scepter purge interaction under debuff immunity and actual independent form handles. Farm estimates deliberately use only the guaranteed central axe until fan geometry is observed.
- Verify forced nearest hero selection including illusions/immune/physical-protected targets, actual critical-health survival and Culling Blade exception, live self-target/no-target shape, talent sharing with human allies and current strong-dispel behavior. No game launched.

Focused verification
109 meaningful native/copied focused scenarios passed under Fengari with realistic integer truncation and float access. Four files parsed as Lua 5.2 and owned diff whitespace checks passed. Scenarios cover stance reach/hysteresis/silence/invisibility/locks and absent or broken Rage, one axe/flight/regeneration/range/point gates, actual upgrades and pierce, human peel, root dispel limitations, forced-target Trance/duplicates/physical protection/emergency/native priority, real talent sharing, Roshan exclusion/healing, farm/last hits and canonical dispatch.

Framework integration
- Native/copied UseBattleStance() runs only for a silenced or invisible actor with the exact actual current stance handle; ordinary action locks remain and it returns true only after a direct toggle.

Full integration/build verification passed. Builds, skill/talent preferences and draft weights are unchanged. No game launched; engine-dependent claims remain lobby checks.

Final integrated verification: node tests/run-builds.cjs, node tests/run-objectives.cjs, node tests/valve_ability_check.cjs and git diff --check passed. Build/skill/talent preference AST comparison passed for all 43 scoped heroes. Native and applicable copied regressions are registered in run-builds. Framework callbacks and unsupported-spell dispatch preservation are covered. No game launched; the recorded lobby checklist remains required.
<!-- SECTION:NOTES:END -->

## Final Summary

<!-- SECTION:FINAL_SUMMARY:BEGIN -->
Troll Warlord standard ability pass completed offline. Native and copied behavior reviewed against Torte and full Dotacoach Strategy/Counter Strategy/Matchup and pinned Valve KV/localization. Meaningful behavior fixes and positive/negative regressions implemented; builds and flags preserved. Final integrated verification: node tests/run-builds.cjs, node tests/run-objectives.cjs, node tests/valve_ability_check.cjs and git diff --check passed. Build/skill/talent preference AST comparison passed for all 43 scoped heroes. Native and applicable copied regressions are registered in run-builds. Framework callbacks and unsupported-spell dispatch preservation are covered. No game launched; the recorded lobby checklist remains required.
<!-- SECTION:FINAL_SUMMARY:END -->
