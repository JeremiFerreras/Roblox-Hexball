# Decisión de Fase 3

## Veredicto

**B. REPRODUCCIÓN CONSEGUIDA, TELEMETRÍA PARCIAL.** La instalación exacta 2.3.0 reproduce el fixture; hay estados y eventos por tick para los tres casos Classic. **La calibración dinámica de Fase 3 continúa NO-GO para cierre**, porque el oráculo es independiente y PhysicsCore2D diverge después de colisiones.

No se cambiaron scripts, parámetros, objetos ni place. Studio terminó en Edit. La suite previa 47/47 no se repitió porque ningún script Roblox fue modificado.

## Comparación in-memory

Se usaron Physics2D.MatchCore (igual al módulo PhysicsCore2D), ClassicStadium2D, perfil activo, estados y posiciones iniciales del oráculo y cero inputs. Solo se crearon tablas en memoria durante Play temporal.

- [8,55], balón: RMS posición 1.72045; máximo 2.41161 en 180 ticks; primer error >0.01 en tick 16. Contactos del oráculo: planos 3,16,48; segmento 60; disco 92.
- [-30,45]: comparación hasta tick 13, anterior al gol del 14; RMS 6.96280, máximo 7.93881; primer error >0.01 en tick 4.
- [40,50], balón: RMS 583.81075 y máximo 754.69224 en 180 ticks; primer error >0.01 en tick 4. El RMS incluye divergencia de contacto y cascadas posteriores; no mide movimiento libre.
- Errores por jugador y velocidades: [CLASSIC_ENTITY_COMPARISON.json](CLASSIC_ENTITY_COMPARISON.json).

La coincidencia de fixture y la comparación contra el núcleo no certifican Haxball oficial ni justifican modificar coeficientes.

## Siguiente trabajo

1. Mantener valores activos sin cambios.
2. Construir ensayos aislados de un solo contacto (planos superior/inferior, pared, segmento, poste), registrando velocidad inmediatamente antes/después.
3. Confirmar para cada ensayo que ambos motores golpean la misma superficie y comparar el mismo paso lógico.
4. Aislar el efecto del orden de solver y subpasos en un comparador temporal, sin cambiar la física activa.
5. Reabrir calibración frente al motor oficial solo si aparece una referencia oficial reproducible.

Aceleración y disparos siguen sin validarse: estas entradas no incluyen movimiento de jugadores ni patadas. No hay base para afirmar fidelidad 1:1.
