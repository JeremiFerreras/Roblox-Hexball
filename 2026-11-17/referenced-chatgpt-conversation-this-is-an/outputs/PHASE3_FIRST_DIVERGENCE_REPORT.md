# Fase 3 — Primeras divergencias por tick

## Alcance y procedencia

Comparación por tick regenerada el 2026-11-18 entre la captura existente de Node-Haxball 2.3.0 y una ejecución en memoria de `PhysicsCore2D`/`ClassicStadium2D` en el place 85137916104328. No se editó código Roblox ni se guardó el place. La reconstrucción Node es una implementación independiente basada en el motor Nago incluido en Node-Haxball; no es una medición directa del cliente oficial.

- Telemetría Oracle: SHA-256 `74e7e0f832a6e91d17765f1419199374209c5ebe7156ae26bc80355d67765ca8`.
- Fixture: SHA-256 `7d612957764a076d506f53c4dd8d7fd39381e3db261cb399a812f6eb7d110e37`.
- Comparación íntegra por tick (estados antes/después, velocidades, errores, eventos y contactos Core): [`PHASE3_MICROBENCHMARK_RESULTS.json`](PHASE3_MICROBENCHMARK_RESULTS.json), SHA-256 `af1717d32fab62ec60e5a7e79246ce94cb48442b997e75256867cd9d0fc9ac7f`.
- Se usaron las posiciones iniciales capturadas, las mismas propiedades iniciales del balón y jugadores, estadio Classic activo, cero inputs y un `stepWorld` por paso `runSteps(1)`. El replay compara hasta el gol/reinicio cuando aplica.

“Diferencia exacta” significa distancia numérica mayor que cero; recoge ruido de coma flotante. “Diferencia significativa” aquí solo es una marca diagnóstica de más de 0,01 unidades Haxball, no un criterio de aceptación.

## Resultado por escenario

| Escenario | Comparación | Primera diferencia numérica > 1e-12 | Primer error > 0,01 | Primer contacto | Resultado |
|---|---:|---:|---:|---:|---|
| 1 — velocidad inicial [8,55] | 180 ticks | 16 | 16 | tick 3, ambos | RMS posición 1,720448; máximo 2,411610 |
| 2 — [-30,45] | 13 ticks, hasta antes del gol en 14 | 4 | 4 | tick 4, ambos | RMS 6,962797; máximo 7,938810 |
| 3 — [40,50] | 180 ticks | 4 | 4 | tick 4, ambos | RMS 583,810752; máximo 754,692242 |

### Escenario 1

Ticks 1–15 coinciden hasta redondeo numérico (errores del orden de 1e-13). En el tick 16, ambos motores detectan el contacto con el límite inferior del área de balón y la velocidad poscontacto coincide: aproximadamente `(6,811662; 11,707544)`. El oráculo termina el tick en `y=-160`; Core termina en `y=-157,634840`, error 2,365160. Esta es una diferencia de posición por resolución temporal, no evidencia de que el coeficiente de rebote de ese contacto sea distinto.

Más tarde, el primer error de velocidad grande aparece alrededor de un contacto entre el balón y el jugador 2: Core registra un contacto en tick 91 y el Oracle en tick 92. En ese punto ya existe una diferencia de posición por las colisiones anteriores. Los datos no permiten separar cuánto del tick de contacto distinto es consecuencia de la posición acumulada y cuánto del orden de resolución de pares.

### Escenario 2

Los tres primeros pasos coinciden numéricamente. En tick 4 el Oracle queda en `(−118,211970;160)` con `vy=−21,613410`; Core termina en `(−118,211970;152,061190)` con la misma velocidad. El error vertical 7,938810 persiste hasta el tick 13, por lo que el RMS pre-gol es 6,962797. El evento de plano aparece en tick 4 en ambos. El salto posterior a `(0,0)` no se incluyó: el Oracle registra gol en el tick 14 y reset más adelante.

Esto aísla una diferencia de posición causada por cuándo se proyecta el disco fuera del plano dentro del tick. No hay una discrepancia de velocidad medible en este segmento (máxima ≈3,6e-15).

### Escenario 3

Hasta tick 3, error de posición <1e-12. En el primer contacto, tick 4:

- Oracle: `(157,615960;160)`, velocidad `(38,423840;0)`.
- Core: `(157,615960;143,206363)`, velocidad `(38,423840;−24,014900)`.
- Diferencia: 16,793637 unidades de posición y 24,014900 de velocidad.

El contacto geométrico ocurre en el borde superior del área del balón; Oracle elimina la componente normal y deja la tangencial. Core aplica su coeficiente activo y refleja la componente normal. El Oracle permanece quieto en `(410,160)` desde tick 11, con callbacks de plano y sin gol ni reset. El Core ya siguió otra trayectoria y no alcanza esa posición en el mismo tick, así que su salida en tick 11 no es una comparación aislada de la pared derecha.

Los controles previos con 0, 2 y 6 jugadores informaron la misma trayectoria del balón, lo que descarta que el contacto inicial dependa de una colisión con los jugadores. El callback Node reporta `planeId=1` en este caso y `planeId=5` en los casos 1/2 aunque el punto geométrico es `y=160`. El ID no se trata como índice de la lista interna sin prueba. La correspondencia exacta de ID y propiedad efectiva sigue abierta.

## Criterio de estados iniciales y entidades

El disco 0 se verificó como balón por el campo `ballPhysics: disc0` del HBS exportado y por sus propiedades. En Node hay cuatro discos estáticos de poste antes de los discos de jugador; los jugadores se asociaron por `playerId` y `discIndex`, no por asumir que todo disco dinámico es jugador. Las posiciones iniciales y grupos coinciden con la captura. El JSON contiene comparación de posición y velocidad del balón y de cada jugador por tick, además de resúmenes por entidad. Los errores tardíos de jugadores siguen a los contactos de balón y no validan por sí solos una masa o restitución aislada.

## Qué atribuye la evidencia

- **Medido en la ejecución comparativa:** trayectorias, velocidades y errores por tick incluidos en el JSON; primeros contactos; error del escenario 3.
- **Reconstruido:** estados y eventos Node-Haxball 2.3.0.
- **Inferido con evidencia de código:** escenario 1/2 deriva de integración/resolución temporal en contactos; el escenario 3 también contiene una respuesta normal distinta.
- **Desconocido:** causa interna exacta de la respuesta `vy→0` del escenario 3 y correspondencia semántica del `planeId`.

No se modificaron parámetros ni solver. No se repitió la suite de regresión de 47 casos porque no se alteró el código del juego; 47/47 es el resultado previo, no una ejecución nueva de esta tarea.