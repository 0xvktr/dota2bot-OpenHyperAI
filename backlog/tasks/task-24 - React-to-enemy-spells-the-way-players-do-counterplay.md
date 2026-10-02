---
id: TASK-24
title: React to enemy spells the way players do (counterplay)
status: To Do
assignee: []
created_date: '2026-09-30 13:58'
updated_date: '2026-10-02 16:49'
labels:
  - teamfight
dependencies: []
references:
  - bots/ability_item_usage_generic.lua
  - 'https://dotacoach.gg/en/heroes/counters/ancient-apparition'
documentation:
  - backlog/docs/doc-2 - Hero-improvement-playbook.md
  - docs/HERO_PASS_TRACKER.md
  - docs/HERO_PASS_REPORT.md
priority: medium
type: feature
ordinal: 27000
---

## Description

<!-- SECTION:DESCRIPTION:BEGIN -->
Guides describe how players respond to specific enemy spells, and bots ignore most of it. dotacoach's "Counter Strategy" and "Bad against" sections (/en/heroes/counters/<slug>) are the main source; each hero pass under TASK-13 adds entries here instead of changing the enemy hero's file. These rules help every bot, including bot-vs-bot games.

The first two come from the Ancient Apparition review (2026-09-30): no generic code reacts to `modifier_cold_feet`, so bots stand still and take the stun; heal items such as Salve (`item_flask`) do not check `modifier_ice_blast`, so bots waste them while Frostbitten. The heal-item side overlaps TASK-21.2, which reworks when heal items are used.
<!-- SECTION:DESCRIPTION:END -->

## Acceptance Criteria
<!-- AC:BEGIN -->
- [ ] #1 A bot cursed by an enemy Cold Feet moves beyond the break distance before the stun when it can move and is not committed to a fight
- [ ] #2 Healing items and healing abilities are not used on a Frostbitten unit (modifier_ice_blast)
- [ ] #3 Offline specs cover both reactions
<!-- AC:END -->

## Implementation Notes

<!-- SECTION:NOTES:BEGIN -->
Dazzle standard pass (TASK-13.2), sources: https://dotacoach.gg/en/heroes/dazzle and https://dotacoach.gg/en/heroes/counters/dazzle, checked against pinned Valve definitions/localization cf0d37a. Counterplay candidates: deny Dazzle attack follow-up while poisoned (only his attacks refresh it); spread away from allied units that multiply Shadow Wave physical damage; focus or gap-close onto the physical body rather than the invulnerable Projection spirit, whose tether exposes its position. Grave remains vulnerable to Axe Culling Blade. Healing suppression and save-item timing overlap TASK-21. Do not adopt the counters page claim that Shard grants Poison hex; current Shard heals allied Weave stacks, while Projection grants hex. No generic counterplay implementation in this hero pass.

2026-10-01 standard batch counterplay follow-up (TASK-13.3-.7). These are reviewed inputs to existing counterplay work, not new generic counterplay implementation:
- Abaddon: stop feeding damage into Borrowed Time and kite/cyclone it; time removable debuffs after Shield is spent; break can stop automatic activation but manual ultimate remains possible, so silence matters. Account for Shield explosion/visibility rather than chasing through it.
- Underlord: avoid standing together in Firestorm/Pit chokepoints, help allies leave the zone, and extend movement/defensive-item responses through repeated Pit roots; watch Gate arrivals including Scepter destination Pit.
- Alchemist: contest camps/bounties and pressure early; healing suppression limits Rage sustain; armor/ethereal protection helps against physical Acid/Concoction but does not negate magical Radiance damage. Disables/silence during brewing can prevent Throw.
- Anti-Mage: roots/silence and area control deny Blink; targeted spells risk reflection; replenish mana before Mana Void and spread away from a drained high-max-mana ally because splash uses that source's missing mana. Physical/pure damage bypasses passive magic resistance.
- Arc Warden: allied heroes/creeps/summons near a Flux target pause damage and Scepter silence while slow persists; enter Field to defeat its outside-only evasion; summons/illusions can intercept single-target Spark Wraith. Separate main/Double cooldowns and arrival threats.
Stale facet, passive-Nullifier, and Oracle Edict magic-immunity wording was excluded where encountered. Source evidence/checklists are in the hero subtasks; broad item responses/draft tables remain unchanged.

Concrete shared-helper follow-up found during batch integration: J.CanCastOnTargetAdvanced checks legacy modifier_antimage_spell_shield but omits current modifier_antimage_counterspell. The five-hero pass uses explicit local guards for relevant reviewed unit spells; audit the shared helper and other unit-target handlers in TASK-24 before broader counterplay changes.

