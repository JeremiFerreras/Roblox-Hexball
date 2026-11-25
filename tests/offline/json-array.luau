-- Test results use dense arrays only. Reject shapes that ipairs would silently truncate.
local function json(v)
	local kind = type(v)
	if kind == "nil" then
		return "null"
	end
	if kind == "boolean" then
		return tostring(v)
	end
	if kind == "number" then
		assert(v == v and v ~= math.huge and v ~= -math.huge, "nonfinite JSON result")
		return tostring(v)
	end
	if kind == "string" then
		local parts = { '"' }
		for i = 1, #v do
			local c = string.byte(v, i)
			if c == 34 then
				table.insert(parts, '\\"')
			elseif c == 92 then
				table.insert(parts, "\\\\")
			elseif c < 32 then
				table.insert(parts, string.format("\\u%04x", c))
			else
				table.insert(parts, string.char(c))
			end
		end
		table.insert(parts, '"')
		return table.concat(parts)
	end
	assert(kind == "table", "unsupported result type: " .. kind)
	local n = 0
	for k in pairs(v) do
		assert(type(k) == "number" and k >= 1 and k % 1 == 0, "results must use arrays")
		n += 1
	end
	local values = {}
	for i = 1, n do
		assert(v[i] ~= nil, "sparse result array")
		values[i] = json(v[i])
	end
	return "[" .. table.concat(values, ",") .. "]"
end
