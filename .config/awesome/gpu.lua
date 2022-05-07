-- nvidia-smi --query-gpu=index,name,temperature.gpu,utilization.gpu,utilization.memory,memory.total,memory.free,memory.used --format=csv

local helpers = require("lain.helpers")
local wibox   = require("wibox")
local naughty = require("naughty")

local function factory(args)
    args = args or {}
    local gpu = { widget = wibox.widget.textbox() }

    local timeout = args.timeout or 2
    local settings =  args.settings or function() end

    function gpu.update()
        local fields = {
            "name",
            "temperature.gpu",
            "utilization.gpu",
            "utilization.memory",
            "memory.used",
            "memory.free",
            "memory.total",
        }
        local cmd = "nvidia-smi --query-gpu=" .. table.concat(fields, ",") .. " --format=csv,noheader,nounits"
        helpers.async(cmd, function(stdout, _)
            gpu_now = {}

            local namelen = 0
            for line in stdout:gmatch("[^\r\n]+") do
                local g = {}
                local i = 0
                for f in line:gmatch("([^,]+),? *") do
                    if i == 0 then
                        f = f:gsub("^GeForce +", "")
                        f = f:gsub("^Quadro +", "")
                        f = f:gsub("^Tesla +", "")
                        f = f:gsub("^TITAN +", "")
                        g.name = f
                        if #f > namelen then
                            namelen = #f
                        end
                    elseif i == 1 then
                        g.temp = tonumber(f)
                    elseif i == 2 then
                        g.gpu_util = tonumber(f)
                    elseif i == 3 then
                        g.mem_util = tonumber(f)
                    elseif i == 4 then
                        g.mem_used = tonumber(f)
                    elseif i == 5 then
                        g.mem_free = tonumber(f)
                    elseif i == 6 then
                        g.mem_total = tonumber(f)
                    end
                    i = i + 1
                end
                gpu_now[#gpu_now+1] = g
            end

            widget = gpu.widget
            widget.stats = ""
            settings()
        end)
    end

    helpers.newtimer("gpu", timeout, gpu.update)
    return gpu
end

return factory
