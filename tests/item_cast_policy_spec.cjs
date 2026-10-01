// Exercise actual generic item decisions and the shared policy under Fengari.
const fs = require('fs');
const path = require('path');
const cp = require('child_process');
const assert = require('assert');
process.chdir(path.resolve(__dirname, '..'));
const source = fs.readFileSync('bots/ability_item_usage_generic.lua', 'utf8');
const names = ['enchanted_mango', 'magic_stick', 'magic_wand', 'mask_of_madness', 'soul_ring'];
let hooks = 'return function(bot, J)\nlocal X = {ConsiderItemDesire={}}\n' +
    "local ItemCastPolicy = require('bots/FunLib/item_cast_policy')\nlocal botName = bot:GetUnitName()\n";
for (const name of names) {
    const re = new RegExp(`X\\.ConsiderItemDesire\\[["']item_${name}["']\\] = function\\([^)]*\\)[\\s\\S]*?\\nend`);
    const match = source.match(re);
    assert(match, `missing item_${name} decision`);
    hooks += match[0] + '\n';
}
fs.writeFileSync('.test-tools/item-cast-hooks.lua', hooks + 'return X.ConsiderItemDesire\nend\n');
for (const file of ['tests/item_cast_policy_spec.lua', 'tests/od_item_policy_spec.lua']) {
    const result = cp.spawnSync(process.execPath,
        [path.resolve('.test-tools/node_modules/fengari-node-cli/src/lua-cli.js'), file], {encoding:'utf8'});
    process.stdout.write(result.stdout || '');
    process.stderr.write(result.stderr || '');
    assert(!result.error && result.status === 0 && result.stdout.includes('item policy scenarios passed'), `${file} failed`);
}
