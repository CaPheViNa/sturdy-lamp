-- Base
import XMonad
import Data.Monoid
import System.Exit
import Graphics.X11.Xlib.Screen

-- Actions
import XMonad.Actions.GridSelect
import XMonad.Actions.Search (isPrefixOf)
import XMonad.Actions.UpdatePointer

-- Utilities
import XMonad.Util.Run
import XMonad.Util.SpawnOnce
import XMonad.Util.Themes

-- Hooks
import XMonad.Hooks.ManageDocks
import XMonad.Hooks.EwmhDesktops
import XMonad.Hooks.ManageHelpers
import XMonad.Hooks.DynamicLog

-- Layouts
import XMonad.Layout.Renamed
import XMonad.Layout.Fullscreen
import XMonad.Layout.ResizableTile
import XMonad.Layout.ThreeColumns
import XMonad.Layout.NoBorders
import XMonad.Layout.Hidden
import XMonad.Layout.IndependentScreens
import XMonad.Layout.BinarySpacePartition
import XMonad.Layout.Gaps
import XMonad.Layout.Spacing
import XMonad.Layout.LayoutModifier
import XMonad.Layout.LimitWindows
import XMonad.Layout.Decoration
import XMonad.Layout.NoFrillsDecoration
-- import XMonad.Layout.ShowWName
import XMonad.Layout.PerScreen
import XMonad.Layout.Simplest
import XMonad.Layout.SubLayouts
import XMonad.Layout.Tabbed
import XMonad.Layout.WindowNavigation

-- Prompts
import XMonad.Prompt
import XMonad.Prompt.Shell
import XMonad.Prompt.XMonad
import XMonad.Prompt.FuzzyMatch
import qualified XMonad.StackSet as W
import qualified Data.Map        as M

myTerminal      = "alacritty"
myFocusFollowsMouse :: Bool
myFocusFollowsMouse = True
myClickJustFocuses :: Bool
myClickJustFocuses = False

myBorderWidth   = 1

myModMask       = mod3Mask

myBar = "xmobar"

vietXPConfig = def 
            { font                  = "xft:Mononoki Nerd Font:size=10"
            , bgColor               = "#272822"       -- ^ Background color
            , fgColor               = "#FFFFFF"       -- ^ Font color
            , bgHLight              = "#66d9ef"       -- ^ Background color of a highlighted completion entry
            , fgHLight              = "#272822"       -- ^ Font color of a highlighted completion entry
            , borderColor           = "#f4bf75"       -- ^ Border color
            , promptBorderWidth     = 1   -- ^ Border width
            , position              = Bottom   -- ^ Position: 'Top', 'Bottom', or 'CenteredAt'
            , height                = 24   -- ^ Window height
            , maxComplRows          = Just 14 
            , historySize           = 256         -- ^ The number of history entries to be saved
            , historyFilter         = id
--			, promptKeymap          = M.Map (KeyMask,KeySym) (XP ())
--            , changeModeKey         = KeySym       -- ^ Key to change mode (when the prompt has multiple modes)
            , defaultText           = []       -- ^ The text by default in the prompt line
            , autoComplete          = Nothing -- ^ Just x: if only one completion remains, auto-select it,
            , showCompletionOnTab   = False         -- ^ Only show list of completions when Tab was pressed
            , searchPredicate       = fuzzyMatch
            , sorter                = fuzzySort
            , alwaysHighlight       = True
            }

windowCount :: X (Maybe String)
windowCount = gets $ Just . show . length . W.integrate' . W.stack . W.workspace . W.current . windowset

--myShowWNameTheme :: SWNConfig
--myShowWNameTheme = def
--    { swn_font      = "xft:Ubuntu:bold:size=60"
--    , swn_fade      = 1.0
--    , swn_bgcolor   = "#1c1f24"
--    , swn_color     = "#ffffff"
--    }

mygridConfig colorizer = (buildDefaultGSConfig myColorizer)
    { gs_cellheight = 40
    , gs_cellwidth = 170
    , gs_cellpadding = 7
    , gs_originFractX = 0.5
    , gs_originFractY = 0.5
    , gs_font = myFont
    }

spawnSelected' lst = gridselect conf lst >>= flip whenJust spawn
      where conf = def
                    { gs_cellheight = 40
                    , gs_cellwidth = 170
                    , gs_cellpadding = 7
                    , gs_originFractX = 0.5
                    , gs_originFractY = 0.5
                    , gs_font = myFont
                    }

