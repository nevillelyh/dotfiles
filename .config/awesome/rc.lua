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
local weather_widget = require("weather")
local cal_widget = require("calendar")
local spotify = require("awesome-wm-widgets.spotify-widget.spotify")

awful.util.spawn("compton -b")
awful.util.spawn("gnome-screensaver")
awful.util.spawn(awesome_path .. "audio.sh")
awful.util.spawn(awesome_path .. "xautolock.sh")
awful.util.spawn("dropbox start")
awful.util.spawn(os.getenv("HOME") .. "/.local/share/JetBrains/Toolbox/bin/jetbrains-toolbox")

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
local lock_screen = function()
    awful.spawn("gnome-screensaver-command --lock")
end
local screenshot = function ()
    awful.spawn("gnome-screenshot --interactive")
end

-- https://github.com/PapirusDevelopmentTeam/papirus-icon-theme/tree/master/ePapirus/24x24/actions
local icons_dir = awesome_path .. "icons/"
local hotkeys_icon = icons_dir .. "help-keybord-shortcuts.svg"
local terminal_icon = icons_dir .. "cm_runterm.svg"
local help_icon = icons_dir .. "help.svg"
local editor_icon = icons_dir .. "edit.svg"
local screenshot_icon = icons_dir .. "camera-on.svg"
local lock_icon = icons_dir .. "lock.svg"
local restart_icon = icons_dir .. "reload.svg"
local quit_icon = icons_dir .. "gtk-quit.svg"

myawesomemenu = {
   { "Hotkeys", function() hotkeys_popup.show_help(nil, awful.screen.focused()) end, hotkeys_icon },
   { "Manual", terminal .. " -e man awesome", help_icon },
   { "Edit Config", editor_cmd .. " " .. awesome.conffile, editor_icon },
   { "Screenshot", screenshot, screenshot_icon },
   { "Lock Screen", lock_screen, lock_icon },
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

-- Menubar configuration
menubar.utils.terminal = terminal -- Set the terminal for applications that require it
-- }}}

-- Keyboard map indicator and switcher
mykeyboardlayout = awful.widget.keyboardlayout()

