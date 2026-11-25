# Recomendación temporal del solver — fase 3

## Conclusión causal

La hipótesis de ciclo temporal diferente quedó demostrada por inspección del código y una prueba aislada pasiva:

- Node 2.3.0 mueve todos los discos por el tick completo, amortigua/actualiza velocidades y después procesa contactos una vez. En tick 4 alcanza el plano exterior superior antes de resolver.
- PhysicsCore2D divide el mismo tick en 13 subpasos; mueve y resuelve dentro de cada uno. En el cuarto subpaso toca primero el plano interior, lo corrige a y=160 y rebota; los subpasos restantes lo llevan a y=143.206363 al final.

El orden y la propiedad, aislados bajo el ciclo actual de Core, no podían crear el contacto exterior: la corrección interior impedía que la pelota llegara a él. En un paso completo, el orden observado en Node hace que Core contacte primero el exterior. Con el `bCoef=0.1` que conserva el perfil activo, Core termina en `vy≈-2.40149`; la traza Node con `bCoef=0` termina en cero. Así, la divergencia observada se debe a la interacción entre cronología de detección, orden de los candidatos y propiedad del plano exterior; no a una sola variable.

## Decisión

**No cambiar todavía la arquitectura productiva.** El experimento demuestra el mecanismo en el tick 4, pero el paso completo no se ha ejecutado sobre todos los fixtures. El orden anterior ya produjo un contacto extra registrado desde el lado opuesto y los cambios de `bCoef` alteraron el microfixture de esquina.

Siguiente paso: crear una corrida diagnóstica full-stadium sobre clones del Core y perfiles recién cargados desde su Source. Comparar 13 subpasos, el ciclo de un paso y la secuencia Node en S1–S3, con A–F, lado opuesto, esquina, pelota-pared, pelota-jugador y goles. Mantener los parámetros y geometría fijos en cada comparación temporal; cambiar el orden y `bCoef` como factores separados. Solo proponer una corrección después de identificar todas las diferencias por tick/contacto y superar regresión completa.

## Riesgo de reproducibilidad

Studio conserva una copia cargada vieja de `StadiumReference2D`: `require(original)` y `ClassicStadium2D.install` difieren del Source actual, mientras un clon recién creado desde ese Source coincide. Todo harness futuro debe identificar explícitamente cuál perfil usa. Esta sesión no refrescó los módulos originales ni guardó el place.

