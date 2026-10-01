// Checks every bots/BotLib/hero_*.lua against Valve's ability data (tests/valve/abilities.json):
//  - names passed to GetAbilityByName('...') must exist on the hero (or on another hero: cross-hero references),
//  - keys read with <ability>:GetSpecialValueInt/Float('...') must exist on the ability the handle points to.
// A wrong key silently returns 0 and a wrong name silently returns nil, so neither ever shows up as an error.
// Run: `node tests/valve_ability_check.cjs` (also part of tests/run-builds.cjs). Refresh the data after a
// patch with `node tests/valve/refresh.cjs`. Intentional findings go in tests/valve/allowlist.json.
const fs = require('fs');
const path = require('path');
const root = path.resolve(__dirname, '..');
const parser = require(path.join(root, '.test-tools/node_modules/luaparse'));

const data = require('./valve/abilities.json');
const allowlist = require('./valve/allowlist.json');
// Bot files that drive a unit whose abilities live in another hero's file.
const HERO_DATA = { lone_druid_bear: 'lone_druid' };

const allNames = new Set();
for (const h of Object.values(data.heroes)) {
    for (const n of Object.keys(h.abilities)) allNames.add(n);
    for (const [, n] of h.slots) allNames.add(n);
}

const isTalent = name => name.startsWith('special_bonus_');
const skipName = name => name.startsWith('item_') || name === 'generic_hidden'
    || (isTalent(name) && !name.startsWith('special_bonus_unique_'));

// Mirrors FunLib/aba_skill.lua GetAbilityList: learnable abilities from slots 0-10, ultimate at index 6.
// Innate/hidden entries depend on runtime flags, so indices after one are not trusted.
function abilityList(hero) {
    const bySlot = new Map(hero.slots.map(([n, name]) => [n - 1, name]));
    const list = [];
    let firstUncertain = Infinity, pushes = 0;
    for (let slot = 0; slot <= 10; slot++) {
        const name = bySlot.get(slot);
        if (!name) continue;
        if (name === 'generic_hidden') { if (slot !== 0) list[++pushes] = name; continue; }
        const info = hero.abilities[name] || { behavior: '', ultimate: false, innate: false };
        const notLearnable = info.behavior.includes('NOT_LEARNABLE');
        const hidden = info.behavior.includes('BEHAVIOR_HIDDEN');
        if (notLearnable && hidden) continue;
        if (info.ultimate && slot >= 4) { if (!notLearnable && !hidden) list[6] = name; continue; }
        if (isTalent(name)) continue;
        list[++pushes] = name;
        if (info.innate || notLearnable || hidden) firstUncertain = Math.min(firstUncertain, pushes);
    }
    const trusted = i => (i === 6 ? pushes <= 5 && list[6] !== undefined : i <= 3 && i < firstUncertain && list[i] !== undefined);
    return { list, trusted };
}

const talentList = hero => hero.slots.map(([, n]) => n).filter(isTalent);

function strOf(node) {
    if (!node || node.type !== 'StringLiteral') return null;
    return node.raw.slice(1, -1);
}

function walk(node, visit) {
    if (!node || typeof node !== 'object') return;
    if (Array.isArray(node)) { for (const n of node) walk(n, visit); return; }
    if (typeof node.type === 'string') visit(node);
    for (const k of Object.keys(node)) if (k !== 'loc' && k !== 'range') walk(node[k], visit);
}

// `bot:GetAbilityByName(x)` -> the argument node, else null.
function abilityArg(node) {
    return node && node.type === 'CallExpression' && node.base.type === 'MemberExpression'
        && node.base.indexer === ':' && node.base.identifier.name === 'GetAbilityByName' ? node.arguments[0] : null;
}

function targetKey(node) {
    if (node.type === 'Identifier') return node.name;
    if (node.type === 'MemberExpression' && node.base.type === 'Identifier') return node.base.name + '.' + node.identifier.name;
    return null;
}

function refOf(arg) {
    const name = strOf(arg);
    if (name) return { name };
    if (arg && arg.type === 'IndexExpression' && arg.base.type === 'Identifier' && arg.index.type === 'NumericLiteral') {
        if (arg.base.name === 'sAbilityList') return { slot: arg.index.value };
        if (arg.base.name === 'sTalentList') return { talent: arg.index.value };
    }
    return { unknown: true };
}

