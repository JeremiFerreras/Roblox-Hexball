# Simple Soccer Game

An original small-sided 2D football game with an **eight-player roster (4v4)**, fixed-tick server authority, client prediction, and a fully GUI-rendered pitch.

## Design direction

Simple Soccer Game is a **faithful inspiration** from the pace and readability of classic browser-based arcade football: compact top-down play, immediate movement, circular players, a responsive ball, short passing combinations, and a clean field. It is an independent implementation. The project does not distribute copied game code, artwork, player identities, or recorded match footage.

## Gameplay and architecture

- **4v4:** exactly eight player slots, four per side. Blue begins at slot five.
- **Balanced entry:** a separately tested pure roster allocator alternates arrivals while teams are tied, fills the smaller team first, and rejects a ninth player without overwriting an owner. Unowned slots are physically disabled, then reset and activated on join/leave; they cannot create invisible ball collisions.
- **Server authority:** fixed-tick simulation, player allocation, collision/rule processing, goals, score and state publication.
- **Client prediction:** local input prediction and snapshot reconciliation remain separate from match authority.
- **GUI presentation:** a 2D ScreenGui pitch with reusable circular player tokens, ball, lines, goals, posts and a compact scoreboard.
- **Loading screen:** a ReplicatedFirst screen with an original pre-authored 4v4 passing sequence. It uses eight rounded player discs and one ball, not video or a second physics simulation.

## Startup and connection

The client waits for typed RemoteEvent/UnreliableRemoteEvent instances, connects all OnClientEvent listeners before constructing the pitch GUI, and then sends the ready handshake. The server replies with a reliable bootstrap snapshot. If no valid snapshot arrives, the client repeats the request. The loading screen closes only after a valid state is accepted and the renderer successfully draws its first frame.

The loader reports the actual preparation stages: local simulation/rule/prediction modules, GUI pitch geometry, initial server snapshot and first render. Avatar thumbnails are requested only for occupied player slots and do not block the match.

## Performance policy

The decorative passing sequence updates at 20 Hz. It reuses eight circular player markers, one ball marker and pre-created pitch geometry. It does not spawn objects every frame, invoke the game physics, download 3D models, or stream video. Live match rendering reuses the same GUI tokens.

The loader does not claim a fabricated CPU percentage. It reports which local components are being prepared; performance measurements can be collected separately with Roblox profiling tools.

## Offline verification

GitHub Actions uses the pinned Luau CLI to analyze the pure geometry module, verify remote-listener order and 4v4 wire invariants, then run headless scene, GUI-adapter and network-codec tests. A second workflow reconstructs an editable Roblox Studio .rbxlx place and uploads it as a build artifact.

Local tests (Luau CLI 0.748):

    luau-analyze tests/luau/run-gui-stadium-tests.luau
    luau tests/luau/run-gui-stadium-tests.luau

Open the generated Simple-Soccer-Game-4v4.rbxlx artifact in Roblox Studio using File → Open from File.
