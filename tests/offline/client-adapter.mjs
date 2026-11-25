import {serverSetup} from './server-adapter.mjs';
import {read,moduleSource,runLuau} from './runtime.mjs';
import fs from 'node:fs';
const setup=read('tests/offline/client-adapter-setup.luau');
const tests=read('tests/offline/client-adapter-tests.luau');
const result=await runLuau(serverSetup+`\nlocal Prediction=${moduleSource('src/ReplicatedStorage/HaxballLab/PredictionLab2D/init.luau')}\n`+setup+`\n(function() ${read('src/ReplicatedStorage/HaxballLab/LabClient/init.server.luau')} end)()\n`+tests);
fs.writeFileSync(new URL('client-adapter-results.json',import.meta.url),JSON.stringify(result,null,2));console.log(result);if(result.some(x=>!x[1]))process.exitCode=1;
