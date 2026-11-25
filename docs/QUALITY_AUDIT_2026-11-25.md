# Auditoría de calidad — 25/11/2026

## Veredicto

La base del motor y partido local tiene validación funcional reproducible y ha mejorado su capacidad de detectar regresiones. **No se certifica como código libre de errores ni listo para producción en Roblox.** Esta es una autorrevisión con ejecución de pruebas, no una revisión independiente por otro desarrollador. Los conteos siguientes son evidencia de casos concretos, no un porcentaje de calidad o cobertura.

La revisión anterior fue demasiado amplia al sugerir que pasar la batería bastaba para cerrar calidad. Esta auditoría encontró un fallo reproducible del servidor, un acoplamiento incorrecto de configuración y debilidades de la infraestructura de pruebas. Se corrigieron.

## Hallazgos concretos

| Hallazgo | Evidencia y resolución |
|---|---|
| Salir el controlador podía borrar el input de otro jugador | Tras salir el controlador original, se reutiliza su puesto 1. Si luego sale el controlador siguiente, el manejador borraba `currentInputs[1]` aunque perteneciera a otra persona. La prueba nueva falló antes del arreglo y pasó después. El modo de partido conserva ahora el input de ese puesto; el modo legacy conserva su limpieza propia. Evidencia en `docs/audit/controller-disconnect-reproduction.json`. |
| Damping de patada acoplado al damping normal | La fábrica de jugadores tomaba `playerDamping` para ambos. Con los valores actuales iguales no se observaba; al configurar `.8` solo para patada, fallaba el contrato. Ahora usa `playerKickDamping` y existe una prueba de configuración diferenciada. |
| Eliminación de líneas con require en algunos runners | Un filtro por texto podía quitar código ejecutable junto con una dependencia. Se sustituyó por un cargador que construye el árbol desde `instance.json` y ejecuta los cuerpos de ModuleScript sin borrar ni reemplazar líneas de su fuente. Se verifica además resolución de dependencias y caché. Los adaptadores de servicios continúan siendo simulados. |
| Comparador incompleto | Ahora exige exactamente todos los escenarios, frames, discos y cuatro componentes finitas por disco. Comprueba también tick e identidad de cada patada y tick/equipo de cada gol Classic. |
| Serialización que podía ocultar estructuras | El encoder anterior recorría `ipairs` sin validar forma. Ahora rechaza diccionarios, huecos, valores no finitos y tipos no soportados; el runner exige exactamente una emisión de resultados. Hay pruebas que provocan esos fallos deliberadamente. |
| Comparación histórica con supuesto modo anterior | La sonda adaptativa archivada no instalaba su geometría productiva completa. Su cifra de 63 divergencias se retiró como evidencia comparativa. La campaña del modo discreto frente a Node sí se vuelve a ejecutar y pasa con el comparador reforzado. |
| Código difícil de revisar | Se formatearon los módulos principales modificados, se extrajo el programa Luau del comparador a un archivo propio, se centralizó la carga de módulos/reportes y se retiró una función de integración sin llamadas. Dependencias de herramientas fijadas por lockfile. |

La sospecha inicial de doble conteo de contactos **se descartó**: las dos ramas eran excluyentes. Se retiró una guarda redundante añadida durante la inspección. Se mantuvo una prueba que obliga a generar un contacto y comprobar su contador; introducir deliberadamente un incremento doble hace fallar esa prueba.

## Pruebas ejecutadas

- 47 regresiones previas.
- 75 escenarios contra Node-Haxball 2.3.0: 22.870 ticks por motor; posiciones y velocidades coinciden con error máximo cero; eventos de patada y gol comparados con tiempo e identidad.
- 20 pruebas de partido/cancha/cámara, incluyendo las dos simulaciones de 12.000 ticks con comparación de estados y eventos.
- 10 pruebas del servidor y 10 del cliente con adaptadores locales.
- 11 comprobaciones de la propia infraestructura de pruebas.
- 64 partidos con semillas pseudoaleatorias reproducibles, 1.800 ticks cada uno: **115.200 ticks** con controles, goles programados, reinicios, ambos equipos iniciales y límites de marcador. Se comprueban finitud, congelación de posiciones, conservación del marcador, ticks y máscaras.
- **12 mutaciones detectadas de 12 seleccionadas.** Los fallos se introducen en memoria, en subprocesos separados, sin escribir las fuentes productivas. Para contarse como detectado debe existir una prueba de comportamiento fallida; un error de compilación, timeout o fallo de infraestructura no cuenta como éxito.
- Compilación de 16 scripts/módulos y comprobaciones de formato de JavaScript y del Luau revisado.

### Mutaciones comprobadas

Desactivar goles; asignar el punto al equipo contrario; omitir el bloqueo de X mantenida; no completar el saque; ejecutar física durante una pausa; reducir a la mitad el diámetro visual; dejar de actualizar el balón; ignorar el identificador de partido al reiniciar; recortar la cámara; duplicar el incremento del contador de contactos; reintroducir el borrado del input de otro jugador al salir el controlador; usar la configuración equivocada de damping de patada.

No se usa el porcentaje 12/12 como una estimación de cobertura de todo el código. Solo muestra que las pruebas detectan esos fallos deliberados.

## Cómo comprobarlo

Entorno ejecutado: Node 24.22.3 y las versiones fijadas por `tests/offline/package-lock.json`.

```sh
cd tests/offline
npm ci --ignore-scripts --no-audit --no-fund
npm test
npm run test:quality
npm run format:check
npm run format:check:luau
cd ../..
python tests/validate_place.py
python tools/place.py verify
```

Resultados individuales: `tests/offline/*results.json`. Resumen de grupos, versiones, hash del lockfile y hashes de las fuentes: `tests/offline/quality-summary.json`. Los logs de los fallos deliberados se regeneran en `build/audit-mutations/` y no se incorporan al juego ni al repositorio.

## Deuda y límites que siguen abiertos

1. **Roblox nativo:** no se han ejecutado InputActions, servicios, cámara, render ni rendimiento reales en Studio. Los adaptadores comprueban lógica y contratos de propiedades, no píxeles ni el comportamiento completo de la plataforma.
2. **Arquitectura del servidor:** `LabServer` sigue mezclando adaptación de servicios, escenarios de depuración, métricas e historial. `LocalMatch2D` y el motor sí están separados; antes de endurecer la red conviene separar las herramientas de laboratorio del servidor de juego.
3. **Tipos:** los módulos principales todavía no tienen una comprobación estática completa con tipos estrictos de Luau. Compilar, formatear y ejecutar pruebas no sustituye ese análisis.
4. **Rendimiento:** esta auditoría no ofrece un benchmark nativo con diez clientes ni una garantía de presupuesto CPU/RAM. La batería no valida red, reconciliación, abuso de RemoteEvents o reconexión de transporte.
5. **Referencia:** Node-Haxball es una implementación independiente. La paridad de estos escenarios no certifica el cliente oficial, mapas arbitrarios, joints ni todas las configuraciones de patada.
6. **Ejecución continua:** las pruebas son reproducibles localmente; no se ha añadido una ejecución automática obligatoria en cada push.

La conclusión sustentada es una base de laboratorio funcional y mejor comprobada, con correcciones demostrables y límites documentados. No una garantía general de calidad de producción.
