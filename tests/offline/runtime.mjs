import { LuauState } from "luau-web";
import fs from "node:fs";
import path from "node:path";
import assert from "node:assert/strict";
import { applyMutation } from "./mutations.mjs";
export function lua(v) {
  if (v === null || v === undefined) return "nil";
  if (typeof v === "number" || typeof v === "boolean") return String(v);
  if (typeof v === "string") return JSON.stringify(v);
  if (Array.isArray(v)) return "{" + v.map(lua).join(",") + "}";
  return (
    "{" +
    Object.entries(v)
      .map(([k, x]) => "[" + lua(k) + "]=" + lua(x))
      .join(",") +
    "}"
  );
}
export const root = new URL("../../", import.meta.url);
export function read(p) {
  return applyMutation(p, fs.readFileSync(new URL(p, root), "utf8"));
}
export function moduleSource(p) {
  return "(function()\n" + read(p) + "\nend)()";
}
export async function runLuau(code) {
  let result;
  let emits = 0;
  const vm = await LuauState.createAsync({
    emit: (s) => {
      assert.equal(++emits, 1, "test emitted more than one result");
      result = JSON.parse(s);
    },
  });
  const encoder = read("tests/offline/json-array.luau");
  try {
    await vm.loadstring(encoder + code, "offline", true)();
    assert.equal(emits, 1, "test did not emit results");
    return result;
  } finally {
    vm.destroy();
  }
}
export const coreSource = () =>
  moduleSource("src/ServerScriptService/HaxballLab/PhysicsCore2D/init.luau");

export function writeReport(name, value) {
  const directory = process.env.HEX_REPORT_DIR;
  const target = directory
    ? path.join(directory, path.basename(name))
    : new URL(name, import.meta.url);
  if (directory) fs.mkdirSync(directory, { recursive: true });
  fs.writeFileSync(target, JSON.stringify(value, null, 2) + "\n");
}