Standard batch TASK13.8–13.12 counterplay observations (full source reconciliation in subtasks, no generic logic edits): Hunger can be removed by kills/building kills/basic dispels; spread against Call, cyclone Axe or save Called allies, break affects Helix. Bane Nightmare transfers on allied attack, preserve/interrupt Grip and all Scepter illusion channels; strong dispel removes Grip; block/reflection punishes targeted spells, BKB denies Nightmare/Enfeeble but Sap/Grip pierce. Batrider basic dispels remove Napalm/Flamebreak; Lasso needs strong dispel and pierces BKB; spread >650 from primary vs Scepter, block/reflection/current Counterspell and allied strong-dispel saves. Beastmaster remove bounty summons, resist physical attacks with armor/barriers and magical Axes/Drums with magic protection; defend Roar with block/reflection/reposition/strong dispel, avoid isolated root→Roar. Brewmaster silence/hex before Split, kite/avoid Split unless all spirits can be killed, immunity denies spirit Cyclone/Boulder and accuracy counters Storm evasion. Legacy Drunken Haze/Void/Companion and unverified numerical or old facet claims excluded.

API audit in second standard batch added J.HasBreakModifier using seven current localization-confirmed effects. It avoids unsupported server-only PassivesDisabled; conditional Break upgrades that reuse ordinary debuffs need source/engine validation before expanding this helper.

Standard batch TASK13.13–13.17 counterplay observations (reviewed sources in subtasks; no generic-policy changes): Bloodseeker Rupture pierces immunity, so control/TP/untargetable mobility and healing suppression need effect-specific checks; Rite is delayed, and enemies can interrupt follow-up. Bounty Track is dispellable vision/damage amplification; detection routes, dispel timing and avoiding tracked Shuriken relay clusters matter; current Toss slows, so do not treat it as a channel interrupt. Bristleback is vulnerable to particular Break effects, forced facing, armor and healing suppression; not every dispel removes every Break. Broodmother's swarm needs AoE/armor/attack-immunity/anti-heal responses; scout and Roshan-clap spider micro remain generic-unit follow-ups. Centaur threatens Blink/Stomp clusters and global mobility saves; spacing, Blink cancellation and roots limit that mobility, while magic mitigation affects Edge. Current batch targeted handlers guard both Counterspell and Counterspell Ally; existing shared helper still needs wider current-modifier audit. No stale Rawhide, Silken Bola, Seeing Red or old Shuriken stun policies added.

Standard batch TASK13.18–13.22 counterplay observations (sources and stale exclusions in subtasks): Chaos Knight rewards spreading, armor/attack protection, illusion control and timely dispels; current Bolt random damage must not be assumed at its maximum. Chen camp blocking, early Roshan vision, healing reduction, army AoE/armor and Scepter-channel interruption; automatic creep disposal/spread/scout policy remains generic minion work. Clinkz detection, armor/attack immunity, reflected damage, Pact-duration windows and lateral Barrage escape. Crystal Maiden spread against Nova/Field, dispel Frostbite and interrupt Field through appropriate immunity/positioning; roots alone do not cancel arbitrary channels. Dark Seer spread against Vacuum/Wall, avoid dangerous Shell hosts, use relevant dispels/roots to deny Surge pursuit and avoid feeding valuable replica targets. Precise vector placement, copied item/passive inheritance and unusual invulnerability interactions need engine validation. No generic counterplay policy or draft changes in this batch.

Standard batch TASK13.23–13.27 counterplay observations (audited sources and capability limits in subtasks): Dark Willow Crown isolation/dispels with Shard-bramble awareness, Bedlam damage sharing through units, maze path avoidance and untargetable Realm versus area damage. Dawnbreaker avoid full physical Starbreaker arc, sidestep Hammer trail, interrupt unprotected global channel and spread/reposition from visible landing; Shard immunity and heal suppression require current mechanics. Death Prophet kite Exorcism and Siphon break buffer, pressure cooldown windows, use physical armor against ghosts and reduce healing. Disruptor avoid visibly tracked TP arrivals, leave Field before formation, spread Storm and activate immunity before Scepter mute; Glimpse is not assumed undodgeable. Doom Linkens/Lotus/current Counterspell, pre-cast disables, Earth heal suppression, Scepter-aura spacing and item/TP escape before mute talent; ordinary Doom does not universally disable items. Existing counter policy/draft tables unchanged.

