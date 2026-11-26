import { spawnSync } from "node:child_process";
import { fileURLToPath } from "node:url";
// Cross-platform invocation. Only the duplicate-retry throttle is disabled.
const child = spawnSync(
  process.execPath,
  [
    fileURLToPath(new URL("multiclient.mjs", import.meta.url)),
    "--retry-baseline",
  ],
  {
    stdio: "inherit",
    env: { ...process.env, HEX_MUTATION: "duplicate_pending_throttle_removed" },
  },
);
if (child.error) throw child.error;
process.exitCode = child.status ?? 1;
