# Actualización causal del escenario 3

## Reforzado
- La recuperación real del runtime 2.3.0 permitió repetir el harness básico. Dos salidas idénticas, SHA esperado correcto, 3 Classic ×180 ticks.
- La localización geométrica en el ball-area top queda fuertemente respaldada: el centro y=160 corresponde a tangencia de radio 10 con la superficie y=170.
- La diferencia de respuesta de velocidad registrada en tick 4 persiste como observación histórica; el rerun básico de trayectoria no añade estados internos del solver.

## Descartado o no relacionado
- La discrepancia de bCoef de los planos exteriores no es el primer contacto, que ocurre en el límite interior de área de balón.
- No hay indicio de que jugadores causen ese primer contacto; los controles anteriores no alteraron la trayectoria.

## Sigue desconocido
- Significado del `planeId=1` runtime y su correspondencia con plano HBS.
- bCoef efectivo de ese plano Node: el HBS exportado lo omite.
- Normal/penetración/velocidad normal e instante interno Node: el callback no los expone.
- Si la respuesta Node vy=0 deriva de propiedad efectiva, rama del solver o secuencia temporal.

## Próxima prueba
Construir dos harnesses temporales de un solo plano y pelota: Node 2.3.0 y PhysicsCore2D en memoria Studio, estado de tick y plano idénticos. Medir antes/después de resolución. Después ejecutar A–F variando una dimensión por vez. Esta sesión no ejecutó esas pruebas y no justifica cambios productivos.

Estado productivo: sin modificaciones; Studio Edit; place no guardado/no publicado.
