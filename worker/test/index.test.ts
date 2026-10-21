import Anthropic from "@anthropic-ai/sdk";
import { describe, expect, it, vi } from "vitest";
import { createHandler, type Env } from "../src/index";
import { SYSTEM_PROMPT } from "../src/prompt";

const ALLOWED_ORIGIN = "https://app.example.test";
const AUTH_TOKEN = "test-app-token-with-at-least-32-characters";

function message(
  stopReason: string | null = "end_turn",
  content: unknown[] = [{ type: "text", text: "A thoughtful answer." }],
): Anthropic.Beta.BetaMessage {
  return {
    id: "msg_test",
    type: "message",
    role: "assistant",
    model: "claude-opus-5-5",
    content,
    stop_reason: stopReason,
    stop_sequence: null,
    usage: { input_tokens: 10, output_tokens: 5 },
  } as Anthropic.Beta.BetaMessage;
}

function mockedAnthropic(response: Anthropic.Beta.BetaMessage = message()) {
  const create = vi.fn().mockResolvedValue(response);
  const client = { beta: { messages: { create } } } as unknown as Anthropic;
  return { client, create };
}

function env(overrides: Partial<Env> = {}): Env {
  return {
    ANTHROPIC_API_KEY: "test-anthropic-key",
    APP_AUTH_TOKEN: AUTH_TOKEN,
    ALLOWED_ORIGIN,
    CHAT_RATE_LIMITER: { limit: vi.fn().mockResolvedValue({ success: true }) },
    ...overrides,
  };
}

const VALID_BODY = {
  sessionId: "session-test",
  locale: "en",
  translationId: "web",
  message: "What does grace mean?",
  history: [],
  context: [],
};

function request(
  body: unknown = VALID_BODY,
  overrides: {
    authorization?: string | null;
    origin?: string | null;
    rawBody?: string;
    contentType?: string | null;
    headers?: Record<string, string>;
  } = {},
): Request {
  const headers = new Headers(overrides.headers);
  if (overrides.authorization !== null) {
    headers.set("Authorization", overrides.authorization ?? `Bearer ${AUTH_TOKEN}`);
  }
  if (overrides.origin !== null) {
    headers.set("Origin", overrides.origin ?? ALLOWED_ORIGIN);
  }
  if (overrides.contentType !== null) {
    headers.set("Content-Type", overrides.contentType ?? "application/json");
  }
  const payload = body !== null && typeof body === "object" && !Array.isArray(body)
    ? { ...VALID_BODY, ...body }
    : body;
  return new Request("https://worker.test/v1/chat", {
    method: "POST",
    headers,
    body: overrides.rawBody ?? JSON.stringify(payload),
  });
}

async function errorCode(response: Response): Promise<string> {
  const payload = (await response.json()) as { error: { code: string } };
  return payload.error.code;
}

describe("routing and CORS", () => {
  it("serves health without calling Anthropic", async () => {
    const { client, create } = mockedAnthropic();
    const handle = createHandler(() => client);

    const response = await handle(
      new Request("https://worker.test/health"),
      env(),
    );

    expect(response.status).toBe(200);
    await expect(response.json()).resolves.toEqual({ status: "ok" });
    expect(create).not.toHaveBeenCalled();
  });

  it("returns 404 for every other route", async () => {
    const { client } = mockedAnthropic();
    const response = await createHandler(() => client)(
      new Request("https://worker.test/nope"),
      env(),
    );

    expect(response.status).toBe(404);
    expect(await errorCode(response)).toBe("not_found");
  });

  it("answers an exact-origin preflight", async () => {
    const response = await createHandler()(
      new Request("https://worker.test/v1/chat", {
        method: "OPTIONS",
        headers: {
          Origin: ALLOWED_ORIGIN,
          "Access-Control-Request-Method": "POST",
          "Access-Control-Request-Headers": "authorization, content-type",
        },
      }),
      env(),
    );

    expect(response.status).toBe(204);
    expect(response.headers.get("Access-Control-Allow-Origin")).toBe(
      ALLOWED_ORIGIN,
    );
    expect(response.headers.get("Access-Control-Allow-Origin")).not.toBe("*");
  });

  it("rejects a different preflight origin without CORS headers", async () => {
    const response = await createHandler()(
      new Request("https://worker.test/v1/chat", {
        method: "OPTIONS",
        headers: {
          Origin: "https://evil.example",
          "Access-Control-Request-Method": "POST",
        },
      }),
      env(),
    );

    expect(response.status).toBe(403);
    expect(response.headers.get("Access-Control-Allow-Origin")).toBeNull();
    expect(await errorCode(response)).toBe("origin_not_allowed");
  });
});

