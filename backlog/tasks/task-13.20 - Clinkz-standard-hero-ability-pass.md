---
id: TASK-13.20
title: 'Clinkz: standard hero ability pass'
status: Needs In-Game Test
assignee:
  - '@codex'
created_date: '2026-10-01 16:04'
updated_date: '2026-10-01 16:37'
labels:
  - hero
dependencies: []
references:
  - bots/BotLib/hero_clinkz.lua
  - bots/FunLib/rubick_hero/clinkz.lua
documentation:
  - backlog/docs/doc-2 - Hero-improvement-playbook.md
parent_task_id: TASK-13
priority: medium
ordinal: 60000
---

## Description

<!-- SECTION:DESCRIPTION:BEGIN -->
Clinkz is in the next standard-pass batch after Bloodseeker/Bounty Hunter/Bristleback/Broodmother/Centaur. Review current ability decisions and combos against guide strategy and authoritative mechanics, including applicable Rubick handling. Existing D2PT builds and future role differentiation remain separate.
<!-- SECTION:DESCRIPTION:END -->

## Acceptance Criteria
<!-- AC:BEGIN -->
- [x] #1 Spell decisions and cast order are reviewed against pinned Valve definitions/localization, Torte de Lini tips and dotacoach Strategy, Counter Strategy and full Matchup advice; source checklist and stale claims are recorded
- [x] #2 Identified ability-use gaps are fixed in the native hero and applicable Rubick copy, with meaningful offline behavior scenarios and preserved D2PT builds
- [x] #3 Hero regression spec, Valve check and shared build suite pass; lobby scenarios and capability limits are recorded and the standard pass is ready for in-game testing
<!-- AC:END -->

## Implementation Plan

<!-- SECTION:PLAN:BEGIN -->
1. Audit current pinned Valve KV/localization, TDL129056935 /7.41f and full dotacoach Strategy/Counter/Matchup; distinguish active Arrows/Walk/Pact from obsolete Tar Bomb/facets and unsafe vector Army casts.
2. Preserve build prefix; improve Death Pact eligible enemy-creep/owned-skeleton healing and charge reservation, Strafe extended-range/control follow-up and invis setup, physical immunity-piercing Arrows harass/last hits/objectives/autocast mana, directional Barrage geometry/bonus attack reach, emergency Walk and verified IGNORE_CHANNEL Barrage cloak. Mirror applicable stolen spells and coordinate shared cloak hook with root.
3. Add faithful native/copy scenarios for legal targets, owned summons, mana/charges/buffs, attack range versus cast bonuses, projectile-line geometry and channel preservation; parse/Valve/focused marker/whitespace and source/lobby notes for parent integration.
<!-- SECTION:PLAN:END -->

## Implementation Notes

<!-- SECTION:NOTES:BEGIN -->
Source checklist (2026-10-01): Valve KV https://raw.githubusercontent.com/dotabuff/d2vpkr/cf0d37a32c8df338a7832fd32a282747969e9a5f/dota/scripts/npc/heroes/npc_dota_hero_clinkz.txt , pinned English localization /tmp/dazzle-abilities-english.txt and tests/valve/abilities.json, all cf0d37a32c8df338a7832fd32a282747969e9a5f. TDL Workshop129056935 Position1 /7.41f fetched and complete ability/item tips reviewed. Applied attack-orb lane usage, invis-preserving Strafe setup, Death Pact sustain, attack-range Barrage and verified IGNORE_CHANNEL Skeleton Walk during Barrage. Rejected stale Tar Bomb combo/Phylactery advice, old Death Pact skeleton spawning/teleport facet, and Solar Crest enemy amplification claims. Army vector direction is current, but a correct bot two-point cast API remains unverified.
Dotacoach https://dotacoach.gg/en/heroes/clinkz complete Strategy/Counter reviewed: manual lane harassment, Death Pact charge held for combat, stealth approach, physical burst and Barrage with Arrows enabled. Detection/armor recommendations route to counterplay. https://dotacoach.gg/en/heroes/counters/clinkz full Matchup gameplay allies/enemies/core/counter items reviewed: control from Disruptor/Mars/Ogre/Axe/Puck/Storm and global pressure setups provide attack windows; Desolator/Daedalus/BKB/Pike and on-hit Barrage are relevant context. Excluded misleading natural channel-interrupt/Desolator silence claims, blanket Echo Stomp dodge and stale Tar Bomb references; spell immunity does not prevent current physical Arrows/Barrage. The hero can exploit enemy eligible summons via Pact. No draft, generic item or minion changes. Build/skill/talent prefix preserved.

