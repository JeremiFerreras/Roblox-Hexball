# Fase 3 — Calibración final de Classic

Fecha: 2026-11-18  
Place: Football, hexball — PlaceId 85137916104328  
Estado final de Studio: Edit. No se guardó ni publicó el place.  
Referencia geométrica: [classic.hbs, commit 4b9724f49fe0ff87ad3f111eb91b208020d96d73](https://github.com/haxball/haxball-issues/blob/4b9724f49fe0ff87ad3f111eb91b208020d96d73/stadiums/classic.hbs)

## Conclusiones

La geometría Classic y sus máscaras están trazadas al HBS fijado. La regresión actual se ejecutó en una sesión Play limpia: 47/47 aprobadas. La comparación adicional contra los tres fixtures Classic de HaxballGym muestra errores dinámicos grandes. La fase geométrica queda cerrada; la calibración física independiente sigue abierta.

La referencia es Node-Haxball 2.3.0, no una medición directa del cliente oficial. El fixture solo almacena posiciones del balón, sin velocidades ni eventos. No se cambiaron parámetros ni scripts: la evidencia no permite atribuir cada divergencia sin ambigüedad a solver, estado de jugadores, reinicio o implementación de referencia.

## Método

El fixture exacto, copiado del ZIP, tiene SHA-256 7d612957764a076d506f53c4dd8d7fd39381e3db261cb399a812f6eb7d110e37.

En DataModel Server de una sesión Play limpia se cargaron los ModuleScripts PhysicsCore2D y ClassicStadium2D. El mundo utilizó unidades Haxball, el perfil Classic fijado, balón en (0,0), velocidad de cada caso, radio 10, masa inversa 1, damping 0.99 y rebote 0.5. Se avanzaron 180 ticks a 60 Hz. El comparador activo usó el límite predeterminado de 64 subpasos, igual al mundo que crea LabServer; se hizo un segundo ensayo diagnóstico con un subpaso por tick. Ambos fueron in-memory; ningún objeto ni script fue modificado.

Se compararon las posiciones numéricas sin redondeo. Para cada tick se conserva error absoluto X/Y; las métricas resumen incluyen RMS por eje y RMS euclidiano. firstNonBitExactTick marca la primera desigualdad numérica exacta: puede ser solo diferencia IEEE-754 y no se usa como tolerancia. No se inventó un umbral de aceptación.

La comparación no incluyó jugadores ni reglas de gol/reinicio. El oráculo sí crea jugadores en spawn, pero no guarda sus coordenadas; por ello la igualdad del estado completo no quedó demostrada.

## Trayectorias

Los datos por tick, posiciones completas de referencia y del laboratorio, velocidades disponibles del laboratorio y eventos de contacto del laboratorio están en [CLASSIC_ORACLE_COMPARISON.json](CLASSIC_ORACLE_COMPARISON.json).

| Velocidad inicial | Ticks | RMS posición X | RMS posición Y | RMS euclidiano | Máximo euclidiano | Primera diferencia exacta |
|---|---:|---:|---:|---:|---:|---:|
| (8,55) | 180 | 51.6033 | 20.4161 | 55.4952 | 121.9728 | 1 |
| (-30,45) | 180 | 106.2843 | 23.6616 | 108.8863 | 321.4855 | 1 |
| (40,50) | 180 | 20.7021 | 135.4360 | 137.0091 | 213.3749 | 1 |

El error exacto en tick 1 incluye diferencias mínimas de coma flotante; no significa por sí solo una divergencia física. En los impactos, las diferencias pasan a ser visibles y se propagan.

- (8,55): el plano superior contacta en tick 3 y la posición Y queda en 160, como en el fixture. En el impacto inferior de tick 16, el núcleo adaptativo acaba en Y=-157.63484 mientras el fixture registra -160. La secuencia es compatible con resolver durante subpasos y continuar el movimiento restante del tick; no establece cuál coincide con el cliente oficial. Más adelante el error crece en contactos adicionales.
- (-30,45): el núcleo detecta el plano superior en tick 4 y la curva inferior de la red izquierda en tick 14. El fixture salta en tick 164 desde (-388.16587,41.41589) a (0,0) y permanece allí hasta el final. La posición anterior está dentro de la zona de gol de Classic; gol/reinicio es una inferencia, pues no hay evento asociado. El RMS euclidiano antes del salto, ticks 1–163, fue 48.8188 unidades.
- (40,50): el fixture conserva Y=160 y queda fijo en (410,160) desde tick 11 hasta 180. Es la esquina superior derecha de los límites del estadio, pero el fixture no contiene velocidad ni callback para explicar el estado. Se clasifica DESCONOCIDO y no cuenta como rebote validado.

El fixture no incluye tiempos ni callbacks de contacto, por lo que los contactos del núcleo no prueban que el punto equivalente del fixture corresponda al mismo evento. No se atribuyeron impactos de poste o red como hechos cuando no hay datos para confirmarlos.

## Geometría, grupos y máscaras

El perfil StadiumReference2D y el montaje ClassicStadium2D coinciden con el HBS fijado: seis planos, catorce segmentos y cuatro postes. Incluyen márgenes exteriores x=±420, y=±200; límites del área del balón x=±370, y=±170; abertura y=±64; redes en x=±380/±400; postes en (±370,±64), radio 8; arcos de kickoff de radio 75. En el HBS, width=420 y height=200 son propiedades del estadio, no las dimensiones totales de una cancha rectangular.

Flags activos: ball=1, red=2, blue=4, redKO=8, blueKO=16, wall=32, kick=64, score=128. Máscaras auditadas: all=63, player=39, ball=63, post=63 y kickoffBarrier=6. El contacto bidireccional exige (A.group & B.mask) != 0 y (B.group & A.mask) != 0. Rojo/azul disputan balón, chocan entre sí y con paredes/postes; el balón choca con paredes/postes; barreras kickoff interactúan con los grupos KO según equipo y fase. No se alteraron estos valores ni la geometría durante esta tarea. El detalle está en el [informe geométrico anterior](PHASE3_CLASSIC_CALIBRATION.md).

Ensayos previos de pared/poste documentaron impactos perpendiculares, diagonales, rasantes, esquina simultánea, alta velocidad, rebotes consecutivos, postes frontales/diagonales/tangenciales, kickoff y boca de gol. Son resultados internos, no validaciones del motor oficial. Rendimiento previo medido: 0.117 ms/tick en 5v5 en reposo y 0.217 ms/tick con diez discos solapados, en las cargas detalladas en el informe anterior.

## Regresión

La suite se ejecutó en Play limpio con LabRegression.Run(Physics2D) y se guardó el resultado completo, incluidos los 47 casos individuales, en [PHASE3_FINAL_REGRESSION.json](PHASE3_FINAL_REGRESSION.json): 47 aprobadas, 0 fallidas, allPassed=true. La suite confirma las expectativas internas codificadas, no fidelidad externa.

## Evidencia y parámetros

| Elemento | Estado / confianza | Evidencia |
|---|---|---|
| Geometría Classic HBS | VERIFICADO, alta | Archivo congelado y perfil implementado. |
| Grupos y máscaras | VERIFICADO, alta para flags/HBS | Flags, matriz bidireccional y regresiones. |
| Jugador, kickoff y goles | Verificado internamente, media | Casos de laboratorio; reglas/input oficiales no certificados. |
| Damping 0.99, radio 10, masa inversa 1, rebote 0.5 del balón | Activos/provisionales | La trayectoria no coincide y no aísla los parámetros. |
| Aceleración y patada de jugadores | No validado por estos fixtures | No hay inputs ni estados de jugadores en las posiciones almacenadas. |
| Subpasos y orden del solver | Diferencia medida respecto a Node-Haxball; original desconocido | Varias posiciones de impacto cambian con la estrategia intratick. |
| Gol/reinicio en (-30,45) | Inferido | Salto abrupto desde el volumen de gol a (0,0); fixture sin evento. |
| Punto detenido (410,160) | Desconocido | Plateau de 170 muestras sin velocidad/evento. |
| Igualdad de spawns | Desconocida | El fixture no guarda posiciones de jugadores. |
| Fidelidad contra el motor oficial | Pendiente | No existe medición oficial sincronizada con estos casos Classic. |

## Decisiones y cierre

- No se alteraron coeficientes ni código del juego. Los grandes errores están medidos respecto de Node-Haxball, pero los datos incompletos no separan todas sus causas.
- La tolerancia cero de HaxballGym prueba el port Rust contra su fixture Node-Haxball, no contra el cliente oficial.
- Se cierra la parte geométrica de fase 3 como verificada contra el HBS. **No se declara cerrada la calibración dinámica.**
- Baseline conservado: geometría Classic fijada, máscaras verificadas, valores activos del laboratorio sin cambios y suite 47/47. Las diferencias se documentan explícitamente.
- Para buscar fidelidad alta faltan referencias Classic que incluyan posiciones y velocidades, tick/eventos de contacto, spawns reales y manejo explícito de goles/reinicios; idealmente del motor oficial o de fixtures con procedencia directa demostrable.
