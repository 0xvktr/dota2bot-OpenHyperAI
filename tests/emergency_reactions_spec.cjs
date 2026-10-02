const fs = require('fs'), path = require('path'), cp = require('child_process'), assert = require('assert');
process.chdir(path.resolve(__dirname, '..'));
const source = fs.readFileSync('bots/FunLib/emergency_reactions.lua', 'utf8');
require('../.test-tools/node_modules/luaparse').parse(source, {luaVersion: '5.1'});
const data = require('./valve/abilities.json');
const abilities = Object.assign({}, ...Object.values(data.heroes).map(h => h.abilities));
for (const [, name, spec] of source.matchAll(/^    (\w+) = \{([^}]+)\}/gm)) {
    assert(abilities[name], `unknown interrupt ${name}`);
    for (const [, key] of spec.matchAll(/(?:speed|radius|delay)='(\w+)'/g)) {
        assert(abilities[name].keys.includes(key), `${name}: unknown timing/range key ${key}`);
    }
}
const run = cp.spawnSync(process.execPath, [path.resolve('.test-tools/node_modules/fengari-node-cli/src/lua-cli.js'),
    'tests/emergency_reactions_spec.lua'], {encoding:'utf8'});
process.stdout.write(run.stdout || ''); process.stderr.write(run.stderr || '');
assert(!run.error && run.status === 0 && /\d+ emergency reaction scenarios passed/.test(run.stdout), 'reaction regressions failed');
