import { moduleBundle } from "./modules.mjs";
import { read, runLuau, writeReport } from "./runtime.mjs";
const result = await runLuau(moduleBundle() + read("tests/offline/presentation-tests.luau"));
writeReport("presentation-results.json", result);
console.log(result);
if (result.some((row) => !row[1])) process.exitCode = 1;
