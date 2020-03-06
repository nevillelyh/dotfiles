local awful = require("awful")
local gears = require("gears")

local function compare_position(a, b)
    if a.x == b.x then
        return a.y < b.y
    else
        return a.x < b.x
    end
end

local function clients_by_position()
    local this = client.focus
    if this then
        sorted = client.focus.first_tag:clients()
        table.sort(sorted, compare_position)

        local idx = 0
        for i, that in ipairs(sorted) do
            if this.window == that.window then
                idx = i
            end
        end

        if idx > 0 then
            return { sorted = sorted, idx = idx }
        end
    end
    return {}
end

local function in_centerwork()
    return client.focus and client.focus.first_tag.layout.name == "centerwork"
end

local centerwork = { focus = {}, swap = {} }

function centerwork.focus.byidx(i)
    if in_centerwork() then
        local cls = clients_by_position()
        if cls.idx then
            local target = cls.sorted[gears.math.cycle(#cls.sorted, cls.idx + i)]
            awful.client.focus.byidx(0, target)
        end
    else
        awful.client.focus.byidx(i)
    end
end

function centerwork.swap.byidx(i)
    if in_centerwork() then
        local cls = clients_by_position()
        if cls.idx then
            local target = cls.sorted[gears.math.cycle(#cls.sorted, cls.idx + i)]
            client.focus:swap(target)
        end
    else
        awful.client.swap.byidx(i)
    end
end

return centerwork
