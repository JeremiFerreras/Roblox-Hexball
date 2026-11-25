# Decisión — aislamiento del escenario 3

## Veredicto: PARTIAL GO

Se identifica con fuerte apoyo geométrico el plano candidato: el plano superior del área de balón Classic, n=(0,-1), dist=-170; una pelota de radio 10 toca con centro y=160. La definición visible de Studio coincide en normal y offset. El contacto no corresponde a los planos exteriores cuyo bCoef activo difiere del HBS.

La causa exacta no está cerrada: el callback Node `planeId=1` no está mapeado a la entrada HBS; la respuesta normal interna de Node no es expuesta por el callback; el bCoef del plano ball-area está omitido en el HBS capturado. No se ejecutaron micropruebas A–F ni se repitió la instalación 2.3.0 en esta sesión. Los datos deterministas anteriores siguen siendo evidencia histórica, no una reproducción nueva.

Escenarios 1/2 conservan la hipótesis documentada de cronología distinta: velocidades tras plano casi iguales, pero posiciones de fin de tick distintas, consistente con subpasos Core y corrección secuencial Node. Falta un contacto aislado para confirmar esa explicación; no se combina con la causa del escenario 3.

No se modificó ningún archivo productivo ni propiedad de Studio. Studio sigue en Edit; place no guardado ni publicado. Los archivos de auditoría de esta entrega son diagnóstico y no alteran el juego.
