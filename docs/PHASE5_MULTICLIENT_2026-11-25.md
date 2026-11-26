# Fase 5: diez clientes reales mediante adaptadores

Se ejecutan diez copias independientes del código completo de `LabClient` y una del código completo de `LabServer`. Las clases de predicción, física, codec, colas, buffer y métricas son los módulos de producción. Sus fuentes y dependencias no se reescriben para la prueba. Cada cliente tiene su propia GUI numérica, input, reloj, predicción e historial. Las primitivas visuales y los servicios/transporte son adaptadores: no se abren procesos Roblox ni se renderiza la interfaz.

## Escenarios

Cuatro mundos de 16 segundos simulados, cada uno con diez clientes simultáneos (640 segundos-cliente). El planificador avanza a 240 Hz, el servidor a 60 Hz y los clientes a 30/60/120/240 FPS. Los RTT nominales van de 20 a 200 ms, con jitter de ±12,5 ms por dirección, pérdidas de datagramas de 0/5/15 %, duplicados del 10 % entre los datagramas enviados y posible reordenamiento. Hay relojes locales con desplazamientos diferentes. El cuarto escenario invierte las conexiones y reparte el retraso 25/75 % entre subida y bajada.

En el caso de interrupción, los clientes 3 y 7 pierden datagramas de ambos sentidos durante 1,2 segundos. Los mensajes fiables se retrasan y conservan orden por canal. No se modelan el control de congestión, compresión, cabeceras ni reintentos internos de Roblox.

A los seis segundos se usa el escenario de tiro del laboratorio para forzar el ciclo de gol; a los doce se reinicia el partido, con tráfico anterior todavía en tránsito. Los controles pasan a neutro a los nueve segundos. El cierre compara las posiciones visibles de los diez jugadores con el servidor, además de comprobar época, ACK y ausencia de controles pegados. El gol preparado es una herramienta de prueba, no una afirmación sobre goles producidos por jugadores humanos.

## Cambios implementados

- Los reintentos de comandos pendientes idénticos pasan de un máximo de 60 a 30 Hz. Los cambios nuevos de controles y el avance de la ventana de comandos conservan el límite de 60 Hz; la recuperación fiable mantiene su condición de 150 ms, sujeta al siguiente frame y al límite de envío existente. Los keepalives confirmados siguen a 10 Hz. No cambió el formato del paquete.
- El cliente espera el bootstrap antes de decidir qué protocolo de input enviar. Desaparecen los inputs legacy iniciales que el servidor de partida rechazaba.
- Se corrigió un salto visual al superar 300 ms sin autoridad: antes se abandonaba la última predicción y se dibujaba una posición antigua. Ahora se conserva el pronóstico final, limitado por `NetPrediction` a 18 ticks. No se simula más allá del límite ni se otorga autoridad al cliente.
- El diagnóstico local expone época/tick/edad de autoridad, puesto, secuencias enviadas/confirmadas y tick predicho. Esto permite comprobar el cliente real sin acceder a sus variables privadas ni añadir mensajes de red.

## Medición de tráfico

La comparación desactiva únicamente el nuevo filtro de reintentos mediante la mutación `duplicate_pending_throttle_removed`. Conserva las mismas configuraciones y semillas. Al cambiar la cantidad de paquetes, las extracciones aleatorias asociadas a paquetes pueden diferir: no es una comparación causal de latencia con una traza externa idéntica.

| Escenario | Bytes antes | Bytes después | Ahorro de inputs | Mayor p95 ACK antes → después |
|---|---:|---:|---:|---:|
| 0 % de pérdida | 72894 | 52287 | 28.3 % | 241.7 → 237.5 ms |
| 5 % de pérdida | 73722 | 52869 | 28.3 % | 241.7 → 245.8 ms |
| 15 % + corte de 1,2 s (clientes 3 y 7) | 81837 | 57519 | 29.7 % | 1170.8 → 1166.7 ms |
| 5 % + conexiones invertidas/asimétricas | 71982 | 53226 | 26.1 % | 258.3 → 258.3 ms |

Los bytes son la suma de payloads de input de los diez clientes durante 16 segundos. El ahorro del 26–30 % corresponde a **inputs**, no a todo el tráfico ni al ping. Se mantienen 481 datagramas de estado por mundo, de 482 bytes cada uno: 231842 bytes antes de multiplicar por destinatarios. Las tablas fiables y cabeceras no están incluidas.

ACK es el intervalo entre crear un comando y recibir su confirmación. Incluye cola, ida y vuelta y espera de snapshot; no es sólo RTT. La interrupción explica los p95 de aproximadamente 1,17 segundos. Espaciar un reintento perdido puede añadir hasta unos 16,7 ms frente al intervalo previo; un control nuevo no espera ese intervalo adicional. No se promete una reducción del ping.

## Comprobaciones y reproducción

`multiclient-results.json` contiene 48 comprobaciones (12 por escenario), con ACK p50/p95/máximo, correcciones, antigüedad máxima, bytes y tamaño de cola por cliente. Se verifican propiedad de cada puesto, horizonte de predicción, memoria limitada, conservación de inputs creados = confirmados + cancelados + pendientes, recuperación de época, controles neutros y convergencia visual final.

`client-adapter-tests.luau` incluye la regresión del salto visual: falló antes de corregirlo y pasa después. Las pruebas de red añaden el límite de duplicados, respuesta a nuevos controles, recuperación fiable, cambio de época/ventana y el hecho de que un timestamp válido diferente no permite rebobinar ni aplicar más de una transición por tick. Las mutaciones reintroducen el salto y eliminan el filtro para demostrar que las pruebas detectan ambos fallos.

Desde la raíz:

```sh
npm ci --prefix tests/offline
npm run test:multiclient --prefix tests/offline
npm run compare:multiclient --prefix tests/offline
npm test --prefix tests/offline
npm run test:quality --prefix tests/offline
```

La comparación usa un wrapper Node para ser reproducible también sin sintaxis de variables de shell POSIX. `multiclient-baseline-results.json` es la referencia con el filtro desactivado; no se mezcla con el informe positivo de calidad. `multiclient-comparison.json` guarda las cifras completas.

## Qué queda en fase 5

La simulación permite cerrar este bloque de recuperación y optimización de inputs. No demuestra igualdad competitiva entre conexiones distintas: aplica las mismas reglas de autoridad y no confía en el timestamp para rebobinar. No se añadió rollback ni retraso artificial común al servidor. Aún hay que validar transporte/rendimiento nativos y decidir/probar una política de compensación competitiva con Roblox Studio, varios clientes y Network/MicroProfiler.

## Validación final ejecutada

`npm test` y `npm run test:quality` terminaron correctamente en Node v24.22.3 con luau-web 1.5.1. El informe agregado contiene **386/386 comprobaciones en 13 grupos**, incluidas 48 multicliente, 35 de red, 17 del cliente y 17 mutaciones detectadas. Los 24 scripts/módulos compilan; las 138 instancias del place tienen fuentes coincidentes, IDs únicos y referencias resueltas. También pasaron formato, hashes del inventario y round-trip XML.

Estos resultados son de ejecución local con adaptadores; no se atribuyen al registro anterior de GitHub Actions ni a Roblox Studio. Los hashes de fuente actuales están en `tests/offline/quality-summary.json`.
