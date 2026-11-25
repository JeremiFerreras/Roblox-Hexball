import { createRequire } from "node:module";
import assert from "node:assert/strict";
const require = createRequire(import.meta.url);
assert.equal(
  require("node-haxball/package.json").version,
  "2.3.0",
  "oracle version must stay pinned",
);
// Pure sandbox: network constructors deliberately fail if accidentally used.
class NoNetwork {
  constructor() {
    throw new Error("Network is disabled in offline oracle");
  }
}
export const api = require("node-haxball/src/api.js")(
  {
    console,
    setTimeout,
    clearTimeout,
    setInterval,
    clearInterval,
    performance,
    crypto: require("node:crypto").webcrypto,
    JSON5: require("json5"),
    pako: require("pako"),
    RTCPeerConnection: NoNetwork,
    RTCIceCandidate: NoNetwork,
    RTCSessionDescription: NoNetwork,
    WebSocket: NoNetwork,
    fetch: () => {
      throw Error("network disabled");
    },
    requestAnimationFrame: () => 0,
    cancelAnimationFrame: () => {},
  },
  {},
);