describe("authentication and request validation", () => {
  it("fails closed when the configured app token is weak", async () => {
    const { client, create } = mockedAnthropic();
    const response = await createHandler(() => client)(
      request(),
      env({ APP_AUTH_TOKEN: "too-short" }),
    );

    expect(response.status).toBe(500);
    expect(await errorCode(response)).toBe("server_misconfigured");
    expect(create).not.toHaveBeenCalled();
  });

  it("validates bearer auth before parsing the body", async () => {
    const { client, create } = mockedAnthropic();
    const response = await createHandler(() => client)(
      request(undefined, {
        authorization: "Bearer wrong-token",
        rawBody: "{not-json",
      }),
      env(),
    );

    expect(response.status).toBe(401);
    expect(await errorCode(response)).toBe("unauthorized");
    expect(create).not.toHaveBeenCalled();
  });

  it("rejects browser requests from a different origin", async () => {
    const { client, create } = mockedAnthropic();
    const response = await createHandler(() => client)(
      request(undefined, {
        origin: "https://evil.example",
        rawBody: "{not-json",
      }),
      env(),
    );

    expect(response.status).toBe(403);
    expect(await errorCode(response)).toBe("origin_not_allowed");
    expect(create).not.toHaveBeenCalled();
  });

  it("rejects requests with no Origin header", async () => {
    const { client, create } = mockedAnthropic();
    const response = await createHandler(() => client)(
      request({ message: "Hello" }, { origin: null }),
      env(),
    );

    expect(response.status).toBe(403);
    expect(response.headers.get("Access-Control-Allow-Origin")).toBeNull();
    expect(await errorCode(response)).toBe("origin_not_allowed");
    expect(create).not.toHaveBeenCalled();
  });

  it("rejects bodies larger than 64 KiB", async () => {
    const { client, create } = mockedAnthropic();
    const response = await createHandler(() => client)(
      request(undefined, { rawBody: "x".repeat(64 * 1024 + 1) }),
      env(),
    );

    expect(response.status).toBe(413);
    expect(await errorCode(response)).toBe("body_too_large");
    expect(create).not.toHaveBeenCalled();
  });

  it.each(["model", "system", "max_tokens"])(
    "rejects the browser-controlled %s field",
    async (field) => {
      const { client, create } = mockedAnthropic();
      const response = await createHandler(() => client)(
        request({ message: "Hello", [field]: "override" }),
        env(),
      );

      expect(response.status).toBe(400);
      expect(await errorCode(response)).toBe("invalid_request");
      expect(create).not.toHaveBeenCalled();
    },
  );

  it.each([
    ["message", { message: "x".repeat(2_001) }],
    [
      "history turns",
      {
        message: "Hello",
        history: Array.from({ length: 13 }, (_, index) => ({
          role: index % 2 === 0 ? "user" : "assistant",
          text: "x",
        })),
      },
    ],
    [
      "history characters",
      {
        message: "Hello",
        history: [{ role: "user", text: "x".repeat(16_001) }],
      },
    ],
    [
      "context passages",
      {
        message: "Hello",
        context: Array.from({ length: 13 }, () => ({
          reference: "John 1:1",
          translationId: "web",
          text: "x",
        })),
      },
    ],
    [
      "context characters",
      {
        message: "Hello",
        context: [{
          reference: "John 1:1",
          translationId: "web",
          text: "x".repeat(12_001),
        }],
      },
    ],
  ])("enforces the %s limit", async (_name, body) => {
    const { client, create } = mockedAnthropic();
    const response = await createHandler(() => client)(request(body), env());

    expect(response.status).toBe(400);
    expect(await errorCode(response)).toBe("invalid_request");
    expect(create).not.toHaveBeenCalled();
  });

  it("enforces the configured rate limiter before parsing", async () => {
    const { client, create } = mockedAnthropic();
    const rateLimit = vi.fn().mockResolvedValue({ success: false });
    const response = await createHandler(() => client)(
      request(undefined, { rawBody: "{not-json" }),
      env({ CHAT_RATE_LIMITER: { limit: rateLimit } }),
    );

    expect(response.status).toBe(429);
    expect(response.headers.get("Retry-After")).toBe("60");
    expect(await errorCode(response)).toBe("rate_limit_exceeded");
    expect(rateLimit).toHaveBeenCalledWith({ key: "unknown" });
    expect(create).not.toHaveBeenCalled();
  });
});

