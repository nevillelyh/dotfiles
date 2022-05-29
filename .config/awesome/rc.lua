-- If LuaRocks is installed, make sure that packages installed through it are
-- found (e.g. lgi). If LuaRocks is not installed, do nothing.
pcall(require, "luarocks.loader")

-- Standard awesome library
local gears = require("gears")
local awful = require("awful")
require("awful.autofocus")
-- Widget and layout library
local wibox = require("wibox")
-- Theme handling library
local beautiful = require("beautiful")
-- Notification library
local naughty = require("naughty")
local menubar = require("menubar")
local hotkeys_popup = require("awful.hotkeys_popup")
-- Enable hotkeys help widget for VIM and other apps
-- when client with a matching name is opened:
require("awful.hotkeys_popup.keys")

-- Load Debian menu entries
local debian = require("debian.menu")
local has_fdo, freedesktop = pcall(require, "freedesktop")

local awesome_path = os.getenv("HOME") .. "/.config/awesome/"
local lain = require("lain")
local volume = require("volume")

awful.util.spawn("compton -b")
awful.util.spawn("gnome-screensaver")
awful.util.spawn(awesome_path .. "scripts/audio-defaults.sh")
awful.util.spawn(awesome_path .. "scripts/lock-screen.sh")
awful.util.spawn("xset dpms 900 0 0")
awful.spawn.with_shell("pkill gsd-rfkill; /usr/libexec/gsd-rfkill")
-- Dropbox messes up other icons in systray
awful.util.spawn("dropbox start")
gears.timer.start_new(5, function()
    awful.util.spawn(os.getenv("HOME") .. "/.local/share/JetBrains/Toolbox/bin/jetbrains-toolbox")
    return false
end)

-- {{{ Error handling
-- Check if awesome encountered an error during startup and fell back to
-- another config (This code will only ever execute for the fallback config)
if awesome.startup_errors then
    naughty.notify({ preset = naughty.config.presets.critical,
                     title = "Oops, there were errors during startup!",
                     text = awesome.startup_errors })
end

-- Handle runtime errors after startup
do
    local in_error = false
    awesome.connect_signal("debug::error", function (err)
        -- Make sure we don't go into an endless error loop
        if in_error then return end
        in_error = true

        naughty.notify({ preset = naughty.config.presets.critical,
                         title = "Oops, an error happened!",
                         text = tostring(err) })
        in_error = false
    end)
end
-- }}}

-- {{{ Variable definitions
-- Themes define colours, icons, font and wallpapers.
beautiful.init(awesome_path .. "theme.lua")

-- This is used later as the default terminal and editor to run.
terminal = "x-terminal-emulator"
editor = os.getenv("EDITOR") or "editor"
editor_cmd = terminal .. " -e " .. editor

-- Default modkey.
-- Usually, Mod4 is the key with a logo between Control and Alt.
-- If you do not like this or do not have such a key,
-- I suggest you to remap Mod4 to another key using xmodmap or other tools.
-- However, you can use another modifier like Mod1, but it may interact with others.
modkey = "Mod4"

-- Table of layouts to cover with awful.layout.inc, order matters.
awful.layout.layouts = {
    awful.layout.suit.floating,
    lain.layout.centerwork,
    awful.layout.suit.tile,
    awful.layout.suit.tile.left,
    -- awful.layout.suit.tile.bottom,
    -- awful.layout.suit.tile.top,
    -- awful.layout.suit.fair,
    -- awful.layout.suit.fair.horizontal,
    -- awful.layout.suit.spiral,
    -- awful.layout.suit.spiral.dwindle,
    awful.layout.suit.max,
    -- awful.layout.suit.max.fullscreen,
    -- awful.layout.suit.magnifier,
    -- awful.layout.suit.corner.nw,
    -- awful.layout.suit.corner.ne,
    -- awful.layout.suit.corner.sw,
    -- awful.layout.suit.corner.se,
}
-- }}}

-- {{{ Menu
-- Create a launcher widget and a main menu
-- https://github.com/PapirusDevelopmentTeam/papirus-icon-theme/tree/master/ePapirus/24x24/actions
local icons_dir = awesome_path .. "icons/"
local hotkeys_icon = icons_dir .. "help-keybord-shortcuts.svg"
local help_icon = icons_dir .. "help.svg"
local editor_icon = icons_dir .. "edit.svg"
local restart_icon = icons_dir .. "reload.svg"
local quit_icon = icons_dir .. "gtk-quit.svg"
local terminal_icon = icons_dir .. "cm_runterm.svg"

myawesomemenu = {
    { "Hotkeys", function() hotkeys_popup.show_help(nil, awful.screen.focused()) end, hotkeys_icon },
    { "Manual", terminal .. " -e man awesome", help_icon },
    { "Edit Config", editor_cmd .. " " .. awesome.conffile, editor_icon },
    { "Restart", awesome.restart, restart_icon },
    { "Quit", function() awesome.quit() end, quit_icon },
}

local menu_awesome = { "Awesome", myawesomemenu, beautiful.awesome_icon }
local menu_terminal = { "Open Terminal", terminal, terminal_icon }

if has_fdo then
    mymainmenu = freedesktop.menu.build({
        before = { menu_awesome },
        after =  { menu_terminal }
    })
else
    mymainmenu = awful.menu({
        items = {
                  menu_awesome,
                  { "Debian", debian.menu.Debian_menu.Debian },
                  menu_terminal,
                }
    })
end

mylauncher = awful.widget.launcher({ image = beautiful.awesome_icon,
                                     menu = mymainmenu })

local screenshot_icon = icons_dir .. "camera-on.svg"
local lock_icon = icons_dir .. "lock.svg"
local logout_icon = icons_dir .. "application-exit.svg"
local sleep_icon = icons_dir .. "chronometer-pause.svg"
local restart_icon = icons_dir .. "system-restart-panel.svg"
local shutdown_icon = icons_dir .. "system-devices-panel.svg"

local screenshot_cmd = "gnome-screenshot --interactive"
local lock_screen_cmd = "xautolock -locknow"

mysystemlauncher = awful.widget.launcher({
    image = shutdown_icon,
    menu = awful.menu({
        items = {
            { "Screenshot", function() awful.spawn(screenshot_cmd) end,       screenshot_icon },
            { "Lock",       function() awful.spawn(lock_screen_cmd) end,      lock_icon },
            { "Log Out",    function() awesome.quit() end,                    logout_icon },
            { "Suspend",    function() awful.spawn("systemctl suspend") end,  sleep_icon },
            { "Restart",    function() awful.spawn("systemctl reboot") end,   restart_icon },
            { "Power Off",  function() awful.spawn("systemctl poweroff") end, shutdown_icon },
        }
    })
})

-- Menubar configuration
menubar.utils.terminal = terminal -- Set the terminal for applications that require it
-- }}}

