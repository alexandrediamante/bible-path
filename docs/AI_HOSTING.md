# AI hosting and Bible speech

Updated: 2026-10-23. Implementation is independent of the reference APK.

## What the APK evidence establishes

Decoded asset names/localization expose Bible player preferences, playback speed and previous/next controls. AI strings expose conversation history, rename/delete, suggested questions and token/daily/lifetime limit states. Static UI evidence does not establish the AI provider, an embedded credential, provider billing, or a monthly free quota. Android runtime validation remains blocked by firmware virtualization.

## Implemented speech

The Bible reader uses browser SpeechSynthesis, one verse at a time. Actual utterance completion advances the verse; the reader highlights and scrolls to it. Users can choose installed/browser voices, change speed, pause/resume/stop and optionally continue into the next chapter. Manual navigation stops playback. Voice choice persists locally. This is generated speech, not the APK's recorded audio. Offline voices, audio quality and background playback vary by device.

## AI without a build-time AI_API_URL

AI_API_URL identifies our backend, not an AI provider credential. With no explicit value, HTTP(S) builds use their own origin. This works only when that origin actually hosts /v1/chat. The local Python static preview does not.

The Worker now uses Cloudflare Workers AI as primary and Groq GPT-OSS 120B as fallback when GROQ_API_KEY is configured server-side. See GROQ_SETUP.md. Without that secret it remains Cloudflare-only. The separate bible-path-chat API was deployed on 2026-10-23; optional all-in-one frontend hosting remains separate. It retains bearer authentication, origin validation and request limits. No APK private service or credential is used.

Optional all-in-one setup (not deployed):
1. Build Flutter web with --base-href "/" and regenerate the custom service worker.
2. Use worker/wrangler.fullstack.toml to serve assets and API at the same origin.
3. Configure APP_AUTH_TOKEN through the provider's secret mechanism; never commit or print it. The client's existing session-token flow still applies.
4. Complete content-rights review before public release, then separately authorize publishing.
5. Verify a real model response on the deployed origin. Mock tests and deployment dry-runs are not this verification.

The current localhost preview build uses /bible-path/; rebuild at root before using the fullstack configuration. Existing separate frontend/backend deployments may continue passing AI_API_URL explicitly.

## Free allowance is provider-specific

Cloudflare currently documents 10,000 Neurons/day, resetting at 00:00 UTC, not a fixed monthly message allowance. Cost depends on model/token usage; free plans stop after the allowance. Check current pricing before publication: https://developers.cloudflare.com/workers-ai/platform/pricing/

## Verified

32 Flutter tests; 26 Worker tests; TypeScript check; 7 Node/content/PWA tests; clean Dart analysis; release build and generated service worker; fullstack Wrangler deploy --dry-run. Update: the separate bible-path-chat API was subsequently deployed and a real Cloudflare inference returned HTTP 200 on 2026-10-23. Groq fallback still needs its server secret. The optional all-in-one frontend deployment remains pending.
