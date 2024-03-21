local log = hs.logger.new('config', 'debug')
log.d("Loading module")

-- auto reload when file changes
function reload_config(files, flags)
    doReload = false
    -- log.d("flags: " .. flags)

    for eventType, file in pairs(files) do
        log.d("looking at (" .. eventType ..") " .. file)


        if file:sub(-4) == ".lua" then
            doReload = true
        end
    end

    if doReload then
        hs.reload()
    end
end
configFileWatcher = hs.pathwatcher.new(
        os.getenv("HOME") .. "/.hammerspoon/",
        reload_config
)
configFileWatcher:start()
