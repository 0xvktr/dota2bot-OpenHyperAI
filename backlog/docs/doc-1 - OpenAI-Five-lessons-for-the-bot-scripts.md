---
id: doc-1
title: OpenAI Five lessons for the bot scripts
type: guide
created_date: '2026-09-29 22:13'
updated_date: '2026-09-29 22:15'
---
# OpenAI Five: lessons for these bot scripts

Source: OpenAI et al., *Dota 2 with Large Scale Deep Reinforcement Learning* (2019), https://arxiv.org/abs/1912.06680.
Read for TASK-12 on 2026-09-30. Sections used: 3.1, 4.1, Appendices D, F.1, G, K, L, O.2, P, Q. Everything below is a paraphrase;
page references are to the arXiv PDF.

OpenAI Five drove Dota through the same Lua bot scripting API these scripts use (Appendix K, p. 49), on a 17-hero pool,
and beat OG 2-0 in April 2019. Its own hand-scripted baseline bot beat beginners but not amateur players (Appendix J).

## 1. Builds were scripted too: invest in decisions, not build logic
The learned policy never chose builds. Ability order, item purchase order, consumable restocking (keep a fixed set of
consumables, rebuy when used, stop after a set time), inventory/backpack swaps (keep the most valuable items active) and the
courier were all rules-based (Section 3.1, Appendix F.1, p. 42-43). It still reached superhuman level.

- Confirms our split: builds come from data (D2PT, TASK-4); the gains are in in-game decisions.

## 2. Play style depends on game state
Early in training the agent fought constantly. That won fast when it got ahead, but it had no way back when behind and
lost long games. The final agent **concentrated farm on its strongest heroes**, grouped and pressed hard when clearly
ahead, and **avoided fights to farm when behind** (Section 4.1, p. 9-10).

- Our push logic already scales with net worth and level advantage (aba_push.lua) and farm mode checks net worth, but no
  shared logic makes the team play safe when behind. TASK-22 (adapt team play to the game state).
- Farm priority for the strongest cores feeds TASK-8.

## 3. Five-man grouping is a trap if it abandons the map
At one point the agents learned to walk together as five on a single lane and fight whatever came. Short-term reward
was higher, but they lost the resources from the other lanes; OpenAI added lane assignments with a penalty for leaving
them (they later found the penalty may not have been needed) (Appendix O.2, p. 62-63).

- Grouping (team roam, push, objectives) should keep side lanes and jungle being farmed unless the group is ending the game.
  TASK-8 and TASK-22.

## 4. Where the agent played differently from humans
- It rotated heroes across the map much more often than humans, who mostly stay in assigned areas.
- It judged well when attacking on low HP was worth the risk.
- It spent consumables and long-cooldown spells readily instead of holding them for a later chance (Section 4.1, p. 10).

- TASK-20 (mid rotations) and TASK-11 (fights): holding ultimates too long is a real cost when a fight is already on.

## 5. A value table for game events
The shaped reward (Appendix G, Table 6, p. 44) is effectively a hand-tuned list of what matters. Team events are paid to
all five heroes, so in total they count five times a solo event.

| Event | Weight | Paid to |
|---|---|---|
| Win | 5 | team |
| Hero death | -1 | solo |
| Courier death | -2 | team |
| Aegis gained | 5 | team |
| Tier 1 / 2 / 3 / 4 tower | 2.25 / 3 / 4.5 / 2.25 | team |
| Barracks | 6 | team |
| Shrine | 2.25 | team |
| Megacreeps unlocked | 4 | team |
| Ancient HP (fraction) | 5 | team |

- Buildings pay two-thirds as they lose HP and one-third on death, so chipping a tower is worth something.
- HP is valued on a concave curve (value of HP fraction x = (x + 1 - (1 - x)^4) / 2): the last part of a hero's HP is worth the most.
  At 50% HP about 72% of the value remains; at 20% about 40%.
- Aegis is weighted like the win itself; a courier death costs two hero deaths.

- Useful as relative priorities for TASK-10 (Roshan), tower defence and push choices, and saves (TASK-21.1).

## 6. Roshan had to be taught
Early in training the agents learned never to approach Roshan. They only learned to kill it after Roshan's HP was
randomised in training games (Appendix O.2, p. 63).

- Even a learning system avoids Roshan without help; our bots need explicit, deliberate Roshan evaluation (TASK-10).

## 7. Reaction time and timing precision
The agent acted every 4th frame (about 133 ms) and reacted in 167-267 ms. It could pick an exact frame inside that step but
learned that it did not help (Appendix L, p. 51-52). Our ability thinks run every ~0.12-0.2 s, which is in the same range.

- Frame-exact actions must tolerate the think step: decide on "reached or passed" windows, never on exact equality.
  The Ice Blast release bug (TASK-1) was exactly this. Applies to pull timing (TASK-5) and stack timing (TASK-6).

## 8. Some heroes are hard for bots by nature
The agent rated Earthshaker low because it never mastered the geometry of Fissure (Appendix D.2, p. 37).

- Skills that need precise geometry are a natural criterion for our weak-hero list (TASK-16).

## Not applicable
Drafting from a learned win-probability model (Appendix D.2), training hyperparameters, surgery, and the Divine Rapier
instability (Appendix Q.3).
