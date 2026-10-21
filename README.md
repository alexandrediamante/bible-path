# Bible Path PWA

Bible Path is a personal, offline-first Bible companion built with Flutter Web. It is designed to be installed from Safari with **Add to Home Screen** and used on an iPhone.

This project is an independent clean-room implementation. It is not affiliated with or endorsed by the publisher of the commercial Android application with a similar name. It does not include that application's source code, private APIs, credentials, subscription logic, artwork, audio, or other proprietary assets.

## Current scope

- Installable Flutter Web PWA hosted under a GitHub Pages project path.
- Bible reading, search, favorites, copy, and share.
- Persistent daily plans, streaks, study progress, prayer journal, preferences, and chat history in Hive/IndexedDB.
- Seven UI locales: English, Spanish, Portuguese, French, German, Italian, and Russian.
- One redistribution-cleared Bible dataset per locale after the content provenance gate passes.
- Optional Bible AI through an authenticated Cloudflare Worker using the Workers AI free daily allocation.
- JSON export and destructive reset of local data.

Not included in the first release: accounts, cloud sync, public prayer/community features, Web Push, native macOS distribution, or prerecorded audio.

## Privacy and storage

Personal data is stored in the browser on the device. The AI access token is local and is excluded from exports. When the user sends a Bible AI message, the question, bounded recent chat history, locale, selected translation, and selected local Bible passages are processed by Cloudflare Workers AI.

Safari can evict website data. Installation to the Home Screen and a persistent-storage request improve durability but do not guarantee it. Export important entries regularly.

## Prerequisites

- Flutter `3.47.7` with web support.
- Node.js 22 or newer for service-worker and Worker tooling.
- A Cloudflare account with Workers AI enabled when using Bible AI.

## Local validation

```bash
flutter pub get
```

```bash
flutter gen-l10n
```

```bash
dart format --output=none --set-exit-if-changed lib test
```

```bash
flutter analyze
```

```bash
flutter test
```

```bash
flutter build web --release --base-href "/bible-path/" --dart-define="AI_API_URL=https://your-worker.example"
```

```bash
node tool/generate_service_worker.mjs build/web
```

```bash
node --test tool/generate_service_worker.test.mjs
```

The build output is `build/web`.

## Bible AI Worker

The Worker lives in `worker/` and calls Cloudflare Workers AI through an account binding. No external model API key is required or exposed to the browser.

```bash
npm ci --prefix worker
```

```bash
npm test --prefix worker
```

```bash
npm run typecheck --prefix worker
```

Before a deployment, configure the Worker secrets through Wrangler or the Cloudflare dashboard:

- `APP_AUTH_TOKEN` (a random value of at least 32 characters)

`ALLOWED_ORIGIN` must be the exact Pages origin. Never commit secret values or pass them through Flutter `--dart-define`.

## GitHub Pages

The Pages workflow is in `.github/workflows/deploy.yml`. It builds under the repository subpath, runs Flutter/content/Worker/service-worker checks, and uploads only `build/web`.

GitHub Actions must be enabled and the account billing lock must be resolved before the workflow can acquire a runner.

## Content and licensing

Bible texts, fonts, and icons are release-blocking dependencies. Their exact editions, source URLs, licenses/public-domain basis, attribution requirements, acquisition dates, and SHA-256 hashes belong in `THIRD_PARTY_CONTENT.md` and `assets/bible/translations.json`.

Do not publish assets with unknown provenance. Do not source Bible text, icons, translations, or audio from the Android APK.

## Clean-room policy

See [CLEAN_ROOM.md](CLEAN_ROOM.md). The local APK and decoded artifacts may be inspected only to understand observable behavior. Decompiled implementation, proprietary copy, assets, endpoints, credentials, payment behavior, and license checks are not copied into this project.
