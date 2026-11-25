# Fase 3 — experimento factorial temporal/contactos/propiedades

Fecha: 2026-11-19. Alcance: clones temporales y harnesses diagnósticos; no se editó PhysicsCore2D productivo ni la instalación original de Node-HaxBall. Roblox Studio se mantuvo en Edit.

## Diseño ejecutado

Se ejecutaron ocho combinaciones para cada fixture completo:

- T0: Core actual, integración fraccionada en subpasos adaptativos; detecta/resuelve en cada subpaso y aplica damping/gravedad tras el bucle.
- T1: clon diagnóstico: integra posición por el tick completo, aplica gravedad/damping y realiza una pasada de contactos. Estudia un cambio temporal del Core; no equivale automáticamente al ciclo semántico completo de Node.
- O0/O1: orden de planos de la fuente fresca StadiumReference2D / orden Classic observado en Node (exterior abajo, arriba, izquierda, derecha; área de balón abajo y arriba).
- P0/P1: valores del perfil fuente fresco / valores efectivos del HBS. En los planos relevantes, outer bCoef=0.1 frente a 0; ball-area bCoef=1 en ambos. Máscaras y grupos quedan en los JSON.

Se cargó StadiumReference2D.Source desde clones ModuleScript recién creados. Los valores de Source, require cacheado y clones recién cargados se mantienen diferenciados en PHASE3_STADIUM_PROFILE_CACHE_AUDIT_20261119.json; no hubo normalización silenciosa. Las variantes usan el clon fresco declarado en el harness.

## Resultados completos

Métricas contra la trayectoria de pelota Node 2.3.0 capturada y fijada en los artefactos previos; Node no se volvió a ejecutar en esta tarea. Primera divergencia = primer error absoluto >0.01.

| Escenario | T | O | P | RMS posición | RMS velocidad | 1.ª divergencia pos/vel | contactos Core |
|---|---|---|---:|---:|---:|---|---:|
| S1 | T0 | cualquiera | cualquiera | 1.7204482587442131 | 0.15649917794252968 | 16 / 91 | 5 |
| S1 | T1 | cualquiera | cualquiera | 0 | 0 | ninguna en 180 ticks | 5 |
| S2 | T0 | cualquiera | cualquiera | 6.962796974254796 | 3.1159360222937565e-15 | 4 / ninguna | 1 |
| S2 | T1 | cualquiera | cualquiera | 0 | 0 | ninguna en 13 ticks | 1 |
| S3 | T0 | cualquiera | cualquiera | 583.8107523575815 | 6.848983711898695 | 4 / 4 | 9 |
| S3 | T1 | O1 | P1 | 0 | 0 | ninguna en 180 ticks | 3 |
| S3 | T1 | O0 | P1 | 171.46955571251027 | 7.796255660561434 | 5 / 4 | 4 |
| S3 | T1 | O1 | P0 | 101.12208061071956 | 1.2190490118174828 | 5 / 4 | 18 |
| S3 | T1 | O0 | P0 | 171.469556206408 | 7.797400952785758 | 5 / 4 | 15 |

En S1/S2, T1 elimina las divergencias medidas en esas entradas; O/P no muestran efecto medible. En S3, con T0, orden o propiedades por separado no cambian la divergencia inicial. Bajo T1 se requieren O1 y P1 además del ciclo temporal para coincidir en toda la trayectoria capturada.

## S3, tick 4

Estado por tick y contacto exacto se registran en PHASE3_TEMPORAL_FACTORIAL_S3_RESULTS_20261119.json. Plano superior del área: normal (0,-1), offset -170; plano exterior superior usa igual normal, offset -200.

- T0 con cualquier O/P: solo ball-area top; penetración 3.432676923076798, impulso 72.772425; termina y=143.2063634615385, vy=-24.01490025.
- T1/O1/P1: exterior top primero, penetración 7.01995 e impulso 48.0298005; luego ball-area top, penetración 30 e impulso 0; termina y=160, vy=0.
- T1/O1/P0: exterior primero pero bCoef 0.1 deja vy=-2.401490025.
- T1/O0: el área se corrige antes de que el exterior pueda detectarse en esa pasada; termina y=160 con vy=-24.01490025.

El tick requiere la conjunción T1+O1+P1. Esto no demuestra que T1 sea seguro globalmente.

