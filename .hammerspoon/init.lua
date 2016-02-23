hs.ipc.cliInstall()

--
save_window_state = {}
local configFileWatcher = nil

local cmd_ctrl = {"cmd", "ctrl"}
local cmd_alt_ctrl = {"cmd", "alt", "ctrl"}

function vertical_resize()
  local win = hs.window.focusedWindow()
  local frame = win:frame()
  local id = win:id()

  local screen = win:screen()
  local max = screen:frame()

  -- store current size
  if (frame.h >= max.h - 10 or frame.h <= max.h) and frame.y == max.y then
      local prev_state = save_window_state[id]
      if prev_state then
        frame.x = prev_state.x
        frame.y = prev_state.y
        frame.h = prev_state.h
        frame.w = prev_state.w

        win:setFrame(frame)
      end
  else
      if save_window_state[id] then
          -- if current state != max size, then it's changed since
          -- we last stored and we should update it
          local prev_state = save_window_state[id]
          if prev_state.y ~= max.y and prev_state.h ~= max.h then
              save_window_state[id] = {
                  x=frame.x,
                  y=frame.y,
                  h=frame.h,
                  w=frame.w
          }
          end
      else
          save_window_state[id] = {
              x=frame.x,
              y=frame.y,
              h=frame.h,
              w=frame.w
          }
      end

      frame.y = max.y
      frame.h = max.h

      win:setFrame(frame)
  end
end

function horizontal_resize()
  local win = hs.window.focusedWindow()
  local frame = win:frame()
  local id = win:id()

  local screen = win:screen()
  local max = screen:frame()

  -- store current size
  if (frame.w >= max.w - 10 or frame.w <= max.w) and frame.x == max.x then
      local prev_state = save_window_state[id]
      if prev_state then
        frame.x = prev_state.x
        frame.y = prev_state.y
        frame.h = prev_state.h
        frame.w = prev_state.w

        win:setFrame(frame)
      end
  else
      if save_window_state[id] then
          -- if current state != max size, then it's changed since
          -- we last stored and we should update it
          local prev_state = save_window_state[id]
          if prev_state.x ~= max.x and prev_state.w ~= max.w then
              save_window_state[id] = {
                  x=frame.x,
                  y=frame.y,
                  h=frame.h,
                  w=frame.w
              }
          end
      else
          save_window_state[id] = {
              x=frame.x,
              y=frame.y,
              h=frame.h,
              w=frame.w
          }
      end

      if not save_window_state[id] then
          save_window_state[id] = {
              x=frame.x,
              y=frame.y,
              h=frame.h,
              w=frame.w,
              state='max'
          }
      end

      frame.x = max.x
      frame.w = max.w

      win:setFrame(frame)
  end
end

function vpn_connect()
    hs.notify.new({
        title="Hammerspoon",
        informativeText="Connecting vpn...",
    }):send()
    os.execute("/Users/ludeman/bin/tvpn")
end

function vpn_disconnect()
    hs.notify.new({
        title="Hammerspoon",
        informativeText="Disabling vpn...",
    }):send()
    os.execute("/Users/ludeman/bin/vpn vpn --action disconnect")
end

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
local display_laptop = "Color LCD"
local display_monitor = "Thunderbolt Display"

-- Define audio device names for headphone/speaker switching
local workHeadphoneDevice = "Turtle Beach USB Audio"
local laptopSpeakerDevice = "Built-in Output"

-- Defines for window grid
hs.grid.GRIDWIDTH = 4
hs.grid.GRIDHEIGHT = 4
hs.grid.MARGINX = 0
hs.grid.MARGINY = 0

--  every window hint starts with the 1st character of the parent apps title
hs.hints.style = "vimperator"

-- debugging tool start
local point_in_rect = function(rect, point)
    return  point.x >= rect.x and
            point.y >= rect.y and
            point.x <= rect.x + rect.w and
            point.y <= rect.y + rect.h
end

local window_underneath_mouse = function()
    local pos = hs.mouse.getAbsolutePosition()
    local win = hs.fnutils.find(hs.window.orderedWindows(), function(window)
        return point_in_rect(window:frame(), pos)
    end)
    return win or window.windowForID(0) or window.windowForID(nil)
end

local dev = hs.hotkey.modal.new(cmd_alt_ctrl, "=", 'Debug Modal')
function dev:entered()
    hs.alert.show('entered Debug modal  <esc> to exit', 5)
end
dev:bind({}, 'escape', 'Quit Debug Modal',
    function()
        dev:exit()
    end)

