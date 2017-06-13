import XMonad
import XMonad.Actions.CycleWS
import XMonad.Actions.PhysicalScreens
import XMonad.Config.Gnome
import XMonad.Hooks.ICCCMFocus
import XMonad.Hooks.ManageDocks
import XMonad.Hooks.SetWMName
import XMonad.Layout.Grid
import XMonad.Layout.NoBorders
import XMonad.Layout.Reflect
import XMonad.Layout.ResizableTile
import XMonad.Layout.Tabbed
import XMonad.Layout.ThreeColumns

import qualified Data.Map as M
import qualified XMonad.StackSet as W

main = xmonad $ gnomeConfig
    { keys        = newKeys
    , layoutHook  = newLayout
    , manageHook  = manageDocks
                 <+> newManageHook
                 <+> manageHook defaultConfig
    , modMask     = mod4Mask
    , startupHook = startupHook gnomeConfig >> takeTopFocus >> setWMName "LG3D"
    }

newLayout = smartBorders ( avoidStruts (
    -- 2 columns, main on the right
    -- (   (ResizableTall 1 (2/100) (2/3) [])  -- wide main
    -- ||| (ResizableTall 1 (2/100) (1/2) [])    -- equal width
    -- 2 columns, main on the left
    (   (reflectHoriz $ ResizableTall 1 (2/100) (2/3) [])  -- wide main
    ||| (reflectHoriz $ ResizableTall 1 (2/100) (1/2) [])    -- equal width
    ||| Grid
    )))

newManageHook = composeAll
    $ map (\n -> className =? n --> doFloat)
    [ "Cssh"
    -- , "Spotify"
    , "Vlc"
    ]

defaultKeys = keys defaultConfig
newKeys x = foldr (uncurry M.insert) (defaultKeys x) (toAddKeys    x)

lockCmd = "gnome-screensaver-command --lock"
screenCmd = "gnome-screenshot --interactive"
termCmd = "lxterminal"
spPrevCmd = "${HOME}/.dotfiles/scripts/spotify.sh previous"
spPlayCmd = "${HOME}/.dotfiles/scripts/spotify.sh playpause"
spNextCmd = "${HOME}/.dotfiles/scripts/spotify.sh next"
toAddKeys XConfig{modMask = modm} =
    [ ((modm,               xK_p),        spawn "gmrun")
    , ((modm,               xK_a),        sendMessage MirrorExpand)
    , ((modm,               xK_z),        sendMessage MirrorShrink)
    -- , ((modm,               xK_h),        sendMessage Expand)
    -- , ((modm,               xK_l),        sendMessage Shrink)
    , ((modm,               xK_Right),    nextWS)
    , ((modm,               xK_Left),     prevWS)
    , ((modm .|. shiftMask, xK_Right),    shiftToNext)
    , ((modm .|. shiftMask, xK_Left),     shiftToPrev)
    , ((modm .|. shiftMask, xK_l),        spawn lockCmd)
    , ((modm .|. shiftMask, xK_s),        spawn screenCmd)
    , ((modm .|. shiftMask, xK_Return),   spawn termCmd)
    , ((modm,               xK_KP_Enter), windows W.swapMaster)
    , ((modm,               xK_F10),      spawn spPrevCmd)
    , ((modm,               xK_F11),      spawn spPlayCmd)
    , ((modm,               xK_F12),      spawn spNextCmd)
    -- , ((modm .|. shiftMask, xK_d),        spawn "setxkbmap -layout dvorak")
    -- , ((modm .|. shiftMask, xK_q),        spawn "setxkbmap -layout us")
    ]
    ++
    -- flip screen #1 and #2
    [ ((modm .|. mask, key), screenWorkspace sc >>= flip whenJust (windows . f))
    | (key, sc) <- zip [xK_w, xK_e, xK_r] [1,0,2]
    , (f, mask) <- [(W.view, 0), (W.shift, shiftMask)]
    ]
