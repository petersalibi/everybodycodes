local function split(input, sep)
    local out = {}

    if not sep then sep = " " end

    for word in string.gmatch(input, "[^" .. sep .. "]") do
        table.insert(out, word)
    end
    return out
end

local function part1(filename)
    local checksum = 0
    for line in io.lines(filename) do
        local iso_base, number = string.match(line, "ISO%-(%d*) (%d*)")
        assert(#iso_base  == #number)

        for i = #iso_base, 1, -1 do
            local iso_n = tonumber(iso_base:sub(i, i))
            local n_int = tonumber(number:sub(i, i))
            checksum = checksum + (n_int * iso_n ^ (#iso_base - i))
        end
    end
    return checksum
end

local function make_equal(base, num)
    local repeat_str = base
    local next_char_idx = #repeat_str - 1
    while #base ~= #num do
        base = repeat_str:sub(next_char_idx + 1, next_char_idx + 1) .. base
        next_char_idx = (next_char_idx - 1) % #repeat_str
    end
    return base
end

local function part2(filename)
    local checksum = 0
    for line in io.lines(filename) do
        local iso_base, number = string.match(line, "ISO%-(%d*) (%d*)")
        if #iso_base < #number then
            iso_base = make_equal(iso_base, number)
        elseif #iso_base > #number then
            iso_base = iso_base:sub(#iso_base - #number + 1, #iso_base)
        end


        for i = #iso_base, 1, -1 do
            local iso_n = tonumber(iso_base:sub(i, i))
            local n_int = tonumber(number:sub(i, i))
            checksum = checksum + (n_int * iso_n ^ (#iso_base - i))
        end
    end
    return checksum
end

local function check_iso2(base, num, res)
    for num_i = 1, tonumber(num) - 1 do
        local number = tostring(num_i)
        local iso_base = base
        if #iso_base < #number then
            iso_base = make_equal(iso_base, number)
        elseif #iso_base > #number then
            iso_base = iso_base:sub(#iso_base - #number + 1, #iso_base)
        end

        local check_res = 0
        for i = #iso_base, 1, -1 do
            local iso_n = tonumber(iso_base:sub(i, i))
            local n_int = tonumber(number:sub(i, i))
            check_res = check_res + (n_int * iso_n ^ (#iso_base - i))
        end
        if check_res == res then return false end
    end
    return true
end

local function part3(filename)
    local checksum = 0
    for line in io.lines(filename) do
        local iso_base, number = string.match(line, "ISO2%-(%d*) (%d*)")
        if #iso_base < #number then
            iso_base = make_equal(iso_base, number)
        elseif #iso_base > #number then
            iso_base = iso_base:sub(#iso_base - #number + 1, #iso_base)
        end

        local res = 0
        for i = #iso_base, 1, -1 do
            local iso_n = tonumber(iso_base:sub(i, i))
            local n_int = tonumber(number:sub(i, i))
            res = res + (n_int * iso_n ^ (#iso_base - i))
        end

        if check_iso2(iso_base, number, res) then
            checksum = checksum + res
        end

    end
    return checksum
end

print("Part 1: ", part1("./everybody_codes_e2026_q03_p1.txt"))
print("Part 2: ", part2("./everybody_codes_e2026_q03_p2.txt"))
print("Part 3: ", part3("./everybody_codes_e2026_q03_p3.txt"))
