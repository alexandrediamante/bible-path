import { createHash } from 'node:crypto';
import { readFile } from 'node:fs/promises';
import { dirname, isAbsolute, join, normalize, relative, resolve, sep } from 'node:path';
import { fileURLToPath, pathToFileURL } from 'node:url';

export const REQUIRED_LOCALES = Object.freeze(['en', 'es', 'pt', 'fr', 'de', 'it', 'ru']);

export const CANONICAL_BOOKS = Object.freeze([
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
]);

const TRANSLATION_KEYS = Object.freeze([
  'id', 'locale', 'name', 'abbreviation', 'asset', 'sourceUrl', 'license',
  'licenseUrl', 'attribution', 'sourceSha256', 'normalizedSha256', 'bookCount', 'chapterCount', 'verseCount',
]);
const ASSET_KEYS = Object.freeze(['id', 'locale', 'books']);
const BOOK_KEYS = Object.freeze(['id', 'name', 'chapters']);
const CHAPTER_KEYS = Object.freeze(['number', 'verses']);
const CONTENT_KEYS = Object.freeze(['id', 'locale', 'title', 'license', 'source', 'days']);
const DAY_KEYS = Object.freeze(['number', 'title', 'reference', 'reflection', 'practice', 'prayer']);
const SHA256_PATTERN = /^[0-9a-f]{64}$/;
const VERSE_PATTERN = /^[1-9][0-9]*$/;
const REFERENCE_PATTERN = /^([1-3]?[A-Z]{2,3})\.([1-9][0-9]*)\.([1-9][0-9]*)$/;

function invariant(condition, message) {
  if (!condition) throw new Error(message);
}

function assertExactKeys(value, expected, label) {
  invariant(value && typeof value === 'object' && !Array.isArray(value), `${label} must be an object`);
  const actual = Object.keys(value).sort();
  const wanted = [...expected].sort();
  invariant(JSON.stringify(actual) === JSON.stringify(wanted), `${label} keys must be exactly ${expected.join(', ')}`);
}

function nonEmptyString(value, label) {
  invariant(typeof value === 'string' && value.trim().length > 0, `${label} must be a non-empty string`);
}

export function sha256(bytes) {
  return createHash('sha256').update(bytes).digest('hex');
}

export function parseCompactJson(bytes, label) {
  const text = bytes.toString('utf8');
  invariant(!text.includes('�'), `${label} is not valid UTF-8`);
  let value;
  try {
    value = JSON.parse(text);
  } catch (error) {
    throw new Error(`${label} is invalid JSON: ${error.message}`);
  }
  invariant(text === JSON.stringify(value), `${label} must be deterministic compact JSON without a trailing newline`);
  return value;
}

function safeProjectPath(root, asset, label) {
  nonEmptyString(asset, label);
  invariant(!isAbsolute(asset), `${label} must be project-relative`);
  invariant(!asset.includes('\\'), `${label} must use forward slashes`);
  const absolute = resolve(root, ...asset.split('/'));
  const rel = relative(root, absolute);
  invariant(rel !== '..' && !rel.startsWith(`..${sep}`), `${label} escapes the project root`);
  return absolute;
}

