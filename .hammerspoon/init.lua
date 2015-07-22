hs.ipc.cliInstall()

save_window_state = {}

local hyper = {"cmd", "ctrl"}
local hyperoption = {"cmd", "alt", "ctrl"}

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

  print("frame.w:" .. frame.w .. " max.w:" .. max.w)

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
    script = [[
    tell application "Safari"
        set currentURL to URL of document 1
    end tell
    return currentURL
    ]]
    ok, result = hs.applescript(script)
    if (ok) then
        hs.eventtap.keyStrokes(result)

--        hs.notify.new({
--          title='Hammerspoon', informativeText=result
--        }):send():release()
    end
end

-- Define monitor names for layout purposes
local display_laptop = "Color LCD"
local display_monitor = "Thunderbolt Display"

-- Defines for screen watcher
local lastNumberOfScreens = #hs.screen.allScreens()

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

local dev = hs.hotkey.modal.new(hyperoption, "=")

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

hs.hotkey.bind(hyper, "f5", vertical_resize)
hs.hotkey.bind(hyper, "f6", horizontal_resize)
hs.hotkey.bind(hyper, 'y', hs.toggleConsole)
hs.hotkey.bind(hyper, 'u', function()
    hs.timer.doAfter(1, typeCurrentSafariURL)
end)
hs.hotkey.bind({"ctrl"}, ".", hs.hints.windowHints)
hs.hotkey.bind(hyperoption, '1', function()
    hs.layout.apply(internal_display)
end)
hs.hotkey.bind(hyperoption, '2', function()
    hs.layout.apply(dual_display)
end)
hs.hotkey.bind(hyper, "V", function()
    hs.eventtap.keyStrokes(hs.pasteboard.getContents())
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
hs.notify.show("Hammerspoon", "", "Config loaded", "")
