local log = hs.logger.new('usb', 'debug')
log.d("Loading module")

require("hid-lib")
require("audio-lib")

-- Callback function for USB device events
function usbDeviceCallback(data)
    print("usbDeviceCallback: "..hs.inspect(data))

    -- apple monitor
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

            -- Turn on wifi
            os.execute("networksetup -setairportpower en0 on")
        end
    end

    -- lg monitor
    if (data["productName"] == "LG UltraFine Display Camera" or
            data["productName"] == "Studio Display") then
        event = data["eventType"]

        if (event == "added") then
            -- at a desk with two monitors
            hs.notify.new({
                title="Hammerspoon",
                informativeText="Found LG Display: Disabling wifi",
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

            -- Turn on wifi
            os.execute("networksetup -setairportpower en0 on")
        end
    end


    if (data["productName"] == "Turtle Beach USB Audio") then
        event = data["eventType"]

        if (event == "added") then
            -- at the office desk with USB Audio
            hs.notify.new({
                title="Hammerspoon",
                informativeText="Audio set to TurtleBeach USB Audio",
            }):send()

            hs.audiodevice.defaultOutputDevice():setVolume(15)
            setHeadphones()
        elseif (event == "removed") then
            -- only using laptop monitor
            hs.notify.new({
                title="Hammerspoon",
                informativeText="Audio set to laptop speakers",
            }):send()

            hs.audiodevice.defaultOutputDevice():setVolume(15)
        end
    end

    if (data["productName"] == "Keychron K8") then
        event = data["eventType"]

        if (event == "added") then
            hs.notify.new({
                title="Hammerspoon",
                informativeText="keychron attached - remapping keys",
            }):send()

           RemapKeys()
        end
    end

    if (data["productName"] == "Sennheiser Profile") then
        event = data["eventType"]

        if (event == "added") then
            hs.notify.new({
                title="Hammerspoon",
                informativeText="setting sennheiser microphone as default",
            }):send()
            hs.timer.doAfter(3, setMicrophoneToPreferred)
        end
    end
end

usbWatcher = hs.usb.watcher.new(usbDeviceCallback)
usbWatcher:start()
