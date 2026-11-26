// Deliberate faults are applied in memory only, in isolated test subprocesses.
export const mutations = [
  {
    name: "goal_detection_disabled",
    path: "src/ServerScriptService/HaxballLab/MatchRules2D/init.luau",
    before: "function Rules.findGoalCrossing(motionSegments, ballId)",
    after:
      "function Rules.findGoalCrossing(motionSegments, ballId)\n if true then return nil end",
    test: "local-match.mjs",
  },
  {
    name: "score_awarded_to_wrong_team",
    path: "src/ServerScriptService/HaxballLab/MatchRules2D/init.luau",
    before: "score[goal.team] += 1",
    after: 'score[goal.team == "red" and "blue" or "red"] += 1',
    test: "local-match.mjs",
  },
  {
    name: "held_kick_gate_bypassed",
    path: "src/ServerScriptService/HaxballLab/LocalMatch2D/init.luau",
    before: "kick and not self.needsKickRelease[slot]",
    after: "kick",
    test: "local-match.mjs",
  },
  {
    name: "kickoff_never_completes",
    path: "src/ServerScriptService/HaxballLab/MatchRules2D/init.luau",
    before: "function Rules.completeKickoff(match, playerTeam)",
    after:
      "function Rules.completeKickoff(match, playerTeam)\n if true then return false end",
    test: "local-match.mjs",
  },
  {
    name: "pause_advances_physics",
    path: "src/ServerScriptService/HaxballLab/LocalMatch2D/init.luau",
    before: "if locked then\n\t\t-- A pause",
    after:
      "if locked then\n Core.stepWorld(s.coreWorld, inputs)\n\t\t-- A pause",
    test: "local-match.mjs",
  },
  {
    name: "discs_drawn_at_half_diameter",
    path: "src/ReplicatedStorage/HaxballLab/LabClient/init.server.luau",
    before: "local diameter = 2 * radius * SCALE",
    after: "local diameter = radius * SCALE",
    test: "client-adapter.mjs",
  },
  {
    name: "ball_not_rendered",
    path: "src/ReplicatedStorage/HaxballLab/LabClient/init.server.luau",
    before: "drawDisc(ballDisc, ball, latest.ball.radius or 10)",
    after: "-- deliberate missing ball update",
    test: "client-adapter.mjs",
  },
  {
    name: "unknown_round_state_accepted",
    path: "src/ReplicatedStorage/HaxballLab/NetCodec/init.luau",
    before: "if s.matchId ~= base.matchId or s.round ~= base.round then",
    after: "if false then",
    test: "client-adapter.mjs",
  },
  {
    name: "camera_crops_bounds",
    path: "src/ReplicatedStorage/HaxballLab/StadiumRender2D/init.luau",
    before:
      "return presentation.floorY + math.max(halfHeight / tangent, halfWidth / (aspect * tangent))",
    after: "return presentation.floorY + 100",
    test: "local-match.mjs",
  },
  {
    name: "contact_counter_incremented_twice",
    path: "src/ServerScriptService/HaxballLab/LabServer/init.server.luau",
    before:
      "if currentTouches[slot] and not touchingCoreBall[slot] then\n\t\t\t\t\tmetrics.ballContacts += 1",
    after:
      "if currentTouches[slot] and not touchingCoreBall[slot] then\n\t\t\t\t\tmetrics.ballContacts += 2",
    test: "server-adapter.mjs",
  },
  {
    name: "controller_disconnect_clears_other_slot",
    path: "src/ServerScriptService/HaxballLab/LabServer/init.server.luau",
    before: "currentInput = currentInputs[1] or currentInput",
    after: "currentInputs[1] = currentInput",
    test: "server-adapter.mjs",
  },
  {
    name: "kick_damping_uses_wrong_setting",
    path: "src/ServerScriptService/HaxballLab/LabServer/init.server.luau",
    before: "kickDamping = Physics2D.Config.playerKickDamping,",
    after: "kickDamping = Physics2D.Config.playerDamping,",
    test: "server-adapter.mjs",
  },
  {
    name: "input_epoch_validation_removed",
    path: "src/ReplicatedStorage/HaxballLab/NetInputQueue/init.luau",
    before: "packet.matchId ~= self.matchId or packet.round ~= self.round",
    after: "false",
    test: "network.mjs",
  },
  {
    name: "first_input_transition_skipped",
    path: "src/ReplicatedStorage/HaxballLab/NetInputQueue/init.luau",
    before: "local c = self.pending[self.ack + 1]",
    after: "local c = self.pending[self.ack + 2]",
    test: "network.mjs",
  },
  {
    name: "state_precision_silently_reduced",
    path: "src/ReplicatedStorage/HaxballLab/NetCodec/init.luau",
    before: "buffer.writef64(b, p + (i - 1) * 8, d[key])",
    after: "buffer.writef32(b, p + (i - 1) * 8, d[key])",
    test: "network.mjs",
  },
];
export function applyMutation(path, source) {
  const name = process.env.HEX_MUTATION;
  if (!name) return source;
  const mutation = mutations.find((m) => m.name === name);
  if (!mutation) throw new Error("unknown mutation: " + name);
  if (mutation.path !== path) return source;
  const count = source.split(mutation.before).length - 1;
  if (count !== 1)
    throw new Error("MUTATION_NOT_APPLIED: " + name + " matches=" + count);
  return source.replace(mutation.before, mutation.after);
}
