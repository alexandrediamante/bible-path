import { describe, expect, it, vi } from "vitest";
import { createHandler, type Env } from "../src/index";
import { SYSTEM_PROMPT } from "../src/prompt";

const ALLOWED_ORIGIN = "https://bible-path.pages.dev";
const AUTH_TOKEN = "test-app-token-with-at-least-32-characters";

function mockedAi(result: unknown = { response: "A thoughtful answer." }) {
  const run = vi.fn().mockResolvedValue(result);
  return { binding: { run } as unknown as Ai, run };
}

function env(overrides: Partial<Env> = {}): Env {
  return {
    AI: mockedAi().binding,
    APP_AUTH_TOKEN: AUTH_TOKEN,
    ALLOWED_ORIGIN,
    CHAT_RATE_LIMITER: { limit: vi.fn().mockResolvedValue({ success: true }) },
    ...overrides,
  };
}

const VALID_BODY = {
  sessionId: "session-test",
  locale: "en",
  translationId: "engwebp",
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
  it("serves health without calling Workers AI", async () => {
    const ai = mockedAi();
    const response = await createHandler()(
      new Request("https://worker.test/health"),
      env({ AI: ai.binding }),
    );

    expect(response.status).toBe(200);
    await expect(response.json()).resolves.toEqual({ status: "ok" });
    expect(ai.run).not.toHaveBeenCalled();
  });

  it("returns 404 for every other route", async () => {
    const response = await createHandler()(
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
  it("fails closed when the AI binding is missing", async () => {
    const response = await createHandler()(request(), env({ AI: undefined as unknown as Ai }));

    expect(response.status).toBe(500);
    expect(await errorCode(response)).toBe("server_misconfigured");
  });

  it("fails closed when the configured app token is weak", async () => {
    const ai = mockedAi();
    const response = await createHandler()(
      request(),
      env({ AI: ai.binding, APP_AUTH_TOKEN: "too-short" }),
    );

    expect(response.status).toBe(500);
    expect(await errorCode(response)).toBe("server_misconfigured");
    expect(ai.run).not.toHaveBeenCalled();
  });

  it("validates bearer auth before parsing the body", async () => {
    const ai = mockedAi();
    const response = await createHandler()(
      request(undefined, {
        authorization: "Bearer wrong-token",
        rawBody: "{not-json",
      }),
      env({ AI: ai.binding }),
    );

    expect(response.status).toBe(401);
    expect(await errorCode(response)).toBe("unauthorized");
    expect(ai.run).not.toHaveBeenCalled();
  });

  it("rejects browser requests from a different origin", async () => {
    const ai = mockedAi();
    const response = await createHandler()(
      request(undefined, {
        origin: "https://evil.example",
        rawBody: "{not-json",
      }),
      env({ AI: ai.binding }),
    );

    expect(response.status).toBe(403);
    expect(await errorCode(response)).toBe("origin_not_allowed");
    expect(ai.run).not.toHaveBeenCalled();
  });

  it("rejects requests with no Origin header", async () => {
    const response = await createHandler()(
      request({ message: "Hello" }, { origin: null }),
      env(),
    );

    expect(response.status).toBe(403);
    expect(response.headers.get("Access-Control-Allow-Origin")).toBeNull();
  });

  it("rejects bodies larger than 64 KiB", async () => {
    const ai = mockedAi();
    const response = await createHandler()(
      request(undefined, { rawBody: "x".repeat(64 * 1024 + 1) }),
      env({ AI: ai.binding }),
    );

    expect(response.status).toBe(413);
    expect(await errorCode(response)).toBe("body_too_large");
    expect(ai.run).not.toHaveBeenCalled();
  });

  it.each(["model", "system", "max_tokens"])(
    "rejects the browser-controlled %s field",
    async (field) => {
      const ai = mockedAi();
      const response = await createHandler()(
        request({ message: "Hello", [field]: "override" }),
        env({ AI: ai.binding }),
      );

      expect(response.status).toBe(400);
      expect(await errorCode(response)).toBe("invalid_request");
      expect(ai.run).not.toHaveBeenCalled();
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
          translationId: "engwebp",
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
          translationId: "engwebp",
          text: "x".repeat(12_001),
        }],
      },
    ],
  ])("enforces the %s limit", async (_name, body) => {
    const ai = mockedAi();
    const response = await createHandler()(request(body), env({ AI: ai.binding }));

    expect(response.status).toBe(400);
    expect(await errorCode(response)).toBe("invalid_request");
    expect(ai.run).not.toHaveBeenCalled();
  });

  it("enforces the configured rate limiter before parsing", async () => {
    const ai = mockedAi();
    const rateLimit = vi.fn().mockResolvedValue({ success: false });
    const response = await createHandler()(
      request(undefined, { rawBody: "{not-json" }),
      env({ AI: ai.binding, CHAT_RATE_LIMITER: { limit: rateLimit } }),
    );

    expect(response.status).toBe(429);
    expect(response.headers.get("Retry-After")).toBe("60");
    expect(await errorCode(response)).toBe("rate_limit_exceeded");
    expect(ai.run).not.toHaveBeenCalled();
  });
});

describe("Workers AI request and outcomes", () => {
  it("uses only the server-owned model and system prompt", async () => {
    const ai = mockedAi();
    const response = await createHandler()(
      request({
        message: "Explain this",
        history: [
          { role: "user", text: "Earlier question" },
          { role: "assistant", text: "Earlier answer" },
        ],
        context: [{
          reference: "Romans 5:1-2",
          translationId: "engwebp",
          text: "Being therefore justified by faith, we have peace with God.",
        }],
      }),
      env({ AI: ai.binding }),
    );

    expect(response.status).toBe(200);
    await expect(response.json()).resolves.toEqual({
      text: "A thoughtful answer.",
      truncated: false,
    });
    expect(response.headers.get("Access-Control-Allow-Origin")).toBe(
      ALLOWED_ORIGIN,
    );

    expect(ai.run).toHaveBeenCalledOnce();
    const [model, params] = ai.run.mock.calls[0] ?? [];
    expect(model).toBe("@cf/meta/llama-3.1-8b-instruct-fp8");
    expect(params).toMatchObject({
      max_tokens: 2_048,
      temperature: 0.2,
    });
    expect(params.messages).toHaveLength(4);
    expect(params.messages[0]).toEqual({
      role: "system",
      content: SYSTEM_PROMPT,
    });
    expect(params.messages[3].content).toContain("Romans 5:1-2");
    expect(params.messages[3].content).toContain("Explain this");
  });

  it("accepts a direct string response", async () => {
    const ai = mockedAi("Direct response");
    const response = await createHandler()(request(), env({ AI: ai.binding }));

    expect(response.status).toBe(200);
    await expect(response.json()).resolves.toEqual({
      text: "Direct response",
      truncated: false,
    });
  });

  it("rejects an empty model response", async () => {
    const ai = mockedAi({ response: "   " });
    const response = await createHandler()(request(), env({ AI: ai.binding }));

    expect(response.status).toBe(502);
    expect(await errorCode(response)).toBe("empty_model_response");
  });

  it("maps Workers AI failures without exposing details", async () => {
    const ai = mockedAi();
    ai.run.mockRejectedValue(new Error("internal model details"));

    const response = await createHandler()(request(), env({ AI: ai.binding }));

    expect(response.status).toBe(503);
    expect(response.headers.get("Retry-After")).toBe("5");
    await expect(response.json()).resolves.toEqual({
      error: {
        code: "upstream_unavailable",
        message: "The assistant service is temporarily unavailable",
      },
    });
  });
});
