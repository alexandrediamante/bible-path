# Bible Path WebApp - APK Parity Implementation Specification

## Context

The current Bible Path webapp (Flutter Web PWA) is a clean-room rebuild with basic Bible reading, daily plans, study, prayer, and AI chat features. However, the original Android APK (Bible Path 2.5.6, package `com.visionwizard.holybible`) has significantly more content and features that are missing from the webapp.

**Goal**: Achieve full feature parity with the APK by implementing all missing content types, Bible versions, and UI flows while maintaining clean-room principles (no proprietary code/assets copied).

## APK vs Webapp Feature Gap Analysis

### Bible Versions (Major Gap)
| APK | Webapp | Action |
|-----|--------|--------|
| 20+ versions: KJV, ESV, NIV, NLT, NKJV, AMP, NET, ASV, Bishops, Coverdale, Geneva, WEB, Schlachter 2000, RVR1909, RVR1960, NVI, BDS, etc. | 7 versions: WEB, RV1909, BLIVRE, LSG1910, LUT1912, DB1885, SYNODAL | Source additional public domain/CC-licensed translations |

### Content Types Missing in Webapp
| Content Type | APK Structure | Webapp Status | Priority |
|--------------|---------------|---------------|----------|
| **Advent** | 25 days with verse text, reference | ❌ Missing | HIGH |
| **Lent** | 40+ days with verse, prayer, audio duration (seconds, minutes) | ❌ Missing | HIGH |
| **Holy Calendar** | Catholic, Orthodox, Protestant liturgical calendars (date, event, description, type) | ❌ Missing | HIGH |
| **Devotionals** | Rich: title, verse, welcomeMessage, suggestions (array) | Basic 7-day only | HIGH |
| **Study** | 3-day challenges with actual verse text | Basic study only | MEDIUM |
| **Audio/Listen Plans** | With duration metadata (seconds, rounded_minutes) | ❌ Missing | MEDIUM |
| **Reading Plans** | Many more categories/themes | Basic only | MEDIUM |
| **Bible Version Selector** | Survey/question flow with icons | Basic dropdown only | HIGH |

### UI/UX Features Missing
- Bible version selection onboarding flow (survey-style)
- Seasonal content navigation (Advent/Lent/Holy Calendar sections)
- Audio player with duration tracking
- Rich devotional cards with suggestions
- Study challenges with progress tracking
- Holy calendar with denomination selector

## Technical Approach

### Data Architecture
All APK content follows a consistent JSON asset pattern:
- Localized JSON files in `assets/flutter_assets/assets/{content_type}/{locale}.json`
- Loaded via `rootBundle.loadString()` in repositories
- Cached in Hive/IndexedDB via StorageService
- Reactive via ChangeNotifier pattern

### Repository Pattern
Each content type needs:
1. **Data models** (e.g., `AdventDay`, `LentDay`, `HolyCalendarEvent`)
2. **Repository** (e.g., `AdventRepository`, `LentRepository`, `HolyCalendarRepository`)
3. **Screen/UI** (e.g., `AdventScreen`, `LentScreen`, `HolyCalendarScreen`)
4. **Localization keys** in all 7 `.arb` files
5. **Route** in `app.dart` router
6. **Navigation entry** in `AppScaffold` or `MoreScreen`

### Bible Version Expansion
1. Source additional translations from eBible.org or other public domain sources
2. Add to `assets/bible/translations.json` manifest
3. Add normalized JSON assets to `assets/bible/`
4. Update `tool/verify_content.mjs` to validate new translations
5. BibleRepository already supports dynamic version loading

### Localization
All 7 locales must be supported for new content:
- English (en), Spanish (es), Portuguese (pt), French (fr), German (de), Italian (it), Russian (ru)
- Add keys to all 7 `.arb` files
- Run `flutter gen-l10n` to regenerate localizations

## Task Breakdown

### Phase 1: Core Bible Content Expansion (Week 1-2)
**T1.1** Source and add 10+ additional Bible translations
- Research public domain/CC-licensed translations matching APK versions
- Download, normalize, and add to `assets/bible/`
- Update `translations.json` manifest
- Run `tool/verify_content.mjs` validation

**T1.2** Enhance Bible Version Selector UI
- Replace simple dropdown with rich selector (like APK survey flow)
- Add version icons, descriptions, license info
- Group by language/tradition

**T1.3** Add Bible version onboarding flow
- First-launch survey to select preferred version
- Store preference in StorageService

