local log = hs.logger.new('keys')
log.i("Loading module")

-- F18 is my Hammer key
-- Then use Hammerspoon to bind f18 to a new modifier key,
-- which we configure with a number of combinations below.
HyperMode = hs.hotkey.modal.new()

function HyperMode:entered()
    log.d("Hammer down")
    self.isDown = true
end

function HyperMode:exited()
    log.d("Hammer up")
    self.isDown = false
end

-- sanity check for accessibility
log.i('Is Hammerspoon enabled under Privacy/Accessibility: ' .. (hs.accessibilityState() and "true" or "false"))
if (hs.eventtap.isSecureInputEnabled()) then
    hs.notify.new({title = 'Hammerspoon',
                   informativeText = '⚠️  Secure input is enabled.',
                   withdrawAfter = 0,
                   otherButtonTitle = "Okay"})
            :send()
end

-- 2022-01-27 "Better" way to capture f18, this way it'll trigger whether or not
-- you already had shift, alt, cmd, etc held down. With hd.hotkey.bind, I'd have
-- to create bindings for all the combinations of modifier keys.
-- 2022-06-23 I mocked it as "better", but it really is better.

-- TODO: https://github.com/Hammerspoon/hammerspoon/issues/2322#issuecomment-599262299
myF18EventTap = hs.eventtap.new({
    hs.eventtap.event.types.flagsChanged,
    hs.eventtap.event.types.keyDown,
    hs.eventtap.event.types.keyUp
}, function(event)
    --log.d('caught key: ' .. event:getKeyCode() .. ' of type: ' .. event:getType())
    if event:getKeyCode() == hs.keycodes.map['f18'] then
        local isRepeat = event:getProperty(hs.eventtap.event.properties.keyboardEventAutorepeat)
        if isRepeat > 0 then
            return true -- ignore and discard
        end
        if event:getType() == hs.eventtap.event.types.keyDown then
            HyperMode:enter()
            return true
        else
            HyperMode:exit()
            return true
        end
    end
end)
myF18EventTap:start()
