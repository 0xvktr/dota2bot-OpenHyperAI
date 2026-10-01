// Exercise the real team-roam cleanup and early-item list, without loading unrelated modes.
const fs = require('fs'), path = require('path'), cp = require('child_process'), assert = require('assert');
process.chdir(path.resolve(__dirname, '..'));
const parser = require('../.test-tools/node_modules/luaparse');
const source = fs.readFileSync('bots/mode_team_roam_generic.lua', 'utf8');
parser.parse(source, {luaVersion: '5.2'});
function section(text, start, end) {
    const a = text.indexOf(start), b = text.indexOf(end, a);
    assert(a >= 0 && b > a, `missing ${start}`);
    return text.slice(a, b);
}
assert(source.includes('local lastEarlyItemSaleCheck = 0'));
assert(source.includes('    TrySellEarlyBackpackItems()'), 'team-roam must call the tested helper');
const items = fs.readFileSync('bots/FunLib/aba_item.lua', 'utf8');
fs.writeFileSync('.test-tools/early-item-cleanup.lua', 'return function(bot, Utils)\n' +
    'local lastEarlyItemSaleCheck = 0\nlocal Item = {}\n' +
    section(items, "Item['tEarlyConsumableItem'] = {", "Item['tEarlyBoots'] = {") +
    section(source, 'function TrySellEarlyBackpackItems()', 'function J.FindLeastExpensiveItemSlot()') +
    'return TrySellEarlyBackpackItems\nend\n');
const run = cp.spawnSync(process.execPath, [path.resolve('.test-tools/node_modules/fengari-node-cli/src/lua-cli.js'),
    'tests/early_item_cleanup_spec.lua'], {encoding: 'utf8'});
process.stdout.write(run.stdout || ''); process.stderr.write(run.stderr || '');
assert(!run.error && run.status === 0 && /\d+ early item cleanup scenarios passed/.test(run.stdout), 'early item cleanup checks failed');
