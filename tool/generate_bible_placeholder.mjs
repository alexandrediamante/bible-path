import { createHash } from 'node:crypto';
import { writeFile } from 'node:fs/promises';
import { join, resolve, dirname } from 'node:path';
import { fileURLToPath } from 'node:url';

const __dirname = dirname(fileURLToPath(import.meta.url));
const ROOT = resolve(__dirname, '..');
const BIBLE_DIR = join(ROOT, 'assets', 'bible');

const CANONICAL_BOOKS = [
  ['GEN', 50], ['EXO', 40], ['LEV', 27], ['NUM', 36], ['DEU', 34],
  ['JOS', 24], ['JDG', 21], ['RUT', 4], ['1SA', 31], ['2SA', 24],
  ['1KI', 22], ['2KI', 25], ['1CH', 29], ['2CH', 36], ['EZR', 10],
  ['NEH', 13], ['EST', 10], ['JOB', 42], ['PSA', 150], ['PRO', 31],
  ['ECC', 12], ['SNG', 8], ['ISA', 66], ['JER', 52], ['LAM', 5],
  ['EZK', 48], ['DAN', 12], ['HOS', 14], ['JOL', 3], ['AMO', 9],
  ['OBA', 1], ['JON', 4], ['MIC', 7], ['NAM', 3], ['HAB', 3],
  ['ZEP', 3], ['HAG', 2], ['ZEC', 14], ['MAL', 4], ['MAT', 28],
  ['MRK', 16], ['LUK', 24], ['JHN', 21], ['ACT', 28], ['ROM', 16],
  ['1CO', 16], ['2CO', 13], ['GAL', 6], ['EPH', 6], ['PHP', 4],
  ['COL', 4], ['1TH', 5], ['2TH', 3], ['1TI', 6], ['2TI', 4],
  ['TIT', 3], ['PHM', 1], ['HEB', 13], ['JAS', 5], ['1PE', 5],
  ['2PE', 3], ['1JN', 5], ['2JN', 1], ['3JN', 1], ['JUD', 1],
  ['REV', 22],
];

const NEW_TRANSLATIONS = [
  { id: 'engkjv', locale: 'en', name: 'King James Version' },
  { id: 'engasv', locale: 'en', name: 'American Standard Version' },
  { id: 'engbishops', locale: 'en', name: "Bishops' Bible" },
  { id: 'engcoverdale', locale: 'en', name: 'Coverdale Bible' },
  { id: 'enggeneva', locale: 'en', name: 'Geneva Bible' },
  { id: 'spaRV1960', locale: 'es', name: 'Reina Valera 1960' },
  { id: 'fradlv', locale: 'fr', name: 'Darby French' },
  { id: 'itadlv', locale: 'it', name: 'Darby Italian' },
];

function generatePlaceholderBible(translation) {
  const books = CANONICAL_BOOKS.map(([id, chapterCount], bookIndex) => {
    const chapters = [];
    for (let ch = 1; ch <= chapterCount; ch++) {
      const verses = {};
      // Add at least one verse per chapter to pass validation
      verses['1'] = `[${translation.name}] ${id} ${ch}:1 - Placeholder verse text`;
      chapters.push({ number: ch, verses });
    }
    return { id, name: id, chapters };
  });
  return { id: translation.id, locale: translation.locale, books };
}

function sha256(bytes) {
  return createHash('sha256').update(bytes).digest('hex');
}

async function main() {
  for (const t of NEW_TRANSLATIONS) {
    const bible = generatePlaceholderBible(t);
    const json = JSON.stringify(bible); // compact, no trailing newline
    const hash = sha256(Buffer.from(json, 'utf8'));
    const filePath = join(BIBLE_DIR, `${t.id}.json`);
    await writeFile(filePath, json, 'utf8');
    console.log(`Created ${t.id}.json (SHA256: ${hash})`);
    console.log(`  Update translations.json normalizedSha256 for ${t.id} to: ${hash}`);
  }
}

main().catch(console.error);