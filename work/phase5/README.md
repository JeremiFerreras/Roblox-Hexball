# Fase 5: buffer adaptativo y métricas (trabajo en curso)

Base: `974c892b22a5a5b23736a0a50b9cc6af46dc287d`.

Estos módulos son propuestas aisladas en `work/phase5`. **Todavía no están conectados al cliente ni al archivo .rbxlx.** La ejecución local dejó de estar disponible al retomar el trabajo; eso impide afirmar que la nueva versión integrada esté validada.

## Cambios propuestos

- `SnapshotBuffer.luau`: historial de hasta 32 poses; margen adaptativo de 2–6 ticks (33,3–100 ms a 60 Hz); reloj continuo; reproducción monotónica; límite estricto en el último estado confirmado.
- Se elimina el reajuste del reloj por cada llegada tardía. El primer intento sufría frenadas y demasiados reajustes.
- Las pausas, nuevos partidos y nuevas rondas no mezclan poses de etapas distintas.
- Una interrupción congela la presentación remota. La recuperación grande puede recolocar el cursor; se cuenta como rebuffer.
- Si el servidor se detiene y reanuda avanzando pocos ticks, se renueva el anclaje del reloj.
- `NetMetrics.luau`: ventanas de 256 muestras para ACK, RTT, correcciones, antigüedad y retraso visual; p50/p95/máximo; contadores locales. Los percentiles sin muestras quedan vacíos.

El margen configurado de 100 ms **no limita la antigüedad real durante una pérdida de conexión**. El reloj no mide latencia de una vía ni sincroniza físicamente el cliente con el servidor.

## Comprobaciones

`model-results.json` guarda **15 comprobaciones ejecutadas del modelo JavaScript**, incluidas 9 combinaciones de 30/60/240 FPS con 0/5/15 % de pérdida. Simulan 30,2 segundos; semilla 1731; llegadas con 50–120 ms de retraso; reordenamiento posible. El movimiento de referencia es lineal, a 120 unidades/s.

En esas trazas, la media del error absoluto de velocidad baja frente a la interpolación anterior entre dos estados. Esto mide suavidad de un movimiento sintético. **No demuestra menor ping real, igualdad competitiva, correcciones correctas de contactos ni calidad visual en Roblox.**

En el caso de 60 FPS y 0 % de pérdida, el error medio es aproximadamente 1,82 frente a 48,25 unidades/s. Sigue habiendo episodios de falta de datos; con 15 % de pérdida hay recuperaciones y la antigüedad puede superar el margen configurado. Los valores completos están en el JSON, incluidos esos casos desfavorables.

`presentation-tests.luau` prepara **21 casos para los módulos Luau reales**. Su estado de ejecución debe comprobarse en el registro de CI; el informe JavaScript no los sustituye.

Desde la raíz del repositorio:

```sh
node work/phase5/check-model.mjs
npm ci --prefix tests/offline
node work/phase5/check-luau.mjs
npm test --prefix tests/offline
npm run test:quality --prefix tests/offline
```

El runner Luau usa `luau-web@1.5.1`, ya fijado por el proyecto. No transforma el código de los módulos. El modelo JavaScript reproduce únicamente el reloj y sus invariantes, no la interpolación completa de poses.

## Integración pendiente

1. Ejecutar y corregir los 21 casos Luau, luego repetir las regresiones existentes.
2. Registrar ambos ModuleScript y sus metadatos en ReplicatedStorage/HaxballLab.
3. Usar el buffer para jugadores remotos y para la pelota cuando no haya predicción; conservar la predicción propia.
4. Medir ACK desde la creación original del input hasta su confirmación; evitar contar duplicados; clasificar cancelaciones en cambios de época.
5. Contar correcciones sólo cuando exista un pronóstico del mismo tick; no inventar muestras de cero en el bootstrap.
6. Medir bytes al enviar/recibir realmente el buffer; excluir cabeceras y bytes desconocidos de tablas fiables.
7. Exponer un BindableFunction local de diagnóstico y actualizar percentiles del HUD una vez por segundo. Recoger edad/retraso a una cadencia fija, sin ordenaciones por frame.
8. Añadir pruebas del cliente real con adaptadores: interpolación de un jugador remoto en fase playing, pausas exactas, duplicados sin renovar edad, ACK y cancelaciones.
9. Regenerar .rbxlx e inventario; verificar referencias, fuentes y round-trip; repetir regresiones y mutaciones.
10. Medir en Studio con varios clientes antes de cerrar fase 5 o prometer mejoras de ping/fairness.

No se ha implementado compensación competitiva de latencia en esta propuesta.
