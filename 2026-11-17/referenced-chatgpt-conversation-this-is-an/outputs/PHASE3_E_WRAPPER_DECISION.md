# Decisión del wrapper E$

## Veredicto: PARTIAL GO

Se validó un wrapper temporal de la función `E$` realmente heredada por `gameState.copy().physicsState` en Node-HaxBall 2.3.0. Conserva `this`, argumentos, llamada única al original, retorno/excepción y descriptor restaurado. En el fixture Classic produjo 180 llamadas por escenario y capturó snapshots de discos/planos antes y después de cada transición física.

La salida física serializada de baseline e instrumentación fue byte por byte idéntica en dos ejecuciones instrumentadas; los tres hashes fueron `74e7e0f832a6e91d17765f1419199374209c5ebe7156ae26bc80355d67765ca8`. Los 540 estados y eventos ordenados coinciden para este fixture. La traza es útil para delimitar el tick en que cambia el estado; no revela las operaciones internas ni penetración/impulso. Por ello aún no es una traza interna completa del contacto ni resuelve la causa física.

En escenario 3, la envoltura muestra entrada al tick 4 con (118.804,148.505), velocidad (38.81196,48.51495), y salida (157.61596,160), velocidad Y 0; el callback accesible reporta planeId 1. Geometría y candidate plane pueden inspeccionarse en el array de planos, pero correlacionar con el ID de callback requiere instrumentar el punto exacto de callback/solver dentro de E$.

No se cambió el paquete original ni ningún archivo productivo; Studio no se usó y permanece en Edit según estado previo. No se ejecutaron A–F. Siguiente paso: instrumentación de fuente en otra copia, añadiendo solo observadores pasivos alrededor del bloque de planos y callback, y repetir prueba bytewise antes de usarla.
