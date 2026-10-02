---
id: TASK-21
title: 'Improve support and team item usage: targets and timing'
status: To Do
assignee: []
created_date: '2026-09-29 22:03'
updated_date: '2026-10-02 16:49'
labels:
  - teamfight
dependencies: []
references:
  - bots/ability_item_usage_generic.lua
  - tools/tdl/fetch.cjs
documentation:
  - docs/HERO_PASS_TRACKER.md
  - docs/HERO_PASS_REPORT.md
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

Standard batch TASK13.13–13.17 item observations (source checklists in hero subtasks; no generic-item changes): Bloodseeker needs BKB for committed attacks, Mjollnir on the active frontliner and TP interruption/ritual setup from Abyssal or Atos; Refresher requires repeat-cast mana. Bounty Hunter benefits from Bearing pursuit/escape, detection-aware Shadow positioning and Scythe/Eul control; dispel Dust only when the item and remaining detection area permit it. Bristleback needs mana for Quill after Goo, controlled targets before Scepter self-slow, contextual Lotus/BKB against specific debuffs and armor/healing support. Broodmother needs BKB before Hunger attacks, swarm protection from Pipe/Greaves and Orchid/Bloodthorn focus. Centaur combines Blink->Stomp with optional BKB and Edge/Pipe mitigation, Force positioning, team auras and protected ranged passengers. Validate current item mechanics and preserve spell mana when implementing TASK21; excluded obsolete guide item claims remain listed in each subtask.

Standard batch TASK13.18–13.22 item observations (source audits in subtasks; candidates for existing item work): Chaos Knight Blink/Bolt/Rift timing, Armlet before Phantasm snapshots, protected BKB attack uptime and Bloodthorn focus. Chen contextual Mekansm/Greaves/Locket with global healing and Pipe/Vladmir/Drums/Solar army sustain; protect Scepter channels with correctly timed BKB. Clinkz BKB before attack/Barrage commitment, Orchid/Hex/Nullifier focus and Pike positioning; on-hit actives must preserve escape mana. Crystal Maiden Glimmer/BKB/Bearing protection and safe Force timing around Freezing Field; Nova vision can support dewarding. Dark Seer aura sustain, Blink initiation and Shiva/disable timing around a verified Vacuum/Wall setup; vector Wall remains unverified. Validate current item mechanics before generic policy changes; builds and role differentiation unchanged.

Standard batch TASK13.23–13.27 item observations (sources/stale exclusions in hero subtasks): Dark Willow Crown/Eul/Atos setup, Blink and protection during Realm, Force/Glimmer/Hex/Bearing and Scepter attack support. Dawnbreaker BKB before exposed Solar Guardian channels, mana for global response, Phase/Harpoon pursuit and protection during physical Starbreaker. Death Prophet Phase to maintain ghosts/links, self-Euls while linked, BKB before entering disables, Blink after Exorcism startup and Shiva/Hex follow-up. Disruptor protected Blink/Storm initiation before enemy immunity, Atos/Euls before Field formation, safe Glimmer/Force and Refresher full second-combo budgets. Doom Blink/Phase/Bearing/BKB pursuit and Refresher mana for two sets of spells, with acquired neutral control; current Shard improves Devour, not Earth. These are inputs to existing item-policy work, not build changes or new generic-item implementation.

Elder Titan standard pass (TASK-13.32), checked against pinned Valve/localization, TDL143016376 and full dotacoach: movement actives Phase/Drums/Bearing before Spirit for useful movement/buff synergies; Echo Sabre/Harpoon after observed Spirit return; defensive BKB around channel risk or after returned Scepter immunity expires, rather than assuming permanent immunity; Meteor Hammer setup must use actual remaining sleep against its own full timing. These are item-policy inputs only; no shared item or build changes in this pass. Discard enemy Solar Crest and claims that Nullifier disables Natural Order.

