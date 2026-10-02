# Bot banter

Bots have offline, event-driven match banter inspired by [issue #38](https://github.com/forest0xia/dota2bot-OpenHyperAI/issues/38). It works in ordinary bot matches without FretBots, a network connection or a language model.

Reactions cover first blood, kills, multikills, kill-streak milestones, revenge on the hero that last killed the bot, ending an enemy's streak, repeated kills on one hero, deaths, a bot losing its own streak, escaping a dangerous encounter, favorable fights, team wipes, growing score leads and comebacks. Lines mix taunts aimed at the enemy with bot jokes and self-deprecation. They do not blame human teammates for a bot's death, and they stay playful: no insults about a player's intelligence, no slurs and no profanity.

English lines can address the enemy hero by name ("Sit down, Lina."). The other languages do not have named lines or their own revenge, shutdown, repeat-kill and team-wipe pools yet; they use their kill and team-fight pools for those events.

## Settings

Use your existing `Customize/general.lua` settings (including the external `game/Customize/general.lua` override, if present):

| Setting | Behavior |
| --- | --- |
| `Allow_Trash_Talk = false` | Disables match banter and existing chat replies, including GPT responses. |
| `Trash_Talk_Level = 0` | Disables offline banter and canned replies. |
| `Trash_Talk_Level = 1` | Occasional match reactions; kill taunts (kill, multikill, streak, revenge, shutdown and repeat kill) are suppressed. |
| `Trash_Talk_Level = 2` | Also enables kill taunts and existing ally chat replies. This is the default. |
| `Localization` | `en`, `zh`, `ru` or `ja`; unavailable phrase banks fall back to English. |

Change language during drafting or the match with `!speak en`, `!speak zh`, `!speak ru` or `!speak ja`. `!sp` is the short form, and `cn` is an alias for `zh`. Use team chat to change your team's language; an all-chat command is visible to both teams. Unsupported or bare commands leave the current language unchanged and print usage to the console. Language changes continue to work after the canned-reply quota is exhausted.

Spontaneous banter is sent to all chat, with at least 45 seconds between a bot's lines, 12 seconds between allied bots' lines and 120 seconds between the same bot's reactions of one type. Existing canned replies also reserve the team banter cooldown. Eligible events have a 45% chance of producing a line, 65% when the named victim or killer is a human player, and 80% for first blood, comebacks, team wipes, revenge and shutdowns. A bot does not repeat its previous line for an event, and allied bots skip the last eight lines any of them used. Events suppressed by settings, chance or cooldown are discarded, never queued for later.

These limits apply to this match-banter system. Existing tactical announcements, debug messages and FretBots GPT responses have their own behavior.

## What the bot observes

- Kills, deaths and assists come from scoreboard deltas, never gold rewards. Only one prioritized event per observation is considered; suppression does not fall through to another taunt. Initialization, hero changes and clock resets establish a fresh baseline without announcing old kills. Observation starts when heroes spawn, so a first blood before the horn counts.
- A victim is named only when the bot gained exactly one kill, its team gained exactly one kill and exactly one enemy's death count rose in the same one-second sample. A killer is named by the mirrored rule. Anything less certain uses an unnamed line.
- Revenge is a kill on the hero last named as the bot's killer. A shutdown is a kill on a hero with at least three kills since its last death. A repeat kill is the third or fifth named kill on one hero since that hero last killed the bot.
- Multikills are observed kills within ten seconds. Streak milestones are three, five, eight and ten kills since the last observed death. The lines do not claim an official announcer result or a rampage.
- A favorable fight means at least three team kills within twenty seconds, a kill advantage of at least two in that window and a fresh kill or assist by the speaker. A team wipe means every enemy hero (at least three) is dead right after a team kill; a bot that took part in that sample or the designated bot can announce it once.
- An escape requires seeing at least two nearby enemy heroes, taking recent hero damage at 35% health or less, then surviving at least six seconds with no nearby enemies and no hero damage for five seconds. The opportunity expires after eighteen seconds. This is a conservative encounter heuristic, not proof of a missed enemy spell.
- One designated bot per team can react when the score lead crosses another five kills, or when the team catches up after trailing by at least five. Comebacks also count if several kills take the team straight into the lead. No exact score or win prediction appears in the lines.
- Illusions, Meepo clones and Tempest Doubles do not get an additional voice. There are no courier-kill, missed-spell or lane-dominance reactions: the bot API does not expose who killed a courier, whether a spell missed, or a reliable lane result, and a wrong claim reads worse than silence.

## Verification

Run `node tests/banter_spec.cjs` and `node tests/reply_member_spec.cjs` from the repository root. They use the existing `.test-tools` Lua parser and Fengari runtime, with deterministic game snapshots and random choices.

In a separate local test lobby, check:

1. At level 2, provoke a first blood, closely spaced kills, a streak, a death and a low-health escape. Observe context, all-chat routing and spacing across allied bots. Named lines must use the right hero, including a first blood before the horn.
2. Kill a bot and then let that bot kill you (revenge), die to one bot three times without killing it (repeat kill), and get three kills before dying to a bot (shutdown).
3. Check a favorable team fight, a full team wipe and a score comeback. The designated speaker should avoid repeating score announcements while the score is unchanged.
4. Switch through all four languages, including `!sp cn`, then send bare `!sp`, `!speak unsupported` and ordinary text containing `!sp`. Only exact supported commands should change language.
5. Repeat with four humans and one bot, level 1, level 0 and `Allow_Trash_Talk = false`. Confirm language commands still work and suppressed events do not appear after re-enabling banter.
6. Check Meepo, Arc Warden and an ARDM hero swap for duplicate or stale messages. Wraith King reincarnating or an Aegis respawn must not read as a team wipe.

Automated tests cannot establish actual engine callback delivery, shared bot-handle fields, how `IsHeroAlive` reports a reincarnating hero, or the subjective pacing of a full match; those need lobby validation.