export function summarizeTranslation(asset, label = 'translation asset') {
  assertExactKeys(asset, ASSET_KEYS, label);
  nonEmptyString(asset.id, `${label}.id`);
  nonEmptyString(asset.locale, `${label}.locale`);
  invariant(Array.isArray(asset.books), `${label}.books must be an array`);
  invariant(asset.books.length === CANONICAL_BOOKS.length, `${label} must contain all ${CANONICAL_BOOKS.length} canonical books`);

  let chapterCount = 0;
  let verseCount = 0;
  const canonicalIds = new Set(CANONICAL_BOOKS.map(([id]) => id));

  asset.books.forEach((book, bookIndex) => {
    const [expectedId, expectedChapters] = CANONICAL_BOOKS[bookIndex];
    const bookLabel = `${label}.books[${bookIndex}]`;
    assertExactKeys(book, BOOK_KEYS, bookLabel);
    invariant(book.id === expectedId, `${bookLabel}.id must be ${expectedId}`);
    nonEmptyString(book.name, `${bookLabel}.name`);
    invariant(Array.isArray(book.chapters), `${bookLabel}.chapters must be an array`);
    invariant(book.chapters.length === expectedChapters, `${bookLabel} must contain ${expectedChapters} chapters`);

    book.chapters.forEach((chapter, chapterIndex) => {
      const chapterLabel = `${bookLabel}.chapters[${chapterIndex}]`;
      assertExactKeys(chapter, CHAPTER_KEYS, chapterLabel);
      invariant(chapter.number === chapterIndex + 1, `${chapterLabel}.number must be ${chapterIndex + 1}`);
      invariant(chapter.verses && typeof chapter.verses === 'object' && !Array.isArray(chapter.verses), `${chapterLabel}.verses must be an object`);
      const verseNumbers = Object.keys(chapter.verses);
      invariant(verseNumbers.length > 0, `${chapterLabel}.verses must not be empty`);
      for (const verseNumber of verseNumbers) {
        invariant(VERSE_PATTERN.test(verseNumber), `${chapterLabel} has invalid verse key ${verseNumber}`);
        nonEmptyString(chapter.verses[verseNumber], `${chapterLabel}.verses.${verseNumber}`);
        invariant(!/[\\][a-z0-9*]+\b/i.test(chapter.verses[verseNumber]), `${chapterLabel}.verses.${verseNumber} contains an unprocessed USFM marker`);
      }
      chapterCount += 1;
      verseCount += verseNumbers.length;
    });
  });

  invariant(new Set(asset.books.map((book) => book.id)).size === canonicalIds.size, `${label} has duplicate book IDs`);
  return { bookCount: asset.books.length, chapterCount, verseCount };
}

