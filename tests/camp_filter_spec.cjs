// Compile just aba_site, check generated Lua, and run the actual camp selectors.
// Pass --write to regenerate that file without overwriting other generated modules.
const fs = require('fs'), path = require('path'), cp = require('child_process'), assert = require('assert');
const ts = require('typescript'), tstl = require('typescript-to-lua');
process.chdir(path.resolve(__dirname, '..'));
const config = tstl.parseConfigFileWithSystem(path.resolve('tsconfig-tstl.json'));
assert.strictEqual(config.errors.length, 0, 'invalid TSTL configuration');
const program = ts.createProgram(config.fileNames, {...config.options, tstlVerbose: false});
const source = program.getSourceFile(path.resolve('typescript/bots/FunLib/aba_site.ts'));
assert(source, 'missing aba_site source');
const diagnostics = ts.getPreEmitDiagnostics(program, source);
let generated;
const result = new tstl.Transpiler().emit({program, sourceFiles: [source], writeFile(file, data) {
    if (path.resolve(file) === path.resolve('bots/FunLib/aba_site.lua')) generated = data;
}});
diagnostics.push(...result.diagnostics);
assert.strictEqual(diagnostics.length, 0, ts.formatDiagnosticsWithColorAndContext(diagnostics, {
    getCurrentDirectory: ts.sys.getCurrentDirectory, getCanonicalFileName: f => f, getNewLine: () => '\n',
}));
assert(generated, 'compiler did not emit aba_site.lua');
// Match the repository's Lua require-path postprocessor.
generated = generated.replace(/(require|dofile)\("bots[./]([^"\n]+)"\)/g,
    (_, fn, module) => `${fn}(GetScriptDirectory().."/${module.replace(/\./g, '/')}")`);
if (process.argv.includes('--write')) fs.writeFileSync('bots/FunLib/aba_site.lua', generated);
assert.strictEqual(fs.readFileSync('bots/FunLib/aba_site.lua', 'utf8').replace(/\r\n/g, '\n'),
    generated.replace(/\r\n/g, '\n'), 'aba_site.lua differs from its TypeScript source; run this spec with --write');
const parser = require('../.test-tools/node_modules/luaparse');
parser.parse(generated, {luaVersion: '5.1'});
const farm = fs.readFileSync('bots/mode_farm_generic.lua', 'utf8');
const start = farm.indexOf('function Think()'), end = farm.indexOf('function X.IsNearLaneFront(', start);
assert(start >= 0 && end > start, 'farm Think not found');
fs.writeFileSync('.test-tools/camp-farm-think.lua',
    'return function(bot,J,preferedCamp,availableCamp,X)\n' +
    'local Customize={ThinkLess=0}; local runMode=false; local farmState=0; local FARM_STATE_NONE=0; local FARM_STATE_FARM=1\n' +
    'local hLaneCreepList={}; local sec=0; local botName=bot:GetUnitName(); local RB={};local DB={}\n' +
    farm.slice(start,end) + 'Think();return preferedCamp\nend\n');
const run = cp.spawnSync(process.execPath, [path.resolve('.test-tools/node_modules/fengari-node-cli/src/lua-cli.js'),
    'tests/camp_filter_spec.lua'], {encoding: 'utf8'});
process.stdout.write(run.stdout || ''); process.stderr.write(run.stderr || '');
assert(!run.error && run.status === 0 && /\d+ camp filter scenarios passed/.test(run.stdout), 'camp filter checks failed');
