// Builds tools/tdl/guides.json: which Steam Workshop guide IDs hold Torte de Lini's hero guides.
// Dota caches every guide the player has opened in game as <workshop id>.item under
// <dota 2 beta>/game/dota/workshop/steampublic; this scans that folder and confirms each ID with
// Steam's public API. The index holds IDs and metadata only -- guide text is copyrighted and is
// fetched on demand by tools/tdl/fetch.cjs.
//
//   node tools/tdl/build_index.cjs "<dota 2 beta>/game/dota/workshop/steampublic"
//
// To add a missing hero: open its Torte de Lini guide in game once, then re-run.
const fs = require('fs');
const path = require('path');

const root = path.resolve(__dirname, '../..');
const out = path.join(__dirname, 'guides.json');
const AUTHOR = /torte de lini/i;

async function steamDetails(ids) {
    const body = new URLSearchParams({ itemcount: String(ids.length) });
    ids.forEach((id, i) => body.append(`publishedfileids[${i}]`, id));
    const res = await fetch('https://api.steampowered.com/ISteamRemoteStorage/GetPublishedFileDetails/v1/', { method: 'POST', body });
    if (!res.ok) throw new Error(`Steam API ${res.status}`);
    return (await res.json()).response.publishedfiledetails;
}

async function main() {
    const dir = process.argv[2];
    if (!dir || !fs.existsSync(dir)) {
        console.error('Usage: node tools/tdl/build_index.cjs "<dota 2 beta>/game/dota/workshop/steampublic"');
        process.exit(1);
    }
    const guides = [];
    for (const file of fs.readdirSync(dir).filter(f => f.endsWith('.item'))) {
        const text = fs.readFileSync(path.join(dir, file), 'utf8');
        const field = k => (text.match(new RegExp('"' + k + '"\\s+"([^"]*)"')) || [])[1] || '';
        if (!AUTHOR.test(field('Title'))) continue;
        guides.push({ hero: field('Hero'), id: file.slice(0, -5), title: field('Title').trim(),
            role: field('Role').replace('#DOTA_HeroGuide_Role_', ''), patch: field('GameplayVersion') });
    }

    // Confirm every ID is a public Dota 2 workshop file and record when Steam last saw it change.
    const details = new Map();
    for (let i = 0; i < guides.length; i += 50) {
        for (const d of await steamDetails(guides.slice(i, i + 50).map(g => g.id))) details.set(d.publishedfileid, d);
    }
    for (const g of guides) {
        const d = details.get(g.id);
        if (!d || d.result !== 1 || d.consumer_app_id !== 570 || !d.file_url) throw new Error(`guide ${g.id} (${g.hero}) is not downloadable from Steam`);
        g.updated = new Date(d.time_updated * 1000).toISOString().slice(0, 10);
    }
    guides.sort((a, b) => a.hero.localeCompare(b.hero) || a.id.localeCompare(b.id));

    const heroes = fs.readdirSync(path.join(root, 'bots/BotLib'))
        .filter(f => /^hero_.+\.lua$/.test(f)).map(f => f.slice(5, -4))
        .filter(h => h !== 'lone_druid_bear'); // the bear is part of Lone Druid's guide
    const covered = new Set(guides.map(g => g.hero));
    const missing = heroes.filter(h => !covered.has(h)).sort();

    fs.writeFileSync(out, JSON.stringify({
        note: 'Workshop IDs of Torte de Lini hero guides. Fetch the text with tools/tdl/fetch.cjs; do not commit guide text.',
        missing, guides,
    }, null, 1) + '\n');
    console.log(`Wrote ${path.relative(root, out)}: ${guides.length} guides, ${covered.size} heroes, missing: ${missing.join(', ') || 'none'}`);
}

main().catch(e => { console.error(e.message); process.exit(1); });
