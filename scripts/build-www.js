// Kopiuje pliki aplikacji do katalogu www/, który Capacitor pakuje do APK.
const fs = require('fs');
const path = require('path');

const root = path.join(__dirname, '..');
const out = path.join(root, 'www');
fs.rmSync(out, { recursive: true, force: true });
fs.mkdirSync(out, { recursive: true });
for (const f of ['index.html', 'manifest.json', 'sw.js']) fs.copyFileSync(path.join(root, f), path.join(out, f));
for (const d of ['icons', 'vendor']) fs.cpSync(path.join(root, d), path.join(out, d), { recursive: true });
console.log('www/ gotowy');
