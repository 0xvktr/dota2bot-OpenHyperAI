// Prints Torte de Lini's ability and item tips for a hero, downloading the guide(s) from the Steam
// Workshop (public API, no key). Works on any machine: tools/tdl/guides.json maps heroes to guide IDs.
//
//   node tools/tdl/fetch.cjs ancient_apparition      tips for one hero (all of its guides, merged)
//   node tools/tdl/fetch.cjs lina --refresh          re-download instead of using the cache
//   node tools/tdl/fetch.cjs --all                   download every indexed guide into the cache
//
// Guides are cached in tools/tdl/cache/ (git-ignored). The text is copyrighted reference material:
// turn it into logic and own-words comments, never paste it into the repo.
// Notes for readers: ability tips lean toward the laning stage; a hero's guides differ mainly in
// item builds (which we take from D2PT, not from here); a guide for an older 7.41 patch is still
// useful, but check anything numeric against Valve's data (tests/valve/abilities.json).
const fs = require('fs');
const path = require('path');
const { parseKV } = require('../../tests/valve/kv.cjs');

const index = require('./guides.json');
const cacheDir = path.join(__dirname, 'cache');
// Keys that are not tips: the attribute slot carries the author's credits.
const SKIP = new Set(['attribute_bonus']);

// Steam drops the odd connection when many guides are fetched in a row.
async function retry(what, fn) {
    for (let attempt = 1; ; attempt++) {
        try { return await fn(); } catch (e) {
            if (attempt === 3) throw new Error(`${what}: ${e.message}`);
            await new Promise(r => setTimeout(r, 1000 * attempt));
        }
    }
}

// Download URLs for up to 50 guides per request.
async function fileUrls(guides) {
    const urls = new Map();
    for (let i = 0; i < guides.length; i += 50) {
        const batch = guides.slice(i, i + 50);
        const body = new URLSearchParams({ itemcount: String(batch.length) });
        batch.forEach((g, n) => body.append(`publishedfileids[${n}]`, g.id));
        const details = await retry('Steam API', async () => {
            const res = await fetch('https://api.steampowered.com/ISteamRemoteStorage/GetPublishedFileDetails/v1/', { method: 'POST', body });
            if (!res.ok) throw new Error(String(res.status));
            return (await res.json()).response.publishedfiledetails;
        });
        for (const d of details) if (d.result === 1 && d.file_url) urls.set(d.publishedfileid, d.file_url);
    }
    return urls;
}

const cacheFile = guide => path.join(cacheDir, `${guide.id}.txt`);

// Guide texts by ID, from the cache unless refreshing.
async function load(guides, refresh, onEach) {
    const texts = new Map();
    const need = guides.filter(g => refresh || !fs.existsSync(cacheFile(g)));
    const urls = need.length ? await fileUrls(need) : new Map();
    for (const g of guides) {
        if (!need.includes(g)) { texts.set(g.id, fs.readFileSync(cacheFile(g), 'utf8')); continue; }
        const url = urls.get(g.id);
        if (!url) throw new Error(`guide ${g.id} (${g.hero}) is not available on Steam`);
        const text = await retry(`download of guide ${g.id}`, async () => {
            const res = await fetch(url);
            if (!res.ok) throw new Error(String(res.status));
            return res.text();
        });
        fs.mkdirSync(cacheDir, { recursive: true });
        fs.writeFileSync(cacheFile(g), text);
        texts.set(g.id, text);
        if (onEach) onEach();
    }
    return texts;
}

// key -> [{ text, guides: [title...] }], identical texts merged across a hero's guides.
function collect(target, tips, label) {
    for (const [key, raw] of Object.entries(tips || {})) {
        const text = typeof raw === 'string' ? raw.trim() : '';
        if (!text || SKIP.has(key)) continue;
        const entries = target.get(key) || target.set(key, []).get(key);
        const same = entries.find(e => e.text === text);
        if (same) same.guides.push(label); else entries.push({ text, guides: [label] });
    }
}

function print(title, tips, guideCount) {
    console.log(`\n## ${title}`);
    if (!tips.size) { console.log('(none)'); return; }
    for (const [key, entries] of tips) {
        console.log(`\n${key}`);
        for (const e of entries) {
            // Name the guide only when a hero's guides disagree.
            if (guideCount > 1 && e.guides.length < guideCount) console.log(`  [${e.guides.join('; ')}]`);
            console.log(e.text.split(/\r?\n/).map(l => '  ' + l).join('\n'));
        }
    }
}

async function main() {
    const args = process.argv.slice(2);
    const refresh = args.includes('--refresh');
    if (args.includes('--all')) {
        await load(index.guides, refresh, () => process.stdout.write('.'));
        console.log(`\nCached ${index.guides.length} guides in ${path.relative(process.cwd(), cacheDir)}`);
        return;
    }
    const hero = (args.find(a => !a.startsWith('--')) || '').replace(/^npc_dota_hero_/, '');
    const guides = index.guides.filter(g => g.hero === hero);
    if (!guides.length) {
        const why = index.missing.includes(hero) ? 'no guide is indexed for it yet (see tools/tdl/build_index.cjs)' : 'unknown hero name';
        console.error(hero ? `${hero}: ${why}` : 'Usage: node tools/tdl/fetch.cjs <hero internal name> [--refresh] | --all');
        process.exit(1);
    }
    const abilities = new Map(), items = new Map();
    const texts = await load(guides, refresh);
    console.log(`# ${hero}: Torte de Lini guide tips (reference only; do not copy the text into the repo)`);
    for (const g of guides) {
        const data = parseKV(texts.get(g.id)).guidedata || {};
        const label = g.title.replace(/torte de lini\s*/i, '') || g.id;
        console.log(`Guide ${g.id}: ${label}, patch ${data.GameplayVersion || g.patch}, role ${g.role}`);
        collect(abilities, (data.AbilityBuild || {}).AbilityTooltips, label);
        collect(items, (data.ItemBuild || {}).ItemTooltips, label);
    }
    print('Ability tips', abilities, guides.length);
    print('Item tips', items, guides.length);
}

main().catch(e => { console.error(e.message); process.exit(1); });
