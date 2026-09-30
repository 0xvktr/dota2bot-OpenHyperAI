const assert = require('assert');
const fs = require('fs');
const path = require('path');
const cp = require('child_process');
const parser = require('../.test-tools/node_modules/luaparse');
process.chdir(path.resolve(__dirname, '..'));

// Execute the affected Lua functions/blocks with a fish classified as a lane creep.
function extract(file, predicate) {
    const source = fs.readFileSync(file, 'utf8');
    const ast = parser.parse(source, {luaVersion: '5.2', ranges: true});
    const matches = [];
    function visit(node) {
        if (!node || typeof node !== 'object') return;
        if (predicate(node, source)) matches.push(source.slice(...node.range));
        for (const [key, value] of Object.entries(node)) {
            if (key !== 'range' && key !== 'comments') {
                if (Array.isArray(value)) value.forEach(visit);
                else visit(value);
            }
        }
    }
    visit(ast);
    assert.strictEqual(matches.length, 1, `${file}: expected one tested path`);
    return matches[0];
}
const fn = name => node => node.type === 'FunctionDeclaration'
    && (node.identifier.name || node.identifier.identifier?.name) === name;
const loop = list => node => node.type === 'ForGenericStatement'
    && node.iterators[0]?.arguments[0]?.name === list;
const teamRoam = 'bots/mode_team_roam_generic.lua';
const paths = [
    ...['bots/mode_laning_generic.lua', 'bots/FunLib/override_generic/mode_laning_generic.lua'].map(file => ({
        name: file, body: extract(file, fn('GetBestDenyCreep')), call: 'GetBestDenyCreep(list)',
    })),
    {name: 'roam last-hit deny', body: extract(teamRoam, fn('GetNearbyLastHitCreep')),
        call: 'X.GetNearbyLastHitCreep(false, false, 100, 1000, bot)'},
    {name: 'group deny', body: `function select(list)
        local nDenyCreeps, nAllies, denyDamage = list, {bot,bot}, 10
        ${extract(teamRoam, loop('nDenyCreeps'))}
    end`, call: 'select(list)'},
    {name: 'two-hit deny', body: `function select(list)
        local nTwoHitDenyCreeps, nEnemyLaneCreep, denyDamage = list, {}, 10
        ${extract(teamRoam, loop('nTwoHitDenyCreeps'))}
    end`, call: 'select(list)'},
    {name: 'tower aggro drop', body: `function select(list)
        local allyCreeps = list
        ${extract('bots/mode_roam_generic.lua', (node, source) => node.type === 'IfStatement'
            && source.slice(...node.range).startsWith('if #allyCreeps >= 1'))}
        return attacked
    end`, call: 'select(list)'},
];
const lua = `
local J, X = {}, {}
local attackDamage, attacked = 100, nil
BOT_MODE_DESIRE_HIGH, BOT_MODE_DESIRE_ABSOLUTE, DAMAGE_TYPE_PHYSICAL = 1, 2, 1
local function unit(name)
    return {GetUnitName=function() return name end, GetHealth=function() return 20 end,
        GetMaxHealth=function() return 100 end, IsLaneCreep=function() return true end}
end
local fish, creep = unit('npc_dota_tidehunter_fish'), unit('npc_dota_creep_goodguys_melee')
local list = {}
local bot = {GetAttackDamage=function() return 100 end, GetAttackRange=function() return 150 end,
    GetUnitName=function() return 'npc_dota_hero_sven' end,
    GetNearbyLaneCreeps=function() return list end,
    Action_AttackUnit=function(_, target) attacked=target end}
GetUnitToUnitDistance=function() return 0 end
J.IsValid=function(u) return u~=nil end
J.GetHP=function(u) return u:GetHealth()/u:GetMaxHealth() end
J.CanBeAttacked=function() return true end
J.IsTormentor=function() return false end
J.IsRoshan=function() return false end
J.GetAttackProDelayTime=function() return 0 end
J.WillKillTarget=function(u, damage) return u:GetHealth()<=damage end
X.CanBeAttacked=J.CanBeAttacked
X.IsAllysTarget=function() return false end
X.IsOthersTarget=function() return false end
X.CanAttackTogether=function() return true end
X.IsLastHitCreep=J.WillKillTarget
${paths.map(p => `do
    ${p.body}
    list, attacked = {fish}, nil
    assert(${p.call}==nil, '${p.name}: must reject allied fish')
    list, attacked = {creep}, nil
    assert(${p.call}==creep, '${p.name}: must retain normal creep targeting')
end`).join('\n')}
list = {fish,creep}
assert(X.GetNearbyLastHitCreep(false,false,100,1000,bot)==creep, 'skip fish before a valid deny')
list = {fish}
assert(X.GetNearbyLastHitCreep(false,true,100,1000,bot)==fish, 'enemy last-hit behavior unchanged')
print('Creep deny fish scenarios passed')
`;
const result = cp.spawnSync(process.execPath, [path.resolve('.test-tools/node_modules/fengari-node-cli/src/lua-cli.js'), '-e', lua], {encoding: 'utf8'});
process.stdout.write(result.stdout || '');
process.stderr.write(result.stderr || '');
assert.strictEqual(result.status, 0);
assert(result.stdout.includes('Creep deny fish scenarios passed'));
