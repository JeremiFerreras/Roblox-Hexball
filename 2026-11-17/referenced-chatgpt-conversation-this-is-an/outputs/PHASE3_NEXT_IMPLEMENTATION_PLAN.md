# Plan de implementación siguiente — no aplicar todavía

1. Recuperar la instalación aislada 2.3.0 previamente verificada y sus scripts/fixture (sin reinstalar ni cambiar versión). Confirmar hashes y dos ejecuciones deterministas.
2. Inspeccionar `N.prototype.E$` y la ruta de `onCollisionDiscVsPlane` de esa distribución para encontrar cómo se asigna `planeId`, y documentar conversión HBS→planos runtime. No adivinar por el entero del callback.
3. Crear harness desechable, sin place productivo: un disco balón, un único plano ball-area top, bounds apagados y estados equivalentes al estado inmediatamente anterior al contacto. Registrar normal/distancia/bCoef convertidos, tick/subpaso, velocidad normal antes/después y desplazamiento.
4. Ejecutar A perpendicular y B oblicua; C velocidad y D distancia; E barridos de un solo parámetro (primero bCoef efectivo y luego cronología); F lado opuesto solo tras verificar semántica unilateral. Repetir cada caso y guardar JSON crudo.
5. Solo si un A/B reproduce vy=0 al cambiar una variable aislada, proponer corrección en copia. No cambiar ahora `PhysicsCore2D`, `Physics2D.Config` ni `StadiumReference2D`.

## Posible ubicación de cambio futuro
- Si se confirma propiedad/configuración del plano: `ReplicatedStorage.HaxballLab.StadiumReference2D` en el registro `classic:ballArea:top` o su conversor `ClassicStadium2D`; el valor debe provenir de la conversión verificada, no del ajuste de RMS.
- Si se confirma cronología/solver: `ServerScriptService.HaxballLab.PhysicsCore2D` en `stepWorld`/`resolveStaticGeometryForDisc`; implementar únicamente la diferencia de orden respaldada por el microcaso.

## Riesgos y aceptación
Riesgo de cambiar trayectoria global, goles, contactos persistentes y estabilidad 5v5. Requerir escenario 3 aislado, A–F deterministas, escenarios 1/2 conservados, regresiones existentes, y explicación de cada estado poscontacto. Aceptar solo si la variable causal es única, reproduce la salida en ambos motores y mantiene regresiones definidas; RMS por sí solo no es criterio.
