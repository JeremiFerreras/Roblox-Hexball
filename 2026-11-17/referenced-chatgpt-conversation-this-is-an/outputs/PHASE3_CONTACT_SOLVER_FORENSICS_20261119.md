# Forense del solver: contacto Classic, escenario 3, tick 4

## Operación observada en Node-HaxBall 2.3.0
En `src/api.js`, Nago `N.prototype.E$` integra primero posición y velocidad/damping, y después itera discos y planos. La rama de plano calcula `s = q.c$ - (n·position) + radius`; si `s>0`, proyecta `position += n*s`. Calcula `vn = velocity·n`; si `vn<0`, transforma `vn *= disc.bCoef * plane.bCoef + 1`, actualiza `velocity -= n*vn` y llama a `h.wr(discIndex,disc,planeIndex)`.

El instrumento en la copia 2.3.0 observó para tick 4:
- Pre plano index 1: centro (157.61596,197.01995), velocidad (38.4238404,48.0298005), radio 10, disco bCoef 0.5; plano normal (0,-1), offset -200, bCoef 0; penetración 7.01995; vn=-48.0298005.
- Pos plano index 1: centro y=190; vy=0. El término normal efectivo tras multiplicar por `1 + .5*0` permanece -48.0298005; restar ese vector normal elimina la velocidad Y. Callback se llama con índice 1.
- Pre plano index 5: centro y=190, vy=0; normal (0,-1), offset -170, bCoef 1; penetración 30; vn=0.
- Pos plano index 5: centro y=160, vy=0; solo corrección posicional, sin impulso.

Así, `planeId=1` es `f$`, índice cero-based del segundo elemento del arreglo runtime/HBS. En el HBS Classic ese elemento es plano exterior superior `(0,-1), dist=-200, bCoef=0`. El plano interior superior es índice 5; callback no lo reporta como causa de la pérdida de vy.

## Contraste con PhysicsCore2D activo
Studio Edit confirmó que `ClassicStadium2D.install` añade planos en orden de `StadiumReference2D`: ball-area bottom, ball-area top (índice 2; bCoef 1), outer bottom, outer top (índice 4; bCoef .1), left, right. En `stepWorld`, cada subpaso avanza posición y luego `resolveStaticGeometryForDisc` recorre `world.planes` en ese orden. En la ejecución temporal real vía MCP, el escenario 3 llega al tick 4 con salida Core (157.61596,143.206363), velocidad (38.4238404,-24.01490025), 13 subpasos; contacto registrado con `classic:ballArea:top`, normal (0,-1), penetración máxima 3.4326769 e impulso 72.772425.

La primera operación que cambia vy no es la misma: Node golpea primero el plano exterior superior HBS bCoef 0, neutraliza vy y luego el plano interior solo reposiciona; Core procesa primero el plano interior con bCoef 1 y devuelve el rebote previsto por su fórmula de restitución. El orden de planos superpuestos y sus propiedades activas explican causalmente la divergencia observada. No requiere atribuir un bCoef desconocido al plano interior HBS: la causa está en el plano exterior explícito.

## Evidencia separada
Observado: registros pre/post de la rama real en copia instrumentada; callback f$; salidas completas iguales al baseline; salida del Core ejecutado en Studio Edit con tablas nuevas en memoria.
Derivado: índices y fórmula del término normal por código inspeccionado. La igualdad índice→plano HBS se verifica aquí porque los seis planos runtime mantienen orden, normal y offset frente a export HBS.
No probado: equivalencia del cliente oficial Haxball. Node-HaxBall sigue siendo reconstrucción independiente.
