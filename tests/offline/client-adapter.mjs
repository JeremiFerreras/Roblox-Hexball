import { writeReport } from "./runtime.mjs";
import { serverSetup } from "./server-adapter.mjs";
import { read, moduleSource, runLuau } from "./runtime.mjs";
const setup = read("tests/offline/client-adapter-setup.luau");
const tests = read("tests/offline/client-adapter-tests.luau");
const result = await runLuau(
  serverSetup +
    `\nlocal Prediction=${moduleSource("src/ReplicatedStorage/HaxballLab/PredictionLab2D/init.luau")}\n` +
    setup +
    `\n(function() ${read("src/ReplicatedStorage/HaxballLab/LabClient/init.server.luau")} end)()\n` +
    tests,
);
writeReport("client-adapter-results.json", result);
console.log(result);
if (result.some((x) => !x[1])) process.exitCode = 1;
