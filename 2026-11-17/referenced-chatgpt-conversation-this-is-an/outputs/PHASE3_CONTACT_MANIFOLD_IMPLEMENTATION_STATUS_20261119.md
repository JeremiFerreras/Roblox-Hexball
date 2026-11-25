# Fase 3 — estado de implementación manifold

## Resultado de esta continuación

Se añadió `PHASE3_CONTACT_MANIFOLD_PGS_PROTOTYPE_20261119.luau`, un módulo diagnóstico independiente. Ordena restricciones por `bodyId`/`surfaceId`, descarta duplicados del mismo par estable, acumula impulsos normales proyectados y devuelve residuo/estado de convergencia. En un manifold de más de un contacto aplica objetivo inelástico (`vn >= 0`) para evitar objetivos de restitución incompatibles entre superficies simultáneas. Para un contacto único conserva la restitución indicada.

El prototipo **todavía no está integrado en un clon del ciclo TOI**. Por tanto, no resuelve aún tiempo de impacto, corrección geométrica, redetección tras manifold ni política de tiempo restante/límite. No se generaron comparaciones TOI/manifold ni trazas físicas nuevas; tampoco se ejecutaron esquina, pared/red, `C_v10`, S3, red, alta velocidad o la batería de regresión con este solver.

## Bloqueo de ejecución

Se intentó cargar temporalmente el módulo en Roblox Studio Edit y ejecutar cuatro controles aritméticos (normales opuestas, esquina ortogonal, contacto único y superficie duplicada). La llamada `ExecuteLuau` falló con `Target is not reachable (ExecuteLuau.runCode, DMN_ID_EDIT)` y `No OnInvoke handler responded`. La consulta posterior devolvió Studio en Edit, pero no permitió ejecutar código. No afirmo que esos controles se hayan ejecutado.

No se creó ni quedó ningún ModuleScript temporal en Studio; no se guardó ni publicó el Place. No se modificó el TOI existente, `PhysicsCore2D` ni la instalación de Node.

## Evaluación del diseño

El PGS devuelve una marca de fallo si el residuo normal supera el umbral configurado. La restitución múltiple se suprime deliberadamente en manifolds para mantener restricciones no penetrantes compatibles; esto cambia el rebote simultáneo y debe medirse frente al TOI original. El prototipo de momento solo resuelve velocidades de un cuerpo dinámico contra superficies estáticas; no cubre parejas dinámicas, masas múltiples ni corrección de posición. No es todavía candidato a la batería amplia.

## Próximo paso

Restablecer el canal de ejecución de Studio y, en un harness nuevo, insertar este módulo en el clon TOI mediante el mecanismo de carga temporal ya usado. Implementar agrupación por `tau` configurable (`1e-9`, `1e-7`, `1e-5`), impulso acumulado por manifold, redetección y estado `failed/incomplete` al no converger o agotar iteraciones. Primero ejecutar esquina y pared/red; después `C_v10`, S3, red y alta velocidad. Comparar contra el TOI original y repetir las corridas principales antes de ampliar a A–F y S1/S2.
