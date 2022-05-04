--[[

     Licensed under GNU General Public License v2
      * (c) 2018, Uli Schlacter
      * (c) 2018, Otto Modinos
      * (c) 2013, Luca CPZ

--]]

local helpers    = require("lain.helpers")
local Gio        = require("lgi").Gio
local wibox      = require("wibox")
local naughty    = require("naughty")
local gears      = require("gears")
local query_size = Gio.FILE_ATTRIBUTE_FILESYSTEM_SIZE
local query_free = Gio.FILE_ATTRIBUTE_FILESYSTEM_FREE
local query_used = Gio.FILE_ATTRIBUTE_FILESYSTEM_USED
local query      = query_size .. "," .. query_free .. "," .. query_used

-- File systems info
-- lain.widget.fs

local function factory(args)
    args = args or {}
    local fs = {
        widget = args.widget or wibox.widget.textbox(),
        units = {
            [1] = "KiB", [2] = "MiB", [3] = "GiB",
            [4] = "TiB", [5] = "PiB", [6] = "EiB",
            [7] = "ZiB", [8] = "YiB",
        },
    }

    local timeout = args.timeout or 600
    local partition = args.partition
    local threshold = args.threshold or 99
    local settings = args.settings or function() end

    local function update_synced()
        local pathlen = 10
        fs_now = {}

        local paths = {}
        for _, mount in ipairs(Gio.unix_mounts_get()) do
            local path = Gio.unix_mount_get_mount_path(mount)
            local root = Gio.File.new_for_path(path)
            local info = root:query_filesystem_info(query)

            if info then
                local size = info:get_attribute_uint64(query_size)
                local used = info:get_attribute_uint64(query_used)
                local free = info:get_attribute_uint64(query_free)

                if size > 0 then
                    local units = math.floor(math.log(size)/math.log(1024))

                    fs_now[path] = {
                        units      = fs.units[units],
                        percentage = math.floor(100 * used / size), -- used percentage
                        size       = size / math.pow(1024, units),
                        used       = used / math.pow(1024, units),
                        free       = free / math.pow(1024, units),
                    }

                    local dev = Gio.unix_mount_get_device_path(mount)
                    if dev:match("^/dev/sd%a+%d+$") then
                        paths[#paths+1] = path

                        if #path > pathlen then
                            pathlen = #path
                        end
                    end
                end
            end
        end

        if partition and fs_now[partition] and fs_now[partition].percentage >= threshold then
            if not helpers.get_map(partition) then
                naughty.notify {
                    preset = naughty.config.presets.critical,
                    title  = "Warning",
                    text   = string.format("%s is above %d%% (%d%%)", partition, threshold, fs_now[partition].percentage),
                }
                helpers.set_map(partition, true)
            else
                helpers.set_map(partition, false)
            end
        end

        local fmt = "<b>%-" .. tostring(pathlen) .. "s %4s\t%6s\t%6s\t%6s</b>"
        local stats = { [1] = string.format(fmt, "Path", "Use%", "Used", "Free", "Total") }
        fmt = "%-" .. tostring(pathlen) .. "s %3s%%\t%6.2f\t%6.2f\t%6.2f %s"
        for _, path in ipairs(paths) do
            local f = fs_now[path]
            stats[#stats+1] =
                string.format(fmt, path, f.percentage, f.used, f.free, f.size, f.units)
        end

        widget = fs.widget
        widget.stats = table.concat(stats, "\n")
        settings()
    end

    function fs.update()
        Gio.Async.start(gears.protected_call.call)(function() update_synced() end)
    end
    helpers.newtimer(partition or "fs", timeout, fs.update)

    return fs
end

return factory
