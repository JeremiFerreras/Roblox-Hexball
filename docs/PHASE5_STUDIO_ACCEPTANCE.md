# Aceptación nativa pendiente — fase 5

1. Abrir el RBXLX actualizado en Studio. Iniciar servidor local y al menos dos clientes; después repetir con diez cuando el entorno lo permita.
2. Confirmar controles de cada puesto, marcador común, goles, pausa y saque. Mantener X durante una pausa: no debe patear hasta soltar y volver a pulsar.
3. Aplicar Network Simulation con latencia, jitter y pérdidas. Repetir con conexiones diferentes entre clientes. Registrar parámetros exactos y capturas de los contadores; no usar solo el retraso artificial del botón del laboratorio.
4. Comprobar que tras perder actualizaciones no se aplican posiciones viejas, que soltar una dirección finalmente se procesa y que el juego converge después de una ráfaga de pérdidas.
5. Reiniciar el partido y marcar goles mientras hay tráfico atrasado. Ningún paquete anterior debe mover el balón de la ronda nueva.
6. Usar Network/MicroProfiler para medir bytes y tasas nativas. El buffer propio normal de estado mide 482 bytes, pero los bytes reales por red incluyen más tráfico y pueden estar comprimidos.
7. Medir respuesta local, tiempo hasta confirmación, correcciones de jugador/ball y percentiles. Repetir casos simétricos intercambiando conexiones y puestos; no confundir respuesta visual con ventaja competitiva.
8. Confirmar comportamiento de modo público: sin comandos de laboratorio ni historial continuo. No activar herramientas de debug para usuarios normales.

Estas comprobaciones no se presentan como ejecutadas. Su resultado decide el ajuste de frecuencias, interpolación y compensación competitiva.

Ya existe una prueba offline de diez copias del cliente real y un servidor con adaptadores. Sus resultados y límites están en [el informe multicliente](PHASE5_MULTICLIENT_2026-11-25.md). No sustituye esta lista nativa. Repetir especialmente el corte de 1,2 s y comprobar que el último pronóstico se congela sin saltar al estado antiguo.