Dragon Knight/Drow Ranger/Earth Spirit standard-pass item inputs (TASK-13.28–30), checked against pinned Valve/localization, TDL and full dotacoach. DK: Blink positioning before Form/Tail/Fire/Fireball, Soul Ring under observed innate regen, safe Armlet/MoM/BKB sequencing. Drow: MoM without denying needed Gust/channel, Hurricane Pike unlimited-range manual-orb follow-up, Gust-to-TP escape and BKB/Manta/Satanic windows; current ability handler conservatively uses actual attack range. Earth Spirit: Urn/Vessel, Blink positioning before real Enchant, BKB before vulnerable combos, Force rescue, Euls dispel/setup, Treads mana, Shiva and Glimmer. Item-policy inputs only, no generic item/build/draft changes.

Earthshaker standard pass (TASK-13.31) item-policy inputs: prebuff Totem before Blink approach, BKB before exposing caster to disables, Euls setup and cast-speed alignment, Force reposition after combo, Refresher only with complete second-combo mana. Source audit covers pinned Valve/localization, TDL129137630 and full dotacoach. These are recorded inputs; shared item policy and builds unchanged.

2026-10-02 Ember Spirit → Pugna standard batch, 49 heroes in hero-file order; Invoker and Lone Druid excluded. Reviewed source and mechanics details are recorded in the linked TASK-13 subtasks. Observations for this existing follow-up; no generic item implementation was added by this batch.

Ember Spirit (TASK-13.33):
- TASK-21: Phase Boots before Remnant improves initial speed; BKB/dispel tools preserve escape availability; Mage Slayer attack debuff spreads via Sleight; Shiva follows actor during attacks; do not infer old Veil active or outdated build requirements.

Enchantress (TASK-13.38):
- TASK-21: Pike separation plus temporary unrestricted attacks makes Impetus useful; Drums/Bearing benefits controlled army; current Solar Crest is ally support, not guide enemy punishment.

Enigma (TASK-13.42):
- TASK-21: BKB before Blink/Black Hole; Refresher requires mana for two ultimates plus reset. Drums/Bearing assist Eidolon army; Soul Ring health cost must fit Summoning health budget.

Faceless Void (TASK-13.45):
- TASK-21: BKB protects aggressive Walk and Chronosphere. Silence from Mask of Madness should follow chosen spells. Manta can dispel Dilation and slows; Refresher requires enough mana for both Chronospheres.

Natures Prophet (TASK-13.46):
- TASK-21: Orchid and Sprout follow actual arrival. Mjollnir can shield a durable ally, while Treant auras and Drums support pushes. Shadow Blade may preserve invisibility during Teleportation; the current Solar Crest is not an enemy-target active.

Grimstroke (TASK-13.47):
- TASK-21: Soulbind should precede useful targeted Hex/Portrait and similar unit spells; preserve range safety and avoid exhausting required spell mana. Shard dispel currently works without speculative blink setup.
- TASK-21: Lens actual cast_range_bonus is read from active inventory; copied Supremacy contributes only while not broken.

Gyrocopter (TASK-13.48):
- TASK-21: BKB/Satanic support actual primary attack uptime; offensive Flak cannot be justified by Side Gunner while disarmed.
- TASK-21: Force Staff on Homing Missile is a useful engine interaction for dedicated item work, not an assumed instant stun.

Hoodwink (TASK-13.49):
- TASK-21: Hex/Atos setups can prepare a real tree trap and safe charged shot; Euls interaction while winding up requires engine verification.
- TASK-21: Acorn attack modifiers and Lens ranges are respected, but tree point trades away initial bounce damage.

Huskar (TASK-13.50):
- TASK-21: preserve current Armlet/BKB/Satanic health and attack uptime policy; Pike needs observed buff before repeated attacks.
- TASK-21: current Shard dispel changes health immediately and heals after 3 s; do not treat it as instant emergency heal.

