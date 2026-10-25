import assert from 'node:assert/strict';
import { readFile } from 'node:fs/promises';
import { join, resolve } from 'node:path';
import test from 'node:test';

const root = resolve(import.meta.dirname, '..');

async function pngSize(path) {
  const bytes = await readFile(path);
  assert.equal(bytes.subarray(1, 4).toString('ascii'), 'PNG');
  return {
    width: bytes.readUInt32BE(16),
    height: bytes.readUInt32BE(20),
  };
}

test('manifest uses relative scope and real maskable icons', async () => {
  const manifest = JSON.parse(
    await readFile(join(root, 'web', 'manifest.json'), 'utf8'),
  );

  assert.equal(manifest.id, './');
  assert.equal(manifest.start_url, './');
  assert.equal(manifest.scope, './');
  assert.equal(manifest.display, 'standalone');

  for (const icon of manifest.icons) {
    const expected = Number(icon.sizes.split('x')[0]);
    const dimensions = await pngSize(join(root, 'web', icon.src));
    assert.deepEqual(dimensions, { width: expected, height: expected });
    assert.match(icon.purpose, /maskable/);
  }
});

test('web shell uses the Flutter base token and original iOS icon', async () => {
  const index = await readFile(join(root, 'web', 'index.html'), 'utf8');
  const bootstrap = await readFile(
    join(root, 'web', 'flutter_bootstrap.js'),
    'utf8',
  );

  assert.match(index, /<base href="\$FLUTTER_BASE_HREF">/);
  assert.match(index, /viewport-fit=cover/);
  assert.match(index, /icons\/pwa\/icon-180\.png/);
  assert.doesNotMatch(index, /serviceWorkerVersion|loadEntrypoint|canvaskit\//i);
  assert.match(bootstrap, /\{\{flutter_js\}\}/);
  assert.doesNotMatch(bootstrap, /serviceWorker\.ready|controllerchange/);
  assert.match(bootstrap, /_flutter\.loader\.load\(\)/);
  assert.ok(
    bootstrap.lastIndexOf('_flutter.loader.load()') <
      bootstrap.lastIndexOf('registerOfflineSupport()'),
  );
});