### Phase 2: Seasonal Content - Advent (Week 2)
**T2.1** Create Advent data models and repository
- `AdventDay` model (day, reference, text)
- `AdventRepository` loading from `assets/advent/{locale}.json`
- Integration with StorageService for progress tracking

**T2.2** Build Advent screen and navigation
- `AdventScreen` with 25-day list
- Day detail view with verse text
- Progress tracking (completed days)
- Add to router: `/advent`

**T2.3** Add Advent localization keys (7 locales)
- Update all 7 `.arb` files
- Run `flutter gen-l10n`

### Phase 3: Seasonal Content - Lent (Week 3)
**T3.1** Create Lent data models and repository
- `LentDay` model (id, title, description, dailyVerse, dailyVerseQuote, dailyPrayer, seconds, roundedMinutes)
- `LentRepository` with audio duration metadata
- Progress tracking with streak integration

**T3.2** Build Lent screen with audio duration display
- `LentScreen` with 40+ day list
- Day detail with verse, prayer, audio duration
- Audio player placeholder (future: actual audio)
- Add to router: `/lent`

**T3.3** Add Lent localization keys (7 locales)

### Phase 4: Holy Calendar (Week 3-4)
**T4.1** Create Holy Calendar data models and repository
- `HolyCalendarEvent` model (date, event, description, type)
- `HolyCalendarRepository` loading Catholic/Orthodox/Protestant
- Denomination selector in UI

**T4.2** Build Holy Calendar screen
- `HolyCalendarScreen` with date-organized list
- Denomination filter (Catholic/Orthodox/Protestant)
- Today highlight, search by date
- Add to router: `/holy-calendar`

**T4.3** Add Holy Calendar localization keys (7 locales)

### Phase 5: Enhanced Devotionals (Week 4)
**T5.1** Extend Devotional model
- Add `welcomeMessage`, `suggestions` (List<String>) fields
- Update `DevotionalCollection` and `ContentRepository`

**T5.2** Build rich devotional UI
- Enhanced `DevotionalScreen` with verse card, welcome message, suggestions chips
- Maintain backward compatibility with existing 7-day format

### Phase 6: Enhanced Study (Week 4-5)
**T6.1** Extend Study models
- Add `StudyChallenge` type with actual verse text (not just references)
- `ChallengeLesson` with verse text, reflection, application

**T6.2** Build Study Challenges screen
- 3-day challenge cards with progress
- Verse text display with context
- Add to router: `/study/challenges`

### Phase 7: Audio/Listen Plans (Week 5)
**T7.1** Create Listen Plan models and repository
- `ListenPlan`, `ListenDay` with audio duration
- `ListenRepository` loading from `assets/json/listen/{locale}.json`

**T7.2** Build Listen screen with audio player UI
- Duration display, progress tracking
- Placeholder for actual audio playback
- Add to router: `/listen`

### Phase 8: Reading Plans Expansion (Week 5-6)
**T8.1** Add more reading plan categories
- Parse APK's `read/{locale}.json` structure
- Create plan categories: book-based, thematic, chronological

**T8.2** Enhanced Reading Plans UI
- Category filtering, progress visualization
- Integration with BibleRepository for verse text

### Phase 9: Integration & Polish (Week 6-7)
**T9.1** Navigation integration
- Add seasonal content to `MoreScreen` or new seasonal tab
- Update `AppScaffold` navigation
- Home screen seasonal content cards (Advent/Lent when in season)

**T9.2** Settings integration
- Add content preferences (seasonal content visibility, etc.)
- Bible version management improvements

**T9.3** Testing & verification
- Run all existing tests
- Test all 7 locales
- Verify PWA build works
- Run `tool/verify_content.mjs` for new Bible assets
- Run `tool/generate_service_worker.mjs` for new assets

## Critical Files to Modify

### New Files (per phase)
```
lib/features/advent/
  advent_repository.dart
  advent_screen.dart
  models/advent_day.dart

lib/features/lent/
  lent_repository.dart
  lent_screen.dart
  models/lent_day.dart

lib/features/holy_calendar/
  holy_calendar_repository.dart
  holy_calendar_screen.dart
  models/holy_calendar_event.dart

lib/features/listen/
  listen_repository.dart
  listen_screen.dart
  models/listen_plan.dart

lib/features/study/
  models/study_challenge.dart  (extend existing)
  challenges_screen.dart

assets/advent/{en,es,pt,fr,de,it,ru}.json
assets/lent/{en,es,pt,fr,de,it,ru}.json
assets/holy_calendar/catholic/{en,es,pt,fr,de,it,ru}.json
assets/holy_calendar/orthodox/{en,es,pt,fr,de,it,ru}.json
assets/holy_calendar/protestant/{en,es,pt,fr,de,it,ru}.json
assets/bible/{new_translations}.json
```

