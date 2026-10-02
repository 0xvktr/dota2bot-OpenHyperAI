---
id: TASK-13.108
title: 'Slardar: standard hero ability pass'
status: Needs In-Game Test
assignee:
  - '@codex'
created_date: '2026-10-02 15:18'
updated_date: '2026-10-02 16:24'
labels:
  - hero
dependencies: []
references:
  - bots/BotLib/hero_slardar.lua
  - tests/slardar_ability_spec.lua
documentation:
  - backlog/docs/doc-2 - Hero-improvement-playbook.md
modified_files:
  - bots/BotLib/hero_slardar.lua
  - bots/FunLib/rubick_hero/slardar.lua
  - tests/slardar_ability_spec.lua
parent_task_id: TASK-13
priority: medium
ordinal: 148000
---

## Description

<!-- SECTION:DESCRIPTION:BEGIN -->
Slardar is part of the requested Queen of Pain through Zeus hero-file-order batch. Review actual spell decisions against current mechanics and human usage, fixing meaningful ability-use gaps while retaining the established D2PT build.
<!-- SECTION:DESCRIPTION:END -->

## Acceptance Criteria
<!-- AC:BEGIN -->
- [x] #1 Ability decisions and cast order are reviewed against Torte de Lini, dotacoach Strategy/Counter Strategy/full Matchup and pinned Valve definitions/localization; verified checklist and stale claims are recorded
- [x] #2 Identified meaningful behavior gaps are fixed, including applicable Rubick handling, with positive and negative offline regression scenarios
- [x] #3 Focused hero scenarios, Valve ability check and full build suite pass; lobby checklist and engine limitations are recorded for Needs In-Game Test handoff
<!-- AC:END -->

## Implementation Plan

<!-- SECTION:PLAN:BEGIN -->
Use current physical Crush and exact predicted radius, meaningful human ally control, current immunity-piercing Haze with actual attack focus/observed expiry, and useful buff-aware Sprint; preserve preferences and ordinary channels/invisibility.
<!-- SECTION:PLAN:END -->

## Implementation Notes

<!-- SECTION:NOTES:BEGIN -->
Source review and offline implementation for the Queen of Pain → Zeus batch (hero-file order).

Sources: Torte CLI tools/tdl/fetch.cjs slardar; https://dotacoach.gg/en/heroes/slardar and https://dotacoach.gg/en/heroes/counters/slardar (full Strategy, Counter Strategy and Matchup); Valve d2vpkr cf0d37a32c8df338a7832fd32a282747969e9a5f hero definitions plus English ability localization.

Verified ability checklist
- Read full native controller, Torte guide 129102427 with all item/ability tips, entire Dotacoach Strategy/Counter Strategy/Matchup gameplay/synergy/core and counter item cards, pinned Valve KV and all English localization.
- Sprint is immediate no-target/IGNORE_CHANNEL, 25 mana, 10-second duration plus actual talent and initial 2.5 seconds slow resistance. Crush is physical, non-piercing, cast point 0.25, radius 325, runtime damage 60/140/220/300 plus actual talent, 0.8-second stun and 7-second puddle.
- Shard applies five seconds Haze before Crush. Haze is a current 900-range, 0.3-cast-point debuff that pierces immunity, costs 25 and lasts 18 seconds with actual armor reduction -8/-14/-20.
- Bash is breakable physical passive after three attacks, current 35/90/145/200 bonus. Seaborn Sentinel is separate current breakable innate with level scaling and Scepter water bonuses. Hidden slardar_scepter has obsolete incomplete behavior metadata and is not invented as an active.

