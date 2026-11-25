# Fase 4 — cierre funcional fuera de Studio

Fecha: 25/11/2026. Estado: **GO para el alcance funcional local probado; validación nativa de Roblox pendiente.**

Esta revisión completa el trabajo funcional del partido local descrito en PHASE4_LOCAL_MATCH_2026-11-25.md. No inicia la fase 5 ni certifica apariencia, latencia o rendimiento en Roblox.

## Fallos encontrados y corregidos

1. Los discos visibles no respetaban el diámetro físico. Los cilindros originales usaban tamaños 7.5/1/7.5 (jugador) y 5/1/5 (balón), incompatibles con el eje X del cilindro y la escala de 0.5 studs/unidad. Ahora todos usan eje vertical, grosor 1 y diámetro `2*radius*scale`: jugador 15 studs y balón 10. Las instancias persistidas también están corregidas; los jugadores adicionales usan la misma forma.
2. Un Reset podía mantener el mismo tick y ronda. Se añadió `matchId` creciente a los snapshots y el cliente lo usa para descartar interpolación y controles artificialmente demorados del partido anterior.
3. La cámara fija podía recortar las porterías, especialmente en ventanas estrechas. Se calcula su altura a partir del campo completo, FOV y relación de aspecto, y se recalcula al cambiar el viewport.
4. La etiqueta de calibración mostraba la geometría HBS antigua pese a usar el perfil Node integrado. Ahora indica la referencia activa y cuenta sus elementos.
5. Las duraciones cero se aceptaban pese a necesitar un tick para transicionar. Se rechazan explícitamente: pausa y cuenta atrás deben tener al menos un tick. El límite de goles cero sigue significando sin límite.

## Verificación ejecutada

| Grupo | Resultado |
|---|---:|
| Compilación de scripts y módulos | 16/16 |
| Regresiones anteriores | 47/47 |
| Comparaciones físicas Node 2.3.0 | 75/75 |
| Partido local y geometría/cámara | 20/20 |
| Servidor real con servicios adaptados | 7/7 |
| Cliente real conectado al servidor adaptado | 10/10 |

Se mantuvieron las 22.870 muestras temporales por motor de la campaña física, con error máximo cero en posiciones y velocidades. La prueba local larga ejecuta dos partidos de 12.000 ticks cada uno y compara sus estados y orden de eventos tick por tick, incluidos los estados de patada. Incluye goles programados y controles para los diez jugadores.

El nuevo adaptador ejecuta el cuerpo completo de LabClient y LabServer, sin sustituir su lógica de partido. Usa objetos numéricos para vectores, CFrame y propiedades de instancias, señales locales para los eventos y un reloj controlado. Comprueba:

- Creación de controles, geometría y cámara.
- Publicación y aplicación de snapshots a los diez discos.
- Diámetros, orientación y posición lógica de los discos.
- Control mantenido durante la cuenta atrás y reenvío tras Reset.
- Gol, pausa y reposición, incluida la posición visible del balón.
- Descarte de inputs con retraso artificial de una ronda anterior.
- Visibilidad correcta al entrar/salir de un escenario de parejas.
- Reset con el mismo tick y ronda pero distinto partido.
- Interpolación numérica entre dos snapshots y reajuste de cámara.
- Rechazo de inputs inválidos y comandos de usuarios no autorizados.
- Diez puestos asignados, espectador adicional y reutilización de un puesto sin permitir que el jugador saliente lo controle.

`tests/validate_place.py` verifica fuentes incorporadas, inventario, identificadores únicos y referencias resueltas en el RBXLX. `python tools/place.py verify` comprueba también su reconstrucción estructural.

## Cómo repetir

```sh
cd tests/offline
npm ci --ignore-scripts --no-audit --no-fund
npm test
cd ../..
python tests/validate_place.py
python tools/place.py verify
```

Los resultados individuales están en `tests/offline/*results.json`. Los adaptadores no abren conexiones ni renderizan imágenes y no sustituyen Roblox Studio. Los arcos se verifican numéricamente; el test de CFrame comprueba el contrato de posición/orientación utilizado por el código, sin emular toda la matemática nativa de Roblox.

## Decisión de cierre

El ciclo de partido local puede considerarse terminado para el entorno offline probado: arranque, saque, controles, física, goles, marcador, último toque, autogoles, pausas, reposiciones, repetición de rondas y final opcional por marcador. No hay fallos conocidos de este alcance tras la campaña ejecutada. Esto no demuestra ausencia de errores en estados no probados.

Permanece una comprobación de aceptación en Studio: abrir `Roblox Hexball.rbxlx`, probar WASD/X, varios goles y saques, cámara y aspecto, y confirmar funcionamiento con los servicios reales. El rendimiento, el dibujo de píxeles, la recepción real de InputActions y la red no se pueden certificar con estos adaptadores. La fase 5 puede tomar esta base sin reabrir la calibración física por defecto.

## Auditoría de calidad posterior

El cierre funcional no equivalía a una certificación de calidad de producción. La [auditoría posterior](QUALITY_AUDIT_2026-11-25.md) corrigió un fallo de desconexión y un fallo de configuración, y reforzó las propias pruebas. Consultarla para el estado actual y las limitaciones.
