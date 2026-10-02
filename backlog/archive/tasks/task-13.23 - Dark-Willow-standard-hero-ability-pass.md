---
id: TASK-13.23
title: 'Dark Willow: standard hero ability pass'
status: Needs In-Game Test
assignee:
  - '@codex'
created_date: '2026-10-01 17:04'
updated_date: '2026-10-01 17:28'
labels:
  - hero
  - weak-hero
milestone: m-0
dependencies: []
references:
  - bots/BotLib/hero_dark_willow.lua
  - bots/FunLib/rubick_hero/dark_willow.lua
  - tests/dark_willow_ability_spec.lua
documentation:
  - backlog/docs/doc-2 - Hero-improvement-playbook.md
parent_task_id: TASK-13
priority: medium
ordinal: 63000
---

## Description

<!-- SECTION:DESCRIPTION:BEGIN -->
Dark Willow is in the next standard-pass batch. Review ability decisions and combos against verified mechanics and gameplay advice, including applicable Rubick handling. Builds and role differentiation remain separate.
<!-- SECTION:DESCRIPTION:END -->

## Acceptance Criteria
<!-- AC:BEGIN -->
- [x] #1 Spell decisions and cast order are reviewed against pinned Valve definitions/localization, Torte de Lini tips and dotacoach Strategy, Counter Strategy and full Matchup advice; source checklist and stale claims are recorded
- [x] #2 Identified ability-use gaps are fixed in the native hero and applicable Rubick copy, with meaningful offline behavior scenarios and preserved D2PT builds
- [x] #3 Hero regression spec, Valve check and shared build suite pass; lobby scenarios and capability limits are recorded and the standard pass is ready for in-game testing
<!-- AC:END -->

## Implementation Plan

<!-- SECTION:PLAN:BEGIN -->
1. Reconcile pinned Valve cf0d37a definitions/localization, TDL 1187546268 and both full dotacoach pages. Preserve the complete D2PT/skill/talent prefix and WeakHeroes/buggy flags; distinguish Bramble root from true channel interruption, delayed Crown, current no-target Bedlam and linked ultimate availability.
2. Replace broken decisions with legal predicted point casts, guarded delayed Crown setup, defensive/offensive Shadow Realm and real close-range Bedlam; prioritize defensive Realm and useful Terrorize before committing Jex to Bedlam. Avoid inventing guaranteed maze latch or orbit damage. Mirror all five supported spells in a dedicated Rubick copy; missing linked handles stay safe. Expose a defensive Realm channel helper only with observed channel and verified live IGNORE_CHANNEL behavior; root owns dispatcher integration. Charged attack-mode policy remains a future shared behavior pass.
3. Add native/copy specs with faithful timing/range/mode/reflection/linkage behavior and single-action dispatch. Run focused exact marker, pinned Valve checker, parse and whitespace checks. Record original source exclusions, item/counterplay candidates and fixed-roster lobby/capability checklist via CLI. Root owns shared runner/wiring/full suite and finalization.
<!-- SECTION:PLAN:END -->

## Implementation Notes

