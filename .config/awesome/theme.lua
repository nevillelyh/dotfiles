-------------------------------
--  "Zenburn" awesome theme  --
--    By Adrian C. (anrxc)   --
-------------------------------

local themes_path = require("gears.filesystem").get_themes_dir()
local dpi = require("beautiful.xresources").apply_dpi

-- {{{ Main
local theme = {}
theme.wallpaper = themes_path .. "zenburn/zenburn-background.png"
-- }}}

-- {{{ Styles
theme.font      = "sans 8"

-- https://github.com/dracula/i3/blob/master/.config/i3/config
-- {{{ Colors
theme.fg_normal  = "#BFBFBF" -- client.unfocused.text
theme.fg_focus   = "#F8F8F2" -- client.focused.text
theme.fg_urgent  = "#F8F8F2" -- client.urgent.text
theme.bg_normal  = "#282A36" -- client.unfocused.bground
theme.bg_focus   = "#282A36" -- client.unfocused.bground
theme.bg_urgent  = "#FF5555" -- client.urgent.bground
theme.bg_systray = theme.bg_normal
-- }}}

-- {{{ Borders
theme.useless_gap   = dpi(0)
theme.border_width  = dpi(2)
theme.border_normal = "#282A36" -- client.unfocused.border
theme.border_focus  = "#6272A4" -- client.focused.border
theme.border_marked = "#44475A" -- client.urgent.border
-- }}}

-- {{{ Titlebars
theme.titlebar_bg_focus  = "#44475A" -- client.focused_inactive.bground
theme.titlebar_bg_normal = "#282A36" -- client.unfocused.bground
-- }}}

-- There are other variable sets
-- overriding the default one when
-- defined, the sets are:
-- [taglist|tasklist]_[bg|fg]_[focus|urgent|occupied|empty|volatile]
-- titlebar_[normal|focus]
-- tooltip_[font|opacity|fg_color|bg_color|border_width|border_color]
-- Example:
--theme.taglist_bg_focus = "#CC9393"
-- }}}

-- {{{ Widgets
-- You can add as many variables as
-- you wish and access them by using
-- beautiful.variable in your rc.lua
--theme.fg_widget        = "#AECF96"
--theme.fg_center_widget = "#88A175"
--theme.fg_end_widget    = "#FF5656"
--theme.bg_widget        = "#494B4F"
--theme.border_widget    = "#3F3F3F"
-- }}}

-- {{{ Mouse finder
theme.mouse_finder_color = "#CC9393"
-- mouse_finder_[timeout|animate_timeout|radius|factor]
-- }}}

-- {{{ Menu
-- Variables set for theming the menu:
-- menu_[bg|fg]_[normal|focus]
-- menu_[border_color|border_width]
theme.menu_height = dpi(15)
theme.menu_width  = dpi(100)
-- }}}

-- {{{ Icons
-- {{{ Taglist
theme.taglist_squares_sel   = themes_path .. "zenburn/taglist/squarefz.png"
theme.taglist_squares_unsel = themes_path .. "zenburn/taglist/squarez.png"
--theme.taglist_squares_resize = "false"
-- }}}

-- {{{ Misc
-- https://github.com/lcpz/awesome-copycats/blob/master/themes/rainbow/icons/awesome.png
theme.awesome_icon = os.getenv("HOME") .. "/.config/awesome/icons/awesome.png"
theme.menu_submenu_icon      = themes_path .. "default/submenu.png"
-- }}}

-- {{{ Layout
theme.layout_tile       = themes_path .. "zenburn/layouts/tile.png"
theme.layout_tileleft   = themes_path .. "zenburn/layouts/tileleft.png"
theme.layout_tilebottom = themes_path .. "zenburn/layouts/tilebottom.png"
theme.layout_tiletop    = themes_path .. "zenburn/layouts/tiletop.png"
theme.layout_fairv      = themes_path .. "zenburn/layouts/fairv.png"
theme.layout_fairh      = themes_path .. "zenburn/layouts/fairh.png"
theme.layout_spiral     = themes_path .. "zenburn/layouts/spiral.png"
theme.layout_dwindle    = themes_path .. "zenburn/layouts/dwindle.png"
theme.layout_max        = themes_path .. "zenburn/layouts/max.png"
theme.layout_fullscreen = themes_path .. "zenburn/layouts/fullscreen.png"
theme.layout_magnifier  = themes_path .. "zenburn/layouts/magnifier.png"
theme.layout_floating   = themes_path .. "zenburn/layouts/floating.png"
theme.layout_cornernw   = themes_path .. "zenburn/layouts/cornernw.png"
theme.layout_cornerne   = themes_path .. "zenburn/layouts/cornerne.png"
theme.layout_cornersw   = themes_path .. "zenburn/layouts/cornersw.png"
theme.layout_cornerse   = themes_path .. "zenburn/layouts/cornerse.png"
theme.lain_icons        = os.getenv("HOME") .. "/.config/awesome/lain/icons/layout/zenburn/"
theme.layout_centerwork = theme.lain_icons .. "centerwork.png"
-- }}}

-- {{{ Titlebar
-- https://github.com/lcpz/awesome-copycats/tree/master/themes/blackburn/icons/titlebar
local titlebar_path = os.getenv("HOME") .. "/.config/awesome/titlebar/"
theme.titlebar_close_button_focus  = titlebar_path .. "close_focus.png"
theme.titlebar_close_button_normal = titlebar_path .. "close_normal.png"

theme.titlebar_ontop_button_focus_active  = titlebar_path .. "ontop_focus_active.png"
theme.titlebar_ontop_button_normal_active = titlebar_path .. "ontop_normal_active.png"
theme.titlebar_ontop_button_focus_inactive  = titlebar_path .. "ontop_focus_inactive.png"
theme.titlebar_ontop_button_normal_inactive = titlebar_path .. "ontop_normal_inactive.png"

theme.titlebar_sticky_button_focus_active  = titlebar_path .. "sticky_focus_active.png"
theme.titlebar_sticky_button_normal_active = titlebar_path .. "sticky_normal_active.png"
theme.titlebar_sticky_button_focus_inactive  = titlebar_path .. "sticky_focus_inactive.png"
theme.titlebar_sticky_button_normal_inactive = titlebar_path .. "sticky_normal_inactive.png"

theme.titlebar_floating_button_focus_active  = titlebar_path .. "floating_focus_active.png"
theme.titlebar_floating_button_normal_active = titlebar_path .. "floating_normal_active.png"
theme.titlebar_floating_button_focus_inactive  = titlebar_path .. "floating_focus_inactive.png"
theme.titlebar_floating_button_normal_inactive = titlebar_path .. "floating_normal_inactive.png"

theme.titlebar_maximized_button_focus_active  = titlebar_path .. "maximized_focus_active.png"
theme.titlebar_maximized_button_normal_active = titlebar_path .. "maximized_normal_active.png"
theme.titlebar_maximized_button_focus_inactive  = titlebar_path .. "maximized_focus_inactive.png"
theme.titlebar_maximized_button_normal_inactive = titlebar_path .. "maximized_normal_inactive.png"
-- }}}
-- }}}

return theme

-- vim: filetype=lua:expandtab:shiftwidth=4:tabstop=8:softtabstop=4:textwidth=80