Jakiro (TASK-13.51):
- TASK-21: Euls/Atos can set actual delayed Ice Path; do not enqueue premature ground prediction before observation.
- TASK-21: Shard removes shared Liquid cooldown and mana via live values; Scepter changes Macro damage/immunity rather than merely adding cosmetic walls.

Juggernaut (TASK-13.52):
- TASK-21: Swift Blink improves actual Slash attack throughput; direct spell logic waits for item policy instead of unobserved queued blink.
- TASK-21: spin TP still needs immunity-piercing interrupt awareness; no unconditional safe TP claim.

Keeper Of The Light (TASK-13.53):
- TASK-21: Holy Locket supports current Spirit Illuminate healing; Shard adds heal and charges, Scepter supplies noninterrupting Wisp grouping.
- TASK-21: Chakra reduces basic ability cooldowns, not item or ultimate cooldowns; Lens plus active Form range read from actual source values.

Kez (TASK-13.54):
- TASK-21: retain selected builds; current ability handles now passed to queued preparation for Echo/Raptor/Toss. Direct emergency parry/Veil/Claw avoids preparation displacing the action.
- Desolator/Daedalus benefit physical attacks/Echo; Raptor pure damage has no attack factor. Scepter combos now depend on observed readiness, not guessed delays. BKB and Nullifier need item policy/lobby validation.

Kunkka (TASK-13.55):
- TASK-21: builds untouched; ordinary native spells pass actual handles into item-aware queued preparation. Observed mark combo casts directly so item prep cannot shift recorded timing.
- BKB interruption protection, Blink/Shadow Blade initiation, Armlet Tidebringer damage and Refresher mana are follow-up item-policy observations. X-fountain-TP routines need coordinated existing TP/item travel policy rather than an unverified ability-only queue.
- Scepter current fleet/cannon upgrade is recognized as engine behavior; no multiplicative guaranteed damage assumption.

Largo (TASK-13.56):
- TASK21: Shard Encore repeats actual eligible item/ability buffs on Largo; Lotus and Glimmer have valid support synergy. Holy Locket and Greaves improve healing. Scepter permits two tunes and actual Bullbelly double-strum damage.

Legion Commander (TASK-13.57):
- TASK-21: BKB/Blade Mail before Duel; Blink/Shadow Blade catch, Nullifier dispellable saves and Linkens breaking only with current item mechanics; Silver Edge attack before Duel if relevant passives; no build changes.

Leshrac (TASK-13.34):
- TASK21: Blink and Eul can set up delayed Split Earth. BKB protects sustained damage, while Shiva and Force Staff help control positioning. Verify the current Bloodstone active separately.

Lich (TASK-13.36):
- TASK21: Glimmer, Force Staff and Solar Crest can complement Shield. Refresher requires mana for two Chain Frost casts. Blink can enter Gaze range safely, and Scepter allows items during Gaze.

Lifestealer (TASK-13.39):
- TASK21: Rage can protect a teleport only when enemies lack piercing interruption. Phase helps sustain attacks; Armlet needs careful management inside Infest. Nullifier removes eligible defensive buffs, and Manta can remove silence before Rage.

Lina (TASK-13.43):
- TASK21: Eul can time Light Strike Array, Blink controls the cast angle, and Ethereal Blade can amplify magic damage or provide a physical save. BKB protects the combination, and Refresher needs actual Laguna mana in reserve.

Lion (TASK-13.58):
- TASK21: Blink enables immediate Hex. Glimmer can precede Mana Drain, Force Staff supports escape, and Ethereal Blade amplifies magic damage. Verify current Shard channel protection, including 60% magic resistance and debuff immunity.

Luna (TASK-13.59):
- TASK21: Cast spells before Mask of Madness silence, use BKB for sustained attacks and Eclipse, use Manta for lane pressure, project Scepter Eclipse from a safe position, and use Pike for range or escape.

Lycan (TASK-13.60):
- TASK21: A suitable Overlord neutral can interrupt teleports. Shard wolves need actual Hightail activation. BKB protects against eligible stuns during Shapeshift, Nullifier removes escape buffs, and Wolf Bite benefits an active melee teammate.

