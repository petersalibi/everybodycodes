local dbg = require "debugger"
local function part1(filename)
	local energy_graph = {}
	local cloud_graph = {}
	local start_id = 1
	local most_cons = 0


	for line in io.lines(filename) do
		local id, energy, connections = string.match(line, "id=(%d+).*energy=(%d+).*connections=([%d,]+)$")
		if not energy_graph[id] then
			energy_graph[id] = energy
			cloud_graph[id] = {}
		end

		for con in string.gmatch(connections, "[^,]+") do
			table.insert(cloud_graph[id], con)
		end

		if #cloud_graph[id] > most_cons then
			start_id = id
			most_cons = #cloud_graph[id]
		end
	end


	local dfs
	dfs = function (node, impulse)
		if impulse == 0 then
			return
		end

		energy_graph[node] = energy_graph[node] + impulse

		for _, cloud in pairs(cloud_graph[node]) do
			dfs(cloud, impulse - 1)
		end
	end

	dfs(start_id, 5)

	local sum_energy = 0

	for _, energy in pairs(energy_graph) do
		sum_energy = sum_energy + energy
	end

	return sum_energy
end

local function part2(filename)
	local energy_graph = {}
	local cloud_graph = {}
	local start_id = 1
	local most_cons = 0


	for line in io.lines(filename) do
		local id, energy, connections = string.match(line, "id=(%d+).*energy=(%d+).*connections=([%d,]+)$")
		id, energy = tonumber(id), tonumber(energy)
		assert(id and energy)
		if not energy_graph[id] then
			energy_graph[id] = energy
			cloud_graph[id] = {}
		end

		for con in string.gmatch(connections, "[^,]+") do
			table.insert(cloud_graph[id], tonumber(con))
		end

		if #cloud_graph[id] > most_cons then
			start_id = id
			most_cons = #cloud_graph[id]
		end
	end


	local impulses = {[start_id] = {[10] = 1}}

	while next(impulses) do
		local next_impulses = {}
		for id, impulse_counts in pairs(impulses) do
			for charge, count in pairs(impulse_counts) do
				energy_graph[id] = energy_graph[id] + charge * count
				if charge > 1 then
					for _, child in ipairs(cloud_graph[id]) do
						if not next_impulses[child] then
							next_impulses[child] = {}
						end
						next_impulses[child][charge - 1] = (next_impulses[child][charge - 1] or 0) + count
					end
				end
			end
		end
		impulses = next_impulses
	end

	local sum_energy = 0

	for _, energy in pairs(energy_graph) do
		sum_energy = sum_energy + energy
	end

	return sum_energy
end


local function check_propogation(start_id, energy_graph, cloud_graph)
	local impulses = {[start_id] = {[10] = 1}}
	local exploded = {}
	local MAX_EXPLOSIONS = 1000000

	while next(impulses) do
		local next_impulses = {}
		for id, impulse_counts in pairs(impulses) do
			if exploded[id] then
				goto continue
			end
			for charge, count in pairs(impulse_counts) do
				energy_graph[id] = energy_graph[id] + charge * count
				if charge > 1 then
					for _, child in ipairs(cloud_graph[id]) do
						if not next_impulses[child] then
							next_impulses[child] = {}
						end
						next_impulses[child][charge - 1] = (next_impulses[child][charge - 1] or 0) + count
					end
				end
			end
			if energy_graph[id] >= MAX_EXPLOSIONS then
				exploded[id] = true
				for _, child in ipairs(cloud_graph[id]) do
					if not next_impulses[child] then
						next_impulses[child] = {}
					end
					next_impulses[child][10] = (next_impulses[child][10] or 0) + 1
				end
			end
			::continue::
		end
		impulses = next_impulses
	end

	local sum_energy = 0

	for _, energy in pairs(energy_graph) do
		if energy < MAX_EXPLOSIONS then
			sum_energy = sum_energy + energy
		end
	end

	return sum_energy
end

function table.shallow_copy(t)
    local t2 = {}
    for k, v in pairs(t) do
        t2[k] = v
    end
    return t2
end   

local function part3(filename)
	local energy_graph = {}
	local cloud_graph = {}
	local start_id = 1
	local most_cons = 0


	for line in io.lines(filename) do
		local id, energy, connections = string.match(line, "id=(%d+).*energy=(%d+).*connections=([%d,]+)$")
		id, energy = tonumber(id), tonumber(energy)
		assert(id and energy)
		if not energy_graph[id] then
			energy_graph[id] = energy
			cloud_graph[id] = {}
		end

		for con in string.gmatch(connections, "[^,]+") do
			table.insert(cloud_graph[id], tonumber(con))
		end

		if #cloud_graph[id] > most_cons then
			start_id = id
			most_cons = #cloud_graph[id]
		end
	end

	local res_max = 0

	for id in ipairs(cloud_graph) do
		local res = check_propogation(id, table.shallow_copy(energy_graph), cloud_graph)
		res_max = math.max(res, res_max)
	end

	return res_max
end

print("test: ", part3("./notes/test.txt"))
print("Part 1: ", part1("./notes/everybody_codes_e2026_q07_p1.txt"))
print("Part 2: ", part2("./notes/everybody_codes_e2026_q07_p2.txt"))
print("Part 3: ", part3("./notes/everybody_codes_e2026_q07_p3.txt"))
