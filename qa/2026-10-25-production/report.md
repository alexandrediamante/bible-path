# Dogfood Report: Bible Path

| Field | Value |
|---|---|
| Date | 2026-10-25 |
| App URL | https://bible-path.pages.dev/ |
| Session | bible-path-qa |
| Scope | Full user journey, mobile layout, scrolling, audio, content, AI, offline/update behavior |

## Summary

| Severity | Count |
|---|---:|
| Open critical/high | 0 |
| Fixed high | 7 |
| Physical-device confirmation | 1 |
| **Total findings** | **7** |

## Follow-up regression: Safari reports speech progress while output is silent

The user's second iPhone recording is 28.49 seconds at 1180x2556. It shows the
Bible player using both Luciana (pt-BR) and Joana (pt-PT), displaying Pause and
advancing through verses, but its decoded audio track has peak `0` and RMS `0`
across 364,544 inspected samples. This rules out merely low recording volume:
WebKit emits synthesis lifecycle events while its output route remains silent.

A browser repro injected Safari's `navigator.audioSession` boundary and drove
the actual Bible Play control. Before the repair it failed with no writes and
session type `auto`. `SpeechOutput` now primes `ambient`, switches to
`playback` synchronously within the Play gesture, then returns to `ambient`
after end, error or stop. Browsers without the Safari-specific API are
unchanged. The same assertion now passes with `ambient -> playback`.

This repairs the page-side condition documented by WebKit where media APIs can
report success while the iOS output session is silent. Audible output on the
user's physical iPhone remains the final acceptance check after deployment.

Fix commit `c901c18` is published at
`https://2b0a632f.bible-path.pages.dev` and the canonical domain. Flutter
analysis passes; the serial Flutter suite passes 43/43, Worker tests pass
44/44, and content/PWA tests pass 7/7. The production browser repeated the
`ambient -> playback` assertion without a page error. Local, immutable and
canonical hashes match (`main.dart.js`
`7b8c3acb966eeefbcc1e1ed9df27d869a2998b40fb798fe60671c666b6cd203d`;
service worker
`c03f843bf65be1590937ced9ec9c0dafbd79422bbeea24a299fee772a2282a52`).

## Follow-up regression: Bible AI intermittently reports a connection failure

The user supplied another iPhone screenshot after the earlier token-gate fix.
The chat accepted the question but displayed the generic connection error. A
fresh production browser session could obtain answers, but the original
2,048-token Worker contract produced long responses in roughly 28-34 seconds.
The active Worker secret inventory contained `APP_AUTH_TOKEN` only, so its
optional Groq fallback was not operational. The exact historical mobile request
had no correlation ID, so its provider-versus-4G failure cannot be recovered.

The Worker now caps both provider paths at 512 tokens and requests 120-220-word
answers by default. The client classifies timeouts and connection failures, and
the chat displays a localized Retry action. Repository coverage proves a retry
replaces the failed turn and does not duplicate the question. A forced local
network failure rendered Retry and clicking it emitted a new request.

Worker version `f4f2eff7-e1dc-40dc-a7cf-faec30a60ce6` passed three direct live
requests with HTTP 200 and nonempty text in 19.9 s, 16.2 s and 9.0 s. The
canonical production site then passed three consecutive Portuguese questions
in one fresh 390x844 session in 21.5 s, 19.6 s and 6.6 s. Every POST returned
200, every answer rendered nonempty, and console/page errors were empty.

The repaired frontend is live at `https://0f8d406a.bible-path.pages.dev` and
the canonical domain. Local, immutable and canonical hashes match
(`main.dart.js` `ff0f4a05530ee67598244d380dbd1d356b0835e043d06c8bbccddb692f662975`;
service worker `24174f89da8dea7aa74802083af23a20796b8e0d15c7fccfc01775a71ab80315`).
No new credential, provider or billing configuration was introduced.

## Follow-up regression: onboarding loses its visible page

The full production onboarding was exercised with `agent-browser` at mobile
and desktop sizes. Advancing from language/style to denomination changed the
logical index to 2, removed the conditional header and footer, and moved the
unkeyed `PageView` within its `Column`. Flutter remounted it at visual page 0,
leaving the Welcome content on screen while index 2 hid every action.