## A–F y regresión

### Sensibilidad al número de subpasos

También se reutilizó PHASE3_TEMPORAL_EXPERIMENT_RESULTS_20261119.json, la microprueba ya ejecutada con el estado exacto de S3 tras tick 3 y geometría/propiedades fijas. Al variar únicamente subpasos, de 1, 2, 4, 8 y 13, todos detectan el plano del área superior y devuelven la misma velocidad final (vx=38.4238404, vy=-24.01490025), pero cambian el momento de detección y la posición al final del tick: y=160, 147.8712625, 141.80689375, 141.80689375000009 y 143.2063634615385, respectivamente. Esto demuestra sensibilidad de posición y penetración al subpaso, sin explicar por sí solo el vy=0 de Node. La variante separada de una pasada con orden Node y propiedades actuales alcanza y=160 pero acaba vy=-2.401490025; queda claro que “un subpaso” con el orden y propiedades actuales no equivale a Node ni a T1 con velocidades actualizadas antes de resolver.

A–F usa las entradas completas archivadas en PHASE3_TEMPORAL_FIXTURE_INPUTS_A-F_20261119.json. En los casos de un solo plano, O es inerte. Se conserva el bCoef explícito de cada caso; el barrido E no se sustituyó por valores del estadio. T1 coincide numéricamente con resultados Node históricos capturados en 14 casos; T0 conserva respuesta Core, con diferencias de posición final cuando continúa avanzando tras resolver. Node no se ejecutó de nuevo en esta tarea.

Se añadieron seis controles de un tick, ocho variantes cada uno:

- Gol/net lateral: T0 detecta classic:goalNet:right:back y acaba x=389.25, vx=-0.99. T1 procesa classic:outer:right primero y acaba x=410; no registra el contacto de red en ese paso. T1/P1 anula vx.
- Esquina: el orden cambia contactos resueltos; algunas variantes omiten uno y conservan velocidad entrante.
- Límite rápido, vx=3000: T0 usa 64 subpasos. T1/P0 termina con vx=-148.5; T1/P1 con vx=0.
- Lado opuesto y pelota-jugador: integración completa cambia posición final respecto de T0 (en el caso jugador x=10 vs 7.5), aunque el impulso horizontal resulta prácticamente igual.

Resultados completos en PHASE3_TEMPORAL_CONTACT_REGRESSIONS_20261119.json. Son diagnósticos de un tick, no una batería histórica multi-tick de gol.

## Reproducibilidad y límites

Se repitieron 12/12 fragmentos principales byte por byte. Los harnesses A–F y los controles nuevos también produjeron salidas byte idénticas en la repetición. Los estados conservan decimales completos sin redondeo manual. La captura bruta guardó pelota y discos móviles; los archivos CANONICAL_STATES expanden cada tick con los discos de jugador inicialmente estáticos, usando sus spawns exactos del harness. Cada jugador emitido por movimiento aparece en todos los ticks desde su primer movimiento hasta el final; los ticks anteriores se reconstruyen como spawn en reposo. Esta regla queda anotada dentro del JSON. Por tanto, los vectores completos de jugador combinan valores observados y reconstrucción determinista explícita, no una captura directa en cada tick.

**Demostrado:** T0/T1 son ciclos distintos; S3 tick 4 solo coincide con T1/O1/P1; el contacto exterior bCoef=0 cancela la velocidad entrante cuando ese contacto ocurre primero. Los controles extra muestran diferencias en contactos de gol, esquinas y alta velocidad.

**Fuertemente respaldado:** el contacto divergente S3 depende de interacción entre momento de detección, orden y bCoef exterior. Ningún factor aislado bajo T0 reproduce el estado Node.

**Abierto:** T1 no implementa todos los semánticos Node (categorías, candidatos, tolerancias, iteraciones). No se ha demostrado compatibilidad completa de jugadores/eventos ni seguridad multi-tick de los controles. La referencia Node es la captura fijada anterior, no una nueva ejecución.

## Artefactos principales

Harness factorial, resultados por escenario S1–S3, resumen, resultados A–F, controles de contacto, estados canónicos y recomendación están en outputs con sufijo 20261119. Ningún módulo productivo fue alterado; instalación Node intacta; Place no guardado ni publicado.

