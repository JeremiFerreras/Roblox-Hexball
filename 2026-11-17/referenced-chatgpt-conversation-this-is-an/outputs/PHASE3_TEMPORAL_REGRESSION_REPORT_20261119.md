# Regresión y reproducibilidad del ciclo temporal — 2026-11-19

## Validación de instrumentación

**Node-HaxBall 2.3.0.** El harness corrió en procesos separados contra la instalación original y contra una copia temporal de la fuente ya instrumentada. Se hicieron dos ejecuciones de cada lado. Baseline e instrumentada produjeron la misma salida física byte por byte: SHA-256 `74e7e0f832a6e91d17765f1419199374209c5ebe7156ae26bc80355d67765ca8`. Hash de estados canónicos sin redondear: `c8d80b14ab068cc103fb992d76472df7a09c2fba03e30ed2be578ee149c42d8d` para ambas. Timeline y callbacks repetidos coinciden.

**PhysicsCore2D.** El resultado del módulo original y el del clon pasivo en 13 subpasos coinciden exactamente en x/y/vx/vy y cantidad de subpasos. El harness se ejecutó dos veces; las serializaciones completas de las dos ejecuciones coincidieron. La comparación no incluyó SHA interno de Roblox; el archivo canónico de la traza Core tiene hash de integridad aparte.

## Barrido temporal controlado de tick 4

Se cambió solo la cantidad de subpasos en clones temporales; se conservaron plano, orden actual y parámetros: 1, 2, 4, 8 y 13.

| Subpasos | Primer contacto | Subpaso | y antes de corregir | y final | vy final |
|---:|---|---:|---:|---:|---:|
| 1 | área superior | 1 | 197.019950 | 160.000000 | -24.014900 |
| 2 | área superior | 1 | 172.762475 | 147.871263 | -24.014900 |
| 4 | área superior | 1 | 160.633737 | 141.806894 | -24.014900 |
| 8 | área superior | 2 | 160.633737 | 141.806894 | -24.014900 |
| 13 | área superior | 4 | 163.432677 | 143.206363 | -24.014900 |

La corrección ocurre durante el subpaso, y la pelota sigue avanzando con velocidad de rebote en lo que queda del tick. Menos subpasos acercan la posición final a Node, pero no cambian qué plano responde primero mientras el orden del Core siga con el plano interior antes del exterior.

En otra variante aislada de un solo paso, se mantuvieron todos los valores físicos actuales y solo se puso primero el plano exterior observado primero en Node. Core procesó exterior y luego área; el estado final fue `y=160`, `vy=-2.4014900249999998`. El exterior conserva `bCoef=0.1`, así que no da `vy=0`. Node observado tiene exterior `bCoef=0`, que cancela la velocidad normal. Esta variante separa el papel del orden temporal/selección de contacto del papel del coeficiente.

## Regresiones reusadas y cobertura pendiente

No se repitieron los fixtures ya verificados:

- S1, S2 y S3 completos: resultados/hashes previos conservados en `PHASE3_PLANE_ORDER_VARIANT_RESULTS_20261119.json`; A–D no cambian estados principales al mantener el ciclo de 13 subpasos.
- Microfixtures A–F: entradas y resultados preservados ahora en `PHASE3_TEMPORAL_FIXTURE_INPUTS_A-F_20261119.json`; resultados históricos en `PHASE3_CONTACT_SOLVER_MICROBENCHMARKS_20261119.json`.
- Esquina, oblicuo, lado opuesto y balón-jugador: variantes de orden previas en `PHASE3_PLANE_ORDER_VARIANT_RESULTS_20261119.json`.

**No se ejecutó la variante temporal de 1 subpaso sobre los fixtures completos S1/S2/S3 ni sobre metas, esquinas, rebotes y jugador-bola en un estadio completo.** El barrido de subpasos de esta tarea es un corte causal de una bola/planos. No hay base para declarar una arquitectura de un paso libre de regresiones. No se modificó el Place ni ningún módulo productivo.

