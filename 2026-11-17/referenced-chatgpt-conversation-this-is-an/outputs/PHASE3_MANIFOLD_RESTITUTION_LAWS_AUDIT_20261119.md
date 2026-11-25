# Leyes restitutivas conjuntas para manifolds — investigación Luau

## Dictamen

Los objetivos restitutivos independientes `bᵢ=eᵢ·max(0,−gᵢ⁰)` pueden ser incompatibles o pueden producir energía muy superior a la inicial aunque exista solución de complementariedad. Un coeficiente común aplicado a cada objetivo no arregla esos problemas.

Dos alternativas sí satisfacen la no penetración, complementariedad y pasividad en el grid probado:

- **C — escalado seguro de la respuesta inelástica.** Es sencillo, exacto para un contacto pasivo y siempre puede volver a la respuesta inelástica. Puede reducir a cero toda la restitución del manifold si un contacto activo estaba inicialmente separándose.
- **D — proyección radial pasiva de objetivos individuales.** Mantiene la restitución individual si es factible y pasiva; en caso contrario busca el mayor `γ∈[0,1]` que conserva proporcionalmente los objetivos individuales y cumple las restricciones y el presupuesto de energía. Es más fiel a materiales distintos y dio restitución pequeña, pero no nula, en el caso de 179,94°.

**Recomendación:** continuar estudiando D como formulación principal y C como fallback simple de referencia. Aún no integrar ninguna con PGS/TOI: son resultados de una batería matemática normal 2D, no validación de contactos físicos.

## Formulación común

Sea `J` la matriz de normales de contacto con `+n` para el primer cuerpo y `−n` para el segundo. Para cuerpos con matriz de masas `M`:

`g⁰ = Jv⁰`, `A = JM⁻¹Jᵀ`, `v⁺ = v⁰ + M⁻¹Jᵀλ`, `g⁺ = g⁰ + Aλ`.

La convención es que la normal apunta al lado admisible. `gᵢ<0` indica cierre. Para contacto estático, `Aᵢⱼ = invMass·(nᵢ·nⱼ)`; para un par dinámico, `Aᵢⱼ` suma las contribuciones de ambos cuerpos. El impulso normal `λᵢ` no puede ser negativo.

Con un objetivo restitutivo `b`, las condiciones son:

`λ ≥ 0`, `w = g⁺−b ≥ 0`, `λᵢwᵢ = 0`.

La energía cinética del sistema cambia en:

`ΔT = T⁺−T⁰ = (g⁰)ᵀλ + ½ λᵀAλ`.

Se exige `ΔT≤0` para un choque pasivo. En una colisión entre dos cuerpos dinámicos, los impulsos son internos y conservan el momento lineal total. Un plano estático ejerce un impulso externo; el momento de la pelota sola no tiene por qué conservarse.

La restitución se define aquí a partir de un coeficiente **efectivo por contacto** `eᵢ`. El módulo PGS recibe `restitution` en el contacto, pero no determina cómo combinar los dos `bCoef` de las superficies que colisionan. No hay evidencia en ese solver para elegir mínimo, máximo o promedio. Esa conversión debe resolverse en la capa que construye el contacto; esta investigación no inventa una.

## Candidatos

### A — objetivos restitutivos independientes

`bᵢᴬ = eᵢ·max(0,−gᵢ⁰)`.

Se resuelve el LCP de contacto contra ese vector. Es el control negativo de “cada contacto rebota por separado”. En el PGS inspeccionado, esto **no** es lo que ejecuta un manifold múltiple: el código actual pone `bᵢ=0` para todos los contactos múltiples. A coincide con el comportamiento actual solo en el contacto único y representa la intención restitutiva individual usada para evaluar el problema.

A conserva exactamente el contacto aislado, pero puede no tener solución complementaria; aun cuando la tenga, no garantiza pasividad. En el grid fue incompatible en 480 casos y no pasivo en 2.160 casos factibles.

