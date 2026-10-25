# Cloudflare primary + Groq fallback

Updated 2026-10-23. User changed provider order: Cloudflare first, Groq reserve.

## Behavior

Authenticated, validated requests first use the Workers AI binding AI and model @cf/meta/llama-3.1-8b-instruct-fp8. Cloudflare failure (including exhausted quota) or empty output invokes Groq once if GROQ_API_KEY is configured.

Groq uses openai/gpt-oss-120b, low reasoning effort, at most 2048 completion tokens, a 15-second timeout and a fixed HTTPS endpoint rejecting redirects. Empty/malformed replies and upstream failures return a safe API error; reasoning and private diagnostics are never exposed.

Every request starts with Cloudflare, so its recovered allowance is used automatically. Without the Groq secret, Cloudflare works alone; its failure cannot use Groq. No distributed daily counter, retry loop or key rotation is used. Existing origin/auth/input/per-IP checks run before providers.

## Groq activation

Use https://console.groq.com/keys to create a key on the Free plan. Do not paste keys into chat, code, screenshots or browser build variables.

For the existing deployed bible-path-chat Worker, add a secret named GROQ_API_KEY in Cloudflare Settings > Variables and Secrets. Alternatively, from worker/ use interactive Wrangler input:
npx wrangler secret put GROQ_API_KEY

For local Worker use only ignored worker/.dev.vars.local. For the separate optional fullstack config, append --config wrangler.fullstack.toml to Wrangler secret commands.

Cloudflare requires the AI binding, not a separate inference key in our code. APP_AUTH_TOKEN protects the endpoint and is separate from Groq credentials.

## Costs and privacy

Keep the provider accounts on free plans if no spending is intended. The code does not enforce provider billing plans or guarantee no charges on a paid plan. Cloudflare quotas use Neurons; Groq quotas use tokens/requests. Allowance exhaustion in both providers means waiting for reset.

The bounded conversation and Bible context go to Cloudflare, and to Groq only on fallback. Smoke testing uses an original, generic one-sentence prompt without user conversation history.

## Verification

43 Worker tests and TypeScript typecheck pass after provider inversion. Live deployment/test outcome is recorded at the top of HANDOFF.md. Tests cover Cloudflare success without Groq requests, fallback and recovery, malformed output, upstream failures, auth gating and safe total failure.

Official documentation:
- https://developers.cloudflare.com/workers-ai/platform/pricing/
- https://console.groq.com/docs/rate-limits
- https://console.groq.com/docs/api-reference
