import assert from "node:assert/strict";
import { compareFrames } from "./assertions.mjs";
import { runLuau, writeReport } from "./runtime.mjs";
import { moduleBundle } from "./modules.mjs";
const results = [];
function test(name, fn) {
  try {
    fn();
    results.push([name, true, "PASS"]);
  } catch (e) {
    results.push([name, false, e.message]);
  }
}
const expected = [[[0, 0, 0, 0]], [[1, 0, 1, 0]]];
test("comparator_rejects_missing_frames", () =>
  assert.throws(() => compareFrames(expected, [expected[0]])));
test("comparator_rejects_missing_discs", () =>
  assert.throws(() => compareFrames(expected, [[], expected[1]])));
test("comparator_rejects_missing_components", () =>
  assert.throws(() => compareFrames(expected, [[[0, 0]], expected[1]])));
test("comparator_rejects_nonfinite_numbers", () =>
  assert.throws(() =>
    compareFrames(expected, [[[NaN, 0, 0, 0]], expected[1]]),
  ));
test("comparator_identifies_first_divergent_tick", () =>
  assert.equal(
    compareFrames(expected, [[[0, 0, 0, 0]], [[2, 0, 1, 0]]]).firstDivergence,
    2,
  ));
for (const [name, code] of [
  ["serializer_rejects_dictionary", `emit(json({passed=true}))`],
  ["serializer_rejects_sparse_array", `emit(json({[1]=1,[3]=3}))`],
  ["serializer_rejects_nan", `emit(json({0/0}))`],
  ["runner_requires_emitted_results", `return true`],
  ["runner_rejects_duplicate_results", `emit('[]') emit('[]')`],
]) {
  try {
    await assert.rejects(() => runLuau(code));
    results.push([name, true, "PASS"]);
  } catch (e) {
    results.push([name, false, e.message]);
  }
}
assert.deepEqual(await runLuau(`emit(json({'line\\nquote"tab\\tend'}))`), [
  'line\nquote"tab\tend',
]);
assert.deepEqual(
  await runLuau(
    moduleBundle() +
      `emit(json({P.MatchCore==Core,require(nodes['ServerScriptService/HaxballLab/ClassicReference230'])==ClassicReference230,require(nodes['ServerScriptService/HaxballLab/PhysicsCore2D'])==Core}))`,
  ),
  [true, true, true],
);
results.push([
  "production_module_dependencies_and_cache_resolve",
  true,
  "PASS",
]);
writeReport("audit-test-results.json", results);
console.log(results);
if (results.some((x) => !x[1])) process.exitCode = 1;
