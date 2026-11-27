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
