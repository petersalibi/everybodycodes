local StackSet = {}
StackSet.__index = StackSet

local function string_point(p)
	return p.x .. "," .. p.y
end

function StackSet.new()
	return setmetatable({ stack = {}, set = {} }, StackSet)
end

function StackSet:push(val)
	if self.set[string_point(val)] then
		return false
	end

	table.insert(self.stack, val)
	self.set[string_point(val)] = ""
	return true
end

function StackSet:pop()
	if #self.stack == 0 then
		return nil
	end

	local ret_val = table.remove(self.stack)

	self.set[string_point(ret_val)] = nil
	return ret_val
end

function StackSet:len()
	return #self.stack
end

function StackSet:is_empty()
	return #self.stack == 0
end

local function get_adjacent(point, x_max, y_max)
	local adjacent_points = {}

	if point.x > 1 and point.y > 1 and point.x <= x_max - 1 and point.y <= y_max - 1 then
		adjacent_points = {
			{x = point.x + 1, y = point.y + 1},
			{x = point.x + 1, y = point.y - 1},
			{x = point.x - 1, y = point.y + 1},
			{x = point.x - 1, y = point.y - 1},
			{x = point.x, y = point.y + 1},
			{x = point.x, y = point.y - 1},
			{x = point.x + 1, y = point.y},
			{x = point.x - 1, y = point.y},

		}
		return adjacent_points
	end

	for x_offset = -1, 1 do
		for y_offset = -1, 1 do
			if y_offset == 0 and y_offset == x_offset then
				goto continue
			end
			local next_x = point.x + x_offset
			local next_y = point.y + y_offset

			if next_x <= 0 or next_x > x_max then
				goto continue
			end

			if next_y <= 0 or next_y > y_max then
				goto continue
			end

			table.insert(adjacent_points, { x = next_x, y = next_y })

			::continue::
		end
	end

	return adjacent_points
end

local function get_adjacent_far(point, x_max, y_max)
	local adjacent_points = {}

	for x_offset = -2, 2 do
		for y_offset = -2, 2 do
			if (y_offset == 0 or math.abs(y_offset) == 2) and math.abs(y_offset) == math.abs(x_offset) then
				goto continue
			end
			local next_x = point.x + x_offset
			local next_y = point.y + y_offset

			if next_x <= 0 or next_x > x_max then
				goto continue
			end

			if next_y <= 0 or next_y > y_max then
				goto continue
			end

			table.insert(adjacent_points, { x = next_x, y = next_y })

			::continue::
		end
	end

	return adjacent_points
end

local function count_cells(map, points)
	local res = 0
	for _, point in ipairs(points) do
		res = res + map[point.y][point.x]
	end
	return res
end

local function iterate_map_land(map, map_neighbors, land, point_queue)
	local HEIGHT = #map
	local WIDTH = #map[1]

	while not point_queue:is_empty() do
		local point = point_queue:pop()
		assert(point, "point is nil")

		if map_neighbors[point.y][point.x] < 5 then
			goto continue
		end

		land[string_point(point)] = point

		local adj_points = get_adjacent(point, WIDTH, HEIGHT)

		for _, adj_point in ipairs(adj_points) do
			if land[string_point(adj_point)] then
				goto continue_for
			end

			point_queue:push(adj_point)
			::continue_for::
		end

		if map[point.y][point.x] == 0 then
			for _, adj_point in ipairs(adj_points) do
				map_neighbors[adj_point.y][adj_point.x] = map_neighbors[adj_point.y][adj_point.x] + 1
			end
		end
		::continue::
	end
end

