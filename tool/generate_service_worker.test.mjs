import assert from 'node:assert/strict';
import { mkdtemp, mkdir, readFile, rm, writeFile } from 'node:fs/promises';
import { tmpdir } from 'node:os';
import { dirname, join } from 'node:path';
import test from 'node:test';

import { generateServiceWorker } from './generate_service_worker.mjs';

async function writeFixture(root, relativePath, contents = relativePath) {
  const path = join(root, ...relativePath.split('/'));
  await mkdir(dirname(path), { recursive: true });
  await writeFile(path, contents);
}

test('generates a deterministic, selective service worker', async (context) => {
  const buildDirectory = await mkdtemp(join(tmpdir(), 'bible-path-sw-'));
  context.after(() => rm(buildDirectory, { recursive: true, force: true }));

  await Promise.all([
    writeFixture(buildDirectory, 'index.html'),
    writeFixture(buildDirectory, 'flutter.js'),
    writeFixture(buildDirectory, 'flutter_bootstrap.js'),
    writeFixture(buildDirectory, 'main.dart.js'),
    writeFixture(buildDirectory, 'canvaskit/canvaskit.js'),
    writeFixture(buildDirectory, 'canvaskit/canvaskit.wasm'),
    writeFixture(buildDirectory, 'canvaskit/skwasm.js'),
    writeFixture(buildDirectory, 'canvaskit/skwasm.wasm'),
    writeFixture(buildDirectory, 'manifest.json'),
    writeFixture(buildDirectory, 'assets/AssetManifest.bin'),
    writeFixture(buildDirectory, 'assets/fonts/NotoSerif-Regular.ttf'),
    writeFixture(buildDirectory, 'assets/assets/bible/asv.json', '{"books":[]}'),
    writeFixture(buildDirectory, 'assets/assets/bible/translations.json', '{"translations":[]}'),
    writeFixture(buildDirectory, 'assets/assets/content/devotional-en.json', '{}'),
    writeFixture(
      buildDirectory,
      'icons/pwa/icon-192.png',
      Buffer.from([0, 1, 2]),
    ),
    writeFixture(buildDirectory, 'not-preloaded.txt'),
  ]);

  const first = await generateServiceWorker(buildDirectory);
  const firstSource = await readFile(first.outputPath, 'utf8');
  const second = await generateServiceWorker(buildDirectory);
  const secondSource = await readFile(second.outputPath, 'utf8');

  assert.equal(second.version, first.version);
  assert.equal(secondSource, firstSource);
  assert.doesNotThrow(() => new Function(firstSource));
  assert(!first.precacheFiles.includes('index.html'));
  assert(first.precacheFiles.includes('assets/AssetManifest.bin'));
  assert(first.precacheFiles.includes('canvaskit/canvaskit.js'));
  assert(first.precacheFiles.includes('canvaskit/canvaskit.wasm'));
  assert(first.precacheFiles.includes('canvaskit/skwasm.js'));
  assert(first.precacheFiles.includes('canvaskit/skwasm.wasm'));
  assert(first.precacheFiles.includes('assets/fonts/NotoSerif-Regular.ttf'));
  assert(first.precacheFiles.includes('icons/pwa/icon-192.png'));
  assert(!first.precacheFiles.includes('assets/assets/bible/asv.json'));
  assert(first.precacheFiles.includes('assets/assets/bible/translations.json'));
  assert(first.precacheFiles.includes('assets/assets/content/devotional-en.json'));
  assert(!first.precacheFiles.includes('not-preloaded.txt'));
  assert.match(firstSource, /url\.origin !== self\.location\.origin/);
  assert.match(firstSource, /request\.mode === 'navigate'/);
  assert.match(firstSource, /const APP_SHELL_URL = self\.registration\.scope/);
  assert.match(firstSource, /cache\.match\(APP_SHELL_URL\)/);
  assert.doesNotMatch(firstSource, /new URL\('index\.html'/);
  assert.match(firstSource, /cache\.put\(request, response\.clone\(\)\)/);
  assert.match(firstSource, /self\.skipWaiting\(\)/);
  assert.match(firstSource, /self\.clients\.claim\(\)/);

  await writeFixture(buildDirectory, 'assets/assets/bible/asv.json', '{"books":[1]}');
  const changed = await generateServiceWorker(buildDirectory);
  assert.notEqual(changed.version, first.version);
});

test('requires the built index', async (context) => {
  const buildDirectory = await mkdtemp(join(tmpdir(), 'bible-path-sw-'));
  context.after(() => rm(buildDirectory, { recursive: true, force: true }));

  await assert.rejects(
    generateServiceWorker(buildDirectory),
    /Missing .*index\.html/,
  );
});
