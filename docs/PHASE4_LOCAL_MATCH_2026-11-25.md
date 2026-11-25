# Fase 4 — partido local, avance implementado el 25/11/2026

## Resultado y alcance

Se implementó un controlador de partido local `LocalMatch2D`, conectado al `LabServer` real y ejecutable sin servicios Roblox. La simulación 5v5 ahora inicia con saque, procesa goles y último toque, congela pausas, recoloca jugadores y balón, asigna el saque al equipo que recibió el gol y repite el ciclo. Esta entrega cubre gran parte de la fase 4; no certifica todavía la experiencia visual o de control dentro de Studio.

## Comportamiento

- Inicio normal y botón Reset: cuenta atrás de saque inicial para rojo. La API admite empezar con azul.
- Estados: `kickoff` (cuenta atrás), `playing` (puede conservar un saque pendiente), `goalPause` y `finished` (si se configura límite de goles).
- Durante cuenta atrás y pausa no se ejecuta física; posiciones, velocidades y estados de patada quedan congelados/neutros. El tick del partido continúa, sin reutilizar trayectorias de gol anteriores.
- Los controles de movimiento recibidos durante el bloqueo se conservan para el siguiente estado. Una X mantenida durante el bloqueo requiere soltar y volver a pulsar antes de patear.
- Al terminar la cuenta atrás se permiten movimientos con las barreras de saque activas. El rival no puede patear. Un toque del equipo que saca que mueve el balón, con o sin X, retira las barreras en ese mismo tick.
- Un cruce válido incrementa el marcador una vez. El gol conserva una copia del último toque, incluido un posible autogol. El último toque se limpia al reponer para la ronda siguiente.
- Tras la pausa se restauran las diez posiciones de inicio, balón, máscaras, velocidades y patadas. El equipo que recibió el gol saca.
- `round` identifica las reposiciones. El cliente no interpola desde la posición anterior a un reinicio y descarta controles artificialmente demorados de la ronda anterior.
- El reloj de juego solo avanza durante juego abierto; no cuenta pausa, cuenta atrás ni espera por el primer toque del saque.
- `scoreLimit` opcional termina el partido después de la pausa del gol definitivo; `restart(team)` limpia marcador, ganador, último gol/toque y reloj. No hay límite activado por defecto ni se ha añadido interfaz de configuración.

Los tiempos conservan decisiones previas del laboratorio: 90 ticks de pausa y 30 de cuenta atrás, configurables en `LocalMatch2D.attach`. No se presentan como tiempos medidos de Haxball oficial.

## Correcciones de integración

Antes el servidor seguía ejecutando colisiones durante las pausas y solo bloqueaba inputs, lo que permitía correcciones posicionales. Ahora los estados bloqueados no invocan el motor.

Antes se descartaban controles recibidos durante el bloqueo, aunque el cliente solo transmite cuando cambian. Ahora se conservan estados de movimiento, con bloqueo específico de patada mantenida.

El cliente calculaba `ball` interpolado sin asignarlo a `ballDisc.Position`: corregido. También se elimina la interpolación a través de una reposición.

La geometría numérica ClassicReference230 se comparte entre física y presentación mediante ReplicatedStorage; la entrada antigua del servidor sigue disponible. El cliente dibuja segmentos, arcos, postes y líneas del área del balón desde esos datos. Las curvas se muestrean con paso máximo pi/48. Las partes visuales no colisionan ni participan en consultas físicas. Se alinearon las líneas exteriores existentes a x=±210/z=±100 studs y altura 11.

Los botones de escenarios físicos siguen iniciando directamente en `playing`, sin cuenta atrás que borre las velocidades de sus fixtures. El arranque normal y Reset sí usan el saque inicial.

## Verificación ejecutada

`cd tests/offline && npm ci --ignore-scripts --no-audit --no-fund && npm test`

- Compilación de los 16 scripts/módulos Luau, incluidos cliente y servidor.
- 47/47 regresiones existentes.
- 75/75 comparaciones físicas frente a Node-Haxball 2.3.0: 22.870 ticks por motor; error máximo cero en posición/velocidad, kicks y cruces de gol comparados. Se conservó el resultado previo al introducir las reglas.
- 19/19 pruebas de partido local, incluidos 20 ciclos completos alternados, saques de ambos equipos, barreras a velocidad normal de jugador, último toque y autogol, bloqueo de X mantenida, límite de goles/reinicio y límites de línea de gol.
- Dos simulaciones locales de 12.000 ticks cada una: diez jugadores, física real, inputs programados, goles y pausas; estado final idéntico y estados finitos.
- 4/4 comprobaciones del cuerpo real de LabServer, ejecutado con adaptadores de Players, señales, Heartbeat y RemoteEvents: inicialización 5v5, movimiento recibido durante cuenta atrás, gol/pausa/reset y snapshots de diagnóstico.
- Curvas visuales verificadas numéricamente sobre el radio físico, uniones exactas, continuidad de muestreo y transformación de coordenadas.
- Reconstrucción y comparación estructural del RBXLX con el árbol editable actualizado.

Los adaptadores de servicios no son una emulación completa de Roblox y no miden red, carga real, RenderStepped, cámaras ni recursos. La prueba larga comprueba determinismo de su estado final, no igualdad de cada evento entre ambas corridas.

## Pendiente

Abrir el RBXLX actualizado en Studio y probar controles, aspecto, cámara, legibilidad y escala; comprobar el dibujo de redes y postes en pantalla. Repetir la integración con los servicios reales y varios clientes. La ejecución del cuerpo del cliente se compila pero no se ejecuta en esta batería; sus funciones puras de geometría sí se ejecutan. No se da fase 4 como validada integralmente en Roblox ni se inicia la fase 5.

La política discreta conserva las limitaciones de la referencia a velocidades artificiales elevadas: no se atribuye a las barreras una garantía antitúnel general. El comportamiento local de pausas, permisos de saque y final del partido es política explícita del proyecto, sin certificación del cliente oficial.

El lugar actualizado está en `Roblox Hexball.rbxlx`. La versión previa a fase 4 se conserva en `archive/Roblox-Hexball-before-phase4.rbxlx`.
