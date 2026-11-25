# Recomendación de arquitectura — ciclo temporal y resolución

## Decisión

No cambiar todavía el solver productivo ni adoptar la pasada T1 global. T1+O1+P1 reproduce S3 tick 4 y las trayectorias fijadas de S1–S3 en estos fixtures, pero los controles de gol, esquina y alta velocidad muestran regresiones funcionales.

## Siguiente paso de investigación

Construir una variante experimental de detección temporal con candidatos de impacto ordenados cronológicamente y re-detección en el tiempo restante del tick, guiada por trazas de Node. Conservar separadas las reglas de segmentos de red, postes, planos y pares disco-disco.

La variante debe:

1. avanzar hasta el siguiente impacto candidato;
2. resolver el contacto con sus propiedades reales;
3. reducir el tiempo restante y volver a detectar contactos;
4. registrar iteraciones, tolerancias y contactos persistentes;
5. evitar reemplazar el orden global estático por un orden universal de planos.

Primero debe corregir en un clon el caso S3 sin perder la red classic:goalNet:right:back del control de gol ni las respuestas razonables del límite rápido.

## Aceptación

Repetir S1–S3 con pelota, jugadores, contactos, eventos/goles y hashes por tick; entradas completas A–F; redes, esquinas, impactos altos, ambos lados, pelota-jugador y múltiples contactos en un tick. Comparar primero el primer contacto y su tiempo, después impulso y corrección. Exigir tres repeticiones deterministas. No pasar cambios a producción hasta tener secuencias por fase verificadas.

Esta es una dirección de investigación, no una corrección confirmada. La traza debe confirmar si Node implementa realmente un avance por impacto o una regla específica distinta. Node 2.3.0 es una referencia independiente, no certificación de la física del cliente oficial.

