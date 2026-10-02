---
id: TASK-13.122
title: 'Io: standard hero ability pass'
status: Needs In-Game Test
assignee:
  - '@codex'
created_date: '2026-10-02 15:56'
updated_date: '2026-10-02 16:24'
labels:
  - hero
  - weak-hero
milestone: m-0
dependencies: []
references:
  - bots/BotLib/hero_wisp.lua
  - tests/wisp_ability_spec.lua
documentation:
  - backlog/docs/doc-2 - Hero-improvement-playbook.md
modified_files:
  - bots/BotLib/hero_wisp.lua
  - bots/FunLib/rubick_hero/wisp.lua
  - tests/wisp_ability_spec.lua
parent_task_id: TASK-13
priority: medium
ordinal: 162000
---

## Description

<!-- SECTION:DESCRIPTION:BEGIN -->
Io is part of the requested Queen of Pain through Zeus hero-file-order batch. Review actual spell decisions against current mechanics and human usage, fixing meaningful ability-use gaps while retaining the established D2PT build.
<!-- SECTION:DESCRIPTION:END -->

## Acceptance Criteria
<!-- AC:BEGIN -->
- [x] #1 Ability decisions and cast order are reviewed against Torte de Lini, dotacoach Strategy/Counter Strategy/full Matchup and pinned Valve definitions/localization; verified checklist and stale claims are recorded
- [x] #2 Identified meaningful behavior gaps are fixed, including applicable Rubick handling, with positive and negative offline regression scenarios
- [x] #3 Focused hero scenarios, Valve ability check and full build suite pass; lobby checklist and engine limitations are recorded for Needs In-Game Test handoff
<!-- AC:END -->

## Implementation Plan

<!-- SECTION:PLAN:BEGIN -->
- Observe the actual owned Tether partner, support real human and immune allies and preserve safe latch geometry and action locks.
- Use useful self/confirmed-partner Overcharge and actual Spirits with independently available radius controls.
- Use legal delayed Relocate saves and supported offensive participation, distinguishing cast requests from observed state.
- Preserve builds/default exports, add independent copied handling and meaningful native/copied regressions; record engine lifecycle limitations.
<!-- SECTION:PLAN:END -->

## Implementation Notes

<!-- SECTION:NOTES:BEGIN -->
Source review and offline implementation for the Queen of Pain → Zeus batch (hero-file order).

Sources: Torte CLI tools/tdl/fetch.cjs wisp; https://dotacoach.gg/en/heroes/io and https://dotacoach.gg/en/heroes/counters/io (full Strategy, Counter Strategy and Matchup); Valve d2vpkr cf0d37a32c8df338a7832fd32a282747969e9a5f hero definitions plus English ability localization.

Verified ability checklist
- Read all378 native lines and every consideration, full Torte128734250 through node tools/tdl/fetch.cjs wisp, complete canonical Dotacoach Io Strategy, Counter Strategy and Matchup gameplay/synergy/core/counter-item cards, pinned cf0d37a32c8df338a7832fd32a282747969e9a5f KV and all relevant English localization.
- Tether is friendly UNIT_TARGET/CUSTOM, pierces allied immunity, cast0, mana40, range1600, cooldown12. Break radius1000;700+distance latches Io toward300 at1000 speed. Transfer55/75/95/115%, move6/8/10/12%. Current Shard adds120 damage with50% heal, no obsolete spell-lifesteal Shard.
- Spirits is immediate NO_TARGET:90/100/110/120mana,15s duration, five spirits, orbit200–650/default425, radial speed250, five-second revolution, collision110, explosion360, hero30/50/70/90 and creep12/18/24/30. Current Scepter passively spawns every1s,25% slow/.3s and active explosion; talent+40% damage. In/Out are actual toggles, hidden until available.
- Overcharge is immediate NO_TARGET,8s plus live duration talent,25/22/19/16cooldown and40/60/80/100mana. Current attack speed35/60/85/110, spell amp8/10/12/14%, maxHPregen.5/.6/.7/.8%; bonus armor/magic resistance are0.
- Relocate POINT/cast0/mana175, delayed3.5/3.25/3s minus actual talent,12s return,90/80/70 cooldown minus talent. Actual disable/silence during delay cancels, hero/creep-hero/illusion passenger travels through existing Tether; no guaranteed rescue, arrival or return is inferred from an action request.
- Equilibrium grants health-dependent damage/heal amplification4%+.4% perlevel; removed Wellspring/old facets and absent copied innate bonuses are not fabricated. Documented modifier source ability, GetCaster and auxiliary-unit queries support observation; pinned localization confirms modifier_puck_coiled.

