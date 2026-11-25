# Comparación de PGS: Luau real vs resultados JavaScript archivados

## Ejecución real

El ejecutable Luau 0.747 cargó directamente `PHASE3_CONTACT_MANIFOLD_PGS_PROTOTYPE_20261119.luau` con `require`; el runner no contiene otra implementación del solver ni stubs de Roblox. El prototipo solo usa tablas, aritmética y funciones estándar de Luau (`typeof`, `table.clone`, `table.create`).

Se ejecutaron 14 verificaciones: normal aislada, esquina ortogonal, normales opuestas y casi opuestas, duplicado, redundancia, no convergencia, entradas inválidas (NaN, infinito, normal cero, normal duplicada conflictiva y target no finito), validación del límite de iteraciones y orden de entrada invertido. Los casos de no convergencia devolvieron fallo explícito y dejaron el cuerpo intacto. `luau-analyze.exe` revisó prototipo y runner con salida vacía y código 0.

Dos corridas completas devolvieron exactamente la misma salida. SHA-256 de ambas salidas: `753752cf45b5a6a2c446d7b6e965c0ee42c04ec081181149e7133e1538eaf109`.

## Comparación numérica

Las salidas de normal aislada, esquina ortogonal, normales opuestas, duplicado exacto, redundancia y estados inválidos coinciden con los resultados JavaScript archivados en `PHASE3_MANIFOLD_PGS_MATH_RESULTS_20261119.json`. La distribución de impulsos también coincide: en normales opuestas `net=0, outer=20`; en redundancia colineal `a=20, b=0`.

En el caso de no convergencia, JavaScript dio residuo `0.3169872981077806`, velocidades candidatas `(0.3169872981077807,-0.1830127018922192)` e impulso `1.3660254037844386`. Luau dio `0.3169872981077809`, `(0.3169872981077805,-0.18301270189221963)` e impulso `1.3660254037844388`. La diferencia máxima observada es `4.44e-16`, compatible con redondeo IEEE-754 y orden de operaciones. Ambos runtimes marcan `constraint-residual`; Luau conserva la velocidad inicial `(1,1)` porque no converge.

La prueba inicial del runner terminó con exit code 1 en la línea de impresión del test de determinismo, después de que los casos anteriores ya hubieran producido resultados: el colector asumía que esa fila también contenía `item.body`. Se corrigió el colector y se repitieron las corridas con exit code 0. La salida inicial también reveló un defecto del prototipo: el patrón Lua `ok and nil or reason` siempre asignaba el motivo de fallo. Se cambió a `(not ok) and reason or nil`; los resultados exitosos ahora retornan `reason=nil`. Esos dos defectos y sus correcciones quedan rastreados en el runner y el código Luau actuales.

## Decisión

El núcleo PGS queda **validado matemáticamente en Luau standalone 0.747**, con los límites de alcance declarados. Esto valida el módulo en runtime Luau, no su integración temporal, su comportamiento geométrico, la física de Roblox ni equivalencia con Node-HaxBall. Siguiente paso: conectarlo mediante una capa adaptadora a una copia del TOI y ejecutar primero esquina y pared/red. Mantener el tiempo restante intacto si el manifold no converge.
