local function part1(filename)
	local graph = {}
	for line in io.lines(filename) do
		local vertex, connections = string.match(line, "(.*):(.*)")
		if not graph[vertex] then
			graph[vertex] = {}
		end

		for con in string.gmatch(connections, "[^,]+") do
			table.insert(graph[vertex], con)
		end
	end

	local seen = {}

	local dfs
	dfs = function(node)
		if seen[node] then
			return
		end
		seen[node] = ""

		if not graph[node] then
			return
		end

		for _, vert in ipairs(graph[node]) do
			dfs(vert)
		end
	end

	dfs("NULL")

	local len = 0
	for _ in pairs(seen) do
		len = len + 1
	end

	return len - 1
end

local function part2(filename)
	local graph = {}
	for line in io.lines(filename) do
		local vertex, connections = string.match(line, "(.*):(.*)")
		for con in string.gmatch(connections, "[^,]+") do
			if not graph[con] then
				graph[con] = {}
			end
			table.insert(graph[con], vertex)
		end
	end

	local seen = {}

	local dfs
	dfs = function(node)
		if seen[node] then
			return
		end

        seen[node] = true

		if not graph[node] then
			return
		end

		for _, vert in ipairs(graph[node]) do
			dfs(vert)
		end
	end

	local indirect_null = 0

    dfs("NULL")

	for _ in pairs(seen) do
		indirect_null = indirect_null + 1
	end

	return indirect_null - 1
end

local function get_intersection(tab1, tab2, intersection)
    for val1 in pairs(tab1) do
        for val2 in pairs(tab2) do
            if val1 == val2 then
                intersection[val1] = true
            end
        end
    end
end

local function part3(filename)
	local graph = {}
	for line in io.lines(filename) do
		local vertex, connections = string.match(line, "(.*):(.*)")
		for con in string.gmatch(connections, "[^,]+") do
			if not graph[con] then
				graph[con] = {}
			end
			table.insert(graph[con], vertex)
		end
	end

	local dfs
	dfs = function(node, seen)
		if seen[node] then
			return
		end

        seen[node] = true

		if not graph[node] then
			return
		end

		for _, vert in ipairs(graph[node]) do
			dfs(vert, seen)
		end
	end


    local v1_seen, v2_seen, v3_seen = {}, {}, {}

    dfs("NULLv1", v1_seen)
    dfs("NULLv2", v2_seen)
    dfs("NULLv3", v3_seen)

    local all_intersections = {}

    get_intersection(v1_seen, v2_seen, all_intersections)
    get_intersection(v1_seen, v3_seen, all_intersections)
    get_intersection(v2_seen, v3_seen, all_intersections)

	local res = 0
	for _ in pairs(all_intersections) do
		res = res + 1
	end

	return res
end

print("Part 1: ", part1("./notes/everybody_codes_e2026_q06_p1.txt"))
print("Part 2: ", part2("./notes/everybody_codes_e2026_q06_p2.txt"))
print("Part 3: ", part3("./notes/everybody_codes_e2026_q06_p3.txt"))
print("test: ", part3("./notes/test.txt"))
