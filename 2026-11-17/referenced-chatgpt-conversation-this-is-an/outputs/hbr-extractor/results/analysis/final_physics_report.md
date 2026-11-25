# Auditoría y análisis físico de Haxball

## Alcance y etiquetas de evidencia

El HBR es **HBR2 versión 3**, 12.368 frames, SHA-256 `60a184ca3e33f763424960e407bc7d898cbf13a0a5e54eb85f811661e4d478d5`. Se reconstruyó con Node-Haxball fijado en `4d4b88f1e5e25d484d27819ee6a4699720bda164`. `Replay.readAll()` y `Replay.read()` confirman versión y duración; el registro contiene 12.368 callbacks `onGameTick`, frames 1–12.368, sin saltos ni duplicados. **RECONSTRUIDO** significa producido por Node-Haxball; **MEDIDO** significa calculado de esos estados o del JSON original. Ninguno de los resultados de movimiento reconstruido es una medición directa del cliente oficial.

## Auditoría de resultados y discos

- Se parsearon las 12.368 filas de `replay_physics_ticks.jsonl`, las 2.770 filas de `replay_events.jsonl`, los metadatos y la validación. Los estados contienen posición, velocidad y propiedades de seis discos por frame. Los CSV contienen 12.368 filas de jugador y 74.208 filas de discos.
- El replay registra un jugador inicial: id 1, Zeozato, equipo 1. En cada estado el disco con `playerId=1` es el disco 5. Los discos 1–4 corresponden a los cuatro discos del estadio en `roomData`; el disco 0 se identifica como balón por sus metadatos consistentes (radio 10, grupo 193, máscara 63) y por el objeto de balón en los callbacks de gol. Esta identificación se comprobó contra metadatos y estados.
- **Error de etiquetas detectado en la extracción:** `compactDisc` escribió el vector interno `d._` bajo `x/y` y `d.h` bajo `xgravity/ygravity`. La lectura cinemática y el estado `MovableDisc` de los tipos locales de Node-Haxball indican que `h` es posición y `_` gravedad en estos estados. Por eso este análisis usa `xgravity/ygravity` como coordenadas y `x/y` como gravedad. Las coordenadas sí quedaron guardadas, pero los nombres de campo en los JSON/CSV de extracción están intercambiados. No los modifiqué; el mapeo corregido queda documentado en `player_physics.json`.
- Comprobación: en frame 62 el jugador está en `(240, 0)`, velocidad `(0, 0)`. De frame 62 a 63 la posición cambia `(-0.1, 0)` y la velocidad posterior es `(-0.096, 0)`. De frame 63 a 64 cambia `(-0.196, 0)` y la velocidad posterior es `(-0.18816, 0)`. Esos pasos son coherentes con aceleración de control 0.1 y damping 0.96 en la reconstrucción.
- El tiempo del Replay API es milisegundos; `gameTime` del HBR termina en 206.133 s. Los análisis de movimiento usan **un callback lógico por paso** y no convierten `gameTime` irregular en una duración uniforme por fila.

## Movimiento del jugador

**Metadatos reconstruidos:** física de jugador: radio 15, masa inversa 0.5, damping 0.96, rebote 0.5, aceleración normal 0.1, aceleración al mantener kick 0.07, damping al patear 0.96, kickStrength 5 y kickback 0. Los valores se decodifican del `playerPhysics` del estadio y su asignación de campos sigue el tipo local `PlayerPhysics` de Node-Haxball. Disco inicial: grupo 4 y máscara 39; ambos pueden cambiar en el partido por equipo/goles.

**Mediciones sobre la reconstrucción:** se observaron 10.002 pares de pasos sin callback de contacto, gol, reset ni cambio de equipo dentro del margen definido. En ellos, el residuo mediano de posición frente al modelo es `6.8e-15` unidades/tick y el residuo mediano de velocidad es 0; el percentil 90 de esos residuos es 0.03 y 0.0288, respectivamente. Para 762 pasos libres sin dirección ni kick, la razón mediana de rapidez es exactamente 0.96 (p10–p95 también 0.96). Esto respalda la conservación de inercia con damping multiplicativo.

La ecuación que describe los pasos libres reconstruidos es:

```text
u = dirección de entrada normalizada
a = 0.10 (movimiento normal) o 0.07 (tecla de kick, según metadatos)
v[n+1] = 0.96 · (v[n] + a·u)
p[n+1] = p[n] + v[n] + a·u
```

Sin dirección, `u=(0,0)`, por lo que `v[n+1]=0.96·v[n]` y `p[n+1]=p[n]+v[n]`. La semivida deducida de ese damping es 16.98 pasos. La trayectoria inicial sirve de ejemplo de aceleración desde reposo; no es un ensayo controlado del original.

El flag 4 produjo aceleración hacia −X; el flag 2, hacia +Y; la combinación 6 produjo diagonal hacia −X,+Y con componentes cercanas a `0.07071`, consistente con magnitud total 0.1 y normalización diagonal. Los bins con entrada cardinal y diagonal en `player_physics.json` contienen sus muestras y residuos. La aceleración normal de metadatos y esos cambios medidos concuerdan.

La rapidez máxima observada fue **2.399702 unidades por paso lógico** (frame 11.379); 227 muestras alcanzan 2.39. Con `a=0.1` y `d=0.96`, el equilibrio de `d·a/(1−d)` es 2.4. Esto explica el máximo observado sin necesitar postular un tope rígido; el replay no demuestra si existe además una saturación interna. Los saltos de posición máximos (585.68 unidades en el jugador) coinciden con resets/cambios de equipo y se excluyen de la física libre.

No se aisló una secuencia limpia de inversión de dirección bajo el filtro de contactos. Por tanto, el número de ticks de inversión queda **DESCONOCIDO** en esta partida; la fórmula permite predecirlo, pero falta una entrada opuesta controlada sin colisiones. Solo hay un jugador, así que no hay movimiento 5v5 ni colisión jugador-jugador.

## Balón y kicks

El balón identificado (disco 0) tiene radio 10, masa inversa 0.5, damping 0.99, rebote 1, grupo 193 y máscara 63. Su rapidez máxima reconstruida es **6.620518 por paso lógico** en frame 7.274. En 10.998 pares sin callback cercano de contacto, el cambio de posición coincide con la velocidad anterior (residuo mediano `2.6e-15`) y la velocidad se multiplica por 0.99 (6002 razones calculables, mediana 0.99). Esto corrobora el damping del balón dentro de Node-Haxball.

Se capturaron 28 callbacks de kick, todos del jugador id 1. En el estado correspondiente al callback, la distancia entre centros fue de 25.0 a 28.96 unidades (mediana 27.64). Entre el estado del frame del callback y el siguiente, la magnitud mediana del cambio de velocidad fue 4.944 (p10 4.933, p90 4.950; un caso bajó a 2.781). `kickStrength=5` procede de los metadatos reconstruidos y es coherente con la mayoría de esos cambios, pero la diferencia entre dos frames **no es un impulso aislado**: pueden intervenir damping, movimiento y solver en el mismo paso. No hay intentos fallidos, así que rango máximo y cooldown siguen desconocidos. No se expone dirección, fuerza ni impulso del kick.

## Colisiones y eventos

Callbacks reconstruidos: 940 disco-disco, 833 disco-segmento, 364 disco-plano y 0 vértice. Los 940 pares disco-disco se distribuyen así: balón-jugador 0–5: 865; balón-discos del estadio 0–1…0–4: 32; jugador-discos del estadio 1–5…4–5: 43. Las colisiones del balón con segmentos y planos suman 76 y 28; las del disco del jugador, 757 y 336.

Los callbacks disco-disco contienen IDs de discos y propietario; segmento/plano incluyen disco, jugador si corresponde e índice geométrico. **No** incluyen normal, profundidad, impulso, fuerza ni iteración del solver. `collision_analysis.json` también resume el cambio de velocidad entre f−1 y f+1: es contexto de trayectoria, no impulso, y sus ventanas se solapan en contactos persistentes. Los callbacks repetidos pueden reflejar contacto persistente, no impactos independientes. Los cinco goles, cuatro resets de posiciones y cambios de equipo deben tratarse como discontinuidades, no como física de movimiento. No existe evidencia de colisión jugador-jugador en estos datos.

