# Auditoría matemática PGS y compatibilidad de manifolds

## Dictamen

El criterio de éxito del PGS es un residuo KKT de velocidad respecto de los objetivos que el propio módulo decidió utilizar. En manifolds con más de una restricción esos objetivos se sustituyen todos por cero. Por tanto, `ok=true` no demuestra que se haya satisfecho la restitución solicitada por contacto. Un caso de normales opuestas con restitución da un **falso éxito respecto del problema físico solicitado**.

El oráculo independiente confirma dos resultados distintos para el caso de 179,94°:

- Con objetivo inelástico cero, el sistema es factible y de rango completo; PGS no converge hasta 128 iteraciones. Este fallo es mala condición/convergencia, no incompatibilidad.
- Con restitución independiente `e=0,5`, el sistema de desigualdades todavía es factible, pero su solución exige `vy≈9554,293` y aumenta la energía cinética de 250 a unos 45.642.258. La factibilidad matemática no la convierte en una respuesta pasiva físicamente aceptable.

**No integrar PGS con TOI.** La formulación debe aclarar qué objetivos se exigen a un manifold y qué condición física debe satisfacer la respuesta antes de modificar el solver.

## Código y alcance ejecutado

Se inspeccionó sin modificar [PHASE3_CONTACT_MANIFOLD_PGS_PROTOTYPE_20261119.luau](PHASE3_CONTACT_MANIFOLD_PGS_PROTOTYPE_20261119.luau), incluyendo normalización, deduplicación, orden estable, actualización de impulsos, residuo y commit. Se creó [PHASE3_PGS_COMPATIBILITY_ORACLE_20261119.luau](PHASE3_PGS_COMPATIBILITY_ORACLE_20261119.luau), que contiene la enumeración independiente de conjuntos activos y el runner de casos. El runner requiere el PGS solo para comparación; las matrices, enumeración, soluciones y pruebas KKT del oráculo son código separado y no llaman al PGS.

La ejecución fue con Luau CLI 0.747 y se repitió dos veces en procesos separados. Las salidas fueron byte idénticas, SHA-256 `fbefa84497543e0f89debfebbde2bc905c8c82a7e5665246a4f9664dba6b82e9`. `luau-analyze` terminó sin diagnósticos. Se ejecutaron 14 sistemas sintéticos; no se volvió a ejecutar el barrido factorial completo, Node-HaxBall ni Roblox Studio.

La matriz `A`, el vector `q`, los multiplicadores, los residuos de complementariedad y los estados están en cada caso del JSON. Resultados estructurados: [PHASE3_PGS_COMPATIBILITY_RESULTS_20261119.json](PHASE3_PGS_COMPATIBILITY_RESULTS_20261119.json). Salida numérica sin redondeo: [PHASE3_PGS_COMPATIBILITY_ORACLE_RAW_20261119.txt](PHASE3_PGS_COMPATIBILITY_ORACLE_RAW_20261119.txt). También se volvió a ejecutar el grid original completo con ambos LCP: [runner Luau](PHASE3_PGS_COMPATIBILITY_FULL_GRID_20261119.luau), [resumen factorial](PHASE3_PGS_COMPATIBILITY_FULL_GRID_RESULTS_20261119.json) y [salida cruda](PHASE3_PGS_COMPATIBILITY_FULL_GRID_RAW_20261119.txt). El grid completo se repitió byte por byte, SHA-256 `37d89d64746e7c08611f96939a127505a2b038106af6c5c5428a909a904e370c`. El barrido previo y su traza íntegra siguen en [PHASE3_PGS_CONVERGENCE_RESULTS_20261119.json](PHASE3_PGS_CONVERGENCE_RESULTS_20261119.json) y [PHASE3_PGS_CONVERGENCE_SWEEP_RAW_V2_20261119.txt](PHASE3_PGS_CONVERGENCE_SWEEP_RAW_V2_20261119.txt).

## Formulación real del módulo

### Convención

Cada normal unitaria `nᵢ` apunta hacia el lado admisible. Para una pelota contra un plano estático, la velocidad normal es `gᵢ = nᵢ·v`. Un valor negativo indica velocidad de cierre. El impulso escalar `λᵢ` es no negativo y modifica la velocidad como `v ← v + invMass·nᵢ·Δλᵢ`.

