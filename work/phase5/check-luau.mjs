// Execute from the repository root after: npm ci --prefix tests/offline
// This runner loads the proposed Luau sources unchanged into the pinned existing runtime.
import { read, moduleSource, runLuau, writeReport } from "../../tests/offline/runtime.mjs";
const result = await runLuau(
  "local SnapshotBuffer=" + moduleSource("work/phase5/SnapshotBuffer.luau") +
  "\nlocal NetMetrics=" + moduleSource("work/phase5/NetMetrics.luau") +
  "\n" + read("work/phase5/presentation-tests.luau"),
);
writeReport("phase5-prototype-luau-results.json", result);
console.log(result);
if (result.some((row) => !row[1])) process.exitCode = 1;