local function progress_map(map)
	local HEIGHT = #map
	local WIDTH = #map[1]

	local map_neighbors = {}

	for y_map, row in ipairs(map) do
		local cell_val_row = {}
		for x_map in ipairs(row) do
			local point = { x = x_map, y = y_map }
			local point_val = count_cells(map, get_adjacent(point, WIDTH, HEIGHT))
			table.insert(cell_val_row, point_val)
		end
		table.insert(map_neighbors, cell_val_row)
	end

	local midpoint = { x = math.floor(WIDTH / 2) + 1, y = math.floor(HEIGHT / 2) + 1 }
	local point_queue = StackSet.new()

	for _, point in ipairs(get_adjacent(midpoint, WIDTH, HEIGHT)) do
		point_queue:push(point)
	end

	local land = {}
	land[string_point(midpoint)] = midpoint

	if map[midpoint.y][midpoint.x] == 0 then
		for _, point in ipairs(get_adjacent(midpoint, WIDTH, HEIGHT)) do
			map_neighbors[point.y][point.x] = map_neighbors[point.y][point.x] + 1
		end
	end

	iterate_map_land(map, map_neighbors, land, point_queue)

	return land
end

local function part1(filename)
	local map = {}
	for line in io.lines(filename) do
		local map_row = {}
		for char in string.gmatch(line, ".") do
			local char_num = tonumber(char)
			assert(char_num)
			table.insert(map_row, char_num)
		end

		table.insert(map, map_row)
	end

	local land = progress_map(map)
	local res = 0

	for _ in pairs(land) do
		res = res + 1
	end

	return res
end

local function part2(filename)
	local map = {}
	for line in io.lines(filename) do
		local map_row = {}
		for char in string.gmatch(line, ".") do
			local char_num = tonumber(char)
			assert(char_num)
			table.insert(map_row, char_num)
		end

		table.insert(map, map_row)
	end

	local land = progress_map(map)

	local map_neighbors = {}

	HEIGHT = #map
	WIDTH = #map[1]

	for y, row in ipairs(map) do
		local map_row = {}
		for x in ipairs(row) do
			if land[string_point({ x = x, y = y })] then
				table.insert(map_row, 0)
			else
				table.insert(map_row, 1)
			end
		end

		table.insert(map_neighbors, map_row)
	end

	local sea_tiles = {}
	local num_sea_tiles = 0

	for _, row in ipairs(map) do
		local map_row = {}
		for _ in ipairs(row) do
			table.insert(map_row, 0)
		end

		table.insert(sea_tiles, map_row)
	end

	for _, point in pairs(land) do
		local adj_points = get_adjacent(point, WIDTH, HEIGHT)

		if
			count_cells(map_neighbors, adj_points) > 0
			or point.x == WIDTH
			or point.x == 0
			or point.y == HEIGHT
			or point.y == 0
		then
			sea_tiles[point.y][point.x] = 1
			num_sea_tiles = num_sea_tiles + 1

			land[string_point(point)] = nil
		end
	end

	local prev_len = nil

	while prev_len ~= num_sea_tiles do
		prev_len = num_sea_tiles

		for _, land_point in pairs(land) do
			local adj_points = get_adjacent(land_point, WIDTH, HEIGHT)
			if count_cells(sea_tiles, adj_points) >= 5 then
				sea_tiles[land_point.y][land_point.x] = 1
				num_sea_tiles = num_sea_tiles + 1

				land[string_point(land_point)] = nil
			end
		end
	end

	-- local map_str = {}
	--
	-- for _, row in ipairs(sea_tiles) do
	-- 	local map_row = {}
	-- 	for _, val in ipairs(row) do
	-- 		table.insert(map_row, tostring(val))
	-- 	end
	--
	-- 	table.insert(map_str, map_row)
	-- end
	--
	-- for _, val in ipairs(map_str) do
	-- 	print(table.concat(val))
	-- end

	return num_sea_tiles
end

