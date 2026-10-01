---
id: TASK-21
title: 'Improve support and team item usage: targets and timing'
status: To Do
assignee: []
created_date: '2026-09-29 22:03'
updated_date: '2026-10-01 14:47'
labels:
  - teamfight
dependencies: []
references:
  - bots/ability_item_usage_generic.lua
  - tools/tdl/fetch.cjs
priority: medium
ordinal: 21000
---

## Description

<!-- SECTION:DESCRIPTION:BEGIN -->
Every common support and team item already has a handler in ability_item_usage_generic.lua (X.ConsiderItemDesire[item]), but they are simple threshold rules: fixed HP cut-offs, the first ally found in range, self before allies, little sense of fight timing. Humans get most of these items' value from choosing the right target and moment, such as a save at the moment the burst lands, or a heal at the end of a fight. Complements TASK-11, which covers the same questions for spells.
<!-- SECTION:DESCRIPTION:END -->

## Acceptance Criteria
<!-- AC:BEGIN -->
- [ ] #1 Each item group's subtask is done
- [ ] #2 Handlers are audited against how the items are used in human play; the reasoning is written into the subtasks
<!-- AC:END -->

## Implementation Notes

<!-- SECTION:NOTES:BEGIN -->
2026-10-01: Torte de Lini guides carry per-item usage tips for many heroes (when and on whom to use the item). `node tools/tdl/fetch.cjs <hero>` prints them under "Item tips"; `node tools/tdl/fetch.cjs --all` caches every guide for searching across heroes. Reference only: turn the advice into logic, never paste the text. See the playbook (doc-2).

Dazzle standard pass (TASK-13.2): review Grave plus TP escape only when enemy interrupts are unavailable; coordinate healing item decisions with Grave amplification and spell saves, and support positioning with Glimmer/Force/Blink. Torte de Lini guide 128730475 is a reference for when to use these items; validate each item mechanic before implementation. Reject its removed Bad Juju item-cooldown reduction, Arcane Boots disassembly and Poison Touch Shard hex claims. Valve currently places Shard healing on passive Weave; no item-handler changes in this pass.

2026-10-01 standard batch follow-up from TASK-13.3 through TASK-13.7. TDL and full dotacoach Matchup/core-item advice reviewed against each hero's pinned Valve mechanics. Record for existing item-usage work; builds and generic item logic were not changed in these hero passes:
- Abaddon: Locket with Coil healing, Blink to reach urgent saves/escape during Borrowed Time, Crest alongside Shield, and Manta/Phase during Curse pursuit. Do not rely on stale old-Shard Coil attack or Curse silence claims.
- Underlord: Atos/cyclone/Gungir timing can extend control between Pit roots rather than overlap it; mana sustain for wave/jungle rotations and mobility to keep Shard Firestorm on a frontliner. Gate Scepter now supplies destination Pit; it is not a Pit upgrade.
- Alchemist: brew then Blink then Throw; BKB protects brewing/attack uptime; Soul Ring cost can be recovered during Rage; Abyssal follows Throw control. Gifting remains TASK-2, support builds TASK-18, unchanged here.
- Anti-Mage: Blink->Abyssal->Manta->attacks->Mana Void, with Manta reserved for removable roots/silence; Intelligence Treads before Blink. Current Scepter empowers the next Mana Break after Blink; old Fragment/reduced-Blink-cooldown guidance is stale.
- Arc Warden: alternate main/Double Hex to extend control, evaluate Double Midas and Travel cooldowns independently, and place Mjollnir charge on the main/clone/pushing creep appropriate to the fight. Current Scepter affects Flux; Shard buffs Double. Shared item/minion behavior still needs its own review.
Sources are linked in the corresponding hero subtasks, including dotacoach /en/heroes/<slug> and /en/heroes/counters/<slug>.

Standard batch TASK13.8–13.12 item observations (sources/checklists in hero subtasks; no generic-item edits): Axe Blink→Call then Blade Mail/area actives, enough damage to meet Culling threshold; Refresher Call follow-up. Bane Lens positioning, Glimmer around Grip, allied follow-up for Blink, and mana for repeat Grip; Scepter illusion channels deserve engine testing. Batrider reserve BKB/Firefly/Blink/Lasso mana, drag with movement/Force/Bearing, avoid Blink/TP that break Lasso, Shiva after grab, Refresher with second-round budget. Beastmaster Blink→Roar→focused summons/Axes, budget optional BKB, Refresher repeats, controlled-creep/attack-speed auras support passive Drums. Brewmaster Urn/Vessel after barrel arrives to ignite Cinder, pre-Split Pipe/Crimson with Split mana intact, Earth carries auras, Refresher requires another Split budget; protective BKB/Lotus/Manta before silence. Retained stale guide build advice was excluded; no D2PT build changes.
<!-- SECTION:NOTES:END -->
