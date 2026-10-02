# Hero ability pass tracker

The standard ability pass is implemented and checked offline for 124 of 127 heroes. All 124 still need lobby validation. Invoker, Lone Druid and Rubick remain explicitly deferred. This tracker replaces the 124 archived hero subtasks; [the reference report](HERO_PASS_REPORT.md) preserves their research, changes and live checklists.

## Active work

| Work | Task | Status |
| --- | --- | --- |
| Roster umbrella | [TASK-13](../backlog/tasks/task-13%20-%20Improve-heroes-one-by-one-using-Torte-de-Lini-ability-guides.md) | In Progress |
| Lobby validation campaign | [TASK-13.125](../backlog/tasks/task-13.125%20-%20Validate-hero-ability-passes-in-lobby-batches.md) | Needs In-Game Test |
| Invoker standard pass | [TASK-13.126](../backlog/tasks/task-13.126%20-%20Invoker-standard-hero-ability-pass.md) | To Do, deferred |
| Lone Druid and Spirit Bear standard pass | [TASK-13.127](../backlog/tasks/task-13.127%20-%20Lone-Druid-standard-hero-ability-pass.md) | To Do, deferred, weak hero |
| Rubick own standard pass | [TASK-13.128](../backlog/tasks/task-13.128%20-%20Rubick-standard-hero-ability-pass.md) | To Do, deferred, weak hero |

Independent tasks remain for specific work: TASK-1 covers Ancient Apparition live release and its weak-list decision; TASK-16 covers weak-hero reasons; TASK-21 covers item usage; TASK-24 covers enemy counterplay; TASK-37 covers role-specific spell priorities. They are not absorbed by this migration.

## Recording progress

For a standard pass, update the hero row and its report section after the source review and relevant offline checks. Record the patch and exact checks. Set lobby status to Pending until the in-game checklist has been exercised; offline results never imply live success. Explicitly deferred heroes remain unstarted until the user resumes them.

For lobby validation, use batches of roughly 5–10 heroes, beginning with channel continuations, vector endpoints, copied spells, minions and weak heroes. Record the game patch, settings, scenario, expected and observed behavior and evidence location in the result section. Use Passed, Failed or Pending per scenario, and link any independent bug/deep-dive task. A retained limitation requires an explicit disposition. Do not silently skip a hero or clear its weak flag.

The 18 current weak flags are retained: 16 reviewed heroes and deferred Lone Druid/Rubick. The validation campaign and those two deferred tasks retain the weak-hero label and milestone m-0. These flags are not a measure of standard-pass completion.

## Roster

The rows follow hero-file alphabetical order. Reviewed and Offline are Yes only for the implemented passes. The Record column links to the preserved checklist; Archive provides the unchanged source record and maps every historical task ID.

