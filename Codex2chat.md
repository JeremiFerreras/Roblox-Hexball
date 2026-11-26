# Resumen del chat de Codex — Haxball Lab, Fase 3 (física)

Sesión de Codex del 17 al 19 de noviembre de 2026 sobre el proyecto **Football, hexball** (PlaceId `85137916104328`). El chat tiene 20 tareas tuyas y respuestas de la IA. Se quitó la salida de herramientas (comandos, JSON, logs) y el relleno.

## Objetivo de toda la sesión
Entender y reducir la diferencia de física entre nuestro `PhysicsCore2D` (Luau) y **Node-HaxBall 2.3.0** (referencia). El foco fue el **escenario 3, tick 4**: la pelota choca con el plano superior del área de balón y las dos físicas dan resultados distintos.

**Reglas que se mantuvieron todo el chat:** no tocar el Core productivo, no guardar ni publicar el Place, y no presentar análisis anteriores como resultados nuevos.

---

## Cronología

### 1. Análisis inicial de la carpeta del 17
- **Tú:** analizar la carpeta Codex del 17 y conectarte al MCP de Roblox.
- **IA:** revisó la carpeta y Studio (instancia correcta, modo Edit) sin hacer cambios. El código vivo está en Studio y la carpeta `src` solo tenía 3 scripts. Encontró `PhysicsCore2D`, el perfil Classic, la lógica de partido, el servidor de laboratorio y las regresiones. Estado de la Fase 3: **PARTIAL GO**.
- Después preguntaste "eres capaz de trabajar? y…" (mensaje cortado). La IA confirmó que sí y pidió que completaras la pregunta.

### 2. Aislar el escenario 3 y auditar planos HBS
- **Tú:** localizar el plano que causa la divergencia y microprobar A–F.
- **IA (PARTIAL GO):** el plano candidato es el superior del área de balón (normal `(0,-1)`, `y=170`). Una pelota de radio 10 lo toca con el centro en `y=160`. No pudo confirmar la causa exacta: el `planeId=1` de Node no estaba mapeado y el HBS omite el `bCoef` de los planos del área. Entregó 7 archivos.

### 3. Recuperar el entorno Node-HaxBall 2.3.0
- **Tú:** recuperar la instalación previa y correr las micropruebas.
- **IA (PARTIAL GO):** recuperó la instalación aislada en `%TEMP%`. Dos ejecuciones dieron el mismo SHA-256 byte por byte (540 ticks Classic, 180 por escenario). Las micropruebas A–F no se ejecutaron porque el harness no expone los estados internos de resolución.

### 4. Instrumentar el oráculo
- **Tú:** construir un entorno que muestre cómo Node resuelve contactos.
- **IA (PARTIAL GO):** el solver está en la función `E$` de `api.js`, sin API pública para observarlo. Propuso envolver `E$` en una copia temporal del harness (aún sin validar).

### 5. Validar el wrapper `E$`
- **Tú:** validar la instrumentación sin tocar la instalación original.
- **IA (PARTIAL GO):** el wrapper reproduce exactamente la referencia (mismo SHA, 540 estados). `E$` se llama 180 veces por escenario. En el tick 4 del escenario 3, `vy` pasa de `48.51` a `0` y `y` termina en `160`. Todavía no se ve la operación interna que lo produce.

### 6. Causa de la divergencia (hallazgo principal)
- **Tú:** resolver la divergencia usando el código y Studio.
- **IA:** **causa identificada.** Node procesa primero el **plano exterior superior** (índice 1, `bCoef=0`): lleva la pelota a `y=190` y anula `vy`. Después procesa el plano del área (índice 5) y deja `y=160`. El Core hace lo contrario: procesa primero el plano del área con `bCoef=1`, rebota la pelota y deja `vy ≈ -24.01`.

### 7. Probar el orden de planos de Node en el Core
- **Tú:** comprobar qué pasa al reproducir ese orden.
- **IA:** **no basta.** Las variantes A–D terminan igual (`y=143.206`, `vy=-24.015`) contra Node (`y=160`, `vy=0`). Error RMS de posición en el escenario 3: 583.81. La evidencia apunta a la **secuencia temporal**, no al orden.

### 8. Ciclo temporal del solver
- **Tú:** explicar por qué orden y propiedades no cambian nada.
- **IA:** **diferencia demostrada.** Node integra el tick completo (la pelota va de `y=148.5` a `197.0`) y luego resuelve contactos. El Core usa 13 subpasos de 1/780 s y detecta primero el plano interior, así que el exterior nunca se llega a procesar.

### 9. Experimento factorial: T (ciclo), O (orden), P (propiedades)
- **Tú:** evaluar los tres factores por separado y combinados.
- **IA (PARTIAL GO, NO-GO para producción):** en el escenario 3 solo coincide con Node la combinación **T1 + O1 + P1** juntas, en los 180 ticks. T1 no es seguro: en el control de gol omite el contacto con la red, y en esquina y alta velocidad da resultados distintos.

### 10. Arquitectura TOI (tiempo de impacto)
- **Tú:** probar avanzar hasta el siguiente contacto y redetectar en el tiempo restante.
- **IA (PARTIAL GO):** TOI recupera el contacto con la red, pero **no reproduce Node en el escenario 3**: elige primero el plano interior y termina en `y=141.49`, `vy=-24.015`. RMS de posición: S1 2.81, S2 7.59, S3 512.29.

