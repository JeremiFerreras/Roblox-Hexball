# Fase 3 — evaluación experimental de TOI

**Veredicto: PARTIAL GO para una investigación aislada del solver TOI; NO-GO para validación amplia o adopción productiva en su estado actual.** El avance continuo detecta la red del control de gol y evita atravesar los límites en el control de alta velocidad. Sin embargo, no reproduce S3 y presenta chatter de contactos en esquinas que llega al límite de eventos. La siguiente investigación útil es resolver contactos simultáneos como un conjunto y repetir primero las regresiones de esquina, red y S3.

## Diseño y límites de la prueba

Se generaron variantes a partir de copias temporales de `PhysicsCore2D` y `StadiumReference2D`, sin sustituir el ciclo productivo. Las copias se cargaron y destruyeron en `ServerStorage`. La configuración de estadio usa el commit `4b9724f49fe0ff87ad3f111eb91b208020d96d73`; las entradas A–F completas se reutilizaron desde `PHASE3_TEMPORAL_FIXTURE_INPUTS_A-F_20261119.json`.

| Variante | Ciclo | Orden | Propiedades de planos |
|---|---|---|---|
| A | Core discreto actual | Core | Core |
| B | T1: tick completo y pasada discreta | Node | HBS/Node |
| C | TOI y redetección | Core | Core |
| D | TOI y redetección | Core | HBS/Node |
| E | TOI y redetección | Node | Core |
| F | TOI y redetección | Node | HBS/Node |

B es el ganador factorial anterior usado como referencia diagnóstica dentro del Core. No es una ejecución de Node. La referencia Node-HaxBall 2.3.0 aquí es la captura archivada del fixture SHA-256 `7d612957764a076d506f53c4dd8d7fd39381e3db261cb399a812f6eb7d110e37`; Node no se volvió a ejecutar en esta tarea.

El clon TOI busca candidatos con la velocidad actual, acepta penetraciones iniciales como eventos de tiempo cero, selecciona el impacto válido más temprano y vuelve a detectar después de cada resolución. Los tiempos empatados dentro de `1e-9` se resuelven con una prioridad determinista por clase de candidato y después por índice/identificador. Usa `posSlop=1e-7`, `velEps=1e-9` y un máximo de 32 eventos por tick. Planos y segmentos rectos se barren analíticamente; los arcos usan intersecciones circulares y validación sobre el arco. El par dinámico usa barrido de círculos.

La simulación mantiene la semántica cinemática del Core: velocidad constante durante el movimiento del tick y gravedad/damping al final. Por ello no equivale a integrar aceleración continuamente, ni reproduce automáticamente el ciclo de Node. Los empates se resuelven de uno en uno, no como un manifold simultáneo. Las causas de descarte se contabilizan por categoría; no se conserva una fila individual para cada candidato rechazado. Al alcanzar 32 eventos, el clon marca `eventLimit` y avanza el tiempo restante con la velocidad actual sin otra detección.

## Escenarios completos y comparación con Node archivado

Errores RMS de la pelota frente a los estados archivados de Node; el umbral de primera divergencia mostrado es error mayor que `0.01`.

| Escenario | Variante | RMS posición | RMS velocidad | Primer tick posición / velocidad >0.01 |
|---|---|---:|---:|---|
| S1, 180 ticks | A | 1.720448 | 0.156499 | 16 / 91 |
| S1 | B | 0 | 0 | — / — |
| S1 | C–F | 2.809689 | 0.154605 | 16 / 91 |
| S2, 13 ticks | A | 6.962797 | ~0 | 4 / — |
| S2 | B | 0 | 0 | — / — |
| S2 | C–F | 7.594426 | ~0 | 4 / — |
| S3, 180 ticks | A | 583.810752 | 6.848984 | 4 / 4 |
| S3 | B | 0 | 0 | — / — |
| S3 | C–F | 512.285730 | 6.489009 | 4 / 4 |

