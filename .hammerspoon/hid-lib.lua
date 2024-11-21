local log = hs.logger.new('hid-lib', 'debug')
log.d("Loading module")

-- Run key remapping script, used in hyper.lua too.
RemapKeys = function()
  log.d("Remapping keys...")
  local cmd = os.getenv("HOME") .. "/bin/hid"
  local output, _, _, rc = hs.execute(cmd)
  hs.hid.capslock.set(false) -- Turn off Caps Lock.
  hs.notify.new({
    title = 'Remapping Keys (running hidutil)...',
    informativeText = rc .. " " .. output,
    withdrawAfter = 3
  }):send()
end
