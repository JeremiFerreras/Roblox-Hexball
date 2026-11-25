# PGS-D aislado frente al oráculo de conjuntos activos

## Veredicto

**PGS-D no está listo para integrarse con TOI.** La variante se implementó en un módulo separado y se ejecutó en Luau real sobre las 11.520 configuraciones del factorial anterior. El selector de restitución D coincide con el oráculo independiente (diferencia máxima de `γ` `1.00000008e-9`, debida al retroceso numérico de pasividad). Cuando el PGS converge, coincide con la velocidad del oráculo y respeta la energía. Sin embargo, PGS no alcanzó el residuo objetivo en **3.706/11.520** ejecuciones. Todas esas ejecuciones tienen solución pasiva válida según el oráculo: los fallos observados pertenecen a la iteración/condicionamiento del PGS, no a una incompatibilidad de la formulación D.

La implementación es híbrida y así debe entenderse: calcula `γ` mediante enumeración de conjuntos activos en manifolds pequeños, y después usa PGS para encontrar impulsos para el objetivo seleccionado. No es una forma de obtener `γ` solo mediante iteraciones PGS ni una implementación escalable demostrada.

## Implementación y salida

- Clon diagnóstico: `PHASE3_PGS_D_ISOLATED_20261119.luau`.
- Harness factorial y oráculo independiente: `PHASE3_PGS_D_FULL_GRID_HARNESS_20261119.luau`.
- Registros completos a precisión completa: `PHASE3_PGS_D_FULL_GRID_RAW_20261119.txt` (una fila por entrada con configuración, objetivos originales y proyectados, `γ`, impulsos PGS y oráculo, velocidades posteriores, residuos KKT, energía, estado de convergencia y presupuesto de iteraciones).
- Resumen estructurado: `PHASE3_PGS_D_FULL_GRID_RESULTS_20261119.json`.
- Repetición byte-identical: `PHASE3_PGS_D_FULL_GRID_REPEAT_20261119.txt`.
- Resumidor: `PHASE3_PGS_D_RESULTS_SUMMARIZER_20261119.ps1`.

El clon no importa, llama ni modifica el PGS de referencia. Su alcance de cuerpo-resolución coincide con el prototipo original: un cuerpo dinámico 2D contra superficies estáticas. La batería no valida fricción, dos cuerpos dinámicos en un manifold, integración, detección geométrica o comportamiento dentro de Roblox.

## D ejecutada por el clon

Para cada contacto se forma el objetivo original `bᵢ=eᵢ max(0,−gᵢ⁰)`. El selector busca el mayor `γ∈[0,1]` para el cual existe una solución de complementariedad:

`λ≥0`, `w=g⁰+Aλ−γb≥0`, `λᵢwᵢ=0`, `ΔT≤0`.

Por soporte activo, el selector implementa los impulsos afines en `γ`, intersecta restricciones lineales con el intervalo de energía y aplica la misma salvaguarda de retroceso de `γ` de la auditoría de D si el cálculo flotante queda apenas por encima de energía cero. Después, el PGS inicia impulsos en cero y realiza el número especificado de pasadas con relajación `ω`. El éxito iterativo exige residuo KKT máximo `≤1e-8` respecto de los **objetivos proyectados**. Se conserva y registra el residuo contra los objetivos originales por separado.

El oráculo del harness vuelve a enumerar soportes activos independientemente de la iteración PGS y construye también el intervalo factible de `γ`. Calcula impulsos, KKT, velocidades y energía con la solución activa. No usa la salida PGS para declarar factibilidad.

## Resultados del factorial completo

El grid contiene 576 sistemas base repetidos en las 20 combinaciones de presupuesto y relajación: ángulos `90, 120, 150, 170, 175, 179, 179.94, 180°`; velocidades `(20,0)`, `(20,−10)`, `(0,−10)`; `e={0,0.5,1}`; 1–4 restricciones; dos asignaciones de ID que alteran el orden estable.