The surrounding slots now remain stable through `Offstage`, preserving the
same `PageView` element without reserving space or exposing hidden controls.
A 390x844 widget regression completes Portuguese + Contemporary + Protestant,
reaches Home, and verifies persisted locale, style, denomination and Bible.
The local release completed the same browser flow and remained at `#/home`
after reload. No IndexedDB reset is involved.

The corrected release was published at
`https://207ea518.bible-path.pages.dev` and promoted on the canonical domain.
The local, immutable and canonical hashes match (`main.dart.js`
`b5cac997b7100fc7df229fec86f4fab9f7f87abca303b257dada70f8079f36a2`;
service worker
`13b1ab6da3b0131e1e18ccc3d4048994cb7457b803faf0f4bb354ea36655a8a8`).
Production `agent-browser` completed Portuguese + Contemporary + Protestant,
reached the Portuguese Home, and remained at `#/home` after reload.

## Follow-up regression: Safari closes IndexedDB during startup

The user later supplied a production screenshot showing
`InvalidStateError: Failed to execute 'transaction' on 'IDBDatabase': The
database connection is closing.` A browser init script reproduced that exact
fatal screen against the deployed bundle by closing the Hive database before
its first transaction.

`StorageService` now recovers only from this transient error: it closes a stale
box when present, waits briefly, and retries up to two times without deleting
the database. The same injection now reaches onboarding on a fresh profile and
reaches `#/home` after reloading a profile with completed-onboarding data.
Focused Dart tests cover successful retry and rejection of unrelated errors.

Evidence: `screenshots/indexeddb-closing-before.png`,
`screenshots/indexeddb-closing-after.png`,
`screenshots/indexeddb-existing-data-before-reload.png`, and
`screenshots/indexeddb-existing-data-after-reload.png`.

The validated release was published to the existing Pages project at
`https://9709db8c.bible-path.pages.dev` and promoted at the canonical
`https://bible-path.pages.dev/`. Both deployed bundle hashes match the local
build (`main.dart.js` SHA-256
`e7fa8e3c9d188065bba318b3d55ee21c9cff00c58c4d1373aa9b6113abe488de`;
service worker SHA-256
`236f2b8e8217e615c0848388fb084a603dd61022d51727073000ab68ca9ed7a2`).
The same fault injection against the canonical production URL reached
onboarding without a startup error; see `screenshots/indexeddb-production-after.png`.

## Environment

The baseline was recorded before code changes. The fixed release was tested in
an isolated Chromium profile at 375×667 and 375×450 against the production
domain. A native iOS simulator could not run on this Windows host; audible
Safari output therefore still needs one confirmation on the user's iPhone.

## Issues

### ISSUE-001: Listen detail cannot scroll on a compact iPhone viewport

| Field | Value |
|---|---|
| Severity | High |
| Category | Functional / responsive layout |
| URL | `https://bible-path.pages.dev/#/listen` |
| Evidence | `screenshots/issue-listen-modal-pt-375x550.png`, `screenshots/issue-listen-modal-pt-after-scroll.png` |

At 375×550 in Portuguese, the detail sheet consumes the available height. Its body is a non-scrollable column. A 500-pixel downward scroll produces an identical screenshot, so content that falls outside the viewport cannot be reached. The user supplied the same symptom from iPhone Safari.

**Reproduction**

1. Complete onboarding, switch the language to Portuguese and start the listening plan.
2. Set the viewport to 375×550 and open “Meus Planos” → “Dia 1”.
3. Attempt to scroll downward by 500 pixels.
4. Observe that the sheet does not move and its layout remains pinned against the bottom navigation.

**Resolution:** Fixed. Listen, Study and Lent detail sheets now have a real
scroll container. A compact widget regression test passes, and production
`scrollIntoView` exposed the previously clipped action at 375×450. Evidence:
`screenshots/fixed-production-listen-compact-before.png` and
`screenshots/fixed-production-listen-compact-after.png`.