Implemented behavior
- Replaced speculative bot.stateTetheredHero assignment after casting with observation of an actual source-owned Tether modifier and its living allied hero auxiliary unit. Retains already linked invulnerable/illusion passengers for safety, separately from eligible new Tether candidates. Missing/foreign/unresolved partners cannot authorize offensive travel or bypass passenger safeguards.
- Tether considers actual visible allied heroes globally then filters real cast range, including Lens/Supremacy beyond1600; supports human and debuff-immune allies without core/retreat-mode restrictions. Scores real heal outlets, current attacks/spell pressure and safe retreat latches; actual roots/Rupture/Coiled/leash and tower/Chrono/Black Hole/number hazards block distant movement while nearby stationary support remains legal.
- Overcharge supports useful self attack/healing pressure and confirmed allied attack/spell/heal needs, including actual building attacks and immune human allies. Ice Blast prevents heal-only valuation, actual owned Overcharge prevents duplicate requests, and no nonexistent damage reduction is assumed.
- Spirits uses reachable real fights or useful local farm groups, with no guaranteed five-hit lethal or full-duration damage estimate. Scepter active explosion requires actual owned source-associated nonhero units and valid current targets; absence of exposed spirit units declines. Radius controls compare actual source-associated orb locations with reachable target distance and toggle only needed direction; no simulated radius or blind timer.
- Relocate now requires actual ready handle, delayed-state locks and conservative caster/destination safety. Useful human passenger saves have no arbitrary caster-health requirement, reject lethal incoming attack projectiles and X Mark/Duel hazards, and preserve healthy linked channels. Healthy unthreatened passengers are protected from selfish travel; a legal emergency Break can release them before later self travel. Missing auxiliary identity declines travel.
- Offensive travel requires a healthy actually engaged confirmed passenger, actual remote allied pressure and support, legal predicted destination and adequate resources. Removed solo teleport to any damaged ally and arbitrary HP comparisons.
- A bounded.4s unconfirmed request lock expires if unobserved; actual cooldown increase starts a conservative live cast-delay lock, actual ability phase/owned channel confirms busy state. Death/disable/silence cancels pending state before ordinary gates, and no local timestamp is claimed as completed teleport. Native/copied paths preserve actual queues, invisibility and disable/channel/cast locks. Copied unknown name returns nil before actor lookups; missing siblings remain independent.

Rejected or stale source claims
- Rejected old Overcharge damage reduction/armor/MR, toggle drain assumptions, old Wellspring/facet bonuses, Shard spell-lifesteal descriptions and obsolete Solar Crest offensive armor reduction.
- Rejected guaranteed Spirit collisions/damage or scouting visibility, treating a queued Tether as a successful link, unrestricted solo offensive Relocate and immediate fountain healing through Ice Blast.

Item follow-up observations for TASK-21
- TASK-21: Tether transfers actual restoration including consumables, Wand/Locket, Mek/Greaves, healing lotus/Cheese and regen auras; current heal restriction and item cooldowns must be respected. Lens improves real Tether range but not spirit orbit. Defensive Glimmer/BKB/positioning protect delayed travel; no item/build edits.

Enemy counterplay observations for TASK-24
- TASK-24: Focus the exposed caster, apply observed disable/silence to cancel delayed travel, use actual X Mark and healing reduction/Ice Blast, and respect displacement/Coiled/Rupture. A passive or existing link can persist through protected target states; this does not authorize an unavailable active spell.

Lobby validation checklist
- No game launched. Verify exact Tether modifier auxiliary-unit contents and linked passenger identity, including invulnerability, illusions, latch path, tree cutting and link break. Unavailable auxiliary identity deliberately declines partner-dependent Relocate.
- Verify actual Spirits auxiliary entities and radius control/Scepter explosion semantics; source-associated nonhero units must represent active spirits. If not exposed, these controls deliberately decline rather than manufacture positions.
- Verify actual Relocate delay/channel and return modifier lifecycle, cooldown timing, disable cancellation, pending-request expiry, passenger eligibility and return location. No successful travel/12-second return or permanent area control is asserted from local request state. Deep weak-hero lifecycle validation remains separate from the standard pass.

Focused verification
- Fengari tests/wisp_ability_spec.lua passed144 native/copied positive/negative scenarios: confirmed versus requested/foreign/unresolved links, exact range beyond1600, immune human support, stationary versus dangerous latch, actual Coil/root/tower safety, self/building/ally Overcharge and Ice Blast, observed Spirit/Scepter/radius controls, request timeout versus cooldown-confirmed delay, early cancellation recovery, healthy/invulnerable passenger protection, human saves/idle offensive refusals and X Mark/lethal projectile guards.
- Missing optional handles and all actual availability flags, nil-first unsupported dispatch and independent copied Overcharge pass. Read-only peer review checked full sources and API, found real range/passenger/movement/observation issues which were corrected and tested. Full integrated validation passed.

Framework integration
- ObserveTetherState is read-only actual source/auxiliary observation; native UseNative calls it before ordinary gates. Shared utility and native Rubick receive the same observation before local action gates. IsRelocating is a read-only actual phase/owned channel/observed cooldown lock with bounded unconfirmed request expiry; shared native/copied ordinary casts respect it without any global disable/invulnerability exception.

Full integration/build verification passed. Builds, skill/talent preferences and draft weights are unchanged. No game launched; engine-dependent claims remain lobby checks.

Final integrated verification: node tests/run-builds.cjs, node tests/run-objectives.cjs, node tests/valve_ability_check.cjs and git diff --check passed. Build/skill/talent preference AST comparison passed for all 43 scoped heroes. Native and applicable copied regressions are registered in run-builds. Framework callbacks and unsupported-spell dispatch preservation are covered. No game launched; the recorded lobby checklist remains required.
<!-- SECTION:NOTES:END -->

## Final Summary

<!-- SECTION:FINAL_SUMMARY:BEGIN -->
Io standard ability pass completed offline. Native and copied behavior reviewed against Torte and full Dotacoach Strategy/Counter Strategy/Matchup and pinned Valve KV/localization. Meaningful behavior fixes and positive/negative regressions implemented; builds and flags preserved. Final integrated verification: node tests/run-builds.cjs, node tests/run-objectives.cjs, node tests/valve_ability_check.cjs and git diff --check passed. Build/skill/talent preference AST comparison passed for all 43 scoped heroes. Native and applicable copied regressions are registered in run-builds. Framework callbacks and unsupported-spell dispatch preservation are covered. No game launched; the recorded lobby checklist remains required.
<!-- SECTION:FINAL_SUMMARY:END -->