| Iteraciones | Converge PGS-D | Falla PGS-D |
|---:|---:|---:|
| 16 | 1.537/2.880 | 1.343 |
| 32 | 1.993/2.880 | 887 |
| 64 | 2.104/2.880 | 776 |
| 128 | 2.180/2.880 | 700 |

| Relajación | Converge PGS-D | Falla PGS-D |
|---:|---:|---:|
| 0.5 | 1.353/2.304 | 951 |
| 0.8 | 1.645/2.304 | 659 |
| 1.0 | 1.688/2.304 | 616 |
| 1.2 | 1.648/2.304 | 656 |
| 1.5 | 1.480/2.304 | 824 |

| Ángulo | Converge | Falla |
|---:|---:|---:|
| 90° | 1.287/1.440 | 153 |
| 120° | 1.289/1.440 | 151 |
| 150° | 988/1.440 | 452 |
| 170° | 741/1.440 | 699 |
| 175° | 738/1.440 | 702 |
| 179° | 713/1.440 | 727 |
| 179.94° | 711/1.440 | 729 |
| 180° | 1.347/1.440 | 93 |

Resumen del grid:

- 11.520/11.520 filas tienen proyección D disponible en el oráculo.
- Error máximo de `γ` PGS-D contra el selector oracle: `1.00000008e-9`; ocurre en la salvaguarda que retrocede de un punto frontera por pasividad numérica.
- 7.814 convergencias PGS; 3.706 fallos por residuo `>1e-8` pese a solución oracle pasiva válida.
- En las 7.814 convergencias, diferencia de velocidad contra el oráculo: `0` bajo el umbral reportado `1e-6`; ningún caso convergido aumenta energía más de `1e-7`.
- 30 candidatos iterativos incompletos tienen energía positiva mayor que `1e-7`. Se marcan como no convergidos; no deben aceptarse ni confirmarse como respuesta física.
- 520 ejecuciones devuelven éxito respecto al objetivo reducido de D, pero el residuo contra los objetivos restitutivos originales supera `1e-8`. No son falsos éxitos para D si se informa `γ` y el objetivo proyectado; sí lo serían si una API ocultara la reducción y afirmara haber satisfecho `b` original.
- Ninguna ejecución convergida difiere de la respuesta de velocidad del oráculo para el objetivo D correspondiente.

El rendimiento no se presenta como benchmark: el factorial es pequeño y se ejecutó instrumentado, con enumeración activa para selección/oráculo.

## Casos destacados

### 179,94°

Para `(vx,vy)=(20,−10)`, dos restricciones y `e=0.5`, a 128 iteraciones y `ω=1`:

- Objetivos originales: `(0, 10.005230503685944)`.
- Objetivos D: `(0, 0.023416044803393047)`.
- `γ=0.0023403803435379663`.
- Oráculo: `λ=(30882.161575725713, 30902.178519739558)`, `v⁺=(0,22.360679757936325)`, residuo KKT `0`, `ΔT=−3.8150835734995781e−7`.
- PGS-D tras 128 iteraciones: `λ=(4.3006934266562675,24.334568120712721)`, `v=(−0.033861351137637996,−9.97451690451212)`, residuo `0.033861351137637996`, diferencia de velocidad `32.3352143922121`.

La proyección D coincide con el oráculo, pero el PGS no se acerca lo suficiente al reparto de impulsos de gran magnitud a los presupuestos evaluados. Esto es evidencia de mala convergencia de la iteración en una matriz casi singular; no es incompatibilidad de D ni falsedad del oráculo.

La antigua respuesta individual `vy≈9554.293` no forma parte del resultado PGS-D: el objetivo se redujo colectivamente y el estado D oracle fue pasivo. La variante iterativa no alcanzó ese estado dentro de 128 pasadas.

### 180°

Para normales opuestas y `e=1`, D produce explícitamente `γ=0`, objetivos proyectados `(0,0)`. El PGS converge a la respuesta inelástica `v≈(0,0)`, con residuo proyectado 0 y residuo contra objetivos originales 20. El objetivo restitutivo original es incompatible; el resultado solo es éxito para el fallback D identificado, nunca éxito restitutivo original.

