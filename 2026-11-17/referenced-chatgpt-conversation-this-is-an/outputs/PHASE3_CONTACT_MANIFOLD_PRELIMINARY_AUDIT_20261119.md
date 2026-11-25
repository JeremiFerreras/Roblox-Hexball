# Fase 3 — auditoría preliminar para contact manifolds

## Estado

**NO-GO para afirmar que existe una variante manifold validada.** Esta auditoría reutiliza únicamente las trazas TOI ya archivadas. No se ejecutó un nuevo solver manifold ni se modificó el TOI existente. Los datos siguientes sirven para especificar y acotar la prueba; no son resultados de una implementación nueva.

## Evidencia que acota la tolerancia

- S3 tick 4: el contacto de `classic:ballArea:top` ocurre en `t=0.2369372739743111`; `classic:outer:top` aparece en `t=0.8553033652513299`. La separación es `0.6183660912770188` ticks. Ninguna tolerancia de simultaneidad razonable para estos cuerpos debe unirlos.
- En la traza del chatter de esquina aparecen candidatos adyacentes en `t=0` y `t=0.0003519042424749192`. Agruparlos requiere una ventana del orden de `3.52e-4` ticks. Con las velocidades de ese caso, esto representa varios milésimos de unidad de recorrido, muy por encima del `posSlop=1e-7` previo. Una tolerancia fija `1e-3` ocultaría contactos temporalmente distintos; no está justificada por la precisión geométrica observada.
- Una regla inicial razonable para evaluar, no una constante ya validada, es `tau = max(1e-9, min(1e-5, spatialTol / max(relativeSpeed, speedFloor)))`, con `spatialTol=1e-7` y `speedFloor` explícito. Deben compararse al menos `1e-9`, `1e-7` y `1e-5` ticks. Aun `1e-5` queda por debajo de la separación de candidatos observada en el chatter; por ello el manifold temporal por sí solo probablemente no resolverá esos nueve/24 eventos.

## Diagnóstico de tiempo cero

La evidencia archivada confirma repetición entre `classic:outer:right` y geometría de red adyacente. En tick 17, C ejecutó 32 impactos, 24 de tiempo cero, con 768 pruebas de candidatos y 102 pruebas de arco. La traza fina muestra una interacción de normales casi opuestas: la pared devuelve al cuerpo hacia la red, y la respuesta de red vuelve a orientarlo hacia la pared. Los impulsos disminuyen, pero no desaparecen antes del límite.

Esto respalda un ciclo de restricciones acopladas y re detección inmediata. No permite atribuir de forma exclusiva el problema a duplicados, penetración, normal errónea o tolerancia: falta instrumentar las candidatas crudas y el cambio de velocidad de cada restricción en una misma pasada. El manifiesto de la prueba debe registrar todos esos valores y marcar el tick como fallido/incompleto si no converge.

Una supresión segura debe ser por par estable `(bodyId, surfaceId)` y estado relativo: después de resolver, ignorar temporalmente solo el contacto persistente cuya velocidad normal sea de separación y cuya separación no se haya invertido; invalidar la supresión si hay nueva aproximación, nueva penetración mayor a la tolerancia, cambio de velocidad por otro impacto o avance positivo de tiempo. No debe usarse una lista global de superficies ignoradas. Esta política aún no se implementó ni probó.

## Especificación recomendada para el clon

1. Generar candidatos en cada estado; filtrar por máscara, lado válido y rango de tiempo. Conservar candidatos rechazados con su razón.
2. Hallar `tMin`; incluir en el manifold solo candidatos del mismo cuerpo/pareja con `abs(t-tMin) <= tau`.
3. Canonizar el orden por clase, `bodyId`, `otherBodyId` y `surfaceId`; colapsar únicamente el mismo contacto geométrico duplicado, no normales distintas.
4. Avanzar una vez a `tMin`. Resolver restricciones normales acopladas mediante PGS determinista con impulsos acumulados no negativos, objetivo de velocidad de separación definido por restitución y un número fijo de iteraciones. Aplicar restitución una vez por contacto nuevo, nunca por pasada iterativa. Registrar residuo de convergencia.
5. Aplicar corrección posicional agrupada por cuerpo, y redetectar para el tiempo restante. Los contactos persistentes en separación se mantienen como estado, no se reimpulsan.
6. Si el residuo supera tolerancia o se alcanza el máximo de manifolds por tick, devolver `failed/incomplete`, conservar el tiempo restante y el estado exacto; no completar el tick fingiendo que no hubo más colisiones.

Esta propuesta distingue el solver del manejo de casos no convergentes. Para contactos con normales opuestas puede no existir una solución compatible con todas las restituciones individuales; la variante debe detectarlo por residuo/conflicto, no silenciarlo ni seleccionar una superficie mediante una excepción específica de fixture.

## Próxima ejecución requerida

Crear `PHASE3_TOI_MANIFOLD_EXPERIMENTAL_HARNESS_20261119.luau` como copia nueva del harness TOI; agregar una variante manifold separada y mantener el TOI original como control. Primero correr esquina, pared/red, `C_v10`, S3 tick 4, red del gol y alta velocidad con las tres tolerancias indicadas. Repetir estados/eventos y hashes. Si esquina o pared/red terminan como `failed/incomplete`, conservar ese resultado como fallo controlado. Solo si ambas convergen sin perder la red del gol ni el impacto rápido, ampliar a los otros microfixtures y S1/S2.

La referencia Node 2.3.0 sigue siendo archivada y no se reejecutó. No se hicieron cambios productivos ni se tocó Studio en esta auditoría.
