import assert from 'node:assert/strict';
import { readFile } from 'node:fs/promises';
import { dirname, resolve } from 'node:path';
import test from 'node:test';
import { fileURLToPath } from 'node:url';

import {
  CANONICAL_BOOKS,
  parseCompactJson,
  sha256,
  summarizeTranslation,
  verifyContent,
} from './verify_content.mjs';

const root = resolve(dirname(fileURLToPath(import.meta.url)), '..');

test('verifies every shipped translation and devotional locale', async () => {
  const result = await verifyContent(root);
  assert.equal(result.translations.length, 7);
  assert.deepEqual(result.devotionalLocales, ['en', 'es', 'pt', 'fr', 'de', 'it', 'ru']);
  for (const translation of result.translations) {
    assert.equal(translation.bookCount, 66);
    assert.equal(translation.chapterCount, 1189);
    assert(translation.verseCount > 25000);
  }
});

test('structural verification does not assume a fixed Bible verse total', () => {
  const asset = {
    id: 'fixture',
    locale: 'en',
    books: CANONICAL_BOOKS.map(([id, chapterCount]) => ({
      id,
      name: id,
      chapters: Array.from({ length: chapterCount }, (_, index) => ({
        number: index + 1,
        verses: { '1': `Fixture text ${id} ${index + 1}` },
      })),
    })),
  };
  assert.deepEqual(summarizeTranslation(asset, 'fixture'), {
    bookCount: 66,
    chapterCount: 1189,
    verseCount: 1189,
  });

  asset.books[0].chapters.pop();
  assert.throws(() => summarizeTranslation(asset, 'fixture'), /books\[0\].*50 chapters/);
});

test('normalized assets use canonical compact bytes and matching SHA-256', async () => {
  const manifestBytes = await readFile(resolve(root, 'assets/bible/translations.json'));
  const manifest = parseCompactJson(manifestBytes, 'manifest');
  for (const record of manifest.translations) {
    const bytes = await readFile(resolve(root, ...record.asset.split('/')));
    assert.equal(sha256(bytes), record.normalizedSha256);
    assert.doesNotThrow(() => parseCompactJson(bytes, record.asset));
  }
  assert.throws(() => parseCompactJson(Buffer.from('{\n  "a": 1\n}\n'), 'pretty fixture'), /compact JSON/);
});
