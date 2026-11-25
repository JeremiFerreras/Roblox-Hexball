# Validación del orden de contactos de planos — 2026-11-19

## Resultado

La configuración B, que cambia únicamente el orden de los planos, es idéntica a A tick por tick en los fixtures S1, S2 y S3. En el escenario 3 no convierte la respuesta de Core en la de Node: al cierre del tick 4 Core mantiene `y=143.206363`, `vy=-24.014900`; Node termina en `y=160`, `vy=0`.

C y D cambian únicamente el `bCoef` de los planos exteriores a los valores observados en la captura Node (0), conservando el `bCoef` activo en el resto. Tampoco cambian S3 tick 4. En S3, C/D cambian el impulso registrado del plano exterior derecho en tick 35, pero no las posiciones ni velocidades capturadas. En S1 y S2 no se observó diferencia entre variantes.

## Variantes ejecutadas

| Variante | Orden | Propiedades |
|---|---|---|
| A | orden activo de Core | perfil activo |
| B | orden de planos Node | perfil activo |
| C | orden activo de Core | bCoef exterior Node |
| D | orden de planos Node | bCoef exterior Node |

El cambio de propiedad no alteró el plano interior del área de balón. Los valores proceden de las trazas/informes previos: plano exterior superior Node `bCoef=0`; plano interior superior `bCoef=1`. El perfil activo documenta `bCoef=0.1` para el exterior y `1` para el plano del área de balón. No se sustituyó ningún valor por estimación.

## Escenario 3, tick 4

| Motor/configuración | x | y | vx | vy | contacto |
|---|---:|---:|---:|---:|---|
| Node-HaxBall 2.3.0 | 157.615960 | 160.000000 | 38.423840 | 0 | exterior superior (índice interno 1), luego área superior (índice 5) |
| A — Baseline | 157.615960 | 143.206363 | 38.423840 | -24.014900 | `classic:ballArea:top` |
| B — Orden Node | 157.615960 | 143.206363 | 38.423840 | -24.014900 | `classic:ballArea:top` |
| C — Propiedades Node | 157.615960 | 143.206363 | 38.423840 | -24.014900 | `classic:ballArea:top` |
| D — Orden + propiedades Node | 157.615960 | 143.206363 | 38.423840 | -24.014900 | `classic:ballArea:top` |

Core registra penetración 3.432677 e impulso 72.772425 en el plano interior, a través de 13 subpasos. Los datos Node provienen de la traza interna previamente validada, no de una nueva captura de esta tarea. Node resuelve en el mismo paso exterior superior `bCoef=0` (que anula `vy`) y después el interior. El orden por sí solo no produce ese primer contacto en Core: cada subpaso avanza la pelota una fracción del tick y corrige al tocar primero el plano interior, de modo que la pelota no llega a penetrar el exterior.

La gran diferencia posicional del tick 4 persiste en A–D. La ordenación de planos no sustituye la diferencia de integración temporal observada.

## Resultados de fixtures principales

Los agregados RMS/max y el primer tick por encima del umbral diagnóstico de posición 0.01 están en `PHASE3_PLANE_ORDER_VARIANT_RESULTS_20261119.json`, junto con cada fila de tick. El JSON preserva las trayectorias cuantizadas a seis decimales del harness y contactos en orden de registro.

- S1 (180 ticks): los cuatro variantes son iguales; RMS posición 1.720448, RMS velocidad 0.156499; primera diferencia diagnóstica contra la referencia en tick 16; 5 ticks con contactos. Repetición determinista.
- S2 (13 ticks previos al gol): los cuatro variantes son iguales; RMS posición 6.962797, RMS velocidad aproximadamente 0; primera diferencia en tick 4; 1 tick con contacto. Repetición determinista.
- S3 (180 ticks): las posiciones/velocidades de A–D son iguales tick por tick; C/D solo cambian el impulso registrado del plano exterior derecho en tick 35. RMS posición 583.810752 y RMS velocidad 6.848984 frente a Node en el conjunto completo; primera diferencia diagnóstica en tick 4; 9 ticks con contactos en Core. Repetición determinista de cada variante.

El RMS de S3 incluye divergencia acumulada de larga duración y no es un criterio de aceptación física. El dato causal para esta comparación es la transición por tick y el plano/evento correspondiente.

## Efectos secundarios observados

Se ejecutaron microfixtures temporales de esquina, oblicuo, lado opuesto y balón-jugador además de S1–S3:

- Esquina: mismo orden de contactos (área superior, exterior derecho) en los cuatro variantes. Cambiar propiedades exteriores cambia el impulso del contacto derecho de 21 a 20 y produce diferencias de estado en el microfixture.
- Oblicuo: sin cambio entre variantes.
- Lado opuesto: el orden B/D cambia a exterior superior seguido del área superior; A/C solo informa el área. No hubo impulso normal porque la velocidad no se aproximaba al plano. La diferencia demuestra que reordenar agrega un contacto registrado del lado contrario; los estados numéricos redondeados no cambian en este microfixture.
- Balón-jugador: sin cambio entre variantes; el orden y el impulso del contacto disco-disco quedan iguales.
- No se observaron velocidades anuladas artificialmente ni cambios numéricos en S1–S3 por las variantes. La esquina sí cambia el estado por el bCoef exterior; el fixture del lado opuesto agrega un contacto registrado por el orden. No se ejecutó un fixture dedicado de goles ni una batería exhaustiva de todos los empates/esquinas del estadio; no se afirma ausencia global de regresiones.

## Limitación del perfil cargado

La inspección textual de `StadiumReference2D.Source` y el valor retornado por `require(StadiumReference2D)` dentro de Edit no coincidían en collision groups/masks (el require mostró datos de caché incompatibles). Para aislar el ensayo, los mundos temporales normalizaron máscaras y grupos a los valores de la fuente/HBS verificados. No se cambió el ModuleScript ni se guardó el place. Antes de trasladar estos resultados a otro harness que requiera los módulos normalmente, hay que resolver la caché/desincronización del perfil.

## Conclusión

Ordenar los planos como Node no basta. Cambiar el `bCoef` exterior de 0.1 a 0 sí cambia impulsos de contacto exterior y los estados del microfixture de esquina, pero tampoco corrige el contacto del escenario 3 en tick 4. La evidencia favorece que el disparador del tick 4 depende de cuándo se integra/detecta el contacto: Node llega al exterior en una pasada completa del tick; Core resuelve antes, durante subpasos, el plano interior. Mantener separadas esta causa temporal y los efectos de orden/propiedades es necesario.

Recomendación: no adoptar globalmente ni el orden Node ni `bCoef=0` todavía. El siguiente experimento debe ejecutar en Core diagnóstico una única pasada de integración/resolución equivalente temporalmente a Node, y evaluar cada plano contactado con una traza por subpaso; luego repetir el conjunto completo S1–S3 y la prueba de lado opuesto, esquina y goles. Ningún cambio productivo queda autorizado por estos resultados.

