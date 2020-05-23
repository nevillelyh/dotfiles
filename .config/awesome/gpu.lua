-- nvidia-smi --query-gpu=index,name,temperature.gpu,utilization.gpu,utilization.memory,memory.total,memory.free,memory.used --format=csv

local helpers = require("lain.helpers")
local wibox   = require("wibox")
local naughty = require("naughty")

local function factory(args)
    local gpu = {
        widget = wibox.widget.textbox()
    }

    function gpu.hide()
        if not gpu.notification then return end
        naughty.destroy(gpu.notification)
        gpu.notification = nil
    end

    function gpu.show(seconds, scr)
        gpu.hide(); gpu.update()
        gpu.notification_preset.screen = gpu.followtag and focused() or scr or 1
        gpu.notification = naughty.notify {
            preset  = gpu.notification_preset,
            timeout = type(seconds) == "number" and seconds or 5
        }
    end

    local args      = args or {}
    local timeout   = args.timeout or 2
    local showpopup = args.showpopup or "on"
    local settings  = args.settings or function() end

    gpu.followtag           = args.followtag or false
    gpu.notification_preset = args.notification_preset

    if not gpu.notification_preset then
        gpu.notification_preset = {
            font = "Monospace 10",
            fg   = "#FFFFFF",
            bg   = "#000000"
        }
    end

    function gpu.update()
        local fields = {
            "name",
            "temperature.gpu",
            "utilization.gpu",
            "utilization.memory",
            "memory.used",
            "memory.free",
            "memory.total"
        }
        local cmd = "nvidia-smi --query-gpu=" .. table.concat(fields, ",") .. " --format=csv,noheader,nounits"
        helpers.async(cmd, function(stdout, exit_code)
            gpu_now = {}

            local namelen = 0
            for line in stdout:gmatch("[^\r\n]+") do
                local g = {}
                local i = 0
                for f in line:gmatch("([^,]+),? *") do
                    if i == 0 then
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

            local fmt = "<b>%-" .. tostring(namelen) .. "s %4s %4s %4s %4s %4s %5s</b>"
            local header = string.format(fmt, "Name", "Temp", "GPU%", "RAM%", "Used", "Free", "Total")
            local notifytable = { [1] = header }
            fmt = "%-" .. tostring(namelen) .. "s %2d°C %3d%% %3d%% %4d %4d %5d MiB"
            for _, g in ipairs(gpu_now) do
                local line = string.format(fmt, g.name, g.temp, g.gpu_util, g.mem_util, g.mem_used, g.mem_free, g.mem_total)
                notifytable[#notifytable+1] = line
            end

            gpu.notification_preset.text = table.concat(notifytable, "\n")

            widget = gpu.widget

            settings()
        end)
    end

    if showpopup == "on" then
       gpu.widget:connect_signal('mouse::enter', function () gpu.show(0) end)
       gpu.widget:connect_signal('mouse::leave', function () gpu.hide() end)
    end

    helpers.newtimer("gpu", timeout, gpu.update)
    return gpu
end

return factory