-- {{{ Wibar
-- Create a textclock widget
mytextclock = wibox.widget.textclock("%a %I:%M %p")
local cw = cal_widget({ theme = 'dracula', placement = 'top_right' })
mytextclock:connect_signal("button::press", function(_, _, _, button)
    if button == 1 then cw.toggle() end
end)

-- https://github.com/lcpz/awesome-copycats/tree/master/themes/powerarrow-dark/icons
local epapirus_dir = icons_dir .. "ePapirus/"
local my_sysload_icon = wibox.widget.imagebox(epapirus_dir .. "gpm-monitor.svg")
local my_sysload = lain.widget.sysload({ settings = function()
    widget:set_markup(load_1 .. " | " .. load_5 .. " | " .. load_15)
end
})
local my_temp_icon = wibox.widget.imagebox(epapirus_dir .. "indicator-sensors-fan.svg")
local my_temp0 = lain.widget.temp({
    tempfile = "/sys/devices/virtual/thermal/thermal_zone0/temp",
    settings = function() widget:set_markup(coretemp_now .. "°C") end
})
local my_temp1 = lain.widget.temp({
    tempfile = "/sys/devices/virtual/thermal/thermal_zone1/temp",
    settings = function()
        if coretemp_now ~= "N/A" then widget:set_markup(" | " .. coretemp_now .. "°C") end
    end
})
local my_cpu_icon = wibox.widget.imagebox(epapirus_dir .. "indicator-sensors-cpu.svg")
local my_cpu = lain.widget.cpu({ settings = function()
    widget:set_markup(cpu_now.usage .. "%")
end
})
local my_mem_icon = wibox.widget.imagebox(epapirus_dir .. "indicator-sensors-memory.svg")
local my_mem = lain.widget.mem({ settings = function()
    widget:set_markup(mem_now.perc .. "%")
end
})
local my_hdd_icon = wibox.widget.imagebox(epapirus_dir .. "indicator-sensors-disk.svg")
local fs = require("fs")
local my_hdd = fs({
    notification_preset = {
        font = "Fira Mono 9",
        fg = "#BFBFBF",
        bg = "#282A36"
    },
    settings = function()
        widget:set_markup(fs_now["/"].percentage .. "%")
    end
})
local my_wifi_icon = wibox.widget.imagebox()
local my_wired_icon = wibox.widget.imagebox()
local my_net = lain.widget.net({ eth_state = "on", wifi_state = "on", settings = function()
    local wifi_icon = nil
    local wired_icon = nil
    for _, v in pairs(net_now.devices) do
        if v.wifi then
            wifi_icon = epapirus_dir .. "network-wireless-signal-"
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
            my_wifi_icon.signal = v.signal
            my_wifi_icon.icon = wifi_icon
            my_wifi_icon.stats = string.format("TX: %dKB / RX: %dKB", v.sent, v.received)
        end
        if v.ethernet then
            wired_icon = epapirus_dir .. "network-wired.svg"
            my_wired_icon.icon = wired_icon
            my_wired_icon.stats = string.format("TX: %dKB / RX: %dKB", v.sent, v.received)
        end
    end
    my_wifi_icon:set_image(wifi_icon)
    my_wired_icon:set_image(wired_icon)
end
})
my_wifi_icon:connect_signal("button::press", function(_,_,_,button)
    if (button == 1) then awful.spawn("gnome-control-center wifi") end
end)
my_wired_icon:connect_signal("button::press", function(_,_,_,button)
    if (button == 1) then awful.spawn("gnome-control-center network") end
end)
local helpers = require("lain.helpers")
local dpi = require("beautiful").xresources.apply_dpi
my_wifi_icon:connect_signal("mouse::enter", function()
    awful.spawn.easy_async("iwgetid -r", function(stdout, stderr, exitreason, exitcode)
        local ssid = stdout:gsub('%s+', '')
        local msg = string.format("SSID: %s\nSignal: %sdBm\n%s", ssid, my_wifi_icon.signal, my_wifi_icon.stats)
        my_wifi_icon.notification = naughty.notify({
            title = "Wireless",
            text = msg,
            icon = my_wifi_icon.icon,
            icon_size = dpi(16),
            position = my_wifi_icon.position,
            timeout = keep and 0 or 2, hover_timeout = 0.5,
            width = 200,
            screen = mouse.screen
        })
    end)
end)
my_wifi_icon:connect_signal("mouse::leave", function()
    naughty.destroy(my_wifi_icon.notification)
end)
my_wired_icon:connect_signal("mouse::enter", function()
    my_wired_icon.notification = naughty.notify({
        title = "Wired",
        text = my_wired_icon.stats,
        icon = my_wired_icon.icon,
        icon_size = dpi(16),
        position = my_wired_icon.position,
        timeout = keep and 0 or 2, hover_timeout = 0.5,
        width = 200,
        screen = mouse.screen
    })
end)
my_wired_icon:connect_signal("mouse::leave", function()
    naughty.destroy(my_wired_icon.notification)
end)
local my_layout = wibox.layout.align.horizontal()
my_layout.forced_width = 5
local my_separator = wibox.widget {
    layout = my_layout
}

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
        gears.wallpaper.maximized(wallpaper, s, true)
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
            spotify({
                -- https://github.com/PapirusDevelopmentTeam/papirus-icon-theme/blob/master/ePapirus/24x24/panel/spotify-indicator.svg
                play_icon = icons_dir .. "spotify-indicator.svg",
                pause_icon = icons_dir .. "spotify-indicator-patched.svg",
                font = "Fira Sans Bold 9"
            }),
            my_separator,
            wibox.widget.systray(),
            my_separator,
            my_sysload_icon,
            my_sysload.widget,
            my_temp_icon,
            my_temp0.widget,
            my_temp1.widget,
            my_cpu_icon,
            my_cpu.widget,
            my_mem_icon,
            my_mem.widget,
            my_hdd_icon,
            my_hdd.widget,
            my_wifi_icon,
            my_wired_icon,
            volume({ display_notification = true, delta = 2 }),
            weather_widget({
                api_key = "cd9f81ebc51ba66bbc40e0872d4464ef",
                city = "Brooklyn, US",
                units = "imperial",
                font = "Fira Sans Bold 9"
            }),
            my_separator,
            mykeyboardlayout,
            my_separator,
            mytextclock,
            my_separator,
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

local centerwork = require("centerwork")

-- {{{ Key bindings
globalkeys = gears.table.join(
    awful.key({ modkey,           }, "s",      hotkeys_popup.show_help,
              {description="show help", group="awesome"}),
    awful.key({ modkey,           }, "Left",   awful.tag.viewprev,
              {description = "view previous", group = "tag"}),
    awful.key({ modkey,           }, "Right",  awful.tag.viewnext,
              {description = "view next", group = "tag"}),
    awful.key({ modkey,           }, "Escape", awful.tag.history.restore,
              {description = "go back", group = "tag"}),
    awful.key({ modkey, "Shift"   }, "Left",
        function()
            if client.focus then
                local i = client.focus.first_tag.index - 1
                if i == 0 then
                    i = #client.focus.screen.tags
                end
                local tag = client.focus.screen.tags[i]
                if tag then
                    client.focus:move_to_tag(tag)
                end
            end
        end,
        {description = "move to previous", group = "tag"}),
    awful.key({ modkey, "Shift"   }, "Right",
        function()
            if client.focus then
                local i = client.focus.first_tag.index + 1
                if i == #client.focus.screen.tags + 1 then
                    i = 1
                end
                local tag = client.focus.screen.tags[i]
                if tag then
                    client.focus:move_to_tag(tag)
                end
            end
        end,
        {description = "move to next", group = "tag"}),

    awful.key({ modkey,           }, "j",
        function ()
            centerwork.focus.byidx( 1)
        end,
        {description = "focus next by index", group = "client"}
    ),
    awful.key({ modkey,           }, "k",
        function ()
            centerwork.focus.byidx(-1)
        end,
        {description = "focus previous by index", group = "client"}
    ),
    awful.key({ modkey,           }, "w", function () mymainmenu:show() end,
              {description = "show main menu", group = "awesome"}),

    -- Layout manipulation
    awful.key({ modkey, "Shift"   }, "j",
        function ()
            centerwork.swap.byidx( 1)
        end,
        {description = "swap with next client by index", group = "client"}),
    awful.key({ modkey, "Shift"   }, "k",
        function ()
            centerwork.swap.byidx(-1)
        end,
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
            if client.focus then
                client.focus:raise()
            end
        end,
        {description = "go back", group = "client"}),

    -- Standard program
    awful.key({ modkey, "Shift"   }, "Return", function () awful.spawn(terminal) end,
              {description = "open a terminal", group = "launcher"}),
    awful.key({ modkey, "Control" }, "r", awesome.restart,
              {description = "reload awesome", group = "awesome"}),
    awful.key({ modkey, "Control" }, "q", awesome.quit,
              {description = "quit awesome", group = "awesome"}),

    awful.key({ modkey,           }, "l",     function () awful.tag.incmwfact( 0.05)          end,
              {description = "increase master width factor", group = "layout"}),
    awful.key({ modkey,           }, "h",     function () awful.tag.incmwfact(-0.05)          end,
              {description = "decrease master width factor", group = "layout"}),
    awful.key({ modkey,           }, ",",     function () awful.tag.incnmaster( 1, nil, true) end,
              {description = "increase the number of master clients", group = "layout"}),
    awful.key({ modkey,           }, ".",     function () awful.tag.incnmaster(-1, nil, true) end,
              {description = "decrease the number of master clients", group = "layout"}),
    awful.key({ modkey, "Shift"   }, ",",     function () awful.tag.incncol( 1, nil, true)    end,
              {description = "increase the number of columns", group = "layout"}),
    awful.key({ modkey, "Shift"   }, ".",     function () awful.tag.incncol(-1, nil, true)    end,
              {description = "decrease the number of columns", group = "layout"}),
    awful.key({ modkey,           }, "space", function () awful.layout.inc( 1)                end,
              {description = "select next", group = "layout"}),
    awful.key({ modkey, "Shift"   }, "space", function () awful.layout.inc(-1)                end,
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
                  if c then
                    c:emit_signal(
                        "request::activate", "key.unminimize", {raise = true}
                    )
                  end
              end,
              {description = "restore minimized", group = "client"}),

    -- Prompt
    awful.key({ modkey },            "r",     function () awful.screen.focused().mypromptbox:run() end,
              {description = "run prompt", group = "launcher"}),

    awful.key({ modkey }, "x",
              function ()
                  awful.prompt.run {
                    prompt       = "Run Lua code: ",
                    textbox      = awful.screen.focused().mypromptbox.widget,
                    exe_callback = awful.util.eval,
                    history_path = awful.util.get_cache_dir() .. "/history_eval"
                  }
              end,
              {description = "lua execute prompt", group = "awesome"}),
    -- Menubar
    awful.key({ modkey }, "p", function() menubar.show() end,
              {description = "show the menubar", group = "launcher"}),

    -- Custom bindings
    awful.key({ modkey, "Shift"   }, "l", lock_screen,
              {description = "lock screen", group = "awesome"}),
    awful.key({ modkey, "Shift"   }, "s", screenshot,
              {description = "screenshot", group = "awesome"}),
    awful.key({ modkey,           }, "`", naughty.destroy_all_notifications,
              {description = "dismiss notifications", group = "awesome"}),

    awful.key({ }, "XF86AudioPlay",        function() awful.spawn("sp play") end,
              {description = "Spotify - play",     group = "media"}),
    awful.key({ }, "XF86AudioPrev",        function() awful.spawn("sp prev") end,
              {description = "Spotify - previous", group = "media"}),
    awful.key({ }, "XF86AudioNext",        function() awful.spawn("sp next") end,
              {description = "Spotify - next",     group = "media"}),
    -- pactl set-default-sink [sink]
    -- amixer -D pulse sget Master
    awful.key({ }, "XF86AudioMute",        volume.toggle,
              {description = "mute volume",        group = "media"}),
    awful.key({ }, "XF86AudioLowerVolume", volume.lower,
              {description = "lower volume",       group = "media"}),
    awful.key({ }, "XF86AudioRaiseVolume", volume.raise,
              {description = "raise volume",       group = "media"})
)

clientkeys = gears.table.join(
    awful.key({ modkey,           }, "f",
        function (c)
            c.fullscreen = not c.fullscreen
            c:raise()
        end,
        {description = "toggle fullscreen", group = "client"}),
    awful.key({ modkey, "Shift"   }, "c",      function (c) c:kill()                         end,
              {description = "close", group = "client"}),
    awful.key({ modkey, "Shift"   }, "f",      awful.client.floating.toggle                     ,
              {description = "toggle floating", group = "client"}),
    awful.key({ modkey,           }, "Return", function (c) c:swap(awful.client.getmaster()) end,
              {description = "move to master", group = "client"}),
    awful.key({ modkey,           }, "o",      function (c) c:move_to_screen()               end,
              {description = "move to screen", group = "client"}),
    awful.key({ modkey, "Shift"   }, "t",      function (c) c.ontop = not c.ontop            end,
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
          "DTA",  -- Firefox addon DownThemAll.
          "copyq",  -- Includes session name in class.
          "pinentry",
        },
        class = {
          "Arandr",
          "Blueman-manager",
          "Gpick",
          "Kruler",
          "MessageWin",  -- kalarm.
          "Sxiv",
          "Tor Browser", -- Needs a fixed window size to avoid fingerprinting by screen size.
          "Wpa_gui",
          "veromix",
          "xtightvncviewer"},

        -- Note that the name property shown in xprop might be set slightly after creation of the client
        -- and the name shown there might not match defined rules here.
        name = {
          "Event Tester",  -- xev.
        },
        role = {
          "AlarmWindow",  -- Thunderbird's calendar.
          "ConfigManager",  -- Thunderbird's about:config.
          "pop-up",       -- e.g. Google Chrome's (detached) Developer Tools.
        }
      }, properties = { floating = true }},

    -- Add titlebars to normal clients and dialogs
    { rule_any = {type = { "normal", "dialog" }
      }, properties = { titlebars_enabled = true }
    },

    -- Set Firefox to always map on the tag named "2" on screen 1.
    -- { rule = { class = "Firefox" },
    --   properties = { screen = 1, tag = "2" } },
}
-- }}}

-- {{{ Signals
-- Signal function to execute when a new client appears.
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
            awful.titlebar.widget.stickybutton   (c),
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