Elder Titan standard pass (TASK-13.32): avoid feeding Spirit touches and respect observed returned damage/movement/Scepter immunity; disperse beyond actual Stomp origins, interrupt full Stomp windup, and move across delayed Splitter line before impact. Bonus armor, bonus magic resistance/barriers and appropriate Spirit-buff dispels retain value because Natural Order removes base defenses. Save/control synergy includes actual remaining Stomp/BH/Chronosphere duration; low-level Stomp is not a guaranteed Splitter setup. Generic wake prevention, camp/portal policy and draft matchup weights are separate follow-ups. No counterplay/draft code changed.

Dragon Knight/Drow Ranger/Earth Spirit standard-pass counterplay/draft inputs (TASK-13.28–30). DK: regen reduction and break, unit-target Tail protection through Linkens/Counterspell versus point-cast Breathe Fire. Drow: close300-range Marksmanship suppression even on Glacier, Blink/Force/Pike repositioning, bonus armor versus base-armor-ignoring procs, disarm/Ghost physical protection and appropriate Gust dispels. Earth Spirit: vision and sidesteps for fog Rolls, collision blockers, tower kick angles, actual Grip/Magnetize dispels, resistance/debuff immunity and vulnerability to silence/control. Source matchup advice is evidence for later review, not new draft weights. No counterplay/draft code changed.

Earthshaker standard pass (TASK-13.31) counterplay/draft inputs: spread from actual nearby bodies including summons/illusions and real double-emitting heroes before Echo; chip caster to deny Blink; respect full Fissure windup and wall crossings, use appropriate immunity before control, terrain/flight escape and interrupt Scepter landing. Strong dispels and reflection have current-mechanics limits. Group-control synergy is evidence for later matchup review. Discard obsolete facets and no-budget double-Echo advice. No counterplay or draft code changed.

2026-10-02 Ember Spirit → Pugna standard batch, 49 heroes in hero-file order; Invoker and Lone Druid excluded. Reviewed source and mechanics details are recorded in the linked TASK-13 subtasks. Observations for this existing follow-up; no generic counterplay implementation was added by this batch.

Ember Spirit (TASK-13.33):
- TASK-24: break/dispel Guard, control sustain runes, spread versus Sleight/Chains, root/silence mobility; Chains does not reveal invisibility.

Enchantress (TASK-13.38):
- TASK-24: block camps/steal summon opportunities; dispellable buffs vulnerable to Enchant; move toward Enchantress after Impetus launches; spells and Break against Untouchable; Ice Blast blocks healing.

Enigma (TASK-13.42):
- TASK-24: separate in chokes, kill Eidolons before six attacks, exploit Hole cooldown; reserve BKB-piercing interrupt/save outside actual 420 radius. Magic-resist items do not mitigate pure Hole.

Faceless Void (TASK-13.45):
- TASK-24: spread against Chronosphere’s actual radius, apply continuous damage beyond the backtrack window, pressure after Walk, and save or interrupt from outside the sphere. Every Faceless Void can move freely in any Chronosphere.

Natures Prophet (TASK-13.46):
- TASK-24: Quelling Blade, Tango and Force Staff can overcome Sprout obstacles. Teleportation’s three-second cast can be interrupted. Tree vision and response to split pushes matter; area damage should clear Treants without feeding Echo Slam.

Grimstroke (TASK-13.47):
- TASK-24: attackable Phantom, dispels, Linkens/Lotus and immunity reduce setup reliability; never count its complete rend as guaranteed.
- TASK-24: avoid clustering around a bound mobile core; Swell needs enemy contact to charge its stun.

Gyrocopter (TASK-13.48):
- TASK-24: share Barrage with units, destroy delayed missiles, use physical armor/evasion against Flak and magic resistance against rockets.
- TASK-24: immunity and Lotus gate Missile; ethereal protects from Flak but is vulnerable to magical Barrage.

Hoodwink (TASK-13.49):
- TASK-24: Quelling cuts the trap tree; predicted-impact checks still require engine tree ownership/timing.
- TASK-24: true strike counters redirect; Blade Mail and early hero interception change Sharpshooter value.

Huskar (TASK-13.50):
- TASK-24: Break and anti-heal make low-health dives unsafe; Rupture damages displacement.
- TASK-24: magic resistance reduces Spear/Life Break output; disarm and ethereal prevent Spear attacks.

Jakiro (TASK-13.51):
- TASK-24: spread perpendicular to line spells, reposition out of Macro and exploit long cast points.
- TASK-24: ordinary immunity blocks spell debuffs; Scepter Macro pierces and deals pure.

