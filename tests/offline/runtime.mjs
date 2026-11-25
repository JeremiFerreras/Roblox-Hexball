import {createRequire} from 'node:module';
import {LuauState} from 'luau-web';
import fs from 'node:fs';
export const require=createRequire(import.meta.url);
// Pure sandbox: network constructors deliberately fail if accidentally used.
class NoNetwork {constructor(){throw new Error('Network is disabled in offline oracle')}}
export const api=require('node-haxball/src/api.js')({console,setTimeout,clearTimeout,setInterval,clearInterval,performance,crypto:require('node:crypto').webcrypto,JSON5:require('json5'),pako:require('pako'),RTCPeerConnection:NoNetwork,RTCIceCandidate:NoNetwork,RTCSessionDescription:NoNetwork,WebSocket:NoNetwork,fetch:()=>{throw Error('network disabled')},requestAnimationFrame:()=>0,cancelAnimationFrame:()=>{}},{});
export function lua(v){if(v===null||v===undefined)return 'nil';if(typeof v==='number'||typeof v==='boolean')return String(v);if(typeof v==='string')return JSON.stringify(v);if(Array.isArray(v))return '{'+v.map(lua).join(',')+'}';return '{'+Object.entries(v).map(([k,x])=>'['+lua(k)+']='+lua(x)).join(',')+'}'}
export const root=new URL('../../',import.meta.url);
export function read(p){return fs.readFileSync(new URL(p,root),'utf8')}
export function moduleSource(p){return '(function()\n'+read(p)+'\nend)()'}
export async function runLuau(code){let result;const vm=await LuauState.createAsync({emit:s=>{result=JSON.parse(s)}});const encoder=`local function json(v) local t=type(v) if t=='number' or t=='boolean' then return tostring(v) elseif t=='string' then return string.format('%q',v) elseif t=='nil' then return 'null' end local a={} for i,x in ipairs(v) do a[i]=json(x) end return '['..table.concat(a,',')..']' end\n`;try{await vm.loadstring(encoder+code,'offline',true)();return result}finally{vm.destroy()}}
export const coreSource=()=>moduleSource('src/ServerScriptService/HaxballLab/PhysicsCore2D/init.luau');
