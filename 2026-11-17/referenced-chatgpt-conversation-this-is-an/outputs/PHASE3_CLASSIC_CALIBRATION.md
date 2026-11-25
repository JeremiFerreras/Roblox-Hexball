# Fase 3 — Calibración física de Classic

Fecha: 2026-11-18  
Place: Football, hexball — PlaceId 85137916104328  
Referencia: [classic.hbs, commit 4b9724f49fe0ff87ad3f111eb91b208020d96d73](https://github.com/haxball/haxball-issues/blob/4b9724f49fe0ff87ad3f111eb91b208020d96d73/stadiums/classic.hbs)

## Resultado

La geometría de Classic queda contrastada campo por campo con el HBS fijado. No se encontró discrepancia numérica en límites, líneas de área, red, arcos del saque, postes o líneas de gol. La suite actual pasó 47/47 pruebas en Roblox Studio.

Se corrigieron tres diferencias del código del laboratorio con respecto a la referencia de colisiones: máscara de poste, conservación de colisión jugador-balón en kickoff y nombres de las dos semicircunferencias. Estas correcciones establecen consistencia con el HBS y la documentación; no certifican que la respuesta dinámica del solver sea idéntica al motor oficial.

## Auditoría geométrica

| Elemento | HBS fijado | Implementación final | Resultado |
|---|---|---|---|
| Propiedades superiores | width 420, height 200, spawnDistance 170 | mismos valores | Coincide |
| Fondo visible | width 370, height 170, kickOffRadius 75, cornerRadius 0 | 370×170, radio 75 | Coincide |
| Límites exteriores | planos en x=±420, y=±200; bCoef 0.1 | 6 planos en esas normales/distancias y bCoef | Coincide |
| Área del balón | planos y laterales en x=±370, y=±170; bCoef 1; cMask ball | 2 planos y 4 segmentos; wall group; máscara ball | Coincide |
| Boca de gol | x=±370, extremos y=±64; lado izquierdo team red y derecho team blue | mismas coordenadas; goles asignados al rival | Coincide con semántica HBS |
| Red | puntos x=±380/±400 y y=±64/±44; laterales curvos ±90°, bCoef 0.1, máscara ball | 6 segmentos de red, mismas coordenadas/curvas/coeficiente/máscara | Coincide |
| Barrera de kickoff recta | (0,200)→(0,75) y (0,-75)→(0,-200); bCoef 0.1; group redKO+blueKO; mask red+blue | mismos segmentos y flags | Coincide |
| Semicírculo kickoff blueKO | endpoints (0,75)→(0,-75), curve +180°, group blueKO, mask red+blue | mismo arco y flags; ID circleBlueKO | Coincide |
| Semicírculo kickoff redKO | endpoints (0,75)→(0,-75), curve -180°, group redKO, mask red+blue | mismo arco y flags; ID circleRedKO | Coincide |
| Postes | cuatro discos en (±370,±64), radius 8, invMass 0, bCoef 0.5 | mismos valores; discos estáticos | Coincide |
| Geometría total | 6 planos, 14 segmentos, 4 discos de poste | 6/14/4 | Coincide |

width/height del HBS describen la región de cámara; los límites físicos son los planos indicados. El fondo visual de 740×340 tampoco sustituye a la geometría física, que incluye redes y margen hasta x=±420/y=±200.

Las curvas se reconstruyen a partir de extremos y ángulo firmado. En el sistema de coordenadas del solver, redKO (-180°) queda en el lado +X y blueKO (+180°) en -X. Los identificadores anteriores circleLower/circleUpper eran ambiguos: se renombraron a circleRedKO/circleBlueKO. La geometría/ángulo no cambió.

## Grupos, máscaras y compatibilidad

Valores confirmados por los flags Haxball:

| Flag | Valor |
|---|---:|
| ball | 1 |
| red | 2 |
| blue | 4 |
| redKO | 8 |
| blueKO | 16 |
| wall | 32 |
| all estándar | 63 |
| kick | 64 |
| score | 128 |

Regla de contacto bidireccional comprobada: (A.group & B.mask) != 0 AND (B.group & A.mask) != 0.

| Par | Contacto esperado | Resultado de la matriz |
|---|---|---|
| Rojo–balón / azul–balón | Sí | Sí |
| Rojo–azul | Sí | Sí |
| Jugador–pared | Sí | Sí |
| Jugador–poste | Sí | Sí |
| Balón–pared / balón–poste | Sí | Sí |
| Jugador–barrera fuera de kickoff | No | No |
| Jugador–barrera con su flag KO activo | Sí | Sí |
| Balón–barrera kickoff | No | No |

Máscara base del jugador = ball|red|blue|wall = 39. Durante kickoff se añade redKO (8) o blueKO (16): máscara 47 o 55. No se elimina ball.

### Discrepancias corregidas

| Elemento | Antes | HBS/documentación | Corrección |
|---|---|---|---|
| Máscara de postes | 7 | cMask implícita all en el trait predeterminado | CollisionMasks.post y discos poste pasan a 63 |
| Máscara rival durante kickoff | se quitaba ball | la documentación describe máscara de jugador con ball, red, blue y wall, más flag KO | mantener ball; ambos equipos siguen colisionando físicamente con balón |
| IDs de semicircunferencias | circleUpper / circleLower | son arcos laterales opuestos, diferenciados por redKO/blueKO | IDs renombrados, sin cambio geométrico |

El bloqueo de la tecla de patada del equipo que no tiene el saque sigue siendo una regla del laboratorio. El HBS define barreras y flags de colisión, no esta regla de input. Su coincidencia con el cliente original queda desconocida y requiere experimento con Haxball.

## Ensayos realizados en Studio

- Regresión de punto de partida: 42/42 aprobadas; cada caso retornó nombre, resultado y detalle.
- Regresión final: 47/47 aprobadas, 0 fallos, 60 ticks/s lógicos.
- Arcos: en saque rojo, la aproximación desde el lado +X produjo contacto con classic:kickoff:circleRedKO; saque azul, desde -X, contactó classic:kickoff:circleBlueKO. Sin flag kickoff, ambos recorridos no registraron contacto con el arco. Máscaras: 47/55 en kickoff, 39 al terminar.
- Flujo de partido: escenario de gol registró gol rojo, pausa, reposición de balón y jugadores; estado observado con 5 rojos, 5 azules, 15 discos, saque azul y las 10 máscaras en 55. El balón conservó group 1 y mask 63.
- Línea de gol: cruce y=63.9 aceptado; y=64.1 rechazado; movimiento inverso rechazado; el segundo gol durante pausa fue rechazado.
- Pared y poste: balón golpeó el poste superior izquierdo; separación final 18, vx pasó de -2 a +0.5 en el ensayo. Contra plano superior, y quedó en 160 y vy pasó de +2 a -1. Son resultados de la implementación del laboratorio, no mediciones del motor original.
- Consola: no aparecieron errores Luau en esta ejecución. Persisten tres advertencias anteriores de tipo de asset para rbxassetid://203785492.

## Rendimiento observado

Benchmark local en Studio, mismo proceso, PhysicsCore2D.stepWorld, arena instalada y 15 discos:

| Ensayo | Ticks | Tiempo | Media | Máximo observado por tick | Substeps máx. | Finitud |
|---|---:|---:|---:|---:|---:|---|
| Formación 5v5 normal, en reposo | 6000 | 0.704 s | 0.117 ms/tick | 9.169 ms | 1 | Sí |
| Diez jugadores solapados cerca del centro | 1200 | 0.261 s | 0.217 ms/tick | 8.482 ms | 1 | Sí |

Esto da margen frente a 16.67 ms/tick en estas dos cargas, pero no es un benchmark de servidor publicado, incluye cargas de red/render, ni prueba los máximos de velocidad/substeps de todos los jugadores simultáneamente. Los picos incluyen fluctuaciones del entorno y no deben tratarse como un límite estadístico garantizado.

## Suite individual final

Las 47 pruebas informaron passed=true:

1. horizontal_free_acceleration_120_ticks
2. diagonal_normalization_120_ticks
3. release_damping_30_ticks
4. ball_damping_120_ticks
5. kick_range_and_impulse
6. fast_player_ball_crossing
7. fast_diagonal_player_ball_contact
8. multiple_ball_wall_bounces_in_one_tick
9. swept_player_pair_crossing
10. symmetric_two_player_ball_collision
11. three_disc_overlap_resolution
12. coincident_player_centers
13. core_fixed_tick_integration_order
14. core_diagonal_input_normalization
15. core_disc_collision_product_restitution
16. core_collision_masks_exclude_pair
17. core_kick_edge_only_once
18. core_ten_player_classic_world_600_ticks
19. core_dense_ten_disc_overlap_relaxes
20. core_replay_deterministic
21. core_boundary_clamp_and_bounce
22. core_kick_windup_uses_kick_damping
23. core_successful_kick_restores_normal_acceleration
24. core_insertion_order_is_preserved
25. core_segment_endpoint_cap
26. core_static_plane_contact
27. core_static_segment_contact
28. core_curved_segment_uses_arc_radius
29. classic_stadium_geometry_and_ball_only_boundary
30. classic_goal_mouth_ball_hits_net_without_tunneling
31. classic_field_trace_detects_goal_crossing
32. classic_goalpost_collides_with_player
33. goal_crossing_awards_opposite_team_and_interpolates
34. goal_pause_resets_ball_and_ten_player_positions
35. kickoff_countdown_locks_until_complete
36. micro_prediction_uses_fixed_tick_player_kinematics
37. micro_prediction_forecasts_ball_contact_without_applying_it
38. last_touch_records_physical_actor_and_overwrites_in_event_order
39. kickoff_rejects_wrong_team_kick_only
40. core_rejects_nonfinite_specs
41. classic_reference_profile_is_frozen_and_complete
42. classic_kickoff_collision_masks_select_reference_arc
43. classic_pinned_hbs_geometry_values
44. classic_collision_matrix_matches_hbs_flags
45. classic_wall_and_post_ball_response
46. classic_kickoff_arc_contacts_both_teams_and_deactivates
47. classic_goal_line_edge_and_duplicate_guard

Estas pruebas verifican el comportamiento esperado codificado en el propio laboratorio. Las pruebas 43–47 cotejan el perfil contra el fixture HBS congelado o recorren las reglas internas. No son una comparación independiente del motor oficial.

## Referencias y límites de evidencia

- HBS fijado: https://github.com/haxball/haxball-issues/blob/4b9724f49fe0ff87ad3f111eb91b208020d96d73/stadiums/classic.hbs
- Documentación del formato HBS: https://github-wiki-see.page/m/haxball/haxball-issues/wiki/Stadium-%28.hbs%29-File
- Documentación de flags y regla bidireccional: https://github-wiki-see.page/m/haxball/haxball-issues/wiki/Collision-Flags
- HaxballGym test_real_engine.py: https://github.com/HaxballGym/HaxballGym/blob/master/haxballgym/tests/test_real_engine.py
- HaxballGym test_fidelity.py: https://github.com/HaxballGym/HaxballGym/blob/master/rust/haxball_core/tests/test_fidelity.py

HaxballGym documenta un fixture de trayectorias de balón generadas mediante Node-Haxball (game-min.js), comparadas tick por tick en su port Rust con tolerancia cero; también distingue el test que compara primitivas contra Ursinaxball con tolerancia 1e-9. Ese resultado corresponde a su implementación y fixtures: no fue ejecutado en este Studio ni contra nuestro solver. Las páginas públicas consultadas no permitieron recuperar el fixture JSON ni verificar si sus escenarios abarcan Classic y todos estos estados límite. No se usa como prueba de nuestra fidelidad.

No se obtuvo trayectoria de referencia del Haxball original para los ensayos de pared/poste/arco/gol. Por ello:
- Geometría y flags: verificados contra HBS/documentación.
- Conteos, métricas y respuestas descritas arriba: medidos en el laboratorio.
- Comparación numérica de respuesta dinámica con Haxball oficial: pendiente/desconocida.
- Orden de solver y subpasos de Haxball original: desconocidos.
- Tiempo por tick de Studio: medición local orientativa, no garantía de producción.

## Estado de fase 3

La base geométrica de Classic y las máscaras de colisión están fijadas y trazadas al commit. El código del laboratorio pasó 47/47 pruebas y los ensayos de recursos quedaron dentro del presupuesto de tick en estas cargas.

**La fase 3 no se cierra como calibración física fiel todavía.** Se cierra la parte de referencia y verificación interna de cancha. Para cerrar la calibración dinámica hacen falta trayectorias comparables del motor original/fixtures reproducibles en Classic, especialmente para paredes diagonales/rasantes, transiciones, postes, contactos tangenciales, kickoff bilateral y goles pegados a los postes. Los coeficientes activos de disco (incluyendo rebote/masa del balón) siguen separados de los valores candidatos reconstruidos de Small y no se sustituyeron.

### Ensayos aislados adicionales de pared y poste

Estos casos ejecutaron directamente el núcleo del laboratorio con estadio instalado para paredes, y un disco poste estático aislado para distinguir sus contactos:

| Caso | Estado inicial | Resultado medido | Lectura |
|---|---|---|---|
| Pared perpendicular | balón (0,155), v=(0,6) | top contact; y=160, vy=-3; 2 substeps | Sin atravesamiento; rebote del solver con coeficientes activos del ensayo |
| Esquina diagonal | (360,160), v=(20,20) | contactos en plano superior y segmento derecho; x=351.667, y=151.667, v=(-10,-10); 6 substeps | Resolvió dos límites en un tick; orden interno afecta el resultado combinado |
| Rasante | (0,160), v=(5,0) | sin evento; x=5, y=160, v=(5,0); 1 substep | Deslizamiento sobre el plano sin impulso normal |
| Alta velocidad contra plano | (0,0), v=(0,500) | top contact; y=-7.5, vy=-250; 100 substeps; finito | No atravesó el plano en este caso a velocidad alta |
| Rebotes consecutivos verticales | (0,155), v=(0,60), 20 ticks | contactos top=1 y bottom=1; final y=-25, vy=15; finito | Dos paredes opuestas resueltas en la secuencia |
| Poste frontal aislado | balón (-20,0), v=(20,0), post r=8, balón r=10 | discContact; penetración 3, impulso 25; vx=-5 | Respuesta interna reproducible |
| Poste diagonal aislado | balón (-15,-15), v=(8,8) | discContact; penetración 0.558033, impulso 14.142136; v≈(-2,-2) | Contacto oblicuo detectado |
| Poste tangencial aislado | balón (17.5,0), vy=0.2, post en (0,0) | discContact; penetración 0.498857, impulso 0; vy=0.2 | Corrige solapamiento sin alterar la componente tangencial |

Los impulsos/penetraciones son campos calculados por el solver propio y no se compararon con el original. La esquina confirmó contactos simultáneos, pero no establece que el orden de resolución coincida con Haxball.
