import { writeReport } from "./runtime.mjs";
import { runLuau } from "./runtime.mjs";
import { moduleBundle } from "./modules.mjs";
const code =
  moduleBundle() +
  `local report=Suite.Run(P) local rows={} for _,t in ipairs(report.tests) do table.insert(rows,{t.name,t.passed,t.detail}) end emit(json(rows))`;
const rows = await runLuau(code);
writeReport("regression-results.json", rows);
console.log(rows.filter((x) => !x[1]));
console.log(rows.filter((x) => x[1]).length + "/" + rows.length);

if (rows.some((x) => !x[1])) process.exitCode = 1;