### B — coeficiente común y LCP de objetivos por contacto

Para un coeficiente de manifold `eM` **suministrado externamente**:

`bᵢᴮ = eM·max(0,−gᵢ⁰)`.

B conserva el caso aislado si `eM=eᵢ`. No es una ley colectiva por sí misma: sigue poniendo objetivos independientes en cada fila. Por ello no impide que los objetivos opuestos sean incompatibles y no impone `ΔT≤0`. En el grid uniforme `eM=eᵢ`, A y B son algebraicamente idénticos; el resultado no demuestra una regla para mezclar materiales. B y C solo coinciden cuando el conjunto de contactos activos inelásticos coincide con las filas que requieren rebote, los contactos activos estaban cerrándose, `eM≤1` y el escalado no viola ninguna restricción inactiva. Si hay una fila inicialmente separándose activa, una fila inicialmente cerrándose inactiva o una restricción que cruza a penetración al escalar, B y C dejan de ser equivalentes.

### C — solve inelástico y escalado seguro

Primero se resuelve el manifold inelástico:

`λ⁰ ∈ LCP(A,g⁰,0)`, `gᴵ=g⁰+Aλ⁰`, `Δvᴵ=M⁻¹Jᵀλ⁰`.

Luego se propone `λᶜ=(1+eM)λ⁰`. La velocidad normal resultante se comprueba para **todas** las restricciones. Si alguna se vuelve negativa, `eM` se reduce hasta el máximo valor que mantiene `g⁺≥0`:

`eC = min(eM,1, min_{dᵢ<0} gᴵᵢ/(−dᵢ))`, donde `d=Aλ⁰`.

Se recalcula `λᶜ=(1+eC)λ⁰` y se verifica de nuevo no penetración y KKT. Para contactos activos con `λ⁰ᵢ>0`, el objetivo realizado es `bᶜᵢ=g⁺ᵢ=−eC·g⁰ᵢ`; los inactivos tienen objetivo cero. Se reporta `eC` explícitamente. Si la única solución segura es cero, C informa `eC=0` y usa el solve inelástico.

**Pasividad:** en el solve inelástico, la condición de optimalidad da `(g⁰)ᵀλ⁰=−(λ⁰)ᵀAλ⁰`. Con `α=1+eC`:

`ΔT = ½(α²−2α)(λ⁰)ᵀAλ⁰ = ½(eC²−1)||Δvᴵ||²_M ≤ 0`, para `0≤eC≤1`.

**Contacto aislado:** `λ⁰` lleva `g⁰<0` a cero; escalar por `1+e` deja `g⁺=−e·g⁰`, que coincide exactamente con restitución aislada para `0≤e≤1`. En un manifold, los contactos activos que ya se separaban pueden imponer `eC=0`; ese es un fallback documentado, no un éxito contra un objetivo distinto.

### D — proyección radial pasiva de objetivos individuales

Se construye el vector individual `bᴵᵢ=eᵢ·max(0,−gᵢ⁰)` y se busca el mayor escalar común `γ∈[0,1]` para el que exista `λ` que cumpla:

`λ≥0`, `g⁰+Aλ−γbᴵ≥0`, `λᵢ(gᵢ⁰+(Aλ)ᵢ−γbᴵᵢ)=0`, `ΔT≤0`.

Esto es una proyección sobre el **rayo de objetivos individuales**: para `bᴵ≠0`, maximizar `γ` equivale a minimizar la distancia a los objetivos sobre ese rayo. No es una proyección euclídea irrestricta sobre todo el espacio de objetivos; elegir otra métrica produciría otra política.

El harness enumera conjuntos activos. En cada soporte, `λS(γ)=λ₀+γλ₁`; las desigualdades dan intervalos lineales de `γ` y la energía es cuadrática. Se intersectan los intervalos y se elige el mayor `γ` factible con desempate determinista. Si `γ≤1e−8`, se registra `γ=0` y se devuelve el solve inelástico. Si `γ<1`, cada coeficiente efectivo queda `eᵢ,eff=γeᵢ`; los valores originales no se sobrescriben silenciosamente.

