// Run `node tests/banter_spec.cjs` with the repo's Lua test tools installed.
const assert = require('node:assert/strict');
const fs = require('node:fs');
const os = require('node:os');
const path = require('node:path');
const cp = require('node:child_process');
process.chdir(path.resolve(__dirname, '..'));
const parser = require('../.test-tools/node_modules/luaparse');
for (const file of ['bots/FunLib/banter.lua', 'bots/FunLib/banter_lines.lua',
    'bots/FunLib/localization.lua', 'bots/ability_item_usage_generic.lua', 'bots/hero_selection.lua',
    'bots/Customize/general.lua', 'bots/FunLib/aba_role.lua', 'tests/banter_spec.lua']) {
    parser.parse(fs.readFileSync(file, 'utf8'), { luaVersion: file === 'bots/hero_selection.lua' ? '5.2' : '5.1' });
}
const source = fs.readFileSync('bots/ability_item_usage_generic.lua', 'utf8');
const start = source.indexOf('local nTalkDelay = RandomInt(');
const end = source.indexOf('local function BuybackUsageComplement()', start);
assert(start >= 0 && end > start, 'missing chat integration section');
const dir = fs.mkdtempSync(path.join(os.tmpdir(), 'openhyp-banter-'));
try {
    const hook = path.join(dir, 'chat-hook.lua');
    fs.writeFileSync(hook, 'return function(bot, J, Banter, Localization)\nlocal X = {}\n' +
        source.slice(start, end) + '\nreturn X\nend\n');
    const draftSource = fs.readFileSync('bots/hero_selection.lua', 'utf8');
    const draftStart = draftSource.indexOf('function SelectHeroChatCallback(');
    const draftEnd = draftSource.indexOf('--==============================================================================', draftStart);
    assert(draftStart >= 0 && draftEnd > draftStart, 'missing draft chat callback');
    const draftHook = path.join(dir, 'draft-chat-hook.lua');
    fs.writeFileSync(draftHook, 'return function(Localization, startsWithExclamation, handleCommand, HandleLocaleSetting)\n' +
        draftSource.slice(draftStart, draftEnd) + '\nreturn SelectHeroChatCallback\nend\n');
    const result = cp.spawnSync(process.execPath,
        ['.test-tools/node_modules/fengari-node-cli/src/lua-cli.js', 'tests/banter_spec.lua', hook, draftHook],
        { encoding: 'utf8' });
    process.stdout.write(result.stdout || '');
    process.stderr.write(result.stderr || '');
    assert(!result.error && result.status === 0 && result.stdout.includes('Banter scenarios passed ('),
        'banter scenarios failed');
} finally {
    fs.rmSync(dir, { recursive: true, force: true });
}