local function part3(filename)
	local map = {}
	for line in io.lines(filename) do
		local map_row = {}
		for char in string.gmatch(line, ".") do
			local char_num = tonumber(char)
			assert(char_num)
			table.insert(map_row, char_num)
		end

		table.insert(map, map_row)
	end

	local land = progress_map(map)

	local map_neighbors = {}

	HEIGHT = #map
	WIDTH = #map[1]

	for y, row in ipairs(map) do
		local map_row = {}
		for x in ipairs(row) do
			if land[string_point({ x = x, y = y })] then
				table.insert(map_row, 0)
			else
				table.insert(map_row, 1)
			end
		end

		table.insert(map_neighbors, map_row)
	end

	local sea_tiles = {}
	local num_sea_tiles = 0

	for _, row in ipairs(map) do
		local map_row = {}
		for _ in ipairs(row) do
			table.insert(map_row, 0)
		end

		table.insert(sea_tiles, map_row)
	end

	for _, point in pairs(land) do
		local adj_points = get_adjacent(point, WIDTH, HEIGHT)

		if
			count_cells(map_neighbors, adj_points) > 0
			or point.x == WIDTH
			or point.x == 0
			or point.y == HEIGHT
			or point.y == 0
		then
			sea_tiles[point.y][point.x] = 1
			num_sea_tiles = num_sea_tiles + 1

			land[string_point(point)] = nil
		end
	end

	local prev_len = nil

	while prev_len ~= num_sea_tiles do
		prev_len = num_sea_tiles

		for _, land_point in pairs(land) do
			local adj_points = get_adjacent(land_point, WIDTH, HEIGHT)
			if count_cells(sea_tiles, adj_points) >= 5 then
				sea_tiles[land_point.y][land_point.x] = 1
				num_sea_tiles = num_sea_tiles + 1

				land[string_point(land_point)] = nil
			end
		end
	end

	local land_tiles = {}

	for _, row in ipairs(map) do
		local map_row = {}
		for _ in ipairs(row) do
			table.insert(map_row, 0)
		end

		table.insert(land_tiles, map_row)
	end

	for _, point in pairs(land) do
		land_tiles[point.y][point.x] = 1
	end

	local tree_tiles = {}
	local num_tree_tiles = 0

	for _, row in ipairs(map) do
		local map_row = {}
		for _ in ipairs(row) do
			table.insert(map_row, 0)
		end

		table.insert(tree_tiles, map_row)
	end

	for _, land_point in pairs(land) do
		local adj_points = get_adjacent_far(land_point, WIDTH, HEIGHT)

		if count_cells(land_tiles, adj_points) + count_cells(tree_tiles, adj_points) == 20 then
			tree_tiles[land_point.y][land_point.x] = 1
			num_tree_tiles = num_tree_tiles + 1
			land_tiles[land_point.y][land_point.x] = 0
			land[string_point(land_point)] = nil
		end
	end

	for i = 1, 2 do
		local removed_land = {}

		for _, land_point in pairs(land) do
			local adj_points = get_adjacent(land_point, WIDTH, HEIGHT)

			if count_cells(tree_tiles, adj_points) >= 4 and count_cells(sea_tiles, adj_points) == 0 then
				table.insert(removed_land, land_point)
			end
		end

		for _, point in ipairs(removed_land) do
			tree_tiles[point.y][point.x] = 1
			num_tree_tiles = num_tree_tiles + 1
			land_tiles[point.y][point.x] = 0
			land[string_point(point)] = nil
		end
	end

	-- local map_str = {}
	--
	-- for _, row in ipairs(sea_tiles) do
	-- 	local map_row = {}
	-- 	for _, val in ipairs(row) do
	-- 		table.insert(map_row, tostring(val))
	-- 	end
	--
	-- 	table.insert(map_str, map_row)
	-- end
	--
	-- for _, val in ipairs(map_str) do
	-- 	print(table.concat(val))
	-- end

	return num_tree_tiles
end

print("Part 1: ", part1("../notes/everybody_codes_e2026_q05_p1.txt"))
print("Part 2: ", part2("../notes/everybody_codes_e2026_q05_p2.txt"))
print("Part 3: ", part3("../notes/everybody_codes_e2026_q05_p3.txt"))
print("test2: ", part3("./test2.txt"))