myColorizer = colorRangeFromClassName
                     (0x28,0x2c,0x34)    -- lowest inactive bg
                     (0x28,0x2c,0x34)    -- highest inactive bg
                     (0xc7,0x92,0xea)    -- active bg
                     (0xc0,0xa7,0x9a)    -- inactive fg
                     (0x28,0x2c,0x34)    -- active fg

myAppGrid = [ ("Brave", "brave")
                , ("Alacritty", "alacritty")
                , ("Microsoft Teams", "teams")
                , ("Thunderbird", "thunderbird")
                , ("GIMP", "gimp")
                , ("Geany", "geany")
            ]

-- The default number of workspaces (virtual screens) and their names.
-- By default we use numeric strings, but any string may be used as a
-- workspace name. The number of workspaces is determined by the length
-- of this list.
--
-- A tagging example:
--
-- > workspaces = ["web", "irc", "code" ] ++ map show [4..9]
--
myWorkspaces    = [" I "," II "," III "," IV "," V "," VI "," VII "," VIII "," IX "]

-- Border colors for unfocused and focused windows, respectively.
--
myNormalBorderColor  = "#000000"
myFocusedBorderColor = "#c2b280"

------------------------------------------------------------------------
-- Key bindings. Add, modify or remove key bindings here.
--
myKeys conf@(XConfig {XMonad.modMask = modm}) = M.fromList $

    -- launch a terminal
    [ ((modm .|. shiftMask, xK_Return), spawn $ XMonad.terminal conf)

    -- Run DMenu Prompt
    -- , ((modm,               xK_p     ), spawn "dmenu_run -b -i -p \"Run: \"")

    -- launch brave
    , ((modm .|. shiftMask, xK_b     ), spawn "brave")

    -- launch GridSelect 
    , ((modm,               xK_g     ), goToSelected $ mygridConfig myColorizer)

    -- launch GridSelect 
    , ((modm,               xK_s     ), spawnSelected' myAppGrid) 

    -- launch XMenu 
    -- , ((modm,               xK_x     ), spawn "/home/vieto/git_sw/xmenu/xmenu.sh")

    -- launch shellPrompt
    , ((modm,               xK_p     ), shellPrompt vietXPConfig)

    -- launch XMonadPrompt
    , ((modm,               xK_x     ), xmonadPrompt vietXPConfig)

    -- close focused window
    , ((modm .|. shiftMask, xK_c     ), kill)

     -- Rotate through the available layout algorithms
    , ((modm,               xK_space ), sendMessage NextLayout)

    --  Reset the layouts on the current workspace to default
    , ((modm .|. shiftMask, xK_space ), setLayout $ XMonad.layoutHook conf)

    -- Resize viewed windows to the correct size
    , ((modm,               xK_n     ), refresh)

    -- Move focus to the next window
    , ((modm,               xK_j     ), windows W.focusDown)

    -- Move focus to the previous window
    , ((modm,               xK_k     ), windows W.focusUp  )

    -- Move focus to the master window
    , ((modm,               xK_m     ), windows W.focusMaster  )

    -- Swap the focused window and the master window
    , ((modm,               xK_Return), windows W.swapMaster)

    -- Swap the focused window with the next window
    , ((modm .|. shiftMask, xK_j     ), windows W.swapDown  )

    , ((modm .|. controlMask, xK_h   ), sendMessage $ pullGroup L )
    , ((modm .|. controlMask, xK_j   ), sendMessage $ pullGroup D )
    , ((modm .|. controlMask, xK_k   ), sendMessage $ pullGroup U )
    , ((modm .|. controlMask, xK_l   ), sendMessage $ pullGroup R )
    , ((modm .|. controlMask, xK_m   ), withFocused (sendMessage . MergeAll) )
    , ((modm .|. controlMask, xK_u   ), withFocused (sendMessage . UnMerge))
    , ((modm .|. controlMask, xK_period ), onGroup W.focusUp' )
    , ((modm .|. controlMask, xK_comma ), onGroup W.focusDown' )

    -- Swap the focused window with the previous window
    , ((modm .|. shiftMask, xK_k     ), windows W.swapUp    )

    -- Shrink the master area
    , ((modm,               xK_h     ), sendMessage Shrink)

    -- Expand the master area
    , ((modm,               xK_l     ), sendMessage Expand)

    , ((modm,               xK_a     ), sendMessage MirrorShrink)

    , ((modm,               xK_z     ), sendMessage MirrorExpand)

    -- Push window back into tiling
    , ((modm,               xK_t     ), withFocused $ windows . W.sink)

    -- Increment the number of windows in the master area
    , ((modm              , xK_comma ), sendMessage (IncMasterN 1))

    -- Deincrement the number of windows in the master area
    , ((modm              , xK_period), sendMessage (IncMasterN (-1)))

    -- Toggle the status bar gap
    -- Use this binding with avoidStruts from Hooks.ManageDocks.
    -- See also the statusBar function from Hooks.DynamicLog.
    --
    , ((modm              , xK_f     ), sendMessage ToggleStruts)

    -- Quit xmonad
    , ((modm .|. shiftMask, xK_q     ), io (exitWith ExitSuccess))

    -- Restart xmonad
    , ((modm              , xK_q     ), spawn "xmonad --recompile; xmonad --restart")

    -- Run xmessage with a summary of the default keybindings (useful for beginners)
    , ((modm .|. shiftMask, xK_slash ), spawn ("echo \"" ++ help ++ "\" | xmessage -file -"))
    ]
    ++

    --
    -- mod-[1..9], Switch to workspace N
    -- mod-shift-[1..9], Move client to workspace N
    --
    [((m .|. modm, k), windows $ f i)
        | (i, k) <- zip (XMonad.workspaces conf) [xK_1 .. xK_9]
        , (f, m) <- [(W.greedyView, 0), (W.shift, shiftMask)]]
    ++

    --
    -- mod-{w,e,r}, Switch to physical/Xinerama screens 1, 2, or 3
    -- mod-shift-{w,e,r}, Move client to screen 1, 2, or 3
    --
    [((m .|. modm, key), screenWorkspace sc >>= flip whenJust (windows . f))
        | (key, sc) <- zip [xK_w, xK_e, xK_r] [0..]
        , (f, m) <- [(W.view, 0), (W.shift, shiftMask)]]


------------------------------------------------------------------------
-- Mouse bindings: default actions bound to mouse events
--
myMouseBindings (XConfig {XMonad.modMask = modm}) = M.fromList $

    -- mod-button1, Set the window to floating mode and move by dragging
    [ ((modm, button1), (\w -> focus w >> mouseMoveWindow w
                                       >> windows W.shiftMaster))

    -- mod-button2, Raise the window to the top of the stack
    , ((modm, button2), (\w -> focus w >> windows W.shiftMaster))


    -- mod-button3, Set the window to floating mode and resize by dragging
    , ((modm, button3), (\w -> focus w >> mouseResizeWindow w
                                       >> windows W.shiftMaster))

    -- you may also bind events to the mouse scroll wheel (button4 and button5)
    ]

------------------------------------------------------------------------
-- Layouts:

-- You can specify and transform your layouts by modifying these values.
-- If you change layout bindings be sure to use 'mod-shift-space' after
-- restarting (with 'mod-q') to reset your layout state to the new
-- defaults, as xmonad preserves your old layout settings by default.
--
-- The available layouts.  Note that each layout is separated by |||,
-- which denotes layout choice.
--

gap     = 7
space   = 9
base00  = "#657b83"
base02  = "#073642"
base03  = "#002b36"
active  = "#0077BE"
myFont      = "xft:Mononoki Nerd Font:pixelsize=12:antialias=true:hinting=true"

topBarTheme = def
    { fontName              = myFont
    , inactiveBorderColor   = base03
    , inactiveColor         = base03
    , inactiveTextColor     = base03
    , activeBorderColor     = active
    , activeColor           = active
    , activeTextColor       = active
    , urgentBorderColor     = "#e34234"
    , urgentTextColor       = "#FFD700"
    , decoHeight            = 4
    }

myTabTheme = def
    { fontName              = myFont
    , inactiveBorderColor   = "#000000"
    , inactiveColor         = base02
    , inactiveTextColor     = base00
    , activeBorderColor     = "#9B7200"
    , activeColor           = active
    , activeTextColor       = base03
    }

myGaps    = gaps [(U, gap), (D, gap), (L, gap), (R, gap)]
mySpacing = spacingRaw True (Border space space space space) True (Border space space space space) True

myLayoutHook = avoidStruts $ myDefaultLayout
                where
                    myDefaultLayout =  ifWider 1050 (threeColMid ||| resizableTall) (threeRow ||| resizableTight) 
                                    ||| tabs
                                    ||| fullSNB


resizableTall = renamed [Replace "Tall"]
                $ windowNavigation
                $ myGaps
                $ addTabs shrinkText myTabTheme
                $ mySpacing
                $ subLayout [] (Simplest)
                $ ResizableTall 1 (3/100) (47/100) []


resizableTight = renamed [Replace "Tight"]
                $ windowNavigation
                $ myGaps
                $ addTabs shrinkText myTabTheme
                $ mySpacing
                $ subLayout [] (Simplest)
                $ Mirror
                $ ResizableTall 1 (3/100) (47/100) []

threeRow = renamed [Replace "3Row"]
           $ windowNavigation
           $ myGaps
           $ addTabs shrinkText myTabTheme
           $ mySpacing
           $ subLayout [] (Simplest)
           $ Mirror
           $ ThreeCol 1 (3/100) (1/3)

threeColMid = renamed [Replace "3Col"]
           $ windowNavigation
           $ myGaps
           $ addTabs shrinkText myTabTheme
           $ mySpacing
           $ subLayout [] (Simplest)
           $ ThreeColMid 1 (3/100) (47/100)

fullSNB = renamed [Replace "Full"]
           $ spacingRaw True (Border 0 0 0 0) True (Border 0 0 0 0) True
           $ Full

tabs    = renamed [Replace "Tabbed"]
            $ tabbed shrinkText myTabTheme
------------------------------------------------------------------------
-- Window rules:

-- Execute arbitrary actions and WindowSet manipulations when managing
-- a new window. You can use this to, for example, always float a
-- particular program, or have a client always appear on a particular
-- workspace.
--
-- To find the property name associated with a program, use
-- > xprop | grep WM_CLASS
-- and click on the client you're interested in.
--
-- To match on the WM_NAME, you can use 'title' in the same way that
-- 'className' and 'resource' are used below.
--
myManageHook = composeAll
    [ className =? "MPlayer"                   --> doFloat
    , className =? "Microsoft Teams - Preview" --> doShift " II "
    , className =? "Thunderbird"               --> doShift " II "
    , className =? "org.remmina.Remmina"       --> doShift " I "
    , className =? "Gimp"                      --> doFloat
    , className =? "XSane"                     --> doFloat
    , className =? "pavucontrol"               --> doFloat
    , resource  =? "desktop_window"            --> doIgnore
    , resource  =? "kdesktop"                  --> doIgnore ]
--    , isFullscreen --> doFullFloat ]

------------------------------------------------------------------------
-- Event handling

-- * EwmhDesktops users should change this to ewmhDesktopsEventHook
--
-- Defines a custom handler function for X Events. The function should
-- return (All True) if the default handler is to be run afterwards. To
-- combine event hooks use mappend or mconcat from Data.Monoid.
--
--myEventHook = mempty
myEventHook = docksEventHook 
-- <+> fullscreenEventHook

------------------------------------------------------------------------
-- Status bars and logging

-- Perform an arbitrary action on each internal state change or X event.
-- See the 'XMonad.Hooks.DynamicLog' extension for examples.
--
--myLogHook = return ()

------------------------------------------------------------------------
-- Startup hook

-- Perform an arbitrary action each time xmonad starts or is restarted
-- with mod-q.  Used by, e.g., XMonad.Layout.PerWorkspace to initialize
-- per-workspace layout choices.
--
-- By default, do nothing.
myStartupHook = do
--        spawnOnce "lxsession &"
        spawnOnce "nitrogen --restore &"
--        spawnOnce "tint2 &"
--        spawnOnce "picom &"
        spawnOnce "pasystray &"
        spawnOnce "trayer --edge top --align right --widthtype request --padding 6 --SetDockType true --SetPartialStrut true --expand true --monitor 1 --transparent true --alpha 14 --tint 0x000000 --height 20 --distance 0 &"
        spawnOnce "nm-applet &"
        spawnOnce "remmina -i &"
        spawnOnce "xset r rate 250 74"
------------------------------------------------------------------------
-- Now run xmonad with all the defaults we set up.

-- Run xmonad with the settings you specify. No need to modify this.
--
main = do
  xmproc0 <- spawnPipe "xmobar -x 0 /home/vieto/.config/xmobar/xmobarrc"
  xmproc1 <- spawnPipe "xmobar -x 0 /home/vieto/.config/xmobar/xmobarrc1"
--  xmonad $ docks defaults

-- A structure containing your configuration settings, overriding
-- fields in the default config. Any you don't override, will
-- use the defaults defined in xmonad/XMonad/Config.hs
--
-- No need to modify this.
--
-- defaults = def {
  xmonad $ ewmh $ docks def {
      -- simple stuff
        terminal           = myTerminal,
        focusFollowsMouse  = myFocusFollowsMouse,
        clickJustFocuses   = myClickJustFocuses,
        borderWidth        = myBorderWidth,
        modMask            = myModMask,
        workspaces         = myWorkspaces,
        normalBorderColor  = myNormalBorderColor,
        focusedBorderColor = myFocusedBorderColor,

      -- key bindings
        keys               = myKeys,
        mouseBindings      = myMouseBindings,

      -- hooks, layouts
     --   layoutHook         = showWName' myShowWNameTheme $ myLayoutHook,
        layoutHook         = myLayoutHook,
        manageHook         = myManageHook,
        handleEventHook    = docksEventHook,
        startupHook        = myStartupHook,
        logHook            = dynamicLogWithPP xmobarPP
            {  ppOutput = \x -> hPutStrLn xmproc0 x
                             >> hPutStrLn xmproc1 x
            ,  ppCurrent = xmobarColor "#98be65" "" . wrap "[" "]"      -- Current workspace
            ,  ppVisible = xmobarColor "#98be65" ""                     -- Visible, but not current workspace
            ,  ppHidden = xmobarColor "#82AAFF" "" . wrap "*" ""       -- Hidden workspaces
            ,  ppHiddenNoWindows = xmobarColor "#c792ea" ""             -- Hidden workspaces (no windows)
            ,  ppTitle = xmobarColor "#b3afc2" "" . shorten 60          -- Title of active window
            ,  ppSep = "<fc=#666666> | </fc>"                           -- Separator character
            ,  ppUrgent = xmobarColor "#C45500" "" . wrap "!" "!"       -- Urgent workspace
            ,  ppExtras = [windowCount]                               -- # of windows current workspace
            ,  ppOrder = \(ws:l:t:ex) -> [ws,l]++ex++[t]                -- order of things in xmobar
            }
            >> updatePointer (0.5, 0.5) (0, 0)
    }

-- | Finally, a copy of the default bindings in simple textual tabular format.
help :: String
help = unlines ["The default modifier key is 'alt'. Default keybindings:",
    "",
    "-- launching and killing programs",
    "mod-Shift-Enter  Launch xterminal",
    "mod-p            Launch dmenu",
    "mod-Shift-p      Launch gmrun",
    "mod-Shift-c      Close/kill the focused window",
    "mod-Space        Rotate through the available layout algorithms",
    "mod-Shift-Space  Reset the layouts on the current workSpace to default",
    "mod-n            Resize/refresh viewed windows to the correct size",
    "",
    "-- move focus up or down the window stack",
    "mod-Tab        Move focus to the next window",
    "mod-Shift-Tab  Move focus to the previous window",
    "mod-j          Move focus to the next window",
    "mod-k          Move focus to the previous window",
    "mod-m          Move focus to the master window",
    "",
    "-- modifying the window order",
    "mod-Return   Swap the focused window and the master window",
    "mod-Shift-j  Swap the focused window with the next window",
    "mod-Shift-k  Swap the focused window with the previous window",
    "",
    "-- resizing the master/slave ratio",
    "mod-h  Shrink the master area",
    "mod-l  Expand the master area",
    "",
    "-- floating layer support",
    "mod-t  Push window back into tiling; unfloat and re-tile it",
    "",
    "-- increase or decrease number of windows in the master area",
    "mod-comma  (mod-,)   Increment the number of windows in the master area",
    "mod-period (mod-.)   Deincrement the number of windows in the master area",
    "",
    "-- quit, or restart",
    "mod-Shift-q  Quit xmonad",
    "mod-q        Restart xmonad",
    "mod-[1..9]   Switch to workSpace N",
    "",
    "-- Workspaces & screens",
    "mod-Shift-[1..9]   Move client to workspace N",
    "mod-{w,e,r}        Switch to physical/Xinerama screens 1, 2, or 3",
    "mod-Shift-{w,e,r}  Move client to screen 1, 2, or 3",
    "",
    "-- Mouse bindings: default actions bound to mouse events",
    "mod-button1  Set the window to floating mode and move by dragging",
    "mod-button2  Raise the window to the top of the stack",
    "mod-button3  Set the window to floating mode and resize by dragging"]
