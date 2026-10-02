// Run `node tests/reply_member_spec.cjs` to exercise the shipped Lua selector.
const assert = require('node:assert/strict');
const fs = require('node:fs');
const path = require('node:path');
const cp = require('node:child_process');
process.chdir(path.resolve(__dirname, '..'));

const source = fs.readFileSync('bots/FunLib/aba_role.lua', 'utf8');
const start = source.indexOf('____exports.GetReplyMemberID = function()');
const end = source.indexOf('____exports.memberIDIndexTable = nil', start);
assert(start >= 0 && end > start, 'missing reply member selector');

const script = `
local ____exports = {}
${source.slice(start, end)}
local players, bots, selectedIndex, randomCalls
function GetTeam() return 2 end
function GetTeamPlayers(team) assert(team == 2); return players end
function IsPlayerBot(id) return bots[id] == true end
function RandomInt(low, high)
    assert(low == 0 and high >= low)
    assert(selectedIndex >= low and selectedIndex <= high)
    randomCalls = randomCalls + 1
    return selectedIndex
end
local function scenario(roster, eligible, index, expected)
    players, bots, selectedIndex, randomCalls = roster, eligible, index, 0
    ____exports.replyMemberID = nil
    assert(____exports.GetReplyMemberID() == expected)
    assert(randomCalls == (expected ~= nil and 1 or 0))
    if expected ~= nil then
        -- A chosen speaker remains stable without consuming another random roll.
        assert(____exports.GetReplyMemberID() == expected)
        assert(randomCalls == 1)
    end
end
-- A single bot must be selected regardless of its position among four humans.
for position = 1, 5 do
    scenario({0, 1, 2, 3, 4}, {[position - 1] = true}, 0, position - 1)
end
-- Interleaved humans and bots, including sparse player IDs and both endpoints.
scenario({8, 3, 12, 5, 19}, {[3] = true, [19] = true}, 0, 3)
scenario({8, 3, 12, 5, 19}, {[3] = true, [19] = true}, 1, 19)
scenario({0, 1, 2, 3, 4}, {[0] = true, [1] = true, [2] = true, [3] = true, [4] = true}, 4, 4)
-- No eligible bot must return nil without an invalid RandomInt range.
scenario({0, 1, 2, 3, 4}, {}, 0, nil)
scenario({}, {}, 0, nil)
print('Reply member scenarios passed')
`;
const result = cp.spawnSync(process.execPath,
    ['.test-tools/node_modules/fengari-node-cli/src/lua-cli.js', '-e', script],
    { encoding: 'utf8' });
process.stdout.write(result.stdout || '');
process.stderr.write(result.stderr || '');
assert(!result.error && result.status === 0 && result.stdout.includes('Reply member scenarios passed'),
    'reply member scenarios failed');
