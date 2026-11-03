local function part1(filename)
    local checksum = 0
    for line in io.lines(filename) do
        local ordering_table = {}
        for comp in string.gmatch(line, "%d[<>]%d") do
            local l, m, r = tonumber(string.sub(comp, 1, 1)), string.sub(comp, 2, 2), tonumber(string.sub(comp, 3, 3))
            assert(l and r)
            if not ordering_table[l] then ordering_table[l] = {} end
            if not ordering_table[r] then ordering_table[r] = {} end
            if m == "<" then
                r, l = l, r
            end
            table.insert(ordering_table[l], r)
        end
        for k, v in pairs(ordering_table) do
            checksum = checksum + k * 10 ^ #v
        end
    end
    return checksum
end

local function part2(filename)
    local checksum = 0
    for line in io.lines(filename) do
        local ordering_table = {}
        for comp in string.gmatch(line, "%d[<>]%d") do
            local l, m, r = tonumber(string.sub(comp, 1, 1)), string.sub(comp, 2, 2), tonumber(string.sub(comp, 3, 3))
            assert(l and r)
            if not ordering_table[l] then ordering_table[l] = {} end
            if not ordering_table[r] then ordering_table[r] = {} end
            if m == "<" then
                r, l = l, r
            end
            table.insert(ordering_table[l], r)
        end

        local node_order = {}
        local seen = {}

        local dfs
        dfs = function (node)
            if seen[node] then return end
            seen[node] = true

            for _, node2 in ipairs(ordering_table[node]) do
                dfs(node2)
            end
            table.insert(node_order, node)
        end

        for k in pairs(ordering_table) do
            dfs(k)
        end

        for i, node in ipairs(node_order) do
            checksum = checksum + node * 10 ^ (i - 1)
        end
    end

    return checksum
end


print("Part 1: ", part2("./everybody_codes_e2026_q02_p1.txt"))
print("Part 2: ", part2("./everybody_codes_e2026_q02_p2.txt"))
print("Part 3: ", part2("./everybody_codes_e2026_q02_p3.txt"))
