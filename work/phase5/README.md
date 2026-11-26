# Fase 5: evolución del buffer

Los módulos activos e integrados están en `src/ReplicatedStorage/HaxballLab/SnapshotBuffer` y `NetMetrics`. Esta carpeta conserva el prototipo aislado, su modelo numérico reproducible y las utilidades de CI. La descripción del comportamiento activo y de sus límites está en [el informe de fase 5](../../docs/PHASE5_BUFFER_METRICS_2026-11-25.md).

El primer intento reajustaba el reloj con cada llegada y producía demasiadas frenadas/rebuffers. El reloj continuo corrigió ese problema. `model-results.json` contiene 15 comprobaciones ejecutadas de un modelo JavaScript del reloj: no sustituye las pruebas de los módulos Luau reales.

La prueba aislada de estos módulos (21 casos) pasó en [GitHub Actions](https://github.com/JeremiFerreras/Roblox-Hexball/actions/runs/45747718881). Las pruebas activas, incluidas ACK/correcciones e integración del cliente, están en `tests/offline` y se ejecutan con la suite completa.

```sh
node work/phase5/check-model.mjs
npm ci --prefix tests/offline
node work/phase5/check-luau.mjs
npm test --prefix tests/offline
npm run test:quality --prefix tests/offline
```

El modelo usa semilla 1731, llegadas de 50–120 ms, 30/60/240 FPS y pérdidas del 0/5/15 %. Mide suavidad de movimiento lineal; no mide el ping real, transporte nativo ni igualdad competitiva. A 60 FPS sin pérdida, su error medio absoluto de velocidad baja de 48,25 a 1,82 unidades/s. Con pérdida persistente hay congelaciones y recuperaciones: consultar también los valores desfavorables del JSON.

`prepare-ci.py` formatea, reconstruye el place e inventario y verifica referencias. `export-ci.py` permite recuperar por el registro los archivos generados y comprobados cuando el entorno de ejecución local no está disponible. No publica cambios por sí solo.