<!-- SECTION:NOTES:BEGIN -->
Source checklist (2026-10-01): doc2 standard pass; pinned Valve https://raw.githubusercontent.com/dotabuff/d2vpkr/cf0d37a32c8df338a7832fd32a282747969e9a5f/dota/scripts/npc/heroes/npc_dota_hero_dark_willow.txt (local /tmp/dark-willow-valve.txt), pinned English abilities localization /tmp/dazzle-abilities-english.txt and tests/valve/abilities.json. Bramble is a point maze with 0.3 cast + 0.3 initial growth, eight separate 90-radius latches inside a 500 placement area; it does not interrupt ordinary channels. Crown is a guarded 700-range targeted delayed stun (4 seconds), with Shard spawning brambles even on dispel. Realm is immediate/no-target/IGNORE_CHANNEL, untargetable but still vulnerable to area damage, disjoints projectiles, adds 600 attack range, charges for 3 seconds and has a Scepter attack-persistence upgrade. Bedlam is immediate/no-target, Jex orbits 200 with 300 attack reach, 5.5 duration and talent-adjustable target count; Terrorize is a linked point fear with 1-second cast, 2000 outbound speed, 1200 cast range and current 450/500/550 radius. Localization explicitly excludes Bedlam/Terrorize simultaneous use. Pixie Dust is passive; obsolete facets have no active decision.
TDL Workshop 1187546268, Position4/7.41f, node tools/tdl/fetch.cjs dark_willow: all ability/item tips reviewed. Used route zoning, projectile defense, delayed Crown setup, protected isolated Bedlam, lane farming and allied disengagement. Unverified Bramble Truesight/structure details did not become code. The blanket all-spells-magic item claim omits Crown with zero baseline damage. Item combos stay with TASK21; builds/talents/skill order remain D2PT-only.
dotacoach https://dotacoach.gg/en/heroes/dark-willow Strategy/Counter reviewed: used projectile defense, pickoff setup, timely group control and reduced value of isolated burst around many enemy units. Wisdom/TP/item/regen execution is shared policy. https://dotacoach.gg/en/heroes/counters/dark-willow full Matchup reviewed (all gameplay allies, core items, favorable/adverse heroes, counter items and stats): Mars/Tiny/Kunkka/Puck control and Abaddon protection support follow-up; ranged Realm item synergies and dispel/AoE counters are routed separately. Excluded blanket Io Tether/Relocate disruption, Vacuum/Ion Shell interruption and magic-immunity wording as generic guarantees; no hardcoded matchup/draft edits. Spell immunity and damage follow pinned mechanics rather than prose.
Implementation: the full native build prefix remains byte-identical; weak and Valve-buggy flags retained. Removed zero-range Bedlam checks, undefined allyTarget/ChronodAlly paths, unsafe high-mana Crown branches, multi-action Realm dispatch and arbitrary startup/ultimate timers. Legal Lens/Supremacy point placement predicts travel/growth, clamps centers and validates coverage; Crown consistently checks actual reach, block/reflection/Counterspell+Ally and avoids existing Crown while permitting delayed allied-control follow-up. Defensive Realm precedes other actions; Terrorize uses useful cluster/channel/retreat/any-role ally saves before spending Jex on Bedlam. Bedlam recognizes the orbit footprint and isolated controlled targets, rejects cluttered/exposed offensive commits and clears nearby creep groups in explicit farming modes without enemy heroes. No deterministic maze latch, random orbit damage or instant Fear arrival is asserted. Dedicated Rubick copy handles all five spells without dereferencing absent linked siblings; live IsActivated through J.CanCastAbility and observed Bedlam state gate incompatible linked casts.
Root-owned early hook uses exported UseShadowRealmDuringChannel. The helper requires an observed channel, live Realm handle/readiness and IGNORE_CHANNEL bit, then only immediately casts defensive Realm. Death, silence, stun, hex, nightmare, cast phase and queues remain protected. Native/copy specs explicitly verify TP-compatible immediate actions and missing-flag rejection; no other spell receives a channel exception.
Focused verification: tests/dark_willow_ability_spec.lua prints exact Dark Willow ability scenarios passed. Scenarios cover real Crown range/Lens/Supremacy/Break, blocked/reflected/self+ally Counterspell, delayed control, maze prediction/legal footprint and no false ordinary channel interrupts, offensive Realm reach/disarm, spell and dangerous attack disjoints, close/orbit Bedlam and farming/clutter/low-HP negatives, predicted Fear flight and too-late TP rejection, real/non-immune cluster counting, allied saves, native single-action/setup order, missing linked handles and TP-safe helper flags/status/queues. Lua5.2 parse and git diff --check pass. Pinned Valve audit passes (128 heroes,27 current Rubick copies,0 findings). Parent owns shared suite/status/AC; no in-game or deep dive performed.
Fixed-roster lobby checklist (pending): Willow/Rubick with Mars/Tiny/Kunkka/Abaddon vs Anti-Mage/Juggernaut/Axe/PL/Leshrac/Io. (1) Inspect the actual eight-bramble layout and order; test moving/fleeing targets, edge-center placement, terrain/chokepoints and existing roots. Placement coverage is zoning, not a full circular guaranteed latch. (2) Crown at 700 plus Lens/Supremacy, current Counterspell+Ally/block/reflect, four-second expiry with allied control and Shard dispel spawns. (3) Realm targeted spell/ranged attack disjoints, untargetability vs Leshrac/Axe area damage, Scepter behavior and defensive casts during TP. Channel safety is pinned behavior evidence plus offline dispatch; verify engine outcome. (4) Observe charged attacks: current shared attack modes can release Realm before maximum charge. This pass prepares the spell but does not claim three-second attack timing or ranged last-hit automation. Charged attack hold/release/retreat/Scepter behavior is a future attack-policy pass. (5) Bedlam close/outer orbit against isolated enemy vs enemy creep clutter, duration/target-count talent, explicit farm clear, engine linked activation while Jex travels and stolen linked spell availability. (6) Fear cast/flight/return behavior and modifier, single channel interruption before completion, moving cluster prediction, TP deadlines, all-role ally saves and mutual Bedlam exclusion. Long-range prediction is an estimate, not guaranteed hit detection.
Follow-ups: TASK21 Crown->Eul/Atos->Realm->Bedlam setup, Blink gap close/escape during Realm, contextual Force/Glimmer/Hex/Bearing and Scepter attack support; TASK24 Crown isolation/dispels with Shard bramble awareness, army/illusion sharing Bedlam, avoiding maze routes and respecting untargetable Realm vs area damage. Shared attack timing, Wisdom steals and vision-aware movement remain outside the standard spell pass.

Final review: Bedlam farming counts distinct unit handles across overlapping nearby-creep and neutral lists. Added native/copy two-unit overlap negative and three-distinct-neutral positive; exact Dark Willow ability scenarios passed marker remains confirmed.

Final verification after all review repairs (2026-10-01): node tests/run-builds.cjs exited0; all five hero spec exact markers verified, 358 Lua files parsed, pinned Valve audit128 native heroes/27 Rubick copies/0 findings, 127 role tables, 112 specialized dispatches,64 Rubick behavior cases and272 purchase lists. git diff --check passed. All five original build/skill/talent prefixes remain byte-identical to HEAD. New handlers and early hooks are integrated; existing prior-batch scenarios still pass. TASK21/24 observations recorded. No lobby launched; standard pass handed off as Needs In-Game Test with capability limits above.
<!-- SECTION:NOTES:END -->

## Final Summary

<!-- SECTION:FINAL_SUMMARY:BEGIN -->
Dark Willow native and dedicated Rubick logic now uses defensive Realm, legal delayed Crown, predicted Maze/Fear and useful close Bedlam, with a verified live channel-safe Realm exception. Builds and weak/buggy flags retained. Hero scenarios, final full suite and Valve check pass. Lobby and charged-attack-policy limits are recorded.
<!-- SECTION:FINAL_SUMMARY:END -->
