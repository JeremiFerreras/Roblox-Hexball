# Decisión — instrumentación del solver y causa de escenario 3

## Veredicto: GO para diagnóstico causal contra Node-HaxBall 2.3.0

La sonda específica de la rama interna E$ quedó validada en esta fixture: salida física idéntica byte a byte al baseline, hashes deterministas, 540 ticks y callbacks en el mismo orden. A diferencia del wrapper exterior, esta sonda captura la rama de planos antes/después de proyectar y actualizar velocidad.

La causa de vy=0 quedó demostrada en la implementación Node 2.3.0: primero se resuelve el plano exterior superior (runtime/HBS index 1), bCoef 0. La fórmula con disco bCoef .5 da factor 1; la operación de velocidad normal elimina vy entrante. Después, el plano interior de área de balón (index 5, bCoef 1 en Core/HBS omitido en la captura) solo corrige y a y=160 porque vn ya es cero. La identidad de callback planeId=1 se demuestra: el callback pasa directamente `f$`, el índice de `K` usado por la rama de planos.

Las micropruebas A-F de un solo plano se ejecutaron en procesos Node 2.3.0 y en mundos temporales del Core real vía MCP. A/B/C/D/E muestran que el plano interior aislado con bCoef 1 aplica el mismo rebote normal (-24.75 para vy=50 con damping .99); la diferencia de posición viene de la cronología subpaso/fin de tick. E con plano exterior bCoef 0 lleva vy a 0 en ambos. F desde el lado opuesto no rebota; ambas implementaciones corrigen posición, con distintas posiciones de fin de tick.

No se modificó el solver productivo, perfil ni place. Studio sigue Edit y no se guardó/publicó. Este GO cierra el diagnóstico de esta divergencia para Node-HaxBall 2.3.0; no aprueba una corrección productiva ni certifica el cliente oficial.

Siguiente paso recomendado: reproducir en un harness Core diagnóstico el orden HBS real de planos (exteriores antes de ball-area) y sus bCoef explícitos, comparar contra el orden actual, y luego proponer una corrección de conversión/orden separada. No cambiar producción hasta revisar efectos sobre segmentos, goles y regresiones.