### 11. Manifolds de contactos simultáneos
- **Tú:** resolver contactos repetidos de tiempo cero en esquinas.
- **IA (NO-GO):** solo entregó una auditoría preliminar. Propone probar tolerancias `1e-9`, `1e-7` y `1e-5`. Una tolerancia amplia podría agrupar contactos distintos.

### 12. Prototipo PGS y bloqueo de Studio
- **Tú:** "Continúa entonces".
- **IA:** creó un prototipo PGS aislado, pero `ExecuteLuau` devolvió `Target is not reachable`, así que no pudo validarlo en Studio.
- **Tú:** diagnosticar la conexión MCP.
- **IA:** la lectura por MCP funciona, la ejecución de Luau no. Corrigió un defecto (la restitución se recalculaba en cada iteración). Las pruebas matemáticas corrieron en una traducción a JavaScript, no en Luau.

### 13. Luau real
- **Tú:** ejecutar el PGS sin depender del MCP.
- **IA:** descargó el CLI oficial **Luau 0.747** a `%TEMP%` (hash verificado). Pasaron 14 verificaciones y el análisis estático. Las normales casi opuestas no convergen en 16 iteraciones: el solver lo reporta y conserva la velocidad original.

### 14. Convergencia
- **Tú:** estudiar las normales casi opuestas.
- **IA (NO-GO integrar con TOI):** barrido de **11.520 casos**, repetido con salidas idénticas.
  - 9.276 convergen y 2.244 fallan explícitamente.
  - Con 128 iteraciones aún fallan 324 de 2.880 casos.
  - A 179,94° el número de condición es ~3,65 millones.
  - El orden de restricciones cambia la convergencia en 102 casos.

### 15. Auditoría matemática
- **Tú:** auditar la formulación del manifold.
- **IA (NO-GO):** con varios contactos, el PGS fija los objetivos de restitución en cero y puede devolver éxito falso. Con un oráculo independiente de conjuntos activos: 480 sistemas son incompatibles con restitución por contacto, el PGS da falso éxito en 432, y 3.944 resultados exitosos no cumplen el objetivo restitutivo.

### 16. Ley restitutiva conjunta (tarea enviada dos veces)
- **Tú:** definir una ley compatible y pasiva.
- **IA:** comparó las leyes A, B, C y D. A y B son incompatibles en 480 casos y no pasivas en 2.160. **C y D son compatibles y pasivas en los 11.520 casos.** **D** es el mejor candidato: conserva los objetivos individuales cuando son factibles. Ejemplo a 179,94° con `e=0,5`: A/B dan `vy ≈ 9554` con +45,64 millones de energía, D da `vy ≈ 22,36`.
- Como repetiste el mensaje, la IA solo verificó que los artefactos existieran.

### 17. Implementar PGS-D
- **Tú:** variante independiente de PGS con la formulación D, comparada contra el oráculo.
- **IA (NO-GO integrar):** el selector coincide con el oráculo, pero el PGS **no converge en 3.706 de 11.520 casos** (limitación de iteraciones, no de la ley D). Cuando converge, coincide con el oráculo y no gana energía. Además, Node multiplica los `bCoef` de las dos superficies.

### 18. Integrar PGS-D con TOI (última tarea)
- **Tú:** avanzar a la integración experimental. Fijaste un criterio de proyecto: **el objetivo no es una física perfecta ni igual bit a bit a Node, sino una física suficientemente fiel, estable y agradable para un Haxball en Roblox.** No hay que prolongar la investigación matemática para eliminar cada imperfección teórica.
- **IA:** armó un clon con PGS-D (128 iteraciones, reducción inelástica y un último pase secuencial limitado) que marca el tick como incompleto si falla. Hubo un error en Studio (`Phase3TOICore:673 attempt to index nil with 'vx'`) y una desconexión momentánea de Studio, y siguió. Resultado parcial en la prueba de esquina: Core `y≈23.77`, `vy≈-3.94`. T1 `y=160`, `vy=0`. TOI+PGS-D terminó en 17 ticks con 1 tick incompleto, 1 límite de eventos y 26 contactos de tiempo cero.
- **El chat terminó aquí** por el límite de uso de Codex (reintento posible el 19 de diciembre de 2026). No hubo informe final de esa tarea.

---

## Conclusiones clave
1. La divergencia del escenario 3 viene del **ciclo temporal** (Node integra el tick completo y luego resuelve contactos), combinado con el orden de planos y los `bCoef`. Ninguno de los tres arregla el caso por sí solo.
2. T1 coincide con Node en el escenario 3 pero rompe otros casos. **No se adoptó nada en producción.**
3. TOI arregla el contacto con la red, pero no coincide con Node en el escenario 3.
4. El PGS tiene problemas de convergencia con normales casi opuestas. La ley restitutiva **D** es el candidato matemático más fiel.
5. Tu criterio final: priorizar fidelidad suficiente y sensación de juego sobre perfección teórica.

## Herramientas y entorno usados
Node-HaxBall 2.3.0 como oráculo, MCP de Roblox Studio (solo lectura útil, `ExecuteLuau` inestable), Luau CLI 0.747 local y un oráculo propio de conjuntos activos para validar el PGS.

## Pendiente al cortarse el chat
Terminar la batería de integración PGS-D + TOI (esquina, red, pared/red, alta velocidad, escenario 3) y decidir, con tu criterio de "suficientemente fiel", qué esquema se adopta en el Core.
