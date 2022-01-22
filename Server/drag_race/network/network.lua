local json = require('util/json')

local function syncRaceState(state, playerId)
    MP.TriggerClientEvent(playerId or -1, 'SyncRaceState', json.encode(state:toJson()))
end

local function sendUIMessageToPlayer(playerId, beamMPMessage)
    MP.TriggerClientEvent(playerId, 'UIMessage', json.encode(beamMPMessage))
end

return {
    syncRaceState = syncRaceState,
    sendUIMessageToPlayer = sendUIMessageToPlayer,
}
