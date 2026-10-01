---
id: TASK-13.21
title: 'Crystal Maiden: standard hero ability pass'
status: Needs In-Game Test
assignee:
  - '@codex'
created_date: '2026-10-01 16:04'
updated_date: '2026-10-01 16:37'
labels:
  - hero
dependencies: []
references:
  - bots/BotLib/hero_crystal_maiden.lua
  - bots/FunLib/rubick_hero/crystal_maiden.lua
documentation:
  - backlog/docs/doc-2 - Hero-improvement-playbook.md
parent_task_id: TASK-13
priority: medium
ordinal: 61000
---

## Description

<!-- SECTION:DESCRIPTION:BEGIN -->
Crystal Maiden is in the next standard-pass batch after Bloodseeker/Bounty Hunter/Bristleback/Broodmother/Centaur. Review current ability decisions and combos against guide strategy and authoritative mechanics, including applicable Rubick handling. Existing D2PT builds and future role differentiation remain separate.
<!-- SECTION:DESCRIPTION:END -->

## Acceptance Criteria
<!-- AC:BEGIN -->
- [x] #1 Spell decisions and cast order are reviewed against pinned Valve definitions/localization, Torte de Lini tips and dotacoach Strategy, Counter Strategy and full Matchup advice; source checklist and stale claims are recorded
- [x] #2 Identified ability-use gaps are fixed in the native hero and applicable Rubick copy, with meaningful offline behavior scenarios and preserved D2PT builds
- [x] #3 Hero regression spec, Valve check and shared build suite pass; lobby scenarios and capability limits are recorded and the standard pass is ready for in-game testing
<!-- AC:END -->

## Implementation Plan

<!-- SECTION:PLAN:BEGIN -->
1. Reconcile pinned Valve/localization, TDL and complete dotacoach strategy/matchup advice with passive Aura, Frostbite damage/root and Clone/Field upgrades. 2. Fix real cast reach, defensive control/combo priority, neutral/summon farming and safe Field commitment/channel protection, including permitted Clone during Field in native/copy. 3. Add faithful behavior specs and source/capability/lobby notes; root integrates shared suite and finalizes.
<!-- SECTION:PLAN:END -->

## Implementation Notes

<!-- SECTION:NOTES:BEGIN -->
Source checklist (2026-10-01):
- [x] Pinned Valve hero KV plus English localization cf0d37a32c8df338a7832fd32a282747969e9a5f: https://github.com/dotabuff/d2vpkr/blob/cf0d37a32c8df338a7832fd32a282747969e9a5f/dota/scripts/npc/heroes/npc_dota_hero_crystal_maiden.txt . Nova700/radius425/0.3 cast; Frostbite600,100 DPS for actual1.5-3 duration, fourfold non-ancient creep damage; passive Aura/Glacial Guard; Field810 radius/random explosions/ten-second channel; Scepter move/cast/attack permission plus Frostbite; Clone275 hop,450 frostbite radius,150 health and five-second duration audited.
- [x] TDL Workshop128851981,7.41f through tools/tdl/fetch.cjs. Adopted Nova beyond Frostbite reach, close root initiation, large neutral farming, waiting for supported Field and permitted Clone reposition/detonation. Root does not interrupt ordinary channels; TP exception retained.
- [x] dotacoach Strategy/Counter: https://dotacoach.gg/en/heroes/crystal-maiden . Reviewed multi-hero/contested-creep Nova, mana barrier benefit, summons, survival before ultimate, Clone->Nova burst and root follow-through; opposing spacing, interruptions and detection.
- [x] Complete Matchup: https://dotacoach.gg/en/heroes/counters/crystal-maiden . Reviewed all synergy/core/opponent/counter items: root/slow sets up allied melee burst and projectiles; protected Field, mobility and mana support matter; immunity, purge, reflection, area physical/magic threats and instant interruptions constrain commitment. Glimmer/BKB/Bearing/Force/Eul interactions routed as item/counterplay candidates.

Stale exclusions: Arcane Aura is passive; no facet active. Old Frostbite damage/ten-second creep assumptions and synthetic offensive-power ultimate kill calculation removed. Field random explosions do not guarantee lethal burst from a single deterministic damage estimate. Public blanket Frostbite interruption of Io channels is not supported by root semantics. Old attack-speed talents and TDL Scepter stun wording excluded. Wind Waker interrupts the caster or purges Frostbite; it does not dispel a Freezing Field instance from existence. Solar Crest self-cast tips excluded. Retained Let It Go and stop definitions are not ordinary cast candidates.

