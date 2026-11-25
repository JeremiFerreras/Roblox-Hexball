# Ciclo temporal de PhysicsCore2D — auditoría

## Fuente y ejecución

Se leyó directamente por MCP el `Source` del `ModuleScript` que Studio tiene en `ServerScriptService.HaxballLab.PhysicsCore2D`. La función ejecutada es `Core.stepWorld(world, inputs)`.

La sonda clona el texto fuente a módulos temporales bajo `ServerStorage`, inserta únicamente registros de estado y destruye los clones. El baseline usa el módulo productivo sin modificar. El harness está en [PHASE3_PHYSICSCORE_TEMPORAL_TRACE_HARNESS_20261119.luau](PHASE3_PHYSICSCORE_TEMPORAL_TRACE_HARNESS_20261119.luau); los resultados están en [PHASE3_TEMPORAL_EXPERIMENT_RESULTS_20261119.json](PHASE3_TEMPORAL_EXPERIMENT_RESULTS_20261119.json).

## Orden del código activo

1. Crea `events/eventKeys` y aplica input/kick una vez.
2. Calcula velocidad máxima y radio mínimo; fija `maxDistance=max(0.5, minRadius*0.5)` y `substeps=clamp(ceil(maxSpeed/maxDistance), 1, maxSubsteps)`.
3. Por cada subpaso, mueve las posiciones una fracción `velocity/substeps`.
4. Recorre los discos. En orden: pares dinámicos; límites; geometría estática. La geometría plana se recorre en el orden de `world.planes`; los segmentos se recorren después.
5. Cada plano penetrado se resuelve inmediatamente: corrige posición, calcula velocidad normal y actualiza la velocidad si entra al plano. La velocidad resultante se usa en los subpasos restantes.
6. Al terminar todos los subpasos, aplica gravedad y damping una vez.
7. Incrementa `world.tick`, asigna `world.events` y devuelve eventos/subpasos.

No vuelve a revisar el mismo plano después de terminar el recorrido estático de ese subpaso. Los siguientes planos del arreglo sí ven la posición ya corregida; una nueva detección completa ocurre al avanzar al próximo subpaso. Los eventos se agregan por identidad y conservan penetración/impulso máximos; el harness productivo no devuelve callbacks internos con timestamp.

## Escenario 3, estado exacto antes de tick 4

La sonda se sembró con el estado posterior a tick 3 conservado en la comparación: `x=118.80399999999997`, `y=148.5049999999999`, `vx=38.81196`, `vy=48.51495`, radio 10. Con velocidad `62.129450444568555`, radio mínimo 10 y distancia máxima 5, el código selecciona 13 subpasos, cada uno `1/13` de tick (`1/780` s bajo el reloj de 60 Hz).

- Pasos 1–3: termina en `y=152.23691923076913`, `155.96883846153835`, `159.70075769230758`; no hay contacto.
- Paso 4: movimiento hasta `y=163.4326769230768`; detecta el plano del área superior (en la instalación completa es el plano de área antes del exterior), penetración `3.432676923076798`.
- La resolución corrige `y) a 160 y cambia `vy) de `48.51495` a `-24.257475` (`delta vy=-72.772425`).
- Los pasos 5–13 continúan con esa velocidad ya invertida. Al final aplica damping `0.99`, terminando en `y=143.2063634615385`, `vy=-24.01490025`.

La detección del exterior superior no ocurre: la corrección al plano interior sucede antes de que el centro alcance el exterior.

## Qué ejecutó el harness frente al escenario completo

La traza temporal de esta tarea es un corte aislado de una pelota y los dos planos relevantes, sembrado con el estado exacto previo al tick 4. Sus estados de tick final reproducen el resultado del Core completo. No se presenta como una ejecución de todo el escenario 3: se excluyeron jugadores, postes y segmentos para observar el orden temporal del contacto sin interferencias.

Los fixtures S1–S3 completos se reutilizan en el informe de regresión anterior; el sweep de cantidad de subpasos de esta tarea se ejecutó solo sobre el corte tick 4. No se extrapola su seguridad a goles ni a todas las interacciones.