Magnus (TASK-13.61):
- TASK21: Use BKB before an exposed initiation sequence. Blink positions Magnus before Reverse Polarity. Harpoon can set up Skewer toward the team, while Refresher needs mana for both ultimates and careful queue sequencing.

Marci (TASK-13.62):
- TASK21: BKB protects Unleash attacks. Rapid strikes provide opportunities for Basher procs, while Nullifier removes eligible escape buffs or barriers. Blink can reach a better attack target.

Mars (TASK-13.63):
- TASK21: BKB protects the combination. Eul setup needs actual arrival timing. Shard enables two-target pins and a fire trail. Refresher requires mana for Arena and Spear twice. Rebuke can interact with eligible attack and lifesteal effects, but a Basher proc is not guaranteed.

Medusa (TASK-13.64):
- TASK21: Mana replenishment supports native survival. Manta copies enabled Split Shot, and Scepter enables secondary effects. Use Gaze before Mask of Madness silence when needed, and use Pike to reposition against mana burn.

Meepo (TASK-13.65):
- TASK21: Clone item cooldowns are shared except teleport scrolls, so do not assume repeated Blink or Hex casts. Dig protects individual clones, MegaMeepo can gather an endangered clone, and current statistic penalties matter.

Mirana (TASK-13.66):
- TASK21: Eul, Atos and allied Bane, Shadow Demon or Outworld Destroyer can provide Arrow timing. BKB protects eligible Leap windows. Scepter path effects require real linked behavior. Moonlight fade and detection matter, and Shard charges support escape.

Monkey King (TASK-13.67):
- TASK21: BKB protects formation and attacks; Skadi and Diffusal help keep targets inside the ring; verify current soldier item inheritance before implementing item policy.

Morphling (TASK-13.68):
- TASK21: Manta or BKB can protect shifting; Shard enables emergency shifting while stunned; current Scepter strong-illusion lifecycle needs the separate Morph deep dive.

Muerta (TASK-13.69):
- TASK21: BKB protects attack opportunity but does not grant universal immunity; Pike and Blink solve positioning; current Shard enables Spectral Slug; current Scepter improves the ricochet. Veil converts physical lifesteal into spell lifesteal for attacks.

Naga Siren (TASK-13.35):
- TASK 21: Manta as extra splitpush/dispel; Orchid/Bloodthorn then net for attack follow-up; Treads mana preparation preserved. Bloodthorn numeric 50 proc not encoded; verify item KV before shared change.

Necrophos (TASK-13.37):
- TASK 21: trigger Wand after Shroud when available; Dagon before delayed Scythe finish; defensive magic resistance and dispels; numeric item claims require separate KV check.

Shadow Fiend (TASK-13.40):
- TASK 21: BKB before close Requiem, Blink/invisibility for positioning; maintain existing invisUlt coordination. Mask of Madness silence should not overlap required spells; Refresher needs mana for two casts.

Night Stalker (TASK-13.41):
- TASK 21: Blink/Harpoon to get silence aura onto backline; BKB maintain attacks, Nullifier remove dispellable defenses. Existing generic item initiation remains responsible.

Nyx Assassin (TASK-13.44):
- TASK 21: Dagon before Mind Flare when targetheld/range/mana allow; Ethereal Blade after Vendetta attack; Euls landing time Impale, Blink/Force for approach/escape.

Outworld Destroyer (TASK-13.70):
- TASK 21: mana/intelligence improve damage and barrier; Treads INT, Witch Blade attacks, Force/Pike reposition, BKB before disables, Blink initiation and Hex follow-up; item build unchanged.

Ogre Magi (TASK-13.71):
- TASK 21: Lens for actual spell reach, Glimmer/Force for survival, Scepter second chained stun after basics; targeted Hex/utility may Multicast but no guaranteed proc. Builds unchanged.

