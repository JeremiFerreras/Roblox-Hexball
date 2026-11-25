# Auditoría de alineación del comparador

Se contrastaron CLASSIC_ORACLE_COMPARISON.json, build-comparison.mjs, el fixture local y las capturas guardadas de Studio.

- Fixture: 3 casos × 180 posiciones; SHA-256 7d612957764a076d506f53c4dd8d7fd39381e3db261cb399a812f6eb7d110e37.
- Comparador: 540 filas en total; todos los ticks son 1–180, sin saltos ni duplicados.
- En cada fila tick n, reference coincide exactamente con fixture ball_traj[n-1].
- No hay fila t=0 extra. La primera posición post-step coincide con la velocidad inicial porque posición inicial=(0,0) y velocidad se aplica antes del primer paso.
- En Studio se ejecuta Core.stepWorld una vez por estado capturado; en el oracle, gs.runSteps(1). El comparador etiqueta 60 Hz.
- Unidades: Haxball stadium units, sin conversión a studs.

| Velocidad inicial | Estados | Tick | Checks |
|---|---:|---|---|
| [8, 55] | 180 | 1–180 | PASS |
| [-30, 45] | 180 | 1–180 | PASS |
| [40, 50] | 180 | 1–180 | PASS |

Resultado: PASS. Es validación de índices, no fidelidad. El oracle incluye jugadores, el run de Studio no. El fixture omite sus posiciones, velocidades/eventos de referencia y la serialización del estadio utilizado. El HBS Classic vendorizado por HaxballGym indica spawnDistance=277.5, frente a 170 en el perfil Studio; queda por comprobar el HBS exacto que usó el oracle.

firstNonBitExactTick es sólo desigualdad binaria exacta, no umbral físico. El caso [8,55] ya muestra una diferencia cercana a 7,1e-15 en Y en el tick 1.
