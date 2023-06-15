local log = hs.logger.new('init.lua', 'debug')
log.d("Loading module")

require("vpn")

local cmd_ctrl = {"cmd", "ctrl"}
local cmd_alt_ctrl = {"cmd", "alt", "ctrl"}
-- local hyper = {"cmd", "alt", "ctrl", "shift"}

-- borrowed from
--    https://github.com/cmsj/hammerspoon-config/blob/master/init.lua
function typeCurrentSafariURL()
    local ok, result
    local script = [[
    tell application "Safari"
        set currentURL to URL of document 1
    end tell
    return currentURL
    ]]
    ok, result = hs.applescript(script)
    if (ok) then
        hs.eventtap.keyStrokes(result)
    end
end

-- Define monitor names for layout purposes
-- local display_laptop = "Color LCD"
local display_laptop = "Built-in Retina Display"
local display_monitor = "LG UltraFine"

-- Define window layouts
-- {"App name", "Window name", "Display Name", "unitrect", "framerect", "fullframerect"},
local internal_display = {
     {"Safari",        nil, display_laptop, {x=0, y=0, w=0.8, h=1}, nil, nil},
     {"Mail",          nil, display_laptop, {x=0, y=0, w=0.75, h=0.9}, nil, nil},
     {"IntelliJ IDEA", nil, display_laptop, {x=0, y=0, w=0.9, h=1}, nil, nil},
     {"Radar",         nil, display_laptop, {x=0, y=0, w=0.9, h=1}, nil, nil},
--    {"IntelliJ IDEA-EAP", nil,    display_laptop, {x=0, y=0, w=0.9, h=1}, nil, nil},

-- something broken here
--    {"Messages",      nil, display_laptop, {x=0, y=0, w=0.3, h=.3}, nil, nil},
     {"Music",         nil, display_laptop, hs.layout.right75, nil},
     {"Slack",         nil, display_laptop, {x=.60, y=0, w=.40, h=1}, nil, nil},
}

local dual_display = {
    {"Safari",        nil, display_monitor, hs.layout.left70,        nil, nil},
    {"Mail",          nil, display_monitor, hs.layout.left70,        nil, nil},
    {"Radar",         nil, display_monitor, hs.layout.left70,        nil, nil},
    {"IntelliJ IDEA", nil, display_monitor, hs.layout.left80,        nil, nil},
--    {"IntelliJ IDEA-EAP", nil,    display_monitor, hs.layout.left80,        nil, nil},

    {"Slack",         nil, display_monitor, {x=.60, y=0, w=.40, h=1},  nil, nil},

    {"Music",        nil,         display_laptop,  hs.layout.left75,        nil, nil},
--     something is broken with this one
--    {"Messages",      nil,        display_monitor, hs.geometry.rect(0, 0, 0.3, .3), nil, nil},
}

-- Defines for screen watcher
local numberOfScreens = #hs.screen.allScreens()

-- Callback function for changes in screen layout
function screensChangedCallback()
    currentNumberOfScreens = #hs.screen.allScreens()

    if numberOfScreens ~= currentNumberOfScreens then
        if currentNumberOfScreens == 1 then
            hs.layout.apply(internal_display)
        elseif currentNumberOfScreens == 2 then
            hs.layout.apply(dual_display)
        end
    end

    numberOfScreens = currentNumberOfScreens
end

screenWatcher = hs.screen.watcher.new(screensChangedCallback)
screenWatcher:start()

-- hs.ipc.cliInstall()

local configFileWatcher = nil

require('hidutil')
RemapKeys()

require("keys")

-- Define audio device names for headphone/speaker switching
local workHeadphoneDevice = "Turtle Beach USB Audio"
local laptopSpeakerDevice = "MacBook Pro Speakers"

--  every window hint starts with the 1st character of the parent apps title
hs.hints.style = "vimperator"

