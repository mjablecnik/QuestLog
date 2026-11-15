/**
 * Assemble `preview.html` — a single self-contained review page that embeds every rendered
 * screen from `screens/` as a data URI, next to the name proposals and the UX notes.
 *
 * Run `node .design/render.mjs` first so the PNGs are current.
 *
 * Usage: node .design/build-preview.mjs
 */
import { readFileSync, writeFileSync } from 'node:fs';
import { dirname, resolve } from 'node:path';
import { fileURLToPath } from 'node:url';

const HERE = dirname(fileURLToPath(import.meta.url));
const png = (name) =>
  `data:image/png;base64,${readFileSync(resolve(HERE, 'screens', `${name}.png`)).toString('base64')}`;

/* Review copy is Czech — it is addressed to the product owner, not to developers. */
const screens = [
  {
    name: 'QuestBoard',
    title: 'Nástěnka',
    note: 'Domovská obrazovka. Nahoře hrdinský pruh s úrovní a XP, pod ním vyvěšené questy jako pergamenové lístky. Splněné se „odevzdají" — zešednou a dostanou mosaznou pečeť. Vpravo nahoře součet XP, který je dnes ve hře.',
  },
  {
    name: 'SwipeActions',
    title: 'Upravit / smazat quest',
    note: 'Tažením lístku doleva se odkryjí dvě akce. Klepnutí na kroužek quest splní, klepnutí na lístek ho otevře k úpravě. Žádné skryté menu — vše je na jeden pohyb.',
  },
  {
    name: 'QuestComplete',
    title: 'Quest splněn',
    note: 'Odměnový moment po zaškrtnutí: pečeť, získané XP a — pokud quest patří do mise — posun mise. Zobrazí se na ~1,5 s a samo zmizí, tlačítko „Pokračovat" ho jen urychlí.',
  },
  {
    name: 'NewQuest',
    title: 'Nový quest',
    note: 'Spodní list přes nástěnku. Tři pole, která opravdu potřebuješ: co udělat, obtížnost (ta rovnou určuje XP, žádné ruční zadávání čísel) a do které mise quest patří. Poznámka je nepovinná.',
  },
  {
    name: 'Missions',
    title: 'Mise',
    note: 'Mise jsou tmavé karty s prstencem postupu — liší se od questů tvarem, ne barvou. Každá říká, co zbývá, a kolik XP přinese dokončení navíc k XP za jednotlivé questy.',
  },
  {
    name: 'MissionDetail',
    title: 'Detail mise',
    note: 'Postup mise, zbývající a splněné questy, přidání dalšího přímo do mise. Úprava a smazání mise jsou pod tlačítkem „···" vpravo nahoře (zde rozbalené).',
  },
  {
    name: 'NewMission',
    title: 'Nová mise',
    note: 'Název, velikost odměny za dokončení a rovnou seznam questů, ze kterých se mise skládá — mise bez questů nedává smysl, tak se zakládají spolu.',
  },
  {
    name: 'EmptyBoard',
    title: 'Prázdná nástěnka',
    note: 'První spuštění: úroveň 1, 0 XP, prázdný lístek přišpendlený na desce a jedna věta, co dělat.',
  },
  {
    name: 'QuestBoardLight',
    title: 'Světlá varianta',
    note: 'Stejné tokeny přepnuté do světla — podklad je pergamen, lístky bílé, mosaz ztmavne kvůli kontrastu. Aplikace může sledovat systémové nastavení iOS.',
  },
  {
    name: 'Settings',
    title: 'Nastavení',
    note: 'Ozubené kolečko v hrdinském pruhu. Jazyk (čeština / English), vzhled (světlý / tmavý / systém) a pravidelné mise: klepnutí na řádek pravidlo upraví, „Vyvěsit teď" ho založí hned. Řádek „Vyvěšeno" ukazuje stav po ručním vyvěšení. Dole dočasná sekce s výběrem písma titulků.',
  },
  {
    name: 'FontPicker',
    title: 'Písmo titulků (dočasné)',
    note: 'Šest písem z minulého kola přímo v aplikaci — každé ukázané samo sebou. Přepíná jen roli „titulky a čísla", projeví se okamžitě. Až se rozhodneš, sekce zmizí a zůstane jedno písmo.',
  },
  {
    name: 'RecurringMission',
    title: 'Pravidelná mise',
    note: 'Pravidlo, ne jednorázová mise: název, opakování (denně · týdně · každé 2 týdny · měsíčně · čtvrtletně · ročně), přesný den vyvěšení, odměna a šablona questů. Podle něj se v nastavený den založí čerstvá mise.',
  },
];

