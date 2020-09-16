-------------------------------------------------
-- Volume Widget for Awesome Window Manager
-- Shows the current volume level
-- More details could be found here:
-- https://github.com/streetturtle/awesome-wm-widgets/tree/master/volume-widget

-- @author Pavel Makhov, Aurélien Lajoie
-- @copyright 2018 Pavel Makhov
-------------------------------------------------

local wibox = require("wibox")
local watch = require("awful.widget.watch")
local spawn = require("awful.spawn")
local naughty = require("naughty")
local gfs = require("gears.filesystem")
local dpi = require('beautiful').xresources.apply_dpi

local PATH_TO_ICONS = os.getenv("HOME") .. "/.config/awesome/icons/ePapirus/"
local volume_icon_name="audio-volume-muted"
local GET_VOLUME_CMD = 'amixer sget Master'

local volume = {device = '', display_notification = false, notification = nil, delta = 5}

function volume:toggle()
    volume:_cmd('amixer ' .. volume.device .. ' sset Master toggle')
end

function volume:raise()
    volume:_cmd('amixer ' .. volume.device .. ' sset Master ' .. tostring(volume.delta) .. '%+')
end
function volume:lower()
    volume:_cmd('amixer ' .. volume.device .. ' sset Master ' .. tostring(volume.delta) .. '%-')
end

