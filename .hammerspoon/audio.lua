local log = hs.logger.new('audio', 'debug')
log.d("Loading module")

require("audio-lib")

-- device to switch to preferred microphone
local MIC_FORCE_NAME = "AirPods Pro 2nd gen"

function audioDeviceCallback(event)
    if (event == "dIn ") then -- That trailing space is not a mistake
        local defaultInputDevice = hs.audiodevice.defaultInputDevice()
        if (defaultInputDevice:name() ~= MIC_FORCE_NAME) then
            log.f("ignoring input switch of \"%s\" as it's not \"%s\"", defaultInputDevice, MIC_FORCE_NAME)
            return
        end

        setMicrophoneToPreferred()

        local sound = hs.sound.getByName("Funk")
        sound:play()
    end
end

hs.audiodevice.watcher.setCallback(audioDeviceCallback)
hs.audiodevice.watcher.start()

HyperMode:bind({"shift"}, 'p', 'sPeaker Toggle', toggleAudioOutput)
