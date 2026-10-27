<!-- Sync Impact Report: scaffold -> 1.0.0; five principles adopted; platform and verification sections added; no deferred governance items. -->
# BiblePath Constitution

## Core Principles

### I. Real playback and truthful state
The app MUST read the actual selected passage. Progress MUST follow playback events,
never simulated timers. Automated events do not prove physical speaker output.

### II. Independent implementation
APK inspection MUST serve behavioral comparison. Implementation MUST use our own
code and content with documented provenance, without copying credentials or services.

### III. Reproducible verification
Behavior changes MUST have focused regression coverage. Analysis, tests and release
build MUST be checked before delivery. Blocked checks MUST be recorded explicitly.

### IV. Device and language honesty
Voice choices MUST represent available engines and their actual languages. The app
MUST NOT label Spanish synthesis as Portuguese. Background playback MUST NOT be
promised without device evidence.

### V. Preserve data and authorization
Changes MUST preserve uncommitted work, preferences and app data. Secrets MUST stay
out of frontend bundles, repository and logs. Authorized work proceeds without
redundant approval; environment restrictions still apply.

## Platform Constraints
Flutter Web/PWA is the current target. Browser speech depends on installed voices
and may require connectivity. Online speech requires a supported backend and internet.
iPhone Safari requires a user playback gesture and physical validation.

## Development Workflow
Use the installed Spec Kit specification, plan, tasks and convergence flow. Record
behavior evidence, test commands and remaining gaps in the feature directory.
Publication must retain existing authentication and origin restrictions.

## Governance
Amendments require a reason, version increment and review against requirements.
MAJOR removes principles; MINOR adds requirements; PATCH clarifies wording.
Verify compliance at design and delivery.

**Version**: 1.0.0 | **Ratified**: 2026-10-26 | **Last Amended**: 2026-10-26