El código normaliza cada normal antes del solve. Deduplica el mismo par cuerpo/superficie con normales equivalentes; rechaza la misma superficie si su normal difiere. El número de restricciones `m` que gobierna la restitución es el número de contactos únicos luego de la deduplicación.

### Objetivo que construye el código

Sea `gᵢ⁰ = nᵢ·v⁰`. Si queda exactamente un contacto único:

`bᵢ = −max(0,eᵢ)·gᵢ⁰`, si `gᵢ⁰ < −velocityTolerance`; en otro caso `bᵢ = 0`.

Si hay más de un contacto único, el código asigna `bᵢ=0` a todos. Los campos `restitution` suministrados en contactos múltiples no se usan para el solve. El módulo valida `eᵢ≥0`, pero no impone `eᵢ≤1`.

### Matriz implícita y actualización

Para la API actual, un cuerpo dinámico y superficies estáticas:

`Aᵢⱼ = invMass · (nᵢ·nⱼ)`

`qᵢ = gᵢ(v⁰) − bᵢ`

`w = q + Aλ = Jv⁺ − b`

El PGS no materializa `A`; su actualización en orden estable equivale a:

`Δλᵢ* = (bᵢ − gᵢ(v)) / invMass`

`λᵢ' = max(0, λᵢ + Δλᵢ*)`

`Δλᵢ = λᵢ' − λᵢ`

`v ← v + invMass·nᵢ·Δλᵢ`

La proyección mantiene `λᵢ≥0`. Para varios cuerpos, la formulación general sería `A=J M⁻¹ Jᵀ`; cada fila de `J` contiene `+nᵢ` para un cuerpo y `−nᵢ` para el otro, y `v⁺=v⁰+M⁻¹Jᵀλ`. El PGS actual no representa ese manifold de dos cuerpos: solo acepta un cuerpo dinámico frente a superficies estáticas.

### Complementariedad y éxito

El problema de contacto unilateral con objetivo `b` requiere:

`λ≥0`, `w=q+Aλ≥0`, `λᵢwᵢ=0`.

El código calcula el residuo máximo así:

- Si `λᵢ>0`, suma `|wᵢ|` como violación potencial.
- Si `λᵢ=0`, suma `max(0,−wᵢ)`.

Devuelve éxito cuando el máximo es menor o igual a `residualTolerance` (por defecto `1e−8`). Es una comprobación KKT de complementariedad para el `b` interno; no verifica que `b` coincida con los objetivos restitutivos de entrada en un manifold múltiple. No comprueba energía, conservación de momento ni si las entradas definen un solve físicamente pasivo. Si no converge, no confirma la velocidad candidata en el cuerpo.

## Oráculo independiente

Para cada sistema pequeño se construyen explícitamente `J`, `A=JM⁻¹Jᵀ` y `q=Jv⁰−b`. El oráculo enumera los `2ᵐ` conjuntos activos posibles. Para cada soporte resuelve el sistema lineal activo mediante eliminación gaussiana con pivoteo, rechaza multiplicadores negativos y verifica todas las desigualdades `w≥0` y la complementariedad. También calcula el rango de `A`; una solución con rango deficiente se clasifica como factible singular/redundante, no como imposible.

El oráculo no reporta incompatibilidad por el mero hecho de que PGS no converja. Reporta “incompatible” solo cuando no encuentra ningún soporte complementario bajo enumeración exhaustiva para este tamaño pequeño. Para las restricciones exactamente opuestas se añade además un certificado directo por suma de desigualdades. Tolerancia de factibilidad: `1e−8`; umbral de pivote informado en el runner: `1e−13·max(1,||A||∞)`. Estas pruebas cubren LCP pequeños y no certifican manifolds grandes ni la detección geométrica del contacto.


## Clasificación del grid factorial reutilizado

Se volvieron a ejecutar las 11.520 entradas del estudio anterior y se compararon dos sistemas distintos en cada entrada: (1) el LCP con los objetivos que PGS realmente aplica, y (2) el LCP con objetivo restitutivo calculado por contacto a partir de la velocidad normal inicial. Esto separa fallo numérico de incompatibilidad del objetivo solicitado.

