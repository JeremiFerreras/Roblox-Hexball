# Reproducción Node-Haxball 2.3.0

## Resultado

**A. REPRODUCCIÓN CONSEGUIDA.** El oráculo original se ejecutó dos veces con el paquete verificado en proceso como 2.3.0. Cada resultado tiene 38.693 bytes y SHA-256 `7d612957764a076d506f53c4dd8d7fd39381e3db261cb399a812f6eb7d110e37`, igual al fixture, byte por byte. No se sustituyó 2.3.0 por 2.3.1.

El fixture contiene 7 escenarios de 180 ticks; se instrumentaron los 3 Classic (540 ticks). Cada escenario recibió 180 callbacks onGameTick, frames consecutivos 1–180, sin faltantes ni duplicados. Las posiciones del balón instrumentadas coinciden con las 540 del fixture (0 discrepancias).

## Captura

El HBS exportado declara `ballPhysics: "disc0"`; se confirmó por propiedades del disco. Cada 1v1 tiene balón, cuatro postes y dos jugadores; el 3v3 tiene balón, cuatro postes y seis jugadores. Se vinculó a los jugadores por playerId. Se capturaron discos y propiedades numéricas en copias independientes pre/post por tick.

Eventos: caso 1, 3 plano, 1 segmento y 1 disco; caso 2, 1 plano, 20 segmentos, 2 discos, 1 gol y 1 reset; caso 3, 2 planos. No hubo inputs ni kicks. La captura completa está en [ORACLE_FULL_TICK_TELEMETRY.json](ORACLE_FULL_TICK_TELEMETRY.json).

Los eventos mantienen frame y argumentos públicos. Los objetos anidados se clonan hasta profundidad 3 con indicadores de circularidad. Los callbacks no proporcionan normales ni impulsos. La frecuencia de 60 Hz es el paso lógico del harness; no afirma frecuencia de render o paquetes. Node-Haxball sigue siendo una implementación independiente, no prueba del motor oficial.

Hashes y estados completos: [ORACLE_230_REPRODUCIBILITY.json](ORACLE_230_REPRODUCIBILITY.json); instalación: [ORACLE_230_INSTALLATION.json](ORACLE_230_INSTALLATION.json).
