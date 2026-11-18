/**
 * Generate the iOS app icon set and the launch screen images from one SVG definition.
 *
 * The mark is a parchment quest slip stamped with a brass seal — the "turn in a quest"
 * moment of the app. Colours are the Guild Board (dark) and Daylight (light) tokens from
 * `.design/DESIGN.md`; this script is the only other place they are written as literals.
 *
 * Output (written into ios/Runner/Assets.xcassets/):
 *   AppIcon.appiconset/*.png      opaque RGB (the App Store rejects an alpha channel)
 *   LaunchImage.imageset/*.png    mark + wordmark on transparency, light and dark variants
 *   LaunchBackground.colorset/    solid background colour, light and dark
 * and `.design/icon/app-icon.svg` (the 1024 master, for reference).
 *
 * Usage: node .design/icon/generate.mjs [--out DIR]   (DIR replaces ios/Runner/Assets.xcassets)
 * Playwright is resolved from NODE_PATH when the project has no node_modules.
 */
import { readFileSync, writeFileSync, mkdirSync } from 'node:fs';
import { dirname, resolve } from 'node:path';
import { fileURLToPath } from 'node:url';
import { createRequire } from 'node:module';
import { deflateSync } from 'node:zlib';

const HERE = dirname(fileURLToPath(import.meta.url));
const ROOT = resolve(HERE, '../..');
const outArg = process.argv.indexOf('--out');
const CATALOG = outArg > 0 ? resolve(process.argv[outArg + 1]) : resolve(ROOT, 'ios/Runner/Assets.xcassets');

let chromium;
try {
  ({ chromium } = await import('playwright'));
} catch {
  const require = createRequire(import.meta.url);
  ({ chromium } = require(require.resolve('playwright', { paths: (process.env.NODE_PATH ?? '').split(':').filter(Boolean) })));
}

const THEMES = {
  dark: {
    boardTop: '#1B2723', boardBottom: '#0F1613', glow: '#D8AE5A', glowOpacity: 0.22,
    slip: '#F1E7D3', slipEdge: '#E3D6BB', ink: '#1F2A26', pip: '#C99A3F',
    seal: '#D8AE5A', sealEdge: '#B98E3C', sealHighlight: '#E9C679', inkOnBrass: '#2A1F0A',
    ground: '#121A17', text: '#ECE6D8', shadow: 0.5,
  },
  light: {
    boardTop: '#F4EEE1', boardBottom: '#F4EEE1', glow: '#B4832A', glowOpacity: 0.14,
    slip: '#FFFDF7', slipEdge: '#E0D3B8', ink: '#1F2A26', pip: '#B4832A',
    seal: '#B4832A', sealEdge: '#8F6619', sealHighlight: '#CB9A41', inkOnBrass: '#FFF8E8',
    ground: '#F4EEE1', text: '#1F2A26', shadow: 0.22,
  },
};

/** The mark in a 1024-unit box, drawn around (512, 512). */
function mark(t) {
  const bars = [
    [-190, 34, 300, 0.88],
    [-118, 22, 380, 0.26],
    [-66, 22, 330, 0.26],
    [-14, 22, 250, 0.26],
  ].map(([y, h, w, a]) => `<rect x="${-250 + 70}" y="${y}" width="${w}" height="${h}" rx="${h / 2}" fill="${t.ink}" opacity="${a}"/>`).join('');
  const pip = (x) => `<path d="M${x} 190 l22 24 l-22 24 l-22 -24 z" fill="${t.pip}"/>`;
  const scallops = Array.from({ length: 16 }, (_, i) => {
    const a = (i / 16) * 2 * Math.PI;
    return `<circle cx="${(652 + 168 * Math.cos(a)).toFixed(1)}" cy="${(694 + 168 * Math.sin(a)).toFixed(1)}" r="21" fill="${t.sealEdge}"/>`;
  }).join('');
  return `
  <g filter="url(#drop)">
    <g transform="translate(446 468) rotate(-7)">
      <rect x="-250" y="-310" width="500" height="620" rx="46" fill="${t.slip}" stroke="${t.slipEdge}" stroke-width="5"/>
      ${bars}${pip(-168)}${pip(-116)}${pip(-64)}
      <circle cx="0" cy="-268" r="27" fill="${t.sealEdge}"/><circle cx="0" cy="-272" r="21" fill="${t.seal}"/><circle cx="-7" cy="-279" r="7" fill="${t.sealHighlight}"/>
    </g>
  </g>
  <g filter="url(#drop)">
    <circle cx="652" cy="694" r="170" fill="${t.sealEdge}"/>
    ${scallops}
    <circle cx="652" cy="694" r="162" fill="${t.seal}"/>
    <circle cx="652" cy="694" r="164" fill="url(#shine)"/>
    <circle cx="652" cy="694" r="128" fill="none" stroke="${t.inkOnBrass}" stroke-opacity="0.28" stroke-width="6"/>
    <path d="M588 700 L634 746 L722 640" fill="none" stroke="${t.inkOnBrass}" stroke-width="34" stroke-linecap="round" stroke-linejoin="round"/>
  </g>`;
}

