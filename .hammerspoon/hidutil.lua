local log = hs.logger.new('hidutil', 'debug')
log.d("Loading module")

require("hid-lib")

-- Always re-remap keys on some events.
RemapKeyWatcher = hs.caffeinate.watcher.new(function(event)
  local eventsToMatch = {
    [hs.caffeinate.watcher.systemDidWake] = true, -- 0
    [hs.caffeinate.watcher.systemWillSleep] = false, -- 1
    [hs.caffeinate.watcher.systemWillPowerOff] = false, -- 2
    [hs.caffeinate.watcher.screensDidSleep] = false, -- 3
    [hs.caffeinate.watcher.screensDidWake] = false, -- 4
    [hs.caffeinate.watcher.sessionDidResignActive] = false, -- 5
    [hs.caffeinate.watcher.sessionDidBecomeActive] = true, -- 6
    [hs.caffeinate.watcher.screensaverDidStart] = false, -- 7
    [hs.caffeinate.watcher.screensaverWillStop] = false, -- 8
    [hs.caffeinate.watcher.screensaverDidStop] = false, -- 9
    [hs.caffeinate.watcher.screensDidLock] = false, -- 10
    [hs.caffeinate.watcher.screensDidUnlock] = true -- 11
  }
  -- Check event number against commented numbers above.
  log.d('Event: ', event, ' matches: ', eventsToMatch[event])
  if eventsToMatch[event] then
    log.d("RemapKeyWatcher found matching event: " .. event)
    RemapKeys()
    HyperMode:reset()
  end
end)
RemapKeyWatcher:start()

-- CapsLock -> Run hidutil script to re-apply key mappings.
hs.hotkey.bind({}, 'capslock', RemapKeys)
