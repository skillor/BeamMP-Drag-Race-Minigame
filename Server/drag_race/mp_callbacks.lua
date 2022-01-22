require('state/global_state_handler')
require('ui/messages/messages')

require('models/result')
require('models/race_state')
require('models/dsq')

local flowControl = require('flow_control/flow_control')
local json = require('util/json')

function onSPStart(playerId, _)
    if state.raceType ~= RaceType.none then
        --race taken, deny
        return
    end

    flowControl.startSPRace(playerId)
end

function onMPStart(_, data)
    if state.raceType ~= RaceType.none then
        --race taken, deny
        return
    end

    local tmp = json.decode(data:gsub("&", ":"):gsub("'", ""))
    if (tmp == nil or tmp.id1 == nil or tmp.id2 == nil) then return end

    flowControl.startMPRace(tmp)
end

function onPrestageReady(playerId, _)
    flowControl.onPlayerPrestageReady(playerId)
end

function onDSQ(playerId, reason)
    if DSQReason[reason] == nil then return end

    flowControl.disqualify(playerId, DSQReason[reason])
end

function onCrossedFinishLine(playerId, results)
    local tmp = json.decode(results:gsub("&", ":"):gsub("'", ""))
    if not tmp
            or tmp.time == nil
            or tmp.maxSpeed == nil
            or tmp.vehicleName == nil then return end

    flowControl.markPlayerCrossedFinishLine(playerId, tmp)
end

function sendInvite(_, data)
    local fixed = data:gsub("&", ":"):gsub("'", "")
    local parsed = json.decode(fixed)

    local network = require('network/network')
    network.sendUIMessageToPlayer(
            parsed.player2.id,
            BeamMPMessage:Invite(parsed.player1, fixed)
    )
end