## Auditoría de telemetría

La telemetría original es una sesión distinta: estadio **Big**, 21.912 filas consecutivas (ticks 1–21.912), un jugador id 1, 78 eventos (61 kicks, 8 goles, 8 resets, 1 fin de juego) y `gameTime` de 0 a 233.45 s. El HBR es estadio **Small**, 12.368 frames y `gameTime` final de 206.133 s. No se correlacionan como una misma partida.

De las 21.911 parejas de filas, `gameTime` se repite 16.627 veces (**75.88%**). Entre esas parejas de tiempo repetido, el estado del jugador cambia en 8.822 y la posición del balón en 434; ambos estados se repiten exactamente en 7.848 parejas consecutivas. Los incrementos positivos son 0.016667 s (646), 0.033333 s (666), 0.05 s (3.859) y 0.066667 s (113). No hay una alternancia simple de una fila nueva con otra duplicada: igual `gameTime` no significa estado físico idéntico. Es probable que el reloj y la captura tengan cadencias distintas, pero sin el código que generó el archivo la causa exacta es **DESCONOCIDA**.

Ticks consecutivos no tienen huecos ni duplicados. Se detectan cinco cambios de equipo (ticks 437, 2045, 14139, 15473 y 16840). La auditoría directa también encuentra 13 saltos de posición mayores de 50 unidades: ocho coinciden con eventos `positionReset` y cinco con spawns tras cambiar de equipo. En los 13, `gameTime` no avanza y la velocidad del destino coincide, dentro de 0.02, con el desplazamiento de la muestra. Por ello se clasifican como discontinuidades y artefactos de captura/reset, no como movimiento físico; los extremos de velocidad asociados quedan excluidos. Esto contradice el `potentialPositionJumps: 0` del `telemetry_analysis.json` preliminar, que queda supersedido por `telemetry_audit.json`. Para las 5.284 parejas con delta de `gameTime` positivo, la diferencia vectorial media entre desplazamiento/delta-tiempo y velocidad media de extremos fue 103.47; el ajuste de escala es 40.01, no 1. Esto no identifica la unidad o el instante de las velocidades y no debe calibrar el motor. La fuente no registra inputs por tick, así que no permite aislar aceleración, soltar teclas o inversión.

## Conclusiones y próximos experimentos

**Suficientemente respaldado como baseline del Node-Haxball reconstruido:** identidad y propiedades de los discos de esta cancha; radio, masa inversa, damping y rebote de balón/jugador; aceleración normal y al patear del estadio; kickback y kickStrength; aceleración de entrada, normalización diagonal, damping sin input y pasos libres del balón. La correspondencia de movimiento a estos valores es fuerte en esta repetición.

**Necesita comparación nueva con el original:** valores de aceleración/damping medidos en escenarios controlados; velocidad máxima como propiedad independiente; inversión de dirección; aceleración al mantener kick; kicks desde reposo/en movimiento, intentos fallidos y cooldown; rebote aislado contra segmento/poste; simultaneidad y contactos múltiples; pruebas jugador-jugador y 5v5. Comparar trayectorias por frame contra el juego original es indispensable antes de llamarlo fiel.

**Desconocido:** equivalencia numérica de Node-Haxball con el motor oficial actual, orden/iteraciones del solver oficial, normales e impulsos, regla exacta y cooldown del kick, tiempo de inversión real del original, semántica del `tick` y causa de `gameTime` repetido en la telemetría.

**Preparación: LISTO CON LIMITACIONES.** Se puede iniciar un laboratorio propio usando estos valores como baseline provisional del replay reconstruido. No se debe declarar física certificada ni transferir los resultados a Roblox como verdad del motor original sin pruebas comparativas controladas.

Los detalles numéricos y muestras por frame están en `player_physics.json`, `ball_physics.json`, `kick_analysis.json`, `collision_analysis.json` y `telemetry_audit.json`. Fuentes locales de interpretación: `work/node-haxball-source/node-haxball-4d4b88f1e5e25d484d27819ee6a4699720bda164/src/index.d.ts` (tipos `MovableDisc`, `PlayerPhysics`, `AsyncReplayReader`) y `examples/api_structure/replayReader.js` (callbacks Replay).
