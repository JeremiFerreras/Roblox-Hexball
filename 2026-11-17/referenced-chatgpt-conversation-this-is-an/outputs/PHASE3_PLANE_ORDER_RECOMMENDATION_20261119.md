# Recomendación técnica — orden de contactos

**No cambiar permanentemente el orden global de planos ni el bCoef activo a partir de estos resultados.**

La prueba controlada muestra que B (orden Node) no modifica la trayectoria de ninguno de los tres fixtures de regresión tick por tick. En S3, incluso D conserva en tick 4 el contacto del plano interior y `vy=-24.014900`. Por eso el orden de iteración no puede reproducir por sí solo el paso Node observado: Node ya ha integrado hasta penetrar el plano exterior antes de resolver; Core detecta/corrige por subpasos antes de llegar a ese plano.

Cambiar el bCoef exterior a cero tampoco corrige el tick 4, aunque cambia el impulso registrado de contactos exteriores que sí ocurren más adelante. En la esquina, el impulso exterior cambia de 21 a 20 y cambia el estado final del microfixture; en S3 tick 35 cambia el evento de impulso, sin cambio capturado de posición o velocidad. El contacto por el lado opuesto confirma que el orden Node puede registrar un plano adicional.

## Siguiente experimento recomendado

En una copia diagnóstica, controlar una sola variable temporal: conservar geometría, orden, bCoef y demás parámetros, pero evaluar la integración y la resolución como una pasada del tick completa comparable a Node. Registrar por contacto pre/post, plano, velocidad normal, impulso y corrección; comparar en particular tick 4 y repetir S1–S3, lado opuesto, esquina, balón-jugador y goles. Mantener un modo actual de subpasos como control. Solo después de aislar la operación temporal conviene evaluar un conversor de orden/propiedades.

## Riesgos y límites

La prueba es sobre Node-HaxBall 2.3.0 como referencia independiente, no sobre el cliente oficial de Haxball. La fuente textual del estadio y la respuesta de `require` en caché de Studio discreparon en máscaras/grupos; los mundos temporales normalizaron esos flags a la fuente/HBS inspeccionada. Antes de reutilizar el harness, resolver esa discrepancia sin editar el perfil ni el lugar activo. No hubo cambios productivos ni guardado/publicación del Place.

