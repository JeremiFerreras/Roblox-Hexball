# Auditoría de planos Classic — escenario 3

## Estado y alcance
Auditoría estática de las fuentes locales, los informes previos y la telemetría congelada. El fixture/oráculo Node-HaxBall 2.3.0 no está disponible como instalación ejecutable en esta sesión; la carpeta de fuente presente declara 2.3.1. Por ello no se repitieron A–F ni la reproducción 2.3.0. Studio fue leído en Edit; no se modificó.

## Contacto localizado geométricamente
En el tick 4, el centro termina en (157.615960,160), radio 10. En `stadiumHbs.planes` del registro Classic aparecen seis planos: índices HBS cero-based 0..3 son perímetro exterior, y 4/5 el área de balón con normales (0,1)/(0,-1), dist=-170. El centro a y=160 satisface tangencia al plano superior (`n=(0,-1)`, distancia firmada `-160`, radio 10); la distancia al otro ball-area plane y=-170 es 330. **El candidato geométrico es inequívocamente el plano superior del área del balón.**

El callback de Oracle reporta `onCollisionDiscVsPlane(..., planeId=1)` en frame 4. Otros eventos de la misma ejecución usan IDs distintos. No se localizó una tabla de mapeo que demuestre que `planeId` sea índice HBS, índice interno o ID del array. Por tanto el candidato geométrico no queda unido al `planeId` por identidad interna verificada.

## Definiciones contrastadas
- HBS telemetría, planos: cuatro exteriores con bCoef=0; ball-area inferior `n=(0,1), dist=-170, cMask=ball`; superior `n=(0,-1), dist=-170, cMask=ball`. El bCoef de los dos planos ball-area está omitido, por tanto no debe inferirse como cero.
- Perfil de Studio `ReplicatedStorage.HaxballLab.StadiumReference2D`: `classic:ballArea:top`, normal (0,-1), offset -170, bCoef 1, grupo 32, máscara 1. El ball-area bottom tiene el espejo geométrico. Los cuatro exteriores usan 0.1, distinto del HBS (0).
- `ClassicStadium2D.install` crea geometría a partir del perfil; `LabServer.makeCoreState` instala postes y geometría y desactiva bounds simplificados.
- Core resuelve plano por `signed=x*nX+y*nY-offset`, `penetration=radius-signed`, corrige `p += n*penetration`; si `v·n<0`, suma `n * (-(1+disc.bCoef*plane.bCoef)*(v·n))`.

Geometría/orientación del candidato coincide en coordenadas lógicas, normal y constante. La igualdad de filtros/propiedades efectivas dentro del motor Node y la causa de su `planeId` siguen sin probarse.