Omniknight (TASK-13.72):
- TASK 21: Locket/Greaves heal sustain, Lens safe saves, BKB keeps Repel for ally, Blink/Harpoon positioning; Scepter and Refresher building defense. Builds unchanged.

Oracle (TASK-13.73):
- TASK 21: Lens/Blink safe timely saves, Locket/Salve heals during Promise, Glimmer reduces pending damage, Force defensive reposition and Aeon self protection; builds unchanged.

Pangolier (TASK-13.74):
- TASK 21: Diffusal/Mage Slayer effects on Swash, Basher chance, Blink active-roll reposition, Scepter Crash swipes, Shard control-safe transform; no guaranteed proc math or item-build changes.

Phantom Assassin (TASK-13.75):
- TASK21: Battle Fury cleave/farm, Desolator attack armor reduction, Basher chance, BKB freedom, Satanic dispel/lifesteal, Nullifier ethereal tools and Scepter passive-break use; chance procs not guaranteed damage, no build changes.

Phantom Lancer (TASK-13.76):
- TASK-21: Review Manta dispel and split push, Scepter Rush through distant creep lines, Shard escape, stats for illusions, and Bloodthorn pressure. Illusion inheritance and current item stats need separate verification. Builds are unchanged.

Phoenix (TASK-13.77):
- TASK-21: Review Shiva setup, Halberd protection for the egg, Eul dispels before egg, Glimmer during Ray, Vessel/Urn sustain, Refresher second egg and Shard beam during egg. Builds are unchanged.

Primal Beast (TASK-13.78):
- TASK-21: Movement speed adds Trample steps; Blink sets up Pulverize or escape; BKB preparation protects the channel; Scepter adds Uproar break projectiles during channels; Shard adds Rock Throw setup. Other Soul Ring, ethereal, Shiva and Vessel policies remain for the item pass.

Puck (TASK-13.79):
- TASK21: Blink escape after Phase damage cooldown, Witch Blade/Parasma physical follow-up, Shard Phase attack and Scepter Coil attacks, Eul dispel versus silence; no guaranteed proc damage or item build changes.

Pudge (TASK-13.80):
- TASK-21: Assess Scepter Rot amplification and anti-heal opportunity, Shard Hook value, and Blink/BKB/Aether Lens positioning policy in a separate item pass. Standard pass uses actual owned range items and preserves generic item policy.

Pugna (TASK-13.81):
- TASK-21: Glimmer and BKB channel protection, Lens positioning, Blink and Force repositioning, Dagon after Decrepify, current Scepter spell amplification drain, Shard Ward refraction and cooldown items need a separate item pass. Native item policy remains shared and unchanged.

2026-10-02 Queen of Pain → Zeus standard batch, 43 heroes in hero-file order; Rubick own pass excluded. Reviewed source and mechanics details are recorded in the linked TASK-13 subtasks. Observations for this existing follow-up; no generic item implementation was added by this batch.

Queen of Pain (TASK-13.82):
- TASK-21: dispelling silence through existing BKB/Euls policy enables Blink. Scream self reflection grants no spell lifesteal, so item healing must not be credited against that self damage. No item/build changes.

Clockwerk (TASK-13.87):
- TASK-21: Blade Mail and mobility support Cogs isolation; Euls/Force Staff enable escape; the current Overclock penalty is a nondispellable slow, so do not schedule BKB against an obsolete self stun. Armor Power consumes Chainmail but no item/build behavior was changed.

Razor (TASK-13.90):
- TASK-21: BKB, mobility and dispels help sustain Link; Refresher allows independent Eye instances and another Link. Current Surge reflected damage provides no lifesteal, so old Bloodstone/Shard sustain assumptions require revision outside this pass. No build/item changes.

Riki (TASK-13.94):
- TASK-21: Diffusal/Disperser and Smoke control, Manta outside Dust AoE and BKB help Riki maintain engagement; Aether Lens and Scepter range are actual live values. No item/build updates.

