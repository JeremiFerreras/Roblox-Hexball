# Fase 3 — Decisión de calibración dinámica

## Veredicto: PARTIAL GO

Tenemos evidencia suficiente para atribuir el primer error significativo de escenarios 1 y 2 a diferencias en la cronología de integración y resolución posicional del contacto. En escenario 3 demostramos una respuesta normal distinta en el primer contacto y descartamos interferencia de jugadores, pero no sabemos asignar esa respuesta a un plano/propiedad interna concreta: el `planeId` del callback no corresponde de forma consistente a los índices de plano inspeccionados. La calibración dinámica no queda cerrada.

## Hallazgos que sí permiten avanzar

- Las condiciones iniciales del comparador y las unidades están alineadas; Core y Oracle recorren vuelo libre prácticamente idéntico hasta el primer contacto.
- Escenarios 1 y 2 conservan velocidades poscontacto equivalentes, pero no la posición final del tick. La corrección ocurre en medio de tick en Core y al resolver al final del paso en Node/Nago.
- El primer error significativo de escenario 3 es tick 4: Oracle fija componente normal `vy` en cero y Core devuelve `−24,01490025`.
- El escenario 3 de Node termina quieto en `(410,160)` tras contactos de plano; no es una congelación del juego ni un gol.
- El HBS Haxball Classic exportado declara `bCoef=0` para los cuatro planos exteriores; el perfil actual usa `0,1`. Es una discrepancia comprobable, aunque no causa el primer error de escenario 3.
- El núcleo activo tiene subpasos adaptativos y no usa los nombres de configuración `collisionIterations`, `maxCollisionSubsteps` y `collisionSubstepRadiusFraction` expuestos por `Physics2D.Config`.

## Incógnitas que impiden GO

1. Identidad interna y bCoef efectivo del plano del evento en escenario 3.
2. Si esa parada normal es propiedad del plano, consecuencia de otro estado interno o una particularidad de Node-Haxball 2.3.0.
3. Contactos equivalentes aislados contra un único plano con varias velocidades y con el mismo estado antes de impactar.
4. Impactos equivalentes de discos con estado precontacto igual; los contactos de replay disponibles ocurren después de la divergencia.
5. Aceleración, frenado, diagonal, kickback, fuerza y cooldown: no hay inputs de jugador ni kicks en los escenarios comparados.
6. Cualquier equivalencia con el Haxball oficial. Node-Haxball es un oráculo independiente; no hay aquí un conjunto de estados de cliente oficial para comparar.

## Decisión técnica ahora

No modificar radios, masa, damping, bounce, kick strength ni el solver productivo. Tampoco reducir tolerancias. Conservar la matriz de evidencia y repetir una prueba mínima de plano de un solo contacto antes de proponer cualquier ajuste. Primero hacer que el Oracle y Core comiencen el tick con estados idénticos y confirmar que golpean la misma superficie; después variar una sola propiedad cada vez en una copia diagnóstica aislada.

Para poder cerrar dinámica hace falta que el caso de escenario 3 sea explicable y que las pruebas de contacto tengan resultados repetibles. Para comenzar movimiento y patadas hace falta una nueva referencia controlada con inputs de jugador observables. Los criterios concretos están en `PHASE3_PLAYER_KICK_VALIDATION_PLAN.md`.

## Ejecución y estado del proyecto

Comparación Core por tick: 180/180, 13/13 y 180/180 filas frente a Oracle; escenario 2 termina antes del gol (tick 14). Sin frames faltantes en los archivos de Oracle utilizados. No se editaron fuentes, propiedades ni objetos; no se guardó ni publicó el place. Studio terminó en Edit. No se volvió a ejecutar la suite 47/47, por lo que su estado actual no se presenta como revalidado.

**Conclusión:** avanzar con diagnóstico de contacto aislado y obtener una referencia de jugador/kick; no cerrar Fase 3 ni afirmar réplica casi 1:1 todavía.