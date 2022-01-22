local ticker = require('tickers/ticker')
local network = require('network/network')

function onInit()
    MP.RegisterEvent("tick", "tick")
    MP.CreateEventTimer("tick", 1000) --start ticking immediately

    MP.RegisterEvent("SendInvite", "sendInvite")
    MP.RegisterEvent("AcceptInvite", "acceptInvite")
    MP.RegisterEvent("RejectInvite", "rejectInvite")

    MP.RegisterEvent("RequestSPStart", "onSPStart")
    MP.RegisterEvent("RequestMPStart", "onMPStart")
    MP.RegisterEvent("RequestPrestageReady", "onPrestageReady")
    MP.RegisterEvent("RequestDSQ", "onDSQ")
    MP.RegisterEvent("RequestCrossedFinishLine", "onCrossedFinishLine")

    MP.RegisterEvent("RequestState", "syncState")
end

--- all fns have to be global to get called by MP.{call} calls
function syncState(playerId, _)
    -- sync state on demand to single player
    network.syncRaceState(state, playerId)
end

function tick()
    ticker.tick()
end
