import { createHash } from 'node:crypto';
import { readdir, readFile, writeFile } from 'node:fs/promises';
import { extname, join, posix, resolve } from 'node:path';
import { pathToFileURL } from 'node:url';

const SERVICE_WORKER_FILE = 'flutter_service_worker.js';
const SHELL_FILES = new Set([
  'flutter.js',
  'flutter_bootstrap.js',
  'index.html',
  'main.dart.js',
  'manifest.json',
  'version.json',
  'assets/AssetManifest.bin',
  'assets/AssetManifest.bin.json',
  'assets/AssetManifest.json',
  'assets/FontManifest.json',
]);
const ICON_FILES = new Set([
  'icons/pwa/icon-32.png',
  'icons/pwa/icon-180.png',
  'icons/pwa/icon-192.png',
  'icons/pwa/icon-512.png',
]);
const FONT_EXTENSIONS = new Set(['.otf', '.ttf', '.woff', '.woff2']);

function compareNames(left, right) {
  return left < right ? -1 : left > right ? 1 : 0;
}

async function listFiles(directory, relativeDirectory = '') {
  const entries = await readdir(directory, { withFileTypes: true });
  entries.sort((left, right) => compareNames(left.name, right.name));

  const files = [];
  for (const entry of entries) {
    const relativePath = relativeDirectory
      ? posix.join(relativeDirectory, entry.name)
      : entry.name;
    const absolutePath = join(directory, entry.name);

    if (entry.isDirectory()) {
      files.push(...await listFiles(absolutePath, relativePath));
    } else if (entry.isFile() && relativePath !== SERVICE_WORKER_FILE) {
      files.push(relativePath);
    }
  }
  return files;
}

function shouldPrecache(relativePath) {
  return SHELL_FILES.has(relativePath)
    || ICON_FILES.has(relativePath)
    || relativePath === 'assets/assets/bible/translations.json'
    || relativePath.startsWith('assets/assets/content/')
    || FONT_EXTENSIONS.has(extname(relativePath).toLowerCase());
}

async function hashBuild(buildDirectory, files) {
  const hash = createHash('sha256');
  for (const relativePath of files) {
    const contents = await readFile(join(buildDirectory, ...relativePath.split('/')));
    hash.update(`${Buffer.byteLength(relativePath)}:${relativePath}\0`);
    hash.update(`${contents.length}:`);
    hash.update(contents);
    hash.update('\0');
  }
  return hash.digest('hex');
}

function renderServiceWorker(version, precacheFiles) {
  return `const VERSION = ${JSON.stringify(version)};
const CACHE_PREFIX = 'bible-path-';
const PRECACHE_CACHE = \`\${CACHE_PREFIX}precache-\${VERSION}\`;
const RUNTIME_CACHE = \`\${CACHE_PREFIX}runtime-\${VERSION}\`;
const PRECACHE_URLS = ${JSON.stringify(precacheFiles, null, 2)};
const INDEX_URL = new URL('index.html', self.registration.scope).toString();

self.addEventListener('install', (event) => {
  event.waitUntil((async () => {
    const cache = await caches.open(PRECACHE_CACHE);
    const urls = PRECACHE_URLS.map((path) =>
      new URL(path, self.registration.scope).toString(),
    );
    await cache.addAll(urls);
    await self.skipWaiting();
  })());
});

self.addEventListener('activate', (event) => {
  event.waitUntil((async () => {
    const currentCaches = new Set([PRECACHE_CACHE, RUNTIME_CACHE]);
    const cacheNames = await caches.keys();
    await Promise.all(cacheNames.map((cacheName) => {
      if (cacheName.startsWith(CACHE_PREFIX) && !currentCaches.has(cacheName)) {
        return caches.delete(cacheName);
      }
      return undefined;
    }));
    await self.clients.claim();
  })());
});

function isOfflineContent(url) {
  return url.pathname.includes('/assets/assets/bible/')
    || url.pathname.includes('/assets/bible/')
    || url.pathname.includes('/assets/assets/content/')
    || url.pathname.includes('/assets/content/');
}

async function serveOfflineContent(request) {
  const precache = await caches.open(PRECACHE_CACHE);
  const preloaded = await precache.match(request, { ignoreSearch: true });
  if (preloaded) {
    return preloaded;
  }

  const cache = await caches.open(RUNTIME_CACHE);
  const cached = await cache.match(request);
  if (cached) {
    return cached;
  }

  const response = await fetch(request);
  if (response.ok && response.type === 'basic') {
    await cache.put(request, response.clone());
  }
  return response;
}

async function serveNavigation(request) {
  const cache = await caches.open(PRECACHE_CACHE);
  return await cache.match(INDEX_URL) || fetch(request);
}

self.addEventListener('fetch', (event) => {
  const { request } = event;
  if (request.method !== 'GET') {
    return;
  }

  const url = new URL(request.url);
  if (url.origin !== self.location.origin) {
    return;
  }

  if (request.mode === 'navigate') {
    event.respondWith(serveNavigation(request));
    return;
  }

  if (isOfflineContent(url)) {
    event.respondWith(serveOfflineContent(request));
    return;
  }

  event.respondWith((async () => {
    const cache = await caches.open(PRECACHE_CACHE);
    return await cache.match(request, { ignoreSearch: true }) || fetch(request);
  })());
});
`;
}

export async function generateServiceWorker(buildDirectory = resolve('build/web')) {
  const root = resolve(buildDirectory);
  const files = await listFiles(root);
  if (!files.includes('index.html')) {
    throw new Error(`Missing ${join(root, 'index.html')}`);
  }

  const version = await hashBuild(root, files);
  const precacheFiles = files.filter(shouldPrecache);
  const outputPath = join(root, SERVICE_WORKER_FILE);
  await writeFile(outputPath, renderServiceWorker(version, precacheFiles), 'utf8');
  return { outputPath, precacheFiles, version };
}

const isDirectInvocation = process.argv[1]
  && pathToFileURL(resolve(process.argv[1])).href === import.meta.url;

if (isDirectInvocation) {
  try {
    const result = await generateServiceWorker(process.argv[2]);
    console.log(
      `Generated ${result.outputPath} with ${result.precacheFiles.length} precached files.`,
    );
  } catch (error) {
    console.error(error instanceof Error ? error.message : error);
    process.exitCode = 1;
  }
}
