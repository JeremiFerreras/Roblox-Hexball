# Validación física ejecutada fuera de Studio — 25/11/2026

## Resultado

75/75 escenarios diferenciales aprobados; 22.870 ticks por motor; 70 patadas de referencia, todas contabilizadas igual. Posición x/y y velocidad vx/vy de cada disco coinciden con tolerancia absoluta 1e-9. Cruces de gol Classic por tick coinciden. 47/47 regresiones históricas ejecutadas ahora en Luau WASM. Dos corridas consecutivas iniciales generaron resultados idénticos; la campaña posterior usando el instalador real del estadio también pasó.

## Cambios

- PhysicsCore2D admite `solverMode="haxballDiscrete"`: un avance de posición, gravedad/damping y luego colisiones en orden. El modo `adaptive` conserva su comportamiento anterior y sigue siendo el valor por defecto de la API para no alterar pruebas/herramientas antiguas.
- LabServer selecciona explícitamente el modo discreto para el partido 5v5.
- ClassicStadium2D carga ClassicReference230 en ese modo. Conserva el perfil HBS anterior para el modo adaptativo. Son perfiles diferentes: no mezclar sus coordenadas, orden de planos o restitución.
- El perfil nuevo incluye vértices, segmentos abiertos, curvas y bias, y planos con el orden/valores de la referencia. La red integrada de Node tiene, por ejemplo, puntos de x=378/y=42 donde el HBS anterior usaba x=380/y=44.
- En discreto se omite el par de centros exactamente coincidentes, como en Node; el modo adaptativo mantiene su separación determinista.
- Los recorridos de gol discretos usan posición inicial y posición final corregida del tick. Se contabilizan contactos de vértice en el servidor.

El modo anterior divergía en 63 de los 75 escenarios de la campaña. No se ajustaron aceleración, damping, fuerza de disparo ni masas para forzar coincidencias: en las pruebas digitales ejecutadas sus valores existentes ya coincidían.

## Reproducción

Consultar tests/offline/README.md. Dependencias fijadas por package-lock.json, sin instalación global ni Studio. `npm test` falla si encuentra discrepancias. El API del oráculo se importa sin parches físicos ni instrumentación que modifique su solver.

## Alcance del cierre

Se cierra la discrepancia física frente a la referencia Node 2.3.0 para esta batería y el perfil Classic seleccionado. No se certifica equivalencia universal ni con el cliente oficial. Faltan ejecución en Studio, presentación/colocación visual de la red (el perfil visual anterior se conserva), latencia/red, transición integral de pausas y saques, mandos analógicos, configuraciones alternativas de kick-rate y mapas con joints. TOI/PGS archivados no se integran: no son necesarios para reproducir el orden discreto probado.

Para abrir directamente la actualización: `Roblox Hexball.rbxlx`. El lugar anterior se conserva en archive/Roblox-Hexball-before-physics.rbxlx. También se puede reconstruir con `python tools/place.py build`.
