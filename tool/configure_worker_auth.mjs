// Reuse the existing app token; never print secret values or write temporary secrets.
import { readFileSync } from "node:fs";
import { spawnSync } from "node:child_process";
import { fileURLToPath } from "node:url";
let token;
for (const name of [".dev.vars.local", ".dev.vars"]) {
  try {
    const source = readFileSync(new URL("../worker/" + name, import.meta.url), "utf8");
    const match = source.match(/^\s*APP_AUTH_TOKEN\s*=\s*(.+)$/m);
    if (match) { token = match[1].trim().replace(/^["']|["']$/g, ""); break; }
  } catch {}
}
if (!token || token.length < 32) {
  console.log("Existing app token unavailable or invalid"); process.exit(1);
}
const worker = fileURLToPath(new URL("../worker/", import.meta.url));
const cli = fileURLToPath(new URL("../worker/node_modules/wrangler/bin/wrangler.js", import.meta.url));
const result = spawnSync(process.execPath, [cli, "secret", "bulk", "--config", "wrangler.toml"], {
  cwd: worker, input: JSON.stringify({ APP_AUTH_TOKEN: token }), encoding: "utf8",
  timeout: 60000, windowsHide: true,
});
console.log(JSON.stringify({ appAuthSecretConfigured: result.status === 0 }));
process.exitCode = result.status === 0 ? 0 : 1;