function checkHero(botName, file = `bots/BotLib/hero_${botName}.lua`, idPrefix = botName) {
    const heroName = HERO_DATA[botName] || botName;
    const hero = data.heroes[heroName];
    const ast = parser.parse(fs.readFileSync(path.join(root, file), 'utf8'), { luaVersion: '5.2', locations: true });
    const findings = [];
    const add = (kind, detail, line, message) => findings.push({ id: `${idPrefix}|${kind}|${detail}`, line, message });
    const own = name => name in hero.abilities || hero.slots.some(([, n]) => n === name);
    const { list, trusted } = abilityList(hero);
    const talents = talentList(hero);

    // Handles: variable -> refs from every assignment of GetAbilityByName(...).
    const handles = new Map();
    walk(ast, node => {
        if (node.type !== 'LocalStatement' && node.type !== 'AssignmentStatement') return;
        node.variables.forEach((v, i) => {
            const arg = abilityArg(node.init[i]);
            const key = arg && targetKey(v);
            if (key) (handles.get(key) || handles.set(key, []).get(key)).push(refOf(arg));
        });
    });

    // Rubick's per-hero copies take the stolen spell as a parameter:
    // `if abilityName == '<name>' then Handle = ability`.
    walk(ast, node => {
        if (node.type !== 'IfClause' && node.type !== 'ElseifClause') return;
        const c = node.condition;
        if (c.type !== 'BinaryExpression' || c.operator !== '==') return;
        const name = strOf(c.right) || strOf(c.left);
        if (!name) return;
        walk(node.body, inner => {
            if (inner.type !== 'AssignmentStatement' && inner.type !== 'LocalStatement') return;
            inner.variables.forEach((v, i) => {
                const init = inner.init[i];
                const key = init && init.type === 'Identifier' && init.name === 'ability' && targetKey(v);
                if (key) (handles.get(key) || handles.set(key, []).get(key)).push({ name });
            });
        });
    });

    // The ability names a ref can point to on this hero; null = unknown (check against the whole hero).
    function resolve(refs) {
        const names = new Set();
        for (const r of refs) {
            if (r.name) { if (!own(r.name)) return 'foreign'; names.add(r.name); }
            else if (r.slot !== undefined && trusted(r.slot)) names.add(list[r.slot]);
            else if (r.talent !== undefined && talents[r.talent - 1]) names.add(talents[r.talent - 1]);
            else return null;
        }
        return names;
    }

    const keysOf = name => {
        const keys = new Set((hero.abilities[name] || { keys: [] }).keys);
        // Talents expose 'value' (engine convention used across the hero files) and bonus_<linked key>.
        if (isTalent(name)) { keys.add('value'); for (const k of hero.talentBonuses[name] || []) keys.add('bonus_' + k); }
        return keys;
    };
    const anyHas = key => key === 'value' || Object.keys(hero.abilities).some(n => keysOf(n).has(key));

    walk(ast, node => {
        if (node.type !== 'CallExpression' || node.base.type !== 'MemberExpression' || node.base.indexer !== ':') return;
        const method = node.base.identifier.name;
        const line = node.loc.start.line;
        if (method === 'GetAbilityByName') {
            const name = strOf(node.arguments[0]);
            if (name && !skipName(name) && !own(name) && !allNames.has(name)) {
                add('name', name, line, `GetAbilityByName('${name}') does not exist in Valve's data`);
            }
            return;
        }
        if (method !== 'GetSpecialValueInt' && method !== 'GetSpecialValueFloat') return;
        const key = strOf(node.arguments[0]);
        if (!key) return;
        const obj = node.base.base;
        const direct = abilityArg(obj);
        const tk = direct ? null : targetKey(obj);
        const refs = direct ? [refOf(direct)] : handles.get(tk);
        if (!refs) return; // not an ability handle (items, function parameters)
        const names = resolve(refs);
        if (names === 'foreign') return;
        const label = direct ? 'GetAbilityByName(...)' : tk;
        if (names === null) {
            if (!anyHas(key)) add('key', `${label}:${key}`, line, `${label}:${method}('${key}') - no ability of ${heroName} has this key`);
            return;
        }
        // A handle reassigned to several abilities (e.g. an alternate form) needs the key on at least one.
        if ([...names].some(name => skipName(name) || keysOf(name).has(key))) return;
        const targets = [...names].join(' / ');
        const elsewhere = Object.keys(hero.abilities).filter(n => !names.has(n) && keysOf(n).has(key));
        add('key', `${label}:${key}`, line, `${label}:${method}('${key}') - ${targets} has no such key`
            + (elsewhere.length ? ` (found on ${elsewhere.join(', ')})` : ''));
    });
    return findings;
}

const heroes = fs.readdirSync(path.join(root, 'bots/BotLib'))
    .filter(f => /^hero_.+\.lua$/.test(f)).map(f => f.slice(5, -4)).sort();
const allowed = new Map(allowlist.map(e => [e.id, e]));
const used = new Set();
const failures = [];
let total = 0;
for (const h of heroes) {
    if (!data.heroes[HERO_DATA[h] || h]) { failures.push(`${h}: no Valve data - run node tests/valve/refresh.cjs`); continue; }
    for (const f of checkHero(h)) {
        total++;
        if (allowed.has(f.id)) { used.add(f.id); continue; }
        failures.push(`bots/BotLib/hero_${h}.lua:${f.line}: ${f.message}  [${f.id}]`);
    }
}
// Rubick's stolen-spell copies of the hero logic (FunLib/rubick_hero/<hero>.lua).
const rubickDir = 'bots/FunLib/rubick_hero';
const rubickFiles = fs.readdirSync(path.join(root, rubickDir)).filter(f => f.endsWith('.lua')).sort();
for (const f of rubickFiles) {
    const h = f.slice(0, -4);
    if (!data.heroes[HERO_DATA[h] || h]) { failures.push(`${rubickDir}/${f}: no Valve data for ${h}`); continue; }
    for (const finding of checkHero(h, `${rubickDir}/${f}`, `rubick/${h}`)) {
        total++;
        if (allowed.has(finding.id)) { used.add(finding.id); continue; }
        failures.push(`${rubickDir}/${f}:${finding.line}: ${finding.message}  [${finding.id}]`);
    }
}
for (const id of allowed.keys()) if (!used.has(id)) failures.push(`stale allowlist entry (no longer found): ${id}`);

if (failures.length) {
    console.error(failures.join('\n'));
    console.error(`\nValve ability check failed: ${failures.length} problem(s). Fix them, or add intentional ones to tests/valve/allowlist.json with a reason.`);
    process.exit(1);
}
console.log(`Valve ability check passed: ${heroes.length} hero files, ${rubickFiles.length} Rubick copies, ${total} allowlisted finding(s), d2vpkr ${data.commit.slice(0, 7)}`);