Juggernaut (TASK-13.52):
- TASK-24: nearby creeps/illusions split Slashes; invisibility/ethereal and Lotus threaten value.
- TASK-24: destroy Ward early and use immunity-piercing control against spin escapes.

Keeper Of The Light (TASK-13.53):
- TASK-24: jump base Illuminate channels and use immunity/magic resistance; Wisp is an attackable noninterrupting pull.
- TASK-24: Lotus/Linkens stop targeted Solar Bind, but ground Blind cannot be reflected as a unit spell.

Kez (TASK-13.54):
- TASK-24: root/leash/Rupture deny dangerous movement, ethereal/disarm deny physical attacks, Toss and Claw respect block/reflect and debuff immunity, Ice Blast suppresses healing-only Raptor.
- Support setup from root/slow/area control is reflected in real delayed prediction; Raptor cannot guarantee all four slashes or survive enemy interruption.

Kunkka (TASK-13.55):
- TASK-24: X block/reflect/immunity, delayed spell prediction, Break/disarm and ethereal primary gates prevent wasted casts. Eul/invulnerability or BKB losing an observed mark invalidates combo state.
- Group control from Tide/Disruptor/Jakiro/Snapfire and allied Rum path benefit inform real setup, rather than Matchup win-rate deltas.
- Wave peels outward and avoids displacing an active observed X combo; offensive reverse-pull geometry remains lobby follow-up.

Largo (TASK-13.56):
- TASK24: Silence and mana burn prevent song value. Vessel, Skadi and Ice Blast reduce healing. Nullifier continuously removes beneficial buffs; basic Lick alone cannot permanently defeat its repeated dispel.

Legion Commander (TASK-13.57):
- TASK-24: bait Blink Duel with nearby saves; Euls/Ghost/Linkens/ethereal/disarm/armor mitigate forced attacks; save allies with Astral/Disruption/Grave/False Promise/Cold Embrace. Space lanes against Odds and punish Press cooldown.

Leshrac (TASK-13.34):
- TASK24: Dodge delayed Split Earth, leave Pulse Nova and Edict range, exploit low mana and healing reduction, and avoid isolated fights inside Edict.

Lich (TASK-13.36):
- TASK24: Spread beyond the 550 bounce distance, divert Chain Frost into creeps, dispel Shield, use immunity against control, and account for Sacrifice changing lane balance.

Lifestealer (TASK-13.39):
- TASK24: Kite Rage and disable afterward. Piercing control such as Lasso, Fiend’s Grip and Black Hole still matters. Use armor and healing reduction, and account for allied Infest carriers and Scepter enemy hosts.

Lina (TASK-13.43):
- TASK24: Evade delayed Light Strike Array, pressure fragile Lina, block or reflect Laguna, and use magic resistance or BKB. Account for innate burns and Fiery Soul stacks.

Lion (TASK-13.58):
- TASK24: Fog can break Mana Drain. Pressure Lion, use block or reflection against entity spells, distinguish directional Earth Spike, and expect Blink Hex and accumulated Finger damage.

Luna (TASK-13.59):
- TASK24: Stay outside the 675 Eclipse radius or dilute beams with creeps and illusions. Invisible targets are excluded. Pressure Luna’s farming and avoid clustered glaive bounces.

Lycan (TASK-13.60):
- TASK24: Armor and Crimson Guard reduce army damage. Kill vulnerable wolves and defend tower timings. Roots, hard control and Rupture still threaten a hasted Lycan.

Magnus (TASK-13.61):
- TASK24: Spread outside the 430 Reverse Polarity radius and scout or cancel Blink. Force Staff, Wind Waker and Aeon Disk can disrupt combinations. Immunity alone does not prevent Reverse Polarity.

Marci (TASK-13.62):
- TASK24: Disarm, ethereal protection, invisibility and kiting can waste the 16-second Unleash window. Healing reduction counters lifesteal, while armor and damage block reduce rapid attacks. Roots and Rupture still constrain Rebound.

Mars (TASK-13.63):
- TASK24: Attack Mars from behind, use immunity against Arena and Spear control, cut pinning trees, use Break against passive damage block, and spread or cancel Blink initiation.

Medusa (TASK-13.64):
- TASK24: Real mana burn threatens Medusa’s small health pool. Spread beyond Snake’s 450 bounce radius or block its first target. Turn away from Stone Gaze and disarm or kite Split Shot.

Meepo (TASK-13.65):
- TASK24: Focus a single clone, use area damage and curse interactions, consider armor and barriers, and reduce Ransack healing. Roots prevent Poof and Dig; immunity avoids Earthbind.

