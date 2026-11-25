# Fase 3 — Estudio de convergencia PGS en Luau

## Veredicto

**NO-GO para integrar PGS con TOI en esta etapa.** El núcleo converge en casos sencillos y falla explícitamente sin mutar el cuerpo, pero no es fiable en manifolds casi singulares con los presupuestos examinados. Además, no detecta incompatibilidad entre objetivos restitutivos múltiples: elimina esos objetivos al fijar a cero la restitución de todo manifold con más de una restricción.

Esto no invalida los resultados anteriores del PGS en casos ortogonales. Sí impide concluir que el prototipo satisfaga el requisito de resolver manifolds factibles y rechazar incompatibles antes de conectarlo a TOI.

## Ejecución reproducible

Se ejecutó el módulo Luau real `PHASE3_CONTACT_MANIFOLD_PGS_PROTOTYPE_20261119.luau` mediante `require`, usando el CLI oficial Luau 0.747. El ejecutable, el paquete y su procedencia están fijados en `PHASE3_MANIFOLD_LUAU_RUNTIME_DIAGNOSTIC_20261119.md`. Hash del ejecutable: `ff0acf7d2df9d38e30c85ee9fe698efd756a920496c84ea848b74d0e2082e958`.

El harness independiente [PHASE3_PGS_CONVERGENCE_SWEEP_V2_20261119.luau](PHASE3_PGS_CONVERGENCE_SWEEP_V2_20261119.luau) ejecutó **11.520 casos** y fue repetido en un segundo proceso. Las salidas completas coincidieron byte por byte; SHA-256 de ambas: `04e96f2e0ef9e549e4c91084bdd32ace74c9b943471cf2741ab908cb5e0c14f8`. `luau-analyze` terminó con código 0 y sin diagnósticos para el prototipo, el clon trazable y el harness.

El barrido incluyó ocho aperturas angulares (90°, 120°, 150°, 170°, 175°, 179°, 179,94° y 180°), tres velocidades iniciales, tres valores de restitución, de una a cuatro restricciones, dos órdenes geométricos derivados de IDs estables, cuatro presupuestos (16, 32, 64 y 128) y cinco relajaciones (0,5; 0,8; 1; 1,2; 1,5). La traza contiene en cada iteración residuo KKT, velocidades, impulsos acumulados y velocidades normales.

La salida estructurada y las trazas completas de 6.000 iteraciones seleccionadas (170°–180°, presupuestos 16–128 y cinco relajaciones) están en [PHASE3_PGS_CONVERGENCE_RESULTS_20261119.json](PHASE3_PGS_CONVERGENCE_RESULTS_20261119.json); la salida cruda íntegra está en [PHASE3_PGS_CONVERGENCE_SWEEP_RAW_V2_20261119.txt](PHASE3_PGS_CONVERGENCE_SWEEP_RAW_V2_20261119.txt). El resumen se regenera con [PHASE3_PGS_CONVERGENCE_SUMMARIZER_20261119.ps1](PHASE3_PGS_CONVERGENCE_SUMMARIZER_20261119.ps1).

## Matriz de convergencia

Fallos explícitos sobre 360 ejecuciones por cada combinación de ángulo y cantidad de restricciones (todos los estados iniciales, restituciones, órdenes, presupuestos y relajaciones):

| Separación angular | 1 restricción | 2 restricciones | 3 restricciones | 4 restricciones |
|---:|---:|---:|---:|---:|
| 90° | 0/360 | 24/360 | 51/360 | 78/360 |
| 120° | 0/360 | 48/360 | 54/360 | 48/360 |
| 150° | 0/360 | 102/360 | 42/360 | 45/360 |
| 170° | 0/360 | 258/360 | 45/360 | 60/360 |
| 175° | 0/360 | 264/360 | 48/360 | 60/360 |
| 179° | 0/360 | 294/360 | 78/360 | 87/360 |
| 179,94° | 0/360 | 294/360 | 78/360 | 93/360 |
| 180° | 0/360 | 12/360 | 30/360 | 51/360 |

En total, **9.276/11.520 convergieron y 2.244/11.520 fallaron** con `constraint-residual`. Los casos fallidos no se comprometieron al cuerpo: la velocidad de entrada se conserva. Los errores de velocidad reportados para una ejecución fallida describen el candidato no comprometido frente al oráculo, no un estado aplicado.

Efecto de aumentar el presupuesto global:

| Iteraciones | Fallos / 2.880 | Tasa de fallo |
|---:|---:|---:|
| 16 | 1.080 | 37,50 % |
| 32 | 486 | 16,88 % |
| 64 | 354 | 12,29 % |
| 128 | 324 | 11,25 % |

Aumentar el presupuesto ayuda, pero los fallos persisten incluso a 128. No es una base para elevar el límite y declarar resuelto el problema.

El promedio de fallos por relajación también depende del conjunto: ω=1 tuvo 228/2.304 fallos; ω=0,8 tuvo 279; ω=1,2 tuvo 396; ω=0,5 tuvo 666; ω=1,5 tuvo 675. Ninguna relajación elimina las regiones problemáticas. El mejor promedio observado no implica estabilidad universal.

## Caso casi opuesto y diagnóstico

Para dos normales separadas 179,94°, el producto escalar es `−0,99999945168869453`. La matriz de Gram de dos normales unitarias tiene un número de condición aproximado de **3,65 millones**. Con velocidad inicial `(20, −10)`, las restricciones inelásticas homogéneas son compatibles (la solución factible de mínima distancia es el origen), pero el PGS alterna impulsos grandes y avanza muy poco hacia esa solución.

