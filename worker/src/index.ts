import { buildUserContent, type BibleContext, SYSTEM_PROMPT } from "./prompt";

const MAX_BODY_BYTES = 64 * 1024;
const MAX_MESSAGE_CHARS = 2_000;
const MAX_HISTORY_TURNS = 12;
const MAX_HISTORY_CHARS = 16_000;
const MAX_CONTEXT_PASSAGES = 12;
const MAX_CONTEXT_CHARS = 12_000;
const RATE_LIMIT_RETRY_SECONDS = 60;
const CHAT_PATH = "/v1/chat";

export interface ChatRateLimiter {
  limit(input: { key: string }): Promise<{ success: boolean }>;
}

export interface Env {
  AI: Ai;
  APP_AUTH_TOKEN: string;
  ALLOWED_ORIGIN: string;
  CHAT_RATE_LIMITER: ChatRateLimiter;
}

interface HistoryTurn {
  role: "user" | "assistant";
  text: string;
}

interface ChatInput {
  sessionId: string;
  locale: string;
  translationId: string;
  message: string;
  history: HistoryTurn[];
  context: BibleContext[];
}

type Handler = (request: Request, env: Env) => Promise<Response>;

class HttpError extends Error {
  constructor(
    readonly status: number,
    readonly code: string,
    message: string,
    readonly headers?: HeadersInit,
  ) {
    super(message);
    this.name = "HttpError";
  }
}

export function createHandler(): Handler {
  return async (request, env) => {
    const { pathname } = new URL(request.url);

    if (request.method === "GET" && pathname === "/health") {
      return json({ status: "ok" }, 200);
    }

    if (request.method === "OPTIONS" && pathname === CHAT_PATH) {
      return handlePreflight(request, env);
    }

    if (request.method !== "POST" || pathname !== CHAT_PATH) {
      return errorResponse(new HttpError(404, "not_found", "Not found"));
    }

    return handleChat(request, env);
  };
}

async function handleChat(request: Request, env: Env): Promise<Response> {
  const origin = request.headers.get("Origin");
  let corsOrigin: string | null = null;

  try {
    assertConfiguration(env);

    if (origin !== env.ALLOWED_ORIGIN) {
      throw new HttpError(403, "origin_not_allowed", "Origin is not allowed");
    }
    corsOrigin = origin;

    assertAuthorized(request, env.APP_AUTH_TOKEN);
    await enforceRateLimit(request, env.CHAT_RATE_LIMITER);

    const contentType = request.headers.get("Content-Type")
      ?.split(";", 1)[0]
      ?.trim()
      .toLowerCase();
    if (contentType !== "application/json") {
      throw new HttpError(
        415,
        "unsupported_media_type",
        "Content-Type must be application/json",
      );
    }

    const input = validateChatInput(await readJsonBody(request));
    const messages = [
      { role: "system" as const, content: SYSTEM_PROMPT },
      ...input.history.map((turn) => ({
        role: turn.role,
        content: turn.text,
      })),
      {
        role: "user" as const,
        content: buildUserContent(
          input.message,
          input.context,
          input.locale,
          input.translationId,
        ),
      },
    ];

    const result = await env.AI.run("@cf/meta/llama-3.1-8b-instruct-fp8", {
      messages,
      max_tokens: 2_048,
      temperature: 0.2,
    });
    const text = extractResponseText(result);
    if (text.length === 0) {
      throw new HttpError(
        502,
        "empty_model_response",
        "The assistant returned no text",
      );
    }
    return json({ text, truncated: false }, 200, corsOrigin);
  } catch (error) {
    const httpError = mapError(error);
    logOperationalError(error);
    return errorResponse(httpError, corsOrigin);
  }
}

function handlePreflight(request: Request, env: Env): Response {
  try {
    assertAllowedOriginConfiguration(env.ALLOWED_ORIGIN);
    const origin = request.headers.get("Origin");
    if (origin !== env.ALLOWED_ORIGIN) {
      throw new HttpError(403, "origin_not_allowed", "Origin is not allowed");
    }

    if (request.headers.get("Access-Control-Request-Method") !== "POST") {
      throw new HttpError(
        403,
        "method_not_allowed",
        "Requested method is not allowed",
      );
    }

    const requestedHeaders = request.headers
      .get("Access-Control-Request-Headers")
      ?.split(",")
      .map((header) => header.trim().toLowerCase())
      .filter(Boolean) ?? [];
    const allowedHeaders = new Set(["authorization", "content-type"]);
    if (requestedHeaders.some((header) => !allowedHeaders.has(header))) {
      throw new HttpError(
        403,
        "headers_not_allowed",
        "Requested headers are not allowed",
      );
    }

    const headers = corsHeaders(origin);
    headers.set("Access-Control-Max-Age", "86400");
    headers.set("Cache-Control", "no-store");
    return new Response(null, { status: 204, headers });
  } catch (error) {
    const httpError = mapError(error);
    const origin = request.headers.get("Origin");
    const corsOrigin = origin === env.ALLOWED_ORIGIN ? origin : null;
    return errorResponse(httpError, corsOrigin);
  }
}