Mirana (TASK-13.66):
- TASK24: Creeps and other heroes can block Arrow. Detection counters Moonlight. Roots, leashes and Rupture constrain Leap, while immunity avoids Arrow and Starstorm damage or control as applicable.

Monkey King (TASK-13.67):
- TASK24: Force Monkey King outside Wukong; magic and pure damage bypass its armor; cut perched trees; distinguish blocked new Jingu charges under Break from existing buffs.

Morphling (TASK-13.68):
- TASK24: Silence and hex prevent reactive shifting; chain stuns matter unless actual Shard permits shifting; vessel and anti-heal reduce recovery; defensive shields and spell block can stop Adaptive Strike.

Muerta (TASK-13.69):
- TASK24: Magic resistance, disarm, silence and mobility reduce her limited magical attack window; Blade Mail discourages offensive burst; physical attacks are ineffective against active Veil.

Naga Siren (TASK-13.35):
- TASK 24: clear Mirror illusions with AoE/hex; avoid ordinary Ensnare/Song with BKB but Scepter net pierces; net reveals invisibility and is dispellable.

Necrophos (TASK-13.37):
- TASK 24: magic burst during Shroud, healing reduction/Ice Blast, dispel Shroud, save Scythe victims with banish/magic immunity; avoid static HP thresholds.

Shadow Fiend (TASK-13.40):
- TASK 24: flank/interrupt Requiem windup or leave radius; avoid facing triple Raze approach; armor vs Presence and magic resistance for spell burst.

Night Stalker (TASK-13.41):
- TASK 24: leave 350 Fear aura with displacement, fight before night/Dark, use Break on Hunter; avoid hiding behind trees vs flying vision.

Nyx Assassin (TASK-13.44):
- TASK 24: avoid triggering active Carapace, debuff immunity versus nonpiercing stuns; reveal Vendetta with detection and burst/control before escape.

Outworld Destroyer (TASK-13.70):
- TASK 24: debuff immunity/ethereal/disarm suppress Orb; jump/silence save caster; mana capacity reduces Eclipse difference. Reflection hazards guarded.

Ogre Magi (TASK-13.71):
- TASK 24: magic resistance/barriers, debuff immunity, Lotus targeted reflection; illusion swarms divide single-target control.

Omniknight (TASK-13.72):
- TASK 24: focus/disable caster, antiheal versus sustain, magical/pure damage bypass physical Angel, kite short attack Hammer; Nullifier targets dispellable Repel, not nondispellable Angel aura.

Oracle (TASK-13.73):
- TASK 24: focus/silence save caster, antiheal near Promise expiry, pure/physical damage bypass Edict magic resistance; enemy dispels remove heal/Edict.

Pangolier (TASK-13.74):
- TASK 24: pressure after dash, spread/sharp turn from rolls, debuff-immunity versus nonpiercing control, root/leash and piercing stuns, Rupture stops movement; dispels remove barrier.

Phantom Assassin (TASK-13.75):
- TASK-24: Armor, ethereal defenses, Force/Pike/Glimmer kiting, reflection, Carapace and control before BKB; Break and accuracy against passive evasion, plus vision in dangerous farming areas.

Phantom Lancer (TASK-13.76):
- TASK-24: Punish Doppelganger cooldown, use area damage and real-hero detection, avoid long low-mana engagements, and assess armor, Crimson Guard, ethereal defenses and debuff immunity against Lance.

Phoenix (TASK-13.77):
- TASK-24: Punish Dive cooldown, dodge Spirits and turn away from Ray, decide early whether to attack the egg or leave, avoid clustering, and assess attack speed, dispels, immunity, roots and Rupture.

Primal Beast (TASK-13.78):
- TASK-24: Dodge the charge, kite Trample movement, use roots, leash or Rupture against mobility, interrupt Pulverize with suitable control, and respect reflection. Debuff immunity does not deny current Pulverize control.

Puck (TASK-13.79):
- TASK24: instant disable/silence before Phase, spread out versus Coil, stand and fight when safely leashed, magic resistance and current debuff immunity, punish rune and side-lane exposure.

Pudge (TASK-13.80):
- TASK-24: Track Hook body blockers, vision and high-mobility dodges; magic resistance against Rot and Dismember damage; interrupt and displacement risks during Dismember; Blade Mail and Spiked Carapace reflection.

Pugna (TASK-13.81):
- TASK-24: Dodge delayed Blast, interrupt or leave Drain range, silence the caster, reflect or block unit-target spells, remove Decrepify with dispels, kill the Ward, and use magical resistance or debuff immunity. Track high-mobility physical initiators and healing reduction.

