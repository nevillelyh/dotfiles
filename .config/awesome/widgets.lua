local awful = require("awful")
local naughty = require("naughty")
local wibox = require("wibox")
local lain = require("lain")

local awesome_path = os.getenv("HOME") .. "/.config/awesome/"
local icons_dir = awesome_path .. "icons/"
local tooltip_preset = {
    font = "Fira Mono 9",
    mode = "outside",
    preferred_positions = { "bottom" },
}

local function on_button_press(widget, cmd)
    widget:connect_signal("button::press", function(_,_,_,button)
        if (button == 1) then awful.spawn(cmd) end
    end)
end

local function fmt_net(stdout)
    local lines = {}
    for line in stdout:gmatch("[^\r\n]+") do
        line = line:gsub("<", "&lt;")
        line = line:gsub(">", "&gt;")
        if line:find("^[^%s]+") then
            line = string.format("<b>%s</b>", line)
            if #lines > 0 then line = "\n" .. line end
        end
        lines[#lines+1] = line
    end
    return table.concat(lines, "\n")
end

local function sysload(cmd)
    local widget = wibox.widget({
        layout = wibox.layout.fixed.horizontal,
        wibox.widget.imagebox(icons_dir .. "ePapirus/gpm-monitor.svg"),
        lain.widget.sysload({
            settings = function() widget:set_markup(load_1 .. " | " .. load_5 .. " | " .. load_15) end,
        }).widget,
    })
    local tooltip = awful.tooltip(tooltip_preset)
    tooltip:add_to_object(widget)
    widget:connect_signal("mouse::enter", function()
        awful.spawn.easy_async("uptime", function(stdout,_,_,_)
            tooltip:set_markup(stdout:gsub("^%s*(.-)%s*$", "%1"))
        end)
    end)
    on_button_press(widget, cmd)
    return widget
end

local function temp()
    local temp = require("temp")
    local widget = wibox.widget({
        layout = wibox.layout.fixed.horizontal,
        wibox.widget.imagebox(icons_dir .. "ePapirus/indicator-sensors-fan.svg"),
        temp({
            settings = function()
                local text = ""
                for i, t in ipairs(coretemp_now) do
                    if i > 1 then text = text .. " | " end
                    text = text .. tostring(t) .. "°C"
                end
                widget:set_markup(text)
            end,
        }),
    })
    local tooltip = awful.tooltip(tooltip_preset)
    tooltip:add_to_object(widget)
    widget:connect_signal("mouse::enter", function()
        local cmd = "sensors --no-adapter $(sensors -j | jq --raw-output 'keys[]' | sort)"
        awful.spawn.easy_async_with_shell(cmd, function(stdout,_,_,_)
            stdout = stdout:gsub("%s*$", "")
            local lines = {}
            for line in stdout:gmatch("[^\r\n]+") do
                if not line:find(":") then
                    line = string.format("<b>Sensor: %s</b>", line)
                    if #lines > 0 then line = "\n" .. line end
                end
                lines[#lines+1] = line
            end
            tooltip:set_markup(table.concat(lines, "\n"))
        end)
    end)
    return widget
end

local function cpu(cmd)
    local widget = wibox.widget({
        layout = wibox.layout.fixed.horizontal,
        wibox.widget.imagebox(icons_dir .. "ePapirus/indicator-sensors-cpu.svg"),
        lain.widget.cpu({
            settings = function() widget:set_markup(cpu_now.usage .. "%") end,
        }).widget,
    })
    local tooltip = awful.tooltip(tooltip_preset)
    tooltip:add_to_object(widget)
    widget:connect_signal("mouse::enter", function()
        local cmd = "ps -eo user,pid,pcpu,pmem,vsz:10,rss:6,tty,stat,start_time,time,exe --sort -pcpu | head"
        awful.spawn.easy_async_with_shell(cmd, function(stdout,_,_,_)
            local lines = {}
            for line in stdout:gmatch("[^\r\n]+") do
                line = line:gsub("<", "&lt;")
                line = line:gsub(">", "&gt;")
                if #lines == 0 then line = string.format("<b>%s</b>", line) end
                lines[#lines+1] = line
            end
            tooltip:set_markup(table.concat(lines, "\n"))
        end)
    end)
    on_button_press(widget, cmd)
    return widget
end

local function mem(cmd)
    local widget = wibox.widget({
        layout = wibox.layout.fixed.horizontal,
        wibox.widget.imagebox(icons_dir .. "ePapirus/indicator-sensors-memory.svg"),
        lain.widget.mem({
            settings = function() widget:set_markup(mem_now.perc .. "%") end,
        }).widget,
    })
    local tooltip = awful.tooltip(tooltip_preset)
    tooltip:add_to_object(widget)
    widget:connect_signal("mouse::enter", function()
        awful.spawn.easy_async("free -h", function(stdout,_,_,_)
            local lines = {}
            for line in stdout:gmatch("[^\r\n]+") do
                if #lines == 0 then line = string.format("<b>%s</b>", line) end
                lines[#lines+1] = line
            end
            tooltip:set_markup(table.concat(lines, "\n"))
        end)
    end)
    on_button_press(widget, cmd)
end

local function gpu(cmd)
    local gpu = require("gpu")
    local widget = wibox.widget({
        layout = wibox.layout.fixed.horizontal,
        wibox.widget.imagebox(icons_dir .. "ePapirus/indicator-sensors-gpu.svg"),
        gpu({
            settings = function()
                local text = ""
                for i, g in ipairs(gpu_now) do
                    if i > 1 then text = text .. " | " end
                    text = text .. tostring(g.gpu_util) .. "%"
                end
                widget:set_markup(text)
            end,
        }).widget,
    })
    local tooltip = awful.tooltip(tooltip_preset)
    tooltip:add_to_object(widget)
    widget:connect_signal("mouse::enter", function()
        awful.spawn.easy_async("nvidia-smi", function(stdout,_,_,_)
            local i = 0
            local lines = {}
            for line in stdout:gmatch("[^\r\n]+") do
                -- First line is date/time
                local line = line:gsub("^|(%s*)(NVIDIA[^|]-)(%s*)|$", "|%1<b>%2</b>%3|")
                if i > 0 then lines[#lines+1] = line end
                i = i + 1
            end
            tooltip:set_markup(table.concat(lines, "\n"))
        end)
    end)
    return widget
end

local function hdd(cmd)
    local widget = wibox.widget({
        layout = wibox.layout.fixed.horizontal,
        wibox.widget.imagebox(icons_dir .. "ePapirus/indicator-sensors-disk.svg"),
        lain.widget.fs({
            partition = "/",
            settings = function() widget:set_markup(fs_now["/"].percentage .. "%") end,
            showpopup = "off",
        }).widget,
    })
    local tooltip = awful.tooltip(tooltip_preset)
    tooltip:add_to_object(widget)
    widget:connect_signal("mouse::enter", function()
        awful.spawn.easy_async("df -h", function(stdout,_,_,_)
            local lines = {}
            for line in stdout:gmatch("[^\r\n]+") do
                if #lines == 0 then line = string.format("<b>%s</b>", line) end
                lines[#lines+1] = line
            end
            tooltip:set_markup(table.concat(lines, "\n"))
        end)
    end)
    on_button_press(widget, cmd)
    return widget
end

local function system()
    return {
        layout = wibox.layout.fixed.horizontal,
        sysload("gnome-system-monitor -p"),
        temp(),
        cpu("gnome-system-monitor -r"),
        mem("gnome-system-monitor -r"),
        gpu("nvidia-settings"),
        hdd("gnome-system-monitor -f"),
    }
end

local function wifi_signal_to_icon(signal)
    prefix = icons_dir .. "ePapirus/network-wireless-signal-"
    if signal >= -50 then
        return prefix .. "excellent.svg"
    elseif signal >= -60 then
        return prefix .. "good.svg"
    elseif signal >= -67 then
        return prefix .. "ok.svg"
    elseif signal >= -70 then
        return prefix .. "low.svg"
    else
        return prefix .. "none.svg"
    end
end

local vpn_activated = false
local vpn_icons = {
    default = icons_dir .. "ePapirus/network-vpn-patched.svg",
    activated = icons_dir .. "ePapirus/network-vpn.svg",
    activating = icons_dir .. "ePapirus/network-vpn-acquiring.svg",
}

local function set_vpn_icon(widget)
    local cmd = "expressvpn status | head -n 1 | sed -e 's/^\\x1b\\[[0-9;]*m//g'"
    awful.spawn.easy_async_with_shell(cmd, function(stdout,_,_,exit_code)
        if exit_code ~= 0 then
            widget:set_image(nil)
        else
            if stdout:find("^Connected") ~= Nil then
                vpn_activated = true
                vpn_icon = vpn_icons.activated
            else
                vpn_activated = false
                vpn_icon = vpn_icons.default
            end
            widget:set_image(vpn_icon)
        end
    end)
end

local function on_vpn_button_press(widget)
    widget:connect_signal("button::press", function(_,_,_,button)
        if (button == 1) then
            set_vpn_icon(widget)
            if vpn_activated then
                naughty.notify({ title = "Disconnecting from ExpressVPN" })
                awful.spawn.easy_async("expressvpn disconnect", function(_,_,_,exit_code)
                    if exit_code == 0 then
                        naughty.notify({ title = "Disconnected from ExpressVPN" })
                    else
                        naughty.notify({
                            preset = naughty.config.presets.critical,
                            title = "Failed to disconnect from ExpressVPN",
                        })
                    end
                end)
            else
                naughty.notify({ title = "Connecting to ExpressVPN" })
                awful.spawn.easy_async("expressvpn connect", function(_,_,_,exit_code)
                    if exit_code == 0 then
                        naughty.notify({ title = "Connected from ExpressVPN" })
                    else
                        naughty.notify({
                            preset = naughty.config.presets.critical,
                            title = "Failed to connect from ExpressVPN",
                        })
                    end
                end)
            end
        end
    end)
end

local function set_bt_icon(widget)
    awful.spawn.easy_async_with_shell("lsusb | grep -iq bluetooth", function(_,_,_,exit_code)
        if exit_code == 0 then
            awful.spawn.easy_async("bluetoothctl info", function(stdout,_,_,exit_code)
                if exit_code == 0 then
                    widget:set_image(icons_dir .. "ePapirus/bluetooth-paired.svg")
                else
                    widget:set_image(icons_dir .. "ePapirus/bluetooth-active-patched.svg")
                end
            end)
        end
    end)
end

local function net()
    local wifi_widget = wibox.widget.imagebox()
    local wired_widget = wibox.widget.imagebox()
    local vpn_widget = wibox.widget.imagebox()
    local bt_widget = wibox.widget.imagebox()
    local net_widget = lain.widget.net({
        eth_state = "on",
        wifi_state = "on",
        settings = function()
            local wifi_icon = nil
            local wired_icon = nil
            wifi_widget.devices = {}
            wired_widget.devices = {}
            vpn_widget.devices = {}
            for k, v in pairs(net_now.devices) do
                is_docker = k:find("^docker[%d]+")
                is_vpn = k:find("^vpn[%d]+")
                if v.state == "up" and not is_docker and not is_vpn then
                    if v.wifi then
                        wifi_icon = wifi_signal_to_icon(v.signal)
                        wifi_widget.devices[#wifi_widget.devices+1] = k
                    end
                    if v.ethernet then
                        wired_icon = icons_dir .. "ePapirus/network-wired.svg"
                        wired_widget.devices[#wired_widget.devices+1] = k
                    end
                end
                if is_vpn then
                    vpn_widget.devices[#vpn_widget.devices+1] = k
                end
            end
            wifi_widget:set_image(wifi_icon)
            wired_widget:set_image(wired_icon)

            set_vpn_icon(vpn_widget)
            set_bt_icon(bt_widget)
        end,
    })

    local wifi_tooltip = awful.tooltip(tooltip_preset)
    wifi_tooltip:add_to_object(wifi_widget)
    wifi_widget:connect_signal("mouse::enter", function()
        local cmd = "echo " .. table.concat(wifi_widget.devices, " ") .. " | xargs -r -n 1 iwconfig"
        awful.spawn.easy_async_with_shell(cmd, function(stdout,_,_,_)
            wifi_tooltip:set_markup(fmt_net(stdout))
        end)
    end)
    local wired_tooltip = awful.tooltip(tooltip_preset)
    wired_tooltip:add_to_object(wired_widget)
    wired_widget:connect_signal("mouse::enter", function()
        local cmd = "echo " .. table.concat(wired_widget.devices, " ") .. " | xargs -r -n 1 ifconfig"
        awful.spawn.easy_async_with_shell(cmd, function(stdout,_,_,_)
            wired_tooltip:set_markup(fmt_net(stdout))
        end)
    end)
    local vpn_tooltip = awful.tooltip(tooltip_preset)
    vpn_tooltip:add_to_object(vpn_widget)
    vpn_widget:connect_signal("mouse::enter", function()
        local cmd = "expressvpn status | head -n 1 | sed -e 's/^\\x1b\\[[0-9;]*m//g'"
        awful.spawn.easy_async_with_shell(cmd, function(stdout,_,_,exit_code)
            if exit_code == 0 then
                vpn_tooltip:set_markup(stdout)
            end
        end)
    end)
    local bt_tooltip = awful.tooltip(tooltip_preset)
    bt_tooltip:add_to_object(bt_widget)
    bt_widget:connect_signal("mouse::enter", function()
        awful.spawn.easy_async_with_shell("bluetoothctl info", function(stdout,_,_,exit_code)
            if exit_code == 0 then
                bt_tooltip:set_markup(fmt_net(stdout))
            else
                bt_tooltip:set_markup("No Bluetooth device connected")
            end
        end)
    end)

    on_button_press(wifi_widget,  "gnome-control-center wifi")
    on_button_press(wired_widget, "gnome-control-center network")
    on_button_press(bt_widget,    "gnome-control-center bluetooth")
    on_vpn_button_press(vpn_widget)
    return {
        layout = wibox.layout.fixed.horizontal,
        wifi_widget,
        wired_widget,
        vpn_widget,
        bt_widget,
    }
end

local function factory()
    return {
        layout = wibox.layout.fixed.horizontal,
        system(),
        net(),
    }
end

return factory
