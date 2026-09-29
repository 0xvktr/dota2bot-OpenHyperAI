import { HeroName } from "bots/ts_libs/dota/heroes";
type HeroPositionMap = {
    [key: string]: number[];
};

// Hero names: https://github.com/forest0xia/dota2bot-OpenHyperAI/discussions/71
// Entries marked "D2PT 7.41f" are migrated: each updated role's weight is
//   round(30 + rating * min(1, sqrt(matches / 2000))), capped at 100,
// from the D2PT role rating and role matches recorded in bots/BotLib/Builds/<hero>.lua; skipped roles are 0.
// 30 is the freshness baseline for an updated build. Roles with 2000+ matches get the full rating; smaller
// samples count for less, because D2PT's rating rewards a high win rate on a handful of games.
// Unmarked entries are the original hand-tuned weights.
const HeroPositions: HeroPositionMap = {
    [HeroName.Abaddon]: [36, 0, 37, 38, 55], // D2PT 7.41f
    [HeroName.Underlord]: [0, 0, 54, 0, 0], // D2PT 7.41f
    [HeroName.Alchemist]: [44, 0, 0, 0, 0], // D2PT 7.41f
    [HeroName.AncientApparition]: [0, 0, 0, 0, 67], // D2PT 7.41f
    [HeroName.Antimage]: [94, 0, 0, 0, 0], // D2PT 7.41f
    [HeroName.ArcWarden]: [0, 74, 0, 0, 0], // D2PT 7.41f
    [HeroName.Axe]: [0, 0, 100, 0, 0], // D2PT 7.41f
    [HeroName.Bane]: [0, 0, 0, 48, 71], // D2PT 7.41f
    [HeroName.Batrider] : [0, 42, 42, 0, 0], // D2PT 7.41f
    [HeroName.Beastmaster]: [0, 43, 65, 0, 0], // D2PT 7.41f
    [HeroName.Bloodseeker]: [46, 0, 0, 0, 0], // D2PT 7.41f
    [HeroName.BountyHunter]: [0, 0, 0, 100, 67], // D2PT 7.41f
    [HeroName.Brewmaster]: [0, 37, 84, 0, 0], // D2PT 7.41f
    [HeroName.Bristleback]: [36, 0, 43, 0, 0], // D2PT 7.41f
    [HeroName.Broodmother]: [43, 51, 40, 0, 0], // D2PT 7.41f
    [HeroName.Centaur]: [0, 0, 69, 0, 0], // D2PT 7.41f
    [HeroName.ChaosKnight]: [47, 0, 53, 0, 0], // D2PT 7.41f
    [HeroName.Chen]: [0, 0, 0, 0, 49], // D2PT 7.41f
    [HeroName.Clinkz]: [77, 46, 0, 0, 0], // D2PT 7.41f
    [HeroName.CrystalMaiden]: [0, 36, 0, 51, 78], // D2PT 7.41f
    [HeroName.DarkSeer]: [0, 0, 99, 0, 0], // D2PT 7.41f
    [HeroName.DarkWillow]: [0, 0, 0, 75, 80], // D2PT 7.41f
    [HeroName.Dawnbreaker]: [0, 42, 98, 0, 0], // D2PT 7.41f
    [HeroName.Dazzle]: [0, 0, 0, 39, 100], // D2PT 7.41f
    [HeroName.DeathProphet]: [5, 60, 40, 5, 0],
    [HeroName.Disruptor]: [0, 5, 10, 30, 55],
    [HeroName.Doom]: [15, 25, 85, 5, 0],
    [HeroName.DragonKnight]: [55, 70, 35, 10, 0],
    [HeroName.DrowRanger]: [70, 35, 5, 0, 0],
    [HeroName.EarthSpirit]: [0, 5, 30, 70, 15],
    [HeroName.Earthshaker]: [0, 5, 35, 70, 15],
    [HeroName.ElderTitan]: [0, 5, 20, 30, 15],
    [HeroName.EmberSpirit]: [15, 70, 15, 0, 0],
    [HeroName.Enchantress]: [0, 5, 20, 35, 50],
    [HeroName.Enigma]: [0, 35, 65, 30, 0],
    [HeroName.FacelessVoid]: [60, 0, 25, 5, 0],
    [HeroName.NaturesProphet]: [75, 25, 80, 60, 0],
    [HeroName.Grimstroke]: [0, 5, 10, 35, 50],
    [HeroName.Gyrocopter]: [60, 5, 25, 20, 10],
    [HeroName.Hoodwink]: [0, 5, 10, 25, 20],
    [HeroName.Huskar]: [35, 50, 35, 0, 0],
    [HeroName.Invoker]: [30, 70, 10, 30, 0],
    [HeroName.Jakiro]: [0, 35, 30, 60, 65],
    [HeroName.Juggernaut]: [80, 15, 15, 0, 0],
    [HeroName.KeeperOfTheLight]: [0, 15, 10, 25, 25],
    [HeroName.Kunkka]: [35, 85, 35, 5, 0],
    [HeroName.LegionCommander]: [5, 35, 65, 5, 0],
    [HeroName.Leshrac]: [15, 30, 25, 25, 20],
    [HeroName.Lich]: [10, 35, 20, 80, 80],
    [HeroName.Lifestealer]: [20, 0, 20, 0, 0],
    [HeroName.Lina]: [75, 70, 5, 66, 30],
    [HeroName.Lion]: [30, 45, 10, 30, 45],
    [HeroName.LoneDruid]: [20, 25, 15, 0, 0],
    [HeroName.Luna]: [70, 5, 15, 0, 0],
    [HeroName.Lycan]: [45, 45, 45, 5, 0],
    [HeroName.Magnus]: [5, 15, 85, 5, 0],
    [HeroName.Marci]: [0, 5, 20, 20, 15],
    [HeroName.Mars]: [5, 55, 55, 5, 0],
    [HeroName.Medusa]: [50, 65, 5, 0, 0],
    [HeroName.Meepo]: [20, 20, 5, 0, 0],
    [HeroName.Mirana]: [10, 65, 10, 65, 20],
    [HeroName.MonkeyKing]: [50, 35, 45, 0, 0],
    [HeroName.Morphling]: [20, 15, 5, 0, 0],
    [HeroName.Muerta]: [35, 5, 5, 15, 5],
    [HeroName.NagaSiren]: [45, 25, 20, 10, 0],
    [HeroName.Necrophos]: [5, 60, 30, 5, 0],
    [HeroName.ShadowFiend]: [45, 80, 5, 0, 0],
    [HeroName.NightStalker]: [25, 35, 55, 25, 0],
    [HeroName.NyxAssassin]: [0, 5, 40, 65, 20],
    [HeroName.Ringmaster]: [5, 20, 5, 50, 20],
    [HeroName.OutworldDestroyer]: [5, 90, 5, 0, 0],
    [HeroName.OgreMagi]: [20, 55, 40, 40, 45],
    [HeroName.Omniknight]: [40, 5, 50, 30, 55],
    [HeroName.Oracle]: [0, 35, 10, 30, 45],
    [HeroName.Pangolier]: [5, 25, 15, 5, 0],
    [HeroName.PhantomAssassin]: [70, 25, 5, 0, 0],
    [HeroName.PhantomLancer]: [50, 45, 5, 0, 0],
    [HeroName.Phoenix]: [0, 35, 30, 65, 20],
    [HeroName.PrimalBeast]: [5, 5, 25, 5, 0],
    [HeroName.Puck]: [5, 70, 25, 10, 10],
    [HeroName.Pudge]: [5, 35, 50, 25, 5],
    [HeroName.Pugna]: [0, 35, 20, 65, 20],
    [HeroName.QueenOfPain]: [25, 50, 25, 20, 0],
    [HeroName.Clockwerk]: [5, 5, 55, 35, 10],
    [HeroName.Razor]: [5, 85, 5, 5, 0],
    [HeroName.Riki]: [55, 10, 20, 15, 10],
    [HeroName.Rubick]: [0, 35, 20, 40, 45],
    [HeroName.SandKing]: [5, 35, 65, 25, 0],
    [HeroName.ShadowDeamon]: [0, 15, 10, 30, 55],
    [HeroName.ShadowShaman]: [0, 20, 20, 45, 55],
    [HeroName.Timbersaw]: [5, 25, 65, 5, 0],
    [HeroName.Silencer]: [10, 55, 10, 30, 35],
    [HeroName.WraithKing]: [50, 5, 45, 0, 0],
    [HeroName.SkywrathMage]: [0, 45, 10, 65, 20],
    [HeroName.Slardar]: [35, 5, 55, 5, 0],
    [HeroName.Slark]: [90, 5, 5, 0, 0],
    [HeroName.Snapfire]: [20, 35, 30, 60, 15],
    [HeroName.Sniper]: [70, 65, 5, 0, 0],
    [HeroName.Spectre]: [70, 5, 5, 0, 0],
    [HeroName.SpiritBreaker]: [0, 5, 20, 20, 15],
    [HeroName.StormSpirit]: [25, 30, 5, 0, 0],
    [HeroName.Sven]: [60, 5, 35, 0, 0],
    [HeroName.Techies]: [10, 35, 20, 40, 15],
    [HeroName.TemplarAssassin]: [5, 90, 5, 0, 0],
    [HeroName.Terrorblade]: [90, 5, 5, 0, 0],
    [HeroName.Tidehunter]: [25, 25, 45, 5, 0],
    [HeroName.Tinker]: [5, 15, 5, 20, 0],
    [HeroName.Tiny]: [5, 25, 65, 5, 0],
    [HeroName.TreantProtector]: [0, 5, 10, 30, 55],
    [HeroName.TrollWarlord]: [90, 5, 25, 0, 0],
    [HeroName.Tusk]: [0, 20, 35, 40, 15],
    [HeroName.Undying]: [0, 5, 30, 30, 55],
    [HeroName.Ursa]: [50, 25, 25, 0, 0],
    [HeroName.VengefulSpirit]: [0, 5, 10, 30, 55],
    [HeroName.Venomancer]: [35, 55, 45, 35, 30],
    [HeroName.Viper]: [45, 65, 45, 5, 0],
    [HeroName.Visage]: [5, 15, 25, 5, 0],
    [HeroName.VoidSpirit]: [15, 30, 15, 0, 0],
    [HeroName.Warlock]: [0, 35, 0, 70, 70],
    [HeroName.Weaver]: [35, 15, 10, 45, 15],
    [HeroName.Windrunner]: [5, 45, 45, 5, 0],
    [HeroName.WinterWyvern]: [0, 35, 10, 20, 25],
    [HeroName.IO]: [0, 5, 10, 25, 20],
    [HeroName.WitchDoctor]: [0, 5, 10, 35, 55],
    [HeroName.Zeus]: [25, 60, 15, 40, 20],
    [HeroName.Kez]: [50, 40, 5, 0, 0],
    [HeroName.Largo]: [0, 5, 0, 40, 40],
};

export function GetHeroPositions(): HeroPositionMap {
    return HeroPositions;
}