2026-10-02 Queen of Pain → Zeus standard batch, 43 heroes in hero-file order; Rubick own pass excluded. Reviewed source and mechanics details are recorded in the linked TASK-13 subtasks. Observations for this existing follow-up; no generic counterplay implementation was added by this batch.

Queen of Pain (TASK-13.82):
- TASK-24: magic immunity prevents Shadow Strike and Scream but Sonic Wave pierces it; movement roots and leashes constrain Blink. Unit spell block differs from live Scepter point targeting. No generic counterplay changes.

Clockwerk (TASK-13.87):
- TASK-24: visible summon and ally collision can intercept Hookshot; summons dilute unenhanced Battery Assault; debuff immunity prevents Battery/Flare but not Hookshot and Cogs. Supports can force movement out of Cogs and Linken only concerns actual unit casts, not Hookshot.

Razor (TASK-13.90):
- TASK-24: Force Staff/Pike distance, Linken and Lotus affect Link; magic immunity blocks Plasma, while ethereal and attack immunity suppress physical Eye. Rupture punishes chase. No generic counterplay changes.

Riki (TASK-13.94):
- TASK-24: detection, roots/leashes, ethereal saves and armor constrain Riki; Smoke Shard prevents allies targeting the trapped hero but does not mute active items. Current Backstab and fixed Tricks damage should replace outdated agility-only estimates. No generic counterplay changes.

Ringmaster (TASK-13.96):
- TASK-24: Box targets remain vulnerable to AoE damage and enemy dispels; none of the main enemy effects pierce debuff immunity. Wheel requires actual facing rather than guaranteed taunt. Souvenirs are muted as fake items even though ordinary silence permits them. No generic counterplay changes.

Sand King (TASK-13.100):
- TASK-24 observation: detection removes the practical protection of Storm invisibility; displacement breaks its original area. Debuff immunity prevents Burrowstrike, Storm and Epicenter damage while Stinger remains a physical attack. Armor, ethereal form, movement leashes and Rupture affect the appropriate portions of the kit.

Shadow Demon (TASK-13.104):
- TASK-24 observations: reflect and spell block constrain enemy unit spells; Disruption does not accept immune allies, while Purge and Cleanse have different immunity rules. Poison damage belongs to the original caster and relies on accurate stack buildup. Enemy detection, positioning and dispels affect practical support play; no generic counter rules changed.

Shadow Shaman (TASK-13.105):
- TASK-24 observations: spell block and reflect matter for targeted control, debuff immunity prevents Hex/Shackles/Shock, and armor or ethereal protection affects actual ward attacks. Multiple attackers or ranged interrupts threaten Shackles. Urnaconda and Ward point casts have different cast shapes from the unit-target spells.

Timbersaw (TASK-13.111):
- TASK-24 observations: root, leash and Rupture constrain Chain travel; tree removal changes the actual first latch and Whirl damage. Pure damage does not imply piercing debuff immunity. Break stops gaining armor stacks, healing reduction limits sustain, and dispels can remove the actual Scepter barrier.

Silencer (TASK-13.115):
- TASK-24: Global pierces debuff immunity but dispels and already-silenced state change its value. Physical attacks continue during silence. Glaives bonus remains magical and Last Word can trigger only after an enemy channel ends. Enemy cooldowns are not queried.

Wraith King (TASK-13.118):
- TASK-24: damage immunity and physical protection affect summons, dispels/stun overlap constrain Blast, and mana denial matters before zero-cost Reincarnation. Current Break stops new Bone Guard stacks and passive critical/lifesteal benefits; it is not assumed to disable Reincarnation.

Skywrath Mage (TASK-13.120):
- TASK-24: dispel Seal/root, move out of the 170 field, deny actual automatic Concussive targeting, use physical disruption and reflect/barrier protection. Source claims that Arcane Bolt can simply be disjointed or Spirit Bear tanks a hero Flare are not adopted.

Slardar (TASK-13.108):
- TASK-24: actual dispels can remove Haze until its current talent, armor/physical barriers and ethereal state reduce physical burst, immunity stops Crush but not Haze, and ranged kiting or disable can deny Bash. Coordinated real allied physical attacks benefit from Haze; pure Ward does not.

Slark (TASK-13.109):
- TASK-24: bait the actual Pact delayed pulses, respect undispellable control, target AoE during Dance/Shroud, deny safe first-hero Pounce path/escape charges and avoid long actual stat-steal fights. Ward/deward inference from passive vision needs a separate observation policy, not fabricated vision knowledge.

