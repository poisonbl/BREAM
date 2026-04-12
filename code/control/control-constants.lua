local Export = {}

Export.spawnEveryTicks = settings.startup["BREAM-spawn-every-seconds"].value * 60

local function splitToList(s)
	if s == "" then return {} end
	local result = {}
	for word in string.gmatch(s, '([^,]+)') do
		table.insert(result, word)
	end
	return result
end

local rawEntries = splitToList(settings.startup["BREAM-safe-tiles"].value)
local literals = {}
local patterns = {}
local subgroups = {}
for _, entry in ipairs(rawEntries) do
	local trimmed = entry:match("^%s*(.-)%s*$")
	if trimmed and trimmed ~= "" then
		if trimmed:sub(1,1) == "@" then
			subgroups[trimmed:sub(2)] = true
		elseif trimmed:match("^[%w%-]+$") then
			literals[trimmed] = true
		else
			table.insert(patterns, trimmed)
		end
	end
end

Export.safeTiles = {}
for tileName, tileProto in pairs(prototypes.tile) do
	local isSafe = literals[tileName] == true

	local subgroupName = tileProto.subgroup and tileProto.subgroup.name
	if not isSafe and subgroupName and subgroups[subgroupName] then
		isSafe = true
	end

	if not isSafe then
		for _, pattern in ipairs(patterns) do
			local status, match = pcall(string.find, tileName, pattern)
			if status and match then
				isSafe = true
				break
			end
		end
	end

	if isSafe then
		table.insert(Export.safeTiles, tileName)
	end
end

for name, _ in pairs(literals) do
	if not prototypes.tile[name] then
		log("Warning: safe tile "..name.." is not a valid tile name.")
	end
end

Export.phylumSurfaces = {
	{phylum = "nauvis", surfaceNames = splitToList(settings.startup["BREAM-surfaces-to-spawn-nauvis-enemies"].value)},
	{phylum = "gleba", surfaceNames = splitToList(settings.startup["BREAM-surfaces-to-spawn-gleba-enemies"].value)},
}

Export.spawnPosTolerance = 2
Export.darknessThreshold = 0.65

return Export