| Hero | Hero file | Reviewed | Offline | Lobby | Weak flag | Record | Archive |
| --- | --- | --- | --- | --- | --- | --- | --- |
| Abaddon | `abaddon` | Yes | Yes | Pending | — | [Checklist](HERO_PASS_REPORT.md#abaddon) | [TASK-13.3](../backlog/archive/tasks/task-13.3%20-%20Abaddon-standard-hero-ability-pass.md) |
| Underlord | `abyssal_underlord` | Yes | Yes | Pending | — | [Checklist](HERO_PASS_REPORT.md#underlord) | [TASK-13.4](../backlog/archive/tasks/task-13.4%20-%20Underlord-standard-hero-ability-pass.md) |
| Alchemist | `alchemist` | Yes | Yes | Pending | — | [Checklist](HERO_PASS_REPORT.md#alchemist) | [TASK-13.5](../backlog/archive/tasks/task-13.5%20-%20Alchemist-standard-hero-ability-pass.md) |
| Ancient Apparition | `ancient_apparition` | Yes | Yes | Pending | Retained | [Checklist](HERO_PASS_REPORT.md#ancient-apparition) | [TASK-13.1](../backlog/archive/tasks/task-13.1%20-%20Ancient-Apparition-Ice-Blast-target-priority-creep-safe-harass-and-Shard-stun.md) |
| Anti-Mage | `antimage` | Yes | Yes | Pending | — | [Checklist](HERO_PASS_REPORT.md#anti-mage) | [TASK-13.6](../backlog/archive/tasks/task-13.6%20-%20Anti-Mage-standard-hero-ability-pass.md) |
| Arc Warden | `arc_warden` | Yes | Yes | Pending | — | [Checklist](HERO_PASS_REPORT.md#arc-warden) | [TASK-13.7](../backlog/archive/tasks/task-13.7%20-%20Arc-Warden-standard-hero-ability-pass.md) |
| Axe | `axe` | Yes | Yes | Pending | — | [Checklist](HERO_PASS_REPORT.md#axe) | [TASK-13.8](../backlog/archive/tasks/task-13.8%20-%20Axe-standard-hero-ability-pass.md) |
| Bane | `bane` | Yes | Yes | Pending | — | [Checklist](HERO_PASS_REPORT.md#bane) | [TASK-13.9](../backlog/archive/tasks/task-13.9%20-%20Bane-standard-hero-ability-pass.md) |
| Batrider | `batrider` | Yes | Yes | Pending | — | [Checklist](HERO_PASS_REPORT.md#batrider) | [TASK-13.10](../backlog/archive/tasks/task-13.10%20-%20Batrider-standard-hero-ability-pass.md) |
| Beastmaster | `beastmaster` | Yes | Yes | Pending | — | [Checklist](HERO_PASS_REPORT.md#beastmaster) | [TASK-13.11](../backlog/archive/tasks/task-13.11%20-%20Beastmaster-standard-hero-ability-pass.md) |
| Bloodseeker | `bloodseeker` | Yes | Yes | Pending | — | [Checklist](HERO_PASS_REPORT.md#bloodseeker) | [TASK-13.13](../backlog/archive/tasks/task-13.13%20-%20Bloodseeker-standard-hero-ability-pass.md) |
| Bounty Hunter | `bounty_hunter` | Yes | Yes | Pending | — | [Checklist](HERO_PASS_REPORT.md#bounty-hunter) | [TASK-13.14](../backlog/archive/tasks/task-13.14%20-%20Bounty-Hunter-standard-hero-ability-pass.md) |
| Brewmaster | `brewmaster` | Yes | Yes | Pending | Retained | [Checklist](HERO_PASS_REPORT.md#brewmaster) | [TASK-13.12](../backlog/archive/tasks/task-13.12%20-%20Brewmaster-standard-hero-ability-pass.md) |
| Bristleback | `bristleback` | Yes | Yes | Pending | — | [Checklist](HERO_PASS_REPORT.md#bristleback) | [TASK-13.15](../backlog/archive/tasks/task-13.15%20-%20Bristleback-standard-hero-ability-pass.md) |
| Broodmother | `broodmother` | Yes | Yes | Pending | — | [Checklist](HERO_PASS_REPORT.md#broodmother) | [TASK-13.16](../backlog/archive/tasks/task-13.16%20-%20Broodmother-standard-hero-ability-pass.md) |
| Centaur | `centaur` | Yes | Yes | Pending | — | [Checklist](HERO_PASS_REPORT.md#centaur) | [TASK-13.17](../backlog/archive/tasks/task-13.17%20-%20Centaur-standard-hero-ability-pass.md) |
| Chaos Knight | `chaos_knight` | Yes | Yes | Pending | — | [Checklist](HERO_PASS_REPORT.md#chaos-knight) | [TASK-13.18](../backlog/archive/tasks/task-13.18%20-%20Chaos-Knight-standard-hero-ability-pass.md) |
| Chen | `chen` | Yes | Yes | Pending | Retained | [Checklist](HERO_PASS_REPORT.md#chen) | [TASK-13.19](../backlog/archive/tasks/task-13.19%20-%20Chen-standard-hero-ability-pass.md) |
| Clinkz | `clinkz` | Yes | Yes | Pending | — | [Checklist](HERO_PASS_REPORT.md#clinkz) | [TASK-13.20](../backlog/archive/tasks/task-13.20%20-%20Clinkz-standard-hero-ability-pass.md) |
| Crystal Maiden | `crystal_maiden` | Yes | Yes | Pending | — | [Checklist](HERO_PASS_REPORT.md#crystal-maiden) | [TASK-13.21](../backlog/archive/tasks/task-13.21%20-%20Crystal-Maiden-standard-hero-ability-pass.md) |
| Dark Seer | `dark_seer` | Yes | Yes | Pending | — | [Checklist](HERO_PASS_REPORT.md#dark-seer) | [TASK-13.22](../backlog/archive/tasks/task-13.22%20-%20Dark-Seer-standard-hero-ability-pass.md) |
| Dark Willow | `dark_willow` | Yes | Yes | Pending | Retained | [Checklist](HERO_PASS_REPORT.md#dark-willow) | [TASK-13.23](../backlog/archive/tasks/task-13.23%20-%20Dark-Willow-standard-hero-ability-pass.md) |
| Dawnbreaker | `dawnbreaker` | Yes | Yes | Pending | — | [Checklist](HERO_PASS_REPORT.md#dawnbreaker) | [TASK-13.24](../backlog/archive/tasks/task-13.24%20-%20Dawnbreaker-standard-hero-ability-pass.md) |
| Dazzle | `dazzle` | Yes | Yes | Pending | — | [Checklist](HERO_PASS_REPORT.md#dazzle) | [TASK-13.2](../backlog/archive/tasks/task-13.2%20-%20Dazzle-standard-ability-pass-saves-and-Shadow-Wave-targeting.md) |
| Death Prophet | `death_prophet` | Yes | Yes | Pending | — | [Checklist](HERO_PASS_REPORT.md#death-prophet) | [TASK-13.25](../backlog/archive/tasks/task-13.25%20-%20Death-Prophet-standard-hero-ability-pass.md) |
| Disruptor | `disruptor` | Yes | Yes | Pending | — | [Checklist](HERO_PASS_REPORT.md#disruptor) | [TASK-13.26](../backlog/archive/tasks/task-13.26%20-%20Disruptor-standard-hero-ability-pass.md) |
| Doom | `doom_bringer` | Yes | Yes | Pending | — | [Checklist](HERO_PASS_REPORT.md#doom) | [TASK-13.27](../backlog/archive/tasks/task-13.27%20-%20Doom-standard-hero-ability-pass.md) |
| Dragon Knight | `dragon_knight` | Yes | Yes | Pending | — | [Checklist](HERO_PASS_REPORT.md#dragon-knight) | [TASK-13.28](../backlog/archive/tasks/task-13.28%20-%20Dragon-Knight-standard-hero-ability-pass.md) |
| Drow Ranger | `drow_ranger` | Yes | Yes | Pending | — | [Checklist](HERO_PASS_REPORT.md#drow-ranger) | [TASK-13.29](../backlog/archive/tasks/task-13.29%20-%20Drow-Ranger-standard-hero-ability-pass.md) |
| Earth Spirit | `earth_spirit` | Yes | Yes | Pending | — | [Checklist](HERO_PASS_REPORT.md#earth-spirit) | [TASK-13.30](../backlog/archive/tasks/task-13.30%20-%20Earth-Spirit-standard-hero-ability-pass.md) |
| Earthshaker | `earthshaker` | Yes | Yes | Pending | — | [Checklist](HERO_PASS_REPORT.md#earthshaker) | [TASK-13.31](../backlog/archive/tasks/task-13.31%20-%20Earthshaker-standard-hero-ability-pass.md) |
| Elder Titan | `elder_titan` | Yes | Yes | Pending | — | [Checklist](HERO_PASS_REPORT.md#elder-titan) | [TASK-13.32](../backlog/archive/tasks/task-13.32%20-%20Elder-Titan-standard-hero-ability-pass.md) |
| Ember Spirit | `ember_spirit` | Yes | Yes | Pending | Retained | [Checklist](HERO_PASS_REPORT.md#ember-spirit) | [TASK-13.33](../backlog/archive/tasks/task-13.33%20-%20Ember-Spirit-standard-hero-ability-pass.md) |
| Enchantress | `enchantress` | Yes | Yes | Pending | — | [Checklist](HERO_PASS_REPORT.md#enchantress) | [TASK-13.38](../backlog/archive/tasks/task-13.38%20-%20Enchantress-standard-hero-ability-pass.md) |
| Enigma | `enigma` | Yes | Yes | Pending | — | [Checklist](HERO_PASS_REPORT.md#enigma) | [TASK-13.42](../backlog/archive/tasks/task-13.42%20-%20Enigma-standard-hero-ability-pass.md) |
| Faceless Void | `faceless_void` | Yes | Yes | Pending | — | [Checklist](HERO_PASS_REPORT.md#faceless-void) | [TASK-13.45](../backlog/archive/tasks/task-13.45%20-%20Faceless-Void-standard-hero-ability-pass.md) |
| Nature's Prophet | `furion` | Yes | Yes | Pending | — | [Checklist](HERO_PASS_REPORT.md#natures-prophet) | [TASK-13.46](../backlog/archive/tasks/task-13.46%20-%20Natures-Prophet-standard-hero-ability-pass.md) |
| Grimstroke | `grimstroke` | Yes | Yes | Pending | — | [Checklist](HERO_PASS_REPORT.md#grimstroke) | [TASK-13.47](../backlog/archive/tasks/task-13.47%20-%20Grimstroke-standard-hero-ability-pass.md) |
| Gyrocopter | `gyrocopter` | Yes | Yes | Pending | — | [Checklist](HERO_PASS_REPORT.md#gyrocopter) | [TASK-13.48](../backlog/archive/tasks/task-13.48%20-%20Gyrocopter-standard-hero-ability-pass.md) |
| Hoodwink | `hoodwink` | Yes | Yes | Pending | Retained | [Checklist](HERO_PASS_REPORT.md#hoodwink) | [TASK-13.49](../backlog/archive/tasks/task-13.49%20-%20Hoodwink-standard-hero-ability-pass.md) |
| Huskar | `huskar` | Yes | Yes | Pending | — | [Checklist](HERO_PASS_REPORT.md#huskar) | [TASK-13.50](../backlog/archive/tasks/task-13.50%20-%20Huskar-standard-hero-ability-pass.md) |
| Invoker | `invoker` | No | No | Deferred | — | [TASK-13.126](../backlog/tasks/task-13.126%20-%20Invoker-standard-hero-ability-pass.md) | — |
| Jakiro | `jakiro` | Yes | Yes | Pending | — | [Checklist](HERO_PASS_REPORT.md#jakiro) | [TASK-13.51](../backlog/archive/tasks/task-13.51%20-%20Jakiro-standard-hero-ability-pass.md) |
| Juggernaut | `juggernaut` | Yes | Yes | Pending | — | [Checklist](HERO_PASS_REPORT.md#juggernaut) | [TASK-13.52](../backlog/archive/tasks/task-13.52%20-%20Juggernaut-standard-hero-ability-pass.md) |
| Keeper of the Light | `keeper_of_the_light` | Yes | Yes | Pending | — | [Checklist](HERO_PASS_REPORT.md#keeper-of-the-light) | [TASK-13.53](../backlog/archive/tasks/task-13.53%20-%20Keeper-of-the-Light-standard-hero-ability-pass.md) |
| Kez | `kez` | Yes | Yes | Pending | — | [Checklist](HERO_PASS_REPORT.md#kez) | [TASK-13.54](../backlog/archive/tasks/task-13.54%20-%20Kez-standard-hero-ability-pass.md) |
| Kunkka | `kunkka` | Yes | Yes | Pending | — | [Checklist](HERO_PASS_REPORT.md#kunkka) | [TASK-13.55](../backlog/archive/tasks/task-13.55%20-%20Kunkka-standard-hero-ability-pass.md) |
| Largo | `largo` | Yes | Yes | Pending | — | [Checklist](HERO_PASS_REPORT.md#largo) | [TASK-13.56](../backlog/archive/tasks/task-13.56%20-%20Largo-standard-hero-ability-pass.md) |
| Legion Commander | `legion_commander` | Yes | Yes | Pending | — | [Checklist](HERO_PASS_REPORT.md#legion-commander) | [TASK-13.57](../backlog/archive/tasks/task-13.57%20-%20Legion-Commander-standard-hero-ability-pass.md) |
| Leshrac | `leshrac` | Yes | Yes | Pending | — | [Checklist](HERO_PASS_REPORT.md#leshrac) | [TASK-13.34](../backlog/archive/tasks/task-13.34%20-%20Leshrac-standard-hero-ability-pass.md) |
| Lich | `lich` | Yes | Yes | Pending | — | [Checklist](HERO_PASS_REPORT.md#lich) | [TASK-13.36](../backlog/archive/tasks/task-13.36%20-%20Lich-standard-hero-ability-pass.md) |
| Lifestealer | `life_stealer` | Yes | Yes | Pending | — | [Checklist](HERO_PASS_REPORT.md#lifestealer) | [TASK-13.39](../backlog/archive/tasks/task-13.39%20-%20Lifestealer-standard-hero-ability-pass.md) |
| Lina | `lina` | Yes | Yes | Pending | — | [Checklist](HERO_PASS_REPORT.md#lina) | [TASK-13.43](../backlog/archive/tasks/task-13.43%20-%20Lina-standard-hero-ability-pass.md) |
| Lion | `lion` | Yes | Yes | Pending | — | [Checklist](HERO_PASS_REPORT.md#lion) | [TASK-13.58](../backlog/archive/tasks/task-13.58%20-%20Lion-standard-hero-ability-pass.md) |
| Lone Druid | `lone_druid` | No | No | Deferred | Retained | [TASK-13.127](../backlog/tasks/task-13.127%20-%20Lone-Druid-standard-hero-ability-pass.md) | — |
| Luna | `luna` | Yes | Yes | Pending | — | [Checklist](HERO_PASS_REPORT.md#luna) | [TASK-13.59](../backlog/archive/tasks/task-13.59%20-%20Luna-standard-hero-ability-pass.md) |
| Lycan | `lycan` | Yes | Yes | Pending | — | [Checklist](HERO_PASS_REPORT.md#lycan) | [TASK-13.60](../backlog/archive/tasks/task-13.60%20-%20Lycan-standard-hero-ability-pass.md) |
| Magnus | `magnataur` | Yes | Yes | Pending | — | [Checklist](HERO_PASS_REPORT.md#magnus) | [TASK-13.61](../backlog/archive/tasks/task-13.61%20-%20Magnus-standard-hero-ability-pass.md) |
| Marci | `marci` | Yes | Yes | Pending | Retained | [Checklist](HERO_PASS_REPORT.md#marci) | [TASK-13.62](../backlog/archive/tasks/task-13.62%20-%20Marci-standard-hero-ability-pass.md) |
| Mars | `mars` | Yes | Yes | Pending | — | [Checklist](HERO_PASS_REPORT.md#mars) | [TASK-13.63](../backlog/archive/tasks/task-13.63%20-%20Mars-standard-hero-ability-pass.md) |
| Medusa | `medusa` | Yes | Yes | Pending | — | [Checklist](HERO_PASS_REPORT.md#medusa) | [TASK-13.64](../backlog/archive/tasks/task-13.64%20-%20Medusa-standard-hero-ability-pass.md) |
| Meepo | `meepo` | Yes | Yes | Pending | — | [Checklist](HERO_PASS_REPORT.md#meepo) | [TASK-13.65](../backlog/archive/tasks/task-13.65%20-%20Meepo-standard-hero-ability-pass.md) |
| Mirana | `mirana` | Yes | Yes | Pending | — | [Checklist](HERO_PASS_REPORT.md#mirana) | [TASK-13.66](../backlog/archive/tasks/task-13.66%20-%20Mirana-standard-hero-ability-pass.md) |
| Monkey King | `monkey_king` | Yes | Yes | Pending | — | [Checklist](HERO_PASS_REPORT.md#monkey-king) | [TASK-13.67](../backlog/archive/tasks/task-13.67%20-%20Monkey-King-standard-hero-ability-pass.md) |
| Morphling | `morphling` | Yes | Yes | Pending | Retained | [Checklist](HERO_PASS_REPORT.md#morphling) | [TASK-13.68](../backlog/archive/tasks/task-13.68%20-%20Morphling-standard-hero-ability-pass.md) |
| Muerta | `muerta` | Yes | Yes | Pending | — | [Checklist](HERO_PASS_REPORT.md#muerta) | [TASK-13.69](../backlog/archive/tasks/task-13.69%20-%20Muerta-standard-hero-ability-pass.md) |
| Naga Siren | `naga_siren` | Yes | Yes | Pending | — | [Checklist](HERO_PASS_REPORT.md#naga-siren) | [TASK-13.35](../backlog/archive/tasks/task-13.35%20-%20Naga-Siren-standard-hero-ability-pass.md) |
| Necrophos | `necrolyte` | Yes | Yes | Pending | — | [Checklist](HERO_PASS_REPORT.md#necrophos) | [TASK-13.37](../backlog/archive/tasks/task-13.37%20-%20Necrophos-standard-hero-ability-pass.md) |
| Shadow Fiend | `nevermore` | Yes | Yes | Pending | — | [Checklist](HERO_PASS_REPORT.md#shadow-fiend) | [TASK-13.40](../backlog/archive/tasks/task-13.40%20-%20Shadow-Fiend-standard-hero-ability-pass.md) |
| Night Stalker | `night_stalker` | Yes | Yes | Pending | — | [Checklist](HERO_PASS_REPORT.md#night-stalker) | [TASK-13.41](../backlog/archive/tasks/task-13.41%20-%20Night-Stalker-standard-hero-ability-pass.md) |
| Nyx Assassin | `nyx_assassin` | Yes | Yes | Pending | — | [Checklist](HERO_PASS_REPORT.md#nyx-assassin) | [TASK-13.44](../backlog/archive/tasks/task-13.44%20-%20Nyx-Assassin-standard-hero-ability-pass.md) |
| Outworld Destroyer | `obsidian_destroyer` | Yes | Yes | Pending | — | [Checklist](HERO_PASS_REPORT.md#outworld-destroyer) | [TASK-13.70](../backlog/archive/tasks/task-13.70%20-%20Outworld-Destroyer-standard-hero-ability-pass.md) |
| Ogre Magi | `ogre_magi` | Yes | Yes | Pending | — | [Checklist](HERO_PASS_REPORT.md#ogre-magi) | [TASK-13.71](../backlog/archive/tasks/task-13.71%20-%20Ogre-Magi-standard-hero-ability-pass.md) |
| Omniknight | `omniknight` | Yes | Yes | Pending | — | [Checklist](HERO_PASS_REPORT.md#omniknight) | [TASK-13.72](../backlog/archive/tasks/task-13.72%20-%20Omniknight-standard-hero-ability-pass.md) |
| Oracle | `oracle` | Yes | Yes | Pending | — | [Checklist](HERO_PASS_REPORT.md#oracle) | [TASK-13.73](../backlog/archive/tasks/task-13.73%20-%20Oracle-standard-hero-ability-pass.md) |
| Pangolier | `pangolier` | Yes | Yes | Pending | Retained | [Checklist](HERO_PASS_REPORT.md#pangolier) | [TASK-13.74](../backlog/archive/tasks/task-13.74%20-%20Pangolier-standard-hero-ability-pass.md) |
| Phantom Assassin | `phantom_assassin` | Yes | Yes | Pending | — | [Checklist](HERO_PASS_REPORT.md#phantom-assassin) | [TASK-13.75](../backlog/archive/tasks/task-13.75%20-%20Phantom-Assassin-standard-hero-ability-pass.md) |
| Phantom Lancer | `phantom_lancer` | Yes | Yes | Pending | — | [Checklist](HERO_PASS_REPORT.md#phantom-lancer) | [TASK-13.76](../backlog/archive/tasks/task-13.76%20-%20Phantom-Lancer-standard-hero-ability-pass.md) |
| Phoenix | `phoenix` | Yes | Yes | Pending | — | [Checklist](HERO_PASS_REPORT.md#phoenix) | [TASK-13.77](../backlog/archive/tasks/task-13.77%20-%20Phoenix-standard-hero-ability-pass.md) |
| Primal Beast | `primal_beast` | Yes | Yes | Pending | Retained | [Checklist](HERO_PASS_REPORT.md#primal-beast) | [TASK-13.78](../backlog/archive/tasks/task-13.78%20-%20Primal-Beast-standard-hero-ability-pass.md) |
| Puck | `puck` | Yes | Yes | Pending | Retained | [Checklist](HERO_PASS_REPORT.md#puck) | [TASK-13.79](../backlog/archive/tasks/task-13.79%20-%20Puck-standard-hero-ability-pass.md) |
| Pudge | `pudge` | Yes | Yes | Pending | — | [Checklist](HERO_PASS_REPORT.md#pudge) | [TASK-13.80](../backlog/archive/tasks/task-13.80%20-%20Pudge-standard-hero-ability-pass.md) |
| Pugna | `pugna` | Yes | Yes | Pending | — | [Checklist](HERO_PASS_REPORT.md#pugna) | [TASK-13.81](../backlog/archive/tasks/task-13.81%20-%20Pugna-standard-hero-ability-pass.md) |
| Queen of Pain | `queenofpain` | Yes | Yes | Pending | — | [Checklist](HERO_PASS_REPORT.md#queen-of-pain) | [TASK-13.82](../backlog/archive/tasks/task-13.82%20-%20Queen-of-Pain-standard-hero-ability-pass.md) |
| Clockwerk | `rattletrap` | Yes | Yes | Pending | — | [Checklist](HERO_PASS_REPORT.md#clockwerk) | [TASK-13.87](../backlog/archive/tasks/task-13.87%20-%20Clockwerk-standard-hero-ability-pass.md) |
| Razor | `razor` | Yes | Yes | Pending | — | [Checklist](HERO_PASS_REPORT.md#razor) | [TASK-13.90](../backlog/archive/tasks/task-13.90%20-%20Razor-standard-hero-ability-pass.md) |
| Riki | `riki` | Yes | Yes | Pending | — | [Checklist](HERO_PASS_REPORT.md#riki) | [TASK-13.94](../backlog/archive/tasks/task-13.94%20-%20Riki-standard-hero-ability-pass.md) |
| Ringmaster | `ringmaster` | Yes | Yes | Pending | — | [Checklist](HERO_PASS_REPORT.md#ringmaster) | [TASK-13.96](../backlog/archive/tasks/task-13.96%20-%20Ringmaster-standard-hero-ability-pass.md) |
| Rubick | `rubick` | No | No | Deferred | Retained | [TASK-13.128](../backlog/tasks/task-13.128%20-%20Rubick-standard-hero-ability-pass.md) | — |
| Sand King | `sand_king` | Yes | Yes | Pending | — | [Checklist](HERO_PASS_REPORT.md#sand-king) | [TASK-13.100](../backlog/archive/tasks/task-13.100%20-%20Sand-King-standard-hero-ability-pass.md) |
| Shadow Demon | `shadow_demon` | Yes | Yes | Pending | — | [Checklist](HERO_PASS_REPORT.md#shadow-demon) | [TASK-13.104](../backlog/archive/tasks/task-13.104%20-%20Shadow-Demon-standard-hero-ability-pass.md) |
| Shadow Shaman | `shadow_shaman` | Yes | Yes | Pending | — | [Checklist](HERO_PASS_REPORT.md#shadow-shaman) | [TASK-13.105](../backlog/archive/tasks/task-13.105%20-%20Shadow-Shaman-standard-hero-ability-pass.md) |
| Timbersaw | `shredder` | Yes | Yes | Pending | — | [Checklist](HERO_PASS_REPORT.md#timbersaw) | [TASK-13.111](../backlog/archive/tasks/task-13.111%20-%20Timbersaw-standard-hero-ability-pass.md) |
| Silencer | `silencer` | Yes | Yes | Pending | — | [Checklist](HERO_PASS_REPORT.md#silencer) | [TASK-13.115](../backlog/archive/tasks/task-13.115%20-%20Silencer-standard-hero-ability-pass.md) |
| Wraith King | `skeleton_king` | Yes | Yes | Pending | — | [Checklist](HERO_PASS_REPORT.md#wraith-king) | [TASK-13.118](../backlog/archive/tasks/task-13.118%20-%20Wraith-King-standard-hero-ability-pass.md) |
| Skywrath Mage | `skywrath_mage` | Yes | Yes | Pending | — | [Checklist](HERO_PASS_REPORT.md#skywrath-mage) | [TASK-13.120](../backlog/archive/tasks/task-13.120%20-%20Skywrath-Mage-standard-hero-ability-pass.md) |
| Slardar | `slardar` | Yes | Yes | Pending | — | [Checklist](HERO_PASS_REPORT.md#slardar) | [TASK-13.108](../backlog/archive/tasks/task-13.108%20-%20Slardar-standard-hero-ability-pass.md) |
| Slark | `slark` | Yes | Yes | Pending | — | [Checklist](HERO_PASS_REPORT.md#slark) | [TASK-13.109](../backlog/archive/tasks/task-13.109%20-%20Slark-standard-hero-ability-pass.md) |
| Snapfire | `snapfire` | Yes | Yes | Pending | — | [Checklist](HERO_PASS_REPORT.md#snapfire) | [TASK-13.83](../backlog/archive/tasks/task-13.83%20-%20Snapfire-standard-hero-ability-pass.md) |
| Sniper | `sniper` | Yes | Yes | Pending | — | [Checklist](HERO_PASS_REPORT.md#sniper) | [TASK-13.86](../backlog/archive/tasks/task-13.86%20-%20Sniper-standard-hero-ability-pass.md) |
| Spectre | `spectre` | Yes | Yes | Pending | — | [Checklist](HERO_PASS_REPORT.md#spectre) | [TASK-13.88](../backlog/archive/tasks/task-13.88%20-%20Spectre-standard-hero-ability-pass.md) |
| Spirit Breaker | `spirit_breaker` | Yes | Yes | Pending | — | [Checklist](HERO_PASS_REPORT.md#spirit-breaker) | [TASK-13.93](../backlog/archive/tasks/task-13.93%20-%20Spirit-Breaker-standard-hero-ability-pass.md) |
| Storm Spirit | `storm_spirit` | Yes | Yes | Pending | — | [Checklist](HERO_PASS_REPORT.md#storm-spirit) | [TASK-13.97](../backlog/archive/tasks/task-13.97%20-%20Storm-Spirit-standard-hero-ability-pass.md) |
| Sven | `sven` | Yes | Yes | Pending | — | [Checklist](HERO_PASS_REPORT.md#sven) | [TASK-13.101](../backlog/archive/tasks/task-13.101%20-%20Sven-standard-hero-ability-pass.md) |
| Techies | `techies` | Yes | Yes | Pending | — | [Checklist](HERO_PASS_REPORT.md#techies) | [TASK-13.103](../backlog/archive/tasks/task-13.103%20-%20Techies-standard-hero-ability-pass.md) |
| Templar Assassin | `templar_assassin` | Yes | Yes | Pending | — | [Checklist](HERO_PASS_REPORT.md#templar-assassin) | [TASK-13.106](../backlog/archive/tasks/task-13.106%20-%20Templar-Assassin-standard-hero-ability-pass.md) |
| Terrorblade | `terrorblade` | Yes | Yes | Pending | — | [Checklist](HERO_PASS_REPORT.md#terrorblade) | [TASK-13.112](../backlog/archive/tasks/task-13.112%20-%20Terrorblade-standard-hero-ability-pass.md) |
| Tidehunter | `tidehunter` | Yes | Yes | Pending | — | [Checklist](HERO_PASS_REPORT.md#tidehunter) | [TASK-13.113](../backlog/archive/tasks/task-13.113%20-%20Tidehunter-standard-hero-ability-pass.md) |
| Tinker | `tinker` | Yes | Yes | Pending | Retained | [Checklist](HERO_PASS_REPORT.md#tinker) | [TASK-13.116](../backlog/archive/tasks/task-13.116%20-%20Tinker-standard-hero-ability-pass.md) |
| Tiny | `tiny` | Yes | Yes | Pending | — | [Checklist](HERO_PASS_REPORT.md#tiny) | [TASK-13.119](../backlog/archive/tasks/task-13.119%20-%20Tiny-standard-hero-ability-pass.md) |
| Treant Protector | `treant` | Yes | Yes | Pending | — | [Checklist](HERO_PASS_REPORT.md#treant-protector) | [TASK-13.124](../backlog/archive/tasks/task-13.124%20-%20Treant-Protector-standard-hero-ability-pass.md) |
| Troll Warlord | `troll_warlord` | Yes | Yes | Pending | — | [Checklist](HERO_PASS_REPORT.md#troll-warlord) | [TASK-13.123](../backlog/archive/tasks/task-13.123%20-%20Troll-Warlord-standard-hero-ability-pass.md) |
| Tusk | `tusk` | Yes | Yes | Pending | Retained | [Checklist](HERO_PASS_REPORT.md#tusk) | [TASK-13.84](../backlog/archive/tasks/task-13.84%20-%20Tusk-standard-hero-ability-pass.md) |
| Undying | `undying` | Yes | Yes | Pending | — | [Checklist](HERO_PASS_REPORT.md#undying) | [TASK-13.85](../backlog/archive/tasks/task-13.85%20-%20Undying-standard-hero-ability-pass.md) |
| Ursa | `ursa` | Yes | Yes | Pending | — | [Checklist](HERO_PASS_REPORT.md#ursa) | [TASK-13.89](../backlog/archive/tasks/task-13.89%20-%20Ursa-standard-hero-ability-pass.md) |
| Vengeful Spirit | `vengefulspirit` | Yes | Yes | Pending | — | [Checklist](HERO_PASS_REPORT.md#vengeful-spirit) | [TASK-13.91](../backlog/archive/tasks/task-13.91%20-%20Vengeful-Spirit-standard-hero-ability-pass.md) |
| Venomancer | `venomancer` | Yes | Yes | Pending | — | [Checklist](HERO_PASS_REPORT.md#venomancer) | [TASK-13.95](../backlog/archive/tasks/task-13.95%20-%20Venomancer-standard-hero-ability-pass.md) |
| Viper | `viper` | Yes | Yes | Pending | — | [Checklist](HERO_PASS_REPORT.md#viper) | [TASK-13.99](../backlog/archive/tasks/task-13.99%20-%20Viper-standard-hero-ability-pass.md) |
| Visage | `visage` | Yes | Yes | Pending | Retained | [Checklist](HERO_PASS_REPORT.md#visage) | [TASK-13.102](../backlog/archive/tasks/task-13.102%20-%20Visage-standard-hero-ability-pass.md) |
| Void Spirit | `void_spirit` | Yes | Yes | Pending | Retained | [Checklist](HERO_PASS_REPORT.md#void-spirit) | [TASK-13.107](../backlog/archive/tasks/task-13.107%20-%20Void-Spirit-standard-hero-ability-pass.md) |
| Warlock | `warlock` | Yes | Yes | Pending | — | [Checklist](HERO_PASS_REPORT.md#warlock) | [TASK-13.110](../backlog/archive/tasks/task-13.110%20-%20Warlock-standard-hero-ability-pass.md) |
| Weaver | `weaver` | Yes | Yes | Pending | — | [Checklist](HERO_PASS_REPORT.md#weaver) | [TASK-13.114](../backlog/archive/tasks/task-13.114%20-%20Weaver-standard-hero-ability-pass.md) |
| Windranger | `windrunner` | Yes | Yes | Pending | — | [Checklist](HERO_PASS_REPORT.md#windranger) | [TASK-13.117](../backlog/archive/tasks/task-13.117%20-%20Windranger-standard-hero-ability-pass.md) |
| Winter Wyvern | `winter_wyvern` | Yes | Yes | Pending | — | [Checklist](HERO_PASS_REPORT.md#winter-wyvern) | [TASK-13.121](../backlog/archive/tasks/task-13.121%20-%20Winter-Wyvern-standard-hero-ability-pass.md) |
| Io | `wisp` | Yes | Yes | Pending | Retained | [Checklist](HERO_PASS_REPORT.md#io) | [TASK-13.122](../backlog/archive/tasks/task-13.122%20-%20Io-standard-hero-ability-pass.md) |
| Witch Doctor | `witch_doctor` | Yes | Yes | Pending | — | [Checklist](HERO_PASS_REPORT.md#witch-doctor) | [TASK-13.92](../backlog/archive/tasks/task-13.92%20-%20Witch-Doctor-standard-hero-ability-pass.md) |
| Zeus | `zuus` | Yes | Yes | Pending | — | [Checklist](HERO_PASS_REPORT.md#zeus) | [TASK-13.98](../backlog/archive/tasks/task-13.98%20-%20Zeus-standard-hero-ability-pass.md) |

## Lobby results

No lobby results have been recorded for this campaign. Existing offline checks and historical observations are preserved in the report; they do not satisfy the pending lobby checklists.

Add a dated batch entry with hero names, game patch/settings, tested scenarios, observations, evidence links and linked follow-up tasks. Update each row only to reflect that evidence.
