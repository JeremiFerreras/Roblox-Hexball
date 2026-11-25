# Informe de regresiones — variantes de orden de planos (2026-11-19)

## Cobertura ejecutada

Se ejecutaron las siete fixtures en cada una de las variantes A–D y se repitió cada variante/fixture para verificar determinismo: S1 (180 ticks), S2 (13 ticks), S3 (180 ticks), esquina (2), oblicuo (2), lado opuesto (2) y balón-jugador (3). No se añadieron los microfixtures a la lógica productiva. Studio se mantuvo en Edit.

## Resultados por variante

- A Baseline y B Cambio de orden: mismo estado por tick en S1, S2 y S3.
- C Cambio de propiedades y D orden+propiedades: posiciones/velocidades iguales a A/B en S1/S2/S3; en S3 el impulso de evento del plano exterior derecho difiere en tick 35, sin cambiar el estado numérico capturado.
- A–D fueron deterministas en repetición según comparación de filas. No se calculó SHA-256 sobre cada flujo individual de estado Core; el JSON adjunto conserva las filas para que se puedan volver a hashear.
- Referencia Node 2.3.0: se reutiliza el fixture previamente verificado, SHA-256 `7d612957764a076d506f53c4dd8d7fd39381e3db261cb399a812f6eb7d110e37`. La telemetría de referencia existente contiene 540 estados; no se regeneró Node en esta tarea.

## Regresión/efectos observados

| Caso | Diferencia observada | Evaluación |
|---|---|---|
| S1 | Ninguna A–D; error comparativo sigue con primera divergencia diagnóstica en tick 16 | Sin regresión relativa entre variantes |
| S2 | Ninguna A–D; divergencia de posición ya en tick 4; velocidad casi igual a referencia | Sin regresión relativa entre variantes |
| S3 tick 4 | Ninguna A–D; permanece vy=-24.014900 y y=143.206363 | Orden/propiedad no solucionan la divergencia prioritaria |
| S3 tick 35 | C/D cambian el impulso registrado del plano exterior derecho; posición y velocidad permanecen iguales a seis decimales | Efecto de evento confirmado; no se midió cambio de trayectoria |
| Esquina | C/D cambian el impulso del plano exterior derecho 21→20 y alteran estados por tick; el orden registrado se mantiene área superior y luego exterior derecho | Efecto físico confirmado del cambio bCoef y evidencia de contacto múltiple |
| Oblicuo | Ningún cambio A–D | Sin efecto observado |
| Lado opuesto | B/D introducen contacto exterior superior además del plano de área; estados redondeados iguales, pero cambia el orden/número de eventos | Efecto de detección/evento confirmado para orden+geometría superpuesta |
| Balón-jugador | Ningún cambio en contacto disco-disco | Sin efecto observado |

No se ejecutó una batería dedicada de goles, ni se cubrieron todas las esquinas/empates geométricos ni todas las interacciones con jugadores. Además, el registro conservado para los cuatro microfixtures suplementarios no incluye en este entregable sus estados iniciales completos; sus resultados sirven como evidencia diagnóstica cualitativa, pero no bastan para que otro investigador reconstruya exactamente esas cuatro entradas. Por tanto, la ausencia de diferencias en esos casos puntuales no demuestra que un cambio global esté libre de regresiones.

## Estado de determinismo y hashes

La verificación ejecutada comparó las filas de estado repetidas y marcó `deterministicRepeat=true` para cada variante y fixture. Los archivos de salida ahora pueden hashearse; esto verifica integridad de estos artefactos, no sustituye una reproducción byte a byte del programa ni un hash del flujo sin redondear. Las filas del harness fueron redondeadas a seis decimales, de modo que los hashes de los archivos no deben interpretarse como equivalencia binaria de floats internos.

## Conclusión

No hay fundamento para aprobar un cambio permanente del orden: no afecta al tick 4 de S3 y genera un contacto agregado adicional desde el lado opuesto en el microfixture. El cambio de bCoef exterior cambia un evento posterior en S3 y el estado de esquina, sin resolver la primera respuesta divergente. Mantener las variantes en el harness temporal y estudiar por separado la cronología de integración.

