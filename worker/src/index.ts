import { buildUserContent, type BibleContext, SYSTEM_PROMPT } from "./prompt";
import { generateReply, generateSpeech } from "./providers";
import { verifyGoogleIdToken, getOrCreateUser, generateAppAuthToken, verifyAppAuthToken } from "./auth";
import { syncUserData, getUserCloudData, type SyncPayload } from "./sync";

const MAX_BODY_BYTES = 64 * 1024;
const MAX_MESSAGE_CHARS = 2_000;
const MAX_HISTORY_TURNS = 12;
const MAX_HISTORY_CHARS = 16_000;
const MAX_CONTEXT_PASSAGES = 12;
const MAX_CONTEXT_CHARS = 12_000;
const RATE_LIMIT_RETRY_SECONDS = 60;
const CHAT_PATH = "/v1/chat";
const TTS_PATH = "/v1/tts";
const MAX_TTS_CHARS = 500;

export interface ChatRateLimiter {
  limit(input: { key: string }): Promise<{ success: boolean }>;
}

export interface Env {
  GROQ_API_KEY?: string;
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

interface TtsInput {
  text: string;
  language: "en" | "es" | "fr";
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
    const requestUrl = new URL(request.url);
    const { pathname } = requestUrl;
    // Full-stack deployments derive their allowed browser origin from the request.
    if (env.ALLOWED_ORIGIN === "self") {
      env = { ...env, ALLOWED_ORIGIN: requestUrl.origin };
    }

    if (request.method === "GET" && pathname === "/health") {
      return json({ status: "ok" }, 200);
    }

    // Auth endpoints
    if (request.method === "POST" && pathname === "/v1/auth/google") {
      return handleGoogleAuth(request, env);
    }

    if (request.method === "GET" && pathname === "/v1/users/me") {
      return handleGetCurrentUser(request, env);
    }

    // Sync endpoints
    if (request.method === "POST" && pathname === "/v1/sync") {
      return handleSync(request, env);
    }

    if (request.method === "GET" && pathname === "/v1/sync") {
      return handleGetCloudData(request, env);
    }

    if (request.method === "OPTIONS" && (pathname === CHAT_PATH || pathname === TTS_PATH || pathname === "/v1/auth/google" || pathname === "/v1/sync" || pathname === "/v1/users/me")) {
      return handlePreflight(request, env);
    }

    if (request.method === "POST" && pathname === TTS_PATH) {
      return handleTts(request, env);
    }

    if (request.method !== "POST" || pathname !== CHAT_PATH) {
      return errorResponse(new HttpError(404, "not_found", "Not found"));
    }

    return handleChat(request, env);
  };
}

async function handleTts(request: Request, env: Env): Promise<Response> {
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
      ?.split(";", 1)[0]?.trim().toLowerCase();
    if (contentType !== "application/json") {
      throw new HttpError(415, "unsupported_media_type", "Content-Type must be application/json");
    }
    const input = validateTtsInput(await readJsonBody(request));
    const speech = await generateSpeech(env, input.text, input.language);
    const headers = new Headers({
      "Content-Type": speech.contentType,
      "Cache-Control": "no-store",
      "X-Content-Type-Options": "nosniff",
    });
    corsHeaders(corsOrigin).forEach((value, key) => headers.set(key, value));
    const body = speech.bytes.buffer.slice(
      speech.bytes.byteOffset,
      speech.bytes.byteOffset + speech.bytes.byteLength,
    ) as ArrayBuffer;
    return new Response(body, { status: 200, headers });
  } catch (error) {
    const httpError = mapError(error);
    logOperationalError(error);
    return errorResponse(httpError, corsOrigin);
  }
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

    const { text, truncated } = await generateReply(env, messages);
    if (text.length === 0) {
      throw new HttpError(
        502,
        "empty_model_response",
        "The assistant returned no text",
      );
    }
    return json({ text, truncated }, 200, corsOrigin);
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
  if (authorization === null) return;
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

