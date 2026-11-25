import fs from "node:fs";
import crypto from "node:crypto";
import { root, writeReport } from "./runtime.mjs";
const suites = {};
for (const name of [
  "regression-results.json",
  "results.json",
  "local-match-results.json",
  "server-adapter-results.json",
  "client-adapter-results.json",
  "audit-test-results.json",
  "fuzz-results.json",
  "mutation-results.json",
]) {
  const data = JSON.parse(
    fs.readFileSync(new URL(name, import.meta.url), "utf8"),
  );
  const rows = Array.isArray(data) ? data : data.cases;
  const passed = rows.filter((r) =>
    Array.isArray(r)
      ? r[1]
      : r.reference
        ? r.reference.maxError <= 1e-9 &&
          r.reference.kicks === r.oracleKicks &&
          r.reference.goalMismatches === 0
        : r.detected,
  ).length;
  if (!rows.length || passed !== rows.length)
    throw new Error("failed/incomplete suite " + name);
  suites[name] = { passed, total: rows.length };
}
const sources = {};
function visit(dir) {
  for (const file of fs.readdirSync(dir, { withFileTypes: true })) {
    const url = new URL(file.name + (file.isDirectory() ? "/" : ""), dir);
    if (file.isDirectory()) visit(url);
    else if (file.name.endsWith(".luau"))
      sources[url.href.slice(new URL("src/", root).href.length)] = crypto
        .createHash("sha256")
        .update(fs.readFileSync(url))
        .digest("hex");
  }
}
visit(new URL("src/", root));
writeReport("quality-summary.json", {
  runtime: process.version,
  oracle: "node-haxball@2.3.0",
  luau: "luau-web@1.5.1",
  scope: "offline adapters; not Roblox Studio or an independent human review",
  suites,
  sourceSha256: sources,
  lockfileSha256: crypto
    .createHash("sha256")
    .update(fs.readFileSync(new URL("package-lock.json", import.meta.url)))
    .digest("hex"),
});
console.log(
  "Quality report saved; " +
    Object.values(suites).reduce((n, s) => n + s.total, 0) +
    " successful checks across " +
    Object.keys(suites).length +
    " groups.",
);
