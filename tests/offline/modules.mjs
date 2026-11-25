import fs from "node:fs";
import path from "node:path";
import { fileURLToPath } from "node:url";
import { root, read, lua } from "./runtime.mjs";

// Build a small instance/dependency tree from the actual project metadata.
// Module source is embedded unchanged; no require lines are removed or rewritten.
export function moduleBundle() {
  const base = fileURLToPath(new URL("src/", root));
  const entries = [];
  function visit(dir) {
    const file = path.join(dir, "instance.json");
    if (fs.existsSync(file)) {
      const data = JSON.parse(fs.readFileSync(file, "utf8"));
      const relative = path.relative(base, dir).split(path.sep).join("/");
      const props =
        data.fields.find((f) => f.tag === "Properties")?.children ?? [];
      const name =
        props.find((p) => p.attributes.name === "Name")?.text ??
        path.basename(dir);
      entries.push({
        relative,
        name,
        className: data.attributes.class,
        source: props.find((p) => p.sourceFile)?.sourceFile,
      });
    }
    for (const item of fs.readdirSync(dir, { withFileTypes: true }))
      if (item.isDirectory()) visit(path.join(dir, item.name));
  }
  visit(base);
  let code = `local nodes={} local factories={} local cache={} local loading={}\n`;
  code += `local function require(node) assert(node and node.ClassName=='ModuleScript','require expects a ModuleScript') if cache[node]~=nil then return cache[node] end assert(not loading[node],'cyclic module dependency: '..node.Name) assert(factories[node],'module factory missing') loading[node]=true local value=factories[node]() loading[node]=nil assert(value~=nil,'module returned nil') cache[node]=value return value end\n`;
  for (const e of entries)
    code += `nodes[${lua(e.relative)}]={Name=${lua(e.name)},ClassName=${lua(e.className)}}\n`;
  code += `local function waitForChild(self,name) local child=self[name] assert(child,'missing dependency: '..self.Name..'/'..name) return child end\n`;
  for (const e of entries) {
    const parent = path.posix.dirname(e.relative);
    code += `nodes[${lua(e.relative)}].WaitForChild=waitForChild\n`;
    if (parent !== ".")
      code += `nodes[${lua(e.relative)}].Parent=nodes[${lua(parent)}] nodes[${lua(parent)}][${lua(e.name)}]=nodes[${lua(e.relative)}]\n`;
  }
  code += `local game={GetService=function(self,name) assert(nodes[name],'unknown service '..name) return nodes[name] end}\n`;
  for (const e of entries)
    if (e.className === "ModuleScript")
      code += `factories[nodes[${lua(e.relative)}]]=function() local script=nodes[${lua(e.relative)}]\n${read("src/" + e.relative + "/" + e.source)}\nend\n`;
  for (const [name, node] of Object.entries({
    Core: "ServerScriptService/HaxballLab/PhysicsCore2D",
    Profile: "ReplicatedStorage/HaxballLab/StadiumReference2D",
    Rules: "ServerScriptService/HaxballLab/MatchRules2D",
    ClassicReference230: "ReplicatedStorage/HaxballLab/ClassicReference230",
    Stadium: "ServerScriptService/HaxballLab/ClassicStadium2D",
    LocalMatch: "ServerScriptService/HaxballLab/LocalMatch2D",
    StadiumRender2D: "ReplicatedStorage/HaxballLab/StadiumRender2D",
    P: "ServerScriptService/HaxballLab/Physics2D",
    Suite: "ServerScriptService/HaxballLab/LabRegression",
  }))
    code += `local ${name}=require(nodes[${lua(node)}])\n`;
  return code;
}