### Existing Files to Modify
```
lib/core/app.dart                    - Add new routes
lib/features/home/home_screen.dart   - Add seasonal content cards
lib/features/more/more_screen.dart   - Add navigation entries
lib/features/settings/settings_screen.dart - Enhanced version selector
lib/features/bible/bible_repository.dart     - Version loading (already supports)
lib/features/content/content_repository.dart - Extended devotional model
lib/features/study/study_repository.dart     - Extended catalog
lib/l10n/app_*.arb (7 files)         - All new localization keys
pubspec.yaml                         - New asset entries
tool/verify_content.mjs              - New translation validation
tool/generate_service_worker.mjs     - New asset entries
```

## Verification Strategy

### Automated Tests
1. `flutter test` - All existing tests pass
2. `flutter analyze` - No new issues
3. `dart format` - Code formatting correct
4. `tool/verify_content.mjs` - All Bible assets validated
5. `tool/generate_service_worker.mjs` - New assets precached
6. `npm test --prefix worker` - Worker tests pass
7. `node --test tool/*.test.mjs` - PWA tooling tests pass

### Manual Verification
1. **Bible versions**: Switch between all 20+ versions, verify text loads
2. **Advent**: Navigate 25 days, verify verse text displays, progress tracks
3. **Lent**: Navigate 40+ days, verify verse/prayer/audio duration displays
4. **Holy Calendar**: Switch denominations, verify events load for dates
5. **Devotionals**: Verify rich format (welcomeMessage, suggestions)
6. **Study Challenges**: Verify 3-day challenges with verse text
7. **Listen Plans**: Verify audio duration metadata displays
8. **Localization**: Test all 7 locales for new content
9. **PWA Build**: `flutter build web --release` succeeds
10. **Offline**: Service worker caches new assets

## Dependencies & Blockers

### External Dependencies
- **Bible translation sources**: Need to locate public domain/CC-licensed versions for KJV, ESV, NIV, NLT, NKJV, AMP, NET, ASV, Bishops, Coverdale, Geneva, Schlachter 2000, RVR1960, NVI, BDS
- **License verification**: Each translation must have verified license for redistribution

### Technical Blockers
- **Audio content**: APK has audio duration metadata but no actual audio files in assets. Webapp will need placeholder UI or external audio hosting.
- **Bible text for new versions**: Must source, normalize, and verify 10+ new translations (significant data work)
- **APK content licensing**: Devotional/advent/lent/holy_calendar content from APK may be proprietary. Must create original CC0 content matching structure.

### Clean-Room Compliance
- All new Bible content: Source from eBible.org or verified public domain, not from APK
- All devotional/advent/lent/holy_calendar text: Create original content (CC0) matching APK structure but not copying text
- UI patterns: Reimplement based on observed behavior, not decompiled code

## Estimated Timeline

| Phase | Tasks | Est. Duration |
|-------|-------|---------------|
| Phase 1: Bible Versions | T1.1-T1.3 | 2 weeks |
| Phase 2: Advent | T2.1-T2.3 | 1 week |
| Phase 3: Lent | T3.1-T3.3 | 1 week |
| Phase 4: Holy Calendar | T4.1-T4.3 | 1-2 weeks |
| Phase 5: Devotionals | T5.1-T5.2 | 1 week |
| Phase 6: Study | T6.1-T6.2 | 1-2 weeks |
| Phase 7: Listen | T7.1-T7.2 | 1 week |
| Phase 8: Reading Plans | T8.1-T8.2 | 1-2 weeks |
| Phase 9: Integration | T9.1-T9.3 | 1-2 weeks |
| **Total** | | **10-14 weeks** |

## Notes

1. **Parallelization**: Phases 2-4 (seasonal content) can be done in parallel by different developers
2. **MVP approach**: Could ship Bible version expansion first (Phase 1), then seasonal content incrementally
3. **Content creation**: The largest time sink is creating original devotional/advent/lent/holy_calendar content for 7 locales - consider using AI assistance for translations then human review
4. **Bible version sourcing**: Some APK versions (NIV, ESV, NLT, NKJV, AMP) are copyrighted - cannot include. Must use public domain alternatives or link to external sources
5. **Maintainability**: Each new content type follows existing repository/screen patterns for consistency