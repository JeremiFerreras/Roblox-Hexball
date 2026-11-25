# Runtime Luau — diagnóstico e procedencia

## Resultado

No había `luau`, `lune`, `lute`, Lua ni Luau en PATH ni en el directorio del proyecto. Tampoco se encontró CMake, Ninja o Visual Studio para compilar. Se descargó el CLI oficial de `luau-lang/luau` en una carpeta temporal aislada, sin cambiar PATH o instalación global.

- Release/tag: `0.747`
- Commit fijado: `c87565b8b0db5d5d5bfd2b8b00ad6573e5d06d9f`
- Asset: `luau-windows.zip`, 3,271,719 bytes
- SHA-256 anunciado por el endpoint oficial de GitHub Releases: `16bbd26575e9a6a3ecd2bd5fc772a81f3232520b56a40a86f2b47fec576d7cc7`
- SHA-256 calculado después de descargar: el mismo valor
- Ejecutable: `%TEMP%\codex-luau-0.747-phase3\bin\luau.exe`
- SHA-256 del ejecutable `luau.exe`: `ff0acf7d2df9d38e30c85ee9fe698efd756a920496c84ea848b74d0e2082e958`
- Ejecutables adicionales del mismo paquete: `luau-analyze.exe`, `luau-compile.exe`, `luau-ast.exe`.

El CLI no reconoce `--version`; se verificó la versión mediante el tag/commit inmutable del release y el hash del asset oficial, luego se comprobó que el ejecutable acepta y ejecuta programas Luau. El archivo original se conserva en `%TEMP%` para uso diagnóstico local.

## Diagnóstico MCP

La instancia correcta y las lecturas MCP siguen disponibles en Edit; `search_game_tree` responde. `ExecuteLuau` había fallado con `Target is not reachable` y sin `OnInvoke`. No se repitió esa llamada. La ejecución de este informe se hizo fuera de Studio mediante el CLI local; no hay prueba física de Roblox asociada.

## Fuente de procedencia

El tag 0.747, commit y release son del [repositorio oficial de Luau](https://github.com/luau-lang/luau/releases/tag/0.747). La documentación oficial describe los binarios de release y el modo CLI en el [README del repositorio](https://github.com/luau-lang/luau#building). El digest comparado procede de `https://api.github.com/repos/luau-lang/luau/releases/tags/0.747` y corresponde al asset `luau-windows.zip`.
