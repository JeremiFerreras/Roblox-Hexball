# Diagnóstico de anomalías

## Escenario 2: (0,0)

Gol y reinicio demostrados en Node-Haxball 2.3.0. En frame 14 ocurren onCollisionDiscVsSegment y onTeamGoal; teamId=2, goalId=1, ballDiscId=0. El marcador azul sube a 1, el estado pasa a 2 y goalTickCounter=150. En frame 163 el contador es 1. En frame 164 ocurre onPositionsReset: el balón pasa de aproximadamente (-388.1659,41.4159), velocidad (-0.04425,-0.11278), a (0,0), velocidad cero; el estado vuelve a 0 y el marcador permanece.

No es rebote, captura duplicada ni teleport aislado: es reinicio posterior al gol. **RECONSTRUIDO**, confianza alta para Node-Haxball, no para el motor oficial.

## Escenario 3: reposo en (410,160)

Frame 4: contacto de plano de disc0; después del paso, centro (157.61596,160), velocidad (38.42384,0). Frame 11: segundo contacto de plano; centro (410,160), velocidad (0,0). Desde frame 12 hasta 180 posición y velocidad permanecen iguales; el juego sigue en estado activo y onGameTick continúa, marcador 0–0, sin gol ni reset.

Control adicional con velocidad [40,50] y 0, 2 o 6 jugadores produjo la misma trayectoria y los mismos callbacks durante 12 ticks: se descarta interferencia de jugadores. El radio 10 sitúa el centro en x=420−10 y y=170−10. La coordenada x coincide con el plano exterior derecho del HBS, cuyo bCoef exportado es 0; el plano superior del área de balón no declara bCoef en el objeto exportado. Los datos observados muestran que ambas componentes normales llegan a cero, pero el callback no expone normales ni impulsos. La correspondencia de los planos es **INFERIDA**, confianza alta; el detalle interno que cancela vy queda desconocido.

La simulación no se congela: el disco queda físicamente en reposo. La trayectoria plana ocultaba los eventos y el estado de partida.

## Límites

Estos hallazgos describen Node-Haxball 2.3.0 y su estadio Classic exportado. No certifican el motor oficial.