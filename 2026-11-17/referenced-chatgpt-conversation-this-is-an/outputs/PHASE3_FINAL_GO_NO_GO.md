# Fase 3 — decisión GO / NO-GO

## Veredicto: NO-GO para cerrar calibración dinámica

La alineación de ticks está validada y la suite interna pasó en una sesión limpia de Play. Pero no se regeneró el fixture con Node-Haxball 2.3.0, no hay telemetría completa por tick, los estados anómalos carecen de causa demostrada y no hay comparación de jugadores/eventos.

## Evidencia

- Alineación: 540/540 estados, ticks 1–180 por escenario, sin inicial duplicado.
- Suite fresca: 47/47 aprobadas, 0 fallidas; duración Luau 0.12421060000087891 s.
- RMS de pelota frente al fixture: 55.50, 108.89, 137.01 unidades.
- Contactos disponibles pertenecen al solver del laboratorio, no al oracle.

## Bloqueos

1. Node v24.22.3 está disponible; npm no. El intento npm view node-haxball@2.3.0 version dist.tarball dist.integrity falló antes de iniciar: The term npm is not recognized as a name of a cmdlet, function, script file, or executable program. No se descargó ni instaló el paquete.
2. Solo está disponible fuente 2.3.1; no se sustituyó por la versión solicitada.
3. El fixture no guarda velocidades, jugadores, inputs, contactos, goles ni resets.
4. Caso 2: salto a (0,0) en tick 164, causa desconocida.
5. Caso 3: [410,160] desde tick 11; velocidad/estado desconocidos.
6. Setup completo no demostrado: oracle incluye jugadores, laboratorio no; el HBS exacto del estadio default no está serializado.

## Regresión nueva

En una sesión nueva de Play, se ejecutó LabRegression.Run(Physics2D) en Server y se guardaron los 47 resultados individuales. Pasaron todos. Console output: cero errores Luau y tres avisos por tipo de asset en rbxassetid://203785492. Studio se detuvo y quedó en Edit; el place no se guardó ni publicó.

## Qué permite avanzar

Se puede continuar con pruebas internas y geometría, manteniendo los parámetros activos como provisionales. No declarar calibración 1:1 ni ajustar coeficientes usando estas curvas. Para cerrar dinámica hacen falta Node-Haxball 2.3.0 en entorno aislado, telemetría ampliada, estado inicial equivalente y causa reproducible de las dos anomalías.