Ringmaster (TASK-13.96):
- TASK-21: Lens/Blink improve actual Escape range and save timing, Glimmer and Force Staff support escape, Atos setup requires actual projectile timing. No item/build updates.

Sand King (TASK-13.100):
- TASK-21 observation: real ready Blink and its upgrades support post-cast relocation; Arcane Blink has its own 1400 range rather than the ordinary 1200. This pass reads existing items and does not change purchases. BKB and armor recommendations remain observations for the item policy task.

Shadow Demon (TASK-13.104):
- TASK-21 observations: actual Lens range improves save coverage and existing Shard activates the real Cleanse sibling; actual Scepter runtime provides two Purge charges and break. Existing purchases and generic item behavior are unchanged.

Shadow Shaman (TASK-13.105):
- TASK-21 observations: actual Lens and Scepter extend different live ranges; BKB/Glimmer advice relates to channel protection, Refresher to another real Ward deployment, and current Shard grants Urnaconda. Existing builds and generic item behavior are unchanged.

Timbersaw (TASK-13.111):
- TASK-21 observations: existing mana items determine how long actual deployed Chakram can remain while preserving ready Chain mana. Actual Scepter barrier and Shard Flame opportunities are now read from runtime sources. BKB/Lotus/dispel recommendations remain observations; purchases and generic item logic are unchanged.

Silencer (TASK-13.115):
- TASK-21: actual Lens and unbroken Supremacy affect Curse/Word casting, never physical attack reach. Existing Refresher/Scepter and mana items remain unchanged; engine Scepter Curse is not manually duplicated, and copied missing Curse is not fabricated.

Wraith King (TASK-13.118):
- TASK-21: actual Wand and mana burn affect positive-cost early Reincarnation reserve; level three costs zero and Shard does not solve revive mana. Existing Blink, BKB, Radiance, consumed Scepter and item builds remain unchanged.

Skywrath Mage (TASK-13.120):
- TASK-21: observed Atos/Gleipnir/root setup matters for Flare dwell and actual mana must support Seal follow-up. Existing item builds remain; no generic item prep policy is changed or queued root success assumed. Actual Lens/Supremacy are measured each decision, avoiding stale sold-Lens bonuses.

Slardar (TASK-13.108):
- TASK-21: actual Blink/Crush access and observed readiness, Soul Ring/Treads mana preparation, current Shard pre-Haze, Scepter water survival, BKB and attack access need shared item follow-up. Existing build and item policy unchanged.

Slark (TASK-13.109):
- TASK-21: actual Diffusal setup, Scepter attack/escape charges, Shard human ally saves, BKB versus AoE disable and silences, Treads/self-cost and observed Refresher mana need shared follow-up. Existing item/build policy remains.

Snapfire (TASK-13.83):
- TASK-21 follow-up: Force Staff and Blink provide positioning and rescue access; Shard adds Cookie healing and landing damage, Scepter adds swallow and release, and Refresher can provide another Kisses barrage. Greaves, Pipe, Locket, Glimmer and Lotus depend on team needs; this pass preserves builds and shared item policy.

Sniper (TASK-13.86):
- TASK-21 follow-up: Pike, Force Staff, Blink and Shard create space against gap closers. Take Aim before Mask of Madness can preserve spell access, while Scepter improves long-range control. Mjollnir, Satanic, BKB, Phylactery and Khanda depend on build and opposing threats; no item lists or shared item policies changed.

Spectre (TASK-13.88):
- TASK-21 follow-up: Radiance and Manta improve farming and illusion pressure; Skadi, Butterfly and Abyssal improve extended fights and pursuit. Manta/BKB help against disables and Break according to actual dispel eligibility. Shard improves Dispersion burst response and Scepter improves Haunt access/fear. Preserve current purchases and shared item policy.

Spirit Breaker (TASK-13.93):
- TASK-21: Shadow Blade/Silver Edge can conceal Charge, movement items improve actual Bash scaling, BKB protects commitment and Scepter improves Bash collisions. Current Shard supplies targeted spell redirection. Preserve purchase policy; do not assume old Scepter grants Charge immunity piercing.

