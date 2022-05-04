--[[

     Licensed under GNU General Public License v2
      * (c) 2013, Luca CPZ

--]]

local helpers  = require("lain.helpers")
local wibox    = require("wibox")
local tonumber = tonumber

-- {thermal,core} temperature info
-- lain.widget.temp

local function factory(args)
    args = args or {}

    local temp = { widget = args.widget or wibox.widget.textbox() }
    local timeout = args.timeout or 30
    local settings = args.settings or function() end

    function temp.update()
        -- temp1 is CPU, temp2..tempN are individual cores
        local cmd = {
            "find", "/sys/devices/platform",
            "-type", "f",
            "-path", "*/coretemp.*/hwmon/hwmon*/temp1_input"
        }
        helpers.async(cmd, function(f)
            local naughty = require("naughty")
            coretemp_now = {}
            local temp_fl, temp_value
            for t in f:gmatch("[^\n]+") do
                temp_fl = helpers.first_line(t)
                if temp_fl then
                    temp_value = tonumber(temp_fl)
                    coretemp_now[t] = temp_value and temp_value/1e3 or temp_fl
                end
            end
            widget = temp.widget
            settings()
        end)
    end

    helpers.newtimer("thermal", timeout, temp.update)

    return temp
end

return factory
