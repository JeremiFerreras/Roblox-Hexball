-- Driver de harness diagnóstico (mundos temporales en Studio Edit; no requiere guardar el Place).
-- Referencia: el run de 2026-11-19 capturó los estados compactos en
-- PHASE3_PLANE_ORDER_VARIANT_RESULTS_20261119.json.
-- La fixtureFactory debe crear un mundo NUEVO por ejecución, con la geometría y
-- discos de la fixture Node ya validada; no reutilizar ni mutar un mundo previo.

local Core = require(game.ServerScriptService.HaxballLab.PhysicsCore2D)
local Stadium = require(game.ServerScriptService.HaxballLab.ClassicStadium2D)

local VARIANTS = {
    A = { nodeOrder = false, nodeOuterB = false },
    B = { nodeOrder = true,  nodeOuterB = false },
    C = { nodeOrder = false, nodeOuterB = true },
    D = { nodeOrder = true,  nodeOuterB = true },
}

local function configureTemporaryWorld(world, variant, nodePlaneOrder, nodeOuterBById)
    -- All inputs are cloned fixture data. No source module table is edited.
    local byId = {}
    for _, plane in ipairs(world.planes) do
        byId[plane.id] = plane
    end

    if variant.nodeOrder then
        local reordered = {}
        for _, id in ipairs(nodePlaneOrder) do
            assert(byId[id], "Node-order plane missing from diagnostic world: " .. tostring(id))
            table.insert(reordered, byId[id])
        end
        for _, plane in ipairs(world.planes) do
            local seen = false
            for _, ordered in ipairs(reordered) do
                if ordered == plane then seen = true; break end
            end
            if not seen then table.insert(reordered, plane) end
        end
        world.planes = reordered
    end

    if variant.nodeOuterB then
        for planeId, bCoef in pairs(nodeOuterBById) do
            assert(byId[planeId], "Node property plane missing: " .. tostring(planeId))
            byId[planeId].bCoef = bCoef
        end
    end
end

local function runFixture(fixtureFactory, fixtureId, variantId, ticks)
    local world, reference = fixtureFactory(fixtureId)
    local variant = assert(VARIANTS[variantId], "unknown variant")
    configureTemporaryWorld(world, variant, reference.nodePlaneOrder, reference.nodeOuterBById)

    local rows = {}
    for tick = 1, ticks do
        local _, events, substeps = Core.stepWorld(world, reference.inputs[tick] or {})
        local ball = world.discById["string:ball"] or world.discById["number:0"]
        local contacts = {}
        for _, event in ipairs(events) do
            if event.kind == "planeContact" or event.kind == "segmentContact"
                or event.kind == "discContact" then
                table.insert(contacts, {
                    kind=event.kind, geometryId=event.geometryId, discId=event.discId,
                    discA=event.discA, discB=event.discB,
                    penetration=event.penetration, impulse=event.impulse,
                    normalX=event.normalX, normalY=event.normalY,
                })
            end
        end
        table.insert(rows, {tick=tick,x=ball.x,y=ball.y,vx=ball.vx,vy=ball.vy,
            substeps=substeps,contacts=contacts})
    end
    return rows
end

-- Fixture geometry, Node index-to-geometry map, HBS bCoef values, and exact
-- initial states come from the preserved verified fixture/report files.
-- Supply a fixtureFactory(fixtureId) adapter that constructs a fresh world and
-- returns {world, reference={inputs, nodePlaneOrder, nodeOuterBById}}.
-- This adapter is intentionally not embedded: fixture serialization lives in
-- the preserved investigation harness, and the supplementary microfixture
-- initial states were not retained in the result record.
local fixtureFactory = _G.Phase3OrderFixtureFactory
assert(type(fixtureFactory) == "function", "install the preserved fixture factory first")
local output = {}
for _, fixtureId in ipairs({"S1","S2","S3","corner","oblique","opposite_side","player_ball"}) do
    output[fixtureId] = {}
    for variantId in pairs(VARIANTS) do
        local ticks = ({S1=180,S2=13,S3=180,corner=2,oblique=2,opposite_side=2,player_ball=3})[fixtureId]
        output[fixtureId][variantId] = runFixture(fixtureFactory, fixtureId, variantId, ticks)
    end
end
return output