Implemented behavior
- Crush uses actual physical incoming damage and regeneration at impact, predicted exact radius rather than arbitrary inner margins, true immunity eligibility and reflection/Carapace protection. It interrupts actual channels and peels observed attacks on damaged human or bot allies.
- Preserved useful ranged creep last hits, local wave/neutral packs and eligible objective uses with actual radius and Glyph/resource guards; removed undefined unused farming target. Guaranteed kills conservatively exclude unobserved Shard pre-Haze or assumed Bash procs.
- Haze now pierces debuff immunity and uses exact runtime Lens/Supremacy range. Actual allied right-click focus determines selection instead of arbitrarily selecting the lowest-armor enemy. Observed existing Haze duration suppresses redundant casts and permits meaningful near-expiry refresh.
- Haze supports useful actual neutral farming and Roshan/eligible boss use; existing spell block and reflection gates remain. Visible invisible units are eligible for current vision utility without guessing hidden unit locations.
- Sprint values actual approach, threatened retreat or stuck escape and avoids recasting the observed buff or movement-only use under root. Normal channel and invisibility preservation remains; no unsupported active passive or blanket channel exception was introduced.
- Channel interrupts use actual observed teleport modifier remaining duration versus cast/projectile arrival, avoiding interrupt-only requests that are already too late.

Rejected or stale source claims
- Rejected old magical Crush, immunity-piercing Crush, obsolete facet behavior, old fixed Seaborn armor/regen, and instant guaranteed Shard/Bash combined damage.
- Source Matchup claims Haze amplifies pure Psi Blades and current pure Death Ward; armor reduction cannot do that. Old Solar Crest enemy targeting, Harpoon tree targeting and Nullifier disabling passives were not implemented.

Item follow-up observations for TASK-21
- TASK-21: actual Blink/Crush access and observed readiness, Soul Ring/Treads mana preparation, current Shard pre-Haze, Scepter water survival, BKB and attack access need shared item follow-up. Existing build and item policy unchanged.

Enemy counterplay observations for TASK-24
- TASK-24: actual dispels can remove Haze until its current talent, armor/physical barriers and ethereal state reduce physical burst, immunity stops Crush but not Haze, and ranged kiting or disable can deny Bash. Coordinated real allied physical attacks benefit from Haze; pure Ward does not.

Lobby validation checklist
- Validate current Shard applies Haze before physical Crush and true spell-immunity handling; guaranteed kill math remains conservative before actual Haze observation.
- Validate current Seaborn water effects/Scepter, actual Bash counter and attack control, Blink readiness/item preparation, and Haze exact live range/refresh. No game launched.

Focused verification
- Fengari tests/slardar_ability_spec.lua passed 78 native/copied positive/negative cases plus unknown dispatch, unavailable handles and independent copied Crush.
- Scenarios cover predicted radius and moving-away/regen/armor boundaries, immunity and reflection, human idle-mode peel/no-threat negative, ranged last hit/Glyph/packs, exact Haze/Lens, immunity piercing, actual ally attack focus, observed expiry, block/reflection, neutral value, Sprint/root/buff/escape/channel/invisibility/queue.
- All build/skill/talent preferences remain unchanged; full final integration verification pending.
- Final peer timing regression: actual modifier index/duration query rejects interrupt-only casts when teleport remaining0.1s is shorter than real spell arrival; remaining2s channel interrupt passes. Focused suite now 78 scenarios.

Full integration/build verification passed. Builds, skill/talent preferences and draft weights are unchanged. No game launched; engine-dependent claims remain lobby checks.

Final integrated verification: node tests/run-builds.cjs, node tests/run-objectives.cjs, node tests/valve_ability_check.cjs and git diff --check passed. Build/skill/talent preference AST comparison passed for all 43 scoped heroes. Native and applicable copied regressions are registered in run-builds. Framework callbacks and unsupported-spell dispatch preservation are covered. No game launched; the recorded lobby checklist remains required.
<!-- SECTION:NOTES:END -->

## Final Summary

<!-- SECTION:FINAL_SUMMARY:BEGIN -->
Slardar standard ability pass completed offline. Native and copied behavior reviewed against Torte and full Dotacoach Strategy/Counter Strategy/Matchup and pinned Valve KV/localization. Meaningful behavior fixes and positive/negative regressions implemented; builds and flags preserved. Final integrated verification: node tests/run-builds.cjs, node tests/run-objectives.cjs, node tests/valve_ability_check.cjs and git diff --check passed. Build/skill/talent preference AST comparison passed for all 43 scoped heroes. Native and applicable copied regressions are registered in run-builds. Framework callbacks and unsupported-spell dispatch preservation are covered. No game launched; the recorded lobby checklist remains required.
<!-- SECTION:FINAL_SUMMARY:END -->
