-- Shared catalog: asset IDs and curated playback regions in seconds.
local Catalog = {}

Catalog.Assets = {
    Normal = { soundId = 86405406260547, duration = 271.12, regions = {
        { 0.00, 44.93 }, { 45.18, 90.12 }, { 90.37, 135.31 },
        { 135.56, 180.49 }, { 180.74, 225.80 }, { 226.05, 271.12 },
    } },
    Rising = { soundId = 113746548892618, duration = 49.88, regions = {
        { 0.00, 6.02 }, { 6.27, 12.28 }, { 12.53, 18.55 }, { 18.80, 24.82 },
        { 25.07, 31.09 }, { 31.34, 37.36 }, { 37.61, 43.62 }, { 43.87, 49.88 },
    } },
    Falling = { soundId = 125927010576537, duration = 49.89, regions = {
        { 0.00, 6.02 }, { 6.27, 12.29 }, { 12.54, 18.56 }, { 18.81, 24.82 },
        { 25.07, 31.09 }, { 31.34, 37.35 }, { 37.60, 43.62 }, { 43.87, 49.89 },
    } },
    ShortReaction = { soundId = 120537209871370, duration = 92.16, regions = {
        { 0.00, 6.53 }, { 6.78, 14.84 }, { 15.09, 22.12 }, { 22.37, 30.18 },
        { 30.43, 37.97 }, { 38.22, 45.00 }, { 45.25, 52.15 }, { 52.40, 59.95 },
        { 60.20, 67.49 }, { 67.74, 75.54 }, { 75.79, 83.72 }, { 83.97, 92.16 },
    } },
    Sustained = { soundId = 106312598432409, duration = 32.11, regions = {
        { 0.00, 10.11 }, { 10.36, 22.13 }, { 22.38, 32.11 },
    } },
    Whistles = { soundId = 115025008870644, duration = 48.43, regions = {
        { 0.00, 2.39 }, { 2.64, 4.90 }, { 5.15, 7.41 }, { 7.66, 9.80 },
        { 10.05, 12.44 }, { 12.69, 15.08 }, { 15.33, 17.72 }, { 17.97, 20.11 },
        { 20.36, 23.01 }, { 23.26, 25.53 }, { 25.78, 28.20 }, { 28.45, 30.71 },
        { 30.96, 32.97 }, { 33.22, 35.36 }, { 35.61, 37.74 }, { 37.99, 40.63 },
        { 40.88, 42.89 }, { 43.14, 45.40 }, { 45.65, 48.43 },
    } },
}

function Catalog.Get(key)
    return Catalog.Assets[key]
end

function Catalog.Validate()
    local errors = {}
    for key, asset in pairs(Catalog.Assets) do
        if type(asset.soundId) ~= "number" or asset.soundId <= 0 then
            table.insert(errors, key .. ": invalid sound ID")
        end
        if type(asset.duration) ~= "number" or asset.duration <= 0 or #asset.regions == 0 then
            table.insert(errors, key .. ": invalid duration or empty regions")
        end
        for index, region in ipairs(asset.regions) do
            if type(region[1]) ~= "number" or type(region[2]) ~= "number"
                or region[1] < 0 or region[2] <= region[1]
                or region[2] > asset.duration + 0.02 then
                table.insert(errors, string.format("%s region %d is invalid", key, index))
            end
        end
    end
    return #errors == 0, errors
end

return Catalog
