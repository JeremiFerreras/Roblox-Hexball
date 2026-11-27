local Profile = {}

Profile.Metadata = {
    id = "simple-soccer-classic",
    name = "Classic",
    geometryStatus = "FROZEN_REFERENCE",
    logicalUnits = "stadium units",
    note = "The classic field bounds are x=[-420,420], y=[-200,200].",
}
Profile.PlayerCount = 8
Profile.PlayersPerTeam = 4

Profile.StadiumProperties = {
    width = 420,
    height = 200,
    spawnDistance = 170,
    bg = { width = 370, height = 170, kickOffRadius = 75 },
}

Profile.Bounds = {
    minX = -420, maxX = 420,
    minY = -200, maxY = 200,
    halfWidth = 420, halfHeight = 200,
    spanWidth = 840, spanHeight = 400,
}

Profile.PlayArea = {
    minX = -370, maxX = 370,
    minY = -170, maxY = 170,
    width = 740, height = 340,
}

Profile.Goals = {
    leftX = -370,
    rightX = 370,
    halfHeight = 64,
    openingWidth = 128,
    netBackX = 400,
    postRadius = 8,
    goalOwnerTeams = { left = "red", right = "blue" },
    scoringTeams = { left = "blue", right = "red" },
}

Profile.CollisionGroups = {
    -- Reference collision flag bit values.
    ball = 1,
    red = 2,
    blue = 4,
    player = 6,
    redKO = 8,
    blueKO = 16,
    kickoffBarrier = 24,
    wall = 32,
    outerWall = 32,
    post = 32,
    ballArea = 32,
    goalNet = 32,
    kick = 64,
    score = 128,
}

Profile.CollisionMasks = {
    all = 63,
    player = 39,
    ball = 63,
    post = 63,
    kickoffBarrier = 6,
}

