# Forense del solver — escenario 3

## Secuencia de Core inspeccionada en Studio
1. `stepWorld` aplica input/kick.
2. Elige subpasos adaptativos por velocidad y radio.
3. Cada subpaso avanza posición por v/N; por disco y en orden, resuelve pares dinámicos, planos y segmentos inmediatamente. En el plano proyecta penetración y refleja la componente normal entrante con `1 + disc.bCoef*geometry.bCoef`.
4. Completa los subpasos restantes usando la velocidad ya cambiada.
5. Aplica gravedad/damping una vez al final del tick.

## Secuencia Node/Nago documentada anteriormente
1. Avanza posición una vez con velocidad previa; amortigua velocidad/gravedad.
2. Recorre discos secuencialmente y resuelve contactos de pares.
3. Por disco, recorre planos, corrige posición y actualiza inmediatamente componente normal si es entrante; sigue segmentos/vértices y dos pasadas de juntas.
4. Callback de plano es público pero no expone normal, penetración ni impulso.

## Evidencia versus interpretación
**Observado en la telemetría congelada:** tick 4 empieza tras vuelo libre equivalente hasta tick 3; radio 10; contacto geométrico en y=160; Node acaba con vy=0; Core acaba con vy≈-24.0149 y y≈143.2064. El callback Node da planeId=1.

**Código inspeccionado:** perfil Core del ball-area top: n=(0,-1), offset=-170, bCoef=1; pelota bCoef=0.5. Entrando con velocidad normal negativa en la convención de Core, la fórmula multiplica la inversión por 1+0.5*1=1.5; la salida reportada por Core es coherente con ese coeficiente y subpasos. La telemetría inicial Node declara pelota con los mismos radius, damping y bCoef. El HBS omite bCoef de los planos ball-area.

**Inferencias:** por coordenadas y radio, el plano geométrico candidato es el ball-area top. La diferencia del tick puede involucrar selección/propiedad efectiva del plano o cronología del solver; con datos de final de tick no se separan.

**No demostrado:** que callback planeId=1 sea índice HBS 5; que Node tenga bCoef efectivo 0 en dicho plano; que cambiar bCoef replique vy=0; que normal o filtro de colisión difieran; el estado justo antes de impacto dentro de cada paso.

## Prueba discriminante pendiente
Instrumentar un solo balón y un solo plano en copias temporales de ambas implementaciones; registrar pre/post resolución. Primero igualar n, offset, radio, bCoef efectivo, damping, tick y estado de entrada. Luego variar solo bCoef, después solo calendario de integración/corrección. No tocar producción.
