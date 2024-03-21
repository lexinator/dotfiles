save_window_state = {}

-- Defines for window grid
hs.grid.GRIDWIDTH = 6
hs.grid.GRIDHEIGHT = 6
hs.grid.MARGINX = 0
hs.grid.MARGINY = 0

function vertical_resize()
  local win = hs.window.focusedWindow()
  local frame = win:frame()
  local id = win:id()

  local screen = win:screen()
  local max = screen:frame()

  if (frame.h >= max.h - 10 or frame.h >= max.h) and frame.y == max.y then
      -- window is at max, if previous state exists revert
      local prev_state = save_window_state[id]
      if prev_state then
        frame.x = prev_state.x
        frame.y = prev_state.y
        frame.h = prev_state.h
        frame.w = prev_state.w

        win:setFrame(frame, 0)
      else
        -- if no previous state, shrink it by 50%
        frame.h = frame.h / 2
        win:setFrame(frame, 0)
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

      win:setFrame(frame, 0)
  end
end

function horizontal_resize()
  local win = hs.window.focusedWindow()
  local frame = win:frame()
  local id = win:id()

  local screen = win:screen()
  local max = screen:frame()

  if (frame.w >= max.w - 10 or frame.w >= max.w) and frame.x == max.x then
      -- window is at max, if previous state exists revert
      local prev_state = save_window_state[id]
      if prev_state then
        frame.x = prev_state.x
        frame.y = prev_state.y
        frame.h = prev_state.h
        frame.w = prev_state.w

        win:setFrame(frame, 0)
      else
        -- if no previous state, shrink it by 50%
        frame.w = frame.w / 2
        win:setFrame(frame, 0)
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

      win:setFrame(frame, 0)
  end
end

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

-- vim: foldmethod=marker