Snapfire (TASK-13.83):
- TASK-24 follow-up: Sharp movement can evade Cookie landings and the first Kiss. Respect magic immunity, reflection, Carapace, magic resistance and physical attack immunity. Enemy gap closers threaten a stationary barrage; allied Ravage, Chronosphere, Arena, roots and other observed disables improve first-impact reliability. No enemy cooldown API is used.

Sniper (TASK-13.86):
- TASK-24 follow-up: Respect Lotus, block, Blade Mail, Carapace, magic and attack immunity, disarm and undying effects. Storm, Spectre, Spirit Breaker, Pudge and other observed gap closers threaten Sniper positioning. Allied frontliners, saves, Cogs and Arena provide safe attack opportunities. Smoke and movement can disrupt enemy attempts to finish a marked target; no enemy cooldown API is used.

Spectre (TASK-13.88):
- TASK-24 follow-up: Break disables Desolate and Dispersion; sustain, roots, attack immunity and early pressure restrict safe jumps. Healing allies can extend Spectre fights, while actual allied attacks and global follow-up create entry opportunities. Respect reflected damage, Carapace, protected targets and unsafe tower or AoE-control destinations.

Spirit Breaker (TASK-13.93):
- TASK-24: roots, silences, spell block, reflected spells and poor arrival numbers restrict commitment. Use actual ally setup and line opportunities; avoid Carapace and Blade Mail. Planar Pocket can protect the selected ally from unit-targeted spells but does not provide a general team aura.

Storm Spirit (TASK-13.97):
- TASK-24: instant silence, roots, Doom, mana burn and unsafe commitments restrict Storm. Frontline allies and actual attacks create safe follow-up; debuff immunity blocks ordinary Vortex. Preserve escape mana against Anti-Mage and avoid Carapace/protected targets.

Sven (TASK-13.101):
- TASK-24: avoid Blade Mail, attack immunity, disarm and protected targets; prioritize actual clustered AoE anchors. Armor, force movement, disables and prolonged fights can waste the God Strength window. Grouping allies such as Dark Seer/Magnus and real frontline attacks create meaningful cleave opportunities.

Techies (TASK-13.103):
- TASK-24: debuff immunity, magic barriers, dispels, illusions and forced movement limit burst and mine reliability. Actual allied stuns/grouping provide mine windows. Avoid Blade Mail/Carapace and unsafe landings; do not assume enemy attack speed or escape cooldowns.

Templar Assassin (TASK-13.106):
- TASK-24: damage over time consumes Refraction barriers, HP removal bypasses them, detection exposes Meld and dispels remove trap slow. Respect enemy debuff immunity and reflected or protected targets without guessing cooldowns.

Terrorblade (TASK-13.112):
- TASK-24: magic burst threatens the low health pool; silence prevents Sunder, and Linken/Lotus/debuff immunity obstruct enemy exchanges. Hex and AoE clear illusions, disarm and kiting waste Meta, and forced friendly attacks can punish illusion grouping. No enemy cooldown or speculative dispel is assumed.

Tidehunter (TASK-13.113):
- TASK-24: debuff immunity and strong dispels counter Ravage, Break removes Kraken protection and pure/magic damage bypasses physical block. Do not waste the long ultimate on already disabled or unsupported targets; current human ally attacks establish actual follow-up.

Tinker (TASK-13.116):
- TASK-24: silence, forced movement, X Mark and ranged initiation interrupt Rearm/TP; vision exposes tree-line positioning. Respect Linken/Lotus, Blade Mail, Carapace and debuff immunity. No enemy cooldown knowledge or permanent item disable loop is assumed.

Tiny (TASK-13.119):
- TASK-24: nearby heroes and creeps can change the actual Toss passenger. Debuff immunity prevents grabbing an enemy but can still permit destination targeting; ordinary offensive decisions remain conservative. Shields, reflection, Blade Mail, Carapace, physical immunity and unsafe landings are respected.

Treant Protector (TASK-13.124):
- TASK-24: tree destruction and detection expose Guise and remove Eyes; direct player attacks consume Living Armor block. New BKB, Manta, Lotus and other dispels can remove Overgrowth, but existing debuff immunity does not prevent it. Silence, roots, channel danger, reflection and physical immunity constrain actual attack Seed decisions.

Troll Warlord (TASK-13.123):
- TASK-24: Trance can be kited, disarmed and controlled; damage cannot normally kill during it, but Culling Blade still can. Ice Blast denies lifesteal healing, physical protection changes the forced target value, Break prevents new Fervor/Rage benefits and Shard procs, and basic dispel does not remove every root or disable.