-- Toggle between laptop speakers and turtle beach audio
function toggle_audio_output()
    local current = hs.audiodevice.defaultOutputDevice()
    local speakers = hs.audiodevice.findOutputByName(laptopSpeakerDevice)
    local headphones = hs.audiodevice.findOutputByName(workHeadphoneDevice)

    if not speakers or not headphones then
        hs.notify.new({
            title="Hammerspoon",
            informativeText="ERROR: Can't toggle some audio devices are missing",
            }):send()
        return
    end

    if current:name() == speakers:name() then
        headphones:setDefaultOutputDevice()
    else
        speakers:setDefaultOutputDevice()
    end
    hs.notify.new({
        title='Hammerspoon',
        informativeText='Audio:'..hs.audiodevice.defaultOutputDevice():name()
    }):send()
end

function set_headphones()
    local current = hs.audiodevice.defaultOutputDevice()
    local headphones = hs.audiodevice.findOutputByName(workHeadphoneDevice)

    if not headphones then
        hs.notify.new({
            title="Hammerspoon",
            informativeText="ERROR: headphones device missing",
            ""}):send()
        return
    end

    if current:name() ~= headphones:name() then
        headphones:setDefaultOutputDevice()
    end
end

-- Callback function for USB device events
function usbDeviceCallback(data)
    -- print("usbDeviceCallback: "..hs.inspect(data))

    -- apple monitor
    if (data["productName"] == "Apple Thunderbolt Display") then
        event = data["eventType"]

        if (event == "added") then
            -- at a desk with two monitors
            hs.notify.new({
                title="Hammerspoon",
                informativeText="Found Thunderbolt Display: Disabling wifi",
            }):send()
            os.execute("networksetup -setairportpower en0 off")

            -- give time to let network settle before trying to disconnect
            hs.timer.doAfter(5, vpn_disconnect)
        elseif (event == "removed") then
            -- only using laptop monitor
            hs.notify.new({
                title="Hammerspoon",
                informativeText="Laptop monitor: Enabling wifi",
            }):send()

            -- Turn on wifi
            os.execute("networksetup -setairportpower en0 on")
        end
    end

    -- lg monitor
    if (data["productName"] == "LG UltraFine Display Camera") then
        event = data["eventType"]

        if (event == "added") then
            -- at a desk with two monitors
            hs.notify.new({
                title="Hammerspoon",
                informativeText="Found LG Display: Disabling wifi",
            }):send()
            os.execute("networksetup -setairportpower en0 off")

            -- give time to let network settle before trying to disconnect
            hs.timer.doAfter(5, vpn_disconnect)
        elseif (event == "removed") then
            -- only using laptop monitor
            hs.notify.new({
                title="Hammerspoon",
                informativeText="Laptop monitor: Enabling wifi",
            }):send()

            -- Turn on wifi
            os.execute("networksetup -setairportpower en0 on")
        end
    end


    if (data["productName"] == "Turtle Beach USB Audio") then
        event = data["eventType"]

        if (event == "added") then
            -- at a sunnyvale desk with USB Audio
            hs.notify.new({
                title="Hammerspoon",
                informativeText="Audio set to TurtleBeach USB Audio",
            }):send()

            hs.audiodevice.defaultOutputDevice():setVolume(15)
            set_headphones()
        elseif (event == "removed") then
            -- only using laptop monitor
            hs.notify.new({
                title="Hammerspoon",
                informativeText="Audio set to laptop speakers",
            }):send()

            hs.audiodevice.defaultOutputDevice():setVolume(15)
        end
    end
end

usbWatcher = hs.usb.watcher.new(usbDeviceCallback)
usbWatcher:start()

require('window-management')
HyperMode:bind({}, "f5", 'Vertical Resize', vertical_resize)
HyperMode:bind({}, "f6", 'Horizontial Resize', horizontal_resize)
-- move window left
HyperMode:bind({}, "f1", function()
  local win = hs.window.focusedWindow()
  local f = win:frame()

  f.x = f.x - 10
  win:setFrame(f, 0)
end)

-- move window right
HyperMode:bind({}, "f2", function()
  local win = hs.window.focusedWindow()
  local f = win:frame()

  f.x = f.x + 10
  win:setFrame(f, 0)
end)