**Contacto aislado:** si `0≤e≤1`, el objetivo está dentro del conjunto pasivo factible, por lo que `γ=1` y coincide exactamente con A. Si el objetivo individual es incompatible, `γ` disminuye o llega a cero. La solución satisface complementariedad respecto al objetivo reducido informado, no respecto a `bᴵ` cuando fue reducido.

## Resultados del grid de 11.520 entradas

Se reutilizó el grid anterior: ocho separaciones angulares, tres velocidades, `e={0,0,5,1}`, uno a cuatro contactos, dos órdenes de IDs, presupuestos 16/32/64/128 y relajaciones 0,5/0,8/1/1,2/1,5. Candidatos A–D son soluciones algebraicas por conjuntos activos; presupuesto y relajación se conservan como etiquetas del diseño para comparar con el grid, pero no cambian una solución exacta.

| Candidato | Sistemas aceptados | Incompatibles | No pasivos / reducciones | Máximo aumento de energía |
|---|---:|---:|---|---:|
| A, objetivos individuales | 11.040 | 480 | 2.160 soluciones factibles no pasivas | 182.568.783,09375 |
| B, `eM=e` uniforme | 11.040 | 480 | 2.160 soluciones factibles no pasivas | 182.568.783,09375 |
| C, escalado inelástico | 11.520 | 0 | 2.880 reducen `eM`; 1.440 usan `eC=0` | `1,17e−10` (redondeo) |
| D, proyección radial pasiva | 11.520 | 0 | 2.640 reducen `γ`; 480 usan `γ=0` | 0 observado |

La factibilidad de A/B no implica pasividad. Sus 480 incompatibilidades son los objetivos opuestos a 180° con restitución positiva. C y D producen una solución explícita con no penetración, complementariedad y energía no creciente en todos los casos del grid.

### 179,94°

Con `(vx,vy)=(20,−10)`, `n₁=(1,0)`, `n₂≈(−0,99999945,0,0010472)` y `dot≈−0,9999994517`:

| Ley | Resultado | Residuo KKT | `ΔT` aproximado |
|---|---|---:|
| A/B, `e=0,5` | Factible; `λ≈(9,133,203,8;9,133,228,8)`, `v⁺≈(0,9554,293)` | `0` | `+45.642.008,28` |
| A/B, `e=1` | Factible; `v⁺≈(0,19.108,586)` | `0` | `+182.568.783,09` |
| C, `eM=0,5` | La verificación de la restricción inicialmente separadora limita `eC` a 0; `v⁺≈(0,0)` | `1,82e−12` | `−250` |
| D, `e=0,5` | `γ≈0,002340380344`; `e₂,eff≈0,001170190172`; `v⁺≈(0,22,36067976)` | `0` | `−4,17e−7` |
| D, `e=1` | `γ≈0,001170190172`; misma respuesta pasiva | `0` | `−4,17e−7` |

La restitución por contacto individual fuerza velocidades tangenciales enormes; las condiciones normales son factibles, pero violan pasividad. C prefiere cero restitución porque el contacto activo que empieza separándose no tolera el escalado global. D conserva una respuesta no nula diminuta al reducir proporcionalmente todos los objetivos hasta la frontera pasiva. En el caso de `e=0`, el LCP inelástico es factible pero PGS del grid previo no convergía cerca de la oposición; aquí se usa el oráculo exacto, no PGS.

### 180° y contacto aislado

A/B clasifican los objetivos `b=(0,10)` de normales opuestas como incompatibles: `vx⁺≥0` y `−vx⁺≥10`, que sumados implican `0≥10`. C informa `eC=0`; D informa `γ=0`; ambos devuelven la respuesta inelástica, sin afirmar que lograron la restitución original.

