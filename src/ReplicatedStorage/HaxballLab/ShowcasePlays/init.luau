-- Playbook of the main-menu showcase, consumed by MenuPreview.
-- Coordinates are stadium units and the attacking side always plays toward +x (red slots 1-4).
-- `mirror = true` only flips the presentation so the blue side stars in that move.
--
-- actions : who touches the ball next. "dribble" carries it to a point, "pass" sends it toward a point
--           (bank = 1/-1 plays it off the top/bottom wall) and "shot" finishes at the goal.
--           wait / meet delay the touch in ticks; tolerance is the allowed aiming error.
-- runs    : per attacker, { fromAction, x, y } off-ball movements.
-- defence : behaviour of the four defenders (press, mark, cover, keeper) and their reaction delay.
--
-- The simulation is deterministic and these values are tuned as a set: after changing any of them,
-- or the physics, run the Luau tests, which require every play to end in a clean goal.
return {
	{
		id = "tikitaka",
		title = "TIKI-TAKA",
		caption = "Toques rápidos, triángulos y definición",
		ball = { -18, -2 },
		red = { { 210, -60 }, { -45, -8 }, { 35, 75 }, { 129, 59 } },
		blue = { { 91, 11 }, { 175, 66 }, { 168, -32 }, { 345, 0 } },
		actions = {
			{ by = 2, kind = "pass", x = 35, y = 54, wait = 5, tolerance = 0.09 },
			{ by = 3, kind = "pass", x = 85, y = 43, wait = 13, tolerance = 0.04 },
			{ by = 4, kind = "pass", x = 98, y = -7, meet = 7, tolerance = 0.09 },
			{ by = 2, kind = "pass", x = 139, y = 16, wait = 11, tolerance = 0.09 },
			{ by = 3, kind = "pass", x = 266, y = -4, wait = 1, tolerance = 0.1 },
			{ by = 1, kind = "shot", x = 385, y = 43, wait = 8, tolerance = 0.04 },
		},
		runs = {
			[1] = { { 1, 210, -55 }, { 4, 223, -29 }, { 5, 246, 81 } },
			[2] = { { 1, -76, -5 }, { 2, 81, -32 }, { 5, 221, -21 } },
			[3] = { { 1, 25, 89 }, { 3, 74, 43 }, { 4, 162, 2 }, { 6, 183, 0 } },
			[4] = { { 1, 110, 35 }, { 4, 205, 49 }, { 6, 163, 28 } },
		},
		defence = {
			{ kind = "press", gap = 51, effort = 0.85, delay = 16 },
			{ kind = "mark", man = 3, gap = 0.51, effort = 0.42, delay = 10 },
			{ kind = "mark", man = 1, gap = 0.1, effort = 0.54, delay = 14 },
			{ kind = "keeper", effort = 0.5, delay = 23 },
		},
	},
	{
		id = "pared",
		title = "PARED Y DEFINICIÓN",
		caption = "Uno-dos para romper a la defensa",
		mirror = true,
		ball = { -25, -45 },
		red = { { -49, -34 }, { 16, 64 }, { -61, 22 }, { 70, -42 } },
		blue = { { -77, -65 }, { 32, -50 }, { 113, -57 }, { 345, 0 } },
		actions = {
			{ by = 1, kind = "dribble", x = 43, y = -33, radius = 18, effort = 0.6 },
			{ by = 1, kind = "pass", x = 173, y = 52, wait = 36, tolerance = 0.1 },
			{ by = 2, kind = "pass", x = 298, y = 49, wait = 3, meet = 7, tolerance = 0.06 },
			{ by = 1, kind = "shot", x = 385, y = -52, wait = 40, meet = 10, tolerance = 0.05 },
		},
		runs = {
			[1] = { { 1, -70, -18 }, { 3, 330, -145 } },
			[2] = { { 1, 99, 108 }, { 4, 204, 132 } },
			[3] = { { 1, -197, 145 }, { 3, 130, 102 } },
			[4] = { { 1, 35, -89 }, { 3, 98, -139 } },
		},
		defence = {
			{ kind = "press", gap = 29, effort = 0.54, delay = 28 },
			{ kind = "mark", man = 2, gap = 0.13, effort = 0.51, delay = 28 },
			{ kind = "mark", man = 4, gap = 0.34, effort = 0.47, delay = 12 },
			{ kind = "keeper", effort = 0.56, delay = 25 },
		},
	},
	{
		id = "colectivo",
		title = "GOLAZO COLECTIVO",
		caption = "Salida desde atrás: la tocan los cuatro",
		ball = { -262, -20 },
		red = { { -304, -20 }, { -208, -104 }, { -56, 70 }, { -48, 145 } },
		blue = { { -150, -10 }, { 56, -138 }, { 167, 44 }, { 345, 0 } },
		actions = {
			{ by = 1, kind = "pass", x = -111, y = -140, wait = 23, meet = 7, tolerance = 0.04 },
			{ by = 2, kind = "pass", x = -92, y = 20, wait = 4, meet = 6, tolerance = 0.1 },
			{ by = 3, kind = "pass", x = 96, y = 91, wait = 13, meet = 2, tolerance = 0.07 },
			{ by = 4, kind = "pass", x = 183, y = 134, wait = 22, meet = 1, tolerance = 0.07 },
			{ by = 1, kind = "pass", x = 317, y = -8, wait = 39, meet = 6, tolerance = 0.1 },
			{ by = 3, kind = "shot", x = 385, y = 6, wait = 24, meet = 11, tolerance = 0.12 },
		},
		runs = {
			[1] = { { 1, -293, -5 }, { 2, -140, -46 }, { 3, 23, -13 }, { 4, 85, 17 }, { 5, 169, 108 } },
			[2] = { { 1, -261, -116 }, { 3, -67, -127 }, { 5, 75, -61 } },
			[3] = { { 1, -70, 51 }, { 3, -65, 57 }, { 4, 155, 51 }, { 5, 204, 5 } },
			[4] = { { 1, -46, 122 }, { 3, 96, 138 }, { 4, 0, 93 }, { 5, 173, 86 } },
		},
		defence = {
			{ kind = "press", gap = 28, effort = 0.42, delay = 12 },
			{ kind = "press", gap = 83, effort = 0.47, delay = 13 },
			{ kind = "mark", man = 4, gap = 0.25, effort = 0.43, delay = 19 },
			{ kind = "keeper", effort = 0.51, delay = 24 },
		},
	},
	{
		id = "autopase",
		title = "AUTOPASE CON LA PARED",
		caption = "Talento: usa la banda para dejar al rival atrás",
		mirror = true,
		ball = { -30, 70 },
		red = { { -57, 89 }, { 40, 25 }, { -195, -53 }, { 58, -110 } },
		blue = { { 5, 136 }, { 250, 92 }, { 83, -135 }, { 345, 0 } },
		actions = {
			{ by = 1, kind = "dribble", x = 53, y = 89, radius = 24, effort = 0.57 },
			{ by = 1, kind = "pass", x = 319, y = -118, bank = 1, tolerance = 0.09 },
			{ by = 1, kind = "shot", x = 385, y = -12, wait = 23, meet = 8, tolerance = 0.06 },
		},
		runs = {
			[1] = { { 1, -73, 24 }, { 3, 86, 113 } },
			[2] = { { 1, -4, 115 }, { 3, 186, -125 } },
			[3] = { { 1, -175, -98 }, { 3, -93, 23 } },
			[4] = { { 1, 0, 67 }, { 3, 64, 3 } },
		},
		defence = {
			{ kind = "press", gap = 45, effort = 0.48, delay = 13 },
			{ kind = "mark", man = 2, gap = 0.31, effort = 0.71, delay = 19 },
			{ kind = "mark", man = 4, gap = 0.1, effort = 0.44, delay = 21 },
			{ kind = "keeper", effort = 0.54, delay = 28 },
		},
	},
	{
		id = "centro",
		title = "DESBORDE Y REMATE DE PRIMERA",
		caption = "El extremo gana la banda y centra al área",
		ball = { 0, -115 },
		red = { { -57, 36 }, { -20, -138 }, { -97, -16 }, { 106, 83 } },
		blue = { { -81, -145 }, { 175, -35 }, { 198, 131 }, { 345, 0 } },
		actions = {
			{ by = 2, kind = "dribble", x = 101, y = -118, radius = 23, effort = 0.4 },
			{ by = 2, kind = "pass", x = 331, y = -104, wait = 40, meet = 5, tolerance = 0.03 },
			{ by = 1, kind = "shot", x = 385, y = 39, wait = 31, meet = 4, tolerance = 0.08 },
		},
		runs = {
			[1] = { { 1, 98, 101 }, { 2, 308, 98 } },
			[2] = { { 3, 239, -95 } },
			[3] = { { 1, -42, 136 }, { 2, 147, 69 } },
			[4] = { { 1, 107, 94 }, { 2, 202, 76 } },
		},
		defence = {
			{ kind = "press", gap = 32, effort = 0.71, delay = 18 },
			{ kind = "mark", man = 1, gap = 0.34, effort = 0.42, delay = 25 },
			{ kind = "mark", man = 4, gap = 0.6, effort = 0.76, delay = 16 },
			{ kind = "keeper", effort = 0.83, delay = 20 },
		},
	},
	{
		id = "contra",
		title = "CONTRAATAQUE LETAL",
		caption = "Recupera, lanza largo y define en tres toques",
		mirror = true,
		ball = { -120, 20, -1.6, -0.3 },
		red = { { -6, -112 }, { -210, 10 }, { -175, -111 }, { -136, 52 } },
		blue = { { -98, 67 }, { 8, 16 }, { 124, 33 }, { 345, 0 } },
		actions = {
			{ by = 2, kind = "pass", x = -58, y = 92, meet = 17, tolerance = 0.1 },
			{ by = 4, kind = "pass", x = 141, y = 88, wait = 17, meet = 18, tolerance = 0.08 },
			{ by = 1, kind = "shot", x = 385, y = -52, wait = 40, meet = 6, tolerance = 0.07 },
		},
		runs = {
			[1] = { { 1, -26, -66 }, { 2, 190, -30 } },
			[2] = { { 2, -111, 44 } },
			[3] = { { 1, -101, -64 }, { 3, 48, -94 } },
			[4] = { { 1, 32, 122 }, { 3, 147, 144 } },
		},
		defence = {
			{ kind = "press", gap = 67, effort = 0.42, delay = 21 },
			{ kind = "press", gap = 95, effort = 0.6, delay = 25 },
			{ kind = "cover", gap = 0.65, effort = 0.61, delay = 10 },
			{ kind = "keeper", effort = 0.55, delay = 26 },
		},
	},
}
