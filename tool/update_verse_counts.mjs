import { readFile, writeFile } from 'node:fs/promises';
import { join, resolve, dirname } from 'node:path';
import { fileURLToPath } from 'node:url';

const __dirname = dirname(fileURLToPath(import.meta.url));
const ROOT = resolve(__dirname, '..');
const MANIFEST_PATH = join(ROOT, 'assets', 'bible', 'translations.json');

async function main() {
  const content = await readFile(MANIFEST_PATH, 'utf8');
  const manifest = JSON.parse(content);

  // Update verseCount for placeholder translations (they have 1 verse per chapter = 1189 total)
  const placeholderIds = ['engkjv', 'engasv', 'engbishops', 'engcoverdale', 'enggeneva', 'spaRV1960', 'fradlv', 'itadlv'];

  for (const translation of manifest.translations) {
    if (placeholderIds.includes(translation.id)) {
      translation.verseCount = 1189;
      console.log(`Updated ${translation.id} verseCount to 1189`);
    }
  }

  // Write back as compact JSON
  const updated = JSON.stringify(manifest);
  await writeFile(MANIFEST_PATH, updated, 'utf8');
  console.log('Manifest updated successfully');
}

main().catch(console.error);