| Medida en el grid completo | Resultado |
|---|---:|
| LCP con objetivos internos de PGS matemáticamente factible | 11.520/11.520 |
| PGS converge / falla con esos objetivos internos | 9.276 / 2.244 |
| LCP con restitución por contacto factible / incompatible | 11.040 / 480 |
| PGS devuelve éxito aunque el LCP restitutivo es incompatible | 432 casos |
| PGS devuelve éxito pero viola el KKT restitutivo solicitado | 3.944 casos |
| PGS éxito y KKT solicitado satisfecho | 5.332 casos |

Los 480 LCP incompatibles aparecen en separación exactamente 180° con varios contactos y restitución positiva. En otros 48 casos incompatibles dentro de ese subconjunto, PGS no converge y por ello no es un falso éxito; los otros **432** sí retornan `ok=true` porque el solver reemplaza el objetivo por cero. La suma de desigualdades para los opuestos certifica la incompatibilidad en cada sistema afectado. Todos los 2.244 fallos de PGS del grid, en cambio, son fallos de convergencia sobre su LCP efectivo factible: no son sistemas imposibles.

El caso exacto de cambio por orden queda reproducido dentro del grid: a 120°, cuatro contactos, velocidad `(0,−10)`, `e=0`, presupuesto 16 y `ω=0,8`, el orden canónico falla con residuo `3,0590e−8`; al asignar IDs reversos el mismo contacto es procesado en sentido inverso y converge. Invertir únicamente el arreglo conservando IDs produce el mismo resultado canónico, por la ordenación estable.
## Casos y comparación

| Caso | Oráculo independiente | PGS observado | Clasificación |
|---|---|---|---|
| Plano aislado, `e=0,5`, `(vx,vy)=(0,10)`, `n=(0,−1)` | `λ=15`, `v⁺=(0,−5)`, `w=0`; energía `50→12,5` | Éxito para 16/32/64/128, coincide | Factible y convergente |
| Esquina ortogonal, `(20,20)`, `n=(-1,0),(0,-1)` | `λ=(20,20)`, `v⁺=(0,0)`, rango 2 | Éxito para todos los presupuestos | Factible y convergente |
| Oblicuos, 120°, `(20,−10)`, `e=0` | `λ=(0,18,660254…)`, `v⁺=(10,669873,6,160254)` | Éxito y coincide | Factible y convergente |
| 179,94°, `(20,−10)`, objetivos cero | `λ≈(9529,293;9549,298)`, `v⁺≈(0,0)` | Falla a 16/32/64/128; residuo `0,01044986→0,01044858` | Factible, mal condicionado, no convergente |
| 179,94°, `(20,−10)`, restitución `e=0,5` por contacto | Factible: `λ≈(9,133,203,8;9,133,228,8)`, `v⁺≈(0,9554,293)`; energía `250→45.642.258,28` | Falla con el sistema interno de objetivo cero en todos los presupuestos probados | Factible algebraicamente, respuesta incompatible con pasividad energética |
| 180°, normales opuestas, `e=0` | Rango 1 de 2; `v⁺=(0,0)`, solución física única y descomposición de impulsos no única | Éxito | Factible singular/redundante; no es imposible |
| 180°, `n₁=(1,0)`, `n₂=(-1,0)`, `vx⁰=10`, `e=1` en ambos | Objetivos `(0,10)`: `vx⁺≥0` y `−vx⁺≥10`; al sumarlas da `0≥10`, imposible | `ok=true`, `vx⁺=0`, residuo interno cero | **Falso éxito** contra los objetivos restitutivos solicitados |
| Duplicado de la misma superficie | LCP singular; misma velocidad física, impulsos redundantes | Deduplica y converge | Factible redundante |
| Mismo normal en superficies distintas | Rango 1; los impulsos no son únicos, velocidad sí | Converge, segundo impulso puede ser cero | Factible redundante |
| Orden sensible, 4 planos a 0°,40°,80°,120°, `(0,−10)`, `e=0`, `ω=0,8` | Rango 2/4, solución `v⁺=(0,0)` | IDs canónicos: falla a 16 con residuo `3,0590e−8`; IDs reversos: éxito con `5,76e−17`; ambos convergen a 32. Invertir el arreglo conservando IDs reproduce el resultado canónico | Factible y redundante; éxito sensible al orden con presupuesto finito |
| Dos cuerpos dinámicos, `invMass=(1,0,25)`, velocidades `(10,−2)`, objetivo 6 | `λ=14,4`; `v⁺=(-4,4;1,6)`; momento lineal `2→2`; energía `58→14,8` | No aplicable: la API PGS no admite dos cuerpos dinámicos en el mismo manifold | Factible; conservación interna validada por oráculo |
| Normal cero | Inválido | Rechazo `invalid-normal-or-inverse-mass` | Entrada inválida |

