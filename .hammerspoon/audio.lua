local log = hs.logger.new('audio', 'debug')
log.d("Loading module")

-- Define audio device names for headphone/speaker switching
local workHeadphoneDevice = "Turtle Beach USB Audio"
local laptopSpeakerDevice = "MacBook Pro Speakers"
local lgDevice = "LG UltraFine Display Audio"

-- preferred microphone
local MIC_PREFERRED_NAME = "Sennheiser Profile"
-- device to switch to preferred microphone
local MIC_FORCE_NAME = "AirPods Pro 2nd gen"

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

function findPreferredInput(name)
    local allDevices = hs.audiodevice.allInputDevices()
    local microphone = nil
    for _, audioDevice in pairs(allDevices) do
        if (audioDevice:name() == name) then
            microphone = audioDevice
        end
    end

    return microphone
end

function audioDeviceCallback(event)
    -- log.f('audioDeviceCallback: "%s"', event)
    if (event == "dIn ") then -- That trailing space is not a mistake
        local microphone = findPreferredInput(MIC_PREFERRED_NAME)

        -- preferred microphone not found so bail
        if (microphone == nil) then
            log.w("preferred microphone (" .. MIC_PREFERRED_NAME .. ") not found")
            return
        end

        -- check to see if input is the device we are looking for
        local defaultInputDevice = hs.audiodevice.defaultInputDevice()
        -- skip if preferred is already the default
        if (defaultInputDevice:name() == MIC_PREFERRED_NAME) then
            return
        end

        -- log default has switched
        if (defaultInputDevice:name() ~= MIC_FORCE_NAME) then
            log.f("ignoring input switch of \"%s\" as it's not \"%s\"", defaultInputDevice, MIC_FORCE_NAME)
            return
        end

        log.i("Setting microphone to preferred microphone (" .. MIC_PREFERRED_NAME .. ")")
        result = microphone:setDefaultInputDevice()
        if (not result) then
            log.wf("failed to switch default input device to \"%s\"", microphone)
        end

        local sound = hs.sound.getByName("Funk")
        sound:play()
    end
end

hs.audiodevice.watcher.setCallback(audioDeviceCallback)
hs.audiodevice.watcher.start()

HyperMode:bind({"shift"}, 'p', 'sPeaker Toggle', toggle_audio_output)
