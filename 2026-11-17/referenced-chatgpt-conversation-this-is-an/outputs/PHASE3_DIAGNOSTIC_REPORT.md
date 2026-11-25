# Fase 3 — Diagnóstico de divergencias

## Conclusión

La alineación temporal del comparador es correcta: tres escenarios, 180 pasos por escenario, 540 estados. La fila tick 1 es posterior al primer paso y corresponde al primer punto del fixture; no hay estado inicial duplicado ni desplazamiento de índices. Esto no valida que ambos mundos tengan exactamente los mismos discos o el mismo estadio serializado.

La reproducción independiente solicitada con Node-Haxball 2.3.0 quedó bloqueada por falta del paquete local. No se descargó ni instaló nada. Las diferencias existentes son contra un fixture identificado por HaxballGym como generado con Node-Haxball, no contra una medición directa del cliente oficial.

## Alineación y configuración

- Fixture SHA-256: 7d612957764a076d506f53c4dd8d7fd39381e3db261cb399a812f6eb7d110e37.
- 3 casos Classic, 180 puntos cada uno; ticks 1–180 consecutivos.
- Ambos caminos colocan el balón en (0,0), aplican velocidad antes del paso y capturan tras cada paso.
- Unidades lógicas del estadio; no se convierte la física a studs.
- Oráculo: jugadores 1v1, 1v1 y 3v3. Laboratorio: balón solo. El comentario del oráculo dice que jugadores quedan en spawn, pero no se guardan sus posiciones ni contactos.
- El oracle selecciona el Classic predeterminado por nombre y no serializa el HBS. El HBS Classic vendorizado por HaxballGym tiene conteos 6 planos, 14 segmentos y 4 postes, pero spawnDistance=277.5, frente a 170 en el perfil Studio inspeccionado. Hace falta verificar el HBS exacto del build del oracle antes de afirmar setup idéntico; esto no demuestra causalidad dinámica.

## Procedencia y reproducción

nh_oracle.js inicializa Room.sandbox, elige un estadio de Utils por nombre, asigna jugadores/equipos, inicia, copia gameState, cambia physicsState.discs[0].I y llama gs.runSteps(1) en cada iteración. package-lock.json fija node-haxball 2.3.0 con tarball e integrity SRI. package.json declara ^2.3.0; la versión concreta procede del lockfile.

No se regeneró el fixture: node-haxball no se puede resolver localmente; solo hay fuente 2.3.1 y faltan dependencias. El ZIP no tiene .git, así que no se certifican criptográficamente todos los blobs del commit solicitado. No se afirma equivalencia oficial.

## Resultados numéricos

### Caso 1 — velocidad [8, 55]

- 180/180 filas alineadas; checks PASS.
- RMS posición adaptativa: 55.495243 unidades; máximo: 121.972803.
- Primera diferencia adaptativa >0,01: tick 16.
- Oráculo: 1 rojo(s), 1 azul(es); laboratorio: 0 jugadores.
- Contactos listados son del solver de laboratorio y no demuestran contactos del oracle.

### Caso 2 — velocidad [-30, 45]

- 180/180 filas alineadas; checks PASS.
- RMS posición adaptativa: 108.886334 unidades; máximo: 321.485544.
- Primera diferencia adaptativa >0,01: tick 4.
- Oráculo: 1 rojo(s), 1 azul(es); laboratorio: 0 jugadores.
- Tick 164: salto de 390.369084 desde [-388.16587355410803, 41.41589290491347] a [0, 0]. Gol/reinicio sin confirmar; causa desconocida.
- Contactos listados son del solver de laboratorio y no demuestran contactos del oracle.

### Caso 3 — velocidad [40, 50]

- 180/180 filas alineadas; checks PASS.
- RMS posición adaptativa: 137.009122 unidades; máximo: 213.374895.
- Primera diferencia adaptativa >0,01: tick 4.
- Oráculo: 3 rojo(s), 3 azul(es); laboratorio: 0 jugadores.
- Alcanza [410,160] en tick 11 y permanece idéntico durante 169 transiciones. Velocidad/eventos del oracle: ausentes; causa desconocida.
- Contactos listados son del solver de laboratorio y no demuestran contactos del oracle.

## Interpretación

firstNonBitExactTick marca cualquier diferencia binaria. En el primer estado del caso [8,55], Y difiere aproximadamente 7,1e-15; no es una divergencia física relevante. Los RMS y máximos se mantienen intactos y no se ajustaron coeficientes.

El caso [-30,45] salta a (0,0) en tick 164 y repite ese punto hasta tick 180. Es compatible con reinicio tras gol, pero no hay evento de gol/reset y se clasifica como desconocido.

El caso [40,50] llega a (410,160) en tick 11 y repite el mismo punto por 169 transiciones. Sin velocidad, contacto ni estado de partido del oracle, no puede afirmarse que estuviera detenido ni por qué quedó ahí.

## Propiedades físicas activas inspeccionadas

El perfil activo del laboratorio conserva estos valores provisionales: jugador radio 15, masa inversa 0.5, damping 0.96, rebote 0.5, aceleración 0.1, aceleración con patada 0.07, damping al preparar patada 0.96, fuerza de patada 5, kickback 0; balón radio 10, masa inversa 1, damping 0.99, rebote 0.5; alcance adicional de patada 4. El núcleo usa paso lógico 60 Hz y máximo predeterminado de 64 subpasos en el comparador adaptativo. Son valores activos del proyecto, no parámetros certificados del Haxball original. El fixture no expone velocidades ni eventos para ajustar estos valores.

## Proyecto

Studio verificado: Football, hexball, PlaceId 85137916104328, Edit. No se modificaron scripts, propiedades ni place; no se guardó ni publicó. El JSON disponible registra 47/47 regresiones aprobadas; no se repitió la suite en esta auditoría.

## Veredicto

Alineación aprobada. Las trayectorias de laboratorio divergen del fixture (RMS adaptativo: 55.50, 108.89, 137.01 unidades). No cambiar parámetros todavía: faltan rerun verificable con Node-Haxball 2.3.0, estado/eventos por tick y equivalencia del conjunto de jugadores. Fidelidad dinámica pendiente.