Para un contacto aislado con `vy⁰=10`, normal `(0,−1)`, `e=0,5`, A/B/C/D dan exactamente `vy⁺=−5`, impulso 15 y `ΔT=−37,5`. Con `e=0` y `e=1` también coinciden exactamente. El código actual permite `e=1,2`: reproducirlo daría `vy⁺=−12` y `ΔT=+22`, incompatible con pasividad. C reduce explícitamente a `eC=1`; D da `γ=5/6`, `e_eff=1`. Por tanto, equivalencia exacta con el solver aislado y pasividad no pueden satisfacerse a la vez para entradas superelásticas `e>1`; esas entradas deben marcarse como no pasivas o rechazarse, no aceptarse como una respuesta pasiva.

### Materiales y masas

Con dos contactos ortogonales y coeficientes efectivos explícitos `(0,2;0,8)`, A/D dan `v⁺=(-2,-8)` y `ΔT=-66`. B/C dependen del `eM` suministrado: `eM=0,2→(-2,-2)`, `eM=0,5→(-5,-5)`, `eM=0,8→(-8,-8)`. Los tres son pasivos, pero diferentes. Los resultados no justifican elegir uno como combinación universal de `bCoef`; D conserva los coeficientes relativos cuando `γ=1` y reduce todos proporcionalmente si la pasividad exige hacerlo.

Para un impacto entre dos cuerpos con `invMass=(1,0,25)`, `v=(10,−2)`, normal `(-1,0)` y `e=0,5`, el solve analítico da `λ=14,4`, velocidades `(-4,4;1,6)`, momento `2→2` y energía `58→14,8`. Las cuatro leyes coinciden en el caso aislado.

## Determinismo, herramientas y límites

El harness independiente [PHASE3_MANIFOLD_RESTITUTION_LAWS_20261119.luau](PHASE3_MANIFOLD_RESTITUTION_LAWS_20261119.luau) usa el CLI Luau 0.747 y un oráculo activo propio; no llama ni modifica el PGS de referencia. El grid y los casos dirigidos se ejecutaron dos veces byte por byte; SHA-256 `6fb60765d55540d5b0b5e52a32b4de435e3305d0d31abb55f507c09b351c57a3`. Las permutaciones de entrada con IDs iguales dieron el mismo `γ` y velocidades. El orden estable usa ID, normal y coeficiente para desempatar.

Las soluciones y los registros dirigidos están en [PHASE3_MANIFOLD_RESTITUTION_LAWS_RESULTS_20261119.json](PHASE3_MANIFOLD_RESTITUTION_LAWS_RESULTS_20261119.json) y la salida completa en [PHASE3_MANIFOLD_RESTITUTION_LAWS_RAW_20261119.txt](PHASE3_MANIFOLD_RESTITUTION_LAWS_RAW_20261119.txt). El análisis estático Luau no reportó problemas.

La batería modela contactos normales, sin fricción, de uno a cuatro planos sobre un cuerpo con masa inversa 1; el control analítico de dos cuerpos cubre un contacto dinámico. No incluye fricción, corrección posicional, integración temporal, colisiones geométricas, red, jugadores ni el cálculo real de `bCoef` en el estadio. No se ejecutó Roblox Studio, Node ni TOI.

## Recomendación

D es el candidato más fiel para la siguiente investigación: preserva los objetivos individuales compatibles y pasivos, reduce un factor colectivo explícito cuando es necesario y rechaza la restitución si solo queda `γ=0`. C es una alternativa más sencilla y demostrablemente pasiva, pero puede suprimir toda la restitución del manifold por una sola restricción activa inicialmente separadora. B no es suficiente y A sigue siendo un control negativo.

Antes de integrar D en cualquier solver, debe fijarse de forma documentada cómo se obtiene el coeficiente efectivo por contacto a partir de los `bCoef` de las dos superficies. También debe definirse el reporte de `γ`, objetivos incompatibles y fallback a cero. Esta investigación no aprueba integración física.