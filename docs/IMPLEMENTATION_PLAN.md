# Bible Path - Master Implementation Plan

Updated: 2026-10-23
Branch: rebuild/iphone-pwa
Repository: alexandrediamante/bible-path

## Goal

Deliver the closest legally and technically feasible clean-room implementation of Bible Path 2.5.6 as an installable Flutter Web PWA, while keeping a separate native-app track for operating-system features that a PWA cannot provide.

"Parity" means matching observable user journeys and useful behavior. It does not mean copying decompiled code, proprietary artwork/text/audio, credentials, private APIs, paywall logic, or restricted Bible translations.

## Platform reality

The PWA can cover Bible reading, search, favorites, sharing, daily content, streaks, plans, prayer journal, Bible AI, localization, offline storage and responsive UI.

The following require a native iOS/Android companion or must be adapted:

- home-screen and lock-screen widgets;
- Prayer Lock / blocking other applications;
- reliable background reminders and push behavior;
- native camera/gallery flows;
- live activities;
- unrestricted background audio;
- OS account/subscription integration.

## Sources of truth

1. Current code and tests in this branch.
2. GitHub issues #2 through #24.
3. Observable APK behavior and decoded asset inventory, used only as a behavioral reference.
4. CLEAN_ROOM.md and THIRD_PARTY_CONTENT.md.
5. docs/APK_FEATURE_MATRIX.md.
6. HANDOFF.md for the latest resumable state.

## Verified baseline

| Check | Result |
|---|---|
| Dart analysis of lib/ and test/ | PASS - No issues found |
| Content verification | PASS - 7 complete selectable Bibles + 7 devotional locales; sample datasets excluded |
| Worker tests | PASS - 23/23 |
| Flutter tests | PASS - 28 tests on normal Windows host via Desktop Commander |
| APK execution | BLOCKED: emulator images/AVDs are installed, but Intel VT-x is disabled in BIOS/UEFI; enable it and reuse `BiblePath_API36` |
| Full web build | PASS - release build and generated service worker (45 precached resources); deployment/device QA not complete |

## Phase 0 - Stabilize the repository

- [x] Exclude the local Flutter SDK from analysis.
- [x] Ignore local Flutter SDK/archive and generated plugin file.
- [x] Fix current Holy Calendar and Listen compilation errors.
- [ ] Decide whether to move the 1.1 GB flutter_windows.zip and local flutter/ SDK outside the repository.
- [ ] Remove malformed accidental directories after explicit review.
- [ ] Run format, targeted analysis, tests, content checks and production build in CI.
- [ ] Reconcile dirty working tree into small reviewed commits.
- [ ] Never commit worker/.dev.vars.local or other secrets.

Exit: clean reproducible build from a fresh checkout.

## Phase 1 - APK behavioral audit and visual specification

- [x] Inventory decoded feature assets and English localization keys.
- [x] Identify major navigation/content families.
- [ ] Enable Intel VT-x in BIOS/UEFI, boot `BiblePath_API36`, and install the APK (all SDK/emulator downloads and AVD creation are complete).
- [ ] Capture every first-run screen, main tab, modal and settings flow.
- [ ] Record screen dimensions, spacing, typography, colors, navigation and empty/error/loading states.
- [ ] Create an original design system inspired by the behavior, without reusing APK artwork.
- [ ] Update docs/APK_FEATURE_MATRIX.md after each observed flow.

Exit: every observable APK flow is marked Implemented, Adapted, Native-only, Not observed, or Out of scope.

## Phase 2 - Core shell and visual parity

- [ ] Complete onboarding survey: language, goal, denomination, style, reminder and Bible version.
- [ ] Rebuild Home around Today, Discover, Ask About and seasonal sections.
- [ ] Match mobile navigation and back behavior at 375x812 and 390x844.
- [ ] Add reusable cards, sheets, dialogs, skeletons, error states and empty states.
- [ ] Complete theme, typography and seven-locale layout QA.
- [ ] Add golden/screenshot tests where feasible.

Exit: first launch and main navigation feel coherent and consistent with the observed APK.

## Phase 3 - Daily spiritual journey

- [ ] Implement Today's Verse with favorite, copy, share and AI actions.
- [ ] Complete daily Devotional, Prayer and Connection tasks.
- [ ] Persist per-day completion, current streak and longest streak.
- [ ] Add journey progress, milestone celebrations and achievements.
- [ ] Add in-app reminders honestly; never promise closed-PWA delivery.
- [ ] Implement local history and resume behavior.

Exit: the complete daily loop works offline and survives restart.

## Phase 4 - Bible reader

