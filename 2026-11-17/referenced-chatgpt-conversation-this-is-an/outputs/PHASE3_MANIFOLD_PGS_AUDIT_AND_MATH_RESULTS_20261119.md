# Auditoría del PGS y pruebas matemáticas independientes

## Auditoría del código

El prototipo es un solver de restricciones normales proyectadas para un solo cuerpo dinámico contra superficies estáticas. Mantiene impulsos acumulados `lambda >= 0`, ordena por cuerpo/superficie estable, colapsa duplicados idénticos y mide residuo KKT. Los fallos no escriben la velocidad calculada de vuelta al cuerpo.

La primera auditoría detectó que el objetivo de restitución se recalculaba cada iteración: tras el primer rebote, el objetivo podía pasar a cero y cancelar el rebote. Se corrigió calculando el objetivo una sola vez desde la velocidad pre-solve. También se añadieron comprobaciones de entradas finitas, normales degeneradas, superficie duplicada con normal conflictiva y estado no finito durante las iteraciones. Contactos ortogonales y casi opuestos son restricciones separadas, no duplicados.

Un manifold de más de una restricción usa objetivo inelástico `vn >= 0`. Es una política explícita para hacer compatibles restricciones simultáneas, con pérdida potencial de energía de rebote. Los tests sintéticos confirman el cálculo del prototipo traducido, pero no justifican esa política para la geometría real.

## Alcance ejecutado y límite

Se ejecutaron nueve casos matemáticos y una permutación de orden mediante una traducción a JavaScript V8: normal aislada, esquina ortogonal, normales opuestas, duplicado exacto, restricción redundante, límite de iteraciones, NaN, normal cero y misma superficie con normales conflictivas. La secuencia de restricciones reordenada produjo el mismo resultado. Estos no son tests del archivo Luau ejecutado ni simulaciones del estadio.

| Caso | Resultado de la prueba V8 traducida |
|---|---|
| Normal aislada, `e=0.5` | Converge; `vy: 10 -> -5`, impulso 15 |
| Esquina ortogonal `(20,20)` | Converge; `(vx,vy) -> (0,0)`, impulsos 20 y 20 |
| Normales opuestas | Converge; `vx -> 0`; una restricción toma impulso 20 y la otra 0 |
| Superficie duplicada idéntica | Se colapsa a una restricción; resultado `vx=-10`, un impulso 30 |
| Restricciones redundantes con IDs distintos | Converge a `vx=0`; impulso 20 y 0, sin duplicar el cambio de velocidad |
| Iteración insuficiente, tres normales | Devuelve `constraint-residual=0.3169872981077806`; conserva el estado de entrada |
| NaN en velocidad | Rechaza como `invalid-body-state` |
| Normal nula | Rechaza como `invalid-normal-or-inverse-mass` |
| Misma superficie con normal opuesta | Rechaza como `duplicate-surface-conflicting-normal` |
| Orden de entrada invertido | Igual a la salida canónica del caso ortogonal |

El caso de iteración insuficiente demuestra el camino de fallo del modelo traducido. No demuestra que una geometría de red converja, ni que el PGS Luau compile. La prueba matemática no incluye masas múltiples, fricción, restitución de contactos nuevos dentro de un manifold, penetración ni corrección posicional.

## Integración física

No se creó el clon TOI integrado: la ruta de ejecución Luau de Studio no responde y no hay runtime Luau local detectado. Por ello siguen sin ejecutarse esquina, pared/red, `C_v10`, red, alta velocidad, S3 tick 4 y regresiones A–F/S1/S2 contra el PGS. El TOI original y `PhysicsCore2D` permanecen intactos.

## Decisión

**PARTIAL GO para el núcleo matemático traducido; NO-GO para integración o validación física.** El siguiente requisito es recuperar un ejecutor Luau verificable o disponer de un runtime Luau aislado. Después debe probarse el archivo real, guardar la traza de cada restricción/iteración y solo entonces conectarlo a un clon nuevo de TOI. Los artefactos de resultados están en `PHASE3_MANIFOLD_PGS_MATH_RESULTS_20261119.json`.
