# Ciclo temporal de Node-HaxBall 2.3.0 — auditoría

## Fuentes verificadas

- Paquete fijado: `%TEMP%\\codex-haxball-oracle-230-20261118\\oracle-install\\node_modules\\node-haxball`, versión declarada y ejecutada `2.3.0`.
- Motor incluido: `src/api.js`, minificado en una sola línea; método interno `N.prototype.E$(C,h)`.
- Harness temporal: [PHASE3_NODE230_TEMPORAL_TRACE_HARNESS_20261119.cjs](PHASE3_NODE230_TEMPORAL_TRACE_HARNESS_20261119.cjs).
- Traza ejecutada: [PHASE3_TEMPORAL_NODE230_TRACE_20261119.json](PHASE3_TEMPORAL_NODE230_TRACE_20261119.json).

El código 2.3.0 inspeccionado y el proceso ejecutado son la instalación aislada existente. No se sustituyó por la fuente 2.3.1.

## Orden efectivo observado en E$

1. Al entrar en `E$`, se capturan los discos actuales.
2. Un único recorrido de todos los discos integra posición como `position += C * velocity`.
3. En ese mismo recorrido actualiza la velocidad como `velocity = damping * (velocity + gravity)`.
4. Después comienza otro recorrido por discos para colisiones. Para cada disco, el orden del código es pares dinámicos, arreglo de planos, segmentos y discos estáticos.
5. En un plano, el código filtra por máscaras, calcula penetración positiva, corrige primero la posición, calcula velocidad normal y aplica restitución si la componente entra al plano. Luego llama el callback de plano.
6. Tras el recorrido de discos, hay dos pasadas para restricciones de joints. No son iteraciones generales de los planos.

No aparece un bucle de subpasos dentro de `E$`. La captura del proceso confirmó `dt=1` y una transición `E$` por cada `runSteps(1)`; también se observa una ejecución por frame en los 180 frames de cada escenario en la instrumentación previamente validada.

## Tick 4 del escenario 3

El estado de entrada a tick 4 concuerda con el final de tick 3: centro aproximado `(118.804,148.505)`, velocidad `(38.81196,48.51495)`.

La traza de tick 4 registra:

- Entrada a `E$`: `y=148.505`, `vy=48.51495`.
- Después del recorrido de integración y antes de detectar contactos: `y=197.01995`, `vy=48.0298005`. El desplazamiento de posición usó la velocidad de entrada; damping `0.99` actualizó velocidad antes de resolver.
- Plano exterior superior, índice interno 1: pre-resolución `y=197.01995`, penetración `7.01995`, normal `(0,-1)`, offset `-200`, plano `bCoef=0`. La resolución elimina `vy`; el centro se corrige a `y=190`.
- Plano del área superior, índice 5: parte de `y=190, vy=0`, penetración 30, offset `-170`, `bCoef=1`; solo corrige a `y=160`.
- Al tick siguiente entra con `y=160, vy=0`.

La fórmula ejecutada del plano usa `1 + disc.bCoef * plane.bCoef`. Para disco `bCoef=0.5` y plano exterior `bCoef=0`, el factor es 1 y el componente normal entrante se cancela.

## Callbacks

El código invoca el callback de plano después de corregir posición y actualizar la velocidad normal. En el registro público de tick 4, `onGameTick` aparece antes de `onCollisionDiscVsPlane(0, null, 1)`; el callback de colisión señala el plano interno 1. La sonda interna pre/post confirma qué operación ocurrió antes de ese callback.

## Evidencia y límites

**Observado directamente:** entradas y estados posteriores a integración en ticks 3–5; dos fases pre/post por cada plano contactado en tick 4; `dt=1`; callback de plano; hashes repetidos.

**Inspeccionado en código:** orden de integración, detección y resolución; fórmula de respuesta normal; dos pasadas posteriores de joints.

**Límite:** Node-HaxBall es el oráculo independiente fijado, no una medición ni certificación del cliente oficial de Haxball.