Storm Spirit (TASK-13.97):
- TASK-21: Bottle and Soul Ring maintain mana; Orchid/Hex offer lockdown, BKB/Linkens protect commitment, Shard helps allied attacks and Scepter changes Vortex to AoE. Preserve purchases and shared item policy; compute spell affordability from verified mana values.

Sven (TASK-13.101):
- TASK-21: activate combat buffs before Mask of Madness silence, use Blink/Harpoon for attack access, BKB against kiting, and Satanic for sustain. Current Scepter travel depends on actual autocast state; current Shard is a physical barrier/radius upgrade. Builds and shared item policy remain unchanged.

Techies (TASK-13.103):
- TASK-21: Lens extends actual spells, Force Staff supports retreat or mine positioning, Ethereal/Hex can prevent mine attacks, Shard supplies the M.A.D. active and Scepter grants Sign. Preserve builds and shared item policy; no item casting or mana discounts are invented.

Templar Assassin (TASK-13.106):
- TASK-21: Lens extends actual trap placement; Blink and attack-range items enable Meld positioning, while Desolator and armor reduction support physical spill. Preserve current builds and shared item policy.

Terrorblade (TASK-13.112):
- TASK-21: BKB and Manta enable Sunder by preventing or removing control; Lens affects actual spell range, Pike preserves distance, Scepter supplies Wave, Shard supplies current Zeal and Refresher supports a second committed Meta. Preserve builds and shared item policy.

Tidehunter (TASK-13.113):
- TASK-21: Blink initiation needs nearby follow-up, Shard adds shorter-cooldown leash, Scepter enables ranged wave clearing, Refresher requires mana for two Ravages, and Vladmir/Mage Slayer/armor effects can benefit actual Anchor attacks. Preserve current builds and shared item actions.

Tinker (TASK-13.116):
- TASK-21: Lens extends actual cast range, Blink supports positioning, BKB prevents channel disruption, Shard supplies Warp and Scepter upgrades current basic spells. Rearm does not refresh Blink, Hex, Dagon or other item cooldowns. Preserve builds and shared item policy.

Tiny (TASK-13.119):
- TASK-21: Blink, Echo Sabre and crit items help positioning and attacks; shared item preparation remains in charge of items. No blind Blink/Toss or inferred full crit/echo volley total. Lens and actual unbroken Supremacy extend legal cast ranges. Preserve all builds.

Treant Protector (TASK-13.124):
- TASK-21: Arcane sustain, Lens cast reach, Blink positioning, current Solar Crest ally barrier, Shard vision, current Scepter attack upgrade and Refresher can support Treant. Preserve all purchases and shared item policy; no blind Blink/Overgrowth or enemy dispel cooldown assumption.

Troll Warlord (TASK-13.123):
- TASK-21: actual BKB/Satanic and anti-kiting items remain usable during Trance, but no item use is assumed to have succeeded. Actual Scepter dispels differ between ranged and melee axes; generic purchases/preparation/builds remain unchanged.

Tusk (TASK-13.84):
- TASK-21: Review Blink positioning and ally saves, Scepter directional Kick support once engine control is verified, current Shard pull, armor reduction for physical Punch, BKB after commitment, and defensive Glimmer/Force/Lotus decisions. Builds and generic item policy are unchanged.

Undying (TASK-13.85):
- TASK-21: Review mana sustain for repeated Decay, Scepter Strength stealing, Locket/Greaves Soul Rip healing, Shard bunker saves, Blink positioning, team auras and defensive Glimmer/Lotus. No item build or generic policy changes.

Ursa (TASK-13.89):
- TASK-21: Review pre-cast Overpower before Blink, movement and anti-kiting items, BKB for silence/hex prevention, Scepter disabled-state Enrage, current Shard stacks, Battle Fury farming and Satanic sustain. No builds or generic item policy changes.

