// Builds the interactive map page: tools/map/map_template.html + docs/map/map_data.json + docs/map/annotations.json
// -> docs/map/bot_route_map.html (self-contained; open it in a browser or publish it).
//   node tools/map/build_map.cjs
const fs = require('fs');
const path = require('path');
const root = path.resolve(__dirname, '..', '..');
const read = p => fs.readFileSync(path.join(root, p), 'utf8');

const data = JSON.parse(read('docs/map/map_data.json'));
const annotations = JSON.parse(read('docs/map/annotations.json'));
for (const p of annotations.pulls.concat(annotations.stacks)) {
    if (!data.camps.some(c => c.key === p.camp)) throw new Error(`annotation refers to unknown camp ${p.camp}`);
}
const embed = v => JSON.stringify(v).replace(/</g, '\\u003c');
let html = read('tools/map/map_template.html');
for (const [marker, value] of [['/*MAP_DATA*/null', embed(data)], ['/*ANNOTATIONS*/null', embed(annotations)]]) {
    if (!html.includes(marker)) throw new Error('template is missing ' + marker);
    html = html.replace(marker, () => value);
}
const out = path.join(root, 'docs', 'map', 'bot_route_map.html');
fs.writeFileSync(out, html);
console.log(`wrote ${path.relative(root, out)} (${fs.statSync(out).size} bytes), ${data.camps.length} camps, ${annotations.pulls.length} pulls, ${annotations.stacks.length} stacks`);