### ISSUE-002: Holy Calendar requests missing JSON and renders a parser exception

| Field | Value |
|---|---|
| Severity | High |
| Category | Functional / content / network |
| URL | `https://bible-path.pages.dev/#/holy-calendar` |
| Evidence | `screenshots/issue-calendar-json.png` |

The route requests `assets/assets/json/holy_calendar/holy_calendar_catholic_en.json`. No calendar files are shipped, and the directory is not declared in the Flutter asset manifest. Cloudflare serves the SPA HTML fallback, so the JSON parser receives `<` and the UI exposes a `FormatException` to the user.

**Resolution:** Fixed. The route generates an original, offline landmark
calendar for Catholic, Orthodox and Protestant selections in all seven app
languages, with year-specific cache keys. It no longer requests a missing
asset. Production showed the localized November 2026 celebrations and the
network log contained no `holy_calendar` request. Evidence:
`screenshots/fixed-production-calendar-events.png`.

### ISSUE-003: Bible AI is unusable for an ordinary production user

| Field | Value |
|---|---|
| Severity | High |
| Category | Functional / UX / authentication |
| URL | `https://bible-path.pages.dev/#/chat` |
| Evidence | `screenshots/issue-ai-token.png` |

Sending a suggested question produces “Enter your personal AI access token in Settings.” No request reaches `/v1/chat`. The deployed Worker has server-side authentication, but the public frontend requires the user to supply the bearer secret, blocking the advertised feature.

**Resolution:** Fixed. The frontend no longer asks ordinary users for a server
secret. Production sent the request without an Authorization header, completed
the CORS preflight with 204, received 200 from `/v1/chat`, and rendered the
answer. A different Origin was rejected with 403 and invalid supplied bearer
credentials still return 401. Evidence:
`screenshots/fixed-production-ai-response.png`.

### ISSUE-004: iPhone shows playback state while the captured audio is silent

| Field | Value |
|---|---|
| Severity | High |
| Category | Functional / audio / state feedback |
| URL | `https://bible-path.pages.dev/#/listen` |
| Evidence | User-supplied 19.7-second iPhone screen recording and screenshots |

The supplied MP4 contains an AAC audio track at 44.1 kHz, but all 850 samples are the same six-byte silent frame (about 2.07 kbps). The current UI sets its internal playing state before the browser emits `onStart`, so it can display Pause even if Safari never starts audible synthesis. Chromium reports `speechSynthesis.speaking=true`; the defect is specific to the iOS/Safari path or its voice lifecycle.

**Resolution:** Fixed in code; physical iPhone confirmation remains. The player
retains the active utterance, avoids an unconditional cancel immediately before
speak, divides long text into Safari-safe chunks, waits for the browser's real
`onStart` event before displaying Pause, and surfaces a timeout instead of
claiming playback. Production Chromium reported `speaking=true`, two pt-BR
voices, and the UI changed to “Pausar” only after start. Evidence:
`screenshots/fixed-production-audio-started.png`.

## Final production verification

| Check | Result |
|---|---|
| Flutter static analysis | Pass, no issues |
| Flutter tests | Pass, 38/38 |
| Worker tests | Pass, 44/44 |
| Worker TypeScript check | Pass |
| Node content/PWA tests | Pass, 7/7 |
| Release web build | Pass |
| Worker public same-origin smoke | 200 with nonempty answer |
| Worker foreign-origin smoke | 403 |
| Main production URL | 200, no redirect |
| Fresh profile launch | Pass |
| Existing-worker update path | Pass; new worker waits instead of replacing assets mid-session |
| Offline reload after installation | Pass on `#/listen` |
| Production routes | Home, Bible, AI, Daily, Listen, Advent, Reading, Prayer, Study, Lent, Calendar, Profile, Settings passed |
| Browser errors after final flows | None |

The accessibility command found no violations but also reported zero applicable
rules for Flutter's canvas/semantics rendering, so that automated result is
inconclusive rather than a WCAG certification. The vitals collector returned a
3.3 ms local TTFB but no paint metrics for the Flutter canvas; it is likewise
not used as a performance sign-off.