En 179,94°, `dot(n₁,n₂)=−0,99999945168869453`. Para dos normales unitarias, la condición de la matriz de Gram es `(1+|dot|)/(1−|dot|)≈3,65·10⁶`. En el solve inelástico `e=0`, la solución factible existe y no tiene energía posterior; PGS no la alcanza. Eso demuestra un problema de acondicionamiento/convergencia y de criterio de suficiencia práctica, no una incompatibilidad matemática. En la solución del oráculo, el máximo producto complementario absoluto es aproximadamente `1,74e−8`: los `wᵢ` están dentro del umbral de velocidad, pero los multiplicadores grandes amplifican el residuo al multiplicar `λᵢwᵢ`. El oráculo reporta ambas magnitudes por separado; el PGS solo compara el residuo de velocidad.

Con `e=0,5`, los objetivos individuales producen una solución algebraica con una velocidad tangencial enorme. El sistema LCP por sí solo no expresa la exigencia energética de un contacto pasivo. La formulación restitutiva por contacto puede tener solución y a la vez no ser aceptable como modelo físico de un impacto simultáneo. Hace falta definir y comprobar la regla de restitución del manifold como conjunto, no apagar restitución silenciosamente.

## Orden y falsos éxitos

El ID de superficie determina el orden estable del recorrido. En el caso de 4 restricciones, cambiar qué ID recibe cada extremo cambia la secuencia normal y provoca una diferencia éxito/fallo a 16 iteraciones; invertir el arreglo sin tocar IDs no la cambia porque el PGS ordena por clave. La diferencia se resuelve a 32 en este fixture, pero no prueba independencia general del orden.

El falso éxito demostrado no es el caso 179,94° de `e=0,5`: ahí el PGS falla explícitamente contra su objetivo cero. El falso éxito exacto es el caso de 180° con restitución simultánea incompatible: el oráculo encuentra contradicción, mientras PGS altera los objetivos a cero y los satisface. La API actual no puede distinguir ese resultado del manifold inelástico que realmente resolvió.

## Recomendación técnica

1. No subir simplemente el número de iteraciones: ya se observó residuo casi estancado en la región mal condicionada.
2. Antes de elegir solver, especificar una ley única de restitución para contactos simultáneos y un criterio energético/pasivo. Con objetivos restitutivos independientes, el caso 179,94° puede exigir un aumento de energía de más de cinco órdenes de magnitud.
3. Mantener el oráculo de conjunto activo como prueba diferencial en manifolds pequeños; agregar certificados de incompatibilidad y medidas escaladas de residuo complementario.
4. Comparar un solver por conjunto activo o una formulación de mínimo cambio de velocidad con restricciones energéticas contra el oráculo, incluyendo solución física e impulsos redundantes. La regularización debe medirse por cambio de velocidades y energía, no aceptarse solo porque mejora el residuo.
5. Solo después de fijar esas reglas y obtener una solución finita, pasiva y determinista para los casos casi opuestos, evaluar el solver en una copia TOI aislada.

## Separación de evidencia

**Ejecutado en Luau real:** oráculo activo, casos sintéticos, PGS original y clon de trazas, dos corridas deterministas y análisis estático. **Grid factorial:** las 11.520 entradas anteriores se volvieron a ejecutar con el oráculo; las trazas previas del TOI no se regeneraron. **No ejecutado:** TOI, colisiones físicas, Roblox Studio, Node-HaxBall, escenario S3 físico. No se modificaron el PGS de referencia, TOI, `PhysicsCore2D`, Node ni el Place; no se guardó ni publicó el Place.