Vengeful Spirit (TASK-13.91):
- TASK-21: Review Lens actual range, Shard secondary targeting, safe Blink/Swap origins, allied Force/Glimmer support and current Scepter illusion lifecycle. No item builds or generic policies changed.

Venomancer (TASK-13.95):
- TASK-21: Review caster debuff transfer with Vessel and appropriate active items, current Noxious Scepter and Gale Shard, Lens range, mana sustain and useful Force/Glimmer peel. No generic item policy or builds changed.

Viper (TASK-13.99):
- TASK-21: Review current Shard building attacks, Dragon Lance/Pike attack reach, spell versus attack range distinction, safe Nosedive/Pike positioning, mana reserve and Scepter Corrosive Skin behavior. No builds or shared item policies changed.

Visage (TASK-13.102):
- TASK-21: Review current Shard survival, innate versus Scepter flight/invisibility, Bearing/Vladmir/Assault auras for actual owned birds, appropriate Hex/Orchid follow-up and true Lens range. No build or generic item policy changes.

Void Spirit (TASK-13.107):
- TASK-21: Current Scepter charge staggering and Shard rotating watch paths are useful. Euls or Hex setup can support Remnant, but exact vector direction needs engine validation. Vessel, silence and attack-proc item follow-ups remain generic item-policy work; no build edits.

Warlock (TASK-13.110):
- TASK-21: Observed Refresher mana/readiness and useful multihero opportunity now integrate through the existing native interface. Generic Refresher fallback still uses shared policy and was not edited. Review Glimmer/Ghost channel protection, current Solar Crest self-cast limits, Bearing/golem buffs and actual Shard imp generation; no build changes.

Weaver (TASK-13.114):
- TASK-21: Current Scepter saves benefit from true Lens and safe Blink positioning; preserve BKB/silence-dispel readiness for the caster. Actual Shard marks/secondary attacks, Geminate attack procs, Desolator and defensive attack range tools need engine-observed follow-up; no build/generic item edits.

Windranger (TASK-13.117):
- TASK-21: True Lens range helps Shackleshot and Focus Fire but cannot extend Powershot arrow range. Blink can create a behind-target shackle angle; BKB and defensive positioning protect a full Powershot channel. Current attack-proc and Scepter Tailwind interactions remain engine checks; no item/build changes.

Winter Wyvern (TASK-13.121):
- TASK-21: Real Lens helps safe Embrace and legal Splinter host reach; Blink improves Curse placement and escape tools reduce risky Embrace immobilization. Current Scepter toggle drains real mana and preserves an actually present save’s reserve. Current Shard is an exit attack buff rather than a blast. Edda choice/consumption remains a separate item-policy observation; builds and generic items untouched.

Io (TASK-13.122):
- TASK-21: Tether transfers actual restoration including consumables, Wand/Locket, Mek/Greaves, healing lotus/Cheese and regen auras; current heal restriction and item cooldowns must be respected. Lens improves real Tether range but not spirit orbit. Defensive Glimmer/BKB/positioning protect delayed travel; no item/build edits.

Witch Doctor (TASK-13.92):
- TASK-21: Keep Glimmer/Amulet use during the actual Ward channel; review Blink/cliff positioning, BKB preparation, Shard disjoint, Scepter bounce opportunities, mana reserve and healing amplification without altering this batch item builds.

Zeus (TASK-13.98):
- TASK-21: current Shard toggle, actual Scepter Nimbus and Bolt dependency, Lens reach, defensive positioning, and useful Refresher mana reserve need shared item follow-up. Builds and generic item policy remain unchanged.

Hero tracking consolidation (2026-10-02): historical TASK-13.x records now live in docs/HERO_PASS_REPORT.md, with old-ID/archive links and current status in docs/HERO_PASS_TRACKER.md. This task retains its independent scope and pending criteria. Lobby validation is coordinated by TASK-13.125.
<!-- SECTION:NOTES:END -->
