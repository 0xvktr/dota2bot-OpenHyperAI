-- An unsupported spell must reach the next handler or generic fallback,
-- without evaluating another hero's state or requiring its linked abilities.
local heroes = {'ember_spirit', 'enchantress', 'enigma', 'faceless_void', 'furion', 'grimstroke', 'gyrocopter', 'hoodwink', 'huskar', 'jakiro', 'juggernaut', 'keeper_of_the_light', 'kez', 'kunkka', 'largo', 'legion_commander', 'leshrac', 'lich', 'life_stealer', 'lina', 'lion', 'luna', 'lycan', 'magnataur', 'marci', 'mars', 'medusa', 'meepo', 'mirana', 'monkey_king', 'morphling', 'muerta', 'naga_siren', 'necrolyte', 'nevermore', 'night_stalker', 'nyx_assassin', 'obsidian_destroyer', 'ogre_magi', 'omniknight', 'oracle', 'pangolier', 'phantom_assassin', 'phantom_lancer', 'phoenix', 'primal_beast', 'puck', 'pudge', 'pugna', 'snapfire', 'tusk', 'queenofpain', 'sniper', 'undying', 'rattletrap', 'ursa', 'razor', 'spectre', 'riki', 'vengefulspirit', 'witch_doctor', 'spirit_breaker', 'ringmaster', 'venomancer', 'storm_spirit', 'viper', 'sand_king', 'sven', 'shadow_demon', 'techies', 'visage', 'zuus', 'void_spirit', 'shadow_shaman', 'templar_assassin', 'shredder', 'terrorblade', 'warlock', 'slardar', 'slark', 'tidehunter', 'weaver', 'silencer', 'tinker', 'skeleton_king', 'windrunner', 'skywrath_mage', 'tiny', 'winter_wyvern', 'treant', 'wisp', 'troll_warlord'}
local H = dofile('tests/hero_harness.lua')
local bot,J = H.bot,H.J
package.loaded['bots/FunLib/minion_lib/familiars']={Think=function() error('Unknown spell invoked Familiar controller') end}
J.CanNotUseAbility=function() error('Unknown spell evaluated another hero gate') end
J.GetProperTarget=function() error('Unknown spell evaluated another hero target') end
local unknown={GetName=function() return 'unrecognized_spell' end}
setmetatable(unknown,{__index=function(_,key) error('Unknown spell queried '..key) end})
for _,hero in ipairs(heroes) do
    bot.GetAbilityByName=function() return nil end
    local handler=H.realDofile('bots/FunLib/rubick_hero/'..hero..'.lua')
    bot.GetAbilityByName=function() error('Unknown spell looked up another hero ability') end
    assert(handler.ConsiderStolenSpell(unknown)==nil,hero..' swallowed an unsupported spell')
end
print('Rubick unknown handler preservation passed: '..#heroes..' heroes')
