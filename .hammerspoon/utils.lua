local log = hs.logger.new('utils', 'debug')
log.d("Loading module")

-- borrowed from https://github.com/cmsj/hammerspoon-config/blob/master/init.lua
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
HyperMode:bind({}, 'u', 'Paste Current Safari URL', function()
    hs.timer.doAfter(1, typeCurrentSafariURL)
end)

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

HyperMode:bind({}, 'd', function()
    log.d("Pasting today's date...")
    local date = os.date("%Y-%m-%d")
    hs.pasteboard.setContents(date)
    HyperMode:exit()
    hs.eventtap.keyStrokes(date)
end)

HyperMode:bind({}, "V", 'Paste (simulated keypresses)', function()
    hs.eventtap.keyStrokes(hs.pasteboard.getContents())
end)
