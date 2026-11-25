# Roblox Hexball

Proyecto extraído de `Roblox Hexball.rbxlx`. La versión previa a los cambios físicos está conservada en `archive/Roblox-Hexball-before-physics.rbxlx`.

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

El proyecto actual contiene 127 instancias y 16 scripts/módulos. La validación y los cambios físicos están documentados en `docs/PHYSICS_OFFLINE_2026-11-25.md`. La comprobación es estructural; no sustituye ejecutar el juego en Roblox Studio. Los recursos externos se conservan por su ID, no se descargan.

## Pruebas físicas fuera de Studio

Ver [instrucciones](tests/offline/README.md) e [informe de validación](docs/PHYSICS_OFFLINE_2026-11-25.md).

## Partido local

La fase 4 incorpora un controlador de partido, pruebas de goles y saques y geometría visual compartida. [Informe y comprobaciones pendientes](docs/PHASE4_LOCAL_MATCH_2026-11-25.md).

[Estado de cierre funcional de fase 4](docs/PHASE4_CLOSURE_2026-11-25.md): aprobado en el entorno offline, pendiente de aceptación nativa en Studio.