--{{{ Icon and notification update

--------------------------------------------------
--  Set the icon and return the message to display
--  base on sound level and mute
--------------------------------------------------
local function parse_output(stdout)
    local level = string.match(stdout, "(%d?%d?%d)%%")
    if stdout:find("%[off%]") then
        volume_icon_name="audio-volume-muted-blocking"
        return level.."% <span color=\"red\"><b>Mute</b></span>"
    end
    level = tonumber(string.format("% 3d", level))

    if (level >= 0 and level < 25) then
        volume_icon_name="audio-volume-muted"
    elseif (level < 50) then
        volume_icon_name="audio-volume-low"
    elseif (level < 75) then
        volume_icon_name="audio-volume-medium"
    else
        volume_icon_name="audio-volume-high"
    end
    return level.."%"
end

--------------------------------------------------
--  Device menus
--------------------------------------------------

local awful = require("awful")
local default_source = ""
local default_sink = ""
local sources = {}
local sinks = {}

local function parse_devices(stdout)
    local name = ""
    local desc = ""
    devices = {}
    for line in stdout:gmatch("[^\r\n]+") do
        local n = string.match(line, " *Name: (.*)")
        local d = string.match(line, " *Description: (.*)")
        if n then
            name = n
        end
        if d then
            desc = d:gsub("^Monitor of ", "")
        end
        if name ~= "" and desc ~= "" then
            devices[#devices + 1] = { name = name, desc = desc }
            name = ""
            desc = ""
        end
    end
    return devices
end

local in_icon = PATH_TO_ICONS .. "audio-input-microphone.svg"
local out_icon = PATH_TO_ICONS .. "audio-speakers.svg"

function volume:_update_menu()
    if default_source ~= "" and default_sink ~= "" and #sources > 0 and #sinks > 0 then
        local source_items = {}
        for _, s in ipairs(sources) do
            if string.match(s.name, "^alsa_input.") then
                local desc = s.desc
                local icon = nil
                if s.name == default_source then
                    icon = in_icon
                end
                local cmd = "pactl set-default-source " .. s.name
                source_items[#source_items + 1] = { desc, function()
                    default_source = ""
                    awful.spawn(cmd)
                    volume:_init_menu()
                end, icon, theme = { width = 350 } }
            end
        end

        local sink_items = {}
        for _, s in ipairs(sinks) do
            if string.match(s.name, "^alsa_output.") then
                local desc = s.desc
                local icon = nil
                if s.name == default_sink then
                    icon = out_icon
                end
                local cmd = "pactl set-default-sink " .. s.name
                sink_items[#sink_items + 1] = { desc, function()
                    awful.spawn(cmd)
                    default_sink = ""
                    volume:_init_menu()
                end, icon, theme = { width = 350 } }
            end
        end

        volume.menu = awful.menu({ items = {
            { "Mute", function() volume.toggle() end, PATH_TO_ICONS .. "audio-volume-muted-blocking.svg" },
            { "Input", source_items, in_icon },
            { "Output", sink_items, out_icon },
        } })
    end
end

function volume:_init_menu()
    spawn.easy_async("pactl info", function(stdout, stderr, exitreason, exitcode)
        for line in stdout:gmatch("[^\r\n]+") do
            local src = string.match(line, "Default Source: (.*)")
            local sink = string.match(line, "Default Sink: (.*)")
            if src then
                default_source = src
            end
            if sink then
                default_sink = sink
            end
        end
        volume:_update_menu()
    end)

    spawn.easy_async("pactl list sources", function(stdout, stderr, exitreason, exitcode)
        sources = parse_devices(stdout)
        volume:_update_menu()
    end)

    spawn.easy_async("pactl list sinks", function(stdout, stderr, exitreason, exitcode)
        sinks = parse_devices(stdout)
        volume:_update_menu()
    end)
end

--------------------------------------------------------
--Update the icon and the notification if needed
--------------------------------------------------------
local function update_graphic(widget, stdout, _, _, _)
    local txt = parse_output(stdout)
    widget.image = PATH_TO_ICONS .. volume_icon_name .. ".svg"
    if volume.display_notification then
        volume.notification.iconbox.image = PATH_TO_ICONS .. volume_icon_name .. ".svg"
        naughty.replace_text(volume.notification, "Volume", txt)
    end
end

local function notif(msg, keep)
    if volume.display_notification then
        naughty.destroy(volume.notification)
        volume.notification= naughty.notify{
            text =  msg,
            icon=PATH_TO_ICONS .. volume_icon_name .. ".svg",
            icon_size = dpi(16),
            title = "Volume",
            position = volume.position,
            timeout = keep and 0 or 2, hover_timeout = 0.5,
            width = 200,
            screen = mouse.screen,
        }
    end
end

--}}}

local function worker(args)
--{{{ Args
    local args = args or {}

    local volume_audio_controller = args.volume_audio_controller or 'pulse'
    volume.display_notification = args.display_notification or false
    volume.position = args.notification_position or "top_right"
    if volume_audio_controller == 'pulse' then
        volume.device = '-D pulse'
    end
    volume.delta = args.delta or 5
    GET_VOLUME_CMD = 'amixer ' .. volume.device.. ' sget Master'
--}}}
--{{{ Check for icon path
    if not gfs.dir_readable(PATH_TO_ICONS) then
        naughty.notify{
            title = "Volume Widget",
            text = "Folder with icons doesn't exist: " .. PATH_TO_ICONS,
            preset = naughty.config.presets.critical,
        }
        return
    end
--}}}
--{{{ Widget creation
    volume.widget = wibox.widget {
        {
            id = "icon",
            image = PATH_TO_ICONS .. "audio-volume-muted.svg",
            resize = false,
            widget = wibox.widget.imagebox,
        },
        layout = wibox.container.margin(_, _, _, 1),
        set_image = function(self, path)
            self.icon.image = path
        end,
    }
--}}}
--{{{ Spawn functions
    function volume:_cmd(cmd)
        notif("")
        spawn.easy_async(cmd, function(stdout, stderr, exitreason, exitcode)
            update_graphic(volume.widget, stdout, stderr, exitreason, exitcode)
        end)
    end

    local function show()
        spawn.easy_async(GET_VOLUME_CMD,
        function(stdout, _, _, _)
        txt = parse_output(stdout)
        notif(txt, true)
        end
        )
    end
--}}}
--{{{ Mouse event
    --[[ allows control volume level by:
    - clicking on the widget to mute/unmute
    - scrolling when cursor is over the widget
    ]]
    volume.menu = nil
    volume.widget:connect_signal("button::press", function(_,_,_,button)
        if (button == 4)     then volume.raise()
        elseif (button == 5) then volume.lower()
        elseif (button == 1) then volume.menu:show()
        end
    end)
    if volume.display_notification then
        volume.widget:connect_signal("mouse::enter", function() show() end)
        volume.widget:connect_signal("mouse::leave", function() naughty.destroy(volume.notification) end)
    end
--}}}

--{{{ Set initial icon
    spawn.easy_async(GET_VOLUME_CMD, function(stdout, stderr, exitreason, exitcode)
        parse_output(stdout)
        volume.widget.image = PATH_TO_ICONS .. volume_icon_name .. ".svg"
    end)
--}}}

    volume:_init_menu()

    return volume.widget
end

return setmetatable(volume, { __call = function(_, ...) return worker(...) end })
