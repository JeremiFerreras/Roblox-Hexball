import {read,moduleSource,coreSource,runLuau} from './runtime.mjs';
import fs from 'node:fs';
import {fileURLToPath} from 'node:url';
// Dependency injection only: run unmodified module bodies in the Luau VM.
function moduleWith(p,names){let s=read(p);for(const [expr,name]of Object.entries(names))s=s.replace(expr,name);return '(function()\n'+s+'\nend)()'}
const profile=moduleSource('src/ReplicatedStorage/HaxballLab/StadiumReference2D/init.luau');
const rules=moduleWith('src/ServerScriptService/HaxballLab/MatchRules2D/init.luau',{'game:GetService("ReplicatedStorage")':'{}','require(ReplicatedStorage:WaitForChild("HaxballLab"):WaitForChild("StadiumReference2D"))':'Profile'});
const stadium=moduleWith('src/ServerScriptService/HaxballLab/ClassicStadium2D/init.luau',{'game:GetService("ReplicatedStorage")':'{}','require(ReplicatedStorage:WaitForChild("HaxballLab"):WaitForChild("StadiumReference2D"))':'Profile','require(script.Parent:WaitForChild("ClassicReference230"))':'ClassicReference230'});
const session=moduleWith('src/ServerScriptService/HaxballLab/LocalMatch2D/init.luau',{'require(script.Parent:WaitForChild("PhysicsCore2D"))':'Core','require(script.Parent:WaitForChild("MatchRules2D"))':'Rules'});
export const modules=`local Core=${coreSource()} local Profile=${profile} local Rules=${rules} local ClassicReference230=${moduleSource('src/ReplicatedStorage/HaxballLab/ClassicReference230/init.luau')} local Stadium=${stadium} local LocalMatch=${session} local StadiumRender2D=${moduleSource('src/ReplicatedStorage/HaxballLab/StadiumRender2D/init.luau')}`;
if(process.argv[1]===fileURLToPath(import.meta.url)) {
    const tests=read('tests/offline/local-match-tests.luau');
    const result=await runLuau(modules+'\n'+tests);
    fs.writeFileSync(new URL('local-match-results.json',import.meta.url),JSON.stringify(result,null,2));
    console.log(result.filter(x=>!x[1]));
    console.log(result.filter(x=>x[1]).length+'/'+result.length+' local match tests');
    if(result.some(x=>!x[1]))process.exitCode=1;
}
