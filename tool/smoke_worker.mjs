const endpoint = "https://bible-path-chat.bible-path-worker.workers.dev/v1/chat";
const body = JSON.stringify({
  sessionId: "public-smoke-test",
  locale: "pt",
  translationId: "blivre",
  message: "Explique a graça de Deus em uma frase curta.",
  history: [],
  context: [],
});

try {
  const blocked = await fetch(endpoint, {
    method: "POST",
    headers: {
      Origin: "https://example.invalid",
      "Content-Type": "application/json",
    },
    body,
    signal: AbortSignal.timeout(15_000),
  });
  if (blocked.status !== 403) {
    throw new Error(`unexpected cross-origin status: ${blocked.status}`);
  }

  const response = await fetch(endpoint, {
    method: "POST",
    headers: {
      Origin: "https://bible-path.pages.dev",
      "Content-Type": "application/json",
    },
    body,
    signal: AbortSignal.timeout(45_000),
  });
  const payload = await response.json();
  const success =
    response.ok &&
    typeof payload.text === "string" &&
    payload.text.trim().length > 0;
  console.log(
    JSON.stringify({
      status: response.status,
      success,
      crossOriginBlocked: true,
      text: success ? payload.text.slice(0, 500) : undefined,
      code: payload.error?.code,
      truncated: payload.truncated,
    }),
  );
  if (!success) process.exitCode = 1;
} catch (error) {
  console.log(
    JSON.stringify({
      success: false,
      reason: "network_or_invalid_response",
      detail: error instanceof Error ? error.message : "unknown",
    }),
  );
  process.exitCode = 1;
}
