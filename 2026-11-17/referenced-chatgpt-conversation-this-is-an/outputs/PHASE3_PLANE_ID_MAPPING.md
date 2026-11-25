# Mapeo de planeId=1

## Resultado: sigue UNKNOWN

La captura reproducida usa Node-HaxBall 2.3.0 y registra frame 4 callback `onCollisionDiscVsPlane(..., planeId=1)`. La reconstrucción geométrica localiza el contacto en el plano superior ball-area: HBS `normal=(0,-1), dist=-170`, radio 10, centro y=160. Esa es evidencia del plano espacial que produjo la colisión, pero no demuestra qué representa el entero `planeId`.

El código de API empaquetado está minificado en `node_modules/node-haxball/src/api.js`. El runner básico no expone el objeto plano ni normal/profundidad del callback. En esta sesión no quedó establecida una asignación verificable entre el entero y la estructura compilada del estadio. No equiparar planeId con el índice HBS (HBS cero-based candidato 5) ni con orden de geometría sin seguir el constructor y callback interno con una sonda.

Siguiente paso: en una copia temporal, instrumentar el constructor HBS→runtime y wrapper del callback para registrar identidad/posición del plano entregado. Si la estructura no conserva identidad, asignar IDs observacionales al recorrer el array runtime y validar contra una prueba de un solo plano. No cambiar estadio productivo.
