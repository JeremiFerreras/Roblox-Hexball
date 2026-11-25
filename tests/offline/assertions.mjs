import assert from "node:assert/strict";

export function compareFrames(expected, actual, tolerance = 1e-9) {
  assert(Array.isArray(actual), "frames must be an array");
  assert.equal(actual.length, expected.length, "missing or extra frames");
  let maxError = 0;
  let firstDivergence = null;
  for (let t = 0; t < expected.length; t++) {
    assert(Array.isArray(actual[t]), `invalid frame ${t + 1}`);
    assert.equal(
      actual[t].length,
      expected[t].length,
      `disc count at tick ${t + 1}`,
    );
    for (let d = 0; d < expected[t].length; d++) {
      assert(Array.isArray(actual[t][d]), "disc state must be an array");
      assert.equal(actual[t][d].length, 4, "disc state requires x, y, vx, vy");
      for (let k = 0; k < 4; k++) {
        const a = actual[t][d][k],
          e = expected[t][d][k];
        assert(
          Number.isFinite(a) && Number.isFinite(e),
          `nonfinite state at tick ${t + 1}`,
        );
        const error = Math.abs(a - e);
        maxError = Math.max(maxError, error);
        if (error > tolerance && firstDivergence === null)
          firstDivergence = t + 1;
      }
    }
  }
  return { maxError, firstDivergence };
}
