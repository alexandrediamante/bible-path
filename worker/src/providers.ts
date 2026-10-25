// Cloudflare primary; Groq fallback. Secrets remain server-side.
export interface ProviderEnv { AI: Ai; GROQ_API_KEY?: string }
type Message = { role: "system" | "user" | "assistant"; content: string };
export interface ModelReply { text: string; truncated: boolean }
export interface SpeechReply { bytes: Uint8Array; contentType: "audio/wav" }
const MAX_COMPLETION_TOKENS = 512;
function record(value: unknown): value is Record<string, unknown> {
  return typeof value === "object" && value !== null && !Array.isArray(value);
}
export async function generateReply(env: ProviderEnv, messages: Message[]): Promise<ModelReply> {
  let primaryError: unknown;
  try {
    const result: unknown = await env.AI.run("@cf/meta/llama-3.1-8b-instruct-fp8", {
      messages, max_tokens: MAX_COMPLETION_TOKENS, temperature: 0.2,
    });
    const text = typeof result === "string" ? result.trim()
      : record(result) && typeof result.response === "string" ? result.response.trim() : "";
    if (text || !env.GROQ_API_KEY?.trim()) return { text, truncated: false };
  } catch (error) {
    primaryError = error;
  }
  const key = env.GROQ_API_KEY?.trim();
  if (!key) throw primaryError ?? new Error("AI unavailable");
  // Includes Cloudflare quota exhaustion. Try Groq once without exposing diagnostics.
  try {
    const response = await fetch("https://api.groq.com/openai/v1/chat/completions", {
      method: "POST",
      headers: { Authorization: `Bearer ${key}`, "Content-Type": "application/json" },
      body: JSON.stringify({
        model: "openai/gpt-oss-120b", messages,
        max_completion_tokens: MAX_COMPLETION_TOKENS,
        reasoning_effort: "low", temperature: 0.2, stream: false,
      }),
      signal: AbortSignal.timeout(15_000),
      redirect: "error",
    });
    if (!response.ok) {
      await response.body?.cancel();
      throw new Error("AI unavailable");
    }
    const payload: unknown = await response.json();
    const choice = record(payload) && Array.isArray(payload.choices)
      ? payload.choices[0] as unknown : undefined;
    const message = record(choice) ? choice.message : undefined;
    const text = record(message) && typeof message.content === "string"
      ? message.content.trim() : "";
    if (text) return { text, truncated: record(choice) && choice.finish_reason === "length" };
  } catch {
    throw new Error("AI unavailable");
  }
  throw new Error("AI unavailable");
}

export async function generateSpeech(
  env: Pick<ProviderEnv, "AI">,
  text: string,
  language: "en" | "es" | "fr",
): Promise<SpeechReply> {
  const result: unknown = await env.AI.run("@cf/myshell-ai/melotts", {
    prompt: text,
    lang: language,
  });
  if (!record(result) || typeof result.audio !== "string") {
    throw new Error("TTS unavailable");
  }
  let binary: string;
  try {
    binary = atob(result.audio);
  } catch {
    throw new Error("TTS unavailable");
  }
  const bytes = Uint8Array.from(binary, (character) => character.charCodeAt(0));
  if (
    bytes.length < 44 ||
    String.fromCharCode(...bytes.subarray(0, 4)) !== "RIFF" ||
    String.fromCharCode(...bytes.subarray(8, 12)) !== "WAVE"
  ) {
    throw new Error("TTS unavailable");
  }
  return { bytes, contentType: "audio/wav" };
}
