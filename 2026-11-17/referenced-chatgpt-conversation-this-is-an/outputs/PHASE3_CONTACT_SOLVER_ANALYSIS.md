# Fase 3 — Auditoría del solver y los contactos

## Node-Haxball 2.3.0 / Nago incluido

Fuente examinada: `node_modules/node-haxball/src/api.js` en el paquete aislado 2.3.0, commit de distribución `4d4b88f1e5e25d484d27819ee6a4699720bda164`. El archivo minificado contiene `N.prototype.E$` cerca del byte 2.383. Su código ejecuta, en este orden:

1. Recorre todos los discos y actualiza posición `B += C·I`; actualiza velocidad `I = Z·(I+V)` (damping aplicado a velocidad más gravedad).
2. Recorre discos en orden de inserción. Para cada disco, prueba pares posteriores; corrige penetración distribuyéndola por masa inversa y aplica respuesta normal solo si la velocidad relativa normal es entrante. La escala de rebote del par usa `1 + a₁·a₂`.
3. Para el disco actual, prueba planos en orden: corrige posición según la distancia firmada y el radio, calcula `v·n`, y cambia solo la componente normal si es entrante. Sigue con segmentos y después vértices; las colisiones se resuelven inmediatamente y llaman al callback tras la actualización.
4. Ejecuta dos pasadas separadas para juntas.

El método no contiene un bucle de subpasos ni una iteración global de contactos en `E$`. Esto caracteriza el código Node/Nago auditado; no demuestra por sí solo el algoritmo privado del cliente oficial. El callback público `onCollisionDiscVsPlane` expone IDs/argumentos, no normales, penetración o impulso. En el `src/api.js` de esta versión no se encontraron callbacks `onBeforeCollisionDiscVsPlane` ni `onAfterCollisionDiscVsPlane`.

## PhysicsCore2D activo en el place

Fuente leída en Studio sin editar: `ServerScriptService.HaxballLab.PhysicsCore2D`; conexión activa `Physics2D.MatchCore == PhysicsCore2D`. `ClassicStadium2D.install` desactiva límites rectangulares simplificados e instala planos, segmentos y postes.

Orden de `Core.stepWorld`:

1. Entrada/patada.
2. Calcula subpasos: `ceil(maxSpeed / max(0.5, minRadius·0.5))`, limitado por `world.config.maxSubsteps` (predeterminado 64).
3. Por cada subpaso avanza posiciones `v/substeps`; procesa cada disco en orden, pares dinámicos, bounds, planos y segmentos. Cada contacto corrige penetración y aplica inmediatamente la velocidad normal entrante. Repite el solver en los siguientes subpasos.
4. Después de todos los subpasos aplica una vez gravedad y damping y aumenta el tick.

`Physics2D.Config` declara `collisionIterations`, `maxCollisionSubsteps` y `collisionSubstepRadiusFraction`; el `stepWorld` activo no consume esos nombres: lee `maxSubsteps` y fija internamente la fracción a 0,5. No hay un bucle `collisionIterations` en el solver activo. En los ensayos se observaron 11–13 subpasos con velocidades iniciales altas. Esto es una divergencia de implementación/configuración que debe conservarse visible; no se alteró.

El núcleo activo usa producto de bCoef en pares y estática (`1 + disc.bCoef·geometry.bCoef`). `Physics2D` también conserva funciones auxiliares distintas: `resolveDiscs` usa `min(a.bounce,b.bounce)` y `step` tiene otra integración por ejes. No son la ruta activa del comparador citado; no deben confundirse con `MatchCore`.

## Diagnóstico causal

### Contactos de plano en escenarios 1 y 2

La respuesta de velocidad poscontacto coincide hasta redondeo. La divergencia principal es espacial: Node hace el avance lógico y luego proyecta la penetración al límite; Core detecta durante subpasos, rebota/proyecta en medio del avance y continúa consumiendo el resto de la fracción temporal. El resultado ya no queda necesariamente sobre el plano al final del tick. Los resultados medidos son `y=-160` frente a `−157,634840` en escenario 1 tick 16 y `y=160` frente a `152,061190` en escenario 2 tick 4.

El orden de damping y colisión es distinto: Node amortigua en la primera pasada y luego resuelve contactos; Core amortigua tras completar contactos del tick. Para gravedad cero y una respuesta lineal de plano, escalar velocidad por damping y restitución puede conmutar, lo que explica que esos ejemplos conserven la velocidad. Esto no permite generalizar a múltiples discos, gravedad o varios impactos en un tick.

### Contacto de escenario 3

La diferencia no es solamente la posición remanente: en tick 4 Node deja `vy=0`, mientras Core termina `vy=−24,014900`. El perfil del juego declara `bCoef=1` para `classic:ballArea:top`, y su pelota `bCoef=0,5`; la fórmula activa de Core produce justamente un rebote de magnitud cercana a la mitad de la velocidad entrante. Eso explica el resultado de Core. La respuesta de Node equivale a retirar por completo la velocidad normal en ese evento, pero el callback ID no mapea coherentemente a los índices que se inspeccionaron; no se afirma si lo causa el bCoef interno, una rama del motor o una particularidad de la captura. Los contactos similares de escenarios 1/2 sí rebotan. **Causa física final del escenario 3: parcialmente atribuida, no cerrada.**

El HBS de Classic en la telemetría declara `bCoef=0` explícitamente para sus cuatro planos exteriores, mientras el perfil activo tiene `0,1` para esos planos. Es una discrepancia literal demostrable de configuración, pero no explica por sí sola la divergencia inicial del tick 4 del escenario 3.

## Micropruebas disponibles y límites

- Vuelo libre: ticks 1–3 de los tres escenarios, sin contactos; posición/velocidad coinciden hasta alrededor de 1e-13.
- Plano superior: contactos controlados por la trayectoria en escenarios 1, 2 y 3; escenarios 1/2 coinciden en velocidad y difieren en posición, escenario 3 difiere en velocidad y posición.
- Contacto disco-disco: hay contactos observados en los recorridos (por ejemplo, escenario 1 Core tick 91 y Oracle tick 92); no es una prueba aislada de masas/restitución porque las posiciones de impacto ya difieren.
- Plano exterior derecho: Oracle queda en reposo en escenario 3 tick 11; Core no está en la misma trayectoria, por lo que no es comparación equivalente.
- Esquina de dos planos, poste aislado, incidencia rasante y velocidades extremas: no quedaron ensayos comparables nuevos en esta ejecución.

No se usan normales/impulsos de Node que su API no entrega. La lista de contactos Core sí contiene normales/penetración calculadas por el propio Core, lo cual no es una observación independiente del oráculo.

## Conclusión de solver

Queda demostrado que Core y Node tienen cronologías de contacto distintas; ello basta para explicar las discrepancias de posición de los escenarios 1/2. El escenario 3 exige resolver primero la identidad/propiedad efectiva del plano o repetirlo con un fixture mínimo equivalente antes de tocar bCoef. La estabilidad de diez jugadores y las pruebas internas previas no reemplazan esta comparación física independiente.

Fuentes: [`PhysicsCore2D` local en Roblox Studio](../); [Node-Haxball 2.3.0, `src/api.js` fijado](https://github.com/wxyz-abcd/node-haxball/blob/4d4b88f1e5e25d484d27819ee6a4699720bda164/src/api.js); [Headless Host API](https://github.com/haxball/haxball-issues/wiki/Headless-Host).