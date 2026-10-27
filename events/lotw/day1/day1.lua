io.input("./everybody_codes_e2026_q01_p1.txt")
local quest_text_p1 = io.read()
io.close()

io.input("./everybody_codes_e2026_q01_p2.txt")
local quest_text_p2 = io.read()
io.close()

io.input("./everybody_codes_e2026_q01_p3.txt")
local quest_text_p3 = io.read()
io.close()

local function part1(q_string)
    local res = 0

    for cones in string.gmatch(q_string, "%d*") do
        local num_cones = tonumber(cones)
        assert(num_cones)
        local num_cones_square = math.floor(math.sqrt(num_cones))
        if num_cones == num_cones_square ^ 2 then
            goto continue
        end

        num_cones_square = num_cones_square + 1

        res = res + (num_cones_square ^ 2 - num_cones)

        ::continue::
    end
    return res
end

local function part2(q_string)
    local res = 0

    for cones in string.gmatch(q_string, "%d*") do
        local num_cones = tonumber(cones)
        assert(num_cones)
        if num_cones < 8 then res = res + 8 - num_cones; goto continue end
        if num_cones % 4 ~= 0 then res = res + (4 - num_cones % 4) end

        ::continue::
    end
    return res
end

local function part3(q_string)
    local res = 0

    for cones in string.gmatch(q_string, "%d*") do
        local num_cones = tonumber(cones)
        assert(num_cones)
        if num_cones <= 8 then res = res + 8 - num_cones; goto continue end

        local num_cones_square = math.floor(math.sqrt(num_cones + 1))
        if num_cones == num_cones_square ^ 2 - 1 and num_cones_square % 2 ~= 0 then
            print("Perfect Square: ", num_cones)
            goto continue
        end

        num_cones_square = num_cones_square + 1
        if num_cones_square % 2 == 0 then num_cones_square = num_cones_square + 1 end

        -- print(num_cones, num_cones_square ^ 2 - num_cones - 1)

        res = res + (num_cones_square ^ 2 - num_cones - 1)

        ::continue::
    end
    return res
end

print("Part 1: ", part1(quest_text_p1))
print("Part 2: ", part2(quest_text_p2))
print("Part 3: ", part3(quest_text_p3))