const names = [
  {
    name: 'Questlog',
    verdict: 'doporučuji',
    why: 'Sourozenec TimeLogu a Worklogu — stejná rodina názvů, jedním slovem říká, co to je. „Quest log" je navíc zažitý pojem z RPG, takže název už nese herní náladu sám o sobě. Doména i bundle id (`cz.jablecnik.questlog`) se čtou čistě.',
  },
  {
    name: 'Sidequest',
    verdict: 'alternativa',
    why: 'Vtipná sebeironie — domácí povinnosti jako vedlejší úkoly života. Nevýhoda: naznačuje, že úkoly nejsou důležité, a pro mise se hodí hůř.',
  },
  {
    name: 'Cechovní deska / Guildboard',
    verdict: 'alternativa',
    why: 'Pojmenovává metaforu návrhu (nástěnka s vyvěšenými questy). Delší a méně univerzální — kdyby se někdy přidaly návyky nebo statistiky, název už nesedí.',
  },
  {
    name: 'Epos',
    verdict: 'alternativa',
    why: 'Krátké, české, zapamatovatelné: život jako epos poskládaný z misí. Je ale abstraktnější — z názvu není poznat, že jde o úkoly.',
  },
];

const html = `<title>Questlog</title>
<style>
  :root {
    --board: #121a17; --raised: #1a2522; --line: rgba(236,230,216,0.08);
    --text: #ece6d8; --dim: rgba(236,230,216,0.64); --faint: rgba(236,230,216,0.42);
    --parchment: #f1e7d3; --ink: #1f2a26; --ink-dim: rgba(31,42,38,0.62);
    --brass: #d8ae5a; --brass-soft: rgba(216,174,90,0.16); --ink-on-brass: #2a1f0a;
    --display: 'Figtree', system-ui, -apple-system, sans-serif; --body: 'Figtree', system-ui, -apple-system, sans-serif;
  }
  body { margin: 0; background: var(--board); color: var(--text); font-family: var(--body); font-size: 16px; line-height: 1.5; -webkit-font-smoothing: antialiased; }
  .wrap { max-width: 1180px; margin: 0 auto; padding: 56px 28px 96px; display: flex; flex-direction: column; gap: 72px; }
  h1, h2, h3 { font-family: var(--display); font-weight: 700; letter-spacing: -0.02em; line-height: 1.1; margin: 0; text-wrap: balance; }
  h1 { font-size: clamp(44px, 7vw, 72px); }
  h2 { font-size: 30px; }
  h3 { font-size: 20px; }
  p { margin: 0; }
  .lbl { font-size: 11px; letter-spacing: 0.16em; text-transform: uppercase; font-weight: 600; color: var(--faint); }
  .brass { color: var(--brass); }
  .dim { color: var(--dim); }

  header { display: grid; grid-template-columns: 1.2fr 1fr; gap: 40px; align-items: end; }
  header .lead { font-size: 19px; color: var(--dim); max-width: 48ch; margin-top: 18px; }
  header .hero-shot { justify-self: end; width: min(100%, 300px); border-radius: 36px; box-shadow: 0 40px 90px rgba(0,0,0,0.55); border: 1px solid var(--line); display: block; }
  @media (max-width: 760px) { header { grid-template-columns: 1fr; } header .hero-shot { justify-self: start; } }

  section { display: flex; flex-direction: column; gap: 24px; }
  .intro { color: var(--dim); max-width: 66ch; }

  .names { display: grid; grid-template-columns: repeat(auto-fit, minmax(240px, 1fr)); gap: 16px; }
  .name {
    padding: 22px 22px 20px; border-radius: 16px; background: var(--raised); border: 1px solid var(--line);
    display: flex; flex-direction: column; gap: 10px;
  }
  .name.pick { background: var(--parchment); color: var(--ink); border-color: transparent; box-shadow: 0 20px 50px rgba(0,0,0,0.35); }
  .name .verdict { font-size: 11px; letter-spacing: 0.14em; text-transform: uppercase; font-weight: 700; color: var(--faint); }
  .name.pick .verdict { color: var(--brass); }
  .name h3 { font-size: 26px; }
  .name p { font-size: 14.5px; color: var(--dim); }
  .name.pick p { color: var(--ink-dim); }
  code { font-family: ui-monospace, SFMono-Regular, Menlo, monospace; font-size: 0.92em; background: rgba(127,127,127,0.14); padding: 1px 5px; border-radius: 4px; }

  .tokens { display: grid; grid-template-columns: repeat(auto-fit, minmax(150px, 1fr)); gap: 12px; }
  .swatch { border-radius: 12px; overflow: hidden; border: 1px solid var(--line); background: var(--raised); }
  .swatch i { display: block; height: 64px; }
  .swatch div { padding: 10px 12px; font-size: 12.5px; }
  .swatch b { display: block; font-weight: 600; }
  .swatch span { color: var(--faint); font-variant-numeric: tabular-nums; font-family: ui-monospace, SFMono-Regular, Menlo, monospace; font-size: 11.5px; }
  .type-row { display: grid; grid-template-columns: repeat(auto-fit, minmax(260px, 1fr)); gap: 16px; }
  .type-card { padding: 20px 22px; border-radius: 14px; background: var(--raised); border: 1px solid var(--line); }
  .type-card .sample { font-size: 34px; line-height: 1.1; margin: 6px 0 10px; }
  .type-card .sample.body { font-family: var(--body); font-size: 22px; font-weight: 500; }
  .type-card p { font-size: 13.5px; color: var(--dim); }

  .screens { display: grid; grid-template-columns: repeat(auto-fill, minmax(250px, 1fr)); gap: 28px 24px; }
  figure { margin: 0; display: flex; flex-direction: column; gap: 14px; }
  figure img { width: 100%; display: block; border-radius: 28px; border: 1px solid var(--line); box-shadow: 0 24px 60px rgba(0,0,0,0.45); }
  figcaption { display: flex; flex-direction: column; gap: 5px; padding: 0 4px; }
  figcaption b { font-size: 16px; font-weight: 600; }
  figcaption p { font-size: 13.5px; color: var(--dim); }

  .decisions { display: grid; grid-template-columns: repeat(auto-fit, minmax(280px, 1fr)); gap: 14px; }
  .decision { padding: 18px 20px; border-radius: 14px; background: var(--raised); border: 1px solid var(--line); display: flex; flex-direction: column; gap: 6px; }
  .decision b { font-weight: 600; }
  .decision.pick { border-color: var(--brass); background: var(--brass-soft); }
  .wide { width: 100%; display: block; border-radius: 18px; border: 1px solid var(--line); }
  .decision p { font-size: 14px; color: var(--dim); }

  ol.questions { margin: 0; padding-left: 22px; display: flex; flex-direction: column; gap: 12px; max-width: 70ch; }
  ol.questions li::marker { color: var(--brass); font-weight: 700; }
  ol.questions b { font-weight: 600; }
  ol.questions p { color: var(--dim); font-size: 15px; }

  footer { color: var(--faint); font-size: 13px; border-top: 1px solid var(--line); padding-top: 20px; }
  @media (prefers-reduced-motion: no-preference) { figure img { transition: transform 0.25s ease; } figure:hover img { transform: translateY(-4px); } }
</style>
<link rel="stylesheet" href="https://fonts.googleapis.com/css2?family=Figtree:wght@400;500;600;700;800&display=swap">

<div class="wrap">
  <header>
    <div>
      <div class="lbl brass">Návrh · 3. kolo · 15. 11. 2026</div>
      <h1 style="margin-top: 14px">Questlog</h1>
      <p class="lead">Nástěnka, na kterou si vyvěsíš, co je potřeba udělat. Jednorázové úkoly jsou <b>questy</b>, dlouhodobé cíle složené z více questů jsou <b>mise</b>. Za splněné získáváš XP a úrovně — nic víc, nic míň.</p>
    </div>
    <img class="hero-shot" src="${png('QuestBoard')}" alt="Nástěnka s vyvěšenými questy">
  </header>

  <section>
    <div>
      <div class="lbl">01 · Název</div>
      <h2 style="margin-top: 8px">Questlog — schváleno</h2>
    </div>
    <div class="names">
      ${names
        .map(
          (n, i) => `<div class="name${i === 0 ? ' pick' : ''}">
        <span class="verdict">${i === 0 ? 'schváleno' : n.verdict}</span>
        <h3>${n.name}</h3>
        <p>${n.why}</p>
      </div>`,
        )
        .join('\n')}
    </div>
  </section>

  <section>
    <div>
      <div class="lbl">02 · Vizuální směr</div>
      <h2 style="margin-top: 8px">Cechovní nástěnka</h2>
    </div>
    <p class="intro">Questy jsou světlé pergamenové lístky vyvěšené na tmavé desce — proto ten kontrast. Mosaz je jediný akcent a znamená vždy totéž: odměnu, splnění, hlavní akci. Mise se od questů liší tvarem (tmavá karta s prstencem postupu), ne další barvou, takže paleta zůstává klidná i při plné nástěnce.</p>
    <div class="tokens">
      <div class="swatch"><i style="background:#121a17"></i><div><b>Deska</b><span>#121A17</span></div></div>
      <div class="swatch"><i style="background:#1a2522"></i><div><b>Deska · vyvýšená</b><span>#1A2522</span></div></div>
      <div class="swatch"><i style="background:#f1e7d3"></i><div><b>Pergamen</b><span>#F1E7D3</span></div></div>
      <div class="swatch"><i style="background:#1f2a26"></i><div><b>Inkoust</b><span>#1F2A26</span></div></div>
      <div class="swatch"><i style="background:#d8ae5a"></i><div><b>Mosaz</b><span>#D8AE5A</span></div></div>
      <div class="swatch"><i style="background:#d96b5a"></i><div><b>Smazat</b><span>#D96B5A</span></div></div>
    </div>
    <div class="type-row">
      <div class="type-card">
        <span class="lbl">Titulky a čísla · výchozí Figtree, přepínatelné</span>
        <div class="sample" style="font-family: var(--display); font-weight: 700; letter-spacing: -0.02em">Nástěnka · <span class="brass">+25</span></div>
        <p><b>Figtree 700–800</b> jako výchozí. Role „titulky" je oddělená (<code>--font-display</code> / vlastní <code>TextTheme</code> styl) a první verze má v Nastavení dočasný přepínač mezi všemi šesti kandidáty — vybereš za běhu, pak přepínač odstraníme.</p>
      </div>
      <div class="type-card">
        <span class="lbl">Text a ovládání</span>
        <div class="sample body">Zamést podlahu · Úklid</div>
        <p><b>Figtree 400–600</b> — čitelný geometrický grotesk blízký systémovému písmu iOS, takže formuláře a seznamy působí nativně.</p>
      </div>
    </div>
  </section>

  <section>
    <div>
      <div class="lbl">03 · Obrazovky</div>
      <h2 style="margin-top: 8px">Dvanáct stavů aplikace</h2>
    </div>
    <div class="screens">
      ${screens
        .map(
          (s) => `<figure>
        <img src="${png(s.name)}" alt="${s.title}" loading="lazy">
        <figcaption><b>${s.title}</b><p>${s.note}</p></figcaption>
      </figure>`,
        )
        .join('\n')}
    </div>
  </section>

  <section>
    <div>
      <div class="lbl">04 · Rozhodnutí v návrhu</div>
      <h2 style="margin-top: 8px">Co jsem rozhodl za tebe</h2>
    </div>
    <div class="decisions">
      <div class="decision"><b>XP určuje obtížnost, ne ruční číslo</b><p>Snadný +10, běžný +25, těžký +50. Tři volby místo číselného pole — rychlejší zadání a XP zůstávají mezi questy srovnatelné.</p></div>
      <div class="decision"><b>Mise má bonus za dokončení</b><p>Malá +50, střední +100, velká +200 navíc k XP z questů. Bez toho by mise byla jen složka; s bonusem má smysl ji dotáhnout.</p></div>
      <div class="decision"><b>Quest může být i bez mise</b><p>„Vynést odpadky" nemusí patřit nikam. Nástěnka ukazuje vše pohromadě, chip prozradí misi tam, kde je.</p></div>
      <div class="decision"><b>Úrovně rostou pomalu</b><p>Úroveň 1 → 2 za 100 XP, dál se hranice zvyšuje. Přesnou křivku doladíme před implementací.</p></div>
      <div class="decision"><b>Splněné zůstávají vidět do 4:00 ráno</b><p>Odevzdané questy zůstanou dole na nástěnce jako „Splněno dnes" a dokončené mise na záložce Mise. Nový den začíná ve 4:00, takže po půlnoci ještě vidíš včerejšek. Pak zmizí — žádná historie.</p></div>
      <div class="decision"><b>Pravidelná mise je pravidlo, ne mise</b><p>V nastavení definuješ šablonu (název, questy, odměna, opakování, den). V nastavený den se z ní vyvěsí nová mise; nedokončené questy z minulého období se nepřenášejí. Co s nedotaženou starou misí: uzavře se bez bonusu, XP za splněné questy zůstávají.</p></div>
      <div class="decision"><b>Ruční vyvěšení nahradí nejbližší automatické</b><p>„Vyvěsit teď" založí misi z pravidla hned. Dokud z tohoto pravidla visí mise vyvěšená ručně — ať je splněná celá, zčásti nebo vůbec — automatické vyvěšení v nejbližším termínu se přeskočí a pravidlo pokračuje až dalším termínem.</p></div>
      <div class="decision"><b>Bez termínů, bez streaku, bez historie</b><p>Podle tvého rozhodnutí: questy nemají datum splnění, nástěnka ukazuje vše otevřené. Historii nahrazuje „Splněno dnes" a dokončené mise v seznamu misí.</p></div>
      <div class="decision"><b>Projekty zatím ne, ale cesta zůstává volná</b><p>Datový model nechá misi i questu místo pro nadřazený „projekt" (jako v TimeLogu); v UI se neukáže, dokud se podle používání neukáže potřeba.</p></div>
      <div class="decision"><b>Písmo titulků se vybere používáním</b><p>Všech šest kandidátů se přibalí do aplikace (~1–2 MB) a v Nastavení je dočasný přepínač. Volba se ukládá lokálně. Jakmile se rozhodneš, přepínač a pět písem z aplikace odejdou.</p></div>
      <div class="decision"><b>Nastavení je jen jedno kolečko</b><p>Žádná třetí záložka — jazyk, vzhled a pravidelné mise se otevírají z ozubeného kolečka v hrdinském pruhu. Záložky zůstávají dvě: questy a mise.</p></div>
      <div class="decision"><b>Jazyk a vzhled se řídí systémem, dokud neřekneš jinak</b><p>Výchozí je „Systém“ pro vzhled a jazyk podle iOS (cs → čeština, jinak English). Obojí jde v nastavení přepsat.</p></div>
      <div class="decision"><b>Žádný účet, žádný server</b><p>Vše lokálně v telefonu (SQLite / Drift), stejně jako TimeLog. Synchronizace přes iCloud je případná další fáze.</p></div>
    </div>
  </section>

  <section>
    <div>
      <div class="lbl">05 · K rozhodnutí</div>
      <h2 style="margin-top: 8px">Poslední drobnosti</h2>
    </div>
    <ol class="questions">
      <li><b>Den vyvěšení u delších period</b><p>Měsíčně = den v měsíci, čtvrtletně a ročně = konkrétní datum (např. 1. 3.), denně = bez dne. Týdně a každé 2 týdny = den v týdnu. Sedí?</p></li>
      <li><b>Nedotažená pravidelná mise při novém termínu</b><p>Návrh ji uzavře bez bonusu (viz výše). Pokud bys ji radši nechal viset vedle nové, řekni.</p></li>
      <li><b>Hotovo k zadání?</b><p>Pokud ano, dalším krokem je Kiro spec (datový model, obrazovky, chování pravidel) a pak Flutter implementace.</p></li>
    </ol>
  </section>

  <footer>Artboardy: <code>questlog/.design/artboards/*.dc.html</code> · rendery: <code>.design/screens/</code> · tokeny: <code>.design/theme.css</code>. Tuto stránku generuje <code>.design/build-preview.mjs</code>.</footer>
</div>
`;

writeFileSync(resolve(HERE, 'preview.html'), html);
console.log(`preview.html written (${(Buffer.byteLength(html) / 1024 / 1024).toFixed(2)} MB)`);
