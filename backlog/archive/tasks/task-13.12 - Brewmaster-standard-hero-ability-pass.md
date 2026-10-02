---
id: TASK-13.12
title: 'Brewmaster: standard hero ability pass'
status: Needs In-Game Test
assignee:
  - '@codex'
created_date: '2026-10-01 14:21'
updated_date: '2026-10-01 14:54'
labels:
  - hero
  - weak-hero
milestone: m-0
dependencies: []
references:
  - bots/BotLib/hero_brewmaster.lua
  - bots/FunLib/rubick_hero/brewmaster.lua
documentation:
  - backlog/docs/doc-2 - Hero-improvement-playbook.md
parent_task_id: TASK-13
priority: medium
ordinal: 52000
---

## Description

<!-- SECTION:DESCRIPTION:BEGIN -->
Brewmaster is in the next standard-pass batch after Abaddon/Underlord/Alchemist/Anti-Mage/Arc Warden. Review current spell decisions and combos against guide strategy and pinned Valve mechanics, including the dedicated Rubick copy. Scope is ability gameplay; existing builds and future role differentiation in TASK-37 remain separate. Brewmaster remains on WeakHeroes; this standard pass records split-control limitations and lobby validation before any weak-list decision.
<!-- SECTION:DESCRIPTION:END -->

## Acceptance Criteria
<!-- AC:BEGIN -->
- [x] #1 Spell decisions and cast order are reviewed against pinned Valve definitions/localization, Torte de Lini tips and dotacoach Strategy, Counter Strategy and full Matchup advice; source checklist and stale claims are recorded
- [x] #2 Identified ability-use gaps are fixed in the native hero and applicable Rubick copy, with meaningful offline behavior scenarios and preserved D2PT builds
- [x] #3 Hero regression spec, Valve check and shared build suite pass; lobby scenarios are recorded and the standard pass is ready for in-game testing
<!-- AC:END -->

## Implementation Plan

<!-- SECTION:PLAN:BEGIN -->
1. Use pinned Valve/localization, TDL 129109889 and dotacoach Strategy/Counter/full Matchup to reconcile current three-spirit Split, Shard Liquid Courage and Scepter upgrade; reject legacy Companion/Void advice.
2. Prioritize urgent Split and reserve its mana, repair Cinder→Clap travel/placement and real damage checks, sync stance switching and use the active Shard drink on units. Mirror current casts in Rubick.
3. Repair hero-specific Split controls with interrupt/range/target guards, useful dispels and survival; preserve builds and generic item/minion code.
4. Add behavior scenarios, run Valve and complete offline suite, document source gaps and weak-hero lobby checklist.
<!-- SECTION:PLAN:END -->

## Implementation Notes

<!-- SECTION:NOTES:BEGIN -->
Source checklist (2026-10-01): [x] Native cast order, emergency/retreat, lane/camp, upgrades and dedicated Rubick handler audited. [x] Valve KV and English localization pinned to d2vpkr cf0d37a32c8df338a7832fd32a282747969e9a5f; tests/valve/abilities.json agrees. Hero KV: https://raw.githubusercontent.com/dotabuff/d2vpkr/cf0d37a32c8df338a7832fd32a282747969e9a5f/dota/scripts/npc/heroes/npc_dota_hero_brewmaster.txt . [x] Torte de Lini guide 129109889 read via tools/tdl (7.41f cached snapshot). [x] dotacoach Strategy, Counter Strategy and full Matchup read: https://dotacoach.gg/en/heroes/brewmaster and https://dotacoach.gg/en/heroes/counters/brewmaster .
Current mechanics: Cinder barrel impact is physical and arrives at projectile speed950; magic/pure damage ignites it, so ordinary Clap waits for impact. Clap uses full400 radius and mitigated magical last-hit estimates. Brawler cycles Earth/Storm/Fire, ignores silence, and abilities trigger Brewed Up (Cinder is no longer the exclusive empowerment source). Liquid Courage is a passive hidden innate until its live Shard unit-target variant; current drink heals3% maxHP/s and gives movement/status resistance for5s. Split has three spirits, Earth→Storm→Fire rebirth, aura-carrying Earth, cast point0.55 and150/200/250 mana. Current Scepter adds a brewling ability level, health/damage, Brewed Up and early cancel; it does not grant active Primal Companion.
Guide reconciliation: retained Cinder→Clap/Urn ignition, early protective Split before silence/lockdown, defensive Earth/mobility Storm/attack Fire, Cyclone secondary target twice, useful Storm basic dispels and Earth aura survival. Rejected old Drunken Haze, fourth Void spirit/Astral Pull, Companion Scepter, Shard extra Split duration and Cinder-only Brawler empowerment; excluded old enemy Solar Crest/Arcane Boots disassembly advice. Dotacoach four-spirit heading conflicts with current three-spirit definitions. Exact obsolete Silencer/CK reveal/Venomancer purge claims were not implemented.
Matchup follow-through: Puck coil or Shaman control helps hold enemies for spirits; TA focused kills and Ember/Lich/Venomancer magic damage can ignite Cinder. Counter advice motivates preemptive Split before silence, saving Earth while threatened, not wasting Cyclone/Boulder on immunity or reflection, and useful illusion dispels. Item observations routed to TASK21/24: Urn/Vessel after barrel impact, active Pipe/Crimson before Split with enough remaining mana, Earth aura carrier, Refresher enough mana for another Split, and BKB/Lotus/Manta against pre-Split lockdown. Generic items and role differentiation remain separate.
Implementation: removed inactive Companion branch/wrong Split dispatch and undefined Liquid ally list/location cast. Solo low-HP Split and outnumbered escape precede ordinary spells; nearby-threat mana reserves preserve ready Split. Native and stolen Clap/Cinder share legal bounded placement, travel prediction, real clustered camps and current damage checks; Rubick now recognizes standalone stolen Split. Shard drink selects injured pressured ally/self with entity dispatch. Stance actions return immediately, preserve channels/queues, can cycle while silenced, and read observed stance modifiers with tracked fallback.