Implementation: native and stolen copies use current Searing Arrows rather than retired Tar Bomb. Physical/manual lane harass and mitigation-aware extra-damage last hits, true attack reach, immunity piercing, tower/boss autocast and low-mana shutdown replace missing lane behavior and undefined boss attacking variable. Strafe now precedes zero-CD orbs, activates at its extended reach, follows controlled targets, prepares expanded Barrage reach and supports owned fighting skeletons while hidden/disarmed. Pact chooses eligible enemy creeps (including summons), excludes ancient/high-level/allied/protected/blocked/reflected targets and can emergency-heal from this player skeletons; current buff no longer forbids needed healing. Healthy preparation preserves mana and final spare charges are held during farming.
Barrage uses its850 length plus current bonus attack range rather than GetCastRange movement allowance; predicted directional corridor requires aligned targets rather than arbitrary AoE center. Arrows are enabled before Barrage when full-wave mana plus escape reserve is available. Native and copy expose UseBarrageInvisibility: observed active Barrage channel plus live immediate Walk, alive/notdisabled/noqueue/noexistinginvis, returns true only on actual cloak action; root coordinates shared Rubick early hooks. Other channels remain intact. Walk escape still benefits from movement under detection and closer gank approach is supported.
Capability limits: Burning Army is vector-targeted; native invalid point cast and mistaken Barrage readiness check removed. Dedicated Army and retired Tar Bomb remain recognized skips in Rubick. A verified two-endpoint API is required before claiming automated Scepter Army coverage. Generic archer positioning, detection-route avoidance and item initiation remain separate. Barrage base attack-range reference is600 for Clinkz and550 for Rubick; live range confirmation remains a lobby check.

Offline verification: tests/clinkz_ability_spec.lua emits Clinkz ability scenarios passed for both native and dedicated Rubick decisions, legal/mana/charge/buff/ownership/protection guards, immunity attack windows, exact attack-vs-cast reach, mitigation-aware lane finish, aligned/spread Barrage geometry, Skeleton Walk channel exceptions and native escape/heal/Strafe priorities. Lua5.1 parse for hero/copy/spec and focused git diff --check passed. Current Valve checker passed128hero files /22Rubick copies /0allowlisted findings. Parent owns full-suite integration and final AC/status.
Lobby checklist: (1) Manual lane Arrows without creep aggro, autocast on targets/structures/bosses and mana shutdown; immunity-piercing attack and controlled enemy follow-up. (2) Strafe before first orb and Barrage, verify effective reach with range items/talent and owned skeleton buff1200aura. (3) Pact enemy ranged/siege/neutral/summoned creatures at current level cap, ancient rejection, active-buff emergency heal and owned skeleton consumption while invisible; final charge held when farming. (4) Barrage aligned/spread waves, moving targets, physical on-hit/Searing modifiers, true projectile width and850plus attack-range bonuses; validate native600/Rubick550base assumption and live GetCastRange Lens/Supremacy behavior. (5) Immediate Skeleton Walk during Barrage without breaking channel, disabled/queued/other-channel refusal, detected retreat movement. (6) Army vector endpoint API remains unverified: retain explicit Scepter limit rather than pointcast.
Parent follow-up candidates: TASK21 BKB before sustained attacks/Barrage; Orchid/Hex setup and Nullifier against Ghost/defensive dispels; Pike after close invis approach to gain attack spacing; on-hit items synergize with Barrage/archers. TASK24 detection on multiple allies and farm routes, armor/attack-immunity/Blade Mail defenses, punish expired Pact/forward positioning, move laterally out of Barrage. No generic item/minion/draft changes made.

Additional range evidence: pinned Rubick KV https://raw.githubusercontent.com/dotabuff/d2vpkr/cf0d37a32c8df338a7832fd32a282747969e9a5f/dota/scripts/npc/heroes/npc_dota_hero_rubick.txt confirms AttackRange550; Clinkz KV confirms600. The base-range references are verified data; lobby checks concern actual bonus application and projectile geometry.

Final integrated verification (2026-10-01): node tests/run-builds.cjs exited 0 after all review repairs; exact markers confirmed for all five new hero specs, 348 Lua files parsed, Valve check 128 native heroes / 22 Rubick copies / 0 allowlisted findings, 127 hero role tables, 90 specialized dispatches, 61 Rubick behavior cases and 272 purchase lists. git diff --check passed. HEAD comparison confirms this hero build/skill/talent prefix unchanged. No lobby launched; standard pass handed off as Needs In-Game Test, with capability limits above. Item/counterplay findings appended to TASK21/24.
<!-- SECTION:NOTES:END -->

## Final Summary

<!-- SECTION:FINAL_SUMMARY:BEGIN -->
Clinkz native and Rubick decisions now use current Searing Arrows, useful Pact/Strafe, real Barrage geometry and mana reserves, and a narrowly observed Barrage-to-Walk channel exception. Builds preserved. Focused scenarios, final shared suite and Valve check passed. Burning Army vector endpoints remain unverified and are explicitly withheld pending engine/API validation.
<!-- SECTION:FINAL_SUMMARY:END -->
