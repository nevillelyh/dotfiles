--------------------------------------------------
-- Volume Widget for Awesome Window Manager
-- Shows the current volume level
-- More details could be found here:
-- https://github.com/streetturtle/awesome-wm-widgets/tree/master/volume-widget

-- @author Pavel Makhov, Aurélien Lajoie
-- @copyright 2018 Pavel Makhov
--------------------------------------------------

local wibox = require("wibox")
local awful = require("awful")
local naughty = require("naughty")
local gfs = require("gears.filesystem")
local dpi = require("beautiful").xresources.apply_dpi

local PATH_TO_ICONS = os.getenv("HOME") .. "/.config/awesome/icons/ePapirus/"
local volume_icon_name="audio-volume-muted"
local GET_VOLUME_CMD = "amixer sget Master"

local volume = {
    device = "",
    display_notification = false,
    notification = nil,
    delta = 5
}

local function cmd(d, c)
    return "amixer " .. d .. " sset Master " .. c
end

function volume:toggle()
    volume:_cmd(cmd(volume.device, "toggle"))
end

function volume:raise()
    volume:_cmd(cmd(volume.device, tostring(volume.delta) .. "%+"))
end
function volume:lower()
    volume:_cmd(cmd(volume.device, tostring(volume.delta) .. "%-"))
end

--{{{ Icon and notification update

--------------------------------------------------
-- Set the icon and return the message to display
-- base on sound level and mute
--------------------------------------------------
local function parse_output(stdout)
    local level = string.match(stdout, "(%d?%d?%d)%%")
    if stdout:find("%[off%]") then
        volume_icon_name="audio-volume-muted-blocking"
        return level .. "% <span color=\"red\"><b>Mute</b></span>"
    end
    level = tonumber(string.format("% 3d", level))

    if (level >= 0 and level < 12.5) then
        volume_icon_name="audio-volume-muted"
    elseif (level < 25) then
        volume_icon_name="audio-volume-low"
    elseif (level < 50) then
        volume_icon_name="audio-volume-medium"
    else
        volume_icon_name="audio-volume-high"
    end
    return level .. "%"
end

--------------------------------------------------
-- Update the icon and the notification if needed
--------------------------------------------------
local function update_graphic(widget, stdout)
    local txt = parse_output(stdout)
    widget.image = PATH_TO_ICONS .. volume_icon_name .. ".svg"
    if volume.display_notification then
        if not volume.notification then
            volume.notification = naughty.notify {
                text =  txt,
                icon=PATH_TO_ICONS .. volume_icon_name .. ".svg",
                icon_size = dpi(16),
                title = "Volume",
                position = volume.position,
                timeout = keep and 0 or 2, hover_timeout = 0.5,
                width = 200,
                screen = mouse.screen
            }
        end
        volume.notification.iconbox.image = PATH_TO_ICONS .. volume_icon_name .. ".svg"
        naughty.replace_text(volume.notification, "Volume", txt)
    end
end

--}}}

local function worker(user_args)
--{{{ Args
    local args = user_args or {}

    local volume_audio_controller = args.volume_audio_controller or "pulse"
    volume.display_notification = args.display_notification or false
    volume.position = args.notification_position or "top_right"
    if volume_audio_controller == "pulse" then
        volume.device = "-D pulse"
    end
    volume.delta = args.delta or 5
    GET_VOLUME_CMD = "amixer " .. volume.device .. " sget Master"
--}}}
--{{{ Check for icon path
    if not gfs.dir_readable(PATH_TO_ICONS) then
        naughty.notify{
            title = "Volume Widget",
            text = "Folder with icons doesn't exist: " .. PATH_TO_ICONS,
            preset = naughty.config.presets.critical
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
        layout = wibox.container.margin(_,_,_,1),
        set_image = function(self, path)
            self.icon.image = path
        end
    }
--}}}
--{{{ Spawn functions
    function volume:_cmd(cmd)
        awful.spawn.easy_async(cmd, function(stdout,_,_,_)
            update_graphic(volume.widget, stdout)
        end)
    end

    local function show()
        awful.spawn.easy_async(GET_VOLUME_CMD, function(stdout,_,_,_)
            update_graphic(volume.widget, stdout)
        end)
    end
--}}}
--{{{ Mouse event
    --[[ allows control volume level by:
    - clicking on the widget to launch control center
    - scrolling when cursor is over the widget
    ]]
    volume.widget:connect_signal("button::press", function(_,_,_,button)
        if (button == 1) then awful.spawn("gnome-control-center sound")
        elseif (button == 4) then volume.raise()
        elseif (button == 5) then volume.lower()
        end
    end)
    if volume.display_notification then
        volume.widget:connect_signal("mouse::enter", function() show() end)
        volume.widget:connect_signal("mouse::leave", function()
            naughty.destroy(volume.notification)
            volume.notification = nil
        end)
    end
--}}}

--{{{ Set initial icon
    awful.spawn.easy_async(GET_VOLUME_CMD, function(stdout)
        parse_output(stdout)
        volume.widget.image = PATH_TO_ICONS .. volume_icon_name .. ".svg"
    end)
--}}}

    return volume.widget
end

return setmetatable(volume, { __call = function(_, ...) return worker(...) end })
