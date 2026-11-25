import {LuauState} from 'luau-web';
import {root} from './runtime.mjs';
import fs from 'node:fs';
import path from 'node:path';
import {fileURLToPath} from 'node:url';
const src=fileURLToPath(new URL('src/',root));const vm=await LuauState.createAsync({});const files=[];
function walk(dir){for(const item of fs.readdirSync(dir,{withFileTypes:true})){const p=path.join(dir,item.name);if(item.isDirectory())walk(p);else if(p.endsWith('.luau'))files.push(p)}}walk(src);
try{for(const p of files)vm.loadstring(fs.readFileSync(p,'utf8'),path.relative(src,p),true);console.log('Compiled '+files.length+' Luau scripts/modules')}finally{vm.destroy()}
