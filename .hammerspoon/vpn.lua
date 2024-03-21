function vpn_connect()
    hs.notify.new({
        title="Hammerspoon",
        informativeText="Connecting vpn...",
    }):send()
    os.execute("/Users/ludeman/bin/tvpn")
end

function vpn_disconnect()
    hs.notify.new({
        title="Hammerspoon",
        informativeText="Disabling vpn...",
    }):send()
    os.execute("/Users/ludeman/bin/tvpn --disconnect")
end

function totp()
    hs.notify.new({
        title="Hammerspoon",
        informativeText="totp...",
    }):send()
    os.execute("/Users/ludeman/bin/tufa | tr -d '\n' | pbcopy")
end

function totp_uat()
    hs.notify.new({
        title="Hammerspoon",
        informativeText="totp uat...",
    }):send()
    os.execute("/Users/ludeman/bin/tufa --LP | sed -e 's/^ //' | tr -d '\n' | pbcopy")
end

-- HyperMode:bind(cmd_ctrl, '1', 'totp', totp)
-- HyperMode:bind(cmd_ctrl, '2', 'totp uat', totp_uat)

HyperMode:bind({}, 'c', 'Connect VPN', vpn_connect)