function defs(t) {
  return `<defs>
    <linearGradient id="board" x1="0" y1="0" x2="0" y2="1"><stop offset="0" stop-color="${t.boardTop}"/><stop offset="1" stop-color="${t.boardBottom}"/></linearGradient>
    <radialGradient id="glow" cx="0.5" cy="0.5" r="0.5"><stop offset="0" stop-color="${t.glow}" stop-opacity="${t.glowOpacity}"/><stop offset="1" stop-color="${t.glow}" stop-opacity="0"/></radialGradient>
    <radialGradient id="shine" cx="0.35" cy="0.3" r="0.8"><stop offset="0" stop-color="${t.sealHighlight}" stop-opacity="0.75"/><stop offset="0.6" stop-color="${t.sealHighlight}" stop-opacity="0"/></radialGradient>
    <filter id="drop" x="-30%" y="-30%" width="160%" height="160%"><feDropShadow dx="0" dy="22" stdDeviation="22" flood-color="#000" flood-opacity="${t.shadow}"/></filter>
  </defs>`;
}

const iconSvg = (t) => `<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 1024 1024" width="1024" height="1024">
  ${defs(t)}
  <rect width="1024" height="1024" fill="url(#board)"/>
  <circle cx="560" cy="600" r="470" fill="url(#glow)"/>
  ${mark(t)}
</svg>`;

/** Mark + wordmark on transparency, 800x1000 units; the font is embedded as base64. */
function splashHtml(t, fontB64) {
  return `<!doctype html><meta charset="utf-8"><style>
    @font-face { font-family: Figtree; font-weight: 700; src: url(data:font/ttf;base64,${fontB64}); }
    html, body { margin: 0; background: transparent; }
    svg { display: block; width: 180px; height: 225px; }
    text { font-family: Figtree; font-weight: 700; font-size: 150px; letter-spacing: -3px; }
  </style>
  <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 800 1000">
    ${defs(t)}
    <g transform="translate(-24 -6) scale(0.86) translate(60 40)">${mark(t)}</g>
    <text x="400" y="905" text-anchor="middle" fill="${t.text}">Questlog</text>
  </svg>`;
}

function pngRgb(width, height, rgba) {
  const stride = width * 3;
  const raw = Buffer.alloc((stride + 1) * height);
  for (let y = 0; y < height; y++) {
    raw[y * (stride + 1)] = 0;
    for (let x = 0; x < width; x++) {
      const s = (y * width + x) * 4, d = y * (stride + 1) + 1 + x * 3;
      raw[d] = rgba[s]; raw[d + 1] = rgba[s + 1]; raw[d + 2] = rgba[s + 2];
    }
  }
  const crcTable = Array.from({ length: 256 }, (_, n) => { let c = n; for (let k = 0; k < 8; k++) c = c & 1 ? 0xedb88320 ^ (c >>> 1) : c >>> 1; return c >>> 0; });
  const crc = (buf) => { let c = 0xffffffff; for (const b of buf) c = crcTable[(c ^ b) & 0xff] ^ (c >>> 8); return (c ^ 0xffffffff) >>> 0; };
  const chunk = (type, data) => {
    const body = Buffer.concat([Buffer.from(type), data]);
    const out = Buffer.alloc(body.length + 8);
    out.writeUInt32BE(data.length, 0); body.copy(out, 4); out.writeUInt32BE(crc(body), body.length + 4);
    return out;
  };
  const ihdr = Buffer.alloc(13);
  ihdr.writeUInt32BE(width, 0); ihdr.writeUInt32BE(height, 4); ihdr[8] = 8; ihdr[9] = 2;
  return Buffer.concat([Buffer.from([137, 80, 78, 71, 13, 10, 26, 10]), chunk('IHDR', ihdr), chunk('IDAT', deflateSync(raw, { level: 9 })), chunk('IEND', Buffer.alloc(0))]);
}

