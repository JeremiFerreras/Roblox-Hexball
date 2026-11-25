# Implementación wrapper temporal de E$

Se usó la instalación aislada Node 24.22.3 / `node-haxball` declarado 2.3.0 en `%TEMP%\codex-haxball-oracle-230-20261118\oracle-install`. No se editó `node_modules` ni la instalación original. Se copió el harness de telemetría `nh_oracle_instrumented.cjs` a `e-wrapper-diagnostic\nh_oracle_e_wrapper.cjs`; requiere el `node_modules` fijado por `NODE_PATH`.

## Objeto y método identificados en runtime
Ruta de construcción: `Room.sandbox(callbacks,{})` → `room.startGame(0)` → `room.gameState.copy()` → `gs.physicsState`. E$ es heredado por `physicsState` desde el segundo prototipo arriba (depth 2); propietario: objeto prototipo anónimo (`constructor.name === "Object"`). No es propiedad propia del physicsState. Descriptor: writable/enumerable/configurable true. La función original tiene nombre `E$`, aridad 2 y comienza `function(C,h){...}`. `physicsState.E$ === descriptor.value` es true.

## Wrapper
La copia conserva el descriptor original y lo reemplaza solo en el proceso. El wrapper captura `this` y argumentos; registra snapshot de entrada; invoca exactamente una vez mediante `Reflect.apply(originalE,this,args)`; registra retorno normal sin cambiarlo, o captura/re-lanza el mismo objeto de excepción; `finally` guarda snapshot de salida. Restaura descriptor después de cada escenario. No escribe propiedades en argumentos, discos o geometría.

El snapshot lee discos dinámicos en `this.F`: identidad observacional local, `B` (posición), `I` (velocidad), radio `l`, invMass `j`, bCoef `a`, y el array de planos `this.m`: `z$` (normal), `c$` (offset), `a` (bCoef). Estos nombres internos se obtuvieron inspeccionando el método minificado exacto 2.3.0. Los eventos accesibles provienen de callbacks públicos capturados por el harness y su orden queda en la salida física. El wrapper no observa la instrucción exacta de detección/resolución, penetración, impulso, contactos seleccionados, ni estados intermedios dentro de E$.

## Conteo y relación física
En escenarios Classic el wrapper observó 180 llamadas por escenario, llamadas 1..180 alineadas con frames 1..180 (una E$ por `gs.runSteps(1)` para esta configuración/harness). Entrada/salida de cada llamada delimita la transición física del tick. No demuestra qué operación interior cambió velocidad/posición.

Copia y scripts diagnósticos: `%TEMP%\codex-haxball-oracle-230-20261118\e-wrapper-diagnostic`. Salidas comparables: baseline.json, instrumented.json, instrumented2.json. Traza completa escenario 3: `PHASE3_E_WRAPPER_CALL_TRACE.json`.
