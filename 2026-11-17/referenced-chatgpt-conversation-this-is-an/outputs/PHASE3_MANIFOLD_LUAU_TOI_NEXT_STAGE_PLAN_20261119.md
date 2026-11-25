# Próxima etapa: conectar PGS al clon TOI

La ejecución standalone del módulo PGS ya pasó las pruebas matemáticas. Este plan prepara la integración; todavía no se implementó un TOI manifold ni se ejecutaron pruebas de estadio.

1. Copiar `PHASE3_TOI_EXPERIMENTAL_HARNESS_20261119.luau` a un harness nuevo; no editar el anterior.
2. En el clon, después de hallar `tMin`, agrupar solo contactos de la misma pareja/cuerpo con `abs(t-tMin) <= tau`. Barrer `tau={1e-9,1e-7,1e-5}` como variantes. No cambiar parámetros de geometría ni usar un umbral de `3.5e-4`, que uniría candidatos temporalmente separados.
3. Avanzar una sola vez a `tMin`; llamar el módulo PGS sobre las normales del manifold. Una restitución se calcula una sola vez a partir de la velocidad pre-impacto; para manifolds múltiples el prototipo actual usa objetivo inelástico y debe registrarse como cambio de política.
4. Aplicar corrección posicional acoplada solo tras resolver velocidades. Registrar normales, candidatos agrupados, lambdas, residuo, tiempo restante y re detección.
5. Si PGS informa fallo, excede iteraciones o produce estado no finito, devolver `failed/incomplete`, mantener el último estado válido y no consumir el tiempo restante.
6. Comparar primero esquina, pared/red, `C_v10`, control de red, alta velocidad y S3 tick 4 contra TOI original. Solo después de pasar esas seis pruebas correr el resto de A–F y S1/S2.

Restricciones de la etapa: cuerpos/superficies con identificadores estables; reprocesar los candidatos después de cada manifold; ninguna supresión global de t=0; no resolver primero el plano exterior de S3 artificialmente. La referencia Node continúa siendo la captura archivada.
