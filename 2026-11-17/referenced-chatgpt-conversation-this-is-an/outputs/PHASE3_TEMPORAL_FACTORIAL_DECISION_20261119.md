# Decisión factorial de Fase 3

**PARTIAL GO para investigación; NO-GO para adoptar T1 en producción.**

**Hechos ejecutados:** ocho combinaciones en S1 (180 ticks), S2 (13), S3 (180); 14 casos A–F con T0/T1; seis controles suplementarios con ocho variantes; repeticiones byte idénticas de 12/12 fragmentos principales y de los harnesses pequeños. En S3, tick 4 solo T1O1P1 coincide con la trayectoria de referencia entre las ocho variantes. A–F T1 coincide numéricamente con salidas Node archivadas anteriormente. La red, esquinas y disparo rápido revelan riesgos de T1.

**Inferencia respaldada:** la diferencia S3 depende de una interacción del momento de contacto, el orden de los planos y el bCoef exterior. La variante de integración completa T1, por sí sola, no basta.

**Pendiente:** equivalencia de la semántica completa de Node, robustez multi-tick en controles de goles, y coincidencia de estados/eventos de todos los jugadores. Los resultados Node usados son el oracle archivado, no una ejecución nueva.

**Recomendación:** investigar en un clon una cola temporal de contactos con re-detección del tiempo restante y candidatos de segmentos/planos/discos. No modificar producción todavía.

No se modificó el Core ni la instalación original de Node. Studio permaneció en Edit. El Place no se guardó ni publicó.

