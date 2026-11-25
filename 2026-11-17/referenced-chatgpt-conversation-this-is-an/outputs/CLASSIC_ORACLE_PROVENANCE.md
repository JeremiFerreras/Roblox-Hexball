# Procedencia del fixture HaxballGym

Fecha de auditoría: 2026-11-18  
Commit solicitado: 1781914b79ccad18a65367d66de4645412405bce  
Clasificación: NODE_HAXBALL_REFERENCE, no medición directa del cliente oficial.

## Archivos y huellas

Se leyó el ZIP proporcionado directamente, sin modificarlo ni descargarlo otra vez. El fixture se copió byte por byte a outputs/hbr-extractor/results/analysis/nh_ball_trajectories.json.

| Archivo | SHA-256 |
|---|---|
| haxballgym/tests/fixtures/nh_ball_trajectories.json | 7d612957764a076d506f53c4dd8d7fd39381e3db261cb399a812f6eb7d110e37 |
| headless-bot/nh_oracle.js | 4992592e984af2451f21b1e7b0913656f009ed6fb45da4b9ee336bf19cf53be0 |
| headless-bot/package.json | 9caf6236fe008bbfcc5c028e21c30f84375280f193e3488f5b7f4cd68084148e |
| headless-bot/package-lock.json | 25a0592f990abf94340600078074f32b2ff6fd95b1794a7b3ec939f2a95288f3 |
| haxballgym/tests/test_real_engine.py | c6e6b46715a735bb36a9dda76141b41293a1842b22315f133aae7b1b0caa7a63 |
| ARCHITECTURE.md | 90b617209cd4efad2ce634356298782bde3f7fa1b36b2cb735b1d792a715bfbe |

El ZIP no incluye .git ni otra prueba criptográfica del SHA del árbol completo. El código de la prueba coincide con la descripción disponible en el enlace fijado, pero no puedo certificar que todos los bytes del ZIP correspondan a ese commit exacto. El JSON de comparación conserva esta limitación.

## Versión de Node-Haxball

headless-bot/package.json declara node-haxball: ^2.3.0. El package-lock.json incluido resuelve exactamente 2.3.0, con tarball https://registry.npmjs.org/node-haxball/-/node-haxball-2.3.0.tgz. Así, la dependencia queda fijada por el lockfile.

Esto identifica la versión declarada por el lockfile; no convierte Node-Haxball en el cliente oficial ni demuestra equivalencia. La copia local separada de Node-Haxball estudiada indica versión 2.3.1, pero esa no es la versión resuelta por el lockfile del ZIP.

## Qué hace realmente nh_oracle.js

El archivo importa Room y Utils desde Node-Haxball. Para cada caso:

1. Busca un estadio integrado por nombre: Classic, Big, Rounded, Hockey o Huge.
2. Crea Room.sandbox, instala el estadio, crea jugadores rojos y azules, los asigna a equipos e inicia el juego.
3. Copia room.gameState; toma physicsState.discs[0] como balón y escribe directamente sus componentes de velocidad inicial.
4. Ejecuta gs.runSteps(1) repetidamente y añade solo [ball.pos.x, ball.pos.y] a ball_traj.

No registra posiciones iniciales de jugadores, estados de velocidad, callbacks de colisión, goles, reinicios, contactos ni más información temporal. El comentario afirma que los jugadores quedan en spawn y no alcanzan el balón, pero las posiciones de spawn y distancias no se guardan. En la comparación de Studio se omitieron jugadores para aislar la física del balón; no se demostró equivalencia del estado completo.

## Qué significa TOL = 0

test_real_engine.py carga ball_traj, crea TransitionEngine, lo reinicia, copia player_pos de snapshot, establece el balón en (0,0) con la velocidad del caso y avanza el motor Rust un paso por llamada a step. Calcula max(abs(rust - oracle)) y exige 0.0.

Por tanto, cero significa igualdad bit a bit entre posiciones producidas por ese port Rust y los números del fixture, en esos escenarios. No compara el fixture con el cliente oficial durante la prueba. Tampoco compara velocidades, eventos o estado oficial. “Motor real” y “1:1” son afirmaciones del proyecto; el dato auditable es que el fixture se generó mediante Node-Haxball 2.3.0.

## Fixture y anomalías

El fixture contiene siete escenarios de 180 pasos: tres Classic y cuatro de otros estadios. Los Classic comienzan en (0,0) con velocidades (8,55), (-30,45) y (40,50). Registra posiciones, no velocidades.

- Para (-30,45), la muestra 163 es (-388.16587355410803, 41.41589290491347), y la 164 salta a (0,0), donde permanece hasta la 180. El punto anterior está dentro del volumen de la portería izquierda. Es INFERIDO que el salto corresponde a gol/reinicio, apoyado por el comentario del oráculo; no hay evento en el fixture que lo demuestre.
- Para (40,50), el balón queda exactamente en (410,160) desde el tick 11 hasta el 180. El punto es una esquina de los límites físicos del perfil Classic, pero no hay velocidad ni evento para determinar si es un contacto, un estado detenido o una limitación del generador. Causa DESCONOCIDA.
- Los escenarios no están etiquetados como rebote perpendicular, tangencial o impacto en poste. No se les atribuyen esos contactos sin datos que los confirmen.

## Fuentes

- [Oracle nh_oracle.js fijado al commit](https://github.com/HaxballGym/HaxballGym/blob/1781914b79ccad18a65367d66de4645412405bce/headless-bot/nh_oracle.js)
- [Lock de la dependencia](https://github.com/HaxballGym/HaxballGym/blob/1781914b79ccad18a65367d66de4645412405bce/headless-bot/package-lock.json)
- [Prueba test_real_engine.py](https://github.com/HaxballGym/HaxballGym/blob/1781914b79ccad18a65367d66de4645412405bce/haxballgym/tests/test_real_engine.py)
- [Fixture de trayectorias](https://github.com/HaxballGym/HaxballGym/blob/1781914b79ccad18a65367d66de4645412405bce/haxballgym/tests/fixtures/nh_ball_trajectories.json)
- [Arquitectura HaxballGym](https://github.com/HaxballGym/HaxballGym/blob/1781914b79ccad18d66de4645412405bce/ARCHITECTURE.md)
- [Repositorio Node-Haxball](https://github.com/wxyz-abcd/node-haxball)

## Veredicto de procedencia

El fixture sirve para comparar el laboratorio con una reconstrucción Node-Haxball 2.3.0, pero no es una medición directa e indiscutible del motor oficial. El ajuste bit exacto de HaxballGym acredita su port frente al fixture, no la fidelidad oficial de este.
