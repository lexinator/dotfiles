local log = hs.logger.new('lights', 'info')
log.i("Loading module")

on = "neewerlite://turnOnLight"
defaultLightLevel = "neewerlite://setLightCCT?CCT=4500&GM=0&Brightness=10"
off = "neewerlite://turnOffLight"

function minimizeNeeewer()
    hs.application.launchOrFocus("NeewerLite")
    local neewerlite = hs.appfinder.appFromName("NeewerLite")

    neewerlite:hide()
end

HyperMode:bind({}, 'o', function()
    log.d("Turning on the lights...")

    hs.execute(string.format("/usr/bin/open '%s'", on))
    hs.execute(string.format("/usr/bin/open '%s'", defaultLightLevel))
    minimizeNeeewer()

    HyperMode:exit()
end)

HyperMode:bind({"shift"}, 'o', function()
    log.d("Turning off the lights...")

    hs.execute(string.format("/usr/bin/open '%s'", off))

    minimizeNeeewer()
    HyperMode:exit()
end)
