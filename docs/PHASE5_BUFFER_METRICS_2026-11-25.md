# Fase 5: presentación remota y métricas locales

El cliente utiliza un historial de hasta 32 poses confirmadas para los jugadores remotos. La pelota utiliza este historial cuando no hay predicción propia. El motor, el formato de paquetes y la autoridad del servidor conservan sus reglas.

## Presentación

El margen se adapta entre 2 y 6 ticks: 33,3–100 ms a 60 Hz. El reloj avanza de manera continua y no retrocede por cada paquete tardío. El cursor interpola posiciones confirmadas y nunca sobrepasa el último tick recibido. En pausas, nuevos partidos y nuevas rondas, las posiciones se muestran sin mezclar etapas.

Una interrupción congela la presentación remota. Una recuperación grande puede recolocar el cursor; se cuenta como rebuffer. Cuando el servidor reanuda después de detenerse avanzando pocos ticks, se renueva el anclaje del reloj.

El margen configurado no limita la antigüedad real durante una interrupción. La predicción propia sigue usando el mismo núcleo físico y su horizonte ya acotado. El buffer afecta la presentación remota; no decide golpes ni goles.

## Mediciones

`Players.LocalPlayer.PlayerGui.HaxballLabDebug.NetworkDiagnostics:Invoke()` devuelve un informe local con:

- ACK desde la creación original del comando hasta su confirmación recibida. Incluye espera, envío y vuelta; no es latencia física de una vía.
- RTT por eco; corrección del jugador y de la pelota sólo cuando existía un pronóstico del mismo tick.
- Antigüedad del estado, retraso visual estimado, margen adaptativo, episodios sin datos y recuperaciones.
- Inputs creados, confirmados y cancelados al cambiar de época/propietario; comandos pendientes.
- Paquetes y bytes de buffers realmente enviados/recibidos, reintentos fiables, estados rechazados y cantidad de snapshots completos.

Cada métrica conserva hasta 256 muestras. Los informes tienen p50/p95/máximo; los percentiles sin muestras quedan vacíos. La antigüedad y los retrasos se muestrean como máximo a 20 Hz; el HUD técnico se actualiza una vez por segundo sólo en Studio. En clientes de menos de 20 FPS se muestrea como máximo una vez por frame. No se rellena con muestras inventadas durante una pausa de frames.

Los bytes son payloads sin cabeceras, compresión ni multiplicación por destinatarios. Los snapshots completos de tablas sólo se cuentan: no se inventa su tamaño de transporte.

Un snapshot fiable repetido no rejuvenece la edad de la autoridad ni repite una corrección. Los comandos cancelados no se registran como confirmaciones exitosas.

## Comprobación

El runner offline carga los módulos reales sin modificar sus dependencias. `tests/offline/presentation-tests.luau` agrega 26 casos: historia, interpolación lineal, límites, pausas, época, interrupción/recuperación, percentiles, ACK y correcciones; incluye 9 trazas con 30/60/240 FPS y pérdidas del 0/5/15 %.

Las trazas usan semilla 1731, 30,2 segundos de movimiento lineal a 120 unidades/s y llegadas de 50–120 ms con posible reordenamiento. Se compara la media del error absoluto de velocidad con la interpolación anterior entre dos estados. El informe JavaScript reproducible de `work/phase5/model-results.json` muestra mejora en los nueve casos. La misma comparación se ejecuta también en las pruebas Luau.

El cliente real con adaptadores añade comprobaciones de uso del buffer, diagnóstico local, edad ante duplicados y cancelación tras reinicio. Las suites de red/servidor y el comparador físico independiente siguen formando parte de `npm test`; las mutaciones y fuzz siguen en `npm run test:quality`.

La validación de CI reconstruye el archivo .rbxlx, verifica fuentes/referencias/inventario y el round-trip. `tests/offline/quality-summary.json` identifica hashes de fuentes y resultados exactos publicados. La ejecución de GitHub Actions proporciona el registro externo reproducible.

## Límites y siguiente paso

Son pruebas de Luau con adaptadores y simulación de red, no una sesión nativa de Roblox. La mejora de suavidad de una trayectoria sintética no demuestra menor ping real ni justicia competitiva. Con pérdidas persistentes aún puede haber congelaciones y recuperaciones.

Faltan mediciones nativas en Studio con varios clientes y pruebas específicas de compensación/fairness antes de cerrar la fase 5. No se ha añadido compensación competitiva de latencia en este cambio.

## Registro comprobado

[GitHub Actions: ejecución integrada correcta](https://github.com/JeremiFerreras/Roblox-Hexball/actions/runs/45748262121), sobre `f53e21ce318fe0a3b49336a74900a832b0688faf` y el workspace formateado/reconstruido por CI: 331/331 comprobaciones en 12 grupos; 24 scripts/módulos compilados; 138 instancias con referencias resueltas y round-trip correcto. Se comprobó SHA-256 al recuperar los archivos generados. Los hashes de los cinco módulos activos modificados coinciden con el informe de calidad.

El primer intento de integración falló en una prueba nueva que comprobaba la cancelación antes de recibir el reinicio del servidor. La prueba final espera ese paso de autoridad y pasa. No se ocultó ni eliminó la comprobación.