Con ω=1 y 128 iteraciones, el residuo bajó de `0,010450035409888869` en la primera iteración a `0,010448580123202952` en la última; las velocidades candidatas pasaron de aproximadamente `(−0,0104500, −9,9790451)` a `(−0,0104486, −9,9776554)`. Sigue muy lejos del oráculo `(0,0)` y falla explícitamente. Con ω=0,8 el residuo baja de `4,00209` a `0,00870758`; con ω=1,2 de `4,01254` a `0,0130530`. Ambas siguen fallando. La traza completa por iteración está en el JSON y en el archivo crudo.

El sistema de restricciones con objetivos cero es factible. La evidencia apunta a **mala condición numérica y convergencia extremadamente lenta**, agravadas por la actualización secuencial y la relajación. No es evidencia de restricciones incompatibles en este caso. El descenso casi plano del residuo al usar ω=1 también muestra que el número de iteraciones por sí solo no describe la calidad; el residuo KKT sí detecta correctamente que aún no convergió.

El caso exactamente opuesto (180°, `dot=−1`) puede converger porque el conjunto inelástico tiene solución (velocidad normal cero). La dependencia no es monotónica respecto al ángulo: el caso casi opuesto resulta mucho peor que el singular exacto para algunos órdenes y presupuestos. Esto es coherente con mala condición, no con que “opuesto” sea siempre imposible.

## Restitución, compatibilidad y redundancia

La restitución sí se varió en todas las entradas. En una sola restricción el prototipo usa el objetivo `−e·vn` y convergió en los 2.880 casos de una restricción. En manifolds múltiples, el código establece los objetivos normales en cero con independencia del `bCoef` de restitución proporcionado. Por ello, las tres entradas `e` no representan tres respuestas restitutivas diferentes en los casos de múltiples contactos.

Una prueba real en Luau con dos normales exactamente opuestas, velocidad `(10,0)` y restitución 1 en ambos contactos devolvió `ok=true`, residuo cero, velocidad `(0,0)` e impulsos `(0,10)`. Esto demuestra que el solver no está contrastando objetivos restitutivos opuestos; está resolviendo el sistema inelástico sustituido. Si se exigiera rebote positivo en ambas direcciones, `vn₁≥10` y `vn₂≥10` con `n₂=−n₁`, el sistema sería incompatible. El prototipo actual no expone esos objetivos ni informa esa incompatibilidad. **No debe etiquetarse la ejecución anterior como detección de incompatibilidad.**

Los tests previos en Luau directo sí comprobaron duplicado exacto (deduplicación), restricción redundante colineal (impulso extra cero), normal cero, normal duplicada conflictiva, NaN/infinito, presupuesto inválido y fallo de convergencia con rollback. Coincidieron con la traducción JavaScript archivada dentro de aproximadamente `4,44e−16` en el caso numérico de una iteración. Esas pruebas previas no son el barrido factorial actual ni pruebas físicas.

## Orden y estabilidad

El prototipo ordena contactos por ID estable y después por componentes normales. Invertir el ID asociado a las normales de los extremos altera qué restricción se procesa primero; no es una permutación inerte del arreglo. En los 5.760 pares de configuración canónica/reversa, **1.302** mostraron diferencia en el residuo o error del candidato mayor que `1e−12`, y **102** cambiaron entre éxito y fallo. La diferencia máxima de residuo fue `0,120142516657`; el cambio máximo de error al oráculo fue `0,354728096006`.

La prueba anterior de determinismo al permutar el arreglo con los mismos IDs sigue pasando: la ordenación estable hace iguales las salidas. La conclusión es que el orden del algoritmo es determinista, pero con presupuesto finito la distribución de impulsos y la convergencia sí dependen de la asignación estable de IDs/superficies.

## Comparación y límites

- El PGS de referencia y el clon de trazas dieron resultados idénticos en las **2.304** corridas con ω=1 (todas las combinaciones aplicables). Las 11.520 filas se ejecutaron sobre el clon instrumentado; las filas de control compararon directamente el módulo original.
- Las pruebas Luau previas y la traducción JavaScript archivada coincidieron para normal aislada, esquina ortogonal, opuestos, duplicado, redundancia, inválidos y el fallo de una iteración dentro de redondeo IEEE-754. La diferencia máxima documentada para ese fallo fue `4,44e−16`.
- No se ejecutó el barrido factorial equivalente en JavaScript ni Node-HaxBall; no se volvió a ejecutar la referencia Node 2.3.0.
- No se ejecutó el solver dentro de TOI, no hubo micropruebas físicas ni Roblox Studio, y no se validaron pared/red, `C_v10`, gol, alta velocidad o S3 con PGS.

El oráculo matemático usado aquí es una proyección independiente sobre la intersección de semiplanos en 2D para objetivos inelásticos y una solución cerrada para una sola restricción restitutiva. Sirve para diagnosticar la solución, no reemplaza el PGS ni prueba la física de un contacto real.

## Recomendación

No integrar todavía con el clon TOI. Antes, diseñar un tratamiento explícito de objetivos restitutivos múltiples y una clasificación de compatibilidad de restricciones; distinguir sistemas factibles mal condicionados de sistemas incompatibles; mantener residuo/rollback obligatorios; y ensayar alternativas matemáticas (p. ej. resolución por conjunto activo o solución regularizada como diagnóstico independiente) contra el mismo oráculo. Después repetir la batería angular y de orden sin relajar el criterio de residuo. Solo si los casos factibles convergen dentro de un presupuesto justificado y los objetivos incompatibles se rechazan explícitamente, proceder a esquina y pared/red en TOI aislado.

## Integridad y alcance

Solo se añadieron harness, clon con trazas, resultados y documentación bajo `outputs/`. El módulo de referencia PGS no se editó durante este estudio. No se modificaron TOI original, `PhysicsCore2D`, Node-HaxBall ni la geometría; no se usó Roblox Studio para ejecutar física y no se guardó ni publicó el Place.