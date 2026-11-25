# Contexto de continuidad — Haxball Lab / Roblox

**Preparado:** 2026-11-18  
**Propósito:** dar a otra IA o desarrollador el contexto de proyecto que cambia decisiones técnicas, sin obligarle a repetir la conversación completa. Este documento resume hechos, resultados, decisiones del usuario y pendientes; no sustituye a las capturas o informes detallados enlazados abajo.

## 1. Proyecto y objetivo

- Experiencia de Roblox: **Football, hexball**.
- **PlaceId:** `85137916104328` · **UniverseId:** `10777655598`.
- Lugar de edición verificado: Roblox Studio conectado por MCP. En la última sesión quedó en **Edit**.
- Objetivo: juego competitivo inspirado en Haxball clásico, partido 5v5 (10 jugadores), vista superior 2D, discos para jugadores y balón, sin avatares humanos ni animaciones de fútbol 3D. Controles iniciales PC: WASD y X para patear.
- Prioridad de diseño: sensación física, consistencia competitiva y una única autoridad del partido. Separar simulación lógica de presentación visual. Las unidades del estadio son unidades lógicas; cualquier conversión a studs debe afectar solo la representación/cámara.
- La física autorizada para el laboratorio es un motor 2D matemático propio en Luau. No sustituir silenciosamente la simulación por Roblox Physics.
- Preferencia comunicada por el usuario para trabajar en Roblox: **MCP con Studio; no usar Rojo**. La preferencia no autoriza guardar, publicar o alterar el lugar por sí sola.

## 2. Estado de desarrollo que debe conservarse

El código Roblox está en la instancia de Studio, no en los informes de `outputs`. La carpeta `work/node-haxball-source` es una copia de investigación de Node-Haxball, no el juego.

Módulos conocidos en Studio:

- `ServerScriptService.HaxballLab.PhysicsCore2D` — núcleo lógico 2D activo.
- `ServerScriptService.HaxballLab.Physics2D` — fachada/configuración y rutinas auxiliares; confirmar siempre la ruta activa.
- `ServerScriptService.HaxballLab.ClassicStadium2D` — instala geometría Classic y postes.
- `ServerScriptService.HaxballLab.MatchRules2D`, `LabRegression`, `LabServer`, `LabClient`.
- `ReplicatedStorage.HaxballLab.StadiumReference2D` — referencia/configuración del estadio y física.
- Se verificó que `Physics2D.MatchCore == PhysicsCore2D` en la sesión previa.

**No asumas que los números históricos certifican el código actual.** Al retomar, lista las instancias de Studio y confirma nombre/PlaceId antes de leer o ejecutar; revisa el estado y el código real. El usuario ha pedido conservar el lugar sin guardar/publicar durante las investigaciones. La última fase solo ejecutó simulaciones en memoria y dejó Studio en Edit.

## 3. Fases y decisiones

| Etapa | Estado al cierre de esta conversación |
|---|---|
| Laboratorio físico inicial | Se construyó y probó iterativamente; sirve para ensayar entradas, discos, contactos y depurar. Los test internos solo verifican el comportamiento esperado por el propio laboratorio. |
| Consolidación del núcleo | Existían pruebas internas para uno/múltiples discos, goles/reinicios y 5v5. Hubo una ejecución registrada de 47/47, pero **no se volvió a ejecutar en la última auditoría dinámica**. No presentar ese resultado previo como una prueba recién corrida. |
| Fase 3: cancha y calibración Classic | **PARTIAL GO; abierta.** Geometría versionada y parte del movimiento/contacto comparados con Node-HaxBall. No hay certificación del cliente oficial. |
| Fase 4: partido local | Aún no debe considerarse iniciada por la última decisión; incluye reglas locales, gol/reset/Last Touch si se autoriza. |
| Fases de red/5v5 final | Posteriores. No mezclar con el diagnóstico físico actual. |

El plan de fases compartido por el usuario fue: 1 cerrar laboratorio; 2 consolidar núcleo; 3 fijar cancha/calibrar; 4 partido local; 5 servidor autoritativo/red; 6 escalar a 5v5; 7 presentación; 8 cierre/publicación.

## 4. Referencias físicas y procedencia

### Estadio