Los ceros de B reflejan la construcción del clon T1 con las decisiones del ganador factorial, no equivalencia independiente de Node ni validación física general. TOI reduce algo el RMS de S3 respecto a A, pero continúa muy lejos del oráculo y empieza a divergir en el mismo tick 4. No se interpreta esa reducción como éxito.

### S3, tick 4

Estado común antes del tick: pelota `(118.804, 148.505)`, velocidad `(38.81196, 48.51495)`, radio 10. En TOI, `classic:ballArea:top`, normal `(0,-1)`, llega a contacto en `t=0.2369372739743111`; `classic:outer:top` figura como candidato posterior en `t=0.8553033652513299`. El impulso normal registrado por el clon es `72.772425`; tras resolver, `vy=-24.257475`. El damping de fin de tick deja `vy=-24.01490025`; el avance del tiempo restante termina en `y=141.4900249`.

La captura archivada de Node termina ese tick en `(157.61596,160)` y `vy=0`. B produce ese estado porque la pasada discreta de T1 corrige primero con el plano exterior según el orden de planos. TOI, por construcción, elige el primer impacto geométrico en la trayectoria: el plano interior del área. Cambiar el orden de candidatos o `bCoef` exterior no cambia el tiempo de impacto ni la respuesta en este contacto; C, D, E y F dan el mismo estado en tick 4. Así que el resultado apoya que la semántica temporal discreta de T1 es necesaria para imitar esa captura; TOI no reproduce por sí solo el comportamiento observado. No demuestra que la física interna de Node use el algoritmo TOI ni determina su ciclo interno.

Los datos del tick, candidatos y estados exactos están en [traza S3 tick 4](PHASE3_TOI_SCENARIO3_TICK4_TRACE_FINAL_20261119.json) y las trayectorias completas en los tres archivos `PHASE3_TOI_SCENARIO_S*_FINAL_20261119.json`.

## Regresiones de control y microfixtures

- **Control de gol/red:** C–F registran un impacto con `classic:goalNet:right:back` y terminan en `x=371.79069375972307`, `vx=-0.8179069375972307`. A también hace contacto con la red, terminando en `x=372.04069375972307`. B termina en el límite exterior `x=410` y no registra ese contacto de red. TOI recupera la interacción que T1 pierde, aunque su posición final difiere por avanzar el tiempo restante después del impacto.
- **Alta velocidad:** C–F registran dos impactos, en las redes derecha e izquierda, sin atravesarlas; terminan en `x=-293.40520309292316`, `vx=6.1343020319792325`. Es un control favorable, no prueba de robustez en geometrías arbitrarias.
- **Esquina/red:** C tiene 44 impactos en 20 ticks y alcanza el máximo de 32 en el tick 17: 768 pruebas de candidatos, 102 pruebas de arco, 24 eventos de tiempo cero. D alcanza el límite en el tick 13. El impacto alterna entre `classic:outer:right` y `classic:goalNet:right:upperCurve`/`back` con impulsos diminutos. Al agotarse el límite, el resto del tick queda sin redetección. E y F no alcanzan el límite en este fixture; F termina en `(410,160)` con tres contactos, pero eso no valida el tratamiento de otras esquinas.
- **Pared derecha:** C y E registran nueve eventos de tiempo cero al alternar entre `classic:outer:right` y `classic:goalNet:right:back`; F con propiedades HBS registra uno. La combinación de orden y propiedad modifica chatter en esta geometría. El evento único no demuestra que la solución sea correcta para el manifold.
- **Contacto pelota-jugador:** TOI registra una pareja y conserva una velocidad posimpacto de aproximadamente `vx=2.726356458657437`; el estado final en 20 ticks difiere de B porque TOI recorre el tiempo restante del tick.
- **Lado opuesto:** C/D producen dos contactos y E/F tres; quedan involucrados los planos superior e inferior del área de balón. El fixture muestra sensibilidad de conteo/orden, pero no basta para certificar las reglas unilaterales del estadio.
- **14 microfixtures A–F, 20 ticks cada uno:** todos se ejecutaron en los seis clones. En los planos aislados C–F coinciden entre sí porque no hay ambigüedad de orden/propiedad en una única superficie. Las diferencias persistentes de posición frente a B son coherentes con resolver al tiempo de impacto y avanzar el resto del tick. El fixture `C_v10` es una frontera temporal concreta: B detecta el contacto al inicio del tick 2 tras terminar el tick 1 en tangencia; TOI resuelve justo en `t=1` del tick 1. Sus velocidades posteriores quedan desplazadas un tick. El fixture de lado opuesto también difiere en si se registra contacto.

