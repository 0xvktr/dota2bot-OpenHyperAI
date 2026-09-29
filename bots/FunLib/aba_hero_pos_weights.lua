--[[ Generated with https://github.com/TypeScriptToLua/TypeScriptToLua ]]
local ____exports = {}
local ____heroes = require(GetScriptDirectory().."/ts_libs/dota/heroes")
local HeroName = ____heroes.HeroName
local HeroPositions = {
    -- Migrated (D2PT 7.41f) weights: round(30 + rating * min(1, sqrt(matches / 2000))); see the TypeScript source.
    [HeroName.Abaddon] = {36, 0, 37, 38, 55},
    [HeroName.Underlord] = {0, 0, 54, 0, 0},
    [HeroName.Alchemist] = {44, 0, 0, 0, 0},
    [HeroName.AncientApparition] = {0, 0, 0, 0, 67},
    [HeroName.Antimage] = {94, 0, 0, 0, 0},
    [HeroName.ArcWarden] = {0, 74, 0, 0, 0},
    [HeroName.Axe] = {0, 0, 100, 0, 0},
    [HeroName.Bane] = {0, 0, 0, 48, 71},
    [HeroName.Batrider] = {0, 42, 42, 0, 0},
    [HeroName.Beastmaster] = {0, 43, 65, 0, 0},
    [HeroName.Bloodseeker] = {46, 0, 0, 0, 0},
    [HeroName.BountyHunter] = {0, 0, 0, 100, 67},
    [HeroName.Brewmaster] = {0, 37, 84, 0, 0},
    [HeroName.Bristleback] = {36, 0, 43, 0, 0},
    [HeroName.Broodmother] = {43, 51, 40, 0, 0},
    [HeroName.Centaur] = {0, 0, 69, 0, 0},
    [HeroName.ChaosKnight] = {47, 0, 53, 0, 0},
    [HeroName.Chen] = {0, 0, 0, 0, 49},
    [HeroName.Clinkz] = {77, 46, 0, 0, 0},
    [HeroName.CrystalMaiden] = {0, 36, 0, 51, 78},
    [HeroName.DarkSeer] = {0, 0, 99, 0, 0},
    [HeroName.DarkWillow] = {0, 0, 0, 75, 80},
    [HeroName.Dawnbreaker] = {0, 42, 98, 0, 0},
    [HeroName.Dazzle] = {0, 0, 0, 39, 100},
    [HeroName.DeathProphet] = {0, 51, 56, 0, 0}, -- D2PT 7.41f; mid/offlane only.
    [HeroName.Disruptor] = {0, 0, 0, 42, 100}, -- D2PT 7.41f
    [HeroName.Doom] = {38, 0, 86, 0, 0}, -- D2PT 7.41f
    [HeroName.DragonKnight] = {52, 100, 93, 0, 0}, -- D2PT 7.41f
    [HeroName.DrowRanger] = {59, 0, 0, 0, 0}, -- D2PT 7.41f
    [HeroName.EarthSpirit] = {0, 87, 55, 68, 0}, -- D2PT 7.41f
    [HeroName.Earthshaker] = {0, 80, 58, 68, 0}, -- D2PT 7.41f
    [HeroName.ElderTitan] = {0, 0, 41, 40, 49}, -- D2PT 7.41f
    [HeroName.EmberSpirit] = {0, 100, 0, 0, 0}, -- D2PT 7.41f
    [HeroName.Enchantress] = {0, 0, 48, 41, 52}, -- D2PT 7.41f
    [HeroName.Enigma] = {0, 0, 100, 0, 0}, -- D2PT 7.41f
    [HeroName.FacelessVoid] = {72, 0, 0, 0, 0}, -- D2PT 7.41f
    [HeroName.NaturesProphet] = {55, 47, 45, 37, 36}, -- D2PT 7.41f
    [HeroName.Grimstroke] = {0, 0, 0, 80, 84}, -- D2PT 7.41f
    [HeroName.Gyrocopter] = {44, 0, 0, 46, 43}, -- D2PT 7.41f
    [HeroName.Hoodwink] = {0, 0, 0, 47, 63}, -- D2PT 7.41f
    [HeroName.Huskar] = {0, 71, 0, 0, 0}, -- D2PT 7.41f
    [HeroName.Invoker] = {
        30,
        70,
        10,
        30,
        0
    },
    [HeroName.Jakiro] = {0, 0, 0, 35, 38}, -- D2PT 7.41f
    [HeroName.Juggernaut] = {94, 0, 0, 0, 0}, -- D2PT 7.41f
    [HeroName.KeeperOfTheLight] = {0, 96, 0, 62, 0}, -- D2PT 7.41f
    [HeroName.Kunkka] = {0, 47, 58, 0, 0}, -- D2PT 7.41f
    [HeroName.Largo] = {0, 44, 47, 46, 48}, -- D2PT 7.41f
    [HeroName.LegionCommander] = {0, 0, 97, 0, 0}, -- D2PT 7.41f
    [HeroName.Leshrac] = {0, 63, 0, 0, 0}, -- D2PT 7.41f
    [HeroName.Lich] = {0, 0, 0, 40, 94}, -- D2PT 7.41f
    [HeroName.Lifestealer] = {92, 0, 0, 0, 0}, -- D2PT 7.41f
    [HeroName.Lina] = {42, 85, 0, 0, 0}, -- D2PT 7.41f
    [HeroName.Lion] = {0, 53, 0, 85, 90}, -- D2PT 7.41f
    [HeroName.LoneDruid] = {
        20,
        25,
        15,
        0,
        0
    },
    [HeroName.Luna] = {94, 0, 0, 0, 0}, -- D2PT 7.41f
    [HeroName.Lycan] = {0, 0, 66, 0, 0}, -- D2PT 7.41f
    [HeroName.Magnus] = {0, 55, 78, 0, 0}, -- D2PT 7.41f
    [HeroName.Marci] = {
        0,
        5,
        20,
        20,
        15
    },
    [HeroName.Mars] = {
        5,
        55,
        55,
        5,
        0
    },
    [HeroName.Medusa] = {
        50,
        65,
        5,
        0,
        0
    },
    [HeroName.Meepo] = {
        20,
        20,
        5,
        0,
        0
    },
    [HeroName.Mirana] = {
        10,
        65,
        10,
        65,
        20
    },
    [HeroName.MonkeyKing] = {
        50,
        35,
        45,
        0,
        0
    },
    [HeroName.Morphling] = {
        20,
        15,
        5,
        0,
        0
    },
    [HeroName.Muerta] = {
        35,
        5,
        5,
        15,
        5
    },
    [HeroName.NagaSiren] = {
        45,
        25,
        20,
        10,
        0
    },
    [HeroName.Necrophos] = {
        5,
        60,
        30,
        5,
        0
    },
    [HeroName.ShadowFiend] = {
        45,
        80,
        5,
        0,
        0
    },
    [HeroName.NightStalker] = {
        25,
        35,
        55,
        25,
        0
    },
    [HeroName.NyxAssassin] = {
        0,
        5,
        40,
        65,
        20
    },
    [HeroName.Ringmaster] = {
        5,
        20,
        5,
        50,
        20
    },
    [HeroName.OutworldDestroyer] = {
        5,
        90,
        5,
        0,
        0
    },
    [HeroName.OgreMagi] = {
        20,
        55,
        40,
        40,
        45
    },
    [HeroName.Omniknight] = {
        40,
        5,
        50,
        30,
        55
    },
    [HeroName.Oracle] = {
        0,
        35,
        10,
        30,
        45
    },
    [HeroName.Pangolier] = {
        5,
        25,
        15,
        5,
        0
    },
    [HeroName.PhantomAssassin] = {
        70,
        25,
        5,
        0,
        0
    },
    [HeroName.PhantomLancer] = {
        50,
        45,
        5,
        0,
        0
    },
    [HeroName.Phoenix] = {
        0,
        35,
        30,
        65,
        20
    },
    [HeroName.PrimalBeast] = {
        5,
        5,
        25,
        5,
        0
    },
    [HeroName.Puck] = {
        5,
        70,
        25,
        10,
        10
    },
    [HeroName.Pudge] = {
        5,
        35,
        50,
        25,
        5
    },
    [HeroName.Pugna] = {
        0,
        35,
        20,
        65,
        20
    },
    [HeroName.QueenOfPain] = {
        25,
        50,
        25,
        20,
        0
    },
    [HeroName.Clockwerk] = {
        5,
        5,
        55,
        35,
        10
    },
    [HeroName.Razor] = {
        5,
        85,
        5,
        5,
        0
    },
    [HeroName.Riki] = {
        55,
        10,
        20,
        15,
        10
    },
    [HeroName.Rubick] = {
        0,
        35,
        20,
        40,
        45
    },
    [HeroName.SandKing] = {
        5,
        35,
        65,
        25,
        0
    },
    [HeroName.ShadowDeamon] = {
        0,
        15,
        10,
        30,
        55
    },
    [HeroName.ShadowShaman] = {
        0,
        20,
        20,
        45,
        55
    },
    [HeroName.Timbersaw] = {
        5,
        25,
        65,
        5,
        0
    },
    [HeroName.Silencer] = {
        10,
        55,
        10,
        30,
        35
    },
    [HeroName.WraithKing] = {
        50,
        5,
        45,
        0,
        0
    },
    [HeroName.SkywrathMage] = {
        0,
        45,
        10,
        65,
        20
    },
    [HeroName.Slardar] = {
        35,
        5,
        55,
        5,
        0
    },
    [HeroName.Slark] = {
        90,
        5,
        5,
        0,
        0
    },
    [HeroName.Snapfire] = {
        20,
        35,
        30,
        60,
        15
    },
    [HeroName.Sniper] = {
        70,
        65,
        5,
        0,
        0
    },
    [HeroName.Spectre] = {
        70,
        5,
        5,
        0,
        0
    },
    [HeroName.SpiritBreaker] = {
        0,
        5,
        20,
        20,
        15
    },
    [HeroName.StormSpirit] = {
        25,
        30,
        5,
        0,
        0
    },
    [HeroName.Sven] = {
        60,
        5,
        35,
        0,
        0
    },
    [HeroName.Techies] = {
        10,
        35,
        20,
        40,
        15
    },
    [HeroName.TemplarAssassin] = {
        5,
        90,
        5,
        0,
        0
    },
    [HeroName.Terrorblade] = {
        90,
        5,
        5,
        0,
        0
    },
    [HeroName.Tidehunter] = {
        25,
        25,
        45,
        5,
        0
    },
    [HeroName.Tinker] = {
        5,
        15,
        5,
        20,
        0
    },
    [HeroName.Tiny] = {
        5,
        25,
        65,
        5,
        0
    },
    [HeroName.TreantProtector] = {
        0,
        5,
        10,
        30,
        55
    },
    [HeroName.TrollWarlord] = {
        90,
        5,
        25,
        0,
        0
    },
    [HeroName.Tusk] = {
        0,
        20,
        35,
        40,
        15
    },
    [HeroName.Undying] = {
        0,
        5,
        30,
        30,
        55
    },
    [HeroName.Ursa] = {
        50,
        25,
        25,
        0,
        0
    },
    [HeroName.VengefulSpirit] = {
        0,
        5,
        10,
        30,
        55
    },
    [HeroName.Venomancer] = {
        35,
        55,
        45,
        35,
        30
    },
    [HeroName.Viper] = {
        45,
        65,
        45,
        5,
        0
    },
    [HeroName.Visage] = {
        5,
        15,
        25,
        5,
        0
    },
    [HeroName.VoidSpirit] = {
        15,
        30,
        15,
        0,
        0
    },
    [HeroName.Warlock] = {
        0,
        35,
        0,
        70,
        70
    },
    [HeroName.Weaver] = {
        35,
        15,
        10,
        45,
        15
    },
    [HeroName.Windrunner] = {
        5,
        45,
        45,
        5,
        0
    },
    [HeroName.WinterWyvern] = {
        0,
        35,
        10,
        20,
        25
    },
    [HeroName.IO] = {
        0,
        5,
        10,
        25,
        20
    },
    [HeroName.WitchDoctor] = {
        0,
        5,
        10,
        35,
        55
    },
    [HeroName.Zeus] = {
        25,
        60,
        15,
        40,
        20
    },
    [HeroName.Kez] = {
        50,
        40,
        5,
        0,
        0
    },
}
function ____exports.GetHeroPositions()
    return HeroPositions
end
return ____exports
