local awful = require("awful")

function compare_position(a, b)
    if a.x == b.x then
        return a.y < b.y
    else
        return a.x < b.x
    end
end

function get_neighbors()
    local this = client.focus
    if this then
        clients = client.focus.first_tag:clients()
        table.sort(clients, compare_position)

        local current = 0
        for i, that in ipairs(clients) do
            if this.window == that.window then
                current = i
            end
        end

        if current > 0 then
            local n = #clients
            local next = current + 1
            if next > n then
                next = 1
            end
            local prev = current - 1
            if prev == 0 then
                prev = n
            end
            return { prev = clients[prev], next = clients[next] }
        end
    end
    return {}
end

local centerwork = {}

function centerwork.current_layout()
    if client.focus and client.focus.first_tag.layout.name == "centerwork" then
        return true
    else
        return false
    end
end

function centerwork.focus_prev()
    local neighbors = get_neighbors()
    if neighbors.prev and neighbors.next then
        awful.client.focus.byidx(0, neighbors.prev)
    end
end

function centerwork.focus_next()
    local neighbors = get_neighbors()
    if neighbors.prev and neighbors.next then
        awful.client.focus.byidx(0, neighbors.next)
    end
end

function centerwork.swap_prev()
    local neighbors = get_neighbors()
    if neighbors.prev and neighbors.next then
        client.focus:swap(neighbors.prev)
    end
end

function centerwork.swap_next()
    local neighbors = get_neighbors()
    if neighbors.prev and neighbors.next then
        client.focus:swap(neighbors.next)
    end
end

return centerwork