function validateTtsInput(value: unknown): TtsInput {
  if (!isRecord(value) || Object.keys(value).some((key) => key !== "text" && key !== "locale")) {
    throw invalidRequest("Request body must contain only text and locale");
  }
  const text = requiredString(value.text, "text", MAX_TTS_CHARS);
  const locale = requiredString(value.locale, "locale", 16).toLowerCase();
  const languageCode = locale.split("-", 1)[0];
  // Never disguise an unsupported language as a different voice.
  // Portuguese is read by an actual Portuguese device voice in the frontend.
  const language = languageCode;
  if (language !== "en" && language !== "es" && language !== "fr") {
    throw invalidRequest("locale is not supported for served speech");
  }
  return { text, language };
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

// ============================================
// Auth Handlers
// ============================================

interface GoogleAuthInput {
  idToken: string;
  clientId: string;
}

async function handleGoogleAuth(request: Request, env: Env): Promise<Response> {
  const origin = request.headers.get("Origin");
  let corsOrigin: string | null = null;

  try {
    assertConfiguration(env);

    if (origin !== env.ALLOWED_ORIGIN) {
      throw new HttpError(403, "origin_not_allowed", "Origin is not allowed");
    }
    corsOrigin = origin;

    const contentType = request.headers.get("Content-Type")
      ?.split(";", 1)[0]
      ?.trim()
      .toLowerCase();
    if (contentType !== "application/json") {
      throw new HttpError(415, "unsupported_media_type", "Content-Type must be application/json");
    }

    const input = await readJsonBody(request);
    if (!isRecord(input) || typeof input.idToken !== "string" || typeof input.clientId !== "string") {
      throw new HttpError(400, "invalid_request", "Request must contain idToken and clientId");
    }

    const { idToken, clientId } = input as GoogleAuthInput;

    // Verify Google ID token
    const googleUser = await verifyGoogleIdToken(idToken, clientId);
    if (!googleUser) {
      throw new HttpError(401, "invalid_token", "Invalid Google ID token");
    }

    // Get or create user
    const user = await getOrCreateUser(env.DB, googleUser);

    // Generate app auth token
    const appAuthToken = generateAppAuthToken(user.id, env.APP_AUTH_TOKEN);

    return json(
      {
        user: {
          id: user.id,
          email: user.email,
          name: user.name,
          picture: user.picture,
          locale: user.locale,
        },
        appAuthToken,
      },
      200,
      corsOrigin
    );
  } catch (error) {
    const httpError = mapError(error);
    return errorResponse(httpError, corsOrigin);
  }
}

async function handleGetCurrentUser(request: Request, env: Env): Promise<Response> {
  const origin = request.headers.get("Origin");
  let corsOrigin: string | null = null;

  try {
    assertConfiguration(env);

    if (origin !== env.ALLOWED_ORIGIN) {
      throw new HttpError(403, "origin_not_allowed", "Origin is not allowed");
    }
    corsOrigin = origin;

    // Verify app auth token
    const authorization = request.headers.get("Authorization");
    if (!authorization) {
      throw new HttpError(401, "unauthorized", "Authorization required");
    }

    const match = authorization.match(/^Bearer ([^\s,]+)$/i);
    if (!match) {
      throw new HttpError(401, "unauthorized", "Invalid authorization format");
    }

    const tokenData = verifyAppAuthToken(match[1], env.APP_AUTH_TOKEN);
    if (!tokenData) {
      throw new HttpError(401, "unauthorized", "Invalid or expired token");
    }

    const user = await env.DB.prepare("SELECT * FROM users WHERE id = ?")
      .bind(tokenData.userId)
      .first();

    if (!user) {
      throw new HttpError(404, "not_found", "User not found");
    }

    return json(
      {
        user: {
          id: user.id,
          email: user.email,
          name: user.name,
          picture: user.picture,
          locale: user.locale,
        },
      },
      200,
      corsOrigin
    );
  } catch (error) {
    const httpError = mapError(error);
    return errorResponse(httpError, corsOrigin);
  }
}

// ============================================
// Sync Handlers
// ============================================

async function handleSync(request: Request, env: Env): Promise<Response> {
  const origin = request.headers.get("Origin");
  let corsOrigin: string | null = null;

  try {
    assertConfiguration(env);

    if (origin !== env.ALLOWED_ORIGIN) {
      throw new HttpError(403, "origin_not_allowed", "Origin is not allowed");
    }
    corsOrigin = origin;

    // Verify app auth token
    const authorization = request.headers.get("Authorization");
    if (!authorization) {
      throw new HttpError(401, "unauthorized", "Authorization required");
    }

    const match = authorization.match(/^Bearer ([^\s,]+)$/i);
    if (!match) {
      throw new HttpError(401, "unauthorized", "Invalid authorization format");
    }

    const tokenData = verifyAppAuthToken(match[1], env.APP_AUTH_TOKEN);
    if (!tokenData) {
      throw new HttpError(401, "unauthorized", "Invalid or expired token");
    }

    const user = await env.DB.prepare("SELECT * FROM users WHERE id = ?")
      .bind(tokenData.userId)
      .first();

    if (!user) {
      throw new HttpError(404, "not_found", "User not found");
    }

    const contentType = request.headers.get("Content-Type")
      ?.split(";", 1)[0]
      ?.trim()
      .toLowerCase();
    if (contentType !== "application/json") {
      throw new HttpError(415, "unsupported_media_type", "Content-Type must be application/json");
    }

    const payload = await readJsonBody(request);
    if (!isRecord(payload)) {
      throw new HttpError(400, "invalid_request", "Request body must be a JSON object");
    }

    // Validate and sync
    const syncPayload: SyncPayload = {
      userId: tokenData.userId,
      preferences: payload.preferences ? validatePreferencesSync(payload.preferences) : undefined,
      favoriteVerses: payload.favoriteVerses ? validateStringArray(payload.favoriteVerses) : undefined,
      chatSessions: payload.chatSessions ? validateChatSessionsSync(payload.chatSessions) : undefined,
      chatMessages: payload.chatMessages ? validateChatMessagesSync(payload.chatMessages) : undefined,
      dailyPlanProgress: payload.dailyPlanProgress ? validateDailyPlanProgressSync(payload.dailyPlanProgress) : undefined,
      prayers: payload.prayers ? validatePrayersSync(payload.prayers) : undefined,
      studyPlans: payload.studyPlans ? validateStudyPlansSync(payload.studyPlans) : undefined,
      studyPlanDays: payload.studyPlanDays ? validateStudyPlanDaysSync(payload.studyPlanDays) : undefined,
      seasonalProgress: payload.seasonalProgress ? validateSeasonalProgressSync(payload.seasonalProgress) : undefined,
    };

    const result = await syncUserData(env.DB, user as any, syncPayload);

    return json(
      {
        success: result.success,
        syncedAt: result.syncedAt,
        conflicts: result.conflicts,
      },
      200,
      corsOrigin
    );
  } catch (error) {
    const httpError = mapError(error);
    return errorResponse(httpError, corsOrigin);
  }
}

async function handleGetCloudData(request: Request, env: Env): Promise<Response> {
  const origin = request.headers.get("Origin");
  let corsOrigin: string | null = null;

  try {
    assertConfiguration(env);

    if (origin !== env.ALLOWED_ORIGIN) {
      throw new HttpError(403, "origin_not_allowed", "Origin is not allowed");
    }
    corsOrigin = origin;

    // Verify app auth token
    const authorization = request.headers.get("Authorization");
    if (!authorization) {
      throw new HttpError(401, "unauthorized", "Authorization required");
    }

    const match = authorization.match(/^Bearer ([^\s,]+)$/i);
    if (!match) {
      throw new HttpError(401, "unauthorized", "Invalid authorization format");
    }

    const tokenData = verifyAppAuthToken(match[1], env.APP_AUTH_TOKEN);
    if (!tokenData) {
      throw new HttpError(401, "unauthorized", "Invalid or expired token");
    }

    const user = await env.DB.prepare("SELECT * FROM users WHERE id = ?")
      .bind(tokenData.userId)
      .first();

    if (!user) {
      throw new HttpError(404, "not_found", "User not found");
    }

    const cloudData = await getUserCloudData(env.DB, tokenData.userId);

    return json(
      {
        userId: tokenData.userId,
        ...cloudData,
      },
      200,
      corsOrigin
    );
  } catch (error) {
    const httpError = mapError(error);
    return errorResponse(httpError, corsOrigin);
  }
}

// Validation helpers
function validatePreferencesSync(value: unknown): any {
  if (!isRecord(value)) throw invalidRequest("preferences must be an object");
  return {
    isDarkMode: Boolean(value.isDarkMode),
    locale: requiredString(value.locale, "locale", 16),
    textScale: Number(value.textScale) || 1,
    dailyReminderTime: requiredString(value.dailyReminderTime, "dailyReminderTime", 16),
    dailyReminderEnabled: Boolean(value.dailyReminderEnabled),
    preferredBibleVersion: requiredString(value.preferredBibleVersion, "preferredBibleVersion", 64),
    translationStyle: value.translationStyle ? String(value.translationStyle) : null,
    denomination: value.denomination ? String(value.denomination) : null,
    aiAuthToken: value.aiAuthToken ? String(value.aiAuthToken) : null,
    hasCompletedOnboarding: Boolean(value.hasCompletedOnboarding),
  };
}

function validateStringArray(value: unknown): string[] {
  if (!Array.isArray(value)) throw invalidRequest("must be an array");
  return value.filter((v): v is string => typeof v === "string");
}

function validateChatSessionsSync(value: unknown): any[] {
  if (!Array.isArray(value)) throw invalidRequest("chatSessions must be an array");
  return value.filter(isRecord).map((s) => ({
    id: requiredString(s.id, "id", 128),
    title: requiredString(s.title, "title", 256),
    createdAt: Number(s.createdAt) || 0,
    updatedAt: Number(s.updatedAt) || 0,
    isDeleted: Boolean(s.isDeleted),
  }));
}

function validateChatMessagesSync(value: unknown): any[] {
  if (!Array.isArray(value)) throw invalidRequest("chatMessages must be an array");
  return value.filter(isRecord).map((m) => ({
    id: requiredString(m.id, "id", 128),
    sessionId: requiredString(m.sessionId, "sessionId", 128),
    text: requiredString(m.text, "text", 10000),
    isUser: Boolean(m.isUser),
    verseReference: m.verseReference ? String(m.verseReference) : null,
    isError: Boolean(m.isError),
    timestamp: Number(m.timestamp) || 0,
  }));
}

function validateDailyPlanProgressSync(value: unknown): any[] {
  if (!Array.isArray(value)) throw invalidRequest("dailyPlanProgress must be an array");
  return value.filter(isRecord).map((p) => ({
    planDate: requiredString(p.planDate, "planDate", 16),
    planId: requiredString(p.planId, "planId", 128),
    completedAt: p.completedAt ? Number(p.completedAt) : null,
    streakDay: p.streakDay ? Number(p.streakDay) : null,
  }));
}

function validatePrayersSync(value: unknown): any[] {
  if (!Array.isArray(value)) throw invalidRequest("prayers must be an array");
  return value.filter(isRecord).map((p) => ({
    id: requiredString(p.id, "id", 128),
    title: p.title ? String(p.title) : null,
    content: requiredString(p.content, "content", 10000),
    category: p.category ? String(p.category) : null,
    isAnswered: Boolean(p.isAnswered),
    answeredAt: p.answeredAt ? Number(p.answeredAt) : null,
    createdAt: Number(p.createdAt) || 0,
    updatedAt: Number(p.updatedAt) || 0,
    isDeleted: Boolean(p.isDeleted),
  }));
}

function validateStudyPlansSync(value: unknown): any[] {
  if (!Array.isArray(value)) throw invalidRequest("studyPlans must be an array");
  return value.filter(isRecord).map((s) => ({
    id: requiredString(s.id, "id", 128),
    title: requiredString(s.title, "title", 256),
    description: s.description ? String(s.description) : null,
    translationId: requiredString(s.translationId, "translationId", 64),
    totalDays: Number(s.totalDays) || 0,
    completedDays: Number(s.completedDays) || 0,
    currentDay: Number(s.currentDay) || 0,
    isCompleted: Boolean(s.isCompleted),
    startedAt: Number(s.startedAt) || 0,
    completedAt: s.completedAt ? Number(s.completedAt) : null,
    updatedAt: Number(s.updatedAt) || 0,
  }));
}

function validateStudyPlanDaysSync(value: unknown): any[] {
  if (!Array.isArray(value)) throw invalidRequest("studyPlanDays must be an array");
  return value.filter(isRecord).map((d) => ({
    planId: requiredString(d.planId, "planId", 128),
    dayNumber: Number(d.dayNumber) || 0,
    title: d.title ? String(d.title) : null,
    reference: d.reference ? String(d.reference) : null,
    isCompleted: Boolean(d.isCompleted),
    completedAt: d.completedAt ? Number(d.completedAt) : null,
    notes: d.notes ? String(d.notes) : null,
  }));
}

function validateSeasonalProgressSync(value: unknown): any[] {
  if (!Array.isArray(value)) throw invalidRequest("seasonalProgress must be an array");
  return value.filter(isRecord).map((s) => ({
    seasonType: requiredString(s.seasonType, "seasonType", 16),
    year: Number(s.year) || 0,
    dayNumber: Number(s.dayNumber) || 0,
    isCompleted: Boolean(s.isCompleted),
    completedAt: s.completedAt ? Number(s.completedAt) : null,
    notes: s.notes ? String(s.notes) : null,
  }));
}

const handler = createHandler();

export default {
  fetch(request, env) {
    return handler(request, env);
  },
} satisfies ExportedHandler<Env>;