HyperMode:bind({}, "l", 'Lockscreen', hs.caffeinate.startScreensaver)
HyperMode:bind({}, 'q', 'Console', hs.toggleConsole)
-- HyperMode:bind({}, 'p', 'sPeaker Toggle', toggle_audio_output)
HyperMode:bind({}, 'p', '1password 7', function()
    hs.application.launchOrFocus("1Password 7")
end)

HyperMode:bind({}, 'c', 'Connect VPN', vpn_connect)

HyperMode:bind({}, 'i', 'iterm', function()
    hs.application.launchOrFocus("iTerm")
end)
HyperMode:bind({}, 's', 'safari', function()
    hs.application.launchOrFocus("Safari")
end)
HyperMode:bind({}, 'j', 'IntelliJ IDEA', function()
    hs.application.launchOrFocus("IntelliJ IDEA")
end)
HyperMode:bind({}, 'g', 'chrome', function()
    hs.application.launchOrFocus("Google Chrome")
end)
HyperMode:bind({}, 'k', 'slack', function()
    hs.application.launchOrFocus("slack")
end)
HyperMode:bind({}, 'r', 'radar', function()
    hs.application.launchOrFocus("radar 8")
end)

HyperMode:bind(cmd_ctrl, '1', 'totp', totp)
HyperMode:bind(cmd_ctrl, '2', 'totp uat', totp_uat)

HyperMode:bind({}, 'u', 'Paste Current Safari URL', function()
    hs.timer.doAfter(1, typeCurrentSafariURL)
end)
HyperMode:bind({}, "V", 'Paste (simulated keypresses)', function()
    hs.eventtap.keyStrokes(hs.pasteboard.getContents())
end)
-- hs.hotkey.showHotkeys({}, 'h')
--
-- TODO: figure out how to map this to above
-- HyperMode:bind({}, "h", "words", function()
--     hs.hotkey.showHotkeys
--     hs.hotkey.new()
-- end)

-- hs.hotkey.bind({"alt"}, "tab", 'Window Hints', hs.hints.windowHints)
HyperMode:bind({}, '1', 'Single Monitor Layout', function()
    log.d("switching to single monitor mode...")
    hs.layout.apply(internal_display)
end)
HyperMode:bind({}, '2', 'Dual Monitor Layout', function()
    log.d("hi mom", dual_display)
    hs.layout.apply(dual_display)
end)
HyperMode:bind({}, '0', 'Show watchers', function()
    print(configFileWatcher)
    print(screenWatcher)
    print(usbWatcher)
end)

-- resize windows
-- if f4 and iterm, then shrink to exactly 80 columns
HyperMode:bind({}, 'f4', 'narrow window in focus', function()
    local win = hs.window.focusedWindow()
    local app = win:application():title()
    local frame = win:frame()

    if (app == "iTerm2") then
        -- set to 80 column size
        frame.w = "570"
        win:setFrame(frame, 0)
    else
        hs.grid.resizeWindowThinner()
    end
end)

HyperMode:bind({}, 'f7', 'widen window in focus', function()
    hs.grid.resizeWindowWider()
end)

-- make control key at an escape when pressed without addition keys
-- hs.loadSpoon("ControlEscape"):start()

hs.loadSpoon("Seal")
spoon.Seal:bindHotkeys({show={{"cmd"}, "space"}})
spoon.Seal:loadPlugins(
{"apps", "useractions"}
)
spoon.Seal.plugins.useractions.actions = {
    ["Hammerspoon docs webpage"] = {
        url = "http://hammerspoon.org/docs/",
        icon = hs.image.imageFromName(hs.image.systemImageNames.ApplicationIcon),
    },
    ["say"] = {
        keyword = "tellme",
        fn = function(str) hs.alert.show(str) end,
    },
    ["open"] = {
        keyword = "open",
        fn = function(str)
            os.execute("open " .. str)
        end
    },
}
spoon.Seal:start()

hs.loadSpoon("FnMate")

hs.loadSpoon("KSheet")
spoon.KSheet:bindHotkeys({toggle={cmd_ctrl, "/"}})

