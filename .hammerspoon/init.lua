hs.ipc.cliInstall()

save_window_state = {}

local cmd_ctrl = {"cmd", "ctrl"}
local cmd_alt_ctrl = {"cmd", "alt", "ctrl"}

function vertical_resize()
  local win = hs.window.focusedWindow()
  local frame = win:frame()
  local id = win:id()

  local screen = win:screen()
  local max = screen:frame()

  -- store current size
  if (frame.h + 4 == max.h or frame.h == max.h) and (frame.y == max.y) then
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

--  print("frame.w:" .. frame.w .. " max.w:" .. max.w)

  -- store current size
  if (frame.x + 4 == max.x or frame.x == max.x) and (frame.w == max.w) then
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

-- debugging
local point_in_rect = function(rect, point)
    return  point.x >= rect.x and
            point.y >= rect.y and
            point.x <= rect.x + rect.w and
            point.y <= rect.y + rect.h
end

local window_underneath_mouse = function()
    local pos = hs.mouse.get()
    local win = hs.fnutils.find(hs.window.orderedWindows(), function(window)
        return point_in_rect(window:frame(), pos)
    end)
    return win or window.windowForID(0) or window.windowForID(nil)
end

local dev = hs.hotkey.modal.new(cmd_alt_ctrl, "=")

function dev:entered() hs.alert.show('entered Debug modal  <esc> to exit') end
function dev:exited()  hs.alert.show('exited Debug modal') end
dev:bind({}, 'escape',
    function()
        dev:exit()
    end)

dev:bind({}, "A",
    function()
        local win = window_underneath_mouse()
        print("App: '" .. win:application():title() ..
                "' Window: '" .. win:title() .. "'")
        dev:exit()
    end
)
-- debugging

-- Define window layouts
-- {"App name", "Window name", "Display Name", "unitrect", "framerect", "fullframerect"},
local internal_display = {
    {"Safari",        nil,        display_laptop, hs.layout.left70,         nil, nil},
    {"Mail",          nil,        display_laptop, {x=0, y=0, w=0.75, h=0.9}, nil, nil},
    {"IntelliJ IDEA", nil,        display_laptop, hs.layout.left75,         nil, nil},

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

-- Callback function for changes in screen layout
function screensChangedCallback()
    newNumberOfScreens = #hs.screen.allScreens()

    if lastNumberOfScreens ~= newNumberOfScreens then
        if newNumberOfScreens == 1 then
            hs.layout.apply(internal_display)
        elseif newNumberOfScreens == 2 then
            hs.layout.apply(dual_display)
        end
    end

    lastNumberOfScreens = newNumberOfScreens
--
-- --    renderStatuslets()
-- --    updateStatuslets()
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
            os.execute("/Users/ludeman/bin/vpn vpn --action disconnect")
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

hs.hotkey.bind(cmd_ctrl, "f5", vertical_resize)
hs.hotkey.bind(cmd_ctrl, "f6", horizontal_resize)
hs.hotkey.bind(cmd_ctrl, 'y', hs.toggleConsole)
hs.hotkey.bind(cmd_ctrl, 'a', toggle_audio_output)
hs.hotkey.bind(cmd_ctrl, 'u', function()
    hs.timer.doAfter(1, typeCurrentSafariURL)
end)
hs.hotkey.bind(cmd_ctrl, "V", function()
    hs.eventtap.keyStrokes(hs.pasteboard.getContents())
end)
hs.hotkey.bind(cmd_ctrl, "h", function()
    helpstr = [[
Vertical Resize                    ⌘⌃ F5
Horizonital Resize               ⌘⌃ F6

Console                               ⌘⌃ y

Audio Toggle                       ⌘⌃ a
Paste Current Safari URL   ⌘⌃ u

Window Hints                        ⌃ .

Single Monitor Layout      ⌘⌥⌃ 1
Dual Monitor Layout         ⌘⌥⌃ 2

Paste                                 ⌘⌃ v
Help                                  ⌘⌃ h]]
    hs.alert.show(helpstr, 5)
end)

hs.hotkey.bind({"ctrl"}, ".", hs.hints.windowHints)
hs.hotkey.bind(cmd_alt_ctrl, '1', function()
    hs.layout.apply(internal_display)
end)
hs.hotkey.bind(cmd_alt_ctrl, '2', function()
    hs.layout.apply(dual_display)
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

hs.pathwatcher.new(os.getenv("HOME") .. "/.hammerspoon/",
                   reload_config):start()
hs.notify.new({
    title='Hammerspoon',
    informativeText='Config loaded'
}):send()
