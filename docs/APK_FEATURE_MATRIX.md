# APK Feature Matrix

Updated: 2026-10-23

This inventory is based on decoded asset names, localization keys and current project code. It is not yet a substitute for operating the APK screen by screen. The audit environment is fully installed, but execution is blocked until Intel VT-x is enabled in BIOS/UEFI; see `HANDOFF.md`.

| Area | APK evidence | Current webapp | Next action |
|---|---|---|---|
| Onboarding/survey | onboarding images, survey_v2, goal/denomination/reminder strings | Locale/Bible selection, style/denomination persistence and Skip-to-Home regression test pass | Remaining survey fields and exact flow require native audit |
| Home | Today, Discover, Ask About, special events | Basic Home exists | Rebuild section order and card behavior |
| Daily plan | verse, devotional, prayer, connection, streak | Daily plan exists | Complete all four tasks and journey progress |
| Bible | reader, translations, long-press actions, favorites, audio controls | Reader/search/favorites plus selectable device voices, sequential verse speech, highlight/autoscroll and optional next chapter; regression tests pass | Validate audible/background behavior on devices; complete other preferences/actions |
| Bible AI | chat, history, personas, suggested questions | Secure Cloudflare AI Worker; same-origin hosting configuration and automatic endpoint resolution tested; not deployed/live-verified | Publish only after rights review/authorization and verify a real response; finish personas/history/share/retry flows |
| Reading plans | read JSON and challenge tags | 11 local plans load in seven locales; progress/undo/restoration tests pass | Complete passage navigation and audit schedules/content provenance |
| Study | study JSON, 3/7-day challenges | Original seven-day CC0 lessons; stable persistent progress and locale regression tests pass | Expand independently authored catalog; verify against native flows |
| Listen | listen JSON, player, sleep timer, ambient sound | Seven-day catalog, persistent progress and browser-generated speech controls tested | Validate audible speech on real devices; sleep timer/ambient recordings not implemented |
| Watch | watch JSON and video controls | Missing | Design licensed/original media adaptation |
| Prayer | daily prayer, personal actions | Personal journal exists | Complete create/edit/archive/delete/history |
| Prayer Wall | community, amen, report, profile names | Deliberately local-only | Requires backend/auth/moderation decision |
| Advent | 25-day assets and seasonal home content | Code/assets exist | Verify 25 complete localized days |
| Lent | journey, verse/pray/listen, badges | Existing 88-entry assets parse in seven locales; progress and speech adaptation implemented | Review source rights, denomination/date behavior and badges |
| Holy Calendar | Catholic/Orthodox/Protestant assets | Screen, route, tradition/month filters and details exist | Missing independent localized calendar datasets still block real use |
| Achievements | streak, reading, prayer and Lent badges | Missing/partial | Derive achievements from persisted activity |
| Profile/settings | profile, appearance, fonts, language, reminders | Partial | Add real statistics and remove dead/fake actions |
| Notifications | reminder and permission strings | In-app reminder only | Native companion needed for reliable background behavior |
| Widgets | daily/hourly verse, Lent, calendar, countdown | Not possible as ordinary PWA | Native companion track |
| Prayer Lock/screen time | app blocking and break flows | Not possible as ordinary PWA | Native companion track and policy review |
| Account/subscription | sign-in, restore, paywall | Excluded | Keep personal app account-free unless cloud sync is designed |
| Sharing | text/image/social share assets | Basic share partial | Add original share-card generator and Web Share fallback |
| Offline/update/error | no connection, maintenance, force update | PWA shell partial | Complete offline/update/error UX |

## Features visible in APK localization but not represented by current GitHub issues

- Daily Connection and candle/progress journey.
- Today's Verse customization and share cards.
- Achievements and milestone badges.
- Watch/video stories.
- Chat rename/delete/history/personas.
- Ambient music, playback speed and sleep timer.
- Hourly verse, widgets, live activity and lock screen.
- Rating/review flows.
- FAQ/support screens.
- Full notification preferences.
- Account/profile photo flows.
- Prayer Wall moderation/reporting.
- Screen-time Prayer Lock.

These gaps must become explicit tickets after visual verification.