- Referencia Classic congelada: `stadiums/classic.hbs`, commit [`4b9724f49fe0ff87ad3f111eb91b208020d96d73`](https://github.com/haxball/haxball-issues/blob/4b9724f49fe0ff87ad3f111eb91b208020d96d73/stadiums/classic.hbs).
- El diseño actual de estadio declara 6 planos, 14 segmentos y 4 discos estáticos de poste. Confirmar propiedades individuales al auditar una futura modificación.
- Datos de una captura Oracle incluyen `ballPhysics: "disc0"`; balón en índice/disc 0, postes en 1–4 y jugadores posteriores asociados mediante `playerId`.
- Hay una diferencia literal pendiente: HBS exportado declara `bCoef=0` en los cuatro planos exteriores; `StadiumReference2D` activo usa `0.1`. Está documentada; **no se cambió** en la auditoría más reciente.

### Node-Haxball / HaxballGym / juego oficial

- Node-Haxball 2.3.0 fue instalado/verificado anteriormente en un entorno temporal independiente. Commit de la copia inspeccionada: `4d4b88f1e5e25d484d27819ee6a4699720bda164`; fuente minificada `src/api.js` incluye el mundo Nago (`N.prototype.E$`).
- Node-Haxball es una implementación independiente/reconstrucción. Sus resultados son **RECONSTRUIDOS**, no mediciones directas del cliente oficial. No llamarlos “física oficial 1:1”. [Repositorio fijado](https://github.com/wxyz-abcd/node-haxball/tree/4d4b88f1e5e25d484d27819ee6a4699720bda164).
- Nago fue útil para reconstruir orden y fórmulas del solver; la procedencia/licencia/ingeniería inversa requieren cautela. No copiar su código al juego publicado sin revisión de derechos.
- HaxballGym y sus fixtures son fuentes derivadas de Node-Haxball según la auditoría previa; la precisión interna de sus tests no certifica igualdad con el Haxball oficial.
- La documentación oficial Headless indica `onGameTick` a 60 veces/s. Eso permite afirmar la frecuencia de tick lógico documentada, no frecuencia de render, simulación interna/substeps o envío de paquetes. [Headless Host](https://github.com/haxball/haxball-issues/wiki/Headless-Host).

## 5. Evidencia y diagnóstico dinámico más reciente

Artefacto principal: [`PHASE3_MICROBENCHMARK_RESULTS.json`](PHASE3_MICROBENCHMARK_RESULTS.json), SHA-256 `af1717d32fab62ec60e5a7e79246ce94cb48442b997e75256867cd9d0fc9ac7f`. Tiene 180 + 13 + 180 pasos comparables, posición/velocidad por tick de pelota y jugadores, errores, eventos Oracle y contactos Core.

Fuentes de entrada:

- `ORACLE_FULL_TICK_TELEMETRY.json`, SHA-256 `74e7e0f832a6e91d17765f1419199374209c5ebe7156ae26bc80355d67765ca8`.
- Replay fixture SHA-256 `7d612957764a076d506f53c4dd8d7fd39381e3db261cb399a812f6eb7d110e37`.
- La réplica Node-Haxball 2.3.0 reprodujo el fixture byte por byte en dos ejecuciones; se capturaron 540 ticks Classic, frames 1–180 por escenario, sin huecos ni duplicados.
- La comparación Luau se hizo en memoria en Studio Play, con cero inputs, y al terminar se devolvió a Edit. No se cambió código ni configuración del place.

| Caso | Resultado por tick |
|---|---|
| 1, velocidad `[8,55]` | Primer error >0,01 en tick 16, al contactar el límite inferior. Velocidad poscontacto coincide casi exactamente; Node termina `y=-160`, Core `y=-157,634840`. Después, el contacto balón/jugador aparece en Core tick 91 y Oracle tick 92. RMS de posición del balón 1,720448, máximo 2,411610. |
| 2, `[-30,45]` | Comparado solo hasta tick 13, antes del gol Node en tick 14. Tick 4: Oracle `y=160`; Core `y=152,061190`, mismas velocidades prácticamente exactas. Offset vertical 7,938810. RMS 6,962797. El reset posterior a `(0,0)` no es trayectoria física: ocurrió tras gol. |
| 3, `[40,50]` | Primer contacto tick 4. Oracle `(157,615960;160)`, `vy=0`; Core `(157,615960;143,206363)`, `vy=-24,014900`. Sin jugadores el Oracle continúa hasta reposo `(410,160)` desde tick 11. RMS de posición de balón a 180 ticks 583,810752, máximo 754,692242; el RMS abarca la divergencia acumulada. |

**Lectura causal:** escenario 1/2 demuestra diferencia de cronología posicional: Core resuelve durante subpasos y continúa el resto del tick; Node/Nago avanza el paso y corrige contacto de forma secuencial. Escenario 3 tiene además una respuesta de velocidad normal distinta. El callback reporta `planeId=1` allí y `5` en contactos de mismo punto geométrico de los otros casos; no mapear ese ID directamente al índice del array. La causa interna exacta de `vy→0` queda **DESCONOCIDA**.

El Core activo usa subpasos adaptativos; `Physics2D.Config` declara `collisionIterations`, `maxCollisionSubsteps`, `collisionSubstepRadiusFraction`, pero `PhysicsCore2D.stepWorld` no consume esos nombres tal como están: usa `maxSubsteps` y una fracción interna de 0,5; no hay loop de `collisionIterations` en ese paso activo. Está documentado como diferencia del código, no se corrigió.

Estado final de fase 3: **PARTIAL GO**. No modificar radios, damping, restitución, masa, patada o solver para forzar RMS pequeño. Hacen falta microcasos de un solo plano con mismo estado previo y una explicación verificable del escenario 3.

## 6. Movimiento de jugador, patadas y red: no validados por estos datos

Los tres escenarios Classic usados para la comparación no tienen inputs de movimiento ni kicks. Por tanto no validan aceleración, velocidad máxima, diagonal, frenado, inversión, kick strength, kickback o cooldown. Los valores visibles en el perfil (por ejemplo acceleration `0.1`, kickAcceleration `0.07`, damping de jugador `0.96`, kickStrength `5`, kickback `0`) son valores activos/provisionales del proyecto, no parámetros oficiales demostrados por esos replays.

La idea de predicción con ping digital 50–200 ms se discutió como trabajo futuro de justicia competitiva; no está implementada/verificada por estos resultados. La autoridad del servidor, inputs secuenciados, reconciliación y visualización interpolada requieren una fase propia. No prometer igualdad perceptiva con cualquier ping.

## 7. Repetición/telemetría y laboratorio local

- El usuario aportó `replay_1794954651243.hbr` y `telemetry_1794955691342.json`; mantenerlos privados y no subirlos a servicios externos.
- El HBR se identificó como HBR2 v3, `totalFrames=12368`; `Replay.readAll()` y `Replay.read()` con Node-Haxball navegador reconstruyeron `12368/12368`, sin duplicados ni huecos. Resultados bajo `outputs/hbr-extractor/results/`.
- La telemetría es otro archivo/sesión y estadio `Big`; no asumir que coincide con el HBR ni tratar sus ticks como los mismos frames físicos sin probar su reloj. Su auditoría está en `outputs/hbr-extractor/results/telemetry_analysis.json` y `analysis_report.json`.
- El extractor usa recursos locales copiados desde la versión fijada; no precisa npm ni servicio externo para leer la repetición.

## 8. Bugs/incidencias resueltos (solo resumen)

- El primer probe de escritura falló por permiso de Windows; al reejecutarlo con Node `fs/promises`, pudo crear, leer y eliminar el archivo temporal en `outputs`.
- La página del extractor resolvía `/` como ruta literal `**` y daba ENOENT; el servidor se corrigió para mapear `/` explícitamente a `index.html` y restringir las rutas servidas/escrituras a su carpeta permitida. La extracción completa posterior quedó validada.
- El intento de generar archivos con el entorno de orquestación falló por falta de `TextEncoder`/`btoa`; se cambió a escritura PowerShell con here-string/UTF-8, sin modificar el repositorio fuente.
- No se estableció una sala privada Headless fiable debido al bloqueo de WebRTC/NAT en el entorno probado. Se dejó de insistir en esa conexión y se usaron replays/datos locales. No reiniciar diagnósticos de router/puertos/WebRTC como parte de calibración, salvo petición nueva y explícita.

## 9. Conversaciones/instrucciones que cambiaron el trabajo

| Solicitud del usuario | Efecto útil en el proyecto |
|---|---|
| Brief inicial: réplica 2D fiel, física y red investigadas antes de construir | Fijó el producto: discos, top-down, PC WASD/X, 5v5; investigación por evidencia y separación lógica/visual. |
| Autorización de trabajo en Roblox y uso de Studio/MCP; preferencia “sin Rojo” | Se inspeccionó y trabajó en la instancia Studio; no sincronizar con Rojo en este flujo. Confirmar siempre place antes de operar. |
| Cambio de plan tras bloqueo del Headless | En lugar de depender de una sala WebRTC, se usaron archivos HBR/JSON y Node-Haxball local como oráculo reconstruido, no oficial. |
| Petición de verificar fidelidad frente a HaxballGym y el original | Se dejó claro que HaxballGym/Node-Haxball no certifican el cliente oficial; se adoptó comparación por tick y clasificación de evidencia. |
| Aprobación del laboratorio y fases, luego inicio de Fase 3 Classic | La implementación avanzó hasta un núcleo con regresiones y geometría Classic; la calibración externa sigue abierta. |
| Última petición de diagnóstico de divergencia | Produjo los informes `PHASE3_*` y el veredicto PARTIAL GO; no se modificó el solver. |
| Petición actual: crear contexto transferible para otras IA | Este documento es el artefacto de continuidad; no autoriza guardar/publicar el place ni hacer cambios adicionales al juego. |

## 10. Qué leer primero al retomar

1. Este documento.
2. [`PHASE3_DYNAMIC_CALIBRATION_DECISION.md`](PHASE3_DYNAMIC_CALIBRATION_DECISION.md) — veredicto/pending.
3. [`PHASE3_FIRST_DIVERGENCE_REPORT.md`](PHASE3_FIRST_DIVERGENCE_REPORT.md) — comparación causal y métricas.
4. [`PHASE3_CONTACT_SOLVER_ANALYSIS.md`](PHASE3_CONTACT_SOLVER_ANALYSIS.md) — código y orden del solver.
5. [`PHASE3_PARAMETER_EVIDENCE_MATRIX.json`](PHASE3_PARAMETER_EVIDENCE_MATRIX.json) — fuente/estado de cada parámetro.
6. [`PHASE3_MICROBENCHMARK_RESULTS.json`](PHASE3_MICROBENCHMARK_RESULTS.json) — datos por tick; comprobar SHA antes de analizarlo en otro entorno.
7. [`PHASE3_PLAYER_KICK_VALIDATION_PLAN.md`](PHASE3_PLAYER_KICK_VALIDATION_PLAN.md) — qué hace falta para calibrar movimiento/kick.
8. [`PHASE3_CLASSIC_CALIBRATION.md`](PHASE3_CLASSIC_CALIBRATION.md), [`PHASE3_FINAL_CALIBRATION.md`](PHASE3_FINAL_CALIBRATION.md), [`PHASE3_FINAL_REGRESSION.json`](PHASE3_FINAL_REGRESSION.json) — historial geométrico y regresiones previas. El 47/47 es histórico, no una regresión recién ejecutada.
9. `ORACLE_230_REPRODUCIBILITY.md`, `ORACLE_ANOMALY_ROOT_CAUSE.md`, `ORACLE_FULL_TICK_TELEMETRY.json` — procedencia del oráculo y eventos.

## 11. Siguiente paso recomendado

Sin modificar el motor productivo, construir una comparación diagnóstica mínima de **un balón + un único plano**, con geometría y bCoef explícitos iguales, varios estados de aproximación y captura antes/después del mismo tick. Primero reproducir el escenario 3 e identificar qué superficie/propiedad genera `vy=0`; repetir después los contactos de escenarios 1/2. Si los resultados coinciden al igualar el contacto, atribuir la diferencia a configuración; si no, aislar integración/orden del solver. Después se necesitan fixtures nuevos de input de jugador y patadas para calibrar aceleración y kickback. Solo con evidencia decidir correcciones y repetir la suite.

**No afirmar:** “1:1”, “física oficial certificada” o “fase 3 cerrada”. El estado sustentado es PARTIAL GO.