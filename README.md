# Roblox Hexball

Proyecto extraído de `Roblox Hexball.rbxlx`. El archivo original se conserva intacto.

## Estructura editable

- `src/`: jerarquía completa del lugar, organizada por servicios y objetos.
- `init.server.luau`: código de Script.
- `init.client.luau`: código de LocalScript.
- `init.luau`: código de ModuleScript.
- `instance.json`: clase, referent, propiedades XML tipadas y orden de hijos de cada objeto.
- `src/place.json`: metadatos globales, SharedStrings y orden original.
- `docs/inventory.json`: inventario de objetos, scripts, hashes y referencias.
- `tools/place.py`: extractor, reconstructor y verificación sin dependencias; requiere Python 3.

Cada objeto tiene su propia carpeta, incluso si no contiene código. Los nombres de objetos duplicados se distinguen con sufijos; el nombre real permanece en sus propiedades. Los JSON conservan los tipos XML, atributos y valores originales, incluidos datos binarios codificados y referencias; no son archivos de modelo de Rojo.

## Reconstruir para Roblox Studio

```sh
python tools/place.py build
```

Abrir `build/Roblox-Hexball.rbxlx` en Roblox Studio. El constructor incorpora las ediciones de los archivos Luau y JSON. Para agregar objetos se debe registrar su ruta en `children` y su posición (`true`) en `layout` del padre. No cambiar `referent` sin actualizar sus referencias.

## Verificar la extracción original

```sh
python tools/place.py verify
```

Compara todos los objetos, propiedades, referencias y textos de scripts con el original, ignorando únicamente la indentación XML entre elementos. Después de modificar el juego es normal que esta comparación señale diferencias.

Para volver a extraer desde el archivo original (sobrescribe archivos coincidentes):

```sh
python tools/place.py export
```

Se han extraído 123 instancias y 12 scripts sin modificar la lógica. La comprobación es estructural; no sustituye ejecutar el juego en Roblox Studio. Los recursos externos se conservan por su ID, no se descargan.
