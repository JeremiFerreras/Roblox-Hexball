# Fase 3 — Plan de validación de movimiento de jugador y patada

## Por qué hace falta una referencia nueva

Los tres escenarios Classic comparados usan inputs de jugador en cero y no contienen eventos `onPlayerBallKick`. Por tanto, no validan aceleración, frenado, movimiento diagonal, respuesta a inversión, fuerza de patada, retroceso ni cooldown. Las cifras activas del perfil Luau (`acceleration=0,1`, `kickAcceleration=0,07`, `kickStrength=5`, `kickback=0`, damping de jugador `0,96`) no se consideran confirmadas por estas trayectorias.

## Captura de referencia

Usar una sesión privada/oráculo disponible con el estadio y propiedades fijados; registrar por `onGameTick` el estado antes/después que permita el API: tick lógico, inputs observables, posición y velocidad del jugador y balón, propiedades de disco y estado de partido. Registrar `onPlayerInputChange`, `onPlayerBallKick`, `onPositionsReset` y eventos de contacto. El callback de kick confirma el evento, pero no debe suponerse que entrega impulso o normal. El Headless Host documenta `onGameTick` a 60 veces/s y acceso a propiedades de discos; los inputs físicos requieren un cliente de prueba controlado, no hay que fingir que Headless pueda inyectar cualquier tecla.

Cada caso debe empezar con estado fijado por host (`setPlayerDiscProperties` / `setDiscProperties` cuando estén disponibles), estadio identificado por hash y todos los demás discos suficientemente lejos. Inputs de tecla se aplican con un cliente normal controlado; guardar secuencia con tick de comienzo y final. Repetir con el mismo orden y reiniciar la ronda entre ensayos. Si no se consigue un cliente de prueba sincronizado, marcar ese caso BLOQUEADO, no sustituirlo por inputs sintéticos en una recreación.

## Matriz mínima reproducible

| Caso | Estado/entrada | Registro y variable estimada | Control que aísla el caso |
|---|---|---|---|
| Aceleración | Un jugador, balón y otros jugadores lejos; reposo; dirección constante durante N ticks | `Δv/Δtick`, `v(t)`, trayectoria; ajustar recurrencia solo sobre todo el tramo | Repetir horizontal, vertical y ambas diagonales; medir magnitud de input y cambios de tecla |
| Velocidad sostenida | Mantener una dirección más allá de la rampa | curva de velocidad y valor límite observado; observar si existe cap | Comparar cardinal y diagonal; no inferir cap de tramo corto |
| Soltar/fricción | Acelerar y retirar input sin contacto | `v[k+1]/v[k]`, distancia restante, tiempo a velocidad próxima a cero | Separar damping constante, gravedad y clamp de velocidad; no llamar “fricción” a un factor sin identificar |
| Inversión | Alcanzar velocidad estable; cambiar directamente a dirección opuesta | instante de cruce por cero, aceleración durante inversión | Comparar inversión con soltar y con pulsación corta |
| Colisión jugador-jugador | Dos discos, velocidades conocidas, contacto frontal y oblicuo; sin balón próximo | posiciones/velocidades antes-después, penetración reconstruible | Repetir con masas/velocidades reversadas si el API permite preparar discos |
| Contacto jugador-balón sin kick | Acercamiento controlado, X no pulsada | evento de contacto y velocidades posteriores | Mantener distancia/velocidad; distinguir colisión normal de patada |
| Patada desde reposo | jugador quieto, balón a distancias medidas a lo largo del facing; pulsar X una vez | kick callback, `Δv_ball`, `Δv_player`, dirección y umbral espacial | Barrido de distancia alrededor del contacto; repetir cardinal/diagonal |
| Patada en movimiento | entrada constante antes del kick; velocidad inicial registrada | cambios de velocidad antes/después, kickback y dependencia de velocidad/facing | Repetir con igual estado pero dirección de desplazamiento opuesta |
| Repetición/cooldown | pulsar, sostener, soltar y volver a pulsar en ticks separados | kicks aceptados y separación mínima entre eventos | Cronometrar por ticks, sin presuponer el cooldown activo del proyecto |
| Competencia simultánea | dos jugadores llegan al balón en el mismo tick lógico; invertir orden/latencia | tick de contacto y kick aceptado, orden de eventos | Repetir desplazamientos idénticos y cambiar cuál input llega primero; sólo con un host autoritativo medible |

## Métricas y aceptación

Conservar valores crudos y calcular por tick velocidades derivadas `(p[k]-p[k−1]) / Δt`, aceleración y diferencia contra la velocidad publicada. Estimar resolución/ruido repitiendo cada estado al menos varias veces; declarar media, desviación y rango. Los límites de tolerancia se fijan a partir de esa variabilidad, no por conveniencia. Separar errores de estado inicial, timestamp de input, física y colisión.

No hay resultados medidos de jugador/patada en este lote; todo lo anterior es plan futuro. Fuente API: [Headless Host oficial](https://github.com/haxball/haxball-issues/wiki/Headless-Host) y [documentación actual de Node-Haxball](https://github.com/wxyz-abcd/node-haxball).