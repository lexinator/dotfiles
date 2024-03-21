local cmd_alt_ctrl = {"cmd", "alt", "ctrl"}

-- debugging tool start
local point_in_rect = function(rect, point)
    return  point.x >= rect.x and
            point.y >= rect.y and
            point.x <= rect.x + rect.w and
            point.y <= rect.y + rect.h
end

local window_underneath_mouse = function()
    local pos = hs.mouse.absolutePosition()
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

dev:bind({}, "a", 'Show Window underneath Mouse',
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
dev:bind({}, "b", 'Show prev Window underneath Mouse',
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
