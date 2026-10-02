---
id: TASK-13.17
title: 'Centaur: standard hero ability pass'
status: Needs In-Game Test
assignee:
  - '@codex'
created_date: '2026-10-01 15:24'
updated_date: '2026-10-01 15:54'
labels:
  - hero
dependencies: []
references:
  - bots/BotLib/hero_centaur.lua
  - bots/FunLib/rubick_hero/centaur.lua
documentation:
  - backlog/docs/doc-2 - Hero-improvement-playbook.md
parent_task_id: TASK-13
priority: medium
ordinal: 57000
---

## Description

<!-- SECTION:DESCRIPTION:BEGIN -->
Centaur is in the next standard-pass batch after Axe/Bane/Batrider/Beastmaster/Brewmaster. Review current spell decisions and combos against guide strategy and pinned Valve mechanics, including the dedicated Rubick copy. Scope is ability gameplay; existing D2PT builds, separate TASK14 build findings and future role differentiation remain separate.
<!-- SECTION:DESCRIPTION:END -->

## Acceptance Criteria
<!-- AC:BEGIN -->
- [x] #1 Spell decisions and cast order are reviewed against pinned Valve definitions/localization, Torte de Lini tips and dotacoach Strategy, Counter Strategy and full Matchup advice; source checklist and stale claims are recorded
- [x] #2 Identified ability-use gaps are fixed in the native hero and applicable Rubick copy, with meaningful offline behavior scenarios and preserved D2PT builds
- [x] #3 Hero regression spec, Valve check and shared build suite pass; lobby scenarios are recorded and the standard pass is ready for in-game testing
<!-- AC:END -->

## Implementation Plan

<!-- SECTION:PLAN:BEGIN -->
1. Reconcile current Hoof Stomp windup, strength-based magical Double Edge/self damage, global Stampede and linked Scepter cart against pinned Valve/localization, TDL128735861 and full dotacoach strategy/matchups; retain builds and reject stale Rawhide/facet advice.
2. Prioritize legal direct Stomp/interrupts and safe budgeted Blink→Stomp; predict windup reach and support moving during windup. Add mitigated Double Edge health budget, meaningful lane/camp AoE and complete entity dispatch.
3. Scan all allies for global Stampede saves/chases without wasting on immobilized/Ruptured targets. Use Work Horse for self mobility or opening a nearby ally save, reserve both cart spells, and target only safe valid allies with live linked ability.
4. Mirror current decisions in Rubick, test standalone stolen spells and meaningful native/copy scenarios, then run Valve/full suite and document lobby limitations.
<!-- SECTION:PLAN:END -->

## Implementation Notes

<!-- SECTION:NOTES:BEGIN -->
Source checklist (2026-10-01): pinned Valve hero KV and English localization at cf0d37a32c8df338a7832fd32a282747969e9a5f, matching tests/valve/abilities.json: https://github.com/dotabuff/d2vpkr/blob/cf0d37a32c8df338a7832fd32a282747969e9a5f/dota/scripts/npc/heroes/npc_dota_hero_centaur.txt . Current active slots are Stomp, Edge, Work Horse, Mount and Stampede; Retaliate/Horsepower are passive. Stomp has 325 radius and 0.5-second movable/disarmed windup. Edge has actual 175 cast reach, 220 splash, base plus current Strength percentage magical damage and nonlethal magical self damage. Stampede is global mobility, not an escape from roots/Rupture. Scepter Work Horse opens linked 200-range Mount; reserve both 75-mana spells for an ally save.
TDL Workshop 128735861, offlane / 7.41f, fetched with node tools/tdl/fetch.cjs centaur. Reviewed every ability/item tip. Applied Blink/Stomp before Edge, meaningful lane/camp splash, global chase/save, mitigated self cost, cart saves and allied follow-up. Excluded obsolete talent/build advice, Hood/Arcane Boots disassembly and unproven assumption that the first Shard strength stack is applied before its triggering Edge damage. Builds remain untouched.
dotacoach https://dotacoach.gg/en/heroes/centaur-warrunner Strategy and Counter Strategy, and https://dotacoach.gg/en/heroes/counters/centaur-warrunner complete Matchup including synergy/core/counter items were reviewed. Global saves and allied control support initiation; frontliners and ranged allies benefit from cart protection. Counterplay emphasizes spacing, denying Blink and movement, armor versus attacks, and healing suppression. Excluded obsolete Rawhide, Oracle Rain of Destiny and unsupported Shiva amplification wording; current Valve mechanics take precedence over stale public tips. Item timing and enemy policy are routed to TASK21/24.

