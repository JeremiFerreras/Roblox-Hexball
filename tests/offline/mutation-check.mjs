import { spawnSync } from "node:child_process";
import fs from "node:fs";
import path from "node:path";
import { fileURLToPath } from "node:url";
import { mutations } from "./mutations.mjs";
import { root, writeReport } from "./runtime.mjs";
const cwd = fileURLToPath(new URL("./", import.meta.url));
const output = fileURLToPath(new URL("build/audit-mutations/", root));
const reports = {
  "local-match.mjs": "local-match-results.json",
  "client-adapter.mjs": "client-adapter-results.json",
  "server-adapter.mjs": "server-adapter-results.json",
};
const results = [];
for (const mutation of mutations) {
  const dir = path.join(output, mutation.name);
  fs.rmSync(dir, { recursive: true, force: true });
  fs.mkdirSync(dir, { recursive: true });
  const child = spawnSync(process.execPath, [mutation.test], {
    cwd,
    encoding: "utf8",
    timeout: 90000,
    env: { ...process.env, HEX_MUTATION: mutation.name, HEX_REPORT_DIR: dir },
  });
  fs.writeFileSync(
    path.join(dir, "output.log"),
    (child.stdout ?? "") + (child.stderr ?? ""),
  );
  let failed = [];
  try {
    failed = JSON.parse(
      fs.readFileSync(path.join(dir, reports[mutation.test]), "utf8"),
    )
      .filter((row) => row[1] === false)
      .map((row) => row[0]);
  } catch {}
  const detected = child.status !== 0 && failed.length > 0 && !child.error;
  results.push({
    name: mutation.name,
    detected,
    failedTests: failed,
    exitCode: child.status,
  });
  console.log(mutation.name + ": " + (detected ? "DETECTED" : "NOT PROVEN"));
}
writeReport("mutation-results.json", results);
if (results.some((r) => !r.detected)) process.exitCode = 1;
