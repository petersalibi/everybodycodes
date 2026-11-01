local function part1(filename)
	local checksum = 0
	local participants = {}
	for line in io.lines(filename) do
		local new_entry = {}
		for key, val in string.gmatch(line, "(%a*)=(%d*)") do
			val = tonumber(val)
			assert(val)

			new_entry[key] = val
		end

		local new_id = new_entry["id"]
		if not participants[new_id] then
			participants[new_id] = new_entry
		else
			participants[new_id].time = participants[new_id].time + new_entry.time
		end
	end
	local alltimes = {}
	for _, v in pairs(participants) do
		table.insert(alltimes, v.time)
	end

	table.sort(alltimes)

	for i, time in ipairs(alltimes) do
		checksum = checksum + time * i
	end

	return checksum
end

local function part2(filename)
	local checksum = 0
	local participants = {}
	for line in io.lines(filename) do
		local new_entry = {
			parts = 1,
		}
		for key, val in string.gmatch(line, "(%a*)=(%d*)") do
			val = tonumber(val)
			assert(val)

			new_entry[key] = val
		end

		local new_id = new_entry["id"]
		if not participants[new_id] then
			participants[new_id] = new_entry
		else
			participants[new_id].time = participants[new_id].time + new_entry.time
			participants[new_id].parts = participants[new_id].parts + 1
		end
	end

	local alltimes = {}
	for _, v in pairs(participants) do
		table.insert(alltimes, { time = v.time, parts = v.parts })
	end

	table.sort(alltimes, function(a, b)
		if a.parts > b.parts then
			return true
		elseif a.parts < b.parts then
			return false
		end
		return a.time < b.time
	end)

	for i, v in ipairs(alltimes) do
		checksum = checksum + v.time * i
	end

	return checksum
end

local function add_points(point_totals, positions, point_alloc)
	local give_points = point_alloc

	for i, v in ipairs(positions) do
		local id = v.id
		local time = v.time
		point_totals[id] = point_totals[id] + give_points
		if positions[i + 1] and time ~= positions[i + 1].time then
			give_points = math.max(point_alloc - i, 0)
		end
	end
end

local function part3(filename)
	local checksum = 0
	local participants = {}
	local points = {}
	local quests = {}
	-- fill in quests with each part and each entry has the id for that part and the time
	for line in io.lines(filename) do
		local part_entry = {}
		local quest_num = 0
		local part_num = 0
		for key, val in string.gmatch(line, "(%a*)=(%d*)") do
			val = tonumber(val)
			assert(val)
			if key == "quest" then
				quest_num = val
			elseif key == "part" then
				part_num = val
			else
				part_entry[key] = val
			end

			if key == "id" and not points[val] then
				points[val] = 0
			end
		end

		if not quests[quest_num] then
			quests[quest_num] = { {}, {}, {} }
		end

		quests[quest_num][part_num][part_entry.id] = part_entry
	end

	-- ensure that the entry for time is the sum for each preceding part
	for _, quest_parts in pairs(quests) do
		for i = 2, #quest_parts do
			for id, part_entry in pairs(quest_parts[i]) do
				local prev_part = quest_parts[i - 1]
				assert(prev_part[id], "id number " .. id .. " did not participate in previous part")
				part_entry.time = part_entry.time + prev_part[id].time
			end
		end
	end

	-- tally points for each quest
	for _, quest_parts in pairs(quests) do
		for i, part in ipairs(quest_parts) do
			-- turn part into a list
			local part_list = {}
			for _, v in pairs(part) do
				table.insert(part_list, v)
			end

			local points_alloc = 50 * i
			table.sort(part_list, function(a, b)
				return a.time < b.time
			end)
			add_points(points, part_list, points_alloc)
		end
	end

	table.sort(points, function (a,b) return a > b end)
	local win_pos = 1
	for i, v in ipairs(points) do
		checksum = checksum + win_pos * v
		if points[i + 1] and v ~= points[i + 1] then
			win_pos = i + 1
		end
	end

	return checksum
end

print("Part 1: ", part1("./everybody_codes_e2026_q04_p1.txt"))
print("Part 2: ", part2("./everybody_codes_e2026_q04_p2.txt"))
print("Part 3: ", part3("./everybody_codes_e2026_q04_p3.txt"))
-- print("Part 3: ", part3("test.txt"))
