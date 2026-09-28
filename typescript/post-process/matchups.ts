// matchups.ts
import fs from "node:fs";
import path from "node:path";
import puppeteer, { Browser } from "puppeteer";
import * as cheerio from "cheerio";
import { hero_name_table } from "./names";

const USER_AGENT = "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/117.0.0.0 Safari/537.36";

type Counters = Record<string, number>;

const visibleToInternal: Record<string, string> = Object.fromEntries(
    Object.entries(hero_name_table).map(([internal, data]) => [data.visibleName.toLowerCase(), internal])
);

async function withBrowser<T>(fn: (browser: Browser) => Promise<T>): Promise<T> {
    const browser = await puppeteer.launch({
        headless: true, // cross-version safe
        args: ["--no-sandbox", "--disable-gpu"],
    });
    try {
        return await fn(browser);
    } finally {
        await browser.close();
    }
}

async function fetchHtml(url: string, browser: Browser): Promise<string> {
    const page = await browser.newPage();
    await page.setUserAgent(USER_AGENT);
    await page.goto(url, { waitUntil: "domcontentloaded" });
    try {
        // Dotabuff pages render a sortable table we parse
        await page.waitForSelector("table.sortable", { timeout: 1000 });
    } catch {
        // ignore if it never appears—parsers already handle "no table" gracefully
    }
    const html = await page.content();
    await page.close();
    return html;
}

export function parseCounterTable(html: string): Counters | null {
    const $ = cheerio.load(html);
    const table = $("table.sortable").first();
    if (!table.length) return null;

    const counters: Counters = {};
    const rows = table.find("tr").toArray().slice(1);

    for (const row of rows) {
        const cols = $(row).find("td");
        if (cols.length >= 3) {
            const heroVisible = $(cols[1]).text().trim().toLowerCase();
            const advantageTxt = $(cols[2]).text().trim().replace("%", "");
            if (!advantageTxt) continue;
            const advantage = Number(advantageTxt);
            if (!Number.isFinite(advantage)) continue;

            const internal = visibleToInternal[heroVisible];
            if (internal) counters[internal] = advantage;
        }
    }

    return counters;
}

async function getHeroCounters(heroUrlName: string, browser: Browser): Promise<Counters | null> {
    // past 12 months
    const url = `https://www.dotabuff.com/heroes/${heroUrlName}/counters?date=year`;
    const html = await fetchHtml(url, browser);
    return parseCounterTable(html);
}

// The Dotabuff column is DISADVANTAGE: positive means the row hero is countered.
// Draft scoring already negates these values. Never invert the imported sign.
export function validateMatchups(data: Record<string, Counters>) {
    const heroes = Object.keys(hero_name_table);
    if (Object.keys(data).length !== heroes.length) throw new Error("Incomplete hero roster; keeping existing data");
    for (const hero of heroes) {
        const row = data[hero];
        if (!row || Object.keys(row).length !== heroes.length - 1) throw new Error(`Incomplete opponents for ${hero}`);
        for (const opponent of heroes) {
            if (opponent !== hero && (!Number.isFinite(row[opponent]) || Math.abs(row[opponent]) > 100)) {
                throw new Error(`Invalid disadvantage: ${hero} / ${opponent}`);
            }
        }
    }
}

export function importSnapshot(snapshot: Record<string, {name: string; href: string; disadvantage: number}[]>) {
    const result: Record<string, Counters> = {};
    for (const [hero, info] of Object.entries(hero_name_table)) {
        const rows = snapshot[info.urlName];
        if (!rows) throw new Error(`Missing browser table for ${hero}`);
        const counters: Counters = {};
        for (const row of rows) {
            const opponent = visibleToInternal[row.name.toLowerCase()];
            if (!opponent || row.href !== `/heroes/${hero_name_table[opponent].urlName}`) throw new Error(`Unknown opponent ${row.name}`);
            if (opponent === hero || Object.prototype.hasOwnProperty.call(counters, opponent)) throw new Error(`Duplicate/self opponent ${row.name}`);
            counters[opponent] = row.disadvantage;
        }
        result[hero] = counters;
    }
    validateMatchups(result);
    return result;
}

async function main() {
    let matchupDict: Record<string, Counters> = {};

    // Optional export of the same visible tables from an authenticated browser.
    // This does not bypass access challenges; complete verification in the browser.
    const snapshotIndex = process.argv.indexOf("--snapshot");
    if (snapshotIndex >= 0) {
        matchupDict = importSnapshot(JSON.parse(fs.readFileSync(process.argv[snapshotIndex + 1], "utf8")));
    } else await withBrowser(async browser => {
        for (const [internalName, data] of Object.entries(hero_name_table)) {
            console.log(`Fetching counters for ${internalName}...`);
            try {
                const counters = await getHeroCounters(data.urlName, browser);
                if (counters) {
                    matchupDict[internalName] = counters;
                } else {
                    console.warn(`No counters found for ${internalName}.`);
                }
            } catch (e) {
                console.error(`Error on ${internalName}:`, e);
            }
        }
    });

    validateMatchups(matchupDict);

    // Write Lua (mirrors Python)
    //   const outPath = path.resolve(process.cwd(), "matchups_data.lua");
    const outPath = path.resolve(__dirname, "../../bots/FretBots/matchups_data.lua");

    const lines: string[] = [];
    lines.push("-----");
    lines.push("-- This file is generated by typescript/post-process/matchups.ts");
    lines.push(`-- Retrieved ${new Date().toISOString().slice(0, 10)}; Dotabuff counters?date=year (last 12 months).`);
    lines.push("-- Values are disadvantage percentages: positive = bad for the row hero, negative = good.");
    lines.push("-----\n");
    lines.push("local heroList = {");
    for (const [hero, counterDict] of Object.entries(matchupDict)) {
        lines.push(`    ['${hero}'] = {`);
        for (const [counterHero, advantage] of Object.entries(counterDict)) {
            lines.push(`        ['${counterHero}'] = ${advantage},`);
        }
        lines.push("    },");
    }
    lines.push("}\n\nreturn heroList\n");

    fs.writeFileSync(outPath + ".tmp", lines.join("\n"), "utf-8");
    fs.renameSync(outPath + ".tmp", outPath);
    console.log("matchups_data.lua has been generated!");
}

if (require.main === module) {
    main().catch(e => {
        console.error("Fatal error:", e);
        process.exit(1);
    });
}
