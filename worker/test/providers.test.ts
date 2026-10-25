import { afterEach, describe, expect, it, vi } from "vitest";
import { generateReply } from "../src/providers";
import { createHandler, type Env } from "../src/index";
const messages = [{ role: "user" as const, content: "Explain grace." }];
const secret = "test-only-groq-secret";
function setup(failed = false) {
  const run = vi.fn();
  if (failed) run.mockRejectedValue(new Error("quota exhausted"));
  else run.mockResolvedValue({ response: "Cloudflare answer" });
  return { run, AI: { run } as unknown as Ai };
}
function reply(content: unknown = "Groq answer", finish = "stop") {
  return new Response(JSON.stringify({
    choices: [{ message: { content, reasoning: "private reasoning" }, finish_reason: finish }],
  }));
}
afterEach(() => vi.unstubAllGlobals());
describe("Cloudflare primary, Groq fallback", () => {
  it("uses Cloudflare first even when Groq is configured", async () => {
    const cf = setup(); const fetcher = vi.fn(); vi.stubGlobal("fetch", fetcher);
    expect(await generateReply({ AI: cf.AI, GROQ_API_KEY: secret }, messages))
      .toEqual({ text: "Cloudflare answer", truncated: false });
    expect(fetcher).not.toHaveBeenCalled();
  });
  it("uses Groq once when Cloudflare quota is exhausted", async () => {
    const cf = setup(true); const fetcher = vi.fn().mockResolvedValue(reply());
    vi.stubGlobal("fetch", fetcher);
    expect(await generateReply({ AI: cf.AI, GROQ_API_KEY: secret }, messages))
      .toEqual({ text: "Groq answer", truncated: false });
    expect(cf.run).toHaveBeenCalledExactlyOnceWith("@cf/meta/llama-3.1-8b-instruct-fp8",
      { messages, max_tokens: 2048, temperature: 0.2 });
    expect(fetcher).toHaveBeenCalledOnce();
    const [url, options] = fetcher.mock.calls[0]!;
    expect(url).toBe("https://api.groq.com/openai/v1/chat/completions");
    expect(options.headers.Authorization).toBe("Bearer " + secret);
    expect(options.redirect).toBe("error");
    expect(JSON.parse(options.body)).toMatchObject({ model: "openai/gpt-oss-120b",
      messages, max_completion_tokens: 2048, reasoning_effort: "low" });
  });
  it("falls back for empty Cloudflare output", async () => {
    const cf = setup(); cf.run.mockResolvedValue({ response: " " });
    vi.stubGlobal("fetch", vi.fn().mockResolvedValue(reply()));
    expect((await generateReply({ AI: cf.AI, GROQ_API_KEY: secret }, messages)).text).toBe("Groq answer");
  });
  it("preserves truncation and hides reasoning", async () => {
    vi.stubGlobal("fetch", vi.fn().mockResolvedValue(reply("Partial", "length")));
    expect(await generateReply({ AI: setup(true).AI, GROQ_API_KEY: secret }, messages))
      .toEqual({ text: "Partial", truncated: true });
  });
  it.each([429, 500, 503, 401, 403, 400])("does not retry Groq HTTP %s", async status => {
    const cf = setup(true); const fetcher = vi.fn().mockResolvedValue(new Response(secret, { status }));
    vi.stubGlobal("fetch", fetcher);
    await expect(generateReply({ AI: cf.AI, GROQ_API_KEY: secret }, messages)).rejects.toThrow("AI unavailable");
    expect(fetcher).toHaveBeenCalledOnce(); expect(cf.run).toHaveBeenCalledOnce();
  });
  it.each(["", " ", null])("rejects empty Groq output (%s)", async content => {
    vi.stubGlobal("fetch", vi.fn().mockResolvedValue(reply(content)));
    await expect(generateReply({ AI: setup(true).AI, GROQ_API_KEY: secret }, messages)).rejects.toThrow("AI unavailable");
  });
  it("handles invalid JSON and network failure safely", async () => {
    const fetcher = vi.fn().mockResolvedValueOnce(new Response("invalid"))
      .mockRejectedValueOnce(new DOMException("timeout", "TimeoutError"));
    vi.stubGlobal("fetch", fetcher);
    for (let i = 0; i < 2; i++) {
      await expect(generateReply({ AI: setup(true).AI, GROQ_API_KEY: secret }, messages)).rejects.toThrow("AI unavailable");
    }
  });
  it("works without Groq key and reports Cloudflare failure", async () => {
    const fetcher = vi.fn(); vi.stubGlobal("fetch", fetcher);
    expect((await generateReply({ AI: setup().AI }, messages)).text).toBe("Cloudflare answer");
    await expect(generateReply({ AI: setup(true).AI }, messages)).rejects.toThrow();
    expect(fetcher).not.toHaveBeenCalled();
  });
  it("returns to Cloudflare as soon as its allowance recovers", async () => {
    const cf = setup(true); cf.run.mockResolvedValueOnce({ response: "Recovered" });
    const fetcher = vi.fn(); vi.stubGlobal("fetch", fetcher);
    expect((await generateReply({ AI: cf.AI, GROQ_API_KEY: secret }, messages)).text).toBe("Recovered");
    expect(fetcher).not.toHaveBeenCalled();
  });
  it("rejects invalid supplied authentication and sanitizes total failure", async () => {
    const cf = setup(true);
    const fetcher = vi.fn().mockResolvedValue(new Response(secret, { status: 429 }));
    vi.stubGlobal("fetch", fetcher);
    const token = "test-app-token-at-least-32-characters";
    const env: Env = { AI: cf.AI, GROQ_API_KEY: secret, APP_AUTH_TOKEN: token,
      ALLOWED_ORIGIN: "https://app.test", CHAT_RATE_LIMITER: { limit: async () => ({ success: true }) } };
    const make = (auth?: string) => new Request("https://api.test/v1/chat", {
      method: "POST", headers: { Origin: env.ALLOWED_ORIGIN, "Content-Type": "application/json",
        ...(auth ? { Authorization: "Bearer " + auth } : {}) },
      body: JSON.stringify({ sessionId: "s", locale: "pt", translationId: "blivre",
        message: "Explique a graca", history: [], context: [] }),
    });
    expect((await createHandler()(make("invalid-token"), env)).status).toBe(401);
    expect(fetcher).not.toHaveBeenCalled(); expect(cf.run).not.toHaveBeenCalled();
    const response = await createHandler()(make(), env);
    expect(response.status).toBe(503);
    expect(await response.json()).toEqual({ error: {
      code: "upstream_unavailable", message: "The assistant service is temporarily unavailable" } });
  });
});
