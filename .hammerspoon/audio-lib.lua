local log = hs.logger.new('audio-lib', 'debug')
log.d("Loading module")

-- Define audio device names for headphone/speaker switching
local workHeadphoneDevice = "Turtle Beach USB Audio"
local laptopSpeakerDevice = "MacBook Pro Speakers"
local lgDevice = "LG UltraFine Display Audio"

-- preferred microphone
local MIC_PREFERRED_NAME = "Sennheiser Profile"

-- Toggle between laptop speakers and turtle beach audio
function toggleAudioOutput()
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

function setHeadphones()
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
        -- log.f("audiodevice: %s", audioDevice:name())
        if (audioDevice:name() == name) then
            microphone = audioDevice
        end
    end

    return microphone
end

function setMicrophoneToPreferred()
    local microphone = findPreferredInput(MIC_PREFERRED_NAME)

    if (microphone == nil) then
        log.f("preferred microphone not found: %s", microphone)
        return
    end

    -- check to see if input is the device we are looking for
    local defaultInputDevice = hs.audiodevice.defaultInputDevice()
    -- skip if preferred is already the default
    if (defaultInputDevice:name() == MIC_PREFERRED_NAME) then
        return
    end

    log.i("Setting microphone to preferred microphone (" .. MIC_PREFERRED_NAME .. ")")
    result = microphone:setDefaultInputDevice()
    if (not result) then
        log.wf("failed to switch default input device to \"%s\"", microphone)
    end
end
