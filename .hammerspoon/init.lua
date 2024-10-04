local log = hs.logger.new('init.lua', 'debug')
log.d("Loading module")

hs.window.animationDuration = 0

-- Use Control+` to reload Hammerspoon config
hs.hotkey.bind({ 'ctrl' }, '`', nil, function() hs.reload() end)

--  every window hint starts with the 1st character of the parent apps title
hs.hints.style = "vimperator"

require("keys")

require("vpn")

require("screen")

require('hidutil')
RemapKeys()

require("utils")

require("audio")

require("usb")

require('window-management')

HyperMode:bind({"shift"}, 'c', 'calendar', function()
    hs.application.launchOrFocus("calendar")
end)
HyperMode:bind({}, 'f', 'finder', function()
    hs.application.launchOrFocus("Finder")
end)
HyperMode:bind({}, 'i', 'iterm', function()
    hs.application.launchOrFocus("iTerm")
end)
HyperMode:bind({}, 'j', 'IntelliJ IDEA', function()
    hs.application.launchOrFocus("IntelliJ IDEA")
end)
HyperMode:bind({}, "l", 'Lockscreen', hs.caffeinate.startScreensaver)
HyperMode:bind({}, 'm', 'mail', function()
    hs.application.launchOrFocus("Mail")
end)
HyperMode:bind({}, 'k', 'slack', function()
    hs.application.launchOrFocus("slack")
end)
HyperMode:bind({}, 'p', '1password 7', function()
    hs.application.launchOrFocus("1Password 7")
end)
HyperMode:bind({}, 'q', 'Console', hs.toggleConsole)
HyperMode:bind({}, 'r', 'radar', function()
    hs.application.launchOrFocus("radar 8")
end)
HyperMode:bind({}, 's', 'safari', function()
    hs.application.launchOrFocus("Safari")
end)

function connectSnorkel()
    hs.notify.new({
        title="Hammerspoon",
        informativeText="Connecting to snorkel..."
    }):send()
    -- https://gist.github.com/nriley/f2dfb2955836462b8f7806ce0da76bfb
    -- https://github.com/Ocasio-J/SidecarLauncher?tab=readme-ov-file
    os.execute("/Users/ludeman/bin/SidecarLauncher connect snorkel")
end

HyperMode:bind({}, 'w', 'sidecar to snorkel', connectSnorkel)

-- hs.hotkey.showHotkeys({"command", "ctrl"}, 'h')
-- TODO: figure out how to map this to above
HyperMode:bind({}, "h", nil, function()
    f = hs.hotkey.getHotkeys()
    log.d("hi", f)
    -- hs.hotkey.showHotkeys()
end)

-- hs.hotkey.bind({"alt"}, "tab", 'Window Hints', hs.hints.windowHints)
HyperMode:bind({}, '0', 'Show watchers', function()
    print(configFileWatcher)
    print(screenWatcher)
    print(usbWatcher)
end)

-- resize windows
HyperMode:bind({}, 'f4', 'narrow window in focus', function()
    local win = hs.window.focusedWindow()
    local app = win:application():title()
    local frame = win:frame()

    -- if f4 and iterm, then shrink to exactly 80 columns
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
spoon.Seal:loadPlugins({"apps", "useractions"})
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
    ["go"] = {
        keyword = "go",
        fn = function(str)
            os.execute("open https://at.apple.com/" .. str)
        end
    },
}
spoon.Seal:start()

--hs.loadSpoon("HotKeySheet")

-- hs.loadSpoon("FnMate")

hs.loadSpoon("KSheet")
HyperMode:bind({"shift"}, 'k', 'key sheet', function()
    spoon.KSheet:toggle()
end)

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
--  :enableBetaFeature('block_cursor_overlay')
--   :disableForApp('Code')
--   :disableForApp('MacVim')
--   :disableForApp('zoom.us')
--   :disableForApp('iTerm')
--   :disableForApp('IntelliJ IDEA')
--   :enterWithSequence('jk')
--   :bindHotKeys({ enter = { hyper, 'n'} })

hs.loadSpoon("TextClipboardHistory")
spoon.TextClipboardHistory:start()
HyperMode:bind({"command"}, 'v', 'text clipboard history', function()
    spoon.TextClipboardHistory:toggleClipboard()
end)

-- hs.loadSpoon("TimeMachineProgress")
-- spoon.TimeMachineProgress:start()

-- require("debugger")

require("window")
require("windowcycler")

require("config")

local message = require('status-message')
local messageMuting = message.new('muted 🎤')
HyperMode:bind({}, ',', function()
    messageMuting:notify(10)
end)

hs.notify.new({
    title='Hammerspoon',
    informativeText = '✅ config loaded',
--    withdrawAfter = 5,
}):send()

-- vim: foldmethod=marker
