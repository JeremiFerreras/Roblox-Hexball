import http from 'node:http';
import fs from 'node:fs/promises';
import path from 'node:path';
import crypto from 'node:crypto';
import {fileURLToPath} from 'node:url';
const ROOT=path.resolve(path.dirname(fileURLToPath(import.meta.url)));
const RESULTS=path.resolve(ROOT,'results');
const INPUT='C:/Users/User/Downloads/replay_1794954651243.hbr';
const ALLOWED=new Set(['replay_metadata.json','replay_events.jsonl','replay_physics_ticks.jsonl','replay_validation.json']);
await fs.mkdir(RESULTS,{recursive:true});
const mime={'.html':'text/html; charset=utf-8','.js':'text/javascript; charset=utf-8','.json':'application/json; charset=utf-8','.jsonl':'application/x-ndjson; charset=utf-8'};
const server=http.createServer(async(req,res)=>{
 try{
  const u=new URL(req.url,'http://127.0.0.1');
  if(req.method==='GET'&&u.pathname==='/input/replay'){
   const b=await fs.readFile(INPUT);res.writeHead(200,{'content-type':'application/octet-stream','content-length':b.length,'cache-control':'no-store','x-content-sha256':crypto.createHash('sha256').update(b).digest('hex')});return res.end(b);
  }
  if(req.method==='POST'&&u.pathname==='/save'){
   const name=u.searchParams.get('name');if(!ALLOWED.has(name)){res.writeHead(400);return res.end('name not allowed');}
   const target=path.resolve(RESULTS,name);if(path.dirname(target)!==RESULTS){res.writeHead(400);return res.end('invalid path');}
   const chunks=[];let size=0;for await(const chunk of req){size+=chunk.length;if(size>150000000){res.writeHead(413);return res.end('too large');}chunks.push(chunk);}
   const body=Buffer.concat(chunks);await fs.writeFile(target,body);res.writeHead(200,{'content-type':'application/json'});return res.end(JSON.stringify({ok:true,name,bytes:body.length,sha256:crypto.createHash('sha256').update(body).digest('hex')}));
  }
  if(req.method!=='GET'&&req.method!=='HEAD'){res.writeHead(405);return res.end('method not allowed');}
  let decoded;try{decoded=decodeURIComponent(u.pathname);}catch{res.writeHead(400);return res.end('bad url encoding');}
  const relative=(decoded==='/'||decoded==='/**')?'index.html':(decoded.startsWith('/')?decoded.slice(1):decoded);
  const target=path.resolve(ROOT,relative);
  const rel=path.relative(ROOT,target);
  if(!rel||rel==='.'||rel==='..'||rel.startsWith('..'+path.sep)||path.isAbsolute(rel)){res.writeHead(403);return res.end('forbidden');}
  let body;try{body=await fs.readFile(target);}catch(e){res.writeHead(e.code==='ENOENT'?404:500);return res.end(e.code==='ENOENT'?'not found':String(e));}
  res.writeHead(200,{'content-type':mime[path.extname(target)]||'application/octet-stream','content-length':body.length,'cache-control':'no-store'});return res.end(req.method==='HEAD'?undefined:body);
 }catch(e){res.writeHead(500);res.end(String(e.stack||e));}
});
server.listen(43127,'127.0.0.1',()=>console.log('http://127.0.0.1:43127/ bound to 127.0.0.1'));