Lobby checklist (standard stage; no game run): solo low-HP/outnumbered Split; silence/hex before0.55s Split windup; mana near Split+Cinder/Clap thresholds; Cinder edge travel and magic/pure ignition with lane ally or Urn; moving target leaving radius; mitigated ranged-creep last hits; Earth/Storm/Fire observed stance synchronization and silenced cycling; live Shard behavior changes, self/ally entity targeting and5s healing; Scepter three-spirit ability levels/Brewed Up, cancellation activation/selected rebirth semantics; Storm second-threat Cyclone/interrupt/repeated use, basic friendly/enemy dispels and illusion damage; low-HP Earth preservation and Storm invisible retreat; spirit targets >1600 from original body; stolen standalone Split and summon ownership. Validate current cast-range bonuses (whether live GetCastRange includes any bonus) and prediction under real server timing. Automatic early cancel remains deferred until those engine semantics are validated. Brewmaster stays weak-hero/m-0 and on WeakHeroes; video/Liquipedia/fixed-roster deep dive is separate.
Meaningful offline scenarios: tests/brewmaster_ability_spec.lua covers solo/stolen Split priority, threat mana reservation, full-radius/lethal Clap, barrel-impact delay, bounded moving-target Cinder prediction, separated farm camps, mitigated last hits, passive-vs-live-Shard behavior, ally/self cast shape, silenced stance sync and channel safety. tests/brewmaster_split_spec.lua covers current spirit spell targeting, interrupts, basic dispel purpose, safe retreat, invalid attack targets and absent legacy Void ability. Both focused success markers passed; full suite verification pending final integration.

Final review additionally repaired native/copy cast-range Break checks using J.HasBreakModifier and bot-compatible HasModifier, replacing unsupported server-only PassivesDisabled. The small shared break_state.lua covers the seven passives-disabled effects confirmed in pinned localization (generic Break, Silver Edge, PA Fan of Knives, Viper Strike, Nyx Vendetta, Hoodwink Sharpshooter, Angels Demise); conditional upgrades reusing other debuffs need later coverage. Regression distinguishes victim Break from caster invisibility/silence and fails on unsupported bot methods. The same API repair was applied to earlier Abaddon/Alchemist and current Axe/Bane/Batrider/Beastmaster range helpers.
Split implementation review: current Earth/Storm/Fire slots verified against pinned npc_units; early Scepter cancellation is deliberately deferred until engine return semantics are tested. Storm interrupts before ordinary control, uses verified basic-dispel effects/illusions instead of real hero counts, preserves Wind Walk fade/escape, and avoids focused target for second-threat Cyclone. Earth interrupts then prioritizes low-health survival before ordinary Boulder. Spell-block/reflection/immunity/legal reach guards and invalid/friendly target rejection apply; spirits can pursue beyond original body location.

Final integrated verification: node tests/run-builds.cjs passed (exit 0): Lua syntax336 files; Valve128 hero files/21 Rubick copies, zero allowlist findings;127 heroes/253 migrated roles;85 specialized Rubick spell dispatches;58 Rubick hero cases;272 purchase lists; all new hero, Split and Break scenarios. git diff --check passed. Sources and lobby checklist recorded; no game run.
<!-- SECTION:NOTES:END -->

## Final Summary

<!-- SECTION:FINAL_SUMMARY:BEGIN -->
Brewmaster standard pass: urgent/solo Split, barrel→Clap timing, legal camps/last hits, silenced stance cycling, current Shard drink, standalone stolen Split and three-spirit control. Full offline suite passed. Ready for lobby; weak flag retained and automatic Scepter cancellation pending engine validation.
<!-- SECTION:FINAL_SUMMARY:END -->
