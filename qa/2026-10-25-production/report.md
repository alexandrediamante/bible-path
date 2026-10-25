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
| Fixed high | 5 |
| Physical-device confirmation | 1 |
| **Total findings** | **5** |

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