### Contacto ortogonal aislado

El control de contacto aislado cierra exactamente con `γ=1` cuando `0≤e≤1`. Para `e=0.5`, ambos objetivos son el mismo `b`, y PGS-D coincide con el oráculo. Los casos pasivos aislados sencillos convergen con todos los presupuestos; los 153 fallos en la categoría agregada de 90° proceden de manifolds de más restricciones, velocidades/órdenes/relajaciones, no de un fallo universal del contacto único.

## Orden y convergencia

La permutación del arreglo de entrada conservando IDs no altera el resultado: el clon ordena de forma estable por `surfaceId`. Intercambiar los IDs de los extremos cambia deliberadamente el orden de barrido. En los 5.760 pares comparables canonical/reverse-ID, 76 pares cambian su estado convergido/fallido y 1.909 muestran distinto residuo; la diferencia máxima de residuo entre pares es `0.370106749719255`. La solución oracle y los estados PGS que sí convergen siguen siendo los mismos. La sensibilidad restante es de convergencia finita, no del objetivo D.

Los fallos se agravan al aumentar la proximidad angular a 180°, aunque 180° exacto puede resolverse al reducir `γ` a cero y caer en un LCP inelástico redundante. Por ejemplo, la tasa de convergencia a 179.94° es `711/1.440`, frente a `1.347/1.440` a 180°. No se probaron presupuestos mayores ni se ajustó un caso particular; el conjunto evaluado quedó limitado a 16/32/64/128 y `ω=0.5/0.8/1/1.2/1.5`.

## Materiales `bCoef`

La auditoría separada [PHASE3_NODE230_BCOEF_MATERIAL_AUDIT_20261119.md](PHASE3_NODE230_BCOEF_MATERIAL_AUDIT_20261119.md) confirma en el código real 2.3.0 que la respuesta normal individual combina los dos materiales como `1 + bCoef₁·bCoef₂`. Para planos HBS, `bCoef` omitido se lee con default 1 y el exportador omite justamente ese default. En Classic el plano superior del área de balón está omitido, por lo que Node lo convierte a `1`; con `ball.bCoef=0.5`, el producto por pareja es `0.5`. Los planos exteriores tienen `bCoef=0` explícito en el HBS capturado. No se infiere que el callback `planeId=1` corresponda a un índice HBS ni se deriva de la regla por-pareja un único `bCoef` de manifold PGS-D.

## Determinismo, hashes y limitaciones

Luau CLI oficial 0.747, ejecutable SHA-256 `ff0acf7d2df9d38e30c85ee9fe698efd756a920496c84ea848b74d0e2082e958`. Dos ejecuciones completas de 11.520 filas son byte idénticas, SHA-256 `ebb054278db31dff314e3767829b4495f9b8d545dcf9128b61e0e31cc8c98967`. `luau-analyze` terminó sin diagnósticos tras limpiar avisos de variables sin uso.

El grid mantiene el mismo modelo sintético del estudio anterior: un cuerpo, normales de planos, masa inversa 1, sin fricción. No es una batería de física de estadio. Node 2.3.0 se inspeccionó estáticamente para materiales, pero no se volvió a ejecutar; Roblox Studio no se usó. No se modificaron PGS original, TOI, `PhysicsCore2D`, Node ni Place.

## Recomendación

D sigue siendo una ley restitutiva candidata matemáticamente admisible para manifolds pequeños, siempre que el estado identifique `γ`, los objetivos realmente resueltos y el fallback inelástico. **El PGS-D iterativo actual no es suficientemente fiable**: falla aproximadamente un tercio del grid aun cuando el oráculo demuestra solución. Investigar un solucionador activo/semiactivo determinista para manifolds pequeños, pivoteo/rango y tratamiento explícito de redundancias antes de conectarlo a TOI. Conservar PGS-D como solver de comparación y devolver fallo sin consumir el estado físico cuando su residuo no cumple.
