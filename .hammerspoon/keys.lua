



local log = hs.logger.new('com.lexinator', 'debug')
log.d("Loading module")

-- A global variable for Hyper Mode
HyperMode = hs.hotkey.modal.new({}, 'F17')

-- Enter Hyper Mode when F17 (right option key) is pressed
local pressedF18 = function() HyperMode:enter() end

-- Leave Hyper Mode when F17 (right option key) is released.
local releasedF18 = function() HyperMode:exit() end

-- Bind the Hyper key
hs.hotkey.bind({}, 'F18', pressedF18, releasedF18)

HyperMode:bind({}, 'd', function()
    log.d("Pasting today's date...")
    local date = os.date("%Y-%m-%d")
    hs.pasteboard.setContents(date)
    HyperMode:exit()
    hs.eventtap.keyStrokes(date)
end)
