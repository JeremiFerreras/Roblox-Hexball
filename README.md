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
- **Main menu:** a soft pitch-green title panel with the Jugar button and, beside it, a live showcase of bot plays.
- **Team selection:** Jugar slides into a page with Rojo and Azul cards showing how many of the four places are taken. The server honours the chosen side and rejects it when full.
- **Showcase:** six moves (tiki-taka, one-two, build-up goal, wall self-pass, wing cross and counterattack). `ShowcasePlays` only describes intentions (who passes where, off-ball runs, defender behaviour); `MenuPreview` turns them into movement and kick inputs and simulates them with the same `PhysicsCore2D` module, 60 Hz tick rate, player/ball parameters, collision groups and Classic stadium geometry used by the server. Only rendering is interpolated between physics ticks.
- **Editing plays:** the parameters of each play are tuned together. After changing them, or the physics, run the tests: each play must end in a goal without an unplanned touch.
- **Loading screen:** a short ReplicatedFirst loader in the menu palette that closes as soon as the menu is ready.

## Startup and connection

The client waits for typed RemoteEvent/UnreliableRemoteEvent instances, connects all OnClientEvent listeners, builds the main menu and its locally simulated showcase, then reports the menu as ready. A player does not consume one of the eight match slots while browsing the menu. Picking a team sends a join request; the server allocates a slot on that side only then and sends a reliable bootstrap snapshot. The live stadium and HUD are enabled after ownership is confirmed.

The loader reports the actual preparation stages: local simulation/rule/prediction modules, GUI pitch geometry, initial server snapshot and first render. Avatar thumbnails are requested only for occupied player slots and do not block the match.

## Performance policy

Each showcase play is simulated once, cached and sampled on every rendered frame (`RenderStepped`); the following play is prepared ahead of time. It reuses eight circular player markers, one ball marker, a fixed pool of trail dots and pre-created pitch geometry. It does not download 3D models or stream video, and it stops updating while the team page covers it. Live match rendering reuses the same GUI tokens.

In match, the static pitch (grass, stripes, lines, posts) lives in a single `World` container: following the camera moves one Frame instead of re-laying out dozens of them every frame, and geometry is only rebuilt when the zoom changes. HUD and token properties are written only when their value changes, the diagnostics text is built only when diagnostics are enabled, and the client turns the 3D renderer off (`RunService:Set3dRenderingEnabled(false)`) because the GUI pitch covers the whole screen.

The camera follows the player's disc (the ball for spectators) with a short frame-rate-independent ease, and is clamped to the 840x400 stadium bounds so it never shows empty space beyond the walls. The server drops its catch-up backlog after eight consecutive ticks instead of carrying it forever.

Diagnostics are opt-in through the `EnableSimpleSoccerDiagnostics` attribute on `ReplicatedStorage.SimpleSoccerGame`.

The loader does not claim a fabricated CPU percentage. It reports which local components are being prepared; performance measurements can be collected separately with Roblox profiling tools.

## Offline verification

GitHub Actions uses the pinned Luau CLI to analyze the pure geometry module, verify remote-listener order and 4v4 wire invariants, then run headless scene, GUI-adapter and network-codec tests. A second workflow reconstructs an editable Roblox Studio .rbxlx place and uploads it as a build artifact.

Local tests (Luau CLI 0.748):

    luau-analyze tests/luau/run-gui-stadium-tests.luau
    luau tests/luau/run-gui-stadium-tests.luau

Open the generated Simple-Soccer-Game-4v4.rbxlx artifact in Roblox Studio using File → Open from File.