function assertConfiguration(env: Env): void {
  if (
    !env.AI ||
    typeof env.AI.run !== "function" ||
    typeof env.APP_AUTH_TOKEN !== "string" ||
    env.APP_AUTH_TOKEN.length < 32 ||
    !env.CHAT_RATE_LIMITER ||
    typeof env.CHAT_RATE_LIMITER.limit !== "function"
  ) {
    throw new HttpError(
      500,
      "server_misconfigured",
      "The service is not configured",
    );
  }
  assertAllowedOriginConfiguration(env.ALLOWED_ORIGIN);
}

function assertAllowedOriginConfiguration(origin: string): void {
  try {
    const parsed = new URL(origin);
    if (
      parsed.origin !== origin ||
      (parsed.protocol !== "https:" && parsed.protocol !== "http:")
    ) {
      throw new Error("invalid origin");
    }
  } catch {
    throw new HttpError(
      500,
      "server_misconfigured",
      "The service is not configured",
    );
  }
}

function assertAuthorized(request: Request, expectedToken: string): void {
  const authorization = request.headers.get("Authorization");
  const match = authorization?.match(/^Bearer ([^\s,]+)$/i);
  if (!match || !constantTimeEqual(match[1] ?? "", expectedToken)) {
    throw new HttpError(401, "unauthorized", "Unauthorized", {
      "WWW-Authenticate": "Bearer",
    });
  }
}

function constantTimeEqual(left: string, right: string): boolean {
  const length = Math.max(left.length, right.length);
  let difference = left.length ^ right.length;
  for (let index = 0; index < length; index += 1) {
    difference |= (left.charCodeAt(index) || 0) ^ (right.charCodeAt(index) || 0);
  }
  return difference === 0;
}

async function enforceRateLimit(
  request: Request,
  rateLimiter: ChatRateLimiter,
): Promise<void> {
  const key = request.headers.get("CF-Connecting-IP") ?? "unknown";
  let result: { success: boolean };
  try {
    result = await rateLimiter.limit({ key });
  } catch {
    throw new HttpError(
      503,
      "rate_limiter_unavailable",
      "The service is temporarily unavailable",
      { "Retry-After": "5" },
    );
  }

  if (!result.success) {
    throw new HttpError(
      429,
      "rate_limit_exceeded",
      "Too many requests",
      { "Retry-After": String(RATE_LIMIT_RETRY_SECONDS) },
    );
  }
}

async function readJsonBody(request: Request): Promise<unknown> {
  const declaredLength = request.headers.get("Content-Length");
  if (declaredLength !== null) {
    const bytes = Number(declaredLength);
    if (Number.isFinite(bytes) && bytes > MAX_BODY_BYTES) {
      throw new HttpError(413, "body_too_large", "Request body is too large");
    }
  }

  if (request.body === null) {
    throw new HttpError(400, "invalid_json", "A JSON body is required");
  }

  const reader = request.body.getReader();
  const chunks: Uint8Array[] = [];
  let totalBytes = 0;

  try {
    while (true) {
      const { done, value } = await reader.read();
      if (done) break;
      totalBytes += value.byteLength;
      if (totalBytes > MAX_BODY_BYTES) {
        await reader.cancel().catch(() => undefined);
        throw new HttpError(413, "body_too_large", "Request body is too large");
      }
      chunks.push(value);
    }
  } catch (error) {
    if (error instanceof HttpError) throw error;
    throw new HttpError(400, "invalid_json", "Could not read request body");
  } finally {
    reader.releaseLock();
  }

  const body = new Uint8Array(totalBytes);
  let offset = 0;
  for (const chunk of chunks) {
    body.set(chunk, offset);
    offset += chunk.byteLength;
  }

  try {
    return JSON.parse(new TextDecoder("utf-8", { fatal: true }).decode(body));
  } catch {
    throw new HttpError(400, "invalid_json", "Request body must be valid JSON");
  }
}

