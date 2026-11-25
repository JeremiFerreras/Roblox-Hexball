# Diagnóstico de la ruta MCP de Studio

- `list_roblox_studios` respondió con una sola instancia: `Football, hexball`, place ID `85137916104328`, studio ID `3e731d6a-4da2-40c5-a4e1-74d65208d2b0`, modo Edit.
- `get_studio_state` respondió: Edit disponible y enfocado.
- La operación inocua `search_game_tree` sobre `ServerStorage` respondió para ese target y devolvió el árbol raíz solicitado.
- `ExecuteLuau` falló con `Target is not reachable (ExecuteLuau.runCode, DMN_ID_EDIT)` / `No OnInvoke handler responded`. No se repitió la llamada.

La selección de instancia, el DataModel Edit y las lecturas MCP responden. El fallo observado se limita al manejador de ejecución Luau/OnInvoke; con la evidencia disponible no se puede distinguir si la causa está en el puente de ejecución o en el registro del manejador. No hay evidencia de sesión Play requerida: la prueba solicitada era Edit y esa lectura funcionó. Se detuvo la ejecución de código en Studio. El Place no se alteró, guardó ni publicó.

La búsqueda local no encontró ejecutables `luau`, `lua`, `luajit` o `rojo`. Se usó el runtime JavaScript V8 disponible en el entorno de herramientas para pruebas matemáticas traducidas del algoritmo; esto no ejecuta ni valida sintaxis/comportamiento de Luau. Node REPL no forma parte de una ruta local comprobada en esta etapa.
