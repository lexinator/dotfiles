local log = hs.logger.new('screen', 'debug')
log.d("Loading module")

-- Define monitor names for layout purposes
local display_laptop = "Built-in Retina Display"
local display_monitor = "LG UltraFine"

local screenWatcher = {}

-- Define window layouts
-- {"App name", "Window name", "Display Name", "unitrect", "framerect", "fullframerect"},
local internal_display = {
    {"Safari",            nil, display_laptop, hs.geometry.rect(0, 0, 0.8, 1),    nil, nil},
    {"Mail",              nil, display_laptop, hs.geometry.rect(0, 0, 0.75, 0.9), nil, nil},
    {"Radar",             nil, display_laptop, hs.geometry.rect(0, 0, 0.9, 1),    nil, nil},
    {"IntelliJ IDEA",     nil, display_laptop, hs.geometry.rect(0, 0, 0.9, 1),    nil, nil},
    {"IntelliJ IDEA-EAP", nil, display_laptop, hs.geometry.rect(0, 0, 0.9, 1),    nil, nil},

    {"Music",             nil, display_laptop, hs.layout.right75, nil},
    {"Slack",             nil, display_laptop, hs.geometry.rect(.60, 0, .40, 1), nil, nil},

    {"Messages",          nil, display_laptop, hs.geometry.rect(0, 0, 0.3, .3), nil, nil},
}

local dual_display = {
    {"Safari",            nil, display_monitor, hs.layout.left70,                nil, nil},
    {"Mail",              nil, display_monitor, hs.layout.left70,                nil, nil},
    {"Radar",             nil, display_monitor, hs.layout.left70,                nil, nil},
    {"IntelliJ IDEA",     nil, display_monitor, hs.geometry.rect(0, 0, 0.8, 1),  nil, nil},
    {"IntelliJ IDEA-EAP", nil, display_monitor, hs.geometry.rect(0, 0, 0.8, 1),  nil, nil},

    {"Slack",             nil, display_monitor, hs.geometry.rect(.6, 0, .4, 1),  nil, nil},

    {"Music",             nil, display_laptop,  hs.layout.left75,                nil, nil},
    {"Messages",          nil, display_monitor, hs.geometry.rect(0, 0, 0.3, .3), nil, nil},
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

function maxBrightness()
    for _,screen in pairs(hs.screen.allScreens()) do
        newBrightness = 1.0
        screen:setBrightness(newBrightness)
    end
end

function dimScreens()
    for _,screen in pairs(hs.screen.allScreens()) do
        current = screen:getBrightness()

        newBrightness = current - 1/17
        if newBrightness < 0.0 then
            newBrightness = 0.0
        end
        screen:setBrightness(newBrightness)
    end
end

screenWatcher = hs.screen.watcher.new(screensChangedCallback)
screenWatcher:start()

HyperMode:bind({}, '1', 'Single Monitor Layout', function()
    log.d("switching to single monitor mode...")
    hs.layout.apply(internal_display)
end)
HyperMode:bind({}, '2', 'Dual Monitor Layout', function()
    hs.layout.apply(dual_display)
end)

HyperMode:bind({}, 'b', 'Max Brightness', function()
    maxBrightness()
end)

HyperMode:bind({"shift"}, 'b', 'Reduce Brightness', function()
    dimScreens()
end)