-- Keyboard map indicator and switcher
-- mykeyboardlayout = awful.widget.keyboardlayout()
local unicode_us = "🇺🇸"
local unicode_altgr = "🇺🇳"
my_keys = {
    map = {
        { layout = "us", variant = "", symbol = unicode_us},
        { layout = "us", variant = "altgr-intl", symbol = unicode_altgr},
        { layout = "us", variant = "colemak", symbol = "CO"}
    },
    current = 1,
    widget = wibox.widget.textbox(),
    next_layout = function()
        my_keys.current = my_keys.current % #(my_keys.map) + 1
        local t = my_keys.map[my_keys.current]
        awful.spawn("setxkbmap " .. t.layout .. " " .. t.variant)
        my_keys.widget:set_text(" " .. t.symbol .. " ")
    end
}
my_keys.widget.align = "center"
my_keys.widget.forced_width = 25
my_keys.widget:buttons(awful.util.table.join(awful.button({}, 1, my_keys.next_layout)))
my_keys.widget:set_text(my_keys.map[my_keys.current].symbol)

-- {{{ Wibar
-- Create a textclock widget
local calendar = require("calendar")
local my_cal = calendar({ theme = "dracula", placement = "top_right" })
mytextclock = wibox.widget.textclock("%a %I:%M %p")
mytextclock:connect_signal("button::press", function(_, _, _, button)
    if button == 1 then my_cal.toggle() end
end)

local spotify = require("awesome-wm-widgets.spotify-widget.spotify")
local my_spotify = spotify({
    -- https://github.com/PapirusDevelopmentTeam/papirus-icon-theme/blob/master/ePapirus/24x24/panel/spotify-indicator.svg
    play_icon = icons_dir .. "spotify-indicator.svg",
    pause_icon = icons_dir .. "spotify-indicator-patched.svg",
    font = "Fira Sans Bold 9",
    max_length = 100,
})
my_spotify.children[3]:set_max_size(200)

local tooltip_preset = {
    font = "Fira Mono 9",
    mode = "outside",
    preferred_positions = { "bottom" },
}

local my_sysload = wibox.widget({
    layout = wibox.layout.fixed.horizontal,
    wibox.widget.imagebox(icons_dir .. "ePapirus/gpm-monitor.svg"),
    lain.widget.sysload({
        settings = function() widget:set_markup(load_1 .. " | " .. load_5 .. " | " .. load_15) end,
    }).widget,
})
local my_sysload_tooltip = awful.tooltip(tooltip_preset)
my_sysload_tooltip:add_to_object(my_sysload)
my_sysload:connect_signal("mouse::enter", function()
    awful.spawn.easy_async("uptime", function(stdout,_,_,_)
        my_sysload_tooltip:set_markup(stdout:gsub("^%s*(.-)%s*$", "%1"))
    end)
end)

local temp = require("temp")
local my_temp = wibox.widget({
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
local my_temp_tooltip = awful.tooltip(tooltip_preset)
my_temp_tooltip:add_to_object(my_temp)
my_temp:connect_signal("mouse::enter", function()
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
        my_temp_tooltip:set_markup(table.concat(lines, "\n"))
    end)
end)

local my_cpu = wibox.widget({
    layout = wibox.layout.fixed.horizontal,
    wibox.widget.imagebox(icons_dir .. "ePapirus/indicator-sensors-cpu.svg"),
    lain.widget.cpu({
        settings = function() widget:set_markup(cpu_now.usage .. "%") end,
    }).widget,
})
local my_cpu_tooltip = awful.tooltip(tooltip_preset)
my_cpu_tooltip:add_to_object(my_cpu)
my_cpu:connect_signal("mouse::enter", function()
    local cmd = "ps -eo user,pid,pcpu,pmem,vsz:10,rss:6,tty,stat,start_time,time,exe --sort -pcpu | head"
    awful.spawn.easy_async_with_shell(cmd, function(stdout,_,_,_)
        local lines = {}
        for line in stdout:gmatch("[^\r\n]+") do
            line = line:gsub("<", "&lt;")
            line = line:gsub(">", "&gt;")
            if #lines == 0 then line = string.format("<b>%s</b>", line) end
            lines[#lines+1] = line
        end
        my_cpu_tooltip:set_markup(table.concat(lines, "\n"))
    end)
end)

local my_mem = wibox.widget({
    layout = wibox.layout.fixed.horizontal,
    wibox.widget.imagebox(icons_dir .. "ePapirus/indicator-sensors-memory.svg"),
    lain.widget.mem({
        settings = function() widget:set_markup(mem_now.perc .. "%") end,
    }).widget,
})
local my_mem_tooltip = awful.tooltip(tooltip_preset)
my_mem_tooltip:add_to_object(my_mem)
my_mem:connect_signal("mouse::enter", function()
    awful.spawn.easy_async("free -h", function(stdout,_,_,_)
        local lines = {}
        for line in stdout:gmatch("[^\r\n]+") do
            if #lines == 0 then line = string.format("<b>%s</b>", line) end
            lines[#lines+1] = line
        end
        my_mem_tooltip:set_markup(table.concat(lines, "\n"))
    end)
end)

local gpu = require("gpu")
local my_gpu_widget = gpu({
    settings = function()
        local text = ""
        for i, g in ipairs(gpu_now) do
            if i > 1 then text = text .. " | " end
            text = text .. tostring(g.gpu_util) .. "%"
        end
        widget:set_markup(text)
    end,
}).widget
local my_gpu = wibox.widget({
    layout = wibox.layout.fixed.horizontal,
    wibox.widget.imagebox(icons_dir .. "ePapirus/indicator-sensors-gpu.svg"),
    my_gpu_widget,
})
local my_gpu_tooltip = awful.tooltip(tooltip_preset)
my_gpu_tooltip:add_to_object(my_gpu)
my_gpu:connect_signal("mouse::enter", function()
    awful.spawn.easy_async("nvidia-smi", function(stdout,_,_,_)
        local i = 0
        local lines = {}
        for line in stdout:gmatch("[^\r\n]+") do
            -- First line is date/time
            local line = line:gsub("^|(%s*)(NVIDIA[^|]-)(%s*)|$", "|%1<b>%2</b>%3|")
            if i > 0 then lines[#lines+1] = line end
            i = i + 1
        end
        my_gpu_tooltip:set_markup(table.concat(lines, "\n"))
    end)
end)
local my_hdd_widget = lain.widget.fs({
    partition = "/",
    settings = function() widget:set_markup(fs_now["/"].percentage .. "%") end,
    showpopup = "off",
}).widget
local my_hdd = wibox.widget({
    layout = wibox.layout.fixed.horizontal,
    wibox.widget.imagebox(icons_dir .. "ePapirus/indicator-sensors-disk.svg"),
    my_hdd_widget,
})
local my_hdd_tooltip = awful.tooltip(tooltip_preset)
my_hdd_tooltip:add_to_object(my_hdd)
my_hdd:connect_signal("mouse::enter", function()
    awful.spawn.easy_async("df -h", function(stdout,_,_,_)
        local lines = {}
        for line in stdout:gmatch("[^\r\n]+") do
            if #lines == 0 then line = string.format("<b>%s</b>", line) end
            lines[#lines+1] = line
        end
        my_hdd_tooltip:set_markup(table.concat(lines, "\n"))
    end)
end)

local my_wifi = wibox.widget.imagebox()
local my_wired = wibox.widget.imagebox()
local my_vpn = wibox.widget.imagebox()
local my_bt = wibox.widget.imagebox()
local my_net = lain.widget.net({ eth_state = "on", wifi_state = "on", settings = function()
    local wifi_icon = nil
    local wired_icon = nil
    local vpn_icon = nil
    my_wifi.devices = {}
    my_wired.devices = {}
    my_vpn.devices = {}
    for k, v in pairs(net_now.devices) do
        is_docker = k:find("^docker[%d]+")
        is_vpn = k:find("^vpn[%d]+")
        if v.state == "up" and not is_docker and not is_vpn then
            if v.wifi then
                wifi_icon = icons_dir .. "ePapirus/network-wireless-signal-"
                if v.signal >= -50 then
                    wifi_icon = wifi_icon .. "excellent.svg"
                elseif v.signal >= -60 then
                    wifi_icon = wifi_icon .. "good.svg"
                elseif v.signal >= -67 then
                    wifi_icon = wifi_icon .. "ok.svg"
                elseif v.signal >= -70 then
                    wifi_icon = wifi_icon .. "low.svg"
                else
                    wifi_icon = wifi_icon .. "none.svg"
                end
                my_wifi.icon = wifi_icon
                my_wifi.devices[#my_wifi.devices+1] = k
            end
            if v.ethernet then
                wired_icon = icons_dir .. "ePapirus/network-wired.svg"
                my_wired.icon = wired_icon
                my_wired.devices[#my_wired.devices+1] = k
            end
        end
        if is_vpn then
            my_vpn.devices[#my_vpn.devices+1] = k
        end
    end

    local cmd = "nmcli -t -f name,type,state connection | grep ':vpn:' | cut -d ':' -f 1,3"
    awful.spawn.easy_async_with_shell(cmd, function(stdout,_,_,_)
        local ids = {}
        local vpn_icon = icons_dir .. "ePapirus/network-vpn-patched.svg"
        for line in stdout:gmatch("[^\r\n]+") do
            local i, _ = line:find(":")
            local id = line:sub(1, i - 1)
            if line:find(":activated$") then
                vpn_icon = icons_dir .. "ePapirus/network-vpn.svg"
            elseif line:find(":activating$") then
                vpn_icon = icons_dir .. "ePapirus/network-vpn-acquiring.svg"
            end
            ids[#ids+1] = id
        end
        if #ids > 0 then
            my_vpn:set_image(vpn_icon)
        end
    end)
    my_wifi:set_image(wifi_icon)
    my_wired:set_image(wired_icon)

    awful.spawn.easy_async_with_shell("lsusb | grep -iq bluetooth", function(_,_,_,exit_code)
        if exit_code == 0 then
            awful.spawn.easy_async("bluetoothctl info", function(stdout,_,_,exit_code)
                if exit_code == 0 then
                    my_bt:set_image(icons_dir .. "ePapirus/bluetooth-paired.svg")
                else
                    my_bt:set_image(icons_dir .. "ePapirus/bluetooth-active-patched.svg")
                end
            end)
        end
    end)
end,
})
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
local my_wifi_tooltip = awful.tooltip(tooltip_preset)
my_wifi_tooltip:add_to_object(my_wifi)
my_wifi:connect_signal("mouse::enter", function()
    local cmd = "echo " .. table.concat(my_wifi.devices, " ") .. " | xargs -r -n 1 iwconfig"
    awful.spawn.easy_async_with_shell(cmd, function(stdout,_,_,_)
        my_wifi_tooltip:set_markup(fmt_net(stdout))
    end)
end)
local my_wired_tooltip = awful.tooltip(tooltip_preset)
my_wired_tooltip:add_to_object(my_wired)
my_wired:connect_signal("mouse::enter", function()
    local cmd = "echo " .. table.concat(my_wired.devices, " ") .. " | xargs -r -n 1 ifconfig"
    awful.spawn.easy_async_with_shell(cmd, function(stdout,_,_,_)
        my_wired_tooltip:set_markup(fmt_net(stdout))
    end)
end)
local my_vpn_tooltip = awful.tooltip(tooltip_preset)
my_vpn_tooltip:add_to_object(my_vpn)
my_vpn:connect_signal("mouse::enter", function()
    local cmd = "nmcli -t -f device,state device | grep -P '^vpn[\\d]+:connected' | cut -d ':' -f 1 | xargs -r -n 1 ifconfig"
    awful.spawn.easy_async_with_shell(cmd, function(stdout,_,_,_)
        stdout = stdout:gsub("%s*$", "")
        if stdout ~= "" then
            my_vpn_tooltip:set_markup(fmt_net(stdout))
        else
            my_vpn_tooltip:set_markup("Not connected")
        end
    end)
end)
local my_bt_tooltip = awful.tooltip(tooltip_preset)
my_bt_tooltip:add_to_object(my_bt)
my_bt:connect_signal("mouse::enter", function()
    awful.spawn.easy_async_with_shell("bluetoothctl info", function(stdout,_,_,exit_code)
        if exit_code == 0 then
            my_bt_tooltip:set_markup(fmt_net(stdout))
        else
            my_bt_tooltip:set_markup("No Bluetooth device connected")
        end
    end)
end)

function my_widget_button(widget, cmd)
    widget:connect_signal("button::press", function(_,_,_,button)
        if (button == 1) then awful.spawn(cmd) end
    end)
end
my_widget_button(my_sysload, "gnome-system-monitor -p")
my_widget_button(my_cpu,     "gnome-system-monitor -r")
my_widget_button(my_mem,     "gnome-system-monitor -r")
my_widget_button(my_gpu,     "nvidia-settings")
my_widget_button(my_hdd,     "gnome-system-monitor -f")
my_widget_button(my_wifi,    "gnome-control-center wifi")
my_widget_button(my_wired,   "gnome-control-center network")
my_widget_button(my_bt,      "gnome-control-center bluetooth")
my_vpn:connect_signal("button::press", function(_,_,_,button)
    -- TODO: drop-down menu for multiple VPNs
    if (button == 1) then
        local cmd = "nmcli -t -f name,type,state connection | grep ':vpn:' | cut -d ':' -f 1,3"
        awful.spawn.easy_async_with_shell(cmd, function(stdout,_,_,_)
            stdout = stdout:gsub("%s*$", "")
            local i, _ = stdout:find(":")
            local id = stdout:sub(1, i - 1)
            if stdout:find(":activated$") then
                awful.spawn.easy_async(awesome_path .. "scripts/nmcli.sh down " .. id, function(_,_,_,exit_code)
                    if exit_code == 0 then
                        naughty.notify({ title = "Disconnected from VPN: " .. id })
                    elseif exit_code ~= 130 then
                        -- Script terminated by Control-C, e.g. cancelled
                        naughty.notify({ title = "Failed to disconnect from VPN: " .. id })
                    end
                end)
            elseif stdout:find(":$") then
                awful.spawn.easy_async(awesome_path .. "scripts/nmcli.sh up " .. id, function(_,_,_,exit_code)
                    if exit_code == 0 then
                        naughty.notify({ title = "Connected to VPN: " .. id })
                    elseif exit_code ~= 130 then
                        -- Script terminated by Control-C, e.g. cancelled
                        naughty.notify({ title = "Failed to connect to VPN: " .. id })
                    end
                end)
            end
        end)
    end
end)

local weather = require("awesome-wm-widgets.weather-widget.weather")
local my_weather = weather({
    coordinates = {40.6756953, -73.9650304},
    api_key = "cd9f81ebc51ba66bbc40e0872d4464ef",
    font_name = "Fira Sans Bold",
    units = "imperial",
    time_format_12h = true,
    show_hourly_forecast = true,
    show_daily_forecast = true,
})

-- Create a wibox for each screen and add it
local taglist_buttons = gears.table.join(
                    awful.button({ }, 1, function(t) t:view_only() end),
                    awful.button({ modkey }, 1, function(t)
                                              if client.focus then
                                                  client.focus:move_to_tag(t)
                                              end
                                          end),
                    awful.button({ }, 3, awful.tag.viewtoggle),
                    awful.button({ modkey }, 3, function(t)
                                              if client.focus then
                                                  client.focus:toggle_tag(t)
                                              end
                                          end),
                    awful.button({ }, 4, function(t) awful.tag.viewnext(t.screen) end),
                    awful.button({ }, 5, function(t) awful.tag.viewprev(t.screen) end)
                )

local tasklist_buttons = gears.table.join(
                     awful.button({ }, 1, function (c)
                                              if c == client.focus then
                                                  c.minimized = true
                                              else
                                                  c:emit_signal(
                                                      "request::activate",
                                                      "tasklist",
                                                      {raise = true}
                                                  )
                                              end
                                          end),
                     awful.button({ }, 3, function()
                                              awful.menu.client_list({ theme = { width = 250 } })
                                          end),
                     awful.button({ }, 4, function ()
                                              awful.client.focus.byidx(1)
                                          end),
                     awful.button({ }, 5, function ()
                                              awful.client.focus.byidx(-1)
                                          end))

local function set_wallpaper(s)
    -- Wallpaper
    if beautiful.wallpaper then
        local wallpaper = beautiful.wallpaper
        -- If wallpaper is a function, call it with the screen
        if type(wallpaper) == "function" then
            wallpaper = wallpaper(s)
        end
        gears.wallpaper.maximized(wallpaper, s, false)
    end
end

-- Re-set wallpaper when a screen's geometry changes (e.g. different resolution)
screen.connect_signal("property::geometry", set_wallpaper)

awful.screen.connect_for_each_screen(function(s)
    -- Wallpaper
    set_wallpaper(s)

    -- Each screen has its own tag table.
    awful.tag({ "1", "2", "3", "4", "5", "6", "7", "8", "9" }, s, awful.layout.layouts[1])

    -- Create a promptbox for each screen
    s.mypromptbox = awful.widget.prompt()
    -- Create an imagebox widget which will contain an icon indicating which layout we're using.
    -- We need one layoutbox per screen.
    s.mylayoutbox = awful.widget.layoutbox(s)
    s.mylayoutbox:buttons(gears.table.join(
                           awful.button({ }, 1, function () awful.layout.inc( 1) end),
                           awful.button({ }, 3, function () awful.layout.inc(-1) end),
                           awful.button({ }, 4, function () awful.layout.inc( 1) end),
                           awful.button({ }, 5, function () awful.layout.inc(-1) end)))
    -- Create a taglist widget
    s.mytaglist = awful.widget.taglist {
        screen  = s,
        filter  = awful.widget.taglist.filter.all,
        buttons = taglist_buttons
    }

    -- Create a tasklist widget
    s.mytasklist = awful.widget.tasklist {
        screen  = s,
        filter  = awful.widget.tasklist.filter.currenttags,
        buttons = tasklist_buttons
    }

    -- Create the wibox
    s.mywibox = awful.wibar({ position = "top", screen = s })

    -- Add widgets to the wibox
    s.mywibox:setup {
        layout = wibox.layout.align.horizontal,
        { -- Left widgets
            layout = wibox.layout.fixed.horizontal,
            mylauncher,
            s.mytaglist,
            s.mypromptbox,
        },
        s.mytasklist, -- Middle widget
        { -- Right widgets
            layout = wibox.layout.fixed.horizontal,
            my_spotify,
            wibox.widget({ layout = wibox.layout.fixed.horizontal, forced_width = 5 }),
            wibox.widget.systray(),
            my_sysload,
            my_temp,
            my_cpu,
            my_mem,
            my_gpu,
            my_hdd,
            my_wifi,
            my_wired,
            my_vpn,
            my_bt,
            volume({ display_notification = true, delta = 2 }),
            my_weather,
            -- mykeyboardlayout,
            my_keys.widget,
            mytextclock,
            mysystemlauncher,
            s.mylayoutbox,
        },
    }
end)
-- }}}

-- {{{ Mouse bindings
root.buttons(gears.table.join(
    awful.button({ }, 3, function () mymainmenu:toggle() end),
    awful.button({ }, 4, awful.tag.viewnext),
    awful.button({ }, 5, awful.tag.viewprev)
))
-- }}}

-- {{{ Key bindings
globalkeys = gears.table.join(
    awful.key({ modkey, }, "s",      hotkeys_popup.show_help,
              {description="show help", group="awesome"}),
    awful.key({ modkey, }, "Left",   awful.tag.viewprev,
              {description = "view previous", group = "tag"}),
    awful.key({ modkey, }, "Right",  awful.tag.viewnext,
              {description = "view next", group = "tag"}),
    awful.key({ modkey, }, "Escape", awful.tag.history.restore,
              {description = "go back", group = "tag"}),

    awful.key({ modkey, "Shift" }, "Left",
        function()
            if client.focus then
                local i = client.focus.first_tag.index - 1
                if i == 0 then i = #client.focus.screen.tags end
                local tag = client.focus.screen.tags[i]
                if tag then client.focus:move_to_tag(tag) end
            end
        end,
        {description = "move to previous", group = "tag"}),
    awful.key({ modkey, "Shift" }, "Right",
        function()
            if client.focus then
                local i = client.focus.first_tag.index + 1
                if i == #client.focus.screen.tags + 1 then i = 1 end
                local tag = client.focus.screen.tags[i]
                if tag then client.focus:move_to_tag(tag) end
            end
        end,
        {description = "move to next", group = "tag"}),

    awful.key({ modkey,           }, "j", function () lain.layout.centerwork.focus.byidx( 1) end,
              {description = "focus next by index", group = "client"}),
    awful.key({ modkey,           }, "k", function () lain.layout.centerwork.focus.byidx(-1) end,
              {description = "focus previous by index", group = "client"}),
    awful.key({ modkey,           }, "w", function () mymainmenu:show() end,
              {description = "show main menu", group = "awesome"}),

    -- Layout manipulation
    awful.key({ modkey, "Shift"   }, "j", function () lain.layout.centerwork.swap.byidx( 1) end,
              {description = "swap with next client by index", group = "client"}),
    awful.key({ modkey, "Shift"   }, "k", function () lain.layout.centerwork.swap.byidx(-1) end,
              {description = "swap with previous client by index", group = "client"}),
    awful.key({ modkey, "Control" }, "j", function () awful.screen.focus_relative( 1) end,
              {description = "focus the next screen", group = "screen"}),
    awful.key({ modkey, "Control" }, "k", function () awful.screen.focus_relative(-1) end,
              {description = "focus the previous screen", group = "screen"}),
    awful.key({ modkey,           }, "u", awful.client.urgent.jumpto,
              {description = "jump to urgent client", group = "client"}),
    awful.key({ modkey,           }, "Tab",
        function ()
            awful.client.focus.history.previous()
            if client.focus then client.focus:raise() end
        end,
        {description = "go back", group = "client"}),

    -- Standard program
    awful.key({ modkey, "Shift"   }, "Return", function () awful.spawn(terminal) end,
              {description = "open a terminal", group = "launcher"}),
    awful.key({ modkey, "Control" }, "r", awesome.restart,
              {description = "reload awesome", group = "awesome"}),
    awful.key({ modkey, "Control" }, "q", awesome.quit,
              {description = "quit awesome", group = "awesome"}),

    awful.key({ modkey,           }, "l",     function () awful.tag.incmwfact( 0.05) end,
              {description = "increase master width factor", group = "layout"}),
    awful.key({ modkey,           }, "h",     function () awful.tag.incmwfact(-0.05) end,
              {description = "decrease master width factor", group = "layout"}),
    awful.key({ modkey,           }, ",",     function () awful.tag.incnmaster( 1, nil, true) end,
              {description = "increase the number of master clients", group = "layout"}),
    awful.key({ modkey,           }, ".",     function () awful.tag.incnmaster(-1, nil, true) end,
              {description = "decrease the number of master clients", group = "layout"}),
    awful.key({ modkey, "Shift"   }, ",",     function () awful.tag.incncol( 1, nil, true) end,
              {description = "increase the number of columns", group = "layout"}),
    awful.key({ modkey, "Shift"   }, ".",     function () awful.tag.incncol(-1, nil, true) end,
              {description = "decrease the number of columns", group = "layout"}),
    awful.key({ modkey,           }, "space", function () awful.layout.inc( 1) end,
              {description = "select next", group = "layout"}),
    awful.key({ modkey, "Shift"   }, "space", function () awful.layout.inc(-1) end,
              {description = "select previous", group = "layout"}),
    awful.key({ modkey, "Control" }, "space",
        function ()
            for _, tag in ipairs(awful.screen.focused().selected_tags) do
                local tag = client.focus.first_tag
                tag.master_width_factor = 0.5
                tag.master_count = 1
                tag.column_count = 1
            end
        end,
        {description = "reset layout", group = "layout"}),
    awful.key({ modkey, "Shift"   }, "n",
        function ()
            local c = awful.client.restore()
            -- Focus restored client
            if c then c:emit_signal("request::activate", "key.unminimize", {raise = true}) end
        end,
        {description = "restore minimized", group = "client"}),

    -- Prompt
    awful.key({ modkey }, "r", function () awful.screen.focused().mypromptbox:run() end,
              {description = "run prompt", group = "launcher"}),
    awful.key({ modkey }, "x",
        function ()
            awful.prompt.run({
                prompt       = "Run Lua code: ",
                textbox      = awful.screen.focused().mypromptbox.widget,
                exe_callback = awful.util.eval,
                history_path = awful.util.get_cache_dir() .. "/history_eval",
            })
            end,
        {description = "lua execute prompt", group = "awesome"}),

    -- Menubar
    awful.key({ modkey }, "p", function() menubar.show() end,
              {description = "show the menubar", group = "launcher"}),

    -- Custom bindings
    awful.key({ modkey, "Shift" }, "l", function() awful.spawn(lock_screen_cmd) end,
              {description = "lock screen", group = "awesome"}),
    awful.key({ modkey, "Shift" }, "s", function() awful.spawn(screenshot_cmd) end,
              {description = "screenshot", group = "awesome"}),
    awful.key({ modkey,         }, "`", naughty.destroy_all_notifications,
              {description = "dismiss notifications", group = "awesome"}),
    awful.key({ modkey, "Mod1"  }, "space", my_keys.next_layout,
              {description = "next keyboard layout", group = "awesome"}),

    awful.key({ }, "XF86AudioPlay", function() awful.spawn("sp play") end,
              {description = "Spotify - play", group = "media"}),
    awful.key({ }, "XF86AudioPrev", function() awful.spawn("sp prev") end,
              {description = "Spotify - previous", group = "media"}),
    awful.key({ }, "XF86AudioNext", function() awful.spawn("sp next") end,
              {description = "Spotify - next", group = "media"}),

    -- pactl set-default-sink [sink]
    -- amixer -D pulse sget Master
    awful.key({ }, "XF86AudioMute",        volume.toggle,
              {description = "mute volume", group = "media"}),
    awful.key({ }, "XF86AudioLowerVolume", volume.lower,
              {description = "lower volume", group = "media"}),
    awful.key({ }, "XF86AudioRaiseVolume", volume.raise,
              {description = "raise volume", group = "media"})
)

clientkeys = gears.table.join(
    awful.key({ modkey,           }, "f",
        function (c)
            c.fullscreen = not c.fullscreen
            c:raise()
        end,
        {description = "toggle fullscreen", group = "client"}),
    awful.key({ modkey, "Shift"   }, "c",      function (c) c:kill() end,
              {description = "close", group = "client"}),
    awful.key({ modkey, "Shift"   }, "f",      awful.client.floating.toggle,
              {description = "toggle floating", group = "client"}),
    awful.key({ modkey,           }, "Return", function (c) c:swap(awful.client.getmaster()) end,
              {description = "move to master", group = "client"}),
    awful.key({ modkey,           }, "o",      function (c) c:move_to_screen() end,
              {description = "move to screen", group = "client"}),
    awful.key({ modkey, "Shift"   }, "t",      function (c) c.ontop = not c.ontop end,
              {description = "toggle keep on top", group = "client"}),
    awful.key({ modkey,           }, "n",
        function (c)
            -- The client currently has the input focus, so it cannot be
            -- minimized, since minimized clients can't have the focus.
            c.minimized = true
        end ,
        {description = "minimize", group = "client"}),
    awful.key({ modkey,           }, "m",
        function (c)
            c.maximized = not c.maximized
            c:raise()
        end ,
        {description = "(un)maximize", group = "client"}),
    awful.key({ modkey, "Shift"   }, "m",
        function (c)
            c.maximized_vertical = not c.maximized_vertical
            c:raise()
        end ,
        {description = "(un)maximize vertically", group = "client"}),
    awful.key({ modkey, "Control" }, "m",
        function (c)
            c.maximized_horizontal = not c.maximized_horizontal
            c:raise()
        end ,
        {description = "(un)maximize horizontally", group = "client"})
)

-- Bind all key numbers to tags.
-- Be careful: we use keycodes to make it work on any keyboard layout.
-- This should map on the top row of your keyboard, usually 1 to 9.
for i = 1, 9 do
    globalkeys = gears.table.join(globalkeys,
        -- View tag only.
        awful.key({ modkey }, "#" .. i + 9,
                  function ()
                        local screen = awful.screen.focused()
                        local tag = screen.tags[i]
                        if tag then
                           tag:view_only()
                        end
                  end,
                  {description = "view tag #"..i, group = "tag"}),
        -- Toggle tag display.
        awful.key({ modkey, "Control" }, "#" .. i + 9,
                  function ()
                      local screen = awful.screen.focused()
                      local tag = screen.tags[i]
                      if tag then
                         awful.tag.viewtoggle(tag)
                      end
                  end,
                  {description = "toggle tag #" .. i, group = "tag"}),
        -- Move client to tag.
        awful.key({ modkey, "Shift" }, "#" .. i + 9,
                  function ()
                      if client.focus then
                          local tag = client.focus.screen.tags[i]
                          if tag then
                              client.focus:move_to_tag(tag)
                          end
                     end
                  end,
                  {description = "move focused client to tag #"..i, group = "tag"}),
        -- Toggle tag on focused client.
        awful.key({ modkey, "Control", "Shift" }, "#" .. i + 9,
                  function ()
                      if client.focus then
                          local tag = client.focus.screen.tags[i]
                          if tag then
                              client.focus:toggle_tag(tag)
                          end
                      end
                  end,
                  {description = "toggle focused client on tag #" .. i, group = "tag"})
    )
end

clientbuttons = gears.table.join(
    awful.button({ }, 1, function (c)
        c:emit_signal("request::activate", "mouse_click", {raise = true})
    end),
    awful.button({ modkey }, 1, function (c)
        c:emit_signal("request::activate", "mouse_click", {raise = true})
        awful.mouse.client.move(c)
    end),
    awful.button({ modkey }, 3, function (c)
        c:emit_signal("request::activate", "mouse_click", {raise = true})
        awful.mouse.client.resize(c)
    end)
)

-- Set keys
root.keys(globalkeys)
-- }}}

-- {{{ Rules
-- Rules to apply to new clients (through the "manage" signal).
awful.rules.rules = {
    -- All clients will match this rule.
    { rule = { },
      properties = { border_width = beautiful.border_width,
                     border_color = beautiful.border_normal,
                     focus = awful.client.focus.filter,
                     raise = true,
                     keys = clientkeys,
                     buttons = clientbuttons,
                     screen = awful.screen.preferred,
                     placement = awful.placement.no_overlap+awful.placement.no_offscreen
     }
    },

    -- Floating clients.
    { rule_any = {
        instance = {
          "DTA", -- Firefox addon DownThemAll.
          "copyq", -- Includes session name in class.
          "pinentry",
        },
        class = {
          "Arandr",
          "Blueman-manager",
          "Gpick",
          "Kruler",
          "MessageWin", -- kalarm.
          "Sxiv",
          "Tor Browser", -- Needs a fixed window size to avoid fingerprinting by screen size.
          "Wpa_gui",
          "veromix",
          "xtightvncviewer"},

        -- Note that the name property shown in xprop might be set slightly after creation of the client
        -- and the name shown there might not match defined rules here.
        name = {
          "Event Tester", -- xev.
        },
        role = {
          "AlarmWindow", -- Thunderbird's calendar.
          "ConfigManager", -- Thunderbird's about:config.
          "pop-up", -- e.g. Google Chrome's (detached) Developer Tools.
        }
      }, properties = { floating = true }},

    -- Add titlebars to normal clients and dialogs
    { rule_any = {type = { "normal", "dialog" }
      }, properties = { titlebars_enabled = true }
    },

    -- Set Firefox to always map on the tag named "2" on screen 1.
    -- { rule = { class = "Firefox" },
    --   properties = { screen = 1, tag = "2" } },

    -- wmctrl -l to list clients
    -- xprop -id $ID to inspect a client
    { rule_any = {
        instance = {
            "gcr-prompter",
            "nm-openconnect-auth-dialog",
            "zenity",
        },
      }, properties = { placement = awful.placement.centered }
    },
    { rule = { instance = "code", type = "dialog",
      }, properties = { placement = awful.placement.centered }
    },
    -- For some reason class or instance won't match
    { rule_any = { name = { "JetBrains Toolbox" },
        }, properties = { placement = awful.placement.top_right }
    },
    { rule_any = { class = { "Evolution" },
      }, properties = { tag = awful.screen.focused().tags[8] }
    },
    { rule_any = { class = { "Microsoft Teams - Preview" },
      }, properties = { tag = awful.screen.focused().tags[8] }
    },
    { rule_any = { class = { "Steam" },
      }, properties = { tag = awful.screen.focused().tags[9], titlebars_enabled = false }
    },
    { rule_any = {
        name = {
            "Aragami",
            "This War of Mine",
            "Trine",
        },
      }, properties = { floating = true },
    },
}
-- }}}

-- {{{ Signals
-- Signal function to execute when a new client appears.
local toolbox_startup = false
client.connect_signal("manage", function (c)
    -- Set the windows at the slave,
    -- i.e. put it at the end of others instead of setting it master.
    -- if not awesome.startup then awful.client.setslave(c) end

    if awesome.startup
      and not c.size_hints.user_position
      and not c.size_hints.program_position then
        -- Prevent clients from being unreachable after screen count changes.
        awful.placement.no_offscreen(c)
    end

    if c.name == "JetBrains Toolbox" and not toolbox_startup then
        c:kill()
        toolbox_startup = true
    end
end)

-- Spotify client has empty name on launch, catch name change signal instead
client.connect_signal("property::name", function(c)
    if c.name == "Slack" then
        awful.spawn(awesome_path .. "scripts/fix-icon.sh slack")
    end
    if c.name == "Spotify" then
        c:move_to_tag(c.screen.tags[9])
        awful.spawn(awesome_path .. "scripts/fix-icon.sh spotify")
    end
end)

-- Add a titlebar if titlebars_enabled is set to true in the rules.
client.connect_signal("request::titlebars", function(c)
    -- buttons for the titlebar
    local buttons = gears.table.join(
        awful.button({ }, 1, function()
            c:emit_signal("request::activate", "titlebar", {raise = true})
            awful.mouse.client.move(c)
        end),
        awful.button({ }, 3, function()
            c:emit_signal("request::activate", "titlebar", {raise = true})
            awful.mouse.client.resize(c)
        end)
    )

    awful.titlebar(c) : setup {
        { -- Left
            awful.titlebar.widget.iconwidget(c),
            buttons = buttons,
            layout  = wibox.layout.fixed.horizontal
        },
        { -- Middle
            { -- Title
                align  = "center",
                widget = awful.titlebar.widget.titlewidget(c)
            },
            buttons = buttons,
            layout  = wibox.layout.flex.horizontal
        },
        { -- Right
            awful.titlebar.widget.floatingbutton (c),
            awful.titlebar.widget.maximizedbutton(c),
            -- Sticky windows causes problem outside their home tags
            -- awful.titlebar.widget.stickybutton   (c),
            awful.titlebar.widget.ontopbutton    (c),
            awful.titlebar.widget.closebutton    (c),
            layout = wibox.layout.fixed.horizontal()
        },
        layout = wibox.layout.align.horizontal
    }
end)

-- Enable sloppy focus, so that focus follows mouse.
client.connect_signal("mouse::enter", function(c)
    c:emit_signal("request::activate", "mouse_enter", {raise = false})
end)

client.connect_signal("focus", function(c) c.border_color = beautiful.border_focus end)
client.connect_signal("unfocus", function(c) c.border_color = beautiful.border_normal end)
-- }}}

-- vim: filetype=lua:expandtab:shiftwidth=4:tabstop=8:softtabstop=4:textwidth=80