describe("Anthropic request and outcomes", () => {
  it("uses only the server-owned Claude configuration", async () => {
    const { client, create } = mockedAnthropic();
    const response = await createHandler(() => client)(
      request({
        message: "Explain this",
        history: [
          { role: "user", text: "Earlier question" },
          { role: "assistant", text: "Earlier answer" },
        ],
        context: [{
          reference: "Romans 5:1-2",
          translationId: "web",
          text: "Being therefore justified by faith, we have peace with God.",
        }],
      }),
      env(),
    );

    expect(response.status).toBe(200);
    await expect(response.json()).resolves.toEqual({
      text: "A thoughtful answer.",
      truncated: false,
    });
    expect(response.headers.get("Access-Control-Allow-Origin")).toBe(
      ALLOWED_ORIGIN,
    );

    expect(create).toHaveBeenCalledOnce();
    const params = create.mock.calls[0]?.[0];
    expect(params).toMatchObject({
      betas: ["server-side-fallback-2026-07-01"],
      fallbacks: "default",
      model: "claude-opus-5-5",
      max_tokens: 2_048,
      thinking: { type: "adaptive" },
      output_config: { effort: "medium" },
      system: SYSTEM_PROMPT,
    });
    expect(params.messages).toHaveLength(3);
    expect(params.messages[2].content).toContain("Romans 5:1-2");
    expect(params.messages[2].content).toContain("Explain this");
  });

  it("returns truncated text for max_tokens", async () => {
    const { client } = mockedAnthropic(message("max_tokens"));
    const response = await createHandler(() => client)(request(), env());

    expect(response.status).toBe(200);
    await expect(response.json()).resolves.toEqual({
      text: "A thoughtful answer.",
      truncated: true,
    });
  });

  it.each([
    ["refusal", 422, "request_refused"],
    ["tool_use", 502, "unexpected_model_stop"],
    ["pause_turn", 502, "unexpected_model_stop"],
  ])("handles the %s stop reason", async (stopReason, status, code) => {
    const { client } = mockedAnthropic(message(stopReason));
    const response = await createHandler(() => client)(request(), env());

    expect(response.status).toBe(status);
    expect(await errorCode(response)).toBe(code);
  });

  it("rejects an empty successful response", async () => {
    const { client } = mockedAnthropic(
      message("end_turn", [{ type: "thinking", thinking: "", signature: "x" }]),
    );
    const response = await createHandler(() => client)(request(), env());

    expect(response.status).toBe(502);
    expect(await errorCode(response)).toBe("empty_model_response");
  });

  it("maps typed Anthropic rate-limit errors without exposing details", async () => {
    const { client, create } = mockedAnthropic();
    const typedError = Object.assign(
      Object.create(Anthropic.RateLimitError.prototype) as Anthropic.RateLimitError,
      { name: "RateLimitError", status: 429, type: "rate_limit_error" },
    );
    create.mockRejectedValue(typedError);

    const response = await createHandler(() => client)(request(), env());

    expect(response.status).toBe(503);
    expect(response.headers.get("Retry-After")).toBe("5");
    await expect(response.json()).resolves.toEqual({
      error: {
        code: "upstream_rate_limited",
        message: "The assistant service is temporarily busy",
      },
    });
  });

  it("maps typed Anthropic authentication errors to a safe gateway error", async () => {
    const { client, create } = mockedAnthropic();
    const typedError = Object.assign(
      Object.create(
        Anthropic.AuthenticationError.prototype,
      ) as Anthropic.AuthenticationError,
      { name: "AuthenticationError", status: 401, type: "authentication_error" },
    );
    create.mockRejectedValue(typedError);

    const response = await createHandler(() => client)(request(), env());

    expect(response.status).toBe(502);
    expect(await errorCode(response)).toBe("upstream_request_failed");
  });
});