function validateChatInput(value: unknown): ChatInput {
  if (!isRecord(value)) {
    throw invalidRequest("Request body must be a JSON object");
  }

  const allowedKeys = new Set([
    "sessionId",
    "locale",
    "translationId",
    "message",
    "history",
    "context",
  ]);
  if (Object.keys(value).some((key) => !allowedKeys.has(key))) {
    throw invalidRequest("Request body contains unsupported fields");
  }

  const sessionId = requiredString(value.sessionId, "sessionId", 128);
  const locale = requiredString(value.locale, "locale", 16);
  const translationId = requiredString(
    value.translationId,
    "translationId",
    64,
  );
  const message = requiredString(value.message, "message", MAX_MESSAGE_CHARS);
  if (!/^[a-z]{2}(?:-[A-Za-z0-9]{2,8})?$/.test(locale)) {
    throw invalidRequest("locale is invalid");
  }

  const historyValue = value.history ?? [];
  if (!Array.isArray(historyValue) || historyValue.length > MAX_HISTORY_TURNS) {
    throw invalidRequest(`history must contain at most ${MAX_HISTORY_TURNS} turns`);
  }

  const history: HistoryTurn[] = [];
  let historyChars = 0;
  for (const turn of historyValue) {
    if (
      !isRecord(turn) ||
      Object.keys(turn).some((key) => key !== "role" && key !== "text") ||
      (turn.role !== "user" && turn.role !== "assistant")
    ) {
      throw invalidRequest(
        "Each history turn must contain only role and text",
      );
    }
    const text = requiredString(turn.text, "history text", MAX_HISTORY_CHARS);
    historyChars += characterCount(text);
    if (historyChars > MAX_HISTORY_CHARS) {
      throw invalidRequest(
        `history must not exceed ${MAX_HISTORY_CHARS} characters`,
      );
    }
    history.push({ role: turn.role, text });
  }
  if (history[0]?.role === "assistant") {
    throw invalidRequest("history must begin with a user turn");
  }

  const contextValue = value.context ?? [];
  if (!Array.isArray(contextValue) || contextValue.length > MAX_CONTEXT_PASSAGES) {
    throw invalidRequest(
      `context must contain at most ${MAX_CONTEXT_PASSAGES} passages`,
    );
  }

  const context: BibleContext[] = [];
  let contextChars = 0;
  for (const passage of contextValue) {
    if (
      !isRecord(passage) ||
      Object.keys(passage).some(
        (key) =>
          key !== "reference" && key !== "translationId" && key !== "text",
      )
    ) {
      throw invalidRequest(
        "Each context passage must contain only reference, translationId, and text",
      );
    }
    const reference = requiredString(passage.reference, "reference", 128);
    const passageTranslation = requiredString(
      passage.translationId,
      "context translationId",
      64,
    );
    const text = requiredString(passage.text, "context text", MAX_CONTEXT_CHARS);
    contextChars += characterCount(reference) +
      characterCount(passageTranslation) + characterCount(text);
    if (contextChars > MAX_CONTEXT_CHARS) {
      throw invalidRequest(
        `context must not exceed ${MAX_CONTEXT_CHARS} characters`,
      );
    }
    context.push({ reference, translationId: passageTranslation, text });
  }

  return { sessionId, locale, translationId, message, history, context };
}

function requiredString(value: unknown, field: string, max: number): string {
  if (typeof value !== "string" || value.trim().length === 0) {
    throw invalidRequest(`${field} must be a non-empty string`);
  }
  if (characterCount(value) > max) {
    throw invalidRequest(`${field} must not exceed ${max} characters`);
  }
  return value;
}

function extractResponseText(value: unknown): string {
  if (typeof value === "string") return value.trim();
  if (isRecord(value) && typeof value.response === "string") {
    return value.response.trim();
  }
  return "";
}

function characterCount(value: string): number {
  let count = 0;
  for (const _character of value) count += 1;
  return count;
}

function isRecord(value: unknown): value is Record<string, unknown> {
  return typeof value === "object" && value !== null && !Array.isArray(value);
}

function invalidRequest(message: string): HttpError {
  return new HttpError(400, "invalid_request", message);
}

function mapError(error: unknown): HttpError {
  if (error instanceof HttpError) return error;
  return new HttpError(
    503,
    "upstream_unavailable",
    "The assistant service is temporarily unavailable",
    { "Retry-After": "5" },
  );
}

function logOperationalError(error: unknown): void {
  if (error instanceof HttpError) return;
  console.error("Workers AI request failed", {
    name: error instanceof Error ? error.name : "UnknownError",
  });
}

function errorResponse(error: HttpError, origin: string | null = null): Response {
  return json(
    { error: { code: error.code, message: error.message } },
    error.status,
    origin,
    error.headers,
  );
}

function json(
  payload: unknown,
  status: number,
  origin: string | null = null,
  extraHeaders?: HeadersInit,
): Response {
  const headers = new Headers(extraHeaders);
  headers.set("Content-Type", "application/json; charset=utf-8");
  headers.set("Cache-Control", "no-store");
  headers.set("X-Content-Type-Options", "nosniff");
  if (origin !== null) {
    const cors = corsHeaders(origin);
    cors.forEach((value, key) => headers.set(key, value));
  }
  return new Response(JSON.stringify(payload), { status, headers });
}

function corsHeaders(origin: string): Headers {
  return new Headers({
    "Access-Control-Allow-Origin": origin,
    "Access-Control-Allow-Methods": "POST, OPTIONS",
    "Access-Control-Allow-Headers": "Authorization, Content-Type",
    Vary: "Origin, Access-Control-Request-Method, Access-Control-Request-Headers",
  });
}

const handler = createHandler();

export default {
  fetch(request, env) {
    return handler(request, env);
  },
} satisfies ExportedHandler<Env>;
