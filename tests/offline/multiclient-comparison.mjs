import fs from "node:fs";
import { writeReport } from "./runtime.mjs";
const before = JSON.parse(
  fs.readFileSync(
    new URL("multiclient-baseline-results.json", import.meta.url),
  ),
);
const after = JSON.parse(
  fs.readFileSync(new URL("multiclient-results.json", import.meta.url)),
);
if ([...before, ...after].some((row) => !row[1]))
  throw new Error("Comparison contains failed checks");
const scenarios = [...new Set(after.map((row) => row[0].split("/")[0]))];
const cases = scenarios.map((name) => {
  const summarize = (rows) => {
    const clients = rows
      .filter((row) => row[0].startsWith(name + "/client_"))
      .map((row) => row[2]);
    if (clients.length !== 10)
      throw new Error("Missing client results: " + name);
    return {
      inputPayloadBytes: clients.reduce(
        (n, r) => n + r[r.indexOf("input/state raw bytes") + 1],
        0,
      ),
      maximumClientAckP95Ms: Math.max(
        ...clients.map((r) => r[r.indexOf("ack p50/p95/max ms") + 2]),
      ),
    };
  };
  const a = summarize(before),
    b = summarize(after);
  return {
    name,
    before: a,
    after: b,
    inputPayloadSavingPct:
      100 * (1 - b.inputPayloadBytes / a.inputPayloadBytes),
  };
});
const report = {
  scope:
    "16 simulated seconds per scenario, 10 actual client scripts and 1 actual server through adapters; not native Roblox",
  baseline:
    "same source with only duplicate_pending_throttle_removed mutation; identical configuration and PRNG seeds, packet-dependent random draws can differ",
  interpretation:
    "payload savings exclude headers, full snapshot table size, compression and fanout; ACK percentiles include local queues and server confirmation, not just ping",
  cases,
};
writeReport("multiclient-comparison.json", report);
console.log(report);