const hexToRgb = (h) => [1, 3, 5].map((i) => parseInt(h.slice(i, i + 2), 16) / 255);
const write = (path, data) => { mkdirSync(dirname(path), { recursive: true }); writeFileSync(path, data); };

const browser = await chromium.launch();
const page = await browser.newPage();

// App icon — dark only; rendered straight from the SVG at every size so each is crisp.
const appIcon = iconSvg(THEMES.dark);
write(resolve(HERE, 'app-icon.svg'), appIcon + '\n');
const sizes = [...new Set(JSON.parse(readFileSync(resolve(CATALOG, 'AppIcon.appiconset/Contents.json'), 'utf8')).images.map((i) => i.filename))];
for (const filename of sizes) {
  const [, base, scale] = filename.match(/Icon-App-([\d.]+)x[\d.]+@(\d)x\.png/);
  const px = Math.round(parseFloat(base) * Number(scale));
  const { w, h, data } = await page.evaluate(async ({ svg, px }) => {
    const img = new Image();
    img.src = 'data:image/svg+xml;charset=utf-8,' + encodeURIComponent(svg);
    await img.decode();
    const c = document.createElement('canvas'); c.width = c.height = px;
    const ctx = c.getContext('2d');
    ctx.drawImage(img, 0, 0, px, px);
    return { w: px, h: px, data: Array.from(ctx.getImageData(0, 0, px, px).data) };
  }, { svg: appIcon, px });
  write(resolve(CATALOG, 'AppIcon.appiconset', filename), pngRgb(w, h, data));
}

// Launch image — transparent, 180x225 pt at 1x/2x/3x, light + dark.
const font = readFileSync(resolve(ROOT, 'assets/fonts/Figtree-700.ttf')).toString('base64');
for (const [name, t] of Object.entries(THEMES)) {
  for (const scale of [1, 2, 3]) {
    const ctx = await browser.newContext({ viewport: { width: 180, height: 225 }, deviceScaleFactor: scale });
    const p = await ctx.newPage();
    await p.setContent(splashHtml(t, font));
    await p.evaluate(() => document.fonts.ready);
    const png = await p.screenshot({ omitBackground: true });
    write(resolve(CATALOG, 'LaunchImage.imageset', `LaunchImage${name === 'dark' ? 'Dark' : ''}${scale === 1 ? '' : `@${scale}x`}.png`), png);
    await ctx.close();
  }
}
await browser.close();

const launchImages = ['', 'Dark'].flatMap((v) => [1, 2, 3].map((s) => ({
  idiom: 'universal', filename: `LaunchImage${v}${s === 1 ? '' : `@${s}x`}.png`, scale: `${s}x`,
  ...(v ? { appearances: [{ appearance: 'luminosity', value: 'dark' }] } : {}),
})));
write(resolve(CATALOG, 'LaunchImage.imageset/Contents.json'), JSON.stringify({ images: launchImages, info: { version: 1, author: 'xcode' } }, null, 2) + '\n');

const color = (hex, dark) => ({
  idiom: 'universal',
  color: { 'color-space': 'srgb', components: { red: hexToRgb(hex)[0].toFixed(3), green: hexToRgb(hex)[1].toFixed(3), blue: hexToRgb(hex)[2].toFixed(3), alpha: '1.000' } },
  ...(dark ? { appearances: [{ appearance: 'luminosity', value: 'dark' }] } : {}),
});
write(resolve(CATALOG, 'LaunchBackground.colorset/Contents.json'), JSON.stringify({ colors: [color(THEMES.light.ground, false), color(THEMES.dark.ground, true)], info: { version: 1, author: 'xcode' } }, null, 2) + '\n');
console.log('done ->', CATALOG);
