-- Local payload observations; excludes Roblox headers, compression and server fan-out.
local NetMetrics = {}
NetMetrics.__index = NetMetrics
local NAMES = {
	"ackMs",
	"rttMs",
	"playerCorrection",
	"ballCorrection",
	"snapshotAgeMs",
	"renderLagMs",
	"adaptiveDelayMs",
}
local CAPACITY = 256

function NetMetrics.new()
	local self = setmetatable({ samples = {}, counters = {} }, NetMetrics)
	for _, name in ipairs(NAMES) do
		self.samples[name] = { values = {}, next = 1, total = 0 }
	end
	return self
end

function NetMetrics:add(name, value)
	local bucket = self.samples[name]
	if not bucket or type(value) ~= "number" or value ~= value or value < 0 or value == math.huge then
		return false
	end
	bucket.values[bucket.next] = value
	bucket.next = bucket.next % CAPACITY + 1
	bucket.total += 1
	return true
end

function NetMetrics:count(name, amount)
	amount = amount or 1
	assert(type(amount) == "number" and amount == amount and amount >= 0 and amount < math.huge)
	self.counters[name] = (self.counters[name] or 0) + amount
end

-- Sort only on request; the intended HUD refresh rate is once per second.
function NetMetrics:report()
	local result = { samples = {}, counters = table.clone(self.counters), capacity = CAPACITY }
	for _, name in ipairs(NAMES) do
		local bucket = self.samples[name]
		local values = table.clone(bucket.values)
		table.sort(values)
		local n = #values
		-- Empty percentiles are nil, never an invented zero.
		result.samples[name] = {
			count = n,
			total = bucket.total,
			p50 = values[math.ceil(n * 0.5)],
			p95 = values[math.ceil(n * 0.95)],
			max = values[n],
		}
	end
	return result
end

return NetMetrics