function validateTranslationRecord(record, index) {
  const label = `translations.json.translations[${index}]`;
  assertExactKeys(record, TRANSLATION_KEYS, label);
  for (const key of ['id', 'locale', 'name', 'abbreviation', 'asset', 'sourceUrl', 'license', 'licenseUrl', 'attribution']) {
    nonEmptyString(record[key], `${label}.${key}`);
  }
  invariant(/^https:\/\//.test(record.sourceUrl), `${label}.sourceUrl must be HTTPS`);
  invariant(/^https:\/\//.test(record.licenseUrl), `${label}.licenseUrl must be HTTPS`);
  invariant(SHA256_PATTERN.test(record.sourceSha256), `${label}.sourceSha256 must be lowercase SHA-256`);
  invariant(SHA256_PATTERN.test(record.normalizedSha256), `${label}.normalizedSha256 must be lowercase SHA-256`);
  for (const key of ['bookCount', 'chapterCount', 'verseCount']) {
    invariant(Number.isSafeInteger(record[key]) && record[key] > 0, `${label}.${key} must be a positive integer`);
  }
  invariant(record.asset.startsWith('assets/bible/') && record.asset.endsWith('.json'), `${label}.asset must name an assets/bible JSON file`);
}

function validateDevotional(asset, locale, label) {
  assertExactKeys(asset, CONTENT_KEYS, label);
  invariant(asset.id === 'seven-days-of-hope', `${label}.id must be seven-days-of-hope`);
  invariant(asset.locale === locale, `${label}.locale must be ${locale}`);
  nonEmptyString(asset.title, `${label}.title`);
  invariant(asset.license === 'CC0-1.0', `${label}.license must be CC0-1.0`);
  nonEmptyString(asset.source, `${label}.source`);
  invariant(/Original|Originale|Originaler|original|Оригинальный/.test(asset.source), `${label}.source must identify original content`);
  invariant(Array.isArray(asset.days) && asset.days.length === 7, `${label}.days must contain exactly seven days`);

  asset.days.forEach((day, index) => {
    const dayLabel = `${label}.days[${index}]`;
    assertExactKeys(day, DAY_KEYS, dayLabel);
    invariant(day.number === index + 1, `${dayLabel}.number must be ${index + 1}`);
    for (const key of ['title', 'reference', 'reflection', 'practice', 'prayer']) nonEmptyString(day[key], `${dayLabel}.${key}`);
    const match = REFERENCE_PATTERN.exec(day.reference);
    invariant(match && CANONICAL_BOOKS.some(([id]) => id === match[1]), `${dayLabel}.reference must use a canonical book ID`);
  });
}

export async function verifyContent(root = resolve(dirname(fileURLToPath(import.meta.url)), '..')) {
  const manifestPath = join(root, 'assets', 'bible', 'translations.json');
  const manifestBytes = await readFile(manifestPath);
  const manifest = parseCompactJson(manifestBytes, 'assets/bible/translations.json');
  assertExactKeys(manifest, ['translations'], 'assets/bible/translations.json');
  invariant(Array.isArray(manifest.translations), 'translations.json.translations must be an array');
  // Require at least one translation per required locale, but allow multiple per locale
  const requiredLocalesSet = new Set(REQUIRED_LOCALES);
  for (const locale of REQUIRED_LOCALES) {
    const hasLocale = manifest.translations.some(t => t.locale === locale);
    invariant(hasLocale, `translations.json must contain at least one translation for locale ${locale}`);
  }

  const ids = new Set();
  const locales = new Map(); // locale -> count
  const assets = new Set();
  const summaries = [];

  for (const [index, record] of manifest.translations.entries()) {
    validateTranslationRecord(record, index);
    invariant(!ids.has(record.id), `duplicate translation id ${record.id}`);
    invariant(!assets.has(record.asset), `duplicate translation asset ${record.asset}`);
    ids.add(record.id);
    assets.add(record.asset);
    const localeCount = locales.get(record.locale) || 0;
    locales.set(record.locale, localeCount + 1);

    const assetPath = safeProjectPath(root, record.asset, `translation ${record.id} asset`);
    const bytes = await readFile(assetPath);
    invariant(sha256(bytes) === record.normalizedSha256, `${record.asset} normalizedSha256 mismatch`);
    const asset = parseCompactJson(bytes, record.asset);
    invariant(asset.id === record.id, `${record.asset}.id does not match manifest`);
    invariant(asset.locale === record.locale, `${record.asset}.locale does not match manifest`);
    const counts = summarizeTranslation(asset, record.asset);
    invariant(counts.verseCount > 25000, `${record.asset} is an incomplete/sample translation (${counts.verseCount} verses); do not ship placeholders`);
    for (const key of ['bookCount', 'chapterCount', 'verseCount']) {
      invariant(counts[key] === record[key], `${record.asset} ${key} is ${counts[key]}, manifest says ${record[key]}`);
    }
    summaries.push({ id: record.id, locale: record.locale, ...counts });
  }

  // Verify all required locales are present (allowing multiple per locale)
  const presentLocales = [...locales.keys()].sort();
  for (const locale of REQUIRED_LOCALES) {
    invariant(locales.has(locale), `translations.json must contain at least one translation for locale ${locale}`);
  }
  // Note: we allow additional translations per locale beyond the required minimum

  const provenance = await readFile(join(root, 'THIRD_PARTY_CONTENT.md'), 'utf8');
  invariant(provenance.includes('Acquisition date: 2026-10-20'), 'THIRD_PARTY_CONTENT.md must record the acquisition date');
  for (const record of manifest.translations) {
    for (const value of [record.id, record.asset, record.sourceUrl, record.license, record.licenseUrl, record.sourceSha256, record.normalizedSha256]) {
      invariant(provenance.includes(value), `THIRD_PARTY_CONTENT.md is missing provenance value ${value}`);
    }
  }

  for (const locale of REQUIRED_LOCALES) {
    const relativePath = `assets/content/devotional-${locale}.json`;
    const bytes = await readFile(safeProjectPath(root, relativePath, `${locale} devotional asset`));
    const asset = parseCompactJson(bytes, relativePath);
    validateDevotional(asset, locale, relativePath);
  }
  invariant(provenance.includes('CC0-1.0') && provenance.includes('assets/content/devotional-'), 'THIRD_PARTY_CONTENT.md must document devotional authorship and license');

  return { translations: summaries, devotionalLocales: [...REQUIRED_LOCALES] };
}

const invokedPath = process.argv[1] ? pathToFileURL(resolve(process.argv[1])).href : '';
if (invokedPath === import.meta.url) {
  try {
    const result = await verifyContent(process.argv[2] ? normalize(resolve(process.argv[2])) : undefined);
    for (const item of result.translations) {
      console.log(`${item.locale}: ${item.id} — ${item.bookCount} books, ${item.chapterCount} chapters, ${item.verseCount} verses`);
    }
    console.log(`devotionals: ${result.devotionalLocales.length} locales × 7 days`);
    console.log('content verification passed');
  } catch (error) {
    console.error(`content verification failed: ${error.message}`);
    process.exitCode = 1;
  }
}
