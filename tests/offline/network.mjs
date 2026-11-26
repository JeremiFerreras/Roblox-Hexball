import { moduleBundle } from "./modules.mjs";
import { read, runLuau, writeReport } from "./runtime.mjs";
const result = await runLuau(
  moduleBundle() + read("tests/offline/network-tests.luau"),
);
writeReport("network-results.json", result);
console.log(result);
if (result.some((x) => !x[1])) process.exitCode = 1;
