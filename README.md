# Roblox Hexball

Proyecto extraído directamente de `hexballactual.rbxl`, el archivo binario original de Roblox Studio.

## Archivos

- `hexballactual.rbxl`: archivo original, conservado sin modificaciones.
- `Roblox Hexball.rbxlx`: conversión XML del mismo place.
- `src/`: jerarquía extraída, con un `instance.json` por instancia y archivos Luau separados.
- `docs/inventory.json`: inventario de instancias, clases, scripts y referents.
- `tools/place.py`: exportación, reconstrucción y verificación de la estructura.
- `tools/rbxl-convert/`: conversor de RBXL binario a RBXLX usando rbx-dom.

## Reconstruir el XML después de editar

```sh
python tools/place.py build
```

El resultado se genera en `build/Roblox-Hexball.rbxlx`.

## Volver a extraer desde el archivo binario original

```sh
cargo run --release --manifest-path tools/rbxl-convert/Cargo.toml -- hexballactual.rbxl build/Roblox-Hexball.rbxlx
python tools/place.py export build/Roblox-Hexball.rbxlx
```

Los recursos externos se mantienen por sus referencias/IDs; no se descargan automáticamente.

## GUI 2D renderer (headless-first)

The match engine, stadium collision profile, rules, prediction and networking remain independent of presentation. The GUI path is built from:

- `GuiStadiumScene`: pure Luau geometry, stripe clipping and world/screen transforms.
- `GuiStadiumRenderer`: ScreenGui/Frame-based presentation. It hides the old Workspace BaseParts locally and draws the same 2D state without a camera or physical visual Parts.
- `tests/luau/run-gui-stadium-tests.luau`: headless logic tests with a fake UI adapter. These run in GitHub Actions using the pinned Luau CLI; no Roblox Studio runtime is needed.

The initial GUI view follows the local player's interpolated position. Physical coordinates remain in Classic stadium units. The kickoff circle uses the profile's 75-unit radius; no rendering value is fed back into collision code.

Run locally with Luau CLI 0.748:

```sh
luau-analyze src/ReplicatedStorage/HaxballLab/GuiStadiumScene/init.luau tests/luau/run-gui-stadium-tests.luau
luau tests/luau/run-gui-stadium-tests.luau
```


Player presentation uses the Roblox headshot thumbnail URI for occupied player slots (ownerUserId supplied by the server). Empty reserved physics slots are hidden; explicit pair/crowd regression actors remain visible. Thumbnail retrieval is client-resolved by Roblox and never participates in simulation or networking.
