# Fase 5 — primera implementación de red, protocolo v1

Estado: base implementada y probada fuera de Studio. **No se declara cerrada la fase 5 ni validada la latencia real o la equidad competitiva.**

## Implementado

- Física autoritativa a 60 ticks/s, publicación de estados nominalmente a 30 Hz. Se serializa una vez y se difunde el mismo buffer a todos. Las reposiciones pueden adelantar una actualización. Si un Heartbeat recupera varios ticks, solo publica el estado más reciente.
- `StateStream` es UnreliableRemoteEvent. Cada snapshot es completo e independiente: perder uno no rompe la siguiente actualización.
- InputStream envía cambios de controles y retransmisiones cortas por UnreliableRemoteEvent. Input, fiable, respalda comandos pendientes tras 150 ms; no duplica su aplicación.
- Controles digitales empaquetados, secuencia, tick informativo y época `matchId/round`. Confirmación por jugador en el snapshot. Los timestamps del cliente no retroceden la física ni dan prioridad a una patada.
- Cola acotada a una ventana de 32 secuencias, máximo ocho comandos por paquete, presupuesto por jugador y una transición aplicada por tick. Duplicados y contradicciones se rechazan. Mensajes de otro partido/ronda no se aplican.
- Press/release cortos se conservan como transiciones independientes, incluso si viajan en un solo paquete. Un refresco periódico evita depender de un único mensaje al soltar una tecla.
- Tras 30 ticks sin controles válidos se neutraliza el estado. La dirección mantenida puede recuperarse mediante un keepalive validado; X requiere una liberación real después de una interrupción o reposición para no generar una patada automática.
- Control fiable para bootstrap, resincronización y ping de aplicación. Las transiciones de partido y cambios de ocupantes generan snapshots completos fiables. En Studio se añaden diagnósticos a 1 Hz; en modo público se desactivan comandos de laboratorio y grabación de historial.
- El cliente rechaza estados viejos, repetidos y épocas desconocidas; espera el bootstrap fiable para cambiar de ronda. Resets y cambios de fase no se interpolan a través de estados incompatibles.
- Predicción completa del mundo usando exactamente el mismo `PhysicsCore2D`, ahora compartido en ReplicatedStorage. La entrada anterior del servidor permanece como shim. Se restauran posiciones, velocidades, máscaras y estados internos de patada de los diez jugadores; se reaplica el historial local y se mantienen los últimos controles conocidos de los rivales.
- Solo el jugador propio y el balón usan la previsión visual. Los otros jugadores se interpolan. Las correcciones pequeñas se suavizan visualmente durante unos 50 ms; el estado físico predicho se corrige inmediatamente. No se adjudican goles localmente.
- Extrapolación limitada a 18 ticks después del último estado confirmado y desactivada al superar 300 ms sin autoridad. Cambiar FPS no aumenta la velocidad de predicción en la prueba 30/60/240 FPS.

## Tamaño exacto del estado

| Parte | Bytes |
|---|---:|
| Cabecera: versión, época, tick, fase, reloj, marcador y último toque/gol | 40 |
| Balón: x/y/vx/vy, cuatro float64 | 32 |
| Diez jugadores: cuatro float64 + ack + cooldown + flags + máscara + input | 410 |
| **Total del buffer de estado** | **482** |

No se redondea la física a float32 ni se cuantizan posiciones. El paquete de controles mide entre 21 y 84 bytes (1–8 comandos).

A 30 publicaciones/s son **14.460 bytes/s por cliente** de datos de estado, y 144.600 bytes/s para diez destinatarios. Esto excluye cabeceras, compresión y tráfico propio de Roblox, bootstrap, controles y mensajes fiables. No es una medición de la red real ni un porcentaje de ahorro respecto al protocolo anterior. Las pruebas con cambios de ronda registraron 904 snapshots en 30 segundos por las actualizaciones inmediatas de época.

## Pruebas ejecutadas

- 31 pruebas específicas de protocolo, pérdida de release, secuencias, corrupción de datos, límites, timeout/reanudación, igualdad de precisión, predicción y orden de llegada.
- Matriz de RTT 20/50/100/150/200 ms y pérdida 0/5/15 %, con jitter, duplicados, desorden y una ráfaga de pérdidas del canal no fiable. El respaldo fiable se modela como entrega eventual; no emula internamente el transporte de Roblox.
- 12 simulaciones del mundo y diez clientes de modelo: 4 semillas × 3 tasas de pérdida. Cada simulación recorre 1.800 ticks de servidor, con RTT distintos de 20 a 200 ms por jugador. Total: 21.600 ticks autoritativos y 216.000 iteraciones de clientes, además de los pasos internos de previsión. Comprobaron recepción, ACKs, límites y convergencia al terminar las acciones.
- 12 pruebas del cuerpo real de LabServer con servicios adaptados, 13 del cliente conectado y 2 de modo público.
- 47 regresiones, 75 comparaciones físicas con Node 2.3.0 y 20 pruebas locales anteriores siguen pasando.
- Campaña de calidad: 64 partidos pseudoaleatorios anteriores, 11 comprobaciones del runner y **15 mutaciones detectadas**. Las mutaciones incluyen aceptar otra época, saltarse el primer input y reducir accidentalmente la precisión del snapshot.
- Compilación de 22 scripts/módulos y verificación de integridad del lugar actualizado.

Los adaptadores no abren conexiones Roblox ni reproducen sus colas, compresión, render, InputActions reales o coste nativo. Los ensayos con diez clientes ejecutan los módulos reales de simulación/protocolo/predicción, no diez procesos de Roblox.

## Equidad y pendientes

La autoridad, las mismas reglas, el presupuesto por jugador y la aplicación por tick forman la base de equidad. El resultado para inputs recibidos en el mismo tick no depende de cuál de los paquetes de esos jugadores se entregue primero. No se concede una acción retroactiva usando el ping declarado por el cliente.

**20 ms y 200 ms todavía no son equivalentes.** Los inputs que llegan tarde se aplican más tarde. La previsión mejora la respuesta percibida, sin cambiar el resultado autorizado. El núcleo conserva el orden físico de la referencia; no se certifica ausencia de sesgos en todos los empates físicos.

Quedan para la siguiente etapa:

1. Aceptación en Studio con varios clientes y Network Simulation: controles, pérdidas, reinicios, sobrecarga y límites de UnreliableRemoteEvent.
2. Medición real de bytes, colas, percentiles de confirmación/corrección, CPU y memoria. El RTT mostrado es un eco de aplicación, no el ping físico puro de la ruta.
3. Un buffer de interpolación con historial y ajuste por jitter más completo; v1 adapta el intervalo de interpolación a los dos últimos snapshots.
4. Ensayos simétricos competitivos y evaluación de una ventana común de compensación. No se implementó rollback del servidor ni se iguala artificialmente a todos con la peor conexión.
5. Perfilar el coste de re-simular el mundo en dispositivos reales. Se soporta el perfil Classic/60 Hz actual; no se han validado perfiles físicos cambiados en caliente o mapas arbitrarios.

## Reproducción

```sh
cd tests/offline
npm ci --ignore-scripts --no-audit --no-fund
npm test
npm run test:quality
npm run format:check
npm run format:check:luau
cd ../..
python tests/validate_place.py
python tools/place.py verify
```

Resultados: `network-results.json`, `network-world-results.json`, `server-public-results.json` y el resumen `quality-summary.json`. Las pruebas por defecto incluyen la campaña de red completa.

Abrir `Roblox Hexball.rbxlx` para probar la actualización. La versión anterior se conserva en `archive/Roblox-Hexball-before-phase5.rbxlx`.
