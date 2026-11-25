import { writeReport } from "./runtime.mjs";
import { read, runLuau } from "./runtime.mjs";
import { fileURLToPath } from "node:url";
import { moduleBundle } from "./modules.mjs";
export const modules = moduleBundle();
if (process.argv[1] === fileURLToPath(import.meta.url)) {
  const tests = read("tests/offline/local-match-tests.luau");
  const result = await runLuau(modules + "\n" + tests);
  writeReport("local-match-results.json", result);
  console.log(result.filter((x) => !x[1]));
  console.log(
    result.filter((x) => x[1]).length +
      "/" +
      result.length +
      " local match tests",
  );
  if (result.some((x) => !x[1])) process.exitCode = 1;
}
