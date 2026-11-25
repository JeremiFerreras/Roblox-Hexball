# Física fuera de Roblox Studio

Requiere Node.js 22+ y Python 3 para reconstruir el lugar. Versiones probadas: Node 24.22.3, luau-web 1.5.1 (Luau en WASM), node-haxball 2.3.0. El código Luau del proyecto se compila y ejecuta directamente; no se traduce su física a JavaScript.

```sh
cd tests/offline
npm ci --ignore-scripts --no-audit --no-fund
npm test
```

Los scripts no abren salas ni conexiones de red. Importan el API del paquete directamente, sin cargar WebRTC nativo; los constructores de red fallan si se usan. La instalación sí necesita descargar las dependencias.

- `regression.mjs`: ejecuta las 47 pruebas existentes, sustituyendo únicamente el enlace de módulos de Roblox por módulos locales. No emula Heartbeat, render ni RemoteEvents.
- `compare.mjs`: ejecuta el Core Luau contra el sandbox Node fijado; devuelve código de error ante divergencias >1e-9, kicks diferentes o cruces de gol diferentes.
- `reference.mjs --export`: genera los datos numéricos del Classic integrado de Node 2.3.0. El modo discreto usa este perfil mediante el instalador real ClassicStadium2D.
- `results.json` y `regression-results.json`: resultados ejecutados; npm test los regenera.

75 escenarios, 22.870 ticks por motor: movimiento horizontal/diagonal, frenado/inversión, movimiento con X, contacto oblicuo, patadas y límite espacial, planos a varias velocidades, 24 impactos parametrizados, tres velocidades Classic históricas y 32 simulaciones Classic 5v5 de 600 ticks. Las trazas completas se comparan en memoria, no se almacenan en el repositorio. También se comparan las cuatro componentes por disco, número total de kicks y gol/no gol por tick en Classic.

Los escenarios Classic fuerzan el estado `playing` cada tick para aislar física y cruce de goles: NO validan la duración de pausas, resets ni transición completa del partido. El runner usa el campo interno `c` de la versión fijada para ello. Los inputs son digitales. No certifica analogía de mandos, tasas configurables de patada, mapas con joints, recursos, presentación, temporización real ni red.

La referencia es Node-Haxball, una implementación independiente; no es una captura del cliente oficial. El modo discreto prioriza reproducir su secuencia, incluidas sus limitaciones de detección a alta velocidad. No promete las garantías antitúnel del modo adaptativo.

## Partido local (fase 4)

`npm test` también ejecuta `local-match.mjs` (19 pruebas del controlador y geometría), `server-adapter.mjs` (4 comprobaciones del servidor real con servicios simulados) y compila todos los scripts con `compile.mjs`. Los resultados están en `local-match-results.json` y `server-adapter-results.json`. Ver `docs/PHASE4_LOCAL_MATCH_2026-11-25.md`. El módulo numérico compartido vive en ReplicatedStorage; el generador de referencia actualiza esa copia.

## Cierre funcional

`client-adapter.mjs` ejecuta cliente y servidor reales juntos con vectores, propiedades, reloj y señales locales: no renderiza ni emula Roblox completo. La suite incluye 20 pruebas locales, 7 del servidor y 10 del cliente, además de las regresiones físicas. La prueba larga compara estados y eventos por tick. Ver `docs/PHASE4_CLOSURE_2026-11-25.md`.