Profile.Geometry = {
    planes = {
        { id = "classic:ballArea:bottom", normalX = 0, normalY = 1, offset = -170, bCoef = 1, collisionGroup = 32, collisionMask = 1 },
        { id = "classic:ballArea:top", normalX = 0, normalY = -1, offset = -170, bCoef = 1, collisionGroup = 32, collisionMask = 1 },
        { id = "classic:outer:bottom", normalX = 0, normalY = 1, offset = -200, bCoef = 0.1, collisionGroup = 32, collisionMask = 63 },
        { id = "classic:outer:top", normalX = 0, normalY = -1, offset = -200, bCoef = 0.1, collisionGroup = 32, collisionMask = 63 },
        { id = "classic:outer:left", normalX = 1, normalY = 0, offset = -420, bCoef = 0.1, collisionGroup = 32, collisionMask = 63 },
        { id = "classic:outer:right", normalX = -1, normalY = 0, offset = -420, bCoef = 0.1, collisionGroup = 32, collisionMask = 63 },
    },
    segments = {
        { id = "classic:ballArea:left:upper", x1 = -370, y1 = 170, x2 = -370, y2 = 64, bCoef = 1, collisionGroup = 32, collisionMask = 1 },
        { id = "classic:ballArea:left:lower", x1 = -370, y1 = -64, x2 = -370, y2 = -170, bCoef = 1, collisionGroup = 32, collisionMask = 1 },
        { id = "classic:ballArea:right:upper", x1 = 370, y1 = 170, x2 = 370, y2 = 64, bCoef = 1, collisionGroup = 32, collisionMask = 1 },
        { id = "classic:ballArea:right:lower", x1 = 370, y1 = -64, x2 = 370, y2 = -170, bCoef = 1, collisionGroup = 32, collisionMask = 1 },
        { id = "classic:goalNet:left:lowerCurve", x1 = -380, y1 = -64, x2 = -400, y2 = -44, curveDegrees = -90, bCoef = 0.1, collisionGroup = 32, collisionMask = 1 },
        { id = "classic:goalNet:left:back", x1 = -400, y1 = -44, x2 = -400, y2 = 44, curveDegrees = 0, bCoef = 0.1, collisionGroup = 32, collisionMask = 1 },
        { id = "classic:goalNet:left:upperCurve", x1 = -400, y1 = 44, x2 = -380, y2 = 64, curveDegrees = -90, bCoef = 0.1, collisionGroup = 32, collisionMask = 1 },
        { id = "classic:goalNet:right:lowerCurve", x1 = 380, y1 = -64, x2 = 400, y2 = -44, curveDegrees = 90, bCoef = 0.1, collisionGroup = 32, collisionMask = 1 },
        { id = "classic:goalNet:right:back", x1 = 400, y1 = -44, x2 = 400, y2 = 44, curveDegrees = 0, bCoef = 0.1, collisionGroup = 32, collisionMask = 1 },
        { id = "classic:goalNet:right:upperCurve", x1 = 400, y1 = 44, x2 = 380, y2 = 64, curveDegrees = 90, bCoef = 0.1, collisionGroup = 32, collisionMask = 1 },
        { id = "classic:kickoff:upperLine", x1 = 0, y1 = 200, x2 = 0, y2 = 75, bCoef = 0.1, collisionGroup = 24, collisionMask = 6, kickoffOnly = true },
        { id = "classic:kickoff:circleBlueKO", x1 = 0, y1 = 75, x2 = 0, y2 = -75, curveDegrees = 180, bCoef = 0.1, collisionGroup = 16, collisionMask = 6, kickoffOnly = true },
        { id = "classic:kickoff:circleRedKO", x1 = 0, y1 = 75, x2 = 0, y2 = -75, curveDegrees = -180, bCoef = 0.1, collisionGroup = 8, collisionMask = 6, kickoffOnly = true },
        { id = "classic:kickoff:lowerLine", x1 = 0, y1 = -75, x2 = 0, y2 = -200, bCoef = 0.1, collisionGroup = 24, collisionMask = 6, kickoffOnly = true },
    },
    posts = {
        { id = "classic:post:left:upper", x = -370, y = 64, radius = 8, bCoef = 0.5 },
        { id = "classic:post:left:lower", x = -370, y = -64, radius = 8, bCoef = 0.5 },
        { id = "classic:post:right:upper", x = 370, y = 64, radius = 8, bCoef = 0.5 },
        { id = "classic:post:right:lower", x = 370, y = -64, radius = 8, bCoef = 0.5 },
    },
}

Profile.SpawnPoints = {
    -- Mirrored four-a-side kickoff formation.
    { x = -80, y = 0 },
    { x = -150, y = -45 }, { x = -150, y = 0 }, { x = -150, y = 45 },
    { x = 80, y = 0 },
    { x = 150, y = -45 }, { x = 150, y = 0 }, { x = 150, y = 45 },
}

Profile.Simulation = {
    tickRate = { value = 60, evidence = "DOCUMENTED_LOGICAL_TICK", source = "Headless Host onGameTick documentation; does not prove internal substeps or render/network rates." },
}