- [ ] Replace every placeholder Bible dataset with complete, redistribution-cleared text.
- [ ] Validate provenance, license, hashes, book/chapter/verse counts.
- [ ] Finish translation selector and first-run recommendation.
- [ ] Add book/chapter picker, search, favorites and recent reading.
- [ ] Add long-press actions: ask, copy, favorite, share.
- [ ] Add font, size, theme and reading preferences.
- [ ] Add Web Speech synthesis as the PWA audio fallback, with clear browser limitations.
- [ ] Add share-card customization using original visual assets.

Exit: complete Bible reading flow in all seven locales, offline for the selected translation.

## Phase 5 - Bible AI

- [x] Worker authentication, CORS, request limits and rate limiting.
- [x] Worker unit tests.
- [ ] Complete chat history, rename, delete, retry and share flows.
- [ ] Add home personas/topics using original content.
- [ ] Add verse-context actions and bounded local retrieval.
- [ ] Add privacy/offline/error states.
- [ ] Confirm Cloudflare deployment and production URL.
- [ ] Add model/provider fallback strategy without exposing secrets.

Exit: all AI entry points use one secure, tested flow.

## Phase 6 - Plans and seasonal content

- [ ] Reading plans: categories, details, progress and verse integration.
- [ ] Study challenges: real lessons, reflection, application and progress.
- [ ] Listen plans: actual legal audio or Web Speech; remove fake player behavior.
- [ ] Watch plans: original or licensed media; otherwise adapt to text/story format.
- [ ] Advent: 25 complete localized days and progress.
- [ ] Lent: complete localized journey and progress.
- [ ] Holy Calendar: screen, Provider, route, tradition/month filters and details are implemented; clean-room data for three traditions and seven locales remains.
- [ ] Home seasonal cards and settings visibility toggle.

Exit: issues #5-#23 are verified against acceptance criteria, not merely matched by filenames.

## Phase 7 - Prayer, profile and personal data

- [ ] Personal prayer journal: create, edit, archive, delete, categories and history.
- [ ] Decide whether a public Prayer Wall is wanted; it requires backend, authentication, moderation and reporting.
- [ ] Derive profile statistics and achievements from real local data.
- [ ] Export/import versioned JSON and destructive reset.
- [ ] Storage persistence request, backup warning and recovery UX.
- [ ] Optional account/cloud sync only as a separately designed backend phase.

Exit: no fake community users, counts, account or cloud-sync claims.

## Phase 8 - Native companion track

- [ ] Decide targets: iOS, Android, or both.
- [ ] Create native Flutter targets from the shared domain/repository layer.
- [ ] Notifications, widgets, lock-screen features, live activities and background audio.
- [ ] Prayer Lock only where the operating system and store policy permit it.
- [ ] Camera/gallery/profile image permissions.
- [ ] Store privacy, signing, review and release preparation.

Exit: native-only gaps have a real implementation or are explicitly rejected.

## Phase 9 - Release quality

- [ ] All analyzers/tests/content checks/builds pass in CI.
- [ ] PWA install, update and offline behavior verified on a real iPhone.
- [ ] Accessibility: 44 px targets, semantics, contrast, text scale and keyboard navigation.
- [ ] Performance budgets and large Bible asset loading.
- [ ] Security review for worker token, logs, CORS and abuse controls.
- [ ] Legal review of every shipped Bible/content/audio/image/font.
- [ ] Close or rewrite GitHub issues to match verified state.
- [ ] Update README, HANDOFF and release notes.

## GitHub issue reconciliation

- #2 translations: partial; several added files are placeholders with only 1,189 verses.
- #3 selector: implemented locally; needs UX verification.
- #4 onboarding: implemented locally; needs compilation/flow tests.
- #5-#7 Advent: code/assets exist; needs completeness and flow verification.
- #8-#10 Lent: code/assets exist; audio remains a placeholder.
- #11-#13 Holy Calendar: models/repository partial; screen/route/content integration incomplete.
- #14-#15 Devotional: needs model/UI comparison and original localized content review.
- #16-#17 Study: partial; verify real lessons and verse text.
- #18-#19 Listen: partial; fake audio player must be replaced.
- #20-#21 Reading plans: partial; verify categories, details and Bible integration.
- #22 navigation: partial.
- #23 settings: partial.
- #24 testing: not complete; Flutter tests and production build still pending.

## Definition of done for every ticket

1. Requirement mapped to an observed behavior or explicit product decision.
2. Clean-room and licensing review completed.
3. Implementation uses persistent real data, not fake counters or dead buttons.
4. All seven locales accounted for.
5. Phone layout verified at 375x812 and 390x844.
6. Analyzer, relevant tests, content verification and build pass.
7. GitHub issue and HANDOFF.md updated with evidence.
8. No commit/push/issue closure unless authorized by Alê.