Tusk (TASK-13.84):
- TASK-24: Roots and leash deny Snowball or Buddies, displacement escapes Shards, mobility changes Snowball endpoints, armor and ethereal defenses reduce Punch, and clustered Snowball pickups risk area counter-initiation.

Undying (TASK-13.85):
- TASK-24: Focus Tombstone with attack speed and range, kite Flesh Golem and zombies, track low resources, use anti-healing against Rip sustain and avoid clustered Decay exposure. Bunker destruction can punish the saved hero.

Ursa (TASK-13.89):
- TASK-24: Kite short Enrage, use suitable displacement/banish, disarm or ethereal defenses to waste Overpower, watch early Roshan and Tormentor, and exploit silence/hex. Illusions divide Fury Swipes focus.

Vengeful Spirit (TASK-13.91):
- TASK-24: Respect piercing Swap and barrier rescue, reveal and pressure the fragile caster, use applicable spell block/reflection and projectile disjoint against Missile, and account for the controlled Scepter illusion after killing Venge.

Venomancer (TASK-13.95):
- TASK-24: Watch dispels and their current host-spread consequence, magic resistance and debuff immunity, ward vision and bounty, illusions splitting targeting and safe disengagement before follow-up poison attacks.

Viper (TASK-13.99):
- TASK-24: Use applicable block/reflection against piercing Strike, avoid extended poison stacks and toxin zones, respect current Break and attack slow, and use magic resistance, disarm, displacement and illusion pressure.

Visage (TASK-13.102):
- TASK-24: Protect and focus high-bounty birds, respect Cloak threshold and existing layers under Break, armor/damage block versus Familiar attacks, applicable reflection/block versus hero nukes, and detection after current Scepter timing.

Void Spirit (TASK-13.107):
- TASK-24: Respect root, leash, Rupture and Coil displacement punishment, reflection/Carapace, regeneration during delayed pops, physical versus magical barrier differences, and existing immunity/silence. Do not inspect enemy cooldowns.

Warlock (TASK-13.110):
- TASK-24: Respect actual dispels of Bonds/Word, immunity versus Upheaval, Offering piercing interruption, dangerous visible caster pursuit, and golem gold feeding. Reflected Bonds damage must not be counted as extra lifesteal or reflected again; enemy cooldowns are not inspected.

Weaver (TASK-13.114):
- TASK-24: Real silence/stun action gates matter before Time Lapse, history determines whether a rewind helps, and detection makes Shukuchi invisibility unreliable as damage prevention. Respect physical immunity/disarm/Break versus Geminate, beetle attack removal, Carapace/reflection and root/leash/Rupture/Coil movement hazards.

Windranger (TASK-13.117):
- TASK-24: Avoid reflection and Carapace; physical immunity/disarm suppress attack-oriented Focus Fire. Scatter behind-target anchors to weaken Shackleshot, use blockers against Powershot and magic damage against Windrun. Curse-like damage protection and pending stuns must be observed.

Winter Wyvern (TASK-13.121):
- TASK-24: Magic/pure threats can punish Cold Embrace, while physical attacks are prevented. Debuff immunity protects secondary Curse attackers and burn/Blast victims, but not the Curse primary. Spread beyond actual 525 Curse and 500 Splinter radius; protect against reflection/spell block and observe caster-owned Curse damage exceptions.

Io (TASK-13.122):
- TASK-24: Focus the exposed caster, apply observed disable/silence to cancel delayed travel, use actual X Mark and healing reduction/Ice Blast, and respect displacement/Coiled/Rupture. A passive or existing link can persist through protected target states; this does not authorize an unavailable active spell.

Witch Doctor (TASK-13.92):
- TASK-24: Separate Cask bounce partners, disrupt the caster channel, escape Ward reach, use attack immunity/invisibility or repositioning, and heal before Maledict bursts. Armor and ordinary magic barriers do not reduce current pure Ward damage.

Zeus (TASK-13.98):
- TASK-24: respect actual block/reflection, immunity, spell resistance/barriers, lost vision, controlled landing, and Nimbus destruction; actual ally setup enables global support. Long-range burst, silences and mobility can deny safe spell access.

Hero tracking consolidation (2026-10-02): historical TASK-13.x records now live in docs/HERO_PASS_REPORT.md, with old-ID/archive links and current status in docs/HERO_PASS_TRACKER.md. This task retains its independent scope and pending criteria. Lobby validation is coordinated by TASK-13.125.
<!-- SECTION:NOTES:END -->
