// Minimal parser for Valve KeyValues text (the format of d2vpkr's scripts/npc files).
// Returns nested objects of { key: value }, where value is a string or another object.
// Repeated keys keep the last value; `//` comments and `[$PLATFORM]` conditionals are skipped.
function parseKV(text) {
    const tokens = [];
    const re = /"((?:[^"\\]|\\.)*)"|([{}])|\/\/[^\n]*|\[[^\]\n]*\]|([^\s{}"]+)/g;
    for (const m of text.matchAll(re)) {
        if (m[1] !== undefined) tokens.push({ str: m[1] });
        else if (m[2] !== undefined) tokens.push({ brace: m[2] });
        else if (m[3] !== undefined) tokens.push({ str: m[3] });
    }
    let i = 0;
    function block() {
        const obj = {};
        while (i < tokens.length) {
            const t = tokens[i++];
            if (t.brace === '}') return obj;
            if (t.brace === '{') continue; // stray brace
            const next = tokens[i];
            if (next === undefined) break;
            if (next.brace === '{') { i++; obj[t.str] = block(); }
            else if (next.brace === '}') { obj[t.str] = ''; }
            else { i++; obj[t.str] = next.str; }
        }
        return obj;
    }
    return block();
}

module.exports = { parseKV };