Native/copy implementation: True legal Lens/Supremacy-aware reach, self/ally Counterspell and advanced reflection/block checks for targeted Frostbite. Actual DPS times duration and full application delay replace instant lethal estimate. Frostbite TP/control/save priority, large non-ancient neutral selection respecting allied target, and enemy-summon control. Nova uses full AoE edge with clamped point, contested ranged-creep/multiple-hero coverage and explicit unattended waveclear modes. Root precedes Nova inside reach; Nova initiates from outside root reach. Field uses actual810 radius, predicted eligibility and supported/protected commitment with exposed low-HP/focus/retreat suppression. Removed passive Aura casts and hero-local generic invis-item policy. Clone disjoints/repositions with real275 hop, is allowed during observed Field, and records its origin/duration for Nova to detonate it when damage can break its150 HP. Normal spells preserve unsceptered channels; Scepter permits spell use only during active Field, while queued/casting actions still prevent repeated enqueues.

Copy exports UseFreezingFieldSpell(): observed active Field only, live Clone->Frostbite->Nova handles, strict alive/stun/hex/silence/nightmare/casting/queue checks, unsceptered Clone-only permission, true only after one cast. Root owns early generic Rubick/dispatcher wiring before channel gates. Ordinary channels such as TP remain untouched. D2PT build/skill/talent prefix preserved.

Verification: tests/crystal_maiden_ability_spec.lua passes Crystal Maiden ability scenarios passed. Native/copy DOT delay/regen, real range/TP-only interruption/reflection, Nova edge, neutral/summon targeting, Field radius/protection/focus/HP, Clone origin Nova burst/expiry, active Field/Scepter/queued/channel permissions and early-hook cases covered. Intermediate Valve checker passed128 hero files/22 copies/zero allowances; root integrates final shared suite/status/AC. Diff check clean.

Lobby: real Frostbite ticks, talent/status resistance and quadruple creep multiplier; Nova contested creep/edge point; supported vs exposed Field random coverage and Scepter spell permissions; Clone actual275 displacement, projectile disjoint timing, current origin/expiry and Nova self-detonation; Rubick linked Clone and copied Field/Scepter interaction, early hook without disturbing TP; actual cast bonuses. Clone queue-time origin timing and Field modifier identity need live observation. No game launched. TASK21/24 candidates: channel-safe Glimmer/BKB/Bearing/Force, deward vision via Nova in ward policy, purge/reflection response and interrupting an opposing protected Field. No generic item/draft/minion edits.

Integration review follow-up: the native and stolen Freezing Field exception now checks GetCurrentActiveAbility whenever IsChanneling is true. Only an observed crystal_maiden_freezing_field channel permits the exception; a TP, another channel, or an unknown active ability remains protected even while the Field modifier persists. Native/copy entry points also preserve current casts and queued actions. Added Scepter Field-modifier plus TP/unknown overlap regressions for native decisions, stolen decisions, and the early Rubick helper. Focused output: Crystal Maiden ability scenarios passed. git diff --check clean.

Final action-shape review: permitted native Frostbite/Nova during active Scepter Freezing Field now use immediate Action_UseAbilityOnEntity/Location, matching the stolen handler; ordinary casts retain their queued actions. Focused native/copy scenarios assert immediate Field actions and queued ordinary actions. Crystal Maiden ability scenarios passed; whitespace check clean.

Final integrated verification (2026-10-01): node tests/run-builds.cjs exited 0 after all review repairs; exact markers confirmed for all five new hero specs, 348 Lua files parsed, Valve check 128 native heroes / 22 Rubick copies / 0 allowlisted findings, 127 hero role tables, 90 specialized dispatches, 61 Rubick behavior cases and 272 purchase lists. git diff --check passed. HEAD comparison confirms this hero build/skill/talent prefix unchanged. No lobby launched; standard pass handed off as Needs In-Game Test, with capability limits above. Item/counterplay findings appended to TASK21/24.
<!-- SECTION:NOTES:END -->

## Final Summary

<!-- SECTION:FINAL_SUMMARY:BEGIN -->
Crystal Maiden native and Rubick decisions now use actual Nova coverage and Frostbite damage/control, supported Freezing Field commitments, and live Clone/Field cast exceptions without breaking unrelated channels. Passive Aura is not cast. Builds preserved. Focused scenarios, final shared suite and Valve check passed; channel, clone and upgrade lobby cases recorded.
<!-- SECTION:FINAL_SUMMARY:END -->