dev:bind({}, "A", 'Show Window underneath Mouse',
    function()
        local win = window_underneath_mouse()
        print("App: '" .. win:application():title() ..
                "' Window: '" .. win:title() .. "'")
        print(" x:" ..win:frame().x ..
              " y:" ..win:frame().y ..
              " h:" ..win:frame().h ..
              " w:" ..win:frame().w)
        dev:exit()
    end
)
dev:bind({}, "B", 'Show prev Window underneath Mouse',
    function()
        local win = window_underneath_mouse()
        local id = win:id()
        local prev_state = save_window_state[id]

        print("App: '" .. win:application():title() ..
                "' Window: '" .. win:title() .. "'")
        print(" x:" ..win:frame().x ..
              " y:" ..win:frame().y ..
              " h:" ..win:frame().h ..
              " w:" ..win:frame().w)

        if prev_state then
            print(" prev_state.x:" .. prev_state.x ..
                  " prev_state.y:" .. prev_state.y ..
                  " prev_state.h:" .. prev_state.h ..
                  " prev_state.w:" .. prev_state.w)
        else
            print("no prev_state")
        end

        local screen = win:screen()
        local max = screen:frame()
        print(" max.x:" .. max.x ..
              " max.y:" .. max.y ..
              " max.h:" .. max.h ..
              " max.w:" .. max.w)
    end
)

-- debugging tool end

-- Define window layouts
-- {"App name", "Window name", "Display Name", "unitrect", "framerect", "fullframerect"},
local internal_display = {
    {"Safari",        nil,        display_laptop, hs.layout.left70,         nil, nil},
    {"Mail",          nil,        display_laptop, {x=0, y=0, w=0.75, h=0.9}, nil, nil},
    {"IntelliJ IDEA", nil,        display_laptop, {x=0, y=0, w=0.9, h=1},  nil, nil},

    {"Messages",      nil,        display_laptop, {x=0, y=0, w=0.3, h=.3},  nil, nil},
    {"Adium",         "Contacts", display_laptop, {x=0, y=0, w=0.1, h=1},   nil, nil},
    {"iTunes",        "iTunes",   display_laptop, hs.layout.right75, nil},
}

local dual_display = {
    {"Safari",        nil,        display_monitor, hs.layout.left70,        nil, nil},
    {"Mail",          nil,        display_monitor, hs.layout.left70,        nil, nil},
    {"IntelliJ IDEA", nil,        display_monitor, hs.layout.left75,        nil, nil},

    {"Messages",      nil,        display_monitor, {x=0, y=0, w=0.3, h=.3}, nil, nil},
    {"Adium",         "Contacts", display_monitor, {x=0, y=0, w=0.1, h=1},  nil, nil},

    {"iTunes",        "iTunes",   display_laptop,  hs.layout.left75,        nil, nil},
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
    print("usbDeviceCallback: "..hs.inspect(data))

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

            -- Turn on wifi on your macbook from the Mac OSX terminal command line:
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

hs.hotkey.bind(cmd_ctrl, "f5", 'Vertical Resize', vertical_resize)
hs.hotkey.bind(cmd_ctrl, "f6", 'Horizontial Resize', horizontal_resize)
hs.hotkey.bind(cmd_ctrl, 'j', 'Console', hs.toggleConsole)
hs.hotkey.bind(cmd_ctrl, 'a', 'Audio Toggle', toggle_audio_output)
hs.hotkey.bind(cmd_ctrl, 'c', 'Connect VPN', vpn_connect)
hs.hotkey.bind(cmd_ctrl, 'd', 'Disconnect VPN', vpn_disconnect)
hs.hotkey.bind(cmd_ctrl, 'u', 'Paste Current Safari URL', function()
    hs.timer.doAfter(1, typeCurrentSafariURL)
end)
hs.hotkey.bind(cmd_ctrl, "V", 'Paste (simulated keypresses)', function()
    hs.eventtap.keyStrokes(hs.pasteboard.getContents())
end)
hs.hotkey.showHotkeys(cmd_ctrl, 'h')

hs.hotkey.bind({"ctrl"}, ".", 'Window Hints', hs.hints.windowHints)
hs.hotkey.bind(cmd_alt_ctrl, '1', 'Single Monitor Layout', function()
    hs.layout.apply(internal_display)
end)
hs.hotkey.bind(cmd_alt_ctrl, '2', 'Dual Monitor Layout', function()
    hs.layout.apply(dual_display)
end)
hs.hotkey.bind(cmd_alt_ctrl, '0', 'Show watchers', function()
    print(configFileWatcher)
    print(screenWatcher)
    print(usbWatcher)
end)

-- TODO: take what's in the paste buffer and create a gist

-- auto reload when file changes
function reload_config(files)
    doReload = false
    for _,file in pairs(files) do
        if file:sub(-4) == ".lua" then
            doReload = true
        end
    end
    if doReload then
        hs.reload()
    end
end

configFileWatcher = hs.pathwatcher.new(os.getenv("HOME") .. "/.hammerspoon/",
                                       reload_config)
configFileWatcher:start()
hs.notify.new({
    title='Hammerspoon',
    informativeText='Config loaded'
}):send()
