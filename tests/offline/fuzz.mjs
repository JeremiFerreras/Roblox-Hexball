import { moduleBundle } from "./modules.mjs";
import { read, runLuau, writeReport } from "./runtime.mjs";
const result = await runLuau(
  moduleBundle() + read("tests/offline/fuzz-tests.luau"),
);
writeReport("fuzz-results.json", result);
console.log(result.filter((r) => !r[1]));
console.log(
  result.filter((r) => r[1]).length +
    "/" +
    result.length +
    " seeded randomized matches",
);
if (result.some((r) => !r[1])) process.exitCode = 1;