Las series completas, las condiciones iniciales y los eventos por tick están en [controles finales](PHASE3_TOI_CONTROL_REGRESSIONS_FINAL_20261119.json) y [microfixtures A–F](PHASE3_TOI_MICROFIXTURES_A-F_FINAL_20261119.json). El archivo [cap de esquina](PHASE3_TOI_CORNER_EVENT_CAP_FINAL_20261119.json) conserva la traza detallada del tick 17. El control verifica el contacto con la geometría de red; este harness no ejecuta ni valida un evento de gol o marcador.

## Coste y reproducibilidad

En las mediciones instrumentadas de Studio, los promedios TOI de S1/S2/S3 quedaron aproximadamente entre `0.029` y `0.072 ms/tick` según variante; el máximo observado en esas corridas fue `0.8064 ms`. El tick de esquina que alcanzó el límite midió `0.6877 ms`. Son lecturas de `os.clock` de ejecuciones de diagnóstico, con jitter y sin un benchmark de rendimiento dedicado; quedan por debajo del presupuesto nominal de 16.67 ms a 60 Hz en estas muestras, pero no son una garantía de rendimiento.

Se repitieron S3 ticks 1–12 y coincidieron los estados; también se repitieron las 6 variantes del control de red y C del control de esquina ticks 1–17, comparando estados/eventos y excluyendo exclusivamente los campos de coste de reloj. Las tres comparaciones fueron deterministas. No se repitieron todas las combinaciones de S1/S2 y los 14 microfixtures, así que la determinación no se generaliza más allá de las corridas citadas. [Resultados finales](PHASE3_TOI_FINAL_RESULTS_20261119.json) y [estados canónicos sin redondear](PHASE3_TOI_CANONICAL_STATES_FINAL_20261119.json) registran los datos; los hashes SHA-256 están en el [manifiesto](PHASE3_TOI_FINAL_HASHES_20261119.json).

## Conclusión y siguiente paso

**Hechos demostrados:** la red del gol se detecta si hay barrido continuo; la trayectoria rápida no atraviesa ambas redes en este fixture; S3 TOI elige `ballArea:top` antes que `outer:top`; el orden y las propiedades no cambian ese impacto; la resolución secuencial puede entrar en chatter determinista en esquinas y alcanzar un límite explícito.

**Inferencia respaldada:** el ciclo temporal TOI puede ser una base para estudiar túneles y contactos dentro del tick, pero su método de resolver una única restricción y volver a detectar no trata bien las superficies casi simultáneas de esquinas/red. La diferencia con Node en S3 no se corrige con el TOI geométricamente más temprano porque la referencia corresponde a otra secuencia temporal de integración/corrección.

**Sigue abierto:** resolver contactos simultáneos con un conjunto de restricciones/manifold; fijar la semántica de tangencia exacta y contactos desde ambos lados; extender el barrido a fuerzas que cambien durante el tick; repetir todos los fixtures y escenarios con el nuevo tratamiento; comparar nuevamente con el oráculo archivado sin atribuir estados finales a operaciones internas de Node.

**Recomendación:** no ampliar todavía la campaña factorial ni cambiar el Core productivo. En un clon aparte, implementar una variante de manifold determinista para los candidatos dentro de la tolerancia temporal, primero contra esquina, pared-red, gol y `C_v10`. Solo si elimina el límite sin crear rebotes o atravesamientos debe pasar a la matriz completa S1/S2/S3 + A–F. No se modificó código productivo ni la instalación Node; Studio quedó en Edit y el Place no se guardó ni publicó.