Profile.PhysicsBaseline = {
    evidenceReplay = {
        format = "HBR2",
        version = 3,
        frames = 12368,
        stadium = "Small",
        sha256 = "60a184ca3e33f763424960e407bc7d898cbf13a0a5e54eb85f811661e4d478d5",
        engine = "independent browser-football replay reference",
        engineCommit = "4d4b88f1e5e25d484d27819ee6a4699720bda164",
        evidenceLevel = "RECONSTRUCTED_INDEPENDENT_IMPLEMENTATION",
        note = "Replay stadium is separate from the frozen Classic geometry profile; values remain candidates until cross-validated.",
    },
    active = {
        status = "PROJECT_PROVISIONAL",
        note = "Existing simulation defaults retained as an independent reference profile; not an official engine certification.",
        player = {
            radius = 15, invMass = 0.5, damping = 0.96, bounce = 0.5,
            acceleration = 0.1, kickAcceleration = 0.07, kickDamping = 0.96,
            kickStrength = 5, kickback = 0,
        },
        ball = { radius = 10, invMass = 1, damping = 0.99, bounce = 0.5 },
        kickRangeExtra = 4,
        evidence = {
            player = "Values match the independent replay reconstruction; official comparison pending.",
            ball = "radius and damping match the replay reconstruction; active invMass/bounce are retained project defaults and differ from that replay candidate.",
            kickRangeExtra = "UNKNOWN_PROJECT_PROVISIONAL",
        },
    },
    replayCandidate = {
        status = "RECONSTRUCTED_NOT_OFFICIAL_MEASUREMENT",
        source = "replay_metadata.json roomData physics metadata",
        player = {
            radius = 15, invMass = 0.5, damping = 0.96, bounce = 0.5,
            acceleration = 0.1, kickAcceleration = 0.07, kickDamping = 0.96,
            kickStrength = 5, kickback = 0,
        },
        ball = { radius = 10, invMass = 0.5, damping = 0.99, bounce = 1 },
    },
    labSolver = {
        collisionIterations = 24,
        maxSubsteps = 128,
        substepRadiusFraction = 0.2,
        evidence = "PROJECT_IMPLEMENTATION_TUNING_NOT_ORIGINAL_ENGINE_PARAMETERS",
    },
}

Profile.Calibration = {
    status = "IN_PROGRESS",
    reference = {
        class = "VERIFIED_FROM_FROZEN_HBS",
        source = Profile.Metadata.sourcePermalink,
        confidence = "high for map data",
        geometryCounts = { planes = 6, segments = 14, kickoffSegments = 4, posts = 4 },
    },
    replayComparison = {
        class = "RECONSTRUCTED_FROM_SEPARATE_GAMEPLAY_REPLAY",
        sourceSha256 = Profile.PhysicsBaseline.evidenceReplay.sha256,
        sourceStadium = "Small",
        frames = 12368,
        directOfficialComparison = false,
        playerFreeFlight = {
            eligiblePairs = 10002,
            noInputPairs = 762,
            medianPositionResidual = 6.8e-15,
            medianVelocityResidual = 0,
            dampingRatioMedian = 0.96,
        },
        ballFreeFlight = {
            eligiblePairs = 10998,
            medianPositionResidual = 2.6e-15,
            dampingRatioMedian = 0.99,
        },
        kicks = { callbacks = 28, medianCenterDistance = 27.64, medianDeltaVelocityMagnitude = 4.944 },
    },
    parameterDelta = {
        playerCandidateValuesMatchActive = true,
        ballRadius = { active = 10, replayCandidate = 10, status = "MATCH" },
        ballInvMass = { active = 1, replayCandidate = 0.5, status = "DISAGREEMENT" },
        ballDamping = { active = 0.99, replayCandidate = 0.99, status = "MATCH" },
        ballBounce = { active = 0.5, replayCandidate = 1, status = "DISAGREEMENT" },
        kickRangeExtra = { active = 4, replayCandidate = nil, status = "UNKNOWN" },
    },
    separateTelemetry = {
        stadium = "Big",
        records = 21912,
        events = 78,
        sameMatchAsReplay = false,
        usableForDirectParameterCalibration = false,
        reason = "Separate stadium/session, no per-tick inputs, repeated gameTime and resets prevent direct physical fitting.",
    },
    unresolved = {
        "Official-engine trajectory comparison on Classic",
        "Kick range and failed-kick boundary",
        "Solver order and internal substeps",
        "Player-to-player calibration on controlled original-engine data",
    },
}

Profile.Presentation = {
    studsPerUnit = 0.5,
    logicalOrigin = { x = 0, y = 0 },
    worldOrigin = { x = 0, z = 0 },
    floorY = 11,
    invertLogicalY = true,
    evidence = "Presentation-only scale; physics coordinates remain in stadium units.",
}

return Profile