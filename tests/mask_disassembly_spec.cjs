const assert = require('assert');
const fs = require('fs');
const path = require('path');
const cp = require('child_process');
process.chdir(path.resolve(__dirname, '..'));

const source = fs.readFileSync('bots/FunLib/jmz_func.lua', 'utf8');
const start = source.indexOf('function J.ConsiderForMkbDisassembleMask(');
const end = source.indexOf('\nlocal LastActionTime', start);
assert(start >= 0 && end > start);
const lua = `
local J, bDebugMode = {}, false
local now = 700
DotaTime=function() return now end
${source.slice(start, end)}
local mask, lifesteal, sword, reaver, satanic = {}, {}, {}, {}, {}
local inventory, names = {[0]=mask}, {[mask]='item_mask_of_madness',
    [lifesteal]='item_lifesteal', [sword]='item_broadsword', [reaver]='item_reaver', [satanic]='item_satanic'}
local disassembled, unlocked = 0, {}
local bot = {
    FindItemSlot=function(_, name)
        for slot,item in pairs(inventory) do if names[item]==name then return slot end end
        return -1
    end,
    GetItemInSlot=function(_, slot) return inventory[slot] end,
    GetGold=function() return 1400 end,
    GetStashValue=function() return 0 end,
    GetCourierValue=function() return 0 end,
    ActionImmediate_DisassembleItem=function(_, item)
        assert(item==mask, 'disassemble the physical mask')
        disassembled=disassembled+1
        inventory[0], inventory[3] = lifesteal, sword
    end,
    ActionImmediate_SetItemCombineLock=function(_, item, locked)
        assert(not locked, 'release a recipe component')
        unlocked[item]=true
    end,
}
J.ConsiderForMkbDisassembleMask(bot)
assert(disassembled==0, 'retain Mask before a late upgrade starts')
inventory[1]=reaver
now=now+2
J.ConsiderForMkbDisassembleMask(bot)
assert(disassembled==1 and not unlocked[lifesteal] and not unlocked[sword], 'disassemble once')
now=now+2
J.ConsiderForMkbDisassembleMask(bot)
assert(unlocked[lifesteal] and not unlocked[sword], 'release lifesteal for Satanic first')
now=now+2
J.ConsiderForMkbDisassembleMask(bot)
assert(not unlocked[sword], 'keep Broadsword locked while Satanic is incomplete; avoid recombining Mask')
inventory[0], inventory[1] = satanic, nil
now=now+2
J.ConsiderForMkbDisassembleMask(bot)
assert(unlocked[sword], 'release the current Broadsword component after Satanic')
now=now+2
J.ConsiderForMkbDisassembleMask(bot)
assert(disassembled==1 and bot.staffUnlockDone, 'finish without repeated dismantling')
print('Mask disassembly recipe scenarios passed')
`;
const result = cp.spawnSync(process.execPath, [path.resolve('.test-tools/node_modules/fengari-node-cli/src/lua-cli.js'), '-e', lua], {encoding: 'utf8'});
process.stdout.write(result.stdout || '');
process.stderr.write(result.stderr || '');
assert.strictEqual(result.status, 0);
assert(result.stdout.includes('Mask disassembly recipe scenarios passed'));