-- {{{ Hyper-Enter -> Open clipboard contents.
HyperMode:bind({}, 'return', function()
  log.d("Opening clipboard contents.")
  local clipboard = hs.pasteboard.getContents():gsub("%s*$", "")
  hs.task.new("/usr/bin/open", function(exitCode, stdOut, stdErr)
    hs.notify.new({
      title = 'Opening Clipboard Contents...',
      subTitle = clipboard,
      informativeText = exitCode .. " " .. stdOut,
      stdErr,
      withdrawAfter = 3
    }):send()
  end, {clipboard}):start()
end)
-- }}} Hyper-Enter -> Open clipboard contents.


-- local ctrlTab = hs.hotkey.new({"ctrl"}, "tab", nil, function()
    --   hs.eventtap.keyStroke({"alt"}, "w")
    -- end)
    -- chromeWatcher = hs.application.watcher.new(function(name, eventType, app)
        --   if eventType ~= hs.application.watcher.activated then return end
        --   if name == "Google Chrome" then
        --     ctrlTab:enable()
        --   else
        --     ctrlTab:disable()
        --   end
        -- end)
        -- chromeWatcher:start()

        -- menuHammer = hs.loadSpoon("MenuHammer")
        -- menuHammer:enter()

        -- pomodoro key binding
        -- require "pomodoro"
        -- hs.hotkey.bind(hyper, '-', "pomodoro close", function() pom_remove() end)
        -- hs.hotkey.bind(hyper, '[', "pomodoro start", function() pom_enable() end)
        -- hs.hotkey.bind(hyper, ']', "pomodoro pause", function() pom_disable() end)
        -- hs.hotkey.bind(hyper, '\\', "pomodoro reset counter", function() pom_reset_work() end)
        --
        --
        -- track the frequency selecting of the app
        -- store the new value after app is started
        -- when hammerspoon boots up read the table back in
        -- https://www.hammerspoon.org/docs/hs.settings.html
        -- `hs.settings.getKeys() -> table`
        --  lines={ foo = 10}
        --  for i,n in pairs(lines) do print(i, "--", n) end

-- local VimMode = hs.loadSpoon('VimMode')
-- local vim = VimMode:new()

-- vim
-- --  :enableBetaFeature('block_cursor_overlay')
--   :disableForApp('Code')
--   :disableForApp('MacVim')
--   :disableForApp('zoom.us')
--   :disableForApp('iTerm')
--   :disableForApp('IntelliJ IDEA')
--   :enterWithSequence('jk')
--   :bindHotKeys({ enter = { hyper, 'n'} })
--
hs.loadSpoon("MiroWindowsManager")

hs.window.animationDuration = 0
-- TODO: figure out how to map f17 to this
-- spoon.MiroWindowsManager:bindHotkeys({
  -- up = {"" , "up"},
  -- right = {"", "right"},
  -- down = {"", "down"},
  -- left = {"", "left"},
  -- fullscreen = {"", "f"},
  -- nextscreen = {"", "n"}
-- })


-- hs.loadSpoon("TextClipboardHistory")
-- figure this out
-- spoon.TextClipboardHistory:bindHotKeys({toggle_clipboard={ {"cmd", "shift" }, "v" }})

-- hs.loadSpoon("TimeMachineProgress")
-- spoon.TimeMachineProgress:start()

-- auto reload when file changes
function reload_config(files, flags)
    doReload = false
    -- log.d("flags: " .. flags)

    for eventType, file in pairs(files) do
        log.d("looking at (" .. eventType ..") " .. file)


        if file:sub(-4) == ".lua" then
            doReload = true
        end
    end

    if doReload then
        hs.reload()
    end
end
configFileWatcher = hs.pathwatcher.new(
        os.getenv("HOME") .. "/.hammerspoon/",
        reload_config
)
configFileWatcher:start()

hs.notify.new({
    title='Hammerspoon',
    informativeText = '✅ config loaded',
--    withdrawAfter = 5,
}):send()

-- vim: foldmethod=marker