Implementation: native/copy use real Stomp radius and full windup prediction, prioritize direct interrupts, and queue safe reachable Blink -> Stomp only with both spell/item mana and adequate allied presence. Observed windup movement follows the target even after Stomp enters cooldown, preserves interrupt/lethal focus while retreating, and holds instead of overwriting queued/channelled/immobilized actions. Rubick has a narrow pending-Stomp hook before normal ready/using guards; real channels remain protected. Edge uses current Strength, actual magical mitigation, nonlethal self cost and sensible remaining-health floors; legal creep/illusion primaries can finish heroes with splash, and lane/camp/objective actions dispatch the complete entity. Reflection, block, immunity and current Counterspell are guarded. Stampede scans all allies for remote pursued saves and useful core chases, skipping rooted/Ruptured/already-buffed units. Work Horse opens a nearby cart save only with linked Mount and its mana/cooldown available; Mount targets a real threatened ally, including rooted/channelled allies, while checking caster survival and excluding invalid passengers. Stolen standalone Stomp works without other Centaur abilities. Five D2PT build/skill/talent prefixes match HEAD unchanged.
Focused evidence: tests/centaur_ability_spec.lua passes exact marker Centaur ability scenarios passed. Native/copy cases exercise windup prediction/movement/interrupt priority, Blink reach/mana/roots/Rupture/hazards/solo-1v2, mitigated nonlethal Edge/Strength/splash/range/reflection, remote mobility saves and linked cart budgets/200-range passengers. Shared Rubick spec passes 59 cases including pending Stomp before cooldown/using guards; stolen dispatcher and 85 specialized dispatch cases pass. Final full-suite results will be appended after completion.

Lobby checklist (pending; no game launched): Centaur/Rubick plus Abaddon/Grimstroke/ranged carry versus mobile enemy/Anti-Mage/root/illusion hero. Confirm moving Stomp windup remains active after action movement and all queued Blink variants land within actual radius; interrupted/channelled casts must survive. Verify Edge mitigation, nonlethal self damage, first Shard strength stack timing and hero splash via creep. Test global far-away ally saves/chases with roots/Rupture/BKB and current Stampede movement restrictions. Verify Scepter Work Horse dynamically activates Mount, live cooldown/mana/200 range and cart passenger casting/attacking/channel persistence/break distance. Native/stolen upgrade linkage, engine-reported Lens/Supremacy range bonuses and Stampede upgrade details require lobby observation before claiming parity. No generic item/minion/draft changes; role differentiation remains TASK37.

Integration review also added explicit Counterspell Ally protection to native and stolen Double Edge; both focused safety scenarios pass. Updated the existing Underlord dispatcher fixture for the new pending-Stomp handler. No production Underlord behavior changed.

Shared-helper review found CanCastOnNonMagicImmune intentionally rejects suspicious illusions, contrary to the dedicated Edge AoE scenario. Added a local damage-eligibility check retaining visibility, invulnerability, immunity and forbidden-effect guards while allowing deliberate illusion primaries/hits. Strengthened the mock to reproduce the shared illusion exclusion; the native/copy AoE scenario now passes with faithful helper behavior.

Final integrated verification (2026-10-01): node tests/run-builds.cjs exited 0 with all five new hero success markers and prior regressions. Lua syntax: 341 files; pinned Valve check: 128 native hero files / 21 Rubick copies / 0 allowlisted findings; builds: 127 heroes / 253 roles; specialized Rubick: 85 dispatches; Rubick hero behavior: 59 cases; purchase planning: 272 buy lists. git diff --check passed. Scripted HEAD comparison confirms all five build/skill/talent prefixes unchanged. Lobby scenarios remain pending; no game launched. Standard pass is ready for in-game testing, with documented engine/capability limits.
<!-- SECTION:NOTES:END -->

## Final Summary

<!-- SECTION:FINAL_SUMMARY:BEGIN -->
Updated native/stolen Centaur safe Blink/Stomp and movable windup, strength/mitigation/nonlethal Edge with legal splash primaries, global Stampede saves/chases and budgeted linked cart saves. Added Rubick pending-windup hook and faithful regressions. Full suite/Valve/diff checks pass; lobby upgrade/windup validation pending.
<!-- SECTION:FINAL_SUMMARY:END -->
